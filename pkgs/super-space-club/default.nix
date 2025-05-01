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
, gameDir ? "$HOME/Games/SuperSpaceClub"
, enableVulkan ? false
, graphicsDriver ? "prefer-wayland"
}:
let
  wineGameDir = "drive_c/SuperSpaceClub";
  exePath = "$WINEPREFIX/${wineGameDir}/Super Space Club.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableHUD enableVulkan graphicsDriver;

  pname = "super-space-club";
  version = "unknown"; #:version:
  wineArch = "win64";
  enableMonoBootPrompt = false;
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  # src is not used at all.
  # This package only provides a launcher.
  # You must provide the game itself.
  src = ./.;

  fileMap = { 
    "${gameDir}" = wineGameDir; 
    "$HOME/.local/share/Super Space Club" = "drive_c/users/$USER/AppData/LocalLow/GrahamOfLegend/Super Space Club"; 
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $MANGOHUD $WINE "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find 'Super Space Club' installed at: ${gameDir}"
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
      desktopName = "Super Space Club";
      categories = [ "Game" "AdventureGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = fetchurl {
        url = "https://images.squarespace-cdn.com/content/v1/636c8fa7494598562ca355af/037b6a66-82c7-4aec-9d1a-cc65a61a485c/favicon.ico?format=100w";
        sha256 = "sha256-DNohc4S/u3gMz1swZ1cAEvHMUqDtyJJpYv5jceUL7bY=";
    };
  };

  meta = with lib; {
    description = "A colorful endless arcade gunner set to the backdrop of chill, lo-fi music.";
    homepage = "https://www.grahamoflegend.com/superspaceclub/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
