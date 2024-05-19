# Be aware that Specter wallet downloads the specterd (daemon) in realtime; I don't like this at all.
# That downloaded binary is the reason why this package runs Specter in a FHS environment.
# I also had to manually edit it's configuration to get it to connect to a local Electrum server.
# This package essentially takes the upstream AppImage and smashes it to get the goods.
# Then it just uses Electron from Nixpkgs to run the app.
{ stdenv
, lib
, fetchurl
, patchelf
, buildFHSUserEnvBubblewrap
, zlib
, electron
, writeScript
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, bash
}: let
  launcher = writeScript "specter-launcher" ''
    #! ${bash}/bin/bash

    ${electron}/bin/electron @out@/appdir/resources/app.asar
  '';

  unwrapped = stdenv.mkDerivation rec {
    pname = "specter-desktop-unwrapped";
    version = "2.0.4-pre2"; #:version:#

    src = fetchurl {
      url = "https://github.com/cryptoadvance/specter-desktop/releases/download/v${version}/specter_desktop-v${version}-x86_64-linux-gnu.tar.gz";
      sha256 = "19d50iavbqs2gaja6pr1cwvicr9vgnh19g2dm536j1c6d713yic4"; #:hash:#
    };

    nativeBuildInputs = [ patchelf zlib copyDesktopItems copyDesktopIcons ];

    preUnpack = ''
      mkdir specter
    '';

    postUnpack = ''
      mv Specter-${version}.AppImage specter/
      mv udev specter/
    '';

    sourceRoot = "specter";

    buildPhase = ''
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath ${zlib}/lib Specter-${version}.AppImage
      chmod u+x Specter-${version}.AppImage
      ./Specter-${version}.AppImage --appimage-extract
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/appdir/resources
      mkdir -p $out/bin
      mkdir -p $out/lib
      mkdir -p $out/etc/udev/rules.d

      cp squashfs-root/resources/app.asar $out/appdir/resources/
      install -D -m 777 ${launcher} $out/bin/specter-desktop
      substituteAllInPlace $out/bin/specter-desktop
      cp udev/*.rules $out/etc/udev/rules.d

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "specter-desktop";
        exec = "specter-desktop";
        icon = "specter-desktop";
        desktopName = "Specter";
        startupWMClass = "Specter";
        genericName = "Bitcoin Wallet";
        categories = [ "Finance" "Network" ];
      })
    ];

    desktopIcon = makeDesktopIcon {
      name = "specter-desktop";

      src = fetchurl {
        url = "https://github.com/cryptoadvance/specter-desktop/raw/v${version}/src/cryptoadvance/specter/static/img/icon.png";
        sha256 = "0k7sw9gx86l97k03z1d9w1wrddhwlfzbbl7sg7v3h555wh8w0kcx";
      };
    };

    meta = with lib; {
      description = "A desktop GUI for Bitcoin Core optimised to work with hardware wallets";
      homepage = "https://specter.solutions/";
      sourceProvenance = with sourceTypes; [
        binaryNativeCode
      ];
      license = licenses.mit;
      maintainers = with maintainers; [ emmanuelrosa ];
      platforms = [ "x86_64-linux" ];
    };
  };

in buildFHSUserEnvBubblewrap {
  name = "specter-desktop";
  runScript = "specter-desktop";

  targetPkgs = pkgs: with pkgs; [
    unwrapped
    zlib
    libusb
  ];

  extraInstallCommands = ''
    mkdir -p $out
    ln -s ${unwrapped}/share $out/
    ln -s ${unwrapped}/etc $out/
  '';

  meta = unwrapped.meta;
}
