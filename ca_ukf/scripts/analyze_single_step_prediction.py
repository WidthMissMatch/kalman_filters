#!/usr/bin/env python3
"""
Analyze Single-Step Prediction Accuracy
Measures k→k+1 prediction error for all three UKF implementations

This is the PRIMARY metric for UKF performance - how well does the
filter predict the next state given current measurements?

Metrics:
- Position RMSE (m)
- Velocity RMSE (m/s)
- Acceleration RMSE (m/s²)
- Per-axis breakdown (x, y, z)
- Comparison: Custom Python vs FilterPy vs VHDL
"""

import numpy as np
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt
import seaborn as sns

BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR / "test_data" / "real_world"
PYTHON_CUSTOM_DIR = BASE_DIR / "results" / "python_outputs" / "custom"
PYTHON_FILTERPY_DIR = BASE_DIR / "results" / "python_outputs" / "filterpy"
VHDL_DIR = BASE_DIR / "results" / "vhdl_outputs" / "ghdl"
OUTPUT_DIR = BASE_DIR / "results" / "single_step"

def load_ground_truth(dataset_name):
    """Load ground truth trajectory"""
    csv_file = DATA_DIR / f"{dataset_name}.csv"
    if not csv_file.exists():
        raise FileNotFoundError(f"Dataset not found: {csv_file}")
    
    df = pd.read_csv(csv_file)
    return df

def load_ukf_outputs(dataset_name, implementation='custom'):
    """Load UKF outputs from specific implementation"""
    if implementation == 'custom':
        output_dir = PYTHON_CUSTOM_DIR
        prefix = 'custom'
    elif implementation == 'filterpy':
        output_dir = PYTHON_FILTERPY_DIR
        prefix = 'filterpy'
    elif implementation == 'vhdl':
        output_dir = VHDL_DIR
        prefix = 'vhdl'
    else:
        raise ValueError(f"Unknown implementation: {implementation}")
    
    # Find matching output file
    pattern = f"{prefix}_{dataset_name.replace('.csv', '')}*.csv"
    matches = list(output_dir.glob(pattern))
    
    if not matches:
        raise FileNotFoundError(f"No outputs found for {dataset_name} in {output_dir}")
    
    return pd.read_csv(matches[0])

def compute_single_step_errors(ground_truth, estimates):
    """
    Compute single-step prediction errors
    
    For each cycle k, compare:
    - Predicted state at k+1 (from prediction step at k)
    - Actual ground truth at k+1
    
    This measures how well the UKF predicts future state
    """
    errors = {
        'cycle': [],
        'time': [],
        # Position errors
        'pos_x_error': [], 'pos_y_error': [], 'pos_z_error': [],
        'pos_mag_error': [],
        # Velocity errors
        'vel_x_error': [], 'vel_y_error': [], 'vel_z_error': [],
        'vel_mag_error': [],
        # Acceleration errors
        'acc_x_error': [], 'acc_y_error': [], 'acc_z_error': [],
        'acc_mag_error': []
    }
    
    # Skip last cycle (no k+1 available)
    for k in range(len(ground_truth) - 1):
        gt_next = ground_truth.iloc[k + 1]
        est_current = estimates.iloc[k]
        
        # Position errors at k+1
        pos_x_err = est_current['est_x_pos'] - gt_next['gt_x_pos']
        pos_y_err = est_current['est_y_pos'] - gt_next['gt_y_pos']
        pos_z_err = est_current['est_z_pos'] - gt_next['gt_z_pos']
        pos_mag_err = np.sqrt(pos_x_err**2 + pos_y_err**2 + pos_z_err**2)
        
        # Velocity errors at k+1
        vel_x_err = est_current['est_x_vel'] - gt_next['gt_x_vel']
        vel_y_err = est_current['est_y_vel'] - gt_next['gt_y_vel']
        vel_z_err = est_current['est_z_vel'] - gt_next['gt_z_vel']
        vel_mag_err = np.sqrt(vel_x_err**2 + vel_y_err**2 + vel_z_err**2)
        
        # Acceleration errors at k+1
        acc_x_err = est_current['est_x_acc'] - gt_next['gt_x_acc']
        acc_y_err = est_current['est_y_acc'] - gt_next['gt_y_acc']
        acc_z_err = est_current['est_z_acc'] - gt_next['gt_z_acc']
        acc_mag_err = np.sqrt(acc_x_err**2 + acc_y_err**2 + acc_z_err**2)
        
        # Store
        errors['cycle'].append(k)
        errors['time'].append(gt_next['time'])
        errors['pos_x_error'].append(pos_x_err)
        errors['pos_y_error'].append(pos_y_err)
        errors['pos_z_error'].append(pos_z_err)
        errors['pos_mag_error'].append(pos_mag_err)
        errors['vel_x_error'].append(vel_x_err)
        errors['vel_y_error'].append(vel_y_err)
        errors['vel_z_error'].append(vel_z_err)
        errors['vel_mag_error'].append(vel_mag_err)
        errors['acc_x_error'].append(acc_x_err)
        errors['acc_y_error'].append(acc_y_err)
        errors['acc_z_error'].append(acc_z_err)
        errors['acc_mag_error'].append(acc_mag_err)
    
    return pd.DataFrame(errors)

def compute_rmse_metrics(error_df):
    """Compute RMSE for all error types"""
    metrics = {}
    
    # Position RMSE
    metrics['pos_x_rmse'] = np.sqrt(np.mean(error_df['pos_x_error']**2))
    metrics['pos_y_rmse'] = np.sqrt(np.mean(error_df['pos_y_error']**2))
    metrics['pos_z_rmse'] = np.sqrt(np.mean(error_df['pos_z_error']**2))
    metrics['pos_mag_rmse'] = np.sqrt(np.mean(error_df['pos_mag_error']**2))
    
    # Velocity RMSE
    metrics['vel_x_rmse'] = np.sqrt(np.mean(error_df['vel_x_error']**2))
    metrics['vel_y_rmse'] = np.sqrt(np.mean(error_df['vel_y_error']**2))
    metrics['vel_z_rmse'] = np.sqrt(np.mean(error_df['vel_z_error']**2))
    metrics['vel_mag_rmse'] = np.sqrt(np.mean(error_df['vel_mag_error']**2))
    
    # Acceleration RMSE
    metrics['acc_x_rmse'] = np.sqrt(np.mean(error_df['acc_x_error']**2))
    metrics['acc_y_rmse'] = np.sqrt(np.mean(error_df['acc_y_error']**2))
    metrics['acc_z_rmse'] = np.sqrt(np.mean(error_df['acc_z_error']**2))
    metrics['acc_mag_rmse'] = np.sqrt(np.mean(error_df['acc_mag_error']**2))
    
    return metrics

def plot_error_time_series(error_df, dataset_name, implementation):
    """Plot error time series"""
    fig, axes = plt.subplots(3, 1, figsize=(14, 10))
    
    # Position errors
    axes[0].plot(error_df['time'], error_df['pos_x_error'], label='X', alpha=0.7)
    axes[0].plot(error_df['time'], error_df['pos_y_error'], label='Y', alpha=0.7)
    axes[0].plot(error_df['time'], error_df['pos_z_error'], label='Z', alpha=0.7)
    axes[0].plot(error_df['time'], error_df['pos_mag_error'], label='Magnitude', 
                 linewidth=2, color='black')
    axes[0].set_ylabel('Position Error (m)')
    axes[0].set_title(f'Single-Step Prediction Errors - {implementation} - {dataset_name}')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Velocity errors
    axes[1].plot(error_df['time'], error_df['vel_x_error'], label='X', alpha=0.7)
    axes[1].plot(error_df['time'], error_df['vel_y_error'], label='Y', alpha=0.7)
    axes[1].plot(error_df['time'], error_df['vel_z_error'], label='Z', alpha=0.7)
    axes[1].plot(error_df['time'], error_df['vel_mag_error'], label='Magnitude', 
                 linewidth=2, color='black')
    axes[1].set_ylabel('Velocity Error (m/s)')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    # Acceleration errors
    axes[2].plot(error_df['time'], error_df['acc_x_error'], label='X', alpha=0.7)
    axes[2].plot(error_df['time'], error_df['acc_y_error'], label='Y', alpha=0.7)
    axes[2].plot(error_df['time'], error_df['acc_z_error'], label='Z', alpha=0.7)
    axes[2].plot(error_df['time'], error_df['acc_mag_error'], label='Magnitude', 
                 linewidth=2, color='black')
    axes[2].set_ylabel('Acceleration Error (m/s²)')
    axes[2].set_xlabel('Time (s)')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)
    
    plt.tight_layout()
    
    plot_file = OUTPUT_DIR / f"single_step_errors_{implementation}_{dataset_name}.png"
    plt.savefig(plot_file, dpi=150)
    plt.close()
    
    return plot_file

def analyze_dataset(dataset_name):
    """Analyze single-step prediction for one dataset across all implementations"""
    print(f"\n{'='*80}")
    print(f"Dataset: {dataset_name}")
    print('='*80)
    
    # Load ground truth
    ground_truth = load_ground_truth(dataset_name)
    print(f"Ground truth cycles: {len(ground_truth)}")
    
    results = {}
    
    for impl in ['custom', 'filterpy', 'vhdl']:
        print(f"\nAnalyzing {impl} implementation...")
        
        try:
            # Load estimates
            estimates = load_ukf_outputs(dataset_name, impl)
            
            # Compute errors
            error_df = compute_single_step_errors(ground_truth, estimates)
            
            # Compute RMSE metrics
            metrics = compute_rmse_metrics(error_df)
            
            # Store results
            results[impl] = {
                'errors': error_df,
                'metrics': metrics
            }
            
            # Print metrics
            print(f"\n  Position RMSE:")
            print(f"    X:     {metrics['pos_x_rmse']:.4f} m")
            print(f"    Y:     {metrics['pos_y_rmse']:.4f} m")
            print(f"    Z:     {metrics['pos_z_rmse']:.4f} m")
            print(f"    3D Mag: {metrics['pos_mag_rmse']:.4f} m")
            
            print(f"\n  Velocity RMSE:")
            print(f"    X:     {metrics['vel_x_rmse']:.4f} m/s")
            print(f"    Y:     {metrics['vel_y_rmse']:.4f} m/s")
            print(f"    Z:     {metrics['vel_z_rmse']:.4f} m/s")
            print(f"    3D Mag: {metrics['vel_mag_rmse']:.4f} m/s")
            
            print(f"\n  Acceleration RMSE:")
            print(f"    X:     {metrics['acc_x_rmse']:.4f} m/s²")
            print(f"    Y:     {metrics['acc_y_rmse']:.4f} m/s²")
            print(f"    Z:     {metrics['acc_z_rmse']:.4f} m/s²")
            print(f"    3D Mag: {metrics['acc_mag_rmse']:.4f} m/s²")
            
            # Plot errors
            plot_file = plot_error_time_series(error_df, dataset_name, impl)
            print(f"\n  ✓ Plot saved: {plot_file.name}")
            
            # Save error CSV
            csv_file = OUTPUT_DIR / f"single_step_errors_{impl}_{dataset_name}.csv"
            error_df.to_csv(csv_file, index=False, float_format='%.6f')
            print(f"  ✓ Errors saved: {csv_file.name}")
            
        except FileNotFoundError as e:
            print(f"  ✗ {impl} outputs not found: {e}")
            results[impl] = None
    
    return results

def compare_implementations(all_results):
    """Compare RMSE across all implementations and datasets"""
    print(f"\n{'='*80}")
    print("IMPLEMENTATION COMPARISON")
    print('='*80)
    
    comparison_data = []
    
    for dataset_name, dataset_results in all_results.items():
        for impl, result in dataset_results.items():
            if result is None:
                continue
            
            metrics = result['metrics']
            comparison_data.append({
                'dataset': dataset_name,
                'implementation': impl,
                'pos_rmse': metrics['pos_mag_rmse'],
                'vel_rmse': metrics['vel_mag_rmse'],
                'acc_rmse': metrics['acc_mag_rmse']
            })
    
    if not comparison_data:
        print("No data available for comparison")
        return None
    
    df = pd.DataFrame(comparison_data)
    
    # Print comparison table
    print("\nPosition RMSE (m):")
    pivot = df.pivot(index='dataset', columns='implementation', values='pos_rmse')
    print(pivot.to_string(float_format=lambda x: f'{x:.4f}'))
    
    print("\nVelocity RMSE (m/s):")
    pivot = df.pivot(index='dataset', columns='implementation', values='vel_rmse')
    print(pivot.to_string(float_format=lambda x: f'{x:.4f}'))
    
    print("\nAcceleration RMSE (m/s²):")
    pivot = df.pivot(index='dataset', columns='implementation', values='acc_rmse')
    print(pivot.to_string(float_format=lambda x: f'{x:.4f}'))
    
    # Save comparison CSV
    csv_file = OUTPUT_DIR / "implementation_comparison.csv"
    df.to_csv(csv_file, index=False, float_format='%.6f')
    print(f"\n✓ Comparison saved: {csv_file}")
    
    # Plot comparison
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    for idx, (metric, ylabel) in enumerate([
        ('pos_rmse', 'Position RMSE (m)'),
        ('vel_rmse', 'Velocity RMSE (m/s)'),
        ('acc_rmse', 'Acceleration RMSE (m/s²)')
    ]):
        pivot = df.pivot(index='dataset', columns='implementation', values=metric)
        pivot.plot(kind='bar', ax=axes[idx], rot=45)
        axes[idx].set_ylabel(ylabel)
        axes[idx].set_xlabel('Dataset')
        axes[idx].legend(title='Implementation')
        axes[idx].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plot_file = OUTPUT_DIR / "implementation_comparison.png"
    plt.savefig(plot_file, dpi=150)
    plt.close()
    print(f"✓ Comparison plot: {plot_file.name}")
    
    return df

def main():
    print("="*80)
    print("SINGLE-STEP PREDICTION ANALYSIS")
    print("="*80)
    print("Analyzes k→k+1 prediction accuracy for:")
    print("  - Custom Python UKF")
    print("  - FilterPy UKF")
    print("  - VHDL UKF")
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Find all datasets
    datasets = sorted(DATA_DIR.glob("*.csv"))
    real_world = [d.stem for d in datasets if 'drone_euroc' in d.name or 'f1_' in d.name or 'synthetic' in d.name]
    
    if not real_world:
        print("\n✗ No datasets found")
        print("Run download_real_datasets.py and preprocessing scripts first")
        return
    
    print(f"\nFound {len(real_world)} datasets to analyze")
    
    all_results = {}
    for dataset_name in real_world:
        try:
            results = analyze_dataset(dataset_name)
            all_results[dataset_name] = results
        except Exception as e:
            print(f"\n✗ Error analyzing {dataset_name}: {e}")
            import traceback
            traceback.print_exc()
    
    # Compare implementations
    if all_results:
        compare_implementations(all_results)
    
    print(f"\n{'='*80}")
    print("ANALYSIS COMPLETE")
    print('='*80)
    print(f"Results directory: {OUTPUT_DIR}")
    print("\nNext step: Run analyze_multi_step_prediction.py")

if __name__ == "__main__":
    main()
