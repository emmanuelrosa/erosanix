{ lib
, mkWindowsAppNoCC
, wine
, fetchurl
, unzip
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
}:
mkWindowsAppNoCC rec {
  inherit wine;

  pname = "caustic";
  version = "3.2.0"; #:version:
  wineArch = "win32";
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  src = fetchurl {
    url = "https://singlecellsoftware.com/download/Caustic_${version}_standalone.zip";
    sha256 = "sha256-TJIehOyqEdPLL0rnaGOBOf+pkCvJjVofT5ajnqx3TwA="; #:hash:
  };

  fileMap = { "$HOME/.local/share/caustic/documents" = "drive_c/caustic/documents"; };

  winAppInstall = ''
    winetricks -q vcrun2012
    unzip ${src} -d "$WINEPREFIX/drive_c/"
    mv "$WINEPREFIX/drive_c/Caustic_${version}_standalone" "$WINEPREFIX/drive_c/caustic"
  '';

  winAppRun = ''
    $WINE start /unix "$WINEPREFIX/drive_c/caustic/app/Caustic.exe"
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
      desktopName = "Caustic 3";
      categories = ["AudioVideo" "Music"];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    icoIndex = 0;
    src = ./caustic.ico;
  };

  meta = with lib; {
    description = "A music creation tool inspired by rack-mount synthesizers / samplers rigs.";
    homepage = "https://singlecellsoftware.com/caustic";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
