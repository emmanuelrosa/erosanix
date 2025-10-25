{ lib
, mkWindowsAppNoCC
, wine
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, zenity
, enableVulkan ? false
, enableHUD ? false
}:
let
  gameDir = "$HOME/Games/BlackBook";
  wineGameDir = "drive_c/Program Files/Epic Games/BlackBook";
  exePath = "$WINEPREFIX/${wineGameDir}/Black Book.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableVulkan enableHUD;

  pname = "black-book";
  version = "unknown"; #:version:
  wineArch = "win64";
  inhibitIdle = true;
  enableMonoBootPrompt = false;
  graphicsDriver = "prefer-wayland";
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  # src is not used at all.
  # This package only provides a launcher.
  # You must provide the game itself.
  # 
  # 1. Use Epic Game Launcher, legendary, etc to install Black Book.
  # 2. Copy the directory C:\Program Files\Epic Games\BlackBook into $HOME/Games/
  # 3. Now you can use this package to run Black Book.
  src = ./.;

  fileMap = { 
    "${gameDir}" = wineGameDir; 
    "$HOME/.local/share/${pname}/Black Book" = "drive_c/users/$USER/AppData/LocalLow/Morteshka/Black Book"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $MANGOHUD $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the Black Book installation at: ${gameDir}. You can use legendary to dowload app ID 1d74dcbca79540efb52cab2ff026215f."
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
      desktopName = "Black Book";
      categories = [ "Game" "RolePlaying" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./black-book.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "A dark RPG Adventure, based on Slavic mythology, in which you play as a young sorceress. Battle evil forces, aid commonfolk and travel across the rural countryside, where humans live alongside mythological creatures.";
    homepage = "https://blackbookgame.com/blackbook.html";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
