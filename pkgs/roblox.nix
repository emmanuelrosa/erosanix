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
  programFiles = if wineArch == "win64" then "Program Files (x86)" else "Program Files";
  geckoMsi = if wineArch == "win64" then "${wine}/share/wine/gecko/wine-gecko-2.47.3-x86_64.msi" else "${wine}/share/wine/gecko/wine-gecko-2.47.3-x86.msi";
  hideDesktop = ''
    rm $WINEPREFIX/drive_c/users/$USER/Desktop
    mkdir $WINEPREFIX/drive_c/users/$USER/Desktop
  '';

  hudCommand = if renderer == "gl" then "${mangohud}/bin/mangohud --dlsym" else "${mangohud}/bin/mangohud"; 
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
