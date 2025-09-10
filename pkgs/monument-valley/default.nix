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
, gameDir ? "$HOME/Games/MonumentValley"
}:
let
  wineGameDir = "drive_c/MonumentValley";
  exePath = "$WINEPREFIX/${wineGameDir}/Monument Valley.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableHUD graphicsDriver;

  pname = "monument-valley";
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
    "$HOME/.local/share/${pname}" = "drive_c/users/$USER/AppData/LocalLow/ustwo games/Monument Valley"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $MANGOHUD $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the MonumentValley installation at: ${gameDir}"
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
      desktopName = "Monument Valley";
      categories = [ "Game" "LogicGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./monument-valley.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "Embark on a journey of forgiveness through impossible environments and illusionary puzzles.";
    homepage = "https://www.monumentvalleygame.com/mv3";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
