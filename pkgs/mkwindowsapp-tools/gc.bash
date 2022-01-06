#! /usr/bin/bash

CACHE_DIR="$HOME/.cache/mkWindowsApp"

# API 0
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

# API 1
for layer in $(find $CACHE_DIR/ -maxdepth 1 -type d | tail -n +2)
do
  if [ -f "$layer/api" ]
  then
    if [ "$(echo $layer | grep incomplete)" = "" ]
    then
      filename="$(basename $layer)"
      size=$(du -h -s "$CACHE_DIR/$filename")
      temp_file=$(mktemp --suffix .mkwindowsapp-gc)

      for ref_path in $(cat $layer/refs)
      do
        if [ -e "$ref_path" ]
        then
          echo "$ref_path" >> "$temp_file"
        fi
      done

      if [ -s "$temp_file" ]
      then
        printf "keeping %s %s\n" "$size" "$filename"
        mv "$temp_file" "$layer/refs"
      else
        printf "deleting %s %s\n" "$size""$filename" 
        rm -fR "$layer"
        rm "$temp_file"
      fi
    fi
  fi
done
