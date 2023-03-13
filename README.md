# erosanix
This repository includes misc. Nix packages, NixOS modules, and Nix functions. This repo also functions as a Nix User Repository (NUR), and replaces my old NUR `emmanuelrosa`.

## Features

* `mkWindowsApp` - A derivation for packaging Wine-compatible Windows programs. There are also various packaged programs, such as Notepad++ and foobar2000.
* Bitcoin packages - Various Bitcoin tools are packaged, such as the Muun wallet recovery tool
* `nvidia-offload-wrapper` - A function to wrap programs so that they use Nvidia offload rendering.
* `makeDesktopIcon` - A function to generate desktop icons. A companion to makeDesktopItem.

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

Keep in mind that the following list of what's included may be incomplete:

```
{
  "bundlers": {
    "type": "unknown"
  },
  "lib": {
    "type": "unknown"
  },
  "nixosModules": {
    "btrbk": {
      "type": "nixos-module"
    },
    "electrs": {
      "type": "nixos-module"
    },
    "electrum-personal-server": {
      "type": "nixos-module"
    },
    "fzf": {
      "type": "nixos-module"
    },
    "matrix-sendmail": {
      "type": "nixos-module"
    },
    "mkwindowsapp-gc": {
      "type": "nixos-module"
    },
    "protonvpn": {
      "type": "nixos-module"
    },
    "sendtome": {
      "type": "nixos-module"
    },
    "usrsharefonts": {
      "type": "nixos-module"
    }
  },
  "packages": {
    "aarch64-linux": {
      "battery-icons-font": {
        "description": "A font containing nothing but batteries.",
        "name": "battery-icons-font-2020-01-26",
        "type": "derivation"
      },
      "bitcoin-onion-nodes": {
        "description": "A list of over 1,000 Bitcoin Core nodes running as Tor v3 onion services.",
        "name": "bitcoin-onion-nodes-2.4.txt",
        "type": "derivation"
      },
      "century-gothic-font": {
        "description": "Century Gothic font.",
        "name": "century-gothic-font-2016-09-17",
        "type": "derivation"
      },
      "electrum-personal-server": {
        "description": "An lightweight, single-user implementation of the Electrum server protocol",
        "name": "electrum-personal-server-0.2.4",
        "type": "derivation"
      },
      "er-wallpaper": {
        "description": "A script for changing wallpaper and setting color schemes, for Linux",
        "name": "er-wallpaper-0.2.0.0",
        "type": "derivation"
      },
      "matrix-sendmail": {
        "description": "A simple sendmail implementation which uses a Matrix CLI client to send 'mail' to a Matrix room.",
        "name": "matrix-sendmail-835d1efc713f6c915e6b2657f77ba19066f61d4b",
        "type": "derivation"
      },
      "muun-recovery-tool": {
        "description": "You can use this Recovery Tool to transfer all funds out of your Muun account to an address of your choosing",
        "name": "muun-recovery-tool-v2.2.4",
        "type": "derivation"
      },
      "pdf2png": {
        "description": "A simple script to convert a PDF into multiple PNGs.",
        "name": "pdf2png-0.2.0.0",
        "type": "derivation"
      },
      "rofi-menu": {
        "description": "Various rofi menus (aka. modi)",
        "name": "rofi-menu-0.7.0",
        "type": "derivation"
      },
      "trace-font": {
        "description": "Trace font",
        "name": "trace-font-2020-03-25",
        "type": "derivation"
      }
    },
    "i686-linux": {
      "battery-icons-font": {
        "description": "A font containing nothing but batteries.",
        "name": "battery-icons-font-2020-01-26",
        "type": "derivation"
      },
      "bitcoin-onion-nodes": {
        "description": "A list of over 1,000 Bitcoin Core nodes running as Tor v3 onion services.",
        "name": "bitcoin-onion-nodes-2.4.txt",
        "type": "derivation"
      },
      "caustic": {
        "description": "A music creation tool inspired by rack-mount synthesizers / samplers rigs.",
        "name": "caustic-3.2.0",
        "type": "derivation"
      },
      "century-gothic-font": {
        "description": "Century Gothic font.",
        "name": "century-gothic-font-2016-09-17",
        "type": "derivation"
      },
      "electrum-personal-server": {
        "description": "An lightweight, single-user implementation of the Electrum server protocol",
        "name": "electrum-personal-server-0.2.4",
        "type": "derivation"
      },
      "er-wallpaper": {
        "description": "A script for changing wallpaper and setting color schemes, for Linux",
        "name": "er-wallpaper-0.2.0.0",
        "type": "derivation"
      },
      "foobar2000": {
        "description": "An advanced freeware audio player for the Windows platform.",
        "name": "foobar2000-1.6.16",
        "type": "derivation"
      },
      "matrix-sendmail": {
        "description": "A simple sendmail implementation which uses a Matrix CLI client to send 'mail' to a Matrix room.",
        "name": "matrix-sendmail-835d1efc713f6c915e6b2657f77ba19066f61d4b",
        "type": "derivation"
      },
      "mkwindowsapp-tools": {
        "description": "A set of tools for working with packages made with mkWindowsApp.",
        "name": "mkwindows-tools-1.0.0",
        "type": "derivation"
      },
      "muun-recovery-tool": {
        "description": "You can use this Recovery Tool to transfer all funds out of your Muun account to an address of your choosing",
        "name": "muun-recovery-tool-v2.2.4",
        "type": "derivation"
      },
      "notepad-plus-plus": {
        "description": "A text editor and source code editor for use under Microsoft Windows. It supports around 80 programming languages with syntax highlighting and code folding. It allows working with multiple open files in a single window, thanks to its tabbed editing interface.",
        "name": "notepad-plus-plus-win32-8.5",
        "type": "derivation"
      },
      "pdf2png": {
        "description": "A simple script to convert a PDF into multiple PNGs.",
        "name": "pdf2png-0.2.0.0",
        "type": "derivation"
      },
      "rofi-menu": {
        "description": "Various rofi menus (aka. modi)",
        "name": "rofi-menu-0.7.0",
        "type": "derivation"
      },
      "trace-font": {
        "description": "Trace font",
        "name": "trace-font-2020-03-25",
        "type": "derivation"
      },
      "vim-desktop": {
        "description": "A desktop menu (and file associations) to run VIM, a greatly improved version of the good old UNIX editor Vi. Alacritty is used as the terminal.",
        "name": "vim-desktop-1.0.1",
        "type": "derivation"
      }
    },
    "x86_64-linux": {
      "amazon-kindle": {
        "description": "Buy once, read everywhere. Sign in with an Amazon account, and sync Kindle books across all your devices that have the Kindle app installed and across any Kindle device.",
        "name": "amazon-kindle-1.39.65323",
        "type": "derivation"
      },
      "battery-icons-font": {
        "description": "A font containing nothing but batteries.",
        "name": "battery-icons-font-2020-01-26",
        "type": "derivation"
      },
      "bitcoin-onion-nodes": {
        "description": "A list of over 1,000 Bitcoin Core nodes running as Tor v3 onion services.",
        "name": "bitcoin-onion-nodes-2.4.txt",
        "type": "derivation"
      },
      "caustic": {
        "description": "A music creation tool inspired by rack-mount synthesizers / samplers rigs.",
        "name": "caustic-3.2.0",
        "type": "derivation"
      },
      "century-gothic-font": {
        "description": "Century Gothic font.",
        "name": "century-gothic-font-2016-09-17",
        "type": "derivation"
      },
      "duskers": {
        "description": "In Duskers you pilot drones into derelict spaceships to find the means to survive and piece together how the universe became a giant graveyard. This package is for the Windows version of the game.",
        "name": "duskers-unknown",
        "type": "derivation"
      },
      "electrum-personal-server": {
        "description": "An lightweight, single-user implementation of the Electrum server protocol",
        "name": "electrum-personal-server-0.2.4",
        "type": "derivation"
      },
      "er-wallpaper": {
        "description": "A script for changing wallpaper and setting color schemes, for Linux",
        "name": "er-wallpaper-0.2.0.0",
        "type": "derivation"
      },
      "foobar2000": {
        "description": "An advanced freeware audio player for the Windows platform.",
        "name": "foobar2000-1.6.16",
        "type": "derivation"
      },
      "lego-builders-journey": {
        "description": "A puzzle game developed by Light Brick Studio and published by Lego Games.",
        "name": "lego-builders-journey-unknown",
        "type": "derivation"
      },
      "line": {
        "description": "LINE is new level of communication, and the very infrastructure of your life.",
        "name": "line-7.14.1.2907",
        "type": "derivation"
      },
      "matrix-sendmail": {
        "description": "A simple sendmail implementation which uses a Matrix CLI client to send 'mail' to a Matrix room.",
        "name": "matrix-sendmail-835d1efc713f6c915e6b2657f77ba19066f61d4b",
        "type": "derivation"
      },
      "mkwindowsapp-tools": {
        "description": "A set of tools for working with packages made with mkWindowsApp.",
        "name": "mkwindows-tools-1.0.0",
        "type": "derivation"
      },
      "muun-recovery-tool": {
        "description": "You can use this Recovery Tool to transfer all funds out of your Muun account to an address of your choosing",
        "name": "muun-recovery-tool-v2.2.4",
        "type": "derivation"
      },
      "notepad-plus-plus": {
        "description": "A text editor and source code editor for use under Microsoft Windows. It supports around 80 programming languages with syntax highlighting and code folding. It allows working with multiple open files in a single window, thanks to its tabbed editing interface.",
        "name": "notepad-plus-plus-win64-8.5",
        "type": "derivation"
      },
      "nvidia-offload": {
        "name": "nvidia-offload",
        "type": "derivation"
      },
      "pdf2png": {
        "description": "A simple script to convert a PDF into multiple PNGs.",
        "name": "pdf2png-0.2.0.0",
        "type": "derivation"
      },
      "qutebrowser-hardware-accelerated": {
        "name": "qutebrowser-2.5.2-wrapped",
        "type": "derivation"
      },
      "rofi-menu": {
        "description": "Various rofi menus (aka. modi)",
        "name": "rofi-menu-0.7.0",
        "type": "derivation"
      },
      "rtrader-pro": {
        "description": "Rithmic professional trading software",
        "name": "rtrader-pro-default-17.24.0.0",
        "type": "derivation"
      },
      "sable": {
        "description": "Guide Sable through her Gliding; a rite of passage that will take her across vast deserts and mesmerizing landscapes, capped by the remains of spaceships and ancient wonders.",
        "name": "sable-unknown",
        "type": "derivation"
      },
      "send-to-kindle": {
        "description": "Send your personal and business documents to read them anytime, everywhere on Kindle devices and reading apps.",
        "name": "send-to-kindle-1.1.1.254",
        "type": "derivation"
      },
      "sierrachart": {
        "description": "A professional desktop Trading and Charting platform for the financial markets, supporting connectivity to various exchanges and backend trading platform services.",
        "name": "sierrachart-default-2485",
        "type": "derivation"
      },
      "sierrachart-example-study": {
        "description": "An example study that comes with Sierra Chart. This package demonstrates how to package Sierra Chart studies.",
        "name": "sierrachart-example-study-x86_64-w64-mingw32",
        "type": "derivation"
      },
      "sierrachart-with-example-study": {
        "description": "A professional desktop Trading and Charting platform for the financial markets, supporting connectivity to various exchanges and backend trading platform services.",
        "name": "sierrachart-example-study-2485",
        "type": "derivation"
      },
      "trace-font": {
        "description": "Trace font",
        "name": "trace-font-2020-03-25",
        "type": "derivation"
      },
      "vim-desktop": {
        "description": "A desktop menu (and file associations) to run VIM, a greatly improved version of the good old UNIX editor Vi. Alacritty is used as the terminal.",
        "name": "vim-desktop-1.0.1",
        "type": "derivation"
      }
    }
  }
}
```
