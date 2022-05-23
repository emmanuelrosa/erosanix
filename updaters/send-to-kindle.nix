{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "hash";
  derivation = builtins.toPath ../pkgs/send-to-kindle.nix;

  getRemoteVersion = ''
    echo "no-op"
  '';

  getRemoteHash = libupdate.prefetchUrl "https://s3.amazonaws.com/sendtokindle/SendToKindleForPC-installer.exe";
}
