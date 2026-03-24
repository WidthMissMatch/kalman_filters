library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity prediction_components_tb is
end prediction_components_tb;

architecture testbench of prediction_components_tb is

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    constant CLK_PERIOD : time := 10 ns;

    constant Q : integer := 24;
    constant SCALE : real := 2.0**Q;

    signal tests_passed : integer := 0;
    signal tests_failed : integer := 0;
    signal all_tests_done : boolean := false;

    constant TOLERANCE_PCT : real := 1.0;

    component cholesky_6x6 is
        port (
            clk       : in  std_logic;
            start     : in  std_logic;
            p11_in, p12_in, p13_in, p14_in, p15_in, p16_in : in signed(47 downto 0);
            p22_in, p23_in, p24_in, p25_in, p26_in         : in signed(47 downto 0);
            p33_in, p34_in, p35_in, p36_in                 : in signed(47 downto 0);
            p44_in, p45_in, p46_in                         : in signed(47 downto 0);
            p55_in, p56_in                                 : in signed(47 downto 0);
            p66_in                                         : in signed(47 downto 0);
            l11_out, l21_out, l31_out, l41_out, l51_out, l61_out : out signed(47 downto 0);
            l22_out, l32_out, l42_out, l52_out, l62_out          : out signed(47 downto 0);
            l33_out, l43_out, l53_out, l63_out                   : out signed(47 downto 0);
            l44_out, l54_out, l64_out                            : out signed(47 downto 0);
            l55_out, l65_out                                     : out signed(47 downto 0);
            l66_out                                              : out signed(47 downto 0);
            done      : out std_logic;
            psd_error : out std_logic
        );
    end component;

    signal chol_start : std_logic := '0';
    signal chol_p11_in, chol_p12_in, chol_p13_in, chol_p14_in, chol_p15_in, chol_p16_in : signed(47 downto 0) := (others => '0');
    signal chol_p22_in, chol_p23_in, chol_p24_in, chol_p25_in, chol_p26_in : signed(47 downto 0) := (others => '0');
    signal chol_p33_in, chol_p34_in, chol_p35_in, chol_p36_in : signed(47 downto 0) := (others => '0');
    signal chol_p44_in, chol_p45_in, chol_p46_in : signed(47 downto 0) := (others => '0');
    signal chol_p55_in, chol_p56_in : signed(47 downto 0) := (others => '0');
    signal chol_p66_in : signed(47 downto 0) := (others => '0');

    signal chol_l11, chol_l21, chol_l31, chol_l41, chol_l51, chol_l61 : signed(47 downto 0);
    signal chol_l22, chol_l32, chol_l42, chol_l52, chol_l62 : signed(47 downto 0);
    signal chol_l33, chol_l43, chol_l53, chol_l63 : signed(47 downto 0);
    signal chol_l44, chol_l54, chol_l64 : signed(47 downto 0);
    signal chol_l55, chol_l65 : signed(47 downto 0);
    signal chol_l66 : signed(47 downto 0);
    signal chol_done : std_logic;
    signal chol_psd_error : std_logic;

    component process_noise_3d is
        port (
            clk   : in  std_logic;
            start : in  std_logic;
            p11_in, p12_in, p13_in, p14_in, p15_in, p16_in : in signed(47 downto 0);
            p22_in, p23_in, p24_in, p25_in, p26_in         : in signed(47 downto 0);
            p33_in, p34_in, p35_in, p36_in                 : in signed(47 downto 0);
            p44_in, p45_in, p46_in                         : in signed(47 downto 0);
            p55_in, p56_in                                 : in signed(47 downto 0);
            p66_in                                         : in signed(47 downto 0);
            p11_out, p12_out, p13_out, p14_out, p15_out, p16_out : out signed(47 downto 0);
            p22_out, p23_out, p24_out, p25_out, p26_out          : out signed(47 downto 0);
            p33_out, p34_out, p35_out, p36_out                   : out signed(47 downto 0);
            p44_out, p45_out, p46_out                            : out signed(47 downto 0);
            p55_out, p56_out                                     : out signed(47 downto 0);
            p66_out                                              : out signed(47 downto 0);
            done  : out std_logic
        );
    end component;

    signal pn_start : std_logic := '0';
    signal pn_p11_in, pn_p12_in, pn_p13_in, pn_p14_in, pn_p15_in, pn_p16_in : signed(47 downto 0) := (others => '0');
    signal pn_p22_in, pn_p23_in, pn_p24_in, pn_p25_in, pn_p26_in : signed(47 downto 0) := (others => '0');
    signal pn_p33_in, pn_p34_in, pn_p35_in, pn_p36_in : signed(47 downto 0) := (others => '0');
    signal pn_p44_in, pn_p45_in, pn_p46_in : signed(47 downto 0) := (others => '0');
    signal pn_p55_in, pn_p56_in : signed(47 downto 0) := (others => '0');
    signal pn_p66_in : signed(47 downto 0) := (others => '0');

    signal pn_p11_out, pn_p12_out, pn_p13_out, pn_p14_out, pn_p15_out, pn_p16_out : signed(47 downto 0);
    signal pn_p22_out, pn_p23_out, pn_p24_out, pn_p25_out, pn_p26_out : signed(47 downto 0);
    signal pn_p33_out, pn_p34_out, pn_p35_out, pn_p36_out : signed(47 downto 0);
    signal pn_p44_out, pn_p45_out, pn_p46_out : signed(47 downto 0);
    signal pn_p55_out, pn_p56_out : signed(47 downto 0);
    signal pn_p66_out : signed(47 downto 0);
    signal pn_done : std_logic;

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
            return error_pct < tolerance_pct;
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

    UUT_cholesky : cholesky_6x6
        port map (
            clk => clk,
            start => chol_start,
            p11_in => chol_p11_in, p12_in => chol_p12_in, p13_in => chol_p13_in,
            p14_in => chol_p14_in, p15_in => chol_p15_in, p16_in => chol_p16_in,
            p22_in => chol_p22_in, p23_in => chol_p23_in, p24_in => chol_p24_in,
            p25_in => chol_p25_in, p26_in => chol_p26_in,
            p33_in => chol_p33_in, p34_in => chol_p34_in, p35_in => chol_p35_in,
            p36_in => chol_p36_in,
            p44_in => chol_p44_in, p45_in => chol_p45_in, p46_in => chol_p46_in,
            p55_in => chol_p55_in, p56_in => chol_p56_in,
            p66_in => chol_p66_in,
            l11_out => chol_l11, l21_out => chol_l21, l31_out => chol_l31,
            l41_out => chol_l41, l51_out => chol_l51, l61_out => chol_l61,
            l22_out => chol_l22, l32_out => chol_l32, l42_out => chol_l42,
            l52_out => chol_l52, l62_out => chol_l62,
            l33_out => chol_l33, l43_out => chol_l43, l53_out => chol_l53, l63_out => chol_l63,
            l44_out => chol_l44, l54_out => chol_l54, l64_out => chol_l64,
            l55_out => chol_l55, l65_out => chol_l65,
            l66_out => chol_l66,
            done => chol_done,
            psd_error => chol_psd_error
        );

    UUT_process_noise : process_noise_3d
        port map (
            clk => clk,
            start => pn_start,
            p11_in => pn_p11_in, p12_in => pn_p12_in, p13_in => pn_p13_in,
            p14_in => pn_p14_in, p15_in => pn_p15_in, p16_in => pn_p16_in,
            p22_in => pn_p22_in, p23_in => pn_p23_in, p24_in => pn_p24_in,
            p25_in => pn_p25_in, p26_in => pn_p26_in,
            p33_in => pn_p33_in, p34_in => pn_p34_in, p35_in => pn_p35_in,
            p36_in => pn_p36_in,
            p44_in => pn_p44_in, p45_in => pn_p45_in, p46_in => pn_p46_in,
            p55_in => pn_p55_in, p56_in => pn_p56_in,
            p66_in => pn_p66_in,
            p11_out => pn_p11_out, p12_out => pn_p12_out, p13_out => pn_p13_out,
            p14_out => pn_p14_out, p15_out => pn_p15_out, p16_out => pn_p16_out,
            p22_out => pn_p22_out, p23_out => pn_p23_out, p24_out => pn_p24_out,
            p25_out => pn_p25_out, p26_out => pn_p26_out,
            p33_out => pn_p33_out, p34_out => pn_p34_out, p35_out => pn_p35_out,
            p36_out => pn_p36_out,
            p44_out => pn_p44_out, p45_out => pn_p45_out, p46_out => pn_p46_out,
            p55_out => pn_p55_out, p56_out => pn_p56_out,
            p66_out => pn_p66_out,
            done => pn_done
        );

    test_process : process
        file csv_file_cholesky : text;
        file csv_file_prediction : text;
        variable csv_line : line;
        variable cycle : integer;
        variable temp_val : real;

        type real_array is array (0 to 20) of real;
        variable l_expected : real_array;
        variable p_init : real_array;

        variable passed_this_module : integer;
        variable failed_this_module : integer;

    begin
        report "============================================================";
        report "GROUP 2 TESTBENCH: Prediction Components";
        report "============================================================";

        rst <= '1';
        wait for CLK_PERIOD * 5;
        rst <= '0';
        wait for CLK_PERIOD * 2;

        report "";
        report "===== Test 2.1: cholesky_6x6 Module =====";
        report "Loading python_cholesky_L.csv (contains P_in and L_out)...";

        passed_this_module := 0;
        failed_this_module := 0;

        file_open(csv_file_cholesky, "/home/arunupscee/Desktop/xtortion/3d_ukf/scripts/intermediate_csv/python_cholesky_L.csv", read_mode);

        readline(csv_file_cholesky, csv_line);

        for test_cycle in 1 to 17 loop

            readline(csv_file_cholesky, csv_line);
            read_csv_real(csv_line, temp_val);

            for i in 0 to 20 loop
                read_csv_real(csv_line, p_init(i));
            end loop;

            for i in 0 to 20 loop
                read_csv_real(csv_line, l_expected(i));
            end loop;

            chol_p11_in <= to_q24(p_init(0));
            chol_p12_in <= to_q24(p_init(1));
            chol_p22_in <= to_q24(p_init(2));
            chol_p13_in <= to_q24(p_init(3));
            chol_p23_in <= to_q24(p_init(4));
            chol_p33_in <= to_q24(p_init(5));
            chol_p14_in <= to_q24(p_init(6));
            chol_p24_in <= to_q24(p_init(7));
            chol_p34_in <= to_q24(p_init(8));
            chol_p44_in <= to_q24(p_init(9));
            chol_p15_in <= to_q24(p_init(10));
            chol_p25_in <= to_q24(p_init(11));
            chol_p35_in <= to_q24(p_init(12));
            chol_p45_in <= to_q24(p_init(13));
            chol_p55_in <= to_q24(p_init(14));
            chol_p16_in <= to_q24(p_init(15));
            chol_p26_in <= to_q24(p_init(16));
            chol_p36_in <= to_q24(p_init(17));
            chol_p46_in <= to_q24(p_init(18));
            chol_p56_in <= to_q24(p_init(19));
            chol_p66_in <= to_q24(p_init(20));

            wait for CLK_PERIOD;
            chol_start <= '1';
            wait until rising_edge(clk);
            chol_start <= '0';
            wait until chol_done = '1' for 5 us;

            if chol_done /= '1' then
                report "  [FAIL] Cycle " & integer'image(test_cycle) & ": Cholesky timeout" severity error;
                failed_this_module := failed_this_module + 1;
            elsif chol_psd_error = '1' then
                report "  [FAIL] Cycle " & integer'image(test_cycle) & ": Cholesky PSD error" severity error;
                failed_this_module := failed_this_module + 1;
            else

                if check_result(chol_l11, to_q24(l_expected(0)), TOLERANCE_PCT) and
                   check_result(chol_l21, to_q24(l_expected(1)), TOLERANCE_PCT) and
                   check_result(chol_l22, to_q24(l_expected(2)), TOLERANCE_PCT) then
                    report "  [PASS] Cycle " & integer'image(test_cycle) & ": L matrix correct";
                    passed_this_module := passed_this_module + 1;
                else
                    report "  [FAIL] Cycle " & integer'image(test_cycle) & ": L matrix mismatch" severity error;
                    report "    l11=" & real'image(from_q24(chol_l11)) & " (expected " & real'image(l_expected(0)) & ")";
                    report "    l21=" & real'image(from_q24(chol_l21)) & " (expected " & real'image(l_expected(1)) & ")";
                    report "    l22=" & real'image(from_q24(chol_l22)) & " (expected " & real'image(l_expected(2)) & ")";
                    failed_this_module := failed_this_module + 1;
                end if;
            end if;

            wait for CLK_PERIOD * 5;
        end loop;

        file_close(csv_file_cholesky);

        tests_passed <= tests_passed + passed_this_module;
        tests_failed <= tests_failed + failed_this_module;

        report "";
        report "Test 2.1 Summary: " & integer'image(passed_this_module) & "/" & integer'image(passed_this_module + failed_this_module) & " passed";

        report "";
        report "===== Test 2.6: process_noise_3d Module =====";
        report "Loading python_prediction.csv...";

        passed_this_module := 0;
        failed_this_module := 0;

        file_open(csv_file_prediction, "/home/arunupscee/Desktop/xtortion/3d_ukf/scripts/intermediate_csv/python_prediction.csv", read_mode);
        readline(csv_file_prediction, csv_line);

        for test_cycle in 1 to 17 loop

            readline(csv_file_prediction, csv_line);
            read_csv_real(csv_line, temp_val);

            for i in 1 to 6 loop
                read_csv_real(csv_line, temp_val);
            end loop;

            for i in 0 to 20 loop
                read_csv_real(csv_line, p_init(i));
            end loop;

            for i in 0 to 20 loop
                read_csv_real(csv_line, l_expected(i));
            end loop;

            pn_p11_in <= to_q24(p_init(0));
            pn_p12_in <= to_q24(p_init(1));
            pn_p22_in <= to_q24(p_init(2));
            pn_p13_in <= to_q24(p_init(3));
            pn_p23_in <= to_q24(p_init(4));
            pn_p33_in <= to_q24(p_init(5));
            pn_p14_in <= to_q24(p_init(6));
            pn_p24_in <= to_q24(p_init(7));
            pn_p34_in <= to_q24(p_init(8));
            pn_p44_in <= to_q24(p_init(9));
            pn_p15_in <= to_q24(p_init(10));
            pn_p25_in <= to_q24(p_init(11));
            pn_p35_in <= to_q24(p_init(12));
            pn_p45_in <= to_q24(p_init(13));
            pn_p55_in <= to_q24(p_init(14));
            pn_p16_in <= to_q24(p_init(15));
            pn_p26_in <= to_q24(p_init(16));
            pn_p36_in <= to_q24(p_init(17));
            pn_p46_in <= to_q24(p_init(18));
            pn_p56_in <= to_q24(p_init(19));
            pn_p66_in <= to_q24(p_init(20));

            wait for CLK_PERIOD;
            pn_start <= '1';
            wait until rising_edge(clk);
            pn_start <= '0';
            wait until pn_done = '1' for 1 us;

            if pn_done /= '1' then
                report "  [FAIL] Cycle " & integer'image(test_cycle) & ": Process noise timeout" severity error;
                failed_this_module := failed_this_module + 1;
            else

                if check_result(pn_p11_out, to_q24(l_expected(0)), TOLERANCE_PCT) and
                   check_result(pn_p22_out, to_q24(l_expected(2)), TOLERANCE_PCT) and
                   check_result(pn_p33_out, to_q24(l_expected(5)), TOLERANCE_PCT) then
                    report "  [PASS] Cycle " & integer'image(test_cycle) & ": Process noise correct";
                    passed_this_module := passed_this_module + 1;
                else
                    report "  [FAIL] Cycle " & integer'image(test_cycle) & ": Process noise mismatch" severity error;
                    report "    p11_out=" & real'image(from_q24(pn_p11_out)) & " (expected " & real'image(l_expected(0)) & ")";
                    report "    p22_out=" & real'image(from_q24(pn_p22_out)) & " (expected " & real'image(l_expected(2)) & ")";
                    failed_this_module := failed_this_module + 1;
                end if;
            end if;

            wait for CLK_PERIOD * 2;
        end loop;

        file_close(csv_file_prediction);

        tests_passed <= tests_passed + passed_this_module;
        tests_failed <= tests_failed + failed_this_module;

        report "";
        report "Test 2.6 Summary: " & integer'image(passed_this_module) & "/" & integer'image(passed_this_module + failed_this_module) & " passed";

        report "";
        report "============================================================";
        report "GROUP 2 TEST SUMMARY";
        report "============================================================";
        report "Modules tested: cholesky_6x6 (Test 2.1), process_noise_3d (Test 2.6)";
        report "Total tests run: " & integer'image(tests_passed + tests_failed);
        report "Tests passed: " & integer'image(tests_passed);
        report "Tests failed: " & integer'image(tests_failed);

        if tests_failed = 0 then
            report "[PASS] ALL TESTS PASSED (100%)";
        else
            report "[PARTIAL] Pass rate: " & integer'image((tests_passed * 100) / (tests_passed + tests_failed)) & "%";
        end if;
        report "============================================================";
        report "NOTE: 2 of 6 prediction modules tested. Remaining: sigma_3d, predicti_cv3d, predicted_mean_3d, covariance_reconstruct_3d";
        report "============================================================";

        all_tests_done <= true;
        wait;
    end process;

end testbench;
