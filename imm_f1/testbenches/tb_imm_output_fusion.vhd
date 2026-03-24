library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_imm_output_fusion is
end entity;

architecture Behavioral of tb_imm_output_fusion is

  component imm_output_fusion is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      prob_ca, prob_singer, prob_bicycle : in signed(47 downto 0);
      ca_px, ca_py, ca_pz       : in signed(47 downto 0);
      singer_px, singer_py, singer_pz : in signed(47 downto 0);
      bike_px, bike_py, bike_pz : in signed(47 downto 0);
      px_out, py_out, pz_out : out signed(47 downto 0);
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
  signal ca_px, ca_py, ca_pz : signed(47 downto 0) := (others => '0');
  signal si_px, si_py, si_pz : signed(47 downto 0) := (others => '0');
  signal bi_px, bi_py, bi_pz : signed(47 downto 0) := (others => '0');
  signal px_out, py_out, pz_out : signed(47 downto 0);

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

  dut : imm_output_fusion port map (
    clk => clk, start => start_sig,
    prob_ca => prob_ca, prob_singer => prob_singer, prob_bicycle => prob_bicycle,
    ca_px => ca_px, ca_py => ca_py, ca_pz => ca_pz,
    singer_px => si_px, singer_py => si_py, singer_pz => si_pz,
    bike_px => bi_px, bike_py => bi_py, bike_pz => bi_pz,
    px_out => px_out, py_out => py_out, pz_out => pz_out,
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
  begin
    report "=== TEST 2: imm_output_fusion ===";
    wait for CLK_PERIOD * 3;

    prob_ca      <= to_q24(0.5);
    prob_singer  <= to_q24(0.3);
    prob_bicycle <= to_q24(0.2);
    ca_px <= to_q24(10.0); ca_py <= to_q24(20.0); ca_pz <= to_q24(5.0);
    si_px <= to_q24(11.0); si_py <= to_q24(21.0); si_pz <= to_q24(6.0);
    bi_px <= to_q24(12.0); bi_py <= to_q24(22.0); bi_pz <= to_q24(7.0);

    start_sig <= '1';
    wait until rising_edge(clk);
    start_sig <= '0';
    wait until done_sig = '1' for 5 us;

    if done_sig /= '1' then
      report "  [FAIL] Test A: TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    else
      if check_result(px_out, to_q24(10.7), 0.5) then
        report "  [PASS] px=10.7: got=" & real'image(from_q24(px_out));
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] px: got=" & real'image(from_q24(px_out)) & " expected=10.7" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if check_result(py_out, to_q24(20.7), 0.5) then
        report "  [PASS] py=20.7: got=" & real'image(from_q24(py_out));
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] py: got=" & real'image(from_q24(py_out)) & " expected=20.7" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if check_result(pz_out, to_q24(5.7), 0.5) then
        report "  [PASS] pz=5.7: got=" & real'image(from_q24(pz_out));
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] pz: got=" & real'image(from_q24(pz_out)) & " expected=5.7" severity error;
        tests_failed <= tests_failed + 1;
      end if;
    end if;
    wait for CLK_PERIOD * 5;

    prob_ca      <= to_q24(1.0);
    prob_singer  <= to_q24(0.0);
    prob_bicycle <= to_q24(0.0);
    ca_px <= to_q24(2.98); ca_py <= to_q24(-1.789); ca_pz <= to_q24(0.596);
    si_px <= to_q24(99.0); si_py <= to_q24(99.0); si_pz <= to_q24(99.0);
    bi_px <= to_q24(99.0); bi_py <= to_q24(99.0); bi_pz <= to_q24(99.0);

    start_sig <= '1';
    wait until rising_edge(clk);
    start_sig <= '0';
    wait until done_sig = '1' for 5 us;

    if done_sig /= '1' then
      report "  [FAIL] Test B: TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    else
      if check_result(px_out, to_q24(2.98), 0.1) then
        report "  [PASS] single-model px=2.98: got=" & real'image(from_q24(px_out));
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] single-model px: got=" & real'image(from_q24(px_out)) & " expected=2.98" severity error;
        tests_failed <= tests_failed + 1;
      end if;
    end if;
    wait for CLK_PERIOD * 5;

    prob_ca      <= to_signed(5592405, 48);
    prob_singer  <= to_signed(5592405, 48);
    prob_bicycle <= to_signed(5592406, 48);
    ca_px <= to_q24(3.0); ca_py <= to_q24(6.0); ca_pz <= to_q24(9.0);
    si_px <= to_q24(6.0); si_py <= to_q24(12.0); si_pz <= to_q24(18.0);
    bi_px <= to_q24(9.0); bi_py <= to_q24(18.0); bi_pz <= to_q24(27.0);

    start_sig <= '1';
    wait until rising_edge(clk);
    start_sig <= '0';
    wait until done_sig = '1' for 5 us;

    if done_sig /= '1' then
      report "  [FAIL] Test C: TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    else
      if check_result(px_out, to_q24(6.0), 0.5) then
        report "  [PASS] equal-weights px=6.0: got=" & real'image(from_q24(px_out));
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] equal-weights px: got=" & real'image(from_q24(px_out)) & " expected=6.0" severity error;
        tests_failed <= tests_failed + 1;
      end if;
    end if;

    report "=== TEST 2 RESULTS: " & integer'image(tests_passed) & " PASS, " &
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
