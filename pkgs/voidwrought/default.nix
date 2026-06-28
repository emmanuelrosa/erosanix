{ lib
, mkWindowsAppNoCC
, fetchurl
, wine
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, zenity
, enableVulkan ? false
, graphicsDriver ? "prefer-wayland"
, gameDir ? "$HOME/Games/Voidwrought"
}:
let
  wineGameDir = "drive_c/Arranger";
  exePath = "$WINEPREFIX/${wineGameDir}/Voidwrought.exe";
in mkWindowsAppNoCC rec {
  inherit wine graphicsDriver enableVulkan;

  pname = "voidwrought";
  version = "unknown";
  wineArch = "win64";
  inhibitIdle = true;
  dontUnpack = true;
  enableMonoBootPrompt = false;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  # src is not used at all.
  # This package only provides a launcher.
  # You must provide the game itself.
  src = ./.;

  fileMap = { 
    "${gameDir}" = wineGameDir; 
    "$HOME/.local/share/${pname}/Voidwrought" = "drive_c/users/$USER/AppData/LocalLow/Powersnake/Voidwrought"; 
    "$HOME/.local/share/${pname}/GameAnalytics" = "drive_c/users/$USER/AppData/Local/GameAnalytics"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the Voidwrought installation at: ${gameDir}"
    fi
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/${pname}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Voidwrought";
      categories = [ "Game" "AdventureGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = fetchurl {
      url = "https://www.voidwrought.com/favicon.png";
      sha256 = "sha256-zQjxKyG0Zm+0KBAHrfgT/iO7Bbcx28/MEVOUV6pR9MQ=";
    };
  };

  meta = with lib; {
    description = "Explore the thawing ruins of the First Civilisation in this cosmic horror metroidvania.";
    homepage = "https://www.voidwrought.com/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
