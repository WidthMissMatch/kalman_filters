#!/usr/bin/env python3
"""
Dataset Adapter for Real-World Trajectory Data

Converts publicly available trajectory datasets to UKF-compatible format:
- ETH UAV datasets
- KITTI odometry
- CMU Motion Capture
- Custom CSV formats

Output format matches python_reference_9d_ca.csv structure
"""

import numpy as np
import pandas as pd
import argparse
from pathlib import Path


class DatasetAdapter:
    """Base class for dataset adapters"""

    def __init__(self, dt=0.02):
        """
        Args:
            dt: Target time step for UKF (seconds)
        """
        self.dt = dt

    def load_and_convert(self, input_file, output_file):
        """
        Load dataset and convert to UKF format

        Args:
            input_file: Path to input dataset
            output_file: Path to output CSV

        Returns:
            num_cycles: Number of measurement cycles generated
        """
        raise NotImplementedError("Subclasses must implement load_and_convert")

    def resample_to_dt(self, timestamps, positions, dt):
        """
        Resample trajectory to constant time step

        Args:
            timestamps: Array of timestamps (seconds)
            positions: (N, 3) array of [x, y, z] positions
            dt: Target time step

        Returns:
            positions_resampled: (M, 3) array at constant dt
        """
        # Create uniform time grid
        t_start = timestamps[0]
        t_end = timestamps[-1]
        t_uniform = np.arange(t_start, t_end, dt)

        # Interpolate positions
        positions_resampled = np.zeros((len(t_uniform), 3))
        for i in range(3):
            positions_resampled[:, i] = np.interp(t_uniform, timestamps, positions[:, i])

        return positions_resampled

    def compute_derivatives(self, positions, dt):
        """
        Compute velocity and acceleration from positions using finite differences

        Args:
            positions: (N, 3) array of positions
            dt: Time step

        Returns:
            ground_truth: (N, 9) array [x_pos, x_vel, x_acc, y_pos, y_vel, y_acc, z_pos, z_vel, z_acc]
        """
        N = len(positions)
        ground_truth = np.zeros((N, 9))

        # Copy positions
        ground_truth[:, 0] = positions[:, 0]  # x_pos
        ground_truth[:, 3] = positions[:, 1]  # y_pos
        ground_truth[:, 6] = positions[:, 2]  # z_pos

        # Compute velocities using central difference (2nd order accurate)
        for i in range(3):
            vel_idx = i * 3 + 1
            pos_idx = i * 3

            # Forward difference for first point
            ground_truth[0, vel_idx] = (ground_truth[1, pos_idx] - ground_truth[0, pos_idx]) / dt

            # Central difference for middle points
            for k in range(1, N-1):
                ground_truth[k, vel_idx] = (ground_truth[k+1, pos_idx] - ground_truth[k-1, pos_idx]) / (2 * dt)

            # Backward difference for last point
            ground_truth[N-1, vel_idx] = (ground_truth[N-1, pos_idx] - ground_truth[N-2, pos_idx]) / dt

        # Compute accelerations using central difference
        for i in range(3):
            acc_idx = i * 3 + 2
            vel_idx = i * 3 + 1

            # Forward difference for first point
            ground_truth[0, acc_idx] = (ground_truth[1, vel_idx] - ground_truth[0, vel_idx]) / dt

            # Central difference for middle points
            for k in range(1, N-1):
                ground_truth[k, acc_idx] = (ground_truth[k+1, vel_idx] - ground_truth[k-1, vel_idx]) / (2 * dt)

            # Backward difference for last point
            ground_truth[N-1, acc_idx] = (ground_truth[N-1, vel_idx] - ground_truth[N-2, vel_idx]) / dt

        return ground_truth

    def add_measurement_noise(self, positions, noise_std=0.1):
        """
        Add Gaussian noise to positions

        Args:
            positions: (N, 3) array of true positions
            noise_std: Standard deviation of measurement noise (meters)

        Returns:
            measurements: (N, 3) array of noisy measurements
        """
        N = len(positions)
        noise = np.random.randn(N, 3) * noise_std
        return positions + noise


class GenericCSVAdapter(DatasetAdapter):
    """
    Adapter for generic CSV files with columns: time, x, y, z

    Expected CSV format:
        time,x,y,z
        0.00,0.0,0.0,0.0
        0.02,0.02,0.01,0.005
        ...
    """

    def load_and_convert(self, input_file, output_file, noise_std=0.1):
        """
        Load generic CSV and convert to UKF format

        Args:
            input_file: CSV with columns [time, x, y, z]
            output_file: Output CSV in UKF format
            noise_std: Measurement noise standard deviation
        """
        print(f"Loading generic CSV: {input_file}")

        # Read CSV
        df = pd.read_csv(input_file)

        # Extract data
        timestamps = df['time'].values
        positions = df[['x', 'y', 'z']].values

        print(f"  Original data points: {len(timestamps)}")
        print(f"  Time range: {timestamps[0]:.3f} - {timestamps[-1]:.3f} seconds")
        print(f"  Duration: {timestamps[-1] - timestamps[0]:.3f} seconds")

        # Resample to constant dt if needed
        dt_actual = np.median(np.diff(timestamps))
        print(f"  Median dt: {dt_actual:.4f} seconds")

        if abs(dt_actual - self.dt) > 1e-6:
            print(f"  Resampling to dt={self.dt} seconds...")
            positions = self.resample_to_dt(timestamps, positions, self.dt)
            timestamps = np.arange(len(positions)) * self.dt

        print(f"  Resampled data points: {len(timestamps)}")

        # Compute ground truth (position, velocity, acceleration)
        print("  Computing velocities and accelerations...")
        ground_truth = self.compute_derivatives(positions, self.dt)

        # Generate noisy measurements
        print(f"  Adding measurement noise (σ={noise_std} m)...")
        measurements = self.add_measurement_noise(positions, noise_std)

        # Write output CSV in UKF format
        print(f"  Writing to {output_file}...")
        self.write_ukf_csv(output_file, ground_truth, measurements)

        print(f"Dataset conversion complete: {len(timestamps)} cycles")
        return len(timestamps)

    def write_ukf_csv(self, filename, ground_truth, measurements):
        """
        Write data in UKF-compatible CSV format

        Args:
            filename: Output CSV path
            ground_truth: (N, 9) array
            measurements: (N, 3) array
        """
        N = len(ground_truth)

        with open(filename, 'w') as f:
            # Header
            header = ['cycle', 'time']
            header += [f'gt_{axis}_{state}' for axis in ['x', 'y', 'z']
                       for state in ['pos', 'vel', 'acc']]
            header += ['z_x_meas', 'z_y_meas', 'z_z_meas']
            f.write(','.join(header) + '\n')

            # Data rows
            for k in range(N):
                row = [str(k), f"{k * self.dt:.4f}"]
                row += [f"{v:.6f}" for v in ground_truth[k]]
                row += [f"{m:.6f}" for m in measurements[k]]
                f.write(','.join(row) + '\n')


class ETH_UAV_Adapter(DatasetAdapter):
    """
    Adapter for ETH Zurich UAV datasets

    Dataset format: TXT file with columns [timestamp, x, y, z, qx, qy, qz, qw]
    Example datasets: machine_hall, vicon_room
    """

    def load_and_convert(self, input_file, output_file, noise_std=0.1):
        """
        Load ETH UAV dataset and convert to UKF format

        Args:
            input_file: Path to .txt file
            output_file: Output CSV path
            noise_std: Measurement noise (meters)
        """
        print(f"Loading ETH UAV dataset: {input_file}")

        # Read space-separated file
        data = np.loadtxt(input_file)

        timestamps = data[:, 0]
        positions = data[:, 1:4]  # x, y, z

        # Convert timestamps to seconds (usually in nanoseconds)
        if timestamps[0] > 1e9:
            timestamps = (timestamps - timestamps[0]) / 1e9

        print(f"  Data points: {len(timestamps)}")
        print(f"  Duration: {timestamps[-1]:.2f} seconds")

        # Resample to constant dt
        print(f"  Resampling to dt={self.dt} seconds...")
        positions = self.resample_to_dt(timestamps, positions, self.dt)

        # Compute derivatives
        ground_truth = self.compute_derivatives(positions, self.dt)

        # Add noise
        measurements = self.add_measurement_noise(positions, noise_std)

        # Write output
        adapter = GenericCSVAdapter(self.dt)
        adapter.write_ukf_csv(output_file, ground_truth, measurements)

        print(f"ETH UAV conversion complete: {len(positions)} cycles")
        return len(positions)


def create_sample_dataset(output_file, scenario='circular', num_cycles=200, dt=0.02, noise_std=0.1):
    """
    Create sample trajectory dataset for testing

    Args:
        output_file: Output CSV path
        scenario: 'linear_ca', 'circular', 'helix', 'figure8'
        num_cycles: Number of measurement cycles
        dt: Time step
        noise_std: Measurement noise
    """
    print(f"Generating sample {scenario} trajectory...")

    timestamps = np.arange(num_cycles) * dt
    positions = np.zeros((num_cycles, 3))

    if scenario == 'linear_ca':
        # Constant acceleration
        a = np.array([1.0, 0.5, 0.3])
        for k in range(num_cycles):
            t = timestamps[k]
            positions[k] = 0.5 * a * t * t

    elif scenario == 'circular':
        # Circular motion in XY plane, constant Z velocity
        radius = 10.0
        omega = 0.1  # rad/s
        v_z = 1.0
        for k in range(num_cycles):
            t = timestamps[k]
            positions[k, 0] = radius * np.cos(omega * t)
            positions[k, 1] = radius * np.sin(omega * t)
            positions[k, 2] = v_z * t

    elif scenario == 'helix':
        # Helical trajectory
        radius = 5.0
        omega = 0.2
        pitch = 2.0
        for k in range(num_cycles):
            t = timestamps[k]
            positions[k, 0] = radius * np.cos(omega * t)
            positions[k, 1] = radius * np.sin(omega * t)
            positions[k, 2] = pitch * t

    elif scenario == 'figure8':
        # Figure-8 trajectory
        a = 5.0
        b = 3.0
        omega = 0.15
        for k in range(num_cycles):
            t = timestamps[k]
            theta = omega * t
            positions[k, 0] = a * np.sin(theta)
            positions[k, 1] = b * np.sin(2 * theta)
            positions[k, 2] = 0.5 * t

    # Write to CSV
    df = pd.DataFrame({
        'time': timestamps,
        'x': positions[:, 0],
        'y': positions[:, 1],
        'z': positions[:, 2]
    })
    df.to_csv(output_file, index=False)

    print(f"Sample dataset created: {output_file}")
    print(f"  Scenario: {scenario}")
    print(f"  Cycles: {num_cycles}")
    print(f"  Duration: {timestamps[-1]:.2f} seconds")


def main():
    parser = argparse.ArgumentParser(description='Convert trajectory datasets to UKF format')
    parser.add_argument('--input', type=str, help='Input dataset file')
    parser.add_argument('--output', type=str, help='Output CSV file')
    parser.add_argument('--format', type=str, default='generic',
                        choices=['generic', 'eth_uav'],
                        help='Input dataset format')
    parser.add_argument('--dt', type=float, default=0.02,
                        help='Target time step (seconds)')
    parser.add_argument('--noise', type=float, default=0.1,
                        help='Measurement noise standard deviation (meters)')
    parser.add_argument('--create-sample', type=str,
                        choices=['linear_ca', 'circular', 'helix', 'figure8'],
                        help='Create sample dataset instead of converting')
    parser.add_argument('--sample-cycles', type=int, default=200,
                        help='Number of cycles for sample dataset')

    args = parser.parse_args()

    if args.create_sample:
        # Create sample dataset
        output = args.output or f'../test_data/sample_{args.create_sample}.csv'
        create_sample_dataset(
            output,
            scenario=args.create_sample,
            num_cycles=args.sample_cycles,
            dt=args.dt,
            noise_std=args.noise
        )
    else:
        # Convert existing dataset
        if not args.input or not args.output:
            print("Error: --input and --output required (unless using --create-sample)")
            return

        # Select adapter
        if args.format == 'generic':
            adapter = GenericCSVAdapter(dt=args.dt)
        elif args.format == 'eth_uav':
            adapter = ETH_UAV_Adapter(dt=args.dt)

        # Convert
        adapter.load_and_convert(args.input, args.output, noise_std=args.noise)

    print("\nDone!")


if __name__ == '__main__':
    main()
