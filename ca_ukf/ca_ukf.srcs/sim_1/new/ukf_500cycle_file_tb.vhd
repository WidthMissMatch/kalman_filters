library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity ukf_500cycle_file_tb is
end ukf_500cycle_file_tb;

architecture Behavioral of ukf_500cycle_file_tb is

    component ukf_supreme_3d is
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            start : in  std_logic;
            z_x_meas : in signed(47 downto 0);
            z_y_meas : in signed(47 downto 0);
            z_z_meas : in signed(47 downto 0);
            x_pos_current : out signed(47 downto 0);
            y_pos_current : out signed(47 downto 0);
            z_pos_current : out signed(47 downto 0);
            x_pos_uncertainty : out signed(47 downto 0);
            y_pos_uncertainty : out signed(47 downto 0);
            z_pos_uncertainty : out signed(47 downto 0);
            x_vel_current : out signed(47 downto 0);
            y_vel_current : out signed(47 downto 0);
            z_vel_current : out signed(47 downto 0);
            x_vel_uncertainty : out signed(47 downto 0);
            y_vel_uncertainty : out signed(47 downto 0);
            z_vel_uncertainty : out signed(47 downto 0);
            x_acc_current : out signed(47 downto 0);
            y_acc_current : out signed(47 downto 0);
            z_acc_current : out signed(47 downto 0);
            x_acc_uncertainty : out signed(47 downto 0);
            y_acc_uncertainty : out signed(47 downto 0);
            z_acc_uncertainty : out signed(47 downto 0);
            done  : out std_logic
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;
    constant NUM_CYCLES : integer := 500;
    constant MAX_WAIT_CYCLES : integer := 100000;
    constant Q_SCALE : real := 16777216.0;

    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal start : std_logic := '0';
    signal done : std_logic;

    signal z_x_meas, z_y_meas, z_z_meas : signed(47 downto 0);
    signal x_pos_current, y_pos_current, z_pos_current : signed(47 downto 0);
    signal x_pos_uncertainty, y_pos_uncertainty, z_pos_uncertainty : signed(47 downto 0);
    signal x_vel_current, y_vel_current, z_vel_current : signed(47 downto 0);
    signal x_vel_uncertainty, y_vel_uncertainty, z_vel_uncertainty : signed(47 downto 0);
    signal x_acc_current, y_acc_current, z_acc_current : signed(47 downto 0);
    signal x_acc_uncertainty, y_acc_uncertainty, z_acc_uncertainty : signed(47 downto 0);

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

    clk_proc: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stim_proc: process
        file input_file : text;
        variable input_line : line;
        variable comma : character;
        variable cycle_num : integer;
        variable time_val : real;
        variable gt_x, gt_y, gt_z : real;
        variable gt_vx, gt_vy, gt_vz : real;
        variable gt_ax, gt_ay, gt_az : real;
        variable meas_x, meas_y, meas_z : real;
        variable meas_x_q24, meas_y_q24, meas_z_q24 : integer;
        variable noise_x, noise_y, noise_z : real;
        variable timeout_counter : integer;
        variable est_x, est_y, est_z : real;
        variable err_x, err_y, err_z : real;
        variable sq_err_x, sq_err_y, sq_err_z : real;
        variable rmse_x, rmse_y, rmse_z : real;
        variable error_sum_x, error_sum_y, error_sum_z : real;
        variable error_count : integer;
    begin
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        report "========================================";
        report "500-CYCLE FULL VALIDATION TEST";
        report "File: test_data/drone_trajectory_800cycles.csv";
        report "Testing Tier 4A: P99=0.01 + K saturation";
        report "========================================";

        file_open(input_file, "test_data/drone_trajectory_800cycles.csv", read_mode);

        readline(input_file, input_line);

        error_sum_x := 0.0;
        error_sum_y := 0.0;
        error_sum_z := 0.0;
        error_count := 0;

        for i in 0 to NUM_CYCLES-1 loop
            if endfile(input_file) then
                report "ERROR: Unexpected end of file at cycle " & integer'image(i);
                exit;
            end if;

            readline(input_file, input_line);
            read(input_line, cycle_num); read(input_line, comma);
            read(input_line, time_val); read(input_line, comma);
            read(input_line, gt_x); read(input_line, comma);
            read(input_line, gt_y); read(input_line, comma);
            read(input_line, gt_z); read(input_line, comma);
            read(input_line, gt_vx); read(input_line, comma);
            read(input_line, gt_vy); read(input_line, comma);
            read(input_line, gt_vz); read(input_line, comma);
            read(input_line, gt_ax); read(input_line, comma);
            read(input_line, gt_ay); read(input_line, comma);
            read(input_line, gt_az); read(input_line, comma);
            read(input_line, meas_x); read(input_line, comma);
            read(input_line, meas_y); read(input_line, comma);
            read(input_line, meas_z); read(input_line, comma);
            read(input_line, meas_x_q24); read(input_line, comma);
            read(input_line, meas_y_q24); read(input_line, comma);
            read(input_line, meas_z_q24);

            z_x_meas <= to_signed(meas_x_q24, 48);
            z_y_meas <= to_signed(meas_y_q24, 48);
            z_z_meas <= to_signed(meas_z_q24, 48);

            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            timeout_counter := 0;
            wait until done = '1' or timeout_counter = MAX_WAIT_CYCLES;

            while done = '0' and timeout_counter < MAX_WAIT_CYCLES loop
                wait for CLK_PERIOD;
                timeout_counter := timeout_counter + 1;
            end loop;

            if timeout_counter >= MAX_WAIT_CYCLES then
                report "ERROR: Timeout at cycle " & integer'image(i);
                exit;
            end if;

            est_x := real(to_integer(x_pos_current)) / Q_SCALE;
            est_y := real(to_integer(y_pos_current)) / Q_SCALE;
            est_z := real(to_integer(z_pos_current)) / Q_SCALE;

            err_x := est_x - gt_x;
            err_y := est_y - gt_y;
            err_z := est_z - gt_z;

            sq_err_x := err_x * err_x;
            sq_err_y := err_y * err_y;
            sq_err_z := err_z * err_z;

            error_sum_x := error_sum_x + sq_err_x;
            error_sum_y := error_sum_y + sq_err_y;
            error_sum_z := error_sum_z + sq_err_z;
            error_count := error_count + 1;

            if (i mod 50) = 0 or i < 5 or i = NUM_CYCLES-1 then
                report "Cycle " & integer'image(i) &
                       ": GT(" & real'image(gt_x)(1 to 6) & "," &
                       real'image(gt_y)(1 to 6) & "," &
                       real'image(gt_z)(1 to 6) & ") " &
                       "EST(" & real'image(est_x)(1 to 6) & "," &
                       real'image(est_y)(1 to 6) & "," &
                       real'image(est_z)(1 to 6) & ") " &
                       "ERR(" & real'image(err_x)(1 to 6) & "," &
                       real'image(err_y)(1 to 6) & "," &
                       real'image(err_z)(1 to 6) & ") " &
                       "P99=" & integer'image(to_integer(z_acc_uncertainty));
            end if;

            if z_acc_uncertainty < to_signed(0, 48) then
                report "ERROR: Negative P99 at cycle " & integer'image(i);
            elsif z_acc_uncertainty > to_signed(100000000, 48) then
                report "WARNING: Large P99 at cycle " & integer'image(i) &
                       ", P99=" & integer'image(to_integer(z_acc_uncertainty));
            end if;

            wait for CLK_PERIOD * 2;
        end loop;

        file_close(input_file);

        if error_count > 0 then
            rmse_x := sqrt(error_sum_x / real(error_count));
            rmse_y := sqrt(error_sum_y / real(error_count));
            rmse_z := sqrt(error_sum_z / real(error_count));
        else
            rmse_x := 0.0;
            rmse_y := 0.0;
            rmse_z := 0.0;
        end if;

        report "========================================";
        report "500-CYCLE TEST COMPLETE";
        report "========================================";
        report "ACCURACY METRICS:";
        report "  RMSE X: " & real'image(rmse_x) & " m";
        report "  RMSE Y: " & real'image(rmse_y) & " m";
        report "  RMSE Z: " & real'image(rmse_z) & " m";
        report "  RMSE 3D: " & real'image(sqrt(rmse_x**2 + rmse_y**2 + rmse_z**2)) & " m";
        report "";
        report "STABILITY METRICS:";
        report "  Final P99: " & integer'image(to_integer(z_acc_uncertainty)) &
               " (" & real'image(real(to_integer(z_acc_uncertainty))/Q_SCALE) & ")";
        report "  Cycles completed: " & integer'image(error_count) & "/" & integer'image(NUM_CYCLES);
        report "========================================";

        wait for 1 us;
        report "Simulation complete";
        wait;
    end process;

end Behavioral;
