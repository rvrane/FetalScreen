#!/bin/bash

# Command to generate NPZ files from BAM files using WisecondorX
# This script assumes that the BAM files are in the current directory and that WisecondorX is installed and available in the system PATH.
# Usage: ./make_NPZ.sh

# Create output directory for NPZ files
mkdir -p npz_files

# Convert all BAM files to NPZ format
for bam_file in *.bam; do
    sample_name="${bam_file%.bam}"
    echo "Processing $bam_file..."
    WisecondorX convert "$bam_file" "npz_files/${sample_name}.npz" --binsize 100000
done

echo "Conversion complete. NPZ files are saved in the npz_files/ directory."
