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
}: stdenv.mkDerivation rec {
  pname = "blockstream-green";
  version = "2.0.1"; #:version:#

  src = fetchurl {
    url = "https://github.com/Blockstream/green_qt/releases/download/release_${version}/BlockstreamGreen-Linux-x86_64.tar.gz";
    sha256 = "0jr64ncpwn9q8dgjyn1i9jqlvz77apxfaq2fjd83cjzi8xgyf482"; #:hash:
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
      sha256 = "0y808kcv53bvlkw2ha9w8a8fnl01y24i5jgfmw54iv9hlskr7l65";
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
