{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/bisq2/default.nix;

  getRemoteVersion = libupdate.getRemoteVersionFromGitHub { 
    owner = "bisq-network";
    repo = "bisq2";
    versionConverter = "${pkgs.gnused}/bin/sed 's/v//'";
  };

  getRemoteHash = libupdate.prefetchUrl "https://github.com/bisq-network/bisq2/releases/download/v$version/Bisq-$version.deb";

}
