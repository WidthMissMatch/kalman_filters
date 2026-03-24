library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_state_mappers is
end entity;

architecture Behavioral of tb_state_mappers is

  component state_mapper_9d_to_7d is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      x_pos_in, x_vel_in, x_acc_in : in signed(47 downto 0);
      y_pos_in, y_vel_in, y_acc_in : in signed(47 downto 0);
      z_pos_in, z_vel_in, z_acc_in : in signed(47 downto 0);
      px_out, py_out, v_out, theta_out, delta_out, a_out, z_out : out signed(47 downto 0);
      done  : out std_logic
    );
  end component;

  component state_mapper_7d_to_9d is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      px_in, py_in, v_in, theta_in, delta_in, a_in, z_in : in signed(47 downto 0);
      x_pos_out, x_vel_out, x_acc_out : out signed(47 downto 0);
      y_pos_out, y_vel_out, y_acc_out : out signed(47 downto 0);
      z_pos_out, z_vel_out, z_acc_out : out signed(47 downto 0);
      done  : out std_logic
    );
  end component;

  constant CLK_PERIOD : time := 10 ns;
  constant Q : integer := 24;
  constant SCALE : real := 2.0**Q;

  signal clk : std_logic := '0';
  signal all_tests_done : boolean := false;

  signal fwd_start, fwd_done : std_logic := '0';
  signal fwd_xp, fwd_xv, fwd_xa : signed(47 downto 0) := (others => '0');
  signal fwd_yp, fwd_yv, fwd_ya : signed(47 downto 0) := (others => '0');
  signal fwd_zp, fwd_zv, fwd_za : signed(47 downto 0) := (others => '0');
  signal fwd_px, fwd_py, fwd_v, fwd_theta, fwd_delta, fwd_a, fwd_z : signed(47 downto 0);

  signal rev_start, rev_done : std_logic := '0';
  signal rev_px, rev_py, rev_v, rev_theta, rev_delta, rev_a, rev_z : signed(47 downto 0) := (others => '0');
  signal rev_xp, rev_xv, rev_xa : signed(47 downto 0);
  signal rev_yp, rev_yv, rev_ya : signed(47 downto 0);
  signal rev_zp, rev_zv, rev_za : signed(47 downto 0);

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

  u_9d_to_7d : state_mapper_9d_to_7d port map (
    clk => clk, start => fwd_start,
    x_pos_in => fwd_xp, x_vel_in => fwd_xv, x_acc_in => fwd_xa,
    y_pos_in => fwd_yp, y_vel_in => fwd_yv, y_acc_in => fwd_ya,
    z_pos_in => fwd_zp, z_vel_in => fwd_zv, z_acc_in => fwd_za,
    px_out => fwd_px, py_out => fwd_py, v_out => fwd_v,
    theta_out => fwd_theta, delta_out => fwd_delta,
    a_out => fwd_a, z_out => fwd_z, done => fwd_done
  );

  u_7d_to_9d : state_mapper_7d_to_9d port map (
    clk => clk, start => rev_start,
    px_in => rev_px, py_in => rev_py, v_in => rev_v,
    theta_in => rev_theta, delta_in => rev_delta,
    a_in => rev_a, z_in => rev_z,
    x_pos_out => rev_xp, x_vel_out => rev_xv, x_acc_out => rev_xa,
    y_pos_out => rev_yp, y_vel_out => rev_yv, y_acc_out => rev_ya,
    z_pos_out => rev_zp, z_vel_out => rev_zv, z_acc_out => rev_za,
    done => rev_done
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
    variable v_real, theta_real, a_real : real;
    variable rt_err_x, rt_err_y : real;
  begin
    report "=== TEST 6: state_mappers (9D <-> 7D) ===";
    wait for CLK_PERIOD * 3;

    fwd_xp <= to_q24(10.0);  fwd_xv <= to_q24(3.0);  fwd_xa <= to_q24(1.0);
    fwd_yp <= to_q24(20.0);  fwd_yv <= to_q24(4.0);  fwd_ya <= to_q24(0.0);
    fwd_zp <= to_q24(5.0);   fwd_zv <= to_q24(0.0);  fwd_za <= to_q24(0.0);

    fwd_start <= '1';
    wait until rising_edge(clk);
    fwd_start <= '0';
    wait until fwd_done = '1' for 50 us;

    if fwd_done /= '1' then
      report "  [FAIL] 9D->7D: TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    else
      v_real := from_q24(fwd_v);
      theta_real := from_q24(fwd_theta);
      a_real := from_q24(fwd_a);

      report "  9D->7D: v=" & real'image(v_real) &
             " theta=" & real'image(theta_real) &
             " a=" & real'image(a_real) &
             " px=" & real'image(from_q24(fwd_px)) &
             " py=" & real'image(from_q24(fwd_py));

      if check_result(fwd_v, to_q24(5.0), 1.0) then
        report "  [PASS] v = 5.0: got=" & real'image(v_real);
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] v: got=" & real'image(v_real) & " expected=5.0" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if abs(theta_real - 0.9273) < 0.02 then
        report "  [PASS] theta = 0.927: got=" & real'image(theta_real);
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] theta: got=" & real'image(theta_real) & " expected=0.9273" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if check_result(fwd_px, to_q24(10.0), 0.1) then
        report "  [PASS] px passthrough = 10.0";
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] px passthrough: got=" & real'image(from_q24(fwd_px)) severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if abs(a_real - 0.6) < 0.05 then
        report "  [PASS] a = 0.6: got=" & real'image(a_real);
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] a: got=" & real'image(a_real) & " expected=0.6" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if abs(from_q24(fwd_delta)) < 0.001 then
        report "  [PASS] delta = 0";
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] delta should be 0: got=" & real'image(from_q24(fwd_delta)) severity error;
        tests_failed <= tests_failed + 1;
      end if;
    end if;
    wait for CLK_PERIOD * 5;

    rev_px    <= to_q24(10.0);
    rev_py    <= to_q24(20.0);
    rev_v     <= to_q24(5.0);
    rev_theta <= to_q24(0.9273);
    rev_delta <= to_q24(0.0);
    rev_a     <= to_q24(0.6);
    rev_z     <= to_q24(5.0);

    rev_start <= '1';
    wait until rising_edge(clk);
    rev_start <= '0';
    wait until rev_done = '1' for 50 us;

    if rev_done /= '1' then
      report "  [FAIL] 7D->9D: TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    else
      report "  7D->9D: xv=" & real'image(from_q24(rev_xv)) &
             " yv=" & real'image(from_q24(rev_yv)) &
             " xa=" & real'image(from_q24(rev_xa)) &
             " ya=" & real'image(from_q24(rev_ya));

      if check_result(rev_xv, to_q24(3.0), 2.0) then
        report "  [PASS] x_vel ~ 3.0: got=" & real'image(from_q24(rev_xv));
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] x_vel: got=" & real'image(from_q24(rev_xv)) & " expected ~3.0" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if check_result(rev_yv, to_q24(4.0), 2.0) then
        report "  [PASS] y_vel ~ 4.0: got=" & real'image(from_q24(rev_yv));
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] y_vel: got=" & real'image(from_q24(rev_yv)) & " expected ~4.0" severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if abs(from_q24(rev_zv)) < 0.001 and abs(from_q24(rev_za)) < 0.001 then
        report "  [PASS] z_vel=0, z_acc=0";
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] z_vel or z_acc non-zero" severity error;
        tests_failed <= tests_failed + 1;
      end if;
    end if;
    wait for CLK_PERIOD * 5;

    rev_px    <= fwd_px;
    rev_py    <= fwd_py;
    rev_v     <= fwd_v;
    rev_theta <= fwd_theta;
    rev_delta <= fwd_delta;
    rev_a     <= fwd_a;
    rev_z     <= fwd_z;

    rev_start <= '1';
    wait until rising_edge(clk);
    rev_start <= '0';
    wait until rev_done = '1' for 50 us;

    if rev_done /= '1' then
      report "  [FAIL] Round-trip: TIMEOUT" severity error;
      tests_failed <= tests_failed + 1;
    else
      rt_err_x := abs(from_q24(rev_xv) - 3.0);
      rt_err_y := abs(from_q24(rev_yv) - 4.0);

      report "  Round-trip: xv_recovered=" & real'image(from_q24(rev_xv)) &
             " yv_recovered=" & real'image(from_q24(rev_yv));

      if check_result(rev_xp, to_q24(10.0), 0.1) then
        report "  [PASS] Round-trip position exact: x_pos=10.0";
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] Round-trip x_pos: got=" & real'image(from_q24(rev_xp)) severity error;
        tests_failed <= tests_failed + 1;
      end if;

      if rt_err_x < 0.1 and rt_err_y < 0.1 then
        report "  [PASS] Round-trip velocity error < 0.1m/s: dx=" &
               real'image(rt_err_x) & " dy=" & real'image(rt_err_y);
        tests_passed <= tests_passed + 1;
      else
        report "  [FAIL] Round-trip velocity error too large: dx=" &
               real'image(rt_err_x) & " dy=" & real'image(rt_err_y) severity error;
        tests_failed <= tests_failed + 1;
      end if;
    end if;

    report "=== TEST 6 RESULTS: " & integer'image(tests_passed) & " PASS, " &
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
