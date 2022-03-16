{ stdenv
, lib
, mkWindowsApp
, wine
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, unzip
, imagemagick
, instanceName ? "default" # This should be alphanumeric, no spaces
}:
mkWindowsApp rec {
  inherit wine;

  pname = "sierrachart-${instanceName}";
  version = "2369";

  src = fetchurl {
    url = "https://www.sierrachart.com/downloads/ZipFiles/SierraChart${version}.zip";
    sha256 = "0pmd40j6kyiaidfap1rh1ahhrmmvfr732vl3q64ddzy019vv2nvs";
  };

  dontUnpack = true;
  wineArch = "win64";
  persistRegistry = true;
  enableInstallNotification = false;
  nativeBuildInputs = [ unzip copyDesktopItems copyDesktopIcons ];

  fileMap = { "$HOME/.local/share/${pname}/Data" = "drive_c/SierraChart/Data"; 
              "$HOME/.local/share/${pname}/Graphics/Buttons" = "drive_c/SierraChart/Graphics/Buttons";
              "$HOME/.local/share/${pname}/Sierra4.config" = "drive_c/SierraChart/Sierra4.config"; 
              "$HOME/.local/share/${pname}/Accounts4.config" = "drive_c/SierraChart/Accounts4.config"; 
              "$HOME/.local/share/${pname}/KeyboardShortcuts4.config" = "drive_c/SierraChart/KeyboardShortcuts4.config"; 
              "$HOME/.local/share/${pname}/TradeActivityLogs" = "drive_c/SierraChart/TradeActivityLogs"; 
              "$HOME/.local/share/${pname}/TradePositions.data" = "drive_c/SierraChart/TradePositions.data"; 
              "$HOME/.local/share/${pname}/AccountBalance.data" = "drive_c/SierraChart/AccountBalance.data"; 
              "$HOME/.local/share/${pname}/TradeOrdersList.data" = "drive_c/SierraChart/TradeOrdersList.data"; 
              "$HOME/.local/share/${pname}/SymbolSettings" = "drive_c/SierraChart/SymbolSettings"; 
              "$HOME/.local/share/${pname}/DefaultStudySettings" = "drive_c/SierraChart/DefaultStudySettings"; 
              "$HOME/.local/share/${pname}/AlertSounds" = "drive_c/SierraChart/AlertSounds"; 
              "$HOME/.local/share/${pname}/Username.txt" = "drive_c/SierraChart/Username.txt";
              "$HOME/.local/share/${pname}/InternalOrderID2.data" = "drive_c/SierraChart/InternalOrderID2.data";
              "$HOME/.local/share/${pname}/TradeAccountData" = "drive_c/SierraChart/TradeAccountData";
              "$HOME/.local/share/${pname}/Backups" = "drive_c/SierraChart/Backups";
              "$HOME/.local/share/${pname}/Images" = "drive_c/SierraChart/Images";
              "$HOME/.local/share/${pname}/SavedTradeActivity" = "drive_c/SierraChart/SavedTradeActivity";
              "$HOME/.local/share/${pname}/ACS_Source" = "drive_c/SierraChart/ACS_Source";
  };

  winAppInstall = ''
    d="$WINEPREFIX/drive_c/SierraChart"
    mkdir -p "$d"
    unzip ${src} -d "$d"
    rm -fR "$d/NPP"

    # Replace Notepad++ with a copy of winebrowser
    # so that TXT files are opened with xdg-open
    mkdir -p "$d/NPP"
    cp "$WINEPREFIX/drive_c/windows/system32/winebrowser.exe" "$d/NPP/notepad++.exe"

    # Prior to supporting multiple instances, user data was stored at ~/.local/share/sierrachart
    # But now the user data for the default instance is stored at ~/.local/share/sierrachart-default
    # This situation is handled below in a backwards-compatible way. 
    if [ -d "$HOME/.local/share/sierrachart" ] && [ "${instanceName}" == "default" ] && [ ! -h "$HOME/.local/share/sierrachart-default" ]
    then
      ln -s "$HOME/.local/share/sierrachart" "$HOME/.local/share/sierrachart-default" 
    fi
  '';

  winAppRun = ''
   wine "$WINEPREFIX/drive_c/SierraChart/SierraChart.exe" "$ARGS"
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
      icon = "sierrachart";
      desktopName = "Sierra Chart (${instanceName})";
      genericName = "Trading and charting software";
      categories = ["Office" "Finance"];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = "sierrachart";

    src = fetchurl {
      url = "https://www.sierrachart.com/favicon/favicon-192x192.png";
      sha256 = "06wdklj01i0h6c6b09288k3qzvpq1zvjk7fsjc26an20yp2lf21f";
    };
  };

  meta = with lib; {
    description = "A professional desktop Trading and Charting platform for the financial markets, supporting connectivity to various exchanges and backend trading platform services.";
    homepage = "https://www.sierrachart.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}

