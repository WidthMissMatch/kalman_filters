library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity ukf_f1_file_io_tb is
    generic (
        MEASUREMENT_FILE : string := "../../test_data/f1_measurements/monaco_measurements.txt";
        OUTPUT_FILE : string := "f1_monaco_output.txt";
        MAX_CYCLES : integer := 300
    );
end entity ukf_f1_file_io_tb;

architecture behavioral of ukf_f1_file_io_tb is

    component ukf_supreme_3d is
        port (
            clk : in std_logic;
            reset : in std_logic;
            start : in std_logic;
            z_x_meas : in signed(47 downto 0);
            z_y_meas : in signed(47 downto 0);
            z_z_meas : in signed(47 downto 0);
            done : out std_logic;
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
            z_acc_uncertainty : out signed(47 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal start : std_logic := '0';
    signal done : std_logic;

    signal z_x_meas : signed(47 downto 0) := (others => '0');
    signal z_y_meas : signed(47 downto 0) := (others => '0');
    signal z_z_meas : signed(47 downto 0) := (others => '0');

    signal x_pos_current : signed(47 downto 0);
    signal x_vel_current : signed(47 downto 0);
    signal x_acc_current : signed(47 downto 0);
    signal y_pos_current : signed(47 downto 0);
    signal y_vel_current : signed(47 downto 0);
    signal y_acc_current : signed(47 downto 0);
    signal z_pos_current : signed(47 downto 0);
    signal z_vel_current : signed(47 downto 0);
    signal z_acc_current : signed(47 downto 0);

    signal x_pos_uncertainty : signed(47 downto 0);
    signal x_vel_uncertainty : signed(47 downto 0);
    signal x_acc_uncertainty : signed(47 downto 0);
    signal y_pos_uncertainty : signed(47 downto 0);
    signal y_vel_uncertainty : signed(47 downto 0);
    signal y_acc_uncertainty : signed(47 downto 0);
    signal z_pos_uncertainty : signed(47 downto 0);
    signal z_vel_uncertainty : signed(47 downto 0);
    signal z_acc_uncertainty : signed(47 downto 0);

    signal sim_done : boolean := false;
    signal cycle_count : integer := 0;

    constant Q_SCALE : real := 16777216.0;

begin

    clk_process : process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    uut : ukf_supreme_3d
        port map (
            clk => clk,
            reset => reset,
            start => start,
            z_x_meas => z_x_meas,
            z_y_meas => z_y_meas,
            z_z_meas => z_z_meas,
            done => done,
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
            z_acc_uncertainty => z_acc_uncertainty
        );

    stim_process : process
        file meas_file : text open read_mode is MEASUREMENT_FILE;
        file result_file : text open write_mode is OUTPUT_FILE;
        variable input_line : line;
        variable output_line : line;
        variable char : character;
        variable cycle : integer;
        variable meas_x_q24, meas_y_q24, meas_z_q24 : integer;
        variable gt_x, gt_y, gt_z : real;
        variable timeout_counter : integer;

    begin

        write(output_line, string'("cycle,time,est_x_pos,est_x_vel,est_x_acc,est_y_pos,est_y_vel,est_y_acc,est_z_pos,est_z_vel,est_z_acc"));
        writeline(result_file, output_line);

        while not endfile(meas_file) loop
            readline(meas_file, input_line);
            read(input_line, char);
            exit when char /= '#';
        end loop;

        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        report "=== F1 UKF Simulation Started ===" severity note;
        report "Input file: " & MEASUREMENT_FILE severity note;
        report "Output file: " & OUTPUT_FILE severity note;

        cycle_count <= 0;

        while not endfile(meas_file) and cycle_count < MAX_CYCLES loop

            readline(meas_file, input_line);
            read(input_line, cycle);
            read(input_line, meas_x_q24);
            read(input_line, meas_y_q24);
            read(input_line, meas_z_q24);
            read(input_line, gt_x);
            read(input_line, gt_y);
            read(input_line, gt_z);

            z_x_meas <= to_signed(meas_x_q24, 48);
            z_y_meas <= to_signed(meas_y_q24, 48);
            z_z_meas <= to_signed(meas_z_q24, 48);

            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            timeout_counter := 0;
            while done = '0' and timeout_counter < 10000 loop
                wait for CLK_PERIOD;
                timeout_counter := timeout_counter + 1;
            end loop;

            if timeout_counter >= 10000 then
                report "TIMEOUT at cycle " & integer'image(cycle) severity error;
                exit;
            end if;

            write(output_line, cycle);
            write(output_line, string'(","));
            write(output_line, real(cycle) * 0.02, digits => 6);
            write(output_line, string'(","));
            write(output_line, real(to_integer(x_pos_current)) / Q_SCALE, digits => 6);
            write(output_line, string'(","));
            write(output_line, real(to_integer(x_vel_current)) / Q_SCALE, digits => 6);
            write(output_line, string'(","));
            write(output_line, real(to_integer(x_acc_current)) / Q_SCALE, digits => 6);
            write(output_line, string'(","));
            write(output_line, real(to_integer(y_pos_current)) / Q_SCALE, digits => 6);
            write(output_line, string'(","));
            write(output_line, real(to_integer(y_vel_current)) / Q_SCALE, digits => 6);
            write(output_line, string'(","));
            write(output_line, real(to_integer(y_acc_current)) / Q_SCALE, digits => 6);
            write(output_line, string'(","));
            write(output_line, real(to_integer(z_pos_current)) / Q_SCALE, digits => 6);
            write(output_line, string'(","));
            write(output_line, real(to_integer(z_vel_current)) / Q_SCALE, digits => 6);
            write(output_line, string'(","));
            write(output_line, real(to_integer(z_acc_current)) / Q_SCALE, digits => 6);
            writeline(result_file, output_line);

            if cycle mod 50 = 0 then
                report "Cycle " & integer'image(cycle) & " / " & integer'image(MAX_CYCLES) severity note;
            end if;

            cycle_count <= cycle_count + 1;
            wait for CLK_PERIOD * 10;
        end loop;

        report "=== F1 UKF Simulation Complete ===" severity note;
        report "Total cycles processed: " & integer'image(cycle_count) severity note;
        report "Output saved to: " & OUTPUT_FILE severity note;

        sim_done <= true;
        wait;
    end process;

end architecture behavioral;
