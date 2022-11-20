# Sierra Chart

Sierra Chart is a charting and trading platform, available at https://www.sierrachart.com/

The software is written for Windows, but it's compatible with Wine. Better yet, the developers are aware Linux users use Sierra Chart.

![Sierra Chart running on NixOS](sierrachart.png)

The erosanix Nix flake contains a Nix package for Sierra Chart. The package uses `mkWindowsApp` (also included in erosanix) to provide seamless integration with NixOS:

 * Clean desktop menu integration (.desktop); Does not use Wine's menu builder. 
 * Upgrade or rollback Sierra Chart just like you would do with any other Nix package. No need to mess around with Wine bottles.
 * Multi-instance installations are supported. Each instance has its own executable, desktop menu entry, and data directory.
 * Up to 9 sub instances are supported. Each sub instance is saved to $HOME/.local/share/INSTANCE_NAME-instance/SierraChartInstance_#. Therefore, to delete a sub instance, exit Sierra Chart and then delete the corresponding sub instance directory.
 * Uses your default text editor to open [ACSIL](https://www.sierrachart.com/index.php?page=doc/Contents.php#AdvancedCustomStudySystemInterfaceandLanguage) study source code.
 * Supports using ACSIL studies packaged using Nix. Although you can also just save your study DLLs in the Sierra Chart "Data" directory.

## Packaging a custom ACSIL study

Packaging a study with Nix is quite easy. Take a look at this annotated example which compiles one of the studies which comes with Sierra Chart. Yes, you can compile a Windows DLL quite easily with Nix:

```
{ stdenv         # The stdenv is not the default one; It's an environment with MingW as the compiler. 
, lib
, mcfgthread     # This threading library is linked in my MingW.
, sierrachart }: # sierrachart is one of the inputs, since it provides the ACSIL header files
stdenv.mkDerivation {
  name = "my-study";
  src = sierrachart; # I'm using sierrachart as the source for this example, since the package contains example code.
  dontUnpack = true; # Which is why I'm disabling source unpacking.

  # This adds the /$out/include directory from the sierrachart package as a directory to include (-I) when compiling.
  # The sierrachart package stores the ACSIL header files (normally in ACS_Source) into $out/include.
  buildInputs = [ sierrachart ]; 

  buildPhase = ''
    cp $src/share/sierrachart/examples/Studies.cpp ./

    # Execute the compiler using the Nixpkgs CC/CXX Wrapper
    # The wrapper take care of including Windows headers and headers provided by buildInputs.
    $CXX -D _WIN64 -shared -static -static-libgcc -static-libstdc++ -s -fno-rtti -fno-exceptions -std=gnu++11 Studies.cpp -o Studies.dll
  '';

  installPhase = ''
    # Create a lib directory, and place the DLL(s) within.
    # The sierrachart package will link the DLL(s) into the ACS_Source directory when creating the WINEPREFIX.
    mkdir -p $out/lib
    cp Studies.dll $out/lib

    # Place any additional (non-study) DLLs in $out/system32
    mkdir -p $out/system32
    ln -s ${mcfgthread}/bin/mcfgthread-12.dll $out/system32/mcfgthread-12.dll
  '';

  meta = with lib; {
    description = "An example study that comes with Sierra Chart. This package demonstrates how to package Sierra Chart studies.";
    homepage = "https://www.sierrachart.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-windows" ]; # Notice that the platform is set to Windows, even though we're cross-compiling on Linux.
  };
}
```

Then, you need to add the package to your flake using the mingwW64 cross compiler support built into Nix (actually Nixpkgs):

```
my-study = pkgs.pkgsCross.mingwW64.callPackage ./pkgs/my-study.nix { 
  mcfgthread = pkgs.pkgsCross.mingwW64.windows.mcfgthreads;
  sierrachart = erosanix.packages.x86_64-linux.sierrachart;
};
```

Packaging a compiled DLL is even simpler, since all you need to do is copy the DLL to $out/lib and copy any additional dependent DLLs to $out/system32.

To use a packaged study, add it to the `studies` attribute when installing Sierra Chart:

```
(erosanix.packages.x86_64-linux.sierrachart.override { 
  studies = [ self.packages.x86_64-linux.my-study ]; 
});
```

What effectively happens is that when you run Sierra Chart, the launcher script will symlink the study to your Sierra Chart "Data" directory. Then when you exit Sierra Chart, the study symlinks are removed.

The end result is a study distribution mechanism which always provides studies compiled against the current version of Sierra Chart, keeping everything nice and fresh :)

## FAQ

 1. Can I upgrade or rollback Sierra Chart within the application? Yes, but you shouldn't do it because your upgrade/rollback will not be persisted. `mkWindowsApp` creates ephemeral Wine bottles from read-only layers, so changes you make outside of certain files and directories will not be persisted.
 2. Where are my data files stored? On Windows Sierra Chart is usually installed at C:\SierraChart. That directory is expected to be writable since data files are stored there. This package handles the situation differently. The C:\SierraChart directory is partly read-only and partly read-write. The writable files are stored at $HOME/.local/share/sierrachart-INSTANCE_NAME, where INSTANCE_NAME defaults to "default".
 3. I created a file within SierraChart, but the file is not in the data directory mentioned in question #3. Where is the file? Only certain files and directories are persisted. Look at the `fileMap` attribute in the package's source code to see what they are. If the file/directory in question is not listed, then let me know so I can add it to the `fileMap`. However, if the file in question is listed yet still missing, it could be that it's a new file and thus `mkWindowsApp` didn't "map" it in. In such cases, the file should be persisted once you exit SierraChart; `mkwindowsApp` will see the file and copy it out to the data directory.
