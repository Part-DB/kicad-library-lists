#!/bin/bash

# Retrieve the script path
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# Define the source and destination paths
clone_path="$SCRIPTPATH/footprints"
output_path="$SCRIPTPATH/footprint_list.txt"

# Clone the latest KiCAD footprints from repository if not already present
if [ ! -d "$clone_path" ]; then
    git clone --depth 1 https://gitlab.com/kicad/libraries/kicad-footprints.git "$clone_path"
else 
    cd "$clone_path"
    git pull
    cd "$SCRIPTPATH"
fi

# Generate the text file with all footprints, we only want the path relative to the clone path
# Also we want to remove the .kicad_mod and .pretty extensions
# And replace the slash with a : to follow the KiCad convention
find "$clone_path" -type f -name "*.kicad_mod" | sed "s|$clone_path/||" | sed "s|.kicad_mod||" | sed "s|.pretty||" | sed "s|/|:|" > "$output_path"

echo "Found $(wc -l < "$output_path") footprints"