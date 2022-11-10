{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/roblox.nix;

  getRemoteVersion = ''
    ${pkgs.curl}/bin/curl https://s3.amazonaws.com/setup.roblox.com/version | ${pkgs.gnused}/bin/sed 's/^version-\(.*\)$/\1/'
  '';

  getRemoteHash = libupdate.prefetchUrl "https://setup.rbxcdn.com/RobloxPlayerLauncher.exe";
}
