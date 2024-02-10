{ lib
, rustPlatform
, fetchFromGitHub
, fetchurl
, cmake
, git
, pkg-config
, ffmpeg
, openssl
, xorg
, libGL
, fontconfig
, dbus
, pipewire
, autoPatchelfHook
, makeDesktopItem
, copyDesktopItems
, makeDesktopIcon
, copyDesktopIcons
, enableVideoPlayback ? true
, enableCJKFonts ? true
}:

rustPlatform.buildRustPackage rec {
  pname = "gossip";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "mikedilger";
    repo = "gossip";
    rev = version;
    hash = "sha256-m0bIpalH12GK7ORcIk+UXwmBORMKXN5AUtdEogtkTRM";
  };

  doCheck = false;

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "ecolor-0.23.0" = "sha256-Jg1oqxt6YNRbkoKqJoQ4uMhO9ncLUK18BGG0fa+7Bow=";
      "egui-video-0.1.0" = "sha256-3483FErslfafCDVYx5qD6+amSkfVenMGMlEpPDnTT1M=";
      "ffmpeg-next-6.0.0" = "sha256-EkzwR5alMjAubskPDGMP95YqB0CaC/HsKiGVRpKqUOE=";
      "ffmpeg-sys-next-6.0.1" = "sha256-UiVKhrgVkROc25VSawxQymaJ0bAZ/dL0xMQErsP4KUU=";
      "gossip-relay-picker-0.2.0-unstable" = "sha256-3rbjtpxNN168Al/5TM0caRLRd5mxLZun/qVhsGwS7wY=";
      "heed-0.20.0-alpha.6" = "sha256-TFUC6SXNzNXfX18/RHFx7fq7O2le+wKcQl69Uv+CQkY=";
      "nostr-types-0.7.0-unstable" = "sha256-B+hOZ4TRDSWgzyAc/yPiTWeU0fFCBPJG1XOHyoXfuQc=";
      "qrcode-0.12.0" = "sha256-onnoQuMf7faDa9wTGWo688xWbmujgE9RraBialyhyPw=";
      "sdl2-0.35.2" = "sha256-qPId64Y6UkVkZJ+8xK645at5fv3mFcYaiInb0rGUfL4=";
      "speedy-0.8.6" = "sha256-ltJQud1kEYkw7L2sZgPnD/teeXl2+FKgyX9kk2IC2Xg=";
      "nip44-0.1.0" = "sha256-of1bG7JuSdR19nXVTggHRUnyVDMlUrkqioyN237o3Oo=";
    };
  };

  RUST_BACKTRACE = "1";

  RUSTFLAGS = "-C target-cpu=x86-64 --cfg tokio_unstable";

  buildFeatures = lib.optionals enableVideoPlayback [ "video-ffmpeg" ]
    ++ lib.optionals enableCJKFonts [ "lang-cjk" ];

  nativeBuildInputs = [
    cmake
    git
    pkg-config
    rustPlatform.bindgenHook
    copyDesktopItems
    copyDesktopIcons
    autoPatchelfHook
  ];

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

  preBuild = ''
    export RUSTUP_TOOLCHAIN=stable
    export CARGO_TARGET_DIR=target
  '';

  buildInputs = [
    ffmpeg
    openssl
  ];

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Gossip";
      categories = [ "Network" "InstantMessaging" ];
      mimeTypes = [ "x-scheme-handler/nostr" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;

    src = fetchurl {
      name = "gossip.png";
      url = "https://github.com/mikedilger/gossip/blob/${version}/logo/gossip.png?raw=true";
      sha256 = "sha256-f08+MZpCmCUAjI1GzCz7rzvc5wly5ZAN9+VI32lnJYs=";
    };
  };

  meta = with lib; {
    description = "Desktop client for nostr, an open social media protocol";
    homepage = "https://github.com/mikedilger/gossip";
    downloadPage = "https://github.com/mikedilger/gossip/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ totoroot emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
    sourceProvenance = with sourceTypes; [
      binaryNativeCode
    ];
  };
}
