{ config, pkgs, lib, ... }:

let cfg = config.services.sendtome;
    userCfg = config.users.users."${cfg.user}";
in {
  options = {
    services.sendtome = {
      enable = lib.mkEnableOption "Whether to set the system sendmail to a script which delivers all mail to a specific user's ~/Maildir.";
      
      package = lib.mkOption {
        type = lib.types.package;
        description = "The sendtome package.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The user to deliver mail to. Must be defined in users.users.";
      };

      spoolDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/spool/sendtome";
        description = "The top-level directory where email messages are stored prior to delivery.";
      };

      deliveryDir = lib.mkOption {
        type = lib.types.path;
        default = "${userCfg.home}/Maildir";
        defaultText = lib.literalExpression "\${userCfg.home}/Maildir";
        example = "$HOME/.mail";
        description = "The top-level directory where email messages are stored prior to delivery.";
      };

      deliveryInterval = lib.mkOption {
        type = lib.types.str;
        default = "10m";
        description = "How frequently to check for queued emails and deliver them.";
      };
    };
  };

  config = let
    prep = pkgs.writeScript "sendtome-prep.bash" ''
      #! ${pkgs.bash}/bin/bash

      ${pkgs.findutils}/bin/find ${cfg.spoolDir}/new -type f | ${pkgs.findutils}/bin/xargs -I "{}" -- chown -v ${cfg.user}:${userCfg.group} {}
    '';

    deliver = pkgs.writeScript "sendtome-deliver.bash" ''
      #! ${pkgs.bash}/bin/bash

      MAILDIR=${cfg.deliveryDir}

      mkdir -p $MAILDIR/new
      mkdir -p $MAILDIR/cur

      ${pkgs.findutils}/bin/find ${cfg.spoolDir}/new -type f | ${pkgs.findutils}/bin/xargs -I "{}" -- mv -v {} $MAILDIR/new/
    '';
  in lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /${cfg.spoolDir} 755 root root -"
      "d /${cfg.spoolDir}/new 1777 root root -"
    ];

    systemd.services.sendtome = {
      description = "sendtome delivery service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = userCfg.group;

        ExecStartPre = "+${prep}";
        ExecStart = "${deliver}";
      };
    };

    systemd.timers.sendtome = {
      description = "Timer to deliver email via sendtome.";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnUnitActiveSec="${cfg.deliveryInterval}";
      };
    };

    environment.systemPackages = [
      (cfg.package.override { spoolDir = cfg.spoolDir;})
    ];
  };
}
