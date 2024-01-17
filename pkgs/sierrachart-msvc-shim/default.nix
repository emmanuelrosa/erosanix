{ stdenv
, lib
, runCommand
, fetchurl
, writeScript
, bash
, libarchive
, zig
}: let
  shim-cpp = ./shim.cpp;

  # It can take a while to build the shim due to
  # the need to build some libraries first.
  # Therefore, I'm putting the shim build in a 
  # separate derivation.
  shim = runCommand "cl.exe" { } ''
    export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
    export ZIG_LOCAL_CACHE_DIR=$(mktemp -d)
    ${zig}/bin/zig c++ -x c++ -std=c++20 -target x86_64-windows ${shim-cpp} -o $out
  '';

  mingw-src = fetchurl {
    url = "https://github.com/brechtsanders/winlibs_mingw/releases/download/13.1.0-11.0.0-msvcrt-r5/winlibs-x86_64-mcf-seh-gcc-13.1.0-mingw-w64msvcrt-11.0.0-r5.zip";
    sha256 = "1qal22px4bs3p52c1kqxf7m15hbk2kfd0wi7hgljx2ava9cnb8cw";
  };

  mingw = runCommand "mingw" { } ''
    mkdir -p $out
    ${libarchive}/bin/bsdtar --strip-components=1 -xf ${mingw-src} -C $out
  '';

  # The Sierra Chart Nix package will execute this installer
  # after installing Sierra Chart.
  # This installer installs the shim (cl.exe) in C:\windows
  # so that it's in the Windows PATH, and it symlinks mingw
  # which is extracted in the Nix store.
  # The shim is hard-coded to execute g++ at C:\mingw\bin\g++.exe
  installer = writeScript "sierrachart-msvc-shim-installer" ''
    #!${bash}/bin/bash

    if [ -e $WINEPREFIX/drive_c/mingw ]
    then
      rm -fR $WINEPREFIX/drive_c/mingw
    fi

    if [ -e $WINEPREFIX/drive_c/windows/cl.exe ]
    then
      rm $WINEPREFIX/drive_c/windows/cl.exe
    fi

    ln -s ${mingw} $WINEPREFIX/drive_c/mingw
    ln -s ${shim} $WINEPREFIX/drive_c/windows/cl.exe
  '';
in stdenv.mkDerivation {
  name = "mingw-sierrachart-msvc-shim";
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
    description = "A Microsoft Visual C++ compiler shim for Sierra Chart.";
    longDescription = "Used with the Sierra Chart Nix package to substitute MSVC MingWG, to compile studies.";
    homepage = "https://github.com/emmanuelrosa/erosanix";
    license = licenses.gpl2;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };

}
