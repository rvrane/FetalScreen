#!/bin/bash


# Create output directory
mkdir -p /wisecondorx_output

# Run analysis on test samples
for npz in /media/user/36d81ee3-f383-4bc4-b619-20abd785be33/DATA/04.09.2025/CordonPool64/trimmed_results/merged_results/ichor_Samples/npz_files/*.npz; do
    sample_name=$(basename $npz .npz)
    
    WisecondorX predict $npz \
        /media/user/36d81ee3-f383-4bc4-b619-20abd785be33/DATA/08.08.25_wcX_WGS/NIPT_reference/nipt_reference.npz \
        /media/user/36d81ee3-f383-4bc4-b619-20abd785be33/DATA/04.09.2025/CordonPool64/trimmed_results/merged_results/ichor_Samples/$sample_name \
        --plot \
        --bed \
        --zscore 5
done
