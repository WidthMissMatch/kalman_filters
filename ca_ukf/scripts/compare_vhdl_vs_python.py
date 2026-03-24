#!/usr/bin/env python3
"""
Direct VHDL vs Python Prediction Accuracy Comparison

Compares VHDL fixed-point implementation against Python floating-point
reference on identical test data.

Extracts VHDL predictions from simulation logs and compares with Python.
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import subprocess
import re
from pathlib import Path
import argparse


def run_vhdl_simulation_and_extract_predictions(testbench, cycles, sim_dir='../sim_work'):
    """
    Run VHDL simulation and extract prediction results

    Args:
        testbench: Testbench entity name
        cycles: Number of cycles to run
        sim_dir: Simulation work directory

    Returns:
        vhdl_results: Dict with cycles, predictions, updates
    """
    print(f"Running VHDL simulation: {testbench} ({cycles} cycles)...")

    sim_dir = Path(sim_dir)
    sim_dir.mkdir(parents=True, exist_ok=True)

    # Run simulation and capture output
    cmd = [
        'ghdl', '-r', '--std=08', testbench,
        '--stop-time=10ms',
        '--assert-level=warning'
    ]

    try:
        result = subprocess.run(
            cmd,
            cwd=sim_dir,
            capture_output=True,
            text=True,
            timeout=120
        )

        output = result.stdout + result.stderr

        # Parse simulation output
        vhdl_results = parse_vhdl_simulation_output(output, cycles)

        print(f"  VHDL simulation complete: {len(vhdl_results['cycles'])} cycles captured")
        return vhdl_results

    except subprocess.TimeoutExpired:
        print("  ERROR: VHDL simulation timeout!")
        return None
    except Exception as e:
        print(f"  ERROR: {e}")
        return None


def parse_vhdl_simulation_output(output, expected_cycles):
    """
    Parse VHDL simulation output to extract predictions

    Looks for patterns like:
    Cycle X
      x_pos_current = Y (Q24.24)
    """
    cycles = []
    x_pos = []
    y_pos = []
    z_pos = []

    lines = output.split('\n')

    current_cycle = None
    for line in lines:
        # Match cycle number
        match_cycle = re.search(r'Cycle\s+(\d+)', line, re.IGNORECASE)
        if match_cycle:
            current_cycle = int(match_cycle.group(1))

        # Match position outputs (looking for Q24.24 values)
        if current_cycle is not None:
            # x_pos_current
            match_x = re.search(r'x_pos_current.*?=\s*(-?\d+)', line)
            if match_x:
                x_val = int(match_x.group(1))
                x_pos.append(from_q24_24(x_val))

            # y_pos_current
            match_y = re.search(r'y_pos_current.*?=\s*(-?\d+)', line)
            if match_y:
                y_val = int(match_y.group(1))
                y_pos.append(from_q24_24(y_val))

            # z_pos_current
            match_z = re.search(r'z_pos_current.*?=\s*(-?\d+)', line)
            if match_z:
                z_val = int(match_z.group(1))
                z_pos.append(from_q24_24(z_val))

                # When all 3 positions captured, save cycle
                if len(x_pos) == len(y_pos) == len(z_pos) == current_cycle + 1:
                    if current_cycle not in cycles:
                        cycles.append(current_cycle)

    # Convert to arrays
    results = {
        'cycles': np.array(cycles),
        'x_pos': np.array(x_pos),
        'y_pos': np.array(y_pos),
        'z_pos': np.array(z_pos)
    }

    return results


def from_q24_24(value):
    """Convert Q24.24 fixed-point to float"""
    return float(value) / (2**24)


def compare_vhdl_python_predictions(vhdl_results, python_results, ground_truth):
    """
    Compare VHDL and Python prediction accuracy

    Args:
        vhdl_results: Dict with VHDL predictions
        python_results: Dict with Python predictions
        ground_truth: Array with true positions

    Returns:
        comparison: Dict with metrics
    """
    # Align data by cycle
    min_cycles = min(len(vhdl_results['cycles']), len(python_results['cycles']))

    vhdl_pos = np.column_stack([
        vhdl_results['x_pos'][:min_cycles],
        vhdl_results['y_pos'][:min_cycles],
        vhdl_results['z_pos'][:min_cycles]
    ])

    python_pos = np.column_stack([
        python_results['x_pos'][:min_cycles],
        python_results['y_pos'][:min_cycles],
        python_results['z_pos'][:min_cycles]
    ])

    gt_pos = ground_truth[:min_cycles, [0, 3, 6]]  # Extract x_pos, y_pos, z_pos

    # Compute errors
    vhdl_error = np.abs(vhdl_pos - gt_pos)
    python_error = np.abs(python_pos - gt_pos)
    vhdl_vs_python_error = np.abs(vhdl_pos - python_pos)

    # Compute metrics
    comparison = {
        'cycles': min_cycles,
        'vhdl_rmse': np.sqrt(np.mean(vhdl_error**2, axis=0)),
        'python_rmse': np.sqrt(np.mean(python_error**2, axis=0)),
        'vhdl_mean_error': np.mean(vhdl_error, axis=0),
        'python_mean_error': np.mean(python_error, axis=0),
        'vhdl_max_error': np.max(vhdl_error, axis=0),
        'python_max_error': np.max(python_error, axis=0),
        'vhdl_vs_python_rmse': np.sqrt(np.mean(vhdl_vs_python_error**2, axis=0)),
        'vhdl_vs_python_max': np.max(vhdl_vs_python_error, axis=0),
        'vhdl_error_per_cycle': vhdl_error,
        'python_error_per_cycle': python_error,
        'vhdl_vs_python_per_cycle': vhdl_vs_python_error
    }

    return comparison


def generate_comparison_report(comparison, output_file='vhdl_vs_python_comparison.txt'):
    """
    Generate detailed comparison report

    Args:
        comparison: Dict from compare_vhdl_python_predictions
        output_file: Output text file
    """
    axes = ['X', 'Y', 'Z']

    with open(output_file, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("VHDL vs PYTHON PREDICTION ACCURACY COMPARISON\n")
        f.write("=" * 80 + "\n\n")

        f.write(f"Cycles Compared: {comparison['cycles']}\n\n")

        f.write("POSITION PREDICTION ACCURACY (vs Ground Truth)\n")
        f.write("-" * 80 + "\n")
        f.write(f"{'Axis':<6} {'VHDL RMSE':<12} {'Python RMSE':<12} {'VHDL Max':<12} {'Python Max':<12}\n")
        f.write("-" * 80 + "\n")

        for i, axis in enumerate(axes):
            f.write(f"{axis:<6} {comparison['vhdl_rmse'][i]:<12.6f} "
                    f"{comparison['python_rmse'][i]:<12.6f} "
                    f"{comparison['vhdl_max_error'][i]:<12.6f} "
                    f"{comparison['python_max_error'][i]:<12.6f}\n")

        avg_vhdl = np.mean(comparison['vhdl_rmse'])
        avg_python = np.mean(comparison['python_rmse'])

        f.write("\n")
        f.write(f"Average VHDL RMSE:   {avg_vhdl:.6f} m\n")
        f.write(f"Average Python RMSE: {avg_python:.6f} m\n")

        if avg_vhdl < avg_python:
            diff_pct = ((avg_python - avg_vhdl) / avg_python) * 100
            f.write(f"\nVHDL is {diff_pct:.2f}% MORE ACCURATE than Python\n")
        elif avg_vhdl > avg_python:
            diff_pct = ((avg_vhdl - avg_python) / avg_vhdl) * 100
            f.write(f"\nPython is {diff_pct:.2f}% MORE ACCURATE than VHDL\n")
        else:
            f.write("\nVHDL and Python have IDENTICAL accuracy\n")

        f.write("\n\nVHDL vs PYTHON AGREEMENT (Direct Comparison)\n")
        f.write("-" * 80 + "\n")
        f.write(f"{'Axis':<6} {'Agreement RMSE':<15} {'Max Difference':<15}\n")
        f.write("-" * 80 + "\n")

        for i, axis in enumerate(axes):
            f.write(f"{axis:<6} {comparison['vhdl_vs_python_rmse'][i]:<15.6f} "
                    f"{comparison['vhdl_vs_python_max'][i]:<15.6f}\n")

        avg_agreement = np.mean(comparison['vhdl_vs_python_rmse'])
        f.write(f"\nAverage VHDL-Python RMSE: {avg_agreement:.6f} m\n")

        if avg_agreement < 0.001:
            f.write("✅ EXCELLENT: VHDL matches Python within 1mm\n")
        elif avg_agreement < 0.01:
            f.write("✅ VERY GOOD: VHDL matches Python within 1cm\n")
        elif avg_agreement < 0.1:
            f.write("✓ GOOD: VHDL matches Python within 10cm\n")
        else:
            f.write("⚠ SIGNIFICANT DIFFERENCE: Review fixed-point implementation\n")

        f.write("\n" + "=" * 80 + "\n")

    print(f"Comparison report saved: {output_file}")


def plot_vhdl_vs_python_comparison(comparison, output_file='vhdl_vs_python_plots.png'):
    """
    Generate comparison plots

    Args:
        comparison: Dict from compare_vhdl_python_predictions
        output_file: Output image file
    """
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('VHDL vs Python Prediction Accuracy Comparison',
                 fontsize=16, fontweight='bold')

    cycles = np.arange(comparison['cycles'])
    axis_names = ['X-axis', 'Y-axis', 'Z-axis']

    # Top row: VHDL vs Python error (vs ground truth)
    for i in range(3):
        ax = axes[0, i]
        ax.plot(cycles, comparison['vhdl_error_per_cycle'][:, i],
                'r-', linewidth=1.5, label='VHDL Error', alpha=0.7)
        ax.plot(cycles, comparison['python_error_per_cycle'][:, i],
                'b-', linewidth=1.5, label='Python Error', alpha=0.7)

        ax.set_title(f'{axis_names[i]} Position Error (vs Truth)', fontweight='bold')
        ax.set_xlabel('Cycle')
        ax.set_ylabel('Error (m)')
        ax.grid(True, alpha=0.3)
        ax.legend()

    # Bottom row: VHDL vs Python agreement
    for i in range(3):
        ax = axes[1, i]
        ax.plot(cycles, comparison['vhdl_vs_python_per_cycle'][:, i],
                'g-', linewidth=1.5, label='VHDL-Python Difference')

        ax.axhline(y=0.01, color='orange', linestyle='--',
                   alpha=0.5, label='1cm threshold')
        ax.axhline(y=0.001, color='green', linestyle='--',
                   alpha=0.5, label='1mm threshold')

        ax.set_title(f'{axis_names[i]} VHDL-Python Agreement', fontweight='bold')
        ax.set_xlabel('Cycle')
        ax.set_ylabel('Absolute Difference (m)')
        ax.grid(True, alpha=0.3)
        ax.legend()

    plt.tight_layout()
    plt.savefig(output_file, dpi=150, bbox_inches='tight')
    print(f"Comparison plots saved: {output_file}")
    plt.close()


def main():
    parser = argparse.ArgumentParser(
        description='Compare VHDL vs Python UKF prediction accuracy'
    )
    parser.add_argument('--testbench', type=str,
                        default='ukf_supreme_3d_comprehensive_tb',
                        help='VHDL testbench entity name')
    parser.add_argument('--reference-csv', type=str, required=True,
                        help='Python reference CSV with ground truth and Python estimates')
    parser.add_argument('--cycles', type=int, default=50,
                        help='Number of cycles to compare')
    parser.add_argument('--output-dir', type=str, default='../results/vhdl_vs_python',
                        help='Output directory')

    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    print("=" * 80)
    print("VHDL vs PYTHON PREDICTION COMPARISON")
    print("=" * 80)
    print()

    # Load Python reference data
    print("Loading Python reference data...")
    df = pd.read_csv(args.reference_csv)

    ground_truth_cols = [f'gt_{axis}_{state}' for axis in ['x', 'y', 'z']
                         for state in ['pos', 'vel', 'acc']]
    python_est_cols = [f'est_{axis}_{state}' for axis in ['x', 'y', 'z']
                       for state in ['pos', 'vel', 'acc']]

    ground_truth = df[ground_truth_cols].values[:args.cycles]
    python_estimates = df[python_est_cols].values[:args.cycles]

    python_results = {
        'cycles': np.arange(args.cycles),
        'x_pos': python_estimates[:, 0],
        'y_pos': python_estimates[:, 3],
        'z_pos': python_estimates[:, 6]
    }

    print(f"  Loaded {len(ground_truth)} cycles")
    print()

    # Run VHDL simulation
    vhdl_results = run_vhdl_simulation_and_extract_predictions(
        args.testbench, args.cycles
    )

    if vhdl_results is None or len(vhdl_results['cycles']) == 0:
        print("\nERROR: Could not extract VHDL results from simulation")
        print("Make sure VHDL testbench outputs predictions in readable format")
        return

    print()

    # Compare
    print("Comparing VHDL vs Python...")
    comparison = compare_vhdl_python_predictions(
        vhdl_results, python_results, ground_truth
    )
    print()

    # Generate report
    generate_comparison_report(
        comparison,
        output_file=output_dir / 'vhdl_vs_python_report.txt'
    )

    # Generate plots
    plot_vhdl_vs_python_comparison(
        comparison,
        output_file=output_dir / 'vhdl_vs_python_plots.png'
    )

    print()
    print("=" * 80)
    print("SUMMARY")
    print("=" * 80)

    avg_vhdl = np.mean(comparison['vhdl_rmse'])
    avg_python = np.mean(comparison['python_rmse'])
    avg_agreement = np.mean(comparison['vhdl_vs_python_rmse'])

    print(f"Average VHDL Prediction RMSE:   {avg_vhdl:.6f} m")
    print(f"Average Python Prediction RMSE: {avg_python:.6f} m")
    print(f"Average VHDL-Python Agreement:  {avg_agreement:.6f} m")
    print()

    if avg_agreement < 0.01:
        print("✅ VHDL implementation matches Python reference (< 1cm difference)")
    elif avg_agreement < 0.1:
        print("✓ VHDL implementation close to Python reference (< 10cm difference)")
    else:
        print("⚠ SIGNIFICANT DIFFERENCE - Review fixed-point implementation")

    print("=" * 80)


if __name__ == '__main__':
    main()
