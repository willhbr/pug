#!/bin/bash

set -e
shopt -s nullglob

export PUG_DIR="$HOME/.pug"
export INSTALLERS_DIR="$PUG_DIR/installers"
export SOURCE_DIR="$PUG_DIR/source"

help_text=()

defhelp() {
  local command="${1?}"
  local text="${2?}"
  local help_str
  help_str="$(printf '   %-18s %s' "$command" "$text")"
  help_text+=("$help_str")
}

init() {
  mkdir -p "$PUG_DIR"
  mkdir -p "$INSTALLERS_DIR"
  mkdir -p "$SOURCE_DIR"
}

defhelp wipe 'Delete everything'
cmd.wipe() {
  echo "Remove sources from pug? [y/n]"
  read confirm
  if [ "$confirm" = "y" ]; then
    rm -r "$SOURCE_DIR"
    echo "Removed"
  fi
}


defhelp help 'Show this help'
cmd.help() {
  for str in "${help_text[@]}"; do
    echo "$str"
  done
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

defhelp get 'Clone a dependency'
cmd.get() {
  local type="${1?}"
  if [ -e "$INSTALLERS_DIR/${type}-install.sh" ]; then
    local url="$2"
    local name="$3"
    if [ -z "$main_file" ]; then
      name="${url##*/}"
      name="${name%.git}"
    fi
    if clone_or_pull "$url" "$name" "$SOURCE_DIR/$type"; then
      "$INSTALLERS_DIR/${type}-install.sh" "$name"
    else
      echo "Failed to install $main_file"
    fi
  else
    echo "Installer for $type doesn't exist"
    echo "Expected to find in "$INSTALLERS_DIR/${type}-install.sh
    return 1
  fi
}

defhelp remove 'Remove a dependency'
cmd.remove() {
  echo "Not implemented"
  exit 1
}

defhelp update 'Rewrite all pug source files from whatever is cloned'
cmd.update() {
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

cmd.list() {
  for module in "$SOURCE_DIR"/*/*; do
    if [ -d "$module" ]; then
      echo "${module##*/}"
    fi
  done
}

cmd="$1"
if shift && type "cmd.$cmd" > /dev/null 2>&1; then
  init
  "cmd.$cmd" "$@"
else
  echo "Unknown command $cmd"
  cmd.help
fi
