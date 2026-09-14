{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/peridot/default.nix;

  getRemoteVersion = libupdate.getRemoteVersionFromGitHub { 
    owner = "nogringo";
    repo = "peridot";
    versionConverter = "${pkgs.gnused}/bin/sed 's/v//'";
  };

  getRemoteHash = libupdate.prefetchUrl "https://github.com/nogringo/peridot/releases/download/v$version/peridot-$version-linux.deb";
}
