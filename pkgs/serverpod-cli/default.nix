{ stdenvNoCC
, buildDartApplication
, lib
, fetchFromGitHub
, coreutils
, flutter
, dart-flutter
}:

let 
  version = "2.9.2";

  src = fetchFromGitHub {
    owner = "serverpod";
    repo = "serverpod";
    tag = version;
    hash = "sha256-H4cB/jp/AwBUH3fQ1vDKpvCWQHLcP1e7HChEbEfnXLU=";
  };

  serverpod_home = stdenvNoCC.mkDerivation {
    pname = "serverpod-home";
    inherit src version;

    installPhase = ''
      mkdir $out
      cp -r . $out/
    '';
  };
in buildDartApplication {
  pname = "serverpod-cli";
  inherit src version;

  sourceRoot = "${src.name}/tools/serverpod_cli";
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  extraWrapProgramArgs = "--set SERVERPOD_HOME ${serverpod_home} --prefix PATH : ${lib.makeBinPath [ coreutils flutter dart-flutter ]}";

  postInstall = ''
    files="dartdoc_options.yaml include lib LICENSE README revision sdk_packages.yaml version"

    for f in $files; do
      if [ -L $f ]; then
        ln -s $(readlink ${dart-flutter}/$f) $out/$f
      else
        ln -s ${dart-flutter}/$f $out/$f
      fi
    done
  '';

  meta = {
    homepage = "https://serverpod.dev/";
    description = "The CLI for serverpod, an open-source, scalable app server, written in Dart for the Flutter community.";
    mainProgram = "serverpod";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ emmanuelrosa ];
  };
}
