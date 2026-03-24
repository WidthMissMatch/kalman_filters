#!/usr/bin/env python3
"""
One-Step-Ahead Prediction Test for CTR UKF VHDL Module.

At each cycle k, uses the VHDL filter's state estimate (pos, vel, omega)
to predict position at cycle k+1 using the CTR motion model, then compares
the prediction against ground truth at k+1.

CTR Motion Model (from predicti_ctr3d.vhd):
  cross = omega x vel
  omega_sq = |omega|^2
  vel' = vel + cross*dt - 0.5*omega_sq*vel*dt^2
  pos' = pos + vel*dt
  omega' = omega  (constant turn rate assumption)

Also computes naive prediction (no filter, just using previous ground truth
or measurement) for comparison.
"""
import re
import csv
import math
import sys

Q = 24
SCALE = 1 << Q  # 16777216
DT = 0.02  # 50 Hz

def q24_to_real(val):
    return val / SCALE

def parse_vhdl_output(filepath):
    """Parse the extracted VHDL simulation output."""
    cycles = []
    current = {}
    with open(filepath) as f:
        for line in f:
            m = re.search(r'CYCLE (\d+)', line)
            if m:
                if current:
                    cycles.append(current)
                current = {'cycle': int(m.group(1))}
                continue

            m = re.search(r'EST_X=(-?\d+)\s+EST_Y=(-?\d+)\s+EST_Z=(-?\d+)', line)
            if m:
                current['est_x'] = int(m.group(1))
                current['est_y'] = int(m.group(2))
                current['est_z'] = int(m.group(3))
                continue

            m = re.search(r'VEL_X=(-?\d+)\s+VEL_Y=(-?\d+)\s+VEL_Z=(-?\d+)', line)
            if m:
                current['vel_x'] = int(m.group(1))
                current['vel_y'] = int(m.group(2))
                current['vel_z'] = int(m.group(3))
                continue

            m = re.search(r'OMEGA_X=(-?\d+)\s+OMEGA_Y=(-?\d+)\s+OMEGA_Z=(-?\d+)', line)
            if m:
                current['omega_x'] = int(m.group(1))
                current['omega_y'] = int(m.group(2))
                current['omega_z'] = int(m.group(3))
                continue

    if current:
        cycles.append(current)
    return cycles

def load_ground_truth(filepath):
    rows = []
    with open(filepath) as f:
        reader = csv.DictReader(f)
        for r in reader:
            rows.append({k: float(v) for k, v in r.items()})
    return rows

def ctr_predict(px, py, pz, vx, vy, vz, wx, wy, wz, dt):
    """Apply CTR motion model to predict one step ahead."""
    # Cross product: omega x vel
    cx = wy * vz - wz * vy
    cy = wz * vx - wx * vz
    cz = wx * vy - wy * vx

    # omega squared
    omega_sq = wx**2 + wy**2 + wz**2

    # Velocity update: vel' = vel + cross*dt - 0.5*omega_sq*vel*dt^2
    vx_new = vx + cx * dt - 0.5 * omega_sq * vx * dt**2
    vy_new = vy + cy * dt - 0.5 * omega_sq * vy * dt**2
    vz_new = vz + cz * dt - 0.5 * omega_sq * vz * dt**2

    # Position update: pos' = pos + vel*dt
    px_new = px + vx * dt
    py_new = py + vy * dt
    pz_new = pz + vz * dt

    return px_new, py_new, pz_new, vx_new, vy_new, vz_new

def main():
    vhdl_file = sys.argv[1] if len(sys.argv) > 1 else \
        "/home/arunupscee/Desktop/xtortion/ctr_ukf/ctr_ukf/ctr_ukf.sim/sim_1/behav/xsim/vhdl_output_real_fpv_500cycles.txt"
    gt_file = "/home/arunupscee/Desktop/xtortion/ctr_ukf/real_fpv_test/ground_truth_fpv.csv"

    print("=" * 80)
    print("ONE-STEP-AHEAD PREDICTION TEST — CTR UKF VHDL MODULE")
    print("=" * 80)

    cycles = parse_vhdl_output(vhdl_file)
    gt = load_ground_truth(gt_file)

    n = min(len(cycles), len(gt))
    print(f"\nParsed {len(cycles)} VHDL cycles, {len(gt)} ground truth rows")
    print(f"Using {n-1} prediction steps (cycle 0..{n-2} predicting cycle 1..{n-1})")

    # ====================================================================
    # Method 1: UKF one-step-ahead prediction
    # Use filter state at cycle k to predict position at cycle k+1
    # ====================================================================
    ukf_pred_errors = []
    ukf_pred_errors_x = []
    ukf_pred_errors_y = []
    ukf_pred_errors_z = []

    # ====================================================================
    # Method 2: Naive prediction (use measurement at k as prediction for k+1)
    # This is the "no filter" baseline
    # ====================================================================
    naive_pred_errors = []

    # ====================================================================
    # Method 3: Zero-velocity prediction (position at k = prediction for k+1)
    # Uses filter estimate position only, no velocity
    # ====================================================================
    zv_pred_errors = []

    # ====================================================================
    # Method 4: CV (constant velocity) prediction using filter state
    # pos_pred = pos + vel*dt (ignoring omega/turn rate)
    # ====================================================================
    cv_pred_errors = []

    predictions = []

    for k in range(n - 1):
        c = cycles[k]
        g_next = gt[k + 1]

        # Ground truth at k+1
        gt_x_next = g_next['gt_x']
        gt_y_next = g_next['gt_y']
        gt_z_next = g_next['gt_z']

        # --- UKF CTR prediction ---
        px = q24_to_real(c['est_x'])
        py = q24_to_real(c['est_y'])
        pz = q24_to_real(c['est_z'])
        vx = q24_to_real(c['vel_x'])
        vy = q24_to_real(c['vel_y'])
        vz = q24_to_real(c['vel_z'])
        wx = q24_to_real(c['omega_x'])
        wy = q24_to_real(c['omega_y'])
        wz = q24_to_real(c['omega_z'])

        pred_x, pred_y, pred_z, _, _, _ = ctr_predict(px, py, pz, vx, vy, vz, wx, wy, wz, DT)

        err_x = pred_x - gt_x_next
        err_y = pred_y - gt_y_next
        err_z = pred_z - gt_z_next
        err_3d = math.sqrt(err_x**2 + err_y**2 + err_z**2)

        ukf_pred_errors.append(err_3d)
        ukf_pred_errors_x.append(err_x**2)
        ukf_pred_errors_y.append(err_y**2)
        ukf_pred_errors_z.append(err_z**2)

        # --- Naive: measurement at k as prediction for k+1 ---
        g_curr = gt[k]
        mx = g_curr['meas_x'] if 'meas_x' in g_curr else g_curr['gt_x']
        my = g_curr['meas_y'] if 'meas_y' in g_curr else g_curr['gt_y']
        mz = g_curr['meas_z'] if 'meas_z' in g_curr else g_curr['gt_z']
        naive_err = math.sqrt((mx - gt_x_next)**2 + (my - gt_y_next)**2 + (mz - gt_z_next)**2)
        naive_pred_errors.append(naive_err)

        # --- Zero-velocity: filter position at k as prediction for k+1 ---
        zv_err = math.sqrt((px - gt_x_next)**2 + (py - gt_y_next)**2 + (pz - gt_z_next)**2)
        zv_pred_errors.append(zv_err)

        # --- CV: filter pos + vel*dt as prediction for k+1 ---
        cv_x = px + vx * DT
        cv_y = py + vy * DT
        cv_z = pz + vz * DT
        cv_err = math.sqrt((cv_x - gt_x_next)**2 + (cv_y - gt_y_next)**2 + (cv_z - gt_z_next)**2)
        cv_pred_errors.append(cv_err)

        predictions.append({
            'k': k, 'pred_x': pred_x, 'pred_y': pred_y, 'pred_z': pred_z,
            'gt_x': gt_x_next, 'gt_y': gt_y_next, 'gt_z': gt_z_next,
            'ukf_err': err_3d, 'naive_err': naive_err, 'cv_err': cv_err,
        })

    # ====================================================================
    # RESULTS
    # ====================================================================
    N = len(ukf_pred_errors)

    ukf_rmse = math.sqrt(sum(e**2 for e in ukf_pred_errors) / N)
    ukf_rmse_x = math.sqrt(sum(ukf_pred_errors_x) / N)
    ukf_rmse_y = math.sqrt(sum(ukf_pred_errors_y) / N)
    ukf_rmse_z = math.sqrt(sum(ukf_pred_errors_z) / N)
    naive_rmse = math.sqrt(sum(e**2 for e in naive_pred_errors) / N)
    zv_rmse = math.sqrt(sum(e**2 for e in zv_pred_errors) / N)
    cv_rmse = math.sqrt(sum(e**2 for e in cv_pred_errors) / N)

    ukf_mean = sum(ukf_pred_errors) / N
    ukf_max = max(ukf_pred_errors)
    ukf_min = min(ukf_pred_errors)
    ukf_median = sorted(ukf_pred_errors)[N // 2]

    naive_mean = sum(naive_pred_errors) / N
    naive_max = max(naive_pred_errors)

    print("\n" + "=" * 80)
    print("ONE-STEP-AHEAD PREDICTION RMSE COMPARISON")
    print("=" * 80)

    print(f"\n{'Method':<45} {'RMSE (m)':>10} {'Mean (m)':>10} {'Max (m)':>10}")
    print("-" * 80)
    print(f"{'UKF CTR (filter + motion model):':<45} {ukf_rmse:>10.4f} {ukf_mean:>10.4f} {ukf_max:>10.4f}")
    print(f"{'CV (filter pos + vel*dt, no omega):':<45} {cv_rmse:>10.4f} {sum(cv_pred_errors)/N:>10.4f} {max(cv_pred_errors):>10.4f}")
    print(f"{'Zero-velocity (filter pos only):':<45} {zv_rmse:>10.4f} {sum(zv_pred_errors)/N:>10.4f} {max(zv_pred_errors):>10.4f}")
    print(f"{'Naive (raw measurement at k):':<45} {naive_rmse:>10.4f} {naive_mean:>10.4f} {naive_max:>10.4f}")

    print(f"\n--- UKF CTR Per-Axis Prediction RMSE ---")
    print(f"  X-axis: {ukf_rmse_x:.4f} m")
    print(f"  Y-axis: {ukf_rmse_y:.4f} m")
    print(f"  Z-axis: {ukf_rmse_z:.4f} m")

    print(f"\n--- UKF CTR Prediction Error Statistics ---")
    print(f"  Min error:    {ukf_min:.4f} m")
    print(f"  Mean error:   {ukf_mean:.4f} m")
    print(f"  Median error: {ukf_median:.4f} m")
    print(f"  Max error:    {ukf_max:.4f} m")
    print(f"  Std dev:      {math.sqrt(sum((e - ukf_mean)**2 for e in ukf_pred_errors) / N):.4f} m")

    # Improvement over baselines
    print(f"\n--- Improvement Over Baselines ---")
    print(f"  vs Naive (measurement):   {(1 - ukf_rmse/naive_rmse)*100:>6.1f}% reduction")
    print(f"  vs Zero-velocity:         {(1 - ukf_rmse/zv_rmse)*100:>6.1f}% reduction")
    if cv_rmse > 0:
        print(f"  vs CV (no omega):         {(1 - ukf_rmse/cv_rmse)*100:>6.1f}% reduction")

    # ====================================================================
    # Time evolution: show prediction quality over time
    # ====================================================================
    print(f"\n--- Prediction Error Over Time (50-cycle windows) ---")
    print(f"  {'Window':<20} {'UKF RMSE':>10} {'Naive RMSE':>12} {'CV RMSE':>10}")
    print(f"  {'-'*20} {'-'*10} {'-'*12} {'-'*10}")

    window = 50
    for start in range(0, N, window):
        end = min(start + window, N)
        if end - start < 10:
            continue
        w_ukf = math.sqrt(sum(e**2 for e in ukf_pred_errors[start:end]) / (end - start))
        w_naive = math.sqrt(sum(e**2 for e in naive_pred_errors[start:end]) / (end - start))
        w_cv = math.sqrt(sum(e**2 for e in cv_pred_errors[start:end]) / (end - start))
        print(f"  Cycle {start:>3}-{end-1:>3}         {w_ukf:>10.4f} {w_naive:>12.4f} {w_cv:>10.4f}")

    # ====================================================================
    # Sample predictions
    # ====================================================================
    print(f"\n--- Sample One-Step-Ahead Predictions ---")
    print(f"  {'k':>4} | {'Pred_X':>9} {'Pred_Y':>9} {'Pred_Z':>9} | {'GT_X':>9} {'GT_Y':>9} {'GT_Z':>9} | {'Err(m)':>8}")
    print(f"  {'-'*4}-+-{'-'*29}-+-{'-'*29}-+-{'-'*8}")

    show = list(range(5)) + [49, 99, 199, 299, 399] + list(range(N-5, N))
    show = sorted(set(i for i in show if i < N))

    for i in show:
        p = predictions[i]
        print(f"  {p['k']:>4} | {p['pred_x']:>9.4f} {p['pred_y']:>9.4f} {p['pred_z']:>9.4f} | "
              f"{p['gt_x']:>9.4f} {p['gt_y']:>9.4f} {p['gt_z']:>9.4f} | {p['ukf_err']:>8.4f}")

    # ====================================================================
    # VERDICT
    # ====================================================================
    print("\n" + "=" * 80)
    print("VERDICT")
    print("=" * 80)

    checks = []

    # Check 1: UKF prediction better than naive
    c1 = ukf_rmse < naive_rmse
    checks.append(("UKF prediction RMSE < Naive measurement RMSE", c1))

    # Check 2: UKF prediction better than zero-velocity
    c2 = ukf_rmse < zv_rmse
    checks.append(("UKF prediction RMSE < Zero-velocity RMSE", c2))

    # Check 3: Max prediction error reasonable (< 5m for 20ms ahead)
    c3 = ukf_max < 5.0
    checks.append(("Max prediction error < 5.0m", c3))

    # Check 4: No divergence (last 50 cycles not worse than 3x first 50)
    first_50_rmse = math.sqrt(sum(e**2 for e in ukf_pred_errors[:50]) / 50)
    last_50_rmse = math.sqrt(sum(e**2 for e in ukf_pred_errors[-50:]) / 50)
    c4 = last_50_rmse < first_50_rmse * 3
    checks.append(("No divergence (last 50 < 3x first 50)", c4))

    # Check 5: Prediction RMSE < 1.0m (for 20ms horizon on real drone data)
    c5 = ukf_rmse < 1.0
    checks.append(("Prediction RMSE < 1.0m", c5))

    for name, passed in checks:
        print(f"  {'PASS' if passed else 'FAIL'}: {name}")

    passes = sum(1 for _, v in checks if v)
    print(f"\n  Result: {passes}/{len(checks)} checks passed")
    print(f"  One-step-ahead prediction RMSE: {ukf_rmse:.4f} m")

    if passes == len(checks):
        print("  === ONE-STEP-AHEAD PREDICTION CONFIRMED WORKING ===")

if __name__ == "__main__":
    main()
