{ lib
, symlinkJoin
, writeShellScript
, runCommand
, genericBinWrapper
, mesa
, linuxPackages
, libglvnd
, libvdpau-va-gl
}:
{ package
, vadrivers ? []
, enableNvidia ? false
}:
let
  mesa-drivers = [ mesa ];
  nvidia_x11 = linuxPackages.nvidia_x11;

  glxindirect = runCommand "mesa_glxindirect" { } (''
    mkdir -p $out/lib
    ln -s ${mesa}/lib/libGLX_mesa.so.0 $out/lib/libGLX_indirect.so.0
  '');

  libraryPath = builtins.concatStringsSep ":" [
    (symlinkJoin {
      name = "nanogl-libraries";
      paths = [
        "${mesa}/lib"
        "${mesa}/lib/dri"
        "${mesa}/lib/gbm"
        "${libvdpau-va-gl}/lib/vdpau"
        "${libglvnd}/lib"
        "${glxindirect}/lib"
      ] ++ (if enableNvidia then [
        "${nvidia_x11}/lib"
        "${nvidia_x11}/lib/gbm"
      ] else []);
    })
  ];

  gbmDriversPath = builtins.concatStringsSep ":" ([
    "${mesa}/lib/gbm"
  ] ++ (if enableNvidia then [
    (lib.optionalString enableNvidia "${nvidia_x11}/lib/gbm")
  ] else []));

  eglVendorLibraryPath = builtins.concatStringsSep ":" ([
    "${mesa}/share/glvnd/egl_vendor.d/"
  ] ++ (if enableNvidia then [
    (lib.optionalString enableNvidia "${nvidia_x11}/share/glvnd/egl_vendor.d/")
  ] else []));

  wrapper = writeShellScript "nanogl-wrapper" ''
    export LIBVA_DRIVERS_PATH=${lib.makeSearchPathOutput "out" "lib/dri" (mesa-drivers ++ vadrivers)}
    export LIBGL_DRIVERS_PATH=${libraryPath}
    export GBM_BACKENDS_PATH=${gbmDriversPath}
    export LD_LIBRARY_PATH=${libraryPath}
    export __EGL_VENDOR_LIBRARY_DIRS=${eglVendorLibraryPath}

    exec "@EXECUTABLE@" "$@"
  '';
in genericBinWrapper package wrapper

