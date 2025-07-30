{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/blockstream/default.nix;

  getRemoteVersion = libupdate.getRemoteVersionFromGitHub { 
    owner = "Blockstream";
    repo = "green_qt";
    versionConverter = "${pkgs.gnused}/bin/sed 's/release_//'";
  };

  getRemoteHash = libupdate.prefetchUrl "https://github.com/Blockstream/green_qt/releases/download/release_$version/Blockstream-Linux-x86_64.tar.gz";

}
