#!/usr/bin/env python3
"""
SR-UKF F1 Parameter Sweep for CA Model
Sweeps Q_POS, Q_VEL, Q_ACC, R on F1 racing data.
Uses Constant Acceleration F-matrix.
"""
import numpy as np
import math
import os
import sys
from itertools import product

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


def build_F_ca():
    F = np.eye(N)
    for axis in range(3):
        base = 3 * axis
        F[base, base+1] = DT
        F[base, base+2] = 0.5 * DT**2
        F[base+1, base+2] = DT
    return F

F = build_F_ca()


def cholupdate(L, u):
    L_new = L.copy(); u_new = u.copy(); n = len(u)
    for col in range(n):
        r = np.sqrt(L_new[col, col]**2 + u_new[col]**2)
        if r == 0: continue
        c = L_new[col, col] / r; s = u_new[col] / r
        L_new[col, col] = r
        for row in range(col + 1, n):
            temp_L = c * L_new[row, col] + s * u_new[row]
            temp_u = c * u_new[row] - s * L_new[row, col]
            L_new[row, col] = temp_L; u_new[row] = temp_u
    return L_new


def choldowndate(L, w):
    L_new = L.copy(); w_new = w.copy(); n = len(w)
    for col in range(n):
        r_sq = L_new[col, col]**2 - w_new[col]**2
        if r_sq <= 0:
            r = np.sqrt(abs(r_sq)) if r_sq < 0 else 0
            if r == 0: continue
        else:
            r = np.sqrt(r_sq)
        c = r / L_new[col, col]; s = w_new[col] / L_new[col, col]
        L_new[col, col] = r
        for row in range(col + 1, n):
            temp_L = (L_new[row, col] - s * w_new[row]) / c if c != 0 else L_new[row, col]
            temp_w = c * w_new[row] - s * L_new[row, col]
            w_new[row] = temp_w; L_new[row, col] = temp_L
    return L_new


def run_sr_ukf(q_pos, q_vel, q_acc, r_val, meas_data, truth_data):
    Q_DIAG = np.array([q_pos, q_vel, q_acc, q_pos, q_vel, q_acc, q_pos, q_vel, q_acc])
    LQ = np.diag(np.sqrt(Q_DIAG))
    R = np.diag([r_val, r_val, r_val])
    L = np.linalg.cholesky(P_INIT)
    x = np.zeros(N)
    x[0] = meas_data[0][0]; x[3] = meas_data[0][1]; x[6] = meas_data[0][2]
    n_cycles = len(meas_data)
    skip = 10
    sum_sq = 0.0; count = 0

    for cyc in range(n_cycles):
        z = np.array(meas_data[cyc])
        chi = np.zeros((N_SIGMA, N)); chi[0] = x
        for i in range(N):
            chi[i + 1] = x + GAMMA * L[:, i]
            chi[i + 1 + N] = x - GAMMA * L[:, i]
        chi_pred = np.zeros((N_SIGMA, N))
        for i in range(N_SIGMA):
            chi_pred[i] = F @ chi[i]
        x_pred = np.zeros(N)
        for i in range(N_SIGMA):
            x_pred += W_M[i] * chi_pred[i]
        sqrt_wc = np.sqrt(W_C[1])
        A = np.zeros((N, N_SIGMA - 1))
        for j in range(N_SIGMA - 1):
            A[:, j] = sqrt_wc * (chi_pred[j + 1] - x_pred)
        Q_mat, R_mat = np.linalg.qr(A.T, mode='reduced')
        L_qr = R_mat.T
        for i in range(N):
            if L_qr[i, i] < 0: L_qr[i, :] *= -1
        sqrt_wc0 = np.sqrt(abs(W_C[0]))
        w0_vec = sqrt_wc0 * (chi_pred[0] - x_pred)
        L_w0 = cholupdate(L_qr, w0_vec)
        L_pred = L_w0.copy()
        for col in range(N):
            L_pred = cholupdate(L_pred, LQ[:, col])
        z_sigma = np.zeros((N_SIGMA, 3))
        for i in range(N_SIGMA):
            z_sigma[i] = H @ chi_pred[i]
        z_mean = np.zeros(3)
        for i in range(N_SIGMA):
            z_mean += W_M[i] * z_sigma[i]
        nu = z - z_mean
        Pxz = np.zeros((N, 3)); S_yy = np.zeros((3, 3))
        for i in range(N_SIGMA):
            dx = chi_pred[i] - x_pred; dz = z_sigma[i] - z_mean
            Pxz += W_C[i] * np.outer(dx, dz)
            S_yy += W_C[i] * np.outer(dz, dz)
        S_yy += R
        K = Pxz @ np.linalg.inv(S_yy)
        x_upd = x_pred + K @ nu
        L_upd = L_pred.copy()
        for m in range(3):
            sqrt_s = np.sqrt(S_yy[m, m])
            w = K[:, m] * sqrt_s
            try: L_upd = choldowndate(L_upd, w)
            except: pass
        x = x_upd; L = L_upd
        if cyc >= skip:
            dx = x[0] - truth_data[cyc][0]; dy = x[3] - truth_data[cyc][1]; dz_e = x[6] - truth_data[cyc][2]
            sum_sq += dx*dx + dy*dy + dz_e*dz_e; count += 1
    return math.sqrt(sum_sq / count) if count > 0 else float('inf')


def load_data(csv_path):
    truth = []; meas = []
    with open(csv_path) as f:
        next(f)
        for line in f:
            p = line.strip().split(',')
            truth.append((float(p[2]), float(p[3]), float(p[4])))
            meas.append((float(p[5]), float(p[6]), float(p[7])))
    return truth, meas


def sweep(track_name, csv_path):
    truth, meas = load_data(csv_path)
    print(f"\n{'='*80}")
    print(f"CA SR-UKF F1 Sweep: {track_name} ({len(truth)} cycles)")
    print(f"{'='*80}")

    baseline = run_sr_ukf(0.021, 0.005, 0.01, 0.13, meas, truth)
    print(f"Baseline (drone-optimized): RMSE = {baseline:.4f} m")

    # Phase 1: Coarse Q_POS x R (F1 needs much larger Q values)
    print("\n--- Phase 1: Coarse Q_POS x R ---")
    q_pos_vals = [0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0]
    r_vals = [0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0]
    best_rmse = float('inf'); best_params = None; results = []
    for q_pos, r_val in product(q_pos_vals, r_vals):
        rmse = run_sr_ukf(q_pos, 0.01, 0.01, r_val, meas, truth)
        results.append((rmse, q_pos, r_val))
        if rmse < best_rmse:
            best_rmse = rmse; best_params = (q_pos, 0.01, 0.01, r_val)
    results.sort()
    print(f"Top 10:")
    for i, (rmse, q_pos, r_val) in enumerate(results[:10]):
        print(f"  {i+1:2d}. Q_POS={q_pos:8.2f} R={r_val:6.2f} RMSE={rmse:.4f}")

    # Phase 2: Q_VEL
    best_q_pos = best_params[0]; best_r = best_params[3]
    print(f"\n--- Phase 2: Q_VEL (Q_POS={best_q_pos}, R={best_r}) ---")
    q_vel_vals = [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1.0, 5.0, 10.0]
    for q_vel in q_vel_vals:
        rmse = run_sr_ukf(best_q_pos, q_vel, 0.01, best_r, meas, truth)
        print(f"  Q_VEL={q_vel:8.4f} RMSE={rmse:.4f}")
        if rmse < best_rmse:
            best_rmse = rmse; best_params = (best_q_pos, q_vel, 0.01, best_r)

    # Phase 3: Q_ACC
    best_q_vel = best_params[1]
    print(f"\n--- Phase 3: Q_ACC (Q_POS={best_q_pos}, Q_VEL={best_q_vel}, R={best_r}) ---")
    q_acc_vals = [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1.0, 5.0, 10.0, 50.0]
    for q_acc in q_acc_vals:
        rmse = run_sr_ukf(best_q_pos, best_q_vel, q_acc, best_r, meas, truth)
        print(f"  Q_ACC={q_acc:8.4f} RMSE={rmse:.4f}")
        if rmse < best_rmse:
            best_rmse = rmse; best_params = (best_q_pos, best_q_vel, q_acc, best_r)

    # Phase 4: Fine-tune
    best_q_acc = best_params[2]
    print(f"\n--- Phase 4: Fine-tune ---")
    q_pos_fine = [best_q_pos * f for f in [0.5, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.5, 2.0]]
    r_fine = [best_r * f for f in [0.5, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.5, 2.0]]
    results4 = []
    for q_pos, r_val in product(q_pos_fine, r_fine):
        rmse = run_sr_ukf(q_pos, best_q_vel, best_q_acc, r_val, meas, truth)
        results4.append((rmse, q_pos, r_val))
        if rmse < best_rmse:
            best_rmse = rmse; best_params = (q_pos, best_q_vel, best_q_acc, r_val)
    results4.sort()
    print(f"Top 5:")
    for i, (rmse, q_pos, r_val) in enumerate(results4[:5]):
        print(f"  {i+1}. Q_POS={q_pos:.4f} R={r_val:.4f} RMSE={rmse:.4f}")

    Q24 = 2**24
    print(f"\n{'='*60}")
    print(f"OPTIMAL for {track_name}:")
    print(f"  Q_POS={best_params[0]:.6f} Q_VEL={best_params[1]:.6f} Q_ACC={best_params[2]:.6f} R={best_params[3]:.6f}")
    print(f"  RMSE = {best_rmse:.4f} m (vs baseline {baseline:.4f} m)")
    print(f"  LQ_POS={int(np.sqrt(best_params[0])*Q24)} LQ_VEL={int(np.sqrt(best_params[1])*Q24)} LQ_ACC={int(np.sqrt(best_params[2])*Q24)}")
    print(f"  R_Q24={int(best_params[3]*Q24)}")
    return best_params, best_rmse


def main():
    # Use same F1 data from singers_model
    base = os.path.dirname(__file__)
    singer_base = os.path.join(base, '..', 'singers_model')
    monaco_csv = os.path.join(singer_base, 'scripts/singer_python_f1_monaco_2024_300cycles.csv')
    silverstone_csv = os.path.join(singer_base, 'python_f1_silverstone_2024_750cycles.csv')

    results = {}
    if os.path.exists(monaco_csv):
        results['Monaco'] = sweep('Monaco', monaco_csv)
    if os.path.exists(silverstone_csv):
        results['Silverstone'] = sweep('Silverstone', silverstone_csv)

    if len(results) == 2:
        print(f"\n{'='*80}")
        print("CROSS-VALIDATION")
        print(f"{'='*80}")
        monaco_truth, monaco_meas = load_data(monaco_csv)
        silver_truth, silver_meas = load_data(silverstone_csv)
        mp = results['Monaco'][0]; sp = results['Silverstone'][0]
        r1 = run_sr_ukf(mp[0], mp[1], mp[2], mp[3], silver_meas, silver_truth)
        print(f"Monaco params on Silverstone: RMSE = {r1:.4f} m")
        r2 = run_sr_ukf(sp[0], sp[1], sp[2], sp[3], monaco_meas, monaco_truth)
        print(f"Silverstone params on Monaco: RMSE = {r2:.4f} m")

        print(f"\n--- Finding universal F1 params ---")
        best_avg = float('inf'); best_uni = None
        q_pos_vals = [0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0]
        r_vals = [1.0, 2.0, 5.0, 10.0, 20.0]
        for q_pos, r_val in product(q_pos_vals, r_vals):
            for q_vel in [0.1, 1.0]:
                for q_acc in [0.1, 1.0]:
                    rm = run_sr_ukf(q_pos, q_vel, q_acc, r_val, monaco_meas, monaco_truth)
                    rs = run_sr_ukf(q_pos, q_vel, q_acc, r_val, silver_meas, silver_truth)
                    avg = (rm + rs) / 2
                    if avg < best_avg:
                        best_avg = avg; best_uni = (q_pos, q_vel, q_acc, r_val)
                        best_rm = rm; best_rs = rs

        Q24 = 2**24
        print(f"\nBest universal F1 params:")
        print(f"  Q_POS={best_uni[0]:.4f} Q_VEL={best_uni[1]:.4f} Q_ACC={best_uni[2]:.4f} R={best_uni[3]:.4f}")
        print(f"  Monaco RMSE={best_rm:.4f} m, Silverstone RMSE={best_rs:.4f} m, Avg={best_avg:.4f} m")
        print(f"  LQ_POS={int(np.sqrt(best_uni[0])*Q24)} LQ_VEL={int(np.sqrt(best_uni[1])*Q24)} LQ_ACC={int(np.sqrt(best_uni[2])*Q24)}")
        print(f"  R_Q24={int(best_uni[3]*Q24)}")


if __name__ == '__main__':
    main()
