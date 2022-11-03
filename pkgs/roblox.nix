# This package is based on https://github.com/roblox-linux-wrapper/roblox-linux-wrapper
# On NixOS, it requires enabling 32-bit DRI; Option hardware.opengl.driSupport32Bit
{ stdenv
, lib
, mkWindowsApp
, wine
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, wineArch
, mangohud
, enableHUD ? false
}:
let
  programFiles = let
    map = {
      "win64" = "Program Files (x86)";
      "win32" = "Program Files";
    };
  in map."${wineArch}";

  geckoMsi = let
    map = {
      "win64" = "${wine}/share/wine/gecko/wine-gecko-2.47.3-x86_64.msi" ;
      "win32" = "${wine}/share/wine/gecko/wine-gecko-2.47.3-x86.msi";
    };
  in map."${wineArch}";

  hideDesktop = ''
    rm $WINEPREFIX/drive_c/users/$USER/Desktop
    mkdir $WINEPREFIX/drive_c/users/$USER/Desktop
  '';

  hudCommand = "${mangohud}/bin/mangohud --dlsym";
in mkWindowsApp rec {
  inherit wine wineArch;

  pname = "roblox";
  version = "717cf6a6f7614f44"; #:version:
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  src = fetchurl {
    url = "https://setup.rbxcdn.com/version-${version}-Roblox.exe";
    sha256 = "sha256-YCkQXKQIGaXtd04KRZgKRwBAiYjrYp5UhTQ7x3TVGf4="; #:hash:#
  };

  fileMap = { 
    "$HOME/.local/share/roblox/ProgramData/Roblox" = "drive_c/ProgramData/Roblox"; 
  };

  winAppInstall = ''
    ${hideDesktop}
    msiexec /i ${geckoMsi}
    wine start /unix ${src}
  '';

  winAppRun = ''
    ${hideDesktop}
    export PULSE_LATENCY_MSEC=60
    ${lib.optionalString enableHUD hudCommand} wine start /unix "$WINEPREFIX/drive_c/${programFiles}/Roblox/Versions/version-${version}/RobloxPlayerLauncher.exe" "$ARGS"
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
      desktopName = "Roblox";
      categories = ["Game"];
      mimeTypes = [ "x-scheme-handler/roblox-player" ];
      noDisplay = true;
      startupNotify = true;
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = fetchurl {
      url = "https://flyclipart.com/thumb2/roblox-filled-icon-245601.png";
      sha256 = "0hw9mh0hdb7f65nkrvv607ys8pjn6vgqsrpnk84mkpdl5q5amsnk";
    };
  };

  meta = with lib; {
    description = "An online game platform and game creation system developed by Roblox Corporation that allows users to program games and play games created by other users.";
    homepage = "https://www.roblox.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}
