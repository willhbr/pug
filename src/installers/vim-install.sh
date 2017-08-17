#!/bin/bash

name="${1?}"
if ! grep -q "/$name\$" "$SOURCE_DIR/vim/pug"; then
  echo "set runtimepath^=$SOURCE_DIR/vim/$name" >> "$SOURCE_DIR/vim/pug"
  echo 'Added to pug file'
else
  echo "Already installed to pug file"
fi

cat <<-EOF

Make sure this is added to your .vimrc file:

let __filepath = expand("$SOURCE_DIR/vim/pug")
if filereadable(__filepath)
  execute 'source '.fnameescape(__filepath)
endif
EOF
