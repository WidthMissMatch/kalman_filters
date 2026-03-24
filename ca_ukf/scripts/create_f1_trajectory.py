#!/usr/bin/env python3
"""
Create realistic F1 CAR trajectory for UKF testing

Track layout (simplified Monaco/street circuit style):
1. Start/Finish straight (0-3s) - full acceleration
2. Hard braking into Turn 1 (3-4s) - high deceleration
3. Slow corner (Turn 1) (4-6s) - lateral acceleration
4. Short straight (6-7s) - acceleration
5. Fast corner (Turn 2) (7-9s) - high lateral + longitudinal
6. Final straight (9-12s) - top speed

Total: 12 seconds @ 20ms timestep = 600 cycles
"""

import numpy as np
import pandas as pd

def to_q24_24(value):
    """Convert float to Q24.24 fixed-point integer"""
    return int(value * (2**24))

def create_f1_trajectory(duration=12.0, dt=0.02):
    """
    Create realistic F1 car trajectory

    Returns: DataFrame with ground truth and measurements
    """

    num_cycles = int(duration / dt)
    t = np.arange(num_cycles) * dt

    # Initialize arrays
    x_pos = np.zeros(num_cycles)
    y_pos = np.zeros(num_cycles)
    z_pos = np.zeros(num_cycles)  # F1 car on flat track, z~0

    x_vel = np.zeros(num_cycles)
    y_vel = np.zeros(num_cycles)
    z_vel = np.zeros(num_cycles)

    x_acc = np.zeros(num_cycles)
    y_acc = np.zeros(num_cycles)
    z_acc = np.zeros(num_cycles)

    print("=" * 80)
    print("CREATING REALISTIC F1 CAR TRAJECTORY")
    print("=" * 80)
    print(f"Duration: {duration} s")
    print(f"Timestep: {dt} s")
    print(f"Total cycles: {num_cycles}")
    print()

    # F1 physics parameters
    max_accel = 12.0      # m/s² (longitudinal acceleration, 0-100km/h in 2.3s)
    max_brake = -45.0     # m/s² (extreme braking, 5-6G)
    max_lateral = 50.0    # m/s² (5G cornering with downforce)
    top_speed = 90.0      # m/s (~324 km/h)

    for i in range(num_cycles):
        time = t[i]

        # PHASE 1: Start/Finish straight - full acceleration (0-3s)
        if time < 3.0:
            # Longitudinal acceleration (reducing as speed increases)
            current_speed = np.sqrt(x_vel[i-1]**2 + y_vel[i-1]**2) if i > 0 else 0.0
            if current_speed < top_speed:
                x_acc[i] = max_accel * (1 - current_speed / top_speed)  # Speed-dependent accel
            else:
                x_acc[i] = 0.0

            x_vel[i] = x_vel[i-1] + x_acc[i] * dt if i > 0 else 0.0
            x_pos[i] = x_pos[i-1] + x_vel[i] * dt if i > 0 else 0.0

        # PHASE 2: Hard braking into Turn 1 (3-4s)
        elif 3.0 <= time < 4.0:
            # Extreme braking
            x_acc[i] = max_brake
            x_vel[i] = max(10.0, x_vel[i-1] + x_acc[i] * dt)  # Don't go below corner entry speed
            x_pos[i] = x_pos[i-1] + x_vel[i] * dt

        # PHASE 3: Slow corner (Turn 1) (4-6s) - 90 degree right turn
        elif 4.0 <= time < 6.0:
            # Constant radius turn
            corner_speed = 15.0  # m/s (~54 km/h)
            corner_radius = 20.0  # m (tight corner)

            # Angular position in turn
            theta = (corner_speed / corner_radius) * (time - 4.0)

            # Position (90 degree arc)
            turn_start_x = x_pos[int(4.0/dt) - 1]
            turn_start_y = 0.0

            x_pos[i] = turn_start_x + corner_radius * np.sin(theta)
            y_pos[i] = corner_radius * (1 - np.cos(theta))

            # Velocity (tangent to circle)
            x_vel[i] = corner_speed * np.cos(theta)
            y_vel[i] = corner_speed * np.sin(theta)

            # Centripetal acceleration
            centripetal = corner_speed**2 / corner_radius
            x_acc[i] = -centripetal * np.sin(theta)
            y_acc[i] = centripetal * np.cos(theta)

        # PHASE 4: Short straight (6-7s) - acceleration out of corner
        elif 6.0 <= time < 7.0:
            # Accelerate forward
            current_speed = np.sqrt(x_vel[i-1]**2 + y_vel[i-1]**2)
            if current_speed < 40.0:  # Accelerate to mid-speed
                # Combined longitudinal and lateral acceleration
                x_acc[i] = max_accel * 0.7
                y_acc[i] = 0.0

                x_vel[i] = x_vel[i-1] + x_acc[i] * dt
                y_vel[i] = y_vel[i-1] * 0.95  # Slight lateral decay

                x_pos[i] = x_pos[i-1] + x_vel[i] * dt
                y_pos[i] = y_pos[i-1] + y_vel[i] * dt

        # PHASE 5: Fast corner (Turn 2) (7-9s) - high-speed left turn
        elif 7.0 <= time < 9.0:
            # High-speed sweeper
            corner_speed = 50.0  # m/s (~180 km/h)
            corner_radius = 60.0  # m (fast corner)

            # Angular position (left turn, opposite direction)
            theta = (corner_speed / corner_radius) * (time - 7.0)

            turn_start_x = x_pos[int(7.0/dt) - 1]
            turn_start_y = y_pos[int(7.0/dt) - 1]

            # Position (left turn)
            x_pos[i] = turn_start_x + corner_radius * np.sin(theta)
            y_pos[i] = turn_start_y - corner_radius * (1 - np.cos(theta))

            # Velocity
            x_vel[i] = corner_speed * np.cos(theta)
            y_vel[i] = -corner_speed * np.sin(theta)  # Negative for left turn

            # High centripetal acceleration
            centripetal = corner_speed**2 / corner_radius
            x_acc[i] = -centripetal * np.sin(theta)
            y_acc[i] = -centripetal * np.cos(theta)

        # PHASE 6: Final straight (9-12s) - maximum speed
        else:
            # Full acceleration to top speed
            current_speed = np.sqrt(x_vel[i-1]**2 + y_vel[i-1]**2)
            if current_speed < top_speed:
                x_acc[i] = max_accel * (1 - current_speed / top_speed)
            else:
                x_acc[i] = 0.0

            # Straighten out lateral velocity
            y_acc[i] = -y_vel[i-1] / dt * 0.5 if abs(y_vel[i-1]) > 0.1 else 0.0

            x_vel[i] = x_vel[i-1] + x_acc[i] * dt
            y_vel[i] = y_vel[i-1] + y_acc[i] * dt

            x_pos[i] = x_pos[i-1] + x_vel[i] * dt
            y_pos[i] = y_pos[i-1] + y_vel[i] * dt

    # Add measurement noise (GPS/IMU fusion, 0.5m std dev)
    noise_std = 0.5  # meters
    np.random.seed(42)

    noise_x = np.random.normal(0, noise_std, num_cycles)
    noise_y = np.random.normal(0, noise_std, num_cycles)
    noise_z = np.random.normal(0, 0.1, num_cycles)  # Small z noise (flat track)

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
    output_file = '../test_data/f1_trajectory_600cycles.csv'
    df.to_csv(output_file, index=False)

    print(f"✅ F1 trajectory saved to: {output_file}")
    print()

    # Print trajectory summary
    total_speed = np.sqrt(x_vel**2 + y_vel**2)
    total_accel = np.sqrt(x_acc**2 + y_acc**2)

    print("TRAJECTORY SUMMARY:")
    print(f"  Max speed: {total_speed.max():.1f} m/s ({total_speed.max()*3.6:.1f} km/h)")
    print(f"  Max acceleration: {total_accel.max():.1f} m/s² ({total_accel.max()/9.81:.1f}G)")
    print(f"  Max braking: {x_acc.min():.1f} m/s² ({abs(x_acc.min())/9.81:.1f}G)")
    print(f"  Max lateral accel: {abs(y_acc).max():.1f} m/s² ({abs(y_acc).max()/9.81:.1f}G)")
    print(f"  Total distance: {np.sum(np.sqrt(np.diff(x_pos)**2 + np.diff(y_pos)**2)):.1f} m")
    print()

    # Print lap checkpoints
    print("LAP CHECKPOINTS:")
    print(f"  t=3s  (end straight):     v={total_speed[int(3.0/dt)]:.1f}m/s ({total_speed[int(3.0/dt)]*3.6:.0f}km/h)")
    print(f"  t=4s  (braking done):     v={total_speed[int(4.0/dt)]:.1f}m/s, a={x_acc[int(3.5/dt)]:.1f}m/s²")
    print(f"  t=6s  (exit Turn 1):      x={x_pos[int(6.0/dt)]:.1f}m, y={y_pos[int(6.0/dt)]:.1f}m")
    print(f"  t=9s  (exit Turn 2):      x={x_pos[int(9.0/dt)]:.1f}m, y={y_pos[int(9.0/dt)]:.1f}m")
    print(f"  t=12s (end lap):          v={total_speed[-1]:.1f}m/s ({total_speed[-1]*3.6:.0f}km/h)")
    print()

    return df

if __name__ == '__main__':
    df = create_f1_trajectory(duration=12.0, dt=0.02)

    print("=" * 80)
    print("DATASET READY FOR UKF TESTING")
    print("=" * 80)
    print("This dataset includes:")
    print("  ✓ High-speed straight (0-100 km/h in ~2.5s)")
    print("  ✓ Extreme braking (5-6G deceleration)")
    print("  ✓ Slow corner (tight radius, moderate lateral G)")
    print("  ✓ Fast corner (high-speed, high lateral G)")
    print("  ✓ Combined acceleration (longitudinal + lateral)")
    print()
    print("Use this to test UKF PREDICTION on extreme racing dynamics!")
    print()
