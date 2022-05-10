{ nixpkgs ? <nixpkgs> }:
let
  pkgs = import nixpkgs { };

  mkUpdateScript = { localInfoGrabber , remoteInfoGrabber , comparator ? "version" , derivationUpdater , derivation }: let
    versionComparator = ''
      get_local_version
      get_remote_version

      if [ "$local_version" == "$remote_version" ]
      then
        echo "No update found for $derivation."
      else
        get_remote_hash
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
      get_local_hash
      get_remote_hash

      if [[ "$local_hash" -eq "$remote_hash" ]]
      then
        echo "No update found for $derivation."
      else
        get_local_version
        version=$local_version
        hash=$remote_hash
        echo "Update found for $derivation. Updating..."
        ${derivationUpdater}
        echo "Updated the hash for $derivation. The version must be updated manually."
      fi
    '';
    comparatorScript = if comparator == "version" then versionComparator else hashComparator;
  in pkgs.writeScriptBin "update.bash" ''
    #!${pkgs.bash}/bin/bash

    export PATH=${pkgs.lib.makeBinPath [ pkgs.nix pkgs.coreutils pkgs.gawk pkgs.curl pkgs.htmlq pkgs.gnugrep pkgs.gnused ]}
    derivation="${derivation}"

    ${localInfoGrabber}
    ${remoteInfoGrabber}

    ${comparatorScript}
  '';

  defaultLocalInfoGrabber = ''
    function get_local_version () {
      local_version=$(awk '/#:version:/ { match ($0, /^(.*)"(.+)"(.*)/, m); printf ("%s", m[2])}' $derivation)
    }

    function get_local_hash () {
      local_hash=$(awk '/#:hash:/ { match ($0, /^(.*)"(.+)"(.*)/, m); printf ("%s", m[2])}' $derivation)
    }
  '';

  defaultDerivationUpdater = let
    updateDerivation = pkgs.writeText "update-derivation.awk" ''
      /#:version:/ { match ($0, /^(.*)"(.+)"(.*)/, m); printf ("%s\"%s\"%s\n", m[1], version , m[3]) }
      /#:hash:/ { match ($0, /^(.*)"([0-9a-z-]+)"(.*)/, m); printf ("%s\"%s\"%s\n", m[1], hash , m[3]) }
      !/#:version:/  && !/#:hash:/ { print $0 }
    '';
  in '' 
    local updated_nix_src=$(mktemp)
    ${pkgs.gawk}/bin/awk -f ${updateDerivation} -v version=$version -v hash=$hash $derivation > $updated_nix_src
    cat $updated_nix_src > $derivation
    rm $updated_nix_src
  '';
in {
  sierrachart = mkUpdateScript {
    remoteInfoGrabber = ''
       _relative_path=""
      _url=""
      _name=""

      function _get_relative_path () {
        if [ "$_relative_path" == "" ]
        then
         _relative_path=$(curl -s https://www.sierrachart.com/index.php?page=doc/SCZipInstallerList.php | htmlq -a href a | grep ZipFiles | head -n 1)
        fi
      }

      function _get_url () {
        _get_relative_path
        _url="https://www.sierrachart.com$_relative_path"
      }

      function _get_name () {
        if [ "$_name" == "" ]
        then
          _get_url
          _name=$(basename $_url)
        fi
      }

      function get_remote_version () {
        _get_name
        remote_version=$(echo $_name | sed 's/^SierraChart\([[:digit:]]\+\)\.zip/\1/')
      }

      function get_remote_hash () {
        _get_name
        _get_url

        local src=$(mktemp)
        curl -s $_url > $src
        remote_hash=$(nix-prefetch-url --name $_name --type sha256 "file://$src")
        rm $src
      }
    '';

    localInfoGrabber = defaultLocalInfoGrabber;
    comparator = "version";
    derivationUpdater = defaultDerivationUpdater;
    derivation = builtins.toPath ./pkgs/sierrachart/default.nix;
  };

  foobar2000 = mkUpdateScript {
    remoteInfoGrabber = ''
      _filename=""
       _relative_path=""
      _url=""
      _name=""

      function _get_filename () {
        if [ "$_filename" == "" ]
        then
          _filename=$(basename $(curl -s https://www.foobar2000.org/download | htmlq -a href a | grep getfile))
        fi
      }

      function _get_url () {
        _get_filename
        _url="https://www.foobar2000.org/files/$_filename"
      }

      function get_remote_version () {
        _get_filename
        remote_version=$(echo $_filename | sed 's/^foobar2000_v\([[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\)\(.*\)/\1/')
      }

      function get_remote_hash () {
        _get_filename
        _get_url

        local src=$(mktemp)
        curl -s $_url > $src
        remote_hash=$(nix-prefetch-url --name $_filename --type sha256 "file://$src")
        rm $src
      }
    '';

    localInfoGrabber = defaultLocalInfoGrabber;
    comparator = "version";
    derivationUpdater = defaultDerivationUpdater;
    derivation = builtins.toPath ./pkgs/foobar2000.nix;
  };
}
