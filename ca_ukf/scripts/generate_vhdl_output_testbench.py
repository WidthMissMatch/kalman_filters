#!/usr/bin/env python3
"""
Generate VHDL testbench that outputs predictions to text file for comparison

Creates testbench that writes VHDL predictions to file in parseable format
"""

import csv
import sys


def generate_output_testbench(measurements, estimates, output_vhd, num_cycles=50):
    """
    Generate VHDL testbench that outputs predictions to file

    Args:
        measurements: List of measurement dicts
        estimates: List of estimate dicts (Python reference)
        output_vhd: Output VHDL file path
        num_cycles: Number of cycles to test
    """
    vhdl_code = f'''--------------------------------------------------------------------------------
-- UKF Testbench with VHDL Output Logging
-- Cycles: {num_cycles}
-- Outputs VHDL predictions to text file for comparison with Python
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity ukf_output_logger_tb is
end ukf_output_logger_tb;

architecture Behavioral of ukf_output_logger_tb is

    component ukf_supreme_3d is
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            start : in  std_logic;
            z_x_meas : in signed(47 downto 0);
            z_y_meas : in signed(47 downto 0);
            z_z_meas : in signed(47 downto 0);
            x_pos_current : out signed(47 downto 0);
            x_vel_current : out signed(47 downto 0);
            x_acc_current : out signed(47 downto 0);
            y_pos_current : out signed(47 downto 0);
            y_vel_current : out signed(47 downto 0);
            y_acc_current : out signed(47 downto 0);
            z_pos_current : out signed(47 downto 0);
            z_vel_current : out signed(47 downto 0);
            z_acc_current : out signed(47 downto 0);
            x_pos_uncertainty : out signed(47 downto 0);
            x_vel_uncertainty : out signed(47 downto 0);
            x_acc_uncertainty : out signed(47 downto 0);
            y_pos_uncertainty : out signed(47 downto 0);
            y_vel_uncertainty : out signed(47 downto 0);
            y_acc_uncertainty : out signed(47 downto 0);
            z_pos_uncertainty : out signed(47 downto 0);
            z_vel_uncertainty : out signed(47 downto 0);
            z_acc_uncertainty : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal start : std_logic := '0';
    signal done : std_logic;

    signal z_x_meas, z_y_meas, z_z_meas : signed(47 downto 0);

    signal x_pos_current, x_vel_current, x_acc_current : signed(47 downto 0);
    signal y_pos_current, y_vel_current, y_acc_current : signed(47 downto 0);
    signal z_pos_current, z_vel_current, z_acc_current : signed(47 downto 0);

    signal x_pos_uncertainty, x_vel_uncertainty, x_acc_uncertainty : signed(47 downto 0);
    signal y_pos_uncertainty, y_vel_uncertainty, y_acc_uncertainty : signed(47 downto 0);
    signal z_pos_uncertainty, z_vel_uncertainty, z_acc_uncertainty : signed(47 downto 0);

    type meas_array is array (0 to {num_cycles-1}) of signed(47 downto 0);
'''

    # Generate measurement arrays
    vhdl_code += f"\n    constant MEAS_Z_X : meas_array := (\n"
    for i, m in enumerate(measurements[:num_cycles]):
        comma = "," if i < num_cycles-1 else ""
        vhdl_code += f"        to_signed({m['z_x']}, 48){comma}\n"
    vhdl_code += "    );\n\n"

    vhdl_code += "    constant MEAS_Z_Y : meas_array := (\n"
    for i, m in enumerate(measurements[:num_cycles]):
        comma = "," if i < num_cycles-1 else ""
        vhdl_code += f"        to_signed({m['z_y']}, 48){comma}\n"
    vhdl_code += "    );\n\n"

    vhdl_code += "    constant MEAS_Z_Z : meas_array := (\n"
    for i, m in enumerate(measurements[:num_cycles]):
        comma = "," if i < num_cycles-1 else ""
        vhdl_code += f"        to_signed({m['z_z']}, 48){comma}\n"
    vhdl_code += "    );\n\n"

    vhdl_code += f'''    constant TOTAL_CYCLES : integer := {num_cycles};
    constant CLK_PERIOD : time := 10 ns;

    -- Output file
    file output_file : text;

begin

    uut: ukf_supreme_3d
        port map (
            clk => clk,
            reset => reset,
            start => start,
            z_x_meas => z_x_meas,
            z_y_meas => z_y_meas,
            z_z_meas => z_z_meas,
            x_pos_current => x_pos_current,
            x_vel_current => x_vel_current,
            x_acc_current => x_acc_current,
            y_pos_current => y_pos_current,
            y_vel_current => y_vel_current,
            y_acc_current => y_acc_current,
            z_pos_current => z_pos_current,
            z_vel_current => z_vel_current,
            z_acc_current => z_acc_current,
            x_pos_uncertainty => x_pos_uncertainty,
            x_vel_uncertainty => x_vel_uncertainty,
            x_acc_uncertainty => x_acc_uncertainty,
            y_pos_uncertainty => y_pos_uncertainty,
            y_vel_uncertainty => y_vel_uncertainty,
            y_acc_uncertainty => y_acc_uncertainty,
            z_pos_uncertainty => z_pos_uncertainty,
            z_vel_uncertainty => z_vel_uncertainty,
            z_acc_uncertainty => z_acc_uncertainty,
            done => done
        );

    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
        variable output_line : line;
    begin
        -- Open output file
        file_open(output_file, "../test_data/vhdl_predictions.txt", write_mode);

        -- Write header
        write(output_line, string'("cycle,x_pos,y_pos,z_pos,x_vel,y_vel,z_vel,x_acc,y_acc,z_acc"));
        writeline(output_file, output_line);

        -- Reset
        reset <= '1';
        wait for CLK_PERIOD * 5;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        report "========================================";
        report "UKF OUTPUT LOGGING TEST";
        report "Total Cycles: " & integer'image(TOTAL_CYCLES);
        report "Output: ../test_data/vhdl_predictions.txt";
        report "========================================";

        -- Run cycles
        for cycle in 0 to TOTAL_CYCLES-1 loop
            report "Cycle " & integer'image(cycle);

            -- Apply measurements
            z_x_meas <= MEAS_Z_X(cycle);
            z_y_meas <= MEAS_Z_Y(cycle);
            z_z_meas <= MEAS_Z_Z(cycle);

            -- Start UKF
            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            -- Wait for completion
            for i in 0 to 10000 loop
                if done = '1' then
                    exit;
                end if;
                wait for CLK_PERIOD;
            end loop;

            if done /= '1' then
                report "ERROR: Cycle timeout!" severity failure;
            end if;

            wait for CLK_PERIOD * 2;

            -- Write output (Q24.24 format)
            write(output_line, integer'image(cycle));
            write(output_line, string'(","));
            write(output_line, integer'image(to_integer(x_pos_current)));
            write(output_line, string'(","));
            write(output_line, integer'image(to_integer(y_pos_current)));
            write(output_line, string'(","));
            write(output_line, integer'image(to_integer(z_pos_current)));
            write(output_line, string'(","));
            write(output_line, integer'image(to_integer(x_vel_current)));
            write(output_line, string'(","));
            write(output_line, integer'image(to_integer(y_vel_current)));
            write(output_line, string'(","));
            write(output_line, integer'image(to_integer(z_vel_current)));
            write(output_line, string'(","));
            write(output_line, integer'image(to_integer(x_acc_current)));
            write(output_line, string'(","));
            write(output_line, integer'image(to_integer(y_acc_current)));
            write(output_line, string'(","));
            write(output_line, integer'image(to_integer(z_acc_current)));
            writeline(output_file, output_line);

            wait for CLK_PERIOD * 5;
        end loop;

        file_close(output_file);

        report "========================================";
        report "OUTPUT LOGGING COMPLETE";
        report "VHDL predictions written to file";
        report "========================================";

        wait for CLK_PERIOD * 10;
        std.env.stop;
    end process;

end Behavioral;
'''

    with open(output_vhd, 'w') as f:
        f.write(vhdl_code)

    print(f"Generated output-logging testbench: {output_vhd}")


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 generate_vhdl_output_testbench.py <reference_csv> [cycles]")
        sys.exit(1)

    csv_file = sys.argv[1]
    num_cycles = int(sys.argv[2]) if len(sys.argv) > 2 else 50
    output_vhd = "../ca_ukf.srcs/sim_1/new/ukf_output_logger_tb.vhd"

    # Read reference CSV
    measurements = []
    estimates = []

    with open(csv_file, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for i, row in enumerate(reader):
            if i >= num_cycles:
                break

            meas = {
                'z_x': int(row['z_x_meas_q24']),
                'z_y': int(row['z_y_meas_q24']),
                'z_z': int(row['z_z_meas_q24'])
            }
            measurements.append(meas)

            est = {
                'x_pos': int(row['est_x_pos_q24']),
                'y_pos': int(row['est_y_pos_q24']),
                'z_pos': int(row['est_z_pos_q24'])
            }
            estimates.append(est)

    generate_output_testbench(measurements, estimates, output_vhd, num_cycles)


if __name__ == "__main__":
    main()
