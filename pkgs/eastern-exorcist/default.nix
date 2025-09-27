{ lib
, mkWindowsAppNoCC
, wine
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, zenity
, enableHUD ? false
, graphicsDriver ? "prefer-wayland"
, gameDir ? "$HOME/Games/EasternExorcist"
, enableVulcan ? false
}:
let
  wineGameDir = "drive_c/EasternExorcist";
  exePath = "$WINEPREFIX/${wineGameDir}/EasternExorcist.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableHUD graphicsDriver enableVulcan;

  pname = "eastern-exorcist";
  version = "unknown";
  wineArch = "win64";
  inhibitIdle = true;
  dontUnpack = true;
  enableMonoBootPrompt = false;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  # src is not used at all.
  # This package only provides a launcher.
  # You must provide the game itself.
  # 
  # 1. Use legendary to install MonumentValley.
  # 2. Make sure gameDir points to the MonumentValley directory.
  # 3. Now you can use this package to run MonumentValley.
  src = ./.;

  fileMap = { 
    "${gameDir}" = wineGameDir; 
    "$HOME/.local/share/${pname}" = "drive_c/users/$USER/AppData/LocalLow/WildFire/EasternExorcist"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $MANGOHUD $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the Eastern Exorcist installation at: ${gameDir}"
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
      desktopName = "Eastern Exorcist";
      categories = [ "Game" "ActionGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./eastern-exorcist.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "A 2D side-scrolling action RPG set in a fantasy Eastern world with spirits and monsters.";
    homepage = "https://www.thermitegames.com/games/eastern-exorcist/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
