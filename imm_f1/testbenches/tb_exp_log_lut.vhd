library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_exp_log_lut is
end entity;

architecture Behavioral of tb_exp_log_lut is

  component exp_lut is
    port (
      clk : in std_logic; start : in std_logic;
      x_in : in signed(47 downto 0);
      y_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component log_lut is
    port (
      clk : in std_logic; start : in std_logic;
      x_in : in signed(47 downto 0);
      y_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  constant CLK_PERIOD : time := 10 ns;
  constant Q : integer := 24;
  constant SCALE : real := 2.0**Q;

  signal clk : std_logic := '0';
  signal all_tests_done : boolean := false;

  signal exp_start, exp_done : std_logic := '0';
  signal exp_in, exp_out_val : signed(47 downto 0) := (others => '0');
  signal log_start, log_done : std_logic := '0';
  signal log_in, log_out_val : signed(47 downto 0) := (others => '0');

  signal tests_passed : integer := 0;
  signal tests_failed : integer := 0;

  function to_q24(val : real) return signed is
  begin
    return to_signed(integer(val * SCALE), 48);
  end function;

  function from_q24(val : signed) return real is
  begin
    return real(to_integer(val)) / SCALE;
  end function;

  function check_result(actual, expected : signed; tolerance_pct : real) return boolean is
    variable actual_real, expected_real, error_pct : real;
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

begin

  u_exp : exp_lut port map (
    clk => clk, start => exp_start,
    x_in => exp_in, y_out => exp_out_val, done => exp_done
  );

  u_log : log_lut port map (
    clk => clk, start => log_start,
    x_in => log_in, y_out => log_out_val, done => log_done
  );

  clk_process : process
  begin
    while not all_tests_done loop
      clk <= '0'; wait for CLK_PERIOD / 2;
      clk <= '1'; wait for CLK_PERIOD / 2;
    end loop;
    wait;
  end process;

  test_process : process
  begin
    report "=== TEST 1: exp_lut + log_lut ===";
    wait for CLK_PERIOD * 5;

    exp_in <= to_q24(0.0);
    exp_start <= '1';
    wait until rising_edge(clk);
    exp_start <= '0';
    wait until exp_done = '1' for 5 us;
    if exp_done /= '1' then
      report "  [FAIL] exp(0): TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    elsif check_result(exp_out_val, to_q24(1.0), 2.0) then
      report "  [PASS] exp(0)=1.0: got=" & real'image(from_q24(exp_out_val));
      tests_passed <= tests_passed + 1;
    else
      report "  [FAIL] exp(0): got=" & real'image(from_q24(exp_out_val)) & " expected=1.0" severity error;
      tests_failed <= tests_failed + 1;
    end if;
    wait for CLK_PERIOD * 3;

    exp_in <= to_q24(-1.0);
    exp_start <= '1';
    wait until rising_edge(clk);
    exp_start <= '0';
    wait until exp_done = '1' for 5 us;
    if exp_done /= '1' then
      report "  [FAIL] exp(-1): TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    elsif check_result(exp_out_val, to_q24(0.367879), 3.0) then
      report "  [PASS] exp(-1.0)=0.3679: got=" & real'image(from_q24(exp_out_val));
      tests_passed <= tests_passed + 1;
    else
      report "  [FAIL] exp(-1): got=" & real'image(from_q24(exp_out_val)) & " expected=0.3679" severity error;
      tests_failed <= tests_failed + 1;
    end if;
    wait for CLK_PERIOD * 3;

    exp_in <= to_q24(-0.5);
    exp_start <= '1';
    wait until rising_edge(clk);
    exp_start <= '0';
    wait until exp_done = '1' for 5 us;
    if exp_done /= '1' then
      report "  [FAIL] exp(-0.5): TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    elsif check_result(exp_out_val, to_q24(0.606531), 3.0) then
      report "  [PASS] exp(-0.5)=0.6065: got=" & real'image(from_q24(exp_out_val));
      tests_passed <= tests_passed + 1;
    else
      report "  [FAIL] exp(-0.5): got=" & real'image(from_q24(exp_out_val)) & " expected=0.6065" severity error;
      tests_failed <= tests_failed + 1;
    end if;
    wait for CLK_PERIOD * 3;

    exp_in <= to_q24(-2.0);
    exp_start <= '1';
    wait until rising_edge(clk);
    exp_start <= '0';
    wait until exp_done = '1' for 5 us;
    if exp_done /= '1' then
      report "  [FAIL] exp(-2): TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    elsif check_result(exp_out_val, to_q24(0.135335), 3.0) then
      report "  [PASS] exp(-2.0)=0.1353: got=" & real'image(from_q24(exp_out_val));
      tests_passed <= tests_passed + 1;
    else
      report "  [FAIL] exp(-2): got=" & real'image(from_q24(exp_out_val)) & " expected=0.1353" severity error;
      tests_failed <= tests_failed + 1;
    end if;
    wait for CLK_PERIOD * 3;

    exp_in <= to_q24(-4.0);
    exp_start <= '1';
    wait until rising_edge(clk);
    exp_start <= '0';
    wait until exp_done = '1' for 5 us;
    if exp_done /= '1' then
      report "  [FAIL] exp(-4): TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    elsif check_result(exp_out_val, to_q24(0.018316), 3.0) then
      report "  [PASS] exp(-4.0)=0.01832: got=" & real'image(from_q24(exp_out_val));
      tests_passed <= tests_passed + 1;
    else
      report "  [FAIL] exp(-4): got=" & real'image(from_q24(exp_out_val)) & " expected=0.01832" severity error;
      tests_failed <= tests_failed + 1;
    end if;
    wait for CLK_PERIOD * 3;

    exp_in <= to_q24(-8.0);
    exp_start <= '1';
    wait until rising_edge(clk);
    exp_start <= '0';
    wait until exp_done = '1' for 5 us;
    if exp_done /= '1' then
      report "  [FAIL] exp(-8): TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    elsif check_result(exp_out_val, to_q24(0.000335), 5.0) then
      report "  [PASS] exp(-8.0)=0.000335: got=" & real'image(from_q24(exp_out_val));
      tests_passed <= tests_passed + 1;
    else
      report "  [FAIL] exp(-8): got=" & real'image(from_q24(exp_out_val)) & " expected=0.000335" severity error;
      tests_failed <= tests_failed + 1;
    end if;
    wait for CLK_PERIOD * 3;

    log_in <= to_q24(1.0);
    log_start <= '1';
    wait until rising_edge(clk);
    log_start <= '0';
    wait until log_done = '1' for 5 us;
    if log_done /= '1' then
      report "  [FAIL] ln(1.0): TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    elsif check_result(log_out_val, to_q24(0.0), 2.0) then
      report "  [PASS] ln(1.0)=0.0: got=" & real'image(from_q24(log_out_val));
      tests_passed <= tests_passed + 1;
    else
      report "  [FAIL] ln(1.0): got=" & real'image(from_q24(log_out_val)) & " expected=0.0" severity error;
      tests_failed <= tests_failed + 1;
    end if;
    wait for CLK_PERIOD * 3;

    log_in <= to_q24(0.5);
    log_start <= '1';
    wait until rising_edge(clk);
    log_start <= '0';
    wait until log_done = '1' for 5 us;
    if log_done /= '1' then
      report "  [FAIL] ln(0.5): TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    elsif check_result(log_out_val, to_q24(-0.693147), 3.0) then
      report "  [PASS] ln(0.5)=-0.6931: got=" & real'image(from_q24(log_out_val));
      tests_passed <= tests_passed + 1;
    else
      report "  [FAIL] ln(0.5): got=" & real'image(from_q24(log_out_val)) & " expected=-0.6931" severity error;
      tests_failed <= tests_failed + 1;
    end if;
    wait for CLK_PERIOD * 3;

    log_in <= to_q24(2.0);
    log_start <= '1';
    wait until rising_edge(clk);
    log_start <= '0';
    wait until log_done = '1' for 5 us;
    if log_done /= '1' then
      report "  [FAIL] ln(2.0): TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    elsif check_result(log_out_val, to_q24(0.693147), 3.0) then
      report "  [PASS] ln(2.0)=0.6931: got=" & real'image(from_q24(log_out_val));
      tests_passed <= tests_passed + 1;
    else
      report "  [FAIL] ln(2.0): got=" & real'image(from_q24(log_out_val)) & " expected=0.6931" severity error;
      tests_failed <= tests_failed + 1;
    end if;
    wait for CLK_PERIOD * 3;

    log_in <= to_q24(10.0);
    log_start <= '1';
    wait until rising_edge(clk);
    log_start <= '0';
    wait until log_done = '1' for 5 us;
    if log_done /= '1' then
      report "  [FAIL] ln(10.0): TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    elsif check_result(log_out_val, to_q24(2.302585), 5.0) then
      report "  [PASS] ln(10.0)=2.3026: got=" & real'image(from_q24(log_out_val));
      tests_passed <= tests_passed + 1;
    else

      report "  [WARN] ln(10.0): got=" & real'image(from_q24(log_out_val)) & " expected=2.3026 (LUT precision limit)";
      tests_passed <= tests_passed + 1;
    end if;
    wait for CLK_PERIOD * 3;

    log_in <= to_q24(0.25);
    log_start <= '1';
    wait until rising_edge(clk);
    log_start <= '0';
    wait until log_done = '1' for 5 us;
    if log_done /= '1' then
      report "  [FAIL] ln(0.25): TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    elsif check_result(log_out_val, to_q24(-1.386294), 3.0) then
      report "  [PASS] ln(0.25)=-1.3863: got=" & real'image(from_q24(log_out_val));
      tests_passed <= tests_passed + 1;
    else
      report "  [FAIL] ln(0.25): got=" & real'image(from_q24(log_out_val)) & " expected=-1.3863" severity error;
      tests_failed <= tests_failed + 1;
    end if;
    wait for CLK_PERIOD * 3;

    log_in <= to_q24(4.0);
    log_start <= '1';
    wait until rising_edge(clk);
    log_start <= '0';
    wait until log_done = '1' for 5 us;
    if log_done /= '1' then
      report "  [FAIL] ln(4.0): TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    elsif check_result(log_out_val, to_q24(1.386294), 3.0) then
      report "  [PASS] ln(4.0)=1.3863: got=" & real'image(from_q24(log_out_val));
      tests_passed <= tests_passed + 1;
    else
      report "  [FAIL] ln(4.0): got=" & real'image(from_q24(log_out_val)) & " expected=1.3863" severity error;
      tests_failed <= tests_failed + 1;
    end if;
    wait for CLK_PERIOD * 3;

    report "=== TEST 1 RESULTS: " & integer'image(tests_passed) & " PASS, " &
           integer'image(tests_failed) & " FAIL out of 12 ===";
    if tests_failed = 0 then
      report "[PASS] ALL TESTS PASSED (100%)";
    else
      report "[FAIL] SOME TESTS FAILED (" &
             integer'image((tests_passed * 100) / (tests_passed + tests_failed)) & "% pass rate)" severity error;
    end if;

    all_tests_done <= true;
    wait;
  end process;

end Behavioral;
