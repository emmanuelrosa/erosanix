{ stdenv
, lib 
, fetchFromGitHub
, makeWrapper
, matrix-commander
}:

stdenv.mkDerivation rec {
  pname = "matrix-sendmail";
  version = "50ccf7f1627545e807841fa5bb8e9cfddeb98b97";

  nativeBuildInputs = [ makeWrapper ];

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = "matrix-sendmail";
    rev = version;
    sha256 = "sha256-T8K/8/3DrtdftnrRvCPHGSfeXEVoE+o+S5qZFq+aPUc=";
  };

  installPhase = ''
    install -D -m ugo=r config.env $out/etc/matrix-sendmail/config.env
    install -D sendmail $out/bin/sendmail
    install -D matrix-sendmail-prep $out/lib/matrix-sendmail/libexec/matrix-sendmail-prep
    install -D matrix-sendmail-deliver $out/lib/matrix-sendmail/libexec/matrix-sendmail-deliver
    wrapProgram $out/lib/matrix-sendmail/libexec/matrix-sendmail-deliver --prefix PATH : ${lib.makeBinPath [ matrix-commander ]}
  '';

  meta = with lib; {
    description = "A simple sendmail implementation which uses a Matrix CLI client to send 'mail' to a Matrix room.";
    homepage = "https://github.com/emmanuelrosa/matrix-sendmail";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
