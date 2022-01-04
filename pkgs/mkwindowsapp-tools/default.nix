{ stdenv
, lib
}:
stdenv.mkDerivation rec {
  pname = "mkwindows-tools";
  version = "0.0.3";
  src = ./.;

  installPhase = ''
    mkdir -p $out/bin

    install -D gc.bash $out/bin/mkwindows-tools-gc
    install -D dedup.bash $out/bin/mkwindows-tools-dedup
  '';

  meta = with lib; {
    description = "A set of tools for working with packages made with mkWindowsApp.";
    homepage = "https://github.com/emmanuelrosa/erosanix";
    license = licenses.mit;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
