{ stdenv
, imagemagick
}:
{ name
, src
, pathWithinSrc ? ""
, icoIndex ? null # For dealing with ico files.
}: stdenv.mkDerivation {
  inherit src;
  name = "${name}-icons";

  nativeBuildInputs = [ imagemagick ];
  dontUnpack = if (builtins.stringLength pathWithinSrc) > 0 then false else true;
  srcPath = if (builtins.stringLength pathWithinSrc) > 0 then pathWithinSrc else src;

  installPhase = ''
    ico_index=${builtins.toString icoIndex}

    for n in 16 24 32 48 64 96 128 256; do
      size=$n"x"$n
      mkdir -p $out/hicolor/$size/apps

      if [ "$ico_index" == "" ]
      then
        convert $srcPath -resize $size $out/hicolor/$size/apps/${name}.png
      else
        convert $srcPath\[$ico_index\] -resize $size $out/hicolor/$size/apps/${name}.png
      fi
    done;
  '';
}
