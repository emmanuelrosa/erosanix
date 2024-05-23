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
, enableHUD ? false
, enableVulkan ? false
}:
let
  title = "HorizonChaseTurbo";
  gameDir = "$HOME/Games/${title}";
  wineGameDir = "drive_c/Program Files/Epic Games/${title}";
  exePath = "$WINEPREFIX/${wineGameDir}/HorizonChase.exe";
in mkWindowsAppNoCC rec {
  inherit wine enableHUD enableVulkan;

  pname = "horizon-chase-turbo";
  version = "unknown"; #:version:
  wineArch = "win64";
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  src = ./.;

  fileMap = { 
    "${gameDir}" = wineGameDir; 
    "$HOME/.local/share/${title}" = "drive_c/users/$USER/AppData/LocalLow/Aquiris/${title}";
  };

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/${wineGameDir}"
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      $MANGOHUD $WINE start /unix "${exePath}";
    else
      ${zenity}/bin/zenity --error --text "Could not find the Horizon Chase Turbo installation at: ${gameDir}. Use legendary to install Horizon Chase Turbo (app name bb406082b69a47208489d3616b22b5c2) and try again."
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
      desktopName = "Horizon Chase Turbo";
      categories = ["Game"];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    icoIndex = 0;
    src = fetchurl {
      url = "https://horizonchase2.com/images/favicon.ico";
      sha256 = "0hd06qag38smlgvdmv3ckkdldnzgg84ibhkmwl0vkqm1p5iihq0m";
    };
  };

  meta = with lib; {
    description = "A racing game inspired by the great hits of the 80's and 90's: Out Run, Lotus Turbo Challenge, Top Gear (SNES), Rush, among others. Each curve and each lap in Horizon Chase Turbo recreates classic arcade gameplay and offers you unbound speed limits of fun. Full throttle on and enjoy!";
    homepage = "https://horizonchase2.com/games/horizon-chase-turbo";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
