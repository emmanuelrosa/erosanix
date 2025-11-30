{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, makeWrapper
, qt6
, kdePackages
, gnupg
, squashfsTools
, e2fsprogs
, hwi
, enableHWI ? false
}: stdenv.mkDerivation rec {
  pname = "blockstream";
  version = "2.0.31"; #:version:#
  archiveName = "Blockstream-x86_64.AppImage";

  src = fetchurl {
    url = "https://github.com/Blockstream/green_qt/releases/download/release_${version}/${archiveName}";
    sha256 = "sha256-7sKkfKQmc50O+V257zUhaYfKYmoGz8fg0KCY80efxP4="; #:hash:

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
    sha256 = "sha256-ihGKu4IQBp95Qeo5vdRTQh/N8A5i20Fl3HRsTFCd0Ns=";
  };

  # Based on nixpkgs/pkgs/build-support/appimage/appimage-exec.sh
  unpackCmd = ''
    offset=$(LC_ALL=C readelf -h "$curSrc" | awk 'NR==13{e_shoff=$5} NR==18{e_shentsize=$5} NR==19{e_shnum=$5} END{print e_shoff+e_shentsize*e_shnum}')
    echo "Extracting squashfs filesystem at offset $offset."
    unsquashfs -q -d "squashfs-root" -o "$offset" "$curSrc"
  '';

  nativeBuildInputs = [ autoPatchelfHook squashfsTools qt6.wrapQtAppsHook ];

  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : /run/current-system/sw/lib"
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtserialport
    qt6.qtconnectivity
    kdePackages.qtmultimedia
    kdePackages.qtdeclarative
    e2fsprogs
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    cp -r ./usr/bin $out/
    cp -r ./usr/share $out/
    cp -r ./usr/qml $out/

    ${lib.optionalString enableHWI "mkdir -p $out/etc/udev/rules.d"}
    ${lib.optionalString enableHWI "ln -s ${hwi}/bin/hwi $out/bin/hwi"}
    ${lib.optionalString enableHWI "cp ${hwi}/lib/python*/site-packages/hwilib/udev/55-usb-jade.rules $out/etc/udev/rules.d/"}
    ${lib.optionalString enableHWI "cp ${hwi}/lib/python*/site-packages/hwilib/udev/20-hw1.rules $out/etc/udev/rules.d/"}

    runHook postInstall
  '';

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
