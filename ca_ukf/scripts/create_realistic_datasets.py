#!/usr/bin/env python3
"""
Create Realistic Trajectory Datasets Based on Real-World Scenarios

Simulates realistic motion profiles:
1. Drone delivery flight
2. Autonomous vehicle urban driving
3. Pedestrian walking with direction changes
4. Ballistic projectile (physics-based)
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path


def generate_drone_delivery_flight(duration=10.0, dt=0.02):
    """
    Generate realistic drone delivery trajectory

    Profile:
    - Takeoff (vertical acceleration)
    - Horizontal cruise
    - Deceleration and landing

    Args:
        duration: Flight duration (seconds)
        dt: Time step

    Returns:
        positions: (N, 3) array
        timestamps: (N,) array
    """
    N = int(duration / dt)
    timestamps = np.arange(N) * dt
    positions = np.zeros((N, 3))

    for i in range(N):
        t = timestamps[i]

        if t < 2.0:  # Takeoff phase (0-2s)
            z_acc = 2.0  # 2 m/s² upward
            positions[i, 2] = 0.5 * z_acc * t**2

        elif t < 7.0:  # Cruise phase (2-7s)
            takeoff_z = 0.5 * 2.0 * 2.0**2  # Final z from takeoff
            v_cruise = 5.0  # 5 m/s horizontal
            cruise_time = t - 2.0

            positions[i, 0] = v_cruise * cruise_time
            positions[i, 2] = takeoff_z

        else:  # Landing phase (7-10s)
            cruise_x = 5.0 * 5.0  # Final x from cruise
            cruise_z = 0.5 * 2.0 * 2.0**2

            landing_time = t - 7.0
            landing_duration = 3.0

            # Deceleration
            x_decel = -5.0 / landing_duration  # Come to stop
            z_decel = -cruise_z / (0.5 * landing_duration**2)  # Land smoothly

            positions[i, 0] = cruise_x + 5.0 * landing_time + 0.5 * x_decel * landing_time**2
            positions[i, 2] = max(0, cruise_z + 0.5 * z_decel * landing_time**2)

    return positions, timestamps


def generate_vehicle_urban_driving(duration=15.0, dt=0.02):
    """
    Generate realistic autonomous vehicle trajectory

    Profile:
    - Acceleration from stop
    - Lane change maneuver
    - Deceleration for turn
    - Turn execution

    Args:
        duration: Drive duration (seconds)
        dt: Time step

    Returns:
        positions: (N, 3) array
        timestamps: (N,) array
    """
    N = int(duration / dt)
    timestamps = np.arange(N) * dt
    positions = np.zeros((N, 3))

    for i in range(N):
        t = timestamps[i]

        if t < 3.0:  # Acceleration phase
            a_x = 2.0  # 2 m/s² forward
            positions[i, 0] = 0.5 * a_x * t**2

        elif t < 6.0:  # Constant speed
            accel_x = 0.5 * 2.0 * 3.0**2
            v_cruise = 2.0 * 3.0  # Final velocity from accel
            cruise_time = t - 3.0

            positions[i, 0] = accel_x + v_cruise * cruise_time

        elif t < 9.0:  # Lane change (lateral acceleration)
            cruise_x = 0.5 * 2.0 * 3.0**2 + 6.0 * 3.0
            lane_time = t - 6.0

            positions[i, 0] = cruise_x + 6.0 * lane_time
            positions[i, 1] = 0.5 * 1.0 * lane_time**2  # Lateral accel

        else:  # Deceleration and turn
            prev_x = 0.5 * 2.0 * 3.0**2 + 6.0 * 3.0 + 6.0 * 3.0
            prev_y = 0.5 * 1.0 * 3.0**2

            turn_time = t - 9.0
            turn_radius = 10.0
            angular_vel = 0.2  # rad/s

            theta = angular_vel * turn_time

            positions[i, 0] = prev_x + turn_radius * np.sin(theta)
            positions[i, 1] = prev_y + turn_radius * (1 - np.cos(theta))

    return positions, timestamps


def generate_ballistic_projectile(duration=5.0, dt=0.02, v0=20.0, angle_deg=45.0):
    """
    Generate physics-based projectile trajectory

    Args:
        duration: Flight time (seconds)
        dt: Time step
        v0: Initial velocity (m/s)
        angle_deg: Launch angle (degrees)

    Returns:
        positions: (N, 3) array
        timestamps: (N,) array
    """
    N = int(duration / dt)
    timestamps = np.arange(N) * dt
    positions = np.zeros((N, 3))

    angle = np.radians(angle_deg)
    v0_x = v0 * np.cos(angle)
    v0_z = v0 * np.sin(angle)
    g = 9.81  # m/s²

    for i in range(N):
        t = timestamps[i]

        positions[i, 0] = v0_x * t
        positions[i, 2] = v0_z * t - 0.5 * g * t**2

        # Stop at ground
        if positions[i, 2] < 0:
            positions[i, 2] = 0

    return positions, timestamps


def generate_pedestrian_walk(duration=12.0, dt=0.02):
    """
    Generate realistic pedestrian walking trajectory with direction changes

    Profile:
    - Walking forward
    - 90-degree turn
    - Walking again
    - Another turn

    Args:
        duration: Walk duration (seconds)
        dt: Time step

    Returns:
        positions: (N, 3) array
        timestamps: (N,) array
    """
    N = int(duration / dt)
    timestamps = np.arange(N) * dt
    positions = np.zeros((N, 3))

    walk_speed = 1.4  # m/s (typical human walking)

    for i in range(N):
        t = timestamps[i]

        if t < 4.0:  # Walk forward
            positions[i, 0] = walk_speed * t

        elif t < 6.0:  # Turn 90 degrees (2s turn)
            prev_x = walk_speed * 4.0

            turn_time = t - 4.0
            turn_radius = 1.0
            angular_vel = np.pi / 4  # 90 deg in 2s

            theta = angular_vel * turn_time

            positions[i, 0] = prev_x + turn_radius * np.sin(theta)
            positions[i, 1] = turn_radius * (1 - np.cos(theta))

        elif t < 10.0:  # Walk in new direction
            prev_x = walk_speed * 4.0 + 1.0
            prev_y = 1.0

            walk_time = t - 6.0
            positions[i, 0] = prev_x
            positions[i, 1] = prev_y + walk_speed * walk_time

        else:  # Final turn
            prev_x = walk_speed * 4.0 + 1.0
            prev_y = 1.0 + walk_speed * 4.0

            turn_time = t - 10.0
            turn_radius = 1.0
            angular_vel = np.pi / 4

            theta = angular_vel * turn_time

            positions[i, 0] = prev_x - turn_radius * (1 - np.cos(theta))
            positions[i, 1] = prev_y + turn_radius * np.sin(theta)

    return positions, timestamps


def save_trajectory(positions, timestamps, filename, scenario_name):
    """Save trajectory to CSV"""
    df = pd.DataFrame({
        'time': timestamps,
        'x': positions[:, 0],
        'y': positions[:, 1],
        'z': positions[:, 2]
    })

    df.to_csv(filename, index=False)
    print(f"Saved {scenario_name}: {filename}")
    print(f"  Duration: {timestamps[-1]:.2f}s, Points: {len(timestamps)}")

    # Print trajectory stats
    total_dist = np.sum(np.linalg.norm(np.diff(positions, axis=0), axis=1))
    max_height = np.max(positions[:, 2])
    print(f"  Total distance: {total_dist:.2f}m, Max height: {max_height:.2f}m\n")


def main():
    print("=" * 80)
    print("REALISTIC TRAJECTORY DATASET GENERATOR")
    print("=" * 80)
    print()

    output_dir = Path("../test_data/realistic")
    output_dir.mkdir(parents=True, exist_ok=True)

    # 1. Drone delivery
    print("Generating drone delivery flight...")
    positions, timestamps = generate_drone_delivery_flight(duration=10.0, dt=0.02)
    save_trajectory(positions, timestamps,
                   output_dir / "drone_delivery.csv",
                   "Drone Delivery")

    # 2. Vehicle urban driving
    print("Generating vehicle urban driving...")
    positions, timestamps = generate_vehicle_urban_driving(duration=15.0, dt=0.02)
    save_trajectory(positions, timestamps,
                   output_dir / "vehicle_urban.csv",
                   "Vehicle Urban Driving")

    # 3. Ballistic projectile
    print("Generating ballistic projectile...")
    positions, timestamps = generate_ballistic_projectile(duration=5.0, dt=0.02,
                                                          v0=20.0, angle_deg=45.0)
    save_trajectory(positions, timestamps,
                   output_dir / "projectile.csv",
                   "Ballistic Projectile")

    # 4. Pedestrian walk
    print("Generating pedestrian walk...")
    positions, timestamps = generate_pedestrian_walk(duration=12.0, dt=0.02)
    save_trajectory(positions, timestamps,
                   output_dir / "pedestrian_walk.csv",
                   "Pedestrian Walk")

    print("=" * 80)
    print("ALL REALISTIC DATASETS GENERATED")
    print("=" * 80)
    print(f"Location: {output_dir}")
    print()
    print("Next steps:")
    print("1. Convert to UKF format: python3 dataset_adapter.py --input <csv> --output <ukf.csv>")
    print("2. Compare VHDL vs Python: python3 compare_vhdl_vs_python.py")


if __name__ == "__main__":
    main()
