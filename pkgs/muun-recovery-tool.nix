{ buildGoModule, fetchFromGitHub, lib }:
buildGoModule rec {
  pname = "muun-recovery-tool";
  version = "2.2.2"; #:version:

  src = fetchFromGitHub {
    owner = "muun";
    repo = "recovery";
    rev = "v${version}";
    sha256 = "01padvz9059yf14sg73smsygwrm7mn66ck9d0j85w5bscxs55bjy"; #:hash:
  };

  vendorSha256 = null;
  runVend = false;

  meta = with lib; {
    description = "You can use this Recovery Tool to transfer all funds out of your Muun account to an address of your choosing";
    homepage = "https://muun.com";
    license = licenses.mit;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
