#!/usr/bin/env python3
"""
Convert Python reference CSV to VHDL testbench with embedded test vectors

Generates a comprehensive VHDL testbench that includes:
- Measurement vectors from Python reference
- Expected state estimates from Python reference
- Tolerance checking and pass/fail reporting
"""

import csv
import sys


def read_reference_csv(filename, max_cycles=20):
    """Read Python reference CSV and extract test vectors"""
    measurements = []
    estimates = []
    covariances = []

    with open(filename, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for i, row in enumerate(reader):
            if i >= max_cycles:
                break

            # Extract measurements (Q24.24 format)
            meas = {
                'z_x': int(row['z_x_meas_q24']),
                'z_y': int(row['z_y_meas_q24']),
                'z_z': int(row['z_z_meas_q24'])
            }
            measurements.append(meas)

            # Extract estimates (Q24.24 format)
            est = {
                'x_pos': int(row['est_x_pos_q24']),
                'x_vel': int(row['est_x_vel_q24']),
                'x_acc': int(row['est_x_acc_q24']),
                'y_pos': int(row['est_y_pos_q24']),
                'y_vel': int(row['est_y_vel_q24']),
                'y_acc': int(row['est_y_acc_q24']),
                'z_pos': int(row['est_z_pos_q24']),
                'z_vel': int(row['est_z_vel_q24']),
                'z_acc': int(row['est_z_acc_q24'])
            }
            estimates.append(est)

            # Extract covariance diagonal (float)
            cov = {
                'p11': float(row['p11']),
                'p44': float(row['p44']),
                'p77': float(row['p77'])
            }
            covariances.append(cov)

    return measurements, estimates, covariances


def generate_vhdl_testbench(measurements, estimates, covariances, output_file):
    """Generate VHDL testbench with embedded test vectors"""

    num_cycles = len(measurements)

    vhdl_code = f'''--------------------------------------------------------------------------------
-- Comprehensive UKF Testbench - Auto-generated from Python reference
-- Cycles: {num_cycles}
-- Compares VHDL UKF output with Python gold model
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ukf_supreme_3d_comprehensive_tb is
end ukf_supreme_3d_comprehensive_tb;

architecture Behavioral of ukf_supreme_3d_comprehensive_tb is

    -- Component declaration
    component ukf_supreme_3d is
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            start : in  std_logic;

            -- Measurements (3D position, Q24.24)
            z_x_meas : in signed(47 downto 0);
            z_y_meas : in signed(47 downto 0);
            z_z_meas : in signed(47 downto 0);

            -- State estimates (9D, Q24.24)
            x_pos_current : out signed(47 downto 0);
            x_vel_current : out signed(47 downto 0);
            x_acc_current : out signed(47 downto 0);
            y_pos_current : out signed(47 downto 0);
            y_vel_current : out signed(47 downto 0);
            y_acc_current : out signed(47 downto 0);
            z_pos_current : out signed(47 downto 0);
            z_vel_current : out signed(47 downto 0);
            z_acc_current : out signed(47 downto 0);

            -- Covariance diagonal (Q24.24)
            x_pos_uncertainty : out signed(47 downto 0);  -- P11
            x_vel_uncertainty : out signed(47 downto 0);  -- P22
            x_acc_uncertainty : out signed(47 downto 0);  -- P33
            y_pos_uncertainty : out signed(47 downto 0);  -- P44
            y_vel_uncertainty : out signed(47 downto 0);  -- P55
            y_acc_uncertainty : out signed(47 downto 0);  -- P66
            z_pos_uncertainty : out signed(47 downto 0);  -- P77
            z_vel_uncertainty : out signed(47 downto 0);  -- P88
            z_acc_uncertainty : out signed(47 downto 0);  -- P99

            done : out std_logic
        );
    end component;

    -- Clock and control signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal start : std_logic := '0';
    signal done : std_logic;

    -- Measurements
    signal z_x_meas, z_y_meas, z_z_meas : signed(47 downto 0);

    -- State estimates
    signal x_pos_current, x_vel_current, x_acc_current : signed(47 downto 0);
    signal y_pos_current, y_vel_current, y_acc_current : signed(47 downto 0);
    signal z_pos_current, z_vel_current, z_acc_current : signed(47 downto 0);

    -- Covariance
    signal x_pos_uncertainty, x_vel_uncertainty, x_acc_uncertainty : signed(47 downto 0);
    signal y_pos_uncertainty, y_vel_uncertainty, y_acc_uncertainty : signed(47 downto 0);
    signal z_pos_uncertainty, z_vel_uncertainty, z_acc_uncertainty : signed(47 downto 0);

    -- Test vectors (measurements in Q24.24)
'''

    # Generate measurement arrays
    vhdl_code += f"    type meas_array is array (0 to {num_cycles-1}) of signed(47 downto 0);\n"

    vhdl_code += "    constant MEAS_Z_X : meas_array := (\n"
    for i, m in enumerate(measurements):
        comma = "," if i < num_cycles-1 else ""
        vhdl_code += f"        to_signed({m['z_x']}, 48){comma}  -- Cycle {i}\n"
    vhdl_code += "    );\n\n"

    vhdl_code += "    constant MEAS_Z_Y : meas_array := (\n"
    for i, m in enumerate(measurements):
        comma = "," if i < num_cycles-1 else ""
        vhdl_code += f"        to_signed({m['z_y']}, 48){comma}\n"
    vhdl_code += "    );\n\n"

    vhdl_code += "    constant MEAS_Z_Z : meas_array := (\n"
    for i, m in enumerate(measurements):
        comma = "," if i < num_cycles-1 else ""
        vhdl_code += f"        to_signed({m['z_z']}, 48){comma}\n"
    vhdl_code += "    );\n\n"

    # Generate expected estimate arrays (for comparison)
    vhdl_code += "    -- Python reference estimates (Q24.24)\n"
    vhdl_code += "    constant REF_X_POS : meas_array := (\n"
    for i, e in enumerate(estimates):
        comma = "," if i < num_cycles-1 else ""
        vhdl_code += f"        to_signed({e['x_pos']}, 48){comma}  -- Cycle {i}\n"
    vhdl_code += "    );\n\n"

    # Continue with other states (y_pos, z_pos for simplicity)
    vhdl_code += "    constant REF_Y_POS : meas_array := (\n"
    for i, e in enumerate(estimates):
        comma = "," if i < num_cycles-1 else ""
        vhdl_code += f"        to_signed({e['y_pos']}, 48){comma}\n"
    vhdl_code += "    );\n\n"

    vhdl_code += "    constant REF_Z_POS : meas_array := (\n"
    for i, e in enumerate(estimates):
        comma = "," if i < num_cycles-1 else ""
        vhdl_code += f"        to_signed({e['z_pos']}, 48){comma}\n"
    vhdl_code += "    );\n\n"

    # Tolerance in Q24.24 (0.5 m = 0.5 * 2^24)
    vhdl_code += f"    constant POS_TOL : signed(47 downto 0) := to_signed({int(0.5 * 2**24)}, 48);  -- 0.5 m tolerance\n"
    vhdl_code += f"    constant TOTAL_CYCLES : integer := {num_cycles};\n\n"

    # Continue with testbench body
    vhdl_code += '''    -- Statistics
    signal passed_cycles : integer := 0;
    signal failed_cycles : integer := 0;

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Unit under test
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

    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus and checking
    stim_proc: process
        variable x_pos_err, y_pos_err, z_pos_err : signed(47 downto 0);
        variable cycle_pass : boolean;
    begin
        -- Reset
        reset <= '1';
        wait for CLK_PERIOD * 5;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        report "========================================";
        report "COMPREHENSIVE UKF VALIDATION";
        report "Comparing VHDL vs Python Reference";
        report "Total Cycles: " & integer'image(TOTAL_CYCLES);
        report "========================================";

        -- Run through all test cycles
        for cycle in 0 to TOTAL_CYCLES-1 loop
            report "----------------------------------------";
            report "Cycle " & integer'image(cycle);

            -- Apply measurements
            z_x_meas <= MEAS_Z_X(cycle);
            z_y_meas <= MEAS_Z_Y(cycle);
            z_z_meas <= MEAS_Z_Z(cycle);

            -- Start UKF
            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            -- Wait for completion (with timeout)
            for i in 0 to 10000 loop
                if done = '1' then
                    exit;
                end if;
                wait for CLK_PERIOD;
            end loop;

            if done /= '1' then
                report "ERROR: Cycle " & integer'image(cycle) & " timeout!" severity failure;
            end if;

            wait for CLK_PERIOD * 2;  -- Let outputs settle

            -- Compare with Python reference
            x_pos_err := abs(x_pos_current - REF_X_POS(cycle));
            y_pos_err := abs(y_pos_current - REF_Y_POS(cycle));
            z_pos_err := abs(z_pos_current - REF_Z_POS(cycle));

            cycle_pass := (x_pos_err < POS_TOL) and (y_pos_err < POS_TOL) and (z_pos_err < POS_TOL);

            if cycle_pass then
                passed_cycles <= passed_cycles + 1;
                report "  Result: PASS";
            else
                failed_cycles <= failed_cycles + 1;
                report "  Result: FAIL";
                report "    x_pos_err = " & integer'image(to_integer(shift_right(x_pos_err, 24)));
                report "    y_pos_err = " & integer'image(to_integer(shift_right(y_pos_err, 24)));
                report "    z_pos_err = " & integer'image(to_integer(shift_right(z_pos_err, 24)));
            end if;

            wait for CLK_PERIOD * 5;
        end loop;

        -- Final summary
        report "========================================";
        report "VALIDATION SUMMARY";
        report "========================================";
        report "Total Cycles:  " & integer'image(TOTAL_CYCLES);
        report "Passed Cycles: " & integer'image(passed_cycles);
        report "Failed Cycles: " & integer'image(failed_cycles);
        report "Pass Rate: " & integer'image((passed_cycles * 100) / TOTAL_CYCLES) & "%";

        if passed_cycles = TOTAL_CYCLES then
            report "========================================";
            report "COMPREHENSIVE TEST: PASS";
            report "========================================";
        else
            report "========================================";
            report "COMPREHENSIVE TEST: FAIL";
            report "========================================";
            report "ERROR: Not all cycles passed!" severity failure;
        end if;

        report "Simulation complete." severity note;
        wait for CLK_PERIOD * 10;
        std.env.stop;
    end process;

end Behavioral;
'''

    # Write to file
    with open(output_file, 'w') as f:
        f.write(vhdl_code)

    print(f"Generated VHDL testbench: {output_file}")
    print(f"Test vectors: {num_cycles} cycles")


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 csv_to_vhdl_testbench.py <reference_csv> [max_cycles] [output_vhd]")
        print("Example: python3 csv_to_vhdl_testbench.py ../test_data/python_reference_9d_ca.csv 20")
        sys.exit(1)

    csv_file = sys.argv[1]
    max_cycles = int(sys.argv[2]) if len(sys.argv) > 2 else 20
    output_file = sys.argv[3] if len(sys.argv) > 3 else "../ca_ukf.srcs/sim_1/new/ukf_supreme_3d_comprehensive_tb.vhd"

    print(f"Reading reference CSV: {csv_file}")
    print(f"Max cycles: {max_cycles}")

    measurements, estimates, covariances = read_reference_csv(csv_file, max_cycles)

    print(f"Loaded {len(measurements)} cycles")
    print(f"Generating VHDL testbench...")

    generate_vhdl_testbench(measurements, estimates, covariances, output_file)

    print("Done!")


if __name__ == "__main__":
    main()
