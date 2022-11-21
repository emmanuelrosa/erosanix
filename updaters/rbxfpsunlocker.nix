{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/rbxfpsunlocker.nix;

  getRemoteVersion = libupdate.getRemoteVersionFromGitHub { 
    owner = "axstin";
    repo = "rbxfpsunlocker";
    versionConverter = "${pkgs.gnused}/bin/sed 's/v//'";
  };

  getRemoteHash = libupdate.prefetchUrl "https://github.com/axstin/rbxfpsunlocker/releases/download/v$version/rbxfpsunlocker-x64.zip";
}
