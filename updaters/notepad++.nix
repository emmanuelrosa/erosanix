{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/notepad++.nix;

  getRemoteVersion = libupdate.getRemoteVersionFromGitHub { 
    owner = "notepad-plus-plus";
    repo = "notepad-plus-plus";
    versionConverter = "${pkgs.gnused}/bin/sed -e 's/^Notepad\+\+ release //g'";
  };

  getRemoteHash = ''
    hash64=$(nix-prefetch-url --type sha256 "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v$version/npp.$version.Installer.x64.exe")
    hash32=$(nix-prefetch-url --type sha256 "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v$version/npp.$version.Installer.exe")
    echo "$hash64|$hash32"
    '';

  derivationUpdater = let
    updateDerivation = pkgs.writeText "update-derivation.awk" ''
      /#:version:/ { match ($0, /^(.*)"(.+)"(.*)/, m); printf ("%s\"%s\"%s\n", m[1], version , m[3]) }
      /#:hash64:/ { match ($0, /^(.*)"([0-9a-z-]+)"(.*)/, m); printf ("%s\"%s\"%s\n", m[1], hash64 , m[3]) }
      /#:hash32:/ { match ($0, /^(.*)"([0-9a-z-]+)"(.*)/, m); printf ("%s\"%s\"%s\n", m[1], hash32 , m[3]) }
      !/#:version:/  && !/#:hash64:/ && !/#:hash32:/ { print $0 }
    '';
  in '' 
    hash64=$(echo $hash | cut -d "|" -f 1)
    hash32=$(echo $hash | cut -d "|" -f 2)
    echo "hash64: $hash64"
    echo "hash32: $hash32"
    updated_nix_src=$(mktemp)
    ${pkgs.gawk}/bin/awk -f ${updateDerivation} -v version=$version -v hash64=$hash64 -v hash32=$hash32 $derivation > $updated_nix_src
    cat $updated_nix_src > $derivation
    rm $updated_nix_src
  '';
}
