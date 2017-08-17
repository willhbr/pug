#!/bin/bash

source_dir="${1?}"
name="${2?}"
echo "set runtimepath^=$SOURCE_DIR/vim/$name" >> "$source_dir/pug"

cat <<-EOF

Make sure this is added to your .vimrc file:

let __filepath = expand("$SOURCE_DIR/vim/pug")
if filereadable(__filepath)
  execute 'source '.fnameescape(__filepath)
endif
EOF
