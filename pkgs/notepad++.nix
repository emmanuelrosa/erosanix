{ stdenv
, lib
, mkWindowsApp
, wine
, wineArch
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
}:
let
  version = "8.5.4"; #:version:

  srcs = {
    win64 = fetchurl {
      url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v${version}/npp.${version}.Installer.x64.exe";
      sha256 = "0ppc925y14a3bhc5v2x6dl83c9qlg547lwn7a3sw4pjab5r6gx8x"; #:hash64:
    };

    win32 = fetchurl {
      url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v${version}/npp.${version}.Installer.exe";
      sha256 = "13r66s2ns2dwhr2w91ypcg6bzjk66ki8ylh8kmlp3ihr2rgr2fss"; #:hash32:
    };
  };
in mkWindowsApp rec {
  inherit version wine wineArch;

  pname = "notepad-plus-plus-${wineArch}";
 
  src = srcs."${wineArch}";

  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];
  dontUnpack = true;
  fileMap = { "$HOME/.config/Notepad++" = "drive_c/users/$USER/AppData/Roaming/Notepad++"; };

  winAppInstall = ''
    $WINE start /unix ${src} /S
    wineserver -w
    rm -f "$WINEPREFIX/drive_c/Program Files/Notepad++/uninstall.exe"
    rm -fR "$WINEPREFIX/drive_c/Program Files/Notepad++/updater"
  '';

  winAppRun = ''
   $WINE start /unix "$WINEPREFIX/drive_c/Program Files/Notepad++/notepad++.exe" "$ARGS"
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/${pname}
    
    runHook postInstall
  '';

  desktopItems = let
    textTypes = builtins.map (s: "text/" + s) [ "plain" "html" "rust" "vbscript" "x-cmake" "x-changelog" "x-cobol" "x-common-lisp" "x-csharp" "x-c++src" "x-csrc" "x-erlang" "x-fortran" "x-haskell" "x-java" "x-log" "x-makefile" "x-objcsrc" "x-python" "x-readme" "x-scheme" "x-install" ];

    appTypes = builtins.map (s: "application/" + s) [ "json" "x-msi" "xml" "x-perl" ];
    mimeTypes = builtins.concatLists [ textTypes appTypes ];
  in [
    (makeDesktopItem {
      inherit mimeTypes;

      name = "Notepad++";
      exec = pname;
      icon = pname;
      desktopName = "Notepad++";
      genericName = "Text Editor";
      categories = ["Utility" "TextEditor"];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    icoIndex = 2;

    src = fetchurl {
      url = "https://notepad-plus-plus.org/favicon.ico";
      sha256 = "1av2m6m665ccfngnzqnbsnv2aky907p2c6ggvfxrwbp70szgj9vi";
    };
  };

  meta = with lib; {
    description = "A text editor and source code editor for use under Microsoft Windows. It supports around 80 programming languages with syntax highlighting and code folding. It allows working with multiple open files in a single window, thanks to its tabbed editing interface.";
    homepage = "https://notepad-plus-plus.org/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" "i686-linux" ];
    mainProgram = pname;
  };
}
