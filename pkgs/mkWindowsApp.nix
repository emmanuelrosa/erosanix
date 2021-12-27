# Based on code from: https://raw.githubusercontent.com/lucasew/nixcfg/fd523e15ccd7ec2fd86a3c9bc4611b78f4e51608/packages/wrapWine.nix
{ stdenv, makeBinPath, writeShellScript, winetricks, gnused, fuse-overlayfs }:
{ wine
, wineArch ? "win32"
, runScript
, tricks ? [ ]
, installScript ? ""
, setupScript ? ""
, teardownScript ? ""
, name ? "${attrs.pname}-${attrs.version}"
, ... } @ attrs:
let
  tricksStmt =
    if (builtins.length tricks) > 0 then
      builtins.concatStringsSep " " tricks
    else
      "-V";

  launcher = writeShellScript "wine-launcher" ''
    PATH="$PATH:${makeBinPath [ wine winetricks gnused fuse-overlayfs ]}"
    MY_PATH="@MY_PATH@"
    ARGS="$@"
    CACHE_DIR="$HOME/.cache/mkWindowsApp"
    TMP_DIR=$(mktemp -d --suffix=.mkwindowsApp)

    WIN_LAYER_HASH=$(printf "%s %s" $(wine --version) ${wineArch} | sha256sum | sed -r 's/(.{64}).*/\1/')
    WIN_LAYER_DIR="$CACHE_DIR/$WIN_LAYER_HASH"
    WIN_LAYER_REF="$CACHE_DIR/$WIN_LAYER_HASH.referrers"

    APP_LAYER_HASH=$(echo -n @MY_PATH@ | sha256sum | sed -r 's/(.{64}).*/\1/')
    APP_LAYER_DIR="$CACHE_DIR/$APP_LAYER_HASH"
    APP_LAYER_REF="$CACHE_DIR/$APP_LAYER_HASH.referrers"

    export WINEPREFIX="$TMP_DIR/wineprefix"
    export WINEARCH="${wineArch}"

    # mk_windows_layer: Builds the WINEPREFIX which serves as the lowest overlayfs layer
    # params: winearch temp_dir
    mk_windows_layer () {
      export WINEARCH="$1"
      export WINEPREFIX="$2/wineprefix"
      echo "Building a Windows $WINEARCH layer at $WINEPREFIX..."
      wine boot --init
      wineserver -w
      mkdir -p "$WIN_LAYER_DIR"
      echo "Copying Windows layer to $WIN_LAYER_DIR..."
      pushd "$WINEPREFIX"
      cp -a . "$WIN_LAYER_DIR/";
      popd
    }

    # mk_app_layer: Builds a WINEPREFIX which serves as the app layer.
    # params: winearch temp_dir
    mk_app_layer () {
      local upper_dir="$2/upper_dir"
      local work_dir="$2/work_dir"
      export WINEARCH="$1"
      export WINEPREFIX="$2/wineprefix"
      echo "Building an app layer at $WINEPREFIX..."
      fuse-overlayfs -o lowerdir=$WIN_LAYER_DIR,upperdir=$upper_dir,workdir=$work_dir $WINEPREFIX
      winetricks ${tricksStmt}
      ${installScript}
      wineserver -w
      fusermount -u "$WINEPREFIX"
      mkdir -p "$APP_LAYER_DIR"
      echo "Copying app layer to $app_layer_dir..."
      pushd "$upper_dir"
      cp -a . "$APP_LAYER_DIR/";
      popd
    }

    # with_wine_prefix: Sets up a WINEPREFIX and calls the function provided with WINEARCH and temp dir. WINEPREFIX is temp_dir/wineprefix.
    # params: winearch callback
    with_wine_prefix () {
      local tmp_dir=$(mktemp -d --suffix=.mkwindowsApp)
      local work_dir="$tmp_dir/work_dir"
      local upper_dir="$tmp_dir/upper_dir"
      local wineprefix="$tmp_dir/wineprefix"
      local winearch="$1"
      local callback="$2"

      mkdir -p "$work_dir"
      mkdir -p "$upper_dir"
      mkdir -p "$wineprefix"

      ($callback $winearch $tmp_dir);
    }

    # mk_layers: Builds the overlayfs "layers".
    # params: winearch win_layer_dir app_layer_dir
    mk_layers () {
      local winearch="$1"
      local win_layer_dir="$2"
      local app_layer_dir="$3"

      if [ ! -d "$win_layer_dir" ]
      then
        rm -fR "$app_layer_dir"
        with_wine_prefix $winearch "mk_windows_layer"
      fi

      if [ ! -d "$app_layer_dir" ]
      then
        with_wine_prefix $winearch "mk_app_layer"
      fi

      echo "Windows and app layers are initialized.";
    }

    # add_referrer: Appends a referrer to a referrer file
    # params: referrers_file
    add_referrer () {
      local temp_ref=$(mktemp --suffix=.mkwindowsApp)
      local ref_file=$1
      touch $ref_file
      cat $ref_file > $temp_ref
      echo $MY_PATH >> $temp_ref
      cat $temp_ref | uniq | sort > $ref_file;
    }

    run_app_or_shell () {
      local upper_dir="$2/upper_dir"
      local work_dir="$2/work_dir"
      export WINEARCH="$1"
      export WINEPREFIX="$2/wineprefix"
      fuse-overlayfs -o lowerdir=$WIN_LAYER_DIR:$APP_LAYER_DIR,upperdir=$upper_dir,workdir=$work_dir $WINEPREFIX
      ${setupScript}

      if [ ! "$REPL" == "" ];
      then
        echo "Entering shell with WINEPREFIX at $WINEPREFIX..."
        pushd $WINEPREFIX
        bash
        popd
      else
        echo "Running Windows app with WINEPREFIX at $WINEPREFIX..."
        ${runScript}
        wineserver -w
      fi

      # Teardown WINEPREFIX and garbage-collect layers. 
      fusermount -u $WINEPREFIX
      ${teardownScript}

      echo "App exited.";
    }

    mkdir -p "$CACHE_DIR"
    mk_layers $WINEARCH $WIN_LAYER_DIR $APP_LAYER_DIR

    # Add the path of this script to the referrers files
    # This is used to track dependencies of the layers, so that unreferrenced layers can be automatically garbage-collected.
    add_referrer $WIN_LAYER_REF
    add_referrer $APP_LAYER_REF

    with_wine_prefix $WINEARCH "run_app_or_shell"

    # TODO: Clean up old layers (using the referrers files)
  '';
in stdenv.mkDerivation (attrs // {

  preInstall = ''
    mkdir -p $out/bin

    cp ${launcher} $out/bin/.launcher
    substituteInPlace $out/bin/.launcher --subst-var-by MY_PATH $out/bin/.launcher
  '';
})
