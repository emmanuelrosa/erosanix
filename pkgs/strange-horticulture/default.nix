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
, gameDir ? "$HOME/Games/StrangeHorticulture"
}:
let
  wineGameDir = "drive_c/StrangeHorticulture";
  exePath = "$WINEPREFIX/${wineGameDir}/Strange Horticulture.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableHUD graphicsDriver;

  pname = "strange-horticulture";
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
    "$HOME/.local/share/${pname}" = "drive_c/users/$USER/AppData/LocalLow/BadVikingLtd/Strange Horticulture"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $MANGOHUD $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the StrangeHorticulture installation at: ${gameDir}"
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
      desktopName = "Strange Horticulture";
      categories = [ "Game" "LogicGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./strange-horticulture.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "Strange Horticulture is an occult puzzle game in which you play as the proprietor of a local plant store.";
    longDescription = "Find and identify new plants, pet your cat, speak to a coven, or join a cult. Use your collection of powerful plants to influence the story and unravel Undermere’s dark mysteries.";
    homepage = "https://www.strangehorticulture.com/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
