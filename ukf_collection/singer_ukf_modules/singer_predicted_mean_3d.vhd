library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity predicted_mean_3d is
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    start       : in  std_logic;
    cycle_num   : in  integer range 0 to 1000;

    chi0_x_pos_pred, chi0_x_vel_pred, chi0_x_acc_pred : in signed(47 downto 0);
    chi0_y_pos_pred, chi0_y_vel_pred, chi0_y_acc_pred : in signed(47 downto 0);
    chi0_z_pos_pred, chi0_z_vel_pred, chi0_z_acc_pred : in signed(47 downto 0);

    chi1_x_pos_pred, chi1_x_vel_pred, chi1_x_acc_pred, chi1_y_pos_pred, chi1_y_vel_pred, chi1_y_acc_pred, chi1_z_pos_pred, chi1_z_vel_pred, chi1_z_acc_pred : in signed(47 downto 0);
    chi2_x_pos_pred, chi2_x_vel_pred, chi2_x_acc_pred, chi2_y_pos_pred, chi2_y_vel_pred, chi2_y_acc_pred, chi2_z_pos_pred, chi2_z_vel_pred, chi2_z_acc_pred : in signed(47 downto 0);
    chi3_x_pos_pred, chi3_x_vel_pred, chi3_x_acc_pred, chi3_y_pos_pred, chi3_y_vel_pred, chi3_y_acc_pred, chi3_z_pos_pred, chi3_z_vel_pred, chi3_z_acc_pred : in signed(47 downto 0);
    chi4_x_pos_pred, chi4_x_vel_pred, chi4_x_acc_pred, chi4_y_pos_pred, chi4_y_vel_pred, chi4_y_acc_pred, chi4_z_pos_pred, chi4_z_vel_pred, chi4_z_acc_pred : in signed(47 downto 0);
    chi5_x_pos_pred, chi5_x_vel_pred, chi5_x_acc_pred, chi5_y_pos_pred, chi5_y_vel_pred, chi5_y_acc_pred, chi5_z_pos_pred, chi5_z_vel_pred, chi5_z_acc_pred : in signed(47 downto 0);
    chi6_x_pos_pred, chi6_x_vel_pred, chi6_x_acc_pred, chi6_y_pos_pred, chi6_y_vel_pred, chi6_y_acc_pred, chi6_z_pos_pred, chi6_z_vel_pred, chi6_z_acc_pred : in signed(47 downto 0);
    chi7_x_pos_pred, chi7_x_vel_pred, chi7_x_acc_pred, chi7_y_pos_pred, chi7_y_vel_pred, chi7_y_acc_pred, chi7_z_pos_pred, chi7_z_vel_pred, chi7_z_acc_pred : in signed(47 downto 0);
    chi8_x_pos_pred, chi8_x_vel_pred, chi8_x_acc_pred, chi8_y_pos_pred, chi8_y_vel_pred, chi8_y_acc_pred, chi8_z_pos_pred, chi8_z_vel_pred, chi8_z_acc_pred : in signed(47 downto 0);
    chi9_x_pos_pred, chi9_x_vel_pred, chi9_x_acc_pred, chi9_y_pos_pred, chi9_y_vel_pred, chi9_y_acc_pred, chi9_z_pos_pred, chi9_z_vel_pred, chi9_z_acc_pred : in signed(47 downto 0);
    chi10_x_pos_pred, chi10_x_vel_pred, chi10_x_acc_pred, chi10_y_pos_pred, chi10_y_vel_pred, chi10_y_acc_pred, chi10_z_pos_pred, chi10_z_vel_pred, chi10_z_acc_pred : in signed(47 downto 0);
    chi11_x_pos_pred, chi11_x_vel_pred, chi11_x_acc_pred, chi11_y_pos_pred, chi11_y_vel_pred, chi11_y_acc_pred, chi11_z_pos_pred, chi11_z_vel_pred, chi11_z_acc_pred : in signed(47 downto 0);
    chi12_x_pos_pred, chi12_x_vel_pred, chi12_x_acc_pred, chi12_y_pos_pred, chi12_y_vel_pred, chi12_y_acc_pred, chi12_z_pos_pred, chi12_z_vel_pred, chi12_z_acc_pred : in signed(47 downto 0);
    chi13_x_pos_pred, chi13_x_vel_pred, chi13_x_acc_pred, chi13_y_pos_pred, chi13_y_vel_pred, chi13_y_acc_pred, chi13_z_pos_pred, chi13_z_vel_pred, chi13_z_acc_pred : in signed(47 downto 0);
    chi14_x_pos_pred, chi14_x_vel_pred, chi14_x_acc_pred, chi14_y_pos_pred, chi14_y_vel_pred, chi14_y_acc_pred, chi14_z_pos_pred, chi14_z_vel_pred, chi14_z_acc_pred : in signed(47 downto 0);
    chi15_x_pos_pred, chi15_x_vel_pred, chi15_x_acc_pred, chi15_y_pos_pred, chi15_y_vel_pred, chi15_y_acc_pred, chi15_z_pos_pred, chi15_z_vel_pred, chi15_z_acc_pred : in signed(47 downto 0);
    chi16_x_pos_pred, chi16_x_vel_pred, chi16_x_acc_pred, chi16_y_pos_pred, chi16_y_vel_pred, chi16_y_acc_pred, chi16_z_pos_pred, chi16_z_vel_pred, chi16_z_acc_pred : in signed(47 downto 0);
    chi17_x_pos_pred, chi17_x_vel_pred, chi17_x_acc_pred, chi17_y_pos_pred, chi17_y_vel_pred, chi17_y_acc_pred, chi17_z_pos_pred, chi17_z_vel_pred, chi17_z_acc_pred : in signed(47 downto 0);
    chi18_x_pos_pred, chi18_x_vel_pred, chi18_x_acc_pred, chi18_y_pos_pred, chi18_y_vel_pred, chi18_y_acc_pred, chi18_z_pos_pred, chi18_z_vel_pred, chi18_z_acc_pred : in signed(47 downto 0);

    x_pos_mean_pred : buffer signed(47 downto 0);
    x_vel_mean_pred : buffer signed(47 downto 0);
    x_acc_mean_pred : buffer signed(47 downto 0);
    y_pos_mean_pred : buffer signed(47 downto 0);
    y_vel_mean_pred : buffer signed(47 downto 0);
    y_acc_mean_pred : buffer signed(47 downto 0);
    z_pos_mean_pred : buffer signed(47 downto 0);
    z_vel_mean_pred : buffer signed(47 downto 0);
    z_acc_mean_pred : buffer signed(47 downto 0);

    done        : out std_logic
  );
end entity;

architecture Behavioral of predicted_mean_3d is

  constant W0 : signed(47 downto 0) := to_signed(0, 48);
  constant W1 : signed(47 downto 0) := to_signed(932067, 48);
  constant Q : integer := 24;

  type state_type is (IDLE, MULTIPLY, ACCUMULATE, OUTPUT, FINISHED);
  signal state : state_type := IDLE;

  signal w_chi0_xp, w_chi1_xp, w_chi2_xp, w_chi3_xp, w_chi4_xp, w_chi5_xp, w_chi6_xp, w_chi7_xp, w_chi8_xp, w_chi9_xp : signed(95 downto 0) := (others => '0');
  signal w_chi10_xp, w_chi11_xp, w_chi12_xp, w_chi13_xp, w_chi14_xp, w_chi15_xp, w_chi16_xp, w_chi17_xp, w_chi18_xp : signed(95 downto 0) := (others => '0');

  signal w_chi0_xv, w_chi1_xv, w_chi2_xv, w_chi3_xv, w_chi4_xv, w_chi5_xv, w_chi6_xv, w_chi7_xv, w_chi8_xv, w_chi9_xv : signed(95 downto 0) := (others => '0');
  signal w_chi10_xv, w_chi11_xv, w_chi12_xv, w_chi13_xv, w_chi14_xv, w_chi15_xv, w_chi16_xv, w_chi17_xv, w_chi18_xv : signed(95 downto 0) := (others => '0');

  signal w_chi0_xa, w_chi1_xa, w_chi2_xa, w_chi3_xa, w_chi4_xa, w_chi5_xa, w_chi6_xa, w_chi7_xa, w_chi8_xa, w_chi9_xa : signed(95 downto 0) := (others => '0');
  signal w_chi10_xa, w_chi11_xa, w_chi12_xa, w_chi13_xa, w_chi14_xa, w_chi15_xa, w_chi16_xa, w_chi17_xa, w_chi18_xa : signed(95 downto 0) := (others => '0');

  signal w_chi0_yp, w_chi1_yp, w_chi2_yp, w_chi3_yp, w_chi4_yp, w_chi5_yp, w_chi6_yp, w_chi7_yp, w_chi8_yp, w_chi9_yp : signed(95 downto 0) := (others => '0');
  signal w_chi10_yp, w_chi11_yp, w_chi12_yp, w_chi13_yp, w_chi14_yp, w_chi15_yp, w_chi16_yp, w_chi17_yp, w_chi18_yp : signed(95 downto 0) := (others => '0');

  signal w_chi0_yv, w_chi1_yv, w_chi2_yv, w_chi3_yv, w_chi4_yv, w_chi5_yv, w_chi6_yv, w_chi7_yv, w_chi8_yv, w_chi9_yv : signed(95 downto 0) := (others => '0');
  signal w_chi10_yv, w_chi11_yv, w_chi12_yv, w_chi13_yv, w_chi14_yv, w_chi15_yv, w_chi16_yv, w_chi17_yv, w_chi18_yv : signed(95 downto 0) := (others => '0');

  signal w_chi0_ya, w_chi1_ya, w_chi2_ya, w_chi3_ya, w_chi4_ya, w_chi5_ya, w_chi6_ya, w_chi7_ya, w_chi8_ya, w_chi9_ya : signed(95 downto 0) := (others => '0');
  signal w_chi10_ya, w_chi11_ya, w_chi12_ya, w_chi13_ya, w_chi14_ya, w_chi15_ya, w_chi16_ya, w_chi17_ya, w_chi18_ya : signed(95 downto 0) := (others => '0');

  signal w_chi0_zp, w_chi1_zp, w_chi2_zp, w_chi3_zp, w_chi4_zp, w_chi5_zp, w_chi6_zp, w_chi7_zp, w_chi8_zp, w_chi9_zp : signed(95 downto 0) := (others => '0');
  signal w_chi10_zp, w_chi11_zp, w_chi12_zp, w_chi13_zp, w_chi14_zp, w_chi15_zp, w_chi16_zp, w_chi17_zp, w_chi18_zp : signed(95 downto 0) := (others => '0');

  signal w_chi0_zv, w_chi1_zv, w_chi2_zv, w_chi3_zv, w_chi4_zv, w_chi5_zv, w_chi6_zv, w_chi7_zv, w_chi8_zv, w_chi9_zv : signed(95 downto 0) := (others => '0');
  signal w_chi10_zv, w_chi11_zv, w_chi12_zv, w_chi13_zv, w_chi14_zv, w_chi15_zv, w_chi16_zv, w_chi17_zv, w_chi18_zv : signed(95 downto 0) := (others => '0');

  signal w_chi0_za, w_chi1_za, w_chi2_za, w_chi3_za, w_chi4_za, w_chi5_za, w_chi6_za, w_chi7_za, w_chi8_za, w_chi9_za : signed(95 downto 0) := (others => '0');
  signal w_chi10_za, w_chi11_za, w_chi12_za, w_chi13_za, w_chi14_za, w_chi15_za, w_chi16_za, w_chi17_za, w_chi18_za : signed(95 downto 0) := (others => '0');

  signal sum_xp, sum_xv, sum_xa, sum_yp, sum_yv, sum_ya, sum_zp, sum_zv, sum_za : signed(43 downto 0) := (others => '0');

  signal x_pos_mean_int, x_vel_mean_int, x_acc_mean_int : signed(47 downto 0) := (others => '0');
  signal y_pos_mean_int, y_vel_mean_int, y_acc_mean_int : signed(47 downto 0) := (others => '0');
  signal z_pos_mean_int, z_vel_mean_int, z_acc_mean_int : signed(47 downto 0) := (others => '0');

begin
  process(clk, rst)
    variable temp_xp, temp_xv, temp_xa, temp_yp, temp_yv, temp_ya, temp_zp, temp_zv, temp_za : signed(43 downto 0);
  begin
    if rst = '1' then
      state <= IDLE;
      done <= '0';
      sum_xp <= (others => '0'); sum_xv <= (others => '0'); sum_xa <= (others => '0');
      sum_yp <= (others => '0'); sum_yv <= (others => '0'); sum_ya <= (others => '0');
      sum_zp <= (others => '0'); sum_zv <= (others => '0'); sum_za <= (others => '0');
      x_pos_mean_int <= (others => '0'); x_vel_mean_int <= (others => '0'); x_acc_mean_int <= (others => '0');
      y_pos_mean_int <= (others => '0'); y_vel_mean_int <= (others => '0'); y_acc_mean_int <= (others => '0');
      z_pos_mean_int <= (others => '0'); z_vel_mean_int <= (others => '0'); z_acc_mean_int <= (others => '0');

      w_chi0_xp <= (others => '0'); w_chi1_xp <= (others => '0'); w_chi2_xp <= (others => '0'); w_chi3_xp <= (others => '0'); w_chi4_xp <= (others => '0'); w_chi5_xp <= (others => '0'); w_chi6_xp <= (others => '0'); w_chi7_xp <= (others => '0'); w_chi8_xp <= (others => '0'); w_chi9_xp <= (others => '0');
      w_chi10_xp <= (others => '0'); w_chi11_xp <= (others => '0'); w_chi12_xp <= (others => '0'); w_chi13_xp <= (others => '0'); w_chi14_xp <= (others => '0'); w_chi15_xp <= (others => '0'); w_chi16_xp <= (others => '0'); w_chi17_xp <= (others => '0'); w_chi18_xp <= (others => '0');

      w_chi0_xv <= (others => '0'); w_chi1_xv <= (others => '0'); w_chi2_xv <= (others => '0'); w_chi3_xv <= (others => '0'); w_chi4_xv <= (others => '0'); w_chi5_xv <= (others => '0'); w_chi6_xv <= (others => '0'); w_chi7_xv <= (others => '0'); w_chi8_xv <= (others => '0'); w_chi9_xv <= (others => '0');
      w_chi10_xv <= (others => '0'); w_chi11_xv <= (others => '0'); w_chi12_xv <= (others => '0'); w_chi13_xv <= (others => '0'); w_chi14_xv <= (others => '0'); w_chi15_xv <= (others => '0'); w_chi16_xv <= (others => '0'); w_chi17_xv <= (others => '0'); w_chi18_xv <= (others => '0');

      w_chi0_xa <= (others => '0'); w_chi1_xa <= (others => '0'); w_chi2_xa <= (others => '0'); w_chi3_xa <= (others => '0'); w_chi4_xa <= (others => '0'); w_chi5_xa <= (others => '0'); w_chi6_xa <= (others => '0'); w_chi7_xa <= (others => '0'); w_chi8_xa <= (others => '0'); w_chi9_xa <= (others => '0');
      w_chi10_xa <= (others => '0'); w_chi11_xa <= (others => '0'); w_chi12_xa <= (others => '0'); w_chi13_xa <= (others => '0'); w_chi14_xa <= (others => '0'); w_chi15_xa <= (others => '0'); w_chi16_xa <= (others => '0'); w_chi17_xa <= (others => '0'); w_chi18_xa <= (others => '0');

      w_chi0_yp <= (others => '0'); w_chi1_yp <= (others => '0'); w_chi2_yp <= (others => '0'); w_chi3_yp <= (others => '0'); w_chi4_yp <= (others => '0'); w_chi5_yp <= (others => '0'); w_chi6_yp <= (others => '0'); w_chi7_yp <= (others => '0'); w_chi8_yp <= (others => '0'); w_chi9_yp <= (others => '0');
      w_chi10_yp <= (others => '0'); w_chi11_yp <= (others => '0'); w_chi12_yp <= (others => '0'); w_chi13_yp <= (others => '0'); w_chi14_yp <= (others => '0'); w_chi15_yp <= (others => '0'); w_chi16_yp <= (others => '0'); w_chi17_yp <= (others => '0'); w_chi18_yp <= (others => '0');

      w_chi0_yv <= (others => '0'); w_chi1_yv <= (others => '0'); w_chi2_yv <= (others => '0'); w_chi3_yv <= (others => '0'); w_chi4_yv <= (others => '0'); w_chi5_yv <= (others => '0'); w_chi6_yv <= (others => '0'); w_chi7_yv <= (others => '0'); w_chi8_yv <= (others => '0'); w_chi9_yv <= (others => '0');
      w_chi10_yv <= (others => '0'); w_chi11_yv <= (others => '0'); w_chi12_yv <= (others => '0'); w_chi13_yv <= (others => '0'); w_chi14_yv <= (others => '0'); w_chi15_yv <= (others => '0'); w_chi16_yv <= (others => '0'); w_chi17_yv <= (others => '0'); w_chi18_yv <= (others => '0');

      w_chi0_ya <= (others => '0'); w_chi1_ya <= (others => '0'); w_chi2_ya <= (others => '0'); w_chi3_ya <= (others => '0'); w_chi4_ya <= (others => '0'); w_chi5_ya <= (others => '0'); w_chi6_ya <= (others => '0'); w_chi7_ya <= (others => '0'); w_chi8_ya <= (others => '0'); w_chi9_ya <= (others => '0');
      w_chi10_ya <= (others => '0'); w_chi11_ya <= (others => '0'); w_chi12_ya <= (others => '0'); w_chi13_ya <= (others => '0'); w_chi14_ya <= (others => '0'); w_chi15_ya <= (others => '0'); w_chi16_ya <= (others => '0'); w_chi17_ya <= (others => '0'); w_chi18_ya <= (others => '0');

      w_chi0_zp <= (others => '0'); w_chi1_zp <= (others => '0'); w_chi2_zp <= (others => '0'); w_chi3_zp <= (others => '0'); w_chi4_zp <= (others => '0'); w_chi5_zp <= (others => '0'); w_chi6_zp <= (others => '0'); w_chi7_zp <= (others => '0'); w_chi8_zp <= (others => '0'); w_chi9_zp <= (others => '0');
      w_chi10_zp <= (others => '0'); w_chi11_zp <= (others => '0'); w_chi12_zp <= (others => '0'); w_chi13_zp <= (others => '0'); w_chi14_zp <= (others => '0'); w_chi15_zp <= (others => '0'); w_chi16_zp <= (others => '0'); w_chi17_zp <= (others => '0'); w_chi18_zp <= (others => '0');

      w_chi0_zv <= (others => '0'); w_chi1_zv <= (others => '0'); w_chi2_zv <= (others => '0'); w_chi3_zv <= (others => '0'); w_chi4_zv <= (others => '0'); w_chi5_zv <= (others => '0'); w_chi6_zv <= (others => '0'); w_chi7_zv <= (others => '0'); w_chi8_zv <= (others => '0'); w_chi9_zv <= (others => '0');
      w_chi10_zv <= (others => '0'); w_chi11_zv <= (others => '0'); w_chi12_zv <= (others => '0'); w_chi13_zv <= (others => '0'); w_chi14_zv <= (others => '0'); w_chi15_zv <= (others => '0'); w_chi16_zv <= (others => '0'); w_chi17_zv <= (others => '0'); w_chi18_zv <= (others => '0');

      w_chi0_za <= (others => '0'); w_chi1_za <= (others => '0'); w_chi2_za <= (others => '0'); w_chi3_za <= (others => '0'); w_chi4_za <= (others => '0'); w_chi5_za <= (others => '0'); w_chi6_za <= (others => '0'); w_chi7_za <= (others => '0'); w_chi8_za <= (others => '0'); w_chi9_za <= (others => '0');
      w_chi10_za <= (others => '0'); w_chi11_za <= (others => '0'); w_chi12_za <= (others => '0'); w_chi13_za <= (others => '0'); w_chi14_za <= (others => '0'); w_chi15_za <= (others => '0'); w_chi16_za <= (others => '0'); w_chi17_za <= (others => '0'); w_chi18_za <= (others => '0');

    elsif rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if start = '1' then
            state <= MULTIPLY;
          end if;

        when MULTIPLY =>

          w_chi0_xp <= W0 * chi0_x_pos_pred;
          w_chi1_xp <= W1 * chi1_x_pos_pred; w_chi2_xp <= W1 * chi2_x_pos_pred; w_chi3_xp <= W1 * chi3_x_pos_pred; w_chi4_xp <= W1 * chi4_x_pos_pred; w_chi5_xp <= W1 * chi5_x_pos_pred;
          w_chi6_xp <= W1 * chi6_x_pos_pred; w_chi7_xp <= W1 * chi7_x_pos_pred; w_chi8_xp <= W1 * chi8_x_pos_pred; w_chi9_xp <= W1 * chi9_x_pos_pred;
          w_chi10_xp <= W1 * chi10_x_pos_pred; w_chi11_xp <= W1 * chi11_x_pos_pred; w_chi12_xp <= W1 * chi12_x_pos_pred; w_chi13_xp <= W1 * chi13_x_pos_pred; w_chi14_xp <= W1 * chi14_x_pos_pred;
          w_chi15_xp <= W1 * chi15_x_pos_pred; w_chi16_xp <= W1 * chi16_x_pos_pred; w_chi17_xp <= W1 * chi17_x_pos_pred; w_chi18_xp <= W1 * chi18_x_pos_pred;

          w_chi0_xv <= W0 * chi0_x_vel_pred;
          w_chi1_xv <= W1 * chi1_x_vel_pred; w_chi2_xv <= W1 * chi2_x_vel_pred; w_chi3_xv <= W1 * chi3_x_vel_pred; w_chi4_xv <= W1 * chi4_x_vel_pred; w_chi5_xv <= W1 * chi5_x_vel_pred;
          w_chi6_xv <= W1 * chi6_x_vel_pred; w_chi7_xv <= W1 * chi7_x_vel_pred; w_chi8_xv <= W1 * chi8_x_vel_pred; w_chi9_xv <= W1 * chi9_x_vel_pred;
          w_chi10_xv <= W1 * chi10_x_vel_pred; w_chi11_xv <= W1 * chi11_x_vel_pred; w_chi12_xv <= W1 * chi12_x_vel_pred; w_chi13_xv <= W1 * chi13_x_vel_pred; w_chi14_xv <= W1 * chi14_x_vel_pred;
          w_chi15_xv <= W1 * chi15_x_vel_pred; w_chi16_xv <= W1 * chi16_x_vel_pred; w_chi17_xv <= W1 * chi17_x_vel_pred; w_chi18_xv <= W1 * chi18_x_vel_pred;

          w_chi0_xa <= W0 * chi0_x_acc_pred;
          w_chi1_xa <= W1 * chi1_x_acc_pred; w_chi2_xa <= W1 * chi2_x_acc_pred; w_chi3_xa <= W1 * chi3_x_acc_pred; w_chi4_xa <= W1 * chi4_x_acc_pred; w_chi5_xa <= W1 * chi5_x_acc_pred;
          w_chi6_xa <= W1 * chi6_x_acc_pred; w_chi7_xa <= W1 * chi7_x_acc_pred; w_chi8_xa <= W1 * chi8_x_acc_pred; w_chi9_xa <= W1 * chi9_x_acc_pred;
          w_chi10_xa <= W1 * chi10_x_acc_pred; w_chi11_xa <= W1 * chi11_x_acc_pred; w_chi12_xa <= W1 * chi12_x_acc_pred; w_chi13_xa <= W1 * chi13_x_acc_pred; w_chi14_xa <= W1 * chi14_x_acc_pred;
          w_chi15_xa <= W1 * chi15_x_acc_pred; w_chi16_xa <= W1 * chi16_x_acc_pred; w_chi17_xa <= W1 * chi17_x_acc_pred; w_chi18_xa <= W1 * chi18_x_acc_pred;

          w_chi0_yp <= W0 * chi0_y_pos_pred;
          w_chi1_yp <= W1 * chi1_y_pos_pred; w_chi2_yp <= W1 * chi2_y_pos_pred; w_chi3_yp <= W1 * chi3_y_pos_pred; w_chi4_yp <= W1 * chi4_y_pos_pred; w_chi5_yp <= W1 * chi5_y_pos_pred;
          w_chi6_yp <= W1 * chi6_y_pos_pred; w_chi7_yp <= W1 * chi7_y_pos_pred; w_chi8_yp <= W1 * chi8_y_pos_pred; w_chi9_yp <= W1 * chi9_y_pos_pred;
          w_chi10_yp <= W1 * chi10_y_pos_pred; w_chi11_yp <= W1 * chi11_y_pos_pred; w_chi12_yp <= W1 * chi12_y_pos_pred; w_chi13_yp <= W1 * chi13_y_pos_pred; w_chi14_yp <= W1 * chi14_y_pos_pred;
          w_chi15_yp <= W1 * chi15_y_pos_pred; w_chi16_yp <= W1 * chi16_y_pos_pred; w_chi17_yp <= W1 * chi17_y_pos_pred; w_chi18_yp <= W1 * chi18_y_pos_pred;

          w_chi0_yv <= W0 * chi0_y_vel_pred;
          w_chi1_yv <= W1 * chi1_y_vel_pred; w_chi2_yv <= W1 * chi2_y_vel_pred; w_chi3_yv <= W1 * chi3_y_vel_pred; w_chi4_yv <= W1 * chi4_y_vel_pred; w_chi5_yv <= W1 * chi5_y_vel_pred;
          w_chi6_yv <= W1 * chi6_y_vel_pred; w_chi7_yv <= W1 * chi7_y_vel_pred; w_chi8_yv <= W1 * chi8_y_vel_pred; w_chi9_yv <= W1 * chi9_y_vel_pred;
          w_chi10_yv <= W1 * chi10_y_vel_pred; w_chi11_yv <= W1 * chi11_y_vel_pred; w_chi12_yv <= W1 * chi12_y_vel_pred; w_chi13_yv <= W1 * chi13_y_vel_pred; w_chi14_yv <= W1 * chi14_y_vel_pred;
          w_chi15_yv <= W1 * chi15_y_vel_pred; w_chi16_yv <= W1 * chi16_y_vel_pred; w_chi17_yv <= W1 * chi17_y_vel_pred; w_chi18_yv <= W1 * chi18_y_vel_pred;

          w_chi0_ya <= W0 * chi0_y_acc_pred;
          w_chi1_ya <= W1 * chi1_y_acc_pred; w_chi2_ya <= W1 * chi2_y_acc_pred; w_chi3_ya <= W1 * chi3_y_acc_pred; w_chi4_ya <= W1 * chi4_y_acc_pred; w_chi5_ya <= W1 * chi5_y_acc_pred;
          w_chi6_ya <= W1 * chi6_y_acc_pred; w_chi7_ya <= W1 * chi7_y_acc_pred; w_chi8_ya <= W1 * chi8_y_acc_pred; w_chi9_ya <= W1 * chi9_y_acc_pred;
          w_chi10_ya <= W1 * chi10_y_acc_pred; w_chi11_ya <= W1 * chi11_y_acc_pred; w_chi12_ya <= W1 * chi12_y_acc_pred; w_chi13_ya <= W1 * chi13_y_acc_pred; w_chi14_ya <= W1 * chi14_y_acc_pred;
          w_chi15_ya <= W1 * chi15_y_acc_pred; w_chi16_ya <= W1 * chi16_y_acc_pred; w_chi17_ya <= W1 * chi17_y_acc_pred; w_chi18_ya <= W1 * chi18_y_acc_pred;

          w_chi0_zp <= W0 * chi0_z_pos_pred;
          w_chi1_zp <= W1 * chi1_z_pos_pred; w_chi2_zp <= W1 * chi2_z_pos_pred; w_chi3_zp <= W1 * chi3_z_pos_pred; w_chi4_zp <= W1 * chi4_z_pos_pred; w_chi5_zp <= W1 * chi5_z_pos_pred;
          w_chi6_zp <= W1 * chi6_z_pos_pred; w_chi7_zp <= W1 * chi7_z_pos_pred; w_chi8_zp <= W1 * chi8_z_pos_pred; w_chi9_zp <= W1 * chi9_z_pos_pred;
          w_chi10_zp <= W1 * chi10_z_pos_pred; w_chi11_zp <= W1 * chi11_z_pos_pred; w_chi12_zp <= W1 * chi12_z_pos_pred; w_chi13_zp <= W1 * chi13_z_pos_pred; w_chi14_zp <= W1 * chi14_z_pos_pred;
          w_chi15_zp <= W1 * chi15_z_pos_pred; w_chi16_zp <= W1 * chi16_z_pos_pred; w_chi17_zp <= W1 * chi17_z_pos_pred; w_chi18_zp <= W1 * chi18_z_pos_pred;

          w_chi0_zv <= W0 * chi0_z_vel_pred;
          w_chi1_zv <= W1 * chi1_z_vel_pred; w_chi2_zv <= W1 * chi2_z_vel_pred; w_chi3_zv <= W1 * chi3_z_vel_pred; w_chi4_zv <= W1 * chi4_z_vel_pred; w_chi5_zv <= W1 * chi5_z_vel_pred;
          w_chi6_zv <= W1 * chi6_z_vel_pred; w_chi7_zv <= W1 * chi7_z_vel_pred; w_chi8_zv <= W1 * chi8_z_vel_pred; w_chi9_zv <= W1 * chi9_z_vel_pred;
          w_chi10_zv <= W1 * chi10_z_vel_pred; w_chi11_zv <= W1 * chi11_z_vel_pred; w_chi12_zv <= W1 * chi12_z_vel_pred; w_chi13_zv <= W1 * chi13_z_vel_pred; w_chi14_zv <= W1 * chi14_z_vel_pred;
          w_chi15_zv <= W1 * chi15_z_vel_pred; w_chi16_zv <= W1 * chi16_z_vel_pred; w_chi17_zv <= W1 * chi17_z_vel_pred; w_chi18_zv <= W1 * chi18_z_vel_pred;

          w_chi0_za <= W0 * chi0_z_acc_pred;
          w_chi1_za <= W1 * chi1_z_acc_pred; w_chi2_za <= W1 * chi2_z_acc_pred; w_chi3_za <= W1 * chi3_z_acc_pred; w_chi4_za <= W1 * chi4_z_acc_pred; w_chi5_za <= W1 * chi5_z_acc_pred;
          w_chi6_za <= W1 * chi6_z_acc_pred; w_chi7_za <= W1 * chi7_z_acc_pred; w_chi8_za <= W1 * chi8_z_acc_pred; w_chi9_za <= W1 * chi9_z_acc_pred;
          w_chi10_za <= W1 * chi10_z_acc_pred; w_chi11_za <= W1 * chi11_z_acc_pred; w_chi12_za <= W1 * chi12_z_acc_pred; w_chi13_za <= W1 * chi13_z_acc_pred; w_chi14_za <= W1 * chi14_z_acc_pred;
          w_chi15_za <= W1 * chi15_z_acc_pred; w_chi16_za <= W1 * chi16_z_acc_pred; w_chi17_za <= W1 * chi17_z_acc_pred; w_chi18_za <= W1 * chi18_z_acc_pred;

          state <= ACCUMULATE;

        when ACCUMULATE =>

          temp_xp := resize(shift_right(w_chi0_xp, Q), 44) +
                     resize(shift_right(w_chi1_xp, Q), 44) + resize(shift_right(w_chi2_xp, Q), 44) + resize(shift_right(w_chi3_xp, Q), 44) + resize(shift_right(w_chi4_xp, Q), 44) + resize(shift_right(w_chi5_xp, Q), 44) +
                     resize(shift_right(w_chi6_xp, Q), 44) + resize(shift_right(w_chi7_xp, Q), 44) + resize(shift_right(w_chi8_xp, Q), 44) + resize(shift_right(w_chi9_xp, Q), 44) +
                     resize(shift_right(w_chi10_xp, Q), 44) + resize(shift_right(w_chi11_xp, Q), 44) + resize(shift_right(w_chi12_xp, Q), 44) + resize(shift_right(w_chi13_xp, Q), 44) + resize(shift_right(w_chi14_xp, Q), 44) +
                     resize(shift_right(w_chi15_xp, Q), 44) + resize(shift_right(w_chi16_xp, Q), 44) + resize(shift_right(w_chi17_xp, Q), 44) + resize(shift_right(w_chi18_xp, Q), 44);

          temp_xv := resize(shift_right(w_chi0_xv, Q), 44) +
                     resize(shift_right(w_chi1_xv, Q), 44) + resize(shift_right(w_chi2_xv, Q), 44) + resize(shift_right(w_chi3_xv, Q), 44) + resize(shift_right(w_chi4_xv, Q), 44) + resize(shift_right(w_chi5_xv, Q), 44) +
                     resize(shift_right(w_chi6_xv, Q), 44) + resize(shift_right(w_chi7_xv, Q), 44) + resize(shift_right(w_chi8_xv, Q), 44) + resize(shift_right(w_chi9_xv, Q), 44) +
                     resize(shift_right(w_chi10_xv, Q), 44) + resize(shift_right(w_chi11_xv, Q), 44) + resize(shift_right(w_chi12_xv, Q), 44) + resize(shift_right(w_chi13_xv, Q), 44) + resize(shift_right(w_chi14_xv, Q), 44) +
                     resize(shift_right(w_chi15_xv, Q), 44) + resize(shift_right(w_chi16_xv, Q), 44) + resize(shift_right(w_chi17_xv, Q), 44) + resize(shift_right(w_chi18_xv, Q), 44);

          temp_xa := resize(shift_right(w_chi0_xa, Q), 44) +
                     resize(shift_right(w_chi1_xa, Q), 44) + resize(shift_right(w_chi2_xa, Q), 44) + resize(shift_right(w_chi3_xa, Q), 44) + resize(shift_right(w_chi4_xa, Q), 44) + resize(shift_right(w_chi5_xa, Q), 44) +
                     resize(shift_right(w_chi6_xa, Q), 44) + resize(shift_right(w_chi7_xa, Q), 44) + resize(shift_right(w_chi8_xa, Q), 44) + resize(shift_right(w_chi9_xa, Q), 44) +
                     resize(shift_right(w_chi10_xa, Q), 44) + resize(shift_right(w_chi11_xa, Q), 44) + resize(shift_right(w_chi12_xa, Q), 44) + resize(shift_right(w_chi13_xa, Q), 44) + resize(shift_right(w_chi14_xa, Q), 44) +
                     resize(shift_right(w_chi15_xa, Q), 44) + resize(shift_right(w_chi16_xa, Q), 44) + resize(shift_right(w_chi17_xa, Q), 44) + resize(shift_right(w_chi18_xa, Q), 44);

          temp_yp := resize(shift_right(w_chi0_yp, Q), 44) +
                     resize(shift_right(w_chi1_yp, Q), 44) + resize(shift_right(w_chi2_yp, Q), 44) + resize(shift_right(w_chi3_yp, Q), 44) + resize(shift_right(w_chi4_yp, Q), 44) + resize(shift_right(w_chi5_yp, Q), 44) +
                     resize(shift_right(w_chi6_yp, Q), 44) + resize(shift_right(w_chi7_yp, Q), 44) + resize(shift_right(w_chi8_yp, Q), 44) + resize(shift_right(w_chi9_yp, Q), 44) +
                     resize(shift_right(w_chi10_yp, Q), 44) + resize(shift_right(w_chi11_yp, Q), 44) + resize(shift_right(w_chi12_yp, Q), 44) + resize(shift_right(w_chi13_yp, Q), 44) + resize(shift_right(w_chi14_yp, Q), 44) +
                     resize(shift_right(w_chi15_yp, Q), 44) + resize(shift_right(w_chi16_yp, Q), 44) + resize(shift_right(w_chi17_yp, Q), 44) + resize(shift_right(w_chi18_yp, Q), 44);

          temp_yv := resize(shift_right(w_chi0_yv, Q), 44) +
                     resize(shift_right(w_chi1_yv, Q), 44) + resize(shift_right(w_chi2_yv, Q), 44) + resize(shift_right(w_chi3_yv, Q), 44) + resize(shift_right(w_chi4_yv, Q), 44) + resize(shift_right(w_chi5_yv, Q), 44) +
                     resize(shift_right(w_chi6_yv, Q), 44) + resize(shift_right(w_chi7_yv, Q), 44) + resize(shift_right(w_chi8_yv, Q), 44) + resize(shift_right(w_chi9_yv, Q), 44) +
                     resize(shift_right(w_chi10_yv, Q), 44) + resize(shift_right(w_chi11_yv, Q), 44) + resize(shift_right(w_chi12_yv, Q), 44) + resize(shift_right(w_chi13_yv, Q), 44) + resize(shift_right(w_chi14_yv, Q), 44) +
                     resize(shift_right(w_chi15_yv, Q), 44) + resize(shift_right(w_chi16_yv, Q), 44) + resize(shift_right(w_chi17_yv, Q), 44) + resize(shift_right(w_chi18_yv, Q), 44);

          temp_ya := resize(shift_right(w_chi0_ya, Q), 44) +
                     resize(shift_right(w_chi1_ya, Q), 44) + resize(shift_right(w_chi2_ya, Q), 44) + resize(shift_right(w_chi3_ya, Q), 44) + resize(shift_right(w_chi4_ya, Q), 44) + resize(shift_right(w_chi5_ya, Q), 44) +
                     resize(shift_right(w_chi6_ya, Q), 44) + resize(shift_right(w_chi7_ya, Q), 44) + resize(shift_right(w_chi8_ya, Q), 44) + resize(shift_right(w_chi9_ya, Q), 44) +
                     resize(shift_right(w_chi10_ya, Q), 44) + resize(shift_right(w_chi11_ya, Q), 44) + resize(shift_right(w_chi12_ya, Q), 44) + resize(shift_right(w_chi13_ya, Q), 44) + resize(shift_right(w_chi14_ya, Q), 44) +
                     resize(shift_right(w_chi15_ya, Q), 44) + resize(shift_right(w_chi16_ya, Q), 44) + resize(shift_right(w_chi17_ya, Q), 44) + resize(shift_right(w_chi18_ya, Q), 44);

          temp_zp := resize(shift_right(w_chi0_zp, Q), 44) +
                     resize(shift_right(w_chi1_zp, Q), 44) + resize(shift_right(w_chi2_zp, Q), 44) + resize(shift_right(w_chi3_zp, Q), 44) + resize(shift_right(w_chi4_zp, Q), 44) + resize(shift_right(w_chi5_zp, Q), 44) +
                     resize(shift_right(w_chi6_zp, Q), 44) + resize(shift_right(w_chi7_zp, Q), 44) + resize(shift_right(w_chi8_zp, Q), 44) + resize(shift_right(w_chi9_zp, Q), 44) +
                     resize(shift_right(w_chi10_zp, Q), 44) + resize(shift_right(w_chi11_zp, Q), 44) + resize(shift_right(w_chi12_zp, Q), 44) + resize(shift_right(w_chi13_zp, Q), 44) + resize(shift_right(w_chi14_zp, Q), 44) +
                     resize(shift_right(w_chi15_zp, Q), 44) + resize(shift_right(w_chi16_zp, Q), 44) + resize(shift_right(w_chi17_zp, Q), 44) + resize(shift_right(w_chi18_zp, Q), 44);

          temp_zv := resize(shift_right(w_chi0_zv, Q), 44) +
                     resize(shift_right(w_chi1_zv, Q), 44) + resize(shift_right(w_chi2_zv, Q), 44) + resize(shift_right(w_chi3_zv, Q), 44) + resize(shift_right(w_chi4_zv, Q), 44) + resize(shift_right(w_chi5_zv, Q), 44) +
                     resize(shift_right(w_chi6_zv, Q), 44) + resize(shift_right(w_chi7_zv, Q), 44) + resize(shift_right(w_chi8_zv, Q), 44) + resize(shift_right(w_chi9_zv, Q), 44) +
                     resize(shift_right(w_chi10_zv, Q), 44) + resize(shift_right(w_chi11_zv, Q), 44) + resize(shift_right(w_chi12_zv, Q), 44) + resize(shift_right(w_chi13_zv, Q), 44) + resize(shift_right(w_chi14_zv, Q), 44) +
                     resize(shift_right(w_chi15_zv, Q), 44) + resize(shift_right(w_chi16_zv, Q), 44) + resize(shift_right(w_chi17_zv, Q), 44) + resize(shift_right(w_chi18_zv, Q), 44);

          temp_za := resize(shift_right(w_chi0_za, Q), 44) +
                     resize(shift_right(w_chi1_za, Q), 44) + resize(shift_right(w_chi2_za, Q), 44) + resize(shift_right(w_chi3_za, Q), 44) + resize(shift_right(w_chi4_za, Q), 44) + resize(shift_right(w_chi5_za, Q), 44) +
                     resize(shift_right(w_chi6_za, Q), 44) + resize(shift_right(w_chi7_za, Q), 44) + resize(shift_right(w_chi8_za, Q), 44) + resize(shift_right(w_chi9_za, Q), 44) +
                     resize(shift_right(w_chi10_za, Q), 44) + resize(shift_right(w_chi11_za, Q), 44) + resize(shift_right(w_chi12_za, Q), 44) + resize(shift_right(w_chi13_za, Q), 44) + resize(shift_right(w_chi14_za, Q), 44) +
                     resize(shift_right(w_chi15_za, Q), 44) + resize(shift_right(w_chi16_za, Q), 44) + resize(shift_right(w_chi17_za, Q), 44) + resize(shift_right(w_chi18_za, Q), 44);

          sum_xp <= temp_xp; sum_xv <= temp_xv; sum_xa <= temp_xa;
          sum_yp <= temp_yp; sum_yv <= temp_yv; sum_ya <= temp_ya;
          sum_zp <= temp_zp; sum_zv <= temp_zv; sum_za <= temp_za;
          state <= OUTPUT;

        when OUTPUT =>

          x_pos_mean_int <= resize(sum_xp, 48);
          y_pos_mean_int <= resize(sum_yp, 48);
          z_pos_mean_int <= resize(sum_zp, 48);

          x_vel_mean_int <= resize(sum_xv, 48);
          y_vel_mean_int <= resize(sum_yv, 48);
          z_vel_mean_int <= resize(sum_zv, 48);

          x_acc_mean_int <= resize(sum_xa, 48);
          y_acc_mean_int <= resize(sum_ya, 48);
          z_acc_mean_int <= resize(sum_za, 48);

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
  end process;

  x_pos_mean_pred <= x_pos_mean_int;
  x_vel_mean_pred <= x_vel_mean_int;
  x_acc_mean_pred <= x_acc_mean_int;
  y_pos_mean_pred <= y_pos_mean_int;
  y_vel_mean_pred <= y_vel_mean_int;
  y_acc_mean_pred <= y_acc_mean_int;
  z_pos_mean_pred <= z_pos_mean_int;
  z_vel_mean_pred <= z_vel_mean_int;
  z_acc_mean_pred <= z_acc_mean_int;

end Behavioral;
