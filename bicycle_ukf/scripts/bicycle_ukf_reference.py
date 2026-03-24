#!/usr/bin/env python3
"""
Kinematic Bicycle Model UKF Reference Implementation
Floating-point Python reference for VHDL validation.

State vector (7 elements):
  x = [px, py, v, theta, delta, a, z]
  px, py  = 2D position (meters)
  v       = speed magnitude (m/s)
  theta   = heading angle (radians)
  delta   = front-wheel steering angle (radians)
  a       = longitudinal acceleration (m/s²)
  z       = altitude (meters)

Measurement vector (3 elements):
  z_meas = [px, py, z]  (position only)

Process model (kinematic bicycle, small-angle side-slip):
  beta    = (lr/L) * delta        -- side-slip angle at CG
  v_new   = v + a * dt
  th_new  = theta + (v * delta / L) * dt
  px_new  = px + v * cos(theta + beta) * dt
  py_new  = py + v * sin(theta + beta) * dt
  delta_new = delta  (constant steering)
  a_new     = a      (constant acceleration)
  z_new     = z      (flat)

F1 geometry: L = 3.6m, lr = 1.6m (CG to rear axle)
"""

import numpy as np
import csv
import sys
import os
import math

# ============================================================================
# State Indices
# ============================================================================
PX = 0   # x position
PY = 1   # y position
V  = 2   # speed magnitude
TH = 3   # heading angle (theta)
DL = 4   # steering angle (delta)
AC = 5   # longitudinal acceleration
PZ = 6   # z position (altitude)

N = 7            # state dimension
N_SIGMA = 2*N+1  # 15 sigma points
DT = 0.02        # 50 Hz

# Bicycle geometry
L  = 3.6    # wheelbase (m)
LR = 1.6    # CG to rear axle (m)
LR_OVER_L = LR / L  # 0.44444

# ============================================================================
# UKF Parameters
# ============================================================================
ALPHA = 1.0
BETA_UKF = 2.0
KAPPA = 0.0

LAMBDA = ALPHA**2 * (N + KAPPA) - N  # = 0 for alpha=1, kappa=0
GAMMA = np.sqrt(N + LAMBDA)          # = sqrt(7) ≈ 2.6458

# UKF weights
W_M = np.zeros(N_SIGMA)
W_C = np.zeros(N_SIGMA)
W_M[0] = LAMBDA / (N + LAMBDA)       # = 0
W_C[0] = LAMBDA / (N + LAMBDA) + (1 - ALPHA**2 + BETA_UKF)  # = 2.0
for i in range(1, N_SIGMA):
    W_M[i] = 1.0 / (2.0 * (N + LAMBDA))  # = 1/14
    W_C[i] = 1.0 / (2.0 * (N + LAMBDA))

# Measurement matrix: extract [px, py, z] from 7-state
H = np.zeros((3, N))
H[0, PX] = 1.0
H[1, PY] = 1.0
H[2, PZ] = 1.0

# ============================================================================
# Default Parameters
# ============================================================================
P_INIT = np.diag([
    5.0,    # px
    5.0,    # py
    20.0,   # speed
    0.1,    # heading
    0.1,    # steering angle
    1.0,    # acceleration
    5.0,    # z
])

Q_DIAG = np.array([
    0.5,      # px noise
    0.5,      # py noise
    10.0,     # speed noise (reduced from 100 for F1 stability)
    0.05,     # heading noise
    0.001,    # steering angle noise (slow change at 50 Hz)
    5.0,      # acceleration noise (reduced from 50 for F1 stability)
    0.5,      # z noise
])

R_DIAG = np.array([2.0, 2.0, 2.0])


# ============================================================================
# Bicycle Process Model
# ============================================================================
def bicycle_predict_state(state, dt):
    """
    Kinematic bicycle model state transition.
    Uses small-angle approximation for side-slip: beta ≈ (lr/L) * delta
    """
    px, py, v, theta, delta, a, z = state

    beta = LR_OVER_L * delta
    v_new = v + a * dt
    th_new = theta + (v * delta / L) * dt
    px_new = px + v * np.cos(theta + beta) * dt
    py_new = py + v * np.sin(theta + beta) * dt

    return np.array([px_new, py_new, v_new, th_new, delta, a, z])


def wrap_angle(angle):
    """Wrap angle to [-pi, pi]."""
    return (angle + np.pi) % (2 * np.pi) - np.pi


# ============================================================================
# Standard UKF (Joseph form covariance update)
# ============================================================================
def ukf_predict(x, P, Q):
    L_chol = np.linalg.cholesky(P)
    chi = np.zeros((N_SIGMA, N))
    chi[0] = x
    for i in range(N):
        chi[i + 1]     = x + GAMMA * L_chol[:, i]
        chi[i + 1 + N] = x - GAMMA * L_chol[:, i]

    chi_pred = np.zeros((N_SIGMA, N))
    for i in range(N_SIGMA):
        chi_pred[i] = bicycle_predict_state(chi[i], DT)

    x_pred = np.zeros(N)
    for i in range(N_SIGMA):
        x_pred += W_M[i] * chi_pred[i]
    x_pred[TH] = wrap_angle(x_pred[TH])

    P_pred = np.zeros((N, N))
    for i in range(N_SIGMA):
        dx = chi_pred[i] - x_pred
        dx[TH] = wrap_angle(dx[TH])
        P_pred += W_C[i] * np.outer(dx, dx)
    P_pred += Q

    return x_pred, P_pred, chi_pred


def ukf_update(x_pred, P_pred, chi_pred, z_meas, R):
    n_z = 3

    z_sigma = np.zeros((N_SIGMA, n_z))
    for i in range(N_SIGMA):
        z_sigma[i] = H @ chi_pred[i]

    z_mean = np.zeros(n_z)
    for i in range(N_SIGMA):
        z_mean += W_M[i] * z_sigma[i]

    nu = z_meas - z_mean

    S = np.zeros((n_z, n_z))
    for i in range(N_SIGMA):
        dz = z_sigma[i] - z_mean
        S += W_C[i] * np.outer(dz, dz)
    S += R

    Pxz = np.zeros((N, n_z))
    for i in range(N_SIGMA):
        dx = chi_pred[i] - x_pred
        dx[TH] = wrap_angle(dx[TH])
        dz = z_sigma[i] - z_mean
        Pxz += W_C[i] * np.outer(dx, dz)

    K = Pxz @ np.linalg.inv(S)

    x_upd = x_pred + K @ nu
    x_upd[TH] = wrap_angle(x_upd[TH])

    IKH = np.eye(N) - K @ H
    P_upd = IKH @ P_pred @ IKH.T + K @ R @ K.T
    P_upd = 0.5 * (P_upd + P_upd.T)

    return x_upd, P_upd


# ============================================================================
# Initialize heading from first measurements
# ============================================================================
def estimate_initial_heading(meas_data, n_init=5):
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
# Run Bicycle UKF
# ============================================================================
def run_bicycle_ukf(measurements, ground_truth=None, q_diag=None, r_diag=None,
                    p_init=None, verbose=False):
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

    theta0, v0 = estimate_initial_heading(measurements, n_init=3)

    x = np.array([
        measurements[0][0],  # px
        measurements[0][1],  # py
        v0,                  # initial speed estimate
        theta0,              # initial heading estimate
        0.0,                 # delta (zero initial steering)
        0.0,                 # acceleration
        measurements[0][2],  # z
    ])

    if verbose:
        print(f"Initial state: px={x[PX]:.2f}, py={x[PY]:.2f}, v={x[V]:.2f}, "
              f"theta={np.degrees(x[TH]):.1f}°, delta={x[DL]:.4f}, a={x[AC]:.2f}, z={x[PZ]:.2f}")

    estimates = []
    errors = []

    for cycle in range(n_cycles):
        z_meas = np.array(measurements[cycle])

        eigvals = np.linalg.eigvalsh(P)
        if np.min(eigvals) < 1e-10:
            P += np.eye(N) * 1e-8

        try:
            x_pred, P_pred, chi_pred = ukf_predict(x, P, Q)
            x_upd, P_upd = ukf_update(x_pred, P_pred, chi_pred, z_meas, R)
            x = x_upd
            P = P_upd
        except np.linalg.LinAlgError:
            if verbose:
                print(f"  Cycle {cycle}: Cholesky failed, resetting P")
            P = np.diag(p_init) * 0.1

        estimates.append(x.copy())

        if ground_truth is not None:
            gt = ground_truth[cycle]
            ex = x[PX] - gt[0]
            ey = x[PY] - gt[1]
            ez = x[PZ] - gt[2]
            err_3d = np.sqrt(ex**2 + ey**2 + ez**2)
            errors.append(err_3d)

            if verbose and (cycle < 10 or (cycle + 1) % 50 == 0 or cycle == n_cycles - 1):
                print(f"Cycle {cycle:3d}: pos=[{x[PX]:.2f}, {x[PY]:.2f}, {x[PZ]:.2f}] "
                      f"v={x[V]:.2f} th={np.degrees(x[TH]):.1f}° δ={x[DL]:.4f} a={x[AC]:.2f} "
                      f"err={err_3d:.4f}m")

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

    datasets = {
        'Monaco 750': os.path.join(ca_dir, 'test_data/real_world/f1_monaco_2024_750cycles.csv'),
        'Silverstone 750': os.path.join(ca_dir, 'test_data/real_world/f1_silverstone_2024_750cycles.csv'),
    }

    drone_path = os.path.join(ca_dir, 'test_data/real_world/synthetic_drone_500cycles.csv')
    if os.path.exists(drone_path):
        datasets['Drone 500'] = drone_path

    print("=" * 80)
    print("Bicycle UKF Reference Implementation (Kinematic Bicycle Model)")
    print(f"State: [px, py, v, theta, delta, a, z] (N={N})")
    print(f"Sigma points: {N_SIGMA}, dt={DT}s, gamma={GAMMA:.4f}")
    print(f"Geometry: L={L}m, lr={LR}m, lr/L={LR_OVER_L:.4f}")
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

        estimates, rmse, errors = run_bicycle_ukf(
            measurements, ground_truth,
            verbose=True
        )

        if rmse is not None:
            print(f"\n  RMSE (full): {rmse:.4f} m")
            for cp in [10, 100, 300, 500, 750]:
                if cp <= len(errors):
                    rmse_cp = np.sqrt(np.mean(np.array(errors[:cp])**2))
                    print(f"  RMSE @{cp:4d}: {rmse_cp:.4f} m")

            results[name] = rmse

    print(f"\n{'='*80}")
    print("BICYCLE UKF RESULTS SUMMARY")
    print(f"{'='*80}")
    for name, rmse in results.items():
        print(f"  {name:25s}: {rmse:.4f} m RMSE")


if __name__ == '__main__':
    main()
