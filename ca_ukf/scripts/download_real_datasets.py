#!/usr/bin/env python3
"""
Download Real-World Datasets for UKF Validation
- ETH Zurich EuRoC MAV Dataset (drone flight data)
- Formula 1 Telemetry via Fast-F1 API (racing vehicle data)
"""

import os
import sys
import subprocess
import zipfile
from pathlib import Path

# Configuration
BASE_DIR = Path(__file__).parent.parent
RAW_DATA_DIR = BASE_DIR / "test_data" / "real_world" / "raw"

# ETH Zurich EuRoC MAV Dataset URLs
EUROC_DATASETS = {
    "MH_01_easy": "http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_01_easy/MH_01_easy.zip",
    "MH_02_easy": "http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_02_easy/MH_02_easy.zip",
}

def create_directories():
    """Create necessary directory structure"""
    RAW_DATA_DIR.mkdir(parents=True, exist_ok=True)
    (RAW_DATA_DIR / "euroc").mkdir(exist_ok=True)
    (RAW_DATA_DIR / "f1").mkdir(exist_ok=True)
    print(f"Created directory structure at {RAW_DATA_DIR}")

def download_euroc_datasets():
    """Download ETH Zurich EuRoC MAV datasets"""
    print("\n" + "="*80)
    print("DOWNLOADING ETH ZURICH EUROC MAV DATASETS")
    print("="*80)

    for name, url in EUROC_DATASETS.items():
        output_zip = RAW_DATA_DIR / "euroc" / f"{name}.zip"
        output_dir = RAW_DATA_DIR / "euroc" / name

        if output_dir.exists():
            print(f"\n✓ {name} already downloaded, skipping...")
            continue

        print(f"\nDownloading {name}...")
        print(f"URL: {url}")
        print(f"Output: {output_zip}")

        # Download using wget (with retries, resume support)
        try:
            subprocess.run([
                "wget",
                "-c",  # Continue partial downloads
                "-t", "3",  # 3 retries
                "-O", str(output_zip),
                url
            ], check=True)

            print(f"Extracting {name}...")
            with zipfile.ZipFile(output_zip, 'r') as zip_ref:
                zip_ref.extractall(output_dir)

            print(f"✓ {name} downloaded and extracted successfully")

            # Remove zip file to save space
            output_zip.unlink()
            print(f"Removed zip file: {output_zip}")

        except subprocess.CalledProcessError as e:
            print(f"✗ Error downloading {name}: {e}")
            print(f"You can manually download from: {url}")
            continue
        except Exception as e:
            print(f"✗ Error processing {name}: {e}")
            continue

def download_f1_telemetry():
    """Download F1 telemetry data using Fast-F1 API"""
    print("\n" + "="*80)
    print("DOWNLOADING F1 TELEMETRY DATA")
    print("="*80)

    try:
        import fastf1
    except ImportError:
        print("\n✗ Fast-F1 library not found!")
        print("Install with: pip install fastf1")
        print("Skipping F1 data download...")
        return

    # Enable Fast-F1 cache
    cache_dir = RAW_DATA_DIR / "f1" / "cache"
    cache_dir.mkdir(exist_ok=True)
    fastf1.Cache.enable_cache(str(cache_dir))

    # Define F1 sessions to download
    sessions = [
        {"year": 2024, "gp": "Monaco", "session": "R", "name": "monaco_2024"},
        {"year": 2024, "gp": "Silverstone", "session": "R", "name": "silverstone_2024"},
    ]

    for session_info in sessions:
        session_name = session_info["name"]
        output_file = RAW_DATA_DIR / "f1" / f"{session_name}.pkl"

        if output_file.exists():
            print(f"\n✓ {session_name} already downloaded, skipping...")
            continue

        print(f"\nDownloading {session_info['gp']} {session_info['year']} ({session_info['session']})...")

        try:
            # Load session
            session = fastf1.get_session(
                session_info["year"],
                session_info["gp"],
                session_info["session"]
            )
            session.load()

            # Save session data
            session.to_pickle(str(output_file))
            print(f"✓ {session_name} downloaded successfully")
            print(f"   Saved to: {output_file}")

        except Exception as e:
            print(f"✗ Error downloading {session_name}: {e}")
            print(f"Note: This may require internet connection and F1 data availability")
            continue

def generate_download_report():
    """Generate a summary report of downloaded datasets"""
    print("\n" + "="*80)
    print("DOWNLOAD SUMMARY")
    print("="*80)

    # Check EuRoC datasets
    print("\nETH Zurich EuRoC MAV Datasets:")
    for name in EUROC_DATASETS.keys():
        dataset_dir = RAW_DATA_DIR / "euroc" / name
        if dataset_dir.exists():
            print(f"  ✓ {name}: {dataset_dir}")
        else:
            print(f"  ✗ {name}: NOT DOWNLOADED")

    # Check F1 datasets
    print("\nF1 Telemetry Datasets:")
    f1_dir = RAW_DATA_DIR / "f1"
    if f1_dir.exists():
        pkl_files = list(f1_dir.glob("*.pkl"))
        if pkl_files:
            for pkl in pkl_files:
                print(f"  ✓ {pkl.stem}: {pkl}")
        else:
            print(f"  ✗ No F1 data downloaded")
    else:
        print(f"  ✗ F1 directory not found")

    print("\nRaw data location: " + str(RAW_DATA_DIR))
    print("\nNext steps:")
    print("  1. Run preprocess_euroc_drone.py to format drone data")
    print("  2. Run preprocess_f1_telemetry.py to format F1 data")
    print("  3. Run validate_dataset_format.py to verify formatting")

def main():
    print("=" * 80)
    print("REAL-WORLD DATASET DOWNLOADER FOR UKF VALIDATION")
    print("=" * 80)
    print(f"Target directory: {RAW_DATA_DIR}")

    # Create directory structure
    create_directories()

    # Download datasets
    download_euroc_datasets()
    download_f1_telemetry()

    # Generate summary
    generate_download_report()

    print("\n" + "=" * 80)
    print("DOWNLOAD PROCESS COMPLETE")
    print("=" * 80)

if __name__ == "__main__":
    main()
