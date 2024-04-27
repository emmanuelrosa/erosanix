# This package installs the compiled shim.cpp
# The reason for this package is that compiling the shim takes a while since Zig
# needs to compile the C++ standard library first.
# Using this shim package avoids the long compilation time by using a compiled copy
# of the shim already stored in this Nix flake.
# This shim package is NOT the default; For transparency, the source-based shim package is the default.
{ stdenv
, runCommand
}:runCommand "cl.exe" { } ''
    cp ${./shim.exe} $out
  ''
