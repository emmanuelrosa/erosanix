{ stdenv
, lib
, fetchurl
}:
stdenv.mkDerivation rec {
  pname = "powershell";
  version = "7.3.1"; #:version:

  src = fetchurl {
    url = "https://github.com/PowerShell/PowerShell/releases/download/v${version}/PowerShell-${version}-win-x64.msi";
    sha256 = "17siclk47xg1cb6l0x4vq5csg2xwx1c1ibksp2av3wbpz1nh5l6a"; #:hash:
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/powershell.msi
  '';

  meta = with lib; {
    description = "Microsoft PowerShell";
    homepage = "https://microsoft.com/PowerShell";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
