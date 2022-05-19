{ localInfoGrabber
, derivationUpdater
}:
{
  inherit localInfoGrabber derivationUpdater;
  comparator = "version";
  derivation = builtins.toPath ../pkgs/sparrow.nix;

  remoteInfoGrabber = ''

    function get_remote_version () {
      remote_version=$(curl -s https://api.github.com/repos/sparrowwallet/sparrow/releases| jq '.[] | {name,prerelease} | select(.prerelease==false) | limit(1;.[])' | sed -e 's/\"//g' -e 's/\"$//g' | head -n 1)
    }

    function get_url () {
      url="https://github.com/sparrowwallet/sparrow/releases/download/1.6.4/sparrow-$remote_version.tar.gz"
    }

    function get_remote_hash () {
      get_url
      remote_hash=$(nix-prefetch-url --type sha256 "$url")
    }
  '';
}
