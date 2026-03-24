#!/usr/bin/env python3
"""
Compute RMSE for CTRA UKF VHDL output vs ground truth
Reads hex-format output from VHDL simulation
"""

import numpy as np
import pandas as pd
import sys
from pathlib import Path

Q_SCALE = 2**24

def hex48_to_float(hex_str):
    """Convert 48-bit hex string (Q24.24) to float"""
    hex_str = hex_str.strip()
    val = int(hex_str, 16)
    if val >= 2**47:
        val -= 2**48
    return val / Q_SCALE

def main():
    if len(sys.argv) < 3:
        print("Usage: python compute_rmse.py <vhdl_output.txt> <ground_truth.csv>")
        print("Example: python compute_rmse.py vhdl_output_synthetic_drone_500cycles.txt ../ca_ukf/test_data/real_world/synthetic_drone_500cycles.csv")
        sys.exit(1)

    vhdl_file = sys.argv[1]
    gt_file = sys.argv[2]

    # Read ground truth
    gt_df = pd.read_csv(gt_file)

    # Read VHDL output (hex format)
    # Format: cycle,px_hex,py_hex,v_hex,theta_hex,omega_hex,a_hex,z_hex,p11,...,p77
    vhdl_lines = []
    with open(vhdl_file, 'r') as f:
        header = f.readline()  # Skip header
        for line in f:
            parts = line.strip().split(',')
            if len(parts) >= 8:
                cycle = int(parts[0])
                px = hex48_to_float(parts[1])
                py = hex48_to_float(parts[2])
                v = hex48_to_float(parts[3])
                theta = hex48_to_float(parts[4])
                omega = hex48_to_float(parts[5])
                a = hex48_to_float(parts[6])
                z = hex48_to_float(parts[7])
                vhdl_lines.append({
                    'cycle': cycle, 'px': px, 'py': py, 'v': v,
                    'theta': theta, 'omega': omega, 'a': a, 'z': z
                })

    vhdl_df = pd.DataFrame(vhdl_lines)

    # Skip first few cycles for initialization
    skip = 3
    n = min(len(vhdl_df), len(gt_df)) - skip

    gt_x = gt_df['gt_x_pos'].values[skip:skip+n]
    gt_y = gt_df['gt_y_pos'].values[skip:skip+n]
    gt_z = gt_df['gt_z_pos'].values[skip:skip+n]

    est_x = vhdl_df['px'].values[skip:skip+n]
    est_y = vhdl_df['py'].values[skip:skip+n]
    est_z = vhdl_df['z'].values[skip:skip+n]

    # 3D position error
    err = np.sqrt((est_x - gt_x)**2 + (est_y - gt_y)**2 + (est_z - gt_z)**2)
    rmse = np.sqrt(np.mean(err**2))

    print(f"=== CTRA UKF RMSE Results ===")
    print(f"Dataset: {gt_file}")
    print(f"VHDL output: {vhdl_file}")
    print(f"Cycles used: {n} (skipped first {skip})")
    print(f"3D Position RMSE: {rmse:.4f} m")
    print(f"Mean error: {np.mean(err):.4f} m")
    print(f"Max error: {np.max(err):.4f} m")
    print(f"Min error: {np.min(err):.4f} m")

    # Also show per-axis RMSE
    rmse_x = np.sqrt(np.mean((est_x - gt_x)**2))
    rmse_y = np.sqrt(np.mean((est_y - gt_y)**2))
    rmse_z = np.sqrt(np.mean((est_z - gt_z)**2))
    print(f"\nPer-axis RMSE: X={rmse_x:.4f}, Y={rmse_y:.4f}, Z={rmse_z:.4f}")

    # Show state statistics
    print(f"\nState statistics (last 10 cycles):")
    last10 = vhdl_df.tail(10)
    print(f"  v range: [{last10['v'].min():.2f}, {last10['v'].max():.2f}] m/s")
    print(f"  theta range: [{last10['theta'].min():.4f}, {last10['theta'].max():.4f}] rad")
    print(f"  omega range: [{last10['omega'].min():.6f}, {last10['omega'].max():.6f}] rad/s")
    print(f"  a range: [{last10['a'].min():.2f}, {last10['a'].max():.2f}] m/s²")

if __name__ == "__main__":
    main()
