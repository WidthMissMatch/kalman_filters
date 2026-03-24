#!/usr/bin/env python3
"""Compute Position RMSE for all three implementations"""

import pandas as pd
import numpy as np
from pathlib import Path

def compute_position_rmse(est_df, ref_df):
    """Compute 3D position RMSE between estimates and reference"""
    dx = est_df['est_x_pos'] - ref_df['est_x_pos']
    dy = est_df['est_y_pos'] - ref_df['est_y_pos']
    dz = est_df['est_z_pos'] - ref_df['est_z_pos']

    position_error = np.sqrt(dx**2 + dy**2 + dz**2)
    rmse = np.sqrt(np.mean(position_error**2))

    return {
        'rmse_x': np.sqrt(np.mean(dx**2)),
        'rmse_y': np.sqrt(np.mean(dy**2)),
        'rmse_z': np.sqrt(np.mean(dz**2)),
        'rmse_3d': rmse,
        'max_error': position_error.max(),
        'mean_error': position_error.mean()
    }

if __name__ == "__main__":
    base_dir = Path(__file__).parent.parent

    datasets = [
        'synthetic_drone_500cycles',
        'synthetic_vehicle_600cycles'
    ]

    print("=" * 80)
    print("POSITION RMSE COMPARISON")
    print("=" * 80)
    print()

    results = []

    for dataset in datasets:
        print(f"Dataset: {dataset}")
        print("-" * 80)

        # Load all three implementations
        custom = pd.read_csv(base_dir / "results" / "python_outputs" / "custom" / f"custom_{dataset}.csv")
        filterpy = pd.read_csv(base_dir / "results" / "python_outputs" / "filterpy" / f"filterpy_{dataset}.csv")
        vhdl = pd.read_csv(base_dir / "results" / "vhdl_outputs" / "csv" / f"vhdl_{dataset}.csv")

        print(f"  Custom Python: {len(custom)} cycles")
        print(f"  FilterPy:      {len(filterpy)} cycles")
        print(f"  VHDL:          {len(vhdl)} cycles")
        print()

        # Compute pairwise RMSE
        custom_vs_filterpy = compute_position_rmse(custom, filterpy)
        custom_vs_vhdl = compute_position_rmse(custom, vhdl)
        filterpy_vs_vhdl = compute_position_rmse(filterpy, vhdl)

        print("Custom Python vs FilterPy:")
        print(f"  Position RMSE (3D): {custom_vs_filterpy['rmse_3d']:.6f} m")
        print(f"  Max error: {custom_vs_filterpy['max_error']:.6f} m")
        print()

        print("Custom Python vs VHDL:")
        print(f"  Position RMSE (3D): {custom_vs_vhdl['rmse_3d']:.6f} m")
        print(f"  RMSE X: {custom_vs_vhdl['rmse_x']:.6f} m")
        print(f"  RMSE Y: {custom_vs_vhdl['rmse_y']:.6f} m")
        print(f"  RMSE Z: {custom_vs_vhdl['rmse_z']:.6f} m")
        print(f"  Max error: {custom_vs_vhdl['max_error']:.6f} m")
        print()

        print("FilterPy vs VHDL:")
        print(f"  Position RMSE (3D): {filterpy_vs_vhdl['rmse_3d']:.6f} m")
        print(f"  Max error: {filterpy_vs_vhdl['max_error']:.6f} m")
        print()

        # Store results
        results.append({
            'dataset': dataset,
            'implementation': 'Custom Python',
            'position_rmse': custom_vs_filterpy['rmse_3d']
        })
        results.append({
            'dataset': dataset,
            'implementation': 'FilterPy',
            'position_rmse': custom_vs_filterpy['rmse_3d']
        })
        results.append({
            'dataset': dataset,
            'implementation': 'VHDL',
            'position_rmse': custom_vs_vhdl['rmse_3d']
        })

    print("=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print()

    df_results = pd.DataFrame(results)
    print(df_results.to_string(index=False))

    # Save results
    output_file = base_dir / "results" / "position_rmse_comparison.csv"
    df_results.to_csv(output_file, index=False)
    print()
    print(f"Results saved to: {output_file}")
