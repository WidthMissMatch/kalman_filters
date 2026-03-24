#!/usr/bin/env python3
"""
Compute One-Step Prediction RMSE

One-step prediction accuracy measures how well the estimate at time k
predicts the actual ground truth position at time k+1.

For each cycle k (0 to N-2):
  error[k] = ||position_estimate[k] - ground_truth_position[k+1]||

This tests the UKF's ability to predict the next state, which is critical
for real-time tracking and control applications.
"""

import pandas as pd
import numpy as np
from pathlib import Path

def compute_one_step_prediction_rmse(est_df, gt_df):
    """
    Compute one-step prediction RMSE

    Args:
        est_df: DataFrame with estimated states (est_x_pos, est_y_pos, est_z_pos)
        gt_df: DataFrame with ground truth (gt_x_pos, gt_y_pos, gt_z_pos)

    Returns:
        Dictionary with RMSE metrics
    """
    # For one-step prediction, compare estimate[k] to ground_truth[k+1]
    # So we go from cycle 0 to N-2
    N = min(len(est_df), len(gt_df))

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

    return {
        'rmse_x': np.sqrt(np.mean(dx**2)),
        'rmse_y': np.sqrt(np.mean(dy**2)),
        'rmse_z': np.sqrt(np.mean(dz**2)),
        'rmse_3d': np.sqrt(np.mean(position_error**2)),
        'max_error': position_error.max(),
        'mean_error': position_error.mean(),
        'std_error': position_error.std(),
        'median_error': np.median(position_error),
        'n_samples': len(position_error)
    }

def main():
    base_dir = Path(__file__).parent.parent

    datasets = [
        ('synthetic_drone_500cycles', 'Drone (500 cycles)'),
        ('synthetic_vehicle_600cycles', 'Vehicle (600 cycles)')
    ]

    print("=" * 80)
    print("ONE-STEP PREDICTION ACCURACY ANALYSIS")
    print("=" * 80)
    print()
    print("Metric: Position estimate at time k vs ground truth at time k+1")
    print("Goal: Measure UKF's ability to predict the next state")
    print()

    all_results = []

    for dataset_name, display_name in datasets:
        print(f"\n{'=' * 80}")
        print(f"Dataset: {display_name}")
        print(f"{'=' * 80}\n")

        # Load ground truth
        gt_file = base_dir / "test_data" / "real_world" / f"{dataset_name}.csv"
        gt_df = pd.read_csv(gt_file)

        # Load implementations
        custom_file = base_dir / "results" / "python_outputs" / "custom" / f"custom_{dataset_name}.csv"
        filterpy_file = base_dir / "results" / "python_outputs" / "filterpy" / f"filterpy_{dataset_name}.csv"
        vhdl_file = base_dir / "results" / "vhdl_outputs" / "csv" / f"vhdl_{dataset_name}.csv"

        custom_df = pd.read_csv(custom_file)
        filterpy_df = pd.read_csv(filterpy_file)
        vhdl_df = pd.read_csv(vhdl_file)

        # Compute one-step prediction RMSE for each implementation
        custom_metrics = compute_one_step_prediction_rmse(custom_df, gt_df)
        filterpy_metrics = compute_one_step_prediction_rmse(filterpy_df, gt_df)
        vhdl_metrics = compute_one_step_prediction_rmse(vhdl_df, gt_df)

        # Display results
        print("Custom Python UKF:")
        print(f"  One-step Position RMSE (3D): {custom_metrics['rmse_3d']:.6f} m")
        print(f"  RMSE X: {custom_metrics['rmse_x']:.6f} m")
        print(f"  RMSE Y: {custom_metrics['rmse_y']:.6f} m")
        print(f"  RMSE Z: {custom_metrics['rmse_z']:.6f} m")
        print(f"  Max error:    {custom_metrics['max_error']:.6f} m")
        print(f"  Mean error:   {custom_metrics['mean_error']:.6f} m")
        print(f"  Median error: {custom_metrics['median_error']:.6f} m")
        print(f"  Samples: {custom_metrics['n_samples']}")
        print()

        print("FilterPy UKF:")
        print(f"  One-step Position RMSE (3D): {filterpy_metrics['rmse_3d']:.6f} m")
        print(f"  RMSE X: {filterpy_metrics['rmse_x']:.6f} m")
        print(f"  RMSE Y: {filterpy_metrics['rmse_y']:.6f} m")
        print(f"  RMSE Z: {filterpy_metrics['rmse_z']:.6f} m")
        print(f"  Max error:    {filterpy_metrics['max_error']:.6f} m")
        print(f"  Mean error:   {filterpy_metrics['mean_error']:.6f} m")
        print(f"  Median error: {filterpy_metrics['median_error']:.6f} m")
        print(f"  Samples: {filterpy_metrics['n_samples']}")
        print()

        print("VHDL UKF (Q24.24 Fixed-Point):")
        print(f"  One-step Position RMSE (3D): {vhdl_metrics['rmse_3d']:.6f} m")
        print(f"  RMSE X: {vhdl_metrics['rmse_x']:.6f} m")
        print(f"  RMSE Y: {vhdl_metrics['rmse_y']:.6f} m")
        print(f"  RMSE Z: {vhdl_metrics['rmse_z']:.6f} m")
        print(f"  Max error:    {vhdl_metrics['max_error']:.6f} m")
        print(f"  Mean error:   {vhdl_metrics['mean_error']:.6f} m")
        print(f"  Median error: {vhdl_metrics['median_error']:.6f} m")
        print(f"  Samples: {vhdl_metrics['n_samples']}")
        print()

        print("-" * 80)
        print("COMPARISON:")
        print("-" * 80)
        print(f"  Custom Python vs FilterPy:  {abs(custom_metrics['rmse_3d'] - filterpy_metrics['rmse_3d']):.6f} m")
        print(f"  Custom Python vs VHDL:      {abs(custom_metrics['rmse_3d'] - vhdl_metrics['rmse_3d']):.6f} m")
        print(f"  FilterPy vs VHDL:           {abs(filterpy_metrics['rmse_3d'] - vhdl_metrics['rmse_3d']):.6f} m")
        print()

        # Store results
        all_results.append({
            'dataset': dataset_name,
            'implementation': 'Custom Python',
            'one_step_rmse': custom_metrics['rmse_3d'],
            'max_error': custom_metrics['max_error'],
            'mean_error': custom_metrics['mean_error']
        })
        all_results.append({
            'dataset': dataset_name,
            'implementation': 'FilterPy',
            'one_step_rmse': filterpy_metrics['rmse_3d'],
            'max_error': filterpy_metrics['max_error'],
            'mean_error': filterpy_metrics['mean_error']
        })
        all_results.append({
            'dataset': dataset_name,
            'implementation': 'VHDL',
            'one_step_rmse': vhdl_metrics['rmse_3d'],
            'max_error': vhdl_metrics['max_error'],
            'mean_error': vhdl_metrics['mean_error']
        })

    # Summary table
    print("\n" + "=" * 80)
    print("SUMMARY: ONE-STEP PREDICTION RMSE")
    print("=" * 80)
    print()

    summary_df = pd.DataFrame(all_results)

    # Pivot table for easy comparison
    pivot = summary_df.pivot(index='implementation', columns='dataset', values='one_step_rmse')
    print(pivot.to_string())
    print()

    # Save results
    output_dir = base_dir / "results" / "one_step_prediction"
    output_dir.mkdir(parents=True, exist_ok=True)

    output_file = output_dir / "one_step_prediction_rmse.csv"
    summary_df.to_csv(output_file, index=False)
    print(f"Results saved to: {output_file}")

    # Pass/Fail assessment
    print("\n" + "=" * 80)
    print("PASS/FAIL CRITERIA")
    print("=" * 80)
    print()

    for dataset_name, display_name in datasets:
        print(f"{display_name}:")

        custom_rmse = summary_df[(summary_df['dataset'] == dataset_name) &
                                (summary_df['implementation'] == 'Custom Python')]['one_step_rmse'].values[0]
        vhdl_rmse = summary_df[(summary_df['dataset'] == dataset_name) &
                              (summary_df['implementation'] == 'VHDL')]['one_step_rmse'].values[0]

        error_diff = abs(custom_rmse - vhdl_rmse)

        print(f"  Python RMSE:      {custom_rmse:.6f} m")
        print(f"  VHDL RMSE:        {vhdl_rmse:.6f} m")
        print(f"  Absolute diff:    {error_diff:.6f} m")

        # Acceptance criteria: VHDL within 0.5m of Python (Q24.24 quantization tolerance)
        if error_diff < 0.5:
            print(f"  ✓ PASS (diff < 0.5m)")
        else:
            print(f"  ✗ FAIL (diff >= 0.5m)")
        print()

if __name__ == "__main__":
    main()
