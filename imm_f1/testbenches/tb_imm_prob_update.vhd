library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_imm_prob_update is
end entity;

architecture Behavioral of tb_imm_prob_update is

  component imm_prob_update is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      L_ca, L_singer, L_bicycle : in signed(47 downto 0);
      c_ca, c_singer, c_bicycle : in signed(47 downto 0);
      prob_ca_out, prob_singer_out, prob_bicycle_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  constant CLK_PERIOD : time := 10 ns;
  constant Q : integer := 24;
  constant SCALE : real := 2.0**Q;

  signal clk : std_logic := '0';
  signal all_tests_done : boolean := false;
  signal start_sig, done_sig : std_logic := '0';

  signal L_ca, L_singer, L_bicycle : signed(47 downto 0) := (others => '0');
  signal c_ca, c_singer, c_bicycle : signed(47 downto 0) := (others => '0');
  signal prob_ca_out, prob_singer_out, prob_bicycle_out : signed(47 downto 0);

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

  dut : imm_prob_update port map (
    clk => clk, start => start_sig,
    L_ca => L_ca, L_singer => L_singer, L_bicycle => L_bicycle,
    c_ca => c_ca, c_singer => c_singer, c_bicycle => c_bicycle,
    prob_ca_out => prob_ca_out, prob_singer_out => prob_singer_out,
    prob_bicycle_out => prob_bicycle_out,
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
    variable p_sum : real;
    variable p1, p2, p3 : real;
  begin
    report "=== TEST 5: imm_prob_update ===";
    wait for CLK_PERIOD * 3;

    L_ca      <= to_q24(0.8);
    L_singer  <= to_q24(0.5);
    L_bicycle <= to_q24(0.3);
    c_ca      <= to_q24(0.5);
    c_singer  <= to_q24(0.3);
    c_bicycle <= to_q24(0.2);

    start_sig <= '1';
    wait until rising_edge(clk);
    start_sig <= '0';
    wait until done_sig = '1' for 100 us;

    if done_sig /= '1' then
      report "  [FAIL] Test A: TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    else
      p1 := from_q24(prob_ca_out);
      p2 := from_q24(prob_singer_out);
      p3 := from_q24(prob_bicycle_out);
      p_sum := p1 + p2 + p3;

      report "  prob_ca=" & real'image(p1) &
             " prob_si=" & real'image(p2) &
             " prob_bi=" & real'image(p3) &
             " sum=" & real'image(p_sum);

      if abs(p_sum - 1.0) < 0.01 then
        report "  [PASS] Probabilities sum to 1.0: " & real'image(p_sum);
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] Sum != 1.0: " & real'image(p_sum) severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if p1 > p2 and p1 > p3 then
        report "  [PASS] CA has highest probability (best likelihood * prior)";
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] CA should have highest probability" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if p1 > p2 and p2 > p3 then
        report "  [PASS] Correct ordering: CA > Singer > Bicycle";
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] Wrong ordering" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if abs(p1 - 0.656) < 0.05 then
        report "  [PASS] prob_ca ~= 0.656: got=" & real'image(p1);
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] prob_ca: got=" & real'image(p1) & " expected ~0.656" severity error;
        tests_failed <= tests_failed + 1;
      end if;
    end if;
    wait for CLK_PERIOD * 10;

    L_ca      <= to_q24(1.0);
    L_singer  <= to_q24(1.0);
    L_bicycle <= to_q24(1.0);
    c_ca      <= to_q24(0.5);
    c_singer  <= to_q24(0.3);
    c_bicycle <= to_q24(0.2);

    start_sig <= '1';
    wait until rising_edge(clk);
    start_sig <= '0';
    wait until done_sig = '1' for 100 us;

    if done_sig /= '1' then
      report "  [FAIL] Test B: TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    else
      p1 := from_q24(prob_ca_out);
      p2 := from_q24(prob_singer_out);
      p3 := from_q24(prob_bicycle_out);
      p_sum := p1 + p2 + p3;

      report "  Equal-L: prob_ca=" & real'image(p1) &
             " prob_si=" & real'image(p2) &
             " prob_bi=" & real'image(p3) &
             " sum=" & real'image(p_sum);

      if abs(p1 - 0.5) < 0.05 and abs(p2 - 0.3) < 0.05 and abs(p3 - 0.2) < 0.05 then
        report "  [PASS] Equal likelihoods preserve prior proportions";
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] Priors not preserved" severity error;
        tests_failed <= tests_failed + 1;
      end if;
    end if;
    wait for CLK_PERIOD * 10;

    L_ca      <= to_q24(1.0);
    L_singer  <= to_q24(0.001);
    L_bicycle <= to_q24(0.001);
    c_ca      <= to_q24(0.5);
    c_singer  <= to_q24(0.3);
    c_bicycle <= to_q24(0.2);

    start_sig <= '1';
    wait until rising_edge(clk);
    start_sig <= '0';
    wait until done_sig = '1' for 100 us;

    if done_sig /= '1' then
      report "  [FAIL] Test C: TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    else
      p1 := from_q24(prob_ca_out);
      p2 := from_q24(prob_singer_out);
      p3 := from_q24(prob_bicycle_out);

      report "  Extreme: prob_ca=" & real'image(p1) &
             " prob_si=" & real'image(p2) &
             " prob_bi=" & real'image(p3);

      if p2 >= 0.005 and p3 >= 0.005 then
        report "  [PASS] Min probabilities clamped above 0.01";
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] Clamping failed: min probs too low" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if p1 <= 0.99 and p1 > 0.9 then
        report "  [PASS] Dominant prob clamped <= 0.98: got=" & real'image(p1);
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] Dominant prob out of range: got=" & real'image(p1) severity error;
        tests_failed <= tests_failed + 1;
      end if;
    end if;

    report "=== TEST 5 RESULTS: " & integer'image(tests_passed) & " PASS, " &
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
