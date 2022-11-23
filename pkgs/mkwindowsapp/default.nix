# Based on code from: https://raw.githubusercontent.com/lucasew/nixcfg/fd523e15ccd7ec2fd86a3c9bc4611b78f4e51608/packages/wrapWine.nix
{ stdenv, lib, makeBinPath, writeShellScript, winetricks, cabextract, gnused, unionfs-fuse
, libnotify }:
{ wine
, wineArch ? "win32"
, winAppRun
, winAppPreRun ? ""
, winAppPostRun ? ""
, winAppInstall ? ""
, name ? "${attrs.pname}-${attrs.version}"
, enableInstallNotification ? true
, fileMap ? {}
, fileMapDuringAppInstall ? false
, persistRegistry ? false # Disabled by default for now because it's experimental.
, persistRuntimeLayer ? false
, ... } @ attrs:
let
  libwindowsapp = ./libwindowsapp.bash;
  
  withFileMap = let
    defaultExtraFileMap = { "$HOME/.config/mkWindowsApp/${attrs.pname}/user.reg" = "user.reg"; 
                            "$HOME/.config/mkWindowsApp/${attrs.pname}/system.reg" = "system.reg";
    };

    extraFileMap = if persistRegistry then defaultExtraFileMap else {};
  in f: builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs f (fileMap // extraFileMap)));

  fileMappingScript = withFileMap (src: dest: ''map_file "${src}" "${dest}"'');
  persistFilesScript = withFileMap (dest: src: ''persist_file "${src}" "${dest}"'');

  launcher = writeShellScript "wine-launcher" ''
    source ${libwindowsapp}
    PATH="$PATH:${makeBinPath [ wine winetricks cabextract gnused unionfs-fuse libnotify ]}"
    MY_PATH="@MY_PATH@"
    OUT_PATH="@out@"
    ARGS="$@"
    WIN_LAYER_HASH=$(printf "%s %s" ${wine} $WA_API | sha256sum | sed -r 's/(.{64}).*/\1/')
    APP_LAYER_HASH=$(printf "%s %s" @MY_PATH@ $WA_API | sha256sum | sed -r 's/(.{64}).*/\1/')
    RUN_LAYER_HASH=$(printf "%s %s" $WIN_LAYER_HASH $APP_LAYER_HASH | sha256sum | sed -r 's/(.{64}).*/\1/')
    BUILD_HASH=$(printf "%s %s %s" $WIN_LAYER_HASH $APP_LAYER_HASH $USER | sha256sum | sed -r 's/(.{64}).*/\1/')
    WA_RUN_APP=''${WA_RUN_APP:-1}
    WINE=${if (builtins.pathExists "${wine}/bin/wine64") then "wine64" else "wine"}
    needs_cleanup="1"

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

    map_file () {
      local s=$1
      local d="$WINEPREFIX/$2"

      echo "Mapping $s to $d"

       if [ -e "$d" ]
       then
         local base_dir=$(dirname "$s")

         mkdir -p "$base_dir"

         if [ -f "$d" ]
         then
           cp -v -n "$d" "$s"
         fi

         if [ -d "$d" ]
         then
           cp -v -r -n "$d" "$base_dir"
         fi
       fi

       if [ -e "$s" ]
       then
         local base_dir=$(dirname "$d")

         rm -v -f -R "$d"
         mkdir -p "$base_dir"
         ln -s -v "$s" "$d"
       fi
    }

    persist_file () {
      local s="$WINEPREFIX/$1"
      local d="$2"
      local base_dir=$(dirname "$d")

      echo "Persisting $s to $d"
      mkdir -p "$base_dir"

      if [ -f "$s" ]
      then
        cp -v -n "$s" "$d"
      fi

      if [ -d "$s" ]
      then
        cp -v -r -n "$s" "$base_dir"
      fi
    }

    mk_windows_layer () {
      echo "Building a Windows $WINEARCH layer at $WINEPREFIX..."
      $WINE boot --init
      wineserver -w
    }

    mk_app_layer () {
      echo "Building an app layer at $WINEPREFIX..."
      show_notification "drive-harddisk" "Installing ${attrs.pname}..."
      ${lib.optionalString fileMapDuringAppInstall fileMappingScript}
      ${winAppInstall}
      wineserver -w
      ${lib.optionalString fileMapDuringAppInstall persistFilesScript}
      show_notification "content-loading" "${attrs.pname} is now installed. Running..."
    }

    run_app () {
      echo "Running Windows app with WINEPREFIX at $WINEPREFIX..."
      if [ "$needs_cleanup" == "1" ]
      then
        echo "Running winAppPreRun."
        ${fileMappingScript}
        ${winAppPreRun}
      fi

      if [ $WA_RUN_APP -eq 1 ]
      then
        ${winAppRun}
        wineserver -w
      else
        echo "WA_RUN_APP is not set to 1. Starting a bash shell instead of running the app. When you're done, please exit the shell."
        bash
      fi

      if [ "$needs_cleanup" == "1" ]
      then
        echo "Running winAppPostRun."
        ${winAppPostRun}
        ${persistFilesScript}
      fi
    }

    wa_init ${wineArch} $BUILD_HASH
    win_layer=$(wa_init_layer $WIN_LAYER_HASH $MY_PATH)
    app_layer=$(wa_init_layer $APP_LAYER_HASH $MY_PATH)
    run_layer=${if persistRuntimeLayer then "$(wa_init_layer $RUN_LAYER_HASH $MY_PATH)" else "\"\""}

    echo "winearch: ${wineArch}"
    echo "windows layer: $win_layer"
    echo "app layer: $app_layer"
    ${lib.optionalString persistRuntimeLayer "echo \"run_layer: $run_layer\""}
    echo "build hash: $BUILD_HASH"

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

    ${lib.optionalString persistRuntimeLayer "wa_close_layer $RUN_LAYER_HASH \"1\""}

    echo "Windows and app layers are initialized.";

    if [ $(wa_is_bottle_initialized $win_layer $app_layer) == "1" ]
    then
      needs_cleanup="0"
      bottle=$(wa_get_bottle_dir $win_layer $app_layer)
    else
      bottle=$(wa_init_bottle $win_layer $app_layer $run_layer)
    fi

    wa_with_bottle $bottle "" "run_app"
    echo "App exited.";

    if [ "$needs_cleanup" == "1" ]
    then
      wa_remove_bottle $bottle
    fi
  '';
in stdenv.mkDerivation ((builtins.removeAttrs attrs [ "fileMap" ]) // {

  preInstall = ''
    mkdir -p $out/bin

    cp ${launcher} $out/bin/.launcher
    substituteInPlace $out/bin/.launcher --subst-var-by MY_PATH $out/bin/.launcher --subst-var out
  '';
})
