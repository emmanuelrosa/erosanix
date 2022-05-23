{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/muun-recovery-tool.nix;

  getRemoteVersion = libupdate.getRemoteVersionFromGitHub { 
    owner = "muun"; 
    repo = "recovery"; 
    versionConverter = "${pkgs.gnused}/bin/sed -e 's/\"Release //g' -e 's/\"$//g'"; 
  };

  getRemoteHash = libupdate.prefetchUrl { unpack = true; url = "https://github.com/muun/recovery/archive/refs/tags/v$version.tar.gz"; };
}
