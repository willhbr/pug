#!/bin/bash

echo "Installing pug vim into .vimrc"
echo '" Load pug bits' >> "$HOME/.vimrc"
echo "source \"$1\"" >> "$HOME/.vimrc"
