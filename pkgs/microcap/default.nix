{ pkgs
, lib
, mkWindowsApp
, wine
, wineArch
, fetchzip
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, ... }: let
  pname = "microcap";
  version = "12.2.0.5"; # The final version, I suppose

  # Press 'F' for Spectrum Software
  src = fetchzip {
    stripRoot = false;
    url = "https://web.archive.org/web/20230214034946/http://www.spectrum-soft.com/download/mc12cd.zip";
    sha256 = "sha256-u97wwMeWzc3S5TEiTvDm/KjyeMTrTdgAnA/QAe7QhDQ=";
  };

  winAppRuns = {
    win32 = ''
      wine "$WINEPREFIX/drive_c/MC12/mc12.exe" "$ARGS"
    '';
    win64 = ''
      wine "$WINEPREFIX/drive_c/MC12/mc12_64.exe" "$ARGS"
    '';
  };
in mkWindowsApp rec {
  inherit pname src version wine wineArch;

  name = pname;

  fileMap = {
    # This file is changed on runtime, so we'll have to link it
    "$HOME/.config/Micro-Cap/mcap.dat" = "drive_c/MC12/MCAP.dat";
  };
  
  issFile = ./setup.iss;
  
  winAppInstall = ''
    mkdir                 "$WINEPREFIX/drive_c/microcap"
    cp "${issFile}"       "$WINEPREFIX/drive_c/microcap/setup.iss"
    cp -rf "${src}/."     "$WINEPREFIX/drive_c/microcap"
    ls                    "$WINEPREFIX/drive_c/microcap"
    $WINE                 "$WINEPREFIX/drive_c/microcap/setup.exe" /s /sms
    wineserver -w         # Wait for the above wine process to finish
    chmod -R 777          "$WINEPREFIX/drive_c/microcap"
    rm -rf                "$WINEPREFIX/drive_c/microcap"
  '';

  winAppRun = winAppRuns."${wineArch}";

  # This is a normal mkDerivation installPhase, with some caveats.
  # The launcher script will be installed at $out/bin/.launcher
  # DO NOT DELETE OR RENAME the launcher. Instead, link to it as shown.
  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/${pname}

    runHook postInstall
  '';

  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  desktopItems = let
    # FileTypes associated with MicroCap
    mimeTypes = ["application/x-wine-extension-cir"
                 "application/x-wine-extension-tno"];
  in [
    (makeDesktopItem {
      inherit mimeTypes;

      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Micro-Cap";
      genericName = "Electronic circuit simulator";
      categories = [ "Development" "Education" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    icoIndex = 0;
    src = fetchurl {
      url = "https://web.archive.org/web/20230214034930if_/http://www.spectrum-soft.com/favicon.ico";
      sha256 = "sha256-VdV81naOG9o0wVZNZj6n5sl39/TPzy0Zofk2DDZXZYk=";
    };
  };

  meta = with lib; {
    description = "An integrated schematic editor and mixed analog/digital simulator.";
    homepage    = "https://web.archive.org/web/20230219052113/http://www.spectrum-soft.com/index.shtm";
    license     = licenses.unfree;
    platforms   = [
      "i686-linux"
      "x86_64-linux"
    ];
    maintainers = with maintainers; [ nikp123 ];
    mainProgram = pname;
  };
}
