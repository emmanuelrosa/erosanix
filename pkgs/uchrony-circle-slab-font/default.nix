{ stdenv, lib, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "uchrony-circle-slab-font";
  version = "2024-06-18"; #:version:

  src = fetchurl {
    url = "https://get.fontspace.co/download/family/e9ljm/b3cdd2d941cc450dac53a57448f9d489/uchrony-circle-font.zip";
    sha256 = "sha256-m7Mch/TC/FZbQxEGU8azHlzkuLg+dsPqAWWLwKA4K1Q="; #:hash:
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
    description = "Uchrony Circle Slab font, by deFharo";
    homepage = "https://www.fontspace.com/uchrony-circle-font-f77872";
    license = licenses.free;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
