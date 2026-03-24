#!/usr/bin/env python3
"""
Generate VHDL Testbench for Bicycle UKF
Creates testbenches that write cycle-by-cycle results to files
Uses hwrite (hex) for 48-bit values to avoid to_integer overflow
"""

import numpy as np
import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR.parent / "ca_ukf" / "test_data" / "real_world"
TB_OUTPUT_DIR = BASE_DIR / "testbenches"

Q_SCALE = 2**24

DATASETS = {
    "synthetic_drone_500cycles": {
        "file": "synthetic_drone_500cycles.csv",
        "cycles": 500,
    },
    "f1_monaco_2024_750cycles": {
        "file": "f1_monaco_2024_750cycles.csv",
        "cycles": 750,
    },
    "f1_silverstone_2024_750cycles": {
        "file": "f1_silverstone_2024_750cycles.csv",
        "cycles": 750,
    },
}


def estimate_initial_state(df, n_init=3, dt=0.02):
    """Estimate initial heading and velocity from first n_init+1 measurements."""
    dx_total = 0.0
    dy_total = 0.0
    n = min(n_init, len(df) - 1)
    for i in range(n):
        dx_total += df.iloc[i+1]["meas_x"] - df.iloc[i]["meas_x"]
        dy_total += df.iloc[i+1]["meas_y"] - df.iloc[i]["meas_y"]
    dx_avg = dx_total / n
    dy_avg = dy_total / n
    theta0 = np.arctan2(dy_avg, dx_avg)
    v0 = np.sqrt(dx_avg**2 + dy_avg**2) / dt
    return v0, theta0


def generate_testbench(dataset_name: str):
    info = DATASETS[dataset_name]
    csv_path = DATA_DIR / info["file"]
    num_cycles = info["cycles"]

    df = pd.read_csv(csv_path)
    df = df.head(num_cycles)

    safe_name = dataset_name.replace("-", "_")
    output_file = f"vhdl_output_{safe_name}.txt"

    # Compute initial velocity and heading
    v0, theta0 = estimate_initial_state(df, n_init=3)
    v0_q24 = int(round(v0 * Q_SCALE))
    theta0_q24 = int(round(theta0 * Q_SCALE))

    def to_hex48(val):
        if val < 0:
            val = val + (1 << 48)
        return f'x"{val:012X}"'

    v_init_hex = to_hex48(v0_q24)
    theta_init_hex = to_hex48(theta0_q24)
    print(f"  Initial v0={v0:.4f} m/s (Q24={v0_q24}), theta0={np.degrees(theta0):.1f}° (Q24={theta0_q24})")

    # Build measurement arrays using hex literals for safety
    meas_lines = []
    gt_lines = []
    for _, row in df.iterrows():
        mx = int(row["meas_x_q24"])
        my = int(row["meas_y_q24"])
        mz = int(row["meas_z_q24"])

        # Convert to hex for 48-bit safety (avoid to_signed overflow)
        def to_hex48(val):
            if val < 0:
                val = val + (1 << 48)
            return f'x"{val:012X}"'

        meas_lines.append(f'        (signed\'({to_hex48(mx)}), signed\'({to_hex48(my)}), signed\'({to_hex48(mz)}))')

        gx = row["gt_x_pos"]
        gy = row["gt_y_pos"]
        gz = row["gt_z_pos"]
        gt_lines.append(f"        -- GT: ({gx:.6f}, {gy:.6f}, {gz:.6f})")

    meas_str = ",\n".join(
        f"{gt_lines[i]}\n{meas_lines[i]}" for i in range(len(meas_lines))
    )

    tb_code = f"""--------------------------------------------------------------------------------
-- Bicycle UKF Testbench with File Output
-- Auto-generated from: {dataset_name}
-- Cycles: {num_cycles}
-- Output: {output_file}
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity bicycle_ukf_{safe_name}_tb is
end entity bicycle_ukf_{safe_name}_tb;

architecture behavioral of bicycle_ukf_{safe_name}_tb is

    component bicycle_ukf_supreme is
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            start : in  std_logic;
            v_init     : in signed(47 downto 0);
            theta_init : in signed(47 downto 0);
            z_x_meas : in signed(47 downto 0);
            z_y_meas : in signed(47 downto 0);
            z_z_meas : in signed(47 downto 0);
            px_current    : out signed(47 downto 0);
            py_current    : out signed(47 downto 0);
            v_current     : out signed(47 downto 0);
            theta_current : out signed(47 downto 0);
            delta_current : out signed(47 downto 0);
            a_current     : out signed(47 downto 0);
            z_current     : out signed(47 downto 0);
            p11_diag : out signed(47 downto 0);
            p22_diag : out signed(47 downto 0);
            p33_diag : out signed(47 downto 0);
            p44_diag : out signed(47 downto 0);
            p55_diag : out signed(47 downto 0);
            p66_diag : out signed(47 downto 0);
            p77_diag : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    -- Clock and control
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal start : std_logic := '0';
    signal done  : std_logic;

    -- Measurements
    signal z_x_meas, z_y_meas, z_z_meas : signed(47 downto 0) := (others => '0');

    -- State outputs
    signal px_out, py_out, v_out, theta_out, delta_out, a_out, z_out : signed(47 downto 0);

    -- Covariance diagonal
    signal p11_out, p22_out, p33_out, p44_out, p55_out, p66_out, p77_out : signed(47 downto 0);

    constant CLK_PERIOD : time := 10 ns;
    constant NUM_CYCLES : integer := {num_cycles};

    -- Measurement data: (meas_x, meas_y, meas_z) in Q24.24
    type meas_triple is array(0 to 2) of signed(47 downto 0);
    type meas_data_array is array(0 to NUM_CYCLES-1) of meas_triple;

    constant MEAS_DATA : meas_data_array := (
{meas_str}
    );

begin

    -- Clock generation
    clk <= not clk after CLK_PERIOD / 2;

    -- UUT instantiation
    uut : bicycle_ukf_supreme
        port map (
            clk => clk, reset => reset, start => start,
            v_init => signed'({v_init_hex}), theta_init => signed'({theta_init_hex}),
            z_x_meas => z_x_meas, z_y_meas => z_y_meas, z_z_meas => z_z_meas,
            px_current => px_out, py_current => py_out, v_current => v_out,
            theta_current => theta_out, delta_current => delta_out,
            a_current => a_out, z_current => z_out,
            p11_diag => p11_out, p22_diag => p22_out, p33_diag => p33_out,
            p44_diag => p44_out, p55_diag => p55_out, p66_diag => p66_out,
            p77_diag => p77_out,
            done => done
        );

    -- Stimulus and file output
    stim_proc : process
        file output_file : text;
        variable line_buf : line;
        variable hex_val : std_logic_vector(47 downto 0);
    begin
        -- Reset
        reset <= '1';
        wait for CLK_PERIOD * 5;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        -- Open output file
        file_open(output_file, "{output_file}", write_mode);

        -- Header
        write(line_buf, string'("cycle,px_hex,py_hex,v_hex,theta_hex,delta_hex,a_hex,z_hex,p11_hex,p22_hex,p33_hex,p44_hex,p55_hex,p66_hex,p77_hex"));
        writeline(output_file, line_buf);

        for i in 0 to NUM_CYCLES - 1 loop
            -- Load measurement
            z_x_meas <= MEAS_DATA(i)(0);
            z_y_meas <= MEAS_DATA(i)(1);
            z_z_meas <= MEAS_DATA(i)(2);

            -- Start cycle
            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            -- Wait for done
            wait until done = '1';
            wait for CLK_PERIOD;

            -- Write results in hex to avoid 32-bit overflow
            write(line_buf, integer'image(i));
            write(line_buf, string'(","));

            hex_val := std_logic_vector(px_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(py_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(v_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(theta_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(delta_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(a_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(z_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p11_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p22_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p33_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p44_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p55_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p66_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p77_out);
            hwrite(line_buf, hex_val);

            writeline(output_file, line_buf);

            -- Report progress
            if (i mod 50 = 0) or (i = NUM_CYCLES - 1) then
                report "Bicycle-UKF Cycle " & integer'image(i) & "/" & integer'image(NUM_CYCLES - 1) & " complete";
            end if;

            wait for CLK_PERIOD;
        end loop;

        file_close(output_file);
        report "=== BICYCLE-UKF SIMULATION COMPLETE ===" &
               " Dataset: {dataset_name}" &
               " Cycles: " & integer'image(NUM_CYCLES);

        wait for CLK_PERIOD * 10;
        std.env.stop;
    end process;

end behavioral;
"""

    TB_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    tb_path = TB_OUTPUT_DIR / f"bicycle_ukf_{safe_name}_tb.vhd"
    tb_path.write_text(tb_code)
    print(f"Generated: {tb_path}")
    print(f"  Cycles: {num_cycles}")


if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1:
        dataset = sys.argv[1]
    else:
        dataset = "synthetic_drone_500cycles"

    if dataset == "all":
        for name in DATASETS:
            generate_testbench(name)
    else:
        generate_testbench(dataset)
