{ lib
, fetchFromGitHub
, buildDartApplication
, dart
}: buildDartApplication rec {
  pname = "dart-frog-cli";
  version = "1.2.11";

  src = fetchFromGitHub {
    owner = "dart-frog-dev";
    repo = "dart_frog";
    rev = "dart_frog_cli-v${version}";
    hash = "sha256-zQBjk7q874KP9nPS+E6M3tGlyjot/6Nwiol1h5TViU8=";
  };

  sourceRoot = "${src.name}/packages/dart_frog_cli";
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  extraWrapProgramArgs = "--prefix PATH : ${dart}/bin";

  meta = {
    description = "The official command line interface for Dart Frog, a fast, minimalist backend framework for Dart";
    homepage = "http://dart-frog.dev";
    mainProgram = "dart_frog"; 
    maintainers = with lib.maintainers; [ emmanuelrosa ];
    license = lib.licenses.mit;
  };
}

