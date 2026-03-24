#!/usr/bin/env python3
"""
Generate VHDL testbench that outputs PREDICTIONS (before update) and UPDATED states

CRITICAL: This testbench outputs:
1. PREDICTION (x_pred) - The one-step-ahead prediction BEFORE seeing measurement
2. MEASUREMENT (z) - The actual measurement received
3. UPDATED (x_updated) - The state AFTER incorporating measurement

This allows verification of PREDICTION accuracy specifically.
"""

import pandas as pd

def generate_prediction_testbench(csv_file, output_vhd, num_cycles=10):
    """Generate testbench with prediction output"""

    # Read dataset
    df = pd.read_csv(csv_file)
    num_cycles = min(num_cycles, len(df))

    # Extract measurements (Q24.24 format)
    meas_z_x = df['meas_x_q24'].values[:num_cycles]
    meas_z_y = df['meas_y_q24'].values[:num_cycles]
    meas_z_z = df['meas_z_q24'].values[:num_cycles]

    # Generate VHDL testbench
    vhdl_code = f'''--------------------------------------------------------------------------------
-- UKF Testbench with PREDICTION Output Logging
-- Cycles: {num_cycles}
-- Dataset: Constant velocity (manually verifiable)
--
-- OUTPUTS:
-- 1. PREDICTION (before measurement update)
-- 2. MEASUREMENT (raw sensor data)
-- 3. UPDATED (after measurement update)
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity ukf_prediction_logger_tb is
end ukf_prediction_logger_tb;

architecture Behavioral of ukf_prediction_logger_tb is

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
            done : out std_logic;
            -- ADDED: Prediction outputs (BEFORE measurement update)
            x_pos_predicted : out signed(47 downto 0);
            y_pos_predicted : out signed(47 downto 0);
            z_pos_predicted : out signed(47 downto 0);
            x_vel_predicted : out signed(47 downto 0);
            y_vel_predicted : out signed(47 downto 0);
            z_vel_predicted : out signed(47 downto 0);
            pred_done : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal start : std_logic := '0';
    signal done : std_logic;
    signal pred_done : std_logic;

    signal z_x_meas, z_y_meas, z_z_meas : signed(47 downto 0);

    signal x_pos_current, x_vel_current, x_acc_current : signed(47 downto 0);
    signal y_pos_current, y_vel_current, y_acc_current : signed(47 downto 0);
    signal z_pos_current, z_vel_current, z_acc_current : signed(47 downto 0);

    signal x_pos_predicted, y_pos_predicted, z_pos_predicted : signed(47 downto 0);
    signal x_vel_predicted, y_vel_predicted, z_vel_predicted : signed(47 downto 0);

    signal x_pos_uncertainty, x_vel_uncertainty, x_acc_uncertainty : signed(47 downto 0);
    signal y_pos_uncertainty, y_vel_uncertainty, y_acc_uncertainty : signed(47 downto 0);
    signal z_pos_uncertainty, z_vel_uncertainty, z_acc_uncertainty : signed(47 downto 0);

    type meas_array is array (0 to {num_cycles-1}) of signed(47 downto 0);

    constant MEAS_Z_X : meas_array := (
'''

    # Add X measurements
    for i, val in enumerate(meas_z_x):
        vhdl_code += f"        to_signed({int(val)}, 48)"
        if i < len(meas_z_x) - 1:
            vhdl_code += ","
        vhdl_code += "\n"

    vhdl_code += "    );\n\n    constant MEAS_Z_Y : meas_array := (\n"

    # Add Y measurements
    for i, val in enumerate(meas_z_y):
        vhdl_code += f"        to_signed({int(val)}, 48)"
        if i < len(meas_z_y) - 1:
            vhdl_code += ","
        vhdl_code += "\n"

    vhdl_code += "    );\n\n    constant MEAS_Z_Z : meas_array := (\n"

    # Add Z measurements
    for i, val in enumerate(meas_z_z):
        vhdl_code += f"        to_signed({int(val)}, 48)"
        if i < len(meas_z_z) - 1:
            vhdl_code += ","
        vhdl_code += "\n"

    vhdl_code += f'''    );

    constant TOTAL_CYCLES : integer := {num_cycles};
    constant CLK_PERIOD : time := 10 ns;

    -- Output files
    file pred_file : text;
    file upd_file : text;

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
            done => done,
            x_pos_predicted => x_pos_predicted,
            y_pos_predicted => y_pos_predicted,
            z_pos_predicted => z_pos_predicted,
            x_vel_predicted => x_vel_predicted,
            y_vel_predicted => y_vel_predicted,
            z_vel_predicted => z_vel_predicted,
            pred_done => pred_done
        );

    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
        variable pred_line : line;
        variable upd_line : line;
    begin
        -- Open output files
        file_open(pred_file, "../test_data/vhdl_predictions_raw.txt", write_mode);
        file_open(upd_file, "../test_data/vhdl_updated_raw.txt", write_mode);

        -- Write headers
        write(pred_line, string'("cycle,x_pos_pred,y_pos_pred,z_pos_pred,x_vel_pred,y_vel_pred,z_vel_pred,z_x_meas,z_y_meas,z_z_meas"));
        writeline(pred_file, pred_line);

        write(upd_line, string'("cycle,x_pos_upd,y_pos_upd,z_pos_upd,x_vel_upd,y_vel_upd,z_vel_upd"));
        writeline(upd_file, upd_line);

        -- Reset
        reset <= '1';
        wait for CLK_PERIOD * 5;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        report "========================================";
        report "UKF PREDICTION OUTPUT TEST";
        report "Total Cycles: " & integer'image(TOTAL_CYCLES);
        report "Output: vhdl_predictions_raw.txt (BEFORE update)";
        report "        vhdl_updated_raw.txt (AFTER update)";
        report "========================================";

        -- Run cycles
        for cycle in 0 to TOTAL_CYCLES-1 loop
            report "========== Cycle " & integer'image(cycle) & " ==========";

            -- Apply measurements
            z_x_meas <= MEAS_Z_X(cycle);
            z_y_meas <= MEAS_Z_Y(cycle);
            z_z_meas <= MEAS_Z_Z(cycle);

            report "  Measurements applied (Q24.24):";
            report "    z_x = " & integer'image(to_integer(MEAS_Z_X(cycle)));
            report "    z_y = " & integer'image(to_integer(MEAS_Z_Y(cycle)));
            report "    z_z = " & integer'image(to_integer(MEAS_Z_Z(cycle)));

            -- Start UKF
            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            -- Wait for prediction phase to complete
            for i in 0 to 5000 loop
                if pred_done = '1' then
                    exit;
                end if;
                wait for CLK_PERIOD;
            end loop;

            if pred_done /= '1' then
                report "ERROR: Prediction timeout!" severity failure;
            end if;

            wait for CLK_PERIOD * 2;

            -- CAPTURE PREDICTION (before measurement update!)
            report "  PREDICTION (before measurement update):";
            report "    x_pos_pred = " & integer'image(to_integer(x_pos_predicted));
            report "    y_pos_pred = " & integer'image(to_integer(y_pos_predicted));
            report "    z_pos_pred = " & integer'image(to_integer(z_pos_predicted));

            -- Write prediction to file
            write(pred_line, integer'image(cycle));
            write(pred_line, string'(","));
            write(pred_line, integer'image(to_integer(x_pos_predicted)));
            write(pred_line, string'(","));
            write(pred_line, integer'image(to_integer(y_pos_predicted)));
            write(pred_line, string'(","));
            write(pred_line, integer'image(to_integer(z_pos_predicted)));
            write(pred_line, string'(","));
            write(pred_line, integer'image(to_integer(x_vel_predicted)));
            write(pred_line, string'(","));
            write(pred_line, integer'image(to_integer(y_vel_predicted)));
            write(pred_line, string'(","));
            write(pred_line, integer'image(to_integer(z_vel_predicted)));
            write(pred_line, string'(","));
            write(pred_line, integer'image(to_integer(z_x_meas)));
            write(pred_line, string'(","));
            write(pred_line, integer'image(to_integer(z_y_meas)));
            write(pred_line, string'(","));
            write(pred_line, integer'image(to_integer(z_z_meas)));
            writeline(pred_file, pred_line);

            -- Wait for full completion (measurement update)
            for i in 0 to 10000 loop
                if done = '1' then
                    exit;
                end if;
                wait for CLK_PERIOD;
            end loop;

            if done /= '1' then
                report "ERROR: Update timeout!" severity failure;
            end if;

            wait for CLK_PERIOD * 2;

            -- CAPTURE UPDATED STATE (after measurement update)
            report "  UPDATED (after measurement update):";
            report "    x_pos_upd = " & integer'image(to_integer(x_pos_current));
            report "    y_pos_upd = " & integer'image(to_integer(y_pos_current));
            report "    z_pos_upd = " & integer'image(to_integer(z_pos_current));

            -- Write updated to file
            write(upd_line, integer'image(cycle));
            write(upd_line, string'(","));
            write(upd_line, integer'image(to_integer(x_pos_current)));
            write(upd_line, string'(","));
            write(upd_line, integer'image(to_integer(y_pos_current)));
            write(upd_line, string'(","));
            write(upd_line, integer'image(to_integer(z_pos_current)));
            write(upd_line, string'(","));
            write(upd_line, integer'image(to_integer(x_vel_current)));
            write(upd_line, string'(","));
            write(upd_line, integer'image(to_integer(y_vel_current)));
            write(upd_line, string'(","));
            write(upd_line, integer'image(to_integer(z_vel_current)));
            writeline(upd_file, upd_line);

            wait for CLK_PERIOD * 5;
        end loop;

        file_close(pred_file);
        file_close(upd_file);

        report "========================================";
        report "PREDICTION OUTPUT COMPLETE";
        report "PREDICTIONS: vhdl_predictions_raw.txt";
        report "UPDATED: vhdl_updated_raw.txt";
        report "========================================";

        wait for CLK_PERIOD * 10;
        std.env.stop;
    end process;

end Behavioral;
'''

    # Write to file
    with open(output_vhd, 'w') as f:
        f.write(vhdl_code)

    print(f"Testbench generated: {output_vhd}")
    print(f"Measurements: {num_cycles} cycles")
    print()
    print("This testbench outputs:")
    print("  1. vhdl_predictions_raw.txt - PREDICTIONS (before measurement update)")
    print("  2. vhdl_updated_raw.txt - UPDATED states (after measurement update)")
    print()

if __name__ == '__main__':
    generate_prediction_testbench(
        '../test_data/constant_velocity_10cycles.csv',
        '../ca_ukf.srcs/sim_1/new/ukf_prediction_logger_tb.vhd',
        num_cycles=10
    )
