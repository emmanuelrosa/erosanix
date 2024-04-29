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
, pulseaudio
, hwi
, xcb-util-cursor
, gnupg
}: stdenv.mkDerivation rec {
  pname = "blockstream-green";
  version = "2.0.4"; #:version:#

  src = fetchurl {
    url = "https://github.com/Blockstream/green_qt/releases/download/release_${version}/BlockstreamGreen-Linux-x86_64.tar.gz";
    sha256 = "0qhy2qnanq0mfhhcq8n46c52ncacwynf499v6wr91yqrjg1fclrm"; #:hash:

    nativeBuildInputs = [ gnupg ];
    downloadToTemp = true;

    postFetch = ''
      pushd $(mktemp -d)
      export GNUPGHOME=./gnupg
      mkdir -m 700 -p $GNUPGHOME
      ln -s $downloadedFile ./BlockstreamGreen-Linux-x86_64.tar.gz
      ln -s ${manifest} ./manifest.asc
      gpg --import ${publicKey}
      gpg --verify manifest.asc
      sha256sum -c --ignore-missing manifest.asc
      popd
      mv $downloadedFile $out
    '';
  };

  # Blockstream's GPG key was obtained from 
  # https://blockstream.com/pgp.txt
  publicKey = ./pubkey.asc;

  manifest = fetchurl {
    url = "https://github.com/Blockstream/green_qt/releases/download/release_${version}/SHA256SUMS.asc";
    sha256 = "sha256-VVsYPXCltw/R1g4HOA+9l9PzxWGKKAO2NbVOzYjb2Mg=";
  };

  setSourceRoot = ''
    mkdir source
    mv green source/
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
  ]) ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
  ]);

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/etc/udev/rules.d
    install green $out/bin/${pname}
    cp ${hwi}/lib/python*/site-packages/hwilib/udev/55-usb-jade.rules $out/etc/udev/rules.d/
    cp ${hwi}/lib/python*/site-packages/hwilib/udev/20-hw1.rules $out/etc/udev/rules.d/

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Blockstream Green";
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
    description = "A multi-platform, feature-rich Bitcoin and Liquid wallet. Note: To use a Blockstream JADE or Ledger Nano S hardware wallet on NixOS you need to add the udev rules: `services.udev.packages = [ blockstream-green ]`";
    homepage = "https://blockstream.com/green/";
    sourceProvenance = with sourceTypes; [
      binaryNativeCode
    ];
    license = licenses.gpl3;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
