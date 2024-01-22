{ stdenv
, lib
, runCommand
, writeScript
, bash
, zig
}: let
  shim-cpp = ./shim.cpp;

  # It can take a while to build the shim with Zig/clang due to the need to build some Windows libraries first.
  # Therefore, I put the shim build in a separate derivation.
  shim = runCommand "cl.exe" { } ''
    export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
    export ZIG_LOCAL_CACHE_DIR=$(mktemp -d)
    ${zig}/bin/zig c++ -x c++ -std=c++20 -target x86_64-windows ${shim-cpp} -o $out
  '';

  # The shim can't execute the compiler directly because it's a Linux ELF executable.
  # Instead, it calls a BASH script which the Wine cmd.exe implementation
  # recognizes as a Linux executable, and is able to execute.
  # This 'runner" accepts parameters via the command-line,
  # converts the Windows paths to unix paths, and executes the cross compiler.
  runner = writeScript "sierrachart-zig-msvc-shim-runner.sh" ''
    #!${bash}/bin/bash
    # USAGE: zig-msvc-shim-runner [-v] [-d] -o outputDLL -s sourceFile1 -s sourceFile2 ...

    pid=$$
    pidFile="$WINEPREFIX/drive_c/windows/temp/msvc-shim.pid"
    dllFile=""
    sourceFiles=""
    verbose=""
    debug=""

    # Convert paths like C:\SierraChart\ACS_Souce\file.cpp to $WINEPREFIX/drive_c/SierraChart/ACS_Source/file.cpp
    function convertPath() {
      a=$(echo ''${1/#C:/})
      b=$(echo ''${a/#Z:/})
      c=$(echo ''${b//\\//})
      echo "$WINEPREFIX/drive_c$c"
    }

    function echoWhenVerbose() {
      if [ -n "$verbose" ]
      then
        echo "zig-msvc-shim-runner: Source files: $sourceFiles"
      fi
    }

    echo -n $pid > $pidFile

    while getopts :vdo:s: flag
    do
      case "''${flag}" in
        v) verbose="--verbose";;
        d) debug="-g";;
        o) dllFile=$(convertPath ''${OPTARG});;
        s) sourceFiles="$sourceFiles $(convertPath ''${OPTARG})";;
      esac
    done

    echoWhenVerbose "zig-msvc-shim-runner: Source files: $sourceFiles"
    echoWhenVerbose "zig-msvc-shim-runner: DLL file: $dllFile"

    ${zig}/bin/zig c++ -x c++ -shared -static -std=c++17 -target x86_64-windows $verbose $debug $sourceFiles -o $dllFile 2>&1
  '';

  # The Sierra Chart Nix package will execute this installer
  # after installing Sierra Chart.
  # This installer installs the shim (cl.exe) in C:\windows
  # so that it's in the Windows PATH.
  installer = writeScript "sierrachart-zig-msvc-shim-installer" ''
    #!${bash}/bin/bash

    if [ -e $WINEPREFIX/drive_c/msvc-shim/runner.sh ]
    then
      rm $WINEPREFIX/drive_c/msvc-shim/runner.sh
    fi

    if [ -e $WINEPREFIX/drive_c/windows/cl.exe ]
    then
      rm $WINEPREFIX/drive_c/windows/cl.exe
    fi

    mkdir -p $WINEPREFIX/drive_c/msvc-shim
    ln -s ${shim} $WINEPREFIX/drive_c/windows/cl.exe
    ln -s ${runner} $WINEPREFIX/drive_c/msvc-shim/runner.sh
  '';
in stdenv.mkDerivation {
  name = "sierrachart-zig-msvc-shim";
  outputs = [ "out" "shim" "installer" ];
  src = ./.;

  installPhase = ''
    mkdir -p $out/libexec
    ln -s ${shim} $out/libexec/cl.exe
    ln -s ${installer} $out/libexec/installer.bash
    cp ${shim} $shim
    cp ${installer} $installer
  '';

  meta = with lib; {
    description = "A Microsoft Visual C++ compiler shim for Sierra Chart, implemented with Zig/clang";
    longDescription = "Used with the Sierra Chart Nix package to compile studies with Zig/clang.";
    homepage = "https://github.com/emmanuelrosa/erosanix";
    license = licenses.gpl2;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };

}
