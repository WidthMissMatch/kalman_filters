#!/usr/bin/env python3
"""
Rigorous verification of VHDL vs Python UKF performance
Compares accuracy and speed on identical dataset
"""

import pandas as pd
import numpy as np
import time
import re

def parse_vhdl_log(log_file):
    """Extract VHDL estimates from simulation log"""
    results = []

    with open(log_file, 'r') as f:
        lines = f.readlines()

    cycle = 0
    for i, line in enumerate(lines):
        if 'VHDL est:' in line:
            # Parse: "VHDL est:    x=1.23 y=4.56 z=7.89"
            match = re.search(r'x=([-\d.e+]+)\s+y=([-\d.e+]+)\s+z=([-\d.e+]+)', line)
            if match:
                x = float(match.group(1))
                y = float(match.group(2))
                z = float(match.group(3))
                results.append({'cycle': cycle, 'x_vhdl': x, 'y_vhdl': y, 'z_vhdl': z})
                cycle += 1

    return pd.DataFrame(results)

def compute_rmse(errors):
    """Root mean square error"""
    return np.sqrt(np.mean(errors**2))

def compute_statistics(python_est, vhdl_est, true_pos):
    """Compute comprehensive error statistics"""
    # Errors vs true position
    python_error = np.abs(python_est - true_pos)
    vhdl_error = np.abs(vhdl_est - true_pos)

    # Direct comparison: VHDL vs Python
    vhdl_vs_python = np.abs(vhdl_est - python_est)

    stats = {
        'python_mean': python_error.mean(),
        'python_max': python_error.max(),
        'python_rmse': compute_rmse(python_est - true_pos),
        'vhdl_mean': vhdl_error.mean(),
        'vhdl_max': vhdl_error.max(),
        'vhdl_rmse': compute_rmse(vhdl_est - true_pos),
        'difference_mean': vhdl_vs_python.mean(),
        'difference_max': vhdl_vs_python.max(),
        'correlation': np.corrcoef(python_est, vhdl_est)[0,1] if len(python_est) > 1 else 0
    }

    return stats

def main():
    print("=" * 80)
    print("RIGOROUS VERIFICATION: VHDL vs Python UKF")
    print("=" * 80)
    print()

    # Load Python reference (MUST match what VHDL testbench uses!)
    print("[1/5] Loading Python reference results...")
    python_df = pd.read_csv('python_results_survey_100_no_dropout.csv')
    print(f"      Loaded {len(python_df)} cycles")

    # Parse VHDL simulation log
    print("[2/5] Parsing VHDL simulation log...")
    vhdl_df = parse_vhdl_log('/tmp/integration_test_current.log')
    print(f"      Parsed {len(vhdl_df)} cycles")

    # Align datasets (use first N cycles present in both)
    n_cycles = min(len(python_df), len(vhdl_df))
    print(f"[3/5] Comparing first {n_cycles} cycles...")

    python_df = python_df.head(n_cycles).reset_index(drop=True)
    vhdl_df = vhdl_df.head(n_cycles).reset_index(drop=True)

    # Extract data
    x_true = python_df['x_pos_true'].values
    y_true = python_df['y_pos_true'].values
    z_true = python_df['z_pos_true'].values

    x_python = python_df['x_pos_est'].values
    y_python = python_df['y_pos_est'].values
    z_python = python_df['z_pos_est'].values

    x_vhdl = vhdl_df['x_vhdl'].values
    y_vhdl = vhdl_df['y_vhdl'].values
    z_vhdl = vhdl_df['z_vhdl'].values

    # Compute statistics for each axis
    print()
    print("=" * 80)
    print("ACCURACY COMPARISON")
    print("=" * 80)

    x_stats = compute_statistics(x_python, x_vhdl, x_true)
    y_stats = compute_statistics(y_python, y_vhdl, y_true)
    z_stats = compute_statistics(z_python, z_vhdl, z_true)

    print()
    print("X-Axis Errors (meters):")
    print(f"  Python:  Mean={x_stats['python_mean']:.4f}, Max={x_stats['python_max']:.4f}, RMSE={x_stats['python_rmse']:.4f}")
    print(f"  VHDL:    Mean={x_stats['vhdl_mean']:.4f}, Max={x_stats['vhdl_max']:.4f}, RMSE={x_stats['vhdl_rmse']:.4f}")
    print(f"  Diff:    Mean={x_stats['difference_mean']:.4f}, Max={x_stats['difference_max']:.4f}")
    print(f"  Correlation: {x_stats['correlation']:.6f}")

    print()
    print("Y-Axis Errors (meters):")
    print(f"  Python:  Mean={y_stats['python_mean']:.4f}, Max={y_stats['python_max']:.4f}, RMSE={y_stats['python_rmse']:.4f}")
    print(f"  VHDL:    Mean={y_stats['vhdl_mean']:.4f}, Max={y_stats['vhdl_max']:.4f}, RMSE={y_stats['vhdl_rmse']:.4f}")
    print(f"  Diff:    Mean={y_stats['difference_mean']:.4f}, Max={y_stats['difference_max']:.4f}")
    print(f"  Correlation: {y_stats['correlation']:.6f}")

    print()
    print("Z-Axis Errors (meters):")
    print(f"  Python:  Mean={z_stats['python_mean']:.4f}, Max={z_stats['python_max']:.4f}, RMSE={z_stats['python_rmse']:.4f}")
    print(f"  VHDL:    Mean={z_stats['vhdl_mean']:.4f}, Max={z_stats['vhdl_max']:.4f}, RMSE={z_stats['vhdl_rmse']:.4f}")
    print(f"  Diff:    Mean={z_stats['difference_mean']:.4f}, Max={z_stats['difference_max']:.4f}")
    print(f"  Correlation: {z_stats['correlation']:.6f}")

    # Pass rate comparison with 0.5m tolerance
    print()
    print("=" * 80)
    print("PASS RATE COMPARISON (0.5m tolerance)")
    print("=" * 80)

    tolerance = 0.5

    python_x_pass = np.abs(x_python - x_true) < tolerance
    python_y_pass = np.abs(y_python - y_true) < tolerance
    python_z_pass = np.abs(z_python - z_true) < tolerance
    python_pass = python_x_pass & python_y_pass & python_z_pass

    vhdl_x_pass = np.abs(x_vhdl - x_true) < tolerance
    vhdl_y_pass = np.abs(y_vhdl - y_true) < tolerance
    vhdl_z_pass = np.abs(z_vhdl - z_true) < tolerance
    vhdl_pass = vhdl_x_pass & vhdl_y_pass & vhdl_z_pass

    python_pass_rate = 100 * np.sum(python_pass) / n_cycles
    vhdl_pass_rate = 100 * np.sum(vhdl_pass) / n_cycles

    print()
    print(f"Python: {np.sum(python_pass)}/{n_cycles} = {python_pass_rate:.1f}%")
    print(f"VHDL:   {np.sum(vhdl_pass)}/{n_cycles} = {vhdl_pass_rate:.1f}%")
    print(f"Ratio:  {vhdl_pass_rate/python_pass_rate:.3f}×")

    # Agreement analysis
    both_pass = np.sum(python_pass & vhdl_pass)
    both_fail = np.sum(~python_pass & ~vhdl_pass)
    python_only = np.sum(python_pass & ~vhdl_pass)
    vhdl_only = np.sum(~python_pass & vhdl_pass)

    print()
    print("Agreement Analysis:")
    print(f"  Both pass:        {both_pass} cycles ({100*both_pass/n_cycles:.1f}%)")
    print(f"  Both fail:        {both_fail} cycles ({100*both_fail/n_cycles:.1f}%)")
    print(f"  Python only:      {python_only} cycles ({100*python_only/n_cycles:.1f}%)")
    print(f"  VHDL only:        {vhdl_only} cycles ({100*vhdl_only/n_cycles:.1f}%)")
    print(f"  Agreement rate:   {100*(both_pass + both_fail)/n_cycles:.1f}%")

    # Speed comparison
    print()
    print("=" * 80)
    print("SPEED COMPARISON")
    print("=" * 80)
    print()
    print("[4/5] Timing Python UKF execution...")

    # Time Python UKF
    from generate_ukf_3d_reference import UKF3D

    ukf = UKF3D()

    # Warmup
    for _ in range(5):
        ukf.predict()
        ukf.update(np.array([0.0, 0.0, 0.0]))

    # Actual timing
    n_iterations = 100
    start = time.perf_counter()
    for _ in range(n_iterations):
        ukf.predict()
        ukf.update(np.array([0.0, 0.0, 0.0]))
    end = time.perf_counter()

    python_time_per_cycle = (end - start) / n_iterations * 1000  # Convert to ms

    print(f"Python: {python_time_per_cycle:.4f} ms per cycle")

    # VHDL timing from simulation log
    print("[5/5] Extracting VHDL timing from simulation...")

    # Parse simulation timing
    with open('/tmp/integration_test_current.log', 'r') as f:
        log_content = f.read()

    # Find cycle timing reports (look for timestamps)
    timestamps = re.findall(r'@(\d+)ns:', log_content)
    if len(timestamps) >= 2:
        # Calculate average time between cycles
        timestamps = [int(t) for t in timestamps[:100]]  # First 100 cycles
        cycle_times = np.diff(timestamps)
        vhdl_time_ns = np.mean(cycle_times)
        vhdl_time_us = vhdl_time_ns / 1000
        vhdl_time_ms = vhdl_time_us / 1000

        print(f"VHDL:   {vhdl_time_us:.4f} µs per cycle (simulation at 100 MHz)")
        print(f"        {vhdl_time_ns:.0f} ns per cycle")
        print()
        print(f"Speedup: {python_time_per_cycle / vhdl_time_ms:.1f}× faster (VHDL vs Python)")
    else:
        print("Could not extract VHDL timing from log")
        vhdl_time_ms = None

    # Final verdict
    print()
    print("=" * 80)
    print("VERIFICATION VERDICT")
    print("=" * 80)
    print()

    # Accuracy verdict
    rmse_ratio = (x_stats['vhdl_rmse'] + y_stats['vhdl_rmse'] + z_stats['vhdl_rmse']) / \
                 (x_stats['python_rmse'] + y_stats['python_rmse'] + z_stats['python_rmse'])

    print("ACCURACY:")
    if vhdl_pass_rate >= 0.95 * python_pass_rate:
        print(f"  ✓ VERIFIED: VHDL achieves {vhdl_pass_rate/python_pass_rate:.1%} of Python's pass rate")
        print(f"  ✓ Pass rates are equivalent ({vhdl_pass_rate:.1f}% vs {python_pass_rate:.1f}%)")
    else:
        print(f"  ✗ REJECTED: VHDL achieves only {vhdl_pass_rate/python_pass_rate:.1%} of Python's pass rate")
        print(f"  ✗ Pass rates differ significantly ({vhdl_pass_rate:.1f}% vs {python_pass_rate:.1f}%)")

    if rmse_ratio < 2.0:
        print(f"  ✓ RMSE ratio: {rmse_ratio:.2f}× (acceptable, <2×)")
    else:
        print(f"  ⚠ RMSE ratio: {rmse_ratio:.2f}× (high, >2×)")

    avg_correlation = (x_stats['correlation'] + y_stats['correlation'] + z_stats['correlation']) / 3
    if avg_correlation > 0.95:
        print(f"  ✓ Correlation: {avg_correlation:.4f} (excellent, >0.95)")
    elif avg_correlation > 0.90:
        print(f"  ✓ Correlation: {avg_correlation:.4f} (good, >0.90)")
    else:
        print(f"  ⚠ Correlation: {avg_correlation:.4f} (needs improvement)")

    print()
    print("SPEED:")
    if vhdl_time_ms is not None:
        speedup = python_time_per_cycle / vhdl_time_ms
        if speedup > 10:
            print(f"  ✓ VERIFIED: VHDL is {speedup:.1f}× faster than Python")
            print(f"  ✓ Python: {python_time_per_cycle:.4f} ms/cycle")
            print(f"  ✓ VHDL:   {vhdl_time_ms:.6f} ms/cycle ({vhdl_time_us:.2f} µs)")
        else:
            print(f"  ⚠ Speedup only {speedup:.1f}×")

    print()
    print("=" * 80)

    # Save detailed comparison
    comparison_df = pd.DataFrame({
        'cycle': range(n_cycles),
        'x_true': x_true,
        'y_true': y_true,
        'z_true': z_true,
        'x_python': x_python,
        'y_python': y_python,
        'z_python': z_python,
        'x_vhdl': x_vhdl,
        'y_vhdl': y_vhdl,
        'z_vhdl': z_vhdl,
        'x_error_python': np.abs(x_python - x_true),
        'y_error_python': np.abs(y_python - y_true),
        'z_error_python': np.abs(z_python - z_true),
        'x_error_vhdl': np.abs(x_vhdl - x_true),
        'y_error_vhdl': np.abs(y_vhdl - y_true),
        'z_error_vhdl': np.abs(z_vhdl - z_true),
        'python_pass': python_pass,
        'vhdl_pass': vhdl_pass
    })

    comparison_df.to_csv('vhdl_vs_python_comparison.csv', index=False)
    print()
    print("Detailed comparison saved to: vhdl_vs_python_comparison.csv")

if __name__ == '__main__':
    main()
