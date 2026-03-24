#!/usr/bin/env python3
"""Diagnose why VHDL Bicycle UKF diverges on F1 data while Python stays accurate."""

import csv, numpy as np, os, sys
from bicycle_ukf_reference import *

Q_SCALE = 2**24

def hex48(s):
    s = s.strip()
    if 'X' in s or 'U' in s: return None
    v = int(s, 16)
    if v >= (1<<47): v -= (1<<48)
    return v / Q_SCALE

def load_vhdl(path):
    data = []
    with open(path) as f:
        for row in csv.DictReader(f):
            data.append({
                'px': hex48(row['px_hex']), 'py': hex48(row['py_hex']), 'z': hex48(row['z_hex']),
                'v': hex48(row['v_hex']), 'th': hex48(row['theta_hex']),
                'dl': hex48(row['delta_hex']), 'a': hex48(row['a_hex']),
                'p11': hex48(row['p11_hex']), 'p22': hex48(row['p22_hex']),
                'p33': hex48(row['p33_hex']), 'p44': hex48(row['p44_hex']),
                'p55': hex48(row['p55_hex']), 'p66': hex48(row['p66_hex']),
                'p77': hex48(row['p77_hex']),
            })
    return data

def analyze_dataset(name, vhdl_path, csv_path):
    print(f"\n{'='*120}")
    print(f"BICYCLE UKF: VHDL vs Python Diagnosis — {name}")
    print(f"{'='*120}")

    vhdl = load_vhdl(vhdl_path)
    measurements, ground_truth = load_f1_csv(csv_path)
    n = min(len(vhdl), len(measurements))

    # Run Python reference
    Q_mat = np.diag(Q_DIAG)
    R_mat = np.diag(R_DIAG)
    P = P_INIT.copy()
    theta0, v0 = estimate_initial_heading(measurements, n_init=3)
    x = np.array([measurements[0][0], measurements[0][1], v0, theta0, 0.0, 0.0, measurements[0][2]])

    print(f"\nInitial state: v0={v0:.2f} m/s, theta0={np.degrees(theta0):.1f}°")
    print(f"Q_DIAG = {Q_DIAG}")
    print(f"R_DIAG = {R_DIAG}")

    # KEY ANALYSIS: What intermediate products look like in Q24.24
    print(f"\n--- Fixed-Point Range Analysis ---")
    print(f"Q24.24 max positive = {(2**47 - 1) / 2**24:.1f}")
    print(f"Q24.24 max negative = {-(2**47) / 2**24:.1f}")
    print(f"v0 * 2^24 = {v0 * 2**24:.0f} (fits in 48-bit: {abs(v0 * 2**24) < 2**47})")

    # Track where things go wrong
    print(f"\n{'Cyc':>4} | {'Py_px':>10} {'VH_px':>10} {'Δpx':>9} | {'Py_v':>8} {'VH_v':>8} {'Δv':>8} | {'Py_θ':>8} {'VH_θ':>8} {'Δθ':>7} | {'Py_δ':>8} {'VH_δ':>8} | {'VH_P11':>9} {'VH_P33':>9}")
    print("-" * 140)

    first_big_diff = None

    for cycle in range(n):
        z_meas = np.array(measurements[cycle])
        gt = ground_truth[cycle]

        if cycle > 0:
            eigvals = np.linalg.eigvalsh(P)
            if np.min(eigvals) < 1e-10:
                P += np.eye(N) * 1e-8
            x_pred, P_pred, chi_pred = ukf_predict(x, P, Q_mat)
            x_upd, P_upd = ukf_update(x_pred, P_pred, chi_pred, z_meas, R_mat)
            x = x_upd
            P = P_upd

        vh = vhdl[cycle]
        if vh['px'] is None: continue

        d_pos = np.sqrt((vh['px']-x[PX])**2 + (vh['py']-x[PY])**2)
        d_v = abs(vh['v'] - x[V]) if vh['v'] is not None else 0
        d_th = abs(vh['th'] - x[TH]) if vh['th'] is not None else 0

        # Track first big divergence
        if first_big_diff is None and d_pos > 5.0:
            first_big_diff = cycle

        # Print for key cycles or when divergence starts
        show = (cycle < 20 or cycle % 50 == 0 or cycle == n-1 or
                (first_big_diff and abs(cycle - first_big_diff) <= 5))
        if show:
            print(f"{cycle:4d} | {x[PX]:10.2f} {vh['px']:10.2f} {vh['px']-x[PX]:9.3f} | "
                  f"{x[V]:8.2f} {vh['v']:8.2f} {vh['v']-x[V]:8.3f} | "
                  f"{np.degrees(x[TH]):8.2f} {np.degrees(vh['th']):8.2f} {np.degrees(vh['th']-x[TH]):7.2f} | "
                  f"{x[DL]:8.5f} {vh['dl']:8.5f} | "
                  f"{vh['p11']:9.3f} {vh['p33']:9.3f}")

        # Check for potential overflow issues in bicycle prediction
        if cycle < 5:
            v_q24 = int(x[V] * Q_SCALE)
            cos_th = np.cos(x[TH])
            cos_q24 = int(cos_th * Q_SCALE)
            product_96 = v_q24 * cos_q24  # This is v*cos(th) in Q48.48
            dt_q24 = int(DT * Q_SCALE)
            full_product = product_96 * dt_q24  # v*cos(th)*dt in Q72.72
            print(f"  [Overflow check] v_q24={v_q24}, cos_q24={cos_q24}, "
                  f"v*cos={product_96} ({product_96.bit_length()}bits), "
                  f"v*cos*dt={full_product} ({full_product.bit_length()}bits)")

    if first_big_diff:
        print(f"\n*** FIRST BIG DIVERGENCE (>5m) at cycle {first_big_diff} ***")
    else:
        print(f"\n*** No major divergence (>5m) found ***")

    # Summary
    py_errors = []
    vh_errors = []
    diffs = []
    for cycle in range(n):
        gt = ground_truth[cycle]
        vh = vhdl[cycle]

        # Rerun python to get x at each cycle (simple approach: use stored estimates)
        if vh['px'] is not None:
            vh_err = np.sqrt((vh['px']-gt[0])**2 + (vh['py']-gt[1])**2 + (vh['z']-gt[2])**2)
            vh_errors.append(vh_err)

    vh_rmse = np.sqrt(np.mean(np.array(vh_errors)**2))
    print(f"\nVHDL RMSE: {vh_rmse:.4f} m")
    print(f"Valid cycles: {len(vh_errors)}/{n}")


if __name__ == '__main__':
    base = os.path.dirname(os.path.abspath(__file__))
    src = os.path.join(base, '..', 'src')
    ca = os.path.join(base, '..', '..', 'ca_ukf')

    datasets = [
        ('Monaco 750cy',
         os.path.join(src, 'vhdl_output_f1_monaco_2024_750cycles.txt'),
         os.path.join(ca, 'test_data/real_world/f1_monaco_2024_750cycles.csv')),
        ('Silverstone 750cy',
         os.path.join(src, 'vhdl_output_f1_silverstone_2024_750cycles.txt'),
         os.path.join(ca, 'test_data/real_world/f1_silverstone_2024_750cycles.csv')),
    ]

    if len(sys.argv) > 1 and sys.argv[1] == 'drone':
        datasets = [('Drone 500cy',
            os.path.join(src, 'vhdl_output_synthetic_drone_500cycles.txt'),
            os.path.join(ca, 'test_data/real_world/synthetic_drone_500cycles.csv'))]

    for name, vhdl_path, csv_path in datasets:
        if os.path.exists(vhdl_path) and os.path.exists(csv_path):
            analyze_dataset(name, vhdl_path, csv_path)
