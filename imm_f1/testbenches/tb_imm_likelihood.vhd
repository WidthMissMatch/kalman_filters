library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_imm_likelihood is
end entity;

architecture Behavioral of tb_imm_likelihood is

  component imm_likelihood is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      nu1_x, nu1_y, nu1_z : in signed(47 downto 0);
      s1_11, s1_22, s1_33 : in signed(47 downto 0);
      nu2_x, nu2_y, nu2_z : in signed(47 downto 0);
      s2_11, s2_22, s2_33 : in signed(47 downto 0);
      nu3_x, nu3_y, nu3_z : in signed(47 downto 0);
      s3_11, s3_22, s3_33 : in signed(47 downto 0);
      L1_out, L2_out, L3_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  constant CLK_PERIOD : time := 10 ns;
  constant Q : integer := 24;
  constant SCALE : real := 2.0**Q;

  signal clk : std_logic := '0';
  signal all_tests_done : boolean := false;
  signal start_sig, done_sig : std_logic := '0';

  signal nu1_x, nu1_y, nu1_z : signed(47 downto 0) := (others => '0');
  signal s1_11, s1_22, s1_33 : signed(47 downto 0) := (others => '0');
  signal nu2_x, nu2_y, nu2_z : signed(47 downto 0) := (others => '0');
  signal s2_11, s2_22, s2_33 : signed(47 downto 0) := (others => '0');
  signal nu3_x, nu3_y, nu3_z : signed(47 downto 0) := (others => '0');
  signal s3_11, s3_22, s3_33 : signed(47 downto 0) := (others => '0');
  signal L1_out, L2_out, L3_out : signed(47 downto 0);

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

begin

  dut : imm_likelihood port map (
    clk => clk, start => start_sig,
    nu1_x => nu1_x, nu1_y => nu1_y, nu1_z => nu1_z,
    s1_11 => s1_11, s1_22 => s1_22, s1_33 => s1_33,
    nu2_x => nu2_x, nu2_y => nu2_y, nu2_z => nu2_z,
    s2_11 => s2_11, s2_22 => s2_22, s2_33 => s2_33,
    nu3_x => nu3_x, nu3_y => nu3_y, nu3_z => nu3_z,
    s3_11 => s3_11, s3_22 => s3_22, s3_33 => s3_33,
    L1_out => L1_out, L2_out => L2_out, L3_out => L3_out,
    done => done_sig
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
    variable L1_real, L2_real, L3_real : real;
  begin
    report "=== TEST 4: imm_likelihood ===";
    wait for CLK_PERIOD * 3;

    nu1_x <= to_q24(0.1);  nu1_y <= to_q24(0.1);  nu1_z <= to_q24(0.1);
    s1_11 <= to_q24(1.0);  s1_22 <= to_q24(1.0);  s1_33 <= to_q24(1.0);

    nu2_x <= to_q24(1.0);  nu2_y <= to_q24(1.0);  nu2_z <= to_q24(1.0);
    s2_11 <= to_q24(1.0);  s2_22 <= to_q24(1.0);  s2_33 <= to_q24(1.0);

    nu3_x <= to_q24(2.0);  nu3_y <= to_q24(2.0);  nu3_z <= to_q24(2.0);
    s3_11 <= to_q24(1.0);  s3_22 <= to_q24(1.0);  s3_33 <= to_q24(1.0);

    start_sig <= '1';
    wait until rising_edge(clk);
    start_sig <= '0';
    wait until done_sig = '1' for 100 us;

    if done_sig /= '1' then
      report "  [FAIL] Test A: TIMEOUT after 100us" severity error;
      tests_failed <= tests_failed + 1;
    else
      L1_real := from_q24(L1_out);
      L2_real := from_q24(L2_out);
      L3_real := from_q24(L3_out);

      report "  L1=" & real'image(L1_real) &
             " L2=" & real'image(L2_real) &
             " L3=" & real'image(L3_real);

      if L1_real > L2_real and L1_real > L3_real then
        report "  [PASS] L1 > L2 > L3 (best model has highest likelihood)";
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] L1 should be largest: L1=" & real'image(L1_real) &
               " L2=" & real'image(L2_real) & " L3=" & real'image(L3_real) severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if L2_real > L3_real then
        report "  [PASS] L2 > L3 (ordering correct)";
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] L2 should > L3" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if abs(L1_real - 1.0) < 0.05 then
        report "  [PASS] L1 ~= 1.0 (max-subtract trick): got=" & real'image(L1_real);
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] L1 should be ~1.0 (max-subtract): got=" & real'image(L1_real) severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if L1_real >= 0.0 and L2_real >= 0.0 and L3_real >= 0.0 then
        report "  [PASS] All likelihoods non-negative";
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] Negative likelihood detected" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if L2_real > 0.05 and L2_real < 0.5 then
        report "  [PASS] L2 in expected range [0.05, 0.5]: got=" & real'image(L2_real);
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] L2 out of expected range: got=" & real'image(L2_real) severity error;
        tests_failed <= tests_failed + 1;
      end if;
    end if;
    wait for CLK_PERIOD * 5;

    nu1_x <= to_q24(0.5);  nu1_y <= to_q24(0.5);  nu1_z <= to_q24(0.5);
    s1_11 <= to_q24(2.0);  s1_22 <= to_q24(2.0);  s1_33 <= to_q24(2.0);

    nu2_x <= to_q24(0.5);  nu2_y <= to_q24(0.5);  nu2_z <= to_q24(0.5);
    s2_11 <= to_q24(2.0);  s2_22 <= to_q24(2.0);  s2_33 <= to_q24(2.0);

    nu3_x <= to_q24(0.5);  nu3_y <= to_q24(0.5);  nu3_z <= to_q24(0.5);
    s3_11 <= to_q24(2.0);  s3_22 <= to_q24(2.0);  s3_33 <= to_q24(2.0);

    start_sig <= '1';
    wait until rising_edge(clk);
    start_sig <= '0';
    wait until done_sig = '1' for 100 us;

    if done_sig /= '1' then
      report "  [FAIL] Test B: TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    else
      L1_real := from_q24(L1_out);
      L2_real := from_q24(L2_out);
      L3_real := from_q24(L3_out);

      report "  Equal-innov: L1=" & real'image(L1_real) &
             " L2=" & real'image(L2_real) &
             " L3=" & real'image(L3_real);

      if abs(L1_real - L2_real) < 0.05 and abs(L2_real - L3_real) < 0.05 then
        report "  [PASS] Equal innovations give equal likelihoods";
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] Likelihoods not equal for equal innovations" severity error;
        tests_failed <= tests_failed + 1;
      end if;
    end if;

    report "=== TEST 4 RESULTS: " & integer'image(tests_passed) & " PASS, " &
           integer'image(tests_failed) & " FAIL ===";
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
