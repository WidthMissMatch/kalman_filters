library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use STD.TEXTIO.ALL;

entity ukf_supreme_3d_comprehensive_tb is
end ukf_supreme_3d_comprehensive_tb;

architecture Behavioral of ukf_supreme_3d_comprehensive_tb is

    component ukf_supreme_3d is
        port (
            clk : in std_logic;
            reset : in std_logic;
            start : in std_logic;
            z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);
            x_pos_current, x_vel_current : out signed(47 downto 0);
            y_pos_current, y_vel_current : out signed(47 downto 0);
            z_pos_current, z_vel_current : out signed(47 downto 0);
            x_pos_uncertainty, x_vel_uncertainty : out signed(47 downto 0);
            y_pos_uncertainty, y_vel_uncertainty : out signed(47 downto 0);
            z_pos_uncertainty, z_vel_uncertainty : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal start : std_logic := '0';
    signal done : std_logic;

    signal z_x_meas : signed(47 downto 0) := (others => '0');
    signal z_y_meas : signed(47 downto 0) := (others => '0');
    signal z_z_meas : signed(47 downto 0) := (others => '0');

    signal x_pos_current, x_vel_current : signed(47 downto 0);
    signal y_pos_current, y_vel_current : signed(47 downto 0);
    signal z_pos_current, z_vel_current : signed(47 downto 0);

    signal x_pos_uncertainty, x_vel_uncertainty : signed(47 downto 0);
    signal y_pos_uncertainty, y_vel_uncertainty : signed(47 downto 0);
    signal z_pos_uncertainty, z_vel_uncertainty : signed(47 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    constant Q : integer := 24;
    constant SCALE : real := 16777216.0;

    function to_fixed(val : real) return signed is
    begin
        return to_signed(integer(val * SCALE), 48);
    end function;

    function from_fixed(val : signed) return real is
    begin
        return real(to_integer(val)) / SCALE;
    end function;

    shared variable total_cycles : integer := 0;
    shared variable passed_cycles : integer := 0;
    shared variable max_x_error : real := 0.0;
    shared variable max_y_error : real := 0.0;
    shared variable max_z_error : real := 0.0;

begin

    uut : ukf_supreme_3d
        port map (
            clk => clk,
            reset => reset,
            start => start,
            z_x_meas => z_x_meas,
            z_y_meas => z_y_meas,
            z_z_meas => z_z_meas,
            x_pos_current => x_pos_current,
            x_vel_current => x_vel_current,
            y_pos_current => y_pos_current,
            y_vel_current => y_vel_current,
            z_pos_current => z_pos_current,
            z_vel_current => z_vel_current,
            x_pos_uncertainty => x_pos_uncertainty,
            x_vel_uncertainty => x_vel_uncertainty,
            y_pos_uncertainty => y_pos_uncertainty,
            y_vel_uncertainty => y_vel_uncertainty,
            z_pos_uncertainty => z_pos_uncertainty,
            z_vel_uncertainty => z_vel_uncertainty,
            done => done
        );

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stim_process : process
        file csv_file : text;
        variable csv_line : line;
        variable char : character;
        variable cycle_num : integer;
        variable time_val : real;
        variable x_pos_true, x_vel_true, y_pos_true, y_vel_true, z_pos_true, z_vel_true : real;
        variable z_x, z_y, z_z : real;
        variable x_pos_ref, x_vel_ref, y_pos_ref, y_vel_ref, z_pos_ref, z_vel_ref : real;
        variable p11, p22, p33, p44, p55, p66 : real;
        variable innov_x, innov_y, innov_z : real;
        variable comma : character;
        variable x_error, y_error, z_error : real;
        variable x_pos_vhdl, y_pos_vhdl, z_pos_vhdl : real;
        variable tolerance : real := 0.5;
        variable test_passed : boolean;
    begin

        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        report "=== Starting Comprehensive 3D UKF Validation ===";
        report "Reading reference data from CSV file...";

        file_open(csv_file, "/home/arunupscee/Desktop/xtortion/3d_ukf/scripts/python_results_survey_100_no_dropout.csv", read_mode);

        readline(csv_file, csv_line);

        while not endfile(csv_file) loop
            readline(csv_file, csv_line);

            read(csv_line, cycle_num); read(csv_line, comma);
            read(csv_line, time_val); read(csv_line, comma);
            read(csv_line, x_pos_true); read(csv_line, comma);
            read(csv_line, x_vel_true); read(csv_line, comma);
            read(csv_line, y_pos_true); read(csv_line, comma);
            read(csv_line, y_vel_true); read(csv_line, comma);
            read(csv_line, z_pos_true); read(csv_line, comma);
            read(csv_line, z_vel_true); read(csv_line, comma);
            read(csv_line, z_x); read(csv_line, comma);
            read(csv_line, z_y); read(csv_line, comma);
            read(csv_line, z_z); read(csv_line, comma);
            read(csv_line, x_pos_ref); read(csv_line, comma);
            read(csv_line, x_vel_ref); read(csv_line, comma);
            read(csv_line, y_pos_ref); read(csv_line, comma);
            read(csv_line, y_vel_ref); read(csv_line, comma);
            read(csv_line, z_pos_ref); read(csv_line, comma);
            read(csv_line, z_vel_ref); read(csv_line, comma);
            read(csv_line, p11); read(csv_line, comma);
            read(csv_line, p22); read(csv_line, comma);
            read(csv_line, p33); read(csv_line, comma);
            read(csv_line, p44); read(csv_line, comma);
            read(csv_line, p55); read(csv_line, comma);
            read(csv_line, p66); read(csv_line, comma);
            read(csv_line, innov_x); read(csv_line, comma);
            read(csv_line, innov_y); read(csv_line, comma);
            read(csv_line, innov_z);

            z_x_meas <= to_fixed(z_x);
            z_y_meas <= to_fixed(z_y);
            z_z_meas <= to_fixed(z_z);

            start <= '1';
            wait until rising_edge(clk);
            start <= '0';

            for i in 0 to 10000 loop
                wait until rising_edge(clk);
                if done = '1' then
                    exit;
                end if;
                if i = 10000 then
                    report "ERROR: Timeout waiting for UKF done signal at cycle " & integer'image(cycle_num) severity error;
                end if;
            end loop;

            wait for CLK_PERIOD;

            x_pos_vhdl := from_fixed(x_pos_current);
            y_pos_vhdl := from_fixed(y_pos_current);
            z_pos_vhdl := from_fixed(z_pos_current);

            x_error := abs(x_pos_vhdl - x_pos_ref);
            y_error := abs(y_pos_vhdl - y_pos_ref);
            z_error := abs(z_pos_vhdl - z_pos_ref);

            total_cycles := total_cycles + 1;
            if x_error > max_x_error then max_x_error := x_error; end if;
            if y_error > max_y_error then max_y_error := y_error; end if;
            if z_error > max_z_error then max_z_error := z_error; end if;

            test_passed := (x_error < tolerance) and (y_error < tolerance) and (z_error < tolerance);
            if test_passed then
                passed_cycles := passed_cycles + 1;
            end if;

            if cycle_num mod 10 = 0 or not test_passed then
                report "Cycle " & integer'image(cycle_num) & ":";
                report "  Measurement: x=" & real'image(z_x) & " y=" & real'image(z_y) & " z=" & real'image(z_z);
                report "  Python ref:  x=" & real'image(x_pos_ref) & " y=" & real'image(y_pos_ref) & " z=" & real'image(z_pos_ref);
                report "  VHDL est:    x=" & real'image(x_pos_vhdl) & " y=" & real'image(y_pos_vhdl) & " z=" & real'image(z_pos_vhdl);
                report "  Errors:      x=" & real'image(x_error) & " y=" & real'image(y_error) & " z=" & real'image(z_error);
                if not test_passed then
                    report "  *** TOLERANCE EXCEEDED ***" severity warning;
                end if;
            end if;

            wait for CLK_PERIOD * 5;
        end loop;

        file_close(csv_file);

        report "=== Validation Complete ===";
        report "Total cycles: " & integer'image(total_cycles);
        report "Passed cycles: " & integer'image(passed_cycles);
        report "Pass rate: " & real'image(real(passed_cycles) / real(total_cycles) * 100.0) & "%";
        report "Max X error: " & real'image(max_x_error) & " m";
        report "Max Y error: " & real'image(max_y_error) & " m";
        report "Max Z error: " & real'image(max_z_error) & " m";

        if passed_cycles = total_cycles then
            report "*** ALL TESTS PASSED ***" severity note;
        else
            report "*** SOME TESTS FAILED ***" severity warning;
        end if;

        wait;
    end process;

end Behavioral;
