{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "hash";
  derivation = builtins.toPath ../pkgs/trace-font.nix;

  getRemoteVersion = ''
    echo "no-op"
  '';

  getRemoteHash = libupdate.prefetchUrl "https://get.fontspace.co/download/font/lxy0/Y2VmNGUzYTIzMzlkNDUxZWFkZjVjOTgyOTRmYjlmMzUuVFRG/Trace-lxy0.ttf";
}
