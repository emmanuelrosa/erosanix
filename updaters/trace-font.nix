{ localInfoGrabber
, derivationUpdater
}:
{
  inherit localInfoGrabber derivationUpdater;
  comparator = "hash";
  derivation = builtins.toPath ../pkgs/trace-font.nix;

  remoteInfoGrabber = ''
    function get_url () {
      url="https://get.fontspace.co/download/font/lxy0/Y2VmNGUzYTIzMzlkNDUxZWFkZjVjOTgyOTRmYjlmMzUuVFRG/Trace-lxy0.ttf"
    }

    function get_remote_hash () {
      get_url
      remote_hash=$(nix-prefetch-url --type sha256 "$url")
    }
  '';
}
