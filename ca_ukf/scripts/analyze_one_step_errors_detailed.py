#!/usr/bin/env python3
"""
Detailed cycle-by-cycle analysis of one-step prediction errors
"""

import pandas as pd
import numpy as np
from pathlib import Path

def analyze_one_step_errors(est_df, gt_df, name):
    """Compute per-cycle one-step prediction errors"""
    # Extract position estimates at time k
    est_x = est_df['est_x_pos'].values[:-1]  # 0 to N-2
    est_y = est_df['est_y_pos'].values[:-1]
    est_z = est_df['est_z_pos'].values[:-1]

    # Extract ground truth at time k+1
    gt_x = gt_df['gt_x_pos'].values[1:]  # 1 to N-1
    gt_y = gt_df['gt_y_pos'].values[1:]
    gt_z = gt_df['gt_z_pos'].values[1:]

    # Compute prediction errors
    dx = est_x - gt_x
    dy = est_y - gt_y
    dz = est_z - gt_z

    position_error = np.sqrt(dx**2 + dy**2 + dz**2)

    return pd.DataFrame({
        'cycle': np.arange(len(position_error)),
        'error_x': dx,
        'error_y': dy,
        'error_z': dz,
        'error_3d': position_error,
        'est_x': est_x,
        'est_y': est_y,
        'est_z': est_z,
        'gt_x_next': gt_x,
        'gt_y_next': gt_y,
        'gt_z_next': gt_z
    })

def main():
    base_dir = Path(__file__).parent.parent

    datasets = [
        ('synthetic_drone_500cycles', 'Drone'),
        ('synthetic_vehicle_600cycles', 'Vehicle')
    ]

    for dataset_name, display_name in datasets:
        print(f"\n{'=' * 80}")
        print(f"{display_name} Dataset - Cycle-by-Cycle One-Step Prediction Errors")
        print(f"{'=' * 80}\n")

        # Load ground truth
        gt_file = base_dir / "test_data" / "real_world" / f"{dataset_name}.csv"
        gt_df = pd.read_csv(gt_file)

        # Load implementations
        custom_file = base_dir / "results" / "python_outputs" / "custom" / f"custom_{dataset_name}.csv"
        vhdl_file = base_dir / "results" / "vhdl_outputs" / "csv" / f"vhdl_{dataset_name}.csv"

        custom_df = pd.read_csv(custom_file)
        vhdl_df = pd.read_csv(vhdl_file)

        # Analyze errors
        custom_errors = analyze_one_step_errors(custom_df, gt_df, "Custom Python")
        vhdl_errors = analyze_one_step_errors(vhdl_df, gt_df, "VHDL")

        # Show first 10 cycles
        print("First 10 cycles:")
        print("-" * 80)
        print("Cycle | Custom Python Error | VHDL Error | Difference")
        print("-" * 80)
        for i in range(min(10, len(custom_errors))):
            custom_err = custom_errors.iloc[i]['error_3d']
            vhdl_err = vhdl_errors.iloc[i]['error_3d']
            diff = abs(vhdl_err - custom_err)
            print(f"  {i:3d} | {custom_err:10.6f} m      | {vhdl_err:10.6f} m | {diff:10.6f} m")

        print()

        # Find worst cycles
        print("Worst 10 cycles (VHDL errors):")
        print("-" * 80)
        worst_indices = vhdl_errors.nlargest(10, 'error_3d').index
        print("Cycle | Custom Python Error | VHDL Error | Difference")
        print("-" * 80)
        for idx in worst_indices:
            cycle = vhdl_errors.iloc[idx]['cycle']
            custom_err = custom_errors.iloc[idx]['error_3d']
            vhdl_err = vhdl_errors.iloc[idx]['error_3d']
            diff = abs(vhdl_err - custom_err)
            print(f"  {int(cycle):3d} | {custom_err:10.6f} m      | {vhdl_err:10.6f} m | {diff:10.6f} m")

        print()

        # Statistics by sections
        n = len(custom_errors)
        sections = [
            ("First 10 cycles", slice(0, 10)),
            ("Cycles 10-50", slice(10, 50)),
            ("Cycles 50-100", slice(50, 100)),
            ("Last 100 cycles", slice(n-100, n))
        ]

        print("Error statistics by section:")
        print("-" * 80)
        print("Section           | Custom Python RMSE | VHDL RMSE      | Difference")
        print("-" * 80)
        for section_name, section_slice in sections:
            if section_slice.stop is not None and section_slice.stop > n:
                continue
            custom_section = custom_errors.iloc[section_slice]['error_3d']
            vhdl_section = vhdl_errors.iloc[section_slice]['error_3d']

            custom_rmse = np.sqrt(np.mean(custom_section**2))
            vhdl_rmse = np.sqrt(np.mean(vhdl_section**2))
            diff = abs(vhdl_rmse - custom_rmse)

            print(f"{section_name:17s} | {custom_rmse:10.6f} m      | {vhdl_rmse:10.6f} m | {diff:10.6f} m")

        print()

        # Identify when error exceeds threshold
        threshold = 2.0  # 2m
        vhdl_bad_cycles = vhdl_errors[vhdl_errors['error_3d'] > threshold]

        if len(vhdl_bad_cycles) > 0:
            first_bad = vhdl_bad_cycles.iloc[0]['cycle']
            print(f"First cycle where VHDL error exceeds {threshold}m: Cycle {int(first_bad)}")
            print(f"Total cycles with error > {threshold}m: {len(vhdl_bad_cycles)} / {n}")
            print(f"Percentage: {100.0 * len(vhdl_bad_cycles) / n:.1f}%")
        else:
            print(f"All VHDL errors below {threshold}m ✓")

        print()

        # Save detailed errors
        output_dir = base_dir / "results" / "one_step_prediction"
        output_dir.mkdir(parents=True, exist_ok=True)

        custom_errors.to_csv(output_dir / f"custom_one_step_errors_{dataset_name}.csv", index=False)
        vhdl_errors.to_csv(output_dir / f"vhdl_one_step_errors_{dataset_name}.csv", index=False)

        print(f"Detailed errors saved to: results/one_step_prediction/")

if __name__ == "__main__":
    main()
