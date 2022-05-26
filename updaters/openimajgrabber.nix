{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/openimajgrabber.nix;

  getRemoteVersion = ''
    echo $(${pkgs.curl}/bin/curl -s https://api.github.com/repos/openimaj/openimaj/tags | ${pkgs.jq}/bin/jq '.[] | {name} | limit(1;.[])' | ${pkgs.gnused}/bin/sed -e 's/^\"//g' -e 's/\"$//g' -e 's/openimaj-//g' | head -n 1)
  '';

  getRemoteHash = libupdate.prefetchUrl "https://github.com/openimaj/openimaj/archive/refs/tags/openimaj-$version.tar.gz";
}
