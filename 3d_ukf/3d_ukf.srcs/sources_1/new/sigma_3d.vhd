library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.TEXTIO.ALL;

entity sigma_3d is
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    start       : in  std_logic;

    x_pos_mean  : in  signed(47 downto 0);
    x_vel_mean  : in  signed(47 downto 0);
    y_pos_mean  : in  signed(47 downto 0);
    y_vel_mean  : in  signed(47 downto 0);
    z_pos_mean  : in  signed(47 downto 0);
    z_vel_mean  : in  signed(47 downto 0);

    cholesky_done : in  std_logic;
    l11         : in  signed(47 downto 0);
    l21         : in  signed(47 downto 0);
    l31         : in  signed(47 downto 0);
    l41         : in  signed(47 downto 0);
    l51         : in  signed(47 downto 0);
    l61         : in  signed(47 downto 0);
    l22         : in  signed(47 downto 0);
    l32         : in  signed(47 downto 0);
    l42         : in  signed(47 downto 0);
    l52         : in  signed(47 downto 0);
    l62         : in  signed(47 downto 0);
    l33         : in  signed(47 downto 0);
    l43         : in  signed(47 downto 0);
    l53         : in  signed(47 downto 0);
    l63         : in  signed(47 downto 0);
    l44         : in  signed(47 downto 0);
    l54         : in  signed(47 downto 0);
    l64         : in  signed(47 downto 0);
    l55         : in  signed(47 downto 0);
    l65         : in  signed(47 downto 0);
    l66         : in  signed(47 downto 0);

    chi0_x_pos  : out signed(47 downto 0);
    chi0_x_vel  : out signed(47 downto 0);
    chi0_y_pos  : out signed(47 downto 0);
    chi0_y_vel  : out signed(47 downto 0);
    chi0_z_pos  : out signed(47 downto 0);
    chi0_z_vel  : out signed(47 downto 0);

    chi1_x_pos  : out signed(47 downto 0);
    chi1_x_vel  : out signed(47 downto 0);
    chi1_y_pos  : out signed(47 downto 0);
    chi1_y_vel  : out signed(47 downto 0);
    chi1_z_pos  : out signed(47 downto 0);
    chi1_z_vel  : out signed(47 downto 0);

    chi2_x_pos  : out signed(47 downto 0);
    chi2_x_vel  : out signed(47 downto 0);
    chi2_y_pos  : out signed(47 downto 0);
    chi2_y_vel  : out signed(47 downto 0);
    chi2_z_pos  : out signed(47 downto 0);
    chi2_z_vel  : out signed(47 downto 0);

    chi3_x_pos  : out signed(47 downto 0);
    chi3_x_vel  : out signed(47 downto 0);
    chi3_y_pos  : out signed(47 downto 0);
    chi3_y_vel  : out signed(47 downto 0);
    chi3_z_pos  : out signed(47 downto 0);
    chi3_z_vel  : out signed(47 downto 0);

    chi4_x_pos  : out signed(47 downto 0);
    chi4_x_vel  : out signed(47 downto 0);
    chi4_y_pos  : out signed(47 downto 0);
    chi4_y_vel  : out signed(47 downto 0);
    chi4_z_pos  : out signed(47 downto 0);
    chi4_z_vel  : out signed(47 downto 0);

    chi5_x_pos  : out signed(47 downto 0);
    chi5_x_vel  : out signed(47 downto 0);
    chi5_y_pos  : out signed(47 downto 0);
    chi5_y_vel  : out signed(47 downto 0);
    chi5_z_pos  : out signed(47 downto 0);
    chi5_z_vel  : out signed(47 downto 0);

    chi6_x_pos  : out signed(47 downto 0);
    chi6_x_vel  : out signed(47 downto 0);
    chi6_y_pos  : out signed(47 downto 0);
    chi6_y_vel  : out signed(47 downto 0);
    chi6_z_pos  : out signed(47 downto 0);
    chi6_z_vel  : out signed(47 downto 0);

    chi7_x_pos  : out signed(47 downto 0);
    chi7_x_vel  : out signed(47 downto 0);
    chi7_y_pos  : out signed(47 downto 0);
    chi7_y_vel  : out signed(47 downto 0);
    chi7_z_pos  : out signed(47 downto 0);
    chi7_z_vel  : out signed(47 downto 0);

    chi8_x_pos  : out signed(47 downto 0);
    chi8_x_vel  : out signed(47 downto 0);
    chi8_y_pos  : out signed(47 downto 0);
    chi8_y_vel  : out signed(47 downto 0);
    chi8_z_pos  : out signed(47 downto 0);
    chi8_z_vel  : out signed(47 downto 0);

    chi9_x_pos  : out signed(47 downto 0);
    chi9_x_vel  : out signed(47 downto 0);
    chi9_y_pos  : out signed(47 downto 0);
    chi9_y_vel  : out signed(47 downto 0);
    chi9_z_pos  : out signed(47 downto 0);
    chi9_z_vel  : out signed(47 downto 0);

    chi10_x_pos  : out signed(47 downto 0);
    chi10_x_vel  : out signed(47 downto 0);
    chi10_y_pos  : out signed(47 downto 0);
    chi10_y_vel  : out signed(47 downto 0);
    chi10_z_pos  : out signed(47 downto 0);
    chi10_z_vel  : out signed(47 downto 0);

    chi11_x_pos  : out signed(47 downto 0);
    chi11_x_vel  : out signed(47 downto 0);
    chi11_y_pos  : out signed(47 downto 0);
    chi11_y_vel  : out signed(47 downto 0);
    chi11_z_pos  : out signed(47 downto 0);
    chi11_z_vel  : out signed(47 downto 0);

    chi12_x_pos  : out signed(47 downto 0);
    chi12_x_vel  : out signed(47 downto 0);
    chi12_y_pos  : out signed(47 downto 0);
    chi12_y_vel  : out signed(47 downto 0);
    chi12_z_pos  : out signed(47 downto 0);
    chi12_z_vel  : out signed(47 downto 0);

    done  : out std_logic
  );
end entity;

architecture Behavioral of sigma_3d is

  type state_type is (IDLE, WAIT_SETTLE1, WAIT_SETTLE2, LATCH_INPUTS, CALCULATE, FINISHED);
  signal state : state_type := IDLE;

  constant GAMMA : signed(47 downto 0) := to_signed(29057024, 48);
  constant Q : integer := 24;

  signal x_pos_mean_reg : signed(47 downto 0) := (others => '0');
  signal x_vel_mean_reg : signed(47 downto 0) := (others => '0');
  signal y_pos_mean_reg : signed(47 downto 0) := (others => '0');
  signal y_vel_mean_reg : signed(47 downto 0) := (others => '0');
  signal z_pos_mean_reg : signed(47 downto 0) := (others => '0');
  signal z_vel_mean_reg : signed(47 downto 0) := (others => '0');

  signal l11_reg, l21_reg, l31_reg, l41_reg, l51_reg, l61_reg : signed(47 downto 0) := (others => '0');
  signal l22_reg, l32_reg, l42_reg, l52_reg, l62_reg : signed(47 downto 0) := (others => '0');
  signal l33_reg, l43_reg, l53_reg, l63_reg : signed(47 downto 0) := (others => '0');
  signal l44_reg, l54_reg, l64_reg : signed(47 downto 0) := (others => '0');
  signal l55_reg, l65_reg : signed(47 downto 0) := (others => '0');
  signal l66_reg : signed(47 downto 0) := (others => '0');

  signal chi0_x_pos_int, chi0_x_vel_int, chi0_y_pos_int, chi0_y_vel_int, chi0_z_pos_int, chi0_z_vel_int : signed(47 downto 0) := (others => '0');
  signal chi1_x_pos_int, chi1_x_vel_int, chi1_y_pos_int, chi1_y_vel_int, chi1_z_pos_int, chi1_z_vel_int : signed(47 downto 0) := (others => '0');
  signal chi2_x_pos_int, chi2_x_vel_int, chi2_y_pos_int, chi2_y_vel_int, chi2_z_pos_int, chi2_z_vel_int : signed(47 downto 0) := (others => '0');
  signal chi3_x_pos_int, chi3_x_vel_int, chi3_y_pos_int, chi3_y_vel_int, chi3_z_pos_int, chi3_z_vel_int : signed(47 downto 0) := (others => '0');
  signal chi4_x_pos_int, chi4_x_vel_int, chi4_y_pos_int, chi4_y_vel_int, chi4_z_pos_int, chi4_z_vel_int : signed(47 downto 0) := (others => '0');
  signal chi5_x_pos_int, chi5_x_vel_int, chi5_y_pos_int, chi5_y_vel_int, chi5_z_pos_int, chi5_z_vel_int : signed(47 downto 0) := (others => '0');
  signal chi6_x_pos_int, chi6_x_vel_int, chi6_y_pos_int, chi6_y_vel_int, chi6_z_pos_int, chi6_z_vel_int : signed(47 downto 0) := (others => '0');
  signal chi7_x_pos_int, chi7_x_vel_int, chi7_y_pos_int, chi7_y_vel_int, chi7_z_pos_int, chi7_z_vel_int : signed(47 downto 0) := (others => '0');
  signal chi8_x_pos_int, chi8_x_vel_int, chi8_y_pos_int, chi8_y_vel_int, chi8_z_pos_int, chi8_z_vel_int : signed(47 downto 0) := (others => '0');
  signal chi9_x_pos_int, chi9_x_vel_int, chi9_y_pos_int, chi9_y_vel_int, chi9_z_pos_int, chi9_z_vel_int : signed(47 downto 0) := (others => '0');
  signal chi10_x_pos_int, chi10_x_vel_int, chi10_y_pos_int, chi10_y_vel_int, chi10_z_pos_int, chi10_z_vel_int : signed(47 downto 0) := (others => '0');
  signal chi11_x_pos_int, chi11_x_vel_int, chi11_y_pos_int, chi11_y_vel_int, chi11_z_pos_int, chi11_z_vel_int : signed(47 downto 0) := (others => '0');
  signal chi12_x_pos_int, chi12_x_vel_int, chi12_y_pos_int, chi12_y_vel_int, chi12_z_pos_int, chi12_z_vel_int : signed(47 downto 0) := (others => '0');

begin

  process(clk, rst)
  begin
    if rst = '1' then

      state <= IDLE;
      done <= '0';

      x_pos_mean_reg <= (others => '0');
      x_vel_mean_reg <= (others => '0');
      y_pos_mean_reg <= (others => '0');
      y_vel_mean_reg <= (others => '0');
      z_pos_mean_reg <= (others => '0');
      z_vel_mean_reg <= (others => '0');

      l11_reg <= (others => '0'); l21_reg <= (others => '0'); l31_reg <= (others => '0'); l41_reg <= (others => '0'); l51_reg <= (others => '0'); l61_reg <= (others => '0');
      l22_reg <= (others => '0'); l32_reg <= (others => '0'); l42_reg <= (others => '0'); l52_reg <= (others => '0'); l62_reg <= (others => '0');
      l33_reg <= (others => '0'); l43_reg <= (others => '0'); l53_reg <= (others => '0'); l63_reg <= (others => '0');
      l44_reg <= (others => '0'); l54_reg <= (others => '0'); l64_reg <= (others => '0');
      l55_reg <= (others => '0'); l65_reg <= (others => '0');
      l66_reg <= (others => '0');

      chi0_x_pos_int <= (others => '0'); chi0_x_vel_int <= (others => '0'); chi0_y_pos_int <= (others => '0'); chi0_y_vel_int <= (others => '0'); chi0_z_pos_int <= (others => '0'); chi0_z_vel_int <= (others => '0');
      chi1_x_pos_int <= (others => '0'); chi1_x_vel_int <= (others => '0'); chi1_y_pos_int <= (others => '0'); chi1_y_vel_int <= (others => '0'); chi1_z_pos_int <= (others => '0'); chi1_z_vel_int <= (others => '0');
      chi2_x_pos_int <= (others => '0'); chi2_x_vel_int <= (others => '0'); chi2_y_pos_int <= (others => '0'); chi2_y_vel_int <= (others => '0'); chi2_z_pos_int <= (others => '0'); chi2_z_vel_int <= (others => '0');
      chi3_x_pos_int <= (others => '0'); chi3_x_vel_int <= (others => '0'); chi3_y_pos_int <= (others => '0'); chi3_y_vel_int <= (others => '0'); chi3_z_pos_int <= (others => '0'); chi3_z_vel_int <= (others => '0');
      chi4_x_pos_int <= (others => '0'); chi4_x_vel_int <= (others => '0'); chi4_y_pos_int <= (others => '0'); chi4_y_vel_int <= (others => '0'); chi4_z_pos_int <= (others => '0'); chi4_z_vel_int <= (others => '0');
      chi5_x_pos_int <= (others => '0'); chi5_x_vel_int <= (others => '0'); chi5_y_pos_int <= (others => '0'); chi5_y_vel_int <= (others => '0'); chi5_z_pos_int <= (others => '0'); chi5_z_vel_int <= (others => '0');
      chi6_x_pos_int <= (others => '0'); chi6_x_vel_int <= (others => '0'); chi6_y_pos_int <= (others => '0'); chi6_y_vel_int <= (others => '0'); chi6_z_pos_int <= (others => '0'); chi6_z_vel_int <= (others => '0');
      chi7_x_pos_int <= (others => '0'); chi7_x_vel_int <= (others => '0'); chi7_y_pos_int <= (others => '0'); chi7_y_vel_int <= (others => '0'); chi7_z_pos_int <= (others => '0'); chi7_z_vel_int <= (others => '0');
      chi8_x_pos_int <= (others => '0'); chi8_x_vel_int <= (others => '0'); chi8_y_pos_int <= (others => '0'); chi8_y_vel_int <= (others => '0'); chi8_z_pos_int <= (others => '0'); chi8_z_vel_int <= (others => '0');
      chi9_x_pos_int <= (others => '0'); chi9_x_vel_int <= (others => '0'); chi9_y_pos_int <= (others => '0'); chi9_y_vel_int <= (others => '0'); chi9_z_pos_int <= (others => '0'); chi9_z_vel_int <= (others => '0');
      chi10_x_pos_int <= (others => '0'); chi10_x_vel_int <= (others => '0'); chi10_y_pos_int <= (others => '0'); chi10_y_vel_int <= (others => '0'); chi10_z_pos_int <= (others => '0'); chi10_z_vel_int <= (others => '0');
      chi11_x_pos_int <= (others => '0'); chi11_x_vel_int <= (others => '0'); chi11_y_pos_int <= (others => '0'); chi11_y_vel_int <= (others => '0'); chi11_z_pos_int <= (others => '0'); chi11_z_vel_int <= (others => '0');
      chi12_x_pos_int <= (others => '0'); chi12_x_vel_int <= (others => '0'); chi12_y_pos_int <= (others => '0'); chi12_y_vel_int <= (others => '0'); chi12_z_pos_int <= (others => '0'); chi12_z_vel_int <= (others => '0');

    elsif rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if cholesky_done = '1' then

            state <= WAIT_SETTLE1;
          end if;

        when WAIT_SETTLE1 =>

          state <= WAIT_SETTLE2;

        when WAIT_SETTLE2 =>

          state <= LATCH_INPUTS;

        when LATCH_INPUTS =>

          x_pos_mean_reg <= x_pos_mean;
          x_vel_mean_reg <= x_vel_mean;
          y_pos_mean_reg <= y_pos_mean;
          y_vel_mean_reg <= y_vel_mean;
          z_pos_mean_reg <= z_pos_mean;
          z_vel_mean_reg <= z_vel_mean;

          l11_reg <= l11; l21_reg <= l21; l31_reg <= l31; l41_reg <= l41; l51_reg <= l51; l61_reg <= l61;
          l22_reg <= l22; l32_reg <= l32; l42_reg <= l42; l52_reg <= l52; l62_reg <= l62;
          l33_reg <= l33; l43_reg <= l43; l53_reg <= l53; l63_reg <= l63;
          l44_reg <= l44; l54_reg <= l54; l64_reg <= l64;
          l55_reg <= l55; l65_reg <= l65;
          l66_reg <= l66;

          report "SIGMA_3D: LATCH_INPUTS" & LF &
                 "  x_pos_mean=" & integer'image(to_integer(x_pos_mean)) & LF &
                 "  y_pos_mean=" & integer'image(to_integer(y_pos_mean)) & LF &
                 "  z_pos_mean=" & integer'image(to_integer(z_pos_mean)) & LF &
                 "  l11=" & integer'image(to_integer(l11)) & LF &
                 "  l66=" & integer'image(to_integer(l66));

          state <= CALCULATE;

        when CALCULATE =>

          chi0_x_pos_int <= x_pos_mean_reg;
          chi0_x_vel_int <= x_vel_mean_reg;
          chi0_y_pos_int <= y_pos_mean_reg;
          chi0_y_vel_int <= y_vel_mean_reg;
          chi0_z_pos_int <= z_pos_mean_reg;
          chi0_z_vel_int <= z_vel_mean_reg;

          chi1_x_pos_int <= x_pos_mean_reg + resize(shift_right(GAMMA * l11_reg, Q), 48);
          chi1_x_vel_int <= x_vel_mean_reg + resize(shift_right(GAMMA * l21_reg, Q), 48);
          chi1_y_pos_int <= y_pos_mean_reg + resize(shift_right(GAMMA * l31_reg, Q), 48);
          chi1_y_vel_int <= y_vel_mean_reg + resize(shift_right(GAMMA * l41_reg, Q), 48);
          chi1_z_pos_int <= z_pos_mean_reg + resize(shift_right(GAMMA * l51_reg, Q), 48);
          chi1_z_vel_int <= z_vel_mean_reg + resize(shift_right(GAMMA * l61_reg, Q), 48);

          chi2_x_pos_int <= x_pos_mean_reg;
          chi2_x_vel_int <= x_vel_mean_reg + resize(shift_right(GAMMA * l22_reg, Q), 48);
          chi2_y_pos_int <= y_pos_mean_reg + resize(shift_right(GAMMA * l32_reg, Q), 48);
          chi2_y_vel_int <= y_vel_mean_reg + resize(shift_right(GAMMA * l42_reg, Q), 48);
          chi2_z_pos_int <= z_pos_mean_reg + resize(shift_right(GAMMA * l52_reg, Q), 48);
          chi2_z_vel_int <= z_vel_mean_reg + resize(shift_right(GAMMA * l62_reg, Q), 48);

          chi3_x_pos_int <= x_pos_mean_reg;
          chi3_x_vel_int <= x_vel_mean_reg;
          chi3_y_pos_int <= y_pos_mean_reg + resize(shift_right(GAMMA * l33_reg, Q), 48);
          chi3_y_vel_int <= y_vel_mean_reg + resize(shift_right(GAMMA * l43_reg, Q), 48);
          chi3_z_pos_int <= z_pos_mean_reg + resize(shift_right(GAMMA * l53_reg, Q), 48);
          chi3_z_vel_int <= z_vel_mean_reg + resize(shift_right(GAMMA * l63_reg, Q), 48);

          chi4_x_pos_int <= x_pos_mean_reg;
          chi4_x_vel_int <= x_vel_mean_reg;
          chi4_y_pos_int <= y_pos_mean_reg;
          chi4_y_vel_int <= y_vel_mean_reg + resize(shift_right(GAMMA * l44_reg, Q), 48);
          chi4_z_pos_int <= z_pos_mean_reg + resize(shift_right(GAMMA * l54_reg, Q), 48);
          chi4_z_vel_int <= z_vel_mean_reg + resize(shift_right(GAMMA * l64_reg, Q), 48);

          chi5_x_pos_int <= x_pos_mean_reg;
          chi5_x_vel_int <= x_vel_mean_reg;
          chi5_y_pos_int <= y_pos_mean_reg;
          chi5_y_vel_int <= y_vel_mean_reg;
          chi5_z_pos_int <= z_pos_mean_reg + resize(shift_right(GAMMA * l55_reg, Q), 48);
          chi5_z_vel_int <= z_vel_mean_reg + resize(shift_right(GAMMA * l65_reg, Q), 48);

          chi6_x_pos_int <= x_pos_mean_reg;
          chi6_x_vel_int <= x_vel_mean_reg;
          chi6_y_pos_int <= y_pos_mean_reg;
          chi6_y_vel_int <= y_vel_mean_reg;
          chi6_z_pos_int <= z_pos_mean_reg;
          chi6_z_vel_int <= z_vel_mean_reg + resize(shift_right(GAMMA * l66_reg, Q), 48);

          chi7_x_pos_int <= x_pos_mean_reg - resize(shift_right(GAMMA * l11_reg, Q), 48);
          chi7_x_vel_int <= x_vel_mean_reg - resize(shift_right(GAMMA * l21_reg, Q), 48);
          chi7_y_pos_int <= y_pos_mean_reg - resize(shift_right(GAMMA * l31_reg, Q), 48);
          chi7_y_vel_int <= y_vel_mean_reg - resize(shift_right(GAMMA * l41_reg, Q), 48);
          chi7_z_pos_int <= z_pos_mean_reg - resize(shift_right(GAMMA * l51_reg, Q), 48);
          chi7_z_vel_int <= z_vel_mean_reg - resize(shift_right(GAMMA * l61_reg, Q), 48);

          chi8_x_pos_int <= x_pos_mean_reg;
          chi8_x_vel_int <= x_vel_mean_reg - resize(shift_right(GAMMA * l22_reg, Q), 48);
          chi8_y_pos_int <= y_pos_mean_reg - resize(shift_right(GAMMA * l32_reg, Q), 48);
          chi8_y_vel_int <= y_vel_mean_reg - resize(shift_right(GAMMA * l42_reg, Q), 48);
          chi8_z_pos_int <= z_pos_mean_reg - resize(shift_right(GAMMA * l52_reg, Q), 48);
          chi8_z_vel_int <= z_vel_mean_reg - resize(shift_right(GAMMA * l62_reg, Q), 48);

          chi9_x_pos_int <= x_pos_mean_reg;
          chi9_x_vel_int <= x_vel_mean_reg;
          chi9_y_pos_int <= y_pos_mean_reg - resize(shift_right(GAMMA * l33_reg, Q), 48);
          chi9_y_vel_int <= y_vel_mean_reg - resize(shift_right(GAMMA * l43_reg, Q), 48);
          chi9_z_pos_int <= z_pos_mean_reg - resize(shift_right(GAMMA * l53_reg, Q), 48);
          chi9_z_vel_int <= z_vel_mean_reg - resize(shift_right(GAMMA * l63_reg, Q), 48);

          chi10_x_pos_int <= x_pos_mean_reg;
          chi10_x_vel_int <= x_vel_mean_reg;
          chi10_y_pos_int <= y_pos_mean_reg;
          chi10_y_vel_int <= y_vel_mean_reg - resize(shift_right(GAMMA * l44_reg, Q), 48);
          chi10_z_pos_int <= z_pos_mean_reg - resize(shift_right(GAMMA * l54_reg, Q), 48);
          chi10_z_vel_int <= z_vel_mean_reg - resize(shift_right(GAMMA * l64_reg, Q), 48);

          chi11_x_pos_int <= x_pos_mean_reg;
          chi11_x_vel_int <= x_vel_mean_reg;
          chi11_y_pos_int <= y_pos_mean_reg;
          chi11_y_vel_int <= y_vel_mean_reg;
          chi11_z_pos_int <= z_pos_mean_reg - resize(shift_right(GAMMA * l55_reg, Q), 48);
          chi11_z_vel_int <= z_vel_mean_reg - resize(shift_right(GAMMA * l65_reg, Q), 48);

          chi12_x_pos_int <= x_pos_mean_reg;
          chi12_x_vel_int <= x_vel_mean_reg;
          chi12_y_pos_int <= y_pos_mean_reg;
          chi12_y_vel_int <= y_vel_mean_reg;
          chi12_z_pos_int <= z_pos_mean_reg;
          chi12_z_vel_int <= z_vel_mean_reg - resize(shift_right(GAMMA * l66_reg, Q), 48);

          state <= FINISHED;

        when FINISHED =>
          done <= '1';

          report "SIGMA_3D: FINISHED state (values should be settled)" & LF &
                 "  chi0_x_pos_int=" & integer'image(to_integer(chi0_x_pos_int)) & LF &
                 "  chi1_x_pos_int=" & integer'image(to_integer(chi1_x_pos_int)) & LF &
                 "  chi0_z_pos_int=" & integer'image(to_integer(chi0_z_pos_int)) & LF &
                 "  chi1_z_pos_int=" & integer'image(to_integer(chi1_z_pos_int));

          if cholesky_done = '0' then
            state <= IDLE;
          end if;

        when others =>
          state <= IDLE;
      end case;
    end if;
  end process;

  chi0_x_pos <= chi0_x_pos_int; chi0_x_vel <= chi0_x_vel_int; chi0_y_pos <= chi0_y_pos_int; chi0_y_vel <= chi0_y_vel_int; chi0_z_pos <= chi0_z_pos_int; chi0_z_vel <= chi0_z_vel_int;
  chi1_x_pos <= chi1_x_pos_int; chi1_x_vel <= chi1_x_vel_int; chi1_y_pos <= chi1_y_pos_int; chi1_y_vel <= chi1_y_vel_int; chi1_z_pos <= chi1_z_pos_int; chi1_z_vel <= chi1_z_vel_int;
  chi2_x_pos <= chi2_x_pos_int; chi2_x_vel <= chi2_x_vel_int; chi2_y_pos <= chi2_y_pos_int; chi2_y_vel <= chi2_y_vel_int; chi2_z_pos <= chi2_z_pos_int; chi2_z_vel <= chi2_z_vel_int;
  chi3_x_pos <= chi3_x_pos_int; chi3_x_vel <= chi3_x_vel_int; chi3_y_pos <= chi3_y_pos_int; chi3_y_vel <= chi3_y_vel_int; chi3_z_pos <= chi3_z_pos_int; chi3_z_vel <= chi3_z_vel_int;
  chi4_x_pos <= chi4_x_pos_int; chi4_x_vel <= chi4_x_vel_int; chi4_y_pos <= chi4_y_pos_int; chi4_y_vel <= chi4_y_vel_int; chi4_z_pos <= chi4_z_pos_int; chi4_z_vel <= chi4_z_vel_int;
  chi5_x_pos <= chi5_x_pos_int; chi5_x_vel <= chi5_x_vel_int; chi5_y_pos <= chi5_y_pos_int; chi5_y_vel <= chi5_y_vel_int; chi5_z_pos <= chi5_z_pos_int; chi5_z_vel <= chi5_z_vel_int;
  chi6_x_pos <= chi6_x_pos_int; chi6_x_vel <= chi6_x_vel_int; chi6_y_pos <= chi6_y_pos_int; chi6_y_vel <= chi6_y_vel_int; chi6_z_pos <= chi6_z_pos_int; chi6_z_vel <= chi6_z_vel_int;
  chi7_x_pos <= chi7_x_pos_int; chi7_x_vel <= chi7_x_vel_int; chi7_y_pos <= chi7_y_pos_int; chi7_y_vel <= chi7_y_vel_int; chi7_z_pos <= chi7_z_pos_int; chi7_z_vel <= chi7_z_vel_int;
  chi8_x_pos <= chi8_x_pos_int; chi8_x_vel <= chi8_x_vel_int; chi8_y_pos <= chi8_y_pos_int; chi8_y_vel <= chi8_y_vel_int; chi8_z_pos <= chi8_z_pos_int; chi8_z_vel <= chi8_z_vel_int;
  chi9_x_pos <= chi9_x_pos_int; chi9_x_vel <= chi9_x_vel_int; chi9_y_pos <= chi9_y_pos_int; chi9_y_vel <= chi9_y_vel_int; chi9_z_pos <= chi9_z_pos_int; chi9_z_vel <= chi9_z_vel_int;
  chi10_x_pos <= chi10_x_pos_int; chi10_x_vel <= chi10_x_vel_int; chi10_y_pos <= chi10_y_pos_int; chi10_y_vel <= chi10_y_vel_int; chi10_z_pos <= chi10_z_pos_int; chi10_z_vel <= chi10_z_vel_int;
  chi11_x_pos <= chi11_x_pos_int; chi11_x_vel <= chi11_x_vel_int; chi11_y_pos <= chi11_y_pos_int; chi11_y_vel <= chi11_y_vel_int; chi11_z_pos <= chi11_z_pos_int; chi11_z_vel <= chi11_z_vel_int;
  chi12_x_pos <= chi12_x_pos_int; chi12_x_vel <= chi12_x_vel_int; chi12_y_pos <= chi12_y_pos_int; chi12_y_vel <= chi12_y_vel_int; chi12_z_pos <= chi12_z_pos_int; chi12_z_vel <= chi12_z_vel_int;

end Behavioral;
