{ stdenv
, lib
, writeScript
, bash
, zig
, git
, shim
}: let
  # The shim can't execute the compiler directly because it's a Linux ELF executable.
  # Instead, it calls a BASH script which the Wine cmd.exe implementation
  # recognizes as a Linux executable, and is able to execute.
  # This 'runner" accepts parameters via the command-line and executes the cross compiler.
  runner = writeScript "sierrachart-zig-msvc-shim-runner.sh" ''
    #!${bash}/bin/bash
    # USAGE: zig-msvc-shim-runner [-v] [-d] -o outputDLL -s sourceFile1 -s sourceFile2 ...

    pid=$$
    pidFile="$WINEPREFIX/drive_c/windows/temp/msvc-shim.pid"
    dllFile=""
    sourceFiles=""
    verbose=""
    extra="-O2"
    gitCommitHash=""
    macros=""

    function echoWhenVerbose() {
      if [ -n "$verbose" ]
      then
        echo "zig-msvc-shim-runner: $1"
      fi
    }

    echo -n $pid > $pidFile

    while getopts :do:s: flag
    do
      case "''${flag}" in
        d) extra="-g -gdwarf-2 -O0 --verbose";;
        o) dllFile=$(eval echo ''${OPTARG});;
        s) sourceFiles="$sourceFiles $(eval echo ''${OPTARG})";;
      esac
    done

    if [ -d $WINEPREFIX/drive_c/SierraChart/ACS_Source/.git ]
    then
      gitCommitHash=$(${git}/bin/git -C $WINEPREFIX/drive_c/SierraChart/ACS_Source/ rev-parse --short HEAD)
      macros="-DSHORT_COMMIT_HASH=\"$gitCommitHash\""
    fi

    echoWhenVerbose "Source files: $sourceFiles"
    echoWhenVerbose "DLL file: $dllFile"
    echoWhenVerbose "GIT commit hash: $gitCommitHash"

    ${zig}/bin/zig c++ -x c++ -shared -static -std=c++17 -target x86_64-windows -ffp-model=precise $extra $macros $sourceFiles -o $dllFile 2>&1
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
