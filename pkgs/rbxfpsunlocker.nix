{ stdenv
, lib
, fetchurl
, unzip
}:
stdenv.mkDerivation {
  pname = "rbxfpsunlocker";
  version = "4.4.3";

  src = fetchurl {
    url = "https://github.com/axstin/rbxfpsunlocker/releases/download/v4.4.3/rbxfpsunlocker-x64.zip";
    sha256 = "13nn1arwn9lqs8hcha3k7c9f0mlnl3b0iypf3r9clpy9p9i4hdaq";
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