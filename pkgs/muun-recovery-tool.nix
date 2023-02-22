{ buildGoModule, fetchFromGitHub, lib }:
buildGoModule rec {
  pname = "muun-recovery-tool";
  version = "v2.2.4"; #:version:

  src = fetchFromGitHub {
    owner = "muun";
    repo = "recovery";
    rev = "${version}";
    sha256 = "sha256-XEgxRxyTwbnDyOh7OcnACFIfjspjxVqFDZpvAQOorfo="; #:hash:
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
