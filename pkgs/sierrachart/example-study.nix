{ stdenv # The stdenv is not the default one; It's an environment with MingW as the compiler. 
, lib
, mcfgthread
, sierrachart }:
stdenv.mkDerivation {
  name = "sierrachart-example-study";
  src = sierrachart; # I'm using sierrachart as the source for this example, since the package contains example code.
  dontUnpack = true; # Which is why I'm disabling source unpacking.

  # This adds the /$out/include directory from the sierrachart package as a directory to include (-I) when compiling.
  # The sierrachart package stores the ACSIL header files (normally in ACS_Source) into $out/include.
  buildInputs = [ sierrachart ]; 

  buildPhase = ''
    cp $src/share/sierrachart/examples/Studies.cpp ./

    # Execute the compiler using the Nixpkgs CC/CXX Wrapper
    # The wrapper take care of including Windows headers and headers provided by buildInputs.
    $CXX -D _WIN64 -U NOMINMAX -march=x86-64 -mtune=x86-64 -O2 -shared -static -static-libgcc -static-libstdc++ -s -fno-rtti -fno-exceptions -std=gnu++11 Studies.cpp -o Studies_64.dll -Wno-deprecated
  '';

  installPhase = ''
    # Create a lib directory, and place the DLL(s) within.
    # The sierrachart package will link the DLL(s) into the ACS_Source directory when creating the WINEPREFIX.
    mkdir -p $out/lib
    cp Studies_64.dll $out/lib

    # Place any additional (non-study) 64-bit DLLs in $out/system32
    mkdir -p $out/system32
    cp ${mcfgthread}/bin/mcfgthread-12.dll $out/system32/mcfgthread-12.dll
  '';

  meta = with lib; {
    description = "An example study that comes with Sierra Chart. This package demonstrates how to package Sierra Chart studies.";
    homepage = "https://www.sierrachart.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-windows" ]; # Notice that the platform is set to Windows, even though we're cross-compiling on Linux.
  };
}
