{ config, lib, pkgs, ... }:

let
  cfg = config.programs.udiskie;

  mkEnabledOption = desc: lib.mkOption {
    type = lib.types.bool;
    default = true;
    example = true;
    description = "Whether to enable ${desc}.";
  };
in {
  meta = {
    maintainers = with lib.maintainers; [ emmanuelrosa ];
  };

  options.programs.udiskie = {
    enable = lib.mkEnableOption "udiskie, a removable disk automounter for udisks";

    package = lib.mkPackageOption pkgs "udiskie" { };

    automount = {
      enable = mkEnabledOption "automounting of new devices";
    };

    notify = {
      enable = mkEnabledOption "pop-up notifications";
    };

    tray = {
      enable = lib.mkEnableOption "show tray icon";
      autoHide = lib.mkEnableOption "automatically hide the tray icon when there is no action available";
    };

    fileManager = lib.mkOption {
      type = lib.types.str;
      default = "xdg-open";
      example = "lib.getExe pkgs.pcmanfm";
      description = "Set program to open mounted directories. Default is 'xdg-open'. Pass an empty string to disable this feature.";
    };

    terminalProgram = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Set program to open mounted directories. Default is 'xdg-open'. Pass an empty string to disable this feature.";
    };

    appIndicator = {
      enable = lib.mkEnableOption "use AppIndicator3 for the status icon. Use this on Unity if no icon is shown";
    };

    passwordCacheTimeoutMinutes = lib.mkOption {
      type = lib.types.numbers.nonnegative;
      default = 0;
      example = 5;
      description = "Cache passwords for LUKS partitions and set the timeout in minutes. When set to 0, passwords are not cached.";
    };

    eventHook = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "zenity --info --text '{event}: {device_presentation}'";
      description = "Command to execute on device events. The command string must be formatted using the event name and the list of device attributes (see example).";
    };
  };

  config = lib.mkIf config.programs.udiskie.enable {
    environment.systemPackages = [ cfg.package ];
    services.udisks2.enable = true;

    systemd.user.services.udiskie = {
      description = "Automounter for udisks";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig.ExecStart = "${cfg.package}/bin/udiskie ${lib.optionalString (!cfg.automount.enable) "-A"} ${lib.optionalString (!cfg.notify.enable) "-N"} ${lib.optionalString cfg.tray.enable "-t"} ${lib.optionalString cfg.tray.autoHide "-s"} -f ${cfg.fileManager} ${lib.optionalString cfg.appIndicator.enable "--appindicator"} ${lib.optionalString (cfg.passwordCacheTimeoutMinutes > 0) "--password-cache ${cfg.passwordCacheTimeoutMinutes}"} ${lib.optionalString (cfg.eventHook != "") "--event-hook \"${cfg.eventHook}\""}";
    };
  };
}
