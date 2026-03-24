#!/usr/bin/env python3
"""
SR-UKF Parameter Sweep for CA Model
Finds optimal Q_POS, Q_VEL, Q_ACC, R values to minimize RMSE.
Uses the same Python SR-UKF implementation as sr_ukf_reference.py.
"""
import numpy as np
import re
import math
import sys
import os
from itertools import product

# ============================================================================
# Fixed parameters
# ============================================================================
N = 9
N_SIGMA = 2*N+1
DT = 0.02

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

P_INIT = np.diag([5.0, 20.0, 0.01, 5.0, 20.0, 0.01, 5.0, 20.0, 0.01])

H = np.zeros((3, N))
H[0, 0] = 1.0
H[1, 3] = 1.0
H[2, 6] = 1.0


def build_F():
    F = np.eye(N)
    for axis in range(3):
        base = 3 * axis
        F[base, base+1] = DT
        F[base, base+2] = 0.5 * DT**2
        F[base+1, base+2] = DT
    return F

F = build_F()


def cholupdate(L, u):
    L_new = L.copy()
    u_new = u.copy()
    n = len(u)
    for col in range(n):
        r = np.sqrt(L_new[col, col]**2 + u_new[col]**2)
        if r == 0:
            continue
        c = L_new[col, col] / r
        s = u_new[col] / r
        L_new[col, col] = r
        for row in range(col + 1, n):
            temp_L = c * L_new[row, col] + s * u_new[row]
            temp_u = c * u_new[row] - s * L_new[row, col]
            L_new[row, col] = temp_L
            u_new[row] = temp_u
    return L_new


def choldowndate(L, w):
    L_new = L.copy()
    w_new = w.copy()
    n = len(w)
    for col in range(n):
        r_sq = L_new[col, col]**2 - w_new[col]**2
        if r_sq <= 0:
            r = np.sqrt(abs(r_sq)) if r_sq < 0 else 0
            if r == 0:
                continue
        else:
            r = np.sqrt(r_sq)
        c = r / L_new[col, col]
        s = w_new[col] / L_new[col, col]
        L_new[col, col] = r
        for row in range(col + 1, n):
            temp_L = (L_new[row, col] - s * w_new[row]) / c if c != 0 else L_new[row, col]
            temp_w = c * w_new[row] - s * L_new[row, col]
            w_new[row] = temp_w
            L_new[row, col] = temp_L
    return L_new


def run_sr_ukf(q_pos, q_vel, q_acc, r_val, meas_data, truth_data, init_from_meas=False):
    """Run SR-UKF with given parameters. Returns RMSE."""
    Q_DIAG = np.array([q_pos, q_vel, q_acc, q_pos, q_vel, q_acc, q_pos, q_vel, q_acc])
    LQ = np.diag(np.sqrt(Q_DIAG))
    R = np.diag([r_val, r_val, r_val])

    L = np.linalg.cholesky(P_INIT)

    if init_from_meas:
        # Match VHDL initialization: state = first measurement
        x = np.zeros(N)
        x[0] = meas_data[0][0]  # x_pos
        x[3] = meas_data[0][1]  # y_pos
        x[6] = meas_data[0][2]  # z_pos
    else:
        x = np.zeros(N)

    n_cycles = len(meas_data)
    skip = 5
    sum_sq = 0.0
    count = 0

    for cyc in range(n_cycles):
        z = np.array(meas_data[cyc])

        # Predict
        chi = np.zeros((N_SIGMA, N))
        chi[0] = x
        for i in range(N):
            chi[i + 1] = x + GAMMA * L[:, i]
            chi[i + 1 + N] = x - GAMMA * L[:, i]

        chi_pred = np.zeros((N_SIGMA, N))
        for i in range(N_SIGMA):
            chi_pred[i] = F @ chi[i]

        x_pred = np.zeros(N)
        for i in range(N_SIGMA):
            x_pred += W_M[i] * chi_pred[i]

        # QR
        sqrt_wc = np.sqrt(W_C[1])
        A = np.zeros((N, N_SIGMA - 1))
        for j in range(N_SIGMA - 1):
            A[:, j] = sqrt_wc * (chi_pred[j + 1] - x_pred)
        Q_mat, R_mat = np.linalg.qr(A.T, mode='reduced')
        L_qr = R_mat.T
        for i in range(N):
            if L_qr[i, i] < 0:
                L_qr[i, :] *= -1

        # W0 update
        sqrt_wc0 = np.sqrt(abs(W_C[0]))
        w0_vec = sqrt_wc0 * (chi_pred[0] - x_pred)
        L_w0 = cholupdate(L_qr, w0_vec)

        # Process noise
        L_pred = L_w0.copy()
        for col in range(N):
            L_pred = cholupdate(L_pred, LQ[:, col])

        # Measurement update
        z_sigma = np.zeros((N_SIGMA, 3))
        for i in range(N_SIGMA):
            z_sigma[i] = H @ chi_pred[i]
        z_mean = np.zeros(3)
        for i in range(N_SIGMA):
            z_mean += W_M[i] * z_sigma[i]

        nu = z - z_mean

        Pxz = np.zeros((N, 3))
        S_yy = np.zeros((3, 3))
        for i in range(N_SIGMA):
            dx = chi_pred[i] - x_pred
            dz = z_sigma[i] - z_mean
            Pxz += W_C[i] * np.outer(dx, dz)
            S_yy += W_C[i] * np.outer(dz, dz)
        S_yy += R

        K = Pxz @ np.linalg.inv(S_yy)
        x_upd = x_pred + K @ nu

        L_upd = L_pred.copy()
        for m in range(3):
            sqrt_s = np.sqrt(S_yy[m, m])
            w = K[:, m] * sqrt_s
            try:
                L_upd = choldowndate(L_upd, w)
            except:
                pass

        x = x_upd
        L = L_upd

        # Accumulate RMSE
        if cyc >= skip:
            dx = x[0] - truth_data[cyc][0]
            dy = x[3] - truth_data[cyc][1]
            dz = x[6] - truth_data[cyc][2]
            sum_sq += dx*dx + dy*dy + dz*dz
            count += 1

    return math.sqrt(sum_sq / count) if count > 0 else float('inf')


def load_data(csv_path):
    """Load truth and measurement data from CSV."""
    truth = []
    meas = []
    with open(csv_path) as f:
        next(f)  # skip header
        for line in f:
            p = line.strip().split(',')
            truth.append((float(p[2]), float(p[3]), float(p[4])))
            meas.append((float(p[11]), float(p[12]), float(p[13])))
    return truth, meas


def main():
    csv_path = os.path.join(os.path.dirname(__file__), 'test_data/real_world/synthetic_drone_500cycles.csv')
    truth, meas = load_data(csv_path)

    print("=" * 80)
    print("SR-UKF Parameter Sweep (CA Model)")
    print("=" * 80)

    # First: baseline with current VHDL parameters
    baseline_rmse = run_sr_ukf(0.05, 0.00025, 0.00001, 0.25, meas, truth, init_from_meas=False)
    baseline_vhdl = run_sr_ukf(0.05, 0.00025, 0.00001, 0.25, meas, truth, init_from_meas=True)
    print(f"\nBaseline (Python init=zero):   RMSE = {baseline_rmse:.6f} m")
    print(f"Baseline (VHDL init=meas):     RMSE = {baseline_vhdl:.6f} m")

    # Phase 1: Coarse sweep of Q_POS and R
    print("\n--- Phase 1: Coarse sweep Q_POS x R ---")
    q_pos_values = [0.01, 0.02, 0.03, 0.05, 0.08, 0.1, 0.15, 0.2, 0.3, 0.5]
    r_values = [0.1, 0.15, 0.2, 0.25, 0.3, 0.4, 0.5]

    best_rmse = float('inf')
    best_params = None
    results = []

    for q_pos, r_val in product(q_pos_values, r_values):
        rmse = run_sr_ukf(q_pos, 0.00025, 0.00001, r_val, meas, truth, init_from_meas=True)
        results.append((rmse, q_pos, r_val))
        if rmse < best_rmse:
            best_rmse = rmse
            best_params = (q_pos, 0.00025, 0.00001, r_val)

    results.sort()
    print(f"\nTop 10 (Q_VEL=0.00025, Q_ACC=0.00001):")
    print(f"{'Rank':>4} {'Q_POS':>8} {'R':>6} {'RMSE':>10}")
    for i, (rmse, q_pos, r_val) in enumerate(results[:10]):
        print(f"{i+1:4d} {q_pos:8.4f} {r_val:6.3f} {rmse:10.6f}")

    # Phase 2: Fine-tune Q_VEL around best Q_POS and R
    best_q_pos = best_params[0]
    best_r = best_params[3]

    print(f"\n--- Phase 2: Fine-tune Q_VEL (Q_POS={best_q_pos}, R={best_r}) ---")
    q_vel_values = [0.0001, 0.00015, 0.0002, 0.00025, 0.0003, 0.0004, 0.0005, 0.001, 0.002, 0.005]

    best_results_2 = []
    for q_vel in q_vel_values:
        rmse = run_sr_ukf(best_q_pos, q_vel, 0.00001, best_r, meas, truth, init_from_meas=True)
        best_results_2.append((rmse, q_vel))
        if rmse < best_rmse:
            best_rmse = rmse
            best_params = (best_q_pos, q_vel, 0.00001, best_r)

    best_results_2.sort()
    print(f"{'Q_VEL':>10} {'RMSE':>10}")
    for rmse, q_vel in best_results_2:
        print(f"{q_vel:10.6f} {rmse:10.6f}")

    # Phase 3: Fine-tune Q_ACC
    best_q_vel = best_params[1]

    print(f"\n--- Phase 3: Fine-tune Q_ACC (Q_POS={best_q_pos}, Q_VEL={best_q_vel}, R={best_r}) ---")
    q_acc_values = [0.000001, 0.000005, 0.00001, 0.00005, 0.0001, 0.0005, 0.001, 0.005, 0.01]

    best_results_3 = []
    for q_acc in q_acc_values:
        rmse = run_sr_ukf(best_q_pos, best_q_vel, q_acc, best_r, meas, truth, init_from_meas=True)
        best_results_3.append((rmse, q_acc))
        if rmse < best_rmse:
            best_rmse = rmse
            best_params = (best_q_pos, best_q_vel, q_acc, best_r)

    best_results_3.sort()
    print(f"{'Q_ACC':>10} {'RMSE':>10}")
    for rmse, q_acc in best_results_3:
        print(f"{q_acc:10.6f} {rmse:10.6f}")

    # Phase 4: Ultra-fine sweep around best values
    best_q_acc = best_params[2]
    print(f"\n--- Phase 4: Ultra-fine sweep around best ---")
    q_pos_fine = [best_q_pos * f for f in [0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.5]]
    r_fine = [best_r * f for f in [0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3]]

    best_results_4 = []
    for q_pos, r_val in product(q_pos_fine, r_fine):
        rmse = run_sr_ukf(q_pos, best_q_vel, best_q_acc, r_val, meas, truth, init_from_meas=True)
        best_results_4.append((rmse, q_pos, r_val))
        if rmse < best_rmse:
            best_rmse = rmse
            best_params = (q_pos, best_q_vel, best_q_acc, r_val)

    best_results_4.sort()
    print(f"\nTop 10 fine-tuned:")
    print(f"{'Rank':>4} {'Q_POS':>8} {'R':>8} {'RMSE':>10}")
    for i, (rmse, q_pos, r_val) in enumerate(best_results_4[:10]):
        print(f"{i+1:4d} {q_pos:8.5f} {r_val:8.5f} {rmse:10.6f}")

    # Final summary
    print("\n" + "=" * 80)
    print("OPTIMAL PARAMETERS")
    print("=" * 80)
    print(f"  Q_POS = {best_params[0]:.6f}")
    print(f"  Q_VEL = {best_params[1]:.6f}")
    print(f"  Q_ACC = {best_params[2]:.6f}")
    print(f"  R     = {best_params[3]:.6f}")
    print(f"  RMSE  = {best_rmse:.6f} m")
    print(f"  vs baseline (Python): {baseline_rmse:.6f} m ({(baseline_rmse-best_rmse)*1000:.1f}mm improvement)")
    print(f"  vs baseline (VHDL):   {baseline_vhdl:.6f} m ({(baseline_vhdl-best_rmse)*1000:.1f}mm improvement)")

    # Compute Q24.24 constants for VHDL
    Q24 = 2**24
    print("\n--- VHDL Constants (Q24.24) ---")
    print(f"  sqrt(Q_POS) = {np.sqrt(best_params[0]):.8f} = {int(np.sqrt(best_params[0]) * Q24)}")
    print(f"  sqrt(Q_VEL) = {np.sqrt(best_params[1]):.8f} = {int(np.sqrt(best_params[1]) * Q24)}")
    print(f"  sqrt(Q_ACC) = {np.sqrt(best_params[2]):.8f} = {int(np.sqrt(best_params[2]) * Q24)}")
    print(f"  R           = {best_params[3]:.8f} = {int(best_params[3] * Q24)}")


if __name__ == '__main__':
    main()
