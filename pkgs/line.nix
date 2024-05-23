{ lib
, mkWindowsAppNoCC
, wine
, fetchurl
, findutils
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
}:
mkWindowsAppNoCC rec {
  inherit wine;

  pname = "line";
  version = "8.7.0.3302"; #:version:

  src = fetchurl {
    url = "https://desktop.line-scdn.net/win/new/LineInst.exe";
    sha256 = "0drhafb68kg6qr1m0r2d68grwvda87l80vv9cd32gpj00j95d59r"; #:hash:
  };

  dontUnpack = true;
  wineArch = "win64";
  persistRegistry = false;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  fileMap = { "$HOME/.local/share/line/Data" = "drive_c/users/$USER/AppData/Local/LINE/Data"; };

  enabledWineSymlinks = {
    desktop = false;
  };

  winAppInstall = ''
    winetricks win10
    $WINE ${src} /S
    wineserver -w
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Local/LINE/Data"
  '';

  winAppRun = '' 
    $WINE start /unix "$WINEPREFIX/drive_c/users/$USER/AppData/Local/LINE/bin/LineLauncher.exe"
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/line

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "LINE";
      categories = ["Network" "Chat"];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = "line";

    src = fetchurl {
      url = "https://line.me/favicon-32x32.png";
      sha256 = "1kry4kab23d8knz1yggj3a0mdz56n7zf6g5hq4sbymdm103j4ksh";
    };
  };

  meta = with lib; {
    homepage = "https://line.me";
    description = "LINE is new level of communication, and the very infrastructure of your life.";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}

