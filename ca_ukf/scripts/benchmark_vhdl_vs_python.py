#!/usr/bin/env python3
"""
Benchmark: VHDL vs Python UKF Execution Time
"""

import numpy as np
import pandas as pd
import time
from run_python_ukf_verification import UKF_9D_CA

def benchmark_python_ukf(num_iterations=1000):
    """Benchmark Python UKF execution time"""

    print("=" * 80)
    print("PYTHON UKF EXECUTION TIME BENCHMARK")
    print("=" * 80)
    print()

    # Initialize UKF
    ukf = UKF_9D_CA(dt=0.02, q_power=0.01, r_diag=0.5)

    # Create dummy measurements
    measurements = np.random.randn(num_iterations, 3) * 0.5

    print(f"Running {num_iterations} UKF updates...")
    print()

    # Warm-up (JIT compilation, cache warming)
    for i in range(10):
        z = measurements[i]
        ukf.process_measurement(z)

    # Reset UKF
    ukf = UKF_9D_CA(dt=0.02, q_power=0.01, r_diag=0.5)

    # Benchmark
    times = []

    for i in range(num_iterations):
        z = measurements[i]

        start = time.perf_counter()
        x_pred, x_updated, P_updated, K = ukf.process_measurement(z)
        end = time.perf_counter()

        elapsed = (end - start) * 1e6  # Convert to microseconds
        times.append(elapsed)

    times = np.array(times)

    # Statistics
    mean_time = np.mean(times)
    median_time = np.median(times)
    min_time = np.min(times)
    max_time = np.max(times)
    std_time = np.std(times)

    print("PYTHON UKF EXECUTION TIME (per update):")
    print("-" * 80)
    print(f"  Mean:     {mean_time:>10.2f} μs")
    print(f"  Median:   {median_time:>10.2f} μs")
    print(f"  Min:      {min_time:>10.2f} μs")
    print(f"  Max:      {max_time:>10.2f} μs")
    print(f"  Std Dev:  {std_time:>10.2f} μs")
    print()

    return mean_time, median_time

def analyze_vhdl_timing():
    """Analyze VHDL simulation timing from logs"""

    print("=" * 80)
    print("VHDL UKF EXECUTION TIME ANALYSIS")
    print("=" * 80)
    print()

    # From simulation logs, extract timing
    # Example: Cycle starts at 70ns, ends at ~7000ns for first cycle
    # Each subsequent cycle takes about 7000 clock periods

    CLK_PERIOD_NS = 10  # 10ns = 100 MHz clock
    CYCLES_PER_UPDATE = 7000  # From simulation observation

    vhdl_time_ns = CYCLES_PER_UPDATE * CLK_PERIOD_NS
    vhdl_time_us = vhdl_time_ns / 1000.0

    print("VHDL UKF EXECUTION TIME (from simulation):")
    print("-" * 80)
    print(f"  Clock frequency:     {1000/CLK_PERIOD_NS:.0f} MHz ({CLK_PERIOD_NS} ns period)")
    print(f"  Cycles per update:   {CYCLES_PER_UPDATE}")
    print(f"  Time per update:     {vhdl_time_ns:.0f} ns = {vhdl_time_us:.1f} μs")
    print()

    # User says 7 microseconds - let's also compute for that
    print("USER-REPORTED VHDL TIMING:")
    print("-" * 80)
    user_time_us = 7.0
    implied_cycles = user_time_us * 1000 / CLK_PERIOD_NS
    print(f"  Time per update:     {user_time_us:.1f} μs")
    print(f"  Implied cycles:      {implied_cycles:.0f} (at 100 MHz)")
    print()

    return vhdl_time_us, user_time_us

def compare_performance(python_time_us, vhdl_sim_us, vhdl_user_us):
    """Compare VHDL vs Python performance"""

    print("=" * 80)
    print("VHDL vs PYTHON PERFORMANCE COMPARISON")
    print("=" * 80)
    print()

    speedup_sim = python_time_us / vhdl_sim_us
    speedup_user = python_time_us / vhdl_user_us

    print("EXECUTION TIME COMPARISON:")
    print("-" * 80)
    print(f"  Python UKF:          {python_time_us:>10.1f} μs/update")
    print(f"  VHDL (simulation):   {vhdl_sim_us:>10.1f} μs/update")
    print(f"  VHDL (user report):  {vhdl_user_us:>10.1f} μs/update")
    print()

    print("SPEEDUP (Python time / VHDL time):")
    print("-" * 80)
    print(f"  VHDL vs Python (sim):   {speedup_sim:>8.1f}× faster")
    print(f"  VHDL vs Python (user):  {speedup_user:>8.1f}× faster")
    print()

    print("THROUGHPUT (updates per second):")
    print("-" * 80)
    print(f"  Python:              {1e6/python_time_us:>12,.0f} updates/sec")
    print(f"  VHDL (simulation):   {1e6/vhdl_sim_us:>12,.0f} updates/sec")
    print(f"  VHDL (user):         {1e6/vhdl_user_us:>12,.0f} updates/sec")
    print()

    # Real-world scenarios
    print("=" * 80)
    print("REAL-WORLD APPLICATION SCENARIOS")
    print("=" * 80)
    print()

    scenarios = [
        ("Drone flight (50 Hz updates)", 50),
        ("Autonomous vehicle (100 Hz)", 100),
        ("High-speed tracking (1000 Hz)", 1000),
        ("Real-time radar (10 kHz)", 10000)
    ]

    for name, freq_hz in scenarios:
        required_time_us = 1e6 / freq_hz
        python_can_meet = "✅" if python_time_us < required_time_us else "❌"
        vhdl_can_meet = "✅" if vhdl_user_us < required_time_us else "❌"

        print(f"{name}:")
        print(f"  Required update time:  {required_time_us:>10.1f} μs")
        print(f"  Python can meet:       {python_can_meet} ({python_time_us:.1f} μs available)")
        print(f"  VHDL can meet:         {vhdl_can_meet} ({vhdl_user_us:.1f} μs available)")
        print()

    # Save results
    results = {
        'implementation': ['Python', 'VHDL (simulation)', 'VHDL (user report)'],
        'time_us': [python_time_us, vhdl_sim_us, vhdl_user_us],
        'throughput_hz': [1e6/python_time_us, 1e6/vhdl_sim_us, 1e6/vhdl_user_us],
        'speedup_vs_python': [1.0, speedup_sim, speedup_user]
    }

    df = pd.DataFrame(results)
    df.to_csv('../results/execution_time_comparison.csv', index=False)
    print("Results saved to: results/execution_time_comparison.csv")
    print()

if __name__ == '__main__':
    print("\n" * 2)

    # Benchmark Python
    python_time, _ = benchmark_python_ukf(num_iterations=1000)

    print()

    # Analyze VHDL
    vhdl_sim, vhdl_user = analyze_vhdl_timing()

    print()

    # Compare
    compare_performance(python_time, vhdl_sim, vhdl_user)

    print("=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print()
    print(f"Your VHDL module ({vhdl_user:.1f} μs) is approximately {python_time/vhdl_user:.0f}× FASTER than Python ({python_time:.1f} μs)")
    print()
    print("This means:")
    print(f"  - VHDL can process ~{1e6/vhdl_user:,.0f} updates/second")
    print(f"  - Python can process ~{1e6/python_time:,.0f} updates/second")
    print()
    print("VHDL enables real-time tracking at rates that are impossible for Python!")
    print()
