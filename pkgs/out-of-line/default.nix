{ lib
, mkWindowsAppNoCC
, wine
, fetchurl
, dxvk
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, zenity
, mangohud
, enableVulkan ? false
, enableHUD ? false
}:
let
  gameDir = "$HOME/Games/OutofLine";
  wineGameDir = "drive_c/Program Files/Epic Games/OutofLine";
  exePath = "$WINEPREFIX/${wineGameDir}/Out of Line.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableVulkan enableHUD;

  pname = "out-of-line";
  version = "unknown"; #:version:
  wineArch = "win64";
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  # src is not used at all.
  # This package only provides a launcher.
  # You must provide the game itself.
  # 
  # 1. Use Epic Game Launcher, legendary, etc to install Sable.
  # 2. Copy the directory C:\Program Files\Epic Games\OutofLine into $HOME/Games/
  # 3. Now you can use this package to run Out of Line.
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
      $MANGOHUD $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the Out of Line installation at: ${gameDir}"
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
      desktopName = "Out of Line";
      categories = [ "Game" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./out-of-line.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "A unique adventure game filled with beautiful puzzles all hand-drawn in an original 2D style.";
    homepage = "https://nerdmonkeys.pt/index.php/portfolio/2/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
