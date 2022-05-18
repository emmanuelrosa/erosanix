{ localInfoGrabber
, derivationUpdater
}:
{
  inherit localInfoGrabber derivationUpdater;
  comparator = "version";
  derivation = builtins.toPath ../pkgs/sierrachart/default.nix;

  remoteInfoGrabber = ''
     _relative_path=""
    _name=""

    function _get_relative_path () {
      if [ "$_relative_path" == "" ]
      then
       _relative_path=$(curl -s https://www.sierrachart.com/index.php?page=doc/SCZipInstallerList.php | htmlq -a href a | grep ZipFiles | head -n 1)
      fi
    }

    function get_url () {
      _get_relative_path
      url="https://www.sierrachart.com$_relative_path"
    }

    function _get_name () {
      if [ "$_name" == "" ]
      then
        get_url
        _name=$(basename $url)
      fi
    }

    function get_remote_version () {
      _get_name
      remote_version=$(echo $_name | sed 's/^SierraChart\([[:digit:]]\+\)\.zip/\1/')
    }

    function get_remote_hash () {
      get_url
      remote_hash=$(nix-prefetch-url --type sha256 "$url")
    }
  '';
}
