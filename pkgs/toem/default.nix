{ lib
, mkWindowsAppNoCC
, wine
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, zenity
, mangohud
, enableHUD ? false
, gameDir ? "$HOME/Games/TOEM"
}:
let
  wineGameDir = "drive_c/Program Files/TOEM";
  exePath = "$WINEPREFIX/${wineGameDir}/TOEM.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableHUD;

  pname = "toem";
  version = "unknown"; #:version:
  wineArch = "win64";
  enableMonoBootPrompt = false;
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  # src is not used at all.
  # This package only provides a launcher.
  # You must provide the game itself.
  # 
  # Use Epic Game Launcher, legendary, etc to install TOEM to $gameDir
  src = ./.;

  fileMap = { 
    "${gameDir}" = wineGameDir; 
    "$HOME/.local/share/${pname}/AppData" = "drive_c/users/$USER/AppData"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $MANGOHUD $WINE "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the TOEM installation at: ${gameDir}"
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
      desktopName = "TOEM";
      categories = [ "Game" "StrategyGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./toem.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "Set off on a delightful expedition and use your photographic eye to uncover the mysteries of the magical TOEM in this hand-drawn adventure game. Chat with quirky characters and solve their problems by snapping neat photos!";
    homepage = "https://www.somethingwemade.se/toem/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
