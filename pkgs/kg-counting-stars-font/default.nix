{ stdenv, lib, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "kg-counting-stars-font";
  version = "2024-06-19"; #:version:

  src = fetchurl {
    url = "https://get.fontspace.co/download/family/dodge/618fd7b03ade4357ac15611cc97cce19/kg-counting-stars-font.zip";
    sha256 = "sha256-OCi8LHdHUHbbDmPuucheZLyFw+Vj0382BXalf17dhrM="; #:hash:
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
    description = "KG Counting Stars font. The lowercase letters have stars- the uppercase do not. Mix and match as desired. :) The < and > keys are solid background circles.";
    homepage = "https://www.fontspace.com/kg-counting-stars-font-f18715";
    license = licenses.free;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
