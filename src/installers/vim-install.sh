#!/bin/bash

source_dir="$1"
name="$2"
echo "set runtimepath^=$source_dir/$name" >> "$source_dir/pug"
