#! /usr/bin/bash

CACHE_DIR="$HOME/.cache/mkWindowsApp"
for file in $(ls $CACHE_DIR/*.referrers)
do
  filename=$(basename -s .referrers $file)
  size=$(du -h -s "$CACHE_DIR/$filename")
  temp_file=$(mktemp --suffix .mkwindowsapp-gc)

  for ref_path in $(cat $file)
  do
    if [ -e "$ref_path" ]
    then
      echo "$ref_path" >> "$temp_file"
    fi
  done

  if [ -s "$temp_file" ]
  then
    printf "keeping %s %s\n" "$size" "$filename"
    mv "$temp_file" "$file"
  else
    printf "deleting %s %s\n" "$size""$filename" 
    rm -fR "$CACHE_DIR/$filename"
    rm "$file"
    rm "$temp_file"
  fi
done
