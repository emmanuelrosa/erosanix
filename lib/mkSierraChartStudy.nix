{ stdenv                          # The stdenv is not the default one; It's an environment with MingW as the compiler. 
, mcfgthread                      # The output DLL is linked to the mcfgthread-12 Windows DLL.
, sierrachart }:
{ name ? "sierrachart-study"
  , sourceFiles ? []              # A list of each individual source file to be compiled into a single DLL.
  , dllName                       # The name of the output DLL. Ex. MyStudies_64.dll
}: let
  cpFile = file: "cp ${file} ./";
  cpSourcesScript = builtins.concatStringsSep "/n" (builtins.map cpFile sourceFiles);
  sourceFilesString = builtins.concatStringsSep " " sourceFiles;
in stdenv.mkDerivation {
  inherit name;
  src = sierrachart; # Dummy src.
  dontUnpack = true; # Which is why I'm disabling source unpacking.

  # This adds the /$out/include directory from the sierrachart package as a directory to include (-I) when compiling.
  # The sierrachart package stores the ACSIL header files (normally in ACS_Source) into $out/include.
  buildInputs = [ sierrachart ]; 

  buildPhase = ''
    ${cpSourcesScript}

    # Execute the compiler using the Nixpkgs CC/CXX Wrapper
    # The wrapper take care of including Windows headers and headers provided by buildInputs.
    $CXX -D _WIN64 -U NOMINMAX -march=x86-64 -mtune=x86-64 -O2 -shared -static -static-libgcc -static-libstdc++ -s -fno-rtti -fno-exceptions -std=gnu++11 ${sourceFilesString} -o ${dllName} -Wno-deprecated
  '';

  installPhase = ''
    # Create a lib directory, and place the DLL(s) within.
    # The sierrachart package will link the DLL(s) into the ACS_Source directory when creating the WINEPREFIX.
    mkdir -p $out/lib
    cp ${dllName} $out/lib

    # Place any additional (non-study) 64-bit DLLs in $out/system32
    mkdir -p $out/system32
    cp ${mcfgthread}/bin/mcfgthread-12.dll $out/system32/mcfgthread-12.dll
  '';
}
