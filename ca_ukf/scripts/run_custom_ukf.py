#!/usr/bin/env python3
import pandas as pd
import numpy as np
import sys
from pathlib import Path
from ukf_9d_ca_reference import UKF_9D_CA

if len(sys.argv) != 3:
    print("Usage: python run_custom_ukf.py <input_csv> <output_csv>")
    sys.exit(1)

dataset_path = sys.argv[1]
output_path = sys.argv[2]
df = pd.read_csv(dataset_path)
ukf = UKF_9D_CA(dt=0.02, q_power=5.0, r_diag=1.0)

results = []
for idx, row in df.iterrows():
    z = np.array([row['meas_x'], row['meas_y'], row['meas_z']])
    x, P, nu = ukf.process_measurement(z)
    results.append({
        'cycle': row['cycle'], 'time': row['time'],
        'est_x_pos': x[0], 'est_x_vel': x[1], 'est_x_acc': x[2],
        'est_y_pos': x[3], 'est_y_vel': x[4], 'est_y_acc': x[5],
        'est_z_pos': x[6], 'est_z_vel': x[7], 'est_z_acc': x[8],
        'cov_x_pos': P[0,0], 'cov_x_vel': P[1,1], 'cov_x_acc': P[2,2],
        'cov_y_pos': P[3,3], 'cov_y_vel': P[4,4], 'cov_y_acc': P[5,5],
        'cov_z_pos': P[6,6], 'cov_z_vel': P[7,7], 'cov_z_acc': P[8,8],
    })
Path(output_path).parent.mkdir(parents=True, exist_ok=True)
pd.DataFrame(results).to_csv(output_path, index=False, float_format='%.6f')
print(f"✓ Saved {len(results)} cycles to {output_path}")
