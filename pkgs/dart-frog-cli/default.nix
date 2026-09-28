{ lib
, fetchFromGitHub
, buildDartApplication
, dart
}: buildDartApplication (finalAttrs: {
  pname = "dart-frog-cli";
  version = "1.2.14";

  src = fetchFromGitHub {
    owner = "dart-frog-dev";
    repo = "dart_frog";
    rev = "dart_frog_cli-v${finalAttrs.version}";
    hash = "sha256-B5ET/SwQzYw251Ox/RyuLM27+M//xTehke9JJSD7Gf8=";
  };

  sourceRoot = "${finalAttrs.src.name}/packages/dart_frog_cli";
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  extraWrapProgramArgs = "--prefix PATH : ${dart}/bin";

  meta = {
    description = "The official command line interface for Dart Frog, a fast, minimalist backend framework for Dart";
    homepage = "http://dart-frog.dev";
    mainProgram = "dart_frog"; 
    maintainers = with lib.maintainers; [ emmanuelrosa ];
    license = lib.licenses.mit;
  };
})

