#!/usr/bin/env python3
"""
Analyze Multi-Step Prediction Accuracy
Tests pure prediction mode (no measurements) for N steps ahead

This measures how long the UKF can reliably predict future states
without new measurements - critical for handling measurement dropouts
or planning ahead in autonomous systems.

Prediction Horizons: 1, 2, 5, 10, 20, 50 steps
Metrics:
- RMSE growth over horizon
- Covariance growth
- Divergence detection
"""

import numpy as np
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt
import sys

# Add scripts directory to path
sys.path.insert(0, str(Path(__file__).parent))

from ukf_9d_ca_filterpy import UKF_9D_CA_FilterPy

BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR / "test_data" / "real_world"
OUTPUT_DIR = BASE_DIR / "results" / "multi_step"

PREDICTION_HORIZONS = [1, 2, 5, 10, 20, 50]

class MultiStepPredictor:
    """Runs UKF in pure prediction mode for N steps"""
    
    def __init__(self, ukf_params=None):
        if ukf_params is None:
            ukf_params = {'dt': 0.02, 'q_power': 5.0, 'r_diag': 1.0}
        
        self.ukf_params = ukf_params
    
    def predict_multi_step(self, initial_state, initial_cov, n_steps):
        """
        Run pure prediction for N steps without measurements
        
        Args:
            initial_state: 9D state vector to start from
            initial_cov: 9x9 covariance matrix
            n_steps: Number of prediction steps
        
        Returns:
            List of (state, covariance) tuples for each step
        """
        # Create fresh UKF
        ukf = UKF_9D_CA_FilterPy(**self.ukf_params)
        
        # Set initial conditions
        ukf.ukf.x = initial_state.copy()
        ukf.ukf.P = initial_cov.copy()
        
        predictions = []
        
        for _ in range(n_steps):
            # Predict only (no update)
            ukf.predict()
            
            # Store prediction
            predictions.append({
                'state': ukf.ukf.x.copy(),
                'cov': ukf.ukf.P.copy(),
                'cov_diag': np.diag(ukf.ukf.P)
            })
        
        return predictions

def run_multi_step_analysis(dataset_name, horizons=PREDICTION_HORIZONS):
    """Analyze multi-step prediction for one dataset"""
    print(f"\n{'='*80}")
    print(f"Dataset: {dataset_name}")
    print('='*80)
    
    # Load dataset
    csv_file = DATA_DIR / f"{dataset_name}.csv"
    df = pd.read_csv(csv_file)
    print(f"Loaded {len(df)} cycles")
    
    # Create predictor
    predictor = MultiStepPredictor()
    
    # We'll analyze prediction from every 10th cycle to save time
    test_cycles = range(0, len(df) - max(horizons), 10)
    
    print(f"Testing {len(test_cycles)} starting points")
    print(f"Prediction horizons: {horizons}")
    
    # Storage for results
    all_errors = {h: [] for h in horizons}
    
    for start_cycle in test_cycles:
        # Get initial state from ground truth
        gt_start = df.iloc[start_cycle]
        
        initial_state = np.array([
            gt_start['gt_x_pos'], gt_start['gt_x_vel'], gt_start['gt_x_acc'],
            gt_start['gt_y_pos'], gt_start['gt_y_vel'], gt_start['gt_y_acc'],
            gt_start['gt_z_pos'], gt_start['gt_z_vel'], gt_start['gt_z_acc']
        ])
        
        # Use identity covariance (assume perfect initial knowledge)
        initial_cov = np.eye(9)
        
        # Predict for max horizon
        predictions = predictor.predict_multi_step(
            initial_state, initial_cov, max(horizons)
        )
        
        # Compute errors at each horizon
        for h in horizons:
            if start_cycle + h >= len(df):
                continue
            
            # Ground truth at k+h
            gt_future = df.iloc[start_cycle + h]
            gt_state = np.array([
                gt_future['gt_x_pos'], gt_future['gt_x_vel'], gt_future['gt_x_acc'],
                gt_future['gt_y_pos'], gt_future['gt_y_vel'], gt_future['gt_y_acc'],
                gt_future['gt_z_pos'], gt_future['gt_z_vel'], gt_future['gt_z_acc']
            ])
            
            # Predicted state at k+h
            pred_state = predictions[h - 1]['state']
            pred_cov_diag = predictions[h - 1]['cov_diag']
            
            # Compute errors
            error = pred_state - gt_state
            
            pos_error = np.sqrt(error[0]**2 + error[3]**2 + error[6]**2)
            vel_error = np.sqrt(error[1]**2 + error[4]**2 + error[7]**2)
            acc_error = np.sqrt(error[2]**2 + error[5]**2 + error[8]**2)
            
            # Store
            all_errors[h].append({
                'start_cycle': start_cycle,
                'horizon': h,
                'pos_error': pos_error,
                'vel_error': vel_error,
                'acc_error': acc_error,
                'pos_uncertainty': np.sqrt(pred_cov_diag[0]),  # X position uncertainty
                'vel_uncertainty': np.sqrt(pred_cov_diag[1]),  # X velocity uncertainty
                'acc_uncertainty': np.sqrt(pred_cov_diag[2])   # X acceleration uncertainty
            })
    
    # Compute statistics for each horizon
    horizon_stats = []
    
    for h in horizons:
        if not all_errors[h]:
            continue
        
        errors_df = pd.DataFrame(all_errors[h])
        
        stats = {
            'horizon': h,
            'time_ahead_s': h * 0.02,
            'pos_rmse': np.sqrt(np.mean(errors_df['pos_error']**2)),
            'vel_rmse': np.sqrt(np.mean(errors_df['vel_error']**2)),
            'acc_rmse': np.sqrt(np.mean(errors_df['acc_error']**2)),
            'pos_max_error': errors_df['pos_error'].max(),
            'vel_max_error': errors_df['vel_error'].max(),
            'acc_max_error': errors_df['acc_error'].max(),
            'mean_pos_uncertainty': errors_df['pos_uncertainty'].mean(),
            'mean_vel_uncertainty': errors_df['vel_uncertainty'].mean(),
            'mean_acc_uncertainty': errors_df['acc_uncertainty'].mean()
        }
        
        horizon_stats.append(stats)
        
        print(f"\nHorizon {h} steps ({h*0.02:.2f}s ahead):")
        print(f"  Position RMSE: {stats['pos_rmse']:.4f} m (max: {stats['pos_max_error']:.4f} m)")
        print(f"  Velocity RMSE: {stats['vel_rmse']:.4f} m/s (max: {stats['vel_max_error']:.4f} m/s)")
        print(f"  Accel RMSE:    {stats['acc_rmse']:.4f} m/s² (max: {stats['acc_max_error']:.4f} m/s²)")
        print(f"  Position σ:    {stats['mean_pos_uncertainty']:.4f} m")
    
    return pd.DataFrame(horizon_stats)

def plot_horizon_curves(stats_df, dataset_name):
    """Plot error growth vs prediction horizon"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # RMSE vs horizon
    axes[0, 0].plot(stats_df['time_ahead_s'], stats_df['pos_rmse'], 
                    marker='o', linewidth=2, label='Position')
    axes[0, 0].plot(stats_df['time_ahead_s'], stats_df['vel_rmse'], 
                    marker='s', linewidth=2, label='Velocity')
    axes[0, 0].plot(stats_df['time_ahead_s'], stats_df['acc_rmse'], 
                    marker='^', linewidth=2, label='Acceleration')
    axes[0, 0].set_xlabel('Prediction Time (s)')
    axes[0, 0].set_ylabel('RMSE')
    axes[0, 0].set_title(f'Multi-Step Prediction Error Growth - {dataset_name}')
    axes[0, 0].legend()
    axes[0, 0].grid(True, alpha=0.3)
    
    # Max error vs horizon
    axes[0, 1].plot(stats_df['time_ahead_s'], stats_df['pos_max_error'], 
                    marker='o', linewidth=2, label='Position')
    axes[0, 1].plot(stats_df['time_ahead_s'], stats_df['vel_max_error'], 
                    marker='s', linewidth=2, label='Velocity')
    axes[0, 1].plot(stats_df['time_ahead_s'], stats_df['acc_max_error'], 
                    marker='^', linewidth=2, label='Acceleration')
    axes[0, 1].set_xlabel('Prediction Time (s)')
    axes[0, 1].set_ylabel('Maximum Error')
    axes[0, 1].set_title('Worst-Case Prediction Error')
    axes[0, 1].legend()
    axes[0, 1].grid(True, alpha=0.3)
    
    # Uncertainty growth
    axes[1, 0].plot(stats_df['time_ahead_s'], stats_df['mean_pos_uncertainty'], 
                    marker='o', linewidth=2, label='Position σ')
    axes[1, 0].plot(stats_df['time_ahead_s'], stats_df['mean_vel_uncertainty'], 
                    marker='s', linewidth=2, label='Velocity σ')
    axes[1, 0].plot(stats_df['time_ahead_s'], stats_df['mean_acc_uncertainty'], 
                    marker='^', linewidth=2, label='Acceleration σ')
    axes[1, 0].set_xlabel('Prediction Time (s)')
    axes[1, 0].set_ylabel('Uncertainty (σ)')
    axes[1, 0].set_title('Covariance Growth')
    axes[1, 0].legend()
    axes[1, 0].grid(True, alpha=0.3)
    
    # Error vs uncertainty (consistency check)
    axes[1, 1].scatter(stats_df['mean_pos_uncertainty'], stats_df['pos_rmse'], 
                      s=100, alpha=0.6, label='Position')
    axes[1, 1].plot([0, stats_df['mean_pos_uncertainty'].max()], 
                   [0, stats_df['mean_pos_uncertainty'].max()], 
                   'k--', alpha=0.5, label='Perfect calibration')
    axes[1, 1].set_xlabel('Predicted Uncertainty (σ)')
    axes[1, 1].set_ylabel('Actual RMSE')
    axes[1, 1].set_title('Uncertainty Calibration')
    axes[1, 1].legend()
    axes[1, 1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    
    plot_file = OUTPUT_DIR / f"multi_step_horizon_{dataset_name}.png"
    plt.savefig(plot_file, dpi=150)
    plt.close()
    
    return plot_file

def main():
    print("="*80)
    print("MULTI-STEP PREDICTION ANALYSIS")
    print("="*80)
    print("Tests pure prediction mode (no measurements)")
    print(f"Horizons: {PREDICTION_HORIZONS} steps")
    print(f"Max time ahead: {max(PREDICTION_HORIZONS) * 0.02:.2f} seconds")
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Find datasets
    datasets = sorted(DATA_DIR.glob("*.csv"))
    real_world = [d.stem for d in datasets if 'drone_euroc' in d.name or 'f1_' in d.name or 'synthetic' in d.name]
    
    if not real_world:
        print("\n✗ No datasets found")
        return
    
    print(f"\nFound {len(real_world)} datasets")
    
    all_stats = {}
    
    for dataset_name in real_world:
        try:
            stats_df = run_multi_step_analysis(dataset_name)
            all_stats[dataset_name] = stats_df
            
            # Save stats
            csv_file = OUTPUT_DIR / f"multi_step_stats_{dataset_name}.csv"
            stats_df.to_csv(csv_file, index=False, float_format='%.6f')
            print(f"\n✓ Stats saved: {csv_file.name}")
            
            # Plot
            plot_file = plot_horizon_curves(stats_df, dataset_name)
            print(f"✓ Plot saved: {plot_file.name}")
            
        except Exception as e:
            print(f"\n✗ Error analyzing {dataset_name}: {e}")
            import traceback
            traceback.print_exc()
    
    # Summary across all datasets
    if all_stats:
        print(f"\n{'='*80}")
        print("SUMMARY ACROSS ALL DATASETS")
        print('='*80)
        
        summary_data = []
        for dataset_name, stats_df in all_stats.items():
            for _, row in stats_df.iterrows():
                summary_data.append({
                    'dataset': dataset_name,
                    'horizon': row['horizon'],
                    'time_s': row['time_ahead_s'],
                    'pos_rmse': row['pos_rmse'],
                    'vel_rmse': row['vel_rmse']
                })
        
        summary_df = pd.DataFrame(summary_data)
        
        # Average across datasets for each horizon
        avg_stats = summary_df.groupby('horizon').agg({
            'time_s': 'first',
            'pos_rmse': 'mean',
            'vel_rmse': 'mean'
        }).reset_index()
        
        print("\nAverage RMSE across all datasets:")
        print(avg_stats.to_string(index=False, float_format=lambda x: f'{x:.4f}'))
        
        csv_file = OUTPUT_DIR / "multi_step_summary.csv"
        summary_df.to_csv(csv_file, index=False, float_format='%.6f')
        print(f"\n✓ Summary saved: {csv_file}")
    
    print(f"\n{'='*80}")
    print("MULTI-STEP ANALYSIS COMPLETE")
    print('='*80)
    print(f"Results: {OUTPUT_DIR}")
    print("\nNext step: Run prediction_horizon_estimator.py")

if __name__ == "__main__":
    main()
