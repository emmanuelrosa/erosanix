{
  description = "A basic Nix flake using mkWindowsApp to package a 64-bit Microsoft Windows application.";

  inputs = {
    erosanix.url = "github:emmanuelrosa/erosanix";
    nixpkgs.follows = "erosanix/nixpkgs";
  };

  outputs = { self, nixpkgs, erosanix }: {

    packages = let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;
      erosanixPkgs = erosanix.packages."${system}";
      erosanixLib = erosanix.lib."${system}";
    in {
      "${system}" = {
        default = self.packages."${system}".win-7zip;

        win-7zip = erosanixLib.mkWindowsAppNoCC rec {
          pname = "win-7zip";
          version = "25.01";
          wine = pkgs.wineWow64Packages.base;
          dontUnpack = true;
          enableMonoBootPrompt = false;
          wineArch = "win64";

          src = let
            majorVersion = lib.versions.major version;
            minorVersion = lib.versions.minor version;
          in pkgs.fetchurl {
            url = "https://github.com/ip7z/7zip/releases/download/${version}/7z${majorVersion}${minorVersion}.msi";
            sha256 = "sha256-3OnkVqzna5af4P5NIovwlmYsEdI3bZmpIQ9jZEKKlMQ=";
          };

          nativeBuildInputs = [ pkgs.copyDesktopItems erosanixLib.copyDesktopIcons ];

          installPhase = ''
            runHook preInstall
            ln -s $out/bin/.launcher $out/bin/${pname}
            runHook postInstall
          '';

          winAppInstall = ''
            $WINE msiexec /i ${src} /q
          '';

          winAppRun = ''
            $WINE "$WINEPREFIX/drive_c/Program Files (x86)/7-Zip/7zFM.exe" "$ARGS"
          '';

          desktopItems = let
            mimeTypes = [
              "application/x-tar"
              "application/7z-compressed"
              # More could be added here...
            ];
          in [
            (pkgs.makeDesktopItem {
              inherit mimeTypes;

              name = pname;
              exec = pname;
              icon = pname;
              desktopName = "7zip";
              categories = [ "Utility" "Archiving" ];
            })
          ];

          desktopIcon = erosanixLib.makeDesktopIcon {
            name = pname;

            src = pkgs.fetchurl {
              url = "https://7-zip.org/7ziplogo.png";
              sha256 = "sha256-+KwiAfQ8SYnrlbIYTu4XpwWjEH5DhShZ1c4B4jnRato=";
            };
          };

          meta = {
            description = "A file archiver with a high compression ratio.";
            homepage = "https://7-zip.org/";
            license = [ lib.licenses.lgpl2Plus lib.licenses.bsd3 ];
            maintainers = [];
            platforms = [ system ];
          };
        };
      };
    };
  };
}
