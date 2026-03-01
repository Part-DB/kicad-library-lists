#!/bin/bash

# Setup paths
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
clone_path="$SCRIPTPATH/footprints"
output_path="$SCRIPTPATH/footprints.txt"

# 1. Sync the library
if [ ! -d "$clone_path" ]; then
    echo "Cloning KiCad footprints (this may take a moment)..."
    git clone --depth 1 https://gitlab.com/kicad/libraries/kicad-footprints.git "$clone_path"
else 
    echo "Updating KiCad footprints..."
    git -C "$clone_path" pull -q
fi

# 2. Preparation
{
    echo "# This file contains all footprints available in the offical KiCAD library"
    echo "# Generated on $(date)"
} > "$output_path"

# Count total files for progress calculation
echo "Counting footprints..."
total_files=$(find "$clone_path" -type f -name "*.kicad_mod" | wc -l)
current_count=0

echo "Processing $total_files footprints..."

# 3. Process with Progress Bar
# We use a while loop to update the UI, but keep the logic fast
find "$clone_path" -type f -name "*.kicad_mod" | while read -r file; do
    ((current_count++))
    
    # Process the path: remove base path, extensions, and format as Lib:Footprint
    # e.g., /path/Capacitor_THT.pretty/C_Disc_D3.0mm_W1.6mm_P2.50mm.kicad_mod 
    # becomes Capacitor_THT:C_Disc_D3.0mm_W1.6mm_P2.50mm
    entry=$(echo "$file" | sed "s|$clone_path/||; s|\.pretty/|:|; s|\.kicad_mod||")
    echo "$entry" >> "$output_path"

    # Update progress every 100 files (to avoid slowing down the script with UI updates)
    if (( current_count % 100 == 0 || current_count == total_files )); then
        percent=$((current_count * 100 / total_files))
        bar_size=$((percent / 2))
        printf "\r[%-50s] %d%% (%d/%d)" \
            "$(printf '#%.0s' $(seq 1 $bar_size))" \
            "$percent" "$current_count" "$total_files"
    fi
done

# 4. Final Alphabetical Sort
echo -e "\nSorting list..."
sort -o "$output_path" "$output_path"

echo "Done! Indexed $(grep -v '^#' "$output_path" | wc -l) footprints."