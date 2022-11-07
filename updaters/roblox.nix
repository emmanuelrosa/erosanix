{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "hash";
  derivation = builtins.toPath ../pkgs/roblox.nix;

  getRemoteVersion = ''
    echo "no-op"
  '';

  getRemoteHash = libupdate.prefetchUrl "https://setup.rbxcdn.com/RobloxPlayerLauncher.exe";
}
