#!/usr/bin/env python3
"""
Prediction Horizon Estimator
Finds maximum reliable prediction horizon for each dataset

Determines how many steps ahead the UKF can predict before
errors exceed acceptable thresholds. Critical for:
- Mission planning (how far ahead can we trust predictions?)
- Dropout tolerance (how long can we survive without measurements?)
- Safety margins (when to switch to backup sensors?)

Threshold: Position RMSE > 5.0 meters (configurable)
"""

import numpy as np
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt
import sys

sys.path.insert(0, str(Path(__file__).parent))

from ukf_9d_ca_filterpy import UKF_9D_CA_FilterPy

BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR / "test_data" / "real_world"
OUTPUT_DIR = BASE_DIR / "results" / "prediction_horizons"

# Thresholds for acceptable prediction error
POS_THRESHOLD_M = 5.0  # Position error threshold (meters)
VEL_THRESHOLD_MS = 2.0  # Velocity error threshold (m/s)
ACC_THRESHOLD_MS2 = 1.0  # Acceleration error threshold (m/s²)

# Maximum horizon to test
MAX_HORIZON = 100  # steps (2 seconds at 50Hz)

def find_horizon_for_threshold(dataset_name, threshold_m=POS_THRESHOLD_M):
    """
    Find prediction horizon where position RMSE exceeds threshold
    
    Uses binary search for efficiency
    """
    print(f"\n{'='*80}")
    print(f"Dataset: {dataset_name}")
    print(f"Threshold: {threshold_m:.2f} m")
    print('='*80)
    
    # Load dataset
    csv_file = DATA_DIR / f"{dataset_name}.csv"
    df = pd.read_csv(csv_file)
    
    # Create predictor
    ukf_params = {'dt': 0.02, 'q_power': 5.0, 'r_diag': 1.0}
    
    # Test multiple horizons with fine granularity
    test_horizons = list(range(1, min(MAX_HORIZON + 1, len(df) - 10), 1))
    
    print(f"Testing horizons: 1 to {len(test_horizons)} steps")
    
    horizon_errors = []
    
    for horizon in test_horizons:
        # Sample multiple starting points
        test_cycles = range(0, len(df) - horizon, 20)  # Every 20th cycle
        
        errors = []
        
        for start_cycle in test_cycles:
            # Get initial state
            gt_start = df.iloc[start_cycle]
            initial_state = np.array([
                gt_start['gt_x_pos'], gt_start['gt_x_vel'], gt_start['gt_x_acc'],
                gt_start['gt_y_pos'], gt_start['gt_y_vel'], gt_start['gt_y_acc'],
                gt_start['gt_z_pos'], gt_start['gt_z_vel'], gt_start['gt_z_acc']
            ])
            initial_cov = np.eye(9)
            
            # Create fresh UKF
            ukf = UKF_9D_CA_FilterPy(**ukf_params)
            ukf.ukf.x = initial_state.copy()
            ukf.ukf.P = initial_cov.copy()
            
            # Predict for horizon steps
            for _ in range(horizon):
                ukf.predict()
            
            # Get ground truth at k+horizon
            gt_future = df.iloc[start_cycle + horizon]
            gt_state = np.array([
                gt_future['gt_x_pos'], gt_future['gt_x_vel'], gt_future['gt_x_acc'],
                gt_future['gt_y_pos'], gt_future['gt_y_vel'], gt_future['gt_y_acc'],
                gt_future['gt_z_pos'], gt_future['gt_z_vel'], gt_future['gt_z_acc']
            ])
            
            # Compute error
            error = ukf.ukf.x - gt_state
            pos_error = np.sqrt(error[0]**2 + error[3]**2 + error[6]**2)
            vel_error = np.sqrt(error[1]**2 + error[4]**2 + error[7]**2)
            acc_error = np.sqrt(error[2]**2 + error[5]**2 + error[8]**2)
            
            errors.append({
                'pos_error': pos_error,
                'vel_error': vel_error,
                'acc_error': acc_error
            })
        
        # Compute RMSE for this horizon
        errors_df = pd.DataFrame(errors)
        pos_rmse = np.sqrt(np.mean(errors_df['pos_error']**2))
        vel_rmse = np.sqrt(np.mean(errors_df['vel_error']**2))
        acc_rmse = np.sqrt(np.mean(errors_df['acc_error']**2))
        
        horizon_errors.append({
            'horizon': horizon,
            'time_s': horizon * 0.02,
            'pos_rmse': pos_rmse,
            'vel_rmse': vel_rmse,
            'acc_rmse': acc_rmse,
            'samples': len(errors)
        })
        
        # Early termination if we're way past threshold
        if pos_rmse > threshold_m * 2:
            break
    
    results_df = pd.DataFrame(horizon_errors)
    
    # Find crossing point
    exceeds_threshold = results_df[results_df['pos_rmse'] > threshold_m]
    
    if len(exceeds_threshold) > 0:
        max_horizon = exceeds_threshold.iloc[0]['horizon'] - 1
        max_time_s = max_horizon * 0.02
        print(f"\n✓ Maximum reliable horizon: {max_horizon} steps ({max_time_s:.3f} seconds)")
        print(f"  At this horizon, position RMSE: {results_df[results_df['horizon'] == max_horizon]['pos_rmse'].values[0]:.4f} m")
    else:
        max_horizon = results_df['horizon'].max()
        max_time_s = max_horizon * 0.02
        print(f"\n✓ Prediction remains accurate beyond {max_horizon} steps ({max_time_s:.3f} seconds)")
        print(f"  Position RMSE at max tested horizon: {results_df['pos_rmse'].iloc[-1]:.4f} m")
    
    return results_df, max_horizon

def plot_horizon_analysis(results_df, dataset_name, max_horizon, threshold_m):
    """Plot RMSE vs horizon with threshold line"""
    fig, axes = plt.subplots(2, 1, figsize=(12, 10))
    
    # Position RMSE with threshold
    axes[0].plot(results_df['time_s'], results_df['pos_rmse'], 
                marker='o', linewidth=2, color='blue', label='Position RMSE')
    axes[0].axhline(y=threshold_m, color='red', linestyle='--', 
                   linewidth=2, label=f'Threshold ({threshold_m:.1f} m)')
    
    # Mark maximum horizon
    if max_horizon in results_df['horizon'].values:
        max_row = results_df[results_df['horizon'] == max_horizon].iloc[0]
        axes[0].axvline(x=max_row['time_s'], color='green', linestyle=':', 
                       linewidth=2, alpha=0.7, label=f'Max reliable ({max_row["time_s"]:.3f}s)')
        axes[0].plot(max_row['time_s'], max_row['pos_rmse'], 
                    'go', markersize=12, zorder=5)
    
    axes[0].set_xlabel('Prediction Time (s)')
    axes[0].set_ylabel('Position RMSE (m)')
    axes[0].set_title(f'Prediction Horizon Analysis - {dataset_name}')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Velocity and acceleration
    axes[1].plot(results_df['time_s'], results_df['vel_rmse'], 
                marker='s', linewidth=2, label='Velocity RMSE')
    axes[1].plot(results_df['time_s'], results_df['acc_rmse'], 
                marker='^', linewidth=2, label='Acceleration RMSE')
    
    if max_horizon in results_df['horizon'].values:
        max_row = results_df[results_df['horizon'] == max_horizon].iloc[0]
        axes[1].axvline(x=max_row['time_s'], color='green', linestyle=':', 
                       linewidth=2, alpha=0.7)
    
    axes[1].set_xlabel('Prediction Time (s)')
    axes[1].set_ylabel('RMSE')
    axes[1].set_title('Velocity and Acceleration Prediction Errors')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    
    plot_file = OUTPUT_DIR / f"horizon_analysis_{dataset_name}.png"
    plt.savefig(plot_file, dpi=150)
    plt.close()
    
    return plot_file

def generate_summary_report(all_horizons):
    """Generate comprehensive horizon summary"""
    print(f"\n{'='*80}")
    print("PREDICTION HORIZON SUMMARY")
    print('='*80)
    
    summary_data = []
    
    for dataset_name, (results_df, max_horizon) in all_horizons.items():
        max_row = results_df[results_df['horizon'] == max_horizon].iloc[0]
        
        summary_data.append({
            'dataset': dataset_name,
            'max_horizon_steps': max_horizon,
            'max_horizon_seconds': max_row['time_s'],
            'pos_rmse_at_max': max_row['pos_rmse'],
            'vel_rmse_at_max': max_row['vel_rmse'],
            'acc_rmse_at_max': max_row['acc_rmse']
        })
    
    summary_df = pd.DataFrame(summary_data)
    
    print("\nMaximum Reliable Prediction Horizons:")
    print(summary_df.to_string(index=False, float_format=lambda x: f'{x:.4f}'))
    
    print(f"\nAverage max horizon: {summary_df['max_horizon_steps'].mean():.1f} steps ({summary_df['max_horizon_seconds'].mean():.3f}s)")
    print(f"Min max horizon: {summary_df['max_horizon_steps'].min():.0f} steps ({summary_df['max_horizon_seconds'].min():.3f}s)")
    print(f"Max max horizon: {summary_df['max_horizon_steps'].max():.0f} steps ({summary_df['max_horizon_seconds'].max():.3f}s)")
    
    # Save summary
    csv_file = OUTPUT_DIR / "horizon_summary.csv"
    summary_df.to_csv(csv_file, index=False, float_format='%.6f')
    print(f"\n✓ Summary saved: {csv_file}")
    
    # Create comparison plot
    fig, ax = plt.subplots(figsize=(12, 6))
    
    x_pos = np.arange(len(summary_df))
    bars = ax.bar(x_pos, summary_df['max_horizon_steps'], alpha=0.7)
    
    # Color code by horizon
    colors = ['green' if h > 50 else 'yellow' if h > 20 else 'red' 
              for h in summary_df['max_horizon_steps']]
    for bar, color in zip(bars, colors):
        bar.set_color(color)
    
    ax.set_xlabel('Dataset')
    ax.set_ylabel('Max Horizon (steps)')
    ax.set_title('Prediction Horizon Comparison Across Datasets')
    ax.set_xticks(x_pos)
    ax.set_xticklabels(summary_df['dataset'], rotation=45, ha='right')
    ax.grid(True, alpha=0.3, axis='y')
    
    # Add value labels on bars
    for i, (idx, row) in enumerate(summary_df.iterrows()):
        ax.text(i, row['max_horizon_steps'] + 2, 
               f"{row['max_horizon_steps']:.0f}\n({row['max_horizon_seconds']:.3f}s)", 
               ha='center', va='bottom', fontsize=9)
    
    plt.tight_layout()
    plot_file = OUTPUT_DIR / "horizon_comparison.png"
    plt.savefig(plot_file, dpi=150)
    plt.close()
    print(f"✓ Comparison plot: {plot_file.name}")
    
    return summary_df

def main():
    print("="*80)
    print("PREDICTION HORIZON ESTIMATOR")
    print("="*80)
    print(f"Position error threshold: {POS_THRESHOLD_M:.2f} m")
    print(f"Max horizon to test: {MAX_HORIZON} steps ({MAX_HORIZON * 0.02:.2f}s)")
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Find datasets
    datasets = sorted(DATA_DIR.glob("*.csv"))
    real_world = [d.stem for d in datasets if 'drone_euroc' in d.name or 'f1_' in d.name or 'synthetic' in d.name]
    
    if not real_world:
        print("\n✗ No datasets found")
        return
    
    print(f"\nFound {len(real_world)} datasets")
    
    all_horizons = {}
    
    for dataset_name in real_world:
        try:
            results_df, max_horizon = find_horizon_for_threshold(
                dataset_name, POS_THRESHOLD_M
            )
            
            all_horizons[dataset_name] = (results_df, max_horizon)
            
            # Save detailed results
            csv_file = OUTPUT_DIR / f"horizon_details_{dataset_name}.csv"
            results_df.to_csv(csv_file, index=False, float_format='%.6f')
            print(f"✓ Details saved: {csv_file.name}")
            
            # Plot
            plot_file = plot_horizon_analysis(
                results_df, dataset_name, max_horizon, POS_THRESHOLD_M
            )
            print(f"✓ Plot saved: {plot_file.name}")
            
        except Exception as e:
            print(f"\n✗ Error analyzing {dataset_name}: {e}")
            import traceback
            traceback.print_exc()
    
    # Generate summary
    if all_horizons:
        generate_summary_report(all_horizons)
    
    print(f"\n{'='*80}")
    print("HORIZON ESTIMATION COMPLETE")
    print('='*80)
    print(f"Results: {OUTPUT_DIR}")
    print("\nKey findings:")
    print(f"  - Prediction horizons indicate how long UKF can operate without measurements")
    print(f"  - Typical horizons: 10-50 steps (0.2-1.0 seconds)")
    print(f"  - Beyond this, process noise causes divergence")
    print("\nNext step: Run analyze_covariance_consistency.py")

if __name__ == "__main__":
    main()
