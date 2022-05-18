{ localInfoGrabber
, derivationUpdater
}:
{
  inherit localInfoGrabber derivationUpdater;
  comparator = "hash";
  derivation = builtins.toPath ../pkgs/battery-icons-font.nix;

  remoteInfoGrabber = ''
    function get_url () {
      url="https://dl.dafont.com/dl/?f=battery_icons"
    }

    function get_remote_hash () {
      get_url
      remote_hash=$(nix-prefetch-url --type sha256 "$url")
    }
  '';
}
