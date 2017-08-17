#!/bin/bash

name="${1?}"
if ! grep -q "/$name.zsh\$" "$SOURCE_DIR/zsh/pug"; then
  echo "source '$SOURCE_DIR/zsh/$name/$name.zsh'" >> "$SOURCE_DIR/zsh/pug"
  echo 'Added to pug file'
else
  echo "Already installed to pug file"
fi

cat<<-EOF

Make sure this is in your .zshrc file:

source '$SOURCE_DIR/zsh/pug'

EOF
