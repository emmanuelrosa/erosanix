
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
, gameDir ? "$HOME/Games/TheOuroborosKing"
}:
let
  wineGameDir = "drive_c/TheOuroborosKing";
  exePath = "$WINEPREFIX/${wineGameDir}/The Ouroboros King.exe";
in mkWindowsAppNoCC rec {
  inherit wine graphicsDriver enableVulkan;

  pname = "the-ouroboros-king";
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
    "$HOME/.local/share/${pname}" = "drive_c/users/$USER/AppData/LocalLow/DefaultCompany/The Ouroboros King"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find The Ouroboros King installation at: ${gameDir}"
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
      desktopName = "The Ouroboros King";
      categories = [ "Game" "LogicGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./the-ouroboros-king.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "Combines the strategic depth of chess with the build variety and replayability of roguelikes";
    homepage = "https://oriolcosp.com/games/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
