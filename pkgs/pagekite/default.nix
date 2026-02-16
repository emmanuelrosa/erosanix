{ python3
, lib
, bash
, writeShellApplication
}: let
  # Snapshot of https://pagekite.net/pk/pagekite.py
  # version 1.5.2.260113
  pagekitePy = ./pagekite.py;
in writeShellApplication {
  name = "pagekite";
  runtimeInputs = [ python3 ];
  text = ''
    exec python ${pagekitePy} "$@"
  '';

  meta = with lib; {
    description = "A fast and reliable tool to make localhost servers visible to the public Internet.";
    longDescription = "This package uses a snapshot of https://pagekite.net/pk/pagekite.py because I could not build it from source; It's a Python 2 app and some dependencies aren't available in Nixpkgs";
    homepage = "http://pagekite.org/";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
