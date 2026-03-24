#!/usr/bin/env python3
"""
CTRA-UKF Parameter Sweep v2 — Fixed divergence thresholds for F1 data.
F1 data has speeds up to 800+ m/s and rapid direction changes.
"""

import numpy as np
import csv
import sys
import os
import itertools

PX, PY, V, TH, OM, AC, PZ = 0, 1, 2, 3, 4, 5, 6
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


def wrap_angle(a):
    return (a + np.pi) % (2 * np.pi) - np.pi


def ctra_predict(s, dt):
    px, py, v, theta, omega, a, z = s
    v_new = v + a * dt
    if abs(omega) > OMEGA_THRESH:
        w = omega
        th_new = theta + w * dt
        st, ct = np.sin(theta), np.cos(theta)
        sn, cn = np.sin(th_new), np.cos(th_new)
        px_new = px + (v_new*sn - v*st)/w + a*(ct - cn)/(w*w)
        py_new = py + (-v_new*cn + v*ct)/w + a*(sn - st)/(w*w)
        return np.array([px_new, py_new, v_new, th_new, w, a, z])
    else:
        ct, st = np.cos(theta), np.sin(theta)
        px_new = px + v*ct*dt + 0.5*a*ct*dt**2
        py_new = py + v*st*dt + 0.5*a*st*dt**2
        return np.array([px_new, py_new, v_new, theta, omega, a, z])


def ukf_cycle(x, P, Q, R, z_meas):
    eigv = np.linalg.eigvalsh(P)
    if np.min(eigv) < 1e-10:
        P = P + np.eye(N) * 1e-8
    L = np.linalg.cholesky(P)
    chi = np.zeros((N_SIGMA, N))
    chi[0] = x
    for i in range(N):
        chi[i+1]   = x + GAMMA * L[:, i]
        chi[i+1+N] = x - GAMMA * L[:, i]

    chi_pred = np.zeros((N_SIGMA, N))
    for i in range(N_SIGMA):
        chi_pred[i] = ctra_predict(chi[i], DT)

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

    z_sigma = np.zeros((N_SIGMA, 3))
    for i in range(N_SIGMA):
        z_sigma[i] = H @ chi_pred[i]
    z_mean = np.zeros(3)
    for i in range(N_SIGMA):
        z_mean += W_M[i] * z_sigma[i]

    nu = z_meas - z_mean
    S = R.copy()
    Pxz = np.zeros((N, 3))
    for i in range(N_SIGMA):
        dx = chi_pred[i] - x_pred
        dx[TH] = wrap_angle(dx[TH])
        dz = z_sigma[i] - z_mean
        S += W_C[i] * np.outer(dz, dz)
        Pxz += W_C[i] * np.outer(dx, dz)

    K = Pxz @ np.linalg.inv(S)
    x_upd = x_pred + K @ nu
    x_upd[TH] = wrap_angle(x_upd[TH])
    IKH = np.eye(N) - K @ H
    P_upd = IKH @ P_pred @ IKH.T + K @ R @ K.T
    P_upd = 0.5 * (P_upd + P_upd.T)
    return x_upd, P_upd


def estimate_init(meas, n_init=5):
    n = min(n_init, len(meas) - 1)
    if n < 1:
        return np.array([meas[0][0], meas[0][1], 0, 0, 0, 0, meas[0][2]])
    vx_l, vy_l = [], []
    for i in range(n):
        vx_l.append((meas[i+1][0] - meas[i][0]) / DT)
        vy_l.append((meas[i+1][1] - meas[i][1]) / DT)
    vx, vy = np.mean(vx_l), np.mean(vy_l)
    v0 = np.sqrt(vx**2 + vy**2)
    theta0 = np.arctan2(vy, vx)
    a0 = 0.0
    if n >= 2:
        ax_l = [(vx_l[i+1]-vx_l[i])/DT for i in range(n-1)]
        ay_l = [(vy_l[i+1]-vy_l[i])/DT for i in range(n-1)]
        a0 = np.mean(ax_l)*np.cos(theta0) + np.mean(ay_l)*np.sin(theta0)
    omega0 = 0.0
    if n >= 3:
        ths = [np.arctan2(vy_l[i], vx_l[i]) for i in range(n)]
        omega0 = np.mean([wrap_angle(ths[i+1]-ths[i])/DT for i in range(len(ths)-1)])
    return np.array([meas[0][0], meas[0][1], v0, theta0, omega0, a0, meas[0][2]])


def run_ukf(meas, gt, q_diag, r_val, p_init_diag, max_v=5000):
    Q = np.diag(q_diag)
    R = np.diag([r_val]*3)
    P = np.diag(p_init_diag)
    x = estimate_init(meas, 5)
    sum_sq, count = 0.0, 0
    for c in range(len(meas)):
        try:
            x, P = ukf_cycle(x, P, Q, R, np.array(meas[c]))
        except:
            return 999.0
        # Relaxed thresholds: F1 data has v up to 800+
        if abs(x[V]) > max_v or abs(x[OM]) > 500 or abs(x[AC]) > 50000:
            return 999.0
        if np.any(np.isnan(x)):
            return 999.0
        g = gt[c]
        sum_sq += (x[PX]-g[0])**2 + (x[PY]-g[1])**2 + (x[PZ]-g[2])**2
        count += 1
    return np.sqrt(sum_sq / count) if count > 0 else 999.0


def load_csv(path):
    m, g = [], []
    with open(path) as f:
        reader = csv.DictReader(f)
        for r in reader:
            m.append((float(r['meas_x']), float(r['meas_y']), float(r['meas_z'])))
            g.append((float(r['gt_x_pos']), float(r['gt_y_pos']), float(r['gt_z_pos'])))
    return m, g


def main():
    base = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'ca_ukf', 'test_data', 'real_world')
    datasets = {}
    for name, fname in [('Monaco', 'f1_monaco_2024_750cycles.csv'),
                        ('Silverstone', 'f1_silverstone_2024_750cycles.csv'),
                        ('Drone', 'synthetic_drone_500cycles.csv')]:
        p = os.path.join(base, fname)
        if os.path.exists(p):
            datasets[name] = load_csv(p)

    # First check initial speeds
    for name, (m, g) in datasets.items():
        x0 = estimate_init(m, 5)
        print(f"{name}: init v={x0[V]:.1f} m/s, theta={np.degrees(x0[TH]):.1f}°, omega={x0[OM]:.4f}")

    print("\n" + "=" * 80)
    print("CTRA-UKF Parameter Sweep v2 (relaxed thresholds)")
    print("=" * 80)

    # Adaptive P_init based on data velocity scale
    # High-speed F1: need larger P_init for v and a
    p_init = [10.0, 10.0, 500.0, 1.0, 0.5, 100.0, 5.0]

    # Sweep parameters
    q_pos_vals   = [0.01, 0.05, 0.1]
    q_v_vals     = [1.0, 5.0, 10.0, 50.0]
    q_th_vals    = [0.001, 0.01, 0.05]
    q_om_vals    = [0.0001, 0.001, 0.005, 0.01, 0.05]
    q_a_vals     = [1.0, 5.0, 10.0, 50.0, 100.0]
    r_vals       = [0.1, 0.25, 0.5, 1.0]

    total = len(q_pos_vals)*len(q_v_vals)*len(q_th_vals)*len(q_om_vals)*len(q_a_vals)*len(r_vals)
    print(f"Combinations: {total}")

    results_all = []
    cnt = 0
    for q_pos, q_v, q_th, q_om, q_a, r_val in itertools.product(
            q_pos_vals, q_v_vals, q_th_vals, q_om_vals, q_a_vals, r_vals):
        q_diag = np.array([q_pos, q_pos, q_v, q_th, q_om, q_a, q_pos])
        cnt += 1
        if cnt % 200 == 0:
            print(f"  {cnt}/{total} ({100*cnt/total:.0f}%)")

        res = {}
        ok = True
        for name, (m, g) in datasets.items():
            rmse = run_ukf(m, g, q_diag, r_val, p_init)
            if rmse > 50:
                ok = False
                break
            res[name] = rmse

        if ok:
            wt = {'Monaco': 2.0, 'Silverstone': 2.0, 'Drone': 1.0}
            combined = sum(wt.get(n, 1)*v for n, v in res.items()) / sum(wt.get(n, 1) for n in res)
            results_all.append((combined, res, {
                'q_pos': q_pos, 'q_v': q_v, 'q_th': q_th,
                'q_om': q_om, 'q_a': q_a, 'r': r_val
            }))

    results_all.sort(key=lambda x: x[0])

    print(f"\n{'='*80}")
    print(f"TOP 25 RESULTS (of {len(results_all)} valid out of {total})")
    print(f"{'='*80}")
    print(f"{'#':>3} | {'q_pos':>6} {'q_v':>6} {'q_th':>6} {'q_om':>7} {'q_a':>6} {'R':>5} |", end='')
    for n in datasets:
        print(f" {n:>11}", end='')
    print(f" | {'Combined':>9}")
    print("-" * 110)

    for i, (comb, res, p) in enumerate(results_all[:25]):
        print(f"{i+1:3d} | {p['q_pos']:6.3f} {p['q_v']:6.2f} {p['q_th']:6.4f} "
              f"{p['q_om']:7.5f} {p['q_a']:6.2f} {p['r']:5.2f} |", end='')
        for n in datasets:
            print(f" {res.get(n, 999):11.4f}", end='')
        print(f" | {comb:9.4f}")

    if not results_all:
        print("  NO VALID RESULTS! All combinations diverged.")
        # Run a single diagnostic
        print("\nDiagnostic run with loose params:")
        q_diag = np.array([0.1, 0.1, 10.0, 0.01, 0.01, 10.0, 0.1])
        for name, (m, g) in datasets.items():
            rmse = run_ukf(m, g, q_diag, 0.5, p_init)
            print(f"  {name}: RMSE={rmse:.4f}")
        return

    # Best per dataset
    print(f"\n{'='*80}")
    print("BEST PER DATASET")
    print(f"{'='*80}")
    for dname in datasets:
        valid = [r for r in results_all if dname in r[1]]
        if valid:
            best = min(valid, key=lambda x: x[1][dname])
            print(f"  {dname:15s}: {best[1][dname]:.4f}m  | {best[2]}")

    if results_all:
        best = results_all[0]
        p = best[2]
        print(f"\n{'='*80}")
        print("OPTIMAL PARAMETERS")
        print(f"{'='*80}")
        print(f"Q_DIAG = [{p['q_pos']}, {p['q_pos']}, {p['q_v']}, {p['q_th']}, {p['q_om']}, {p['q_a']}, {p['q_pos']}]")
        print(f"R = {p['r']}")
        print(f"P_INIT = {p_init}")
        print(f"Combined RMSE: {best[0]:.4f}m")
        for n, v in best[1].items():
            print(f"  {n}: {v:.4f}m")


if __name__ == '__main__':
    main()
