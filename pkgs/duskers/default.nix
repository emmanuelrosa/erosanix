# NOTE: If you don't run the game in "windowed mode" then you may need to use your window manager to bring the game into focus
# before it will accept keyboard input.
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
, gameDir ? "$HOME/Games/Duskers"
, graphicsDriver ? "auto"
}:
let
  title = "Duskers";
  wineGameDir = "drive_c/Program Files/Epic Games/${title}";
  exePath = "$WINEPREFIX/${wineGameDir}/${title}.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableVulkan enableHUD graphicsDriver;

  pname = "duskers";
  version = "unknown"; #:version:
  wineArch = "win64";
  enableMonoBootPrompt = false;
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  src = ./.;

  fileMap = { 
    "${gameDir}" = wineGameDir; 
    "$HOME/.config/unity3d/Misfits Attic/Duskers" = "drive_c/users/$USER/Documents/My Games/Duskers";
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
    rm "$WINEPREFIX/drive_c/users/$USER/Documents";
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/Documents";
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $MANGOHUD $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the ${title} installation at: ${gameDir}. Use legendary to install ${title} (app name 1e9c3a9a10c6463e9c065f371b8b42bf) and try again."
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
      desktopName = title;
      categories = [ "Game" "StrategyGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./duskers.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "In Duskers you pilot drones into derelict spaceships to find the means to survive and piece together how the universe became a giant graveyard. This package is for the Windows version of the game.";
    homepage = "http://duskers.misfits-attic.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
