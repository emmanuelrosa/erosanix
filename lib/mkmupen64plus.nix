{ stdenv
, writeShellScript
, mupen64plus
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
}:
{ name                          # The name of the executable.
, desktopName                   # The name displayed in the "applications" menu.
, category ? "Emulator"         # The freedesktop.org additional category.
                                # Can be any additional category where the "related category" is "Game". Defaults to "Emulator".
                                # See https://specifications.freedesktop.org/menu-spec/latest/apas02.html
, icon ? {}                     # Attribute set passed to makeDesktopIcon, minus the 'name" attribute:
                                # { src - Build-time path to the icon image.
                                #   icoIndex - For *.ico files, a number indicating which of the multiple images to extract; Etc, 0.
                                # }
, rom                           # Run-time path to the N64 ROM file.
}: 
let
  wrapper = writeShellScript "mupen64plus-wrapper" ''
    ${mupen64plus}/bin/mupen64plus "${rom}"
  '';
in stdenv.mkDerivation rec {
  pname = "${name}-mupen64plus-wrapper";
  version = "1.0.0";
  src = mupen64plus; # Dummy src; It's not used.
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    ln -s ${wrapper} $out/bin/${name}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      inherit desktopName;
      name = pname;
      exec = name;
      icon = name;
      categories = [ "Game" category ];
    })
  ];

  desktopIcon = makeDesktopIcon ({ inherit name; } // icon);
}
