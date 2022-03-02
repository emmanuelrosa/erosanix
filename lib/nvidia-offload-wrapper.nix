{ stdenv
, writeShellScript
, nvidia-offload
}:
pkg: 
let
  wrapper = writeShellScript "nvidia-offload" ''
    ${nvidia-offload}/bin/nvidia-offload "@EXECUTABLE@" "$@"
  '';
in stdenv.mkDerivation {
  pname = "nvidia-offload-wrapper";
  version = "1.0.1";
  src = pkg;
  dontUnpack = true;

  installPhase = ''
    for f in $(find -L $src/bin)
    do 
      if [[ ! "$(basename $f)" =~ ^\. ]] && [[ ! -d "$f" ]] && [[ -x "$f" ]]
      then 
        local executable=$out/bin/$(basename "$f")
        install -D ${wrapper} "$executable"
        substituteInPlace "$executable" --subst-var-by EXECUTABLE "$f"
      fi
    done

    if [[ ! -d $out ]]
    then
      echo "ERROR: No executables to wrap were found at $src/bin" 1>&2 
      exit 1
    fi

    # Symlink the share directory so that .desktop files and such continue to work.
    if [[ -d $src/share ]]
    then
      ln -s $src/share $out/share
    fi
  '';
}
