{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/specter-desktop/default.nix;

  getRemoteVersion = libupdate.getRemoteVersionFromGitHub { 
    owner = "cryptoadvance";
    repo = "specter-desktop";
    versionConverter = "${pkgs.gnused}/bin/sed 's/v//'";
    allowPrerelease = true;
  };

  getRemoteHash = libupdate.prefetchUrl "https://github.com/cryptoadvance/specter-desktop/releases/download/v$version/specter_desktop-v$version-x86_64-linux-gnu.tar.gz";
}
