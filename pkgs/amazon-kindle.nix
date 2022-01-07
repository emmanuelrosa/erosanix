{ stdenv
, lib
, mkWindowsApp
, wine
, fetchurl
, requireFile
, makeDesktopItem
, copyDesktopItems
, imagemagick }:
let
  homepage = "https://www.amazon.com/Amazon-Digital-Services-LLC-Download/dp/B00UB76290/";
  icons = stdenv.mkDerivation {
    name = "amazon-kindle-icons";

    src = fetchurl {
      url = "https://r7.hiclipart.com/path/440/869/236/kindle-fire-iphone-kindle-store-amazon-kindle-7382d0d39a5d99e1ac56652e55c6b644.png";
      sha256 = "sha256-ao3UdXkhcp9tpB506dFR1cWgYUOLkEcX3DP5JyvVEzw=";
    };

    dontUnpack = true;
    nativeBuildInputs = [ imagemagick ];

    installPhase = ''
      for n in 16 24 32 48 64 96 128 256; do
        size=$n"x"$n
        mkdir -p $out/hicolor/$size/apps
        convert $src -resize $size $out/hicolor/$size/apps/amazon-kindle.png
      done;
    '';
  };
in mkWindowsApp rec {
  inherit wine;

  pname = "amazon-kindle";
  version = "1.33.62002";

  src = requireFile rec {
    name = "Kindle_for_PC_Download.exe";
    sha256 = "0f3b5lyijd8vlsrgqg2fvqx87ymc78qza7m7jkinrdzqrkcicmkg";
    message = ''
      In order to install Amazon Kindle for PC:

      1. Go to ${homepage}.
      2. Add the app to your cart, and checkout in order to purchase the app (which is free).
      3. You'll receive an email with a link to download the app.
      4. Once you have downloaded the file, please use the following command and re-run the installation: nix-prefetch-url file://path/to/${name}
      '';
  };

  dontUnpack = true;
  wineArch = "win64";
  nativeBuildInputs = [ copyDesktopItems ];

  winAppInstall = ''
    wine ${src} /S
  '';

  winAppRun = '' 
    cache_dir="$HOME/.cache/amazon-kindle"
    config_dir="$HOME/.config/amazon-kindle"

    mkdir -p "$cache_dir"
    rm -fR "$WINEPREFIX/drive_c/users/$USER"
    ln -s -v "$cache_dir" "$WINEPREFIX/drive_c/users/$USER"
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Local/Amazon/Kindle/crashdump"

    mkdir -p "$config_dir"
    cp -n "$WINEPREFIX/user.reg" "$config_dir/"
    rm "$WINEPREFIX/user.reg"
    ln -s "$config_dir/user.reg" "$WINEPREFIX/user.reg" 

    wine "$WINEPREFIX/drive_c/Program Files (x86)/Amazon/Kindle/Kindle.exe"
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/amazon-kindle
    mkdir -p $out/bin $out/share/icons
    ln -s ${icons}/hicolor $out/share/icons

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Amazon Kindle";
      categories = "Office;Viewer;";
    })
  ];

  meta = with lib; {
    inherit homepage;

    description = "Buy once, read everywhere. Sign in with an Amazon account, and sync Kindle books across all your devices that have the Kindle app installed and across any Kindle device.";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}

