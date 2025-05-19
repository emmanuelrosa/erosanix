{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/sideswap/default.nix;

  getRemoteVersion = libupdate.getRemoteVersionFromGitHub { 
    owner = "sideswap-io";
    repo = "sideswapclient";
    versionConverter = "${pkgs.gnused}/bin/sed 's/v//'";
  };

  getRemoteHash = libupdate.prefetchUrl "https://github.com/sideswap-io/sideswapclient/releases/download/v$version/SideSwap.AppImage";

}
