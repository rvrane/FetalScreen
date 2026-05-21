#!/bin/bash

# Create output directory
mkdir -p wisecondorx_output

# Base directory with proper escaping for spaces
BASE_DIR="/media/user/36d81ee3-f383-4bc4-b619-20abd785be33/DATA/22.04.2025_NIPT/New folder/trimmed_results/output"
REFERENCE="/media/user/36d81ee3-f383-4bc4-b619-20abd785be33/DATA/08.08.25_wcX_WGS/NIPT_reference/nipt_reference.npz"

# Run analysis on test samples
for npz in "${BASE_DIR}/npz_files/"*.npz; do
    sample_name=$(basename "$npz" .npz)
    
    echo "Processing sample: $sample_name"
    
    WisecondorX predict "$npz" \
        "$REFERENCE" \
        "${BASE_DIR}/wisecondorx_output/${sample_name}" \
        --plot \
        --bed \
        --zscore 3.5
done
