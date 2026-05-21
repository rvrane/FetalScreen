#!/usr/bin/env python3
import os
import pandas as pd
from pathlib import Path

def convert_statistics_to_csv(directory):
    """
    Find all files ending with _statistics.txt in the directory and convert them to CSV format.
    Each CSV will be named after the original file.
    """
    base_dir = Path(directory)
    output_dir = base_dir / "statistics_csv"
    output_dir.mkdir(exist_ok=True)
    
    # Find all files ending with _statistics.txt
    stats_files = list(base_dir.rglob("*_statistics.txt"))
    
    if not stats_files:
        print(f"No statistics files found in {base_dir}")
        return
    
    print(f"Found {len(stats_files)} statistics files to process...")
    
    for stats_file in stats_files:
        try:
            # Read the statistics file
            with open(stats_file, 'r') as f:
                lines = [line.strip().split('\t') for line in f if line.strip()]
            
            # Create a DataFrame and save as CSV
            if len(lines) > 1:
                df = pd.DataFrame(lines[1:], columns=lines[0])
                # Create output filename by replacing .txt with .csv
                output_file = output_dir / f"{stats_file.stem}.csv"
                df.to_csv(output_file, index=False)
                print(f"Created: {output_file}")
        
        except Exception as e:
            print(f"Error processing {stats_file}: {str(e)}")
    
    print("\nConversion complete!")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) != 2:
        print("Usage: python wx_stats.py <directory_path>")
        sys.exit(1)
    
    directory = sys.argv[1]
    if not os.path.isdir(directory):
        print(f"Error: Directory not found: {directory}")
        sys.exit(1)
    
    convert_statistics_to_csv(directory)