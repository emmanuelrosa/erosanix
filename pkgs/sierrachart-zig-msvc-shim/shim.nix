{ stdenv
, runCommand
, zig
}:runCommand "cl.exe" { } ''
    export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
    export ZIG_LOCAL_CACHE_DIR=$(mktemp -d)
    ${zig}/bin/zig c++ -x c++ -std=c++20 -target x86_64-windows ${./shim.cpp} -o $out
  ''
