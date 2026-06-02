
{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/responsively/default.nix;

  getRemoteVersion = libupdate.getRemoteVersionFromGitHub { 
    owner = "responsively-org";
    repo = "responsively-app";
    versionConverter = "${pkgs.gnused}/bin/sed 's/v//'";
  };

  getRemoteHash = libupdate.prefetchUrl "https://github.com/responsively-org/responsively-app-releases/releases/download/v$version/ResponsivelyApp-$version.AppImage";

}
