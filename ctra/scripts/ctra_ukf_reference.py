#!/usr/bin/env python3
"""
CTRA-UKF Reference Implementation (Constant Turn Rate and Acceleration)
Floating-point Python reference for VHDL validation.

State vector (7 elements):
  x = [px, py, v, theta, omega, a, z]
  px, py  = 2D position (meters)
  v       = speed magnitude (m/s)
  theta   = heading angle (radians)
  omega   = yaw rate (rad/s)
  a       = longitudinal acceleration (m/s²)
  z       = altitude (meters)

Measurement vector (3 elements):
  z_meas = [px, py, z]  (position only, same as CA/Singer)

Process model:
  When |omega| > threshold (turning):
    px_new = px + (v/w)*sin(th+w*dt) - (v/w)*sin(th)
             + (a/(2*w²))*(cos(th) - cos(th+w*dt) + w*dt*sin(th+w*dt))  [simplified below]
    py_new = py - (v/w)*cos(th+w*dt) + (v/w)*cos(th)
             + (a/(2*w²))*(sin(th+w*dt) - sin(th) - w*dt*cos(th+w*dt))
    v_new  = v + a*dt
    th_new = theta + omega*dt
    w_new  = omega  (constant)
    a_new  = a      (constant)
    z_new  = z      (flat)

  When |omega| ≈ 0 (straight):
    px_new = px + v*cos(theta)*dt + 0.5*a*cos(theta)*dt²
    py_new = py + v*sin(theta)*dt + 0.5*a*sin(theta)*dt²
    v_new  = v + a*dt
    th_new = theta
    w_new  = omega
    a_new  = a
    z_new  = z

Parameters matched to F1 dynamics (50 Hz, dt=0.02s).
"""

import numpy as np
import csv
import sys
import os
import math

# ============================================================================
# CTRA State Indices
# ============================================================================
PX = 0   # x position
PY = 1   # y position
V  = 2   # speed magnitude
TH = 3   # heading angle (theta)
OM = 4   # yaw rate (omega)
AC = 5   # longitudinal acceleration
PZ = 6   # z position (altitude)

N = 7            # state dimension
N_SIGMA = 2*N+1  # 15 sigma points
DT = 0.02        # 50 Hz, matching existing UKFs

# Omega threshold for straight vs turn
OMEGA_THRESH = 1e-6

# ============================================================================
# UKF Parameters
# ============================================================================
ALPHA = 1.0
BETA = 2.0
KAPPA = 0.0

LAMBDA = ALPHA**2 * (N + KAPPA) - N  # = 0 for alpha=1, kappa=0
GAMMA = np.sqrt(N + LAMBDA)          # = sqrt(7) ≈ 2.6458

# UKF weights
W_M = np.zeros(N_SIGMA)
W_C = np.zeros(N_SIGMA)
W_M[0] = LAMBDA / (N + LAMBDA)       # = 0
W_C[0] = LAMBDA / (N + LAMBDA) + (1 - ALPHA**2 + BETA)  # = 2.0
for i in range(1, N_SIGMA):
    W_M[i] = 1.0 / (2.0 * (N + LAMBDA))  # = 1/14
    W_C[i] = 1.0 / (2.0 * (N + LAMBDA))

# Measurement matrix: extract [px, py, z] from 7-state
H = np.zeros((3, N))
H[0, PX] = 1.0  # px
H[1, PY] = 1.0  # py
H[2, PZ] = 1.0  # z

# ============================================================================
# Default Parameters (will be overridden by param sweep)
# ============================================================================
# Initial covariance
P_INIT = np.diag([
    5.0,    # px position variance
    5.0,    # py position variance
    20.0,   # speed variance
    0.1,    # heading variance (radians²)
    0.1,    # yaw rate variance
    1.0,    # acceleration variance
    5.0,    # z position variance
])

# Process noise (optimized via parameter sweep)
Q_DIAG = np.array([
    1.0,      # px noise
    1.0,      # py noise
    1500.0,   # speed noise (F1 has huge speed range 0-800 m/s)
    0.1,      # heading noise
    0.05,     # yaw rate noise
    500.0,    # acceleration noise (F1 braking: huge accel changes)
    1.0,      # z noise
])

# Measurement noise (optimized via parameter sweep)
R_DIAG = np.array([2.0, 2.0, 2.0])  # Position measurement variance


# ============================================================================
# CTRA Process Model
# ============================================================================
def ctra_predict_state(state, dt):
    """
    CTRA state transition for a single state vector.
    Handles both turning (|omega| > thresh) and straight-line cases.
    """
    px, py, v, theta, omega, a, z = state

    if abs(omega) > OMEGA_THRESH:
        # Turning case
        w = omega
        th_new = theta + w * dt
        v_new = v + a * dt

        sin_th = np.sin(theta)
        cos_th = np.cos(theta)
        sin_th_new = np.sin(th_new)
        cos_th_new = np.cos(th_new)

        # Position update (CTRA equations)
        # Using the standard form from literature:
        # px_new = px + (1/w²) * [(v*w + a*w*dt)*sin(th_new) - a*cos(th_new)]
        #            - (1/w²) * [v*w*sin(th) - a*cos(th)]
        # Simplified:
        px_new = px + (v_new * sin_th_new - v * sin_th) / w \
                    + a * (cos_th - cos_th_new) / (w * w)

        py_new = py + (-v_new * cos_th_new + v * cos_th) / w \
                    + a * (sin_th_new - sin_th) / (w * w)

        return np.array([px_new, py_new, v_new, th_new, w, a, z])
    else:
        # Straight-line case (omega ≈ 0)
        cos_th = np.cos(theta)
        sin_th = np.sin(theta)

        v_new = v + a * dt
        px_new = px + v * cos_th * dt + 0.5 * a * cos_th * dt**2
        py_new = py + v * sin_th * dt + 0.5 * a * sin_th * dt**2

        return np.array([px_new, py_new, v_new, theta, omega, a, z])


def wrap_angle(angle):
    """Wrap angle to [-pi, pi]."""
    return (angle + np.pi) % (2 * np.pi) - np.pi


# ============================================================================
# Standard UKF (Joseph form covariance update)
# ============================================================================
def ukf_predict(x, P, Q):
    """
    UKF prediction step with CTRA process model.
    Returns: x_pred, P_pred, chi_pred
    """
    # Generate sigma points
    L = np.linalg.cholesky(P)
    chi = np.zeros((N_SIGMA, N))
    chi[0] = x
    for i in range(N):
        chi[i + 1]     = x + GAMMA * L[:, i]
        chi[i + 1 + N] = x - GAMMA * L[:, i]

    # Propagate sigma points through CTRA model
    chi_pred = np.zeros((N_SIGMA, N))
    for i in range(N_SIGMA):
        chi_pred[i] = ctra_predict_state(chi[i], DT)

    # Compute predicted mean
    x_pred = np.zeros(N)
    for i in range(N_SIGMA):
        x_pred += W_M[i] * chi_pred[i]

    # Wrap predicted heading angle
    x_pred[TH] = wrap_angle(x_pred[TH])

    # Compute predicted covariance
    P_pred = np.zeros((N, N))
    for i in range(N_SIGMA):
        dx = chi_pred[i] - x_pred
        dx[TH] = wrap_angle(dx[TH])  # Wrap angle difference
        P_pred += W_C[i] * np.outer(dx, dx)
    P_pred += Q

    return x_pred, P_pred, chi_pred


def ukf_update(x_pred, P_pred, chi_pred, z_meas, R):
    """
    UKF measurement update with Joseph form.
    Returns: x_upd, P_upd
    """
    n_z = 3  # measurement dimension

    # Predicted measurement sigma points
    z_sigma = np.zeros((N_SIGMA, n_z))
    for i in range(N_SIGMA):
        z_sigma[i] = H @ chi_pred[i]  # Extract [px, py, z]

    # Measurement mean
    z_mean = np.zeros(n_z)
    for i in range(N_SIGMA):
        z_mean += W_M[i] * z_sigma[i]

    # Innovation
    nu = z_meas - z_mean

    # Innovation covariance
    S = np.zeros((n_z, n_z))
    for i in range(N_SIGMA):
        dz = z_sigma[i] - z_mean
        S += W_C[i] * np.outer(dz, dz)
    S += R

    # Cross-covariance
    Pxz = np.zeros((N, n_z))
    for i in range(N_SIGMA):
        dx = chi_pred[i] - x_pred
        dx[TH] = wrap_angle(dx[TH])
        dz = z_sigma[i] - z_mean
        Pxz += W_C[i] * np.outer(dx, dz)

    # Kalman gain
    K = Pxz @ np.linalg.inv(S)

    # State update
    x_upd = x_pred + K @ nu
    x_upd[TH] = wrap_angle(x_upd[TH])

    # Covariance update (Joseph form for numerical stability)
    IKH = np.eye(N) - K @ H
    P_upd = IKH @ P_pred @ IKH.T + K @ R @ K.T

    # Symmetrize
    P_upd = 0.5 * (P_upd + P_upd.T)

    return x_upd, P_upd


# ============================================================================
# Initialize heading from first measurements
# ============================================================================
def estimate_initial_heading(meas_data, n_init=5):
    """
    Estimate initial heading angle from first few measurement differences.
    Returns theta0 (radians) and v0 (speed estimate).
    """
    if len(meas_data) < 2:
        return 0.0, 0.0

    dx_total = 0.0
    dy_total = 0.0
    n = min(n_init, len(meas_data) - 1)
    for i in range(n):
        dx_total += meas_data[i+1][0] - meas_data[i][0]
        dy_total += meas_data[i+1][1] - meas_data[i][1]

    dx_avg = dx_total / n
    dy_avg = dy_total / n

    theta0 = np.arctan2(dy_avg, dx_avg)
    v0 = np.sqrt(dx_avg**2 + dy_avg**2) / DT

    return theta0, v0


# ============================================================================
# Load F1 data from CSV
# ============================================================================
def load_f1_csv(csv_path):
    """Load F1 trajectory data from CSV file.
    Returns: list of (meas_x, meas_y, meas_z) and list of (gt_x, gt_y, gt_z)
    """
    measurements = []
    ground_truth = []
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            measurements.append((
                float(row['meas_x']),
                float(row['meas_y']),
                float(row['meas_z'])
            ))
            ground_truth.append((
                float(row['gt_x_pos']),
                float(row['gt_y_pos']),
                float(row['gt_z_pos'])
            ))
    return measurements, ground_truth


# ============================================================================
# Run CTRA-UKF
# ============================================================================
def run_ctra_ukf(measurements, ground_truth=None, q_diag=None, r_diag=None,
                 p_init=None, verbose=False):
    """
    Run CTRA-UKF on measurement data.
    Returns: list of state estimates, RMSE (if ground truth provided)
    """
    if q_diag is None:
        q_diag = Q_DIAG
    if r_diag is None:
        r_diag = R_DIAG
    if p_init is None:
        p_init = np.diag(P_INIT)

    Q = np.diag(q_diag)
    R = np.diag(r_diag)
    P = np.diag(p_init)

    n_cycles = len(measurements)

    # Initialize state from first measurements
    theta0, v0 = estimate_initial_heading(measurements, n_init=3)

    x = np.array([
        measurements[0][0],  # px
        measurements[0][1],  # py
        v0,                  # initial speed estimate
        theta0,              # initial heading estimate
        0.0,                 # omega (zero initially)
        0.0,                 # acceleration (zero initially)
        measurements[0][2],  # z
    ])

    if verbose:
        print(f"Initial state: px={x[PX]:.2f}, py={x[PY]:.2f}, v={x[V]:.2f}, "
              f"theta={np.degrees(x[TH]):.1f}°, omega={x[OM]:.4f}, a={x[AC]:.2f}, z={x[PZ]:.2f}")

    estimates = []
    errors = []

    for cycle in range(n_cycles):
        z_meas = np.array(measurements[cycle])

        # Ensure P stays positive definite
        eigvals = np.linalg.eigvalsh(P)
        if np.min(eigvals) < 1e-10:
            P += np.eye(N) * 1e-8

        try:
            # Prediction
            x_pred, P_pred, chi_pred = ukf_predict(x, P, Q)

            # Update
            x_upd, P_upd = ukf_update(x_pred, P_pred, chi_pred, z_meas, R)

            x = x_upd
            P = P_upd
        except np.linalg.LinAlgError:
            # Cholesky failed — reset P
            if verbose:
                print(f"  Cycle {cycle}: Cholesky failed, resetting P")
            P = np.diag(p_init) * 0.1
            # Keep current x, skip update

        estimates.append(x.copy())

        # Compute error vs ground truth
        if ground_truth is not None:
            gt = ground_truth[cycle]
            ex = x[PX] - gt[0]
            ey = x[PY] - gt[1]
            ez = x[PZ] - gt[2]
            err_3d = np.sqrt(ex**2 + ey**2 + ez**2)
            errors.append(err_3d)

            if verbose and (cycle < 10 or (cycle + 1) % 50 == 0 or cycle == n_cycles - 1):
                print(f"Cycle {cycle:3d}: pos=[{x[PX]:.2f}, {x[PY]:.2f}, {x[PZ]:.2f}] "
                      f"v={x[V]:.2f} th={np.degrees(x[TH]):.1f}° w={x[OM]:.4f} a={x[AC]:.2f} "
                      f"err={err_3d:.4f}m")

    # Compute RMSE
    rmse = None
    if errors:
        rmse = np.sqrt(np.mean(np.array(errors)**2))

    return estimates, rmse, errors


# ============================================================================
# Main
# ============================================================================
def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    ca_dir = os.path.join(base_dir, '..', '..', 'ca_ukf')

    # Test datasets
    datasets = {
        'Monaco 750': os.path.join(ca_dir, 'test_data/real_world/f1_monaco_2024_750cycles.csv'),
        'Silverstone 750': os.path.join(ca_dir, 'test_data/real_world/f1_silverstone_2024_750cycles.csv'),
    }

    # Also try drone data for baseline comparison
    drone_path = os.path.join(ca_dir, 'test_data/real_world/synthetic_drone_500cycles.csv')
    if os.path.exists(drone_path):
        datasets['Drone 500'] = drone_path

    print("=" * 80)
    print("CTRA-UKF Reference Implementation")
    print(f"State: [px, py, v, theta, omega, a, z] (N={N})")
    print(f"Sigma points: {N_SIGMA}, dt={DT}s, gamma={GAMMA:.4f}")
    print(f"Q_diag: {Q_DIAG}")
    print(f"R_diag: {R_DIAG}")
    print("=" * 80)

    results = {}

    for name, csv_path in datasets.items():
        if not os.path.exists(csv_path):
            print(f"\n[{name}] Data file not found: {csv_path}")
            continue

        print(f"\n{'='*60}")
        print(f"Dataset: {name}")
        print(f"{'='*60}")

        measurements, ground_truth = load_f1_csv(csv_path)
        print(f"Loaded {len(measurements)} cycles")

        estimates, rmse, errors = run_ctra_ukf(
            measurements, ground_truth,
            verbose=True
        )

        if rmse is not None:
            print(f"\n  RMSE (full): {rmse:.4f} m")
            # Also compute RMSE at checkpoints
            for cp in [10, 100, 300, 500, 750]:
                if cp <= len(errors):
                    rmse_cp = np.sqrt(np.mean(np.array(errors[:cp])**2))
                    print(f"  RMSE @{cp:4d}: {rmse_cp:.4f} m")

            results[name] = rmse

    # Summary comparison
    print(f"\n{'='*80}")
    print("CTRA-UKF RESULTS SUMMARY")
    print(f"{'='*80}")
    for name, rmse in results.items():
        print(f"  {name:25s}: {rmse:.4f} m RMSE")

    print(f"\nReference (CA standard UKF):")
    print(f"  Monaco:      ~1.7m (estimated)")
    print(f"  Silverstone: ~1.7m (estimated)")
    print(f"  Drone:       0.882m")
    print(f"\nReference (Singer standard UKF):")
    print(f"  Drone:       0.995m")


if __name__ == '__main__':
    main()
