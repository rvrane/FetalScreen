# WisecondorX Pipeline

A pipeline for processing NGS data using WisecondorX for copy number variation analysis.

## Overview

This repository contains scripts and documentation for processing NGS data with WisecondorX. The pipeline includes steps for converting BAM files to NPZ format and subsequent analysis.

## Prerequisites

- WisecondorX
- SAMtools
- Python 3.x
- Required Python packages (if any)

## Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd wisecondorx-pipeline
   ```

2. Make the scripts executable:
   ```bash
   chmod +x make_NPZ.sh
   ```

## Usage

### Convert BAM to NPZ format

```bash
./make_NPZ.sh
```

This will process all BAM files in the current directory and save NPZ files in the `npz_files/` directory.

## Directory Structure

- `make_NPZ.sh` - Main script for converting BAM to NPZ format
- `npz_files/` - Directory containing output NPZ files (created automatically)

## License

[Add your license here]

## Contact

[Your name] - [Your email]
Project Link: [GitHub repository URL]
