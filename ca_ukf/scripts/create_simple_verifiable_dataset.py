#!/usr/bin/env python3
"""
Create a SIMPLE, MANUALLY VERIFIABLE dataset for UKF validation

Trajectory: Constant velocity (SIMPLEST case, easy to verify)
- Initial position: [0, 0, 0] m
- Constant velocity: [1.0, 0.5, 0.2] m/s
- Time step: 0.02s (20ms)
- Duration: 10 cycles (0.2s)

Ground truth is trivial: x(t) = x0 + v*t
No acceleration, so predictions should be nearly perfect
"""

import numpy as np
import pandas as pd

def to_q24_24(value):
    """Convert float to Q24.24 fixed-point integer"""
    return int(value * (2**24))

def create_constant_velocity_dataset(num_cycles=10, dt=0.02):
    """
    Create constant velocity trajectory

    Ground truth:
    - x(t) = v_x * t = 1.0 * t
    - y(t) = v_y * t = 0.5 * t
    - z(t) = v_z * t = 0.2 * t
    """

    # Constants
    v_x = 1.0  # m/s
    v_y = 0.5  # m/s
    v_z = 0.2  # m/s

    # Measurement noise
    noise_std = 0.05  # m (5cm standard deviation)
    np.random.seed(42)  # Fixed seed for reproducibility

    data = []

    print("=" * 80)
    print("CREATING CONSTANT VELOCITY DATASET")
    print("=" * 80)
    print(f"Velocity: vx={v_x} m/s, vy={v_y} m/s, vz={v_z} m/s")
    print(f"Time step: {dt} s")
    print(f"Cycles: {num_cycles}")
    print(f"Measurement noise: {noise_std} m (std dev)")
    print()

    for i in range(num_cycles):
        t = i * dt

        # Ground truth (exact)
        gt_x = v_x * t
        gt_y = v_y * t
        gt_z = v_z * t

        # Add measurement noise
        noise_x = np.random.normal(0, noise_std)
        noise_y = np.random.normal(0, noise_std)
        noise_z = np.random.normal(0, noise_std)

        meas_x = gt_x + noise_x
        meas_y = gt_y + noise_y
        meas_z = gt_z + noise_z

        # Convert to Q24.24 for VHDL
        meas_x_q24 = to_q24_24(meas_x)
        meas_y_q24 = to_q24_24(meas_y)
        meas_z_q24 = to_q24_24(meas_z)

        data.append({
            'cycle': i,
            'time': t,
            'gt_x_pos': gt_x,
            'gt_y_pos': gt_y,
            'gt_z_pos': gt_z,
            'gt_x_vel': v_x,
            'gt_y_vel': v_y,
            'gt_z_vel': v_z,
            'gt_x_acc': 0.0,
            'gt_y_acc': 0.0,
            'gt_z_acc': 0.0,
            'meas_x': meas_x,
            'meas_y': meas_y,
            'meas_z': meas_z,
            'meas_x_q24': meas_x_q24,
            'meas_y_q24': meas_y_q24,
            'meas_z_q24': meas_z_q24,
            'noise_x': noise_x,
            'noise_y': noise_y,
            'noise_z': noise_z
        })

        print(f"Cycle {i}: t={t:.3f}s")
        print(f"  Ground truth: ({gt_x:.4f}, {gt_y:.4f}, {gt_z:.4f})")
        print(f"  Measurement:  ({meas_x:.4f}, {meas_y:.4f}, {meas_z:.4f})")
        print(f"  Q24.24:       ({meas_x_q24}, {meas_y_q24}, {meas_z_q24})")
        print()

    df = pd.DataFrame(data)

    # Save CSV
    output_file = '../test_data/constant_velocity_10cycles.csv'
    df.to_csv(output_file, index=False)
    print(f"Dataset saved to: {output_file}")
    print()

    # Print summary
    print("=" * 80)
    print("DATASET SUMMARY")
    print("=" * 80)
    print(f"Total cycles: {len(df)}")
    print(f"Duration: {df['time'].iloc[-1]:.3f} s")
    print(f"Position range:")
    print(f"  X: {df['gt_x_pos'].min():.4f} to {df['gt_x_pos'].max():.4f} m")
    print(f"  Y: {df['gt_y_pos'].min():.4f} to {df['gt_y_pos'].max():.4f} m")
    print(f"  Z: {df['gt_z_pos'].min():.4f} to {df['gt_z_pos'].max():.4f} m")
    print(f"Measurement noise RMS:")
    print(f"  X: {np.sqrt(np.mean(df['noise_x']**2)):.4f} m")
    print(f"  Y: {np.sqrt(np.mean(df['noise_y']**2)):.4f} m")
    print(f"  Z: {np.sqrt(np.mean(df['noise_z']**2)):.4f} m")
    print()

    return df

if __name__ == '__main__':
    df = create_constant_velocity_dataset(num_cycles=10, dt=0.02)

    print("=" * 80)
    print("MANUAL VERIFICATION")
    print("=" * 80)
    print("Expected ground truth at t=0.18s (cycle 9):")
    print(f"  x = 1.0 * 0.18 = 0.18 m")
    print(f"  y = 0.5 * 0.18 = 0.09 m")
    print(f"  z = 0.2 * 0.18 = 0.036 m")
    print()
    print("Actual:")
    last = df.iloc[-1]
    print(f"  x = {last['gt_x_pos']:.4f} m")
    print(f"  y = {last['gt_y_pos']:.4f} m")
    print(f"  z = {last['gt_z_pos']:.4f} m")
    print()
    if abs(last['gt_x_pos'] - 0.18) < 0.0001:
        print("✅ VERIFICATION PASSED!")
    else:
        print("❌ VERIFICATION FAILED!")
