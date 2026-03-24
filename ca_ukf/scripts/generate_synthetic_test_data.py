#!/usr/bin/env python3
"""
Generate Synthetic Test Data for UKF Validation
Creates realistic drone-like trajectories for testing when real data unavailable
"""

import numpy as np
import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent
OUTPUT_DIR = BASE_DIR / "test_data" / "real_world"

DT = 0.02  # 50Hz
Q_SCALE = 2**24
MEAS_NOISE_STD = 1.0

def generate_circular_trajectory(num_cycles=500, radius=50.0, height=10.0):
    """Generate circular trajectory (drone-like)"""
    np.random.seed(42)
    
    data = []
    for k in range(num_cycles):
        t = k * DT
        
        # Circular motion with constant acceleration
        omega = 0.5  # rad/s
        theta = omega * t
        
        # Position
        x_pos = radius * np.cos(theta)
        y_pos = radius * np.sin(theta)
        z_pos = height + 2.0 * np.sin(0.2 * t)  # Gentle vertical oscillation
        
        # Velocity
        x_vel = -radius * omega * np.sin(theta)
        y_vel = radius * omega * np.cos(theta)
        z_vel = 2.0 * 0.2 * np.cos(0.2 * t)
        
        # Acceleration (centripetal + vertical)
        x_acc = -radius * omega**2 * np.cos(theta)
        y_acc = -radius * omega**2 * np.sin(theta)
        z_acc = -2.0 * 0.2**2 * np.sin(0.2 * t)
        
        # Add measurement noise
        noise_x = np.random.normal(0, MEAS_NOISE_STD)
        noise_y = np.random.normal(0, MEAS_NOISE_STD)
        noise_z = np.random.normal(0, MEAS_NOISE_STD)
        
        meas_x = x_pos + noise_x
        meas_y = y_pos + noise_y
        meas_z = z_pos + noise_z
        
        # Q24.24 conversion
        meas_x_q24 = int(meas_x * Q_SCALE)
        meas_y_q24 = int(meas_y * Q_SCALE)
        meas_z_q24 = int(meas_z * Q_SCALE)
        
        data.append({
            'cycle': k,
            'time': t,
            'gt_x_pos': x_pos, 'gt_y_pos': y_pos, 'gt_z_pos': z_pos,
            'gt_x_vel': x_vel, 'gt_y_vel': y_vel, 'gt_z_vel': z_vel,
            'gt_x_acc': x_acc, 'gt_y_acc': y_acc, 'gt_z_acc': z_acc,
            'meas_x': meas_x, 'meas_y': meas_y, 'meas_z': meas_z,
            'meas_x_q24': meas_x_q24, 'meas_y_q24': meas_y_q24, 'meas_z_q24': meas_z_q24,
            'noise_x': noise_x, 'noise_y': noise_y, 'noise_z': noise_z
        })
    
    return pd.DataFrame(data)

def generate_figure8_trajectory(num_cycles=600):
    """Generate figure-8 trajectory (vehicle-like)"""
    np.random.seed(43)
    
    data = []
    for k in range(num_cycles):
        t = k * DT
        
        # Figure-8 Lissajous curve
        omega_x = 1.0
        omega_y = 2.0
        A_x = 30.0
        A_y = 20.0
        
        # Position
        x_pos = A_x * np.sin(omega_x * t)
        y_pos = A_y * np.sin(omega_y * t)
        z_pos = 5.0  # Constant height (vehicle on ground)
        
        # Velocity
        x_vel = A_x * omega_x * np.cos(omega_x * t)
        y_vel = A_y * omega_y * np.cos(omega_y * t)
        z_vel = 0.0
        
        # Acceleration
        x_acc = -A_x * omega_x**2 * np.sin(omega_x * t)
        y_acc = -A_y * omega_y**2 * np.sin(omega_y * t)
        z_acc = 0.0
        
        # Add measurement noise
        noise_x = np.random.normal(0, MEAS_NOISE_STD)
        noise_y = np.random.normal(0, MEAS_NOISE_STD)
        noise_z = np.random.normal(0, MEAS_NOISE_STD)
        
        meas_x = x_pos + noise_x
        meas_y = y_pos + noise_y
        meas_z = z_pos + noise_z
        
        # Q24.24 conversion
        meas_x_q24 = int(meas_x * Q_SCALE)
        meas_y_q24 = int(meas_y * Q_SCALE)
        meas_z_q24 = int(meas_z * Q_SCALE)
        
        data.append({
            'cycle': k,
            'time': t,
            'gt_x_pos': x_pos, 'gt_y_pos': y_pos, 'gt_z_pos': z_pos,
            'gt_x_vel': x_vel, 'gt_y_vel': y_vel, 'gt_z_vel': z_vel,
            'gt_x_acc': x_acc, 'gt_y_acc': y_acc, 'gt_z_acc': z_acc,
            'meas_x': meas_x, 'meas_y': meas_y, 'meas_z': meas_z,
            'meas_x_q24': meas_x_q24, 'meas_y_q24': meas_y_q24, 'meas_z_q24': meas_z_q24,
            'noise_x': noise_x, 'noise_y': noise_y, 'noise_z': noise_z
        })
    
    return pd.DataFrame(data)

def main():
    print("="*80)
    print("SYNTHETIC TEST DATA GENERATOR")
    print("="*80)
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Generate drone-like trajectory
    print("\nGenerating drone circular trajectory (500 cycles)...")
    drone_df = generate_circular_trajectory(num_cycles=500)
    drone_file = OUTPUT_DIR / "synthetic_drone_500cycles.csv"
    drone_df.to_csv(drone_file, index=False, float_format='%.6f')
    print(f"✓ Saved: {drone_file.name}")
    
    # Generate vehicle-like trajectory  
    print("\nGenerating vehicle figure-8 trajectory (600 cycles)...")
    vehicle_df = generate_figure8_trajectory(num_cycles=600)
    vehicle_file = OUTPUT_DIR / "synthetic_vehicle_600cycles.csv"
    vehicle_df.to_csv(vehicle_file, index=False, float_format='%.6f')
    print(f"✓ Saved: {vehicle_file.name}")
    
    print(f"\n{'='*80}")
    print("SYNTHETIC DATA GENERATION COMPLETE")
    print('='*80)
    print(f"Output directory: {OUTPUT_DIR}")
    print("\nThese synthetic datasets can be used for UKF validation testing.")
    print("Next: Run automated_test_runner.py")

if __name__ == "__main__":
    main()
