{ stdenv
, lib
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, gtk3
, xdg-user-dirs
}: stdenv.mkDerivation rec {
  pname = "apidash";
  version = "0.3.0"; #:version:#

  src = fetchurl {
    url = "https://github.com/foss42/apidash/releases/download/v${version}/apidash-linux-amd64.deb";
    sha256 = "sha256-bd+HOI5jhlR000KoKBkBVQxEsH+le/80OVDCpWkWTAM="; #:hash:
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  buildInputs = [
    gtk3
  ];

  unpackPhase = ''
    dpkg -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r usr/. $out/
    ln -s $out/share/apidash/apidash $out/bin/apidash

    patchelf --add-rpath $out/share/apidash/lib $out/share/apidash/apidash
    wrapProgram $out/share/apidash/apidash --prefix PATH : ${lib.makeBinPath [ xdg-user-dirs ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "A beautiful AI-powered open-source cross-platform (Desktop & Mobile) API Client built using Flutter which can help you easily create & customize your HTTP & GraphQL API requests, visually inspect responses and generate API integration code.";
    homepage = "https://apidash.dev/";
    sourceProvenance = with sourceTypes; [
      binaryNativeCode
    ];
    license = licenses.asl20;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
