#!/usr/bin/env python3
"""
Generate Python UKF reference data for VHDL validation

Creates CSV file with ground truth, measurements, and Python UKF estimates
for comparison with VHDL implementation.
"""

import numpy as np
import csv
from ukf_9d_ca_reference import UKF_9D_CA, to_q24_24, from_q24_24


def generate_constant_acceleration_trajectory(num_cycles=100, dt=0.02):
    """
    Generate synthetic trajectory with constant acceleration

    Initial conditions:
        Position: [0, 0, 0]
        Velocity: [0, 0, 0]
        Acceleration: [1.0, 0.5, 0.3] m/s²

    Args:
        num_cycles: Number of measurement cycles
        dt: Time step (seconds)

    Returns:
        ground_truth: (num_cycles, 9) array of true states
        measurements: (num_cycles, 3) array of noisy position measurements
    """
    # True initial state
    x0 = np.array([0.0, 0.0, 1.0,  # x: pos, vel, acc
                   0.0, 0.0, 0.5,  # y: pos, vel, acc
                   0.0, 0.0, 0.3]) # z: pos, vel, acc

    ground_truth = np.zeros((num_cycles, 9))
    measurements = np.zeros((num_cycles, 3))

    # Measurement noise standard deviation
    noise_std = 0.1  # meters

    x = x0.copy()
    for k in range(num_cycles):
        # Store ground truth
        ground_truth[k] = x.copy()

        # Generate noisy measurement (position only)
        z_true = np.array([x[0], x[3], x[6]])
        z_noisy = z_true + np.random.randn(3) * noise_std
        measurements[k] = z_noisy

        # Propagate true state (constant acceleration)
        x_next = np.zeros(9)
        # X axis
        x_next[0] = x[0] + x[1] * dt + 0.5 * x[2] * dt * dt
        x_next[1] = x[1] + x[2] * dt
        x_next[2] = x[2]  # constant
        # Y axis
        x_next[3] = x[3] + x[4] * dt + 0.5 * x[5] * dt * dt
        x_next[4] = x[4] + x[5] * dt
        x_next[5] = x[5]  # constant
        # Z axis
        x_next[6] = x[6] + x[7] * dt + 0.5 * x[8] * dt * dt
        x_next[7] = x[7] + x[8] * dt
        x_next[8] = x[8]  # constant

        x = x_next

    return ground_truth, measurements


def run_python_ukf(measurements, dt=0.02, q_power=5.0, r_diag=0.01):
    """
    Run Python UKF on measurement sequence

    Args:
        measurements: (num_cycles, 3) array of measurements
        dt: Time step
        q_power: Process noise power
        r_diag: Measurement noise variance

    Returns:
        estimates: (num_cycles, 9) array of state estimates
        covariances: (num_cycles, 9) array of covariance diagonals
        innovations: (num_cycles, 3) array of innovations
    """
    num_cycles = len(measurements)
    estimates = np.zeros((num_cycles, 9))
    covariances = np.zeros((num_cycles, 9))
    innovations = np.zeros((num_cycles, 3))

    # Initialize UKF
    ukf = UKF_9D_CA(dt=dt, q_power=q_power, r_diag=r_diag)

    for k in range(num_cycles):
        # Process measurement
        x, P, nu = ukf.process_measurement(measurements[k])

        # Store results
        estimates[k] = x
        covariances[k] = np.diag(P)
        innovations[k] = nu

    return estimates, covariances, innovations


def write_reference_csv(filename, ground_truth, measurements, estimates, covariances, innovations, dt=0.02):
    """
    Write reference data to CSV file

    CSV format:
        cycle, time,
        gt_x_pos, gt_x_vel, gt_x_acc, ..., gt_z_acc,
        z_x_meas, z_y_meas, z_z_meas,
        z_x_meas_q24, z_y_meas_q24, z_z_meas_q24,
        est_x_pos, est_x_vel, est_x_acc, ..., est_z_acc,
        est_x_pos_q24, est_x_vel_q24, est_x_acc_q24, ..., est_z_acc_q24,
        p11, p22, p33, p44, p55, p66, p77, p88, p99,
        nu_x, nu_y, nu_z
    """
    num_cycles = len(ground_truth)

    with open(filename, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)

        # Header
        header = ['cycle', 'time']
        # Ground truth (9 states)
        header += [f'gt_{axis}_{state}' for axis in ['x', 'y', 'z']
                   for state in ['pos', 'vel', 'acc']]
        # Measurements (3 positions, float + Q24.24)
        header += ['z_x_meas', 'z_y_meas', 'z_z_meas']
        header += ['z_x_meas_q24', 'z_y_meas_q24', 'z_z_meas_q24']
        # Estimates (9 states, float + Q24.24)
        header += [f'est_{axis}_{state}' for axis in ['x', 'y', 'z']
                   for state in ['pos', 'vel', 'acc']]
        header += [f'est_{axis}_{state}_q24' for axis in ['x', 'y', 'z']
                   for state in ['pos', 'vel', 'acc']]
        # Covariance diagonal (9 elements)
        header += [f'p{i+1}{i+1}' for i in range(9)]
        # Innovation (3 elements)
        header += ['nu_x', 'nu_y', 'nu_z']

        writer.writerow(header)

        # Data rows
        for k in range(num_cycles):
            row = [k, k * dt]
            # Ground truth
            row += ground_truth[k].tolist()
            # Measurements (float)
            row += measurements[k].tolist()
            # Measurements (Q24.24)
            row += [to_q24_24(m) for m in measurements[k]]
            # Estimates (float)
            row += estimates[k].tolist()
            # Estimates (Q24.24)
            row += [to_q24_24(e) for e in estimates[k]]
            # Covariance
            row += covariances[k].tolist()
            # Innovation
            row += innovations[k].tolist()

            writer.writerow(row)

    print(f"Reference data written to {filename}")
    print(f"Total cycles: {num_cycles}")


def main():
    """Generate reference data for VHDL validation"""
    import argparse

    parser = argparse.ArgumentParser(description='Generate Python UKF reference data')
    parser.add_argument('--cycles', type=int, default=100,
                        help='Number of measurement cycles (default: 100)')
    parser.add_argument('--dt', type=float, default=0.02,
                        help='Time step in seconds (default: 0.02)')
    parser.add_argument('--q-power', type=float, default=5.0,
                        help='Process noise power (default: 5.0)')
    parser.add_argument('--r-diag', type=float, default=0.01,
                        help='Measurement noise variance (default: 0.01)')
    parser.add_argument('--output', type=str,
                        default='../test_data/python_reference_9d_ca.csv',
                        help='Output CSV file path')
    parser.add_argument('--seed', type=int, default=42,
                        help='Random seed for reproducibility (default: 42)')

    args = parser.parse_args()

    # Set random seed for reproducibility
    np.random.seed(args.seed)

    print("=" * 60)
    print("9D CA UKF Reference Data Generator")
    print("=" * 60)
    print(f"Configuration:")
    print(f"  Cycles: {args.cycles}")
    print(f"  Time step: {args.dt} s")
    print(f"  Process noise power: {args.q_power}")
    print(f"  Measurement noise variance: {args.r_diag}")
    print(f"  Random seed: {args.seed}")
    print(f"  Output file: {args.output}")
    print()

    # Generate trajectory
    print("Generating constant acceleration trajectory...")
    ground_truth, measurements = generate_constant_acceleration_trajectory(
        num_cycles=args.cycles, dt=args.dt
    )
    print(f"  Initial state: {ground_truth[0]}")
    print(f"  Final state: {ground_truth[-1]}")
    print()

    # Run Python UKF
    print("Running Python UKF...")
    estimates, covariances, innovations = run_python_ukf(
        measurements, dt=args.dt, q_power=args.q_power, r_diag=args.r_diag
    )
    print(f"  Initial estimate: {estimates[0]}")
    print(f"  Final estimate: {estimates[-1]}")
    print(f"  Final covariance diagonal: {covariances[-1]}")
    print()

    # Compute error statistics
    print("Computing error statistics...")
    errors = np.abs(estimates - ground_truth)
    mean_errors = np.mean(errors, axis=0)
    max_errors = np.max(errors, axis=0)
    rmse = np.sqrt(np.mean(errors**2, axis=0))

    state_names = ['x_pos', 'x_vel', 'x_acc', 'y_pos', 'y_vel', 'y_acc', 'z_pos', 'z_vel', 'z_acc']
    print("  State         Mean Error    Max Error     RMSE")
    print("  " + "-" * 50)
    for i, name in enumerate(state_names):
        print(f"  {name:8s}    {mean_errors[i]:10.6f}  {max_errors[i]:10.6f}  {rmse[i]:10.6f}")
    print()

    # Write CSV
    print("Writing reference data...")
    write_reference_csv(
        args.output, ground_truth, measurements, estimates, covariances, innovations, dt=args.dt
    )
    print()
    print("=" * 60)
    print("Reference data generation complete!")
    print("=" * 60)


if __name__ == "__main__":
    main()
