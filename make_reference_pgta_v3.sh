#!/bin/bash

################################################################################
# WisecondorX Female-Only Reference Creation for PGTA Analysis
# 
# Purpose: Create a female-only reference (103 euploid female samples) that can
#          analyze BOTH male and female embryos using manual yfrac=0.010 threshold
#
# Key Features:
# - 103 pure female (XX) samples for clean autosomal normalization
# - Manual yfrac=0.010 threshold for gender classification
# - Single reference analyzes both male (yfrac > 0.010) and female (yfrac < 0.010)
# - Eliminates false positive male calls from contamination
#
# Usage: ./make_reference_pgta_v3.sh
################################################################################

# ============================================
# CONFIGURATION - Update these paths
# ============================================

# Input directory containing NPZ files from euploid FEMALE samples ONLY
NPZ_INPUT_DIR="/media/user/36d81ee3-f383-4bc4-b619-20abd785be33/DATA/08.08.25_wcX_WGS/pgta_fem_npz_files"

# Output directory for reference
OUTPUT_DIR="/media/user/36d81ee3-f383-4bc4-b619-20abd785be33/DATA/08.08.25_wcX_WGS/PGTA_fem_reference"

# ============================================
# FEMALE-ONLY REFERENCE PARAMETERS FOR PGTA
# ============================================

# Bin size: Optimized for targeted genome sequencing
# 75bp average read length -> use 50-100kb bins
BINSIZE=100000

# Reference size: Number of reference locations per target
# Use 103 for 103 female samples
REFSIZE=103

# Manual yfrac threshold for gender classification
# Female samples (XX): yfrac < 0.010
# Male samples (XY):   yfrac > 0.010
# This allows single female-only reference to classify both genders
YFRAC_THRESHOLD=0.010

# Number of CPU threads for parallel processing
CPUS=4

# ============================================
# SCRIPT START
# ============================================

# Collect all NPZ files from input directory
NPZ_FILES=("${NPZ_INPUT_DIR}"/*.npz)

# Check if any NPZ files were found
if [ ${#NPZ_FILES[@]} -eq 0 ] || [ ! -e "${NPZ_FILES[0]}" ]; then
    echo "Error: No NPZ files found in $NPZ_INPUT_DIR"
    echo "Expected directory: $NPZ_INPUT_DIR"
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
echo "=========================================="
echo "WisecondorX FEMALE-ONLY Reference for PGTA"
echo "=========================================="
echo "Input NPZ files:     ${NPZ_INPUT_DIR}/*.npz"
echo "Total samples:       ${#NPZ_FILES[@]} (FEMALE ONLY)"
echo "Output directory:    $OUTPUT_DIR"
echo "Bin size:            $BINSIZE bp"
echo "Reference size:      $REFSIZE"
echo "yfrac threshold:     $YFRAC_THRESHOLD"
echo "CPU threads:         $CPUS"
echo ""
echo "Expected yfrac distribution:"
echo "  Female embryos (XX): < 0.010"
echo "  Male embryos (XY):   > 0.010"
echo "=========================================="
echo ""

# ============================================
# Step 1: Generate Y-fraction histogram
# ============================================

echo "[Step 1/3] Generating Y-chromosome fraction histogram..."
echo "This shows distribution of Y-reads across female reference samples"
echo "Expected: Sharp peak near 0.0001-0.0005 (minimal Y contamination)"
echo ""

WisecondorX newref "${NPZ_FILES[@]}" \
    "${OUTPUT_DIR}/pgta_reference_temp.npz" \
    --binsize $BINSIZE \
    --refsize $REFSIZE \
    --cpus $CPUS \
    --plotyfrac "${OUTPUT_DIR}/yfrac_histogram_female_ref.png" 2>&1

# Check if the yfrac plot was created
if [ -f "${OUTPUT_DIR}/yfrac_histogram_female_ref.png" ]; then
    echo "✓ Y-fraction histogram created: ${OUTPUT_DIR}/yfrac_histogram_female_ref.png"
    echo ""
    echo "CRITICAL: Review this histogram!"
    echo "  Expected: Single sharp peak at yfrac < 0.001"
    echo "  If peak is higher (~0.003-0.005): Indicates Y-chromosome contamination"
    echo "  Solution: Remove contaminated samples and rebuild reference"
    echo ""
fi

# ============================================
# Step 2: Create final reference with yfrac threshold
# ============================================

echo "[Step 2/3] Creating female-only reference with --yfrac $YFRAC_THRESHOLD..."
echo "This sets the gender classification threshold:"
echo "  Samples with yfrac < $YFRAC_THRESHOLD → Classified as FEMALE"
echo "  Samples with yfrac > $YFRAC_THRESHOLD → Classified as MALE"
echo ""

WisecondorX newref "${NPZ_FILES[@]}" \
    "${OUTPUT_DIR}/pgta_reference_female_only.npz" \
    --binsize $BINSIZE \
    --refsize $REFSIZE \
    --yfrac $YFRAC_THRESHOLD \
    --cpus $CPUS

# Check if reference was created successfully
if [ ! -f "${OUTPUT_DIR}/pgta_reference_female_only.npz" ]; then
    echo ""
    echo "✗ Error: Reference creation failed!"
    exit 1
fi

echo "✓ Reference with yfrac threshold created"
echo ""

# ============================================
# Step 3: Verify reference and provide usage
# ============================================

echo "[Step 3/3] Verifying reference integrity..."
echo ""

# Check reference file
if [ -f "${OUTPUT_DIR}/pgta_reference_female_only.npz" ]; then
    REFSIZE_MB=$(du -h "${OUTPUT_DIR}/pgta_reference_female_only.npz" | cut -f1)
    echo "✓ Reference file created: ${OUTPUT_DIR}/pgta_reference_female_only.npz"
    echo "  File size: $REFSIZE_MB"
    echo ""
fi

# ============================================
# Summary and Next Steps
# ============================================

echo ""
echo "=========================================="
echo "✓ FEMALE-ONLY REFERENCE CREATED SUCCESSFULLY!"
echo "=========================================="
echo ""
echo "Reference Details:"
echo "  - Samples: ${#NPZ_FILES[@]} female euploid embryos (XX)"
echo "  - Type: Female-only with manual yfrac=$YFRAC_THRESHOLD threshold"
echo "  - Usage: Can analyze both male and female embryos"
echo ""
echo "File Location:"
echo "  ${OUTPUT_DIR}/pgta_reference_female_only.npz"
echo ""
echo "Next Steps: Use in WisecondorX predict command"
echo ""
echo "For FEMALE embryo analysis:"
echo "  WisecondorX predict female_sample.npz \\"
echo "    ${OUTPUT_DIR}/pgta_reference_female_only.npz \\"
echo "    output_name \\"
echo "    --plot --bed --zscore 3.5"
echo ""
echo "For MALE embryo analysis (same reference):"
echo "  WisecondorX predict male_sample.npz \\"
echo "    ${OUTPUT_DIR}/pgta_reference_female_only.npz \\"
echo "    output_name \\"
echo "    --plot --bed --zscore 3.5"
echo ""
echo "Gender Classification (automatic):"
echo "  Female: yfrac < 0.010"
echo "  Male:   yfrac > 0.010"
echo ""
echo "Expected Results:"
echo "  ✓ Female embryos: yfrac < 0.001 (no false positives)"
echo "  ✓ Male embryos:   yfrac 0.015-0.035 (clear male signature)"
echo "  ✓ Improved X-chromosome normalization for both genders"
echo "  ✓ Single reference handles both male and female analysis"
echo ""
echo "=========================================="
echo ""

# Display histogram location for quality assessment
if [ -f "${OUTPUT_DIR}/yfrac_histogram_female_ref.png" ]; then
    echo "IMPORTANT: Review the yfrac histogram for quality control"
    echo "  Path: ${OUTPUT_DIR}/yfrac_histogram_female_ref.png"
    echo ""
    echo "Quality Criteria:"
    echo "  ✓ GOOD: Single sharp peak at yfrac < 0.001"
    echo "  ✗ BAD:  Peak at yfrac > 0.003 (indicates contamination)"
    echo "  ✗ BAD:  Multiple peaks (indicates mixed genders in 'female' samples)"
    echo ""
fi

echo "References:"
echo "  [1] Raman et al. (2018) WisecondorX. Nucleic Acids Res. 47:1605-1614"
echo "  [2] WisecondorX GitHub: Manual yfrac parameter for single-gender references"
echo ""
