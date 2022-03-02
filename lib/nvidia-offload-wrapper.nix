{ stdenv
, writeShellScript
, nvidia-offload
}:
pkg: 
let
  wrapper = writeShellScript "nvidia-offload" ''
    exec -a ${nvidia-offload}/bin/nvidia-offload "@EXECUTABLE@" "$@"
  '';
in stdenv.mkDerivation {
  pname = "nvidia-offload-wrapper";
  version = "1.0.0";
  src = pkg;
  dontUnpack = true;

  installPhase = ''
    for f in $(find ${pkg}/bin)
    do 
      if [[ ! "$f" =~ "." ]] && [[ -f "$f" ]]
      then 
        local executable=$out/bin/$(basename "$f")
        echo "Wrapping $executable"
        install -D ${wrapper} "$executable"
        substituteInPlace "$executable" --subst-var-by EXECUTABLE "$f"
      fi
    done

    ln -s $src/share $out/share
  '';
}
