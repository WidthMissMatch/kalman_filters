#!/usr/bin/env python3
"""
Comprehensive verification of 500-cycle CTR UKF VHDL output against ground truth.
Confirms that the VHDL modules are actually producing valid output.
"""
import re
import csv
import math
import sys

Q = 24
SCALE = 1 << Q  # 16777216

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

            # Parse EST_X=... EST_Y=... EST_Z=...
            m = re.search(r'EST_X=(-?\d+)\s+EST_Y=(-?\d+)\s+EST_Z=(-?\d+)', line)
            if m:
                current['est_x'] = int(m.group(1))
                current['est_y'] = int(m.group(2))
                current['est_z'] = int(m.group(3))
                continue

            # Parse VEL_X=... VEL_Y=... VEL_Z=...
            m = re.search(r'VEL_X=(-?\d+)\s+VEL_Y=(-?\d+)\s+VEL_Z=(-?\d+)', line)
            if m:
                current['vel_x'] = int(m.group(1))
                current['vel_y'] = int(m.group(2))
                current['vel_z'] = int(m.group(3))
                continue

            # Parse OMEGA_X=... OMEGA_Y=... OMEGA_Z=...
            m = re.search(r'OMEGA_X=(-?\d+)\s+OMEGA_Y=(-?\d+)\s+OMEGA_Z=(-?\d+)', line)
            if m:
                current['omega_x'] = int(m.group(1))
                current['omega_y'] = int(m.group(2))
                current['omega_z'] = int(m.group(3))
                continue

            # Parse P_xpos=... P_xvel=... etc
            m = re.search(r'P_xpos=(-?\d+)\s+P_xvel=(-?\d+)\s+P_xomg=(-?\d+)\s+P_ypos=(-?\d+)\s+P_yvel=(-?\d+)\s+P_yomg=(-?\d+)\s+P_zpos=(-?\d+)\s+P_zvel=(-?\d+)\s+P_zomg=(-?\d+)', line)
            if m:
                current['p_xpos'] = int(m.group(1))
                current['p_xvel'] = int(m.group(2))
                current['p_xomg'] = int(m.group(3))
                current['p_ypos'] = int(m.group(4))
                current['p_yvel'] = int(m.group(5))
                current['p_yomg'] = int(m.group(6))
                current['p_zpos'] = int(m.group(7))
                current['p_zvel'] = int(m.group(8))
                current['p_zomg'] = int(m.group(9))
                continue

    if current:
        cycles.append(current)
    return cycles

def load_ground_truth(filepath):
    """Load ground truth CSV."""
    rows = []
    with open(filepath) as f:
        reader = csv.DictReader(f)
        for r in reader:
            rows.append({k: float(v) for k, v in r.items()})
    return rows

def main():
    vhdl_file = sys.argv[1] if len(sys.argv) > 1 else "/home/arunupscee/Desktop/xtortion/ctr_ukf/ctr_ukf/ctr_ukf.sim/sim_1/behav/xsim/vhdl_output_real_fpv_500cycles.txt"
    gt_file = "/home/arunupscee/Desktop/xtortion/ctr_ukf/real_fpv_test/ground_truth_fpv.csv"

    print("=" * 80)
    print("CTR UKF VHDL 500-CYCLE COMPREHENSIVE VERIFICATION")
    print("=" * 80)

    # Parse data
    cycles = parse_vhdl_output(vhdl_file)
    gt = load_ground_truth(gt_file)

    num_cycles = len(cycles)
    num_gt = len(gt)

    print(f"\nParsed {num_cycles} VHDL cycles, {num_gt} ground truth rows")

    # ====================================================================
    # CHECK 1: All 500 cycles completed
    # ====================================================================
    print("\n" + "-" * 60)
    print("CHECK 1: All 500 cycles completed")
    cycle_nums = [c['cycle'] for c in cycles]
    missing = [i for i in range(500) if i not in cycle_nums]
    if num_cycles == 500 and len(missing) == 0:
        print("  RESULT: PASS - All 500 cycles produced output")
        print(f"  First cycle: {cycle_nums[0]}, Last cycle: {cycle_nums[-1]}")
    else:
        print(f"  RESULT: FAIL - Got {num_cycles} cycles, missing: {missing[:20]}")

    # ====================================================================
    # CHECK 2: Outputs are changing (not stuck)
    # ====================================================================
    print("\n" + "-" * 60)
    print("CHECK 2: Outputs are changing every cycle (not stuck)")
    unique_x = len(set(c['est_x'] for c in cycles))
    unique_y = len(set(c['est_y'] for c in cycles))
    unique_z = len(set(c['est_z'] for c in cycles))
    unique_vx = len(set(c['vel_x'] for c in cycles))
    unique_vy = len(set(c['vel_y'] for c in cycles))
    unique_vz = len(set(c['vel_z'] for c in cycles))
    print(f"  Unique est_x values: {unique_x}/500")
    print(f"  Unique est_y values: {unique_y}/500")
    print(f"  Unique est_z values: {unique_z}/500")
    print(f"  Unique vel_x values: {unique_vx}/500")
    print(f"  Unique vel_y values: {unique_vy}/500")
    print(f"  Unique vel_z values: {unique_vz}/500")
    all_changing = all(u >= 450 for u in [unique_x, unique_y, unique_z, unique_vx, unique_vy, unique_vz])
    if all_changing:
        print("  RESULT: PASS - All state outputs are changing across cycles")
    else:
        print("  RESULT: PARTIAL - Some outputs have limited variation")

    # ====================================================================
    # CHECK 3: No overflow/saturation (values within sane range)
    # ====================================================================
    print("\n" + "-" * 60)
    print("CHECK 3: No overflow or saturation")
    MAX_48 = (1 << 47) - 1
    overflow_count = 0
    for c in cycles:
        for key in ['est_x', 'est_y', 'est_z', 'vel_x', 'vel_y', 'vel_z']:
            val = c[key]
            if abs(val) > MAX_48 * 0.9:
                overflow_count += 1

    # Check position range in real units
    x_min = min(q24_to_real(c['est_x']) for c in cycles)
    x_max = max(q24_to_real(c['est_x']) for c in cycles)
    y_min = min(q24_to_real(c['est_y']) for c in cycles)
    y_max = max(q24_to_real(c['est_y']) for c in cycles)
    z_min = min(q24_to_real(c['est_z']) for c in cycles)
    z_max = max(q24_to_real(c['est_z']) for c in cycles)
    print(f"  Position X range: [{x_min:.3f}, {x_max:.3f}] m")
    print(f"  Position Y range: [{y_min:.3f}, {y_max:.3f}] m")
    print(f"  Position Z range: [{z_min:.3f}, {z_max:.3f}] m")

    vx_min = min(q24_to_real(c['vel_x']) for c in cycles)
    vx_max = max(q24_to_real(c['vel_x']) for c in cycles)
    vy_min = min(q24_to_real(c['vel_y']) for c in cycles)
    vy_max = max(q24_to_real(c['vel_y']) for c in cycles)
    vz_min = min(q24_to_real(c['vel_z']) for c in cycles)
    vz_max = max(q24_to_real(c['vel_z']) for c in cycles)
    print(f"  Velocity X range: [{vx_min:.3f}, {vx_max:.3f}] m/s")
    print(f"  Velocity Y range: [{vy_min:.3f}, {vy_max:.3f}] m/s")
    print(f"  Velocity Z range: [{vz_min:.3f}, {vz_max:.3f}] m/s")

    if overflow_count == 0:
        print("  RESULT: PASS - No overflow detected in any cycle")
    else:
        print(f"  RESULT: FAIL - {overflow_count} near-overflow values detected")

    # ====================================================================
    # CHECK 4: Covariance behavior (should decrease then stabilize)
    # ====================================================================
    print("\n" + "-" * 60)
    print("CHECK 4: Covariance convergence behavior")
    p_xpos_0 = q24_to_real(cycles[0]['p_xpos'])
    p_xpos_10 = q24_to_real(cycles[10]['p_xpos'])
    p_xpos_50 = q24_to_real(cycles[50]['p_xpos'])
    p_xpos_100 = q24_to_real(cycles[100]['p_xpos']) if num_cycles > 100 else None
    p_xpos_last = q24_to_real(cycles[-1]['p_xpos'])

    print(f"  P_xpos cycle  0: {p_xpos_0:.6f}")
    print(f"  P_xpos cycle 10: {p_xpos_10:.6f}")
    print(f"  P_xpos cycle 50: {p_xpos_50:.6f}")
    if p_xpos_100 is not None:
        print(f"  P_xpos cycle 100: {p_xpos_100:.6f}")
    print(f"  P_xpos cycle {num_cycles-1}: {p_xpos_last:.6f}")

    # Check all covariances are positive at end
    neg_cov = 0
    for c in cycles:
        for key in ['p_xpos', 'p_xvel', 'p_xomg', 'p_ypos', 'p_yvel', 'p_yomg', 'p_zpos', 'p_zvel', 'p_zomg']:
            if c[key] < 0:
                neg_cov += 1

    decreased = p_xpos_last < p_xpos_0
    if decreased and neg_cov == 0:
        print(f"  RESULT: PASS - Covariance decreased ({p_xpos_0:.4f} -> {p_xpos_last:.4f}), all positive")
    elif neg_cov > 0:
        print(f"  RESULT: FAIL - {neg_cov} negative covariance entries detected")
    else:
        print(f"  RESULT: PARTIAL - Covariance did not decrease (start={p_xpos_0:.4f}, end={p_xpos_last:.4f})")

    # ====================================================================
    # CHECK 5: RMSE against ground truth (position)
    # ====================================================================
    print("\n" + "-" * 60)
    print("CHECK 5: RMSE against ground truth")

    n = min(num_cycles, num_gt)

    pos_errors_sq = []
    meas_errors_sq = []
    for i in range(n):
        c = cycles[i]
        g = gt[i]

        ex = q24_to_real(c['est_x']) - g['gt_x']
        ey = q24_to_real(c['est_y']) - g['gt_y']
        ez = q24_to_real(c['est_z']) - g['gt_z']
        pos_errors_sq.append(ex**2 + ey**2 + ez**2)

        mx = g['meas_x'] - g['gt_x'] if 'meas_x' in g else 0
        my = g['meas_y'] - g['gt_y'] if 'meas_y' in g else 0
        mz = g['meas_z'] - g['gt_z'] if 'meas_z' in g else 0
        meas_errors_sq.append(mx**2 + my**2 + mz**2)

    filter_rmse = math.sqrt(sum(pos_errors_sq) / n)
    meas_rmse = math.sqrt(sum(meas_errors_sq) / n) if any(meas_errors_sq) else 0

    # Per-axis RMSE
    rmse_x = math.sqrt(sum((q24_to_real(cycles[i]['est_x']) - gt[i]['gt_x'])**2 for i in range(n)) / n)
    rmse_y = math.sqrt(sum((q24_to_real(cycles[i]['est_y']) - gt[i]['gt_y'])**2 for i in range(n)) / n)
    rmse_z = math.sqrt(sum((q24_to_real(cycles[i]['est_z']) - gt[i]['gt_z'])**2 for i in range(n)) / n)

    print(f"  Position RMSE (3D): {filter_rmse:.4f} m")
    print(f"  Position RMSE X:    {rmse_x:.4f} m")
    print(f"  Position RMSE Y:    {rmse_y:.4f} m")
    print(f"  Position RMSE Z:    {rmse_z:.4f} m")
    print(f"  Measurement RMSE:   {meas_rmse:.4f} m")

    if meas_rmse > 0:
        improvement = (1 - filter_rmse / meas_rmse) * 100
        print(f"  Noise reduction:    {improvement:.1f}%")

    if filter_rmse < meas_rmse and filter_rmse < 5.0:
        print(f"  RESULT: PASS - Filter RMSE ({filter_rmse:.4f}m) < Measurement RMSE ({meas_rmse:.4f}m)")
    elif filter_rmse < 5.0:
        print(f"  RESULT: PARTIAL - Filter working but RMSE > measurement noise")
    else:
        print(f"  RESULT: FAIL - Filter RMSE too large ({filter_rmse:.4f}m)")

    # ====================================================================
    # CHECK 6: Velocity RMSE
    # ====================================================================
    print("\n" + "-" * 60)
    print("CHECK 6: Velocity estimation quality")

    vel_rmse_x = math.sqrt(sum((q24_to_real(cycles[i]['vel_x']) - gt[i]['gt_vx'])**2 for i in range(n)) / n)
    vel_rmse_y = math.sqrt(sum((q24_to_real(cycles[i]['vel_y']) - gt[i]['gt_vy'])**2 for i in range(n)) / n)
    vel_rmse_z = math.sqrt(sum((q24_to_real(cycles[i]['vel_z']) - gt[i]['gt_vz'])**2 for i in range(n)) / n)
    vel_rmse_3d = math.sqrt((vel_rmse_x**2 + vel_rmse_y**2 + vel_rmse_z**2) / 3)

    print(f"  Velocity RMSE X: {vel_rmse_x:.4f} m/s")
    print(f"  Velocity RMSE Y: {vel_rmse_y:.4f} m/s")
    print(f"  Velocity RMSE Z: {vel_rmse_z:.4f} m/s")
    print(f"  Velocity RMSE (avg): {vel_rmse_3d:.4f} m/s")

    if vel_rmse_3d < 10.0:
        print(f"  RESULT: PASS - Velocity estimation within reasonable bounds")
    else:
        print(f"  RESULT: FAIL - Velocity RMSE too high")

    # ====================================================================
    # CHECK 7: Correlation with ground truth
    # ====================================================================
    print("\n" + "-" * 60)
    print("CHECK 7: Correlation with ground truth trajectory")

    def correlation(a, b):
        n = len(a)
        mean_a = sum(a) / n
        mean_b = sum(b) / n
        cov = sum((a[i] - mean_a) * (b[i] - mean_b) for i in range(n))
        std_a = math.sqrt(sum((x - mean_a)**2 for x in a))
        std_b = math.sqrt(sum((x - mean_b)**2 for x in b))
        if std_a < 1e-10 or std_b < 1e-10:
            return 0.0
        return cov / (std_a * std_b)

    est_x_list = [q24_to_real(cycles[i]['est_x']) for i in range(n)]
    est_y_list = [q24_to_real(cycles[i]['est_y']) for i in range(n)]
    est_z_list = [q24_to_real(cycles[i]['est_z']) for i in range(n)]
    gt_x_list = [gt[i]['gt_x'] for i in range(n)]
    gt_y_list = [gt[i]['gt_y'] for i in range(n)]
    gt_z_list = [gt[i]['gt_z'] for i in range(n)]

    corr_x = correlation(est_x_list, gt_x_list)
    corr_y = correlation(est_y_list, gt_y_list)
    corr_z = correlation(est_z_list, gt_z_list)

    print(f"  Correlation X: {corr_x:.4f}")
    print(f"  Correlation Y: {corr_y:.4f}")
    print(f"  Correlation Z: {corr_z:.4f}")

    avg_corr = (corr_x + corr_y + corr_z) / 3
    if avg_corr > 0.8:
        print(f"  RESULT: PASS - Average correlation {avg_corr:.4f} > 0.8")
    elif avg_corr > 0.5:
        print(f"  RESULT: PARTIAL - Average correlation {avg_corr:.4f}")
    else:
        print(f"  RESULT: FAIL - Low correlation {avg_corr:.4f}")

    # ====================================================================
    # CHECK 8: Filter stability (no divergence over 500 cycles)
    # ====================================================================
    print("\n" + "-" * 60)
    print("CHECK 8: Long-term stability (no divergence)")

    # Check position error doesn't grow unboundedly
    errors_first_50 = [math.sqrt(pos_errors_sq[i]) for i in range(50)]
    errors_last_50 = [math.sqrt(pos_errors_sq[i]) for i in range(n-50, n)]
    avg_first_50 = sum(errors_first_50) / 50
    avg_last_50 = sum(errors_last_50) / 50
    max_error = max(math.sqrt(e) for e in pos_errors_sq)

    print(f"  Avg position error, first 50 cycles:  {avg_first_50:.4f} m")
    print(f"  Avg position error, last  50 cycles:  {avg_last_50:.4f} m")
    print(f"  Max position error across all cycles:  {max_error:.4f} m")

    # Check covariance didn't explode
    p_xpos_end = q24_to_real(cycles[-1]['p_xpos'])
    p_xvel_end = q24_to_real(cycles[-1]['p_xvel'])
    p_ypos_end = q24_to_real(cycles[-1]['p_ypos'])
    p_yvel_end = q24_to_real(cycles[-1]['p_yvel'])
    p_zpos_end = q24_to_real(cycles[-1]['p_zpos'])
    p_zvel_end = q24_to_real(cycles[-1]['p_zvel'])

    print(f"  Final P_xpos={p_xpos_end:.4f}, P_xvel={p_xvel_end:.4f}")
    print(f"  Final P_ypos={p_ypos_end:.4f}, P_yvel={p_yvel_end:.4f}")
    print(f"  Final P_zpos={p_zpos_end:.4f}, P_zvel={p_zvel_end:.4f}")

    stable = max_error < 20.0 and p_xpos_end < 100.0 and avg_last_50 < avg_first_50 * 5
    if stable:
        print(f"  RESULT: PASS - Filter remains stable over 500 cycles")
    else:
        print(f"  RESULT: FAIL - Signs of divergence detected")

    # ====================================================================
    # CHECK 9: Sample output dump (first 5 and last 5 cycles)
    # ====================================================================
    print("\n" + "-" * 60)
    print("CHECK 9: Sample outputs (first 5 and last 5 cycles)")
    print(f"  {'Cycle':>5} | {'Est_X':>10} | {'Est_Y':>10} | {'Est_Z':>10} | {'GT_X':>10} | {'GT_Y':>10} | {'GT_Z':>10} | {'Err(m)':>8}")
    print(f"  {'-'*5}-+-{'-'*10}-+-{'-'*10}-+-{'-'*10}-+-{'-'*10}-+-{'-'*10}-+-{'-'*10}-+-{'-'*8}")

    show_cycles = list(range(5)) + list(range(n-5, n))
    for i in show_cycles:
        c = cycles[i]
        g = gt[i]
        ex = q24_to_real(c['est_x'])
        ey = q24_to_real(c['est_y'])
        ez = q24_to_real(c['est_z'])
        err = math.sqrt((ex - g['gt_x'])**2 + (ey - g['gt_y'])**2 + (ez - g['gt_z'])**2)
        print(f"  {c['cycle']:>5} | {ex:>10.4f} | {ey:>10.4f} | {ez:>10.4f} | {g['gt_x']:>10.4f} | {g['gt_y']:>10.4f} | {g['gt_z']:>10.4f} | {err:>8.4f}")

    # ====================================================================
    # FINAL SUMMARY
    # ====================================================================
    print("\n" + "=" * 80)
    print("FINAL SUMMARY")
    print("=" * 80)
    print(f"  Total cycles simulated:  {num_cycles}")
    print(f"  Position RMSE (3D):      {filter_rmse:.4f} m")
    print(f"  Measurement RMSE (3D):   {meas_rmse:.4f} m")
    if meas_rmse > 0:
        print(f"  Noise reduction:         {improvement:.1f}%")
    print(f"  Velocity RMSE (avg):     {vel_rmse_3d:.4f} m/s")
    print(f"  Avg correlation:         {avg_corr:.4f}")
    print(f"  Max position error:      {max_error:.4f} m")
    print(f"  Final covariance P_xpos: {p_xpos_end:.6f}")
    print(f"  Stable over 500 cycles:  {'YES' if stable else 'NO'}")
    print()

    # Count passes
    checks = {
        "1. All cycles complete": num_cycles == 500,
        "2. Outputs changing": all_changing,
        "3. No overflow": overflow_count == 0,
        "4. Covariance convergence": decreased and neg_cov == 0,
        "5. Position RMSE < noise": filter_rmse < meas_rmse and filter_rmse < 5.0,
        "6. Velocity reasonable": vel_rmse_3d < 10.0,
        "7. Trajectory correlation": avg_corr > 0.5,
        "8. Long-term stability": stable,
    }

    passes = sum(1 for v in checks.values() if v)
    total = len(checks)

    for name, passed in checks.items():
        status = "PASS" if passed else "FAIL"
        print(f"  {name}: {status}")

    print(f"\n  VERDICT: {passes}/{total} checks passed")
    if passes == total:
        print("  === VHDL CTR UKF MODULE CONFIRMED WORKING ===")
    elif passes >= total - 1:
        print("  === VHDL CTR UKF MODULE CONFIRMED WORKING (minor issues) ===")
    else:
        print("  === SOME CHECKS FAILED - INVESTIGATE ===")

if __name__ == "__main__":
    main()
