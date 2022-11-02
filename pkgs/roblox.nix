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
in mkWindowsApp rec {
  inherit wine wineArch;

  pname = "roblox";
  version = "current";
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  src = fetchurl {
    url = "https://setup.rbxcdn.com/RobloxPlayerLauncher.exe";
    sha256 = "0a2yn5amwnhlbra17a0xgx2qm1rg7f7xczhvszkfn4ia5520j74a";
  };

  fileMap = { 
    "$HOME/.local/share/roblox/ProgramData/Roblox" = "drive_c/ProgramData/Roblox"; 
    "$HOME/.local/share/roblox/Versions" = "drive_c/${programFiles}/Roblox/Versions"; 
  };

  winAppInstall = ''
    ${hideDesktop}
    msiexec /i ${geckoMsi}
    wine start /unix ${src}
  '';

    # Select the Wine3d3 renderer.
    # Relies on the render options built into Wine; No DXVK.
    # See https://linuxreviews.org/The_New_Wine_Vulkan_Backend_For_DirectX_9-11_Is_Coming_Along_Nicely
  winAppPreRun = '' 
    wine reg add "HKCU\\Software\\Wine\\Direct3D" /v renderer -d "${renderer}" /f
  '';

  winAppRun = ''
    ${hideDesktop}
    export PULSE_LATENCY_MSEC=60
    roblox_launcher=$(find "$WINEPREFIX/drive_c/${programFiles}/Roblox/Versions" -name RobloxPlayerLauncher.exe -print -quit)
    ${lib.optionalString enableHUD hudCommand} wine start /unix "$roblox_launcher" "$ARGS"
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
