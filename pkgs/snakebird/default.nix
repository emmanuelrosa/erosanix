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
, gameDir ? "$HOME/Games/SnakebirdComplete"
}:
let
  wineGameDir = "drive_c/Program Files/SnakebirdComplete";
  exePath = "$WINEPREFIX/${wineGameDir}/Snakebird Complete.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableHUD;

  pname = "snakebird-complete";
  version = "unknown"; #:version:
  wineArch = "win64";
  enableMonoBootPrompt = false;
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  # src is not used at all.
  # This package only provides a launcher.
  # You must provide the game itself.
  # 
  # Use Epic Game Launcher, legendary, etc to install 'Snakebird Complete' to $gameDir
  src = ./.;

  fileMap = { 
    "${gameDir}" = wineGameDir; 
    "$HOME/.local/share/snakebird-complete/Player.log" = "drive_c/users/$USER/AppData/LocalLow/Noumenon Games/Snakebird Complete/Player.log"; 
    "$HOME/.local/share/snakebird-complete/SavesDir" = "drive_c/users/$USER/AppData/LocalLow/Noumenon Games/Snakebird Complete/SavesDir"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $MANGOHUD $WINE "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find 'Snakebird Complete' installed at: ${gameDir}"
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
      desktopName = "Snakebird Complete";
      categories = [ "Game" "LogicGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./snakebird.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "Embark on an extraordinary puzzle-solving adventure bringing together hit classic Snakebird and Snakebird Primer.";
    homepage = "https://nomenongames.com/game/snakebird_complete";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
