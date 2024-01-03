{ stdenv
, lib
, fetchurl
, dpkg
, makeDesktopIcon
, copyDesktopIcons
, autoPatchelfHook
, xorg
, libGL
, openssl
, fontconfig
, dbus
, pipewire
}: stdenv.mkDerivation rec {
  name = "gossip";
  version = "0.9.0"; #:version:

  nativeBuildInputs = [ dpkg copyDesktopIcons autoPatchelfHook stdenv.cc.cc.libgcc ];
  runtimeDependencies = [ xorg.libX11 
                          xorg.libXcursor
                          xorg.libXrandr
                          xorg.libXi
                          xorg.libxcb
                          xorg.libXau
                          xorg.libXdmcp
                          xorg.libXext
                          xorg.libXfixes
                          xorg.libXrender
                          dbus
                          pipewire
                          libGL
                          openssl 
                          fontconfig 
                        ];

  src = fetchurl {
    url = "https://github.com/mikedilger/gossip/releases/download/v${version}/gossip_${version}_amd64.deb";
    sha256 = "0b6jkz6wggck8smrhkcjlcb2h6q4b2hp7kmx0vm0npyn1b60lxl3"; #:hash:
  };

  unpackPhase = ''
    dpkg -x $src .
  '';

  desktopIcon = makeDesktopIcon {
    inherit name;

    src = fetchurl {
      url = "https://github.com/mikedilger/gossip/raw/v${version}/gossip.png";
      sha256 = "12r5cxlxyj75yw6r1rbj17kxqfxgzcncqildih02b622k8qkwkvz";
    };
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r ./usr/* $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "A desktop client for nostr";
    homepage = "https://github.com/mikedilger/gossip";
    sourceProvenance = with sourceTypes; [
      binaryNativeCode
    ];
    license = licenses.mit;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "gossip";
  };
}
