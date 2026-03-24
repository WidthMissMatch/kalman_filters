#!/usr/bin/env python3
"""Compute RMSE of CTR UKF VHDL output against real FPV drone ground truth."""
import csv
import re
import math
import sys

Q_SCALE = 2**24

def parse_vhdl_output(filepath):
    """Parse VHDL testbench output (report messages)."""
    cycles = {}
    current_cycle = None
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            m = re.match(r'CYCLE\s+(\d+)', line)
            if m:
                current_cycle = int(m.group(1))
                cycles[current_cycle] = {}
                continue
            if current_cycle is None:
                continue
            for key, val in re.findall(r'(\w+)=(-?\d+)', line):
                cycles[current_cycle][key] = int(val)
    return cycles

def main():
    gt_path = "/home/arunupscee/Desktop/xtortion/ctr_ukf/real_fpv_test/ground_truth_fpv.csv"
    vhdl_path = sys.argv[1] if len(sys.argv) > 1 else "/home/arunupscee/Desktop/xtortion/ctr_ukf/real_fpv_test/vhdl_output_real_fpv.txt"

    print("=" * 90)
    print("CTR UKF: VHDL vs Real FPV Drone Ground Truth")
    print("=" * 90)

    # Load ground truth
    gt = {}
    with open(gt_path) as f:
        reader = csv.DictReader(f)
        for row in reader:
            c = int(row['cycle'])
            gt[c] = {
                'x': float(row['gt_x']), 'y': float(row['gt_y']), 'z': float(row['gt_z']),
                'vx': float(row['gt_vx']), 'vy': float(row['gt_vy']), 'vz': float(row['gt_vz']),
                'wx': float(row['gt_wx']), 'wy': float(row['gt_wy']), 'wz': float(row['gt_wz']),
            }

    # Load VHDL output
    try:
        vhdl = parse_vhdl_output(vhdl_path)
    except FileNotFoundError:
        print(f"ERROR: VHDL output not found: {vhdl_path}")
        print("  Run the VHDL simulation first, then pass the output file.")
        return 1

    num_cycles = min(len(vhdl), len(gt))
    print(f"  Ground truth cycles: {len(gt)}")
    print(f"  VHDL output cycles:  {len(vhdl)}")
    print(f"  Comparing:           {num_cycles} cycles")
    print()

    # State mapping: VHDL name -> ground truth key
    state_map = [
        ('EST_X', 'x', 'x_pos'), ('VEL_X', 'vx', 'x_vel'), ('OMEGA_X', 'wx', 'x_omega'),
        ('EST_Y', 'y', 'y_pos'), ('VEL_Y', 'vy', 'y_vel'), ('OMEGA_Y', 'wy', 'y_omega'),
        ('EST_Z', 'z', 'z_pos'), ('VEL_Z', 'vz', 'z_vel'), ('OMEGA_Z', 'wz', 'z_omega'),
    ]

    # Accumulate errors
    errors = {name: [] for _, _, name in state_map}
    max_err = {name: 0.0 for _, _, name in state_map}

    print(f"{'Cyc':>3} | {'State':>8} | {'VHDL (real)':>12} | {'GT (real)':>12} | {'Error':>12}")
    print("-" * 65)

    for c in range(num_cycles):
        if c not in vhdl or c not in gt:
            continue
        show = c < 5 or c == num_cycles - 1 or c % 50 == 0

        for vkey, gtkey, sname in state_map:
            v_q24 = vhdl[c].get(vkey, 0)
            v_real = v_q24 / Q_SCALE
            g_real = gt[c][gtkey]
            err = v_real - g_real

            errors[sname].append(err ** 2)
            max_err[sname] = max(max_err[sname], abs(err))

            if show:
                print(f"{c:3d} | {sname:>8} | {v_real:12.4f} | {g_real:12.4f} | {err:+12.4f}")

        if show:
            print()

    # RMSE summary
    print("=" * 70)
    print("RMSE SUMMARY (VHDL estimates vs ground truth)")
    print("=" * 70)
    print(f"{'State':>10} | {'RMSE':>12} | {'Max Error':>12} | {'Unit':>8}")
    print("-" * 50)

    for _, _, sname in state_map:
        errs = errors[sname]
        if len(errs) == 0:
            continue
        rmse = math.sqrt(sum(errs) / len(errs))
        mx = max_err[sname]
        unit = "m" if "pos" in sname else ("m/s" if "vel" in sname else "rad/s")
        print(f"{sname:>10} | {rmse:12.4f} | {mx:12.4f} | {unit:>8}")

    print()
    print("=" * 70)

    # Overall position RMSE
    pos_errs = errors['x_pos'] + errors['y_pos'] + errors['z_pos']
    pos_rmse = math.sqrt(sum(pos_errs) / len(pos_errs)) if pos_errs else 0
    vel_errs = errors['x_vel'] + errors['y_vel'] + errors['z_vel']
    vel_rmse = math.sqrt(sum(vel_errs) / len(vel_errs)) if vel_errs else 0
    print(f"Overall Position RMSE: {pos_rmse:.4f} m")
    print(f"Overall Velocity RMSE: {vel_rmse:.4f} m/s")
    print("=" * 70)

    return 0

if __name__ == '__main__':
    sys.exit(main())
