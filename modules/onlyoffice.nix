{ config, lib, pkgs, erosanix, ... }:

with lib;

let

  cfg = config.programs.onlyoffice;

  x11Fonts = pkgs.runCommand "X11-fonts" { preferLocalBuild = true; } ''
    mkdir -p "$out"
    font_regexp='.*\.\(ttf\|ttc\|otf\|pcf\|pfa\|pfb\|bdf\)\(\.gz\)?'
    find ${toString config.fonts.fonts} -regex "$font_regexp" \
      -exec ln -sf -t "$out" '{}' \;
    cd "$out"
    ${pkgs.gzip}/bin/gunzip -f *.gz
    ${pkgs.xorg.mkfontscale}/bin/mkfontscale
    ${pkgs.xorg.mkfontdir}/bin/mkfontdir
    cat $(find ${pkgs.xorg.fontalias}/ -name fonts.alias) >fonts.alias
  '';

in

{

  options = {
    programs.onlyoffice = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Whether to add system fonts to ONLYOFFICE Desktop Editors.
          NOTE: This is a temporary fix.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ (erosanix.packages.x86_64-linux.onlyoffice-bin.override { fonts = x11Fonts; }) ];
  };
}
