{ stdenv
, lib
, mkWindowsApp
, wine
, wineArch
, wineFlavor
, enableVulkan ? false
}:
mkWindowsApp rec {
  inherit wine wineArch enableVulkan;

  pname = "winerun-${wineFlavor}";
  version = "0.1.0"; #:version:

  src = ./.;

  winAppRun = ''
    $WINE start /unix "$ARGS"
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/${pname}

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Bash script which sets up an ephemeral WINEPREFIX containing ${wineFlavor} and then runs the provided Wine-compatible Windows executable. Ex. winerun-wine64 /path/to/64bit/notepad++.exe";
    homepage = "https://github.com/emmanuelrosa/erosanix";
    license = licenses.mit;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
