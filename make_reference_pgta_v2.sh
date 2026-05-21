#!/bin/bash

# Create reference for PGTA (Preimplantation Genetic Testing for Aneuploidy) analysis
# This script creates a WisecondorX reference from euploid embryo samples
# Parameters optimized for targeted genome sequencing (75bp reads)
# Usage: ./make_reference_pgta.sh

# ============================================
# CONFIGURATION - Update these paths
# ============================================

# Input directory containing NPZ files from euploid PGTA samples
NPZ_INPUT_DIR="/media/user/36d81ee3-f383-4bc4-b619-20abd785be33/DATA/08.08.25_wcX_WGS/pgta_npz_files"

# Output directory for reference
OUTPUT_DIR="/media/user/36d81ee3-f383-4bc4-b619-20abd785be33/DATA/08.08.25_wcX_WGS/PGTA_reference"

# ============================================
# REFERENCE PARAMETERS FOR PGTA
# ============================================

# Bin size: Adjusted for targeted genome
# 75bp average read length -> use 50-100kb bins
# Larger bin sizes reduce noise in targeted sequencing
BINSIZE=100000

# Reference size: Amount of reference locations per target
# Default: 300 (appropriate for 273 samples)
REFSIZE=225

# Number of CPU threads
CPUS=4

# ============================================
# SCRIPT START
# ============================================

# Collect all NPZ files from input directory
NPZ_FILES=("${NPZ_INPUT_DIR}"/*.npz)

# Check if any NPZ files were found
if [ ${#NPZ_FILES[@]} -eq 0 ] || [ ! -e "${NPZ_FILES[0]}" ]; then
    echo "Error: No NPZ files found in $NPZ_INPUT_DIR"
    exit 1
fi

echo "Found ${#NPZ_FILES[@]} NPZ files for reference creation"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

if [ ! -w "$OUTPUT_DIR" ]; then
    echo "Error: Output directory is not writable: $OUTPUT_DIR"
    exit 1
fi

echo ""
echo "========================================="
echo "WisecondorX Reference Creation for PGTA"
echo "========================================="
echo "Input NPZ files: ${NPZ_INPUT_DIR}/*.npz"
echo "Total samples: ${#NPZ_FILES[@]}"
echo "Output directory: $OUTPUT_DIR"
echo "Bin size: $BINSIZE bp"
echo "Reference size: $REFSIZE"
echo "CPU threads: $CPUS"
echo "========================================="
echo ""

# Step 1: Generate Y-fraction histogram for quality control
echo "[Step 1/2] Generating Y-chromosome fraction histogram..."
echo "This helps identify potential contamination or gender classification issues"
echo ""

WisecondorX newref "${NPZ_FILES[@]}" \
    "${OUTPUT_DIR}/pgta_reference_temp.npz" \
    --binsize $BINSIZE \
    --refsize $REFSIZE \
    --cpus $CPUS \
    --plotyfrac "${OUTPUT_DIR}/yfrac_histogram.png" 2>&1

# Check if the yfrac plot was created
if [ -f "${OUTPUT_DIR}/yfrac_histogram.png" ]; then
    echo "✓ Y-fraction histogram created: ${OUTPUT_DIR}/yfrac_histogram.png"
    echo "  Review this to check for gender classification accuracy"
    echo "  For pure female embryo reference, expect yfrac near 0"
    echo ""
fi

# Step 2: Create final reference
echo "[Step 2/2] Creating WisecondorX reference..."
echo ""

WisecondorX newref "${NPZ_FILES[@]}" \
    "${OUTPUT_DIR}/pgta_reference.npz" \
    --binsize $BINSIZE \
    --refsize $REFSIZE \
    --cpus $CPUS

# Check if reference was created successfully
if [ -f "${OUTPUT_DIR}/pgta_reference.npz" ]; then
    echo ""
    echo "========================================="
    echo "✓ Reference creation successful!"
    echo "========================================="
    echo ""
    echo "Reference file: ${OUTPUT_DIR}/pgta_reference.npz"
    echo "File size: $(du -h ${OUTPUT_DIR}/pgta_reference.npz | cut -f1)"
    echo ""
    echo "Next steps:"
    echo "1. Review yfrac histogram for gender classification accuracy"
    echo "2. Use this reference in WisecondorX predict command:"
    echo ""
    echo "   WisecondorX predict sample.npz \\"
    echo "     ${OUTPUT_DIR}/pgta_reference.npz \\"
    echo "     output_name \\"
    echo "     --zscore 3.3 \\"
    echo "     --plot --bed"
    echo ""
    echo "========================================="
else
    echo "✗ Error: Reference creation failed!"
    exit 1
fi
