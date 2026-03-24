#!/usr/bin/env python3
"""
Compute RMSE from Bicycle UKF VHDL simulation output.
Compares hex output against ground truth from CSV data.
"""

import csv
import sys
import os
import numpy as np

Q_SCALE = 2**24

def hex48_to_float(hex_str):
    """Convert 48-bit hex string (Q24.24) to float."""
    hex_str = hex_str.strip()
    if 'X' in hex_str.upper() or 'U' in hex_str.upper():
        return None
    val = int(hex_str, 16)
    if val >= (1 << 47):
        val -= (1 << 48)
    return val / Q_SCALE


def compute_rmse(vhdl_output_path, csv_path):
    """Compute RMSE between VHDL output and ground truth."""
    # Load ground truth
    gt_data = []
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            gt_data.append((
                float(row['gt_x_pos']),
                float(row['gt_y_pos']),
                float(row['gt_z_pos'])
            ))

    # Load VHDL output
    errors = []
    valid_cycles = 0
    with open(vhdl_output_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            cycle = int(row['cycle'])
            if cycle >= len(gt_data):
                break

            px = hex48_to_float(row['px_hex'])
            py = hex48_to_float(row['py_hex'])
            pz = hex48_to_float(row['z_hex'])

            if px is None or py is None or pz is None:
                errors.append(None)
                continue

            gt = gt_data[cycle]
            ex = px - gt[0]
            ey = py - gt[1]
            ez = pz - gt[2]
            err = np.sqrt(ex**2 + ey**2 + ez**2)
            errors.append(err)
            valid_cycles += 1

    # Compute RMSE
    valid_errors = [e for e in errors if e is not None]
    if not valid_errors:
        print("ERROR: No valid cycles found (all X values)")
        return

    rmse = np.sqrt(np.mean(np.array(valid_errors)**2))

    print(f"VHDL Output: {vhdl_output_path}")
    print(f"Ground Truth: {csv_path}")
    print(f"Valid cycles: {valid_cycles}/{len(errors)}")
    print(f"RMSE (3D): {rmse:.4f} m")

    # Checkpoints
    for cp in [10, 50, 100, 200, 500, 750]:
        subset = [e for e in errors[:cp] if e is not None]
        if subset:
            rmse_cp = np.sqrt(np.mean(np.array(subset)**2))
            print(f"  RMSE @{cp:4d}: {rmse_cp:.4f} m ({len(subset)} valid)")

    # Show first few cycles
    print(f"\nFirst 10 cycles:")
    for i, err in enumerate(errors[:10]):
        if err is not None:
            print(f"  Cycle {i}: err={err:.4f} m")
        else:
            print(f"  Cycle {i}: INVALID (X values)")

    return rmse


if __name__ == '__main__':
    base_dir = os.path.dirname(os.path.abspath(__file__))
    src_dir = os.path.join(base_dir, '..', 'src')
    ca_dir = os.path.join(base_dir, '..', '..', 'ca_ukf')

    datasets = {
        'synthetic_drone_500cycles': {
            'vhdl': os.path.join(src_dir, 'vhdl_output_synthetic_drone_500cycles.txt'),
            'csv': os.path.join(ca_dir, 'test_data/real_world/synthetic_drone_500cycles.csv'),
        },
        'f1_monaco_2024_750cycles': {
            'vhdl': os.path.join(src_dir, 'vhdl_output_f1_monaco_2024_750cycles.txt'),
            'csv': os.path.join(ca_dir, 'test_data/real_world/f1_monaco_2024_750cycles.csv'),
        },
        'f1_silverstone_2024_750cycles': {
            'vhdl': os.path.join(src_dir, 'vhdl_output_f1_silverstone_2024_750cycles.txt'),
            'csv': os.path.join(ca_dir, 'test_data/real_world/f1_silverstone_2024_750cycles.csv'),
        },
    }

    if len(sys.argv) > 1:
        name = sys.argv[1]
        if name in datasets:
            d = datasets[name]
            compute_rmse(d['vhdl'], d['csv'])
        else:
            print(f"Unknown dataset: {name}")
    else:
        for name, d in datasets.items():
            if os.path.exists(d['vhdl']):
                print(f"\n{'='*60}")
                print(f"Dataset: {name}")
                print(f"{'='*60}")
                compute_rmse(d['vhdl'], d['csv'])
