# FetalScreen

> **WisecondorX-based NIPT pipeline** for non-invasive prenatal testing (NIPT), fetal copy number prediction, and aneuploidy screening using cfDNA from maternal plasma.

![Language](https://img.shields.io/badge/language-Python%20%7C%20Shell-blue)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20HPC-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Overview

FetalScreen is a comprehensive bioinformatics pipeline for **non-invasive prenatal testing (NIPT)** using cell-free fetal DNA (cffDNA) from maternal plasma. Built around the **WisecondorX** framework, the pipeline converts aligned BAM files to NPZ format, constructs panel-of-normals (PoN) references, and predicts chromosomal copy number aberrations (CNAs) including common aneuploidies (T21, T18, T13, monosomy X).

**Dual-purpose pipeline:**
- **NIPT mode** — Fetal aneuploidy detection from cfDNA (plasma)
- **PGT-A mode** — Preimplantation genetic testing aneuploidy screening from trophectoderm biopsies

---

## Repository Structure

```
FetalScreen/
├── make_NPZ.sh                    # Convert BAM files to WisecondorX NPZ format
├── make_reference.sh              # Build WisecondorX PoN reference (NIPT)
├── make_reference_pgta.sh         # Build PGT-A PoN reference (v1)
├── make_reference_pgta_v2.sh      # Build PGT-A PoN reference (v2)
├── make_reference_pgta_v3.sh      # Build PGT-A PoN reference (v3, production)
├── predict_CNV_v1.sh              # Run WisecondorX CNV prediction (v1)
├── predict_CNV_v2.sh              # Run WisecondorX CNV prediction (v2, improved)
├── predict_PGTA.sh                # Run WisecondorX PGT-A aneuploidy prediction
├── copy_genome_plots.sh           # Copy output genome plots to report directory
├── rename_genome_plots.sh         # Rename genome plot files for reporting
├── wx_stats.py                    # WisecondorX output statistics parser
├── pgta_control_list.txt          # List of PGT-A control samples for PoN
├── requirements.txt               # Python dependencies
├── PoN_reference.md               # Panel-of-normals construction documentation
└── .gitignore
```

---

## Pipeline Workflow

### NIPT Mode
```
BAM Files (cfDNA, maternal plasma)
            │
            ▼
  1. BAM to NPZ Conversion      (make_NPZ.sh)
     └─ WisecondorX convert: creates binned coverage NPZ files
            │
            ▼
  2. Build PoN Reference        (make_reference.sh)
     └─ WisecondorX newref: trains reference from euploid controls
            │
            ▼
  3. CNV Prediction             (predict_CNV_v2.sh)
     └─ WisecondorX predict: segment & call aneuploidies
     └─ Outputs: aberrations.bed, genome plots, statistics
            │
            ▼
  4. Statistics Parsing         (wx_stats.py)
     └─ Extracts QC metrics and fetal fraction estimates
            │
            ▼
    NIPT Report (aberrations.bed + genome plots)
```

### PGT-A Mode
```
BAM Files (TE biopsy, WGA amplified)
            │
            ▼
  1. BAM to NPZ                 (make_NPZ.sh)
  2. Build PGT-A Reference      (make_reference_pgta_v3.sh)
  3. Predict Aneuploidy         (predict_PGTA.sh)
  4. Rename & Organize Plots    (rename_genome_plots.sh)
```

---

## Requirements

| Tool | Version | Purpose |
|------|---------|-------- |
| WisecondorX | ≥ 1.2.0 | Core CNV/aneuploidy calling |
| SAMtools | ≥ 1.15 | BAM file processing |
| Python | ≥ 3.7 | Statistics parsing |
| Bash | ≥ 4.0 | Pipeline scripting |

**Python dependencies:**
```bash
pip install -r requirements.txt
```

---

## Installation

```bash
# Clone the repository
git clone https://github.com/rvrane/FetalScreen.git
cd FetalScreen
chmod +x *.sh

# Install WisecondorX
conda install -c bioconda wisecondorx
# or
pip install wisecondorx
```

---

## Usage

### Step 1: Convert BAM files to NPZ
```bash
bash make_NPZ.sh /path/to/bam_directory/ /path/to/npz_output/
```

### Step 2: Build PoN reference (NIPT)
```bash
bash make_reference.sh \
  --npz_dir /path/to/euploid_npz/ \
  --output /path/to/nipt_reference.npz
```

### Step 3: Predict CNVs / aneuploidies
```bash
# NIPT mode
bash predict_CNV_v2.sh \
  --sample_npz /path/to/sample.npz \
  --reference /path/to/nipt_reference.npz \
  --output_dir /path/to/results/

# PGT-A mode
bash predict_PGTA.sh \
  --sample_npz /path/to/sample.npz \
  --reference /path/to/pgta_reference.npz \
  --output_dir /path/to/results/
```

### Step 4: Parse statistics
```bash
python wx_stats.py --results_dir /path/to/results/
```

---

## Output

| File | Description |
|------|-------------|
| `*.npz` | WisecondorX binned coverage file |
| `*_aberrations.bed` | Called chromosomal aberrations |
| `*_genome.png` | Genome-wide CNV plot |
| `*_statistics.json` | QC metrics including fetal fraction |
| `wx_stats_summary.tsv` | Aggregated run statistics table |

---

## Panel-of-Normals (PoN)

See [PoN_reference.md](PoN_reference.md) for detailed instructions on:
- How to select euploid control samples for reference building
- Recommended minimum sample size (n ≥ 50 for NIPT; n ≥ 30 for PGT-A)
- QC criteria for reference inclusion

---

## References

1. Raman L, et al. WisecondorX: improved copy number detection for routine shallow whole-genome sequencing. *Nucleic Acids Research*. 2019;47(4):1605-1614. [DOI: 10.1093/nar/gky1263](https://doi.org/10.1093/nar/gky1263)

---

## Author

**Rugved Rane**  
Senior Bioinformatician | Reproductive Genetics & Clinical Genomics  
[GitHub](https://github.com/rvrane)

---

## License

MIT License — see [LICENSE](LICENSE) for details.
