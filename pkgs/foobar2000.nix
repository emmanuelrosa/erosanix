{ lib
, mkWindowsAppNoCC
, wine
, wineArch
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
}:
mkWindowsAppNoCC rec {
  inherit wine wineArch;

  pname = "foobar2000-${wineArch}";
  version = "2.24.6"; #:version:
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];
  fileMapDuringAppInstall = true;

  src = {
    win32 = fetchurl {
      url = "https://www.foobar2000.org/downloads/foobar2000_v${version}.exe";
      sha256 = "07khw1j0vgm9xyhgk0gwqhpzzc4c3d9z7rmk6s96qk2nk6p31r8p"; #:hash32:
    };

    win64 = fetchurl {
      url = "https://www.foobar2000.org/downloads/foobar2000-x64_v${version}.exe";
      sha256 = "sha256-F5ldEYA6arFgO4zCKlUTSQWmMfin2YU3IDSFCTJW2ZU="; #:hash64:
    };
  }."${wineArch}";

  # Note: The old (v1) profile directory is still being mapped in case the user has used this package before.
  # The Foobar2000 v2 installer will import the v1 configuration data if it exists.
  fileMap = { 
    "$HOME/.local/share/foobar2000" = "drive_c/users/$USER/AppData/Roaming/foobar2000"; 
    "$HOME/.local/share/foobar2000-v2" = "drive_c/users/$USER/AppData/Roaming/foobar2000-v2";
  };

  winAppInstall = ''
    $WINE start /unix ${src} /S
  '';

  winAppRun = ''
    $WINE start /unix "$WINEPREFIX/drive_c/Program Files/foobar2000/foobar2000.exe" "$ARGS"
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
      desktopName = "foobar2000";
      comment = "Advanced Freeware Audio Player";
      categories = ["Music" "Audio" "Player"];
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
