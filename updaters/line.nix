{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "hash";
  derivation = builtins.toPath ../pkgs/line.nix;

  getRemoteVersion = ''
    echo "no-op"
  '';

  getRemoteHash = libupdate.prefetchUrl "https://desktop.line-scdn.net/win/new/LineInst.exe";
}
