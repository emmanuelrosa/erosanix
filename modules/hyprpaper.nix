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

    systemd.user.services.hyprpaper = {
      enable = true;
      description = "Fast, IPC-controlled wallpaper utility for Hyprland.";
      documentation = [ "https://wiki.hyprland.org/Hypr-Ecosystem/hyprpaper/" ];
      partOf = [ "graphical-session.desktop.target" ];
      after = [ "graphical-session.desktop.target" ];
      wantedBy = [ "graphical-session.desktop.target" ];
      path = [ config.programs.hyprland.package ];
      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe cfg.package;
        Slice = "background-graphical.slice";
        Restart = "on-failure";
        ExecCondition = pkgs.writeScript "hyprpaper-execcondition" ''
          #!/bin/sh
          stat $XDG_CONFIG_HOME/hypr/hyprpaper.conf
        '';
      };
    };
  };
}
