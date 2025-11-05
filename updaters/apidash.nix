{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/apidash/default.nix;

  getRemoteVersion = libupdate.getRemoteVersionFromGitHub { 
    owner = "foss42";
    repo = "apidash";
    versionConverter = "${pkgs.gnused}/bin/sed 's/v//'";
  };

  getRemoteHash = libupdate.prefetchUrl "https://github.com/foss42/apidash/releases/download/v$version/apidash-linux-amd64.deb";

}
