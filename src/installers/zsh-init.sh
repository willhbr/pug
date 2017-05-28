#!/bin/bash

echo "Installing pug zsh into .zshrc"
echo "# Load pug bits" >> "$HOME/.zshrc"
echo "source \"$1\"" >> "$HOME/.zshrc"
