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
    systemd.user.services.swaync = {
      enable = true;
      description = "Sway notificiation center daemon";
      documentation = [ "https://github.com/ErikReider/SwayNotificationCenter" ];
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        Slice = "background-graphical.slice";
        Restart = "on-failure";
        ExecStart = "${cfg.package}/bin/swaync";
        ExecReload = "${cfg.package}/bin/swaync-client --reload-config; ${cfg.package}/bin/swaync-client --reload-css";
      };
    };
  };
}
