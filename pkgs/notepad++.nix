{ stdenv
, lib
, mkWindowsApp
, wine
, fetchurl
, imagemagick
, makeDesktopItem
, copyDesktopItems
}:
let
  icons = stdenv.mkDerivation {
    name = "notepad-plus-plus-icons";

    src = fetchurl {
      url = "https://notepad-plus-plus.org/favicon.ico";
      sha256 = "1av2m6m665ccfngnzqnbsnv2aky907p2c6ggvfxrwbp70szgj9vi";
    };

    nativeBuildInputs = [ imagemagick ];
    dontUnpack = true;

    installPhase = ''
      for n in 16 24 32 48 64 96 128 256; do
        size=$n"x"$n
        mkdir -p $out/hicolor/$size/apps
        convert $src\[2\] -resize $size $out/hicolor/$size/apps/notepad++.png
      done;
    '';
  };
in mkWindowsApp rec {
  inherit wine;

  pname = "notepad++";
  version = "8.1.9.3";
  nativeBuildInputs = [ copyDesktopItems ];

  src = fetchurl {
    url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v${version}/npp.${version}.Installer.x64.exe";
    sha256 = "22b33029e7db77ad25ac28c64882aed572faf585c4be13084a1ec80ed14fdb52";
  };

  dontUnpack = true;
  wineArch = "win64";

  installScript = ''
    wine start /unix ${src} /S
    wineserver -w
    rm -f "$WINEPREFIX/drive_c/Program Files/Notepad++/uninstall.exe"
    rm -fR "$WINEPREFIX/drive_c/Program Files/Notepad++/updater"
  '';

  runScript = ''
   rm -fR "$WINEPREFIX/drive_c/users/$USER/Application Data/Notepad++"
   mkdir -p "$HOME/.config/Notepad++"
   ln -s -v "$HOME/.config/Notepad++" "$WINEPREFIX/drive_c/users/emmanuel/Application Data/"

   wine start /unix "$WINEPREFIX/drive_c/Program Files/Notepad++/notepad++.exe" "$ARGS"
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/notepad++
    mkdir -p $out/share/icons
    ln -s ${icons}/hicolor $out/share/icons
    
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Notepad++";
      exec = pname;
      icon = pname;
      desktopName = "Notepad++";
      genericName = "Text Editor";
      categories = "Utility;TextEditor;";
    })
  ];

  meta = with lib; {
    description = "A text editor and source code editor for use under Microsoft Windows. It supports around 80 programming languages with syntax highlighting and code folding. It allows working with multiple open files in a single window, thanks to its tabbed editing interface.";
    homepage = "https://notepad-plus-plus.org/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
