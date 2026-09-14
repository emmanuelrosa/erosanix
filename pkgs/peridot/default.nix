{ stdenv
, lib
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, gtk3
, xdg-user-dirs
, libsecret
}: stdenv.mkDerivation (finalAttrs: {
  pname = "peridot";
  version = "1.2.0"; #:version:#

  src = fetchurl {
    url = "https://github.com/nogringo/peridot/releases/download/v${finalAttrs.version}/peridot-${finalAttrs.version}-linux.deb";
    hash = "sha256-N7guQyBlmvDOBxakwIPOLV2tQi5Heo2+XPzLn9r/OTY="; #:hash:#
  };

  unpackPhase = ''
    dpkg -x $src .
  '';

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  buildInputs = [
    gtk3
    libsecret
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share
    mkdir -p $out/lib/peridot

    cp -r usr/local/peridot/. $out/lib/peridot/
    cp -r usr/share/. $out/share/
    ln -s $out/lib/peridot/peridot $out/bin/peridot

    patchelf --add-rpath $out/lib/peridot/lib $out/lib/peridot/peridot
    wrapProgram $out/lib/peridot/peridot --prefix PATH : ${lib.makeBinPath [ xdg-user-dirs ]}
    substituteInPlace $out/share/applications/peridot.desktop \
      --replace-fail "Exec=/usr/local/peridot/peridot" "Exec=peridot"

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
