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
, instanceName ? "default" # This should be alphanumeric, no spaces
, studies ? []
, symlinkJoin
}: let
  version = "2558"; #:version:
  src = fetchurl {
    url = "https://www.sierrachart.com/downloads/ZipFiles/SierraChart${version}.zip";
    sha256 = "00kdhd604gxipn2gh9q7bdsfjglh0x557w5nbpxdjw85xrx0jpz4"; #:hash:
  };

  defaultStudies = {
    stdenv
    , unzip
    }: stdenv.mkDerivation {
      inherit src;
      name = "sierrachart-default-studies";
      buildInputs = [ unzip ];

      preUnpack = ''
        mkdir SierraChart
        pushd SierraChart
      '';

      setSourceRoot = ''
        popd
        sourceRoot="SierraChart"
      '';

      installPhase = ''
        mkdir -p $out/lib
        cp Data/UserContributedStudies_64.dll $out/lib
      '';
    };
in mkWindowsApp rec {
  inherit wine src version;
  pname = "sierrachart-${instanceName}";
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
              "$HOME/.local/share/${pname}-instance/SierraChartInstance_2" = "drive_c/SierraChart/SierraChartInstance_2";
              "$HOME/.local/share/${pname}-instance/SierraChartInstance_3" = "drive_c/SierraChart/SierraChartInstance_3";
              "$HOME/.local/share/${pname}-instance/SierraChartInstance_4" = "drive_c/SierraChart/SierraChartInstance_4";
              "$HOME/.local/share/${pname}-instance/SierraChartInstance_5" = "drive_c/SierraChart/SierraChartInstance_5";
              "$HOME/.local/share/${pname}-instance/SierraChartInstance_6" = "drive_c/SierraChart/SierraChartInstance_6";
              "$HOME/.local/share/${pname}-instance/SierraChartInstance_7" = "drive_c/SierraChart/SierraChartInstance_7";
              "$HOME/.local/share/${pname}-instance/SierraChartInstance_8" = "drive_c/SierraChart/SierraChartInstance_8";
              "$HOME/.local/share/${pname}-instance/SierraChartInstance_9" = "drive_c/SierraChart/SierraChartInstance_9";
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

    ${installStudyDeps}

    # Prior to supporting multiple instances, user data was stored at ~/.local/share/sierrachart
    # But now the user data for the default instance is stored at ~/.local/share/sierrachart-default
    # This situation is handled below in a backwards-compatible way. 
    if [ -d "$HOME/.local/share/sierrachart" ] && [ "${instanceName}" == "default" ] && [ ! -h "$HOME/.local/share/sierrachart-default" ]
    then
      ln -s "$HOME/.local/share/sierrachart" "$HOME/.local/share/sierrachart-default" 
    fi
  '';

  joinedStudies = symlinkJoin { name = "sierrachart-studies"; paths = [ (defaultStudies { inherit stdenv unzip; }) studies ]; };

  installStudyDeps = ''
    # Create symlinks to Sierra Chart studies dependencies
    pushd "$WINEPREFIX/drive_c/windows/system32/"

    for dll in $(find ${joinedStudies}/system32 -name "*.dll") 
    do
      ln -vs $dll "$(basename $dll)"
    done

    popd
  '';

  installStudies = ''
    for p in "$HOME/.local/share/${pname}/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_2/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_3/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_4/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_5/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_6/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_7/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_8/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_9/Data" 
    do
      if [ -e "$p" ]
      then
        # Create symlinks to Sierra Chart studies
        pushd "$p"

        for study in $(find ${joinedStudies}/lib -name "*.dll") 
        do
          ln -vs --backup=simple $study "$(basename $study)"
        done

        popd
      fi
    done
  '';

  uninstallStudies = ''
    for p in "$HOME/.local/share/${pname}/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_2/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_3/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_4/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_5/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_6/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_7/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_8/Data" "$HOME/.local/share/${pname}-instance/SierraChartInstance_9/Data" 
    do
      if [ -e "$p" ]
      then
        # Remove symlinks to Sierra Chart studies
        pushd "$p"

        for study in $(find ${joinedStudies}/lib -name "*.dll") 
        do
          local filename="$(basename $study)"
          rm -v "$filename"

          # Restore DLL backup; For package backwards compatibility.
          if [ -e "$filename~" ]
          then
            mv "$filename~" "$filename"
          fi
        done
        popd
      fi
    done
  '';

  winAppPreRun = '' 
    ${installStudies}

    cached_version_file="$HOME/.cache/${pname}/acs-source-version.txt" 
    needs_acs_update="1"

    if [ "$(cat $cached_version_file)" == "${version}" ]
    then
      needs_acs_update=0
    fi
    
    if [ "$needs_acs_update" == "1" ]
    then
      echo "Updating ACS_Source."
      cp -a "$OUT_PATH/include/." "$WINEPREFIX/drive_c/SierraChart/ACS_Source/";
      cp -an "$OUT_PATH/share/sierrachart/examples/." "$WINEPREFIX/drive_c/SierraChart/ACS_Source/";
      mkdir -p $(dirname "$cached_version_file")
      echo "${version}" > "$cached_version_file"
    fi
  '';

  winAppRun = ''
    $WINE "$WINEPREFIX/drive_c/SierraChart/SierraChart.exe" "$ARGS"
  '';

  winAppPostRun = ''
    ${uninstallStudies}
  '';

  buildPhase = ''
    unzip ${src} "ACS_Source/*"
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/${pname}

    # Copy Sierra Chart ACSIL, except for example code.
    mkdir -p $out/include
    cp -a ACS_Source/*.h $out/include
    cp ACS_Source/SCStudyFunctions.cpp $out/include

    # Copy Sierra Chart ACSIL example code.
    mkdir -p $out/share/sierrachart/examples
    cp -a ACS_Source/*.cpp $out/share/sierrachart/examples
    rm $out/share/sierrachart/examples/SCStudyFunctions.cpp

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
    mainProgram = "sierrachart-${instanceName}";
  };
}

