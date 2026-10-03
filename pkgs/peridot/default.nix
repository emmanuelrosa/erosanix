{ stdenv
, lib
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, gtk3
, xdg-user-dirs
, libsecret
, jre_minimal
}: stdenv.mkDerivation (finalAttrs: {
  pname = "peridot";
  version = "1.3.0"; #:version:#

  src = fetchurl {
    url = "https://github.com/nogringo/peridot/releases/download/v${finalAttrs.version}/peridot-${finalAttrs.version}-linux-x64.deb";
    hash = "sha256-ku4WqvzSeo84Q6xtkx2VlLONA5BgTZ/z1G7FEaGm0a4="; #:hash:#
  };

  unpackPhase = ''
    dpkg -x $src .
  '';

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  buildInputs = [
    gtk3
    libsecret
  ];

  autoPatchelfLibs = [
    "${jre_minimal}/lib/server/"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share
    mkdir -p $out/opt/peridot

    cp -r opt/peridot/. $out/opt/peridot/
    cp -r usr/share/. $out/share/
    ln -s $out/opt/peridot/peridot $out/bin/peridot

    patchelf --add-rpath $out/opt/peridot/lib $out/opt/peridot/peridot
    wrapProgram $out/opt/peridot/peridot \
      --prefix PATH : ${lib.makeBinPath [ xdg-user-dirs ]} \
      --set LD_LIBRARY_PATH $out/opt/peridot/lib

    runHook postInstall
  '';

  meta = {
    description = "Nostr bunker (aka. Nostr Connect) for desktop.";
    homepage = "https://github.com/nogringo/peridot/";
    mainProgram = "peridot"; 
    maintainers = with lib.maintainers; [ emmanuelrosa ];
    license = lib.licenses.mit;
  };
})
