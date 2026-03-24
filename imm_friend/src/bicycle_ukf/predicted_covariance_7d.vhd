library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity predicted_covariance_7d is
  port (
    clk   : in  std_logic;
    start : in  std_logic;

    s1_mean, s2_mean, s3_mean, s4_mean, s5_mean, s6_mean, s7_mean : in signed(47 downto 0);

    chi0_s1, chi0_s2, chi0_s3, chi0_s4, chi0_s5, chi0_s6, chi0_s7 : in signed(47 downto 0);
    chi1_s1, chi1_s2, chi1_s3, chi1_s4, chi1_s5, chi1_s6, chi1_s7 : in signed(47 downto 0);
    chi2_s1, chi2_s2, chi2_s3, chi2_s4, chi2_s5, chi2_s6, chi2_s7 : in signed(47 downto 0);
    chi3_s1, chi3_s2, chi3_s3, chi3_s4, chi3_s5, chi3_s6, chi3_s7 : in signed(47 downto 0);
    chi4_s1, chi4_s2, chi4_s3, chi4_s4, chi4_s5, chi4_s6, chi4_s7 : in signed(47 downto 0);
    chi5_s1, chi5_s2, chi5_s3, chi5_s4, chi5_s5, chi5_s6, chi5_s7 : in signed(47 downto 0);
    chi6_s1, chi6_s2, chi6_s3, chi6_s4, chi6_s5, chi6_s6, chi6_s7 : in signed(47 downto 0);
    chi7_s1, chi7_s2, chi7_s3, chi7_s4, chi7_s5, chi7_s6, chi7_s7 : in signed(47 downto 0);
    chi8_s1, chi8_s2, chi8_s3, chi8_s4, chi8_s5, chi8_s6, chi8_s7 : in signed(47 downto 0);
    chi9_s1, chi9_s2, chi9_s3, chi9_s4, chi9_s5, chi9_s6, chi9_s7 : in signed(47 downto 0);
    chi10_s1, chi10_s2, chi10_s3, chi10_s4, chi10_s5, chi10_s6, chi10_s7 : in signed(47 downto 0);
    chi11_s1, chi11_s2, chi11_s3, chi11_s4, chi11_s5, chi11_s6, chi11_s7 : in signed(47 downto 0);
    chi12_s1, chi12_s2, chi12_s3, chi12_s4, chi12_s5, chi12_s6, chi12_s7 : in signed(47 downto 0);
    chi13_s1, chi13_s2, chi13_s3, chi13_s4, chi13_s5, chi13_s6, chi13_s7 : in signed(47 downto 0);
    chi14_s1, chi14_s2, chi14_s3, chi14_s4, chi14_s5, chi14_s6, chi14_s7 : in signed(47 downto 0);

    p11_out, p12_out, p13_out, p14_out, p15_out, p16_out, p17_out : buffer signed(47 downto 0);
    p22_out, p23_out, p24_out, p25_out, p26_out, p27_out : buffer signed(47 downto 0);
    p33_out, p34_out, p35_out, p36_out, p37_out : buffer signed(47 downto 0);
    p44_out, p45_out, p46_out, p47_out : buffer signed(47 downto 0);
    p55_out, p56_out, p57_out : buffer signed(47 downto 0);
    p66_out, p67_out : buffer signed(47 downto 0);
    p77_out : buffer signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of predicted_covariance_7d is

  type state_type is (IDLE, COMPUTE_DEV, COMPUTE_OUTER, WEIGHT_ACC, CHECK_NEXT, OUTPUT_RESULT, FINISHED);
  signal state : state_type := IDLE;

  constant Q_BITS : integer := 24;

  constant WC0 : signed(47 downto 0) := to_signed(33554432, 48);
  constant WC1 : signed(47 downto 0) := to_signed(1198373, 48);

  type sigma_state_array is array(0 to 14) of signed(47 downto 0);
  signal chi_s1, chi_s2, chi_s3, chi_s4, chi_s5, chi_s6, chi_s7 : sigma_state_array;

  type weight_array is array(0 to 14) of signed(47 downto 0);
  constant WEIGHTS : weight_array := (WC0, WC1, WC1, WC1, WC1, WC1, WC1, WC1,
                                      WC1, WC1, WC1, WC1, WC1, WC1, WC1);

  signal idx : integer range 0 to 14 := 0;

  signal m1, m2, m3, m4, m5, m6, m7 : signed(47 downto 0);

  signal d1, d2, d3, d4, d5, d6, d7 : signed(47 downto 0);

  signal w_cur : signed(47 downto 0);

  signal o11, o12, o13, o14, o15, o16, o17 : signed(95 downto 0);
  signal o22, o23, o24, o25, o26, o27 : signed(95 downto 0);
  signal o33, o34, o35, o36, o37 : signed(95 downto 0);
  signal o44, o45, o46, o47 : signed(95 downto 0);
  signal o55, o56, o57 : signed(95 downto 0);
  signal o66, o67 : signed(95 downto 0);
  signal o77 : signed(95 downto 0);

  signal acc11, acc12, acc13, acc14, acc15, acc16, acc17 : signed(95 downto 0);
  signal acc22, acc23, acc24, acc25, acc26, acc27 : signed(95 downto 0);
  signal acc33, acc34, acc35, acc36, acc37 : signed(95 downto 0);
  signal acc44, acc45, acc46, acc47 : signed(95 downto 0);
  signal acc55, acc56, acc57 : signed(95 downto 0);
  signal acc66, acc67 : signed(95 downto 0);
  signal acc77 : signed(95 downto 0);

  constant MAX_P : signed(47 downto 0) := signed'(X"3FFFFFFFFFFF");
  constant MIN_P : signed(47 downto 0) := signed'(X"C00000000000");
  constant UNITY : signed(47 downto 0) := to_signed(16777216, 48);

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

  function sat_p(val : signed(95 downto 0); is_diag : boolean) return signed is
    variable result : signed(47 downto 0);
    constant MAX_P_WIDE : signed(95 downto 0) := resize(MAX_P, 96);
    constant MIN_P_WIDE : signed(95 downto 0) := resize(MIN_P, 96);
    constant UNITY_WIDE : signed(95 downto 0) := resize(UNITY, 96);
  begin
    if val > MAX_P_WIDE then result := MAX_P;
    elsif is_diag and val < UNITY_WIDE then result := UNITY;
    elsif val < MIN_P_WIDE then result := MIN_P;
    else result := resize(val, 48);
    end if;
    return result;
  end function;

begin

  process(clk)
    variable w_prod : signed(143 downto 0);
  begin
    if rising_edge(clk) then
      case state is

        when IDLE =>
          done <= '0';
          idx <= 0;
          if start = '1' then

            m1 <= s1_mean; m2 <= s2_mean; m3 <= s3_mean; m4 <= s4_mean;
            m5 <= s5_mean; m6 <= s6_mean; m7 <= s7_mean;

            chi_s1(0)  <= chi0_s1;  chi_s2(0)  <= chi0_s2;  chi_s3(0)  <= chi0_s3;
            chi_s4(0)  <= chi0_s4;  chi_s5(0)  <= chi0_s5;  chi_s6(0)  <= chi0_s6;  chi_s7(0)  <= chi0_s7;
            chi_s1(1)  <= chi1_s1;  chi_s2(1)  <= chi1_s2;  chi_s3(1)  <= chi1_s3;
            chi_s4(1)  <= chi1_s4;  chi_s5(1)  <= chi1_s5;  chi_s6(1)  <= chi1_s6;  chi_s7(1)  <= chi1_s7;
            chi_s1(2)  <= chi2_s1;  chi_s2(2)  <= chi2_s2;  chi_s3(2)  <= chi2_s3;
            chi_s4(2)  <= chi2_s4;  chi_s5(2)  <= chi2_s5;  chi_s6(2)  <= chi2_s6;  chi_s7(2)  <= chi2_s7;
            chi_s1(3)  <= chi3_s1;  chi_s2(3)  <= chi3_s2;  chi_s3(3)  <= chi3_s3;
            chi_s4(3)  <= chi3_s4;  chi_s5(3)  <= chi3_s5;  chi_s6(3)  <= chi3_s6;  chi_s7(3)  <= chi3_s7;
            chi_s1(4)  <= chi4_s1;  chi_s2(4)  <= chi4_s2;  chi_s3(4)  <= chi4_s3;
            chi_s4(4)  <= chi4_s4;  chi_s5(4)  <= chi4_s5;  chi_s6(4)  <= chi4_s6;  chi_s7(4)  <= chi4_s7;
            chi_s1(5)  <= chi5_s1;  chi_s2(5)  <= chi5_s2;  chi_s3(5)  <= chi5_s3;
            chi_s4(5)  <= chi5_s4;  chi_s5(5)  <= chi5_s5;  chi_s6(5)  <= chi5_s6;  chi_s7(5)  <= chi5_s7;
            chi_s1(6)  <= chi6_s1;  chi_s2(6)  <= chi6_s2;  chi_s3(6)  <= chi6_s3;
            chi_s4(6)  <= chi6_s4;  chi_s5(6)  <= chi6_s5;  chi_s6(6)  <= chi6_s6;  chi_s7(6)  <= chi6_s7;
            chi_s1(7)  <= chi7_s1;  chi_s2(7)  <= chi7_s2;  chi_s3(7)  <= chi7_s3;
            chi_s4(7)  <= chi7_s4;  chi_s5(7)  <= chi7_s5;  chi_s6(7)  <= chi7_s6;  chi_s7(7)  <= chi7_s7;
            chi_s1(8)  <= chi8_s1;  chi_s2(8)  <= chi8_s2;  chi_s3(8)  <= chi8_s3;
            chi_s4(8)  <= chi8_s4;  chi_s5(8)  <= chi8_s5;  chi_s6(8)  <= chi8_s6;  chi_s7(8)  <= chi8_s7;
            chi_s1(9)  <= chi9_s1;  chi_s2(9)  <= chi9_s2;  chi_s3(9)  <= chi9_s3;
            chi_s4(9)  <= chi9_s4;  chi_s5(9)  <= chi9_s5;  chi_s6(9)  <= chi9_s6;  chi_s7(9)  <= chi9_s7;
            chi_s1(10) <= chi10_s1; chi_s2(10) <= chi10_s2; chi_s3(10) <= chi10_s3;
            chi_s4(10) <= chi10_s4; chi_s5(10) <= chi10_s5; chi_s6(10) <= chi10_s6; chi_s7(10) <= chi10_s7;
            chi_s1(11) <= chi11_s1; chi_s2(11) <= chi11_s2; chi_s3(11) <= chi11_s3;
            chi_s4(11) <= chi11_s4; chi_s5(11) <= chi11_s5; chi_s6(11) <= chi11_s6; chi_s7(11) <= chi11_s7;
            chi_s1(12) <= chi12_s1; chi_s2(12) <= chi12_s2; chi_s3(12) <= chi12_s3;
            chi_s4(12) <= chi12_s4; chi_s5(12) <= chi12_s5; chi_s6(12) <= chi12_s6; chi_s7(12) <= chi12_s7;
            chi_s1(13) <= chi13_s1; chi_s2(13) <= chi13_s2; chi_s3(13) <= chi13_s3;
            chi_s4(13) <= chi13_s4; chi_s5(13) <= chi13_s5; chi_s6(13) <= chi13_s6; chi_s7(13) <= chi13_s7;
            chi_s1(14) <= chi14_s1; chi_s2(14) <= chi14_s2; chi_s3(14) <= chi14_s3;
            chi_s4(14) <= chi14_s4; chi_s5(14) <= chi14_s5; chi_s6(14) <= chi14_s6; chi_s7(14) <= chi14_s7;

            acc11 <= (others => '0'); acc12 <= (others => '0'); acc13 <= (others => '0');
            acc14 <= (others => '0'); acc15 <= (others => '0'); acc16 <= (others => '0');
            acc17 <= (others => '0');
            acc22 <= (others => '0'); acc23 <= (others => '0'); acc24 <= (others => '0');
            acc25 <= (others => '0'); acc26 <= (others => '0'); acc27 <= (others => '0');
            acc33 <= (others => '0'); acc34 <= (others => '0'); acc35 <= (others => '0');
            acc36 <= (others => '0'); acc37 <= (others => '0');
            acc44 <= (others => '0'); acc45 <= (others => '0'); acc46 <= (others => '0');
            acc47 <= (others => '0');
            acc55 <= (others => '0'); acc56 <= (others => '0'); acc57 <= (others => '0');
            acc66 <= (others => '0'); acc67 <= (others => '0');
            acc77 <= (others => '0');

            state <= COMPUTE_DEV;
          end if;

        when COMPUTE_DEV =>

          w_cur <= WEIGHTS(idx);
          d1 <= chi_s1(idx) - m1;
          d2 <= chi_s2(idx) - m2;
          d3 <= chi_s3(idx) - m3;
          d4 <= wrap_angle(chi_s4(idx) - m4);
          d5 <= chi_s5(idx) - m5;
          d6 <= chi_s6(idx) - m6;
          d7 <= chi_s7(idx) - m7;
          state <= COMPUTE_OUTER;

        when COMPUTE_OUTER =>

          o11 <= d1 * d1; o12 <= d1 * d2; o13 <= d1 * d3;
          o14 <= d1 * d4; o15 <= d1 * d5; o16 <= d1 * d6; o17 <= d1 * d7;
          o22 <= d2 * d2; o23 <= d2 * d3; o24 <= d2 * d4;
          o25 <= d2 * d5; o26 <= d2 * d6; o27 <= d2 * d7;
          o33 <= d3 * d3; o34 <= d3 * d4; o35 <= d3 * d5;
          o36 <= d3 * d6; o37 <= d3 * d7;
          o44 <= d4 * d4; o45 <= d4 * d5; o46 <= d4 * d6; o47 <= d4 * d7;
          o55 <= d5 * d5; o56 <= d5 * d6; o57 <= d5 * d7;
          o66 <= d6 * d6; o67 <= d6 * d7;
          o77 <= d7 * d7;
          state <= WEIGHT_ACC;

        when WEIGHT_ACC =>

          acc11 <= acc11 + resize(shift_right(o11 * w_cur, 2*Q_BITS), 96);
          acc12 <= acc12 + resize(shift_right(o12 * w_cur, 2*Q_BITS), 96);
          acc13 <= acc13 + resize(shift_right(o13 * w_cur, 2*Q_BITS), 96);
          acc14 <= acc14 + resize(shift_right(o14 * w_cur, 2*Q_BITS), 96);
          acc15 <= acc15 + resize(shift_right(o15 * w_cur, 2*Q_BITS), 96);
          acc16 <= acc16 + resize(shift_right(o16 * w_cur, 2*Q_BITS), 96);
          acc17 <= acc17 + resize(shift_right(o17 * w_cur, 2*Q_BITS), 96);
          acc22 <= acc22 + resize(shift_right(o22 * w_cur, 2*Q_BITS), 96);
          acc23 <= acc23 + resize(shift_right(o23 * w_cur, 2*Q_BITS), 96);
          acc24 <= acc24 + resize(shift_right(o24 * w_cur, 2*Q_BITS), 96);
          acc25 <= acc25 + resize(shift_right(o25 * w_cur, 2*Q_BITS), 96);
          acc26 <= acc26 + resize(shift_right(o26 * w_cur, 2*Q_BITS), 96);
          acc27 <= acc27 + resize(shift_right(o27 * w_cur, 2*Q_BITS), 96);
          acc33 <= acc33 + resize(shift_right(o33 * w_cur, 2*Q_BITS), 96);
          acc34 <= acc34 + resize(shift_right(o34 * w_cur, 2*Q_BITS), 96);
          acc35 <= acc35 + resize(shift_right(o35 * w_cur, 2*Q_BITS), 96);
          acc36 <= acc36 + resize(shift_right(o36 * w_cur, 2*Q_BITS), 96);
          acc37 <= acc37 + resize(shift_right(o37 * w_cur, 2*Q_BITS), 96);
          acc44 <= acc44 + resize(shift_right(o44 * w_cur, 2*Q_BITS), 96);
          acc45 <= acc45 + resize(shift_right(o45 * w_cur, 2*Q_BITS), 96);
          acc46 <= acc46 + resize(shift_right(o46 * w_cur, 2*Q_BITS), 96);
          acc47 <= acc47 + resize(shift_right(o47 * w_cur, 2*Q_BITS), 96);
          acc55 <= acc55 + resize(shift_right(o55 * w_cur, 2*Q_BITS), 96);
          acc56 <= acc56 + resize(shift_right(o56 * w_cur, 2*Q_BITS), 96);
          acc57 <= acc57 + resize(shift_right(o57 * w_cur, 2*Q_BITS), 96);
          acc66 <= acc66 + resize(shift_right(o66 * w_cur, 2*Q_BITS), 96);
          acc67 <= acc67 + resize(shift_right(o67 * w_cur, 2*Q_BITS), 96);
          acc77 <= acc77 + resize(shift_right(o77 * w_cur, 2*Q_BITS), 96);
          state <= CHECK_NEXT;

        when CHECK_NEXT =>
          if idx = 14 then
            state <= OUTPUT_RESULT;
          else
            idx <= idx + 1;
            state <= COMPUTE_DEV;
          end if;

        when OUTPUT_RESULT =>

          p11_out <= sat_p(acc11, true);
          p12_out <= sat_p(acc12, false);
          p13_out <= sat_p(acc13, false);
          p14_out <= sat_p(acc14, false);
          p15_out <= sat_p(acc15, false);
          p16_out <= sat_p(acc16, false);
          p17_out <= sat_p(acc17, false);
          p22_out <= sat_p(acc22, true);
          p23_out <= sat_p(acc23, false);
          p24_out <= sat_p(acc24, false);
          p25_out <= sat_p(acc25, false);
          p26_out <= sat_p(acc26, false);
          p27_out <= sat_p(acc27, false);
          p33_out <= sat_p(acc33, true);
          p34_out <= sat_p(acc34, false);
          p35_out <= sat_p(acc35, false);
          p36_out <= sat_p(acc36, false);
          p37_out <= sat_p(acc37, false);
          p44_out <= sat_p(acc44, true);
          p45_out <= sat_p(acc45, false);
          p46_out <= sat_p(acc46, false);
          p47_out <= sat_p(acc47, false);
          p55_out <= sat_p(acc55, true);
          p56_out <= sat_p(acc56, false);
          p57_out <= sat_p(acc57, false);
          p66_out <= sat_p(acc66, true);
          p67_out <= sat_p(acc67, false);
          p77_out <= sat_p(acc77, true);
          state <= FINISHED;

        when FINISHED =>
          done <= '1';
          if start = '0' then
            state <= IDLE;
          end if;

      end case;
    end if;
  end process;

end Behavioral;
