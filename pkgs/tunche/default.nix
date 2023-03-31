{ stdenv
, lib
, mkWindowsApp
, wine
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, zenity
, enableHUD ? false
, enableVulkan ? false
}:
let
  title = "Tunche";
  gameDir = "$HOME/Games/${title}";
  wineGameDir = "drive_c/Program Files/Epic Games/${title}";
  exePath = "$WINEPREFIX/${wineGameDir}/${title}.exe";
in mkWindowsApp rec {
  inherit wine enableHUD enableVulkan;

  pname = "tunche";
  version = "unknown"; #:version:
  wineArch = "win64";
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  src = ./.;

  fileMap = { 
    "${gameDir}" = wineGameDir; 
    "$HOME/.local/share/tunche/Tunche" = "drive_c/users/$USER/AppData/LocalLow/Leap Game Studios/Tunche";
    "$HOME/.local/share/tunche/Tunche_EGS" = "drive_c/users/$USER/AppData/LocalLow/Leap Game Studios/Tunche_EGS";
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $MANGOHUD $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the ${title} installation at: ${gameDir}. Use legendary to download `Tunche` and try again."
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
      desktopName = "Tunche";
      categories = ["Game"];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./tunche.ico;
    icoIndex = 0;
  };

  meta = with lib; {
    description = "A charming, hand-drawn beat'em up hack and slash game with roguelike elements.";
    homepage = "https://leapgs.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
