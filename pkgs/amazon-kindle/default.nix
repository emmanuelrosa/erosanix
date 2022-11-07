{ stdenv
, lib
, mkWindowsApp
, wine
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
}:
let
  # settings.reg disables auto updates and sets the content dir to C:\KindleContent
  settings = ./settings.reg;
in mkWindowsApp rec {
  inherit wine;

  pname = "amazon-kindle";
  release = "65323";
  version = "1.39.${release}";

  src = fetchurl {
    url = "https://kindleforpc.s3.amazonaws.com/${release}/KindleForPC-installer-${version}.exe";
    sha256 = "1xpha1388hf6c12aj58v75hrj3rpkrsrarl4vjahs1r1zqqkjdih";
  };

  dontUnpack = true;
  wineArch = "win64";
  persistRegistry = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  fileMap = { "$HOME/.cache/amazon-kindle/Local Settings" = "drive_c/users/$USER/Local Settings";
              "$HOME/.cache/amazon-kindle/AppData" = "drive_c/users/$USER/AppData";
              "$HOME/.local/share/amazon-kindle/KindleContent" = "drive_c/KindleContent";
  };

  winAppInstall = ''
    $WINE ${src} /S
    wineserver -w

    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Local/Amazon/Kindle/crashdump"
    mkdir -p "$WINEPREFIX/drive_c/KindleContent"
    $WINE reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion" /v CSDVersion -d "" /f
    $WINE reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion" /v CurrentBuildNumber -d "10240" /f
    $WINE reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion" /v CurrentVersion -d "10.0" /f
    $WINE reg add "HKLM\\System\\CurrentControlSet\\Control\\Windows" /v CSDVersion -d "dword:00000000" /f
    regedit ${settings}
  '';

  winAppPreRun = '' 
  '';

  winAppRun = '' 
    $WINE "$WINEPREFIX/drive_c/Program Files (x86)/Amazon/Kindle/Kindle.exe"
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/amazon-kindle

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Amazon Kindle";
      categories = ["Office" "Viewer"];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = "amazon-kindle";

    src = fetchurl {
      url = "https://r7.hiclipart.com/path/440/869/236/kindle-fire-iphone-kindle-store-amazon-kindle-7382d0d39a5d99e1ac56652e55c6b644.png";
      sha256 = "sha256-ao3UdXkhcp9tpB506dFR1cWgYUOLkEcX3DP5JyvVEzw=";
    };
  };

  meta = with lib; {
    description = "Buy once, read everywhere. Sign in with an Amazon account, and sync Kindle books across all your devices that have the Kindle app installed and across any Kindle device.";
    homepage = "https://www.amazon.com/b?ie=UTF8&node=16571048011";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}

