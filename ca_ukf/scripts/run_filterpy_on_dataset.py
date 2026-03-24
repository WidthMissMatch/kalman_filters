#!/usr/bin/env python3
"""
Run FilterPy UKF on Real-World Datasets
Processes all datasets and saves outputs for comparison
"""

import numpy as np
import pandas as pd
from pathlib import Path
from ukf_9d_ca_filterpy import UKF_9D_CA_FilterPy

BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR / "test_data" / "real_world"
OUTPUT_DIR = BASE_DIR / "results" / "python_outputs" / "filterpy"

def run_ukf_on_dataset(csv_file, ukf_params=None):
    """Run FilterPy UKF on one dataset"""
    if ukf_params is None:
        ukf_params = {'dt': 0.02, 'q_power': 5.0, 'r_diag': 1.0}
    
    # Load dataset
    df = pd.read_csv(csv_file)
    
    # Create UKF
    ukf = UKF_9D_CA_FilterPy(**ukf_params)
    
    # Storage for results
    results = []
    
    for idx, row in df.iterrows():
        # Measurement
        z = np.array([row['meas_x'], row['meas_y'], row['meas_z']])
        
        # Process
        ukf.process_measurement(z)
        
        # Get estimates
        state = ukf.get_state()
        cov_diag = ukf.get_covariance_diagonal()
        
        # Store
        result = {
            'cycle': row['cycle'],
            'time': row['time'],
            'est_x_pos': state[0], 'est_x_vel': state[1], 'est_x_acc': state[2],
            'est_y_pos': state[3], 'est_y_vel': state[4], 'est_y_acc': state[5],
            'est_z_pos': state[6], 'est_z_vel': state[7], 'est_z_acc': state[8],
            'cov_x_pos': cov_diag[0], 'cov_x_vel': cov_diag[1], 'cov_x_acc': cov_diag[2],
            'cov_y_pos': cov_diag[3], 'cov_y_vel': cov_diag[4], 'cov_y_acc': cov_diag[5],
            'cov_z_pos': cov_diag[6], 'cov_z_vel': cov_diag[7], 'cov_z_acc': cov_diag[8]
        }
        results.append(result)
    
    return pd.DataFrame(results)

def main():
    print("="*80)
    print("FILTERPY UKF - DATASET PROCESSOR")
    print("="*80)
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Find datasets
    datasets = sorted(DATA_DIR.glob("*.csv"))
    real_world = [d for d in datasets if 'drone_euroc' in d.name or 'f1_' in d.name or 'synthetic' in d.name]

    if not real_world:
        print("No datasets found. Run preprocessing scripts first.")
        return
    
    print(f"Found {len(real_world)} datasets")
    
    for dataset_file in real_world:
        print(f"\nProcessing {dataset_file.name}...")
        
        try:
            results = run_ukf_on_dataset(dataset_file)
            
            output_file = OUTPUT_DIR / f"filterpy_{dataset_file.stem}.csv"
            results.to_csv(output_file, index=False, float_format='%.6f')
            
            print(f"  ✓ Saved {len(results)} cycles to {output_file.name}")
            
        except Exception as e:
            print(f"  ✗ Error: {e}")
            continue
    
    print("\n" + "="*80)
    print("FILTERPY PROCESSING COMPLETE")
    print(f"Results: {OUTPUT_DIR}")

if __name__ == "__main__":
    main()
