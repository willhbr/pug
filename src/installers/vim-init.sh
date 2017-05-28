#!/bin/bash

if ! grep -q "Pug installed" "$HOME/.vimrc"; then
  echo "Installing pug vim into .vimrc"
  cat <<- EOF > $HOME/.vimrc
  " Pug installed"
  let __filepath = expand("~/$1/vim/$2")
  if filereadable(__filepath)
    execute 'source '.fnameescape(__filepath)
  endif
  EOF
fi

