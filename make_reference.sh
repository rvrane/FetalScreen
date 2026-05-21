#!/bin/bash

# Create reference for NIPT analysis
# List all NPZ files to include in the reference
NPZ_FILES=(
    /media/user/36d81ee3-f383-4bc4-b619-20abd785be33/DATA/08.08.25_wcX_WGS/npz_files/*.npz
)

# Check if any NPZ files were found
if [ ${#NPZ_FILES[@]} -eq 0 ]; then
    echo "Error: No NPZ files found in the specified directory"
    exit 1
fi

# Create output directory if it doesn't exist
OUTPUT_DIR="/media/user/36d81ee3-f383-4bc4-b619-20abd785be33/DATA/08.08.25_wcX_WGS/NIPT_reference"
mkdir -p "$OUTPUT_DIR"

# Run the WisecondorX newref command with all NPZ files
WisecondorX newref "${NPZ_FILES[@]}" \
    "$OUTPUT_DIR/nipt_reference.npz" \
    --nipt \
    --binsize 100000 \
    --refsize 669
