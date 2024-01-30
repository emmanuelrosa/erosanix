# erosanix
This repository includes misc. Nix packages, NixOS modules, and Nix functions. This repo also functions as a Nix User Repository (NUR), and replaces my old NUR `emmanuelrosa`.

## Setup as a Nix Flake

Setting up this repo as a Nix flake is no different than setting up any other flake:

*flake.nix*
```
{
  inputs.erosanix.url = "github:emmanuelrosa/erosanix";
  ...

  ouputs = { self, nixpkgs, erosanix, ...}: {
    nixosConfigurations.blah = nixpkgs.lib.nixosSystem {
      ...
      modules = [ erosanix.nixosModules.someModule ];
      ... 
      environment.systemPackages = with pkgs; [
        erosanix.packages.x86_64-linux.somePackage
      ];
    };
  };
};
```

## Setup as a NUR

The NUR-based setup differs from a normal NUR because this repo is not published. Frankly, it's easier to set it up this way:

*configuration.nix*
```
  ...
  erosanixSrc = builtins.fetchTarball {
    url = "https://github.com/emmanuelrosa/erosanix/archive/cb7298b0361716f4948424d9909312e9529b8b39.tar.gz";
    sha256 = "0fckfx5sib3d4rjv6qzghlnkyrkcac9c9z1g84w9n6nkhy3h7s7b";
  };
  
  # This is for NixOS modules
  erosanixWithoutPkgs = import erosanixSrc { };
  
  # And this is for packages
  erosanixPkgs = import erosanixSrc { inherit pkgs; };
  ...
  
  imports =
    [ erosanixWithoutPkgs.modules.someModule 
    ];
  
  environment.systemPackages = with pkgs; [
    erosanixPkgs.somePackage
  ];
```

## What's included?

### Library functions

- **generic-bin-wrapper** - A reusable function that is used to wrap the executables of an existing package, while making the wrapping transparent so that programs can still be launched from the "application menu." For an example, see the source for `nvidia-offload-wrapper` in `lib/nvidia-offload-wrapper.nix`. Wrappers created with `generic-bin-wrapper` are composable; Wrappers can wrap wrappers; To do this in a more readable fashion, see `compose` below.
- **makeDesktopIcon** - The counter-part to makeDesktop from Nixpkgs; Used to scale the provided icon and install it in `$out/usr/share`
- **nvidia-offload-wrapper** - Wraps the given package so that it renders on an NVIDIA GPU using NVIDIA's offload rendering. Ex. `(nvidia-offload-wrapper pkgs.superTuxKart)`.
- **mkmupen64plus** - Creates a launcher script to run a N64 game using *mupen64plus*. Also creates a corresponding menu item. Compose `mupen64plus` and `nvidia-offload-wrapper` using `compose` and you get a Nix package which launches a N64 game on your NVIDIA dGPU using offload rendering.
- **compose** - Returns a function which when applied to an argument, applies the functions in the list, in the order provided. Ex 1. `myFunc = compose [ mkmupen64plus nvidia-offload-wrapper ];`. Ex 2. `(compose [ mkmupen64plus nvidia-offload-wrapper ]) {...}`
- **composeAndApply** - Composes a list of functions (see `compose` above) and then applies them to the argument. Ex. `composeAndApply [ mkmupen64plus nvidia-offload-wrapper ] {...}`
- **mkSierraChartStudyFromSrc** - A simple derivation function to cross-compile studies (indicators) for the Sierra Chart trading platform.
- **mkSierraChartStudyFromDLL** - A simple derivation function install studies DLL's (indicators) for the Sierra Chart trading platform.
- **torsocks** - Uses `torsocks` to allow you to use most applications in a safe way with Tor. Beware that torsocks it has its limits.

### NixOS modules

- **btrbk** - My own version of an automatic BTRFS snapshot program, using btrbk.
- **electrs** - A NixOS module to run the electrs Bitcoin electrum server.
- **electrum-personal-server** - A NixOS module to run the EPS bitcoin electrum server.
- **fzf** - Sets up fuzzy-finding for your shell.
- **matrix-sendmail** - Use "sendtome" instead. See below.
- **mkwindowsapp-gc** - Garbage collector for the `mkWindowsApp` derivation function.
- **onlyoffice** - Sets up ONLYOFFICE such that it can access your system fonts. 
- **protonvpn** - Facade for Wireguard's "quick" to easily connect to a ProvonVPN server.
- **sendtome** - Sets up a simple `sendmail` implementation which copies messages to a Maildir directory.

### Packages

This repo has quite a variety of packages.

#### Wine-compatible Windows applications 

- **caustic** - A music creation tool inspired by rack-mount synthesizers / samplers rigs.
- **amazon-kindle** - Buy once, read everywhere. Sign in with an Amazon account, and sync Kindle books across all your devices that have the Kindle app installed and across any Kindle device.
- **chess-ultra** - The most breathtaking chess game ever made. Experience stunning 4K visuals, seamless online multiplayer, Grandmaster approved AI and full VR compatibility.
- **duskers** - In Duskers you pilot drones into derelict spaceships to find the means to survive and piece together how the universe became a giant graveyard. This package is for the Windows version of the game.
- **foobar2000** - An advanced freeware audio player for the Windows platform.
- **lego-builders-journey** - A puzzle game developed by Light Brick Studio and published by Lego Games.
- **line** - LINE is new level of communication, and the very infrastructure of your life.
- **notepad++** - A text editor and source code editor for use under Microsoft Windows. It supports around 80 programming languages with syntax highlighting and code folding. It allows working with multiple open files in a single window, thanks to its tabbed editing interface.
- **rbxfpsunlocker** - FPS Unlocker for Roblox
- **roblox** - An online game platform and game creation system developed by Roblox Corporation that allows users to program games and play games created by other users.
- **rtrader** - Rithmic professional trading software.
- **sable** - Guide Sable through her Gliding; a rite of passage that will take her across vast deserts and mesmerizing landscapes, capped by the remains of spaceships and ancient wonders.
- **send-to-kindle** - Send your personal and business documents to read them anytime, everywhere on Kindle devices and reading apps.
- **sierrachart** - A professional desktop Trading and Charting platform for the financial markets, supporting connectivity to various exchanges and backend trading platform services.
- **tunche** - A charming, hand-drawn beat'em up hack and slash game with roguelike elements.
- **horizon-chase-turbo** - A racing game inspired by the great hits of the 80's and 90's: Out Run, Lotus Turbo Challenge, Top Gear (SNES), Rush, among others. Each curve and each lap in Horizon Chase Turbo recreates classic arcade gameplay and offers you unbound speed limits of fun. Full throttle on and enjoy!
- **black-book** - A dark RPG Adventure, based on Slavic mythology, in which you play as a young sorceress. Battle evil forces, aid commonfolk and travel across the rural countryside, where humans live alongside mythological creatures.

#### Misc utilities
  
- **mkwindowsapp** - A derivation function used to package Wine-compatible Windows (R) application to run on NixOS.
- **mkwindowsapp-tools** - The garbage collector for `mkWindowsApp`.
- **er-wallpaper** - My custom wallpaper setting tool, which also invokes `wal`.
- **nvidia-offload** - A script to run the specified program using NVIDIA offload rendering.
- **pdf2png** - A simple pdf to png converter.
- **rofi-menu** - My custom rofi menu scripts.
- **vim-desktop** - A .desktop file to execute VIM using alacritty.
- **gossip** - A desktop client for nostr.
- **alice3** - An innovative block-based programming environment that makes it easy to create animations, build interactive narratives, or program simple games in 3D.

#### Bitcoin utilities
  
- **electrum-personal-server** - An lightweight, single-user implementation of the Electrum server protocol.
- **specter-desktop** - A desktop GUI for Bitcoin Core optimised to work with hardware wallets.
- **bitcoin-onion-nodes** - A list of over 1,000 Bitcoin Core nodes running as Tor v3 onion services or I2P nodes.
- **blockstream-green** - A multi-platform, feature-rich Bitcoin and Liquid wallet.

#### Fonts

- **battery-icons-font** - A font containing nothing but batteries.
- **century-gothic** - Century Gothic font.
- **trace-font** - Trace font.
