{ stdenv, lib, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "bubble-dance-monogram-font";
  version = "2024-06-19"; #:version:

  src = fetchurl {
    url = "https://get.fontspace.co/download/family/4x07x/6ed9dadfe046435fb0e216b1b11c66d6/bubble-dance-monogram-font.zip";
    sha256 = "sha256-Xp5krg4KuHdZfd6XNsumqXhzfUab4qBmObggX46/0uw="; #:hash:
  };

  nativeBuildInputs = [ unzip ];

  unpackCmd = ''
    mkdir ${pname}
    pushd ${pname}
    unzip $curSrc
    chmod -R ugo+r .
    popd
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/${pname}
    mkdir -p $out/share/doc/${pname}

    cp -r *.ttf $out/share/fonts/${pname}/
    cp info.txt $out/share/doc/${pname}/
    cp -r misc/* $out/share/doc/${pname}/
  '';

  meta = with lib; {
    description = "Bubble Dance Monogram font";
    homepage = "https://www.fontspace.com/bubble-dance-monogram-font-f113144";
    license = licenses.free;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
