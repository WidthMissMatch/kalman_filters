#!/usr/bin/env python3
"""
Generate predicti_ctr3d.vhd - Constant Turn Rate prediction model for 3D UKF.

This generates a VHDL entity with the same port interface as predicti_ca3d.vhd
but with '_acc_' renamed to '_omega_' and the motion model changed from
Constant Acceleration to Constant Turn Rate (2nd-order Taylor, no CORDIC).

CTR motion model per sigma point:
  cx = wy*vz - wz*vy       (cross product x)
  cy = wz*vx - wx*vz       (cross product y)
  cz = wx*vy - wy*vx       (cross product z)
  omega_sq = wx^2 + wy^2 + wz^2

  vx' = vx + cx*dt - 0.5*omega_sq*vx*dt^2
  vy' = vy + cy*dt - 0.5*omega_sq*vy*dt^2
  vz' = vz + cz*dt - 0.5*omega_sq*vz*dt^2

  pos' = pos + vel*dt
  omega' = omega  (constant turn rate)

FSM: IDLE -> MULTIPLY_CROSS_VEL -> COMPUTE_CROSS_OMEGASQ -> COMPUTE_CORRECTION -> CALCULATE -> FINISHED
"""

import os

NUM_POINTS = 19
AXES = ['x', 'y', 'z']
STATES = ['pos', 'vel', 'omega']  # 9 states: 3 axes x 3 states each


def sig(i):
    """Return sigma point prefix like 'chi0', 'chi18'."""
    return f"chi{i}"


def gen_port_signals(direction, suffix, sig_type="signed(47 downto 0)"):
    """Generate port signal declarations for all 19 points."""
    lines = []
    for i in range(NUM_POINTS):
        p = sig(i)
        sigs = []
        for ax in AXES:
            for st in STATES:
                sigs.append(f"{p}_{ax}_{st}_{suffix}")
        if i == 0:
            # Point 0: one signal per line for clarity
            for s in sigs:
                lines.append(f"    {s} : {direction} {sig_type};")
        else:
            # Compact: group by axis on one line
            for ax in AXES:
                group = [f"{p}_{ax}_{st}_{suffix}" for st in STATES]
                lines.append(f"    {', '.join(group)} : {direction} {sig_type};")
        lines.append("")
    return lines


def gen_signal_group_96(name_template, comment=""):
    """Generate 96-bit signal declarations for all 19 points.
    name_template is a function(i) -> signal_name."""
    lines = []
    if comment:
        lines.append(f"  -- {comment}")
    # Group signals in batches of 4
    names = [name_template(i) for i in range(NUM_POINTS)]
    for start in range(0, NUM_POINTS, 4):
        batch = names[start:start+4]
        lines.append(f"  signal {', '.join(batch)} : signed(95 downto 0) := (others => '0');")
    return lines


def gen_signal_group_48(name_template, comment=""):
    """Generate 48-bit signal declarations for all 19 points."""
    lines = []
    if comment:
        lines.append(f"  -- {comment}")
    names = [name_template(i) for i in range(NUM_POINTS)]
    for start in range(0, NUM_POINTS, 4):
        batch = names[start:start+4]
        lines.append(f"  signal {', '.join(batch)} : signed(47 downto 0) := (others => '0');")
    return lines


def gen_reset_96(name_template):
    """Generate reset assignments for 96-bit signals."""
    lines = []
    names = [name_template(i) for i in range(NUM_POINTS)]
    for start in range(0, NUM_POINTS, 3):
        batch = names[start:start+3]
        lines.append("      " + " ".join(f"{n} <= (others => '0');" for n in batch))
    return lines


def gen_reset_48(name_template):
    """Generate reset assignments for 48-bit signals."""
    lines = []
    names = [name_template(i) for i in range(NUM_POINTS)]
    for start in range(0, NUM_POINTS, 3):
        batch = names[start:start+3]
        lines.append("      " + " ".join(f"{n} <= (others => '0');" for n in batch))
    return lines


def main():
    L = []  # accumulate lines

    # Header
    L.append("--------------------------------------------------------------------------------")
    L.append("-- 3D Constant Turn Rate Prediction Model")
    L.append("-- Purpose: Predict future state for 19 sigma points using CTR motion model")
    L.append("-- Motion Model (2nd-order Taylor, no CORDIC):")
    L.append("--   cross = omega x vel")
    L.append("--   omega_sq = |omega|^2")
    L.append("--   vel' = vel + cross*dt - 0.5*omega_sq*vel*dt^2")
    L.append("--   pos' = pos + vel*dt")
    L.append("--   omega' = omega  (constant turn rate)")
    L.append("-- Fixed-Point Format: Q24.24")
    L.append("-- Time Step: dt = 20ms (0.02 seconds = 50Hz)")
    L.append("-- Cycle Count: ~6 cycles (more than CA due to cross-product/correction terms)")
    L.append("--------------------------------------------------------------------------------")
    L.append("")
    L.append("library IEEE;")
    L.append("use IEEE.STD_LOGIC_1164.ALL;")
    L.append("use IEEE.NUMERIC_STD.ALL;")
    L.append("")
    L.append("library STD;")
    L.append("use STD.TEXTIO.ALL;")
    L.append("")

    # Entity declaration
    L.append("entity predicti_ctr3d is")
    L.append("  port (")
    L.append("    clk         : in  std_logic;")
    L.append("    rst         : in  std_logic;")
    L.append("    start       : in  std_logic;")
    L.append("")
    L.append("    -- Input sigma points (19 points, 9 states each = 171 inputs)")

    # Input ports
    for i in range(NUM_POINTS):
        p = sig(i)
        L.append(f"    -- Point {i}")
        if i == 0:
            for ax in AXES:
                for st in STATES:
                    L.append(f"    {p}_{ax}_{st}_in : in signed(47 downto 0);{('  -- Q24.24' if st == 'pos' and ax == 'x' else '')}")
        else:
            for ax in AXES:
                group = [f"{p}_{ax}_{st}_in" for st in STATES]
                L.append(f"    {', '.join(group)} : in signed(47 downto 0);")
        L.append("")

    # Output ports
    L.append("    -- Output predicted sigma points (19 points x 9 states = 171 outputs)")
    for i in range(NUM_POINTS):
        p = sig(i)
        L.append(f"    -- Point {i}")
        for ax in AXES:
            group = [f"{p}_{ax}_{st}_pred" for st in STATES]
            L.append(f"    {', '.join(group)} : out signed(47 downto 0);")
        L.append("")

    # Done signal and close entity
    L.append("    -- Control signal")
    L.append("    done        : out std_logic")
    L.append("  );")
    L.append("end entity;")
    L.append("")

    # Architecture
    L.append("architecture Behavioral of predicti_ctr3d is")
    L.append("  -- Time step constants in Q24.24 format")
    L.append("  -- dt = 0.02 seconds (20ms = 50Hz): 0.02 * 2^24 = 335544")
    L.append("  -- dt^2 = 0.0004 seconds^2: 0.0004 * 2^24 = 6711")
    L.append("  -- 0.5 (for 0.5*omega_sq*vel*dt^2): 0.5 * 2^24 = 8388608")
    L.append("  constant DT_Q24_24      : signed(47 downto 0) := to_signed(335544, 48);    -- 0.02s")
    L.append("  constant DT_SQ_Q24_24   : signed(47 downto 0) := to_signed(6711, 48);      -- 0.0004s^2")
    L.append("  constant HALF_Q24_24    : signed(47 downto 0) := to_signed(8388608, 48);   -- 0.5")
    L.append("  constant Q : integer := 24;")
    L.append("")
    L.append("  -- State machine (6 states for CTR model)")
    L.append("  type state_type is (IDLE, MULTIPLY_CROSS_VEL, COMPUTE_CROSS_OMEGASQ, COMPUTE_CORRECTION, CALCULATE, FINISHED);")
    L.append("  signal state : state_type := IDLE;")
    L.append("")

    # -- Internal signal declarations --

    # vel*dt (96-bit) for each axis and point
    for ax in AXES:
        L.extend(gen_signal_group_96(
            lambda i, a=ax: f"{sig(i)}_{a}_vel_dt",
            f"vel*dt for {ax}-axis (96-bit)"))
        L.append("")

    # Cross product sub-term multiplications (96-bit): wy*vz, wz*vy, wz*vx, wx*vz, wx*vy, wy*vx
    cross_terms = [
        ('wy_vz', 'y', 'omega', 'z', 'vel'),
        ('wz_vy', 'z', 'omega', 'y', 'vel'),
        ('wz_vx', 'z', 'omega', 'x', 'vel'),
        ('wx_vz', 'x', 'omega', 'z', 'vel'),
        ('wx_vy', 'x', 'omega', 'y', 'vel'),
        ('wy_vx', 'y', 'omega', 'x', 'vel'),
    ]
    for ct_name, _, _, _, _ in cross_terms:
        L.extend(gen_signal_group_96(
            lambda i, n=ct_name: f"{sig(i)}_{n}",
            f"Cross product sub-term: {ct_name} (96-bit)"))
        L.append("")

    # Omega squared sub-terms (96-bit): wx^2, wy^2, wz^2
    for ax in AXES:
        L.extend(gen_signal_group_96(
            lambda i, a=ax: f"{sig(i)}_w{a}_sq",
            f"omega_{ax}^2 (96-bit)"))
        L.append("")

    # Cross products (48-bit): cx, cy, cz
    for ax in AXES:
        L.extend(gen_signal_group_48(
            lambda i, a=ax: f"{sig(i)}_c{a}",
            f"Cross product c{ax} (48-bit)"))
        L.append("")

    # Omega squared (48-bit)
    L.extend(gen_signal_group_48(
        lambda i: f"{sig(i)}_omega_sq",
        "omega magnitude squared (48-bit)"))
    L.append("")

    # cx*dt, cy*dt, cz*dt (96-bit)
    for ax in AXES:
        L.extend(gen_signal_group_96(
            lambda i, a=ax: f"{sig(i)}_c{a}_dt",
            f"c{ax}*dt (96-bit)"))
        L.append("")

    # omega_sq * vel (96-bit) for each axis
    for ax in AXES:
        L.extend(gen_signal_group_96(
            lambda i, a=ax: f"{sig(i)}_osq_v{a}",
            f"omega_sq * v{ax} (96-bit)"))
        L.append("")

    # omega_sq_vel * dt^2 (96-bit) for each axis -- uses truncated osq_v
    for ax in AXES:
        L.extend(gen_signal_group_96(
            lambda i, a=ax: f"{sig(i)}_osq_v{a}_dtsq",
            f"truncate(omega_sq*v{ax}) * dt^2 (96-bit)"))
        L.append("")

    # Final predicted states (internal, 48-bit)
    for i in range(NUM_POINTS):
        p = sig(i)
        sigs = []
        for ax in AXES:
            for st in STATES:
                sigs.append(f"{p}_{ax}_{st}_pred_int")
        L.append(f"  signal {', '.join(sigs)} : signed(47 downto 0) := (others => '0');")
    L.append("")

    # Begin architecture
    L.append("begin")
    L.append("  -- Main prediction process")
    L.append("  process(clk, rst)")
    L.append("  begin")
    L.append("    if rst = '1' then")
    L.append("      state <= IDLE;")
    L.append("      done <= '0';")
    L.append("")

    # Reset all 96-bit signals
    L.append("      -- Reset vel*dt signals")
    for ax in AXES:
        L.extend(gen_reset_96(lambda i, a=ax: f"{sig(i)}_{a}_vel_dt"))
    L.append("")

    L.append("      -- Reset cross product sub-term signals")
    for ct_name, _, _, _, _ in cross_terms:
        L.extend(gen_reset_96(lambda i, n=ct_name: f"{sig(i)}_{n}"))
    L.append("")

    L.append("      -- Reset omega squared sub-term signals")
    for ax in AXES:
        L.extend(gen_reset_96(lambda i, a=ax: f"{sig(i)}_w{a}_sq"))
    L.append("")

    L.append("      -- Reset cross product signals (48-bit)")
    for ax in AXES:
        L.extend(gen_reset_48(lambda i, a=ax: f"{sig(i)}_c{a}"))
    L.append("")

    L.append("      -- Reset omega_sq signals (48-bit)")
    L.extend(gen_reset_48(lambda i: f"{sig(i)}_omega_sq"))
    L.append("")

    L.append("      -- Reset cx*dt, cy*dt, cz*dt signals")
    for ax in AXES:
        L.extend(gen_reset_96(lambda i, a=ax: f"{sig(i)}_c{a}_dt"))
    L.append("")

    L.append("      -- Reset omega_sq*vel signals")
    for ax in AXES:
        L.extend(gen_reset_96(lambda i, a=ax: f"{sig(i)}_osq_v{a}"))
    L.append("")

    L.append("      -- Reset omega_sq*vel*dt^2 signals")
    for ax in AXES:
        L.extend(gen_reset_96(lambda i, a=ax: f"{sig(i)}_osq_v{a}_dtsq"))
    L.append("")

    L.append("      -- Reset predicted state signals")
    for i in range(NUM_POINTS):
        p = sig(i)
        parts = []
        for ax in AXES:
            for st in STATES:
                parts.append(f"{p}_{ax}_{st}_pred_int <= (others => '0');")
        L.append("      " + " ".join(parts))
    L.append("")

    L.append("    elsif rising_edge(clk) then")
    L.append("      case state is")

    # IDLE state
    L.append("        when IDLE =>")
    L.append("          done <= '0';")
    L.append("          if start = '1' then")
    L.append("            state <= MULTIPLY_CROSS_VEL;")
    L.append("          end if;")
    L.append("")

    # MULTIPLY_CROSS_VEL state
    L.append("        when MULTIPLY_CROSS_VEL =>")
    L.append("          -- Compute vel*dt for all 19 points x 3 axes")
    for ax in AXES:
        for i in range(NUM_POINTS):
            p = sig(i)
            L.append(f"          {p}_{ax}_vel_dt <= {p}_{ax}_vel_in * DT_Q24_24;")
    L.append("")

    L.append("          -- Compute cross product sub-terms (96-bit multiplications)")
    # wy*vz, wz*vy, wz*vx, wx*vz, wx*vy, wy*vx
    cross_mult_map = [
        ('wy_vz', 'y_omega_in', 'z_vel_in'),
        ('wz_vy', 'z_omega_in', 'y_vel_in'),
        ('wz_vx', 'z_omega_in', 'x_vel_in'),
        ('wx_vz', 'x_omega_in', 'z_vel_in'),
        ('wx_vy', 'x_omega_in', 'y_vel_in'),
        ('wy_vx', 'y_omega_in', 'x_vel_in'),
    ]
    for ct_name, op1, op2 in cross_mult_map:
        for i in range(NUM_POINTS):
            p = sig(i)
            L.append(f"          {p}_{ct_name} <= {p}_{op1} * {p}_{op2};")
    L.append("")

    L.append("          -- Compute omega squared sub-terms (96-bit)")
    for ax in AXES:
        for i in range(NUM_POINTS):
            p = sig(i)
            L.append(f"          {p}_w{ax}_sq <= {p}_{ax}_omega_in * {p}_{ax}_omega_in;")
    L.append("")

    L.append("          state <= COMPUTE_CROSS_OMEGASQ;")
    L.append("")

    # COMPUTE_CROSS_OMEGASQ state
    L.append("        when COMPUTE_CROSS_OMEGASQ =>")
    L.append("          -- Compute cross products cx, cy, cz (48-bit) from 96-bit sub-terms")
    # cx = truncate(wy_vz) - truncate(wz_vy)
    # cy = truncate(wz_vx) - truncate(wx_vz)
    # cz = truncate(wx_vy) - truncate(wy_vx)
    cross_defs = [
        ('cx', 'wy_vz', 'wz_vy'),
        ('cy', 'wz_vx', 'wx_vz'),
        ('cz', 'wx_vy', 'wy_vx'),
    ]
    for c_name, pos_term, neg_term in cross_defs:
        for i in range(NUM_POINTS):
            p = sig(i)
            L.append(f"          {p}_{c_name} <= resize(shift_right({p}_{pos_term}, Q), 48) - resize(shift_right({p}_{neg_term}, Q), 48);")
    L.append("")

    L.append("          -- Compute omega_sq = wx^2 + wy^2 + wz^2 (48-bit)")
    for i in range(NUM_POINTS):
        p = sig(i)
        L.append(f"          {p}_omega_sq <= resize(shift_right({p}_wx_sq, Q), 48) + resize(shift_right({p}_wy_sq, Q), 48) + resize(shift_right({p}_wz_sq, Q), 48);")
    L.append("")

    L.append("          -- Compute cx*dt, cy*dt, cz*dt (96-bit)")
    for ax in AXES:
        c = f"c{ax}"
        for i in range(NUM_POINTS):
            p = sig(i)
            L.append(f"          {p}_{c}_dt <= {p}_{c} * DT_Q24_24;")
    L.append("")

    L.append("          -- Compute omega_sq * vel for each axis (96-bit)")
    for ax in AXES:
        for i in range(NUM_POINTS):
            p = sig(i)
            L.append(f"          {p}_osq_v{ax} <= {p}_omega_sq * {p}_{ax}_vel_in;")
    L.append("")

    L.append("          state <= COMPUTE_CORRECTION;")
    L.append("")

    # COMPUTE_CORRECTION state
    L.append("        when COMPUTE_CORRECTION =>")
    L.append("          -- Compute truncate(omega_sq*vel) * dt^2 (96-bit)")
    for ax in AXES:
        for i in range(NUM_POINTS):
            p = sig(i)
            L.append(f"          {p}_osq_v{ax}_dtsq <= resize(shift_right({p}_osq_v{ax}, Q), 48) * DT_SQ_Q24_24;")
    L.append("")

    L.append("          state <= CALCULATE;")
    L.append("")

    # CALCULATE state
    L.append("        when CALCULATE =>")
    L.append("          -- Apply constant turn rate motion model:")
    L.append("          -- pos' = pos + vel*dt")
    L.append("          -- vel' = vel + cross*dt - 0.5*omega_sq*vel*dt^2")
    L.append("          -- omega' = omega (constant turn rate)")
    L.append("")

    for i in range(NUM_POINTS):
        p = sig(i)
        L.append(f"          -- Point {i}")
        for ax in AXES:
            c = f"c{ax}"
            # Position update: pos' = pos + vel*dt
            L.append(f"          {p}_{ax}_pos_pred_int <= {p}_{ax}_pos_in + resize(shift_right({p}_{ax}_vel_dt, Q), 48);")
            # Velocity update: vel' = vel + cx*dt - 0.5*omega_sq*vel*dt^2
            # Pattern matches CA: resize(shift_right(resize(HALF_Q24_24 * osq_vx_dtsq, 96), 2*Q), 48)
            L.append(f"          {p}_{ax}_vel_pred_int <= {p}_{ax}_vel_in + resize(shift_right({p}_{c}_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * {p}_osq_v{ax}_dtsq, 96), 2*Q), 48);")
            # Omega: constant
            L.append(f"          {p}_{ax}_omega_pred_int <= {p}_{ax}_omega_in;")
        L.append("")

    L.append("          state <= FINISHED;")
    L.append("")

    # FINISHED state
    L.append("        when FINISHED =>")
    L.append("          done <= '1';")
    L.append("          if start = '0' then")
    L.append("            state <= IDLE;")
    L.append("          end if;")
    L.append("")
    L.append("        when others =>")
    L.append("          state <= IDLE;")
    L.append("      end case;")
    L.append("    end if;")
    L.append("  end process;")
    L.append("")

    # Output assignments
    L.append("  -- Output assignments (19 points x 9 states = 171 assignments)")
    for i in range(NUM_POINTS):
        p = sig(i)
        L.append(f"  -- Point {i}")
        for ax in AXES:
            for st in STATES:
                L.append(f"  {p}_{ax}_{st}_pred <= {p}_{ax}_{st}_pred_int;")
        L.append("")

    L.append("end architecture;")

    # Write output
    out_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "src", "predicti_ctr3d.vhd")
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, 'w') as f:
        f.write('\n'.join(L) + '\n')
    print(f"Generated: {out_path}")
    print(f"Total lines: {len(L)}")


if __name__ == "__main__":
    main()
