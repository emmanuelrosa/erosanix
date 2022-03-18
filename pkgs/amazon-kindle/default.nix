{ stdenv
, lib
, mkWindowsApp
, wine
, fetchurl
, requireFile
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, imagemagick }:
let
  homepage = "https://www.amazon.com/Amazon-Digital-Services-LLC-Download/dp/B00UB76290/";
  # settings.reg disables auto updates and sets the content dir to C:\KindleContent
  settings = ./settings.reg;
in mkWindowsApp rec {
  inherit wine;

  pname = "amazon-kindle";
  version = "1.33.62002";

  src = requireFile rec {
    name = "Kindle_for_PC_Download.exe";
    sha256 = "0f3b5lyijd8vlsrgqg2fvqx87ymc78qza7m7jkinrdzqrkcicmkg";
    message = ''
      In order to install Amazon Kindle for PC:

      1. Go to ${homepage}.
      2. Add the app to your cart, and checkout in order to purchase the app (which is free).
      3. You'll receive an email with a link to download the app.
      4. Once you have downloaded the file, please use the following command and re-run the installation: nix-prefetch-url file://path/to/${name}
      '';
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
    wine ${src} /S
    wineserver -w
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Local/Amazon/Kindle/crashdump"
  '';

  winAppRun = '' 
    regedit ${settings}
    wine "$WINEPREFIX/drive_c/Program Files (x86)/Amazon/Kindle/Kindle.exe"
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
    inherit homepage;

    description = "Buy once, read everywhere. Sign in with an Amazon account, and sync Kindle books across all your devices that have the Kindle app installed and across any Kindle device.";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}

