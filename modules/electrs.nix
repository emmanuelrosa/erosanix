{ config, pkgs, lib, ... }:

with lib;

let cfg = config.services.electrs;
in {
  options = {
    services.electrs = {
      enable = mkEnableOption "Enable the electrs service.";

      network = mkOption {
        type = types.enum [ "bitcoin" "testnet" "regtest" "signet" ];
        default = "bitcoin";
        description = "The bitcoin network to connect to. 'bitcoin' means mainnet.";
      };

      dbDir = mkOption {
        type = types.path;
        default = "/var/lib/electrs";
        description = "The path to the electrs database directory.";
      };

      daemonDir = mkOption {
        type = types.path;
        default = "/var/lib/bitcoind-mainnet";
        description = "The path to the bitcoind data directory.";
      };

      authMechanism = mkOption {
        type = types.enum [ "cookie_file" "auth" ];
        default = "auth";
        description = "The authentication mechanism can be either a bitcoind cookie file, or the 'auth' configuration setting. When using a cookie file, the user and group settings must be set to those of bitcoind.";
      };

      authFile = mkOption {
        type = types.path;
        default = "/run/agenix/electrs.toml";
        description = "If `authMechanism` is `cookie_file`, then the path to the bitcoind cookie file. Otherwise, the path to an electrs.toml file containing the 'auth' configuration.";
      };

      daemonRPCAddr = mkOption {
        type = types.str;
        default = "127.0.0.1:8332";
        description = "The bitcoind IPv4 RPC address.";
      };

      daemonP2PAddr = mkOption {
        type = types.str;
        default =  "127.0.0.1:8333";
        description = "The bitcoind IPv4 P2P address.";
      };

      electrumRPCAddr = mkOption {
        type = types.str;
        default = "127.0.0.1:50001";
        description = "The Electrum IPv4 RPC address.";
      };

      monitoringAddr = mkOption {
        type = types.str;
        default = "127.0.0.1:4224";
        description = "The electrs IPv4 monitoring address.";
      };

      waitDuration = mkOption { 
        type = types.ints.unsigned;
        default = 10;
        description = "Duration to wait between bitcoind polling.";
      };

      jsonRPCTimeout = mkOption {
        type = types.ints.positive;
        default = 15;
        description = "Duration to wait until bitcoind JSON-RPC timeouts (must be greater than waitDuration).";
      };

      indexBatchSize = mkOption {
        type = types.ints.positive;
        default = 10;
        description = "Number of blocks to get in a single p2p protocol request from bitcoind.";
      };

      indexLookupLimit = mkOption {
        type = types.ints.unsigned;
        default = 0;
        description = "Number of transactions to lookup before returning an error, to prevent 'too popular' addresses from causing the RPC server to get stuck (0 - disable the limit).";
      };

      reindexLastBlocks = mkOption {
        type = types.ints.unsigned;
        default = 0;
        description = "Number of last blocks to reindex (used for testing).";
      };

      serverBanner = mkOption {
        type = types.str;
        default = "electrs";
        description = "Welcome to electrs ${cfg.package.version} (Electrum Rust Server)!"; 
      };

      autoReindex = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically reindex the database if it's inconsistent or in old format.";
      };

      verbose = mkOption {
        type = types.int;
        default = 0;
        description = "Set verbosity level";
      };

      ignoreMempool = mkOption {
        type = types.bool;
        default = false;
        description = "Don't sync mempool - queries will show only confirmed transactions.";
      };

      user = mkOption {
        type = types.str;
        default = "electrs";
        description = "User account under which electrs executes.Must match that of bitcoind when using cookie authentication.";
      };

      group = mkOption {
        type = types.str;
        default = "electrs";
        description = "Group account under which electrs executes. Must match that of bitcoind when using cookie authentication.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.electrs;
        defaultText = lib.literalExpression "pkgs.electrs";
        description = "The package providing electrs.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions =
      [ { assertion = cfg.jsonRPCTimeout > cfg.waitDuration;
          message = "The jsonRPCTimeout must be greater than the waitDuration.";
        }
      ];

    systemd.tmpfiles.rules = [
      "d ${cfg.dbDir} 770 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.electrs = {
      description = "Electrum Rust Server";
      wantedBy = [ "multi-user.target" ];

      environment = {
        ELECTRS_NETWORK = cfg.network;
        ELECTRS_DB_DIR = cfg.dbDir;
        ELECTRS_DAEMON_DIR = cfg.daemonDir;
        ELECTRS_DAEMON_RPC_ADDR = cfg.daemonRPCAddr;
        ELECTRS_DAEMON_P2P_ADDR = cfg.daemonP2PAddr;
        ELECTRS_MONITORING_ADDR = cfg.monitoringAddr;
        ELECTRS_WAIT_DURATION_SECS = builtins.toString cfg.waitDuration;
        ELECTRS_JSONRPC_TIMEOUT_SECS = builtins.toString cfg.jsonRPCTimeout;
        ELECTRS_INDEX_BATCH_SIZE = builtins.toString cfg.indexBatchSize;
        ELECTRS_INDEX_LOOKUP_LIMIT = builtins.toString cfg.indexLookupLimit;
        ELECTRS_REINDEX_LAST_BLOCKS = builtins.toString cfg.reindexLastBlocks;
        ELECTRS_AUTO_REINDEX = if cfg.autoReindex then "true" else "false";
        ELECTRS_SERVER_BANNER = cfg.serverBanner;
        ELECTRS_VERBOSE = "cfg.verbose";
      };

      serviceConfig = let 
        authString = (if cfg.authMechanism == "auth" then "--conf " else "--cookie-file ") + cfg.authFile; 
        ignoreMempool = optionalString cfg.ignoreMempool "--ignore-mempool";
      in {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;

        ExecStart = "${cfg.package}/bin/electrs ${ignoreMempool}  ${authString}";
        Restart = "on-failure";
        RestartSec = 60;
        PrivateTmp = true;
        ProtectSystem = "full";
        NoNewPrivileges = true;
        MemoryDenyWriteExecute = true;
      };
    };

    users.users."${cfg.user}" = {
      group = cfg.group;
      description = "electrs user";
      home = cfg.dbDir;
      isSystemUser = true;
    };

    users.groups."${cfg.group}" = { };
  };
}
