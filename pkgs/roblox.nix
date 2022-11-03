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
, renderer ? "gl" # Can be gl or vulkan
, wineArch
, mangohud
, enableHUD ? false
, dxvk
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

  hudCommand = let
    map = {
      "gl" = "${mangohud}/bin/mangohud --dlsym";
      "vulkan" = "${mangohud}/bin/mangohud";
    };
  in map."${renderer}";

  rendererSetup = let
    map = {
      "gl" = ''wine reg add "HKCU\\Software\\Wine\\Direct3D" /v renderer -d "${renderer}" /f'';

      "vulkan" = "${dxvk}/bin/setup_dxvk.sh install --with-d3d10 --symlink"; 
    };
  in map."${renderer}";
in mkWindowsApp rec {
  inherit wine wineArch;

  pname = "roblox";
  version = "93fb1ddae5a243cc"; #:version:
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  src = fetchurl {
    url = "https://setup.rbxcdn.com/version-${version}-Roblox.exe";
    sha256 = "0a2yn5amwnhlbra17a0xgx2qm1rg7f7xczhvszkfn4ia5520j74a";
  };

  fileMap = { 
    "$HOME/.local/share/roblox/ProgramData/Roblox" = "drive_c/ProgramData/Roblox"; 
  };

  winAppInstall = ''
    ${hideDesktop}
    msiexec /i ${geckoMsi}
    ${rendererSetup}
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
