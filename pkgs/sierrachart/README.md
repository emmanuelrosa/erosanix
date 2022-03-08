# Sierra Chart

Sierra Chart is a charting and trading platform, available at https://www.sierrachart.com/

The software is written for Windows, but it's compatible with Wine. Better yet, the developers are aware Linux users use Sierra Chart.

![Sierra Chart running on NixOS](sierrachart.png)

The erosanix Nix flake contains a Nix package for Sierra Chart. The package uses `mkWindowsApp` (also included in erosanix) to provide seamless integration with NixOS:

 * Clean desktop menu integration (.desktop); Does not use Wine's menu builder. 
 * Upgrade or rollback Sierra Chart just like you would do with any other Nix package. No need to mess around with Wine bottles.
 * Multi-instance installations are supported. Each instance has its own executable, desktop menu entry, and data directory.
 * The bundled Notepad++ is replaced with xdg-open so that your favorite Linux text editor is used instead.

## FAQ

 1. Can I upgrade or rollback Sierra Chart within the application? Yes, but you shouldn't do it because your upgrade/rollback will not be persisted. `mkWindowsApp` creates ephemeral Wine bottles from read-only layers, so changes you make outside of certain files and directories will not be persisted.
 2. Where are my data files stored? On Windows Sierra Chart is usually installed at C:\SierraChart. That directory is expected to be writable since data files are stored there. This package handles the situation differently. The C:\SierraChart directory is partly read-only and partly read-write. The writable files are stored at $HOME/.local/share/sierrachart-INSTANCE_NAME, where INSTANCE_NAME defaults to "default".
 3. I created a file within SierraChart, but the file is not in the data directory mentioned in question #3. Where is the file? Only certain files and directories are persisted. Look at the `fileMap` attribute in the package's source code to see what they are. If the file/directory in question is not listed, then let me know so I can add it to the `fileMap`. However, if the file in question is listed yet still missing, it could be that it's a new file and thus `mkWindowsApp` didn't "map" it in. In such cases, the file should be persisted once you exit SierraChart; `mkwindowsApp` will see the file and copy it out to the data directory.
