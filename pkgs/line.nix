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
  version = "9.0.1.3361"; #:version:

  src = fetchurl {
    url = "https://desktop.line-scdn.net/win/new/LineInst.exe";
    sha256 = "1w8apqfkr4m4r1k85pan776dvjlysxdbyilpl6ypykiqh1dclg2k"; #:hash:
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

