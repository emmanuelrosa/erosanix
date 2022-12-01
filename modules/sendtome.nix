{ config, pkgs, lib, ... }:

let cfg = config.services.sendtome;
in {
  options = {
    services.sendtome = {
      setSendmail = lib.mkEnableOption "Whether to set the system sendmail to a script which delivers all mail to a specific user's ~/Maildir.";
      
      user = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The user to deliver mail to. Must be defined in users.users.";
      };
    };
  };

  config = let
    userCfg = config.users.users."${cfg.user}";
  in lib.mkIf cfg.setSendmail {
    services.mail.sendmailSetuidWrapper = {
      setuid = true;
      setgid = true;
      program = "sendmail";
      owner = cfg.user;
      group = userCfg.group;
      source = pkgs.writeScript "sendmail" ''
        #! ${pkgs.bash}/bin/bash
        # Based on a script from https://unix.stackexchange.com/questions/82093/minimal-mta-that-delivers-mail-locally-for-cron

        MAILDIR=${userCfg.home}/Maildir
        rand=$((RANDOM % 1000))
        msgname=$(date +%s).P$$R$rand.$(hostname | tr '/:' '\057\072')

        mkdir -p $MAILDIR/new
        mkdir -p $MAILDIR/tmp
        mkdir -p $MAILDIR/cur

        cat > $MAILDIR/tmp/$msgname
        mv -n $MAILDIR/tmp/$msgname $MAILDIR/new/$msgname
      '';
    };
  };
}
