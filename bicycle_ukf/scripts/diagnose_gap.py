#!/usr/bin/env python3
"""Diagnose VHDL vs Python precision gap for Bicycle UKF."""

import csv, numpy as np, os
from bicycle_ukf_reference import *

Q_SCALE = 2**24

def hex48(s):
    s = s.strip()
    if 'X' in s or 'U' in s: return None
    v = int(s, 16)
    if v >= (1<<47): v -= (1<<48)
    return v / Q_SCALE

# Load VHDL output
vhdl = []
vhdl_path = os.path.join(os.path.dirname(__file__), '..', 'src', 'vhdl_output_synthetic_drone_500cycles.txt')
with open(vhdl_path) as f:
    for row in csv.DictReader(f):
        vhdl.append({
            'px': hex48(row['px_hex']), 'py': hex48(row['py_hex']), 'z': hex48(row['z_hex']),
            'v': hex48(row['v_hex']), 'th': hex48(row['theta_hex']),
            'dl': hex48(row['delta_hex']), 'a': hex48(row['a_hex']),
            'p11': hex48(row['p11_hex']), 'p22': hex48(row['p22_hex']),
            'p33': hex48(row['p33_hex']),
        })

# Load CSV data
ca_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'ca_ukf')
csv_path = os.path.join(ca_dir, 'test_data/real_world/synthetic_drone_500cycles.csv')
measurements, ground_truth = load_f1_csv(csv_path)

# Run Python reference step-by-step
Q_mat = np.diag(Q_DIAG)
R_mat = np.diag(R_DIAG)
P = P_INIT.copy()
theta0, v0 = estimate_initial_heading(measurements, n_init=3)
x = np.array([measurements[0][0], measurements[0][1], v0, theta0, 0.0, 0.0, measurements[0][2]])

print("=" * 100)
print("BICYCLE UKF: VHDL vs Python Precision Diagnosis")
print("=" * 100)

print(f"\n{'Cyc':>3} | {'Py_px':>9} {'VH_px':>9} {'Δpx':>8} | {'Py_py':>9} {'VH_py':>9} {'Δpy':>8} | {'Py_v':>7} {'VH_v':>7} {'Δv':>7} | {'Py_P11':>8} {'VH_P11':>8} {'ΔP11':>8}")
print("-" * 100)

pos_diffs = []
py_gt_errors = []
vh_gt_errors = []

for cycle in range(len(measurements)):
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

    # Python vs ground truth error
    py_err = np.sqrt((x[PX]-gt[0])**2 + (x[PY]-gt[1])**2 + (x[PZ]-gt[2])**2)
    py_gt_errors.append(py_err)

    # VHDL vs ground truth error
    if vh['px'] is not None:
        vh_err = np.sqrt((vh['px']-gt[0])**2 + (vh['py']-gt[1])**2 + (vh['z']-gt[2])**2)
        vh_gt_errors.append(vh_err)
    else:
        vh_gt_errors.append(None)

    # VHDL vs Python diff
    if vh['px'] is not None:
        d = np.sqrt((vh['px']-x[PX])**2 + (vh['py']-x[PY])**2 + (vh['z']-x[PZ])**2)
        pos_diffs.append(d)
    else:
        pos_diffs.append(None)

    # Print detail for key cycles
    if cycle < 15 or cycle % 50 == 0 or cycle == len(measurements)-1:
        if vh['px'] is not None:
            dpx = vh['px'] - x[PX]
            dpy = vh['py'] - x[PY]
            dv = (vh['v'] - x[V]) if vh['v'] is not None else 0
            dp11 = (vh['p11'] - P[0,0]) if vh['p11'] is not None else 0
            print(f"{cycle:3d} | {x[PX]:9.3f} {vh['px']:9.3f} {dpx:8.4f} | "
                  f"{x[PY]:9.3f} {vh['py']:9.3f} {dpy:8.4f} | "
                  f"{x[V]:7.2f} {vh['v']:7.2f} {dv:7.3f} | "
                  f"{P[0,0]:8.4f} {vh['p11']:8.4f} {dp11:8.4f}")

# Summary
print("\n" + "=" * 100)
print("PRECISION GAP SUMMARY")
print("=" * 100)

valid_diffs = [d for d in pos_diffs if d is not None]
print(f"\nVHDL-vs-Python position difference:")
print(f"  Mean: {np.mean(valid_diffs):.4f} m")
print(f"  Max:  {max(valid_diffs):.4f} m at cycle {pos_diffs.index(max(valid_diffs))}")
print(f"  Median: {np.median(valid_diffs):.4f} m")

for cp in [10, 50, 100, 200, 500]:
    subset = [d for d in pos_diffs[:cp] if d is not None]
    if subset:
        print(f"  @{cp:3d}: mean={np.mean(subset):.4f}m, max={max(subset):.4f}m")

py_rmse = np.sqrt(np.mean(np.array(py_gt_errors)**2))
valid_vh = [e for e in vh_gt_errors if e is not None]
vh_rmse = np.sqrt(np.mean(np.array(valid_vh)**2))

print(f"\nGround-truth RMSE:")
print(f"  Python: {py_rmse:.4f} m")
print(f"  VHDL:   {vh_rmse:.4f} m")
print(f"  Gap:    {vh_rmse/py_rmse - 1:.1%}")
print(f"  VHDL/Python ratio: {vh_rmse/py_rmse:.3f}x")

# Check where error grows fastest
print(f"\nError growth rate (VHDL-Python diff):")
for i in range(1, min(11, len(valid_diffs))):
    growth = valid_diffs[i] / max(valid_diffs[i-1], 1e-10)
    print(f"  Cycle {i}: diff={valid_diffs[i]:.6f}m (x{growth:.2f} from prev)")
