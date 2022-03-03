{ stdenv
, lib
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, alacritty
}:
stdenv.mkDerivation rec {

  pname = "vim-desktop";
  version = "1.0.1";
 
  src = fetchurl {
    url = "https://github.com/vim/vim/raw/master/runtime/vimlogo.gif";
    sha256 = "1mzgmi87gcpd2ld1xgpd1vqr0zkcba6a3ikb9jggjzy28sbfm2m7";
  };

  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  desktopItems = let
    mimeTypes = builtins.map (s: "text/" + s) [ 
"x-kaitai-struct" "x-gradle" "x-credits" "x-gettext-translation" "x-uil" "vnd.wap.wml" "x-cobol" "x-mrml" "markdown" "vnd.senx.warpscript" "x-dsl" "x-patch" "x-xslfo" "x-scala" "tab-separated-values" "x-subviewer" "x-verilog" "x-authors" "x-csharp" "html" "x-fortran" "x-vhdl" "x-opml+xml" "x-genie" "vnd.trolltech.linguist" "x-ldif" "x-uri" "x-matlab" "cache-manifest" "x-uuencode" "x-java" "x-install" "x-moc" "x-iptables" "x-systemd-unit" "vnd.graphviz" "xmcd" "x-makefile" "x-mof" "vnd.rn-realtext" "richtext" "css" "x-gherkin" "rfc822-headers" "csv" "x-scons" "x-groovy" "vbscript" "x-ocaml" "x-maven+xml" "x-google-video-pointer" "vcard" "troff" "x-troff-me" "x-emacs-lisp" "x-reject" "x-bibtex" "x-dcl" "x-sagemath" "x-scss" "x-troff-mm" "x-rpm-spec" "x-idl" "x-ms-regedit" "x-mup" "x-rst" "x-ocl" "x-pascal" "x-erlang" "x-changelog" "x-cmake" "x-qml" "x-log" "vnd.wap.wmlscript" "x-twig" "x-haskell" "x-troff-ms" "vtt" "x-microdvd" "x-common-lisp" "x-readme" "x-lua" "sgml" "x-copying" "x-eiffel" "x-imelody" "x-literate-haskell" "htmlh" "x-xmi" "x-setext" "x-ooc" "x-c++src" "x-dbus-service" "calendar" "x-gettext-translation-template" "x-kotlin" "x-csrc" "x-vala" "x-opencl-src" "x-python3" "x-lilypond" "x.gcode" "x-c++hdr" "enriched" "x-scheme" "x-texinfo" "x-modelica" "x-svsrc" "x-adasrc" "x-nfo" "x-go" "x-chdr" "x-objcsrc" "rust" "vnd.sun.j2me.app-descriptor" "x-txt2tags" "x-sass" "x-mpsub" "x-dsrc" "turtle" "x-svhdr" "tcl" "plain" "x-python" "spreadsheet" "csv-schema" "x-ssa" "x-meson" "x-tex" 
    ];
  in [
    (makeDesktopItem {
      inherit mimeTypes;

      name = "VIM";
      exec = "${alacritty}/bin/alacritty -e vim %F";
      icon = "VIM";
      desktopName = "VIM";
      genericName = "Text Editor";
      categories = ["Utility" "TextEditor"];
    })
  ];

  desktopIcon = makeDesktopIcon {
    inherit src;

    name = "VIM";
  };

  meta = with lib; {
    description = "A desktop menu (and file associations) to run VIM, a greatly improved version of the good old UNIX editor Vi. Alacritty is used as the terminal.";
    homepage = "https://github.com/emmanuelrosa/erosanix";
    license = licenses.mit;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" "i386-linux" ];
  };
}
