#!/usr/bin/env python3
"""
Compare VHDL CTR UKF output against Python golden model.

Parses both the VHDL testbench output and golden model output,
computes per-state errors, RMSE, and PASS/FAIL verdict.

Usage:
  python compare_vhdl_vs_golden.py [vhdl_output] [golden_output]
  python compare_vhdl_vs_golden.py  # uses defaults
"""
import re
import sys
import math

Q_SCALE = 2**24  # Q24.24 fixed-point scale

def q24_to_real(val):
    return val / Q_SCALE

def to_hex48(val):
    """Convert signed integer to 12-char hex (48-bit unsigned representation)."""
    if val < 0:
        val += (1 << 48)
    return f"{val & 0xFFFFFFFFFFFF:012X}"

def parse_output_file(filepath):
    """Parse output file with format:
       CYCLE N
         EST_X=<int>  EST_Y=<int>  EST_Z=<int>
         VEL_X=<int>  VEL_Y=<int>  VEL_Z=<int>
         OMEGA_X=<int>  OMEGA_Y=<int>  OMEGA_Z=<int>
         P_xpos=<int>  P_xvel=<int> ...
    """
    cycles = {}
    current_cycle = None

    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()

            # Match CYCLE N
            m = re.match(r'CYCLE\s+(\d+)', line)
            if m:
                current_cycle = int(m.group(1))
                cycles[current_cycle] = {}
                continue

            if current_cycle is None:
                continue

            # Match key=value pairs
            for key, val in re.findall(r'(\w+)=(-?\d+)', line):
                cycles[current_cycle][key] = int(val)

    return cycles

STATE_NAMES = [
    ('EST_X', 'x_pos'), ('VEL_X', 'x_vel'), ('OMEGA_X', 'x_omega'),
    ('EST_Y', 'y_pos'), ('VEL_Y', 'y_vel'), ('OMEGA_Y', 'y_omega'),
    ('EST_Z', 'z_pos'), ('VEL_Z', 'z_vel'), ('OMEGA_Z', 'z_omega'),
]

COV_NAMES = [
    'P_xpos', 'P_xvel', 'P_xomg',
    'P_ypos', 'P_yvel', 'P_yomg',
    'P_zpos', 'P_zvel', 'P_zomg',
]

def main():
    # Default paths
    vhdl_path = "ctr_ukf/ctr_ukf.sim/sim_1/behav/xsim/vhdl_output_ctr_25cycles.txt"
    golden_path = "golden_model_float.txt"

    if len(sys.argv) > 1:
        vhdl_path = sys.argv[1]
    if len(sys.argv) > 2:
        golden_path = sys.argv[2]

    print("=" * 90)
    print("CTR UKF: VHDL vs Golden Model Comparison")
    print("=" * 90)
    print(f"  VHDL output:   {vhdl_path}")
    print(f"  Golden output: {golden_path}")
    print()

    try:
        vhdl = parse_output_file(vhdl_path)
    except FileNotFoundError:
        print(f"ERROR: VHDL output file not found: {vhdl_path}")
        return 1

    try:
        golden = parse_output_file(golden_path)
    except FileNotFoundError:
        print(f"ERROR: Golden model output file not found: {golden_path}")
        print("  Run the golden model first: python ctr_ukf_golden_model.py --mode float")
        return 1

    num_cycles = min(len(vhdl), len(golden))
    if num_cycles == 0:
        print("ERROR: No cycles found in one or both files.")
        return 1

    print(f"  Cycles in VHDL:   {len(vhdl)}")
    print(f"  Cycles in Golden: {len(golden)}")
    print(f"  Comparing:        {num_cycles} cycles")
    print()

    # ─── Per-cycle state comparison ──────────────────────────────────────
    print("--- State Estimate Comparison (first 10 cycles) ---")
    print(f"{'Cyc':>3} | {'State':>8} | {'VHDL (Q24)':>14} | {'Golden (Q24)':>14} | {'Diff (Q24)':>12} | {'Diff (real)':>12}")
    print("-" * 80)

    # Accumulate errors for RMSE
    state_errors = {name: [] for _, name in STATE_NAMES}
    max_errors = {name: 0.0 for _, name in STATE_NAMES}

    for c in range(num_cycles):
        if c not in vhdl or c not in golden:
            continue

        show = c < 10 or c == num_cycles - 1

        for vkey, sname in STATE_NAMES:
            v_val = vhdl[c].get(vkey, 0)
            g_val = golden[c].get(vkey, 0)
            diff = v_val - g_val
            diff_real = q24_to_real(diff)

            state_errors[sname].append(diff_real ** 2)
            max_errors[sname] = max(max_errors[sname], abs(diff_real))

            if show:
                print(f"{c:3d} | {sname:>8} | {v_val:14d} | {g_val:14d} | {diff:12d} | {diff_real:+12.6f}")

        if show and c < 10:
            print()

    # ─── Covariance comparison ───────────────────────────────────────────
    print("\n--- Covariance Diagonal Comparison (first 5 + last cycle) ---")
    print(f"{'Cyc':>3} | {'Cov':>8} | {'VHDL':>14} | {'Golden':>14} | {'Diff':>12} | {'Diff%':>8}")
    print("-" * 70)

    for c in range(num_cycles):
        if c not in vhdl or c not in golden:
            continue
        if c >= 5 and c != num_cycles - 1:
            continue

        for cname in COV_NAMES:
            v_val = vhdl[c].get(cname, 0)
            g_val = golden[c].get(cname, 0)
            diff = v_val - g_val
            pct = (diff / g_val * 100) if g_val != 0 else 0.0
            print(f"{c:3d} | {cname:>8} | {v_val:14d} | {g_val:14d} | {diff:12d} | {pct:+7.2f}%")
        print()

    # ─── RMSE summary ───────────────────────────────────────────────────
    print("=" * 70)
    print("RMSE SUMMARY (across all cycles)")
    print("=" * 70)
    print(f"{'State':>10} | {'RMSE (real)':>14} | {'Max Error':>14} | {'Status':>8}")
    print("-" * 55)

    test_pass = True
    for _, sname in STATE_NAMES:
        errors = state_errors[sname]
        if len(errors) == 0:
            continue
        rmse = math.sqrt(sum(errors) / len(errors))
        max_err = max_errors[sname]

        # Thresholds
        if 'pos' in sname:
            threshold = 1.0  # 1.0m position error
        elif 'vel' in sname:
            threshold = 5.0  # 5.0 m/s velocity error
        else:  # omega
            threshold = 2.0  # 2.0 rad/s omega error

        status = "PASS" if max_err < threshold else "WARN"
        if max_err >= threshold * 5:
            status = "FAIL"
            test_pass = False

        print(f"{sname:>10} | {rmse:14.6f} | {max_err:14.6f} | {status:>8}")

    # ─── Bit-exact check for first cycle ─────────────────────────────────
    print("\n" + "=" * 70)
    print("CYCLE 0 BIT-EXACT CHECK")
    print("=" * 70)
    if 0 in vhdl and 0 in golden:
        exact_match = True
        for vkey, sname in STATE_NAMES:
            v_val = vhdl[0].get(vkey, 0)
            g_val = golden[0].get(vkey, 0)
            match = "EXACT" if v_val == g_val else f"DIFF={v_val - g_val}"
            if v_val != g_val:
                exact_match = False
            print(f"  {sname:>10}: VHDL={v_val:14d}  Golden={g_val:14d}  {match}")
        print(f"\n  Cycle 0 bit-exact: {'YES' if exact_match else 'NO'}")

    # ─── Final verdict ───────────────────────────────────────────────────
    print("\n" + "=" * 70)
    if test_pass:
        print("COMPARISON RESULT: PASS")
        print("  All state errors within acceptable thresholds.")
        print("  Note: Fixed-point mode should match VHDL more closely than float mode.")
    else:
        print("COMPARISON RESULT: FAIL")
        print("  Some state errors exceed acceptable thresholds.")
    print("=" * 70)

    return 0 if test_pass else 1

if __name__ == '__main__':
    sys.exit(main())
