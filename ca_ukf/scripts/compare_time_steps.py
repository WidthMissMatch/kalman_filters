#!/usr/bin/env python3
"""
Compare UKF prediction accuracy across different time steps

Tests dt values: 10ms, 20ms, 50ms, 100ms
Analyzes how prediction accuracy degrades with larger time steps
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import argparse
from pathlib import Path
from analyze_prediction_accuracy import PredictionAnalyzer
from dataset_adapter import GenericCSVAdapter


def test_multiple_time_steps(trajectory_csv, test_dts=[0.01, 0.02, 0.05, 0.1],
                              q_power=5.0, r_diag=0.01, output_dir='../results/dt_comparison'):
    """
    Test UKF prediction accuracy with different time steps

    Args:
        trajectory_csv: Path to trajectory CSV (time, x, y, z)
        test_dts: List of time steps to test (seconds)
        q_power: Process noise power
        r_diag: Measurement noise variance
        output_dir: Output directory for results
    """
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Load original trajectory
    df_traj = pd.read_csv(trajectory_csv)
    timestamps = df_traj['time'].values
    positions = df_traj[['x', 'y', 'z']].values

    print("=" * 80)
    print("TIME STEP COMPARISON ANALYSIS")
    print("=" * 80)
    print(f"Trajectory: {trajectory_csv}")
    print(f"Duration: {timestamps[-1]:.2f} seconds")
    print(f"Testing dt values: {[f'{dt*1000:.0f}ms' for dt in test_dts]}")
    print()

    results_all = {}

    for dt in test_dts:
        print(f"\n{'='*80}")
        print(f"Testing dt = {dt*1000:.0f} ms")
        print(f"{'='*80}")

        # Create adapter and convert trajectory
        adapter = GenericCSVAdapter(dt=dt)
        positions_resampled = adapter.resample_to_dt(timestamps, positions, dt)
        ground_truth = adapter.compute_derivatives(positions_resampled, dt)
        measurements = adapter.add_measurement_noise(positions_resampled, noise_std=0.1)

        print(f"  Resampled to {len(ground_truth)} cycles")

        # Run prediction analysis
        analyzer = PredictionAnalyzer(dt=dt)
        results = analyzer.run_python_ukf_with_prediction_tracking(
            measurements, ground_truth,
            q_power=q_power, r_diag=r_diag
        )

        # Compute metrics
        metrics = analyzer.compute_prediction_metrics(
            results['prediction_errors'],
            results['update_errors']
        )

        # Extract position RMSEs
        pred_rmse_pos = np.mean([metrics['prediction'][f'{ax}_pos']['rmse']
                                 for ax in ['x', 'y', 'z']])
        upd_rmse_pos = np.mean([metrics['update'][f'{ax}_pos']['rmse']
                                for ax in ['x', 'y', 'z']])

        results_all[dt] = {
            'pred_rmse_pos': pred_rmse_pos,
            'upd_rmse_pos': upd_rmse_pos,
            'metrics': metrics,
            'improvement': ((pred_rmse_pos - upd_rmse_pos) / pred_rmse_pos) * 100
        }

        print(f"  Position Prediction RMSE:  {pred_rmse_pos:.6f} m")
        print(f"  Position Update RMSE:      {upd_rmse_pos:.6f} m")
        print(f"  Improvement:               {results_all[dt]['improvement']:.2f}%")

    print("\n" + "=" * 80)
    print("COMPARISON SUMMARY")
    print("=" * 80)
    print(f"{'dt (ms)':<10} {'Pred RMSE (m)':<15} {'Upd RMSE (m)':<15} {'Improvement':<15} {'Status':<20}")
    print("-" * 80)

    for dt in test_dts:
        res = results_all[dt]
        status = "✅ EXCELLENT" if res['pred_rmse_pos'] < 0.5 else \
                 "✓ GOOD" if res['pred_rmse_pos'] < 1.0 else \
                 "⚠ MODERATE" if res['pred_rmse_pos'] < 2.0 else "❌ POOR"

        print(f"{dt*1000:<10.0f} {res['pred_rmse_pos']:<15.6f} {res['upd_rmse_pos']:<15.6f} "
              f"{res['improvement']:<14.2f}% {status:<20}")

    # Plot comparison
    plot_dt_comparison(test_dts, results_all, output_dir / 'dt_comparison.png')

    # Write detailed report
    write_dt_comparison_report(test_dts, results_all, output_dir / 'dt_comparison_report.txt')

    return results_all


def plot_dt_comparison(test_dts, results_all, output_file):
    """
    Plot prediction RMSE vs time step

    Args:
        test_dts: List of time steps
        results_all: Dict of results for each dt
        output_file: Output image path
    """
    dt_ms = [dt * 1000 for dt in test_dts]
    pred_rmse = [results_all[dt]['pred_rmse_pos'] for dt in test_dts]
    upd_rmse = [results_all[dt]['upd_rmse_pos'] for dt in test_dts]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: RMSE vs dt
    ax1.plot(dt_ms, pred_rmse, 'ro-', linewidth=2, markersize=8, label='Prediction RMSE')
    ax1.plot(dt_ms, upd_rmse, 'bo-', linewidth=2, markersize=8, label='Update RMSE')
    ax1.axhline(y=0.5, color='g', linestyle='--', alpha=0.5, label='0.5m threshold')
    ax1.axhline(y=1.0, color='orange', linestyle='--', alpha=0.5, label='1.0m threshold')

    ax1.set_xlabel('Time Step (ms)', fontsize=12, fontweight='bold')
    ax1.set_ylabel('Position RMSE (m)', fontsize=12, fontweight='bold')
    ax1.set_title('Prediction Accuracy vs Time Step', fontsize=14, fontweight='bold')
    ax1.grid(True, alpha=0.3)
    ax1.legend(fontsize=10)

    # Plot 2: Improvement percentage
    improvement = [results_all[dt]['improvement'] for dt in test_dts]
    ax2.bar(dt_ms, improvement, color='#3498db', alpha=0.8, edgecolor='black')

    ax2.set_xlabel('Time Step (ms)', fontsize=12, fontweight='bold')
    ax2.set_ylabel('Update Improvement (%)', fontsize=12, fontweight='bold')
    ax2.set_title('Measurement Update Effectiveness', fontsize=14, fontweight='bold')
    ax2.grid(True, axis='y', alpha=0.3)

    # Add value labels
    for i, (dt_val, imp_val) in enumerate(zip(dt_ms, improvement)):
        ax2.text(dt_val, imp_val + 0.2, f'{imp_val:.1f}%', ha='center', fontsize=9)

    plt.tight_layout()
    plt.savefig(output_file, dpi=150, bbox_inches='tight')
    print(f"\nComparison plot saved: {output_file}")
    plt.close()


def write_dt_comparison_report(test_dts, results_all, output_file):
    """
    Write detailed comparison report

    Args:
        test_dts: List of time steps
        results_all: Dict of results
        output_file: Output text file
    """
    with open(output_file, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("9D CA UKF - TIME STEP COMPARISON ANALYSIS\n")
        f.write("=" * 80 + "\n\n")

        f.write("PREDICTION ACCURACY vs TIME STEP\n")
        f.write("-" * 80 + "\n")
        f.write(f"{'dt (ms)':<10} {'Pred RMSE':<12} {'Upd RMSE':<12} {'Improvement':<12} {'Assessment':<20}\n")
        f.write("-" * 80 + "\n")

        for dt in test_dts:
            res = results_all[dt]
            status = "EXCELLENT" if res['pred_rmse_pos'] < 0.5 else \
                     "GOOD" if res['pred_rmse_pos'] < 1.0 else \
                     "MODERATE" if res['pred_rmse_pos'] < 2.0 else "POOR"

            f.write(f"{dt*1000:<10.0f} {res['pred_rmse_pos']:<12.6f} {res['upd_rmse_pos']:<12.6f} "
                    f"{res['improvement']:<11.2f}% {status:<20}\n")

        f.write("\n\nRECOMMENDATIONS\n")
        f.write("-" * 80 + "\n")

        # Find optimal dt (smallest with pred_rmse < 0.5)
        optimal_dt = None
        for dt in sorted(test_dts, reverse=True):
            if results_all[dt]['pred_rmse_pos'] < 0.5:
                optimal_dt = dt

        if optimal_dt:
            f.write(f"✅ Recommended dt: {optimal_dt*1000:.0f} ms\n")
            f.write(f"   Prediction RMSE: {results_all[optimal_dt]['pred_rmse_pos']:.6f} m\n")
            f.write(f"   This provides excellent accuracy while maximizing update rate.\n\n")
        else:
            f.write("⚠ No tested dt achieved EXCELLENT prediction accuracy.\n")
            f.write("  Consider reducing dt below tested range.\n\n")

        # Analysis of degradation
        f.write("\nDEGRADATION ANALYSIS\n")
        f.write("-" * 80 + "\n")

        if len(test_dts) >= 2:
            rmse_range = max([results_all[dt]['pred_rmse_pos'] for dt in test_dts]) - \
                         min([results_all[dt]['pred_rmse_pos'] for dt in test_dts])

            f.write(f"RMSE range across tested dt: {rmse_range:.6f} m\n")

            if rmse_range < 0.1:
                f.write("Conclusion: Prediction accuracy is ROBUST to dt selection in tested range.\n")
            elif rmse_range < 0.5:
                f.write("Conclusion: Moderate sensitivity to dt - choose carefully based on requirements.\n")
            else:
                f.write("Conclusion: HIGH sensitivity to dt - smaller dt strongly recommended.\n")

        f.write("\n" + "=" * 80 + "\n")

    print(f"Detailed report saved: {output_file}")


def main():
    parser = argparse.ArgumentParser(
        description='Compare UKF prediction accuracy across different time steps'
    )
    parser.add_argument('--input', type=str, required=True,
                        help='Input trajectory CSV (columns: time, x, y, z)')
    parser.add_argument('--dts', type=float, nargs='+',
                        default=[0.01, 0.02, 0.05, 0.1],
                        help='Time steps to test (seconds)')
    parser.add_argument('--q-power', type=float, default=5.0,
                        help='Process noise power')
    parser.add_argument('--r-diag', type=float, default=0.01,
                        help='Measurement noise variance')
    parser.add_argument('--output-dir', type=str, default='../results/dt_comparison',
                        help='Output directory')

    args = parser.parse_args()

    test_multiple_time_steps(
        args.input,
        test_dts=args.dts,
        q_power=args.q_power,
        r_diag=args.r_diag,
        output_dir=args.output_dir
    )


if __name__ == '__main__':
    main()
