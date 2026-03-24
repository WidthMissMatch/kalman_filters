library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

entity measurement_update_components_tb is
end entity measurement_update_components_tb;

architecture behavior of measurement_update_components_tb is

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    constant CLK_PERIOD : time := 10 ns;
    signal all_tests_done : boolean := false;

    constant Q : integer := 24;
    constant SCALE : real := 16777216.0;
    constant TOLERANCE_PCT : real := 10.0;

    component innovation_3d is
        port (
            clk   : in  std_logic;
            start : in  std_logic;
            z_x_meas, z_y_meas, z_z_meas         : in signed(47 downto 0);
            z_x_mean, z_y_mean, z_z_mean         : in signed(47 downto 0);
            nu_x, nu_y, nu_z                     : out signed(47 downto 0);
            done  : out std_logic
        );
    end component;

    signal innov_start : std_logic := '0';
    signal innov_z_x_meas, innov_z_y_meas, innov_z_z_meas : signed(47 downto 0) := (others => '0');
    signal innov_z_x_mean, innov_z_y_mean, innov_z_z_mean : signed(47 downto 0) := (others => '0');
    signal innov_nu_x, innov_nu_y, innov_nu_z : signed(47 downto 0);
    signal innov_done : std_logic;

    function to_q24(val : real) return signed is
    begin
        return to_signed(integer(round(val * SCALE)), 48);
    end function;

    function from_q24(val : signed) return real is
    begin
        return real(to_integer(val)) / SCALE;
    end function;

    function check_result(actual, expected : signed; tolerance_pct : real) return boolean is
        variable actual_real : real;
        variable expected_real : real;
        variable error_pct : real;
    begin
        actual_real := from_q24(actual);
        expected_real := from_q24(expected);

        if abs(expected_real) < 1.0e-6 then
            return abs(actual_real - expected_real) < 0.001;
        else
            error_pct := abs((actual_real - expected_real) / expected_real) * 100.0;
            return error_pct <= tolerance_pct;
        end if;
    end function;

    procedure read_csv_real(variable L : inout line; variable val : out real) is
        variable char : character;
        variable str_val : string(1 to 256);
        variable str_len : integer := 0;
        variable good : boolean;
        variable temp_line : line;
    begin

        while L'length > 0 and (L(L'left) = ' ' or L(L'left) = HT) loop
            read(L, char);
        end loop;

        while L'length > 0 and L(L'left) /= ',' loop
            str_len := str_len + 1;
            read(L, str_val(str_len));
        end loop;

        if L'length > 0 and L(L'left) = ',' then
            read(L, char);
        end if;

        if str_len > 0 then
            temp_line := new string'(str_val(1 to str_len));
            read(temp_line, val, good);
            deallocate(temp_line);
            if not good then
                val := 0.0;
            end if;
        else
            val := 0.0;
        end if;
    end procedure;

begin

    clk_process : process
    begin
        while not all_tests_done loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    UUT_innovation : innovation_3d
        port map (
            clk => clk,
            start => innov_start,
            z_x_meas => innov_z_x_meas,
            z_y_meas => innov_z_y_meas,
            z_z_meas => innov_z_z_meas,
            z_x_mean => innov_z_x_mean,
            z_y_mean => innov_z_y_mean,
            z_z_mean => innov_z_z_mean,
            nu_x => innov_nu_x,
            nu_y => innov_nu_y,
            nu_z => innov_nu_z,
            done => innov_done
        );

    test_process : process
        file csv_file_main : text;
        file csv_file_update : text;
        variable csv_line : line;
        variable cycle : integer;
        variable temp_val : real;

        variable z_x_meas_val, z_y_meas_val, z_z_meas_val : real;
        variable z_x_mean_val, z_y_mean_val, z_z_mean_val : real;
        variable innov_x_expected, innov_y_expected, innov_z_expected : real;

        variable passed_this_module : integer;
        variable failed_this_module : integer;

    begin
        report "============================================================";
        report "GROUP 3 TESTBENCH: Measurement Update Components";
        report "============================================================";

        rst <= '1';
        wait for CLK_PERIOD * 5;
        rst <= '0';
        wait for CLK_PERIOD * 2;

        report "";
        report "===== Test 3.1: innovation_3d Module =====";
        report "Loading python_reference_main.csv (z_meas, innovation)...";
        report "Loading python_measurement_update.csv (z_pred)...";

        passed_this_module := 0;
        failed_this_module := 0;

        file_open(csv_file_main, "/home/arunupscee/Desktop/xtortion/3d_ukf/scripts/intermediate_csv/python_reference_main.csv", read_mode);
        file_open(csv_file_update, "/home/arunupscee/Desktop/xtortion/3d_ukf/scripts/intermediate_csv/python_measurement_update.csv", read_mode);

        readline(csv_file_main, csv_line);
        readline(csv_file_update, csv_line);

        for test_cycle in 1 to 17 loop

            readline(csv_file_main, csv_line);

            for i in 1 to 8 loop
                read_csv_real(csv_line, temp_val);
            end loop;

            read_csv_real(csv_line, z_x_meas_val);
            read_csv_real(csv_line, z_y_meas_val);
            read_csv_real(csv_line, z_z_meas_val);

            for i in 1 to 12 loop
                read_csv_real(csv_line, temp_val);
            end loop;

            read_csv_real(csv_line, innov_x_expected);
            read_csv_real(csv_line, innov_y_expected);
            read_csv_real(csv_line, innov_z_expected);

            readline(csv_file_update, csv_line);
            read_csv_real(csv_line, temp_val);

            for i in 1 to 39 loop
                read_csv_real(csv_line, temp_val);
            end loop;

            read_csv_real(csv_line, z_x_mean_val);
            read_csv_real(csv_line, z_y_mean_val);
            read_csv_real(csv_line, z_z_mean_val);

            innov_z_x_meas <= to_q24(z_x_meas_val);
            innov_z_y_meas <= to_q24(z_y_meas_val);
            innov_z_z_meas <= to_q24(z_z_meas_val);
            innov_z_x_mean <= to_q24(z_x_mean_val);
            innov_z_y_mean <= to_q24(z_y_mean_val);
            innov_z_z_mean <= to_q24(z_z_mean_val);

            wait for CLK_PERIOD;
            innov_start <= '1';
            wait until rising_edge(clk);
            innov_start <= '0';
            wait until innov_done = '1' for 1 us;

            if innov_done /= '1' then
                report "  [FAIL] Cycle " & integer'image(test_cycle) & ": Innovation timeout" severity error;
                failed_this_module := failed_this_module + 1;
            else

                if check_result(innov_nu_x, to_q24(innov_x_expected), TOLERANCE_PCT) and
                   check_result(innov_nu_y, to_q24(innov_y_expected), TOLERANCE_PCT) and
                   check_result(innov_nu_z, to_q24(innov_z_expected), TOLERANCE_PCT) then
                    report "  [PASS] Cycle " & integer'image(test_cycle) & ": Innovation correct";
                    passed_this_module := passed_this_module + 1;
                else
                    report "  [FAIL] Cycle " & integer'image(test_cycle) & ": Innovation mismatch" severity error;
                    report "    Expected: nu_x=" & real'image(innov_x_expected) &
                           " nu_y=" & real'image(innov_y_expected) &
                           " nu_z=" & real'image(innov_z_expected);
                    report "    Actual:   nu_x=" & real'image(from_q24(innov_nu_x)) &
                           " nu_y=" & real'image(from_q24(innov_nu_y)) &
                           " nu_z=" & real'image(from_q24(innov_nu_z));
                    failed_this_module := failed_this_module + 1;
                end if;
            end if;
        end loop;

        file_close(csv_file_main);
        file_close(csv_file_update);

        report "";
        report "Test 3.1 Summary: " & integer'image(passed_this_module) & "/" &
               integer'image(passed_this_module + failed_this_module) & " passed";

        report "";
        report "============================================================";
        report "GROUP 3 TEST SUMMARY";
        report "============================================================";
        report "Modules tested: innovation_3d (Test 3.1)";
        report "Total tests: " & integer'image(passed_this_module + failed_this_module);
        report "Tests passed: " & integer'image(passed_this_module);
        report "Tests failed: " & integer'image(failed_this_module);

        if failed_this_module = 0 then
            report "[PASS] ALL TESTS PASSED (100%)";
        else
            report "[FAIL] SOME TESTS FAILED" severity warning;
        end if;

        all_tests_done <= true;
        wait;
    end process;

end architecture behavior;
