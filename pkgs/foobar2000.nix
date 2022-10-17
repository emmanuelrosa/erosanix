{ stdenv
, lib
, mkWindowsApp
, wine
, fetchurl
, samba
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
}:
mkWindowsApp rec {
  inherit wine;

  pname = "foobar2000";
  version = "1.6.13"; #:version:
  wineArch = "win32";
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  src = fetchurl {
    url = "https://www.foobar2000.org/files/foobar2000_v${version}.exe";
    sha256 = "0a02zvmd98z8zhm2lfl3g8q3cl059gqq70pksm9h08kiqf56js2x"; #:hash:
  };

  fileMap = { "$HOME/.local/share/foobar2000" = "drive_c/users/$USER/AppData/Roaming/foobar2000"; };

  winAppInstall = ''
    wine start /unix ${src} /S
  '';

  winAppRun = ''
    export PATH=$PATH:${samba}/bin
    wine start /unix "$WINEPREFIX/drive_c/Program Files/foobar2000/foobar2000.exe" "$ARGS"
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
      desktopName = "Foobar2000";
      categories = ["Audio" "Player"];
      mimeTypes = builtins.map (s: "audio/" + s) [ "mpeg" "mp4" "aac" "x-vorbis+ogg" "x-opus+ogg" "flac" "x-wavpack" "x-wav" "x-aiff" "x-musepack" "x-speex" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    icoIndex = 0;
    src = fetchurl {
      url = "https://www.foobar2000.org/favicon.ico";
      sha256 = "1lk997iqaf7ma7jrfld6wc6spcgmz198nhrqclxn7bjvdws4csr6";
    };
  };

  meta = with lib; {
    description = "An advanced freeware audio player for the Windows platform.";
    homepage = "https://www.foobar2000.org";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
