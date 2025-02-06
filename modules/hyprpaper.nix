{ config, lib, pkgs, ... }:

let
  cfg = config.programs.hyprpaper;
in {
  meta = {
    maintainers = with lib.maintainers; [ emmanuelrosa ];
  };

  options.programs.hyprpaper = {
    enable = lib.mkEnableOption "hyprpaper, a blazing fast wayland wallpaper utility for Hyprland";
    package = lib.mkPackageOption pkgs "hyprpaper" { };
  };

  config = lib.mkIf config.programs.hyprpaper.enable {
    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];
  };
}
