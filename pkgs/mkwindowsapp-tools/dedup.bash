#! /usr/bin/bash

CACHE_DIR="$HOME/.cache/mkWindowsApp"
hashes=$(mktemp --suffix .mkwindowsapp-dedup)

echo "Generating hashes..."
for layer in $(find $CACHE_DIR/ -maxdepth 1 -type d | tail -n +2)
do
  find "$layer" -type f | xargs -I {} sha256sum {} | sed 's/  \//\:\//' >> "$hashes"
done

prev_hash=""
prev_path=""

echo "Deduplicating..."
for line in $(cat "$hashes" | sort)
do
  cur_hash=$(echo $line | cut -d ":" -f 1)  
  cur_path=$(echo $line | cut -d ":" -f 2)  

  if [ "$prev_hash" = "$cur_hash" ]
  then
    fname=$(basename "$cur_path")
    pushd $(dirname "$cur_path")
    mv "$fname" "$fname.old"
    ln  "$prev_path" "$fname"

    if [ ! -e "$fname" ]
    then
      echo "OOPS: Failed to hardlink $cur_path. Reverting..."
      mv "$fname.old" "$fname" 
    else
        rm -f "$fname.old"
    fi

    popd
  fi

  prev_hash="$cur_hash"
  prev_path="$cur_path"
done

rm "$hashes"
echo "Deduplication finished."
