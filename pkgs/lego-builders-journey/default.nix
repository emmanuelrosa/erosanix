{ lib
, mkWindowsAppNoCC
, wine
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, zenity
, enableVulkan ? false
, enableHUD ? false
}:
let
  gameDir = "$HOME/Games/LEGOBuildersJourney";
  exePath = "${gameDir}/Builder's Journey.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableVulkan enableHUD;

  pname = "lego-builders-journey";
  version = "unknown"; #:version:
  wineArch = "win64";
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  # NOTE: src isn't used by this package.
  src = ./.;

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $MANGOHUD $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the LEGO Builder's journey installation at: ${gameDir}. Use `legendary-gl` to install it and try again."
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
      desktopName = "LEGO(c) Builder's Journey";
      categories = [ "Game" "LogicGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./lego-builders-journey.ico;
  };

  meta = with lib; {
    description = "A puzzle game developed by Light Brick Studio and published by Lego Games.";
    longDescription = "The game allows the players to build their own model and solving puzzles. Download the game using `legendary-gl`, then use this launcher to run it. You'll be prompted to authenticate with your Epic Games account via your web browser.";
    homepage = "https://www.lego.com/en-us";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
