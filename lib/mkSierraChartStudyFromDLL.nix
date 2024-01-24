{ stdenv                          
, sierrachart }:
{ name ? "sierrachart-study"
  , src                           # The path to a single study DLL file.
  , dllName                       # The name of the output DLL. Ex. MyStudies_64.dll
}: stdenv.mkDerivation {
  inherit name src;
  dontUnpack = true;

  installPhase = ''
    # Create a lib directory, and place the DLL(s) within.
    # The sierrachart package will link the DLL(s) into the ACS_Source directory when creating the WINEPREFIX.
    mkdir -p $out/lib
    cp ${src} $out/lib/${dllName}
  '';
}
