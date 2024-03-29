{ stdenv
, lib
, mkWindowsApp
, wine
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, zenity
}:
mkWindowsApp rec {
  inherit wine;

  pname = "send-to-kindle";
  version = "1.1.1.255"; #:version:

  src = fetchurl {
    url = "https://s3.amazonaws.com/sendtokindle/SendToKindleForPC-installer.exe";
    sha256 = "0ah8fx05fppavlb384cyzlywyki43x03qq26a6ys5q51vgg49kii"; #:hash:
  };

  dontUnpack = true;
  wineArch = "win64";
  persistRegistry = true;
  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  fileMap = { "$HOME/.cache/send-to-kindle/AppData" = "drive_c/users/$USER/AppData"; };

  enabledWineSymlinks = {
    desktop = false;
  };

  winAppInstall = ''
    ${zenity}/bin/zenity --info --text "During the Send to Kindle installation you will be prompted to sign in to Amazon. Close that first prompt to allow the installation to complete. If prompted a 2nd time, go ahead and sign in."
    $WINE ${src} /S
    wineserver -w
  '';

  winAppRun = '' 
   if [ "$ARGS" == "" ]
   then
     $WINE start /unix "$WINEPREFIX/drive_c/Program Files (x86)/Amazon/SendToKindle/SendToKindle.exe"
   else
     file=$(winepath -w "$ARGS")
     $WINE start /unix "$WINEPREFIX/drive_c/Program Files (x86)/Amazon/SendToKindle/StkSendToHandler.exe" "$file"
  fi
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/${pname}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Send to Kindle";
      categories = ["Office" "Viewer"];
      mimeTypes = [ "text/plain" "application/msword" "application/rtf" "application/pdf" "image/png" "image/jpeg" "image/bmp" "image/gif" "application/x-mobipocket-ebook" "application/vnd.amazon.mobi8-ebook" "application/epub+zip" ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = "send-to-kindle";

    src = fetchurl {
      url = "https://r7.hiclipart.com/path/440/869/236/kindle-fire-iphone-kindle-store-amazon-kindle-7382d0d39a5d99e1ac56652e55c6b644.png";
      sha256 = "sha256-ao3UdXkhcp9tpB506dFR1cWgYUOLkEcX3DP5JyvVEzw=";
    };
  };

  meta = with lib; {
    homepage = "https://www.amazon.com/gp/sendtokindle";
    description = "Send your personal and business documents to read them anytime, everywhere on Kindle devices and reading apps.";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}

