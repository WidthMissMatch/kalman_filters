#!/usr/bin/env python3
"""Convert Abu Dhabi Verstappen Excel to CSV + generate VHDL testbench arrays."""
import sys
try:
    import openpyxl
except ImportError:
    print("Installing openpyxl...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "openpyxl", "-q"])
    import openpyxl

import csv, struct

EXCEL_PATH = "/home/arunupscee/Desktop/xtortion/collection/Max_Verstappen_Abu_Dhabi_6_Laps.xlsx"
CSV_PATH = "/home/arunupscee/Desktop/xtortion/collection/imm_friend/test_data/abu_dhabi_verstappen_4173cycles.csv"
TB_PATH = "/home/arunupscee/Desktop/xtortion/collection/imm_friend/testbenches/imm_friend_abu_dhabi_4173_tb.vhd"

Q = 24
SCALE = 2**Q

def float_to_q24_hex(val):
    """Convert float to Q24.24 48-bit hex string."""
    raw = int(round(val * SCALE))
    # Clamp to 48-bit signed range
    if raw > 2**47 - 1:
        raw = 2**47 - 1
    if raw < -(2**47):
        raw = -(2**47)
    # Convert to unsigned for hex
    if raw < 0:
        raw += 2**48
    return f"{raw:012X}"

def main():
    wb = openpyxl.load_workbook(EXCEL_PATH, read_only=True)
    ws = wb.active

    rows = list(ws.iter_rows(min_row=2, values_only=True))
    print(f"Read {len(rows)} rows from Excel")

    # Headers: Lap, Time, Speed_kmh, RPM, Gear, Throttle, Brake, meas_x, meas_y, meas_z
    # Time is in fractional days for Excel, convert to seconds
    # Check first few times
    times_raw = [r[1] for r in rows[:5]]
    print(f"First 5 raw times: {times_raw}")

    # Detect time format
    if isinstance(times_raw[0], (int, float)) and times_raw[0] < 1:
        # Fractional days
        time_scale = 86400.0
        print("Time format: fractional days → converting to seconds")
    elif isinstance(times_raw[0], (int, float)) and times_raw[0] > 100:
        # Already in seconds
        time_scale = 1.0
        print("Time format: already in seconds")
    else:
        # Try as-is
        time_scale = 1.0
        print(f"Time format: unknown, using as-is")

    # Extract data
    data = []
    for i, r in enumerate(rows):
        lap, t, speed, rpm, gear, throttle, brake, mx, my, mz = r
        if t is None or mx is None:
            continue
        t_sec = float(t) * time_scale if isinstance(t, (int, float)) else 0.0
        data.append({
            'cycle': i,
            'time': t_sec,
            'gt_x_pos': float(mx),
            'gt_y_pos': float(my),
            'gt_z_pos': float(mz),
            'meas_x': float(mx),
            'meas_y': float(my),
            'meas_z': float(mz),
        })

    n = len(data)
    print(f"Valid data points: {n}")
    print(f"Time range: {data[0]['time']:.3f} to {data[-1]['time']:.3f} seconds")
    print(f"X range: {min(d['meas_x'] for d in data):.1f} to {max(d['meas_x'] for d in data):.1f}")
    print(f"Y range: {min(d['meas_y'] for d in data):.1f} to {max(d['meas_y'] for d in data):.1f}")
    print(f"Z range: {min(d['meas_z'] for d in data):.1f} to {max(d['meas_z'] for d in data):.1f}")

    # Write CSV
    with open(CSV_PATH, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['cycle','time','gt_x_pos','gt_y_pos','gt_z_pos','meas_x','meas_y','meas_z','meas_x_q24','meas_y_q24','meas_z_q24'])
        for d in data:
            writer.writerow([
                d['cycle'], f"{d['time']:.6f}",
                f"{d['gt_x_pos']:.6f}", f"{d['gt_y_pos']:.6f}", f"{d['gt_z_pos']:.6f}",
                f"{d['meas_x']:.6f}", f"{d['meas_y']:.6f}", f"{d['meas_z']:.6f}",
                float_to_q24_hex(d['meas_x']),
                float_to_q24_hex(d['meas_y']),
                float_to_q24_hex(d['meas_z']),
            ])
    print(f"\nCSV written: {CSV_PATH}")

    # Generate VHDL testbench
    generate_testbench(data, n)
    print(f"Testbench written: {TB_PATH}")

def generate_testbench(data, n):
    """Generate VHDL testbench with measurement arrays."""
    with open(TB_PATH, 'w') as f:
        f.write(f"""-- IMM Friend (Singer+CTRA+Bicycle) Abu Dhabi Verstappen {n}-cycle testbench
-- Output: namo.txt (hex format)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity imm_friend_abu_dhabi_{n}_tb is
end imm_friend_abu_dhabi_{n}_tb;

architecture Behavioral of imm_friend_abu_dhabi_{n}_tb is

  component imm_friend_top is
    port (
      clk, reset, start : in std_logic;
      z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);
      px_out, py_out, pz_out : out signed(47 downto 0);
      prob_ctra_out, prob_singer_out, prob_bike_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  signal clk, reset, start, done_sig : std_logic := '0';
  signal z_x, z_y, z_z : signed(47 downto 0) := (others => '0');
  signal px, py, pz : signed(47 downto 0);
  signal p_ct, p_si, p_bi : signed(47 downto 0);
  constant CLK_PERIOD : time := 10 ns;

  -- Measurement data array
  constant N_CYCLES : integer := {n};
  type meas_array_t is array (0 to N_CYCLES-1) of signed(47 downto 0);

""")
        # Write MEAS_X array
        f.write("  constant MEAS_X : meas_array_t := (\n")
        for i, d in enumerate(data):
            hx = float_to_q24_hex(d['meas_x'])
            comma = "," if i < n-1 else ""
            f.write(f'    {i} => signed\'(X"{hx}"){comma}\n')
        f.write("  );\n\n")

        # Write MEAS_Y array
        f.write("  constant MEAS_Y : meas_array_t := (\n")
        for i, d in enumerate(data):
            hy = float_to_q24_hex(d['meas_y'])
            comma = "," if i < n-1 else ""
            f.write(f'    {i} => signed\'(X"{hy}"){comma}\n')
        f.write("  );\n\n")

        # Write MEAS_Z array
        f.write("  constant MEAS_Z : meas_array_t := (\n")
        for i, d in enumerate(data):
            hz = float_to_q24_hex(d['meas_z'])
            comma = "," if i < n-1 else ""
            f.write(f'    {i} => signed\'(X"{hz}"){comma}\n')
        f.write("  );\n\n")

        # Write the rest of the testbench
        f.write("""  -- hex output procedure
  procedure hwrite48(variable L : inout line; val : in signed(47 downto 0)) is
    variable uval : unsigned(47 downto 0);
  begin
    uval := unsigned(val);
    hwrite(L, std_logic_vector(uval));
  end procedure;

begin

  -- DUT
  dut : imm_friend_top port map (
    clk => clk, reset => reset, start => start,
    z_x_meas => z_x, z_y_meas => z_y, z_z_meas => z_z,
    px_out => px, py_out => py, pz_out => pz,
    prob_ctra_out => p_ct, prob_singer_out => p_si, prob_bike_out => p_bi,
    done => done_sig
  );

  -- Clock
  clk_proc : process
  begin
    clk <= '0'; wait for CLK_PERIOD/2;
    clk <= '1'; wait for CLK_PERIOD/2;
  end process;

  -- Stimulus
  stim_proc : process
    variable L : line;
    file out_file : text open write_mode is "namo.txt";
  begin
    -- Reset
    reset <= '1';
    wait for CLK_PERIOD * 5;
    reset <= '0';
    wait for CLK_PERIOD * 2;

    -- Run cycles
    for i in 0 to N_CYCLES-1 loop
      z_x <= MEAS_X(i);
      z_y <= MEAS_Y(i);
      z_z <= MEAS_Z(i);

      start <= '1';
      wait for CLK_PERIOD;
      start <= '0';

      -- Wait for done with timeout
      wait until done_sig = '1' for 200 us;

      if done_sig /= '1' then
        write(L, string'("Cycle "));
        write(L, i);
        write(L, string'(": TIMEOUT"));
        writeline(out_file, L);
      else
        -- Write hex output
        write(L, string'("Cycle "));
        write(L, i);
        write(L, string'(": imm_x=0x"));
        hwrite48(L, px);
        write(L, string'(" imm_y=0x"));
        hwrite48(L, py);
        write(L, string'(" imm_z=0x"));
        hwrite48(L, pz);
        write(L, string'(" p_ct=0x"));
        hwrite48(L, p_ct);
        write(L, string'(" p_si=0x"));
        hwrite48(L, p_si);
        write(L, string'(" p_bi=0x"));
        hwrite48(L, p_bi);
        writeline(out_file, L);
      end if;

      wait for CLK_PERIOD * 5;
    end loop;

    report "IMM FRIEND Abu Dhabi simulation complete after " & integer'image(N_CYCLES) & " cycles";
    wait;
  end process;

end Behavioral;
""")

if __name__ == '__main__':
    main()
