#! /run/current-system/sw/bin/env nix-shell
#! nix-shell -i bash -p curl htmlq gnused gnugrep gawk

script_path=$(dirname $(realpath ${BASH_SOURCE[0]}))
repo_path=$(dirname $script_path)
echo "Checking sierrachart for updates..."
relative_path=$(curl -s https://www.sierrachart.com/index.php?page=doc/SCZipInstallerList.php | htmlq -a href a | grep ZipFiles | head -n 1)
url="https://www.sierrachart.com$relative_path"
name=$(basename $url)
upstream_version=$(echo $name | sed 's/^SierraChart\([[:digit:]]\+\)\.zip/\1/')
pkg_version=$(grep "version =" $repo_path/pkgs/sierrachart/default.nix | sed -e 's/#:version://' -e 's/version = \"\([[:digit:]]\+\)\";/\1/')

if [ "$upstream_version" -eq "$pkg_version" ]
then
  echo "The sierrachart package is already up-to-date".
else
  echo "Found an update for the sierrachart package."
  echo "Attempting to update from $pkg_version to $upstream_version ..."
  src=$(mktemp)
  updated_nix_src=$(mktemp)
  curl $url > $src
  sha256=$(nix-prefetch-url --name $name --type sha256 "file://$src")
  awk -f $script_path/update-sierrachart.awk -v hash="$sha256" -v version="$upstream_version" $repo_path/pkgs/sierrachart/default.nix > $updated_nix_src
  cat $updated_nix_src > $repo_path/pkgs/sierrachart/default.nix
  rm $src
  rm $updated_nix_src
  echo "Update complete."
fi

