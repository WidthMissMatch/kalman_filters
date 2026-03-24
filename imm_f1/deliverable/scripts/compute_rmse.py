#!/usr/bin/env python3
"""
Compute RMSE for IMM Filter output vs ground truth.
Reads VHDL simulation output + CSV ground truth.
Supports both hex and decimal VHDL output formats.
"""
import csv
import re
import sys
import math

Q_SCALE = 2**24

def load_ground_truth(csv_path):
    gt = {}
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            cycle = int(row['cycle'])
            gt[cycle] = {
                'x': float(row['gt_x_pos']),
                'y': float(row['gt_y_pos']),
                'z': float(row['gt_z_pos']),
            }
    return gt

def hex48_to_signed(hex_str):
    val = int(hex_str, 16)
    if val >= (1 << 47):
        val -= (1 << 48)
    return val

def load_vhdl_output(txt_path):
    results = {}
    # IMM hex format: Cycle N: imm_x=0x... imm_y=0x... imm_z=0x... [p_ca=... p_singer=... p_bike=...]
    hex_pattern = re.compile(
        r'Cycle\s+(\d+):\s+'
        r'imm_x=0x([0-9A-Fa-f]+)\s+'
        r'imm_y=0x([0-9A-Fa-f]+)\s+'
        r'imm_z=0x([0-9A-Fa-f]+)'
        r'(?:\s+p_ca=([0-9.]+)\s+'
        r'p_singer=([0-9.]+)\s+'
        r'p_bike=([0-9.]+))?'
    )
    # Also support standard 9D format (reuse from single-model tests)
    std_hex_pattern = re.compile(
        r'Cycle\s+(\d+):\s+'
        r'x_pos=0x([0-9A-Fa-f]+)\s+.*'
        r'y_pos=0x([0-9A-Fa-f]+)\s+.*'
        r'z_pos=0x([0-9A-Fa-f]+)'
    )

    with open(txt_path, 'r') as f:
        for line in f:
            m = hex_pattern.search(line)
            if m:
                cycle = int(m.group(1))
                entry = {
                    'x_pos': hex48_to_signed(m.group(2)),
                    'y_pos': hex48_to_signed(m.group(3)),
                    'z_pos': hex48_to_signed(m.group(4)),
                }
                if m.group(5):
                    entry['p_ca'] = float(m.group(5))
                    entry['p_singer'] = float(m.group(6))
                    entry['p_bike'] = float(m.group(7))
                results[cycle] = entry
                continue
            m = std_hex_pattern.search(line)
            if m:
                cycle = int(m.group(1))
                results[cycle] = {
                    'x_pos': hex48_to_signed(m.group(2)),
                    'y_pos': hex48_to_signed(m.group(3)),
                    'z_pos': hex48_to_signed(m.group(4)),
                }
    return results

def q24_to_real(val):
    return val / Q_SCALE

def to_hex48(val):
    if val < 0:
        val = val + (1 << 48)
    return f"{val:012X}"

def compute_rmse(gt, est, max_cycle):
    sum_sq = 0.0
    count = 0
    for c in range(max_cycle):
        if c not in gt or c not in est:
            continue
        ex = q24_to_real(est[c]['x_pos']) - gt[c]['x']
        ey = q24_to_real(est[c]['y_pos']) - gt[c]['y']
        ez = q24_to_real(est[c]['z_pos']) - gt[c]['z']
        sum_sq += ex*ex + ey*ey + ez*ez
        count += 1
    if count == 0:
        return None, 0
    return math.sqrt(sum_sq / count), count

def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <vhdl_output.txt> <ground_truth.csv>")
        sys.exit(1)

    txt_path = sys.argv[1]
    csv_path = sys.argv[2]

    gt = load_ground_truth(csv_path)
    est = load_vhdl_output(txt_path)
    total_cycles = len(est)

    print("=" * 70)
    print(f"IMM FILTER - RMSE ANALYSIS")
    print(f"VHDL output: {txt_path}")
    print(f"Ground truth: {csv_path}")
    print(f"Total cycles: {total_cycles}")
    print("=" * 70)

    # Print first 10 cycles
    print(f"\n--- First 10 cycles ---")
    print(f"{'Cyc':>3} | {'x_pos':>14} {'y_pos':>14} {'z_pos':>14} | {'err_3D':>8}")
    print("-" * 70)
    for c in range(min(10, total_cycles)):
        if c not in est:
            continue
        xr = q24_to_real(est[c]['x_pos'])
        yr = q24_to_real(est[c]['y_pos'])
        zr = q24_to_real(est[c]['z_pos'])
        if c in gt:
            err = math.sqrt((xr-gt[c]['x'])**2 + (yr-gt[c]['y'])**2 + (zr-gt[c]['z'])**2)
        else:
            err = 0
        print(f"{c:3d} | 0x{to_hex48(est[c]['x_pos'])} 0x{to_hex48(est[c]['y_pos'])} 0x{to_hex48(est[c]['z_pos'])} | {err:8.4f}")

    # RMSE at checkpoints
    print(f"\n{'='*70}")
    print(f"RMSE AT CHECKPOINTS")
    print(f"{'='*70}")
    print(f"{'Cycles':>8} | {'RMSE_3D (m)':>12} | {'Status':>8}")
    print("-" * 40)

    test_pass = True
    for cp in [10, 100, 500, 750]:
        if cp > total_cycles:
            continue
        r3d, n = compute_rmse(gt, est, cp)
        if r3d is None:
            print(f"{cp:>8} | {'N/A':>12} | {'FAIL':>8}")
            test_pass = False
        else:
            status = "PASS" if r3d < 20.0 else "FAIL"
            if status == "FAIL":
                test_pass = False
            print(f"{cp:>8} | {r3d:12.4f} | {status:>8}")

    # Final
    print(f"\n{'='*70}")
    print("SIMULATION SUCCESSFUL" if test_pass else "SIMULATION FAILED")
    print(f"{'='*70}")
    return 0 if test_pass else 1

if __name__ == '__main__':
    sys.exit(main())
