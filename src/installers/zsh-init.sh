#!/bin/bash

if ! grep -q "Pug installed" "$HOME/.zshrc"; then
  echo "Installing pug zsh into .zshrc"
  echo "# Pug installed" >> "$HOME/.zshrc"
  echo "source '$1/zsh/$2'" >> "$HOME/.zshrc"
fi
