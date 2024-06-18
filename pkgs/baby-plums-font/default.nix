{ stdenv, lib, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "baby-plums-font";
  version = "2024-06-18"; #:version:

  src = fetchurl {
    url = "https://get.fontspace.co/download/family/mdmne/4f0d524b9cf44147b2c9cf02db5d791d/baby-plums-font.zip";
    sha256 = "sha256-1ZASWdLeR48DGce0lYcYdJPrLi0SQrpdGZl/dJ/K/eI="; #:hash:
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
    ls -l
    find .
    mkdir -p $out/share/fonts/${pname}
    mkdir -p $out/share/doc/${pname}

    cp BabyPlums-rv2gL.ttf $out/share/fonts/${pname}/
    cp info.txt $out/share/doc/${pname}/
    cp -r misc/. $out/share/doc/${pname}/
  '';

  meta = with lib; {
    description = "Baby Plums font, by Dmletter studio";
    homepage = "https://www.fontspace.com/baby-plums-font-f109480";
    license = licenses.free;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
