{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.onlyoffice;

  x11Fonts = pkgs.runCommand "X11-fonts" { preferLocalBuild = true; } ''
    mkdir -p "$out"
    font_regexp='.*\.\(ttf\|ttc\|otf\|pcf\|pfa\|pfb\|bdf\)\(\.gz\)?'
    find ${toString config.fonts.fonts} -regex "$font_regexp" \
      -exec cp '{}' "$out" \;
    cd "$out"
    ${pkgs.gzip}/bin/gunzip -f *.gz
    ${pkgs.xorg.mkfontscale}/bin/mkfontscale
    ${pkgs.xorg.mkfontdir}/bin/mkfontdir
    cat $(find ${pkgs.xorg.fontalias}/ -name fonts.alias) >fonts.alias
  '';

  mkFHSEnv = onlyofficeUnwrapped: pkgs.buildFHSUserEnvBubblewrap {
    name = "onlyoffice";
    runScript = "DesktopEditors";
    extraBwrapArgs = [ "--tmpfs /usr/share"
                       "--symlink ${x11Fonts} /usr/share/fonts" 
                     ];

    targetPkgs = pkgs: with pkgs; [
      onlyofficeUnwrapped
    ];

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      test -d ${onlyofficeUnwrapped}/share/icons && ln -s ${onlyofficeUnwrapped}/share/icons $out/share
      cp ${onlyofficeUnwrapped}/share/applications/onlyoffice-desktopeditors.desktop $out/share/applications
      substituteInPlace $out/share/applications/onlyoffice-desktopeditors.desktop \
        --replace "${onlyofficeUnwrapped}/bin/DesktopEditors" "$out/bin/onlyoffice"
    '';
  };
in

{
  options = {
    programs.onlyoffice = {
      enable = mkOption {
        type = types.bool;
        default = false;
        defaultText = literalExpression "false";
        description = lib.mdDoc ''
          Whether to install the onlyoffice desktop application with access to system fonts.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.onlyoffice-bin;
        defaultText = lib.literalExpression "pkgs.onlyoffice-bin";
        description = "The package providing onlyoffice.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ (mkFHSEnv cfg.package) ];
  };
}
