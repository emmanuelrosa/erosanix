{ stdenv, lib, makeWrapper, fetchFromGitHub, gnused, jq, sxiv, libnotify, fd, file, xdg-utils }:

stdenv.mkDerivation rec {
  pname = "rofi-menu";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = pname;
    rev = version; 
    sha256 = "sha256-SU2/KUEFEG8Fs0rT25voDS15jPqjYntokEVGyIvZh3I=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -D rofi-menu-history $out/bin/rofi-menu-history
    install -D rofi-menu-shutdown $out/bin/rofi-menu-shutdown
    install -D rofi-menu-open $out/bin/rofi-menu-open
  '';

  postFixup = ''
    wrapProgram $out/bin/rofi-menu-history --prefix PATH : ${lib.makeBinPath [ gnused jq sxiv ]}
    wrapProgram $out/bin/rofi-menu-open --prefix PATH : ${lib.makeBinPath [ fd sxiv file xdg-utils ]}
  '';

  meta = with lib; {
    description = "Various rofi menus (aka. modi)";
    homepage = "https://github.com/emmanuelrosa/rofi-menu";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
