{ stdenvNoCC
, lib
, mkWindowsAppNoCC
, wine
, requireFile
, rsync
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, instanceName ? "default" # This should be alphanumeric, no spaces
, useNativeTextEditor ? true # Edit text files using a native Linux text editor, via xdg-open.
}: let
  disableBundledTextEditor = ''
    rm -fR "$WINEPREFIX/drive_c/users/$USER/Zorro/Notepad++"
    mkdir "$WINEPREFIX/drive_c/users/$USER/Zorro/Notepad++"
    cp "$WINEPREFIX/drive_c/windows/system32/winebrowser.exe" "$WINEPREFIX/drive_c/users/$USER/Zorro/Notepad++/notepad++.exe"
  '';
in mkWindowsAppNoCC rec { 
  inherit wine;

  pname = "zorro-${instanceName}";
  version = "2.64.3"; #:version:
  dontUnpack = true;
  wineArch = "win64";
  enableMonoBootPrompt = false;

  enabledWineSymlinks = {
    desktop = false;
  };

  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  src = requireFile {
    name = "Zorro_setup.exe";
    hash = "sha256-ennGQbmsAUwPCt4JglPQeazGuoNFGz/z0W6DfxqNvV0="; #:hash:
    message = "To download Zorro, first visit https://zorro-project.com/download.php and ensure the current stable version of Zorro is ${version}. Then, execute:\n nix-prefetch-url --type sha256 https://opserver.de/down/Zorro_setup.exe"; 
  };

  winAppInstall = ''
    cp ${src} "$WINEPREFIX/drive_c/windows/temp/setup.exe"
    $WINE "$WINEPREFIX/drive_c/windows/temp/setup.exe"
    rm -fR "$WINEPREFIX/drive_c/windows/temp/setup.exe"
    rmdir "$WINEPREFIX/drive_c/users/$USER/Zorro/Cache"

    ${lib.optionalString useNativeTextEditor disableBundledTextEditor}
  '';

  winAppPreRun = ''
    excludes=""
    cache_dir=$(mktemp --suffix=zorro -d)
    mkdir -p "$HOME/.local/share/${pname}"
    rm "$HOME/.local/share/${pname}/Cache"
    ln -s "$cache_dir" "$HOME/.local/share/${pname}/Cache"

    mkdir -p "$HOME/.cache/${pname}"
    version_file="$HOME/.cache/${pname}/version.txt"
    needs_sync="1"

    if [ -e "$version_file" ]
    then
      excludes="--exclude 'History/AssetsFix.csv'"
    fi

    if [ "$(cat $version_file)" == "${version}" ]
    then
      needs_sync=0
    fi

    if [ "$needs_sync" == "1" ]
    then
      echo "Synching Zorro installation..."
      ${rsync}/bin/rsync -a --checksum --mkpath $excludes "$WINEPREFIX/drive_c/users/$USER/Zorro/" "$HOME/.local/share/${pname}/"
      echo "${version}" > "$version_file"
    fi
  '';

  winAppRun = ''
    $WINE "$HOME/.local/share/${pname}/@executable@" "$ARGS"
  '';

  winAppPostRun = ''
    rm "$HOME/.local/share/${pname}/Cache"
  '';

  installPhase = ''
    runHook preInstall

    cp $out/bin/.launcher $out/bin/zorro-${instanceName}
    substituteInPlace $out/bin/zorro-${instanceName} --subst-var-by executable Zorro.exe

    cp $out/bin/.launcher $out/bin/zview-${instanceName}
    substituteInPlace $out/bin/zview-${instanceName} --subst-var-by executable Zview.exe

    runHook postInstall
  '';

  desktopItems = let 
    icon = "zorro";
    genericName = "Financial research and trading software";
    categories = ["Office" "Finance"];
  in [
    (makeDesktopItem {
      inherit icon genericName categories;

      name = "zorro";
      exec = "zorro-${instanceName}";
      desktopName = "Zorro (${instanceName})";
    })

    (makeDesktopItem {
      inherit icon;

      genericName = "Image Viewer";
      name = "zview";
      exec = "zview-${instanceName}";
      desktopName = "Zview (${instanceName})";
      categories = [ "Graphics" "RasterGraphics" ];
      mimeTypes = [ "image/png" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = "zorro";
    icoIndex = 0;
    src = ./zorro.ico;
  };

  meta = with lib; {
    description = "A free institutional-grade software tool for data collection, financial research, and algorithmic trading with AI-based algorithms.";
    homepage = "https://zorro-project.com/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "zorro-${instanceName}";
  };
}
