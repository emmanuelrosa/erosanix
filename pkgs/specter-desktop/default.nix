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
    version = "2.0.1";

    src = fetchurl {
      url = "https://github.com/cryptoadvance/specter-desktop/releases/download/v${version}/specter_desktop-v${version}-x86_64-linux-gnu.tar.gz";
      sha256 = "1ivzxbfmhnisb4harq07isxdggf9n3vpsi4jl9h9fgbkly24d5vf";
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

      mkdir -p $out/appdir
      mkdir -p $out/bin
      mkdir -p $out/lib
      mkdir -p $out/etc/udev/rules.d

      cp -r squashfs-root/* $out/appdir
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
