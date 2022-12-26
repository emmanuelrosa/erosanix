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
, renderer ? "wine-opengl" # Choices: "wine-opengl", "wine-vulkan", "dxvk-vulkan"
, enableHUD ? false
}:
let
  gameDir = "$HOME/Games/Sable";
  wineGameDir = "drive_c/Program Files/Epic Games/Sable";
  exePath = "$WINEPREFIX/${wineGameDir}/Sable.exe";

  hudCommand = {
    wine-opengl = "${mangohud}/bin/mangohud --dlsym";
    wine-vulkan = "${mangohud}/bin/mangohud";
    dxvk-vulkan = "${mangohud}/bin/mangohud";
  }."${renderer}";

  setWineRenderer = value: ''
    $WINE reg add 'HKCU\Software\Wine\Direct3D' /v renderer /d "${value}" /f
  '';

  setupRenderer = {
    wine-opengl = setWineRenderer "gl";
    wine-vulkan = setWineRenderer "vulkan";
    dxvk-vulkan = "${dxvk}/bin/setup_dxvk.sh install";
  }."${renderer}";

  runGame = let
    cmd = "$WINE start /unix \"${exePath}\"";
  in if enableHUD then "${hudCommand} ${cmd}" else "${cmd}";

  configIsValid = let
    olddxvk = lib.versionOlder dxvk.version "2.0" && lib.versionOlder wine.version "7.1";
    newdxvk = lib.versionAtLeast dxvk.version "2.0" && lib.versionAtLeast wine.version "7.1";
  in if renderer != "dxvk-vulkan" then true else (if olddxvk || newdxvk then true else false);
in if !configIsValid then (throw "sable: dxvk ${dxvk.version} is incompatible with Wine ${wine.version}. Try setting the renderer to 'wine-vulkan' instead.") else mkWindowsApp rec {
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
    ${setupRenderer}
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
