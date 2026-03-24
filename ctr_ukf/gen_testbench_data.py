#!/usr/bin/env python3
"""
Generate 25-cycle helical turn trajectory data for CTR UKF testbench.
Circular motion in XY plane with constant Z climb.

Parameters:
  R = 100 m (turn radius)
  omega = 0.5 rad/s (turn rate)
  vz = 2.0 m/s (vertical climb rate)
  dt = 0.02 s (50 Hz, matching UKF design)
  N = 25 cycles

Trajectory:
  x(t) = R * sin(omega * t)
  y(t) = R * (1 - cos(omega * t))
  z(t) = vz * t

Output: Q24.24 fixed-point hex constants for VHDL testbench
"""

import math

# Parameters
R = 100.0       # radius in meters
omega = 0.5     # turn rate rad/s
vz = 2.0        # vertical velocity m/s
dt = 0.02       # time step (50 Hz)
N = 25          # number of cycles
SCALE = 2**24   # Q24.24 scale factor

# Small measurement noise (deterministic pseudo-noise for reproducibility)
noise_x = [ 0.3, -0.2,  0.1, -0.3,  0.2,
           -0.1,  0.3, -0.2,  0.1, -0.3,
            0.2, -0.1,  0.3, -0.2,  0.1,
           -0.3,  0.2, -0.1,  0.3, -0.2,
            0.1, -0.3,  0.2, -0.1,  0.3]
noise_y = [-0.2,  0.1, -0.3,  0.2, -0.1,
            0.3, -0.2,  0.1, -0.3,  0.2,
           -0.1,  0.3, -0.2,  0.1, -0.3,
            0.2, -0.1,  0.3, -0.2,  0.1,
           -0.3,  0.2, -0.1,  0.3, -0.2]
noise_z = [ 0.1, -0.1,  0.2, -0.2,  0.1,
           -0.1,  0.2, -0.2,  0.1, -0.1,
            0.2, -0.2,  0.1, -0.1,  0.2,
           -0.2,  0.1, -0.1,  0.2, -0.2,
            0.1, -0.1,  0.2, -0.2,  0.1]

def to_q24_hex(val):
    """Convert float to Q24.24 signed 48-bit hex string (12 digits)."""
    raw = int(round(val * SCALE))
    if raw < 0:
        raw = raw + (1 << 48)  # Two's complement for 48-bit
    return f"{raw:012X}"

def to_q24_int(val):
    """Convert float to Q24.24 signed integer."""
    return int(round(val * SCALE))

print("=" * 70)
print("CTR UKF 25-Cycle Helical Turn Testbench Data")
print(f"R={R}m, omega={omega} rad/s, vz={vz} m/s, dt={dt}s")
print("=" * 70)
print()

# Generate trajectory
print("-- Trajectory table:")
print(f"-- {'Cyc':>3} | {'t(s)':>5} | {'true_x':>10} | {'true_y':>10} | {'true_z':>8} | {'meas_x':>10} | {'meas_y':>10} | {'meas_z':>8}")
meas_data = []
true_data = []
for i in range(N):
    t = i * dt
    true_x = R * math.sin(omega * t)
    true_y = R * (1.0 - math.cos(omega * t))
    true_z = vz * t
    mx = true_x + noise_x[i]
    my = true_y + noise_y[i]
    mz = true_z + noise_z[i]
    meas_data.append((mx, my, mz))
    true_data.append((true_x, true_y, true_z))
    print(f"-- {i:3d} | {t:5.2f} | {true_x:10.4f} | {true_y:10.4f} | {true_z:8.4f} | {mx:10.4f} | {my:10.4f} | {mz:8.4f}")

print()
print("-- VHDL measurement arrays (Q24.24 hex, signed 48-bit):")
print()

# Print VHDL arrays
for axis_name, axis_idx in [("meas_x", 0), ("meas_y", 1), ("meas_z", 2)]:
    print(f"    constant {axis_name} : meas_array := (")
    for i in range(N):
        val = meas_data[i][axis_idx]
        hex_str = to_q24_hex(val)
        comma = "," if i < N-1 else " "
        true_val = true_data[i][axis_idx]
        print(f'        signed\'(X"{hex_str}"){comma}  -- {i:2d}: meas={val:10.4f}  true={true_val:10.4f}')
    print("    );")
    print()

# Print VHDL true-value arrays
for axis_name, axis_idx in [("true_x", 0), ("true_y", 1), ("true_z", 2)]:
    print(f"    constant {axis_name} : meas_array := (")
    for i in range(N):
        val = true_data[i][axis_idx]
        hex_str = to_q24_hex(val)
        comma = "," if i < N-1 else " "
        print(f'        signed\'(X"{hex_str}"){comma}  -- {i:2d}: {val:10.4f}')
    print("    );")
    print()

# Also print key reference values
print("-- Key reference values:")
print(f"-- omega_z true = {omega} rad/s => Q24.24 = 0x{to_q24_hex(omega)} (int={to_q24_int(omega)})")
print(f"-- vz true = {vz} m/s => Q24.24 = 0x{to_q24_hex(vz)} (int={to_q24_int(vz)})")
print(f"-- R = {R} m => Q24.24 = 0x{to_q24_hex(R)} (int={to_q24_int(R)})")
