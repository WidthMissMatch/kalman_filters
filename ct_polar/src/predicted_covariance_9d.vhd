library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity predicted_covariance_9d is
  port (
    clk   : in  std_logic;
    start : in  std_logic;

    s1_mean, s2_mean, s3_mean, s4_mean, s5_mean : in signed(47 downto 0);
    s6_mean, s7_mean, s8_mean, s9_mean           : in signed(47 downto 0);

    chi0_s1, chi0_s2, chi0_s3, chi0_s4, chi0_s5, chi0_s6, chi0_s7, chi0_s8, chi0_s9 : in signed(47 downto 0);
    chi1_s1, chi1_s2, chi1_s3, chi1_s4, chi1_s5, chi1_s6, chi1_s7, chi1_s8, chi1_s9 : in signed(47 downto 0);
    chi2_s1, chi2_s2, chi2_s3, chi2_s4, chi2_s5, chi2_s6, chi2_s7, chi2_s8, chi2_s9 : in signed(47 downto 0);
    chi3_s1, chi3_s2, chi3_s3, chi3_s4, chi3_s5, chi3_s6, chi3_s7, chi3_s8, chi3_s9 : in signed(47 downto 0);
    chi4_s1, chi4_s2, chi4_s3, chi4_s4, chi4_s5, chi4_s6, chi4_s7, chi4_s8, chi4_s9 : in signed(47 downto 0);
    chi5_s1, chi5_s2, chi5_s3, chi5_s4, chi5_s5, chi5_s6, chi5_s7, chi5_s8, chi5_s9 : in signed(47 downto 0);
    chi6_s1, chi6_s2, chi6_s3, chi6_s4, chi6_s5, chi6_s6, chi6_s7, chi6_s8, chi6_s9 : in signed(47 downto 0);
    chi7_s1, chi7_s2, chi7_s3, chi7_s4, chi7_s5, chi7_s6, chi7_s7, chi7_s8, chi7_s9 : in signed(47 downto 0);
    chi8_s1, chi8_s2, chi8_s3, chi8_s4, chi8_s5, chi8_s6, chi8_s7, chi8_s8, chi8_s9 : in signed(47 downto 0);
    chi9_s1, chi9_s2, chi9_s3, chi9_s4, chi9_s5, chi9_s6, chi9_s7, chi9_s8, chi9_s9 : in signed(47 downto 0);
    chi10_s1, chi10_s2, chi10_s3, chi10_s4, chi10_s5, chi10_s6, chi10_s7, chi10_s8, chi10_s9 : in signed(47 downto 0);
    chi11_s1, chi11_s2, chi11_s3, chi11_s4, chi11_s5, chi11_s6, chi11_s7, chi11_s8, chi11_s9 : in signed(47 downto 0);
    chi12_s1, chi12_s2, chi12_s3, chi12_s4, chi12_s5, chi12_s6, chi12_s7, chi12_s8, chi12_s9 : in signed(47 downto 0);
    chi13_s1, chi13_s2, chi13_s3, chi13_s4, chi13_s5, chi13_s6, chi13_s7, chi13_s8, chi13_s9 : in signed(47 downto 0);
    chi14_s1, chi14_s2, chi14_s3, chi14_s4, chi14_s5, chi14_s6, chi14_s7, chi14_s8, chi14_s9 : in signed(47 downto 0);
    chi15_s1, chi15_s2, chi15_s3, chi15_s4, chi15_s5, chi15_s6, chi15_s7, chi15_s8, chi15_s9 : in signed(47 downto 0);
    chi16_s1, chi16_s2, chi16_s3, chi16_s4, chi16_s5, chi16_s6, chi16_s7, chi16_s8, chi16_s9 : in signed(47 downto 0);
    chi17_s1, chi17_s2, chi17_s3, chi17_s4, chi17_s5, chi17_s6, chi17_s7, chi17_s8, chi17_s9 : in signed(47 downto 0);
    chi18_s1, chi18_s2, chi18_s3, chi18_s4, chi18_s5, chi18_s6, chi18_s7, chi18_s8, chi18_s9 : in signed(47 downto 0);

    p11_out, p12_out, p13_out, p14_out, p15_out, p16_out, p17_out, p18_out, p19_out : buffer signed(47 downto 0);
    p22_out, p23_out, p24_out, p25_out, p26_out, p27_out, p28_out, p29_out : buffer signed(47 downto 0);
    p33_out, p34_out, p35_out, p36_out, p37_out, p38_out, p39_out : buffer signed(47 downto 0);
    p44_out, p45_out, p46_out, p47_out, p48_out, p49_out : buffer signed(47 downto 0);
    p55_out, p56_out, p57_out, p58_out, p59_out : buffer signed(47 downto 0);
    p66_out, p67_out, p68_out, p69_out : buffer signed(47 downto 0);
    p77_out, p78_out, p79_out : buffer signed(47 downto 0);
    p88_out, p89_out : buffer signed(47 downto 0);
    p99_out : buffer signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of predicted_covariance_9d is

  type state_type is (IDLE, COMPUTE_DEV, COMPUTE_OUTER, WEIGHT_ACC, CHECK_NEXT, OUTPUT_RESULT, FINISHED);
  signal state : state_type := IDLE;

  constant Q_BITS : integer := 24;

  constant WC0 : signed(47 downto 0) := to_signed(33554432, 48);
  constant WC1 : signed(47 downto 0) := to_signed(932068, 48);

  type sigma_state_array is array(0 to 18) of signed(47 downto 0);
  signal chi_s1, chi_s2, chi_s3, chi_s4, chi_s5 : sigma_state_array;
  signal chi_s6, chi_s7, chi_s8, chi_s9          : sigma_state_array;

  type weight_array is array(0 to 18) of signed(47 downto 0);
  constant WEIGHTS : weight_array := (WC0, WC1, WC1, WC1, WC1, WC1, WC1, WC1, WC1, WC1,
                                       WC1, WC1, WC1, WC1, WC1, WC1, WC1, WC1, WC1);

  signal idx : integer range 0 to 18 := 0;

  signal m1, m2, m3, m4, m5, m6, m7, m8, m9 : signed(47 downto 0);

  signal d1, d2, d3, d4, d5, d6, d7, d8, d9 : signed(47 downto 0);

  signal w_cur : signed(47 downto 0);

  signal o11, o12, o13, o14, o15, o16, o17, o18, o19 : signed(95 downto 0);
  signal o22, o23, o24, o25, o26, o27, o28, o29 : signed(95 downto 0);
  signal o33, o34, o35, o36, o37, o38, o39 : signed(95 downto 0);
  signal o44, o45, o46, o47, o48, o49 : signed(95 downto 0);
  signal o55, o56, o57, o58, o59 : signed(95 downto 0);
  signal o66, o67, o68, o69 : signed(95 downto 0);
  signal o77, o78, o79 : signed(95 downto 0);
  signal o88, o89 : signed(95 downto 0);
  signal o99 : signed(95 downto 0);

  signal acc11, acc12, acc13, acc14, acc15, acc16, acc17, acc18, acc19 : signed(48 downto 0);
  signal acc22, acc23, acc24, acc25, acc26, acc27, acc28, acc29 : signed(48 downto 0);
  signal acc33, acc34, acc35, acc36, acc37, acc38, acc39 : signed(48 downto 0);
  signal acc44, acc45, acc46, acc47, acc48, acc49 : signed(48 downto 0);
  signal acc55, acc56, acc57, acc58, acc59 : signed(48 downto 0);
  signal acc66, acc67, acc68, acc69 : signed(48 downto 0);
  signal acc77, acc78, acc79 : signed(48 downto 0);
  signal acc88, acc89 : signed(48 downto 0);
  signal acc99 : signed(48 downto 0);

  constant MAX_P : signed(47 downto 0) := signed'(X"3FFFFFFFFFFF");
  constant MIN_P : signed(47 downto 0) := signed'(X"C00000000000");
  constant UNITY : signed(47 downto 0) := to_signed(16777216, 48);

  function sat_p(val : signed(48 downto 0); is_diag : boolean) return signed is
    variable result : signed(47 downto 0);
  begin
    if val > MAX_P then result := MAX_P;
    elsif is_diag and val < UNITY then result := UNITY;
    elsif val < MIN_P then result := MIN_P;
    else result := resize(val, 48);
    end if;
    return result;
  end function;

begin

  process(clk)
    variable w_prod : signed(95 downto 0);
  begin
    if rising_edge(clk) then
      case state is

        when IDLE =>
          done <= '0';
          idx <= 0;
          if start = '1' then

            m1 <= s1_mean; m2 <= s2_mean; m3 <= s3_mean; m4 <= s4_mean;
            m5 <= s5_mean; m6 <= s6_mean; m7 <= s7_mean; m8 <= s8_mean;
            m9 <= s9_mean;

            chi_s1(0)  <= chi0_s1;  chi_s2(0)  <= chi0_s2;  chi_s3(0)  <= chi0_s3;
            chi_s4(0)  <= chi0_s4;  chi_s5(0)  <= chi0_s5;  chi_s6(0)  <= chi0_s6;
            chi_s7(0)  <= chi0_s7;  chi_s8(0)  <= chi0_s8;  chi_s9(0)  <= chi0_s9;

            chi_s1(1)  <= chi1_s1;  chi_s2(1)  <= chi1_s2;  chi_s3(1)  <= chi1_s3;
            chi_s4(1)  <= chi1_s4;  chi_s5(1)  <= chi1_s5;  chi_s6(1)  <= chi1_s6;
            chi_s7(1)  <= chi1_s7;  chi_s8(1)  <= chi1_s8;  chi_s9(1)  <= chi1_s9;

            chi_s1(2)  <= chi2_s1;  chi_s2(2)  <= chi2_s2;  chi_s3(2)  <= chi2_s3;
            chi_s4(2)  <= chi2_s4;  chi_s5(2)  <= chi2_s5;  chi_s6(2)  <= chi2_s6;
            chi_s7(2)  <= chi2_s7;  chi_s8(2)  <= chi2_s8;  chi_s9(2)  <= chi2_s9;

            chi_s1(3)  <= chi3_s1;  chi_s2(3)  <= chi3_s2;  chi_s3(3)  <= chi3_s3;
            chi_s4(3)  <= chi3_s4;  chi_s5(3)  <= chi3_s5;  chi_s6(3)  <= chi3_s6;
            chi_s7(3)  <= chi3_s7;  chi_s8(3)  <= chi3_s8;  chi_s9(3)  <= chi3_s9;

            chi_s1(4)  <= chi4_s1;  chi_s2(4)  <= chi4_s2;  chi_s3(4)  <= chi4_s3;
            chi_s4(4)  <= chi4_s4;  chi_s5(4)  <= chi4_s5;  chi_s6(4)  <= chi4_s6;
            chi_s7(4)  <= chi4_s7;  chi_s8(4)  <= chi4_s8;  chi_s9(4)  <= chi4_s9;

            chi_s1(5)  <= chi5_s1;  chi_s2(5)  <= chi5_s2;  chi_s3(5)  <= chi5_s3;
            chi_s4(5)  <= chi5_s4;  chi_s5(5)  <= chi5_s5;  chi_s6(5)  <= chi5_s6;
            chi_s7(5)  <= chi5_s7;  chi_s8(5)  <= chi5_s8;  chi_s9(5)  <= chi5_s9;

            chi_s1(6)  <= chi6_s1;  chi_s2(6)  <= chi6_s2;  chi_s3(6)  <= chi6_s3;
            chi_s4(6)  <= chi6_s4;  chi_s5(6)  <= chi6_s5;  chi_s6(6)  <= chi6_s6;
            chi_s7(6)  <= chi6_s7;  chi_s8(6)  <= chi6_s8;  chi_s9(6)  <= chi6_s9;

            chi_s1(7)  <= chi7_s1;  chi_s2(7)  <= chi7_s2;  chi_s3(7)  <= chi7_s3;
            chi_s4(7)  <= chi7_s4;  chi_s5(7)  <= chi7_s5;  chi_s6(7)  <= chi7_s6;
            chi_s7(7)  <= chi7_s7;  chi_s8(7)  <= chi7_s8;  chi_s9(7)  <= chi7_s9;

            chi_s1(8)  <= chi8_s1;  chi_s2(8)  <= chi8_s2;  chi_s3(8)  <= chi8_s3;
            chi_s4(8)  <= chi8_s4;  chi_s5(8)  <= chi8_s5;  chi_s6(8)  <= chi8_s6;
            chi_s7(8)  <= chi8_s7;  chi_s8(8)  <= chi8_s8;  chi_s9(8)  <= chi8_s9;

            chi_s1(9)  <= chi9_s1;  chi_s2(9)  <= chi9_s2;  chi_s3(9)  <= chi9_s3;
            chi_s4(9)  <= chi9_s4;  chi_s5(9)  <= chi9_s5;  chi_s6(9)  <= chi9_s6;
            chi_s7(9)  <= chi9_s7;  chi_s8(9)  <= chi9_s8;  chi_s9(9)  <= chi9_s9;

            chi_s1(10) <= chi10_s1; chi_s2(10) <= chi10_s2; chi_s3(10) <= chi10_s3;
            chi_s4(10) <= chi10_s4; chi_s5(10) <= chi10_s5; chi_s6(10) <= chi10_s6;
            chi_s7(10) <= chi10_s7; chi_s8(10) <= chi10_s8; chi_s9(10) <= chi10_s9;

            chi_s1(11) <= chi11_s1; chi_s2(11) <= chi11_s2; chi_s3(11) <= chi11_s3;
            chi_s4(11) <= chi11_s4; chi_s5(11) <= chi11_s5; chi_s6(11) <= chi11_s6;
            chi_s7(11) <= chi11_s7; chi_s8(11) <= chi11_s8; chi_s9(11) <= chi11_s9;

            chi_s1(12) <= chi12_s1; chi_s2(12) <= chi12_s2; chi_s3(12) <= chi12_s3;
            chi_s4(12) <= chi12_s4; chi_s5(12) <= chi12_s5; chi_s6(12) <= chi12_s6;
            chi_s7(12) <= chi12_s7; chi_s8(12) <= chi12_s8; chi_s9(12) <= chi12_s9;

            chi_s1(13) <= chi13_s1; chi_s2(13) <= chi13_s2; chi_s3(13) <= chi13_s3;
            chi_s4(13) <= chi13_s4; chi_s5(13) <= chi13_s5; chi_s6(13) <= chi13_s6;
            chi_s7(13) <= chi13_s7; chi_s8(13) <= chi13_s8; chi_s9(13) <= chi13_s9;

            chi_s1(14) <= chi14_s1; chi_s2(14) <= chi14_s2; chi_s3(14) <= chi14_s3;
            chi_s4(14) <= chi14_s4; chi_s5(14) <= chi14_s5; chi_s6(14) <= chi14_s6;
            chi_s7(14) <= chi14_s7; chi_s8(14) <= chi14_s8; chi_s9(14) <= chi14_s9;

            chi_s1(15) <= chi15_s1; chi_s2(15) <= chi15_s2; chi_s3(15) <= chi15_s3;
            chi_s4(15) <= chi15_s4; chi_s5(15) <= chi15_s5; chi_s6(15) <= chi15_s6;
            chi_s7(15) <= chi15_s7; chi_s8(15) <= chi15_s8; chi_s9(15) <= chi15_s9;

            chi_s1(16) <= chi16_s1; chi_s2(16) <= chi16_s2; chi_s3(16) <= chi16_s3;
            chi_s4(16) <= chi16_s4; chi_s5(16) <= chi16_s5; chi_s6(16) <= chi16_s6;
            chi_s7(16) <= chi16_s7; chi_s8(16) <= chi16_s8; chi_s9(16) <= chi16_s9;

            chi_s1(17) <= chi17_s1; chi_s2(17) <= chi17_s2; chi_s3(17) <= chi17_s3;
            chi_s4(17) <= chi17_s4; chi_s5(17) <= chi17_s5; chi_s6(17) <= chi17_s6;
            chi_s7(17) <= chi17_s7; chi_s8(17) <= chi17_s8; chi_s9(17) <= chi17_s9;

            chi_s1(18) <= chi18_s1; chi_s2(18) <= chi18_s2; chi_s3(18) <= chi18_s3;
            chi_s4(18) <= chi18_s4; chi_s5(18) <= chi18_s5; chi_s6(18) <= chi18_s6;
            chi_s7(18) <= chi18_s7; chi_s8(18) <= chi18_s8; chi_s9(18) <= chi18_s9;

            acc11 <= (others => '0'); acc12 <= (others => '0'); acc13 <= (others => '0');
            acc14 <= (others => '0'); acc15 <= (others => '0'); acc16 <= (others => '0');
            acc17 <= (others => '0'); acc18 <= (others => '0'); acc19 <= (others => '0');
            acc22 <= (others => '0'); acc23 <= (others => '0'); acc24 <= (others => '0');
            acc25 <= (others => '0'); acc26 <= (others => '0'); acc27 <= (others => '0');
            acc28 <= (others => '0'); acc29 <= (others => '0');
            acc33 <= (others => '0'); acc34 <= (others => '0'); acc35 <= (others => '0');
            acc36 <= (others => '0'); acc37 <= (others => '0'); acc38 <= (others => '0');
            acc39 <= (others => '0');
            acc44 <= (others => '0'); acc45 <= (others => '0'); acc46 <= (others => '0');
            acc47 <= (others => '0'); acc48 <= (others => '0'); acc49 <= (others => '0');
            acc55 <= (others => '0'); acc56 <= (others => '0'); acc57 <= (others => '0');
            acc58 <= (others => '0'); acc59 <= (others => '0');
            acc66 <= (others => '0'); acc67 <= (others => '0'); acc68 <= (others => '0');
            acc69 <= (others => '0');
            acc77 <= (others => '0'); acc78 <= (others => '0'); acc79 <= (others => '0');
            acc88 <= (others => '0'); acc89 <= (others => '0');
            acc99 <= (others => '0');

            state <= COMPUTE_DEV;
          end if;

        when COMPUTE_DEV =>

          w_cur <= WEIGHTS(idx);
          d1 <= chi_s1(idx) - m1;
          d2 <= chi_s2(idx) - m2;
          d3 <= chi_s3(idx) - m3;
          d4 <= chi_s4(idx) - m4;
          d5 <= chi_s5(idx) - m5;
          d6 <= chi_s6(idx) - m6;
          d7 <= chi_s7(idx) - m7;
          d8 <= chi_s8(idx) - m8;
          d9 <= chi_s9(idx) - m9;
          state <= COMPUTE_OUTER;

        when COMPUTE_OUTER =>

          o11 <= d1 * d1; o12 <= d1 * d2; o13 <= d1 * d3;
          o14 <= d1 * d4; o15 <= d1 * d5; o16 <= d1 * d6;
          o17 <= d1 * d7; o18 <= d1 * d8; o19 <= d1 * d9;

          o22 <= d2 * d2; o23 <= d2 * d3; o24 <= d2 * d4;
          o25 <= d2 * d5; o26 <= d2 * d6; o27 <= d2 * d7;
          o28 <= d2 * d8; o29 <= d2 * d9;

          o33 <= d3 * d3; o34 <= d3 * d4; o35 <= d3 * d5;
          o36 <= d3 * d6; o37 <= d3 * d7; o38 <= d3 * d8;
          o39 <= d3 * d9;

          o44 <= d4 * d4; o45 <= d4 * d5; o46 <= d4 * d6;
          o47 <= d4 * d7; o48 <= d4 * d8; o49 <= d4 * d9;

          o55 <= d5 * d5; o56 <= d5 * d6; o57 <= d5 * d7;
          o58 <= d5 * d8; o59 <= d5 * d9;

          o66 <= d6 * d6; o67 <= d6 * d7; o68 <= d6 * d8;
          o69 <= d6 * d9;

          o77 <= d7 * d7; o78 <= d7 * d8; o79 <= d7 * d9;

          o88 <= d8 * d8; o89 <= d8 * d9;

          o99 <= d9 * d9;
          state <= WEIGHT_ACC;

        when WEIGHT_ACC =>

          acc11 <= acc11 + resize(shift_right(resize(o11 * w_cur, 96), 2*Q_BITS), 49);
          acc12 <= acc12 + resize(shift_right(resize(o12 * w_cur, 96), 2*Q_BITS), 49);
          acc13 <= acc13 + resize(shift_right(resize(o13 * w_cur, 96), 2*Q_BITS), 49);
          acc14 <= acc14 + resize(shift_right(resize(o14 * w_cur, 96), 2*Q_BITS), 49);
          acc15 <= acc15 + resize(shift_right(resize(o15 * w_cur, 96), 2*Q_BITS), 49);
          acc16 <= acc16 + resize(shift_right(resize(o16 * w_cur, 96), 2*Q_BITS), 49);
          acc17 <= acc17 + resize(shift_right(resize(o17 * w_cur, 96), 2*Q_BITS), 49);
          acc18 <= acc18 + resize(shift_right(resize(o18 * w_cur, 96), 2*Q_BITS), 49);
          acc19 <= acc19 + resize(shift_right(resize(o19 * w_cur, 96), 2*Q_BITS), 49);

          acc22 <= acc22 + resize(shift_right(resize(o22 * w_cur, 96), 2*Q_BITS), 49);
          acc23 <= acc23 + resize(shift_right(resize(o23 * w_cur, 96), 2*Q_BITS), 49);
          acc24 <= acc24 + resize(shift_right(resize(o24 * w_cur, 96), 2*Q_BITS), 49);
          acc25 <= acc25 + resize(shift_right(resize(o25 * w_cur, 96), 2*Q_BITS), 49);
          acc26 <= acc26 + resize(shift_right(resize(o26 * w_cur, 96), 2*Q_BITS), 49);
          acc27 <= acc27 + resize(shift_right(resize(o27 * w_cur, 96), 2*Q_BITS), 49);
          acc28 <= acc28 + resize(shift_right(resize(o28 * w_cur, 96), 2*Q_BITS), 49);
          acc29 <= acc29 + resize(shift_right(resize(o29 * w_cur, 96), 2*Q_BITS), 49);

          acc33 <= acc33 + resize(shift_right(resize(o33 * w_cur, 96), 2*Q_BITS), 49);
          acc34 <= acc34 + resize(shift_right(resize(o34 * w_cur, 96), 2*Q_BITS), 49);
          acc35 <= acc35 + resize(shift_right(resize(o35 * w_cur, 96), 2*Q_BITS), 49);
          acc36 <= acc36 + resize(shift_right(resize(o36 * w_cur, 96), 2*Q_BITS), 49);
          acc37 <= acc37 + resize(shift_right(resize(o37 * w_cur, 96), 2*Q_BITS), 49);
          acc38 <= acc38 + resize(shift_right(resize(o38 * w_cur, 96), 2*Q_BITS), 49);
          acc39 <= acc39 + resize(shift_right(resize(o39 * w_cur, 96), 2*Q_BITS), 49);

          acc44 <= acc44 + resize(shift_right(resize(o44 * w_cur, 96), 2*Q_BITS), 49);
          acc45 <= acc45 + resize(shift_right(resize(o45 * w_cur, 96), 2*Q_BITS), 49);
          acc46 <= acc46 + resize(shift_right(resize(o46 * w_cur, 96), 2*Q_BITS), 49);
          acc47 <= acc47 + resize(shift_right(resize(o47 * w_cur, 96), 2*Q_BITS), 49);
          acc48 <= acc48 + resize(shift_right(resize(o48 * w_cur, 96), 2*Q_BITS), 49);
          acc49 <= acc49 + resize(shift_right(resize(o49 * w_cur, 96), 2*Q_BITS), 49);

          acc55 <= acc55 + resize(shift_right(resize(o55 * w_cur, 96), 2*Q_BITS), 49);
          acc56 <= acc56 + resize(shift_right(resize(o56 * w_cur, 96), 2*Q_BITS), 49);
          acc57 <= acc57 + resize(shift_right(resize(o57 * w_cur, 96), 2*Q_BITS), 49);
          acc58 <= acc58 + resize(shift_right(resize(o58 * w_cur, 96), 2*Q_BITS), 49);
          acc59 <= acc59 + resize(shift_right(resize(o59 * w_cur, 96), 2*Q_BITS), 49);

          acc66 <= acc66 + resize(shift_right(resize(o66 * w_cur, 96), 2*Q_BITS), 49);
          acc67 <= acc67 + resize(shift_right(resize(o67 * w_cur, 96), 2*Q_BITS), 49);
          acc68 <= acc68 + resize(shift_right(resize(o68 * w_cur, 96), 2*Q_BITS), 49);
          acc69 <= acc69 + resize(shift_right(resize(o69 * w_cur, 96), 2*Q_BITS), 49);

          acc77 <= acc77 + resize(shift_right(resize(o77 * w_cur, 96), 2*Q_BITS), 49);
          acc78 <= acc78 + resize(shift_right(resize(o78 * w_cur, 96), 2*Q_BITS), 49);
          acc79 <= acc79 + resize(shift_right(resize(o79 * w_cur, 96), 2*Q_BITS), 49);

          acc88 <= acc88 + resize(shift_right(resize(o88 * w_cur, 96), 2*Q_BITS), 49);
          acc89 <= acc89 + resize(shift_right(resize(o89 * w_cur, 96), 2*Q_BITS), 49);

          acc99 <= acc99 + resize(shift_right(resize(o99 * w_cur, 96), 2*Q_BITS), 49);
          state <= CHECK_NEXT;

        when CHECK_NEXT =>
          if idx = 18 then
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
          p18_out <= sat_p(acc18, false);
          p19_out <= sat_p(acc19, false);

          p22_out <= sat_p(acc22, true);
          p23_out <= sat_p(acc23, false);
          p24_out <= sat_p(acc24, false);
          p25_out <= sat_p(acc25, false);
          p26_out <= sat_p(acc26, false);
          p27_out <= sat_p(acc27, false);
          p28_out <= sat_p(acc28, false);
          p29_out <= sat_p(acc29, false);

          p33_out <= sat_p(acc33, true);
          p34_out <= sat_p(acc34, false);
          p35_out <= sat_p(acc35, false);
          p36_out <= sat_p(acc36, false);
          p37_out <= sat_p(acc37, false);
          p38_out <= sat_p(acc38, false);
          p39_out <= sat_p(acc39, false);

          p44_out <= sat_p(acc44, true);
          p45_out <= sat_p(acc45, false);
          p46_out <= sat_p(acc46, false);
          p47_out <= sat_p(acc47, false);
          p48_out <= sat_p(acc48, false);
          p49_out <= sat_p(acc49, false);

          p55_out <= sat_p(acc55, true);
          p56_out <= sat_p(acc56, false);
          p57_out <= sat_p(acc57, false);
          p58_out <= sat_p(acc58, false);
          p59_out <= sat_p(acc59, false);

          p66_out <= sat_p(acc66, true);
          p67_out <= sat_p(acc67, false);
          p68_out <= sat_p(acc68, false);
          p69_out <= sat_p(acc69, false);

          p77_out <= sat_p(acc77, true);
          p78_out <= sat_p(acc78, false);
          p79_out <= sat_p(acc79, false);

          p88_out <= sat_p(acc88, true);
          p89_out <= sat_p(acc89, false);

          p99_out <= sat_p(acc99, true);
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
