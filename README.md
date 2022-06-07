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

