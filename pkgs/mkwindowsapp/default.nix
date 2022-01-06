# Based on code from: https://raw.githubusercontent.com/lucasew/nixcfg/fd523e15ccd7ec2fd86a3c9bc4611b78f4e51608/packages/wrapWine.nix
{ stdenv, makeBinPath, writeShellScript, winetricks, cabextract, gnused, fuse-overlayfs }:
{ wine
, wineArch ? "win32"
, winAppRun
, winAppInstall ? ""
, name ? "${attrs.pname}-${attrs.version}"
, ... } @ attrs:
let
  libwindowsapp = ./libwindowsapp.bash;

  launcher = writeShellScript "wine-launcher" ''
    source ${libwindowsapp}
    PATH="$PATH:${makeBinPath [ wine winetricks cabextract gnused fuse-overlayfs ]}"
    MY_PATH="@MY_PATH@"
    ARGS="$@"
    WIN_LAYER_HASH=$(printf "%s %s %s" $(wine --version) ${wineArch} $WA_API | sha256sum | sed -r 's/(.{64}).*/\1/')
    APP_LAYER_HASH=$(printf "%s %s" @MY_PATH@ $WA_API | sha256sum | sed -r 's/(.{64}).*/\1/')

    mk_windows_layer () {
      echo "Building a Windows $WINEARCH layer at $WINEPREFIX..."
      wine boot --init
      wineserver -w
    }

    mk_app_layer () {
      echo "Building an app layer at $WINEPREFIX..."
      ${winAppInstall}
      wineserver -w
    }

    run_app () {
      echo "Running Windows app with WINEPREFIX at $WINEPREFIX..."
      ${winAppRun}
      wineserver -w
    }

    wa_init ${wineArch}
    win_layer=$(wa_init_layer $WIN_LAYER_HASH $MY_PATH)
    app_layer=$(wa_init_layer $APP_LAYER_HASH $MY_PATH)

    echo "winearch: ${wineArch}"
    echo "windows layer: $win_layer"
    echo "app layer: $app_layer"

    if [ -d "$win_layer" ]
    then
      if [ ! -d "$app_layer" ]
      then
        bottle=$(wa_init_bottle $win_layer $app_layer)
        wa_with_bottle $bottle "" "mk_app_layer"
        wa_remove_bottle $bottle
        wa_close_layer $APP_LAYER_HASH
      fi
    else
      if [ -d "$app_layer" ]
      then
        rm -fR "$app_layer"
        app_layer=$(wa_init_layer $APP_LAYER_HASH $MY_PATH)
      fi

      bottle=$(wa_init_bottle $win_layer $app_layer)
      wa_with_bottle $bottle "" "mk_windows_layer"
      wa_remove_bottle $bottle
      wa_close_layer $WIN_LAYER_HASH

      bottle=$(wa_init_bottle $win_layer $app_layer)
      wa_with_bottle $bottle "" "mk_app_layer"
      wa_remove_bottle $bottle
      wa_close_layer $APP_LAYER_HASH
    fi

    echo "Windows and app layers are initialized.";
    bottle=$(wa_init_bottle $win_layer $app_layer)
    wa_with_bottle $bottle "" "run_app"
    echo "App exited.";
    wa_remove_bottle $bottle
  '';
in stdenv.mkDerivation (attrs // {

  preInstall = ''
    mkdir -p $out/bin

    cp ${launcher} $out/bin/.launcher
    substituteInPlace $out/bin/.launcher --subst-var-by MY_PATH $out/bin/.launcher
  '';
})
