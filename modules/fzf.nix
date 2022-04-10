{ config, pkgs, lib, ... }:

let cfg = config.programs.fzf;
in {
  options = {
    programs.fzf = {
      enable = lib.mkEnableOption "Enable fzf bindings and command completions in Bash interactive shells.";
      
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.fzf;
        defaultText = lib.literalExpression "pkgs.fzf";
        description = "The package providing fzf.";
      };

      findCommand = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The command used to find files and directories.";
      };

      findFilesAndDirectoriesCommand = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The command used to find files and directories when CTRL-T is used.";
      };

      findDirectoriesCommand = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The command used to find directories when ALT-C is used.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.bash = { 
      enableCompletion = true;
      interactiveShellInit = ''
        source "${cfg.package}/share/fzf/key-bindings.bash"
        source "${cfg.package}/share/fzf/completion.bash"
        ${lib.optionalString ("" != cfg.findCommand) "export FZF_DEFAULT_COMMAND=\"${cfg.findCommand}\""}
        ${lib.optionalString ("" != cfg.findFilesAndDirectoriesCommand) "export FZF_CTRL_T_COMMAND=\"${cfg.findFilesAndDirectoriesCommand}\""}
        ${lib.optionalString ("" != cfg.findDirectoriesCommand) "export FZF_ALT_C_COMMAND=\"${cfg.findDirectoriesCommand}\""}
      '';
    };

    environment.systemPackages = [ cfg.package ];
  };
}
