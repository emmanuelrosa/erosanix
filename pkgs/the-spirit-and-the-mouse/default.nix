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
, gameDir ? "$HOME/Games/TheSpiritandtheMouse"
}:
let
  wineGameDir = "drive_c/Program Files/TheSpiritandtheMouse";
  exePath = "$WINEPREFIX/${wineGameDir}/TheSpiritAndTheMouse.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableHUD;

  pname = "the-spirit-and-the-mouse";
  version = "unknown"; #:version:
  wineArch = "win64";
  enableMonoBootPrompt = false;
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  # src is not used at all.
  # This package only provides a launcher.
  # You must provide the game itself.
  # 
  # Use Epic Game Launcher, legendary, etc to install 'The Spirit and the Mouse' to $gameDir
  src = ./.;

  fileMap = { 
    "${gameDir}" = wineGameDir; 
    "$HOME/.local/share/TheSpiritAndTheMouse" = "drive_c/users/$USER/AppData/LocalLow/Alblune/TheSpiritAndTheMouse"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $MANGOHUD $WINE "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find 'The Spirit and the Mouse' installed at: ${gameDir}"
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
      desktopName = "The Spirit and the Mouse";
      categories = [ "Game" "AdventureGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./TheSpiritAndTheMouse.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "Play as Lila the mouse! Help humans, and meet a cast of colorful Spirits in this charming narrative adventure!";
    homepage = "https://thespiritandthemouse.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
