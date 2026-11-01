{ stdenv
, lib
, nim
, spoolDir ? "/tmp/sendtome"
}: stdenv.mkDerivation {
  pname = "sendtome";
  version = "2.0.0";
  src = ./.;

  nativeBuildInputs = [ nim ];

  buildPhase = ''
    cache_dir=$(mktemp -d)
    nim c --app:console -d:release -d:spoolDir="${spoolDir}" --nimcache:$cache_dir sendmail.nim
  '';

  installPhase = ''
    mkdir -p $out/bin/

    install sendmail $out/bin/
  '';

  meta = with lib; {
    description = "A simple MTA that delivers all mail to a single spool directory. From there, emails can be delivered to a single inbox.";
    longDescription = "This package is meant to be used with the sendtome NixOS module.";
    homepage = "https://github.com/emmanuelrosa/erosanix";
    license = licenses.mit;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = lib.platforms.unix;
    mainProgram = "sendmail";
  };
}
