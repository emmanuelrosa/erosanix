{ stdenv
, lib
, fetchurl
, unzip
}:
stdenv.mkDerivation rec {
  pname = "rbxfpsunlocker";
  version = "4.4.4"; #:version:

  src = fetchurl {
    url = "https://github.com/axstin/rbxfpsunlocker/releases/download/v${version}/rbxfpsunlocker-x64.zip";
    sha256 = "1y7j630h41n4x9a1mfpd6x6y39wb4i3bmwzc1kf4zgbx2b0ff3q5"; #:hash:
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
