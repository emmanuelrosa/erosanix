{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, glib
, dbus
, libdrm
, freetype
, fontconfig
, zlib
, libgpg-error
, xorg
, libxkbcommon
, gst_all_1
, mesa
, pulseaudio
, hwi
, xcb-util-cursor
, gnupg
}: stdenv.mkDerivation rec {
  pname = "blockstream";
  version = "2.0.28"; #:version:#
  archiveName = "Blockstream-linux-x86_64.tar.gz";

  src = fetchurl {
    url = "https://github.com/Blockstream/green_qt/releases/download/release_${version}/${archiveName}";
    sha256 = "1cd9kwxyx31gwa53d6pml6nv6bvbpvzsiaqs66ijv2rhmv9jiv19"; #:hash:

    nativeBuildInputs = [ gnupg ];
    downloadToTemp = true;

    postFetch = ''
      pushd $(mktemp -d)
      export GNUPGHOME=./gnupg
      mkdir -m 700 -p $GNUPGHOME
      ln -s $downloadedFile ./${archiveName}
      ln -s ${manifest} ./manifest.asc
      gpg --import ${publicKey}
      gpg --verify manifest.asc
      sha256sum -c --ignore-missing manifest.asc
      popd
      mv $downloadedFile $out
    '';
  };

  # Blockstream's GPG key was obtained as follows: 
  # gpg --keyserver keyserver.ubuntu.com --recv-keys "04BE BF2E 35A2 AF2F FDF1 FA5D E7F0 54AA 2E76 E792"
  # See https://help.blockstream.com/hc/en-us/articles/900002174043-How-do-I-verify-the-Blockstream-Green-binaries
  publicKey = ./pubkey.asc;

  manifest = fetchurl {
    url = "https://github.com/Blockstream/green_qt/releases/download/release_${version}/SHA256SUMS.asc";
    sha256 = "sha256-E9z1ez9Tir9XCW3+gDxANe/lawnenqqldnuEzNyW0a0=";
  };

  setSourceRoot = ''
    mkdir source
    mv blockstream source/
    sourceRoot=source
  '';

  nativeBuildInputs = [ autoPatchelfHook copyDesktopItems copyDesktopIcons ];

  buildInputs = [
    libdrm
    freetype
    fontconfig
    zlib
    libgpg-error
    glib
    dbus
    libxkbcommon
    xcb-util-cursor
  ] ++ (with xorg; [
    libX11
    libxcb
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilwm
    xcbutilimage
    pulseaudio
    libXrandr
  ]) ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    mesa
  ]);

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/etc/udev/rules.d
    install blockstream $out/bin/${pname}
    cp ${hwi}/lib/python*/site-packages/hwilib/udev/55-usb-jade.rules $out/etc/udev/rules.d/
    cp ${hwi}/lib/python*/site-packages/hwilib/udev/20-hw1.rules $out/etc/udev/rules.d/

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Blockstream";
      categories = ["Office" "Finance"];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = fetchurl {
      url = "https://github.com/Blockstream/green_qt/raw/release_${version}/assets/icons/green.png";
      sha256 = "sha256-xdCTp6Yw7UgKr+7JEonwAVDrkEI8KSj4pHuNstlEAHk=";
    };
  };

  meta = with lib; {
    description = "A multi-platform, feature-rich Bitcoin and Liquid wallet. Note: To use a Blockstream JADE or Ledger Nano S hardware wallet on NixOS you need to add the udev rules: `services.udev.packages = [ blockstream ]`";
    homepage = "https://blockstream.com/app/";
    sourceProvenance = with sourceTypes; [
      binaryNativeCode
    ];
    license = licenses.gpl3;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
