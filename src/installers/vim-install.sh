#!/bin/bash

# Args should be URL, main file
if [ -z "$1" ]; then
  echo "No url given"
  exit 1
fi
url="$1"
name="$2"
source_dir="$3"
install_dir="$source_dir/$name"

echo "installing $name from $url"

if git clone "$url" "$install_dir"; then
  echo "set runtimepath^=$install_dir" >> "$source_dir/pug"
else
  echo "Failed to download $url"
  echo "Not installed"
  exit 2
fi
