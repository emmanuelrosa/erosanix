{ stdenv
, lib
, fetchurl
, unzip
}:
stdenv.mkDerivation rec {
  pname = "rbxfpsunlocker";
  version = "5.1"; #:version:

  src = fetchurl {
    url = "https://github.com/axstin/rbxfpsunlocker/releases/download/v${version}/rbxfpsunlocker-x64.zip";
    sha256 = "1fbcjsnf6chpj6d1zkjnvdw2sh4rgsihqq0sv3b1fyz4713k688w"; #:hash:
  };

  nativeBuildInputs = [ unzip ];

  unpackCmd = ''
    mkdir src
    pushd src
    unzip $curSrc
    popd
  '';

  installPhase = ''
    mkdir -p $out
    cp rbxfpsunlocker.exe $out
  '';

  meta = with lib; {
    description = "FPS Unlocker for Roblox";
    homepage = "https://github.com/axstin/rbxfpsunlocker";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
