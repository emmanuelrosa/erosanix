{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/gossip/default.nix;

  getRemoteVersion = libupdate.getRemoteVersionFromGitHub { 
    owner = "mikedilger";
    repo = "gossip";
    versionConverter = "${pkgs.gnused}/bin/sed 's/v//'";
  };

  getRemoteHash = libupdate.prefetchUrl "https://github.com/mikedilger/gossip/releases/download/v$version/gossip_$version-1_amd64.deb";
}
