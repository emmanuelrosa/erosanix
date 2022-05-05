BEGIN {
}
/:version:/ { print "  version = \""version"\"; #:version:" }
/:hash:/ { print "    sha256 = \""hash"\" #:hash:" }
!/:version:/  && !/:hash:/ { print $0 }
END {
}
