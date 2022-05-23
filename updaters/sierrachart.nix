{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/sierrachart/default.nix;

  getRemoteVersion = ''
    echo $(basename $(${pkgs.curl}/bin/curl -s https://www.sierrachart.com/index.php?page=doc/SCZipInstallerList.php | ${pkgs.htmlq}/bin/htmlq -a href a | ${pkgs.gnugrep}/bin/grep ZipFiles | head -n 1) | ${pkgs.gnused}/bin/sed 's/^SierraChart\([[:digit:]]\+\)\.zip/\1/')
  '';

  getRemoteHash = libupdate.prefetchUrl "https://www.sierrachart.com/downloads/ZipFiles/SierraChart$version.zip";
}
