{ localInfoGrabber
, derivationUpdater
}:
{
  inherit localInfoGrabber derivationUpdater;
  comparator = "hash";
  derivation = builtins.toPath ../pkgs/send-to-kindle.nix;

  remoteInfoGrabber = ''
    function get_url () {
      url="https://s3.amazonaws.com/sendtokindle/SendToKindleForPC-installer.exe"
    }

    function get_remote_hash () {
      get_url
      remote_hash=$(nix-prefetch-url --type sha256 "$url")
    }
  '';
}
