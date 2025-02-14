{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, libepoxy
, gtk3
, gnupg
, gawk
, binutils
, squashfsTools
}: stdenv.mkDerivation rec {
  pname = "sideswap";
  version = "1.6.1"; #:version:#
  appImageName = "SideSwap.AppImage";

  src = fetchurl {
    url = "https://github.com/sideswap-io/sideswapclient/releases/download/v${version}/${appImageName}";
    sha256 = "0d154a40ac11e2fa325bc28c8b59a5fdafff05b410d65a04fdc743f0ebc2d642"; #:hash:

    nativeBuildInputs = [ gnupg ];
    downloadToTemp = true;

    postFetch = ''
      pushd $(mktemp -d)
      export GNUPGHOME=./gnupg
      mkdir -m 700 -p $GNUPGHOME
      ln -s $downloadedFile ./${appImageName}
      ln -s ${manifest} ./manifest.asc
      gpg --import ${publicKey}
      gpg --verify manifest.asc
      sha256sum -c --ignore-missing manifest.asc
      popd
      mv $downloadedFile $out
    '';
  };

  # Based on nixpkgs/pkgs/build-support/appimage/appimage-exec.sh
  unpackCmd = ''
    offset=$(LC_ALL=C readelf -h "$curSrc" | awk 'NR==13{e_shoff=$5} NR==18{e_shentsize=$5} NR==19{e_shnum=$5} END{print e_shoff+e_shentsize*e_shnum}')
    echo "Extracting squashfs filesystem at offset $offset."
    unsquashfs -q -d "squashfs-root" -o "$offset" "$curSrc"
  '';

  # Downloaded from https://sideswap.io/resource/sideswap.gpg.txt
  publicKey = ./pubkey.asc;

  manifest = fetchurl {
    url = "https://github.com/sideswap-io/sideswapclient/releases/download/v${version}/SHA256SUMS.asc";
    sha256 = "63f6378d4cc921684d1e9b291209b42769e0d0d62ca204992131966bb3d22097";
  };

  nativeBuildInputs = [ gawk squashfsTools binutils autoPatchelfHook copyDesktopItems copyDesktopIcons ];

  buildInputs = [
    libepoxy
    gtk3
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/sideswap
    mkdir -p $out/opt/sideswap/data
    mkdir -p $out/opt/sideswap/lib
    mkdir -p $out/bin

    cp sideswap $out/opt/sideswap/
    cp -R data $out/opt/sideswap/
    cp lib/*.so $out/opt/sideswap/lib/
    ln -s $out/opt/sideswap/sideswap $out/bin/sideswap
    ln -s $out/opt/sideswap/lib $out/lib

    patchelf --add-needed libsideswap_client.so $out/opt/sideswap/sideswap
    patchelf --add-rpath $out/opt/sideswap/lib $out/opt/sideswap/sideswap

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "SlideSwap";
      categories = ["Office" "Finance"];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = fetchurl {
      url = "https://github.com/sideswap-io/sideswapclient/raw/v${version}/assets/icon/icon.png";
      sha256 = "sha256-gITXbxMPc6tupF67WCka/bfTyyGXPokrW04sfCoVO5k=";
    };
  };

  meta = with lib; {
    description = "A Liquid Bitcoin exchange and wallet.";
    homepage = "https://sideswap.io";
    sourceProvenance = with sourceTypes; [
      binaryNativeCode
    ];
    license = licenses.gpl3;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
