#!/usr/bin/env python3
"""
Generate GHDL-compatible VHDL testbench for IMM F1 filter.
Reads CSV test data and creates a testbench that:
1. Feeds measurements cycle by cycle
2. Captures fused output and model probabilities
3. Writes results in hex format for RMSE comparison
"""
import csv
import sys
import os
import math

Q_SCALE = 2**24

def to_q24_hex(val):
    """Convert float to Q24.24 hex string (12 chars, 48-bit)."""
    q = int(round(val * Q_SCALE))
    if q < 0:
        q += (1 << 48)
    return f'X"{q & 0xFFFFFFFFFFFF:012X}"'

def to_q24_signed(val):
    """Convert float to Q24.24 signed integer string."""
    q = int(round(val * Q_SCALE))
    return f'to_signed({q}, 48)'

def generate_testbench(csv_path, tb_name, max_cycles=None):
    """Generate testbench VHDL from CSV data."""
    # Load data
    measurements = []
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            measurements.append({
                'cycle': int(row['cycle']),
                'meas_x': float(row['meas_x']),
                'meas_y': float(row['meas_y']),
                'meas_z': float(row['meas_z']),
            })

    if max_cycles:
        measurements = measurements[:max_cycles]
    n_cycles = len(measurements)

    tb = []
    tb.append(f'-- Auto-generated IMM F1 testbench: {tb_name}')
    tb.append(f'-- Dataset: {os.path.basename(csv_path)}, {n_cycles} cycles')
    tb.append('library IEEE;')
    tb.append('use IEEE.STD_LOGIC_1164.ALL;')
    tb.append('use IEEE.NUMERIC_STD.ALL;')
    tb.append('use STD.TEXTIO.ALL;')
    tb.append('use IEEE.STD_LOGIC_TEXTIO.ALL;')
    tb.append('')
    tb.append(f'entity {tb_name} is')
    tb.append(f'end {tb_name};')
    tb.append('')
    tb.append(f'architecture Behavioral of {tb_name} is')
    tb.append('')
    tb.append('  component imm_f1_top is')
    tb.append('    port (')
    tb.append('      clk, reset, start : in std_logic;')
    tb.append('      z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);')
    tb.append('      px_out, py_out, pz_out : out signed(47 downto 0);')
    tb.append('      prob_ca_out, prob_singer_out, prob_bike_out : out signed(47 downto 0);')
    tb.append('      done : out std_logic')
    tb.append('    );')
    tb.append('  end component;')
    tb.append('')
    tb.append('  signal clk, reset, start, done_sig : std_logic := \'0\';')
    tb.append('  signal z_x, z_y, z_z : signed(47 downto 0) := (others => \'0\');')
    tb.append('  signal px, py, pz : signed(47 downto 0);')
    tb.append('  signal p_ca, p_si, p_bi : signed(47 downto 0);')
    tb.append('  constant CLK_PERIOD : time := 10 ns;')
    tb.append('')
    tb.append('  -- Measurement data array')
    tb.append(f'  constant N_CYCLES : integer := {n_cycles};')
    tb.append('  type meas_array_t is array (0 to N_CYCLES-1) of signed(47 downto 0);')
    tb.append('')

    # Generate measurement arrays
    for axis, field in [('x', 'meas_x'), ('y', 'meas_y'), ('z', 'meas_z')]:
        tb.append(f'  constant MEAS_{axis.upper()} : meas_array_t := (')
        lines = []
        for i, m in enumerate(measurements):
            comma = ',' if i < n_cycles - 1 else ''
            lines.append(f'    {i} => signed\'({to_q24_hex(m[field])}){comma}')
        tb.extend(lines)
        tb.append('  );')
        tb.append('')

    tb.append('  -- hex output procedure')
    tb.append('  procedure hwrite48(variable L : inout line; val : in signed(47 downto 0)) is')
    tb.append('    variable uval : unsigned(47 downto 0);')
    tb.append('  begin')
    tb.append('    uval := unsigned(val);')
    tb.append('    hwrite(L, std_logic_vector(uval));')
    tb.append('  end procedure;')
    tb.append('')
    tb.append('begin')
    tb.append('')
    tb.append('  -- DUT')
    tb.append('  dut : imm_f1_top port map (')
    tb.append('    clk => clk, reset => reset, start => start,')
    tb.append('    z_x_meas => z_x, z_y_meas => z_y, z_z_meas => z_z,')
    tb.append('    px_out => px, py_out => py, pz_out => pz,')
    tb.append('    prob_ca_out => p_ca, prob_singer_out => p_si, prob_bike_out => p_bi,')
    tb.append('    done => done_sig')
    tb.append('  );')
    tb.append('')
    tb.append('  -- Clock')
    tb.append('  clk_proc : process')
    tb.append('  begin')
    tb.append('    clk <= \'0\'; wait for CLK_PERIOD/2;')
    tb.append('    clk <= \'1\'; wait for CLK_PERIOD/2;')
    tb.append('  end process;')
    tb.append('')
    tb.append('  -- Stimulus')
    tb.append('  stim_proc : process')
    tb.append('    variable L : line;')
    tb.append('    file out_file : text open write_mode is "imm_vhdl_output.txt";')
    tb.append('  begin')
    tb.append('    -- Reset')
    tb.append('    reset <= \'1\';')
    tb.append('    wait for CLK_PERIOD * 5;')
    tb.append('    reset <= \'0\';')
    tb.append('    wait for CLK_PERIOD * 2;')
    tb.append('')
    tb.append('    -- Run cycles')
    tb.append('    for i in 0 to N_CYCLES-1 loop')
    tb.append('      z_x <= MEAS_X(i);')
    tb.append('      z_y <= MEAS_Y(i);')
    tb.append('      z_z <= MEAS_Z(i);')
    tb.append('')
    tb.append('      start <= \'1\';')
    tb.append('      wait for CLK_PERIOD;')
    tb.append('      start <= \'0\';')
    tb.append('')
    tb.append('      -- Wait for done')
    tb.append('      wait until done_sig = \'1\' for 200 us;')
    tb.append('')
    tb.append('      -- Write output')
    tb.append('      write(L, string\'("Cycle "));')
    tb.append('      write(L, i);')
    tb.append('      write(L, string\'(": imm_x=0x"));')
    tb.append('      hwrite48(L, px);')
    tb.append('      write(L, string\'(" imm_y=0x"));')
    tb.append('      hwrite48(L, py);')
    tb.append('      write(L, string\'(" imm_z=0x"));')
    tb.append('      hwrite48(L, pz);')
    tb.append('      writeline(out_file, L);')
    tb.append('')
    tb.append('      wait for CLK_PERIOD * 5;')
    tb.append('    end loop;')
    tb.append('')
    tb.append('    report "IMM simulation complete after " & integer\'image(N_CYCLES) & " cycles";')
    tb.append('    wait;')
    tb.append('  end process;')
    tb.append('')
    tb.append('end Behavioral;')

    return '\n'.join(tb)


def main():
    base = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.join(base, '..', '..')
    tb_dir = os.path.join(base, '..', 'testbenches')

    datasets = [
        ('synthetic_drone_500cycles.csv', 'imm_f1_drone_tb', 500),
        ('f1_monaco_2024_750cycles.csv', 'imm_f1_monaco_tb', 750),
        ('f1_silverstone_2024_750cycles.csv', 'imm_f1_silverstone_tb', 750),
    ]

    for csv_name, tb_name, max_cy in datasets:
        csv_path = os.path.join(project_root, 'ca_ukf/test_data/real_world', csv_name)
        if not os.path.exists(csv_path):
            print(f"Skipping {csv_name}: not found")
            continue

        tb_code = generate_testbench(csv_path, tb_name, max_cy)
        out_path = os.path.join(tb_dir, f'{tb_name}.vhd')
        with open(out_path, 'w') as f:
            f.write(tb_code)
        print(f"Generated: {out_path} ({max_cy} cycles)")

if __name__ == '__main__':
    main()
