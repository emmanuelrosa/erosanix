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
      hsCallPackage = pkgs.haskellPackages.callPackage;
      in {
        nvidia-offload = callPackage ./pkgs/nvidia-offload.nix {};
        er-wallpaper = pkgs.lib.trivial.warn "er-wallpaper will be removed from the erosanix flake." (hsCallPackage ./pkgs/er-wallpaper.nix { });

        notepad-plus-plus = callPackage ./pkgs/notepad++.nix { 
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wineWowPackages.full; 
          wineArch = "win64";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        sierrachart = callPackage ./pkgs/sierrachart { 
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wine64Packages.stableFull; 
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
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wineWowPackages.full; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        send-to-kindle = callPackage ./pkgs/send-to-kindle.nix { 
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wineWowPackages.full; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
          zenity = pkgs.gnome.zenity;
        };

        vim-desktop = callPackage ./pkgs/vim-desktop.nix {
          makeDesktopIcon = lib.makeDesktopIcon;
          copyDesktopIcons = lib.copyDesktopIcons;
        };

        mkwindowsapp-tools = callPackage ./pkgs/mkwindowsapp-tools { wrapProgram = pkgs.wrapProgram; };

        foobar2000 = callPackage ./pkgs/foobar2000.nix {
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wine64Packages.stableFull; 
          wineArch = "win64";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        roblox = callPackage ./pkgs/roblox/default.nix {
          inherit (lib) mkWindowsApp copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wineWowPackages.full;
          wineArch = "win64";
          rbxfpsunlocker = self.packages.x86_64-linux.rbxfpsunlocker;
        };

        rbxfpsunlocker = callPackage ./pkgs/rbxfpsunlocker.nix { };

        rtrader-pro = callPackage ./pkgs/rtrader/rtrader-pro.nix {
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wineWowPackages.full;
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        line = callPackage ./pkgs/line.nix {
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wineWowPackages.full; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        sable = callPackage ./pkgs/sable/default.nix { 
          inherit (lib) mkWindowsApp copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.gnome.zenity;
        };

        lego-builders-journey = callPackage ./pkgs/lego-builders-journey/default.nix { 
          inherit (lib) mkWindowsApp makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wine64Packages.stableFull;
          zenity = pkgs.gnome.zenity;
        };

        qutebrowser-hardware-accelerated = let
          wrapper = pkgs.writeShellScript "qutebrowser-hardware-accelerated" ''
            "@EXECUTABLE@" --qt-flag ignore-gpu-backlist --qt-flag enable-gpu-rasterization --qt-flag enable-native-gpu-memory-buffers --qt-flag enable-accelerated-video-decode "$@"
          '';
        in pkgs.lib.trivial.warn "qutebrowser-hardware-accelerated will be removed from the erosanix flake." (self.lib.x86_64-linux.genericBinWrapper pkgs.qutebrowser wrapper);

        duskers = callPackage ./pkgs/duskers/default.nix { 
          inherit (lib) mkWindowsApp makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wineWowPackages.stableFull;
          zenity = pkgs.gnome.zenity;
        };

        caustic = callPackage ./pkgs/caustic/default.nix {
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.winePackages.stableFull; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        chess-ultra = callPackage ./pkgs/chess-ultra/default.nix {
          inherit (lib) mkWindowsApp makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.gnome.zenity;
        };

        tunche = callPackage ./pkgs/tunche/default.nix {
          inherit (lib) mkWindowsApp makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.gnome.zenity;
        };

        specter-desktop = pkgs.lib.trivial.warn "specter-desktop will be removed from the erosanix flake." (callPackage ./pkgs/specter-desktop/default.nix {
          inherit (lib) makeDesktopIcon copyDesktopIcons;
        });

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
          inherit (lib) mkWindowsApp makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.gnome.zenity;
        };

        black-book = callPackage ./pkgs/black-book/default.nix { 
          inherit (lib) mkWindowsApp copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.gnome.zenity;
        };

        microcap = callPackage ./pkgs/microcap { 
          mkWindowsApp = lib.mkWindowsApp;
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
      hsCallPackage = pkgs.haskellPackages.callPackage;
      in {
        er-wallpaper = pkgs.lib.trivial.warn "er-wallpaper will be removed from the erosanix flake." (hsCallPackage ./pkgs/er-wallpaper.nix { });
    } // (builtins.mapAttrs (name: pkg: callPackage pkg { }) (import ./cross-platform-pkgs.nix));

    packages.i686-linux = let
      pkgs = import "${nixpkgs}" {
        system = "i686-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
      hsCallPackage = pkgs.haskellPackages.callPackage;
      lib = self.lib.i686-linux;
      in {
        er-wallpaper = pkgs.lib.trivial.warn "er-wallpaper will be removed from the erosanix flake." (hsCallPackage ./pkgs/er-wallpaper.nix { });
        mkwindowsapp-tools = callPackage ./pkgs/mkwindowsapp-tools { wrapProgram = pkgs.wrapProgram; };

        notepad-plus-plus = callPackage ./pkgs/notepad++.nix { 
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.winePackages.stableFull; 
          wineArch = "win32";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        vim-desktop = pkgs.lib.trivial.warn "vim-desktop will be removed from the erosanix flake." (callPackage ./pkgs/vim-desktop.nix {
          makeDesktopIcon = lib.makeDesktopIcon;
          copyDesktopIcons = lib.copyDesktopIcons;
        });

        foobar2000 = callPackage ./pkgs/foobar2000.nix {
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.winePackages.stableFull; 
          wineArch = "win32";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        caustic = callPackage ./pkgs/caustic/default.nix {
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.winePackages.stableFull; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        roblox = callPackage ./pkgs/roblox/default.nix {
          inherit (lib) mkWindowsApp copyDesktopIcons makeDesktopIcon;
          wine = pkgs.winePackages.stableFull;
          wineArch = "win32";
          rbxfpsunlocker = null;
        };

        microcap = callPackage ./pkgs/microcap { 
          mkWindowsApp = lib.mkWindowsApp;
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

        wineshell-wine-vulkan = self.packages.x86-linux.wineshell-wine.override {
          enableVulkan = true;
        };

        winerun-wine = callPackage ./pkgs/winerun/default.nix {
          inherit (lib) mkWindowsApp;
          wine = pkgs.winePackages.stableFull;
          wineArch = "win32";
          wineFlavor = "wine";
        };

        winerun-wine-vulkan = self.packages.x86-linux.winerun-wine.override {
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
