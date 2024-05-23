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
  gameDir = "$HOME/Games/Sable";
  wineGameDir = "drive_c/Program Files/Epic Games/Sable";
  exePath = "$WINEPREFIX/${wineGameDir}/Sable.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableVulkan enableHUD;

  pname = "sable";
  version = "unknown"; #:version:
  wineArch = "win64";
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  # src is not used at all.
  # This package only provides a launcher.
  # You must provide the game itself.
  # 
  # 1. Use Epic Game Launcher, legendary, etc to install Sable.
  # 2. Copy the directory C:\Program Files\Epic Games\Sable into $HOME/Games/
  # 3. Now you can use this package to run Sable.
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
      ${zenity}/bin/zenity --error --text "Could not find the Sable installation at: ${gameDir}"
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
      desktopName = "Sabel";
      categories = [ "Game" "RolePlaying" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./sable.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "Guide Sable through her Gliding; a rite of passage that will take her across vast deserts and mesmerizing landscapes, capped by the remains of spaceships and ancient wonders.";
    homepage = "https://www.shed-works.co.uk/sable";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
