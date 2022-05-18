{ localInfoGrabber
, derivationUpdater
}:
{
  inherit localInfoGrabber derivationUpdater;
  comparator = "version";
  derivation = builtins.toPath ../pkgs/foobar2000.nix;

  remoteInfoGrabber = ''
    _filename=""
     _relative_path=""
    _name=""

    function _get_filename () {
      if [ "$_filename" == "" ]
      then
        _filename=$(basename $(curl -s https://www.foobar2000.org/download | htmlq -a href a | grep getfile))
      fi
    }

    function get_url () {
      _get_filename
      url="https://www.foobar2000.org/files/$_filename"
    }

    function get_remote_version () {
      _get_filename
      remote_version=$(echo $_filename | sed 's/^foobar2000_v\([[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\)\(.*\)/\1/')
    }

    function get_remote_hash () {
      get_url
      remote_hash=$(nix-prefetch-url --type sha256 "$url")
    }
  '';
}
