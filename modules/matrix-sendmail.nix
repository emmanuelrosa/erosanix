{ config, lib, ... }:

with lib;

let cfg = config.services.matrix-sendmail;
in {
  options = {

    services.matrix-sendmail = {
      enable = mkEnableOption "Enable the matrix-sendmail service.";

      spoolDir = mkOption {
        type = types.path;
        default = "/var/spool/matrix-sendmail";
        description = "The top-level directory where email messages are stored prior to delivery.";
      };

      deliveryInterval = mkOption {
        type = types.str;
        default = "10m";
        description = "How frequently to check for queued emails and deliver them.";
      };

      libDir = mkOption {
        type = types.path;
        default = "/var/lib/matrix-sendmail";
        description = "The directory where matrix-sendmail stores stateful data. Primarily used for matrix-commander.";
      };

      user = mkOption {
        type = types.str;
        default = "msm";
        description = "User account under which emails are delivered";
      };

      group = mkOption {
        type = types.str;
        default = "msm";
        description = "Group account under which emails are delivered";
      };

      package = mkOption {
        type = types.package;
        default = null;
        description = "The package providing the matrix-sendmail.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    environment.etc."matrix-sendmail/config.env" = {
      mode = "555";
      text = ''
        MSM_SPOOL_DIR=${cfg.spoolDir}
        MSM_LIB_DIR=${cfg.libDir}
        MSM_DELIVERY_USER=${cfg.user}
        MSM_DELIVERY_GROUP=${cfg.group}
      '';
    };

    systemd.tmpfiles.rules = [
      "d /${cfg.spoolDir} 755 root root -"
      "d /${cfg.spoolDir}/system 770 ${cfg.user} ${cfg.group} -"
      "d /${cfg.spoolDir}/user 1777 root root -"
      "d /${cfg.libDir} 770 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.matrix-sendmail = {
      description = "matrix-sendmail delivery service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        MSM_SPOOL_DIR = cfg.spoolDir;
        MSM_LIB_DIR = cfg.libDir;
        MSM_DELIVERY_USER = cfg.user;
        MSM_DELIVERY_GROUP = cfg.group;
      };

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;

        ExecStartPre = "+${cfg.package}/lib/matrix-sendmail/libexec/matrix-sendmail-prep";
        ExecStart = "${cfg.package}/lib/matrix-sendmail/libexec/matrix-sendmail-deliver";
      };
    };

    systemd.timers.matrix-sendmail = {
      description = "Timer to deliver email via matrix-sendmail.";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnUnitActiveSec="${cfg.deliveryInterval}";
      };
    };

    users.users."${cfg.user}" = {
      group = cfg.group;
      description = "matrix-sendmail delivery user";
      home = cfg.spoolDir;
      isSystemUser = true;
    };

    users.groups."${cfg.group}" = { };
  };
}
