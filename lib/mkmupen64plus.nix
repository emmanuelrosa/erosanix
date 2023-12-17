{ stdenv
, writeShellScript
, mupen64plus
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
}:
{ name
, desktopName 
, icon ? {}
, rom
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
      categories = [ "Game" "Emulator" ];
    })
  ];

  desktopIcon = makeDesktopIcon ({ inherit name; } // icon);
}
