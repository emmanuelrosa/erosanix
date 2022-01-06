WA_API="1"
_wa_cache_dir="$HOME/.cache/mkWindowsApp"
_wa_winearch=""

# Library initialization
wa_init () {
  _wa_winearch=$1
}

# Layers API
_wa_get_layer () {
  local input_hash=$1

  printf "%s" "$_wa_cache_dir/$input_hash"
}

wa_init_layer () {
  local input_hash=$1
  local reference=$2
  local layer_dir=$(_wa_get_layer $input_hash)
  local incomplete_layer_dir="$layer_dir.incomplete"

  if [ ! -d "$layer_dir" ]
  then
    if [ ! -d "$incomplete_layer_dir" ]
    then
      mkdir -p "$incomplete_layer_dir/wineprefix"

      pushd "$incomplete_layer_dir" > /dev/null
      echo "$WA_API" > api
      echo "$reference" > refs
      chmod ugo-w api
      popd > /dev/null
    fi
  else
      local tmp_refs=$(mktemp --suffix=.mkwindowsApp)
      cat "$layer_dir/refs" > "$tmp_refs"
      echo "$reference" >> "$tmp_refs"
      cat "$tmp_refs" | sort | uniq > "$layer_dir/refs"
      rm -f "$tmp_refs"
  fi

  printf "%s" $layer_dir
}

wa_close_layer () {
  local input_hash=$1
  local layer_dir=$(_wa_get_layer $input_hash)
  local incomplete_layer_dir="$layer_dir.incomplete"

  if [ -d "$incomplete_layer_dir" ]
  then
    pushd "$incomplete_layer_dir/wineprefix"
    # chmod -R ugo-w .
    popd
    
    pushd "$(dirname $incomplete_layer_dir)"
    mv "$(basename $incomplete_layer_dir)" "$(basename $layer_dir)"
    popd
  fi
}

# Wine bottle API
wa_init_bottle () {
  local windows_layer=$1
  local app_layer=$2
  local tmp_dir=$(mktemp -d --suffix=.mkwindowsApp)
  local work_dir="$tmp_dir/work_dir"
  local upper_dir="$tmp_dir/upper_dir"
  local wineprefix="$tmp_dir/wineprefix"

  if [ -d "$windows_layer" ]
  then
    echo "overlay" > "$tmp_dir/type"

    if [ -d "$app_layer" ]
    then
      mkdir -p "$work_dir"
      mkdir -p "$upper_dir"
      mkdir -p "$wineprefix"

      fuse-overlayfs -o lowerdir=$windows_layer/wineprefix:$app_layer/wineprefix,upperdir=$upper_dir,workdir=$work_dir $wineprefix
    else
      work_dir="$app_layer.incomplete/workdir"
      upper_dir="$app_layer.incomplete/wineprefix"
      mkdir -p "$work_dir"
      mkdir -p "$wineprefix"

      fuse-overlayfs -o lowerdir=$windows_layer/wineprefix,upperdir=$upper_dir,workdir=$work_dir $wineprefix
    fi

  else
    echo "plain" > "$tmp_dir/type"
    pushd "$tmp_dir" > /dev/null
    ln -s "$windows_layer.incomplete/wineprefix" wineprefix 
    popd > /dev/null
  fi

  printf "%s" "$tmp_dir"
}

wa_remove_bottle () {
  local bottle_dir=$1
  local wineprefix="$bottle_dir/wineprefix"

  if [ -d "$bottle_dir" ]
  then
    local type=$(cat $bottle_dir/type)

    if [ "$type" = "overlay" ]
    then
      fusermount -u $wineprefix
    fi

    rm -fR "$bottle_dir"
  fi
}

wa_with_bottle () {
  local bottle_dir=$1
  local dlloverrides=$2
  local callback=$3
  export WINEARCH="$_wa_winearch"
  export WINEPREFIX="$bottle_dir/wineprefix"
  export WINEDLLOVERRIDES="winemenubuilder.exe=d;$dlloverrides"

  ($callback)
}
