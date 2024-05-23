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
}:
let
  title = "ChessUltraEifZw";
  gameDir = "$HOME/Games/${title}";
  wineGameDir = "drive_c/Program Files/Epic Games/${title}";
  exePath = "$WINEPREFIX/${wineGameDir}/Chess2.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableHUD;

  pname = "chess-ultra";
  version = "unknown"; #:version:
  wineArch = "win64";
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  src = ./.;

  fileMap = { 
    "${gameDir}" = wineGameDir; 
    "$HOME/.local/share/chess-ultra/Local" = "drive_c/users/$USER/AppData/Local";
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $MANGOHUD $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the ${title} installation at: ${gameDir}. Use legendary to install `Chess Ultra` and try again."
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
      desktopName = "Chess Ultra";
      categories = [ "Game" "BoardGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./chess-ultra.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "The most breathtaking chess game ever made. Experience stunning 4K visuals, seamless online multiplayer, Grandmaster approved AI and full VR compatibility.";
    homepage = "https://ripstone.com/games/chess-ultra/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
