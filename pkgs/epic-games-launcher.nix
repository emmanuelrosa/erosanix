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
}:
mkWindowsApp rec {
  inherit wine;

  pname = "epic-games-launcher";
  version = "14.2.1"; #:version:
  wineArch = "win64";
  persistRegistry = true;
  persistRuntimeLayer = true;
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  src = fetchurl {
    url = "https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-${version}.msi";
    sha256 = "0nli2sg2c9xvk1sa9hbrd4ar4wyrg1l9nwn5igm4n3r91gybj3d6"; #:hash:
  };

  fileMap = { 
    "$HOME/.cache/${pname}/Content" = "drive_c/Program Files (x86)/Epic Games/Launcher/Portal/Content"; 
    "$HOME/.cache/${pname}/Extras" = "drive_c/Program Files (x86)/Epic Games/Launcher/Portal/Extras"; 
    "$HOME/.cache/${pname}/SysFiles" = "drive_c/Program Files (x86)/Epic Games/Launcher/Portal/SysFiles"; 
    "$HOME/.cache/${pname}/Data" = "drive_c/ProgramData/Epic/EpicGamesLauncher/Data"; 
    "$HOME/.cache/${pname}/AppData/UnrealEngine" = "drive_c/users/$USER/AppData/Local/UnrealEngine"; 
    "$HOME/.cache/${pname}/AppData/EpicGamesLauncher" = "drive_c/users/$USER/AppData/Local/EpicGamesLauncher"; 
    "$HOME/.local/share/${pname}/Games/Epic Games" = "drive_c/Program Files/Epic Games"; 
  };

  winAppInstall = ''
    winetricks arial cjkfonts vcrun2019 d3dcompiler_43 d3dcompiler_47 d3dx9
    ${dxvk}/bin/setup_dxvk.sh install
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
