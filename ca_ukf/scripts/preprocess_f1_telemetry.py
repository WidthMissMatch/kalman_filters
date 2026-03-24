#!/usr/bin/env python3
"""Preprocess F1 telemetry to UKF dataset format"""

import pandas as pd
import numpy as np
from pathlib import Path
import argparse

def preprocess_f1_circuit(input_file, output_file, target_cycles=750, gps_noise_std=1.0):
    """
    Convert F1 telemetry to UKF dataset format

    Args:
        input_file: Path to F1 telemetry pickle file
        output_file: Path to output CSV file
        target_cycles: Number of cycles to extract
        gps_noise_std: GPS measurement noise standard deviation (meters)
    """
    print(f"\nProcessing {input_file.name}...")

    # Load F1 telemetry
    telemetry = pd.read_pickle(input_file)

    # Extract X, Y, Z positions and time
    positions = telemetry[['Time', 'X', 'Y', 'Z']].copy()

    # Convert Time from timedelta to seconds
    positions['time_sec'] = positions['Time'].dt.total_seconds()
    positions['time_sec'] = positions['time_sec'] - positions['time_sec'].iloc[0]  # Start from 0

    # Resample to 50Hz (dt = 0.02s)
    dt = 0.02
    max_time = positions['time_sec'].iloc[-1]

    # Create uniform time grid
    target_time = np.arange(0, max_time, dt)

    # Interpolate X, Y, Z to uniform 50Hz grid
    x_interp = np.interp(target_time, positions['time_sec'], positions['X'])
    y_interp = np.interp(target_time, positions['time_sec'], positions['Y'])
    z_interp = np.interp(target_time, positions['time_sec'], positions['Z'])

    # Find the most dynamic section (highest variance in position)
    window_size = target_cycles
    if len(x_interp) > window_size:
        # Compute variance in sliding windows
        best_start = 0
        max_variance = 0

        for start in range(len(x_interp) - window_size):
            end = start + window_size
            x_var = np.var(x_interp[start:end])
            y_var = np.var(y_interp[start:end])
            z_var = np.var(z_interp[start:end])
            total_var = x_var + y_var + z_var

            if total_var > max_variance:
                max_variance = total_var
                best_start = start

        # Extract most dynamic section
        x_section = x_interp[best_start:best_start + window_size]
        y_section = y_interp[best_start:best_start + window_size]
        z_section = z_interp[best_start:best_start + window_size]
        time_section = target_time[best_start:best_start + window_size]
    else:
        # Use entire trajectory if shorter than target
        x_section = x_interp
        y_section = y_interp
        z_section = z_interp
        time_section = target_time

    # Add GPS measurement noise
    np.random.seed(42)  # Reproducible noise
    meas_x = x_section + np.random.normal(0, gps_noise_std, len(x_section))
    meas_y = y_section + np.random.normal(0, gps_noise_std, len(y_section))
    meas_z = z_section + np.random.normal(0, gps_noise_std, len(z_section))

    # Create UKF dataset
    dataset = pd.DataFrame({
        'cycle': np.arange(len(x_section)),
        'time': time_section,
        'gt_x_pos': x_section,
        'gt_y_pos': y_section,
        'gt_z_pos': z_section,
        'meas_x': meas_x,
        'meas_y': meas_y,
        'meas_z': meas_z
    })

    # Save to CSV
    dataset.to_csv(output_file, index=False)

    # Compute statistics
    x_range = np.max(x_section) - np.min(x_section)
    y_range = np.max(y_section) - np.min(y_section)
    z_range = np.max(z_section) - np.min(z_section)

    # Estimate speed and acceleration
    vx = np.diff(x_section) / dt
    vy = np.diff(y_section) / dt
    vz = np.diff(z_section) / dt
    speed = np.sqrt(vx**2 + vy**2 + vz**2)

    ax = np.diff(vx) / dt
    ay = np.diff(vy) / dt
    az = np.diff(vz) / dt
    accel = np.sqrt(ax**2 + ay**2 + az**2)

    print(f"  ✓ Cycles: {len(dataset)}")
    print(f"  ✓ Duration: {time_section[-1]:.2f}s")
    print(f"  ✓ Position range: X={x_range:.1f}m, Y={y_range:.1f}m, Z={z_range:.1f}m")
    print(f"  ✓ Max speed: {np.max(speed):.1f} m/s ({np.max(speed)*3.6:.1f} km/h)")
    print(f"  ✓ Max accel: {np.max(accel):.1f} m/s² ({np.max(accel)/9.81:.1f}G)")
    print(f"  ✓ Saved to {output_file.name}")

    return dataset

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Preprocess F1 telemetry to UKF format')
    parser.add_argument('--circuits', nargs='+', default=['monaco', 'singapore', 'suzuka', 'silverstone'],
                        help='Circuits to process')
    parser.add_argument('--cycles', type=int, default=750, help='Number of cycles to extract')
    parser.add_argument('--noise', type=float, default=1.0, help='GPS noise std dev (meters)')

    args = parser.parse_args()

    raw_dir = Path('../test_data/real_world/raw/f1')
    output_dir = Path('../test_data/real_world')
    output_dir.mkdir(parents=True, exist_ok=True)

    print("=== F1 Telemetry Preprocessing ===")

    for circuit in args.circuits:
        input_file = raw_dir / f'{circuit}_2024.pkl'
        output_file = output_dir / f'f1_{circuit}_2024_{args.cycles}cycles.csv'

        if not input_file.exists():
            print(f"  ✗ {input_file.name} not found, skipping")
            continue

        try:
            preprocess_f1_circuit(input_file, output_file, args.cycles, args.noise)
        except Exception as e:
            print(f"  ✗ ERROR: {e}")
            continue

    print("\n=== F1 Preprocessing Complete ===")
