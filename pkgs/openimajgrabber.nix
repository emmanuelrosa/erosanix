{ stdenv
, lib
, fetchurl
, libv4l
}:
stdenv.mkDerivation rec {
  pname = "openimajgrabber";
  version = "1.3.10"; #:version:

  src = fetchurl {
    url = "https://github.com/openimaj/openimaj/archive/refs/tags/openimaj-${version}.tar.gz";
    sha256 = "0dyk9qrqgllfiwfacxgy8widwjadaiv6qs36qiixk427i3d7zdg0"; #:hash:
  };

  buildInputs = [ libv4l ];

  buildPhase = ''
    pushd hardware/core-video-capture/src-native/linux
    g++ -fPIC -g -c OpenIMAJGrabber.cpp
    g++ -fPIC -g -c capture.cpp 
    g++ -shared -Wl,-soname,OpenIMAJGrabber.so -o OpenIMAJGrabber.so OpenIMAJGrabber.o capture.o -lv4l2 -lrt -lv4lconvert
    popd
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp hardware/core-video-capture/src-native/linux/OpenIMAJGrabber.so $out/lib
  '';

  meta = with lib; {
    description = "A collection of libraries and tools for multimedia (images, text, video, audio, etc.) content analysis and content generation. This package only builds the OpenIMAJGrabber for Linux.";
    homepage = "http://www.openimaj.org";
    license = licenses.bsd0;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
