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
, libxkbcommon
, wayland
}: stdenv.mkDerivation rec {
  name = "gossip";
  version = "0.11.2"; #:version:

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
                          libxkbcommon
                          dbus
                          pipewire
                          libGL
                          openssl 
                          fontconfig 
                          wayland
                        ];

  src = fetchurl {
    url = "https://github.com/mikedilger/gossip/releases/download/v${version}/gossip_${version}-1_amd64.deb";
    sha256 = "sha256-mpCvgGnGCe5viUntnrlbL3sZDNz8R8Chs+R6HYuGqZU="; #:hash
  };

  unpackPhase = ''
    dpkg -x $src .
  '';

  desktopIcon = makeDesktopIcon {
    inherit name;

    src = fetchurl {
      url = "https://github.com/mikedilger/gossip/raw/v${version}/logo/gossip.png";
      sha256 = "sha256-f08+MZpCmCUAjI1GzCz7rzvc5wly5ZAN9+VI32lnJYs=";
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
