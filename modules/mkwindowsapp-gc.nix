{ config, pkgs, lib, erosanix, ... }:

with lib;

let cfg = config.services.mkwindowsapp-gc;
in {
  options = {

    services.mkwindowsapp-gc = {
      enable = mkEnableOption "Enable automatic daily execution of the mkWindowsApp garbage collector.";

      package = mkOption {
        type = types.package;
        default = erosanix.packages.x86_64-linux.mkwindowsapp-tools;
        description = "The package providing the mkwindowsapp-tools.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.mkwindowsapp-gc = {
      description = "Clean up outdated mkWindowsApp layers.";
      script = "${cfg.package}/bin/mkwindows-tools-gc";
      serviceConfig = {
        ExecCondition = pkgs.writeScript "mkwindowsapp-gc-execcondition" ''
          #!/bin/sh
          stat $HOME/.cache/mkWindowsApp
        '';
      };
    };

    systemd.user.timers.mkwindowsapp-gc = {
      description = "Timer to clean up outdated mkWindowsApp layers.";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1h";
      }; 
    };
  };
}
