#!/bin/bash

name="$2"
echo "source '$SOURCE_DIR/zsh/$name/$name.zsh'" >> "$source_dir/pug"

cat<<-EOF

Make sure this is in your .zshrc file:

source '$SOURCE_DIR/zsh/pug'

EOF
