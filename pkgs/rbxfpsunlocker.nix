{ stdenv
, lib
, fetchurl
, unzip
}:
stdenv.mkDerivation rec {
  pname = "rbxfpsunlocker";
  version = "5.2"; #:version:

  src = fetchurl {
    url = "https://github.com/axstin/rbxfpsunlocker/releases/download/v${version}/rbxfpsunlocker-x64.zip";
    sha256 = "0y2xqp4irib10y83mrg41zn04qdsm7hsgkasgwmvyzdqlj97bv0z"; #:hash:
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
