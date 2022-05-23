{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/foobar2000.nix;

  getRemoteVersion = ''
      echo $(basename $(${pkgs.curl}/bin/curl -s https://www.foobar2000.org/download | ${pkgs.htmlq}/bin/htmlq -a href a | ${pkgs.gnugrep}/bin/grep getfile) | ${pkgs.gnused}/bin/sed 's/^foobar2000_v\([[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\)\(.*\)/\1/')
  '';

  getRemoteHash = libupdate.prefetchUrl "https://www.foobar2000.org/files/foobar2000_v$version.exe";
}
