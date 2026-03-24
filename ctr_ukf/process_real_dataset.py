#!/usr/bin/env python3
"""
Process real drone flight data (UZH FPV) into CTR UKF test vectors.

Source: UZH FPV Indoor Forward 7 (davis ground truth)
  - Real aggressive indoor drone flight with significant turning
  - omega_z up to 6.0 rad/s, speeds up to 12 m/s
  - From: https://github.com/mzahana/drone_trajectories/

Pipeline:
  1. Load trajectory (timestamp, tx, ty, tz, qx, qy, qz, qw)
  2. Interpolate to 50 Hz (dt=0.02s) matching VHDL
  3. Compute ground truth velocity + angular velocity
  4. Add measurement noise (sigma=0.5m position-only)
  5. Generate VHDL testbench (.vhd) with hardcoded measurements
  6. Generate golden model input file
  7. Run golden model comparison and compute RMSE

Usage:
  python3 process_real_dataset.py [--cycles N] [--noise SIGMA]
"""
import csv
import math
import argparse
import numpy as np
from scipy.interpolate import interp1d
from scipy.spatial.transform import Rotation
import os
import sys

Q = 24
SCALE = 1 << Q  # 16777216

def real_to_q24(val):
    return int(round(val * SCALE))

def q24_to_real(val):
    return val / SCALE

def to_hex48(val):
    """Convert signed Q24.24 integer to 12-char hex (48-bit unsigned representation)."""
    if val < 0:
        val += (1 << 48)
    return f"{val & 0xFFFFFFFFFFFF:012X}"

def load_trajectory(filepath):
    """Load trajectory CSV/TXT with columns: timestamp,tx,ty,tz,qx,qy,qz,qw"""
    rows = []
    with open(filepath) as f:
        reader = csv.DictReader(f)
        for r in reader:
            rows.append({
                't': float(r['timestamp']),
                'x': float(r['tx']),
                'y': float(r['ty']),
                'z': float(r['tz']),
                'qx': float(r['qx']),
                'qy': float(r['qy']),
                'qz': float(r['qz']),
                'qw': float(r['qw']),
            })
    return rows

def interpolate_trajectory(rows, dt=0.02, num_cycles=None):
    """Interpolate trajectory to uniform dt using cubic splines."""
    t_orig = np.array([r['t'] for r in rows])
    t_orig -= t_orig[0]  # start at t=0

    # Determine time span
    t_max = t_orig[-1]
    if num_cycles is not None:
        t_max = min(t_max, num_cycles * dt)

    t_new = np.arange(0, t_max, dt)
    if num_cycles is not None:
        t_new = t_new[:num_cycles]

    # Interpolate position
    x_interp = interp1d(t_orig, [r['x'] for r in rows], kind='cubic')(t_new)
    y_interp = interp1d(t_orig, [r['y'] for r in rows], kind='cubic')(t_new)
    z_interp = interp1d(t_orig, [r['z'] for r in rows], kind='cubic')(t_new)

    # Interpolate quaternion (using SLERP via scipy Rotation)
    quats_orig = np.array([[r['qx'], r['qy'], r['qz'], r['qw']] for r in rows])
    rots = Rotation.from_quat(quats_orig)  # scipy uses (x,y,z,w) format

    # Use Slerp for quaternion interpolation
    from scipy.spatial.transform import Slerp
    slerp = Slerp(t_orig, rots)
    rots_new = slerp(t_new)
    quats_new = rots_new.as_quat()  # (x,y,z,w)

    # Compute velocity via finite differences on interpolated data
    vx = np.gradient(x_interp, dt)
    vy = np.gradient(y_interp, dt)
    vz = np.gradient(z_interp, dt)

    # Compute angular velocity from quaternion differences
    wx = np.zeros(len(t_new))
    wy = np.zeros(len(t_new))
    wz = np.zeros(len(t_new))
    for i in range(1, len(t_new)):
        r0 = rots_new[i-1]
        r1 = rots_new[i]
        # delta rotation: R_delta = R1 * R0^-1
        r_delta = r1 * r0.inv()
        # Convert to rotation vector (axis*angle)
        rotvec = r_delta.as_rotvec()
        wx[i] = rotvec[0] / dt
        wy[i] = rotvec[1] / dt
        wz[i] = rotvec[2] / dt
    wx[0] = wx[1]  # fill first sample
    wy[0] = wy[1]
    wz[0] = wz[1]

    result = []
    for i in range(len(t_new)):
        result.append({
            't': t_new[i],
            'x': x_interp[i], 'y': y_interp[i], 'z': z_interp[i],
            'vx': vx[i], 'vy': vy[i], 'vz': vz[i],
            'wx': wx[i], 'wy': wy[i], 'wz': wz[i],
        })
    return result

def add_measurement_noise(trajectory, sigma_pos=0.5, seed=42):
    """Add Gaussian noise to position measurements."""
    rng = np.random.RandomState(seed)
    measurements = []
    for pt in trajectory:
        measurements.append({
            'z_x': pt['x'] + rng.normal(0, sigma_pos),
            'z_y': pt['y'] + rng.normal(0, sigma_pos),
            'z_z': pt['z'] + rng.normal(0, sigma_pos),
        })
    return measurements

def generate_vhdl_testbench(trajectory, measurements, num_cycles, outpath):
    """Generate VHDL testbench with hardcoded measurement data."""
    lines = []
    lines.append("-- Auto-generated CTR UKF testbench from real FPV drone data")
    lines.append("-- Source: UZH FPV Indoor Forward 7 (davis ground truth)")
    lines.append(f"-- Cycles: {num_cycles}, dt=0.02s, noise_sigma=0.5m")
    lines.append("library IEEE;")
    lines.append("use IEEE.STD_LOGIC_1164.ALL;")
    lines.append("use IEEE.NUMERIC_STD.ALL;")
    lines.append("")
    lines.append(f"entity ctr_ukf_real_fpv_{num_cycles}cycles_tb is")
    lines.append(f"end ctr_ukf_real_fpv_{num_cycles}cycles_tb;")
    lines.append("")
    lines.append(f"architecture Behavioral of ctr_ukf_real_fpv_{num_cycles}cycles_tb is")
    lines.append("")
    lines.append("    component ukf_supreme_3d is")
    lines.append("        port (")
    lines.append("            clk   : in  std_logic;")
    lines.append("            reset : in  std_logic;")
    lines.append("            start : in  std_logic;")
    lines.append("            z_x_meas : in  signed(47 downto 0);")
    lines.append("            z_y_meas : in  signed(47 downto 0);")
    lines.append("            z_z_meas : in  signed(47 downto 0);")
    lines.append("            done  : out std_logic;")
    lines.append("            x_pos_current   : out signed(47 downto 0);")
    lines.append("            x_vel_current   : out signed(47 downto 0);")
    lines.append("            x_omega_current : out signed(47 downto 0);")
    lines.append("            y_pos_current   : out signed(47 downto 0);")
    lines.append("            y_vel_current   : out signed(47 downto 0);")
    lines.append("            y_omega_current : out signed(47 downto 0);")
    lines.append("            z_pos_current   : out signed(47 downto 0);")
    lines.append("            z_vel_current   : out signed(47 downto 0);")
    lines.append("            z_omega_current : out signed(47 downto 0);")
    lines.append("            x_pos_uncertainty : out signed(47 downto 0);")
    lines.append("            x_vel_uncertainty : out signed(47 downto 0);")
    lines.append("            x_omega_uncertainty : out signed(47 downto 0);")
    lines.append("            y_pos_uncertainty : out signed(47 downto 0);")
    lines.append("            y_vel_uncertainty : out signed(47 downto 0);")
    lines.append("            y_omega_uncertainty : out signed(47 downto 0);")
    lines.append("            z_pos_uncertainty : out signed(47 downto 0);")
    lines.append("            z_vel_uncertainty : out signed(47 downto 0);")
    lines.append("            z_omega_uncertainty : out signed(47 downto 0)")
    lines.append("        );")
    lines.append("    end component;")
    lines.append("")
    lines.append("    signal clk, reset, start, done : std_logic := '0';")
    lines.append("    signal z_x_meas, z_y_meas, z_z_meas : signed(47 downto 0) := (others => '0');")
    lines.append("    signal x_pos_current, x_vel_current, x_omega_current : signed(47 downto 0);")
    lines.append("    signal y_pos_current, y_vel_current, y_omega_current : signed(47 downto 0);")
    lines.append("    signal z_pos_current, z_vel_current, z_omega_current : signed(47 downto 0);")
    lines.append("    signal x_pos_unc, x_vel_unc, x_omega_unc : signed(47 downto 0);")
    lines.append("    signal y_pos_unc, y_vel_unc, y_omega_unc : signed(47 downto 0);")
    lines.append("    signal z_pos_unc, z_vel_unc, z_omega_unc : signed(47 downto 0);")
    lines.append("")
    lines.append("    constant CLK_PERIOD : time := 10 ns;")
    lines.append(f"    constant NUM_CYCLES : integer := {num_cycles};")
    lines.append("")
    lines.append("    -- Measurement arrays (Q24.24 format)")
    lines.append(f"    type meas_array_t is array(0 to {num_cycles-1}) of signed(47 downto 0);")

    # Generate measurement arrays
    def fmt_meas(val):
        q = real_to_q24(val)
        return f'signed\'(X"{to_hex48(q)}")'

    lines.append("    constant MEAS_X : meas_array_t := (")
    for i in range(num_cycles):
        comma = "," if i < num_cycles - 1 else ""
        lines.append(f"        {fmt_meas(measurements[i]['z_x'])}{comma}  -- cycle {i}: x={trajectory[i]['x']:.3f}m + noise")
    lines.append("    );")

    lines.append("    constant MEAS_Y : meas_array_t := (")
    for i in range(num_cycles):
        comma = "," if i < num_cycles - 1 else ""
        lines.append(f"        {fmt_meas(measurements[i]['z_y'])}{comma}")
    lines.append("    );")

    lines.append("    constant MEAS_Z : meas_array_t := (")
    for i in range(num_cycles):
        comma = "," if i < num_cycles - 1 else ""
        lines.append(f"        {fmt_meas(measurements[i]['z_z'])}{comma}")
    lines.append("    );")

    lines.append("")
    lines.append("begin")
    lines.append("")
    lines.append("    uut: ukf_supreme_3d port map (")
    lines.append("        clk => clk, reset => reset, start => start,")
    lines.append("        z_x_meas => z_x_meas, z_y_meas => z_y_meas, z_z_meas => z_z_meas,")
    lines.append("        done => done,")
    lines.append("        x_pos_current => x_pos_current, x_vel_current => x_vel_current,")
    lines.append("        x_omega_current => x_omega_current,")
    lines.append("        y_pos_current => y_pos_current, y_vel_current => y_vel_current,")
    lines.append("        y_omega_current => y_omega_current,")
    lines.append("        z_pos_current => z_pos_current, z_vel_current => z_vel_current,")
    lines.append("        z_omega_current => z_omega_current,")
    lines.append("        x_pos_uncertainty => x_pos_unc, x_vel_uncertainty => x_vel_unc,")
    lines.append("        x_omega_uncertainty => x_omega_unc,")
    lines.append("        y_pos_uncertainty => y_pos_unc, y_vel_uncertainty => y_vel_unc,")
    lines.append("        y_omega_uncertainty => y_omega_unc,")
    lines.append("        z_pos_uncertainty => z_pos_unc, z_vel_uncertainty => z_vel_unc,")
    lines.append("        z_omega_uncertainty => z_omega_unc")
    lines.append("    );")
    lines.append("")
    lines.append("    -- Clock generation")
    lines.append("    clk_process: process begin")
    lines.append("        clk <= '0'; wait for CLK_PERIOD/2;")
    lines.append("        clk <= '1'; wait for CLK_PERIOD/2;")
    lines.append("    end process;")
    lines.append("")
    lines.append("    -- Main test stimulus")
    lines.append("    stim_proc: process")
    lines.append("        variable cycle_count : integer := 0;")
    lines.append("    begin")
    lines.append("        -- Reset")
    lines.append("        reset <= '1';")
    lines.append("        start <= '0';")
    lines.append("        wait for CLK_PERIOD * 5;")
    lines.append("        reset <= '0';")
    lines.append("        wait for CLK_PERIOD * 2;")
    lines.append("")
    lines.append("        -- Run UKF cycles")
    lines.append("        for i in 0 to NUM_CYCLES - 1 loop")
    lines.append("            -- Load measurement")
    lines.append("            z_x_meas <= MEAS_X(i);")
    lines.append("            z_y_meas <= MEAS_Y(i);")
    lines.append("            z_z_meas <= MEAS_Z(i);")
    lines.append("            wait for CLK_PERIOD;")
    lines.append("")
    lines.append("            -- Start UKF cycle")
    lines.append("            start <= '1';")
    lines.append("            wait for CLK_PERIOD;")
    lines.append("            start <= '0';")
    lines.append("")
    lines.append("            -- Wait for done")
    lines.append("            wait until done = '1';")
    lines.append("            wait for CLK_PERIOD;")
    lines.append("")
    lines.append("            -- Report results")
    lines.append('            report "CYCLE " & integer\'image(i);')
    lines.append('            report "  EST_X=" & integer\'image(to_integer(x_pos_current)) &')
    lines.append('                   "  EST_Y=" & integer\'image(to_integer(y_pos_current)) &')
    lines.append('                   "  EST_Z=" & integer\'image(to_integer(z_pos_current));')
    lines.append('            report "  VEL_X=" & integer\'image(to_integer(x_vel_current)) &')
    lines.append('                   "  VEL_Y=" & integer\'image(to_integer(y_vel_current)) &')
    lines.append('                   "  VEL_Z=" & integer\'image(to_integer(z_vel_current));')
    lines.append('            report "  OMEGA_X=" & integer\'image(to_integer(x_omega_current)) &')
    lines.append('                   "  OMEGA_Y=" & integer\'image(to_integer(y_omega_current)) &')
    lines.append('                   "  OMEGA_Z=" & integer\'image(to_integer(z_omega_current));')
    lines.append('            report "  P_xpos=" & integer\'image(to_integer(x_pos_unc)) &')
    lines.append('                   "  P_xvel=" & integer\'image(to_integer(x_vel_unc)) &')
    lines.append('                   "  P_xomg=" & integer\'image(to_integer(x_omega_unc)) &')
    lines.append('                   "  P_ypos=" & integer\'image(to_integer(y_pos_unc)) &')
    lines.append('                   "  P_yvel=" & integer\'image(to_integer(y_vel_unc)) &')
    lines.append('                   "  P_yomg=" & integer\'image(to_integer(y_omega_unc)) &')
    lines.append('                   "  P_zpos=" & integer\'image(to_integer(z_pos_unc)) &')
    lines.append('                   "  P_zvel=" & integer\'image(to_integer(z_vel_unc)) &')
    lines.append('                   "  P_zomg=" & integer\'image(to_integer(z_omega_unc));')
    lines.append("")
    lines.append("            -- Wait for done to deassert")
    lines.append("            start <= '0';")
    lines.append("            wait for CLK_PERIOD * 3;")
    lines.append("        end loop;")
    lines.append("")
    lines.append('        report "=== SIMULATION COMPLETE ===" severity note;')
    lines.append("        wait;")
    lines.append("    end process;")
    lines.append("")
    lines.append(f"end Behavioral;")

    with open(outpath, 'w') as f:
        f.write('\n'.join(lines) + '\n')
    print(f"  VHDL testbench: {outpath}")

def generate_ground_truth_csv(trajectory, measurements, num_cycles, outpath):
    """Write ground truth + measurements to CSV for RMSE computation."""
    with open(outpath, 'w', newline='') as f:
        w = csv.writer(f)
        w.writerow(['cycle', 'time',
                     'gt_x', 'gt_y', 'gt_z',
                     'gt_vx', 'gt_vy', 'gt_vz',
                     'gt_wx', 'gt_wy', 'gt_wz',
                     'meas_x', 'meas_y', 'meas_z',
                     'meas_x_q24', 'meas_y_q24', 'meas_z_q24'])
        for i in range(num_cycles):
            pt = trajectory[i]
            m = measurements[i]
            w.writerow([i, f"{pt['t']:.4f}",
                        f"{pt['x']:.6f}", f"{pt['y']:.6f}", f"{pt['z']:.6f}",
                        f"{pt['vx']:.6f}", f"{pt['vy']:.6f}", f"{pt['vz']:.6f}",
                        f"{pt['wx']:.6f}", f"{pt['wy']:.6f}", f"{pt['wz']:.6f}",
                        f"{m['z_x']:.6f}", f"{m['z_y']:.6f}", f"{m['z_z']:.6f}",
                        real_to_q24(m['z_x']), real_to_q24(m['z_y']), real_to_q24(m['z_z'])])
    print(f"  Ground truth CSV: {outpath}")

def generate_measurement_hex(measurements, num_cycles, outpath):
    """Write measurement hex values for golden model input."""
    with open(outpath, 'w') as f:
        f.write(f"# CTR UKF measurement data - {num_cycles} cycles\n")
        f.write("# Source: UZH FPV Indoor Forward 7 + noise (sigma=0.5m)\n")
        f.write("# Format: cycle meas_x_q24 meas_y_q24 meas_z_q24\n")
        for i in range(num_cycles):
            m = measurements[i]
            mx = real_to_q24(m['z_x'])
            my = real_to_q24(m['z_y'])
            mz = real_to_q24(m['z_z'])
            f.write(f"{i} {mx} {my} {mz}\n")
    print(f"  Measurement hex: {outpath}")

def compute_rmse_against_ground_truth(gt_csv, vhdl_output, outpath):
    """Compare VHDL output against ground truth and compute RMSE."""
    # This will be run separately after simulation
    pass

def generate_rmse_script(num_cycles, outdir):
    """Generate Python script to compute RMSE of VHDL output vs ground truth."""
    script = f'''#!/usr/bin/env python3
"""Compute RMSE of CTR UKF VHDL output against real FPV drone ground truth."""
import csv
import re
import math
import sys

Q_SCALE = 2**24

def parse_vhdl_output(filepath):
    """Parse VHDL testbench output (report messages)."""
    cycles = {{}}
    current_cycle = None
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            m = re.match(r'CYCLE\\s+(\\d+)', line)
            if m:
                current_cycle = int(m.group(1))
                cycles[current_cycle] = {{}}
                continue
            if current_cycle is None:
                continue
            for key, val in re.findall(r'(\\w+)=(-?\\d+)', line):
                cycles[current_cycle][key] = int(val)
    return cycles

def main():
    gt_path = "{outdir}/ground_truth_fpv.csv"
    vhdl_path = sys.argv[1] if len(sys.argv) > 1 else "{outdir}/vhdl_output_real_fpv.txt"

    print("=" * 90)
    print("CTR UKF: VHDL vs Real FPV Drone Ground Truth")
    print("=" * 90)

    # Load ground truth
    gt = {{}}
    with open(gt_path) as f:
        reader = csv.DictReader(f)
        for row in reader:
            c = int(row['cycle'])
            gt[c] = {{
                'x': float(row['gt_x']), 'y': float(row['gt_y']), 'z': float(row['gt_z']),
                'vx': float(row['gt_vx']), 'vy': float(row['gt_vy']), 'vz': float(row['gt_vz']),
                'wx': float(row['gt_wx']), 'wy': float(row['gt_wy']), 'wz': float(row['gt_wz']),
            }}

    # Load VHDL output
    try:
        vhdl = parse_vhdl_output(vhdl_path)
    except FileNotFoundError:
        print(f"ERROR: VHDL output not found: {{vhdl_path}}")
        print("  Run the VHDL simulation first, then pass the output file.")
        return 1

    num_cycles = min(len(vhdl), len(gt))
    print(f"  Ground truth cycles: {{len(gt)}}")
    print(f"  VHDL output cycles:  {{len(vhdl)}}")
    print(f"  Comparing:           {{num_cycles}} cycles")
    print()

    # State mapping: VHDL name -> ground truth key
    state_map = [
        ('EST_X', 'x', 'x_pos'), ('VEL_X', 'vx', 'x_vel'), ('OMEGA_X', 'wx', 'x_omega'),
        ('EST_Y', 'y', 'y_pos'), ('VEL_Y', 'vy', 'y_vel'), ('OMEGA_Y', 'wy', 'y_omega'),
        ('EST_Z', 'z', 'z_pos'), ('VEL_Z', 'vz', 'z_vel'), ('OMEGA_Z', 'wz', 'z_omega'),
    ]

    # Accumulate errors
    errors = {{name: [] for _, _, name in state_map}}
    max_err = {{name: 0.0 for _, _, name in state_map}}

    print(f"{{'Cyc':>3}} | {{'State':>8}} | {{'VHDL (real)':>12}} | {{'GT (real)':>12}} | {{'Error':>12}}")
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
                print(f"{{c:3d}} | {{sname:>8}} | {{v_real:12.4f}} | {{g_real:12.4f}} | {{err:+12.4f}}")

        if show:
            print()

    # RMSE summary
    print("=" * 70)
    print("RMSE SUMMARY (VHDL estimates vs ground truth)")
    print("=" * 70)
    print(f"{{'State':>10}} | {{'RMSE':>12}} | {{'Max Error':>12}} | {{'Unit':>8}}")
    print("-" * 50)

    for _, _, sname in state_map:
        errs = errors[sname]
        if len(errs) == 0:
            continue
        rmse = math.sqrt(sum(errs) / len(errs))
        mx = max_err[sname]
        unit = "m" if "pos" in sname else ("m/s" if "vel" in sname else "rad/s")
        print(f"{{sname:>10}} | {{rmse:12.4f}} | {{mx:12.4f}} | {{unit:>8}}")

    print()
    print("=" * 70)

    # Overall position RMSE
    pos_errs = errors['x_pos'] + errors['y_pos'] + errors['z_pos']
    pos_rmse = math.sqrt(sum(pos_errs) / len(pos_errs)) if pos_errs else 0
    vel_errs = errors['x_vel'] + errors['y_vel'] + errors['z_vel']
    vel_rmse = math.sqrt(sum(vel_errs) / len(vel_errs)) if vel_errs else 0
    print(f"Overall Position RMSE: {{pos_rmse:.4f}} m")
    print(f"Overall Velocity RMSE: {{vel_rmse:.4f}} m/s")
    print("=" * 70)

    return 0

if __name__ == '__main__':
    sys.exit(main())
'''
    script_path = os.path.join(outdir, "compute_rmse_real_fpv.py")
    with open(script_path, 'w') as f:
        f.write(script)
    print(f"  RMSE script: {script_path}")

def main():
    parser = argparse.ArgumentParser(description="Process real drone data for CTR UKF testing")
    parser.add_argument('--input', default='/tmp/ctr_ukf_work/datasets/fpv_indoor_7.txt',
                        help='Input trajectory file')
    parser.add_argument('--cycles', '-n', type=int, default=500,
                        help='Number of UKF cycles (default: 500 = 10s at 50Hz)')
    parser.add_argument('--noise', type=float, default=0.5,
                        help='Measurement noise sigma in meters (default: 0.5)')
    parser.add_argument('--outdir', default=None,
                        help='Output directory (default: ctr_ukf/real_fpv_test/)')
    args = parser.parse_args()

    if args.outdir is None:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        args.outdir = os.path.join(script_dir, "real_fpv_test")
    os.makedirs(args.outdir, exist_ok=True)

    print("=" * 70)
    print("CTR UKF Real Dataset Processor")
    print("=" * 70)
    print(f"  Input:    {args.input}")
    print(f"  Cycles:   {args.cycles} ({args.cycles * 0.02:.1f}s at 50Hz)")
    print(f"  Noise:    sigma={args.noise}m")
    print(f"  Output:   {args.outdir}/")
    print()

    # 1. Load trajectory
    print("Loading trajectory...")
    raw = load_trajectory(args.input)
    t_span = raw[-1]['t'] - raw[0]['t']
    print(f"  Raw: {len(raw)} points, {t_span:.1f}s")

    # 2. Interpolate to 50 Hz
    print("Interpolating to 50 Hz (dt=0.02s)...")
    trajectory = interpolate_trajectory(raw, dt=0.02, num_cycles=args.cycles)
    actual_cycles = len(trajectory)
    print(f"  Interpolated: {actual_cycles} points")

    if actual_cycles < args.cycles:
        print(f"  WARNING: Only {actual_cycles} cycles available (requested {args.cycles})")
        args.cycles = actual_cycles

    # 3. Print trajectory stats
    xs = [p['x'] for p in trajectory]
    ys = [p['y'] for p in trajectory]
    zs = [p['z'] for p in trajectory]
    speeds = [math.sqrt(p['vx']**2 + p['vy']**2 + p['vz']**2) for p in trajectory]
    omegas = [math.sqrt(p['wx']**2 + p['wy']**2 + p['wz']**2) for p in trajectory]
    print(f"  Position: X=[{min(xs):.1f},{max(xs):.1f}] Y=[{min(ys):.1f},{max(ys):.1f}] Z=[{min(zs):.1f},{max(zs):.1f}]")
    print(f"  Speed: [{min(speeds):.1f},{max(speeds):.1f}] m/s, mean={np.mean(speeds):.1f}")
    print(f"  |omega|: [{min(omegas):.2f},{max(omegas):.2f}] rad/s, mean={np.mean(omegas):.2f}")
    print()

    # 4. Add measurement noise
    print("Adding measurement noise...")
    measurements = add_measurement_noise(trajectory, sigma_pos=args.noise)

    # 5. Generate outputs
    print("Generating output files...")
    generate_ground_truth_csv(
        trajectory, measurements, args.cycles,
        os.path.join(args.outdir, "ground_truth_fpv.csv"))

    generate_measurement_hex(
        measurements, args.cycles,
        os.path.join(args.outdir, "measurements_fpv.txt"))

    generate_vhdl_testbench(
        trajectory, measurements, args.cycles,
        os.path.join(args.outdir, f"ctr_ukf_real_fpv_{args.cycles}cycles_tb.vhd"))

    generate_rmse_script(args.cycles, args.outdir)

    # 6. Generate golden model measurement data for the existing golden model
    # Update the golden model's MEAS arrays
    print()
    print("Generating golden model measurement constants...")
    meas_path = os.path.join(args.outdir, "golden_model_meas_constants.py")
    with open(meas_path, 'w') as f:
        f.write(f"# Auto-generated measurement data for CTR UKF golden model\n")
        f.write(f"# Source: UZH FPV Indoor Forward 7, noise sigma={args.noise}m\n")
        f.write(f"# {args.cycles} cycles at dt=0.02s (50 Hz)\n\n")

        f.write("MEAS_X_HEX = [\n")
        for i in range(args.cycles):
            q = real_to_q24(measurements[i]['z_x'])
            hex_val = to_hex48(q)
            comma = "," if i < args.cycles - 1 else ""
            f.write(f"    0x{hex_val}{comma}  # cycle {i}: {measurements[i]['z_x']:.4f}m\n")
        f.write("]\n\n")

        f.write("MEAS_Y_HEX = [\n")
        for i in range(args.cycles):
            q = real_to_q24(measurements[i]['z_y'])
            hex_val = to_hex48(q)
            comma = "," if i < args.cycles - 1 else ""
            f.write(f"    0x{hex_val}{comma}\n")
        f.write("]\n\n")

        f.write("MEAS_Z_HEX = [\n")
        for i in range(args.cycles):
            q = real_to_q24(measurements[i]['z_z'])
            hex_val = to_hex48(q)
            comma = "," if i < args.cycles - 1 else ""
            f.write(f"    0x{hex_val}{comma}\n")
        f.write("]\n")
    print(f"  Golden model constants: {meas_path}")

    print()
    print("=" * 70)
    print("DONE. Generated files:")
    print(f"  1. VHDL testbench:     {args.outdir}/ctr_ukf_real_fpv_{args.cycles}cycles_tb.vhd")
    print(f"  2. Ground truth CSV:   {args.outdir}/ground_truth_fpv.csv")
    print(f"  3. Measurements:       {args.outdir}/measurements_fpv.txt")
    print(f"  4. RMSE script:        {args.outdir}/compute_rmse_real_fpv.py")
    print(f"  5. Golden model data:  {args.outdir}/golden_model_meas_constants.py")
    print()
    print("Next steps:")
    print(f"  1. Add testbench to Vivado project and run simulation")
    print(f"  2. Capture output to: {args.outdir}/vhdl_output_real_fpv.txt")
    print(f"  3. Run RMSE: python3 {args.outdir}/compute_rmse_real_fpv.py <vhdl_output>")
    print("=" * 70)

if __name__ == '__main__':
    main()
