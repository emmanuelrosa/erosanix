{ stdenv
, lib
, fetchurl
, appimageTools
, autoPatchelfHook
, imagemagick
, gnused
, libdrm
, libGL
, freetype
, fontconfig
, mesa
, zlib
, libuuid
, libgpg-error
, xorg
, hwi
}: let
  pname = "blockstream-green";
  version = "1.2.0"; #:version:#

  icons = stdenv.mkDerivation {
    inherit version;
    pname = "${pname}-icons";
    nativeBuildInputs = [ imagemagick ];
    dontUnpack = true;

    src = blockstream-green-extracted;

    installPhase = ''
      for n in 16 24 32 48 64 96 128 256; do
        size=$n"x"$n
        mkdir -p $out/hicolor/$size/apps
        convert $src/green.png -resize $size $out/hicolor/$size/apps/green.png
      done;
    '';
  };

  blockstream-green-extracted = appimageTools.extractType2 {
    name = "${pname}-extracted";

    src = fetchurl {
      url = "https://github.com/Blockstream/green_qt/releases/download/release_${version}/BlockstreamGreen-x86_64.AppImage";
      sha256 = "0bpxihh2q2rr62z1al7nbmqmsbvd55lq78fg3hf2rl0vdwzqkr8d"; #:hash:
    };
  };
in stdenv.mkDerivation {
  inherit pname version;
  src = blockstream-green-extracted;
  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libdrm
    libGL
    freetype
    fontconfig
    mesa
    zlib
    libuuid
    libgpg-error
  ] ++ (with xorg; [
    libX11
    libxcb
  ]);

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib
    mkdir -p $out/share/applications
    mkdir -p $out/etc/udev/rules.d
    cp $src/usr/bin/green $out/bin/${pname}
    cp $src/usr/lib/* $out/lib/
    ln -s ${icons} $out/share/icons
    cp "$src/usr/share/applications/green.desktop" $out/share/applications/${pname}.desktop
    ${gnused}/bin/sed -i 's/Exec=green/Exec=${pname}/' $out/share/applications/${pname}.desktop
    cp ${hwi}/lib/python*/site-packages/hwilib/udev/55-usb-jade.rules $out/etc/udev/rules.d/
    cp ${hwi}/lib/python*/site-packages/hwilib/udev/20-hw1.rules $out/etc/udev/rules.d/

    runHook postInstall
  '';

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
