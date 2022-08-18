{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.fonts.usrsharefonts;

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
in

{

  options = {
    fonts.usrsharefonts = {
      enable = mkOption {
        type = types.bool;
        default = false;
        defaultText = literalExpression "false";
        description = lib.mdDoc ''
          Whether to create 
          {file}`/usr/share/fonts`
          and fill it with the system fonts.
        '';
      };
    };
  };

  config = {
    system.activationScripts.usrsharefonts = if cfg.enable then ''
      mkdir -m 0755 -p /usr/share
      ln -sfn ${x11Fonts} /usr/share/.fonts.tmp
      mv /usr/share/.fonts.tmp /usr/share/fonts
    '' else ''
      rm -f /usr/share/fonts
      rm -f /usr/share/.fonts.tmp
      rmdir --ignore-fail-on-non-empty /usr/share /usr
    '';
  };
}
