#!/bin/bash

preserve_structure=0
max_depth=""
input_dir=""
output_dir=""

if [ "$1" = "--max_depth" ]; then
    [ "$#" -ne 4 ] && exit 1
    max_depth=$2
    input_dir=$3
    output_dir=$4
    preserve_structure=1
else
    [ "$#" -ne 2 ] && exit 1
    input_dir=$1
    output_dir=$2
fi

[ ! -d "$input_dir" ] && exit 1
mkdir -p "$output_dir"
shopt -s nullglob #https://gist.github.com/shichao-an/9521450 #https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
process_item() {
    local src=$1
    local dest=$2
    local depth=$3

    if [ -f "$src" ]; then
        filename=$(basename "$src")
        name="${filename%.*}"
        ext="${filename##*.}"
        [ "$ext" = "$filename" ] && ext=""
        
        newname="$filename"
        counter=1
        while [ -e "$dest/$newname" ]; do
            [ -z "$ext" ] && newname="${name}${counter}" || newname="${name}${counter}.${ext}"
            ((counter++))
        done
        cp "$src" "$dest/$newname"
    elif [ -d "$src" ]; then
        if [ "$preserve_structure" -eq 1 ] && [ "$depth" -lt "$max_depth" ]; then
            new_dest="$dest/$(basename "$src")"
            mkdir -p "$new_dest"
            for item in "$src"/*; do
                [ -e "$item" ] && process_item "$item" "$new_dest" $((depth + 1))
            done
        else
            for item in "$src"/*; do
                [ -e "$item" ] && process_item "$item" "$dest" $((depth + 1))
            done
        fi
    fi
}
for item in "$input_dir"/*; do
    [ -e "$item" ] && process_item "$item" "$output_dir" 1
done