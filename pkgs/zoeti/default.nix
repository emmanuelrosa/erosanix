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
, gameDir ? "$HOME/Games/Zoeti"
, enableVulkan ? false
}:
let
  wineGameDir = "drive_c/Zoeti";
  exePath = "$WINEPREFIX/${wineGameDir}/Zoeti.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableHUD graphicsDriver enableVulkan;

  pname = "zoeti";
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
    "$HOME/.local/share/${pname}" = "drive_c/users/$USER/AppData/LocalLow/DuskLight/Zoeti"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $MANGOHUD $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the Zoeti installation at: ${gameDir}"
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
      desktopName = "Zoeti";
      categories = [ "Game" "CardGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./zoeti.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "A turn-based roguelite that features a deck of playing cards used to create card combos and activate skills in the heat of battle.";
    homepage = "https://www.softsourcepublishing.com/release/zoeti/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
