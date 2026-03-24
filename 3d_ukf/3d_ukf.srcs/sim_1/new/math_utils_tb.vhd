library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity math_utils_tb is
end math_utils_tb;

architecture testbench of math_utils_tb is

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    constant CLK_PERIOD : time := 10 ns;

    constant Q : integer := 24;
    constant SCALE : real := 2.0**Q;

    signal tests_passed : integer := 0;
    signal tests_failed : integer := 0;
    signal all_tests_done : boolean := false;

    component sqrt_newton is
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            start : in  std_logic;
            x_in  : in  signed(47 downto 0);
            sqrt_out : out signed(47 downto 0);
            done  : out std_logic
        );
    end component;

    signal sqrt_start : std_logic := '0';
    signal sqrt_x_in : signed(47 downto 0) := (others => '0');
    signal sqrt_out : signed(47 downto 0);
    signal sqrt_done : std_logic;

    component reciprocal_newton is
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            start : in  std_logic;
            x_in  : in  signed(47 downto 0);
            recip_out : out signed(47 downto 0);
            done  : out std_logic
        );
    end component;

    signal recip_start : std_logic := '0';
    signal recip_x_in : signed(47 downto 0) := (others => '0');
    signal recip_out : signed(47 downto 0);
    signal recip_done : std_logic;

    component matrix_inverse_3x3 is
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            start : in  std_logic;
            s11, s12, s13, s22, s23, s33 : in signed(47 downto 0);
            s11_inv, s12_inv, s13_inv, s22_inv, s23_inv, s33_inv : out signed(47 downto 0);
            done  : out std_logic;
            error : out std_logic
        );
    end component;

    signal inv_start : std_logic := '0';
    signal inv_s11, inv_s12, inv_s13, inv_s22, inv_s23, inv_s33 : signed(47 downto 0) := (others => '0');
    signal inv_s11_out, inv_s12_out, inv_s13_out, inv_s22_out, inv_s23_out, inv_s33_out : signed(47 downto 0);
    signal inv_done : std_logic;
    signal inv_error : std_logic;

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

    UUT_sqrt : sqrt_newton
        port map (
            clk => clk,
            rst => rst,
            start => sqrt_start,
            x_in => sqrt_x_in,
            sqrt_out => sqrt_out,
            done => sqrt_done
        );

    UUT_recip : reciprocal_newton
        port map (
            clk => clk,
            rst => rst,
            start => recip_start,
            x_in => recip_x_in,
            recip_out => recip_out,
            done => recip_done
        );

    UUT_inv : matrix_inverse_3x3
        port map (
            clk => clk,
            rst => rst,
            start => inv_start,
            s11 => inv_s11,
            s12 => inv_s12,
            s13 => inv_s13,
            s22 => inv_s22,
            s23 => inv_s23,
            s33 => inv_s33,
            s11_inv => inv_s11_out,
            s12_inv => inv_s12_out,
            s13_inv => inv_s13_out,
            s22_inv => inv_s22_out,
            s23_inv => inv_s23_out,
            s33_inv => inv_s33_out,
            done => inv_done,
            error => inv_error
        );

    test_process : process
        variable result_real : real;
        variable expected_real : real;
        variable error_pct : real;
    begin
        report "============================================================";
        report "GROUP 1 TESTBENCH: Math Utilities";
        report "============================================================";

        rst <= '1';
        wait for CLK_PERIOD * 5;
        rst <= '0';
        wait for CLK_PERIOD * 2;

        report "";
        report "===== Testing sqrt_newton =====";

        report "Test 1: sqrt(4.0) = 2.0";
        sqrt_x_in <= to_q24(4.0);
        wait for CLK_PERIOD;
        sqrt_start <= '1';
        wait until rising_edge(clk);
        sqrt_start <= '0';
        wait until sqrt_done = '1';
        wait for CLK_PERIOD;

        result_real := from_q24(sqrt_out);
        expected_real := 2.0;
        error_pct := abs((result_real - expected_real) / expected_real) * 100.0;

        if check_result(sqrt_out, to_q24(2.0), 0.1) then
            report "  [PASS] result=" & real'image(result_real) & " (error=" & real'image(error_pct) & "%)";
            tests_passed <= tests_passed + 1;
        else
            report "  [FAIL] result=" & real'image(result_real) & ", expected=2.0 (error=" & real'image(error_pct) & "%)" severity error;
            tests_failed <= tests_failed + 1;
        end if;
        wait for CLK_PERIOD * 5;

        report "Test 2: sqrt(0.25) = 0.5";
        sqrt_x_in <= to_q24(0.25);
        wait for CLK_PERIOD;
        sqrt_start <= '1';
        wait until rising_edge(clk);
        sqrt_start <= '0';
        wait until sqrt_done = '1';
        wait for CLK_PERIOD;

        result_real := from_q24(sqrt_out);
        expected_real := 0.5;
        error_pct := abs((result_real - expected_real) / expected_real) * 100.0;

        if check_result(sqrt_out, to_q24(0.5), 0.1) then
            report "  [PASS] result=" & real'image(result_real) & " (error=" & real'image(error_pct) & "%)";
            tests_passed <= tests_passed + 1;
        else
            report "  [FAIL] result=" & real'image(result_real) & ", expected=0.5" severity error;
            tests_failed <= tests_failed + 1;
        end if;
        wait for CLK_PERIOD * 5;

        report "Test 3: sqrt(100.0) = 10.0";
        sqrt_x_in <= to_q24(100.0);
        wait for CLK_PERIOD;
        sqrt_start <= '1';
        wait until rising_edge(clk);
        sqrt_start <= '0';
        wait until sqrt_done = '1';
        wait for CLK_PERIOD;

        if check_result(sqrt_out, to_q24(10.0), 0.1) then
            report "  [PASS] result=" & real'image(from_q24(sqrt_out));
            tests_passed <= tests_passed + 1;
        else
            report "  [FAIL] result=" & real'image(from_q24(sqrt_out)) & ", expected=10.0" severity error;
            tests_failed <= tests_failed + 1;
        end if;
        wait for CLK_PERIOD * 5;

        report "Test 4: sqrt(1.5) ~ 1.2247";
        sqrt_x_in <= to_q24(1.5);
        wait for CLK_PERIOD;
        sqrt_start <= '1';
        wait until rising_edge(clk);
        sqrt_start <= '0';
        wait until sqrt_done = '1';
        wait for CLK_PERIOD;

        if check_result(sqrt_out, to_q24(1.2247), 0.1) then
            report "  [PASS] result=" & real'image(from_q24(sqrt_out));
            tests_passed <= tests_passed + 1;
        else
            report "  [FAIL] result=" & real'image(from_q24(sqrt_out)) & ", expected=1.2247" severity error;
            tests_failed <= tests_failed + 1;
        end if;
        wait for CLK_PERIOD * 5;

        report "";
        report "===== Testing reciprocal_newton =====";

        report "Test 5: 1/2.0 = 0.5";
        recip_x_in <= to_q24(2.0);
        wait for CLK_PERIOD;
        recip_start <= '1';
        wait until rising_edge(clk);
        recip_start <= '0';
        wait until recip_done = '1';
        wait for CLK_PERIOD;

        if check_result(recip_out, to_q24(0.5), 0.1) then
            report "  [PASS] result=" & real'image(from_q24(recip_out));
            tests_passed <= tests_passed + 1;
        else
            report "  [FAIL] result=" & real'image(from_q24(recip_out)) & ", expected=0.5" severity error;
            tests_failed <= tests_failed + 1;
        end if;
        wait for CLK_PERIOD * 5;

        report "Test 6: 1/0.5 = 2.0";
        recip_x_in <= to_q24(0.5);
        wait for CLK_PERIOD;
        recip_start <= '1';
        wait until rising_edge(clk);
        recip_start <= '0';
        wait until recip_done = '1';
        wait for CLK_PERIOD;

        if check_result(recip_out, to_q24(2.0), 0.1) then
            report "  [PASS] result=" & real'image(from_q24(recip_out));
            tests_passed <= tests_passed + 1;
        else
            report "  [FAIL] result=" & real'image(from_q24(recip_out)) & ", expected=2.0" severity error;
            tests_failed <= tests_failed + 1;
        end if;
        wait for CLK_PERIOD * 5;

        report "Test 7: 1/10.0 = 0.1";
        recip_x_in <= to_q24(10.0);
        wait for CLK_PERIOD;
        recip_start <= '1';
        wait until rising_edge(clk);
        recip_start <= '0';
        wait until recip_done = '1';
        wait for CLK_PERIOD;

        if check_result(recip_out, to_q24(0.1), 0.1) then
            report "  [PASS] result=" & real'image(from_q24(recip_out));
            tests_passed <= tests_passed + 1;
        else
            report "  [FAIL] result=" & real'image(from_q24(recip_out)) & ", expected=0.1" severity error;
            tests_failed <= tests_failed + 1;
        end if;
        wait for CLK_PERIOD * 5;

        report "Test 8: 1/1.5 ~ 0.6667";
        recip_x_in <= to_q24(1.5);
        wait for CLK_PERIOD;
        recip_start <= '1';
        wait until rising_edge(clk);
        recip_start <= '0';
        wait until recip_done = '1';
        wait for CLK_PERIOD;

        if check_result(recip_out, to_q24(0.6667), 0.1) then
            report "  [PASS] result=" & real'image(from_q24(recip_out));
            tests_passed <= tests_passed + 1;
        else
            report "  [FAIL] result=" & real'image(from_q24(recip_out)) & ", expected=0.6667" severity error;
            tests_failed <= tests_failed + 1;
        end if;
        wait for CLK_PERIOD * 5;

        report "";
        report "===== Testing matrix_inverse_3x3 =====";

        report "Test 9: Diagonal matrix [[1.5, 0, 0], [0, 1.5, 0], [0, 0, 1.5]]";
        inv_s11 <= to_q24(1.5);
        inv_s22 <= to_q24(1.5);
        inv_s33 <= to_q24(1.5);
        inv_s12 <= to_q24(0.0);
        inv_s13 <= to_q24(0.0);
        inv_s23 <= to_q24(0.0);
        wait for CLK_PERIOD;

        inv_start <= '1';
        wait until rising_edge(clk);
        inv_start <= '0';
        wait until inv_done = '1';
        wait for CLK_PERIOD;

        if check_result(inv_s11_out, to_q24(0.6667), 0.1) and
           check_result(inv_s22_out, to_q24(0.6667), 0.1) and
           check_result(inv_s33_out, to_q24(0.6667), 0.1) then
            report "  [PASS] Diagonal matrix inverted correctly";
            tests_passed <= tests_passed + 1;
        else
            report "  [FAIL] Diagonal matrix inversion error" severity error;
            report "    s11_inv=" & real'image(from_q24(inv_s11_out)) & " (expected 0.6667)";
            tests_failed <= tests_failed + 1;
        end if;
        wait for CLK_PERIOD * 5;

        report "Test 10: Identity matrix [[1, 0, 0], [0, 1, 0], [0, 0, 1]]";
        inv_s11 <= to_q24(1.0);
        inv_s22 <= to_q24(1.0);
        inv_s33 <= to_q24(1.0);
        inv_s12 <= to_q24(0.0);
        inv_s13 <= to_q24(0.0);
        inv_s23 <= to_q24(0.0);
        wait for CLK_PERIOD;

        inv_start <= '1';
        wait until rising_edge(clk);
        inv_start <= '0';
        wait until inv_done = '1';
        wait for CLK_PERIOD;

        if check_result(inv_s11_out, to_q24(1.0), 0.1) and
           check_result(inv_s22_out, to_q24(1.0), 0.1) and
           check_result(inv_s33_out, to_q24(1.0), 0.1) then
            report "  [PASS] Identity matrix inverted correctly";
            tests_passed <= tests_passed + 1;
        else
            report "  [FAIL] Identity matrix inversion error" severity error;
            tests_failed <= tests_failed + 1;
        end if;

        wait for CLK_PERIOD * 10;

        report "";
        report "============================================================";
        report "GROUP 1 TEST SUMMARY";
        report "============================================================";
        report "Total tests: 10";
        report "Tests passed: " & integer'image(tests_passed);
        report "Tests failed: " & integer'image(tests_failed);

        if tests_failed = 0 then
            report "[PASS] ALL TESTS PASSED (100%)";
        else
            report "[FAIL] SOME TESTS FAILED (" & integer'image(tests_passed * 10) & "% pass rate)";
        end if;
        report "============================================================";

        all_tests_done <= true;
        wait;
    end process;

end testbench;
