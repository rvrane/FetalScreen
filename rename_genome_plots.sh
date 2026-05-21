#!/bin/bash

# Directory containing the .plots folders
BASE_DIR="/media/user/36d81ee3-f383-4bc4-b619-20abd785be33/DATA/5.10.2025_ZMNY/wisecondorx_output"

# Find all .plots directories and process them
find "$BASE_DIR" -type d -name "*.plots" | while read -r plot_dir; do
    # Extract the sample ID (remove the _sorted.plots part)
    sample_id=$(basename "$plot_dir" | sed 's/_sorted.plots$//')
    
    # Define the source and destination paths
    src_file="${plot_dir}/genome_wide.png"
    dest_file="${plot_dir}/${sample_id}_genome_wide.png"
    
    # Check if the source file exists and is a regular file
    if [ -f "$src_file" ]; then
        echo "Renaming: $src_file to $dest_file"
        mv "$src_file" "$dest_file"
    else
        echo "Warning: $src_file not found" >&2
    fi
done

echo "All genome_wide.png files have been renamed with their sample IDs."
