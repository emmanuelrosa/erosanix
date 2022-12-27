{ lib }:
rec {
# Returns a string representing the renderer to use given the inputs:# "wine-opengl" - Wine's Direct3D to OpenGL translation
# "wine-vulkan" - Wine's Direct3D to Vulkan translation
# "dxvk-vulkan" - The DXVK Direct3D to Vulkan translation

  getRenderer = useVulkan: winePkg: dxvkPkg: let
    impl = recommendedVulkanImplementation winePkg dxvkPkg;
  in if !useVulkan then "wine-opengl" else (if impl == "wine" then "wine-vulkan" else "dxvk-vulkan");

  # Compares the wine and dxvk packages and returns one of the following strings:
  # "dxvk" - This means DXVK is the recommended Vulkan implementation.
  # "wine" - This means Wine D3D is the recommended Vulkan implementation.
  #
  # In short, DXVK is recommended unless it's incompatible with Wine.

  recommendedVulkanImplementation = winePkg: dxvkPkg: let
    olddxvk = lib.versionOlder dxvkPkg.version "2.0" && lib.versionOlder winePkg.version "7.1";
    newdxvk = lib.versionAtLeast dxvkPkg.version "2.0" && lib.versionAtLeast winePkg.version "7.1";
  in if olddxvk || newdxvk then "dxvk" else "wine";

  # Generate a script to set up the specified renderer in Wine

  setupRenderer = dxvk: renderer: let 
    setWineRenderer = value: ''
      $WINE reg add 'HKCU\Software\Wine\Direct3D' /v renderer /d "${value}" /f
    '';
  in {
    wine-opengl = setWineRenderer "gl";
    wine-vulkan = setWineRenderer "vulkan";
    dxvk-vulkan = "${dxvk}/bin/setup_dxvk.sh install";
  }."${renderer}";

  # Returns a MangoHUD command script according to the inputs

  getHudCommand = mangohud: renderer: {
    wine-opengl = "${mangohud}/bin/mangohud --dlsym";
    wine-vulkan = "${mangohud}/bin/mangohud";
    dxvk-vulkan = "${mangohud}/bin/mangohud";
  }."${renderer}";
}
