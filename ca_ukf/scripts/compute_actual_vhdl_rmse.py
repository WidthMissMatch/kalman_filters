#!/usr/bin/env python3
"""
Compute ACTUAL VHDL RMSE from real simulation output

Compares VHDL predictions (from simulation) with:
1. Python predictions
2. Ground truth

This gives us the REAL performance numbers.
"""

import numpy as np
import pandas as pd


def from_q24_24(value):
    """Convert Q24.24 fixed-point to float"""
    return float(value) / (2**24)


def main():
    print("=" * 80)
    print("ACTUAL VHDL PERFORMANCE (from real simulation output)")
    print("=" * 80)
    print()

    # Load VHDL predictions
    print("Loading VHDL predictions from simulation...")
    vhdl_df = pd.read_csv('../test_data/vhdl_predictions.txt')
    print(f"  Loaded {len(vhdl_df)} cycles")
    print()

    # Load Python reference
    print("Loading Python reference...")
    python_df = pd.read_csv('../test_data/python_reference_9d_ca.csv')
    print(f"  Loaded {len(python_df)} cycles")
    print()

    # Align data
    num_cycles = min(len(vhdl_df), len(python_df))
    print(f"Comparing {num_cycles} cycles")
    print()

    # Extract positions (convert VHDL from Q24.24 to float)
    vhdl_x_pos = np.array([from_q24_24(v) for v in vhdl_df['x_pos'][:num_cycles]])
    vhdl_y_pos = np.array([from_q24_24(v) for v in vhdl_df['y_pos'][:num_cycles]])
    vhdl_z_pos = np.array([from_q24_24(v) for v in vhdl_df['z_pos'][:num_cycles]])

    # Python estimates
    python_x_pos = python_df['est_x_pos'][:num_cycles].values
    python_y_pos = python_df['est_y_pos'][:num_cycles].values
    python_z_pos = python_df['est_z_pos'][:num_cycles].values

    # Ground truth
    gt_x_pos = python_df['gt_x_pos'][:num_cycles].values
    gt_y_pos = python_df['gt_y_pos'][:num_cycles].values
    gt_z_pos = python_df['gt_z_pos'][:num_cycles].values

    # Compute errors vs ground truth
    vhdl_error_x = np.abs(vhdl_x_pos - gt_x_pos)
    vhdl_error_y = np.abs(vhdl_y_pos - gt_y_pos)
    vhdl_error_z = np.abs(vhdl_z_pos - gt_z_pos)

    python_error_x = np.abs(python_x_pos - gt_x_pos)
    python_error_y = np.abs(python_y_pos - gt_y_pos)
    python_error_z = np.abs(python_z_pos - gt_z_pos)

    # Compute VHDL vs Python difference
    vhdl_vs_python_x = np.abs(vhdl_x_pos - python_x_pos)
    vhdl_vs_python_y = np.abs(vhdl_y_pos - python_y_pos)
    vhdl_vs_python_z = np.abs(vhdl_z_pos - python_z_pos)

    # Compute RMSEs
    vhdl_rmse_x = np.sqrt(np.mean(vhdl_error_x**2))
    vhdl_rmse_y = np.sqrt(np.mean(vhdl_error_y**2))
    vhdl_rmse_z = np.sqrt(np.mean(vhdl_error_z**2))
    vhdl_rmse_avg = np.mean([vhdl_rmse_x, vhdl_rmse_y, vhdl_rmse_z])

    python_rmse_x = np.sqrt(np.mean(python_error_x**2))
    python_rmse_y = np.sqrt(np.mean(python_error_y**2))
    python_rmse_z = np.sqrt(np.mean(python_error_z**2))
    python_rmse_avg = np.mean([python_rmse_x, python_rmse_y, python_rmse_z])

    diff_rmse_x = np.sqrt(np.mean(vhdl_vs_python_x**2))
    diff_rmse_y = np.sqrt(np.mean(vhdl_vs_python_y**2))
    diff_rmse_z = np.sqrt(np.mean(vhdl_vs_python_z**2))
    diff_rmse_avg = np.mean([diff_rmse_x, diff_rmse_y, diff_rmse_z])

    # Print results
    print("=" * 80)
    print("POSITION PREDICTION ACCURACY (vs Ground Truth)")
    print("=" * 80)
    print(f"{'Axis':<6} {'VHDL RMSE':<15} {'Python RMSE':<15} {'VHDL Max':<15} {'Python Max':<15}")
    print("-" * 80)
    print(f"{'X':<6} {vhdl_rmse_x:<15.6f} {python_rmse_x:<15.6f} "
          f"{np.max(vhdl_error_x):<15.6f} {np.max(python_error_x):<15.6f}")
    print(f"{'Y':<6} {vhdl_rmse_y:<15.6f} {python_rmse_y:<15.6f} "
          f"{np.max(vhdl_error_y):<15.6f} {np.max(python_error_y):<15.6f}")
    print(f"{'Z':<6} {vhdl_rmse_z:<15.6f} {python_rmse_z:<15.6f} "
          f"{np.max(vhdl_error_z):<15.6f} {np.max(python_error_z):<15.6f}")
    print("-" * 80)
    print(f"{'AVG':<6} {vhdl_rmse_avg:<15.6f} {python_rmse_avg:<15.6f}")
    print()

    print("=" * 80)
    print("VHDL vs PYTHON DIRECT COMPARISON")
    print("=" * 80)
    print(f"{'Axis':<6} {'Difference RMSE':<20} {'Max Difference':<20}")
    print("-" * 80)
    print(f"{'X':<6} {diff_rmse_x:<20.6f} {np.max(vhdl_vs_python_x):<20.6f}")
    print(f"{'Y':<6} {diff_rmse_y:<20.6f} {np.max(vhdl_vs_python_y):<20.6f}")
    print(f"{'Z':<6} {diff_rmse_z:<20.6f} {np.max(vhdl_vs_python_z):<20.6f}")
    print("-" * 80)
    print(f"{'AVG':<6} {diff_rmse_avg:<20.6f} {np.max([np.max(vhdl_vs_python_x), np.max(vhdl_vs_python_y), np.max(vhdl_vs_python_z)]):<20.6f}")
    print()

    # Analysis
    print("=" * 80)
    print("ANALYSIS")
    print("=" * 80)
    print()

    if vhdl_rmse_avg < python_rmse_avg:
        pct_diff = ((python_rmse_avg - vhdl_rmse_avg) / python_rmse_avg) * 100
        print(f"✅ VHDL is {pct_diff:.2f}% MORE ACCURATE than Python")
    elif vhdl_rmse_avg > python_rmse_avg:
        pct_diff = ((vhdl_rmse_avg - python_rmse_avg) / vhdl_rmse_avg) * 100
        print(f"⚠ Python is {pct_diff:.2f}% MORE ACCURATE than VHDL")
    else:
        print("✅ VHDL and Python have IDENTICAL accuracy")
    print()

    print(f"VHDL-Python Agreement RMSE: {diff_rmse_avg:.6f} m")
    if diff_rmse_avg < 0.001:
        print("✅ EXCELLENT: VHDL matches Python within 1mm")
    elif diff_rmse_avg < 0.01:
        print("✅ VERY GOOD: VHDL matches Python within 1cm")
    elif diff_rmse_avg < 0.1:
        print("✓ GOOD: VHDL matches Python within 10cm")
    elif diff_rmse_avg < 0.5:
        print("⚠ ACCEPTABLE: VHDL within testbench tolerance (0.5m)")
    else:
        print("❌ POOR: VHDL differs from Python by > 0.5m")
    print()

    # Sample cycle comparison
    print("=" * 80)
    print("SAMPLE CYCLE COMPARISON (Cycle 10)")
    print("=" * 80)
    cycle = 10
    print(f"{'State':<10} {'Ground Truth':<15} {'VHDL':<15} {'Python':<15} {'VHDL Error':<15} {'Py Error':<15}")
    print("-" * 80)
    print(f"{'x_pos':<10} {gt_x_pos[cycle]:<15.6f} {vhdl_x_pos[cycle]:<15.6f} "
          f"{python_x_pos[cycle]:<15.6f} {vhdl_error_x[cycle]:<15.6f} {python_error_x[cycle]:<15.6f}")
    print(f"{'y_pos':<10} {gt_y_pos[cycle]:<15.6f} {vhdl_y_pos[cycle]:<15.6f} "
          f"{python_y_pos[cycle]:<15.6f} {vhdl_error_y[cycle]:<15.6f} {python_error_y[cycle]:<15.6f}")
    print(f"{'z_pos':<10} {gt_z_pos[cycle]:<15.6f} {vhdl_z_pos[cycle]:<15.6f} "
          f"{python_z_pos[cycle]:<15.6f} {vhdl_error_z[cycle]:<15.6f} {python_error_z[cycle]:<15.6f}")
    print()

    # Write detailed results
    output_file = '../results/ACTUAL_VHDL_PERFORMANCE.txt'
    with open(output_file, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("ACTUAL VHDL MODULE PERFORMANCE\n")
        f.write("From Real GHDL Simulation Output\n")
        f.write("=" * 80 + "\n\n")

        f.write(f"Cycles Compared: {num_cycles}\n\n")

        f.write("PREDICTION ACCURACY (vs Ground Truth):\n")
        f.write("-" * 80 + "\n")
        f.write(f"  VHDL Average RMSE:   {vhdl_rmse_avg:.6f} m\n")
        f.write(f"  Python Average RMSE: {python_rmse_avg:.6f} m\n\n")

        f.write(f"  VHDL X-axis RMSE:  {vhdl_rmse_x:.6f} m\n")
        f.write(f"  VHDL Y-axis RMSE:  {vhdl_rmse_y:.6f} m\n")
        f.write(f"  VHDL Z-axis RMSE:  {vhdl_rmse_z:.6f} m\n\n")

        f.write("VHDL vs PYTHON AGREEMENT:\n")
        f.write("-" * 80 + "\n")
        f.write(f"  Average Difference RMSE: {diff_rmse_avg:.6f} m\n")
        f.write(f"  X-axis Difference RMSE:  {diff_rmse_x:.6f} m\n")
        f.write(f"  Y-axis Difference RMSE:  {diff_rmse_y:.6f} m\n")
        f.write(f"  Z-axis Difference RMSE:  {diff_rmse_z:.6f} m\n\n")

        if diff_rmse_avg < 0.01:
            f.write("VERDICT: ✅ VHDL MATCHES Python (< 1cm difference)\n")
        elif diff_rmse_avg < 0.1:
            f.write("VERDICT: ✓ VHDL Close to Python (< 10cm difference)\n")
        else:
            f.write("VERDICT: ⚠ Significant difference detected\n")

    print(f"Detailed results saved to: {output_file}")
    print()
    print("=" * 80)


if __name__ == '__main__':
    main()
