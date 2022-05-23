{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "hash";
  derivation = builtins.toPath ../pkgs/battery-icons-font.nix;

  getRemoteVersion = ''
    echo "no-op"
  '';

  getRemoteHash = libupdate.prefetchUrl "https://dl.dafont.com/dl/?f=battery_icons";
}
