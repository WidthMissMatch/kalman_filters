#!/usr/bin/env python3
"""
CTRA-UKF Parameter Sweep for F1 Data
Finds optimal Q/R parameters to minimize RMSE on F1 trajectories.
"""

import numpy as np
import csv
import sys
import os
import itertools
import math

# ============================================================================
# CTRA State Indices
# ============================================================================
PX = 0
PY = 1
V  = 2
TH = 3
OM = 4
AC = 5
PZ = 6

N = 7
N_SIGMA = 2*N+1
DT = 0.02

OMEGA_THRESH = 1e-6

ALPHA = 1.0
BETA = 2.0
KAPPA = 0.0
LAMBDA = ALPHA**2 * (N + KAPPA) - N
GAMMA = np.sqrt(N + LAMBDA)

W_M = np.zeros(N_SIGMA)
W_C = np.zeros(N_SIGMA)
W_M[0] = LAMBDA / (N + LAMBDA)
W_C[0] = LAMBDA / (N + LAMBDA) + (1 - ALPHA**2 + BETA)
for i in range(1, N_SIGMA):
    W_M[i] = 1.0 / (2.0 * (N + LAMBDA))
    W_C[i] = 1.0 / (2.0 * (N + LAMBDA))

H = np.zeros((3, N))
H[0, PX] = 1.0
H[1, PY] = 1.0
H[2, PZ] = 1.0


def wrap_angle(angle):
    return (angle + np.pi) % (2 * np.pi) - np.pi


def ctra_predict_state(state, dt):
    px, py, v, theta, omega, a, z = state
    v_new = v + a * dt

    if abs(omega) > OMEGA_THRESH:
        w = omega
        th_new = theta + w * dt
        sin_th = np.sin(theta)
        cos_th = np.cos(theta)
        sin_th_new = np.sin(th_new)
        cos_th_new = np.cos(th_new)

        px_new = px + (v_new * sin_th_new - v * sin_th) / w \
                    + a * (cos_th - cos_th_new) / (w * w)
        py_new = py + (-v_new * cos_th_new + v * cos_th) / w \
                    + a * (sin_th_new - sin_th) / (w * w)

        return np.array([px_new, py_new, v_new, th_new, w, a, z])
    else:
        cos_th = np.cos(theta)
        sin_th = np.sin(theta)
        px_new = px + v * cos_th * dt + 0.5 * a * cos_th * dt**2
        py_new = py + v * sin_th * dt + 0.5 * a * sin_th * dt**2
        return np.array([px_new, py_new, v_new, theta, omega, a, z])


def ukf_predict(x, P, Q):
    try:
        L = np.linalg.cholesky(P)
    except np.linalg.LinAlgError:
        P = P + np.eye(N) * 1e-6
        L = np.linalg.cholesky(P)

    chi = np.zeros((N_SIGMA, N))
    chi[0] = x
    for i in range(N):
        chi[i + 1]     = x + GAMMA * L[:, i]
        chi[i + 1 + N] = x - GAMMA * L[:, i]

    chi_pred = np.zeros((N_SIGMA, N))
    for i in range(N_SIGMA):
        chi_pred[i] = ctra_predict_state(chi[i], DT)

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


def load_f1_csv(csv_path):
    measurements = []
    ground_truth = []
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            measurements.append((float(row['meas_x']), float(row['meas_y']), float(row['meas_z'])))
            ground_truth.append((float(row['gt_x_pos']), float(row['gt_y_pos']), float(row['gt_z_pos'])))
    return measurements, ground_truth


def estimate_initial_state(meas, n_init=5):
    """Better initial state estimation using multiple measurements."""
    n = min(n_init, len(meas) - 1)
    if n < 1:
        return np.array([meas[0][0], meas[0][1], 0, 0, 0, 0, meas[0][2]])

    # Estimate velocity from position differences
    vx_list = []
    vy_list = []
    for i in range(n):
        vx_list.append((meas[i+1][0] - meas[i][0]) / DT)
        vy_list.append((meas[i+1][1] - meas[i][1]) / DT)

    vx = np.mean(vx_list)
    vy = np.mean(vy_list)
    v0 = np.sqrt(vx**2 + vy**2)
    theta0 = np.arctan2(vy, vx)

    # Estimate acceleration from velocity changes
    if n >= 2:
        ax_list = []
        ay_list = []
        for i in range(n - 1):
            ax_list.append((vx_list[i+1] - vx_list[i]) / DT)
            ay_list.append((vy_list[i+1] - vy_list[i]) / DT)
        # Longitudinal acceleration (in heading direction)
        ax = np.mean(ax_list)
        ay = np.mean(ay_list)
        a0 = ax * np.cos(theta0) + ay * np.sin(theta0)
    else:
        a0 = 0.0

    # Estimate yaw rate from heading changes
    if n >= 3:
        thetas = [np.arctan2(vy_list[i], vx_list[i]) for i in range(n)]
        omega_list = []
        for i in range(len(thetas) - 1):
            dth = wrap_angle(thetas[i+1] - thetas[i])
            omega_list.append(dth / DT)
        omega0 = np.mean(omega_list)
    else:
        omega0 = 0.0

    return np.array([meas[0][0], meas[0][1], v0, theta0, omega0, a0, meas[0][2]])


def run_ctra_ukf(measurements, ground_truth, q_diag, r_val, p_init_diag=None):
    """Run CTRA-UKF, return RMSE. Returns (rmse, diverged)."""
    Q = np.diag(q_diag)
    R = np.diag([r_val, r_val, r_val])

    if p_init_diag is None:
        p_init_diag = [5.0, 5.0, 100.0, 0.5, 1.0, 10.0, 5.0]
    P = np.diag(p_init_diag)

    x = estimate_initial_state(measurements, n_init=5)

    n_cycles = len(measurements)
    sum_sq = 0.0
    count = 0
    diverged = False

    for cycle in range(n_cycles):
        z_meas = np.array(measurements[cycle])

        # Check for P positive definiteness
        eigvals = np.linalg.eigvalsh(P)
        if np.min(eigvals) < 1e-10:
            P += np.eye(N) * 1e-8

        try:
            x_pred, P_pred, chi_pred = ukf_predict(x, P, Q)
            x_upd, P_upd = ukf_update(x_pred, P_pred, chi_pred, z_meas, R)
            x = x_upd
            P = P_upd
        except (np.linalg.LinAlgError, ValueError, FloatingPointError):
            return 999.0, True

        # Check for divergence
        if abs(x[V]) > 5000 or abs(x[OM]) > 100 or abs(x[AC]) > 5000:
            return 999.0, True
        if np.any(np.isnan(x)) or np.any(np.isinf(x)):
            return 999.0, True

        gt = ground_truth[cycle]
        ex = x[PX] - gt[0]
        ey = x[PY] - gt[1]
        ez = x[PZ] - gt[2]
        sum_sq += ex**2 + ey**2 + ez**2
        count += 1

    if count == 0:
        return 999.0, True

    rmse = np.sqrt(sum_sq / count)
    return rmse, diverged


def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    ca_dir = os.path.join(base_dir, '..', '..', 'ca_ukf')

    datasets = {}
    monaco_path = os.path.join(ca_dir, 'test_data/real_world/f1_monaco_2024_750cycles.csv')
    silverstone_path = os.path.join(ca_dir, 'test_data/real_world/f1_silverstone_2024_750cycles.csv')
    drone_path = os.path.join(ca_dir, 'test_data/real_world/synthetic_drone_500cycles.csv')

    if os.path.exists(monaco_path):
        datasets['Monaco'] = load_f1_csv(monaco_path)
    if os.path.exists(silverstone_path):
        datasets['Silverstone'] = load_f1_csv(silverstone_path)
    if os.path.exists(drone_path):
        datasets['Drone'] = load_f1_csv(drone_path)

    if not datasets:
        print("No datasets found!")
        sys.exit(1)

    print("=" * 80)
    print("CTRA-UKF Parameter Sweep")
    print("=" * 80)

    # Parameter grid
    # q_diag = [q_pos, q_pos, q_v, q_th, q_omega, q_a, q_z]
    q_pos_vals   = [0.01, 0.05, 0.1]
    q_v_vals     = [0.1, 0.5, 1.0, 5.0]
    q_th_vals    = [0.001, 0.01, 0.05]
    q_omega_vals = [0.01, 0.05, 0.1, 0.5]
    q_a_vals     = [0.1, 0.5, 1.0, 5.0, 10.0]
    r_vals       = [0.1, 0.25, 0.5, 1.0]

    # P_init
    p_init_diag = [5.0, 5.0, 100.0, 0.5, 1.0, 10.0, 5.0]

    total = len(q_pos_vals) * len(q_v_vals) * len(q_th_vals) * len(q_omega_vals) * len(q_a_vals) * len(r_vals)
    print(f"Total combinations: {total}")

    best_combined = {}
    best_per_dataset = {name: (999.0, None) for name in datasets}

    count = 0
    for q_pos, q_v, q_th, q_om, q_a, r_val in itertools.product(
            q_pos_vals, q_v_vals, q_th_vals, q_omega_vals, q_a_vals, r_vals):

        q_diag = np.array([q_pos, q_pos, q_v, q_th, q_om, q_a, q_pos])
        count += 1

        if count % 500 == 0:
            print(f"  Progress: {count}/{total} ({100*count/total:.1f}%)")

        results = {}
        all_valid = True
        for name, (meas, gt) in datasets.items():
            rmse, diverged = run_ctra_ukf(meas, gt, q_diag, r_val, p_init_diag)
            if diverged:
                all_valid = False
                break
            results[name] = rmse

            if rmse < best_per_dataset[name][0]:
                best_per_dataset[name] = (rmse, {
                    'q_pos': q_pos, 'q_v': q_v, 'q_th': q_th,
                    'q_om': q_om, 'q_a': q_a, 'r': r_val
                })

        if not all_valid:
            continue

        # Combined metric (weighted average)
        # Weight F1 datasets more since that's the target
        combined = 0
        weights = {'Monaco': 2.0, 'Silverstone': 2.0, 'Drone': 1.0}
        total_weight = 0
        for name, rmse in results.items():
            w = weights.get(name, 1.0)
            combined += w * rmse
            total_weight += w
        combined /= total_weight

        key = (q_pos, q_v, q_th, q_om, q_a, r_val)
        best_combined[key] = (combined, results)

    # Sort by combined RMSE
    sorted_results = sorted(best_combined.items(), key=lambda x: x[0][1])

    print(f"\n{'='*80}")
    print("TOP 20 PARAMETER SETS (by weighted combined RMSE)")
    print(f"{'='*80}")
    print(f"{'Rank':>4} | {'q_pos':>6} {'q_v':>6} {'q_th':>6} {'q_om':>6} {'q_a':>6} {'R':>6} | ", end='')
    for name in datasets:
        print(f"{name:>12}", end=' ')
    print(f"| {'Combined':>10}")
    print("-" * 100)

    for rank, (key, (combined, results)) in enumerate(sorted_results[:20]):
        q_pos, q_v, q_th, q_om, q_a, r_val = key
        print(f"{rank+1:4d} | {q_pos:6.3f} {q_v:6.3f} {q_th:6.4f} {q_om:6.3f} {q_a:6.2f} {r_val:6.2f} | ", end='')
        for name in datasets:
            print(f"{results.get(name, 999.0):12.4f}", end=' ')
        print(f"| {combined:10.4f}")

    # Best per dataset
    print(f"\n{'='*80}")
    print("BEST PER DATASET")
    print(f"{'='*80}")
    for name, (rmse, params) in best_per_dataset.items():
        if params:
            print(f"  {name:15s}: {rmse:.4f}m  | "
                  f"q_pos={params['q_pos']:.3f} q_v={params['q_v']:.3f} "
                  f"q_th={params['q_th']:.4f} q_om={params['q_om']:.3f} "
                  f"q_a={params['q_a']:.2f} R={params['r']:.2f}")

    # Print the winner
    if sorted_results:
        best_key = sorted_results[0][0]
        best_combined_rmse = sorted_results[0][1][0]
        best_results = sorted_results[0][1][1]
        q_pos, q_v, q_th, q_om, q_a, r_val = best_key
        print(f"\n{'='*80}")
        print("OPTIMAL PARAMETERS")
        print(f"{'='*80}")
        print(f"Q_DIAG = [{q_pos}, {q_pos}, {q_v}, {q_th}, {q_om}, {q_a}, {q_pos}]")
        print(f"R = {r_val}")
        print(f"Combined RMSE: {best_combined_rmse:.4f}m")
        for name, rmse in best_results.items():
            print(f"  {name}: {rmse:.4f}m")


if __name__ == '__main__':
    main()
