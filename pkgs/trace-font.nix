{ stdenv, lib, fetchurl, unzip }:

let
  description = "Trace font";
in stdenv.mkDerivation rec {
  pname = "trace-font";
  version = "2020-03-25";

  src = fetchurl {
    url = "https://get.fontspace.co/download/font/lxy0/Y2VmNGUzYTIzMzlkNDUxZWFkZjVjOTgyOTRmYjlmMzUuVFRG/Trace-lxy0.ttf";
    sha256 = "sha256-CFN8u1qrL+4qfsvDjIcuZIs1mFU/G6VaDbY/bsM+QH4=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/fonts/trace
    ln -s $src $out/share/fonts/trace/trace.ttf
  '';

  meta = with lib; {
    inherit description;
    homepage = https://www.fontspace.com/trace-font-f3625;
    license = licenses.free;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
