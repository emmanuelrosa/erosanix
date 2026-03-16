{ stdenv
, lib
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, gtk3
, dconf
, libepoxy
, libtiff
, libjpeg_turbo
, gdk-pixbuf
, fontconfig
, harfbuzz
, cairo
, pango
, librsvg
, zlib
, mpv-unwrapped
, xdg-user-dirs
}: stdenv.mkDerivation rec {
  pname = "tiny_audio_player";
  version = "1.1.0"; #:version:#

  src = fetchurl {
    url = "https://github.com/emmanuelrosa/tiny_audio_player/releases/download/v${version}/tiny-audio-player_${version}-1_amd64.deb";
    sha256 = "sha256-1ipQ/VGSCuXQkm8JM9sU2m3ZtWAeleYB9txwxsMzFO8="; #:hash:
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  buildInputs = [
    gtk3
    dconf
    libepoxy
    libtiff
    libjpeg_turbo
    gdk-pixbuf
    fontconfig
    harfbuzz
    cairo
    pango
    librsvg
    zlib
  ];

  unpackPhase = ''
    dpkg -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share}
    cp -r usr/share/. $out/share/
    ln -s $out/share/tiny_audio_player/tiny_audio_player $out/bin/tiny_audio_player

    patchelf --add-rpath $out/share/tiny_audio_player/lib $out/share/tiny_audio_player/tiny_audio_player
    wrapProgram $out/share/tiny_audio_player/tiny_audio_player \
      --set LD_LIBRARY_PATH ${mpv-unwrapped}/lib \
      --set PATH ${lib.makeBinPath [ xdg-user-dirs ]}

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/emmanuelrosa/tiny_audio_player";
    description = "A minimalist audio player, written in Dart/Flutter";
    longDescription = "This package takes the Debian package (which was built using Nix) and repackages it.";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
