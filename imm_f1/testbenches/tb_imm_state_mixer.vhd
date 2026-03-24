library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_imm_state_mixer is
end entity;

architecture Behavioral of tb_imm_state_mixer is

  component imm_state_mixer is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      prob_ca, prob_singer, prob_bicycle : in signed(47 downto 0);
      ca_s1, ca_s2, ca_s3, ca_s4, ca_s5, ca_s6, ca_s7, ca_s8, ca_s9 : in signed(47 downto 0);
      si_s1, si_s2, si_s3, si_s4, si_s5, si_s6, si_s7, si_s8, si_s9 : in signed(47 downto 0);
      bi_s1, bi_s2, bi_s3, bi_s4, bi_s5, bi_s6, bi_s7, bi_s8, bi_s9 : in signed(47 downto 0);
      ca_b1, ca_b2, ca_b3, ca_b4, ca_b5, ca_b6, ca_b7 : in signed(47 downto 0);
      si_b1, si_b2, si_b3, si_b4, si_b5, si_b6, si_b7 : in signed(47 downto 0);
      bi_b1, bi_b2, bi_b3, bi_b4, bi_b5, bi_b6, bi_b7 : in signed(47 downto 0);
      mix_ca_s1, mix_ca_s2, mix_ca_s3, mix_ca_s4, mix_ca_s5, mix_ca_s6, mix_ca_s7, mix_ca_s8, mix_ca_s9 : out signed(47 downto 0);
      mix_si_s1, mix_si_s2, mix_si_s3, mix_si_s4, mix_si_s5, mix_si_s6, mix_si_s7, mix_si_s8, mix_si_s9 : out signed(47 downto 0);
      mix_bi_b1, mix_bi_b2, mix_bi_b3, mix_bi_b4, mix_bi_b5, mix_bi_b6, mix_bi_b7 : out signed(47 downto 0);
      c_ca_out, c_singer_out, c_bicycle_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  constant CLK_PERIOD : time := 10 ns;
  constant Q : integer := 24;
  constant SCALE : real := 2.0**Q;

  signal clk : std_logic := '0';
  signal all_tests_done : boolean := false;
  signal start_sig, done_sig : std_logic := '0';

  signal prob_ca, prob_singer, prob_bicycle : signed(47 downto 0) := (others => '0');

  signal ca_s1, ca_s2, ca_s3, ca_s4, ca_s5, ca_s6, ca_s7, ca_s8, ca_s9 : signed(47 downto 0) := (others => '0');
  signal si_s1, si_s2, si_s3, si_s4, si_s5, si_s6, si_s7, si_s8, si_s9 : signed(47 downto 0) := (others => '0');
  signal bi_s1, bi_s2, bi_s3, bi_s4, bi_s5, bi_s6, bi_s7, bi_s8, bi_s9 : signed(47 downto 0) := (others => '0');

  signal ca_b1, ca_b2, ca_b3, ca_b4, ca_b5, ca_b6, ca_b7 : signed(47 downto 0) := (others => '0');
  signal si_b1, si_b2, si_b3, si_b4, si_b5, si_b6, si_b7 : signed(47 downto 0) := (others => '0');
  signal bi_b1, bi_b2, bi_b3, bi_b4, bi_b5, bi_b6, bi_b7 : signed(47 downto 0) := (others => '0');

  signal mix_ca_s1, mix_ca_s2, mix_ca_s3, mix_ca_s4, mix_ca_s5, mix_ca_s6, mix_ca_s7, mix_ca_s8, mix_ca_s9 : signed(47 downto 0);
  signal mix_si_s1, mix_si_s2, mix_si_s3, mix_si_s4, mix_si_s5, mix_si_s6, mix_si_s7, mix_si_s8, mix_si_s9 : signed(47 downto 0);
  signal mix_bi_b1, mix_bi_b2, mix_bi_b3, mix_bi_b4, mix_bi_b5, mix_bi_b6, mix_bi_b7 : signed(47 downto 0);
  signal c_ca_out, c_singer_out, c_bicycle_out : signed(47 downto 0);

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
      return abs(actual_real - expected_real) < 0.01;
    else
      error_pct := abs((actual_real - expected_real) / expected_real) * 100.0;
      return error_pct <= tolerance_pct;
    end if;
  end function;

begin

  dut : imm_state_mixer port map (
    clk => clk, start => start_sig,
    prob_ca => prob_ca, prob_singer => prob_singer, prob_bicycle => prob_bicycle,
    ca_s1 => ca_s1, ca_s2 => ca_s2, ca_s3 => ca_s3, ca_s4 => ca_s4, ca_s5 => ca_s5,
    ca_s6 => ca_s6, ca_s7 => ca_s7, ca_s8 => ca_s8, ca_s9 => ca_s9,
    si_s1 => si_s1, si_s2 => si_s2, si_s3 => si_s3, si_s4 => si_s4, si_s5 => si_s5,
    si_s6 => si_s6, si_s7 => si_s7, si_s8 => si_s8, si_s9 => si_s9,
    bi_s1 => bi_s1, bi_s2 => bi_s2, bi_s3 => bi_s3, bi_s4 => bi_s4, bi_s5 => bi_s5,
    bi_s6 => bi_s6, bi_s7 => bi_s7, bi_s8 => bi_s8, bi_s9 => bi_s9,
    ca_b1 => ca_b1, ca_b2 => ca_b2, ca_b3 => ca_b3, ca_b4 => ca_b4,
    ca_b5 => ca_b5, ca_b6 => ca_b6, ca_b7 => ca_b7,
    si_b1 => si_b1, si_b2 => si_b2, si_b3 => si_b3, si_b4 => si_b4,
    si_b5 => si_b5, si_b6 => si_b6, si_b7 => si_b7,
    bi_b1 => bi_b1, bi_b2 => bi_b2, bi_b3 => bi_b3, bi_b4 => bi_b4,
    bi_b5 => bi_b5, bi_b6 => bi_b6, bi_b7 => bi_b7,
    mix_ca_s1 => mix_ca_s1, mix_ca_s2 => mix_ca_s2, mix_ca_s3 => mix_ca_s3,
    mix_ca_s4 => mix_ca_s4, mix_ca_s5 => mix_ca_s5, mix_ca_s6 => mix_ca_s6,
    mix_ca_s7 => mix_ca_s7, mix_ca_s8 => mix_ca_s8, mix_ca_s9 => mix_ca_s9,
    mix_si_s1 => mix_si_s1, mix_si_s2 => mix_si_s2, mix_si_s3 => mix_si_s3,
    mix_si_s4 => mix_si_s4, mix_si_s5 => mix_si_s5, mix_si_s6 => mix_si_s6,
    mix_si_s7 => mix_si_s7, mix_si_s8 => mix_si_s8, mix_si_s9 => mix_si_s9,
    mix_bi_b1 => mix_bi_b1, mix_bi_b2 => mix_bi_b2, mix_bi_b3 => mix_bi_b3,
    mix_bi_b4 => mix_bi_b4, mix_bi_b5 => mix_bi_b5, mix_bi_b6 => mix_bi_b6,
    mix_bi_b7 => mix_bi_b7,
    c_ca_out => c_ca_out, c_singer_out => c_singer_out, c_bicycle_out => c_bicycle_out,
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
    variable c_sum_real : real;

  begin
    report "=== TEST 3: imm_state_mixer ===";
    wait for CLK_PERIOD * 3;

    prob_ca      <= to_q24(0.5);
    prob_singer  <= to_q24(0.3);
    prob_bicycle <= to_q24(0.2);

    ca_s1 <= to_q24(10.0);  ca_s2 <= to_q24(3.0);   ca_s3 <= to_q24(0.1);
    ca_s4 <= to_q24(20.0);  ca_s5 <= to_q24(4.0);   ca_s6 <= to_q24(0.2);
    ca_s7 <= to_q24(5.0);   ca_s8 <= to_q24(0.0);   ca_s9 <= to_q24(0.0);

    si_s1 <= to_q24(11.0);  si_s2 <= to_q24(3.5);   si_s3 <= to_q24(0.15);
    si_s4 <= to_q24(21.0);  si_s5 <= to_q24(4.5);   si_s6 <= to_q24(0.25);
    si_s7 <= to_q24(6.0);   si_s8 <= to_q24(0.1);   si_s9 <= to_q24(0.01);

    bi_s1 <= to_q24(12.0);  bi_s2 <= to_q24(2.8);   bi_s3 <= to_q24(0.05);
    bi_s4 <= to_q24(22.0);  bi_s5 <= to_q24(3.8);   bi_s6 <= to_q24(0.1);
    bi_s7 <= to_q24(7.0);   bi_s8 <= to_q24(0.0);   bi_s9 <= to_q24(0.0);

    ca_b1 <= to_q24(10.0); ca_b2 <= to_q24(20.0); ca_b3 <= to_q24(5.0);
    ca_b4 <= to_q24(0.927); ca_b5 <= to_q24(0.0);  ca_b6 <= to_q24(0.2);
    ca_b7 <= to_q24(5.0);

    si_b1 <= to_q24(11.0); si_b2 <= to_q24(21.0); si_b3 <= to_q24(5.7);
    si_b4 <= to_q24(0.909); si_b5 <= to_q24(0.0);  si_b6 <= to_q24(0.3);
    si_b7 <= to_q24(6.0);

    bi_b1 <= to_q24(12.0); bi_b2 <= to_q24(22.0); bi_b3 <= to_q24(4.72);
    bi_b4 <= to_q24(0.935); bi_b5 <= to_q24(0.01); bi_b6 <= to_q24(0.1);
    bi_b7 <= to_q24(7.0);

    start_sig <= '1';
    wait until rising_edge(clk);
    start_sig <= '0';
    wait until done_sig = '1' for 50 us;

    if done_sig /= '1' then
      report "  [FAIL] State mixer TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    else

      c_sum_real := from_q24(c_ca_out) + from_q24(c_singer_out) + from_q24(c_bicycle_out);
      report "  c_ca=" & real'image(from_q24(c_ca_out)) &
             " c_si=" & real'image(from_q24(c_singer_out)) &
             " c_bi=" & real'image(from_q24(c_bicycle_out)) &
             " sum=" & real'image(c_sum_real);

      if abs(c_sum_real - 1.0) < 0.02 then
        report "  [PASS] c_j sum ~= 1.0 (got " & real'image(c_sum_real) & ")";
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] c_j sum: got " & real'image(c_sum_real) & " expected ~1.0" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if check_result(c_ca_out, to_q24(0.504), 2.0) then
        report "  [PASS] c_ca ~= 0.504: got=" & real'image(from_q24(c_ca_out));
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] c_ca: got=" & real'image(from_q24(c_ca_out)) & " expected ~0.504" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if check_result(c_singer_out, to_q24(0.305), 2.0) then
        report "  [PASS] c_singer ~= 0.305: got=" & real'image(from_q24(c_singer_out));
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] c_singer: got=" & real'image(from_q24(c_singer_out)) & " expected ~0.305" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if check_result(c_bicycle_out, to_q24(0.191), 2.0) then
        report "  [PASS] c_bicycle ~= 0.191: got=" & real'image(from_q24(c_bicycle_out));
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] c_bicycle: got=" & real'image(from_q24(c_bicycle_out)) & " expected ~0.191" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if check_result(mix_ca_s1, to_q24(10.058), 2.0) then
        report "  [PASS] mix_ca_px ~= 10.06: got=" & real'image(from_q24(mix_ca_s1));
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] mix_ca_px: got=" & real'image(from_q24(mix_ca_s1)) & " expected ~10.06" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      report "  mix_si_s1 (Singer px)=" & real'image(from_q24(mix_si_s1));
      if check_result(mix_si_s1, to_q24(11.0), 5.0) then
        report "  [PASS] mix_si_px near Singer: got=" & real'image(from_q24(mix_si_s1));
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] mix_si_px: got=" & real'image(from_q24(mix_si_s1)) & " expected near 11.0" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      report "  mix_bi_b1 (Bicycle px)=" & real'image(from_q24(mix_bi_b1));
      if check_result(mix_bi_b1, to_q24(12.0), 5.0) then
        report "  [PASS] mix_bi_px near Bicycle: got=" & real'image(from_q24(mix_bi_b1));
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] mix_bi_px: got=" & real'image(from_q24(mix_bi_b1)) & " expected near 12.0" severity error;
        tests_failed <= tests_failed + 1;
      end if;
    end if;

    report "=== TEST 3 RESULTS: " & integer'image(tests_passed) & " PASS, " &
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
