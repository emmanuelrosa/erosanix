# erosanix
My main NixOS/Nix Flakes repository includes misc. packages, NixOS modules, and Nix functions. This repo also functions as a Nix User Repository (NUR), and replaces my old NUR `emmanuelrosa`.

## Features

* `mkWindowsApp` - A derivation for packaging Wine-compatible Windows programs. There are also various packaged programs, such as Notepad++ and Sierra Chart.
* Bitcoin packages - Various Bitcoin tools are packaged, such as the Muun wallet recovery tool
* `nvidia-offload-wrapper` - A function to wrap programs so that they use Nvidia offload rendering.
* `makeDesktopIcon` - A function to generate desktop icons. A companion to makeDesktopItem.
