#!/bin/bash

# Retrieve the script path
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# Define the source and destination paths
clone_path="$SCRIPTPATH/symbols"
output_path="$SCRIPTPATH/symbol_list.txt"

# Clone the latest KiCAD footprints from repository if not already present
if [ ! -d "$clone_path" ]; then
    git clone --depth 1 https://gitlab.com/kicad/libraries/kicad-symbols.git "$clone_path"
else 
    cd "$clone_path"
    git pull
    cd "$SCRIPTPATH"
fi

# Empty the output file
> "$output_path"

# Iterate over all kicad_sym files and extract the symbol names
for file in $(find "$clone_path" -type f -name "*.kicad_sym"); do
    # Extract the symbol name from the file
    # This line give us something like: '(symbol "74LS574" ('
    symbols=$(grep -oP "\(symbol \"(\w+)\" \(" $file)
    
    # Now we just need to extract the part from the quotes for each line
    # This line give us something like: 74LS574
    symbols=$(echo "$symbols" | sed "s|(symbol \"||" | sed "s|\" (||")

    # Now prepend the filename to the symbol name
    # This line give us something like: 74xx:74LS574
    symbols=$(echo "$symbols" | sed "s|^|$file:|" | sed "s|$clone_path/||" | sed "s|.kicad_sym||" | sed "s|/|:|" )

    if [ ! -z "$symbols" ]; then
        echo "$symbols" >> "$output_path"
    fi
done

echo "Found $(wc -l < "$output_path") symbols"