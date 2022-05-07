/#:version:/ { match ($0, /^(.*)"([0-9]+)"(.*)/, m); printf ("%s\"%s\"%s", m[1], version , m[3]) }
/#:hash:/ { match ($0, /^(.*)"([0-9a-z-]+)"(.*)/, m); printf ("%s\"%s\"%s", m[1], hash , m[3]) }
!/#:version:/  && !/#:hash:/ { print $0 }
