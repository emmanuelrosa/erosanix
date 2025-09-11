{
  description = "Emmanuel's NixOS/Nix Flakes repository.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-compat }: {

    lib.x86_64-linux = let
      pkgs = import "${nixpkgs}" {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
      trivial = import ./lib/trivial.nix;
    in {
      mkWindowsApp = callPackage ./pkgs/mkwindowsapp { 
        makeBinPath = pkgs.lib.makeBinPath; 
      };

      mkWindowsAppNoCC = callPackage ./pkgs/mkwindowsapp { 
        stdenv = pkgs.stdenvNoCC;
        makeBinPath = pkgs.lib.makeBinPath; 
      };

      copyDesktopIcons = pkgs.makeSetupHook { name = "copyDesktopIcons"; } ./hooks/copy-desktop-icons.sh;
      makeDesktopIcon = callPackage ./lib/makeDesktopIcon.nix {};

      genericBinWrapper = callPackage ./lib/generic-bin-wrapper.nix { };
      nvidia-offload-wrapper = callPackage ./lib/nvidia-offload-wrapper.nix { 
        genericBinWrapper = self.lib.x86_64-linux.genericBinWrapper;
        nvidia-offload = self.packages.x86_64-linux.nvidia-offload;
      };

      mkmupen64plus = callPackage ./lib/mkmupen64plus.nix {
        copyDesktopIcons = self.lib.x86_64-linux.copyDesktopIcons;
        makeDesktopIcon = self.lib.x86_64-linux.makeDesktopIcon;
      };

      compose = trivial.compose;
      composeAndApply = trivial.composeAndApply;

      torsocks = callPackage ./lib/torsocks.nix { 
        genericBinWrapper = self.lib.x86_64-linux.genericBinWrapper;
      };

      nanogl = callPackage ./lib/nanogl.nix { 
        genericBinWrapper = self.lib.x86_64-linux.genericBinWrapper;
      };
    };

    lib.i686-linux = let
      pkgs = import "${nixpkgs}" {
        system = "i686-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
      trivial = import ./lib/trivial.nix;
    in {
      mkWindowsApp = callPackage ./pkgs/mkwindowsapp { 
        makeBinPath = pkgs.lib.makeBinPath; 
      };

      mkWindowsAppNoCC = callPackage ./pkgs/mkwindowsapp { 
        stdenv = pkgs.stdenvNoCC;
        makeBinPath = pkgs.lib.makeBinPath; 
      };

      copyDesktopIcons = pkgs.makeSetupHook { name = "copyDesktopIcons"; } ./hooks/copy-desktop-icons.sh;
      makeDesktopIcon = callPackage ./lib/makeDesktopIcon.nix {};
      compose = trivial.compose;
      composeAndApply = trivial.composeAndApply;
      genericBinWrapper = callPackage ./lib/generic-bin-wrapper.nix { };

      torsocks = callPackage ./lib/torsocks.nix { 
        genericBinWrapper = self.lib.i686-linux.genericBinWrapper;
      };
    };

    packages.x86_64-linux = let
      pkgs = import "${nixpkgs}" {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
      lib = self.lib.x86_64-linux;
      in {
        nvidia-offload = callPackage ./pkgs/nvidia-offload.nix {};

        amazon-kindle = callPackage ./pkgs/amazon-kindle { 
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wineWowPackages.full; 
        };

        mkwindowsapp-tools = callPackage ./pkgs/mkwindowsapp-tools { wrapProgram = pkgs.wrapProgram; };

        foobar2000 = callPackage ./pkgs/foobar2000.nix {
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wine64Packages.stableFull; 
          wineArch = "win64";
        };

        line = callPackage ./pkgs/line.nix {
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wineWowPackages.base; 
        };

        sable = callPackage ./pkgs/sable/default.nix { 
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wine64Packages.base; 
          zenity = pkgs.zenity;
        };

        toem = callPackage ./pkgs/toem/default.nix { 
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wine64Packages.base; 
          zenity = pkgs.zenity;
        };

        the-spirit-and-the-mouse = callPackage ./pkgs/the-spirit-and-the-mouse/default.nix { 
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wine64Packages.base; 
          zenity = pkgs.zenity;
        };

        super-space-club = callPackage ./pkgs/super-space-club/default.nix { 
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wineWowPackages.base; 
          zenity = pkgs.zenity;
        };

        snakebird-complete = callPackage ./pkgs/snakebird/default.nix { 
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wine64Packages.base; 
          zenity = pkgs.zenity;
        };

        lego-builders-journey = callPackage ./pkgs/lego-builders-journey/default.nix { 
          inherit (lib) mkWindowsAppNoCC makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wine64Packages.stableFull;
          zenity = pkgs.zenity;
        };

        duskers = callPackage ./pkgs/duskers/default.nix { 
          inherit (lib) mkWindowsAppNoCC makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wineWowPackages.base;
          zenity = pkgs.zenity;
        };

        caustic = callPackage ./pkgs/caustic/default.nix {
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.winePackages.stableFull; 
        };

        chess-ultra = callPackage ./pkgs/chess-ultra/default.nix {
          inherit (lib) mkWindowsAppNoCC makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.zenity;
        };

        tunche = callPackage ./pkgs/tunche/default.nix {
          inherit (lib) mkWindowsAppNoCC makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.zenity;
        };

        blockstream-green = pkgs.lib.warn "blockstream-green has been renamed to blockstream" self.packages.x86_64-linux.blockstream;

        blockstream = callPackage ./pkgs/blockstream/default.nix { 
          inherit (lib) makeDesktopIcon copyDesktopIcons;
        };

        gossip = callPackage ./pkgs/gossip/default.nix { 
          inherit (lib) makeDesktopIcon copyDesktopIcons;
        };

        horizon-chase-turbo = callPackage ./pkgs/horizon-chase-turbo/default.nix {
          inherit (lib) mkWindowsAppNoCC makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.zenity;
        };

        black-book = callPackage ./pkgs/black-book/default.nix { 
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.zenity;
        };

        microcap = callPackage ./pkgs/microcap { 
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wineWowPackages.stableFull; 
          wineArch = "win64";
        };

        monument-valley = callPackage ./pkgs/monument-valley/default.nix {
          inherit (lib) mkWindowsAppNoCC makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wine64Packages.base; 
        };

        monument-valley2 = callPackage ./pkgs/monument-valley2/default.nix {
          inherit (lib) mkWindowsAppNoCC makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wine64Packages.base; 
        };

        strange-horticulture = callPackage ./pkgs/strange-horticulture/default.nix {
          inherit (lib) mkWindowsAppNoCC makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wine64Packages.base; 
        };

        wineshell-wine64 = callPackage ./pkgs/wineshell/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.wine64Packages.stableFull; 
          wineArch = "win64";
          wineFlavor = "wine64";
        };

        wineshell-wineWow64 = callPackage ./pkgs/wineshell/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.wineWowPackages.stableFull;
          wineArch = "win64";
          wineFlavor = "wineWow64";
        };

        wineshell-wine = callPackage ./pkgs/wineshell/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.winePackages.stableFull;
          wineArch = "win32";
          wineFlavor = "wine";
        };

        wineshell-wine64-base = callPackage ./pkgs/wineshell/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.wine64Packages.base; 
          wineArch = "win64";
          wineFlavor = "wine64";
          enableMonoBootPrompt = false;
        };

        wineshell-wineWow64-base = callPackage ./pkgs/wineshell/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.wineWowPackages.base;
          wineArch = "win64";
          wineFlavor = "wineWow64";
          enableMonoBootPrompt = false;
        };

        wineshell-wine-base = callPackage ./pkgs/wineshell/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.winePackages.base;
          wineArch = "win32";
          wineFlavor = "wine";
          enableMonoBootPrompt = false;
        };

        wineshell-wine64-vulkan = self.packages.x86_64-linux.wineshell-wine64.override {
          enableVulkan = true;
        };

        wineshell-wineWow64-vulkan = self.packages.x86_64-linux.wineshell-wineWow64.override {
          enableVulkan = true;
        };

        wineshell-wine-vulkan = self.packages.x86_64-linux.wineshell-wine.override {
          enableVulkan = true;
        };

        wineshell-wine64-base-vulkan = self.packages.x86_64-linux.wineshell-wine64-base.override {
          enableVulkan = true;
        };

        wineshell-wineWow64-base-vulkan = self.packages.x86_64-linux.wineshell-wineWow64-base.override {
          enableVulkan = true;
        };

        wineshell-wine-base-vulkan = self.packages.x86_64-linux.wineshell-wine-base.override {
          enableVulkan = true;
        };

        winerun-wine64 = callPackage ./pkgs/winerun/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.wine64Packages.stableFull; 
          wineArch = "win64";
          wineFlavor = "wine64";
        };

        winerun-wineWow64 = callPackage ./pkgs/winerun/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.wineWowPackages.stableFull;
          wineArch = "win64";
          wineFlavor = "wineWow64";
        };

        winerun-wine = callPackage ./pkgs/winerun/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.winePackages.stableFull;
          wineArch = "win32";
          wineFlavor = "wine";
        };

        winerun-wine64-base = callPackage ./pkgs/winerun/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.wine64Packages.base; 
          wineArch = "win64";
          wineFlavor = "wine64";
          enableMonoBootPrompt = false;
        };

        winerun-wineWow64-base = callPackage ./pkgs/winerun/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.wineWowPackages.base;
          wineArch = "win64";
          wineFlavor = "wineWow64";
          enableMonoBootPrompt = false;
        };

        winerun-wine-base = callPackage ./pkgs/winerun/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.winePackages.base;
          wineArch = "win32";
          wineFlavor = "wine";
          enableMonoBootPrompt = false;
        };

        winerun-wine64-vulkan = self.packages.x86_64-linux.winerun-wine64.override {
          enableVulkan = true;
        };

        winerun-wineWow64-vulkan = self.packages.x86_64-linux.winerun-wineWow64.override {
          enableVulkan = true;
        };

        winerun-wine-vulkan = self.packages.x86_64-linux.winerun-wine.override {
          enableVulkan = true;
        };

        winerun-wine64-base-vulkan = self.packages.x86_64-linux.winerun-wine64-base.override {
          enableVulkan = true;
        };

        winerun-wineWow64-base-vulkan = self.packages.x86_64-linux.winerun-wineWow64-base.override {
          enableVulkan = true;
        };

        winerun-wine-base-vulkan = self.packages.x86_64-linux.winerun-wine-base.override {
          enableVulkan = true;
        };

        out-of-line = callPackage ./pkgs/out-of-line/default.nix { 
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.zenity;
        };

        alice3 = callPackage ./pkgs/alice/alice3.nix {
          inherit (lib) makeDesktopIcon copyDesktopIcons;
          openjdk = pkgs.openjdk.override { enableJavaFX = true; };
        };

        sideswap = callPackage ./pkgs/sideswap/default.nix { 
          inherit (lib) makeDesktopIcon copyDesktopIcons;
        };

        harmonoid = callPackage ./pkgs/harmonoid/default.nix { };
    } // (builtins.mapAttrs (name: pkg: callPackage pkg { }) (import ./cross-platform-pkgs.nix));

    packages.aarch64-linux = let
      pkgs = import "${nixpkgs}" {
        system = "aarch64-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
      in {
    } // (builtins.mapAttrs (name: pkg: callPackage pkg { }) (import ./cross-platform-pkgs.nix));

    packages.i686-linux = let
      pkgs = import "${nixpkgs}" {
        system = "i686-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
      lib = self.lib.i686-linux;
      in {
        mkwindowsapp-tools = callPackage ./pkgs/mkwindowsapp-tools { wrapProgram = pkgs.wrapProgram; };

        foobar2000 = callPackage ./pkgs/foobar2000.nix {
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.winePackages.stableFull; 
          wineArch = "win32";
        };

        caustic = callPackage ./pkgs/caustic/default.nix {
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.winePackages.stableFull; 
        };

        microcap = callPackage ./pkgs/microcap { 
          inherit (lib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.winePackages.stableFull; 
          wineArch = "win32";
        };

        wineshell-wine = callPackage ./pkgs/wineshell/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.winePackages.stableFull;
          wineArch = "win32";
          wineFlavor = "wine";
        };

        wineshell-wine-vulkan = self.packages.i686-linux.wineshell-wine.override {
          enableVulkan = true;
        };

        winerun-wine = callPackage ./pkgs/winerun/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.winePackages.stableFull;
          wineArch = "win32";
          wineFlavor = "wine";
        };

        winerun-wine-vulkan = self.packages.i686-linux.winerun-wine.override {
          enableVulkan = true;
        };
    } // (builtins.mapAttrs (name: pkg: callPackage pkg { }) (import ./cross-platform-pkgs.nix));

    nixosModules.electrum-personal-server = import ./modules/electrum-personal-server.nix;
    nixosModules.protonvpn = import ./modules/protonvpn.nix;
    nixosModules.btrbk = import ./modules/btrbk.nix;
    nixosModules.electrs = import ./modules/electrs.nix;
    nixosModules.fzf = import ./modules/fzf.nix;
    nixosModules.mkwindowsapp-gc = import ./modules/mkwindowsapp-gc.nix;
    nixosModules.sendtome = import ./modules/sendtome.nix;
    nixosModules.onlyoffice = import ./modules/onlyoffice.nix;
    nixosModules.udiskie = import ./modules/udiskie.nix;
    nixosModules.swaynotificationcenter = import ./modules/swaync.nix;

    bundlers.x86_64-linux = let
      pkgs = import "${nixpkgs}" {
        system = "x86_64-linux";
      };
    in {
      nvidia-offload = import ./lib/nvidia-offload-wrapper.nix { 
        genericBinWrapper = import ./lib/generic-bin-wrapper.nix { stdenv = pkgs.stdenv; };
        writeShellScript = pkgs.writeShellScript;
        nvidia-offload = self.packages.x86_64-linux.nvidia-offload;
      };

      torsocks = import ./lib/torsocks.nix { 
        genericBinWrapper = import ./lib/generic-bin-wrapper.nix { stdenv = pkgs.stdenv; };
        writeShellScript = pkgs.writeShellScript;
        torsocks = pkgs.torsocks;
      };
    };
  };
}
