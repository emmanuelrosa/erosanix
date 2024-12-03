# erosanix
 
This repository includes misc. Nix packages, NixOS modules, and Nix functions.

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
      modules = [ erosanix.nixosModules.someModule ./configuration.nix ];
      ... 
    };
  };
};
```

*configuration.nix*
```
{ self, config, pkgs, lib, erosanix, ...}:
{
  environment.systemPackages = with pkgs; [
    erosanix.packages.x86_64-linux.somePackage
  ];
}
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
- **nanogl** - Used to run OpenGL applications on Linux distributions other than NixOS, using Mesa drivers; NVIDIA drivers are not included. Based on [nixGL](https://github.com/nix-community/nixGL).

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
- **udiskie** - Sets up a systemd user service to start udiskie. Also enables `services.udisks2`.

### Packages

This repo has quite a variety of packages.

#### Wine-compatible Windows applications 

*WARNING:* The following Wine-compatible applications utilize my Nix derivation function `mkWindowsApp`, which creates something similar to the Nix store at `$HOME/.cache/mkWindowsApp`. Like the Nix store, this storage location will consume a lot of disk space over time unless you run the garbage collector periodically. See the [documentation](pkgs/mkwindowsapp/).

- **caustic** - A music creation tool inspired by rack-mount synthesizers / samplers rigs.
- **amazon-kindle** - Buy once, read everywhere. Sign in with an Amazon account, and sync Kindle books across all your devices that have the Kindle app installed and across any Kindle device.
- **chess-ultra** - The most breathtaking chess game ever made. Experience stunning 4K visuals, seamless online multiplayer, Grandmaster approved AI and full VR compatibility.
- **duskers** - In Duskers you pilot drones into derelict spaceships to find the means to survive and piece together how the universe became a giant graveyard. This package is for the Windows version of the game.
- **foobar2000** - An advanced freeware audio player for the Windows platform.
- **lego-builders-journey** - A puzzle game developed by Light Brick Studio and published by Lego Games.
- **line** - LINE is new level of communication, and the very infrastructure of your life.
- **rtrader** - Rithmic professional trading software.
- **sable** - Guide Sable through her Gliding; a rite of passage that will take her across vast deserts and mesmerizing landscapes, capped by the remains of spaceships and ancient wonders.
- **tunche** - A charming, hand-drawn beat'em up hack and slash game with roguelike elements.
- **horizon-chase-turbo** - A racing game inspired by the great hits of the 80's and 90's: Out Run, Lotus Turbo Challenge, Top Gear (SNES), Rush, among others. Each curve and each lap in Horizon Chase Turbo recreates classic arcade gameplay and offers you unbound speed limits of fun. Full throttle on and enjoy!
- **black-book** - A dark RPG Adventure, based on Slavic mythology, in which you play as a young sorceress. Battle evil forces, aid commonfolk and travel across the rural countryside, where humans live alongside mythological creatures.
- **microcap** - An integrated schematic editor and mixed analog/digital simulator.
- **TOEM** -Set off on a delightful expedition and use your photographic eye to uncover the mysteries of the magical TOEM in this hand-drawn adventure game. Chat with quirky characters and solve their problems by snapping neat photos! 
- **Snakebird Complete** - Embark on an extraordinary puzzle-solving adventure bringing together hit classic Snakebird and Snakebird Primer.

#### Misc utilities
  
- **mkwindowsapp** - A derivation function used to package Wine-compatible Windows (R) application to run on NixOS.
- **mkwindowsapp-tools** - The garbage collector for `mkWindowsApp`.
- **er-wallpaper** - My custom wallpaper setting tool, which also invokes `wal`.
- **nvidia-offload** - A script to run the specified program using NVIDIA offload rendering.
- **pdf2png** - A simple pdf to png converter.
- **rofi-menu** - My custom rofi menu scripts.
- **gossip** - A desktop client for Nostr.
- **alice3** - An innovative block-based programming environment that makes it easy to create animations, build interactive narratives, or program simple games in 3D.

#### Bitcoin utilities
  
- **electrum-personal-server** - An lightweight, single-user implementation of the Electrum server protocol.
- **bitcoin-onion-nodes** - A list of over 1,000 Bitcoin Core nodes running as Tor v3 onion services or I2P nodes.
- **blockstream-green** - A multi-platform, feature-rich Bitcoin and Liquid wallet.
- **bisq2** - A decentralized bitcoin exchange network.
_ **sparrow** - A Bitcoin wallet. 

#### Fonts

- battery-icons-font
- century-gothic
- trace-font
- baby-plums-font
- bubble-dance-monogram-font
- kg-counting-stars-font
- uchrony-circle-slab-font
