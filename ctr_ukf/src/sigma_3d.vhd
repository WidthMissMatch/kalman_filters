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
    x_omega_mean  : in  signed(47 downto 0);
    y_pos_mean  : in  signed(47 downto 0);
    y_vel_mean  : in  signed(47 downto 0);
    y_omega_mean  : in  signed(47 downto 0);
    z_pos_mean  : in  signed(47 downto 0);
    z_vel_mean  : in  signed(47 downto 0);
    z_omega_mean  : in  signed(47 downto 0);

    cholesky_done : in  std_logic;
    l11, l21, l31, l41, l51, l61, l71, l81, l91 : in signed(47 downto 0);
    l22, l32, l42, l52, l62, l72, l82, l92      : in signed(47 downto 0);
    l33, l43, l53, l63, l73, l83, l93           : in signed(47 downto 0);
    l44, l54, l64, l74, l84, l94                : in signed(47 downto 0);
    l55, l65, l75, l85, l95                     : in signed(47 downto 0);
    l66, l76, l86, l96                          : in signed(47 downto 0);
    l77, l87, l97                               : in signed(47 downto 0);
    l88, l98                                    : in signed(47 downto 0);
    l99                                         : in signed(47 downto 0);

    chi0_x_pos, chi0_x_vel, chi0_x_omega, chi0_y_pos, chi0_y_vel, chi0_y_omega, chi0_z_pos, chi0_z_vel, chi0_z_omega : out signed(47 downto 0);

    chi1_x_pos, chi1_x_vel, chi1_x_omega, chi1_y_pos, chi1_y_vel, chi1_y_omega, chi1_z_pos, chi1_z_vel, chi1_z_omega : out signed(47 downto 0);
    chi2_x_pos, chi2_x_vel, chi2_x_omega, chi2_y_pos, chi2_y_vel, chi2_y_omega, chi2_z_pos, chi2_z_vel, chi2_z_omega : out signed(47 downto 0);
    chi3_x_pos, chi3_x_vel, chi3_x_omega, chi3_y_pos, chi3_y_vel, chi3_y_omega, chi3_z_pos, chi3_z_vel, chi3_z_omega : out signed(47 downto 0);
    chi4_x_pos, chi4_x_vel, chi4_x_omega, chi4_y_pos, chi4_y_vel, chi4_y_omega, chi4_z_pos, chi4_z_vel, chi4_z_omega : out signed(47 downto 0);
    chi5_x_pos, chi5_x_vel, chi5_x_omega, chi5_y_pos, chi5_y_vel, chi5_y_omega, chi5_z_pos, chi5_z_vel, chi5_z_omega : out signed(47 downto 0);
    chi6_x_pos, chi6_x_vel, chi6_x_omega, chi6_y_pos, chi6_y_vel, chi6_y_omega, chi6_z_pos, chi6_z_vel, chi6_z_omega : out signed(47 downto 0);
    chi7_x_pos, chi7_x_vel, chi7_x_omega, chi7_y_pos, chi7_y_vel, chi7_y_omega, chi7_z_pos, chi7_z_vel, chi7_z_omega : out signed(47 downto 0);
    chi8_x_pos, chi8_x_vel, chi8_x_omega, chi8_y_pos, chi8_y_vel, chi8_y_omega, chi8_z_pos, chi8_z_vel, chi8_z_omega : out signed(47 downto 0);
    chi9_x_pos, chi9_x_vel, chi9_x_omega, chi9_y_pos, chi9_y_vel, chi9_y_omega, chi9_z_pos, chi9_z_vel, chi9_z_omega : out signed(47 downto 0);

    chi10_x_pos, chi10_x_vel, chi10_x_omega, chi10_y_pos, chi10_y_vel, chi10_y_omega, chi10_z_pos, chi10_z_vel, chi10_z_omega : out signed(47 downto 0);
    chi11_x_pos, chi11_x_vel, chi11_x_omega, chi11_y_pos, chi11_y_vel, chi11_y_omega, chi11_z_pos, chi11_z_vel, chi11_z_omega : out signed(47 downto 0);
    chi12_x_pos, chi12_x_vel, chi12_x_omega, chi12_y_pos, chi12_y_vel, chi12_y_omega, chi12_z_pos, chi12_z_vel, chi12_z_omega : out signed(47 downto 0);
    chi13_x_pos, chi13_x_vel, chi13_x_omega, chi13_y_pos, chi13_y_vel, chi13_y_omega, chi13_z_pos, chi13_z_vel, chi13_z_omega : out signed(47 downto 0);
    chi14_x_pos, chi14_x_vel, chi14_x_omega, chi14_y_pos, chi14_y_vel, chi14_y_omega, chi14_z_pos, chi14_z_vel, chi14_z_omega : out signed(47 downto 0);
    chi15_x_pos, chi15_x_vel, chi15_x_omega, chi15_y_pos, chi15_y_vel, chi15_y_omega, chi15_z_pos, chi15_z_vel, chi15_z_omega : out signed(47 downto 0);
    chi16_x_pos, chi16_x_vel, chi16_x_omega, chi16_y_pos, chi16_y_vel, chi16_y_omega, chi16_z_pos, chi16_z_vel, chi16_z_omega : out signed(47 downto 0);
    chi17_x_pos, chi17_x_vel, chi17_x_omega, chi17_y_pos, chi17_y_vel, chi17_y_omega, chi17_z_pos, chi17_z_vel, chi17_z_omega : out signed(47 downto 0);
    chi18_x_pos, chi18_x_vel, chi18_x_omega, chi18_y_pos, chi18_y_vel, chi18_y_omega, chi18_z_pos, chi18_z_vel, chi18_z_omega : out signed(47 downto 0);

    done  : out std_logic
  );
end entity;

architecture Behavioral of sigma_3d is

  type state_type is (IDLE, LATCH_INPUTS, CALCULATE, FINISHED);
  signal state : state_type := IDLE;

  constant GAMMA : signed(47 downto 0) := to_signed(50331648, 48);
  constant Q : integer := 24;

  signal x_pos_mean_reg, x_vel_mean_reg, x_omega_mean_reg : signed(47 downto 0) := (others => '0');
  signal y_pos_mean_reg, y_vel_mean_reg, y_omega_mean_reg : signed(47 downto 0) := (others => '0');
  signal z_pos_mean_reg, z_vel_mean_reg, z_omega_mean_reg : signed(47 downto 0) := (others => '0');

  signal l11_reg, l21_reg, l31_reg, l41_reg, l51_reg, l61_reg, l71_reg, l81_reg, l91_reg : signed(47 downto 0) := (others => '0');
  signal l22_reg, l32_reg, l42_reg, l52_reg, l62_reg, l72_reg, l82_reg, l92_reg          : signed(47 downto 0) := (others => '0');
  signal l33_reg, l43_reg, l53_reg, l63_reg, l73_reg, l83_reg, l93_reg                   : signed(47 downto 0) := (others => '0');
  signal l44_reg, l54_reg, l64_reg, l74_reg, l84_reg, l94_reg                            : signed(47 downto 0) := (others => '0');
  signal l55_reg, l65_reg, l75_reg, l85_reg, l95_reg                                     : signed(47 downto 0) := (others => '0');
  signal l66_reg, l76_reg, l86_reg, l96_reg                                              : signed(47 downto 0) := (others => '0');
  signal l77_reg, l87_reg, l97_reg                                                       : signed(47 downto 0) := (others => '0');
  signal l88_reg, l98_reg                                                                : signed(47 downto 0) := (others => '0');
  signal l99_reg                                                                         : signed(47 downto 0) := (others => '0');

  signal chi0_x_pos_int, chi0_x_vel_int, chi0_x_omega_int, chi0_y_pos_int, chi0_y_vel_int, chi0_y_omega_int, chi0_z_pos_int, chi0_z_vel_int, chi0_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi1_x_pos_int, chi1_x_vel_int, chi1_x_omega_int, chi1_y_pos_int, chi1_y_vel_int, chi1_y_omega_int, chi1_z_pos_int, chi1_z_vel_int, chi1_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi2_x_pos_int, chi2_x_vel_int, chi2_x_omega_int, chi2_y_pos_int, chi2_y_vel_int, chi2_y_omega_int, chi2_z_pos_int, chi2_z_vel_int, chi2_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi3_x_pos_int, chi3_x_vel_int, chi3_x_omega_int, chi3_y_pos_int, chi3_y_vel_int, chi3_y_omega_int, chi3_z_pos_int, chi3_z_vel_int, chi3_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi4_x_pos_int, chi4_x_vel_int, chi4_x_omega_int, chi4_y_pos_int, chi4_y_vel_int, chi4_y_omega_int, chi4_z_pos_int, chi4_z_vel_int, chi4_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi5_x_pos_int, chi5_x_vel_int, chi5_x_omega_int, chi5_y_pos_int, chi5_y_vel_int, chi5_y_omega_int, chi5_z_pos_int, chi5_z_vel_int, chi5_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi6_x_pos_int, chi6_x_vel_int, chi6_x_omega_int, chi6_y_pos_int, chi6_y_vel_int, chi6_y_omega_int, chi6_z_pos_int, chi6_z_vel_int, chi6_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi7_x_pos_int, chi7_x_vel_int, chi7_x_omega_int, chi7_y_pos_int, chi7_y_vel_int, chi7_y_omega_int, chi7_z_pos_int, chi7_z_vel_int, chi7_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi8_x_pos_int, chi8_x_vel_int, chi8_x_omega_int, chi8_y_pos_int, chi8_y_vel_int, chi8_y_omega_int, chi8_z_pos_int, chi8_z_vel_int, chi8_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi9_x_pos_int, chi9_x_vel_int, chi9_x_omega_int, chi9_y_pos_int, chi9_y_vel_int, chi9_y_omega_int, chi9_z_pos_int, chi9_z_vel_int, chi9_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi10_x_pos_int, chi10_x_vel_int, chi10_x_omega_int, chi10_y_pos_int, chi10_y_vel_int, chi10_y_omega_int, chi10_z_pos_int, chi10_z_vel_int, chi10_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi11_x_pos_int, chi11_x_vel_int, chi11_x_omega_int, chi11_y_pos_int, chi11_y_vel_int, chi11_y_omega_int, chi11_z_pos_int, chi11_z_vel_int, chi11_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi12_x_pos_int, chi12_x_vel_int, chi12_x_omega_int, chi12_y_pos_int, chi12_y_vel_int, chi12_y_omega_int, chi12_z_pos_int, chi12_z_vel_int, chi12_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi13_x_pos_int, chi13_x_vel_int, chi13_x_omega_int, chi13_y_pos_int, chi13_y_vel_int, chi13_y_omega_int, chi13_z_pos_int, chi13_z_vel_int, chi13_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi14_x_pos_int, chi14_x_vel_int, chi14_x_omega_int, chi14_y_pos_int, chi14_y_vel_int, chi14_y_omega_int, chi14_z_pos_int, chi14_z_vel_int, chi14_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi15_x_pos_int, chi15_x_vel_int, chi15_x_omega_int, chi15_y_pos_int, chi15_y_vel_int, chi15_y_omega_int, chi15_z_pos_int, chi15_z_vel_int, chi15_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi16_x_pos_int, chi16_x_vel_int, chi16_x_omega_int, chi16_y_pos_int, chi16_y_vel_int, chi16_y_omega_int, chi16_z_pos_int, chi16_z_vel_int, chi16_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi17_x_pos_int, chi17_x_vel_int, chi17_x_omega_int, chi17_y_pos_int, chi17_y_vel_int, chi17_y_omega_int, chi17_z_pos_int, chi17_z_vel_int, chi17_z_omega_int : signed(47 downto 0) := (others => '0');
  signal chi18_x_pos_int, chi18_x_vel_int, chi18_x_omega_int, chi18_y_pos_int, chi18_y_vel_int, chi18_y_omega_int, chi18_z_pos_int, chi18_z_vel_int, chi18_z_omega_int : signed(47 downto 0) := (others => '0');
begin

  process(clk, rst)
  begin
    if rst = '1' then

      state <= IDLE;
      done <= '0';

      x_pos_mean_reg <= (others => '0');
      x_vel_mean_reg <= (others => '0');
      x_omega_mean_reg <= (others => '0');
      y_pos_mean_reg <= (others => '0');
      y_vel_mean_reg <= (others => '0');
      y_omega_mean_reg <= (others => '0');
      z_pos_mean_reg <= (others => '0');
      z_vel_mean_reg <= (others => '0');
      z_omega_mean_reg <= (others => '0');

      l11_reg <= (others => '0'); l21_reg <= (others => '0'); l31_reg <= (others => '0'); l41_reg <= (others => '0'); l51_reg <= (others => '0'); l61_reg <= (others => '0'); l71_reg <= (others => '0'); l81_reg <= (others => '0'); l91_reg <= (others => '0');
      l22_reg <= (others => '0'); l32_reg <= (others => '0'); l42_reg <= (others => '0'); l52_reg <= (others => '0'); l62_reg <= (others => '0'); l72_reg <= (others => '0'); l82_reg <= (others => '0'); l92_reg <= (others => '0');
      l33_reg <= (others => '0'); l43_reg <= (others => '0'); l53_reg <= (others => '0'); l63_reg <= (others => '0'); l73_reg <= (others => '0'); l83_reg <= (others => '0'); l93_reg <= (others => '0');
      l44_reg <= (others => '0'); l54_reg <= (others => '0'); l64_reg <= (others => '0'); l74_reg <= (others => '0'); l84_reg <= (others => '0'); l94_reg <= (others => '0');
      l55_reg <= (others => '0'); l65_reg <= (others => '0'); l75_reg <= (others => '0'); l85_reg <= (others => '0'); l95_reg <= (others => '0');
      l66_reg <= (others => '0'); l76_reg <= (others => '0'); l86_reg <= (others => '0'); l96_reg <= (others => '0');
      l77_reg <= (others => '0'); l87_reg <= (others => '0'); l97_reg <= (others => '0');
      l88_reg <= (others => '0'); l98_reg <= (others => '0');
      l99_reg <= (others => '0');

      chi0_x_pos_int <= (others => '0'); chi0_x_vel_int <= (others => '0'); chi0_x_omega_int <= (others => '0'); chi0_y_pos_int <= (others => '0'); chi0_y_vel_int <= (others => '0'); chi0_y_omega_int <= (others => '0'); chi0_z_pos_int <= (others => '0'); chi0_z_vel_int <= (others => '0'); chi0_z_omega_int <= (others => '0');
      chi1_x_pos_int <= (others => '0'); chi1_x_vel_int <= (others => '0'); chi1_x_omega_int <= (others => '0'); chi1_y_pos_int <= (others => '0'); chi1_y_vel_int <= (others => '0'); chi1_y_omega_int <= (others => '0'); chi1_z_pos_int <= (others => '0'); chi1_z_vel_int <= (others => '0'); chi1_z_omega_int <= (others => '0');
      chi2_x_pos_int <= (others => '0'); chi2_x_vel_int <= (others => '0'); chi2_x_omega_int <= (others => '0'); chi2_y_pos_int <= (others => '0'); chi2_y_vel_int <= (others => '0'); chi2_y_omega_int <= (others => '0'); chi2_z_pos_int <= (others => '0'); chi2_z_vel_int <= (others => '0'); chi2_z_omega_int <= (others => '0');
      chi3_x_pos_int <= (others => '0'); chi3_x_vel_int <= (others => '0'); chi3_x_omega_int <= (others => '0'); chi3_y_pos_int <= (others => '0'); chi3_y_vel_int <= (others => '0'); chi3_y_omega_int <= (others => '0'); chi3_z_pos_int <= (others => '0'); chi3_z_vel_int <= (others => '0'); chi3_z_omega_int <= (others => '0');
      chi4_x_pos_int <= (others => '0'); chi4_x_vel_int <= (others => '0'); chi4_x_omega_int <= (others => '0'); chi4_y_pos_int <= (others => '0'); chi4_y_vel_int <= (others => '0'); chi4_y_omega_int <= (others => '0'); chi4_z_pos_int <= (others => '0'); chi4_z_vel_int <= (others => '0'); chi4_z_omega_int <= (others => '0');
      chi5_x_pos_int <= (others => '0'); chi5_x_vel_int <= (others => '0'); chi5_x_omega_int <= (others => '0'); chi5_y_pos_int <= (others => '0'); chi5_y_vel_int <= (others => '0'); chi5_y_omega_int <= (others => '0'); chi5_z_pos_int <= (others => '0'); chi5_z_vel_int <= (others => '0'); chi5_z_omega_int <= (others => '0');
      chi6_x_pos_int <= (others => '0'); chi6_x_vel_int <= (others => '0'); chi6_x_omega_int <= (others => '0'); chi6_y_pos_int <= (others => '0'); chi6_y_vel_int <= (others => '0'); chi6_y_omega_int <= (others => '0'); chi6_z_pos_int <= (others => '0'); chi6_z_vel_int <= (others => '0'); chi6_z_omega_int <= (others => '0');
      chi7_x_pos_int <= (others => '0'); chi7_x_vel_int <= (others => '0'); chi7_x_omega_int <= (others => '0'); chi7_y_pos_int <= (others => '0'); chi7_y_vel_int <= (others => '0'); chi7_y_omega_int <= (others => '0'); chi7_z_pos_int <= (others => '0'); chi7_z_vel_int <= (others => '0'); chi7_z_omega_int <= (others => '0');
      chi8_x_pos_int <= (others => '0'); chi8_x_vel_int <= (others => '0'); chi8_x_omega_int <= (others => '0'); chi8_y_pos_int <= (others => '0'); chi8_y_vel_int <= (others => '0'); chi8_y_omega_int <= (others => '0'); chi8_z_pos_int <= (others => '0'); chi8_z_vel_int <= (others => '0'); chi8_z_omega_int <= (others => '0');
      chi9_x_pos_int <= (others => '0'); chi9_x_vel_int <= (others => '0'); chi9_x_omega_int <= (others => '0'); chi9_y_pos_int <= (others => '0'); chi9_y_vel_int <= (others => '0'); chi9_y_omega_int <= (others => '0'); chi9_z_pos_int <= (others => '0'); chi9_z_vel_int <= (others => '0'); chi9_z_omega_int <= (others => '0');
      chi10_x_pos_int <= (others => '0'); chi10_x_vel_int <= (others => '0'); chi10_x_omega_int <= (others => '0'); chi10_y_pos_int <= (others => '0'); chi10_y_vel_int <= (others => '0'); chi10_y_omega_int <= (others => '0'); chi10_z_pos_int <= (others => '0'); chi10_z_vel_int <= (others => '0'); chi10_z_omega_int <= (others => '0');
      chi11_x_pos_int <= (others => '0'); chi11_x_vel_int <= (others => '0'); chi11_x_omega_int <= (others => '0'); chi11_y_pos_int <= (others => '0'); chi11_y_vel_int <= (others => '0'); chi11_y_omega_int <= (others => '0'); chi11_z_pos_int <= (others => '0'); chi11_z_vel_int <= (others => '0'); chi11_z_omega_int <= (others => '0');
      chi12_x_pos_int <= (others => '0'); chi12_x_vel_int <= (others => '0'); chi12_x_omega_int <= (others => '0'); chi12_y_pos_int <= (others => '0'); chi12_y_vel_int <= (others => '0'); chi12_y_omega_int <= (others => '0'); chi12_z_pos_int <= (others => '0'); chi12_z_vel_int <= (others => '0'); chi12_z_omega_int <= (others => '0');
      chi13_x_pos_int <= (others => '0'); chi13_x_vel_int <= (others => '0'); chi13_x_omega_int <= (others => '0'); chi13_y_pos_int <= (others => '0'); chi13_y_vel_int <= (others => '0'); chi13_y_omega_int <= (others => '0'); chi13_z_pos_int <= (others => '0'); chi13_z_vel_int <= (others => '0'); chi13_z_omega_int <= (others => '0');
      chi14_x_pos_int <= (others => '0'); chi14_x_vel_int <= (others => '0'); chi14_x_omega_int <= (others => '0'); chi14_y_pos_int <= (others => '0'); chi14_y_vel_int <= (others => '0'); chi14_y_omega_int <= (others => '0'); chi14_z_pos_int <= (others => '0'); chi14_z_vel_int <= (others => '0'); chi14_z_omega_int <= (others => '0');
      chi15_x_pos_int <= (others => '0'); chi15_x_vel_int <= (others => '0'); chi15_x_omega_int <= (others => '0'); chi15_y_pos_int <= (others => '0'); chi15_y_vel_int <= (others => '0'); chi15_y_omega_int <= (others => '0'); chi15_z_pos_int <= (others => '0'); chi15_z_vel_int <= (others => '0'); chi15_z_omega_int <= (others => '0');
      chi16_x_pos_int <= (others => '0'); chi16_x_vel_int <= (others => '0'); chi16_x_omega_int <= (others => '0'); chi16_y_pos_int <= (others => '0'); chi16_y_vel_int <= (others => '0'); chi16_y_omega_int <= (others => '0'); chi16_z_pos_int <= (others => '0'); chi16_z_vel_int <= (others => '0'); chi16_z_omega_int <= (others => '0');
      chi17_x_pos_int <= (others => '0'); chi17_x_vel_int <= (others => '0'); chi17_x_omega_int <= (others => '0'); chi17_y_pos_int <= (others => '0'); chi17_y_vel_int <= (others => '0'); chi17_y_omega_int <= (others => '0'); chi17_z_pos_int <= (others => '0'); chi17_z_vel_int <= (others => '0'); chi17_z_omega_int <= (others => '0');
      chi18_x_pos_int <= (others => '0'); chi18_x_vel_int <= (others => '0'); chi18_x_omega_int <= (others => '0'); chi18_y_pos_int <= (others => '0'); chi18_y_vel_int <= (others => '0'); chi18_y_omega_int <= (others => '0'); chi18_z_pos_int <= (others => '0'); chi18_z_vel_int <= (others => '0'); chi18_z_omega_int <= (others => '0');

    elsif rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if cholesky_done = '1' then

            state <= LATCH_INPUTS;
          end if;

        when LATCH_INPUTS =>

          x_pos_mean_reg <= x_pos_mean;
          x_vel_mean_reg <= x_vel_mean;
          x_omega_mean_reg <= x_omega_mean;
          y_pos_mean_reg <= y_pos_mean;
          y_vel_mean_reg <= y_vel_mean;
          y_omega_mean_reg <= y_omega_mean;
          z_pos_mean_reg <= z_pos_mean;
          z_vel_mean_reg <= z_vel_mean;
          z_omega_mean_reg <= z_omega_mean;

          l11_reg <= l11; l21_reg <= l21; l31_reg <= l31; l41_reg <= l41; l51_reg <= l51; l61_reg <= l61; l71_reg <= l71; l81_reg <= l81; l91_reg <= l91;
          l22_reg <= l22; l32_reg <= l32; l42_reg <= l42; l52_reg <= l52; l62_reg <= l62; l72_reg <= l72; l82_reg <= l82; l92_reg <= l92;
          l33_reg <= l33; l43_reg <= l43; l53_reg <= l53; l63_reg <= l63; l73_reg <= l73; l83_reg <= l83; l93_reg <= l93;
          l44_reg <= l44; l54_reg <= l54; l64_reg <= l64; l74_reg <= l74; l84_reg <= l84; l94_reg <= l94;
          l55_reg <= l55; l65_reg <= l65; l75_reg <= l75; l85_reg <= l85; l95_reg <= l95;
          l66_reg <= l66; l76_reg <= l76; l86_reg <= l86; l96_reg <= l96;
          l77_reg <= l77; l87_reg <= l87; l97_reg <= l97;
          l88_reg <= l88; l98_reg <= l98;
          l99_reg <= l99;

          report "SIGMA_3D: LATCH_INPUTS" & LF &
                 "  x_pos_mean=" & integer'image(to_integer(x_pos_mean)) & LF &
                 "  x_omega_mean=" & integer'image(to_integer(x_omega_mean)) & LF &
                 "  y_pos_mean=" & integer'image(to_integer(y_pos_mean)) & LF &
                 "  y_omega_mean=" & integer'image(to_integer(y_omega_mean)) & LF &
                 "  z_pos_mean=" & integer'image(to_integer(z_pos_mean)) & LF &
                 "  z_omega_mean=" & integer'image(to_integer(z_omega_mean)) & LF &
                 "  l11=" & integer'image(to_integer(l11)) & LF &
                 "  l99=" & integer'image(to_integer(l99));

          state <= CALCULATE;

        when CALCULATE =>

          chi0_x_pos_int <= x_pos_mean_reg;
          chi0_x_vel_int <= x_vel_mean_reg;
          chi0_x_omega_int <= x_omega_mean_reg;
          chi0_y_pos_int <= y_pos_mean_reg;
          chi0_y_vel_int <= y_vel_mean_reg;
          chi0_y_omega_int <= y_omega_mean_reg;
          chi0_z_pos_int <= z_pos_mean_reg;
          chi0_z_vel_int <= z_vel_mean_reg;
          chi0_z_omega_int <= z_omega_mean_reg;

          chi1_x_pos_int <= x_pos_mean_reg + resize(shift_right(GAMMA * l11_reg, Q), 48);
          chi1_x_vel_int <= x_vel_mean_reg + resize(shift_right(GAMMA * l21_reg, Q), 48);
          chi1_x_omega_int <= x_omega_mean_reg + resize(shift_right(GAMMA * l31_reg, Q), 48);
          chi1_y_pos_int <= y_pos_mean_reg + resize(shift_right(GAMMA * l41_reg, Q), 48);
          chi1_y_vel_int <= y_vel_mean_reg + resize(shift_right(GAMMA * l51_reg, Q), 48);
          chi1_y_omega_int <= y_omega_mean_reg + resize(shift_right(GAMMA * l61_reg, Q), 48);
          chi1_z_pos_int <= z_pos_mean_reg + resize(shift_right(GAMMA * l71_reg, Q), 48);
          chi1_z_vel_int <= z_vel_mean_reg + resize(shift_right(GAMMA * l81_reg, Q), 48);
          chi1_z_omega_int <= z_omega_mean_reg + resize(shift_right(GAMMA * l91_reg, Q), 48);

          chi2_x_pos_int <= x_pos_mean_reg;
          chi2_x_vel_int <= x_vel_mean_reg + resize(shift_right(GAMMA * l22_reg, Q), 48);
          chi2_x_omega_int <= x_omega_mean_reg + resize(shift_right(GAMMA * l32_reg, Q), 48);
          chi2_y_pos_int <= y_pos_mean_reg + resize(shift_right(GAMMA * l42_reg, Q), 48);
          chi2_y_vel_int <= y_vel_mean_reg + resize(shift_right(GAMMA * l52_reg, Q), 48);
          chi2_y_omega_int <= y_omega_mean_reg + resize(shift_right(GAMMA * l62_reg, Q), 48);
          chi2_z_pos_int <= z_pos_mean_reg + resize(shift_right(GAMMA * l72_reg, Q), 48);
          chi2_z_vel_int <= z_vel_mean_reg + resize(shift_right(GAMMA * l82_reg, Q), 48);
          chi2_z_omega_int <= z_omega_mean_reg + resize(shift_right(GAMMA * l92_reg, Q), 48);

          chi3_x_pos_int <= x_pos_mean_reg;
          chi3_x_vel_int <= x_vel_mean_reg;
          chi3_x_omega_int <= x_omega_mean_reg + resize(shift_right(GAMMA * l33_reg, Q), 48);
          chi3_y_pos_int <= y_pos_mean_reg + resize(shift_right(GAMMA * l43_reg, Q), 48);
          chi3_y_vel_int <= y_vel_mean_reg + resize(shift_right(GAMMA * l53_reg, Q), 48);
          chi3_y_omega_int <= y_omega_mean_reg + resize(shift_right(GAMMA * l63_reg, Q), 48);
          chi3_z_pos_int <= z_pos_mean_reg + resize(shift_right(GAMMA * l73_reg, Q), 48);
          chi3_z_vel_int <= z_vel_mean_reg + resize(shift_right(GAMMA * l83_reg, Q), 48);
          chi3_z_omega_int <= z_omega_mean_reg + resize(shift_right(GAMMA * l93_reg, Q), 48);

          chi4_x_pos_int <= x_pos_mean_reg;
          chi4_x_vel_int <= x_vel_mean_reg;
          chi4_x_omega_int <= x_omega_mean_reg;
          chi4_y_pos_int <= y_pos_mean_reg + resize(shift_right(GAMMA * l44_reg, Q), 48);
          chi4_y_vel_int <= y_vel_mean_reg + resize(shift_right(GAMMA * l54_reg, Q), 48);
          chi4_y_omega_int <= y_omega_mean_reg + resize(shift_right(GAMMA * l64_reg, Q), 48);
          chi4_z_pos_int <= z_pos_mean_reg + resize(shift_right(GAMMA * l74_reg, Q), 48);
          chi4_z_vel_int <= z_vel_mean_reg + resize(shift_right(GAMMA * l84_reg, Q), 48);
          chi4_z_omega_int <= z_omega_mean_reg + resize(shift_right(GAMMA * l94_reg, Q), 48);

          chi5_x_pos_int <= x_pos_mean_reg;
          chi5_x_vel_int <= x_vel_mean_reg;
          chi5_x_omega_int <= x_omega_mean_reg;
          chi5_y_pos_int <= y_pos_mean_reg;
          chi5_y_vel_int <= y_vel_mean_reg + resize(shift_right(GAMMA * l55_reg, Q), 48);
          chi5_y_omega_int <= y_omega_mean_reg + resize(shift_right(GAMMA * l65_reg, Q), 48);
          chi5_z_pos_int <= z_pos_mean_reg + resize(shift_right(GAMMA * l75_reg, Q), 48);
          chi5_z_vel_int <= z_vel_mean_reg + resize(shift_right(GAMMA * l85_reg, Q), 48);
          chi5_z_omega_int <= z_omega_mean_reg + resize(shift_right(GAMMA * l95_reg, Q), 48);

          chi6_x_pos_int <= x_pos_mean_reg;
          chi6_x_vel_int <= x_vel_mean_reg;
          chi6_x_omega_int <= x_omega_mean_reg;
          chi6_y_pos_int <= y_pos_mean_reg;
          chi6_y_vel_int <= y_vel_mean_reg;
          chi6_y_omega_int <= y_omega_mean_reg + resize(shift_right(GAMMA * l66_reg, Q), 48);
          chi6_z_pos_int <= z_pos_mean_reg + resize(shift_right(GAMMA * l76_reg, Q), 48);
          chi6_z_vel_int <= z_vel_mean_reg + resize(shift_right(GAMMA * l86_reg, Q), 48);
          chi6_z_omega_int <= z_omega_mean_reg + resize(shift_right(GAMMA * l96_reg, Q), 48);

          chi7_x_pos_int <= x_pos_mean_reg;
          chi7_x_vel_int <= x_vel_mean_reg;
          chi7_x_omega_int <= x_omega_mean_reg;
          chi7_y_pos_int <= y_pos_mean_reg;
          chi7_y_vel_int <= y_vel_mean_reg;
          chi7_y_omega_int <= y_omega_mean_reg;
          chi7_z_pos_int <= z_pos_mean_reg + resize(shift_right(GAMMA * l77_reg, Q), 48);
          chi7_z_vel_int <= z_vel_mean_reg + resize(shift_right(GAMMA * l87_reg, Q), 48);
          chi7_z_omega_int <= z_omega_mean_reg + resize(shift_right(GAMMA * l97_reg, Q), 48);

          chi8_x_pos_int <= x_pos_mean_reg;
          chi8_x_vel_int <= x_vel_mean_reg;
          chi8_x_omega_int <= x_omega_mean_reg;
          chi8_y_pos_int <= y_pos_mean_reg;
          chi8_y_vel_int <= y_vel_mean_reg;
          chi8_y_omega_int <= y_omega_mean_reg;
          chi8_z_pos_int <= z_pos_mean_reg;
          chi8_z_vel_int <= z_vel_mean_reg + resize(shift_right(GAMMA * l88_reg, Q), 48);
          chi8_z_omega_int <= z_omega_mean_reg + resize(shift_right(GAMMA * l98_reg, Q), 48);

          chi9_x_pos_int <= x_pos_mean_reg;
          chi9_x_vel_int <= x_vel_mean_reg;
          chi9_x_omega_int <= x_omega_mean_reg;
          chi9_y_pos_int <= y_pos_mean_reg;
          chi9_y_vel_int <= y_vel_mean_reg;
          chi9_y_omega_int <= y_omega_mean_reg;
          chi9_z_pos_int <= z_pos_mean_reg;
          chi9_z_vel_int <= z_vel_mean_reg;
          chi9_z_omega_int <= z_omega_mean_reg + resize(shift_right(GAMMA * l99_reg, Q), 48);

          chi10_x_pos_int <= x_pos_mean_reg - resize(shift_right(GAMMA * l11_reg, Q), 48);
          chi10_x_vel_int <= x_vel_mean_reg - resize(shift_right(GAMMA * l21_reg, Q), 48);
          chi10_x_omega_int <= x_omega_mean_reg - resize(shift_right(GAMMA * l31_reg, Q), 48);
          chi10_y_pos_int <= y_pos_mean_reg - resize(shift_right(GAMMA * l41_reg, Q), 48);
          chi10_y_vel_int <= y_vel_mean_reg - resize(shift_right(GAMMA * l51_reg, Q), 48);
          chi10_y_omega_int <= y_omega_mean_reg - resize(shift_right(GAMMA * l61_reg, Q), 48);
          chi10_z_pos_int <= z_pos_mean_reg - resize(shift_right(GAMMA * l71_reg, Q), 48);
          chi10_z_vel_int <= z_vel_mean_reg - resize(shift_right(GAMMA * l81_reg, Q), 48);
          chi10_z_omega_int <= z_omega_mean_reg - resize(shift_right(GAMMA * l91_reg, Q), 48);

          chi11_x_pos_int <= x_pos_mean_reg;
          chi11_x_vel_int <= x_vel_mean_reg - resize(shift_right(GAMMA * l22_reg, Q), 48);
          chi11_x_omega_int <= x_omega_mean_reg - resize(shift_right(GAMMA * l32_reg, Q), 48);
          chi11_y_pos_int <= y_pos_mean_reg - resize(shift_right(GAMMA * l42_reg, Q), 48);
          chi11_y_vel_int <= y_vel_mean_reg - resize(shift_right(GAMMA * l52_reg, Q), 48);
          chi11_y_omega_int <= y_omega_mean_reg - resize(shift_right(GAMMA * l62_reg, Q), 48);
          chi11_z_pos_int <= z_pos_mean_reg - resize(shift_right(GAMMA * l72_reg, Q), 48);
          chi11_z_vel_int <= z_vel_mean_reg - resize(shift_right(GAMMA * l82_reg, Q), 48);
          chi11_z_omega_int <= z_omega_mean_reg - resize(shift_right(GAMMA * l92_reg, Q), 48);

          chi12_x_pos_int <= x_pos_mean_reg;
          chi12_x_vel_int <= x_vel_mean_reg;
          chi12_x_omega_int <= x_omega_mean_reg - resize(shift_right(GAMMA * l33_reg, Q), 48);
          chi12_y_pos_int <= y_pos_mean_reg - resize(shift_right(GAMMA * l43_reg, Q), 48);
          chi12_y_vel_int <= y_vel_mean_reg - resize(shift_right(GAMMA * l53_reg, Q), 48);
          chi12_y_omega_int <= y_omega_mean_reg - resize(shift_right(GAMMA * l63_reg, Q), 48);
          chi12_z_pos_int <= z_pos_mean_reg - resize(shift_right(GAMMA * l73_reg, Q), 48);
          chi12_z_vel_int <= z_vel_mean_reg - resize(shift_right(GAMMA * l83_reg, Q), 48);
          chi12_z_omega_int <= z_omega_mean_reg - resize(shift_right(GAMMA * l93_reg, Q), 48);

          chi13_x_pos_int <= x_pos_mean_reg;
          chi13_x_vel_int <= x_vel_mean_reg;
          chi13_x_omega_int <= x_omega_mean_reg;
          chi13_y_pos_int <= y_pos_mean_reg - resize(shift_right(GAMMA * l44_reg, Q), 48);
          chi13_y_vel_int <= y_vel_mean_reg - resize(shift_right(GAMMA * l54_reg, Q), 48);
          chi13_y_omega_int <= y_omega_mean_reg - resize(shift_right(GAMMA * l64_reg, Q), 48);
          chi13_z_pos_int <= z_pos_mean_reg - resize(shift_right(GAMMA * l74_reg, Q), 48);
          chi13_z_vel_int <= z_vel_mean_reg - resize(shift_right(GAMMA * l84_reg, Q), 48);
          chi13_z_omega_int <= z_omega_mean_reg - resize(shift_right(GAMMA * l94_reg, Q), 48);

          chi14_x_pos_int <= x_pos_mean_reg;
          chi14_x_vel_int <= x_vel_mean_reg;
          chi14_x_omega_int <= x_omega_mean_reg;
          chi14_y_pos_int <= y_pos_mean_reg;
          chi14_y_vel_int <= y_vel_mean_reg - resize(shift_right(GAMMA * l55_reg, Q), 48);
          chi14_y_omega_int <= y_omega_mean_reg - resize(shift_right(GAMMA * l65_reg, Q), 48);
          chi14_z_pos_int <= z_pos_mean_reg - resize(shift_right(GAMMA * l75_reg, Q), 48);
          chi14_z_vel_int <= z_vel_mean_reg - resize(shift_right(GAMMA * l85_reg, Q), 48);
          chi14_z_omega_int <= z_omega_mean_reg - resize(shift_right(GAMMA * l95_reg, Q), 48);

          chi15_x_pos_int <= x_pos_mean_reg;
          chi15_x_vel_int <= x_vel_mean_reg;
          chi15_x_omega_int <= x_omega_mean_reg;
          chi15_y_pos_int <= y_pos_mean_reg;
          chi15_y_vel_int <= y_vel_mean_reg;
          chi15_y_omega_int <= y_omega_mean_reg - resize(shift_right(GAMMA * l66_reg, Q), 48);
          chi15_z_pos_int <= z_pos_mean_reg - resize(shift_right(GAMMA * l76_reg, Q), 48);
          chi15_z_vel_int <= z_vel_mean_reg - resize(shift_right(GAMMA * l86_reg, Q), 48);
          chi15_z_omega_int <= z_omega_mean_reg - resize(shift_right(GAMMA * l96_reg, Q), 48);

          chi16_x_pos_int <= x_pos_mean_reg;
          chi16_x_vel_int <= x_vel_mean_reg;
          chi16_x_omega_int <= x_omega_mean_reg;
          chi16_y_pos_int <= y_pos_mean_reg;
          chi16_y_vel_int <= y_vel_mean_reg;
          chi16_y_omega_int <= y_omega_mean_reg;
          chi16_z_pos_int <= z_pos_mean_reg - resize(shift_right(GAMMA * l77_reg, Q), 48);
          chi16_z_vel_int <= z_vel_mean_reg - resize(shift_right(GAMMA * l87_reg, Q), 48);
          chi16_z_omega_int <= z_omega_mean_reg - resize(shift_right(GAMMA * l97_reg, Q), 48);

          chi17_x_pos_int <= x_pos_mean_reg;
          chi17_x_vel_int <= x_vel_mean_reg;
          chi17_x_omega_int <= x_omega_mean_reg;
          chi17_y_pos_int <= y_pos_mean_reg;
          chi17_y_vel_int <= y_vel_mean_reg;
          chi17_y_omega_int <= y_omega_mean_reg;
          chi17_z_pos_int <= z_pos_mean_reg;
          chi17_z_vel_int <= z_vel_mean_reg - resize(shift_right(GAMMA * l88_reg, Q), 48);
          chi17_z_omega_int <= z_omega_mean_reg - resize(shift_right(GAMMA * l98_reg, Q), 48);

          chi18_x_pos_int <= x_pos_mean_reg;
          chi18_x_vel_int <= x_vel_mean_reg;
          chi18_x_omega_int <= x_omega_mean_reg;
          chi18_y_pos_int <= y_pos_mean_reg;
          chi18_y_vel_int <= y_vel_mean_reg;
          chi18_y_omega_int <= y_omega_mean_reg;
          chi18_z_pos_int <= z_pos_mean_reg;
          chi18_z_vel_int <= z_vel_mean_reg;
          chi18_z_omega_int <= z_omega_mean_reg - resize(shift_right(GAMMA * l99_reg, Q), 48);

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

  chi0_x_pos <= chi0_x_pos_int; chi0_x_vel <= chi0_x_vel_int; chi0_x_omega <= chi0_x_omega_int; chi0_y_pos <= chi0_y_pos_int; chi0_y_vel <= chi0_y_vel_int; chi0_y_omega <= chi0_y_omega_int; chi0_z_pos <= chi0_z_pos_int; chi0_z_vel <= chi0_z_vel_int; chi0_z_omega <= chi0_z_omega_int;
  chi1_x_pos <= chi1_x_pos_int; chi1_x_vel <= chi1_x_vel_int; chi1_x_omega <= chi1_x_omega_int; chi1_y_pos <= chi1_y_pos_int; chi1_y_vel <= chi1_y_vel_int; chi1_y_omega <= chi1_y_omega_int; chi1_z_pos <= chi1_z_pos_int; chi1_z_vel <= chi1_z_vel_int; chi1_z_omega <= chi1_z_omega_int;
  chi2_x_pos <= chi2_x_pos_int; chi2_x_vel <= chi2_x_vel_int; chi2_x_omega <= chi2_x_omega_int; chi2_y_pos <= chi2_y_pos_int; chi2_y_vel <= chi2_y_vel_int; chi2_y_omega <= chi2_y_omega_int; chi2_z_pos <= chi2_z_pos_int; chi2_z_vel <= chi2_z_vel_int; chi2_z_omega <= chi2_z_omega_int;
  chi3_x_pos <= chi3_x_pos_int; chi3_x_vel <= chi3_x_vel_int; chi3_x_omega <= chi3_x_omega_int; chi3_y_pos <= chi3_y_pos_int; chi3_y_vel <= chi3_y_vel_int; chi3_y_omega <= chi3_y_omega_int; chi3_z_pos <= chi3_z_pos_int; chi3_z_vel <= chi3_z_vel_int; chi3_z_omega <= chi3_z_omega_int;
  chi4_x_pos <= chi4_x_pos_int; chi4_x_vel <= chi4_x_vel_int; chi4_x_omega <= chi4_x_omega_int; chi4_y_pos <= chi4_y_pos_int; chi4_y_vel <= chi4_y_vel_int; chi4_y_omega <= chi4_y_omega_int; chi4_z_pos <= chi4_z_pos_int; chi4_z_vel <= chi4_z_vel_int; chi4_z_omega <= chi4_z_omega_int;
  chi5_x_pos <= chi5_x_pos_int; chi5_x_vel <= chi5_x_vel_int; chi5_x_omega <= chi5_x_omega_int; chi5_y_pos <= chi5_y_pos_int; chi5_y_vel <= chi5_y_vel_int; chi5_y_omega <= chi5_y_omega_int; chi5_z_pos <= chi5_z_pos_int; chi5_z_vel <= chi5_z_vel_int; chi5_z_omega <= chi5_z_omega_int;
  chi6_x_pos <= chi6_x_pos_int; chi6_x_vel <= chi6_x_vel_int; chi6_x_omega <= chi6_x_omega_int; chi6_y_pos <= chi6_y_pos_int; chi6_y_vel <= chi6_y_vel_int; chi6_y_omega <= chi6_y_omega_int; chi6_z_pos <= chi6_z_pos_int; chi6_z_vel <= chi6_z_vel_int; chi6_z_omega <= chi6_z_omega_int;
  chi7_x_pos <= chi7_x_pos_int; chi7_x_vel <= chi7_x_vel_int; chi7_x_omega <= chi7_x_omega_int; chi7_y_pos <= chi7_y_pos_int; chi7_y_vel <= chi7_y_vel_int; chi7_y_omega <= chi7_y_omega_int; chi7_z_pos <= chi7_z_pos_int; chi7_z_vel <= chi7_z_vel_int; chi7_z_omega <= chi7_z_omega_int;
  chi8_x_pos <= chi8_x_pos_int; chi8_x_vel <= chi8_x_vel_int; chi8_x_omega <= chi8_x_omega_int; chi8_y_pos <= chi8_y_pos_int; chi8_y_vel <= chi8_y_vel_int; chi8_y_omega <= chi8_y_omega_int; chi8_z_pos <= chi8_z_pos_int; chi8_z_vel <= chi8_z_vel_int; chi8_z_omega <= chi8_z_omega_int;
  chi9_x_pos <= chi9_x_pos_int; chi9_x_vel <= chi9_x_vel_int; chi9_x_omega <= chi9_x_omega_int; chi9_y_pos <= chi9_y_pos_int; chi9_y_vel <= chi9_y_vel_int; chi9_y_omega <= chi9_y_omega_int; chi9_z_pos <= chi9_z_pos_int; chi9_z_vel <= chi9_z_vel_int; chi9_z_omega <= chi9_z_omega_int;
  chi10_x_pos <= chi10_x_pos_int; chi10_x_vel <= chi10_x_vel_int; chi10_x_omega <= chi10_x_omega_int; chi10_y_pos <= chi10_y_pos_int; chi10_y_vel <= chi10_y_vel_int; chi10_y_omega <= chi10_y_omega_int; chi10_z_pos <= chi10_z_pos_int; chi10_z_vel <= chi10_z_vel_int; chi10_z_omega <= chi10_z_omega_int;
  chi11_x_pos <= chi11_x_pos_int; chi11_x_vel <= chi11_x_vel_int; chi11_x_omega <= chi11_x_omega_int; chi11_y_pos <= chi11_y_pos_int; chi11_y_vel <= chi11_y_vel_int; chi11_y_omega <= chi11_y_omega_int; chi11_z_pos <= chi11_z_pos_int; chi11_z_vel <= chi11_z_vel_int; chi11_z_omega <= chi11_z_omega_int;
  chi12_x_pos <= chi12_x_pos_int; chi12_x_vel <= chi12_x_vel_int; chi12_x_omega <= chi12_x_omega_int; chi12_y_pos <= chi12_y_pos_int; chi12_y_vel <= chi12_y_vel_int; chi12_y_omega <= chi12_y_omega_int; chi12_z_pos <= chi12_z_pos_int; chi12_z_vel <= chi12_z_vel_int; chi12_z_omega <= chi12_z_omega_int;
  chi13_x_pos <= chi13_x_pos_int; chi13_x_vel <= chi13_x_vel_int; chi13_x_omega <= chi13_x_omega_int; chi13_y_pos <= chi13_y_pos_int; chi13_y_vel <= chi13_y_vel_int; chi13_y_omega <= chi13_y_omega_int; chi13_z_pos <= chi13_z_pos_int; chi13_z_vel <= chi13_z_vel_int; chi13_z_omega <= chi13_z_omega_int;
  chi14_x_pos <= chi14_x_pos_int; chi14_x_vel <= chi14_x_vel_int; chi14_x_omega <= chi14_x_omega_int; chi14_y_pos <= chi14_y_pos_int; chi14_y_vel <= chi14_y_vel_int; chi14_y_omega <= chi14_y_omega_int; chi14_z_pos <= chi14_z_pos_int; chi14_z_vel <= chi14_z_vel_int; chi14_z_omega <= chi14_z_omega_int;
  chi15_x_pos <= chi15_x_pos_int; chi15_x_vel <= chi15_x_vel_int; chi15_x_omega <= chi15_x_omega_int; chi15_y_pos <= chi15_y_pos_int; chi15_y_vel <= chi15_y_vel_int; chi15_y_omega <= chi15_y_omega_int; chi15_z_pos <= chi15_z_pos_int; chi15_z_vel <= chi15_z_vel_int; chi15_z_omega <= chi15_z_omega_int;
  chi16_x_pos <= chi16_x_pos_int; chi16_x_vel <= chi16_x_vel_int; chi16_x_omega <= chi16_x_omega_int; chi16_y_pos <= chi16_y_pos_int; chi16_y_vel <= chi16_y_vel_int; chi16_y_omega <= chi16_y_omega_int; chi16_z_pos <= chi16_z_pos_int; chi16_z_vel <= chi16_z_vel_int; chi16_z_omega <= chi16_z_omega_int;
  chi17_x_pos <= chi17_x_pos_int; chi17_x_vel <= chi17_x_vel_int; chi17_x_omega <= chi17_x_omega_int; chi17_y_pos <= chi17_y_pos_int; chi17_y_vel <= chi17_y_vel_int; chi17_y_omega <= chi17_y_omega_int; chi17_z_pos <= chi17_z_pos_int; chi17_z_vel <= chi17_z_vel_int; chi17_z_omega <= chi17_z_omega_int;
  chi18_x_pos <= chi18_x_pos_int; chi18_x_vel <= chi18_x_vel_int; chi18_x_omega <= chi18_x_omega_int; chi18_y_pos <= chi18_y_pos_int; chi18_y_vel <= chi18_y_vel_int; chi18_y_omega <= chi18_y_omega_int; chi18_z_pos <= chi18_z_pos_int; chi18_z_vel <= chi18_z_vel_int; chi18_z_omega <= chi18_z_omega_int;

end Behavioral;
