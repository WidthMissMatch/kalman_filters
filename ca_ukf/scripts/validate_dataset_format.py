#!/usr/bin/env python3
"""
Validate Dataset Format for UKF Compatibility
Checks:
- CSV column structure
- Constant time step (dt=0.02s)
- Q24.24 conversion accuracy
- Noise characteristics
- Trajectory feasibility
"""

import numpy as np
import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR / "test_data" / "real_world"

EXPECTED_COLUMNS = [
    'cycle', 'time',
    'gt_x_pos', 'gt_y_pos', 'gt_z_pos',
    'gt_x_vel', 'gt_y_vel', 'gt_z_vel',
    'gt_x_acc', 'gt_y_acc', 'gt_z_acc',
    'meas_x', 'meas_y', 'meas_z',
    'meas_x_q24', 'meas_y_q24', 'meas_z_q24',
    'noise_x', 'noise_y', 'noise_z'
]

DT_EXPECTED = 0.02
Q_SCALE = 2**24

class ValidationResult:
    def __init__(self, dataset_name):
        self.dataset_name = dataset_name
        self.passed = True
        self.warnings = []
        self.errors = []
    
    def add_warning(self, msg):
        self.warnings.append(msg)
    
    def add_error(self, msg):
        self.errors.append(msg)
        self.passed = False
    
    def summary(self):
        status = "✓ PASS" if self.passed else "✗ FAIL"
        lines = [f"\n{self.dataset_name}: {status}"]
        
        if self.errors:
            lines.append(f"  Errors ({len(self.errors)}):")
            for err in self.errors:
                lines.append(f"    - {err}")
        
        if self.warnings:
            lines.append(f"  Warnings ({len(self.warnings)}):")
            for warn in self.warnings:
                lines.append(f"    - {warn}")
        
        return "\n".join(lines)

def validate_columns(df, result):
    """Check all required columns exist"""
    missing = set(EXPECTED_COLUMNS) - set(df.columns)
    if missing:
        result.add_error(f"Missing columns: {missing}")
    
    extra = set(df.columns) - set(EXPECTED_COLUMNS)
    if extra:
        result.add_warning(f"Extra columns: {extra}")

def validate_time_step(df, result):
    """Check constant time step"""
    dt_values = df['time'].diff().dropna()
    dt_mean = dt_values.mean()
    dt_std = dt_values.std()
    
    if abs(dt_mean - DT_EXPECTED) > 0.001:
        result.add_error(f"Time step mean {dt_mean:.4f} != expected {DT_EXPECTED}")
    
    if dt_std > 0.0001:
        result.add_warning(f"Time step varies (std={dt_std:.6f})")

def validate_q24_conversion(df, result):
    """Check Q24.24 fixed-point conversion accuracy"""
    for axis in ['x', 'y', 'z']:
        meas_col = f'meas_{axis}'
        q24_col = f'meas_{axis}_q24'
        
        # Convert back from Q24.24
        reconstructed = df[q24_col] / Q_SCALE
        error = np.abs(df[meas_col] - reconstructed)
        max_error = error.max()
        
        # Should be within 1 LSB (1/2^24)
        if max_error > 2.0 / Q_SCALE:
            result.add_error(f"{axis} Q24.24 conversion error: {max_error:.9f} m")

def validate_noise(df, result):
    """Check noise characteristics"""
    for axis in ['x', 'y', 'z']:
        noise = df[f'noise_{axis}']
        mean = noise.mean()
        std = noise.std()
        
        # Check zero mean
        if abs(mean) > 0.1:
            result.add_warning(f"{axis} noise mean {mean:.4f} != 0")
        
        # Check std close to 1.0m (expected GPS noise)
        if abs(std - 1.0) > 0.2:
            result.add_warning(f"{axis} noise std {std:.4f} != 1.0")

def validate_trajectory_physics(df, result):
    """Check trajectory is physically feasible"""
    # Check acceleration magnitudes
    acc_mag = np.sqrt(df['gt_x_acc']**2 + df['gt_y_acc']**2 + df['gt_z_acc']**2)
    max_acc = acc_mag.max()
    
    # Reasonable limits
    if max_acc > 100:  # > 10g
        result.add_warning(f"Very high acceleration: {max_acc:.2f} m/s²")
    
    # Check velocity continuity
    vel_mag = np.sqrt(df['gt_x_vel']**2 + df['gt_y_vel']**2 + df['gt_z_vel']**2)
    vel_jumps = vel_mag.diff().abs()
    max_jump = vel_jumps.max()
    
    if max_jump > 20:  # >20 m/s change in 0.02s
        result.add_warning(f"Large velocity jump: {max_jump:.2f} m/s")

def validate_dataset(csv_file):
    """Validate one dataset"""
    result = ValidationResult(csv_file.stem)
    
    try:
        df = pd.read_csv(csv_file)
        
        validate_columns(df, result)
        validate_time_step(df, result)
        validate_q24_conversion(df, result)
        validate_noise(df, result)
        validate_trajectory_physics(df, result)
        
    except Exception as e:
        result.add_error(f"Failed to load/process: {e}")
    
    return result

def main():
    print("="*80)
    print("UKF DATASET FORMAT VALIDATOR")
    print("="*80)
    print(f"Data directory: {DATA_DIR}")
    print(f"Expected dt: {DT_EXPECTED} s")
    print(f"Expected columns: {len(EXPECTED_COLUMNS)}")
    
    # Find all CSV files
    csv_files = list(DATA_DIR.glob("*.csv"))
    real_world_csvs = [f for f in csv_files if 'drone_euroc' in f.name or 'f1_' in f.name]
    
    if not real_world_csvs:
        print("\n✗ No real-world datasets found")
        print("Run download_real_datasets.py and preprocessing scripts first")
        return
    
    print(f"\nFound {len(real_world_csvs)} datasets to validate")
    
    # Validate each dataset
    results = []
    for csv_file in sorted(real_world_csvs):
        print(f"\nValidating {csv_file.name}...")
        result = validate_dataset(csv_file)
        results.append(result)
        print(result.summary())
    
    # Overall summary
    print("\n" + "="*80)
    print("VALIDATION SUMMARY")
    print("="*80)
    
    passed = sum(1 for r in results if r.passed)
    failed = len(results) - passed
    
    print(f"Total datasets: {len(results)}")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    
    if failed == 0:
        print("\n✓ ALL DATASETS VALID FOR UKF")
        print("Ready to proceed with UKF validation")
    else:
        print("\n✗ SOME DATASETS HAVE ERRORS")
        print("Fix errors before proceeding")
    
    # Save report
    report_file = DATA_DIR / "validation_report.txt"
    with open(report_file, 'w') as f:
        f.write("UKF Dataset Validation Report\n")
        f.write("="*80 + "\n\n")
        for result in results:
            f.write(result.summary() + "\n")
        f.write("\n" + "="*80 + "\n")
        f.write(f"Total: {len(results)}, Passed: {passed}, Failed: {failed}\n")
    
    print(f"\nReport saved to: {report_file}")

if __name__ == "__main__":
    main()
