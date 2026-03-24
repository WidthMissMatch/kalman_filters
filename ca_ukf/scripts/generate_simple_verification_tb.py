#!/usr/bin/env python3
"""
Generate SIMPLE testbench with CLEAR console output for manual verification

This testbench:
1. Prints measurements to console (so you can verify they match dataset)
2. Prints VHDL outputs to console (so you can verify they're real)
3. Writes outputs to file
"""

import pandas as pd

def generate_simple_testbench(csv_file, output_vhd, num_cycles=10):
    # Read dataset
    df = pd.read_csv(csv_file)
    num_cycles = min(num_cycles, len(df))

    # Extract measurements
    meas_z_x = df['meas_x_q24'].values[:num_cycles]
    meas_z_y = df['meas_y_q24'].values[:num_cycles]
    meas_z_z = df['meas_z_q24'].values[:num_cycles]

    vhdl_code = f'''--------------------------------------------------------------------------------
-- Simple UKF Testbench for Manual Verification
-- Cycles: {num_cycles}
-- Outputs printed to console AND saved to file
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity ukf_simple_verification_tb is
end ukf_simple_verification_tb;

architecture Behavioral of ukf_simple_verification_tb is

    component ukf_supreme_3d is
        port (
            clk, reset, start : in std_logic;
            z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);
            x_pos_current, x_vel_current, x_acc_current : out signed(47 downto 0);
            y_pos_current, y_vel_current, y_acc_current : out signed(47 downto 0);
            z_pos_current, z_vel_current, z_acc_current : out signed(47 downto 0);
            x_pos_uncertainty, x_vel_uncertainty, x_acc_uncertainty : out signed(47 downto 0);
            y_pos_uncertainty, y_vel_uncertainty, y_acc_uncertainty : out signed(47 downto 0);
            z_pos_uncertainty, z_vel_uncertainty, z_acc_uncertainty : out signed(47 downto 0);
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

    constant MEAS_Z_X : meas_array := (
'''

    # Add measurements
    for i, val in enumerate(meas_z_x):
        vhdl_code += f"        to_signed({int(val)}, 48)"
        vhdl_code += "," if i < len(meas_z_x) - 1 else ""
        vhdl_code += "\n"

    vhdl_code += "    );\n\n    constant MEAS_Z_Y : meas_array := (\n"

    for i, val in enumerate(meas_z_y):
        vhdl_code += f"        to_signed({int(val)}, 48)"
        vhdl_code += "," if i < len(meas_z_y) - 1 else ""
        vhdl_code += "\n"

    vhdl_code += "    );\n\n    constant MEAS_Z_Z : meas_array := (\n"

    for i, val in enumerate(meas_z_z):
        vhdl_code += f"        to_signed({int(val)}, 48)"
        vhdl_code += "," if i < len(meas_z_z) - 1 else ""
        vhdl_code += "\n"

    vhdl_code += f'''    );

    constant TOTAL_CYCLES : integer := {num_cycles};
    constant CLK_PERIOD : time := 10 ns;

    file output_file : text;

begin

    uut: ukf_supreme_3d
        port map (
            clk => clk, reset => reset, start => start,
            z_x_meas => z_x_meas, z_y_meas => z_y_meas, z_z_meas => z_z_meas,
            x_pos_current => x_pos_current, x_vel_current => x_vel_current, x_acc_current => x_acc_current,
            y_pos_current => y_pos_current, y_vel_current => y_vel_current, y_acc_current => y_acc_current,
            z_pos_current => z_pos_current, z_vel_current => z_vel_current, z_acc_current => z_acc_current,
            x_pos_uncertainty => x_pos_uncertainty, x_vel_uncertainty => x_vel_uncertainty, x_acc_uncertainty => x_acc_uncertainty,
            y_pos_uncertainty => y_pos_uncertainty, y_vel_uncertainty => y_vel_uncertainty, y_acc_uncertainty => y_acc_uncertainty,
            z_pos_uncertainty => z_pos_uncertainty, z_vel_uncertainty => z_vel_uncertainty, z_acc_uncertainty => z_acc_uncertainty,
            done => done
        );

    clk_process: process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
        variable output_line : line;
    begin
        file_open(output_file, "../test_data/vhdl_outputs_verified.txt", write_mode);
        write(output_line, string'("cycle,x_pos,y_pos,z_pos,x_vel,y_vel,z_vel,x_acc,y_acc,z_acc,z_x_meas,z_y_meas,z_z_meas"));
        writeline(output_file, output_line);

        reset <= '1'; wait for CLK_PERIOD * 5;
        reset <= '0'; wait for CLK_PERIOD * 2;

        report "======================================================================";
        report "UKF SIMPLE VERIFICATION TEST";
        report "Cycles: " & integer'image(TOTAL_CYCLES);
        report "Check console output to verify measurements and results are REAL!";
        report "======================================================================";

        for cycle in 0 to TOTAL_CYCLES-1 loop
            report "====== CYCLE " & integer'image(cycle) & " ======";

            -- Apply measurements
            z_x_meas <= MEAS_Z_X(cycle);
            z_y_meas <= MEAS_Z_Y(cycle);
            z_z_meas <= MEAS_Z_Z(cycle);

            -- PRINT TO CONSOLE so user can verify
            report "INPUT (Q24.24):";
            report "  z_x_meas = " & integer'image(to_integer(MEAS_Z_X(cycle)));
            report "  z_y_meas = " & integer'image(to_integer(MEAS_Z_Y(cycle)));
            report "  z_z_meas = " & integer'image(to_integer(MEAS_Z_Z(cycle)));

            start <= '1'; wait for CLK_PERIOD; start <= '0';

            -- Wait for completion
            for i in 0 to 10000 loop
                if done = '1' then exit; end if;
                wait for CLK_PERIOD;
            end loop;

            if done /= '1' then
                report "ERROR: Timeout!" severity failure;
            end if;

            wait for CLK_PERIOD * 2;

            -- PRINT OUTPUTS TO CONSOLE
            report "OUTPUT (Q24.24):";
            report "  x_pos = " & integer'image(to_integer(x_pos_current));
            report "  y_pos = " & integer'image(to_integer(y_pos_current));
            report "  z_pos = " & integer'image(to_integer(z_pos_current));
            report "  x_vel = " & integer'image(to_integer(x_vel_current));
            report "  y_vel = " & integer'image(to_integer(y_vel_current));
            report "  z_vel = " & integer'image(to_integer(z_vel_current));

            -- Write to file
            write(output_line, integer'image(cycle) & ",");
            write(output_line, integer'image(to_integer(x_pos_current)) & ",");
            write(output_line, integer'image(to_integer(y_pos_current)) & ",");
            write(output_line, integer'image(to_integer(z_pos_current)) & ",");
            write(output_line, integer'image(to_integer(x_vel_current)) & ",");
            write(output_line, integer'image(to_integer(y_vel_current)) & ",");
            write(output_line, integer'image(to_integer(z_vel_current)) & ",");
            write(output_line, integer'image(to_integer(x_acc_current)) & ",");
            write(output_line, integer'image(to_integer(y_acc_current)) & ",");
            write(output_line, integer'image(to_integer(z_acc_current)) & ",");
            write(output_line, integer'image(to_integer(z_x_meas)) & ",");
            write(output_line, integer'image(to_integer(z_y_meas)) & ",");
            write(output_line, integer'image(to_integer(z_z_meas)));
            writeline(output_file, output_line);

            wait for CLK_PERIOD * 5;
        end loop;

        file_close(output_file);
        report "======================================================================";
        report "TEST COMPLETE - Check vhdl_outputs_verified.txt";
        report "======================================================================";

        wait for CLK_PERIOD * 10;
        std.env.stop;
    end process;

end Behavioral;
'''

    with open(output_vhd, 'w') as f:
        f.write(vhdl_code)

    print(f"✅ Testbench generated: {output_vhd}")
    print(f"   Cycles: {num_cycles}")
    print()
    print("This testbench will:")
    print("  1. Print measurements to console (so you can verify they're correct)")
    print("  2. Print VHDL outputs to console (so you can see they're REAL)")
    print("  3. Save outputs to: test_data/vhdl_outputs_verified.txt")
    print()

if __name__ == '__main__':
    generate_simple_testbench(
        '../test_data/constant_velocity_10cycles.csv',
        '../ca_ukf.srcs/sim_1/new/ukf_simple_verification_tb.vhd',
        num_cycles=10
    )
