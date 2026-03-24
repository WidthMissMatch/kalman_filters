library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity predicti_bicycle is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    start : in  std_logic;

    chi0_px_in, chi0_py_in, chi0_v_in, chi0_theta_in, chi0_delta_in, chi0_a_in, chi0_z_in : in signed(47 downto 0);
    chi1_px_in, chi1_py_in, chi1_v_in, chi1_theta_in, chi1_delta_in, chi1_a_in, chi1_z_in : in signed(47 downto 0);
    chi2_px_in, chi2_py_in, chi2_v_in, chi2_theta_in, chi2_delta_in, chi2_a_in, chi2_z_in : in signed(47 downto 0);
    chi3_px_in, chi3_py_in, chi3_v_in, chi3_theta_in, chi3_delta_in, chi3_a_in, chi3_z_in : in signed(47 downto 0);
    chi4_px_in, chi4_py_in, chi4_v_in, chi4_theta_in, chi4_delta_in, chi4_a_in, chi4_z_in : in signed(47 downto 0);
    chi5_px_in, chi5_py_in, chi5_v_in, chi5_theta_in, chi5_delta_in, chi5_a_in, chi5_z_in : in signed(47 downto 0);
    chi6_px_in, chi6_py_in, chi6_v_in, chi6_theta_in, chi6_delta_in, chi6_a_in, chi6_z_in : in signed(47 downto 0);
    chi7_px_in, chi7_py_in, chi7_v_in, chi7_theta_in, chi7_delta_in, chi7_a_in, chi7_z_in : in signed(47 downto 0);
    chi8_px_in, chi8_py_in, chi8_v_in, chi8_theta_in, chi8_delta_in, chi8_a_in, chi8_z_in : in signed(47 downto 0);
    chi9_px_in, chi9_py_in, chi9_v_in, chi9_theta_in, chi9_delta_in, chi9_a_in, chi9_z_in : in signed(47 downto 0);
    chi10_px_in, chi10_py_in, chi10_v_in, chi10_theta_in, chi10_delta_in, chi10_a_in, chi10_z_in : in signed(47 downto 0);
    chi11_px_in, chi11_py_in, chi11_v_in, chi11_theta_in, chi11_delta_in, chi11_a_in, chi11_z_in : in signed(47 downto 0);
    chi12_px_in, chi12_py_in, chi12_v_in, chi12_theta_in, chi12_delta_in, chi12_a_in, chi12_z_in : in signed(47 downto 0);
    chi13_px_in, chi13_py_in, chi13_v_in, chi13_theta_in, chi13_delta_in, chi13_a_in, chi13_z_in : in signed(47 downto 0);
    chi14_px_in, chi14_py_in, chi14_v_in, chi14_theta_in, chi14_delta_in, chi14_a_in, chi14_z_in : in signed(47 downto 0);

    chi0_px_out, chi0_py_out, chi0_v_out, chi0_theta_out, chi0_delta_out, chi0_a_out, chi0_z_out : out signed(47 downto 0);
    chi1_px_out, chi1_py_out, chi1_v_out, chi1_theta_out, chi1_delta_out, chi1_a_out, chi1_z_out : out signed(47 downto 0);
    chi2_px_out, chi2_py_out, chi2_v_out, chi2_theta_out, chi2_delta_out, chi2_a_out, chi2_z_out : out signed(47 downto 0);
    chi3_px_out, chi3_py_out, chi3_v_out, chi3_theta_out, chi3_delta_out, chi3_a_out, chi3_z_out : out signed(47 downto 0);
    chi4_px_out, chi4_py_out, chi4_v_out, chi4_theta_out, chi4_delta_out, chi4_a_out, chi4_z_out : out signed(47 downto 0);
    chi5_px_out, chi5_py_out, chi5_v_out, chi5_theta_out, chi5_delta_out, chi5_a_out, chi5_z_out : out signed(47 downto 0);
    chi6_px_out, chi6_py_out, chi6_v_out, chi6_theta_out, chi6_delta_out, chi6_a_out, chi6_z_out : out signed(47 downto 0);
    chi7_px_out, chi7_py_out, chi7_v_out, chi7_theta_out, chi7_delta_out, chi7_a_out, chi7_z_out : out signed(47 downto 0);
    chi8_px_out, chi8_py_out, chi8_v_out, chi8_theta_out, chi8_delta_out, chi8_a_out, chi8_z_out : out signed(47 downto 0);
    chi9_px_out, chi9_py_out, chi9_v_out, chi9_theta_out, chi9_delta_out, chi9_a_out, chi9_z_out : out signed(47 downto 0);
    chi10_px_out, chi10_py_out, chi10_v_out, chi10_theta_out, chi10_delta_out, chi10_a_out, chi10_z_out : out signed(47 downto 0);
    chi11_px_out, chi11_py_out, chi11_v_out, chi11_theta_out, chi11_delta_out, chi11_a_out, chi11_z_out : out signed(47 downto 0);
    chi12_px_out, chi12_py_out, chi12_v_out, chi12_theta_out, chi12_delta_out, chi12_a_out, chi12_z_out : out signed(47 downto 0);
    chi13_px_out, chi13_py_out, chi13_v_out, chi13_theta_out, chi13_delta_out, chi13_a_out, chi13_z_out : out signed(47 downto 0);
    chi14_px_out, chi14_py_out, chi14_v_out, chi14_theta_out, chi14_delta_out, chi14_a_out, chi14_z_out : out signed(47 downto 0);

    done  : out std_logic
  );
end entity;

architecture Behavioral of predicti_bicycle is

  component sin_cos_cordic is
    port (
      clk       : in  std_logic;
      start     : in  std_logic;
      angle_in  : in  signed(47 downto 0);
      sin_out   : out signed(47 downto 0);
      cos_out   : out signed(47 downto 0);
      done      : out std_logic
    );
  end component;

  constant Q      : integer := 24;

  constant DT_Q24 : signed(47 downto 0) := to_signed(335544, 48);

  constant LR_OVER_L : signed(47 downto 0) := to_signed(7456540, 48);

  constant INV_L     : signed(47 downto 0) := to_signed(4660337, 48);

  type main_state_t is (
    IDLE,
    LATCH_POINT,
    COMPUTE_BETA_ANGLE,
    START_CORDIC,
    WAIT_CORDIC,
    COMPUTE_PROPAGATION,
    STORE_RESULT,
    NEXT_POINT,
    FINISHED
  );
  signal state : main_state_t := IDLE;

  signal point_idx : integer range 0 to 14 := 0;

  signal cur_px, cur_py, cur_v, cur_theta, cur_delta, cur_a, cur_z : signed(47 downto 0);

  signal beta : signed(47 downto 0);
  signal angle_for_cordic : signed(47 downto 0);
  signal sin_th_beta, cos_th_beta : signed(47 downto 0);

  signal cordic_start : std_logic := '0';
  signal cordic_angle : signed(47 downto 0);
  signal cordic_sin, cordic_cos : signed(47 downto 0);
  signal cordic_done : std_logic;

  type state_array_t is array (0 to 14) of signed(47 downto 0);
  signal out_px, out_py, out_v, out_theta, out_delta, out_a, out_z : state_array_t;

  type sigma_array_t is array (0 to 14, 0 to 6) of signed(47 downto 0);
  signal sigma_in : sigma_array_t;

  function q_mul(a, b : signed(47 downto 0)) return signed is
    variable prod : signed(95 downto 0);
  begin
    prod := a * b;
    return resize(shift_right(prod, Q), 48);
  end function;

  constant PI_Q24     : signed(47 downto 0) := to_signed(52707178, 48);
  constant TWO_PI_Q24 : signed(47 downto 0) := to_signed(105414357, 48);

  function wrap_angle(angle : signed(47 downto 0)) return signed is
    variable result : signed(47 downto 0);
  begin
    result := angle;
    for i in 0 to 127 loop
      if result > PI_Q24 then
        result := result - TWO_PI_Q24;
      elsif result < -PI_Q24 then
        result := result + TWO_PI_Q24;
      else
        exit;
      end if;
    end loop;
    return result;
  end function;

begin

  cordic_inst : sin_cos_cordic
    port map (
      clk       => clk,
      start     => cordic_start,
      angle_in  => cordic_angle,
      sin_out   => cordic_sin,
      cos_out   => cordic_cos,
      done      => cordic_done
    );

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= IDLE;
        done <= '0';
        cordic_start <= '0';
      else
        case state is

          when IDLE =>
            done <= '0';
            cordic_start <= '0';
            if start = '1' then

              sigma_in(0, 0) <= chi0_px_in;  sigma_in(0, 1) <= chi0_py_in;
              sigma_in(0, 2) <= chi0_v_in;   sigma_in(0, 3) <= chi0_theta_in;
              sigma_in(0, 4) <= chi0_delta_in; sigma_in(0, 5) <= chi0_a_in;
              sigma_in(0, 6) <= chi0_z_in;

              sigma_in(1, 0) <= chi1_px_in;  sigma_in(1, 1) <= chi1_py_in;
              sigma_in(1, 2) <= chi1_v_in;   sigma_in(1, 3) <= chi1_theta_in;
              sigma_in(1, 4) <= chi1_delta_in; sigma_in(1, 5) <= chi1_a_in;
              sigma_in(1, 6) <= chi1_z_in;

              sigma_in(2, 0) <= chi2_px_in;  sigma_in(2, 1) <= chi2_py_in;
              sigma_in(2, 2) <= chi2_v_in;   sigma_in(2, 3) <= chi2_theta_in;
              sigma_in(2, 4) <= chi2_delta_in; sigma_in(2, 5) <= chi2_a_in;
              sigma_in(2, 6) <= chi2_z_in;

              sigma_in(3, 0) <= chi3_px_in;  sigma_in(3, 1) <= chi3_py_in;
              sigma_in(3, 2) <= chi3_v_in;   sigma_in(3, 3) <= chi3_theta_in;
              sigma_in(3, 4) <= chi3_delta_in; sigma_in(3, 5) <= chi3_a_in;
              sigma_in(3, 6) <= chi3_z_in;

              sigma_in(4, 0) <= chi4_px_in;  sigma_in(4, 1) <= chi4_py_in;
              sigma_in(4, 2) <= chi4_v_in;   sigma_in(4, 3) <= chi4_theta_in;
              sigma_in(4, 4) <= chi4_delta_in; sigma_in(4, 5) <= chi4_a_in;
              sigma_in(4, 6) <= chi4_z_in;

              sigma_in(5, 0) <= chi5_px_in;  sigma_in(5, 1) <= chi5_py_in;
              sigma_in(5, 2) <= chi5_v_in;   sigma_in(5, 3) <= chi5_theta_in;
              sigma_in(5, 4) <= chi5_delta_in; sigma_in(5, 5) <= chi5_a_in;
              sigma_in(5, 6) <= chi5_z_in;

              sigma_in(6, 0) <= chi6_px_in;  sigma_in(6, 1) <= chi6_py_in;
              sigma_in(6, 2) <= chi6_v_in;   sigma_in(6, 3) <= chi6_theta_in;
              sigma_in(6, 4) <= chi6_delta_in; sigma_in(6, 5) <= chi6_a_in;
              sigma_in(6, 6) <= chi6_z_in;

              sigma_in(7, 0) <= chi7_px_in;  sigma_in(7, 1) <= chi7_py_in;
              sigma_in(7, 2) <= chi7_v_in;   sigma_in(7, 3) <= chi7_theta_in;
              sigma_in(7, 4) <= chi7_delta_in; sigma_in(7, 5) <= chi7_a_in;
              sigma_in(7, 6) <= chi7_z_in;

              sigma_in(8, 0) <= chi8_px_in;  sigma_in(8, 1) <= chi8_py_in;
              sigma_in(8, 2) <= chi8_v_in;   sigma_in(8, 3) <= chi8_theta_in;
              sigma_in(8, 4) <= chi8_delta_in; sigma_in(8, 5) <= chi8_a_in;
              sigma_in(8, 6) <= chi8_z_in;

              sigma_in(9, 0) <= chi9_px_in;  sigma_in(9, 1) <= chi9_py_in;
              sigma_in(9, 2) <= chi9_v_in;   sigma_in(9, 3) <= chi9_theta_in;
              sigma_in(9, 4) <= chi9_delta_in; sigma_in(9, 5) <= chi9_a_in;
              sigma_in(9, 6) <= chi9_z_in;

              sigma_in(10, 0) <= chi10_px_in;  sigma_in(10, 1) <= chi10_py_in;
              sigma_in(10, 2) <= chi10_v_in;   sigma_in(10, 3) <= chi10_theta_in;
              sigma_in(10, 4) <= chi10_delta_in; sigma_in(10, 5) <= chi10_a_in;
              sigma_in(10, 6) <= chi10_z_in;

              sigma_in(11, 0) <= chi11_px_in;  sigma_in(11, 1) <= chi11_py_in;
              sigma_in(11, 2) <= chi11_v_in;   sigma_in(11, 3) <= chi11_theta_in;
              sigma_in(11, 4) <= chi11_delta_in; sigma_in(11, 5) <= chi11_a_in;
              sigma_in(11, 6) <= chi11_z_in;

              sigma_in(12, 0) <= chi12_px_in;  sigma_in(12, 1) <= chi12_py_in;
              sigma_in(12, 2) <= chi12_v_in;   sigma_in(12, 3) <= chi12_theta_in;
              sigma_in(12, 4) <= chi12_delta_in; sigma_in(12, 5) <= chi12_a_in;
              sigma_in(12, 6) <= chi12_z_in;

              sigma_in(13, 0) <= chi13_px_in;  sigma_in(13, 1) <= chi13_py_in;
              sigma_in(13, 2) <= chi13_v_in;   sigma_in(13, 3) <= chi13_theta_in;
              sigma_in(13, 4) <= chi13_delta_in; sigma_in(13, 5) <= chi13_a_in;
              sigma_in(13, 6) <= chi13_z_in;

              sigma_in(14, 0) <= chi14_px_in;  sigma_in(14, 1) <= chi14_py_in;
              sigma_in(14, 2) <= chi14_v_in;   sigma_in(14, 3) <= chi14_theta_in;
              sigma_in(14, 4) <= chi14_delta_in; sigma_in(14, 5) <= chi14_a_in;
              sigma_in(14, 6) <= chi14_z_in;

              point_idx <= 0;
              state <= LATCH_POINT;
            end if;

          when LATCH_POINT =>

            cur_px    <= sigma_in(point_idx, 0);
            cur_py    <= sigma_in(point_idx, 1);
            cur_v     <= sigma_in(point_idx, 2);
            cur_theta <= sigma_in(point_idx, 3);
            cur_delta <= sigma_in(point_idx, 4);
            cur_a     <= sigma_in(point_idx, 5);
            cur_z     <= sigma_in(point_idx, 6);
            state <= COMPUTE_BETA_ANGLE;

          when COMPUTE_BETA_ANGLE =>

            beta <= q_mul(LR_OVER_L, cur_delta);

            angle_for_cordic <= cur_theta + q_mul(LR_OVER_L, cur_delta);

            cordic_angle <= cur_theta + q_mul(LR_OVER_L, cur_delta);
            cordic_start <= '1';
            state <= START_CORDIC;

          when START_CORDIC =>

            cordic_start <= '0';
            state <= WAIT_CORDIC;

          when WAIT_CORDIC =>
            if cordic_done = '1' then
              sin_th_beta <= cordic_sin;
              cos_th_beta <= cordic_cos;
              state <= COMPUTE_PROPAGATION;
            end if;

          when COMPUTE_PROPAGATION =>

            out_v(point_idx) <= cur_v + q_mul(cur_a, DT_Q24);

            out_theta(point_idx) <= wrap_angle(cur_theta + q_mul(q_mul(q_mul(cur_v, cur_delta), INV_L), DT_Q24));

            out_px(point_idx) <= cur_px + q_mul(q_mul(cur_v, cos_th_beta), DT_Q24);

            out_py(point_idx) <= cur_py + q_mul(q_mul(cur_v, sin_th_beta), DT_Q24);

            out_delta(point_idx) <= cur_delta;

            out_a(point_idx) <= cur_a;

            out_z(point_idx) <= cur_z;

            state <= STORE_RESULT;

          when STORE_RESULT =>

            state <= NEXT_POINT;

          when NEXT_POINT =>
            if point_idx = 14 then
              state <= FINISHED;
            else
              point_idx <= point_idx + 1;
              state <= LATCH_POINT;
            end if;

          when FINISHED =>
            done <= '1';
            if start = '0' then
              state <= IDLE;
            end if;

          when others =>
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;

  chi0_px_out <= out_px(0);  chi0_py_out <= out_py(0);  chi0_v_out <= out_v(0);
  chi0_theta_out <= out_theta(0); chi0_delta_out <= out_delta(0);
  chi0_a_out <= out_a(0);    chi0_z_out <= out_z(0);

  chi1_px_out <= out_px(1);  chi1_py_out <= out_py(1);  chi1_v_out <= out_v(1);
  chi1_theta_out <= out_theta(1); chi1_delta_out <= out_delta(1);
  chi1_a_out <= out_a(1);    chi1_z_out <= out_z(1);

  chi2_px_out <= out_px(2);  chi2_py_out <= out_py(2);  chi2_v_out <= out_v(2);
  chi2_theta_out <= out_theta(2); chi2_delta_out <= out_delta(2);
  chi2_a_out <= out_a(2);    chi2_z_out <= out_z(2);

  chi3_px_out <= out_px(3);  chi3_py_out <= out_py(3);  chi3_v_out <= out_v(3);
  chi3_theta_out <= out_theta(3); chi3_delta_out <= out_delta(3);
  chi3_a_out <= out_a(3);    chi3_z_out <= out_z(3);

  chi4_px_out <= out_px(4);  chi4_py_out <= out_py(4);  chi4_v_out <= out_v(4);
  chi4_theta_out <= out_theta(4); chi4_delta_out <= out_delta(4);
  chi4_a_out <= out_a(4);    chi4_z_out <= out_z(4);

  chi5_px_out <= out_px(5);  chi5_py_out <= out_py(5);  chi5_v_out <= out_v(5);
  chi5_theta_out <= out_theta(5); chi5_delta_out <= out_delta(5);
  chi5_a_out <= out_a(5);    chi5_z_out <= out_z(5);

  chi6_px_out <= out_px(6);  chi6_py_out <= out_py(6);  chi6_v_out <= out_v(6);
  chi6_theta_out <= out_theta(6); chi6_delta_out <= out_delta(6);
  chi6_a_out <= out_a(6);    chi6_z_out <= out_z(6);

  chi7_px_out <= out_px(7);  chi7_py_out <= out_py(7);  chi7_v_out <= out_v(7);
  chi7_theta_out <= out_theta(7); chi7_delta_out <= out_delta(7);
  chi7_a_out <= out_a(7);    chi7_z_out <= out_z(7);

  chi8_px_out <= out_px(8);  chi8_py_out <= out_py(8);  chi8_v_out <= out_v(8);
  chi8_theta_out <= out_theta(8); chi8_delta_out <= out_delta(8);
  chi8_a_out <= out_a(8);    chi8_z_out <= out_z(8);

  chi9_px_out <= out_px(9);  chi9_py_out <= out_py(9);  chi9_v_out <= out_v(9);
  chi9_theta_out <= out_theta(9); chi9_delta_out <= out_delta(9);
  chi9_a_out <= out_a(9);    chi9_z_out <= out_z(9);

  chi10_px_out <= out_px(10);  chi10_py_out <= out_py(10);  chi10_v_out <= out_v(10);
  chi10_theta_out <= out_theta(10); chi10_delta_out <= out_delta(10);
  chi10_a_out <= out_a(10);    chi10_z_out <= out_z(10);

  chi11_px_out <= out_px(11);  chi11_py_out <= out_py(11);  chi11_v_out <= out_v(11);
  chi11_theta_out <= out_theta(11); chi11_delta_out <= out_delta(11);
  chi11_a_out <= out_a(11);    chi11_z_out <= out_z(11);

  chi12_px_out <= out_px(12);  chi12_py_out <= out_py(12);  chi12_v_out <= out_v(12);
  chi12_theta_out <= out_theta(12); chi12_delta_out <= out_delta(12);
  chi12_a_out <= out_a(12);    chi12_z_out <= out_z(12);

  chi13_px_out <= out_px(13);  chi13_py_out <= out_py(13);  chi13_v_out <= out_v(13);
  chi13_theta_out <= out_theta(13); chi13_delta_out <= out_delta(13);
  chi13_a_out <= out_a(13);    chi13_z_out <= out_z(13);

  chi14_px_out <= out_px(14);  chi14_py_out <= out_py(14);  chi14_v_out <= out_v(14);
  chi14_theta_out <= out_theta(14); chi14_delta_out <= out_delta(14);
  chi14_a_out <= out_a(14);    chi14_z_out <= out_z(14);

end Behavioral;
