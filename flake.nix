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

      mkSierraChartStudyFromSrc = pkgs.pkgsCross.mingwW64.callPackage ./lib/mkSierraChartStudyFromSrc.nix { 
        mcfgthread = pkgs.pkgsCross.mingwW64.windows.mcfgthreads_pre_gcc_13;
        sierrachart = self.packages.x86_64-linux.sierrachart;
      };

      mkSierraChartStudyFromDLL = pkgs.callPackage ./lib/mkSierraChartStudyFromDLL.nix { 
        sierrachart = self.packages.x86_64-linux.sierrachart;
      };

      torsocks = callPackage ./lib/torsocks.nix { 
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

        notepad-plus-plus = callPackage ./pkgs/notepad++.nix { 
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wineWowPackages.base; 
          wineArch = "win64";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        sierrachart = callPackage ./pkgs/sierrachart { 
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wine64Packages.base; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
          msvcShim = self.packages.x86_64-linux.sierrachart-zig-msvc-shim;
        };

        sierrachart-zig-msvc-shim-exec = callPackage ./pkgs/sierrachart-zig-msvc-shim/shim.nix { };
        sierrachart-zig-msvc-shim-bin-exec = callPackage ./pkgs/sierrachart-zig-msvc-shim/shim-bin.nix { };

        sierrachart-zig-msvc-shim = callPackage ./pkgs/sierrachart-zig-msvc-shim { 
            shim = self.packages.x86_64-linux.sierrachart-zig-msvc-shim-exec;
        };

        sierrachart-mingw-msvc-shim = callPackage ./pkgs/sierrachart-mingw-msvc-shim { };

        amazon-kindle = callPackage ./pkgs/amazon-kindle { 
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wineWowPackages.full; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        send-to-kindle = pkgs.lib.trivial.warn "send-to-kindle will be removed from the erosanix flake. Instead, use https://www.amazon.com/sendtokindle" (callPackage ./pkgs/send-to-kindle.nix { 
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wineWowPackages.full; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
          zenity = pkgs.gnome.zenity;
        });

        mkwindowsapp-tools = callPackage ./pkgs/mkwindowsapp-tools { wrapProgram = pkgs.wrapProgram; };

        foobar2000 = callPackage ./pkgs/foobar2000.nix {
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wine64Packages.base; 
          wineArch = "win64";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        rtrader-pro = callPackage ./pkgs/rtrader/rtrader-pro.nix {
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wineWowPackages.full;
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        line = callPackage ./pkgs/line.nix {
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wineWowPackages.full; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        sable = callPackage ./pkgs/sable/default.nix { 
          inherit (lib) copyDesktopIcons makeDesktopIcon;
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.gnome.zenity;
        };

        lego-builders-journey = callPackage ./pkgs/lego-builders-journey/default.nix { 
          inherit (lib) makeDesktopIcon copyDesktopIcons;
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wine64Packages.stableFull;
          zenity = pkgs.gnome.zenity;
        };

        duskers = callPackage ./pkgs/duskers/default.nix { 
          inherit (lib) makeDesktopIcon copyDesktopIcons;
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wineWowPackages.stableFull;
          zenity = pkgs.gnome.zenity;
        };

        caustic = callPackage ./pkgs/caustic/default.nix {
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.winePackages.stableFull; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        chess-ultra = callPackage ./pkgs/chess-ultra/default.nix {
          inherit (lib) makeDesktopIcon copyDesktopIcons;
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.gnome.zenity;
        };

        tunche = callPackage ./pkgs/tunche/default.nix {
          inherit (lib) makeDesktopIcon copyDesktopIcons;
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.gnome.zenity;
        };

        blockstream-green = callPackage ./pkgs/blockstream-green/default.nix { 
          inherit (lib) makeDesktopIcon copyDesktopIcons;
        };

        sparrow-unwrapped = callPackage ./pkgs/sparrow/default.nix {
          openimajgrabber = callPackage ./pkgs/sparrow/openimajgrabber.nix {};
          openjdk = pkgs.openjdk21.override { enableJavaFX = true; };
        };

        sparrow = callPackage ./pkgs/sparrow/fhsenv.nix { 
          sparrow-unwrapped = self.packages.x86_64-linux.sparrow-unwrapped;
        };

        gossip = callPackage ./pkgs/gossip/default.nix { 
          inherit (lib) makeDesktopIcon copyDesktopIcons;
        };

        gossip-full = pkgs.lib.trivial.warn "gossip-full will be removed from the erosanix flake." (callPackage ./pkgs/gossip-full/default.nix { });

        horizon-chase-turbo = callPackage ./pkgs/horizon-chase-turbo/default.nix {
          inherit (lib) makeDesktopIcon copyDesktopIcons;
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.gnome.zenity;
        };

        black-book = callPackage ./pkgs/black-book/default.nix { 
          inherit (lib) copyDesktopIcons makeDesktopIcon;
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.gnome.zenity;
        };

        microcap = callPackage ./pkgs/microcap { 
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.wineWowPackages.stableFull; 
          wineArch = "win64";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
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

        wineshell-wine64-vulkan = self.packages.x86_64-linux.wineshell-wine64.override {
          enableVulkan = true;
        };

        wineshell-wineWow64-vulkan = self.packages.x86_64-linux.wineshell-wineWow64.override {
          enableVulkan = true;
        };

        wineshell-wine-vulkan = self.packages.x86_64-linux.wineshell-wine.override {
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

        winerun-wine64-vulkan = self.packages.x86_64-linux.winerun-wine64.override {
          enableVulkan = true;
        };

        winerun-wineWow64-vulkan = self.packages.x86_64-linux.winerun-wineWow64.override {
          enableVulkan = true;
        };

        winerun-wine-vulkan = self.packages.x86_64-linux.winerun-wine.override {
          enableVulkan = true;
        };

        out-of-line = callPackage ./pkgs/out-of-line/default.nix { 
          inherit (lib) mkWindowsApp copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.gnome.zenity;
        };

        alice3 = callPackage ./pkgs/alice/alice3.nix {
          inherit (lib) makeDesktopIcon copyDesktopIcons;
          openjdk = pkgs.openjdk.override { enableJavaFX = true; };
        };

        bisq2 = callPackage ./pkgs/bisq2/default.nix { 
          openjdk = pkgs.openjdk.override { enableJavaFX = true; };
        };
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

        notepad-plus-plus = callPackage ./pkgs/notepad++.nix { 
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.winePackages.base; 
          wineArch = "win32";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        foobar2000 = callPackage ./pkgs/foobar2000.nix {
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.winePackages.base; 
          wineArch = "win32";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        caustic = callPackage ./pkgs/caustic/default.nix {
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.winePackages.stableFull; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        microcap = callPackage ./pkgs/microcap { 
          mkWindowsApp = lib.mkWindowsAppNoCC;
          wine = pkgs.winePackages.stableFull; 
          wineArch = "win32";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
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
