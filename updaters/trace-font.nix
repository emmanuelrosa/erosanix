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
  '';
}
