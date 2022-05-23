{ nixpkgs ? <nixpkgs> }:
let
  pkgs = import nixpkgs { };

  defaultGetLocalVersion = ''
      echo $(${pkgs.gawk}/bin/awk '/#:version:/ { match ($0, /^(.*)"(.+)"(.*)/, m); printf ("%s", m[2])}' $derivation)
  '';

  defaultGetLocalHash = ''
      echo $(${pkgs.gawk}/bin/awk '/#:hash:/ { match ($0, /^(.*)"(.+)"(.*)/, m); printf ("%s", m[2])}' $derivation)
  '';

  # Implementation of getRemoteHash
  prefetchUrl = args: let
    url = if builtins.isAttrs args then args.url else args;
    unpack = if builtins.isAttrs args then args.unpack else false;
    unpackStr = if unpack then "--unpack" else "";
  in ''
    echo $(nix-prefetch-url --type sha256 ${unpackStr} "${url}")
  '';

  getRemoteVersionFromGitHub = { owner, repo, versionConverter }: ''
      echo $(${pkgs.curl}/bin/curl -s https://api.github.com/repos/${owner}/${repo}/releases| ${pkgs.jq}/bin/jq '.[] | {name,prerelease} | select(.prerelease==false) | limit(1;.[])' | ${versionConverter} | head -n 1)
  '';

  mkUpdateScript = { getLocalVersion ? defaultGetLocalVersion
                   , getLocalHash ? defaultGetLocalHash
                   , getRemoteVersion
                   , getRemoteHash
                   , comparator ? "version"
                   , derivation }: let
    versionComparator = ''
      local_version=$(get_local_version)
      remote_version=$(get_remote_version)

      if [ "$local_version" == "$remote_version" ]
      then
        echo "No update found for $derivation."
      else
        remote_hash=$(get_remote_hash $remote_version)
        version=$remote_version
        hash=$remote_hash
        echo "Update found for $derivation. Updating..."
        ${derivationUpdater}
        echo "Updated $derivation."
      fi
    '';

      # Assuming the comparator is "hash"
      # The hash comparator is for when the version cannot be determined from the remote content.
      # This means the version must be updated manually.
    hashComparator = ''
      local_hash=$(get_local_hash)
      remote_hash=$(get_remote_hash "version_is_not_used") 

      if [[ "$local_hash" == "$remote_hash" ]]
      then
        echo "No update found for $derivation."
      else
        local_version=$(get_local_version)
        version=$local_version
        hash=$remote_hash
        echo "Update found for $derivation. Updating..."
        ${derivationUpdater}
        echo "Updated the hash for $derivation. The version must be updated manually."
      fi
    '';
    comparatorScript = if comparator == "version" then versionComparator else hashComparator;
  in if (! builtins.pathExists derivation) then throw "The path ${derivation} doesn't exist!" else pkgs.writeScript "update.bash" ''
    #!${pkgs.bash}/bin/bash

    export PATH=${pkgs.lib.makeBinPath [ pkgs.nix pkgs.coreutils ]}
    derivation="${derivation}"

    function get_local_version () {
      ${getLocalVersion}
    }

    function get_local_hash () {
      ${getLocalHash}
    }

    function get_remote_version () {
      ${getRemoteVersion}
    }

    function get_remote_hash () {
      local version=$1
      ${getRemoteHash}
    }

    echo "Starting the updater for $derivation"
    ${comparatorScript}
  '';

  derivationUpdater = let
    updateDerivation = pkgs.writeText "update-derivation.awk" ''
      /#:version:/ { match ($0, /^(.*)"(.+)"(.*)/, m); printf ("%s\"%s\"%s\n", m[1], version , m[3]) }
      /#:hash:/ { match ($0, /^(.*)"([0-9a-z-]+)"(.*)/, m); printf ("%s\"%s\"%s\n", m[1], hash , m[3]) }
      !/#:version:/  && !/#:hash:/ { print $0 }
    '';
  in '' 
    updated_nix_src=$(mktemp)
    ${pkgs.gawk}/bin/awk -f ${updateDerivation} -v version=$version -v hash=$hash $derivation > $updated_nix_src
    cat $updated_nix_src > $derivation
    rm $updated_nix_src
  '';

  importUpdater = updater:
    import updater { 
      inherit pkgs;

      libupdate = {
        inherit mkUpdateScript prefetchUrl getRemoteVersionFromGitHub;
      };
    };

  updaters = builtins.mapAttrs (name: path: importUpdater path) {
    sierrachart = ./updaters/sierrachart.nix;
    battery-icons-font = ./updaters/battery-icons-font.nix;
    trace-font = ./updaters/trace-font.nix;
    send-to-kindle = ./updaters/send-to-kindle.nix;
    foobar2000 = ./updaters/foobar2000.nix;
    muun-recovery = ./updaters/muun-recovery.nix;
    sparrow = ./updaters/sparrow.nix;
  };

  sets = let 
    script = updaterSet: builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: updater: "${updater}") updaterSet));
  in {
    sets = {
      all = pkgs.writeScript "update-all.bash" ''
        #!${pkgs.bash}/bin/bash

        ${script updaters}
      '';

      quick = pkgs.writeScript "update-quick.bash" ''
        #!${pkgs.bash}/bin/bash

        ${script (builtins.removeAttrs updaters [ "send-to-kindle" "battery-icons-font" "trace-font" ])}
      '';
    };
  };

in updaters // sets
