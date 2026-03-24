#!/usr/bin/env python3
"""
Analyze IMM VHDL output and compare with Python reference.
Usage: python3 analyze_vhdl_output.py <vhdl_output.txt> <dataset_csv>
"""
import sys, re, csv, math
import numpy as np

def parse_hex48(h):
    """Parse Q24.24 hex value to float"""
    val = int(h, 16)
    if val >= 2**47:
        val -= 2**48
    return val / (2**24)

def load_vhdl_output(fname):
    """Parse VHDL hex output file"""
    cycles = []
    with open(fname) as f:
        for line in f:
            m = re.match(r'Cycle\s+(\d+):\s+imm_x=0x([0-9A-Fa-f]+)\s+imm_y=0x([0-9A-Fa-f]+)\s+imm_z=0x([0-9A-Fa-f]+)\s+p_ca=0x([0-9A-Fa-f]+)\s+p_si=0x([0-9A-Fa-f]+)\s+p_bi=0x([0-9A-Fa-f]+)', line)
            if m:
                cy = int(m.group(1))
                x = parse_hex48(m.group(2))
                y = parse_hex48(m.group(3))
                z = parse_hex48(m.group(4))
                p_ca = parse_hex48(m.group(5))
                p_si = parse_hex48(m.group(6))
                p_bi = parse_hex48(m.group(7))
                cycles.append({'cycle': cy, 'x': x, 'y': y, 'z': z,
                              'p_ca': p_ca, 'p_si': p_si, 'p_bi': p_bi})
    return cycles

def load_ground_truth(csv_path, n_cycles=None):
    """Load ground truth from CSV. Format: cycle,time,gt_x,gt_y,gt_z,meas_x,meas_y,meas_z,..."""
    gt = []
    with open(csv_path) as f:
        reader = csv.reader(f)
        header = next(reader)
        for row in reader:
            gt.append({
                'gx': float(row[2]), 'gy': float(row[3]), 'gz': float(row[4]),
                'mx': float(row[5]), 'my': float(row[6]), 'mz': float(row[7])
            })
            if n_cycles and len(gt) >= n_cycles:
                break
    return gt

def main():
    if len(sys.argv) < 3:
        print("Usage: python3 analyze_vhdl_output.py <vhdl_output.txt> <dataset.csv>")
        sys.exit(1)

    vhdl_file = sys.argv[1]
    csv_file = sys.argv[2]

    vhdl = load_vhdl_output(vhdl_file)
    gt = load_ground_truth(csv_file, len(vhdl))

    print(f"VHDL cycles: {len(vhdl)}, Ground truth rows: {len(gt)}")
    print()

    # Compute RMSE
    errors = []
    for i, (v, g) in enumerate(zip(vhdl, gt)):
        ex = v['x'] - g['gx']
        ey = v['y'] - g['gy']
        ez = v['z'] - g['gz']
        err3d = math.sqrt(ex**2 + ey**2 + ez**2)
        errors.append(err3d)

    errors = np.array(errors)
    print(f"{'Cycles':>8} | {'RMSE':>10} | {'Mean Err':>10} | {'Max Err':>10}")
    print("-" * 50)
    for n in [10, 50, 100, 500, 750, len(errors)]:
        if n <= len(errors):
            rmse = np.sqrt(np.mean(errors[:n]**2))
            mean_e = np.mean(errors[:n])
            max_e = np.max(errors[:n])
            print(f"{n:>8} | {rmse:>10.4f} | {mean_e:>10.4f} | {max_e:>10.4f}")

    print()
    print("Model Probability Statistics:")
    print(f"{'Model':>10} | {'Mean':>8} | {'Std':>8} | {'Min':>8} | {'Max':>8}")
    print("-" * 55)
    for model, key in [('CA', 'p_ca'), ('Singer', 'p_si'), ('Bicycle', 'p_bi')]:
        vals = [v[key] for v in vhdl]
        print(f"{model:>10} | {np.mean(vals):>8.4f} | {np.std(vals):>8.4f} | {np.min(vals):>8.4f} | {np.max(vals):>8.4f}")

    # Probability switching analysis
    print()
    dominant = [max(('CA', v['p_ca']), ('Singer', v['p_si']), ('Bicycle', v['p_bi']), key=lambda x:x[1])[0] for v in vhdl]
    switches = sum(1 for i in range(1, len(dominant)) if dominant[i] != dominant[i-1])
    from collections import Counter
    counts = Counter(dominant)
    print(f"Model switches: {switches} over {len(vhdl)} cycles")
    print(f"Dominant model distribution: {dict(counts)}")

    # First 20 cycles detail
    print()
    print("First 20 cycles:")
    print(f"{'Cy':>4} | {'VHDL_x':>12} {'VHDL_y':>12} {'VHDL_z':>12} | {'GT_x':>10} {'GT_y':>10} {'GT_z':>10} | {'Err3D':>8} | {'P_CA':>6} {'P_Si':>6} {'P_Bi':>6}")
    print("-" * 120)
    for i in range(min(20, len(vhdl))):
        v = vhdl[i]
        g = gt[i]
        ex = v['x'] - g['gx']
        ey = v['y'] - g['gy']
        ez = v['z'] - g['gz']
        err = math.sqrt(ex**2 + ey**2 + ez**2)
        print(f"{i:>4} | {v['x']:>12.4f} {v['y']:>12.4f} {v['z']:>12.4f} | {g['gx']:>10.4f} {g['gy']:>10.4f} {g['gz']:>10.4f} | {err:>8.4f} | {v['p_ca']:>6.3f} {v['p_si']:>6.3f} {v['p_bi']:>6.3f}")

if __name__ == '__main__':
    main()
