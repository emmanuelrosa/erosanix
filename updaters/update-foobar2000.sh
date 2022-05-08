#! /run/current-system/sw/bin/env nix-shell
#! nix-shell -i bash -p curl htmlq gnused gnugrep gawk

script_path=$(dirname $(realpath ${BASH_SOURCE[0]}))
repo_path=$(dirname $script_path)
echo "Checking foobar2000 for updates..."
filename=$(basename $(curl -s https://www.foobar2000.org/download | htmlq -a href a | grep getfile))
url="https://www.foobar2000.org/files/$filename"
upstream_version=$(echo $filename | sed 's/^foobar2000_v\([[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\)\(.*\)/\1/')
pkg_version=$(grep "#:version: =" $repo_path/pkgs/foobar2000.nix | sed -e 's/#:version://' -e 's/version = \"\([[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\)\";/\1/')

if [ "$upstream_version" == "$pkg_version" ]
then
  echo "The foobar2000 package is already up-to-date".
else
  echo "Found an update for the foobar2000 package."
  echo "Attempting to update from $pkg_version to $upstream_version ..."
  src=$(mktemp)
  updated_nix_src=$(mktemp)
  curl $url > $src
  sha256=$(nix-prefetch-url --name $filename --type sha256 "file://$src")
  awk -f $script_path/update-derivation.awk -v hash="$sha256" -v version="$upstream_version" $repo_path/pkgs/foobar2000.nix > $updated_nix_src
  cat $updated_nix_src > $repo_path/pkgs/foobar2000.nix
  rm $src
  rm $updated_nix_src
  echo "Update complete."
fi

