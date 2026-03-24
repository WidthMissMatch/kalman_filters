#!/usr/bin/env python3
"""
Test robustness of two initialization strategies:
1. Bayesian: Full predict+update from cycle 0
2. Direct: Initialize state from measurement, skip filtering on cycle 0
"""

import numpy as np
import pandas as pd
from pathlib import Path
import sys
sys.path.insert(0, '.')

from ukf_9d_ca_reference import UKF_9D_CA

def ukf_with_bayesian_init(measurements, dt=0.02):
    """UKF with full Bayesian filtering from cycle 0 (current Python)"""
    ukf = UKF_9D_CA(dt=dt, q_power=5.0, r_diag=1.0)
    results = []

    for i, z in enumerate(measurements):
        x, P, nu = ukf.process_measurement(z)
        results.append({
            'cycle': i,
            'x_pos': x[0], 'y_pos': x[3], 'z_pos': x[6],
            'P11': P[0,0], 'innovation_norm': np.linalg.norm(nu)
        })

    return pd.DataFrame(results)

def ukf_with_direct_init(measurements, dt=0.02):
    """UKF with direct measurement initialization on cycle 0 (VHDL approach)"""
    ukf = UKF_9D_CA(dt=dt, q_power=5.0, r_diag=1.0)
    results = []

    for i, z in enumerate(measurements):
        if i == 0:
            # Initialize state from first measurement (VHDL approach)
            ukf.x[0] = z[0]  # x_pos
            ukf.x[3] = z[1]  # y_pos
            ukf.x[6] = z[2]  # z_pos
            # velocities and accelerations remain zero
            results.append({
                'cycle': i,
                'x_pos': ukf.x[0], 'y_pos': ukf.x[3], 'z_pos': ukf.x[6],
                'P11': ukf.P[0,0], 'innovation_norm': 0.0
            })
        else:
            # Run full predict+update
            ukf.predict()
            x, P, nu = ukf.update(z)
            results.append({
                'cycle': i,
                'x_pos': x[0], 'y_pos': x[3], 'z_pos': x[6],
                'P11': P[0,0], 'innovation_norm': np.linalg.norm(nu)
            })

    return pd.DataFrame(results)

def compute_metrics(est_df, gt_df):
    """Compute performance metrics"""
    dx = est_df['x_pos'] - gt_df['gt_x_pos']
    dy = est_df['y_pos'] - gt_df['gt_y_pos']
    dz = est_df['z_pos'] - gt_df['gt_z_pos']

    position_error = np.sqrt(dx**2 + dy**2 + dz**2)

    return {
        'rmse': np.sqrt(np.mean(position_error**2)),
        'max_error': position_error.max(),
        'mean_error': position_error.mean(),
        'std_error': position_error.std(),
        'median_error': np.median(position_error),
        # Convergence metrics
        'rmse_first_10': np.sqrt(np.mean(position_error[:10]**2)),
        'rmse_last_100': np.sqrt(np.mean(position_error[-100:]**2)),
        'final_covariance': est_df.iloc[-1]['P11'],
        'innovation_mean': est_df['innovation_norm'].mean(),
        'innovation_std': est_df['innovation_norm'].std()
    }

if __name__ == "__main__":
    base_dir = Path(__file__).parent.parent

    print("=" * 80)
    print("INITIALIZATION ROBUSTNESS COMPARISON")
    print("=" * 80)
    print()

    datasets = [
        ('synthetic_drone_500cycles', 'Drone (500 cycles)'),
        ('synthetic_vehicle_600cycles', 'Vehicle (600 cycles)')
    ]

    all_results = []

    for dataset_name, display_name in datasets:
        print(f"\nDataset: {display_name}")
        print("=" * 80)

        # Load ground truth and measurements
        data_file = base_dir / "test_data" / "real_world" / f"{dataset_name}.csv"
        df = pd.read_csv(data_file)

        measurements = np.column_stack([df['meas_x'], df['meas_y'], df['meas_z']])

        # Test both approaches
        bayesian_results = ukf_with_bayesian_init(measurements)
        direct_results = ukf_with_direct_init(measurements)

        # Compute metrics
        bayesian_metrics = compute_metrics(bayesian_results, df)
        direct_metrics = compute_metrics(direct_results, df)

        print("\nApproach 1: BAYESIAN (Full filtering from cycle 0)")
        print("-" * 80)
        print(f"  Overall RMSE:          {bayesian_metrics['rmse']:.6f} m")
        print(f"  Max error:             {bayesian_metrics['max_error']:.6f} m")
        print(f"  Mean error:            {bayesian_metrics['mean_error']:.6f} m")
        print(f"  Std error:             {bayesian_metrics['std_error']:.6f} m")
        print(f"  Median error:          {bayesian_metrics['median_error']:.6f} m")
        print()
        print(f"  RMSE (first 10 cycles):  {bayesian_metrics['rmse_first_10']:.6f} m")
        print(f"  RMSE (last 100 cycles):  {bayesian_metrics['rmse_last_100']:.6f} m")
        print(f"  Final covariance P11:    {bayesian_metrics['final_covariance']:.6f}")
        print(f"  Innovation mean:         {bayesian_metrics['innovation_mean']:.6f}")
        print(f"  Innovation std:          {bayesian_metrics['innovation_std']:.6f}")

        print("\nApproach 2: DIRECT (Measurement-only init on cycle 0)")
        print("-" * 80)
        print(f"  Overall RMSE:          {direct_metrics['rmse']:.6f} m")
        print(f"  Max error:             {direct_metrics['max_error']:.6f} m")
        print(f"  Mean error:            {direct_metrics['mean_error']:.6f} m")
        print(f"  Std error:             {direct_metrics['std_error']:.6f} m")
        print(f"  Median error:          {direct_metrics['median_error']:.6f} m")
        print()
        print(f"  RMSE (first 10 cycles):  {direct_metrics['rmse_first_10']:.6f} m")
        print(f"  RMSE (last 100 cycles):  {direct_metrics['rmse_last_100']:.6f} m")
        print(f"  Final covariance P11:    {direct_metrics['final_covariance']:.6f}")
        print(f"  Innovation mean:         {direct_metrics['innovation_mean']:.6f}")
        print(f"  Innovation std:          {direct_metrics['innovation_std']:.6f}")

        print("\nCOMPARISON:")
        print("-" * 80)
        rmse_diff = direct_metrics['rmse'] - bayesian_metrics['rmse']
        max_err_diff = direct_metrics['max_error'] - bayesian_metrics['max_error']
        convergence_diff = direct_metrics['rmse_last_100'] - bayesian_metrics['rmse_last_100']

        print(f"  RMSE difference (Direct - Bayesian):         {rmse_diff:+.6f} m")
        print(f"  Max error difference:                        {max_err_diff:+.6f} m")
        print(f"  Convergence difference (last 100 cycles):    {convergence_diff:+.6f} m")

        if abs(rmse_diff) < 0.01:
            winner = "TIE (no significant difference)"
        elif rmse_diff < 0:
            winner = "DIRECT is better"
        else:
            winner = "BAYESIAN is better"

        print(f"\n  >>> {winner}")

        all_results.append({
            'dataset': display_name,
            'bayesian_rmse': bayesian_metrics['rmse'],
            'direct_rmse': direct_metrics['rmse'],
            'bayesian_max_error': bayesian_metrics['max_error'],
            'direct_max_error': direct_metrics['max_error'],
            'bayesian_convergence': bayesian_metrics['rmse_last_100'],
            'direct_convergence': direct_metrics['rmse_last_100']
        })

    print("\n" + "=" * 80)
    print("OVERALL SUMMARY")
    print("=" * 80)

    summary_df = pd.DataFrame(all_results)
    print("\n", summary_df.to_string(index=False))

    # Determine overall winner
    bayesian_wins = sum(summary_df['bayesian_rmse'] < summary_df['direct_rmse'])
    direct_wins = sum(summary_df['direct_rmse'] < summary_df['bayesian_rmse'])

    print("\n" + "=" * 80)
    print("ROBUSTNESS VERDICT:")
    print("=" * 80)

    if bayesian_wins > direct_wins:
        print("\n✓ BAYESIAN approach is MORE ROBUST")
        print("  - Better overall RMSE")
        print("  - Proper Bayesian filtering from start")
        print("  - Recommended for production use")
    elif direct_wins > bayesian_wins:
        print("\n✓ DIRECT approach is MORE ROBUST")
        print("  - Better overall RMSE")
        print("  - Faster convergence")
        print("  - Simpler implementation")
    else:
        print("\n= BOTH approaches are EQUALLY ROBUST")
        print("  - Use BAYESIAN for theoretical correctness")
        print("  - Use DIRECT for simplicity")
