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

    systemd.user.services.hyprpaper = let
      desiredTarget =  [ "wayland-session@hyprland.desktop.target" ];
    in {
      enable = true;
      description = "Fast, IPC-controlled wallpaper utility for Hyprland.";
      documentation = [ "https://wiki.hyprland.org/Hypr-Ecosystem/hyprpaper/" ];
      after = desiredTarget;
      wantedBy = desiredTarget;
      path = [ config.programs.hyprland.package ];
      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe cfg.package;
        Slice = "background-graphical.slice";
        Restart = "on-failure";
      };
    };
  };
}
