{ stdenv
, lib 
, fetchFromGitHub
, makeWrapper
, matrix-commander
, gnused
, gnugrep
}:

stdenv.mkDerivation rec {
  pname = "matrix-sendmail";
  version = "835d1efc713f6c915e6b2657f77ba19066f61d4b";

  nativeBuildInputs = [ makeWrapper ];

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = "matrix-sendmail";
    rev = version;
    sha256 = "sha256-q4cvFMOYiqrxRFyaTVhwpgl/p874sfmaXZjk1NEELdo=";
  };

  installPhase = ''
    install -D -m ugo=r config.env $out/etc/matrix-sendmail/config.env
    install -D sendmail $out/bin/sendmail
    install -D matrix-sendmail-prep $out/lib/matrix-sendmail/libexec/matrix-sendmail-prep
    install -D matrix-sendmail-deliver $out/lib/matrix-sendmail/libexec/matrix-sendmail-deliver

    wrapProgram $out/lib/matrix-sendmail/libexec/matrix-sendmail-deliver --prefix PATH : ${lib.makeBinPath [ matrix-commander ]}
    wrapProgram $out/bin/sendmail --prefix PATH : ${lib.makeBinPath [ gnused gnugrep ]}
  '';

  meta = with lib; {
    description = "A simple sendmail implementation which uses a Matrix CLI client to send 'mail' to a Matrix room.";
    homepage = "https://github.com/emmanuelrosa/matrix-sendmail";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
