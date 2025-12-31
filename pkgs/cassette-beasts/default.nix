{ lib
, mkWindowsAppNoCC
, fetchurl
, wine
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, zenity
, graphicsDriver ? "prefer-wayland"
, gameDir ? "$HOME/Games/CassetteBeasts"
}:
let
  wineGameDir = "drive_c/CassetteBeasts";
  exePath = "$WINEPREFIX/${wineGameDir}/CassetteBeasts.exe";
in mkWindowsAppNoCC rec {
  inherit wine graphicsDriver;

  pname = "cassette-beasts";
  version = "unknown";
  wineArch = "win64";
  inhibitIdle = true;
  dontUnpack = true;
  enableMonoBootPrompt = false;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  # src is not used at all.
  # This package only provides a launcher.
  # You must provide the game itself.
  # 
  # 1. Use legendary to install MonumentValley.
  # 2. Make sure gameDir points to the MonumentValley directory.
  # 3. Now you can use this package to run MonumentValley.
  src = ./.;

  fileMap = { 
    "${gameDir}" = wineGameDir; 
    "$HOME/.local/share/${pname}" = "drive_c/users/$USER/AppData/Roaming/CassetteBeasts"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the Cassette Beasts installation at: ${gameDir}"
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
      desktopName = "Cassette Beasts";
      categories = [ "Game" "RolePlaying" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = fetchurl {
      url = "https://www.cassettebeasts.com/wp-content/uploads/2022/09/cropped-icon-192x192.png";
      hash = "sha256-55OsXv34D3KNRdt81EuUVumPP63kxNU7I55bY4oBvMg=";
    };
    icoIndex = 0;
  };

  meta = with lib; {
    description = "Collect awesome monster forms to use in turn-based battles in this indie open-world RPG. Combine any two monster forms using Cassette Beasts' Fusion System to create unique and powerful new ones!";
    homepage = "https://www.cassettebeasts.com/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
