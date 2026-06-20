
{ lib
, mkWindowsAppNoCC
, fetchurl
, wine
, systemd
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, zenity
, legendary-gl
, graphicsDriver ? "prefer-wayland"
}: let
  appId = "eeaf9fd0962d4ab29d72a42df19aaa4a";
  exePath = "$HOME/Games/RobobeateUL6R/ROBOBEAT.exe";
in mkWindowsAppNoCC rec {
  inherit wine graphicsDriver;

  pname = "robobeat";
  version = "unknown";
  wineArch = "win64";
  dontUnpack = true;
  enableMonoBootPrompt = false;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  # src is not used at all.
  # This package only provides a launcher.
  # You must provide the game itself.
  src = ./.;

  fileMap = { 
    "$HOME/.local/share/${pname}" = "drive_c/users/$USER/AppData/LocalLow/Inzanity/ROBOBEAT"; 
  };

  winAppInstall = ''
    if [ ! -f "${exePath}" ]; then
      loggedIn=$(${legendary-gl}/bin/legendary status | grep "Epic account")

      if [ "$loggedIn" == "" ]; then
        ${zenity}/bin/zenity --error --text "Could not install ROBOBEAT because you're not logged in to your Epic Games account. Use `legendary auth` to log in, then try again."
      else
        ${legendary-gl}/bin/legendary install ${appId}
      fi
    fi
  '';

  winAppRun = ''
    if [ -f "${exePath}" ]
    then
      ${systemd}/bin/systemd-inhibit --no-ask-password --what=idle --who="${pname}" --why="To prevent the screen from turning off." --mode="block" ${legendary-gl}/bin/legendary launch ${appId} --wine-prefix $WINEPREFIX
    else
      ${zenity}/bin/zenity --error --text "Could not find the ROBOBEAT installation."
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
      desktopName = "Robobeat";
      categories = [ "Game" "ActionGame" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;

    src = fetchurl {
      url = "https://www.robobeatgame.com/favicon.png";
      hash = "sha256-QCDsCpHSYl0ISfVVw0jWYUBSx82l+IfcWMVsBnLFk7g=";
    };
  };

  meta = with lib; {
    description = "Keep your trigger finger on the pulse in this rhythm shooting game!";
    longDescripton = "This package requires an Epic Games account managed using legendary-gl. In addition, this game uses DirectX 12, so you need Linux Vulkan drivers for your GPU.";
    homepage = "https://www.robobeatgame.com/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
