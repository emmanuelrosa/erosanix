{ localInfoGrabber
, derivationUpdater
}:
{
  inherit localInfoGrabber derivationUpdater;
  comparator = "version";
  derivation = builtins.toPath ../pkgs/muun-recovery-tool.nix;

  remoteInfoGrabber = ''

    function get_remote_version () {
      remote_version=$(curl -s https://api.github.com/repos/muun/recovery/releases| jq '.[] | {name,prerelease} | select(.prerelease==false) | limit(1;.[])' | sed -e 's/\"Release //g' -e 's/\"$//g' | head -n 1)
    }

    function get_url () {
      url="https://github.com/muun/recovery/archive/refs/tags/v$remote_version.tar.gz"
    }

    function get_remote_hash () {
      get_url
      remote_hash=$(nix-prefetch-url --type sha256 --unpack "$url")
    }
  '';
}
