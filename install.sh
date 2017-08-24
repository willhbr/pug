#!/bin/bash
set -e

install_from_repo() {
  echo "Installing pug"
  if [ "$1" != -l ]; then
    echo 'Password may be required to copy pug to /usr/local/bin/pug'
    if ! sudo cp src/pug.sh /usr/local/bin/pug; then
      echo 'Could not copy to /usr/local/bin (Did sudo work?)'
      echo 'To use pug copy this file into your PATH as "pug":'
      realpath src/pug.sh
    fi
  fi

  echo 'Copying installers to ~/.pug/installers'
  mkdir -p ~/.pug/installers
  cp src/installers/* ~/.pug/installers
}


if [ -e ./src/pug.sh ]; then
  echo 'pug.sh exists, installing locally'
  install_from_repo "$@"
else
  echo 'pug.sh does not exist, cloning to /tmp'
  cd /tmp
  git clone 'https://github.com/javanut13/pug.git'
  cd pug
  install_from_repo
fi
