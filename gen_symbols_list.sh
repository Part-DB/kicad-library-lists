#!/bin/bash

# Path setup
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
clone_path="$SCRIPTPATH/symbols"
output_path="$SCRIPTPATH/symbols.txt"

# 1. Sync the library
if [ ! -d "$clone_path" ]; then
    echo "Cloning KiCad symbols..."
    git clone --depth 1 https://gitlab.com/kicad/libraries/kicad-symbols.git "$clone_path"
else 
    echo "Updating KiCad symbols..."
    git -C "$clone_path" pull -q
fi

# 2. Preparation
echo "# KiCad Symbol Index" > "$output_path"
echo "# Generated on $(date)" >> "$output_path"

# Count total directories for the progress indicator
total_libs=$(find "$clone_path" -type d -name "*.kicad_symdir" | wc -l)
current_lib=0

echo "Starting extraction of $total_libs libraries..."

# 3. Process .kicad_symdir folders
find "$clone_path" -type d -name "*.kicad_symdir" | while read -r dir; do
    ((current_lib++))
    
    # Extract Library name
    lib_name=$(basename "$dir" .kicad_symdir)
    
    # Calculate percentage
    percent=$((current_lib * 100 / total_libs))
    
    # Update progress line (\r moves cursor to start of line, -n prevents newline)
    printf "\r[%-50s] %d%% (%d/%d) %-30s" \
        "$(printf '#%.0s' $(seq 1 $((percent / 2))))" \
        "$percent" "$current_lib" "$total_libs" "$lib_name"

    # Process files inside
    find "$dir" -type f -name "*.kicad_sym" | while read -r sym_file; do
        name=$(grep -oP '(?<=\(symbol \")[^\"]+(?=\")' "$sym_file" | head -n 1)
        if [[ ! "$name" =~ _[0-9]+_[0-9]+$ ]] && [ ! -z "$name" ]; then
            echo "$lib_name:$name" >> "$output_path"
        fi
    done
done

# 4. Final Sort
echo -e "\nFinalizing list..."
sort -u -o "$output_path" "$output_path"

total_symbols=$(grep -v '^#' "$output_path" | wc -l)
echo "Done! Indexed $total_symbols symbols from $total_libs libraries."