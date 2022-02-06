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
  version = "1.0.0";
 
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
    textTypes = builtins.map (s: "text/" + s) [ 
"text/x-kaitai-struct.xml" "text/x-gradle.xml" "text/x-credits.xml" "text/x-gettext-translation.xml" "text/x-uil.xml" "text/vnd.wap.wml.xml" "text/x-cobol.xml" "text/x-mrml.xml" "text/markdown.xml" "text/vnd.senx.warpscript.xml" "text/x-dsl.xml" "text/x-patch.xml" "text/x-xslfo.xml" "text/x-scala.xml" "text/tab-separated-values.xml" "text/x-subviewer.xml" "text/x-verilog.xml" "text/x-authors.xml" "text/x-csharp.xml" "text/html.xml" "text/x-fortran.xml" "text/x-vhdl.xml" "text/x-opml+xml.xml" "text/x-genie.xml" "text/vnd.trolltech.linguist.xml" "text/x-ldif.xml" "text/x-uri.xml" "text/x-matlab.xml" "text/cache-manifest.xml" "text/x-uuencode.xml" "text/x-java.xml" "text/x-install.xml" "text/x-moc.xml" "text/x-iptables.xml" "text/x-systemd-unit.xml" "text/vnd.graphviz.xml" "text/xmcd.xml" "text/x-makefile.xml" "text/x-mof.xml" "text/vnd.rn-realtext.xml" "text/richtext.xml" "text/css.xml" "text/x-gherkin.xml" "text/rfc822-headers.xml" "text/csv.xml" "text/x-scons.xml" "text/x-groovy.xml" "text/vbscript.xml" "text/x-ocaml.xml" "text/x-maven+xml.xml" "text/x-google-video-pointer.xml" "text/vcard.xml" "text/troff.xml" "text/x-troff-me.xml" "text/x-emacs-lisp.xml" "text/x-reject.xml" "text/x-bibtex.xml" "text/x-dcl.xml" "text/x-sagemath.xml" "text/x-scss.xml" "text/x-troff-mm.xml" "text/x-rpm-spec.xml" "text/x-idl.xml" "text/x-ms-regedit.xml" "text/x-mup.xml" "text/x-rst.xml" "text/x-ocl.xml" "text/x-pascal.xml" "text/x-erlang.xml" "text/x-changelog.xml" "text/x-cmake.xml" "text/x-qml.xml" "text/x-log.xml" "text/vnd.wap.wmlscript.xml" "text/x-twig.xml" "text/x-haskell.xml" "text/x-troff-ms.xml" "text/vtt.xml" "text/x-microdvd.xml" "text/x-common-lisp.xml" "text/x-readme.xml" "text/x-lua.xml" "text/sgml.xml" "text/x-copying.xml" "text/x-eiffel.xml" "text/x-imelody.xml" "text/x-literate-haskell.xml" "text/htmlh.xml" "text/x-xmi.xml" "text/x-setext.xml" "text/x-ooc.xml" "text/x-c++src.xml" "text/x-dbus-service.xml" "text/calendar.xml" "text/x-gettext-translation-template.xml" "text/x-kotlin.xml" "text/x-csrc.xml" "text/x-vala.xml" "text/x-opencl-src.xml" "text/x-python3.xml" "text/x-lilypond.xml" "text/x.gcode.xml" "text/x-c++hdr.xml" "text/enriched.xml" "text/x-scheme.xml" "text/x-texinfo.xml" "text/x-modelica.xml" "text/x-svsrc.xml" "text/x-adasrc.xml" "text/x-nfo.xml" "text/x-go.xml" "text/x-chdr.xml" "text/x-objcsrc.xml" "text/rust.xml" "text/vnd.sun.j2me.app-descriptor.xml" "text/x-txt2tags.xml" "text/x-sass.xml" "text/x-mpsub.xml" "text/x-dsrc.xml" "text/turtle.xml" "text/x-svhdr.xml" "text/tcl.xml" "text/plain.xml" "text/x-python.xml" "text/spreadsheet.xml" "text/csv-schema.xml" "text/x-ssa.xml" "text/x-meson.xml" "text/x-tex.xml" 
    ];

    mimeType = builtins.concatStringsSep ";" textTypes;
  in [
    (makeDesktopItem {
      inherit mimeType;

      name = "VIM";
      exec = "${alacritty}/bin/alacritty -e vim %F";
      icon = "VIM";
      desktopName = "VIM";
      genericName = "Text Editor";
      categories = "Utility;TextEditor;";
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
