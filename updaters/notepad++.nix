{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/notepad++.nix;

  getRemoteVersion = libupdate.getRemoteVersionFromGitHub { 
    owner = "notepad-plus-plus";
    repo = "notepad-plus-plus";
    versionConverter = "${pkgs.gnused}/bin/sed -e 's/v//'";
  };

  getRemoteHash = ''
    hash64=$(nix-prefetch-url --type sha256 "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v$version/npp.$version.Installer.x64.exe")
    hash32=$(nix-prefetch-url --type sha256 "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v$version/npp.$version.Installer.exe")
    echo "$hash64|$hash32"
    '';

  derivationUpdater = libupdate.multiArchDerivationUpdater;
}
