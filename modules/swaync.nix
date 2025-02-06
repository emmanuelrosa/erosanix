{ config, lib, pkgs, ... }:

let
  cfg = config.programs.swaynotificationcenter;
in {
  meta = {
    maintainers = with lib.maintainers; [ emmanuelrosa ];
  };

  options.programs.swaynotificationcenter = {
    enable = lib.mkEnableOption "swaynotificationcenter, a simple notification daemon for Sway";
    package = lib.mkPackageOption pkgs "swaynotificationcenter" { };
  };

  config = lib.mkIf config.programs.swaynotificationcenter.enable {
    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];
  };
}
