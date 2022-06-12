{ config, pkgs, lib, ... }:

with lib;

let cfg = config.services.protonvpn;
in {
  options = {
    services.protonvpn = {
      enable = mkEnableOption "Enable ProtonVPN. Now using Wireguard instead of OpenVPN."; 

      interface = {
        name = mkOption {
          default = "protonvpn";
          example = "wg0";
          type = types.str;
          description = "The name of the Wireguard network interface to create. Go to https://account.protonmail.com/u/0/vpn/WireGuard to create a Linux Wireguard certificate and download it. You'll need it's content to set the options for this module.";
        };

        address = mkOption {
          default = "10.2.0.2/32";
          example = "10.2.0.2/32";
          type = types.str;
          description = "The IP address of the interface. See your Wireguard certificate.";
        };

        privateKeyFile = mkOption {
          example = "/root/secrets/protonvpn";
          type = types.path;
          description = "The path to a file containing the private key for this interface/peer. Only root should have access to the file. See your Wireguard certificate.";
        };

        dns = mkOption {
          default = "10.2.0.1";
          example = "10.2.0.1";
          type = types.str;
          description = "The IP address of the DNS provided by the VPN. See your Wireguard certificate.";
        };
      };

      endpoint = {
        publicKey = mkOption {
          example = "23*********************************************=";
          type = types.str;
          description = "The public key of the VPN endpoint. See your Wireguard certificate.";
        };

        ip = mkOption {
          example = "48.1.3.4";
          type = types.str;
          description = "The IP address of the VPN endpoint. See your Wireguard certificate.";
        };

        port = mkOption {
          default = 51820;
          example = 51820;
          type = types.port;
          description = "The port number of the VPN peer endpoint. See your Wireguard certificate.";
        };
      };

      gateway = {
        autoDetect = mkOption {
          default = true;
          example = "true";
          type = types.bool;
          description = "Attempt to automatically detect the default gateway. The gateway is used to set up a route so that Wireguard can perform the handshake with the ProtonVPN peer. Try this first, and if it doesn't work then set it to 'false' and use the 'interface' and 'ip' options instead.";
        };

        interface = mkOption {
          default = "eth0";
          example = "eth0";
          type = types.str;
          description = "The network interface which can reach the gateway. This is used to add a route so that the Wireguard handshake can complete.";
        };

        ip = mkOption {
          default = "192.168.1.1";
          example = "192.168.1.1";
          type = types.str;
          description = "The gateway IP address. This is used to add a route so that the Wireguard handshake can complete.";
        };
      };
    };
  };

  config = let
    staticSetup = ''
      ${pkgs.iproute}/bin/ip route add ${cfg.gateway.ip} dev ${cfg.gateway.interface} 
      ${pkgs.iproute}/bin/ip route add ${cfg.endpoint.ip} via ${cfg.gateway.ip}
    '';

    staticShutdown = ''
      ${pkgs.iproute}/bin/ip route del ${cfg.endpoint.ip} via ${cfg.gateway.ip}
      ${pkgs.iproute}/bin/ip route del ${cfg.gateway.ip} dev ${cfg.gateway.interface} 
      ${pkgs.openresolv}/bin/resolvconf -d ${cfg.interface.name}
    '';

    dynamicSetup = ''
      MAX_TRIES=10
      tries=0
      gateway=""
      while [[ -z $gateway && $tries -lt $MAX_TRIES ]]
      do
        sleep 2s
        gateway=$(${pkgs.iproute}/bin/ip route | ${pkgs.gnugrep}/bin/grep "default via" | ${pkgs.coreutils}/bin/cut -d " " -f 3)
        ((++tries))
        echo Gateway inquiry try $tries of $MAX_TRIES.
      done

      if [[ -z $gateway ]]
      then
        echo "ERROR: Failed to acquire the default gateway's IP address."
        exit 1
      fi

      ${pkgs.iproute}/bin/ip route add ${cfg.endpoint.ip} via $gateway
    '';

    dynamicShutdown = ''
      gateway=$(${pkgs.iproute}/bin/ip route | ${pkgs.gnugrep}/bin/grep "default via" | ${pkgs.coreutils}/bin/cut -d " " -f 3)
      ${pkgs.iproute}/bin/ip route del ${cfg.endpoint.ip} via $gateway
      ${pkgs.openresolv}/bin/resolvconf -d ${cfg.interface.name}
    '';
  in mkIf cfg.enable {
    networking.wireguard.interfaces."${cfg.interface.name}" = {
      preSetup = if cfg.gateway.autoDetect then dynamicSetup else staticSetup;

      postSetup = ''
        printf "nameserver ${cfg.interface.dns}" | ${pkgs.openresolv}/bin/resolvconf -a ${cfg.interface.name} -m 0
      '';

      postShutdown = if cfg.gateway.autoDetect then dynamicShutdown else staticShutdown;

      ips = [ "${cfg.interface.address}" ];
      privateKeyFile = "${cfg.interface.privateKeyFile}";
      peers = [
        { publicKey = "${cfg.endpoint.publicKey}";
          allowedIPs = [ "0.0.0.0/0" "::/0"];
          endpoint = "${cfg.endpoint.ip}:${builtins.toString cfg.endpoint.port}";
        }
      ];
    };
  };

  meta.maintainers = with maintainers; [ emmanuelrosa ];
}
