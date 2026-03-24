#!/usr/bin/env python3
"""
Generate VHDL Testbench for CT Polar UKF
Creates testbenches that write cycle-by-cycle results to files
Uses hwrite (hex) for 48-bit values to avoid to_integer overflow
9-state: [px, py, v, theta, omega, a, z, vz, az]
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


def generate_testbench(dataset_name: str):
    info = DATASETS[dataset_name]
    csv_path = DATA_DIR / info["file"]
    num_cycles = info["cycles"]

    df = pd.read_csv(csv_path)
    df = df.head(num_cycles)

    safe_name = dataset_name.replace("-", "_")
    output_file = f"vhdl_output_{safe_name}.txt"

    # Build measurement arrays
    meas_lines = []
    gt_lines = []
    for _, row in df.iterrows():
        mx = int(row["meas_x_q24"])
        my = int(row["meas_y_q24"])
        mz = int(row["meas_z_q24"])
        # Use hex literals to avoid 32-bit integer overflow in to_signed()
        def to_hex48(v):
            if v < 0:
                v = v + (1 << 48)
            return f'signed\'(x"{v:012X}")'
        meas_lines.append(f'        ({to_hex48(mx)}, {to_hex48(my)}, {to_hex48(mz)})')

        gx = row["gt_x_pos"]
        gy = row["gt_y_pos"]
        gz = row["gt_z_pos"]
        gt_lines.append(f"        -- GT: ({gx:.6f}, {gy:.6f}, {gz:.6f})")

    meas_str = ",\n".join(
        f"{gt_lines[i]}\n{meas_lines[i]}" for i in range(len(meas_lines))
    )

    tb_code = f"""--------------------------------------------------------------------------------
-- CT Polar UKF Testbench with File Output
-- Auto-generated from: {dataset_name}
-- Cycles: {num_cycles}
-- Output: {output_file}
-- 9-state: [px, py, v, theta, omega, a, z, vz, az]
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity ct_polar_ukf_{safe_name}_tb is
end entity ct_polar_ukf_{safe_name}_tb;

architecture behavioral of ct_polar_ukf_{safe_name}_tb is

    component ct_polar_ukf_supreme is
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            start : in  std_logic;
            z_x_meas : in signed(47 downto 0);
            z_y_meas : in signed(47 downto 0);
            z_z_meas : in signed(47 downto 0);
            px_current    : out signed(47 downto 0);
            py_current    : out signed(47 downto 0);
            v_current     : out signed(47 downto 0);
            theta_current : out signed(47 downto 0);
            omega_current : out signed(47 downto 0);
            a_current     : out signed(47 downto 0);
            z_current     : out signed(47 downto 0);
            vz_current    : out signed(47 downto 0);
            az_current    : out signed(47 downto 0);
            p11_diag : out signed(47 downto 0);
            p22_diag : out signed(47 downto 0);
            p33_diag : out signed(47 downto 0);
            p44_diag : out signed(47 downto 0);
            p55_diag : out signed(47 downto 0);
            p66_diag : out signed(47 downto 0);
            p77_diag : out signed(47 downto 0);
            p88_diag : out signed(47 downto 0);
            p99_diag : out signed(47 downto 0);
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

    -- State outputs (9 states)
    signal px_out, py_out, v_out, theta_out, omega_out, a_out, z_out : signed(47 downto 0);
    signal vz_out, az_out : signed(47 downto 0);

    -- Covariance diagonal (9 elements)
    signal p11_out, p22_out, p33_out, p44_out, p55_out : signed(47 downto 0);
    signal p66_out, p77_out, p88_out, p99_out : signed(47 downto 0);

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
    uut : ct_polar_ukf_supreme
        port map (
            clk => clk, reset => reset, start => start,
            z_x_meas => z_x_meas, z_y_meas => z_y_meas, z_z_meas => z_z_meas,
            px_current => px_out, py_current => py_out, v_current => v_out,
            theta_current => theta_out, omega_current => omega_out,
            a_current => a_out, z_current => z_out,
            vz_current => vz_out, az_current => az_out,
            p11_diag => p11_out, p22_diag => p22_out, p33_diag => p33_out,
            p44_diag => p44_out, p55_diag => p55_out, p66_diag => p66_out,
            p77_diag => p77_out, p88_diag => p88_out, p99_diag => p99_out,
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
        write(line_buf, string'("cycle,px_hex,py_hex,v_hex,theta_hex,omega_hex,a_hex,z_hex,vz_hex,az_hex,p11_hex,p22_hex,p33_hex,p44_hex,p55_hex,p66_hex,p77_hex,p88_hex,p99_hex"));
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

            -- 9 state values
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

            hex_val := std_logic_vector(omega_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(a_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(z_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(vz_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(az_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            -- 9 covariance diagonal values
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
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p88_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p99_out);
            hwrite(line_buf, hex_val);

            writeline(output_file, line_buf);

            -- Report progress
            if (i mod 50) = 0 then
                report "CT Polar UKF cycle " & integer'image(i) & " of " & integer'image(NUM_CYCLES) & " complete"
                    severity note;
            end if;

            wait for CLK_PERIOD * 2;
        end loop;

        file_close(output_file);
        report "CT Polar UKF simulation complete. Output: {output_file}" severity note;
        wait;
    end process;

end behavioral;
"""

    TB_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    tb_path = TB_OUTPUT_DIR / f"ct_polar_ukf_{safe_name}_tb.vhd"
    tb_path.write_text(tb_code)
    print(f"Generated: {tb_path}")
    print(f"  Cycles: {num_cycles}")
    print(f"  Output file: {output_file}")


def main():
    for name in DATASETS:
        try:
            generate_testbench(name)
        except FileNotFoundError as e:
            print(f"Warning: Skipping {name} - {e}")
        except Exception as e:
            print(f"Error generating {name}: {e}")


if __name__ == "__main__":
    main()
