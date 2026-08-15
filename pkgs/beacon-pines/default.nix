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
, gameDir ? "$HOME/Games/BeaconPines"
}:
let
  wineGameDir = "drive_c/beacon-pines";
  exePath = "$WINEPREFIX/${wineGameDir}/Beacon Pines.exe";
in mkWindowsAppNoCC rec {
  inherit wine graphicsDriver enableVulkan;

  pname = "beacon-pines";
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
    "$HOME/.local/share/${pname}" = "drive_c/users/$USER/AppData/LocalLow/Hiding Spot/Beacon Pines"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the Beacon Pines installation at: ${gameDir}"
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
      desktopName = "Beacon Pines";
      categories = [ "Game" "AdventureGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./beacon-pines.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "Beacon Pines is a cute and creepy adventure game, set within a mysterious book.";
    homepage = "https://www.fellowtraveller.games/beacon-pines";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
