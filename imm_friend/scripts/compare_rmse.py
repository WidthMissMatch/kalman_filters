#!/usr/bin/env python3
"""Compare RMSE: imm_friend (octavius.txt) vs imm_f1 (yeah_raha.txt) against ground truth."""
import re, math, csv, sys

Q = 24
SCALE = 2**Q

def hex48_to_float(h):
    """Convert 48-bit hex (Q24.24) to float, handling sign."""
    v = int(h, 16)
    if v >= 2**47:
        v -= 2**48
    return v / SCALE

def parse_output(path, px_key="imm_x", py_key="imm_y", pz_key="imm_z"):
    """Parse hex output file, return list of (cycle, x, y, z)."""
    results = []
    pattern = re.compile(
        r'Cycle\s+(\d+):\s+' +
        re.escape(px_key) + r'=0x([0-9A-Fa-f]+)\s+' +
        re.escape(py_key) + r'=0x([0-9A-Fa-f]+)\s+' +
        re.escape(pz_key) + r'=0x([0-9A-Fa-f]+)'
    )
    with open(path) as f:
        for line in f:
            m = pattern.search(line)
            if m:
                cy = int(m.group(1))
                x = hex48_to_float(m.group(2))
                y = hex48_to_float(m.group(3))
                z = hex48_to_float(m.group(4))
                results.append((cy, x, y, z))
    return results

def load_ground_truth(path):
    """Load ground truth from CSV."""
    gt = {}
    with open(path) as f:
        reader = csv.DictReader(f)
        for row in reader:
            cy = int(row['cycle'])
            gt[cy] = (float(row['gt_x_pos']), float(row['gt_y_pos']), float(row['gt_z_pos']))
    return gt

def compute_rmse(estimates, gt):
    """Compute 3D position RMSE."""
    sum_sq = 0.0
    n = 0
    for cy, ex, ey, ez in estimates:
        if cy in gt:
            gx, gy, gz = gt[cy]
            sum_sq += (ex - gx)**2 + (ey - gy)**2 + (ez - gz)**2
            n += 1
    return math.sqrt(sum_sq / n) if n > 0 else float('inf'), n

def main():
    gt_path = "/home/arunupscee/Desktop/xtortion/collection/imm_f1/deliverable/test_data/f1_monaco_2024_750cycles.csv"
    imm_f1_path = "/home/arunupscee/Desktop/xtortion/collection/imm_f1/results/yeah_raha.txt"
    imm_friend_path = "/tmp/imm_friend_xsim/octavius.txt"

    if len(sys.argv) > 1:
        imm_friend_path = sys.argv[1]

    gt = load_ground_truth(gt_path)
    print(f"Ground truth: {len(gt)} cycles loaded")

    # Parse imm_f1
    f1_est = parse_output(imm_f1_path)
    f1_rmse, f1_n = compute_rmse(f1_est, gt)
    print(f"\nimm_f1 (CA+Singer+Bicycle):")
    print(f"  Cycles: {f1_n}")
    print(f"  RMSE:   {f1_rmse:.4f} m")

    # Parse imm_friend
    friend_est = parse_output(imm_friend_path)
    friend_rmse, friend_n = compute_rmse(friend_est, gt)
    print(f"\nimm_friend (CTRA+Singer+Bicycle):")
    print(f"  Cycles: {friend_n}")
    print(f"  RMSE:   {friend_rmse:.4f} m")

    # Comparison
    if f1_rmse > 0:
        improvement = (f1_rmse - friend_rmse) / f1_rmse * 100
        print(f"\n{'='*50}")
        if improvement > 0:
            print(f"imm_friend is {improvement:.1f}% BETTER than imm_f1")
        else:
            print(f"imm_friend is {-improvement:.1f}% WORSE than imm_f1")
        print(f"  imm_f1:     {f1_rmse:.4f} m")
        print(f"  imm_friend: {friend_rmse:.4f} m")
        print(f"  Delta:      {friend_rmse - f1_rmse:+.4f} m")

if __name__ == '__main__':
    main()
