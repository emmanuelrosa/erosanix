{ stdenvNoCC
, lib
, fetchurl
, autoPatchelfHook
, makeWrapper
, buildFHSEnv
, libepoxy
, gtk3
, mpv-unwrapped
, xdg-utils
, xdg-user-dirs
, gsettings-desktop-schemas
}: let
  version = "0.3.8"; #:version:#

  src = fetchurl {
    url = "https://github.com/alexmercerind2/harmonoid-releases/releases/download/v${version}/harmonoid-linux-x86_64.tar.gz";
    sha256 = "9cb0a34cb1c3e2067a964613f0b75c8004690b17685e0defc43b23fc46e7164e"; #:hash:
  };

  # Provides an MPV package which symlinks libmpv.so.1 to libmpv.so.2
  harmonoid-mpv = stdenvNoCC.mkDerivation {
    pname = "harmonoid-mpv";
    version = mpv-unwrapped.version;
    src = mpv-unwrapped;
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/lib
      cp -r $src/lib/* $out/lib/
      ln -s $out/lib/libmpv.so.2.3.0 $out/lib/libmpv.so.1
    '';
  };

  # The harmonoid tag reader is packaged alone so that it can be executed in a container.
  # It does not work when patchelf'ed.
  harmonoid-tag-reader = stdenvNoCC.mkDerivation {
    pname = "harmonoid-tag-reader";
    inherit version src;

    installPhase = ''
      mkdir -p $out/bin
      cp share/harmonoid/data/flutter_assets/assets/platform/tag_reader $out/bin/
    '';
  };

  # Linux container for the tag reader.
  harmonoid-tag-reader-fhsenv = buildFHSEnv {
    pname = "harmonoid-tag-reader-fhsenv";
    inherit version;

    targetPkgs = pkgs: [
      pkgs.glibc
      harmonoid-mpv
    ];

    runScript = "${harmonoid-tag-reader}/bin/tag_reader";
  };

  xdg-data-dirs = "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}";
in stdenvNoCC.mkDerivation rec {
  pname = "harmonoid";
  inherit version src;

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  buildInputs = [
    libepoxy
    gtk3
    harmonoid-mpv
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share

    cp -dr share $out/
    ln -s $out/share/harmonoid/harmonoid $out/bin/harmonoid

    patchelf --add-needed libmpv.so $out/share/harmonoid/harmonoid
    patchelf --add-rpath $out/share/harmonoid/lib $out/share/harmonoid/harmonoid
    wrapProgram $out/share/harmonoid/harmonoid --prefix XDG_DATA_DIRS : ${xdg-data-dirs} --prefix PATH : ${lib.makeBinPath [ xdg-utils xdg-user-dirs ]}
    ln -f -s ${harmonoid-tag-reader-fhsenv}/bin/harmonoid-tag-reader-fhsenv $out/share/harmonoid/data/flutter_assets/assets/platform/tag_reader

    runHook postInstall
  '';

  meta = with lib; {
    description = "Plays & manages your music library. Looks beautiful & juicy.";
    longDescription = "Playlists, visuals, synced lyrics, pitch shift, volume boost & more.";
    homepage = "https://harmonoid.com/";
    sourceProvenance = with sourceTypes; [
      binaryNativeCode
    ];
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
