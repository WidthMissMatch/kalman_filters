#!/usr/bin/env python3
"""Compute RMSE for IMM Friend Abu Dhabi Verstappen dataset.
One-step-ahead prediction: compare filter output at cycle N vs measurement at cycle N+1.
"""
import re, math, csv

Q = 24
SCALE = 2**Q

NAMO_PATH = "/tmp/imm_friend_xsim/namo.txt"
CSV_PATH = "/home/arunupscee/Desktop/xtortion/collection/imm_friend/test_data/abu_dhabi_verstappen_4173cycles.csv"

def hex48_to_float(h):
    v = int(h, 16)
    if v >= 2**47:
        v -= 2**48
    return v / SCALE

def main():
    # Load ground truth (= measurements)
    gt = {}
    with open(CSV_PATH) as f:
        reader = csv.DictReader(f)
        for row in reader:
            cy = int(row['cycle'])
            gt[cy] = (float(row['gt_x_pos']), float(row['gt_y_pos']), float(row['gt_z_pos']))
    print(f"Ground truth: {len(gt)} cycles")

    # Parse namo.txt
    pattern = re.compile(
        r'Cycle\s+(\d+):\s+imm_x=0x([0-9A-Fa-f]+)\s+imm_y=0x([0-9A-Fa-f]+)\s+imm_z=0x([0-9A-Fa-f]+)'
        r'\s+p_ct=0x([0-9A-Fa-f]+)\s+p_si=0x([0-9A-Fa-f]+)\s+p_bi=0x([0-9A-Fa-f]+)'
    )
    estimates = []
    with open(NAMO_PATH) as f:
        for line in f:
            m = pattern.search(line)
            if m:
                cy = int(m.group(1))
                x = hex48_to_float(m.group(2))
                y = hex48_to_float(m.group(3))
                z = hex48_to_float(m.group(4))
                p_ct = hex48_to_float(m.group(5))
                p_si = hex48_to_float(m.group(6))
                p_bi = hex48_to_float(m.group(7))
                estimates.append((cy, x, y, z, p_ct, p_si, p_bi))
    print(f"Estimates:    {len(estimates)} cycles parsed from namo.txt")

    # ================================================================
    # ONE-STEP-AHEAD PREDICTION RMSE
    # Filter output at cycle N compared to measurement at cycle N+1
    # ================================================================
    print(f"\n{'='*60}")
    print("ONE-STEP-AHEAD PREDICTION ACCURACY")
    print(f"  Filter state at cycle N  vs  measurement at cycle N+1")
    print(f"{'='*60}")

    checkpoints = [100, 500, 1000, 2000, 3000, 4000, len(estimates)-1]
    print(f"\n{'Checkpoint':>12} {'RMSE (m)':>10} {'Cycles':>8}")
    print(f"{'-'*40}")

    for cp in checkpoints:
        subset = estimates[:cp]
        sum_sq = 0.0
        n = 0
        for cy, ex, ey, ez, _, _, _ in subset:
            next_cy = cy + 1
            if next_cy in gt:
                gx, gy, gz = gt[next_cy]
                sum_sq += (ex - gx)**2 + (ey - gy)**2 + (ez - gz)**2
                n += 1
        if n > 0:
            rmse = math.sqrt(sum_sq / n)
            print(f"{cp:>12} {rmse:>10.4f} {n:>8}")

    # Full one-step-ahead RMSE
    sum_sq = 0.0
    sum_x, sum_y, sum_z = 0.0, 0.0, 0.0
    n = 0
    for cy, ex, ey, ez, _, _, _ in estimates:
        next_cy = cy + 1
        if next_cy in gt:
            gx, gy, gz = gt[next_cy]
            dx2 = (ex - gx)**2
            dy2 = (ey - gy)**2
            dz2 = (ez - gz)**2
            sum_sq += dx2 + dy2 + dz2
            sum_x += dx2
            sum_y += dy2
            sum_z += dz2
            n += 1
    full_rmse = math.sqrt(sum_sq / n) if n > 0 else float('inf')
    print(f"{'-'*40}")
    print(f"\nFINAL ONE-STEP-AHEAD 3D RMSE: {full_rmse:.4f} m over {n} cycles")

    print(f"\nPer-axis one-step-ahead RMSE:")
    print(f"  X: {math.sqrt(sum_x/n):.4f} m")
    print(f"  Y: {math.sqrt(sum_y/n):.4f} m")
    print(f"  Z: {math.sqrt(sum_z/n):.4f} m")

    # ================================================================
    # FILTER TRACKING RMSE (for reference — output N vs meas N)
    # ================================================================
    sum_sq2 = 0.0
    n2 = 0
    for cy, ex, ey, ez, _, _, _ in estimates:
        if cy in gt:
            gx, gy, gz = gt[cy]
            sum_sq2 += (ex - gx)**2 + (ey - gy)**2 + (ez - gz)**2
            n2 += 1
    track_rmse = math.sqrt(sum_sq2 / n2) if n2 > 0 else float('inf')
    print(f"\n{'='*60}")
    print(f"Filter tracking RMSE (output N vs meas N): {track_rmse:.4f} m")
    print(f"  (measures smoothing residual, not prediction)")

    # Model probability stats
    print(f"\n{'='*60}")
    print("Model probability distribution (last 100 cycles):")
    last100 = estimates[-100:]
    avg_ct = sum(p_ct for _, _, _, _, p_ct, _, _ in last100) / len(last100)
    avg_si = sum(p_si for _, _, _, _, _, p_si, _ in last100) / len(last100)
    avg_bi = sum(p_bi for _, _, _, _, _, _, p_bi in last100) / len(last100)
    print(f"  CTRA:    {avg_ct:.4f}")
    print(f"  Singer:  {avg_si:.4f}")
    print(f"  Bicycle: {avg_bi:.4f}")

if __name__ == '__main__':
    main()
