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
, dxvk
, rbxfpsunlocker
, enableHUD ? false
, enableDXVK ? false
, enableFPSUnlocker ? false # x86-64-linux only, at the moment.
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

  hudCommand = if enableDXVK then "${mangohud}/bin/mangohud" else "${mangohud}/bin/mangohud --dlsym";
in mkWindowsApp rec {
  inherit wine wineArch;

  pname = "roblox-${wineArch}";
  version = "abee5e356bde4475"; #:version:
  dontUnpack = true;
  persistRuntimeLayer = true;
  fileMapDuringAppInstall = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  src = fetchurl {
    url = "https://setup.rbxcdn.com/version-${version}-Roblox.exe";
    sha256 = "1n00pygl03r9nq8vmymk5az5555hjf3iasirraflkr67g9jjd4f4"; #:hash:#
  };

  fileMap = { 
    "$HOME/.local/share/roblox/ProgramData/Roblox" = "drive_c/ProgramData/Roblox"; 
    "$HOME/.local/share/roblox/Temp/Roblox" = "drive_c/users/$USER/Temp/Roblox"; 
    "$HOME/.local/share/roblox/rbxfpsunlocker/settings" = "drive_c/rbxfpsunlocker/settings"; 
    "$HOME/.local/share/roblox/rbxcsettings.rbx" = "drive_c/users/$USER/AppData/LocalLow/rbxcsettings.rbx"; 
  };

  winAppInstall = ''
    ${hideDesktop}
    msiexec /i ${geckoMsi}
    $WINE start /unix ${src}
    ${lib.optionalString enableDXVK "${dxvk}/bin/setup_dxvk.sh install"}
    ${lib.optionalString enableFPSUnlocker "mkdir -p $WINEPREFIX/drive_c/rbxfpsunlocker && ln -s ${rbxfpsunlocker}/rbxfpsunlocker.exe $WINEPREFIX/drive_c/rbxfpsunlocker/rbxfpsunlocker.exe"}
  '';

  winAppPreRun = ''
    ${lib.optionalString enableFPSUnlocker "$WINE start /unix $WINEPREFIX/drive_c/rbxfpsunlocker/rbxfpsunlocker.exe"}
  '';

  winAppRun = ''
    ${hideDesktop}
    export PULSE_LATENCY_MSEC=60
    ${lib.optionalString enableHUD hudCommand} $WINE start /unix "$WINEPREFIX/drive_c/${programFiles}/Roblox/Versions/version-${version}/RobloxPlayerLauncher.exe" "$ARGS"
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
