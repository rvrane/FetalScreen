#!/bin/bash

# Source directory containing the .plots folders
SOURCE_DIR="/media/user/36d81ee3-f383-4bc4-b619-20abd785be33/DATA/5.10.2025_ZMNY/wisecondorx_output"
# Output directory for the plots
OUTPUT_DIR="${SOURCE_DIR}/all_genome_plots"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Starting to copy genome_wide.png files..."

# Find and copy all genome_wide.png files
find "$SOURCE_DIR" -type f -name "*genome_wide.png" | while read -r file; do
    # Get just the filename
    filename=$(basename "$file")
    echo "Copying: $filename"
    cp -v "$file" "${OUTPUT_DIR}/"
done

echo -e "\nCopy complete!"
echo "Copied $(ls -1 "$OUTPUT_DIR" | wc -l) files to: $OUTPUT_DIR"
