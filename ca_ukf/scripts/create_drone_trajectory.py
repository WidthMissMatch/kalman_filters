#!/usr/bin/env python3
"""
Create realistic DRONE trajectory for UKF testing

Maneuvers:
1. Vertical takeoff (0-2s)
2. Forward acceleration (2-4s)
3. Banking turn (4-8s)
4. Altitude change during cruise (8-12s)
5. Deceleration and hover (12-14s)
6. Controlled landing (14-16s)

Total: 16 seconds @ 20ms timestep = 800 cycles
"""

import numpy as np
import pandas as pd

def to_q24_24(value):
    """Convert float to Q24.24 fixed-point integer"""
    return int(value * (2**24))

def create_drone_trajectory(duration=16.0, dt=0.02):
    """
    Create realistic drone trajectory with maneuvers

    Returns: DataFrame with ground truth and measurements
    """

    num_cycles = int(duration / dt)
    t = np.arange(num_cycles) * dt

    # Initialize arrays
    x_pos = np.zeros(num_cycles)
    y_pos = np.zeros(num_cycles)
    z_pos = np.zeros(num_cycles)

    x_vel = np.zeros(num_cycles)
    y_vel = np.zeros(num_cycles)
    z_vel = np.zeros(num_cycles)

    x_acc = np.zeros(num_cycles)
    y_acc = np.zeros(num_cycles)
    z_acc = np.zeros(num_cycles)

    print("=" * 80)
    print("CREATING REALISTIC DRONE TRAJECTORY")
    print("=" * 80)
    print(f"Duration: {duration} s")
    print(f"Timestep: {dt} s")
    print(f"Total cycles: {num_cycles}")
    print()

    # Physics parameters
    max_vert_accel = 5.0   # m/s² (vertical)
    max_horiz_accel = 3.0  # m/s² (horizontal)
    max_speed = 10.0       # m/s

    for i in range(num_cycles):
        time = t[i]

        # PHASE 1: Vertical takeoff (0-2s)
        if time < 2.0:
            z_acc[i] = max_vert_accel
            z_vel[i] = z_vel[i-1] + z_acc[i] * dt if i > 0 else 0.0
            z_pos[i] = z_pos[i-1] + z_vel[i] * dt if i > 0 else 0.0

        # PHASE 2: Forward acceleration (2-4s)
        elif 2.0 <= time < 4.0:
            x_acc[i] = max_horiz_accel
            x_vel[i] = x_vel[i-1] + x_acc[i] * dt if i > 0 else 0.0
            x_pos[i] = x_pos[i-1] + x_vel[i] * dt if i > 0 else 0.0

            # Maintain altitude
            z_vel[i] = z_vel[i-1]
            z_pos[i] = z_pos[i-1] + z_vel[i] * dt

        # PHASE 3: Banking turn (4-8s) - circular arc
        elif 4.0 <= time < 8.0:
            # Constant speed turn
            speed = 6.0  # m/s
            radius = 10.0  # m
            omega = speed / radius  # angular velocity

            theta = omega * (time - 4.0)  # angle from start of turn

            # Centripetal acceleration
            centripetal = speed**2 / radius

            # Position on circle
            center_x = x_pos[int(4.0/dt) - 1]  # where turn started
            x_pos[i] = center_x + radius * np.sin(theta)
            y_pos[i] = radius * (1 - np.cos(theta))

            # Velocity (tangent to circle)
            x_vel[i] = speed * np.cos(theta)
            y_vel[i] = speed * np.sin(theta)

            # Acceleration (towards center)
            x_acc[i] = -centripetal * np.sin(theta)
            y_acc[i] = centripetal * np.cos(theta)

            # Slight altitude gain during turn
            z_acc[i] = 0.5
            z_vel[i] = z_vel[i-1] + z_acc[i] * dt if i > 0 else 0.0
            z_pos[i] = z_pos[i-1] + z_vel[i] * dt if i > 0 else 0.0

        # PHASE 4: Cruise with altitude change (8-12s)
        elif 8.0 <= time < 12.0:
            # Maintain forward velocity
            x_vel[i] = x_vel[i-1]
            y_vel[i] = y_vel[i-1]

            x_pos[i] = x_pos[i-1] + x_vel[i] * dt
            y_pos[i] = y_pos[i-1] + y_vel[i] * dt

            # Descend gradually
            z_acc[i] = -2.0
            z_vel[i] = z_vel[i-1] + z_acc[i] * dt
            z_pos[i] = z_pos[i-1] + z_vel[i] * dt

        # PHASE 5: Deceleration to hover (12-14s)
        elif 12.0 <= time < 14.0:
            # Decelerate horizontally
            x_acc[i] = -max_horiz_accel
            y_acc[i] = -max_horiz_accel if y_vel[i-1] > 0.1 else 0.0

            x_vel[i] = max(0, x_vel[i-1] + x_acc[i] * dt) if i > 0 else 0.0
            y_vel[i] = max(0, y_vel[i-1] + y_acc[i] * dt) if i > 0 else 0.0

            x_pos[i] = x_pos[i-1] + x_vel[i] * dt
            y_pos[i] = y_pos[i-1] + y_vel[i] * dt

            # Stabilize altitude
            z_acc[i] = 0.0
            z_vel[i] = 0.0
            z_pos[i] = z_pos[i-1]

        # PHASE 6: Controlled landing (14-16s)
        else:
            # Gentle descent
            z_acc[i] = -2.0
            z_vel[i] = z_vel[i-1] + z_acc[i] * dt if z_pos[i-1] > 0.1 else 0.0
            z_pos[i] = max(0.0, z_pos[i-1] + z_vel[i] * dt)

            # Maintain hover position
            x_vel[i] = 0.0
            y_vel[i] = 0.0
            x_pos[i] = x_pos[i-1]
            y_pos[i] = y_pos[i-1]

    # Add measurement noise (GPS-like, 1m std dev)
    noise_std = 1.0  # meters
    np.random.seed(42)

    noise_x = np.random.normal(0, noise_std, num_cycles)
    noise_y = np.random.normal(0, noise_std, num_cycles)
    noise_z = np.random.normal(0, noise_std, num_cycles)

    meas_x = x_pos + noise_x
    meas_y = y_pos + noise_y
    meas_z = z_pos + noise_z

    # Convert to Q24.24
    meas_x_q24 = [to_q24_24(m) for m in meas_x]
    meas_y_q24 = [to_q24_24(m) for m in meas_y]
    meas_z_q24 = [to_q24_24(m) for m in meas_z]

    # Create DataFrame
    data = {
        'cycle': np.arange(num_cycles),
        'time': t,
        'gt_x_pos': x_pos,
        'gt_y_pos': y_pos,
        'gt_z_pos': z_pos,
        'gt_x_vel': x_vel,
        'gt_y_vel': y_vel,
        'gt_z_vel': z_vel,
        'gt_x_acc': x_acc,
        'gt_y_acc': y_acc,
        'gt_z_acc': z_acc,
        'meas_x': meas_x,
        'meas_y': meas_y,
        'meas_z': meas_z,
        'meas_x_q24': meas_x_q24,
        'meas_y_q24': meas_y_q24,
        'meas_z_q24': meas_z_q24,
        'noise_x': noise_x,
        'noise_y': noise_y,
        'noise_z': noise_z
    }

    df = pd.DataFrame(data)

    # Save
    output_file = '../test_data/drone_trajectory_800cycles.csv'
    df.to_csv(output_file, index=False)

    print(f"✅ Drone trajectory saved to: {output_file}")
    print()

    # Print trajectory summary
    print("TRAJECTORY SUMMARY:")
    print(f"  Max altitude: {z_pos.max():.1f} m")
    print(f"  Max speed: {np.sqrt(x_vel**2 + y_vel**2 + z_vel**2).max():.1f} m/s")
    print(f"  Max acceleration: {np.sqrt(x_acc**2 + y_acc**2 + z_acc**2).max():.1f} m/s²")
    print(f"  Total distance: {np.sum(np.sqrt(np.diff(x_pos)**2 + np.diff(y_pos)**2 + np.diff(z_pos)**2)):.1f} m")
    print()

    # Print maneuver checkpoints
    print("MANEUVER CHECKPOINTS:")
    print(f"  t=2s  (end takeoff):      z={z_pos[int(2.0/dt)]:.1f}m, vz={z_vel[int(2.0/dt)]:.1f}m/s")
    print(f"  t=4s  (end accel):        x={x_pos[int(4.0/dt)]:.1f}m, vx={x_vel[int(4.0/dt)]:.1f}m/s")
    print(f"  t=8s  (end turn):         x={x_pos[int(8.0/dt)]:.1f}m, y={y_pos[int(8.0/dt)]:.1f}m")
    print(f"  t=12s (end descent):      z={z_pos[int(12.0/dt)]:.1f}m")
    print(f"  t=14s (start landing):    z={z_pos[int(14.0/dt)]:.1f}m")
    print(f"  t=16s (landed):           z={z_pos[-1]:.1f}m")
    print()

    return df

if __name__ == '__main__':
    df = create_drone_trajectory(duration=16.0, dt=0.02)

    print("=" * 80)
    print("DATASET READY FOR UKF TESTING")
    print("=" * 80)
    print("This dataset includes:")
    print("  ✓ Vertical takeoff with acceleration")
    print("  ✓ Forward flight with varying velocity")
    print("  ✓ Banking turn (centripetal acceleration)")
    print("  ✓ Altitude changes (climb/descent)")
    print("  ✓ Deceleration maneuvers")
    print("  ✓ Controlled landing")
    print()
    print("Use this to test UKF PREDICTION accuracy on realistic drone flight!")
    print()
