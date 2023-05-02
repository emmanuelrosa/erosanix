{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/foobar2000.nix;

  getRemoteVersion = ''
      echo $(basename $(${pkgs.curl}/bin/curl -s https://www.foobar2000.org/download | ${pkgs.htmlq}/bin/htmlq -a href a | ${pkgs.gnugrep}/bin/grep getfile | head -n 1) | ${pkgs.gnused}/bin/sed 's/^foobar2000_v\(.*\)\(.exe\)/\1/')
  '';

  getRemoteHash = ''
    hash64=$(nix-prefetch-url --type sha256 "https://www.foobar2000.org/files/foobar2000-x64_v$version.exe")
    hash32=$(nix-prefetch-url --type sha256 "https://www.foobar2000.org/files/foobar2000_v$version.exe")
    echo "$hash64|$hash32"
    '';

  derivationUpdater = libupdate.multiArchDerivationUpdater;
}
