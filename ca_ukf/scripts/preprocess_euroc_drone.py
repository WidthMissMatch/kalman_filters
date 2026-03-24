#!/usr/bin/env python3
"""
Preprocess ETH Zurich EuRoC MAV Dataset for UKF Validation
Converts drone flight data to UKF-compatible format:
- Resample to 50Hz (dt=0.02s)
- Compute velocity/acceleration from position
- Add GPS-like measurement noise
- Generate Q24.24 fixed-point representations
"""

import numpy as np
import pandas as pd
from pathlib import Path
from scipy.interpolate import interp1d

# Configuration
BASE_DIR = Path(__file__).parent.parent
RAW_DATA_DIR = BASE_DIR / "test_data" / "real_world" / "raw" / "euroc"
OUTPUT_DIR = BASE_DIR / "test_data" / "real_world"

# UKF Parameters
DT = 0.02  # 50Hz sampling rate
Q_SCALE = 2**24  # Q24.24 fixed-point scale
MEAS_NOISE_STD = 1.0  # GPS noise standard deviation (meters)
MAX_CYCLES = 500  # Limit trajectory length

def load_euroc_groundtruth(dataset_name):
    """Load EuRoC ground truth data from state_groundtruth_estimate0 directory"""
    dataset_dir = RAW_DATA_DIR / dataset_name / "mav0" / "state_groundtruth_estimate0"
    data_file = dataset_dir / "data.csv"
    
    if not data_file.exists():
        raise FileNotFoundError(f"Ground truth file not found: {data_file}")
    
    # EuRoC format: timestamp,p_x,p_y,p_z,q_w,q_x,q_y,q_z,v_x,v_y,v_z,b_w_x,b_w_y,b_w_z,b_a_x,b_a_y,b_a_z
    df = pd.read_csv(data_file, comment='#')
    
    # Convert timestamp from nanoseconds to seconds
    df['time'] = (df['#timestamp'] - df['#timestamp'].iloc[0]) / 1e9
    
    # Extract position (meters) and velocity (m/s)
    df['x_pos'] = df['p_RS_R_x']
    df['y_pos'] = df['p_RS_R_y']
    df['z_pos'] = df['p_RS_R_z']
    df['x_vel'] = df['v_RS_R_x']
    df['y_vel'] = df['v_RS_R_y']
    df['z_vel'] = df['v_RS_R_z']
    
    return df[['time', 'x_pos', 'y_pos', 'z_pos', 'x_vel', 'y_vel', 'z_vel']]

def resample_to_constant_dt(df, dt=DT):
    """Resample trajectory to constant time step using interpolation"""
    t_start = df['time'].iloc[0]
    t_end = df['time'].iloc[-1]
    
    # Create uniform time grid
    t_uniform = np.arange(t_start, t_end, dt)
    
    # Limit to max cycles
    if len(t_uniform) > MAX_CYCLES:
        t_uniform = t_uniform[:MAX_CYCLES]
    
    # Interpolate position and velocity
    result = {'time': t_uniform}
    
    for col in ['x_pos', 'y_pos', 'z_pos', 'x_vel', 'y_vel', 'z_vel']:
        interp_func = interp1d(df['time'], df[col], kind='cubic', fill_value='extrapolate')
        result[col] = interp_func(t_uniform)
    
    return pd.DataFrame(result)

def compute_acceleration(df, dt=DT):
    """Compute acceleration from velocity using finite differences"""
    # Central difference for interior points
    df['x_acc'] = np.gradient(df['x_vel'], dt)
    df['y_acc'] = np.gradient(df['y_vel'], dt)
    df['z_acc'] = np.gradient(df['z_vel'], dt)
    
    return df

def add_measurement_noise(df, noise_std=MEAS_NOISE_STD, seed=42):
    """Add Gaussian noise to position measurements (GPS-like noise)"""
    np.random.seed(seed)
    
    # Generate noise samples
    noise_x = np.random.normal(0, noise_std, len(df))
    noise_y = np.random.normal(0, noise_std, len(df))
    noise_z = np.random.normal(0, noise_std, len(df))
    
    # Add noise to position
    df['meas_x'] = df['x_pos'] + noise_x
    df['meas_y'] = df['y_pos'] + noise_y
    df['meas_z'] = df['z_pos'] + noise_z
    
    # Store noise separately for analysis
    df['noise_x'] = noise_x
    df['noise_y'] = noise_y
    df['noise_z'] = noise_z
    
    return df

def convert_to_q24_24(df):
    """Convert measurements to Q24.24 fixed-point format"""
    df['meas_x_q24'] = (df['meas_x'] * Q_SCALE).astype(np.int64)
    df['meas_y_q24'] = (df['meas_y'] * Q_SCALE).astype(np.int64)
    df['meas_z_q24'] = (df['meas_z'] * Q_SCALE).astype(np.int64)
    
    return df

def format_for_ukf(df):
    """Arrange columns in UKF expected format"""
    df['cycle'] = np.arange(len(df))
    
    # Rename ground truth columns with gt_ prefix
    df = df.rename(columns={
        'x_pos': 'gt_x_pos', 'y_pos': 'gt_y_pos', 'z_pos': 'gt_z_pos',
        'x_vel': 'gt_x_vel', 'y_vel': 'gt_y_vel', 'z_vel': 'gt_z_vel',
        'x_acc': 'gt_x_acc', 'y_acc': 'gt_y_acc', 'z_acc': 'gt_z_acc'
    })
    
    # Select and order columns
    columns = [
        'cycle', 'time',
        'gt_x_pos', 'gt_y_pos', 'gt_z_pos',
        'gt_x_vel', 'gt_y_vel', 'gt_z_vel',
        'gt_x_acc', 'gt_y_acc', 'gt_z_acc',
        'meas_x', 'meas_y', 'meas_z',
        'meas_x_q24', 'meas_y_q24', 'meas_z_q24',
        'noise_x', 'noise_y', 'noise_z'
    ]
    
    return df[columns]

def generate_dataset_summary(df, dataset_name):
    """Generate summary statistics for the dataset"""
    summary = f"""
Dataset: {dataset_name}
Cycles: {len(df)}
Duration: {df['time'].iloc[-1]:.2f} seconds
Sampling rate: {1/DT:.0f} Hz (dt = {DT} s)

Position range (meters):
  X: [{df['gt_x_pos'].min():.2f}, {df['gt_x_pos'].max():.2f}]
  Y: [{df['gt_y_pos'].min():.2f}, {df['gt_y_pos'].max():.2f}]
  Z: [{df['gt_z_pos'].min():.2f}, {df['gt_z_pos'].max():.2f}]

Velocity range (m/s):
  X: [{df['gt_x_vel'].min():.2f}, {df['gt_x_vel'].max():.2f}]
  Y: [{df['gt_y_vel'].min():.2f}, {df['gt_y_vel'].max():.2f}]
  Z: [{df['gt_z_vel'].min():.2f}, {df['gt_z_vel'].max():.2f}]

Acceleration range (m/s²):
  X: [{df['gt_x_acc'].min():.2f}, {df['gt_x_acc'].max():.2f}]
  Y: [{df['gt_y_acc'].min():.2f}, {df['gt_y_acc'].max():.2f}]
  Z: [{df['gt_z_acc'].min():.2f}, {df['gt_z_acc'].max():.2f}]

Measurement noise (actual):
  Std X: {df['noise_x'].std():.4f} m
  Std Y: {df['noise_y'].std():.4f} m
  Std Z: {df['noise_z'].std():.4f} m
"""
    return summary

def process_euroc_dataset(dataset_name):
    """Complete preprocessing pipeline for one EuRoC dataset"""
    print(f"\nProcessing {dataset_name}...")
    
    # Load ground truth
    print("  Loading ground truth data...")
    df = load_euroc_groundtruth(dataset_name)
    print(f"  Loaded {len(df)} samples")
    
    # Resample to constant dt
    print(f"  Resampling to {1/DT:.0f} Hz (dt={DT}s)...")
    df = resample_to_constant_dt(df, DT)
    print(f"  Resampled to {len(df)} cycles")
    
    # Compute acceleration
    print("  Computing acceleration...")
    df = compute_acceleration(df, DT)
    
    # Add measurement noise
    print(f"  Adding GPS noise (σ={MEAS_NOISE_STD}m)...")
    df = add_measurement_noise(df, MEAS_NOISE_STD)
    
    # Convert to Q24.24
    print("  Converting to Q24.24 fixed-point...")
    df = convert_to_q24_24(df)
    
    # Format for UKF
    print("  Formatting for UKF...")
    df = format_for_ukf(df)
    
    # Save to CSV
    output_file = OUTPUT_DIR / f"drone_euroc_{dataset_name.lower()}_{len(df)}cycles.csv"
    df.to_csv(output_file, index=False, float_format='%.6f')
    print(f"  ✓ Saved to: {output_file}")
    
    # Generate summary
    summary = generate_dataset_summary(df, dataset_name)
    summary_file = OUTPUT_DIR / f"drone_euroc_{dataset_name.lower()}_summary.txt"
    with open(summary_file, 'w') as f:
        f.write(summary)
    print(f"  ✓ Summary saved to: {summary_file}")
    
    return df

def main():
    print("="*80)
    print("ETH EUROC DRONE DATA PREPROCESSOR")
    print("="*80)
    
    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Process available datasets
    datasets = ["MH_01_easy", "MH_02_easy"]
    
    results = {}
    for dataset_name in datasets:
        dataset_dir = RAW_DATA_DIR / dataset_name
        if not dataset_dir.exists():
            print(f"\n✗ {dataset_name} not found, skipping...")
            print(f"  Run download_real_datasets.py first")
            continue
        
        try:
            df = process_euroc_dataset(dataset_name)
            results[dataset_name] = df
        except Exception as e:
            print(f"\n✗ Error processing {dataset_name}: {e}")
            continue
    
    print("\n" + "="*80)
    print("PREPROCESSING COMPLETE")
    print("="*80)
    print(f"\nProcessed {len(results)} datasets")
    print(f"Output directory: {OUTPUT_DIR}")
    print("\nNext step: Run validate_dataset_format.py to verify formatting")

if __name__ == "__main__":
    main()
