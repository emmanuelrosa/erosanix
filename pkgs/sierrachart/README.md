# Sierra Chart

Sierra Chart is a charting and trading platform, available at https://www.sierrachart.com/

Sierra Chart is written for Windows x86_64, but it's highly compatible with Wine. 

NOTE: Due to an IO performance limitation in Wine, there's a setting you may wish to enable. See the following links for context:

 - https://www.sierrachart.com/SupportBoard.php?ThreadID=85248
 - https://bugs.winehq.org/show_bug.cgi?id=55232
 - https://www.sierrachart.com/SupportBoard.php?ThreadID=85443

![Sierra Chart running on NixOS](sierrachart.png)

The erosanix Nix flake contains a Nix package for Sierra Chart. The package uses `mkWindowsApp` (also included in erosanix) to provide seamless integration with NixOS.

## Sierra Chart Nix package features

 - Native-like integration with your desktop environment's Application menu.
 - Upgrade or rollback Sierra Chart just like any other Nix package.
 - Multiple (*named*) instances can be installed.
 - Limited support for up to 9 sub-instances.
 - Edit ACSIL study source code using your favorite text editor.
 - (Optionally) compile ACSIL studies locally from within Sierra Chart, using Clang/LLVM.
 - ACSIL studies can be packaged with Nix in DLL or source form, and automatically installed in a Sierra Chart instance.

### Linux desktop integration

The Sierra Chart Nix package created a .desktop file for launching Sierra Chart. In addition, the Wine menu builder is disabled. This leads to an Application menu entry which always points to the correct Sierra Chart installation; No more stale menu entries.

Sierra Chart bundles the Notepad++ text editor, but the Nix package disables it in favor of using `xdg-open` to edit ACSIL source files. Emacs, VIM, ... simply install your Linux native text editor of choice. Sierra Chart will unknowingly use it when you select an ACSIL source file from the *Analysis* menu.

### Upgrades and rollbacks

Instead of using the updater built-in to Sierra Chart, the Nix package expects users to upgrade and rollback Sierra Chart using Nix. Simply treat it like any other Nix package. Through the magic of `mkWindowsApp`, Sierra Chart and the Wine prefix will be upgraded or rolled back, accordingly. 

You can essentially forget about the Wine prefix; It's managed for you automatically. This also applies to Wine updates.

### Multi-instance support

The ability to install multiple instances of Sierra Chart is very important, and it's a well-supported feature of this Nix package. By default, when you install Sierra Chart with this Nix package, it will create the executable `sierrachart-default`. The postfix *default* is the name of the instance. Therefore, to install multiple instances you simply provide a unique alternative instance name:

```
environment.systemPackages = with pkgs; [
    (erosanix.packages.x86_64.sierrachart.override {
        instanceName = "dev";
    })
]
```

The example above would create an executable named `sierrachart-dev`, reflecting the *dev* instance. Each instance is completely independent, with its own entry in the Application menu, seperate Wine prefix and data files.

By the way, the Sierra Chart data files are saved at $HOME/.local/share/sierrachart-*INSTANCE_NAME*/.

### Sub-instance support

Although this Nix package provides support for sub-instances, it's not a well-tested feature. I don't recommend using it for anything important. The directories for each sub-instance are located at $HOME/.local/share/sierrachart-*INSTANCE_NAME*-instance/

### ASCIL study development

The Sierra Chart Nix package contains really good support for ASCIL study development. The intention is to provide a seamless experience which mimics how ASCIL development is done on Windows, but instead using Linux native tools. It begins with the text editor.

As mentioned previously, all you need to do is ensure you have installed a Linux native text editor. However, the text editor must come with a .desktop file which associates text files; Ideally it will associate C++ source files. Basically any GUI-based text editor will work. Personally, I have a custom Nix package which runs VIM without the GUI in an **Alacritty** terminal. Since the Sierra Chart Nix package replaces Notepad++ with `winebrowser`, when you select or create an ASCIL source file Sierra Chart will indirectly open your text editor through `xdg-open`.

When you're ready to compile an ASCIL study, by default you can only compile remotely; The Visual C++ release and debug builds are not available. My preferred method is to enable support for local builds using Clang/LLVM:

```
environment.systemPackages = with pkgs; [
    (erosanix.packages.x86_64.sierrachart.override {
        enableCompilerShim = true;   
    })
]
```

When the compiler shim is enabled, the Sierra Chart Nix package will install the Zig compiler. The compiler for the Zig programming language comes with a smaller version of the Clang compiler. This compiler is then transparently integrated with Sierra Chart so that when you run a Visual C++ release or debug build, it will compile with the Linux native version of Clang while targeting Windows; Hence the build is cross-compiled. Release builds are compiled with level 2 (-O2) optimizations and debug builds enable debug symbols, compiler verbosity, and shim verbosity.

NOTE: During a local release or debug build you'll see an empty Windows console (created by Wine). Don't close that console window; It will remain open without producing any visible output, throughout the build process. Don't worry, the shim is programmed to automatically timeout in the event the build gets stuck. Once the build completes, the Windows console will close and Sierra Chart will display the build output.

As a bonus, the Zig compiler features a powerful build cache which is made available to Clang. Initial builds are slower than with a traditional Clang installation because the C and C++ standard libraries need to be compiled from source. But, later builds are *very* fast; For example, with a hot build cache Clang can compile a study on my Ryzen 7 PC in under 3 seconds. And because the standard libraries are compiled from source, the compiler optimizations implemented in the compiler shim also apply to the ASCIL header files and the C/C++ standard libraries.

NOTE: Consider debugging, (meaning attaching a debugger to an ASCIL DLL) as unsupported. It may work, but I've never tried it.

### ASCIL study distribution

Packaging a study and building it with Nix from source code is made easy using the function `mkSierraChartStudyFromSrc`: 

```
my-study = erosanix.lib.x86_64-linux.mkSierraChartStudy {
  name = "my-sierrachart-study";                  # The name of your Nix package.
  dllName = "MyStudy_64.dll";                     # The name of the output DLL.
  src = ./path/to/the/source/code;                # The source code for the study.
};
```

A study already compiled as a DLL can also be packaged with `mkSierraChartStudy`:

```
my-study = erosanix.lib.x86_64-linux.mkSierraChartStudyFromDLL {
  name = "my-sierrachart-study";
  dllName = "MyStudy_64.dll";
  src = ./path/to/MyStudy_64.dll;
};
```

Once the study is packaged, add it to the `studies` attribute when installing Sierra Chart:

```
(erosanix.packages.x86_64-linux.sierrachart.override { 
  studies = [ self.packages.x86_64-linux.my-study ]; 
});
```

The `mkSierraChartStudyFromDLL` and `mkSierraChartStudyFromSrc` Nix functions create a Nix package which conforms to a specific API which the Sierra Chart Nix package uses to make the studies available to Sierra Chart. You don't have to use those functions, but they illustrate how to use the API; See their source code for details.

## Limitations and considerations

The Sierra Chart Nix package has the following known limitations:

 - The Data directory must be `C:\SierraChart\Data`. This is the default and must not be changed.
 - Sub-instance support is very minimal. I don't recommend using it.
 - I intended `mkSierraChartStudyFromSrc` to provide assurance that the ASCIL source code is always compiled with the specific version of Sierra Chart they're installed with. In practice it does work that way in most cases, but due to it's current design it's possible to break such an assurance. I have every intention to address this nitpick.

Since the Sierra Chart Nix package uses `mkWindowsApp` under-the-hood, it's important to become familiar with its functionality. Namely, `mkWindowsApp` uses Docker-like layers to build Wine prefixes. In practice, it mimics the Nix store, but it's user-specific. Like the Nix store, without periodic purging it will accumulate large amounts of disk space. There's already tooling to keep these layers trimmed, but it needs to be set up manually.
