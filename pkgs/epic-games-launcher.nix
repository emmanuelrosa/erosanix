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
}:
mkWindowsApp rec {
  inherit wine;

  pname = "epic-games-launcher";
  version = "14.2.1"; #:version:
  wineArch = "win64";
  persistRuntimeLayer = true;
  dontUnpack = true;
  inputHashMethod = "version";
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  src = fetchurl {
    url = "https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-${version}.msi";
    sha256 = "0nli2sg2c9xvk1sa9hbrd4ar4wyrg1l9nwn5igm4n3r91gybj3d6"; #:hash:
  };

  fileMap = { 
    "$HOME/.cache/${pname}/Data" = "drive_c/ProgramData/Epic/EpicGamesLauncher/Data"; 
    "$HOME/.cache/${pname}/AppData/UnrealEngine" = "drive_c/users/$USER/AppData/Local/UnrealEngine"; 
    "$HOME/.cache/${pname}/AppData/EpicGamesLauncher" = "drive_c/users/$USER/AppData/Local/EpicGamesLauncher"; 
    "$HOME/Games/Epic Games" = "drive_c/Program Files/Epic Games";
  };

  winAppInstall = ''
    ${zenity}/bin/zenity --info --text "Epic Games Launcher takes a LONG time to install, and there's little visual indication of progress. Sit back, relax, and be ready to confirm the installation of C++ runtimes; There are two of them. You may be able to see what's going on with journalctl."
    mkdir -p "$HOME/Games/Epic Games"
    winetricks -q arial cjkfonts vcrun2019 d3dcompiler_43 d3dcompiler_47 d3dx9 dotnet471
    ${dxvk}/bin/setup_dxvk.sh install

    rm $WINEPREFIX/drive_c/users/$USER/Desktop
    mkdir $WINEPREFIX/drive_c/users/$USER/Desktop

    $WINE msiexec /i ${src} /qn
  '';

  winAppRun = ''
    $WINE start /unix "$WINEPREFIX/drive_c/Program Files (x86)/Epic Games/Launcher/Portal/Binaries/Win32/EpicGamesLauncher.exe" "-opengl -SkipBuildPatchPrereq"
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
      desktopName = "Epic Games Launcher";
      categories = ["Game"];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    icoIndex = 0;
    src = fetchurl {
      url = "https://static-assets-prod.epicgames.com/epic-store/static/webpack/../favicon.ico";
      sha256 = "008nw1ynfn584pmyyv2f6qp0iy9k4kg6akcc9zni1mk4d6hr49fp";
    };
  };

  meta = with lib; {
    description = "An app store for games distributed by Epic Games.";
    homepage = "https://store.epicgames.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}