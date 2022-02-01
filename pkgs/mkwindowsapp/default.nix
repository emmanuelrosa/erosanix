# Based on code from: https://raw.githubusercontent.com/lucasew/nixcfg/fd523e15ccd7ec2fd86a3c9bc4611b78f4e51608/packages/wrapWine.nix
{ stdenv, makeBinPath, writeShellScript, winetricks, cabextract, gnused, fuse-overlayfs
, libnotify }:
{ wine
, wineArch ? "win32"
, winAppRun
, winAppInstall ? ""
, name ? "${attrs.pname}-${attrs.version}"
, enableInstallNotification ? true
, fileMap ? {}
, persistRegistry ? false # Disabled by default for now because it's experimental.
, ... } @ attrs:
let
  libwindowsapp = ./libwindowsapp.bash;
  
  withFileMap = f: builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs f fileMap));
  fileMappingScript = withFileMap (src: dest: ''map_file "${src}" "${dest}"'');
  persistFilesScript = withFileMap (dest: src: ''persist_file "${src}" "${dest}"'');

  launcher = writeShellScript "wine-launcher" ''
    source ${libwindowsapp}
    PATH="$PATH:${makeBinPath [ wine winetricks cabextract gnused fuse-overlayfs libnotify ]}"
    MY_PATH="@MY_PATH@"
    ARGS="$@"
    WIN_LAYER_HASH=$(printf "%s %s %s" $(wine --version) ${wineArch} $WA_API | sha256sum | sed -r 's/(.{64}).*/\1/')
    APP_LAYER_HASH=$(printf "%s %s" @MY_PATH@ $WA_API | sha256sum | sed -r 's/(.{64}).*/\1/')
    REGISTRY_PATH="$HOME/.config/mkWindowsApp/${attrs.pname}/registry.reg"

    show_notification () {
      local fallback_icon=$1
      local msg=$2
      local icon=$(find -L $(dirname $(dirname $MY_PATH))/share/icons -name *.png | tail -n 1)

      if [ ! -f $icon ]
      then
        icon=$fallback_icon
      fi

      ${if enableInstallNotification then "notify-send -i $icon \"$msg\"" else "echo 'Notifications are disabled. Ignoring.'"}
    }

    load_registry () {
      if [ -f "$REGISTRY_PATH" ]
      then 
        ${if persistRegistry then "regedit \"$REGISTRY_PATH\"" else "echo 'Not loading the persisted registry.'"}
      fi
    }

    save_registry () {
      mkdir -p "$(dirname $REGISTRY_PATH)"
      ${if persistRegistry then "regedit /E \"$REGISTRY_PATH\"" else "echo 'Not persisting the registry.'"}
    }

    map_file () {
      local s=$1
      local d="$WINEPREFIX/$2"

      echo "Mapping $s to $d"

       if [ -e "$d" ]
       then
         local base_dir=$(dirname "$s")

         mkdir -v -p "$base_dir"
         cp -v -r -n "$d" "$s"
       fi

       if [ -e "$s" ]
       then
         local base_dir=$(dirname "$d")

         rm -v -f -R "$d"
         mkdir -v -p "$base_dir"
         ln -s -v "$s" "$d"
       fi
    }

    persist_file () {
      local s="$WINEPREFIX/$1"
      local d="$2"

      echo "Persisting $s to $d"

       if [ -f "$s" ] || [ -d "$s" ]
       then
         cp -v -r -n "$s" "$d"
       fi
    }
    mk_windows_layer () {
      echo "Building a Windows $WINEARCH layer at $WINEPREFIX..."
      wine boot --init
      wineserver -w
    }

    mk_app_layer () {
      echo "Building an app layer at $WINEPREFIX..."
      show_notification "drive-harddisk" "Installing ${attrs.pname}..."
      ${winAppInstall}
      wineserver -w
      show_notification "content-loading" "${attrs.pname} is now installed. Running..."
    }

    run_app () {
      echo "Running Windows app with WINEPREFIX at $WINEPREFIX..."
      ${fileMappingScript}
      load_registry
      wineserver -w
      ${winAppRun}
      wineserver -w
      save_registry
      wineserver -w
      ${persistFilesScript}
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
in stdenv.mkDerivation ((builtins.removeAttrs attrs [ "fileMap" ]) // {

  preInstall = ''
    mkdir -p $out/bin

    cp ${launcher} $out/bin/.launcher
    substituteInPlace $out/bin/.launcher --subst-var-by MY_PATH $out/bin/.launcher
  '';
})
