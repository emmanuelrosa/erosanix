# Sierra Chart

Sierra Chart is a charting and trading platform, available at https://www.sierrachart.com/

The software is written for Windows, but it's compatible with Wine. Better yet, the developers are aware Linux users use Sierra Chart. However, due to an IO performance limitation in Wine, there's a setting you may wish to enable. See the following links for context:

 * https://www.sierrachart.com/SupportBoard.php?ThreadID=85248
 * https://bugs.winehq.org/show_bug.cgi?id=55232
 * https://www.sierrachart.com/SupportBoard.php?ThreadID=85443

![Sierra Chart running on NixOS](sierrachart.png)

The erosanix Nix flake contains a Nix package for Sierra Chart. The package uses `mkWindowsApp` (also included in erosanix) to provide seamless integration with NixOS:

 * Clean desktop menu integration (.desktop); Does not use Wine's menu builder. 
 * Upgrade or rollback Sierra Chart just like you would do with any other Nix package. No need to mess around with Wine bottles.
 * Multi-instance installations are supported. Each instance has its own executable, desktop menu entry, and data directory.
 * Up to 9 sub instances are supported. Each sub instance is saved to $HOME/.local/share/INSTANCE_NAME-instance/SierraChartInstance_#. Therefore, to delete a sub instance, exit Sierra Chart and then delete the corresponding sub instance directory.
 * Uses your default text editor to open [ACSIL](https://www.sierrachart.com/index.php?page=doc/Contents.php#AdvancedCustomStudySystemInterfaceandLanguage) study source code.
 * Supports using ACSIL studies packaged using Nix. Although you can also just save your study DLLs in the Sierra Chart "Data" directory.

## Packaging a custom ACSIL study

Packaging a study and building it with Nix from source code is made easy using the function `mkSierraChartStudy`: 

```
my-study = erosanix.lib.x86_64-linux.mkSierraChartStudy {
  name = "my-sierrachart-study";                  # The name of your Nix package.
  dllName = "MyStudy_64.dll";                     # The name of the output DLL.
  sourceFiles = [ ./MyStudy.h ./MyStudy.cpp ];    # The source code for the study.
};
```

To package a compiled DLL, simply use `mkDerivation` to copy the DLL to $out/lib and copy any additional dependent 64-bit DLLs to $out/system32.

Once the study is packaged, add it to the `studies` attribute when installing Sierra Chart:

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
