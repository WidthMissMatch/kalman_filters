library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cross_covariance_9d is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    start : in  std_logic;

    s1_mean, s2_mean, s3_mean, s4_mean, s5_mean : in signed(47 downto 0);
    s6_mean, s7_mean, s8_mean, s9_mean           : in signed(47 downto 0);

    z1_mean, z2_mean, z3_mean : in signed(47 downto 0);

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

    pxz_11, pxz_12, pxz_13 : buffer signed(47 downto 0);
    pxz_21, pxz_22, pxz_23 : buffer signed(47 downto 0);
    pxz_31, pxz_32, pxz_33 : buffer signed(47 downto 0);
    pxz_41, pxz_42, pxz_43 : buffer signed(47 downto 0);
    pxz_51, pxz_52, pxz_53 : buffer signed(47 downto 0);
    pxz_61, pxz_62, pxz_63 : buffer signed(47 downto 0);
    pxz_71, pxz_72, pxz_73 : buffer signed(47 downto 0);
    pxz_81, pxz_82, pxz_83 : buffer signed(47 downto 0);
    pxz_91, pxz_92, pxz_93 : buffer signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of cross_covariance_9d is

  type state_type is (IDLE, COMPUTE, FINISHED);
  signal state : state_type := IDLE;

  constant Q : integer := 24;

  constant WC0 : signed(47 downto 0) := to_signed(33554432, 48);
  constant WC1 : signed(47 downto 0) := to_signed(932068, 48);

  function w_outer(w, dx, dz : signed(47 downto 0)) return signed is
    variable prod1 : signed(95 downto 0);
    variable prod2 : signed(95 downto 0);
  begin
    prod1 := dx * dz;
    prod2 := w * resize(shift_right(prod1, Q), 48);
    return resize(shift_right(prod2, Q), 48);
  end function;

begin

  process(clk)

    type dev_array is array(0 to 18) of signed(47 downto 0);
    variable ds1, ds2, ds3, ds4, ds5, ds6, ds7, ds8, ds9 : dev_array;

    variable dz1, dz2, dz3 : dev_array;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= IDLE;
        done <= '0';
      else
        case state is
          when IDLE =>
            done <= '0';
            if start = '1' then

              ds1(0)  := chi0_s1  - s1_mean; ds1(1)  := chi1_s1  - s1_mean;
              ds1(2)  := chi2_s1  - s1_mean; ds1(3)  := chi3_s1  - s1_mean;
              ds1(4)  := chi4_s1  - s1_mean; ds1(5)  := chi5_s1  - s1_mean;
              ds1(6)  := chi6_s1  - s1_mean; ds1(7)  := chi7_s1  - s1_mean;
              ds1(8)  := chi8_s1  - s1_mean; ds1(9)  := chi9_s1  - s1_mean;
              ds1(10) := chi10_s1 - s1_mean; ds1(11) := chi11_s1 - s1_mean;
              ds1(12) := chi12_s1 - s1_mean; ds1(13) := chi13_s1 - s1_mean;
              ds1(14) := chi14_s1 - s1_mean; ds1(15) := chi15_s1 - s1_mean;
              ds1(16) := chi16_s1 - s1_mean; ds1(17) := chi17_s1 - s1_mean;
              ds1(18) := chi18_s1 - s1_mean;

              ds2(0)  := chi0_s2  - s2_mean; ds2(1)  := chi1_s2  - s2_mean;
              ds2(2)  := chi2_s2  - s2_mean; ds2(3)  := chi3_s2  - s2_mean;
              ds2(4)  := chi4_s2  - s2_mean; ds2(5)  := chi5_s2  - s2_mean;
              ds2(6)  := chi6_s2  - s2_mean; ds2(7)  := chi7_s2  - s2_mean;
              ds2(8)  := chi8_s2  - s2_mean; ds2(9)  := chi9_s2  - s2_mean;
              ds2(10) := chi10_s2 - s2_mean; ds2(11) := chi11_s2 - s2_mean;
              ds2(12) := chi12_s2 - s2_mean; ds2(13) := chi13_s2 - s2_mean;
              ds2(14) := chi14_s2 - s2_mean; ds2(15) := chi15_s2 - s2_mean;
              ds2(16) := chi16_s2 - s2_mean; ds2(17) := chi17_s2 - s2_mean;
              ds2(18) := chi18_s2 - s2_mean;

              ds3(0)  := chi0_s3  - s3_mean; ds3(1)  := chi1_s3  - s3_mean;
              ds3(2)  := chi2_s3  - s3_mean; ds3(3)  := chi3_s3  - s3_mean;
              ds3(4)  := chi4_s3  - s3_mean; ds3(5)  := chi5_s3  - s3_mean;
              ds3(6)  := chi6_s3  - s3_mean; ds3(7)  := chi7_s3  - s3_mean;
              ds3(8)  := chi8_s3  - s3_mean; ds3(9)  := chi9_s3  - s3_mean;
              ds3(10) := chi10_s3 - s3_mean; ds3(11) := chi11_s3 - s3_mean;
              ds3(12) := chi12_s3 - s3_mean; ds3(13) := chi13_s3 - s3_mean;
              ds3(14) := chi14_s3 - s3_mean; ds3(15) := chi15_s3 - s3_mean;
              ds3(16) := chi16_s3 - s3_mean; ds3(17) := chi17_s3 - s3_mean;
              ds3(18) := chi18_s3 - s3_mean;

              ds4(0)  := chi0_s4  - s4_mean; ds4(1)  := chi1_s4  - s4_mean;
              ds4(2)  := chi2_s4  - s4_mean; ds4(3)  := chi3_s4  - s4_mean;
              ds4(4)  := chi4_s4  - s4_mean; ds4(5)  := chi5_s4  - s4_mean;
              ds4(6)  := chi6_s4  - s4_mean; ds4(7)  := chi7_s4  - s4_mean;
              ds4(8)  := chi8_s4  - s4_mean; ds4(9)  := chi9_s4  - s4_mean;
              ds4(10) := chi10_s4 - s4_mean; ds4(11) := chi11_s4 - s4_mean;
              ds4(12) := chi12_s4 - s4_mean; ds4(13) := chi13_s4 - s4_mean;
              ds4(14) := chi14_s4 - s4_mean; ds4(15) := chi15_s4 - s4_mean;
              ds4(16) := chi16_s4 - s4_mean; ds4(17) := chi17_s4 - s4_mean;
              ds4(18) := chi18_s4 - s4_mean;

              ds5(0)  := chi0_s5  - s5_mean; ds5(1)  := chi1_s5  - s5_mean;
              ds5(2)  := chi2_s5  - s5_mean; ds5(3)  := chi3_s5  - s5_mean;
              ds5(4)  := chi4_s5  - s5_mean; ds5(5)  := chi5_s5  - s5_mean;
              ds5(6)  := chi6_s5  - s5_mean; ds5(7)  := chi7_s5  - s5_mean;
              ds5(8)  := chi8_s5  - s5_mean; ds5(9)  := chi9_s5  - s5_mean;
              ds5(10) := chi10_s5 - s5_mean; ds5(11) := chi11_s5 - s5_mean;
              ds5(12) := chi12_s5 - s5_mean; ds5(13) := chi13_s5 - s5_mean;
              ds5(14) := chi14_s5 - s5_mean; ds5(15) := chi15_s5 - s5_mean;
              ds5(16) := chi16_s5 - s5_mean; ds5(17) := chi17_s5 - s5_mean;
              ds5(18) := chi18_s5 - s5_mean;

              ds6(0)  := chi0_s6  - s6_mean; ds6(1)  := chi1_s6  - s6_mean;
              ds6(2)  := chi2_s6  - s6_mean; ds6(3)  := chi3_s6  - s6_mean;
              ds6(4)  := chi4_s6  - s6_mean; ds6(5)  := chi5_s6  - s6_mean;
              ds6(6)  := chi6_s6  - s6_mean; ds6(7)  := chi7_s6  - s6_mean;
              ds6(8)  := chi8_s6  - s6_mean; ds6(9)  := chi9_s6  - s6_mean;
              ds6(10) := chi10_s6 - s6_mean; ds6(11) := chi11_s6 - s6_mean;
              ds6(12) := chi12_s6 - s6_mean; ds6(13) := chi13_s6 - s6_mean;
              ds6(14) := chi14_s6 - s6_mean; ds6(15) := chi15_s6 - s6_mean;
              ds6(16) := chi16_s6 - s6_mean; ds6(17) := chi17_s6 - s6_mean;
              ds6(18) := chi18_s6 - s6_mean;

              ds7(0)  := chi0_s7  - s7_mean; ds7(1)  := chi1_s7  - s7_mean;
              ds7(2)  := chi2_s7  - s7_mean; ds7(3)  := chi3_s7  - s7_mean;
              ds7(4)  := chi4_s7  - s7_mean; ds7(5)  := chi5_s7  - s7_mean;
              ds7(6)  := chi6_s7  - s7_mean; ds7(7)  := chi7_s7  - s7_mean;
              ds7(8)  := chi8_s7  - s7_mean; ds7(9)  := chi9_s7  - s7_mean;
              ds7(10) := chi10_s7 - s7_mean; ds7(11) := chi11_s7 - s7_mean;
              ds7(12) := chi12_s7 - s7_mean; ds7(13) := chi13_s7 - s7_mean;
              ds7(14) := chi14_s7 - s7_mean; ds7(15) := chi15_s7 - s7_mean;
              ds7(16) := chi16_s7 - s7_mean; ds7(17) := chi17_s7 - s7_mean;
              ds7(18) := chi18_s7 - s7_mean;

              ds8(0)  := chi0_s8  - s8_mean; ds8(1)  := chi1_s8  - s8_mean;
              ds8(2)  := chi2_s8  - s8_mean; ds8(3)  := chi3_s8  - s8_mean;
              ds8(4)  := chi4_s8  - s8_mean; ds8(5)  := chi5_s8  - s8_mean;
              ds8(6)  := chi6_s8  - s8_mean; ds8(7)  := chi7_s8  - s8_mean;
              ds8(8)  := chi8_s8  - s8_mean; ds8(9)  := chi9_s8  - s8_mean;
              ds8(10) := chi10_s8 - s8_mean; ds8(11) := chi11_s8 - s8_mean;
              ds8(12) := chi12_s8 - s8_mean; ds8(13) := chi13_s8 - s8_mean;
              ds8(14) := chi14_s8 - s8_mean; ds8(15) := chi15_s8 - s8_mean;
              ds8(16) := chi16_s8 - s8_mean; ds8(17) := chi17_s8 - s8_mean;
              ds8(18) := chi18_s8 - s8_mean;

              ds9(0)  := chi0_s9  - s9_mean; ds9(1)  := chi1_s9  - s9_mean;
              ds9(2)  := chi2_s9  - s9_mean; ds9(3)  := chi3_s9  - s9_mean;
              ds9(4)  := chi4_s9  - s9_mean; ds9(5)  := chi5_s9  - s9_mean;
              ds9(6)  := chi6_s9  - s9_mean; ds9(7)  := chi7_s9  - s9_mean;
              ds9(8)  := chi8_s9  - s9_mean; ds9(9)  := chi9_s9  - s9_mean;
              ds9(10) := chi10_s9 - s9_mean; ds9(11) := chi11_s9 - s9_mean;
              ds9(12) := chi12_s9 - s9_mean; ds9(13) := chi13_s9 - s9_mean;
              ds9(14) := chi14_s9 - s9_mean; ds9(15) := chi15_s9 - s9_mean;
              ds9(16) := chi16_s9 - s9_mean; ds9(17) := chi17_s9 - s9_mean;
              ds9(18) := chi18_s9 - s9_mean;

              dz1(0)  := chi0_s1  - z1_mean; dz1(1)  := chi1_s1  - z1_mean;
              dz1(2)  := chi2_s1  - z1_mean; dz1(3)  := chi3_s1  - z1_mean;
              dz1(4)  := chi4_s1  - z1_mean; dz1(5)  := chi5_s1  - z1_mean;
              dz1(6)  := chi6_s1  - z1_mean; dz1(7)  := chi7_s1  - z1_mean;
              dz1(8)  := chi8_s1  - z1_mean; dz1(9)  := chi9_s1  - z1_mean;
              dz1(10) := chi10_s1 - z1_mean; dz1(11) := chi11_s1 - z1_mean;
              dz1(12) := chi12_s1 - z1_mean; dz1(13) := chi13_s1 - z1_mean;
              dz1(14) := chi14_s1 - z1_mean; dz1(15) := chi15_s1 - z1_mean;
              dz1(16) := chi16_s1 - z1_mean; dz1(17) := chi17_s1 - z1_mean;
              dz1(18) := chi18_s1 - z1_mean;

              dz2(0)  := chi0_s2  - z2_mean; dz2(1)  := chi1_s2  - z2_mean;
              dz2(2)  := chi2_s2  - z2_mean; dz2(3)  := chi3_s2  - z2_mean;
              dz2(4)  := chi4_s2  - z2_mean; dz2(5)  := chi5_s2  - z2_mean;
              dz2(6)  := chi6_s2  - z2_mean; dz2(7)  := chi7_s2  - z2_mean;
              dz2(8)  := chi8_s2  - z2_mean; dz2(9)  := chi9_s2  - z2_mean;
              dz2(10) := chi10_s2 - z2_mean; dz2(11) := chi11_s2 - z2_mean;
              dz2(12) := chi12_s2 - z2_mean; dz2(13) := chi13_s2 - z2_mean;
              dz2(14) := chi14_s2 - z2_mean; dz2(15) := chi15_s2 - z2_mean;
              dz2(16) := chi16_s2 - z2_mean; dz2(17) := chi17_s2 - z2_mean;
              dz2(18) := chi18_s2 - z2_mean;

              dz3(0)  := chi0_s7  - z3_mean; dz3(1)  := chi1_s7  - z3_mean;
              dz3(2)  := chi2_s7  - z3_mean; dz3(3)  := chi3_s7  - z3_mean;
              dz3(4)  := chi4_s7  - z3_mean; dz3(5)  := chi5_s7  - z3_mean;
              dz3(6)  := chi6_s7  - z3_mean; dz3(7)  := chi7_s7  - z3_mean;
              dz3(8)  := chi8_s7  - z3_mean; dz3(9)  := chi9_s7  - z3_mean;
              dz3(10) := chi10_s7 - z3_mean; dz3(11) := chi11_s7 - z3_mean;
              dz3(12) := chi12_s7 - z3_mean; dz3(13) := chi13_s7 - z3_mean;
              dz3(14) := chi14_s7 - z3_mean; dz3(15) := chi15_s7 - z3_mean;
              dz3(16) := chi16_s7 - z3_mean; dz3(17) := chi17_s7 - z3_mean;
              dz3(18) := chi18_s7 - z3_mean;

              state <= COMPUTE;
            end if;

          when COMPUTE =>

            pxz_11 <= w_outer(WC0, ds1(0), dz1(0)) + w_outer(WC1, ds1(1), dz1(1)) + w_outer(WC1, ds1(2), dz1(2))
                    + w_outer(WC1, ds1(3), dz1(3)) + w_outer(WC1, ds1(4), dz1(4)) + w_outer(WC1, ds1(5), dz1(5))
                    + w_outer(WC1, ds1(6), dz1(6)) + w_outer(WC1, ds1(7), dz1(7)) + w_outer(WC1, ds1(8), dz1(8))
                    + w_outer(WC1, ds1(9), dz1(9)) + w_outer(WC1, ds1(10), dz1(10)) + w_outer(WC1, ds1(11), dz1(11))
                    + w_outer(WC1, ds1(12), dz1(12)) + w_outer(WC1, ds1(13), dz1(13)) + w_outer(WC1, ds1(14), dz1(14))
                    + w_outer(WC1, ds1(15), dz1(15)) + w_outer(WC1, ds1(16), dz1(16)) + w_outer(WC1, ds1(17), dz1(17))
                    + w_outer(WC1, ds1(18), dz1(18));

            pxz_12 <= w_outer(WC0, ds1(0), dz2(0)) + w_outer(WC1, ds1(1), dz2(1)) + w_outer(WC1, ds1(2), dz2(2))
                    + w_outer(WC1, ds1(3), dz2(3)) + w_outer(WC1, ds1(4), dz2(4)) + w_outer(WC1, ds1(5), dz2(5))
                    + w_outer(WC1, ds1(6), dz2(6)) + w_outer(WC1, ds1(7), dz2(7)) + w_outer(WC1, ds1(8), dz2(8))
                    + w_outer(WC1, ds1(9), dz2(9)) + w_outer(WC1, ds1(10), dz2(10)) + w_outer(WC1, ds1(11), dz2(11))
                    + w_outer(WC1, ds1(12), dz2(12)) + w_outer(WC1, ds1(13), dz2(13)) + w_outer(WC1, ds1(14), dz2(14))
                    + w_outer(WC1, ds1(15), dz2(15)) + w_outer(WC1, ds1(16), dz2(16)) + w_outer(WC1, ds1(17), dz2(17))
                    + w_outer(WC1, ds1(18), dz2(18));

            pxz_13 <= w_outer(WC0, ds1(0), dz3(0)) + w_outer(WC1, ds1(1), dz3(1)) + w_outer(WC1, ds1(2), dz3(2))
                    + w_outer(WC1, ds1(3), dz3(3)) + w_outer(WC1, ds1(4), dz3(4)) + w_outer(WC1, ds1(5), dz3(5))
                    + w_outer(WC1, ds1(6), dz3(6)) + w_outer(WC1, ds1(7), dz3(7)) + w_outer(WC1, ds1(8), dz3(8))
                    + w_outer(WC1, ds1(9), dz3(9)) + w_outer(WC1, ds1(10), dz3(10)) + w_outer(WC1, ds1(11), dz3(11))
                    + w_outer(WC1, ds1(12), dz3(12)) + w_outer(WC1, ds1(13), dz3(13)) + w_outer(WC1, ds1(14), dz3(14))
                    + w_outer(WC1, ds1(15), dz3(15)) + w_outer(WC1, ds1(16), dz3(16)) + w_outer(WC1, ds1(17), dz3(17))
                    + w_outer(WC1, ds1(18), dz3(18));

            pxz_21 <= w_outer(WC0, ds2(0), dz1(0)) + w_outer(WC1, ds2(1), dz1(1)) + w_outer(WC1, ds2(2), dz1(2))
                    + w_outer(WC1, ds2(3), dz1(3)) + w_outer(WC1, ds2(4), dz1(4)) + w_outer(WC1, ds2(5), dz1(5))
                    + w_outer(WC1, ds2(6), dz1(6)) + w_outer(WC1, ds2(7), dz1(7)) + w_outer(WC1, ds2(8), dz1(8))
                    + w_outer(WC1, ds2(9), dz1(9)) + w_outer(WC1, ds2(10), dz1(10)) + w_outer(WC1, ds2(11), dz1(11))
                    + w_outer(WC1, ds2(12), dz1(12)) + w_outer(WC1, ds2(13), dz1(13)) + w_outer(WC1, ds2(14), dz1(14))
                    + w_outer(WC1, ds2(15), dz1(15)) + w_outer(WC1, ds2(16), dz1(16)) + w_outer(WC1, ds2(17), dz1(17))
                    + w_outer(WC1, ds2(18), dz1(18));
            pxz_22 <= w_outer(WC0, ds2(0), dz2(0)) + w_outer(WC1, ds2(1), dz2(1)) + w_outer(WC1, ds2(2), dz2(2))
                    + w_outer(WC1, ds2(3), dz2(3)) + w_outer(WC1, ds2(4), dz2(4)) + w_outer(WC1, ds2(5), dz2(5))
                    + w_outer(WC1, ds2(6), dz2(6)) + w_outer(WC1, ds2(7), dz2(7)) + w_outer(WC1, ds2(8), dz2(8))
                    + w_outer(WC1, ds2(9), dz2(9)) + w_outer(WC1, ds2(10), dz2(10)) + w_outer(WC1, ds2(11), dz2(11))
                    + w_outer(WC1, ds2(12), dz2(12)) + w_outer(WC1, ds2(13), dz2(13)) + w_outer(WC1, ds2(14), dz2(14))
                    + w_outer(WC1, ds2(15), dz2(15)) + w_outer(WC1, ds2(16), dz2(16)) + w_outer(WC1, ds2(17), dz2(17))
                    + w_outer(WC1, ds2(18), dz2(18));
            pxz_23 <= w_outer(WC0, ds2(0), dz3(0)) + w_outer(WC1, ds2(1), dz3(1)) + w_outer(WC1, ds2(2), dz3(2))
                    + w_outer(WC1, ds2(3), dz3(3)) + w_outer(WC1, ds2(4), dz3(4)) + w_outer(WC1, ds2(5), dz3(5))
                    + w_outer(WC1, ds2(6), dz3(6)) + w_outer(WC1, ds2(7), dz3(7)) + w_outer(WC1, ds2(8), dz3(8))
                    + w_outer(WC1, ds2(9), dz3(9)) + w_outer(WC1, ds2(10), dz3(10)) + w_outer(WC1, ds2(11), dz3(11))
                    + w_outer(WC1, ds2(12), dz3(12)) + w_outer(WC1, ds2(13), dz3(13)) + w_outer(WC1, ds2(14), dz3(14))
                    + w_outer(WC1, ds2(15), dz3(15)) + w_outer(WC1, ds2(16), dz3(16)) + w_outer(WC1, ds2(17), dz3(17))
                    + w_outer(WC1, ds2(18), dz3(18));

            pxz_31 <= w_outer(WC0, ds3(0), dz1(0)) + w_outer(WC1, ds3(1), dz1(1)) + w_outer(WC1, ds3(2), dz1(2))
                    + w_outer(WC1, ds3(3), dz1(3)) + w_outer(WC1, ds3(4), dz1(4)) + w_outer(WC1, ds3(5), dz1(5))
                    + w_outer(WC1, ds3(6), dz1(6)) + w_outer(WC1, ds3(7), dz1(7)) + w_outer(WC1, ds3(8), dz1(8))
                    + w_outer(WC1, ds3(9), dz1(9)) + w_outer(WC1, ds3(10), dz1(10)) + w_outer(WC1, ds3(11), dz1(11))
                    + w_outer(WC1, ds3(12), dz1(12)) + w_outer(WC1, ds3(13), dz1(13)) + w_outer(WC1, ds3(14), dz1(14))
                    + w_outer(WC1, ds3(15), dz1(15)) + w_outer(WC1, ds3(16), dz1(16)) + w_outer(WC1, ds3(17), dz1(17))
                    + w_outer(WC1, ds3(18), dz1(18));
            pxz_32 <= w_outer(WC0, ds3(0), dz2(0)) + w_outer(WC1, ds3(1), dz2(1)) + w_outer(WC1, ds3(2), dz2(2))
                    + w_outer(WC1, ds3(3), dz2(3)) + w_outer(WC1, ds3(4), dz2(4)) + w_outer(WC1, ds3(5), dz2(5))
                    + w_outer(WC1, ds3(6), dz2(6)) + w_outer(WC1, ds3(7), dz2(7)) + w_outer(WC1, ds3(8), dz2(8))
                    + w_outer(WC1, ds3(9), dz2(9)) + w_outer(WC1, ds3(10), dz2(10)) + w_outer(WC1, ds3(11), dz2(11))
                    + w_outer(WC1, ds3(12), dz2(12)) + w_outer(WC1, ds3(13), dz2(13)) + w_outer(WC1, ds3(14), dz2(14))
                    + w_outer(WC1, ds3(15), dz2(15)) + w_outer(WC1, ds3(16), dz2(16)) + w_outer(WC1, ds3(17), dz2(17))
                    + w_outer(WC1, ds3(18), dz2(18));
            pxz_33 <= w_outer(WC0, ds3(0), dz3(0)) + w_outer(WC1, ds3(1), dz3(1)) + w_outer(WC1, ds3(2), dz3(2))
                    + w_outer(WC1, ds3(3), dz3(3)) + w_outer(WC1, ds3(4), dz3(4)) + w_outer(WC1, ds3(5), dz3(5))
                    + w_outer(WC1, ds3(6), dz3(6)) + w_outer(WC1, ds3(7), dz3(7)) + w_outer(WC1, ds3(8), dz3(8))
                    + w_outer(WC1, ds3(9), dz3(9)) + w_outer(WC1, ds3(10), dz3(10)) + w_outer(WC1, ds3(11), dz3(11))
                    + w_outer(WC1, ds3(12), dz3(12)) + w_outer(WC1, ds3(13), dz3(13)) + w_outer(WC1, ds3(14), dz3(14))
                    + w_outer(WC1, ds3(15), dz3(15)) + w_outer(WC1, ds3(16), dz3(16)) + w_outer(WC1, ds3(17), dz3(17))
                    + w_outer(WC1, ds3(18), dz3(18));

            pxz_41 <= w_outer(WC0, ds4(0), dz1(0)) + w_outer(WC1, ds4(1), dz1(1)) + w_outer(WC1, ds4(2), dz1(2))
                    + w_outer(WC1, ds4(3), dz1(3)) + w_outer(WC1, ds4(4), dz1(4)) + w_outer(WC1, ds4(5), dz1(5))
                    + w_outer(WC1, ds4(6), dz1(6)) + w_outer(WC1, ds4(7), dz1(7)) + w_outer(WC1, ds4(8), dz1(8))
                    + w_outer(WC1, ds4(9), dz1(9)) + w_outer(WC1, ds4(10), dz1(10)) + w_outer(WC1, ds4(11), dz1(11))
                    + w_outer(WC1, ds4(12), dz1(12)) + w_outer(WC1, ds4(13), dz1(13)) + w_outer(WC1, ds4(14), dz1(14))
                    + w_outer(WC1, ds4(15), dz1(15)) + w_outer(WC1, ds4(16), dz1(16)) + w_outer(WC1, ds4(17), dz1(17))
                    + w_outer(WC1, ds4(18), dz1(18));
            pxz_42 <= w_outer(WC0, ds4(0), dz2(0)) + w_outer(WC1, ds4(1), dz2(1)) + w_outer(WC1, ds4(2), dz2(2))
                    + w_outer(WC1, ds4(3), dz2(3)) + w_outer(WC1, ds4(4), dz2(4)) + w_outer(WC1, ds4(5), dz2(5))
                    + w_outer(WC1, ds4(6), dz2(6)) + w_outer(WC1, ds4(7), dz2(7)) + w_outer(WC1, ds4(8), dz2(8))
                    + w_outer(WC1, ds4(9), dz2(9)) + w_outer(WC1, ds4(10), dz2(10)) + w_outer(WC1, ds4(11), dz2(11))
                    + w_outer(WC1, ds4(12), dz2(12)) + w_outer(WC1, ds4(13), dz2(13)) + w_outer(WC1, ds4(14), dz2(14))
                    + w_outer(WC1, ds4(15), dz2(15)) + w_outer(WC1, ds4(16), dz2(16)) + w_outer(WC1, ds4(17), dz2(17))
                    + w_outer(WC1, ds4(18), dz2(18));
            pxz_43 <= w_outer(WC0, ds4(0), dz3(0)) + w_outer(WC1, ds4(1), dz3(1)) + w_outer(WC1, ds4(2), dz3(2))
                    + w_outer(WC1, ds4(3), dz3(3)) + w_outer(WC1, ds4(4), dz3(4)) + w_outer(WC1, ds4(5), dz3(5))
                    + w_outer(WC1, ds4(6), dz3(6)) + w_outer(WC1, ds4(7), dz3(7)) + w_outer(WC1, ds4(8), dz3(8))
                    + w_outer(WC1, ds4(9), dz3(9)) + w_outer(WC1, ds4(10), dz3(10)) + w_outer(WC1, ds4(11), dz3(11))
                    + w_outer(WC1, ds4(12), dz3(12)) + w_outer(WC1, ds4(13), dz3(13)) + w_outer(WC1, ds4(14), dz3(14))
                    + w_outer(WC1, ds4(15), dz3(15)) + w_outer(WC1, ds4(16), dz3(16)) + w_outer(WC1, ds4(17), dz3(17))
                    + w_outer(WC1, ds4(18), dz3(18));

            pxz_51 <= w_outer(WC0, ds5(0), dz1(0)) + w_outer(WC1, ds5(1), dz1(1)) + w_outer(WC1, ds5(2), dz1(2))
                    + w_outer(WC1, ds5(3), dz1(3)) + w_outer(WC1, ds5(4), dz1(4)) + w_outer(WC1, ds5(5), dz1(5))
                    + w_outer(WC1, ds5(6), dz1(6)) + w_outer(WC1, ds5(7), dz1(7)) + w_outer(WC1, ds5(8), dz1(8))
                    + w_outer(WC1, ds5(9), dz1(9)) + w_outer(WC1, ds5(10), dz1(10)) + w_outer(WC1, ds5(11), dz1(11))
                    + w_outer(WC1, ds5(12), dz1(12)) + w_outer(WC1, ds5(13), dz1(13)) + w_outer(WC1, ds5(14), dz1(14))
                    + w_outer(WC1, ds5(15), dz1(15)) + w_outer(WC1, ds5(16), dz1(16)) + w_outer(WC1, ds5(17), dz1(17))
                    + w_outer(WC1, ds5(18), dz1(18));
            pxz_52 <= w_outer(WC0, ds5(0), dz2(0)) + w_outer(WC1, ds5(1), dz2(1)) + w_outer(WC1, ds5(2), dz2(2))
                    + w_outer(WC1, ds5(3), dz2(3)) + w_outer(WC1, ds5(4), dz2(4)) + w_outer(WC1, ds5(5), dz2(5))
                    + w_outer(WC1, ds5(6), dz2(6)) + w_outer(WC1, ds5(7), dz2(7)) + w_outer(WC1, ds5(8), dz2(8))
                    + w_outer(WC1, ds5(9), dz2(9)) + w_outer(WC1, ds5(10), dz2(10)) + w_outer(WC1, ds5(11), dz2(11))
                    + w_outer(WC1, ds5(12), dz2(12)) + w_outer(WC1, ds5(13), dz2(13)) + w_outer(WC1, ds5(14), dz2(14))
                    + w_outer(WC1, ds5(15), dz2(15)) + w_outer(WC1, ds5(16), dz2(16)) + w_outer(WC1, ds5(17), dz2(17))
                    + w_outer(WC1, ds5(18), dz2(18));
            pxz_53 <= w_outer(WC0, ds5(0), dz3(0)) + w_outer(WC1, ds5(1), dz3(1)) + w_outer(WC1, ds5(2), dz3(2))
                    + w_outer(WC1, ds5(3), dz3(3)) + w_outer(WC1, ds5(4), dz3(4)) + w_outer(WC1, ds5(5), dz3(5))
                    + w_outer(WC1, ds5(6), dz3(6)) + w_outer(WC1, ds5(7), dz3(7)) + w_outer(WC1, ds5(8), dz3(8))
                    + w_outer(WC1, ds5(9), dz3(9)) + w_outer(WC1, ds5(10), dz3(10)) + w_outer(WC1, ds5(11), dz3(11))
                    + w_outer(WC1, ds5(12), dz3(12)) + w_outer(WC1, ds5(13), dz3(13)) + w_outer(WC1, ds5(14), dz3(14))
                    + w_outer(WC1, ds5(15), dz3(15)) + w_outer(WC1, ds5(16), dz3(16)) + w_outer(WC1, ds5(17), dz3(17))
                    + w_outer(WC1, ds5(18), dz3(18));

            pxz_61 <= w_outer(WC0, ds6(0), dz1(0)) + w_outer(WC1, ds6(1), dz1(1)) + w_outer(WC1, ds6(2), dz1(2))
                    + w_outer(WC1, ds6(3), dz1(3)) + w_outer(WC1, ds6(4), dz1(4)) + w_outer(WC1, ds6(5), dz1(5))
                    + w_outer(WC1, ds6(6), dz1(6)) + w_outer(WC1, ds6(7), dz1(7)) + w_outer(WC1, ds6(8), dz1(8))
                    + w_outer(WC1, ds6(9), dz1(9)) + w_outer(WC1, ds6(10), dz1(10)) + w_outer(WC1, ds6(11), dz1(11))
                    + w_outer(WC1, ds6(12), dz1(12)) + w_outer(WC1, ds6(13), dz1(13)) + w_outer(WC1, ds6(14), dz1(14))
                    + w_outer(WC1, ds6(15), dz1(15)) + w_outer(WC1, ds6(16), dz1(16)) + w_outer(WC1, ds6(17), dz1(17))
                    + w_outer(WC1, ds6(18), dz1(18));
            pxz_62 <= w_outer(WC0, ds6(0), dz2(0)) + w_outer(WC1, ds6(1), dz2(1)) + w_outer(WC1, ds6(2), dz2(2))
                    + w_outer(WC1, ds6(3), dz2(3)) + w_outer(WC1, ds6(4), dz2(4)) + w_outer(WC1, ds6(5), dz2(5))
                    + w_outer(WC1, ds6(6), dz2(6)) + w_outer(WC1, ds6(7), dz2(7)) + w_outer(WC1, ds6(8), dz2(8))
                    + w_outer(WC1, ds6(9), dz2(9)) + w_outer(WC1, ds6(10), dz2(10)) + w_outer(WC1, ds6(11), dz2(11))
                    + w_outer(WC1, ds6(12), dz2(12)) + w_outer(WC1, ds6(13), dz2(13)) + w_outer(WC1, ds6(14), dz2(14))
                    + w_outer(WC1, ds6(15), dz2(15)) + w_outer(WC1, ds6(16), dz2(16)) + w_outer(WC1, ds6(17), dz2(17))
                    + w_outer(WC1, ds6(18), dz2(18));
            pxz_63 <= w_outer(WC0, ds6(0), dz3(0)) + w_outer(WC1, ds6(1), dz3(1)) + w_outer(WC1, ds6(2), dz3(2))
                    + w_outer(WC1, ds6(3), dz3(3)) + w_outer(WC1, ds6(4), dz3(4)) + w_outer(WC1, ds6(5), dz3(5))
                    + w_outer(WC1, ds6(6), dz3(6)) + w_outer(WC1, ds6(7), dz3(7)) + w_outer(WC1, ds6(8), dz3(8))
                    + w_outer(WC1, ds6(9), dz3(9)) + w_outer(WC1, ds6(10), dz3(10)) + w_outer(WC1, ds6(11), dz3(11))
                    + w_outer(WC1, ds6(12), dz3(12)) + w_outer(WC1, ds6(13), dz3(13)) + w_outer(WC1, ds6(14), dz3(14))
                    + w_outer(WC1, ds6(15), dz3(15)) + w_outer(WC1, ds6(16), dz3(16)) + w_outer(WC1, ds6(17), dz3(17))
                    + w_outer(WC1, ds6(18), dz3(18));

            pxz_71 <= w_outer(WC0, ds7(0), dz1(0)) + w_outer(WC1, ds7(1), dz1(1)) + w_outer(WC1, ds7(2), dz1(2))
                    + w_outer(WC1, ds7(3), dz1(3)) + w_outer(WC1, ds7(4), dz1(4)) + w_outer(WC1, ds7(5), dz1(5))
                    + w_outer(WC1, ds7(6), dz1(6)) + w_outer(WC1, ds7(7), dz1(7)) + w_outer(WC1, ds7(8), dz1(8))
                    + w_outer(WC1, ds7(9), dz1(9)) + w_outer(WC1, ds7(10), dz1(10)) + w_outer(WC1, ds7(11), dz1(11))
                    + w_outer(WC1, ds7(12), dz1(12)) + w_outer(WC1, ds7(13), dz1(13)) + w_outer(WC1, ds7(14), dz1(14))
                    + w_outer(WC1, ds7(15), dz1(15)) + w_outer(WC1, ds7(16), dz1(16)) + w_outer(WC1, ds7(17), dz1(17))
                    + w_outer(WC1, ds7(18), dz1(18));
            pxz_72 <= w_outer(WC0, ds7(0), dz2(0)) + w_outer(WC1, ds7(1), dz2(1)) + w_outer(WC1, ds7(2), dz2(2))
                    + w_outer(WC1, ds7(3), dz2(3)) + w_outer(WC1, ds7(4), dz2(4)) + w_outer(WC1, ds7(5), dz2(5))
                    + w_outer(WC1, ds7(6), dz2(6)) + w_outer(WC1, ds7(7), dz2(7)) + w_outer(WC1, ds7(8), dz2(8))
                    + w_outer(WC1, ds7(9), dz2(9)) + w_outer(WC1, ds7(10), dz2(10)) + w_outer(WC1, ds7(11), dz2(11))
                    + w_outer(WC1, ds7(12), dz2(12)) + w_outer(WC1, ds7(13), dz2(13)) + w_outer(WC1, ds7(14), dz2(14))
                    + w_outer(WC1, ds7(15), dz2(15)) + w_outer(WC1, ds7(16), dz2(16)) + w_outer(WC1, ds7(17), dz2(17))
                    + w_outer(WC1, ds7(18), dz2(18));
            pxz_73 <= w_outer(WC0, ds7(0), dz3(0)) + w_outer(WC1, ds7(1), dz3(1)) + w_outer(WC1, ds7(2), dz3(2))
                    + w_outer(WC1, ds7(3), dz3(3)) + w_outer(WC1, ds7(4), dz3(4)) + w_outer(WC1, ds7(5), dz3(5))
                    + w_outer(WC1, ds7(6), dz3(6)) + w_outer(WC1, ds7(7), dz3(7)) + w_outer(WC1, ds7(8), dz3(8))
                    + w_outer(WC1, ds7(9), dz3(9)) + w_outer(WC1, ds7(10), dz3(10)) + w_outer(WC1, ds7(11), dz3(11))
                    + w_outer(WC1, ds7(12), dz3(12)) + w_outer(WC1, ds7(13), dz3(13)) + w_outer(WC1, ds7(14), dz3(14))
                    + w_outer(WC1, ds7(15), dz3(15)) + w_outer(WC1, ds7(16), dz3(16)) + w_outer(WC1, ds7(17), dz3(17))
                    + w_outer(WC1, ds7(18), dz3(18));

            pxz_81 <= w_outer(WC0, ds8(0), dz1(0)) + w_outer(WC1, ds8(1), dz1(1)) + w_outer(WC1, ds8(2), dz1(2))
                    + w_outer(WC1, ds8(3), dz1(3)) + w_outer(WC1, ds8(4), dz1(4)) + w_outer(WC1, ds8(5), dz1(5))
                    + w_outer(WC1, ds8(6), dz1(6)) + w_outer(WC1, ds8(7), dz1(7)) + w_outer(WC1, ds8(8), dz1(8))
                    + w_outer(WC1, ds8(9), dz1(9)) + w_outer(WC1, ds8(10), dz1(10)) + w_outer(WC1, ds8(11), dz1(11))
                    + w_outer(WC1, ds8(12), dz1(12)) + w_outer(WC1, ds8(13), dz1(13)) + w_outer(WC1, ds8(14), dz1(14))
                    + w_outer(WC1, ds8(15), dz1(15)) + w_outer(WC1, ds8(16), dz1(16)) + w_outer(WC1, ds8(17), dz1(17))
                    + w_outer(WC1, ds8(18), dz1(18));
            pxz_82 <= w_outer(WC0, ds8(0), dz2(0)) + w_outer(WC1, ds8(1), dz2(1)) + w_outer(WC1, ds8(2), dz2(2))
                    + w_outer(WC1, ds8(3), dz2(3)) + w_outer(WC1, ds8(4), dz2(4)) + w_outer(WC1, ds8(5), dz2(5))
                    + w_outer(WC1, ds8(6), dz2(6)) + w_outer(WC1, ds8(7), dz2(7)) + w_outer(WC1, ds8(8), dz2(8))
                    + w_outer(WC1, ds8(9), dz2(9)) + w_outer(WC1, ds8(10), dz2(10)) + w_outer(WC1, ds8(11), dz2(11))
                    + w_outer(WC1, ds8(12), dz2(12)) + w_outer(WC1, ds8(13), dz2(13)) + w_outer(WC1, ds8(14), dz2(14))
                    + w_outer(WC1, ds8(15), dz2(15)) + w_outer(WC1, ds8(16), dz2(16)) + w_outer(WC1, ds8(17), dz2(17))
                    + w_outer(WC1, ds8(18), dz2(18));
            pxz_83 <= w_outer(WC0, ds8(0), dz3(0)) + w_outer(WC1, ds8(1), dz3(1)) + w_outer(WC1, ds8(2), dz3(2))
                    + w_outer(WC1, ds8(3), dz3(3)) + w_outer(WC1, ds8(4), dz3(4)) + w_outer(WC1, ds8(5), dz3(5))
                    + w_outer(WC1, ds8(6), dz3(6)) + w_outer(WC1, ds8(7), dz3(7)) + w_outer(WC1, ds8(8), dz3(8))
                    + w_outer(WC1, ds8(9), dz3(9)) + w_outer(WC1, ds8(10), dz3(10)) + w_outer(WC1, ds8(11), dz3(11))
                    + w_outer(WC1, ds8(12), dz3(12)) + w_outer(WC1, ds8(13), dz3(13)) + w_outer(WC1, ds8(14), dz3(14))
                    + w_outer(WC1, ds8(15), dz3(15)) + w_outer(WC1, ds8(16), dz3(16)) + w_outer(WC1, ds8(17), dz3(17))
                    + w_outer(WC1, ds8(18), dz3(18));

            pxz_91 <= w_outer(WC0, ds9(0), dz1(0)) + w_outer(WC1, ds9(1), dz1(1)) + w_outer(WC1, ds9(2), dz1(2))
                    + w_outer(WC1, ds9(3), dz1(3)) + w_outer(WC1, ds9(4), dz1(4)) + w_outer(WC1, ds9(5), dz1(5))
                    + w_outer(WC1, ds9(6), dz1(6)) + w_outer(WC1, ds9(7), dz1(7)) + w_outer(WC1, ds9(8), dz1(8))
                    + w_outer(WC1, ds9(9), dz1(9)) + w_outer(WC1, ds9(10), dz1(10)) + w_outer(WC1, ds9(11), dz1(11))
                    + w_outer(WC1, ds9(12), dz1(12)) + w_outer(WC1, ds9(13), dz1(13)) + w_outer(WC1, ds9(14), dz1(14))
                    + w_outer(WC1, ds9(15), dz1(15)) + w_outer(WC1, ds9(16), dz1(16)) + w_outer(WC1, ds9(17), dz1(17))
                    + w_outer(WC1, ds9(18), dz1(18));
            pxz_92 <= w_outer(WC0, ds9(0), dz2(0)) + w_outer(WC1, ds9(1), dz2(1)) + w_outer(WC1, ds9(2), dz2(2))
                    + w_outer(WC1, ds9(3), dz2(3)) + w_outer(WC1, ds9(4), dz2(4)) + w_outer(WC1, ds9(5), dz2(5))
                    + w_outer(WC1, ds9(6), dz2(6)) + w_outer(WC1, ds9(7), dz2(7)) + w_outer(WC1, ds9(8), dz2(8))
                    + w_outer(WC1, ds9(9), dz2(9)) + w_outer(WC1, ds9(10), dz2(10)) + w_outer(WC1, ds9(11), dz2(11))
                    + w_outer(WC1, ds9(12), dz2(12)) + w_outer(WC1, ds9(13), dz2(13)) + w_outer(WC1, ds9(14), dz2(14))
                    + w_outer(WC1, ds9(15), dz2(15)) + w_outer(WC1, ds9(16), dz2(16)) + w_outer(WC1, ds9(17), dz2(17))
                    + w_outer(WC1, ds9(18), dz2(18));
            pxz_93 <= w_outer(WC0, ds9(0), dz3(0)) + w_outer(WC1, ds9(1), dz3(1)) + w_outer(WC1, ds9(2), dz3(2))
                    + w_outer(WC1, ds9(3), dz3(3)) + w_outer(WC1, ds9(4), dz3(4)) + w_outer(WC1, ds9(5), dz3(5))
                    + w_outer(WC1, ds9(6), dz3(6)) + w_outer(WC1, ds9(7), dz3(7)) + w_outer(WC1, ds9(8), dz3(8))
                    + w_outer(WC1, ds9(9), dz3(9)) + w_outer(WC1, ds9(10), dz3(10)) + w_outer(WC1, ds9(11), dz3(11))
                    + w_outer(WC1, ds9(12), dz3(12)) + w_outer(WC1, ds9(13), dz3(13)) + w_outer(WC1, ds9(14), dz3(14))
                    + w_outer(WC1, ds9(15), dz3(15)) + w_outer(WC1, ds9(16), dz3(16)) + w_outer(WC1, ds9(17), dz3(17))
                    + w_outer(WC1, ds9(18), dz3(18));

            state <= FINISHED;

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

end Behavioral;
