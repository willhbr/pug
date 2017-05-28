#!/bin/bash

set -e
shopt -s nullglob

PUG_DIR='~/.pug'
INSTALLERS_DIR="$PUG_DIR/installers"
SOURCE_DIR="$PUG_DIR/source"

# Initialize expected file locations
initialize() {
  mkdir -p "$PUG_DIR"
  mkdir -p "$INSTALLERS_DIR"
  mkdir -p "$SOURCE_DIR"

  for init in "$INSTALLERS_DIR"/*-init.sh; do
    "$init" "$SOURCE_DIR" "pug"
  done
}

# Delete modules
wipeout() {
  echo "Remove sources from pug? [y/n]"
  read confirm
  if [ "$confirm" = "y" ]; then
    rm -r "$SOURCE_DIR"
    echo "Removed"
  fi
}

# Print usage information
print_usage() {
  echo "That's not how you use this"
}

# Update a module
clone_or_pull() {
  local url="$1"
  local name="$2"
  local source_dir="$3"

  if [ -d "$source_dir/$name/.git" ]; then
    git -C "$source_dir/$name" pull
  else
    git clone "$url" "$source_dir/$name"
  fi
}

use() {
  local type="${1?}"
  if [ -e "$INSTALLERS_DIR/${type}-install.sh" ]; then
    local url="$2"
    local name="$3"
    if [ -z "$main_file" ]; then
      name="${url##*/}"
      name="${name%.git}"
    fi
    if clone_or_pull "$url" "$name" "$SOURCE_DIR/$type"; then
      "$INSTALLERS_DIR/${type}-install.sh" "$SOURCE_DIR/$type" "$name"
    else
      echo "Failed to install $main_file"
    fi
  else
    echo "Installer for $type doesn't exist"
    return 1
  fi
}

remove() {
  echo "Not implemented"
  exit 1
}

update() {
  for pugfile in "$SOURCE_DIR"/*/pug; do
    echo '' > "$pugfile"
  done
  for module in "$SOURCE_DIR"/*/*; do
    if [ -d "$module" ]; then
      local name="${module##*/}"
      echo "Updating $name"
      git -C "$module" pull
      local type="$(dirname "$module")"
      type="${type##*/}"
      "$INSTALLERS_DIR/${type}-install.sh" "$SOURCE_DIR/$type" "$name"
    fi
  done
}

list() {
  for module in "$SOURCE_DIR"/*/*; do
    if [ -d "$module" ]; then
      echo "${module##*/}"
    fi
  done
}

if [ -z "$1" ]; then
  print_usage
  exit 1
fi

case "$1" in
  use)
    use "$2" "$3" "$4"
    ;;
  update)
    update
    ;;
  remove)
    remove "$2"
    ;;
  wipe)
    wipeout
    ;;
  init)
    initialize
    ;;
  list)
    list
    ;;
  *)
    echo "Unknown command $1"
    print_usage
    exit 2
esac
