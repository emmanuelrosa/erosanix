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
, gameDir ? "$HOME/Games/Arranger"
}:
let
  wineGameDir = "drive_c/Arranger";
  exePath = "$WINEPREFIX/${wineGameDir}/Arranger.exe";
in mkWindowsAppNoCC rec {
  inherit wine graphicsDriver enableVulkan;

  pname = "arranger";
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
    "$HOME/.local/share/${pname}" = "drive_c/users/$USER/AppData/LocalLow/FurnitureAndMattress/Arranger"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the Arranger installation at: ${gameDir}"
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
      desktopName = "Arranger: A Role-Playing Adventure";
      categories = [ "Game" "LogicGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = fetchurl {
      url = "https://arranger.quest/favicon-32x32.png";
      sha256 = "sha256-IbLjqdH25oZ5jhU5Jrft9A2Nvyje1+DQM8CdOGRMZoI=";
    };
  };

  meta = with lib; {
    description = "Find your way in a world of breezy, thoughtful puzzles, along a charming journey of self-discovery.";
    homepage = "https://arranger.quest/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
