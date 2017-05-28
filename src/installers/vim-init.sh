#!/bin/bash

if ! grep -q "Pug installed" "$HOME/.vimrc"; then
  echo "Installing pug vim into .vimrc"
  echo '" Pug installed' >> "$HOME/.vimrc"
  echo "source \"$1\"" >> "$HOME/.vimrc"
fi
