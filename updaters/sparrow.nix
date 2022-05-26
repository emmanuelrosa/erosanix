{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/sparrow.nix;

  getRemoteVersion = libupdate.getRemoteVersionFromGitHub { 
    owner = "sparrowwallet"; 
    repo = "sparrow"; 
  };

  getRemoteHash = libupdate.prefetchUrl "https://github.com/sparrowwallet/sparrow/releases/download/$version/sparrow-$version.tar.gz"; 
}
