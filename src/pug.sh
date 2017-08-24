#!/bin/bash

set -e
shopt -s nullglob

export PUG_DIR="$HOME/.pug"
export INSTALLERS_DIR="$PUG_DIR/installers"
export SOURCE_DIR="$PUG_DIR/source"
export PUG_VERSION=0.1.1

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
  echo -n 'Remove sources from pug? [y/n] '
  read confirm
  if [ "$confirm" = "y" ]; then
    local flags=-r
    if [ "$1" = '-f' ]; then
      flags=-rf
    fi
    rm "$flags" "$SOURCE_DIR"
    echo "Removed"
  fi
}

defhelp version 'Show the pug version'
cmd.version() {
  echo "Pug version $PUG_VERSION"
}

defhelp installers 'List available installers'
cmd.installers() {
  local type_name
  for installer in "$INSTALLERS_DIR/"*-install; do
    type_name="${installer##*/}"
    type_name="${type_name%-install}"
    echo "$1$type_name"
  done
}

defhelp help 'Show this help'
cmd.help() {
  echo 'Commands:'
  for str in "${help_text[@]}"; do
    echo "$str"
  done
  echo 'Installers:'
  cmd.installers '   '
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
  if [ -e "$INSTALLERS_DIR/${type}-install" ]; then
    local url="$2"
    local name="$3"
    if [ -z "$name" ]; then
      name="${url##*/}"
      name="${name%.git}"
    fi
    if clone_or_pull "$url" "$name" "$SOURCE_DIR/$type"; then
      "$INSTALLERS_DIR/${type}-install" install "$name"
    else
      echo "Failed to install $name"
    fi
  else
    echo "Installer for $type doesn't exist"
    echo "Expected to find in $INSTALLERS_DIR/${type}-install"
    return 1
  fi
}

defhelp remove 'Remove a dependency'
cmd.remove() {
  echo "Not implemented"
  exit 1
}

defhelp update 'Pull all plugins and re-write pugfiles'
cmd.update() {
  for pugfile in "$SOURCE_DIR"/*/pug; do
    echo -n '' > "$pugfile"
  done
  local count=0
  for module in "$SOURCE_DIR"/*/*; do
    if [ -d "$module" ]; then
      local name="${module##*/}"
      echo "Updating $name"
      git -C "$module" pull
      local type
      type="$(dirname "$module")"
      type="${type##*/}"
      if ! "$INSTALLERS_DIR/${type}-install" install "$name"; then
        echo "ERROR: Installing $name failed"
      fi
      (( count+=1 ))
      echo
      echo '-------------------------------------'
      echo
    fi
  done
  echo "$count modules updated"
}

defhelp list 'List installed modules'
cmd.list() {
  local count=0
  for module in "$SOURCE_DIR"/*/*; do
    if [ -d "$module" ]; then
      echo "${module##*/}"
      (( count+=1 ))
    fi
  done
  echo "$count modules installed"
}

defhelp upgrade 'Upgrade pug and installers'
cmd.upgrade() {
  echo 'Upgrading Pug...'
  dest="$(mktemp -d)"
  git clone 'https://github.com/javanut13/pug.git' "$dest"
  cd "$dest"
  if [ "$1" != -l ]; then
    echo 'Password may be required to copy pug to /usr/local/bin/pug'
    if ! sudo cp src/pug.sh /usr/local/bin/pug; then
      echo 'Could not copy to /usr/local/bin (Did sudo work?)'
      echo 'To use pug copy this file into your PATH as "pug":'
      echo "$(realpath src/pug.sh)"
    fi
  fi

  echo 'Copying installers to ~/.pug/installers'
  mkdir -p ~/.pug/installers
  cp src/installers/* ~/.pug/installers
}

dependency() {
  local installer="$1"
  local url
  case "$2" in
    from:)
      url="$3" ;;
    github:)
      url="https://github.com/$3.git" ;;
    gitlab:)
      url="https://gitlab.com/$3.git" ;;
    *)
      echo "Unknown arg $2"
      return 1 ;;
  esac
  cmd.get "$installer" "$url"
}

installer_type() {
  local type_name
  type_name="${1##*/}"
  type_name="${type_name%-install}"
  echo "$type_name"
}

defhelp load 'Used for loading config files'
cmd.load() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "$file does not exist or is not a file"
    return 1
  fi

  local type_name
  for installer in "$INSTALLERS_DIR/"*-install; do
    type_name="${installer##*/}"
    type_name="${type_name%-install}"
    eval "function ${type_name} { dependency '$type_name' \"\$@\"; }"
  done

  source "$file"
}

after_install() {}

defhelp installer 'Used for loading installers'
cmd.installer() {
  local script="$1"
  shift 2
  source "$script"
  local type_name
  type_name="$(installer_type "$script")"
  local name="$1"
  if ! is_already_installed "$name"; then
    echo -n 'Installing... '
    echo
    if pugfile_text "$name" >> "$SOURCE_DIR/$type_name/pug"; then
      after_install new "$name"
      echo 'Done.'
    else
      echo 'Failed.'
    fi
  else
    after_install already "$name"
  fi
  if ! grep -q '/vim/pug' "$HOME/.vimrc"; then
    source_help_text
  fi
}

cmd="$1"
if shift && type "cmd.$cmd" > /dev/null 2>&1; then
  init
  "cmd.$cmd" "$@"
else
  echo "Unknown command $cmd"
  cmd.help
fi
