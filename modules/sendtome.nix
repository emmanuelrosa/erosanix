{ config, pkgs, lib, ... }:

let cfg = config.services.sendtome;
    userCfg = config.users.users."${cfg.user}";
in {
  options = {
    services.sendtome = {
      setSendmail = lib.mkEnableOption "Whether to set the system sendmail to a script which delivers all mail to a specific user's ~/Maildir.";
      
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
  in lib.mkIf cfg.setSendmail {
    systemd.tmpfiles.rules = [
      "d /${cfg.spoolDir} 755 root root -"
      "d /${cfg.spoolDir}/new 1777 root root -"
      "d /${cfg.spoolDir}/tmp 1777 root root -"
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

    services.mail.sendmailSetuidWrapper = {
      owner = cfg.user;
      group = userCfg.group;
      program = "sendmail";
      source = "${(pkgs.writeShellApplication { 
        name = "sendmail";
        runtimeInputs = with pkgs; [ coreutils ];
        text = ''
          #! ${pkgs.bash}/bin/bash
          # Based on a script from https://unix.stackexchange.com/questions/82093/minimal-mta-that-delivers-mail-locally-for-cron

          rand=$((RANDOM % 1000))
          msgname=$(date +%s).P$$R$rand.$(${pkgs.nettools}/bin/hostname | tr '/:' '\057\072')
          tmp_msgpath="${cfg.spoolDir}/tmp/$msgname"

          cat > "$tmp_msgpath"

          # If the encoding is base64, then decode into plain text.
          if [ "$(${pkgs.gnugrep}/bin/grep 'Content-Transfer-Encoding: base64' "$tmp_msgpath")" != "" ] 
          then 
            tmp_message=$(mktemp)
            sed -e '/^$/,$d' < "$tmp_msgpath" > "$tmp_message"
            echo "" >> "$tmp_message"
            sed -e '1,/^To\:/d' < "$tmp_msgpath" | base64 -d >> "$tmp_message"
            mv "$tmp_message" "$tmp_msgpath"
          fi

          tmp_message=$(mktemp)

          if [ "$(${pkgs.gnugrep}/bin/grep 'Message-ID:' "$tmp_msgpath")" == "" ] 
          then
            echo "Message-ID: <$(${pkgs.util-linux}/bin/uuidgen)>" > "$tmp_message"
          fi

          if [ "$(${pkgs.gnugrep}/bin/grep 'Date:' "$tmp_msgpath")" == "" ] 
          then
            echo "Date: $(date -R)" >> "$tmp_message"
          fi

          cat "$tmp_msgpath" >> "$tmp_message"
          mv "$tmp_message" "$tmp_msgpath"

          mv -n "$tmp_msgpath" "${cfg.spoolDir}/new/$msgname"
        '';
      })}/bin/sendmail";
    };
  };
}
