{ lib
, mkWindowsAppNoCC
, fetchurl
, wine
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, zenity
, graphicsDriver ? "prefer-wayland"
, gameDir ? "$HOME/Games/BoxesLostFragments"
}:
let
  wineGameDir = "drive_c/BoxesLostFragments";
  exePath = "$WINEPREFIX/${wineGameDir}/Boxes Lost Fragments.exe";
in mkWindowsAppNoCC rec {
  inherit wine graphicsDriver;

  pname = "boxes-lost-fragments";
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
    "$HOME/.local/share/${pname}" = "drive_c/users/$USER/AppData/LocalLow/Big Loop Studios/Boxes Lost Fragments"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the Boxes Lost Fragments installation at: ${gameDir}"
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
      desktopName = "Boxes Lost Fragments";
      categories = [ "Game" "LogicGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./boxes-lost-fragments.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "As a legendary thief, your next assignment lures you into a grand and lavish mansion. There you find a series of puzzle boxes, designed for an unknown purpose.";
    longDescription = "What should have been a quick in-and-out, gradually turns into your own harrowing struggle for freedom and answers.";
    homepage = "https://bigloopstudios.com/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
