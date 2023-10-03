{ stdenv
, lib
, fetchurl
, writeScript
, dpkg
, gnutar
, patchelf
, makeDesktopItem
, copyDesktopItems
, makeDesktopIcon
, copyDesktopIcons
, autoPatchelfHook
, openjdk
, bash
, xorg
, libGL
, libGLU
, libdrm
, mesa
}: let
  launcher = writeScript "alice3-launcher" ''
    #! ${bash}/bin/bash

    # This is just a comment to convince Nix to keep the src
    # dep package; It's a big file so I rather keep it around
    # for as long as possible.
    # @src@

    app_home=@out@/opt/alice3
    classpath=$app_home/.install4j/i4jruntime.jar:$app_home/.install4j/launcherd9df6f3c.jar:$app_home/lib/*

    exec ${openjdk}/bin/java "-splash:$app_home/.install4j/s_15z2a4p.png" "-ea" "-Xmx1024m" "-Dorg.alice.ide.rootDirectory=$app_home/" "-Dswing.aatext=true" "-Djogamp.gluegen.UseTempJarCache=false" "-Djava.library.path=$app_home/platform/linux-amd64/jogl/natives/linux-amd64/" "--add-opens=java.base/java.io=ALL-UNNAMED" "--add-opens=java.desktop/sun.awt=ALL-UNNAMED" "--add-opens=java.base/java.time=ALL-UNNAMED" -classpath "$classpath" install4j.org.alice.stageide.EntryPoint  "$@"
  '';

in stdenv.mkDerivation rec {
  name = "alice3";
  version = "3.8.0.0"; #:version:
  versionUnderscored = builtins.concatStringsSep "_" (lib.versions.splitVersion version);
  build = "1046"; #:build:#

  nativeBuildInputs = [ dpkg gnutar copyDesktopItems copyDesktopIcons autoPatchelfHook stdenv.cc.cc.libgcc ];

  buildInputs = [ xorg.libXi
                  xorg.libX11
                  xorg.libXrender
                  xorg.libXxf86vm
                  xorg.libXrandr
                  xorg.libXcursor
                  libGL
                  libGLU
                  openjdk
                  libdrm
                  mesa
                ];

  src = fetchurl {
    url = "https://github.com/TheAliceProject/alice3/releases/download/${version}/alice3_linux_bundle_${versionUnderscored}+build_${build}.deb";
    sha256 = "1wxk2zagygsvx5955k7iibzz26vcd3x86dh76ynjl1g9j3439j2p"; #:hash:
  };

  dontUnpack = true;

  desktopItems = [
    (makeDesktopItem {
      name = "alice3";
      exec = "alice3";
      icon = "alice3";
      desktopName = "Alice 3";
      categories = [ "Development" "IDE" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    inherit name;

    src = fetchurl {
      inherit name;

      url = "https://github.com/TheAliceProject/alice3/raw/${version}/installer/installerFiles/desktopIcon256.png";
      sha256 = "1mz8128kjjcm9nviqa35vz59bh72zxg4xwz12cw968wl93khyymi";
    };
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    dpkg --fsys-tarfile $src | tar -C $out -xf - --exclude="opt/alice3/platform/linux-armv6hf/*" --exclude="opt/alice3/platform/linux-i586/*"
    install -D -m 777 ${launcher} $out/bin/alice3
    substituteAllInPlace $out/bin/alice3 
    patchelf --set-rpath ${openjdk}/lib/openjdk/lib $out/opt/alice3/platform/linux-amd64/jogl/natives/linux-amd64/libnativewindow_awt.so

    runHook postInstall
  '';

  meta = with lib; {
    description = "An innovative block-based programming environment that makes it easy to create animations, build interactive narratives, or program simple games in 3D.";
    homepage = "https://www.alice.org/";
    sourceProvenance = with sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];
    license = licenses.mit;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
