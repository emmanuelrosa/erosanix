{ stdenv
, lib
, mkWindowsApp
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
, setupRenderer
, getRenderer
, getHudCommand
}:
let
  renderer = getRenderer enableVulkan wine dxvk;
  gameDir = "$HOME/Games/Sable";
  wineGameDir = "drive_c/Program Files/Epic Games/Sable";
  exePath = "$WINEPREFIX/${wineGameDir}/Sable.exe";
  hudCommand = getHudCommand mangohud renderer;

  runGame = let
    cmd = "$WINE start /unix \"${exePath}\"";
  in if enableHUD then "${hudCommand} ${cmd}" else "${cmd}";
in mkWindowsApp rec {
  inherit wine;

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
    ${setupRenderer dxvk renderer}
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      ${runGame}
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
      categories = ["Game"];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = fetchurl {
      url = "https://images.squarespace-cdn.com/content/v1/5b0583a7f93fd49e35a7c61c/1623348529138-3XZYH4AYOEBQUTE63G5F/QuestBulletSelect.png?format=100w";
      sha256 = "0yca6f8rp6r644id0rgwsrqzvsp0jwsgbkbys7w3z72p84hg7wxg";
    };
  };

  meta = with lib; {
    description = "Guide Sable through her Gliding; a rite of passage that will take her across vast deserts and mesmerizing landscapes, capped by the remains of spaceships and ancient wonders.";
    homepage = "https://www.shed-works.co.uk/sable";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
