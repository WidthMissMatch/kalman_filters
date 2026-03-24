library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.TEXTIO.ALL;

entity predicti_ca3d is
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    start       : in  std_logic;

    chi0_x_pos_in : in signed(47 downto 0);
    chi0_x_vel_in : in signed(47 downto 0);
    chi0_x_acc_in : in signed(47 downto 0);
    chi0_y_pos_in : in signed(47 downto 0);
    chi0_y_vel_in : in signed(47 downto 0);
    chi0_y_acc_in : in signed(47 downto 0);
    chi0_z_pos_in : in signed(47 downto 0);
    chi0_z_vel_in : in signed(47 downto 0);
    chi0_z_acc_in : in signed(47 downto 0);

    chi1_x_pos_in, chi1_x_vel_in, chi1_x_acc_in : in signed(47 downto 0);
    chi1_y_pos_in, chi1_y_vel_in, chi1_y_acc_in : in signed(47 downto 0);
    chi1_z_pos_in, chi1_z_vel_in, chi1_z_acc_in : in signed(47 downto 0);

    chi2_x_pos_in, chi2_x_vel_in, chi2_x_acc_in : in signed(47 downto 0);
    chi2_y_pos_in, chi2_y_vel_in, chi2_y_acc_in : in signed(47 downto 0);
    chi2_z_pos_in, chi2_z_vel_in, chi2_z_acc_in : in signed(47 downto 0);

    chi3_x_pos_in, chi3_x_vel_in, chi3_x_acc_in : in signed(47 downto 0);
    chi3_y_pos_in, chi3_y_vel_in, chi3_y_acc_in : in signed(47 downto 0);
    chi3_z_pos_in, chi3_z_vel_in, chi3_z_acc_in : in signed(47 downto 0);

    chi4_x_pos_in, chi4_x_vel_in, chi4_x_acc_in : in signed(47 downto 0);
    chi4_y_pos_in, chi4_y_vel_in, chi4_y_acc_in : in signed(47 downto 0);
    chi4_z_pos_in, chi4_z_vel_in, chi4_z_acc_in : in signed(47 downto 0);

    chi5_x_pos_in, chi5_x_vel_in, chi5_x_acc_in : in signed(47 downto 0);
    chi5_y_pos_in, chi5_y_vel_in, chi5_y_acc_in : in signed(47 downto 0);
    chi5_z_pos_in, chi5_z_vel_in, chi5_z_acc_in : in signed(47 downto 0);

    chi6_x_pos_in, chi6_x_vel_in, chi6_x_acc_in : in signed(47 downto 0);
    chi6_y_pos_in, chi6_y_vel_in, chi6_y_acc_in : in signed(47 downto 0);
    chi6_z_pos_in, chi6_z_vel_in, chi6_z_acc_in : in signed(47 downto 0);

    chi7_x_pos_in, chi7_x_vel_in, chi7_x_acc_in : in signed(47 downto 0);
    chi7_y_pos_in, chi7_y_vel_in, chi7_y_acc_in : in signed(47 downto 0);
    chi7_z_pos_in, chi7_z_vel_in, chi7_z_acc_in : in signed(47 downto 0);

    chi8_x_pos_in, chi8_x_vel_in, chi8_x_acc_in : in signed(47 downto 0);
    chi8_y_pos_in, chi8_y_vel_in, chi8_y_acc_in : in signed(47 downto 0);
    chi8_z_pos_in, chi8_z_vel_in, chi8_z_acc_in : in signed(47 downto 0);

    chi9_x_pos_in, chi9_x_vel_in, chi9_x_acc_in : in signed(47 downto 0);
    chi9_y_pos_in, chi9_y_vel_in, chi9_y_acc_in : in signed(47 downto 0);
    chi9_z_pos_in, chi9_z_vel_in, chi9_z_acc_in : in signed(47 downto 0);

    chi10_x_pos_in, chi10_x_vel_in, chi10_x_acc_in : in signed(47 downto 0);
    chi10_y_pos_in, chi10_y_vel_in, chi10_y_acc_in : in signed(47 downto 0);
    chi10_z_pos_in, chi10_z_vel_in, chi10_z_acc_in : in signed(47 downto 0);

    chi11_x_pos_in, chi11_x_vel_in, chi11_x_acc_in : in signed(47 downto 0);
    chi11_y_pos_in, chi11_y_vel_in, chi11_y_acc_in : in signed(47 downto 0);
    chi11_z_pos_in, chi11_z_vel_in, chi11_z_acc_in : in signed(47 downto 0);

    chi12_x_pos_in, chi12_x_vel_in, chi12_x_acc_in : in signed(47 downto 0);
    chi12_y_pos_in, chi12_y_vel_in, chi12_y_acc_in : in signed(47 downto 0);
    chi12_z_pos_in, chi12_z_vel_in, chi12_z_acc_in : in signed(47 downto 0);

    chi13_x_pos_in, chi13_x_vel_in, chi13_x_acc_in : in signed(47 downto 0);
    chi13_y_pos_in, chi13_y_vel_in, chi13_y_acc_in : in signed(47 downto 0);
    chi13_z_pos_in, chi13_z_vel_in, chi13_z_acc_in : in signed(47 downto 0);

    chi14_x_pos_in, chi14_x_vel_in, chi14_x_acc_in : in signed(47 downto 0);
    chi14_y_pos_in, chi14_y_vel_in, chi14_y_acc_in : in signed(47 downto 0);
    chi14_z_pos_in, chi14_z_vel_in, chi14_z_acc_in : in signed(47 downto 0);

    chi15_x_pos_in, chi15_x_vel_in, chi15_x_acc_in : in signed(47 downto 0);
    chi15_y_pos_in, chi15_y_vel_in, chi15_y_acc_in : in signed(47 downto 0);
    chi15_z_pos_in, chi15_z_vel_in, chi15_z_acc_in : in signed(47 downto 0);

    chi16_x_pos_in, chi16_x_vel_in, chi16_x_acc_in : in signed(47 downto 0);
    chi16_y_pos_in, chi16_y_vel_in, chi16_y_acc_in : in signed(47 downto 0);
    chi16_z_pos_in, chi16_z_vel_in, chi16_z_acc_in : in signed(47 downto 0);

    chi17_x_pos_in, chi17_x_vel_in, chi17_x_acc_in : in signed(47 downto 0);
    chi17_y_pos_in, chi17_y_vel_in, chi17_y_acc_in : in signed(47 downto 0);
    chi17_z_pos_in, chi17_z_vel_in, chi17_z_acc_in : in signed(47 downto 0);

    chi18_x_pos_in, chi18_x_vel_in, chi18_x_acc_in : in signed(47 downto 0);
    chi18_y_pos_in, chi18_y_vel_in, chi18_y_acc_in : in signed(47 downto 0);
    chi18_z_pos_in, chi18_z_vel_in, chi18_z_acc_in : in signed(47 downto 0);

    chi0_x_pos_pred, chi0_x_vel_pred, chi0_x_acc_pred : out signed(47 downto 0);
    chi0_y_pos_pred, chi0_y_vel_pred, chi0_y_acc_pred : out signed(47 downto 0);
    chi0_z_pos_pred, chi0_z_vel_pred, chi0_z_acc_pred : out signed(47 downto 0);

    chi1_x_pos_pred, chi1_x_vel_pred, chi1_x_acc_pred : out signed(47 downto 0);
    chi1_y_pos_pred, chi1_y_vel_pred, chi1_y_acc_pred : out signed(47 downto 0);
    chi1_z_pos_pred, chi1_z_vel_pred, chi1_z_acc_pred : out signed(47 downto 0);

    chi2_x_pos_pred, chi2_x_vel_pred, chi2_x_acc_pred : out signed(47 downto 0);
    chi2_y_pos_pred, chi2_y_vel_pred, chi2_y_acc_pred : out signed(47 downto 0);
    chi2_z_pos_pred, chi2_z_vel_pred, chi2_z_acc_pred : out signed(47 downto 0);

    chi3_x_pos_pred, chi3_x_vel_pred, chi3_x_acc_pred : out signed(47 downto 0);
    chi3_y_pos_pred, chi3_y_vel_pred, chi3_y_acc_pred : out signed(47 downto 0);
    chi3_z_pos_pred, chi3_z_vel_pred, chi3_z_acc_pred : out signed(47 downto 0);

    chi4_x_pos_pred, chi4_x_vel_pred, chi4_x_acc_pred : out signed(47 downto 0);
    chi4_y_pos_pred, chi4_y_vel_pred, chi4_y_acc_pred : out signed(47 downto 0);
    chi4_z_pos_pred, chi4_z_vel_pred, chi4_z_acc_pred : out signed(47 downto 0);

    chi5_x_pos_pred, chi5_x_vel_pred, chi5_x_acc_pred : out signed(47 downto 0);
    chi5_y_pos_pred, chi5_y_vel_pred, chi5_y_acc_pred : out signed(47 downto 0);
    chi5_z_pos_pred, chi5_z_vel_pred, chi5_z_acc_pred : out signed(47 downto 0);

    chi6_x_pos_pred, chi6_x_vel_pred, chi6_x_acc_pred : out signed(47 downto 0);
    chi6_y_pos_pred, chi6_y_vel_pred, chi6_y_acc_pred : out signed(47 downto 0);
    chi6_z_pos_pred, chi6_z_vel_pred, chi6_z_acc_pred : out signed(47 downto 0);

    chi7_x_pos_pred, chi7_x_vel_pred, chi7_x_acc_pred : out signed(47 downto 0);
    chi7_y_pos_pred, chi7_y_vel_pred, chi7_y_acc_pred : out signed(47 downto 0);
    chi7_z_pos_pred, chi7_z_vel_pred, chi7_z_acc_pred : out signed(47 downto 0);

    chi8_x_pos_pred, chi8_x_vel_pred, chi8_x_acc_pred : out signed(47 downto 0);
    chi8_y_pos_pred, chi8_y_vel_pred, chi8_y_acc_pred : out signed(47 downto 0);
    chi8_z_pos_pred, chi8_z_vel_pred, chi8_z_acc_pred : out signed(47 downto 0);

    chi9_x_pos_pred, chi9_x_vel_pred, chi9_x_acc_pred : out signed(47 downto 0);
    chi9_y_pos_pred, chi9_y_vel_pred, chi9_y_acc_pred : out signed(47 downto 0);
    chi9_z_pos_pred, chi9_z_vel_pred, chi9_z_acc_pred : out signed(47 downto 0);

    chi10_x_pos_pred, chi10_x_vel_pred, chi10_x_acc_pred : out signed(47 downto 0);
    chi10_y_pos_pred, chi10_y_vel_pred, chi10_y_acc_pred : out signed(47 downto 0);
    chi10_z_pos_pred, chi10_z_vel_pred, chi10_z_acc_pred : out signed(47 downto 0);

    chi11_x_pos_pred, chi11_x_vel_pred, chi11_x_acc_pred : out signed(47 downto 0);
    chi11_y_pos_pred, chi11_y_vel_pred, chi11_y_acc_pred : out signed(47 downto 0);
    chi11_z_pos_pred, chi11_z_vel_pred, chi11_z_acc_pred : out signed(47 downto 0);

    chi12_x_pos_pred, chi12_x_vel_pred, chi12_x_acc_pred : out signed(47 downto 0);
    chi12_y_pos_pred, chi12_y_vel_pred, chi12_y_acc_pred : out signed(47 downto 0);
    chi12_z_pos_pred, chi12_z_vel_pred, chi12_z_acc_pred : out signed(47 downto 0);

    chi13_x_pos_pred, chi13_x_vel_pred, chi13_x_acc_pred : out signed(47 downto 0);
    chi13_y_pos_pred, chi13_y_vel_pred, chi13_y_acc_pred : out signed(47 downto 0);
    chi13_z_pos_pred, chi13_z_vel_pred, chi13_z_acc_pred : out signed(47 downto 0);

    chi14_x_pos_pred, chi14_x_vel_pred, chi14_x_acc_pred : out signed(47 downto 0);
    chi14_y_pos_pred, chi14_y_vel_pred, chi14_y_acc_pred : out signed(47 downto 0);
    chi14_z_pos_pred, chi14_z_vel_pred, chi14_z_acc_pred : out signed(47 downto 0);

    chi15_x_pos_pred, chi15_x_vel_pred, chi15_x_acc_pred : out signed(47 downto 0);
    chi15_y_pos_pred, chi15_y_vel_pred, chi15_y_acc_pred : out signed(47 downto 0);
    chi15_z_pos_pred, chi15_z_vel_pred, chi15_z_acc_pred : out signed(47 downto 0);

    chi16_x_pos_pred, chi16_x_vel_pred, chi16_x_acc_pred : out signed(47 downto 0);
    chi16_y_pos_pred, chi16_y_vel_pred, chi16_y_acc_pred : out signed(47 downto 0);
    chi16_z_pos_pred, chi16_z_vel_pred, chi16_z_acc_pred : out signed(47 downto 0);

    chi17_x_pos_pred, chi17_x_vel_pred, chi17_x_acc_pred : out signed(47 downto 0);
    chi17_y_pos_pred, chi17_y_vel_pred, chi17_y_acc_pred : out signed(47 downto 0);
    chi17_z_pos_pred, chi17_z_vel_pred, chi17_z_acc_pred : out signed(47 downto 0);

    chi18_x_pos_pred, chi18_x_vel_pred, chi18_x_acc_pred : out signed(47 downto 0);
    chi18_y_pos_pred, chi18_y_vel_pred, chi18_y_acc_pred : out signed(47 downto 0);
    chi18_z_pos_pred, chi18_z_vel_pred, chi18_z_acc_pred : out signed(47 downto 0);

    done        : out std_logic
  );
end entity;

architecture Behavioral of predicti_ca3d is

  constant DT_Q24_24      : signed(47 downto 0) := to_signed(335544, 48);
  constant DT_SQ_Q24_24   : signed(47 downto 0) := to_signed(6711, 48);
  constant HALF_Q24_24    : signed(47 downto 0) := to_signed(8388608, 48);
  constant Q : integer := 24;

  type state_type is (IDLE, MULTIPLY_VEL, MULTIPLY_ACC, CALCULATE, FINISHED);
  signal state : state_type := IDLE;

  signal chi0_x_vel_dt, chi1_x_vel_dt, chi2_x_vel_dt, chi3_x_vel_dt : signed(95 downto 0) := (others => '0');
  signal chi4_x_vel_dt, chi5_x_vel_dt, chi6_x_vel_dt, chi7_x_vel_dt : signed(95 downto 0) := (others => '0');
  signal chi8_x_vel_dt, chi9_x_vel_dt, chi10_x_vel_dt, chi11_x_vel_dt : signed(95 downto 0) := (others => '0');
  signal chi12_x_vel_dt, chi13_x_vel_dt, chi14_x_vel_dt, chi15_x_vel_dt : signed(95 downto 0) := (others => '0');
  signal chi16_x_vel_dt, chi17_x_vel_dt, chi18_x_vel_dt : signed(95 downto 0) := (others => '0');

  signal chi0_y_vel_dt, chi1_y_vel_dt, chi2_y_vel_dt, chi3_y_vel_dt : signed(95 downto 0) := (others => '0');
  signal chi4_y_vel_dt, chi5_y_vel_dt, chi6_y_vel_dt, chi7_y_vel_dt : signed(95 downto 0) := (others => '0');
  signal chi8_y_vel_dt, chi9_y_vel_dt, chi10_y_vel_dt, chi11_y_vel_dt : signed(95 downto 0) := (others => '0');
  signal chi12_y_vel_dt, chi13_y_vel_dt, chi14_y_vel_dt, chi15_y_vel_dt : signed(95 downto 0) := (others => '0');
  signal chi16_y_vel_dt, chi17_y_vel_dt, chi18_y_vel_dt : signed(95 downto 0) := (others => '0');

  signal chi0_z_vel_dt, chi1_z_vel_dt, chi2_z_vel_dt, chi3_z_vel_dt : signed(95 downto 0) := (others => '0');
  signal chi4_z_vel_dt, chi5_z_vel_dt, chi6_z_vel_dt, chi7_z_vel_dt : signed(95 downto 0) := (others => '0');
  signal chi8_z_vel_dt, chi9_z_vel_dt, chi10_z_vel_dt, chi11_z_vel_dt : signed(95 downto 0) := (others => '0');
  signal chi12_z_vel_dt, chi13_z_vel_dt, chi14_z_vel_dt, chi15_z_vel_dt : signed(95 downto 0) := (others => '0');
  signal chi16_z_vel_dt, chi17_z_vel_dt, chi18_z_vel_dt : signed(95 downto 0) := (others => '0');

  signal chi0_x_acc_dt, chi1_x_acc_dt, chi2_x_acc_dt, chi3_x_acc_dt : signed(95 downto 0) := (others => '0');
  signal chi4_x_acc_dt, chi5_x_acc_dt, chi6_x_acc_dt, chi7_x_acc_dt : signed(95 downto 0) := (others => '0');
  signal chi8_x_acc_dt, chi9_x_acc_dt, chi10_x_acc_dt, chi11_x_acc_dt : signed(95 downto 0) := (others => '0');
  signal chi12_x_acc_dt, chi13_x_acc_dt, chi14_x_acc_dt, chi15_x_acc_dt : signed(95 downto 0) := (others => '0');
  signal chi16_x_acc_dt, chi17_x_acc_dt, chi18_x_acc_dt : signed(95 downto 0) := (others => '0');

  signal chi0_y_acc_dt, chi1_y_acc_dt, chi2_y_acc_dt, chi3_y_acc_dt : signed(95 downto 0) := (others => '0');
  signal chi4_y_acc_dt, chi5_y_acc_dt, chi6_y_acc_dt, chi7_y_acc_dt : signed(95 downto 0) := (others => '0');
  signal chi8_y_acc_dt, chi9_y_acc_dt, chi10_y_acc_dt, chi11_y_acc_dt : signed(95 downto 0) := (others => '0');
  signal chi12_y_acc_dt, chi13_y_acc_dt, chi14_y_acc_dt, chi15_y_acc_dt : signed(95 downto 0) := (others => '0');
  signal chi16_y_acc_dt, chi17_y_acc_dt, chi18_y_acc_dt : signed(95 downto 0) := (others => '0');

  signal chi0_z_acc_dt, chi1_z_acc_dt, chi2_z_acc_dt, chi3_z_acc_dt : signed(95 downto 0) := (others => '0');
  signal chi4_z_acc_dt, chi5_z_acc_dt, chi6_z_acc_dt, chi7_z_acc_dt : signed(95 downto 0) := (others => '0');
  signal chi8_z_acc_dt, chi9_z_acc_dt, chi10_z_acc_dt, chi11_z_acc_dt : signed(95 downto 0) := (others => '0');
  signal chi12_z_acc_dt, chi13_z_acc_dt, chi14_z_acc_dt, chi15_z_acc_dt : signed(95 downto 0) := (others => '0');
  signal chi16_z_acc_dt, chi17_z_acc_dt, chi18_z_acc_dt : signed(95 downto 0) := (others => '0');

  signal chi0_x_acc_dt_sq, chi1_x_acc_dt_sq, chi2_x_acc_dt_sq, chi3_x_acc_dt_sq : signed(95 downto 0) := (others => '0');
  signal chi4_x_acc_dt_sq, chi5_x_acc_dt_sq, chi6_x_acc_dt_sq, chi7_x_acc_dt_sq : signed(95 downto 0) := (others => '0');
  signal chi8_x_acc_dt_sq, chi9_x_acc_dt_sq, chi10_x_acc_dt_sq, chi11_x_acc_dt_sq : signed(95 downto 0) := (others => '0');
  signal chi12_x_acc_dt_sq, chi13_x_acc_dt_sq, chi14_x_acc_dt_sq, chi15_x_acc_dt_sq : signed(95 downto 0) := (others => '0');
  signal chi16_x_acc_dt_sq, chi17_x_acc_dt_sq, chi18_x_acc_dt_sq : signed(95 downto 0) := (others => '0');

  signal chi0_y_acc_dt_sq, chi1_y_acc_dt_sq, chi2_y_acc_dt_sq, chi3_y_acc_dt_sq : signed(95 downto 0) := (others => '0');
  signal chi4_y_acc_dt_sq, chi5_y_acc_dt_sq, chi6_y_acc_dt_sq, chi7_y_acc_dt_sq : signed(95 downto 0) := (others => '0');
  signal chi8_y_acc_dt_sq, chi9_y_acc_dt_sq, chi10_y_acc_dt_sq, chi11_y_acc_dt_sq : signed(95 downto 0) := (others => '0');
  signal chi12_y_acc_dt_sq, chi13_y_acc_dt_sq, chi14_y_acc_dt_sq, chi15_y_acc_dt_sq : signed(95 downto 0) := (others => '0');
  signal chi16_y_acc_dt_sq, chi17_y_acc_dt_sq, chi18_y_acc_dt_sq : signed(95 downto 0) := (others => '0');

  signal chi0_z_acc_dt_sq, chi1_z_acc_dt_sq, chi2_z_acc_dt_sq, chi3_z_acc_dt_sq : signed(95 downto 0) := (others => '0');
  signal chi4_z_acc_dt_sq, chi5_z_acc_dt_sq, chi6_z_acc_dt_sq, chi7_z_acc_dt_sq : signed(95 downto 0) := (others => '0');
  signal chi8_z_acc_dt_sq, chi9_z_acc_dt_sq, chi10_z_acc_dt_sq, chi11_z_acc_dt_sq : signed(95 downto 0) := (others => '0');
  signal chi12_z_acc_dt_sq, chi13_z_acc_dt_sq, chi14_z_acc_dt_sq, chi15_z_acc_dt_sq : signed(95 downto 0) := (others => '0');
  signal chi16_z_acc_dt_sq, chi17_z_acc_dt_sq, chi18_z_acc_dt_sq : signed(95 downto 0) := (others => '0');

  signal chi0_x_pos_pred_int, chi0_x_vel_pred_int, chi0_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi0_y_pos_pred_int, chi0_y_vel_pred_int, chi0_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi0_z_pos_pred_int, chi0_z_vel_pred_int, chi0_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi1_x_pos_pred_int, chi1_x_vel_pred_int, chi1_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi1_y_pos_pred_int, chi1_y_vel_pred_int, chi1_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi1_z_pos_pred_int, chi1_z_vel_pred_int, chi1_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi2_x_pos_pred_int, chi2_x_vel_pred_int, chi2_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi2_y_pos_pred_int, chi2_y_vel_pred_int, chi2_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi2_z_pos_pred_int, chi2_z_vel_pred_int, chi2_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi3_x_pos_pred_int, chi3_x_vel_pred_int, chi3_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi3_y_pos_pred_int, chi3_y_vel_pred_int, chi3_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi3_z_pos_pred_int, chi3_z_vel_pred_int, chi3_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi4_x_pos_pred_int, chi4_x_vel_pred_int, chi4_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi4_y_pos_pred_int, chi4_y_vel_pred_int, chi4_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi4_z_pos_pred_int, chi4_z_vel_pred_int, chi4_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi5_x_pos_pred_int, chi5_x_vel_pred_int, chi5_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi5_y_pos_pred_int, chi5_y_vel_pred_int, chi5_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi5_z_pos_pred_int, chi5_z_vel_pred_int, chi5_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi6_x_pos_pred_int, chi6_x_vel_pred_int, chi6_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi6_y_pos_pred_int, chi6_y_vel_pred_int, chi6_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi6_z_pos_pred_int, chi6_z_vel_pred_int, chi6_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi7_x_pos_pred_int, chi7_x_vel_pred_int, chi7_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi7_y_pos_pred_int, chi7_y_vel_pred_int, chi7_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi7_z_pos_pred_int, chi7_z_vel_pred_int, chi7_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi8_x_pos_pred_int, chi8_x_vel_pred_int, chi8_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi8_y_pos_pred_int, chi8_y_vel_pred_int, chi8_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi8_z_pos_pred_int, chi8_z_vel_pred_int, chi8_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi9_x_pos_pred_int, chi9_x_vel_pred_int, chi9_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi9_y_pos_pred_int, chi9_y_vel_pred_int, chi9_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi9_z_pos_pred_int, chi9_z_vel_pred_int, chi9_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi10_x_pos_pred_int, chi10_x_vel_pred_int, chi10_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi10_y_pos_pred_int, chi10_y_vel_pred_int, chi10_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi10_z_pos_pred_int, chi10_z_vel_pred_int, chi10_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi11_x_pos_pred_int, chi11_x_vel_pred_int, chi11_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi11_y_pos_pred_int, chi11_y_vel_pred_int, chi11_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi11_z_pos_pred_int, chi11_z_vel_pred_int, chi11_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi12_x_pos_pred_int, chi12_x_vel_pred_int, chi12_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi12_y_pos_pred_int, chi12_y_vel_pred_int, chi12_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi12_z_pos_pred_int, chi12_z_vel_pred_int, chi12_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi13_x_pos_pred_int, chi13_x_vel_pred_int, chi13_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi13_y_pos_pred_int, chi13_y_vel_pred_int, chi13_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi13_z_pos_pred_int, chi13_z_vel_pred_int, chi13_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi14_x_pos_pred_int, chi14_x_vel_pred_int, chi14_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi14_y_pos_pred_int, chi14_y_vel_pred_int, chi14_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi14_z_pos_pred_int, chi14_z_vel_pred_int, chi14_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi15_x_pos_pred_int, chi15_x_vel_pred_int, chi15_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi15_y_pos_pred_int, chi15_y_vel_pred_int, chi15_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi15_z_pos_pred_int, chi15_z_vel_pred_int, chi15_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi16_x_pos_pred_int, chi16_x_vel_pred_int, chi16_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi16_y_pos_pred_int, chi16_y_vel_pred_int, chi16_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi16_z_pos_pred_int, chi16_z_vel_pred_int, chi16_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi17_x_pos_pred_int, chi17_x_vel_pred_int, chi17_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi17_y_pos_pred_int, chi17_y_vel_pred_int, chi17_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi17_z_pos_pred_int, chi17_z_vel_pred_int, chi17_z_acc_pred_int : signed(47 downto 0) := (others => '0');

  signal chi18_x_pos_pred_int, chi18_x_vel_pred_int, chi18_x_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi18_y_pos_pred_int, chi18_y_vel_pred_int, chi18_y_acc_pred_int : signed(47 downto 0) := (others => '0');
  signal chi18_z_pos_pred_int, chi18_z_vel_pred_int, chi18_z_acc_pred_int : signed(47 downto 0) := (others => '0');

begin

  process(clk, rst)
  begin
    if rst = '1' then
      state <= IDLE;
      done <= '0';

      chi0_x_vel_dt <= (others => '0'); chi1_x_vel_dt <= (others => '0'); chi2_x_vel_dt <= (others => '0');
      chi3_x_vel_dt <= (others => '0'); chi4_x_vel_dt <= (others => '0'); chi5_x_vel_dt <= (others => '0');
      chi6_x_vel_dt <= (others => '0'); chi7_x_vel_dt <= (others => '0'); chi8_x_vel_dt <= (others => '0');
      chi9_x_vel_dt <= (others => '0'); chi10_x_vel_dt <= (others => '0'); chi11_x_vel_dt <= (others => '0');
      chi12_x_vel_dt <= (others => '0'); chi13_x_vel_dt <= (others => '0'); chi14_x_vel_dt <= (others => '0');
      chi15_x_vel_dt <= (others => '0'); chi16_x_vel_dt <= (others => '0'); chi17_x_vel_dt <= (others => '0');
      chi18_x_vel_dt <= (others => '0');

      chi0_y_vel_dt <= (others => '0'); chi1_y_vel_dt <= (others => '0'); chi2_y_vel_dt <= (others => '0');
      chi3_y_vel_dt <= (others => '0'); chi4_y_vel_dt <= (others => '0'); chi5_y_vel_dt <= (others => '0');
      chi6_y_vel_dt <= (others => '0'); chi7_y_vel_dt <= (others => '0'); chi8_y_vel_dt <= (others => '0');
      chi9_y_vel_dt <= (others => '0'); chi10_y_vel_dt <= (others => '0'); chi11_y_vel_dt <= (others => '0');
      chi12_y_vel_dt <= (others => '0'); chi13_y_vel_dt <= (others => '0'); chi14_y_vel_dt <= (others => '0');
      chi15_y_vel_dt <= (others => '0'); chi16_y_vel_dt <= (others => '0'); chi17_y_vel_dt <= (others => '0');
      chi18_y_vel_dt <= (others => '0');

      chi0_z_vel_dt <= (others => '0'); chi1_z_vel_dt <= (others => '0'); chi2_z_vel_dt <= (others => '0');
      chi3_z_vel_dt <= (others => '0'); chi4_z_vel_dt <= (others => '0'); chi5_z_vel_dt <= (others => '0');
      chi6_z_vel_dt <= (others => '0'); chi7_z_vel_dt <= (others => '0'); chi8_z_vel_dt <= (others => '0');
      chi9_z_vel_dt <= (others => '0'); chi10_z_vel_dt <= (others => '0'); chi11_z_vel_dt <= (others => '0');
      chi12_z_vel_dt <= (others => '0'); chi13_z_vel_dt <= (others => '0'); chi14_z_vel_dt <= (others => '0');
      chi15_z_vel_dt <= (others => '0'); chi16_z_vel_dt <= (others => '0'); chi17_z_vel_dt <= (others => '0');
      chi18_z_vel_dt <= (others => '0');

      chi0_x_acc_dt <= (others => '0'); chi1_x_acc_dt <= (others => '0'); chi2_x_acc_dt <= (others => '0');
      chi3_x_acc_dt <= (others => '0'); chi4_x_acc_dt <= (others => '0'); chi5_x_acc_dt <= (others => '0');
      chi6_x_acc_dt <= (others => '0'); chi7_x_acc_dt <= (others => '0'); chi8_x_acc_dt <= (others => '0');
      chi9_x_acc_dt <= (others => '0'); chi10_x_acc_dt <= (others => '0'); chi11_x_acc_dt <= (others => '0');
      chi12_x_acc_dt <= (others => '0'); chi13_x_acc_dt <= (others => '0'); chi14_x_acc_dt <= (others => '0');
      chi15_x_acc_dt <= (others => '0'); chi16_x_acc_dt <= (others => '0'); chi17_x_acc_dt <= (others => '0');
      chi18_x_acc_dt <= (others => '0');

      chi0_y_acc_dt <= (others => '0'); chi1_y_acc_dt <= (others => '0'); chi2_y_acc_dt <= (others => '0');
      chi3_y_acc_dt <= (others => '0'); chi4_y_acc_dt <= (others => '0'); chi5_y_acc_dt <= (others => '0');
      chi6_y_acc_dt <= (others => '0'); chi7_y_acc_dt <= (others => '0'); chi8_y_acc_dt <= (others => '0');
      chi9_y_acc_dt <= (others => '0'); chi10_y_acc_dt <= (others => '0'); chi11_y_acc_dt <= (others => '0');
      chi12_y_acc_dt <= (others => '0'); chi13_y_acc_dt <= (others => '0'); chi14_y_acc_dt <= (others => '0');
      chi15_y_acc_dt <= (others => '0'); chi16_y_acc_dt <= (others => '0'); chi17_y_acc_dt <= (others => '0');
      chi18_y_acc_dt <= (others => '0');

      chi0_z_acc_dt <= (others => '0'); chi1_z_acc_dt <= (others => '0'); chi2_z_acc_dt <= (others => '0');
      chi3_z_acc_dt <= (others => '0'); chi4_z_acc_dt <= (others => '0'); chi5_z_acc_dt <= (others => '0');
      chi6_z_acc_dt <= (others => '0'); chi7_z_acc_dt <= (others => '0'); chi8_z_acc_dt <= (others => '0');
      chi9_z_acc_dt <= (others => '0'); chi10_z_acc_dt <= (others => '0'); chi11_z_acc_dt <= (others => '0');
      chi12_z_acc_dt <= (others => '0'); chi13_z_acc_dt <= (others => '0'); chi14_z_acc_dt <= (others => '0');
      chi15_z_acc_dt <= (others => '0'); chi16_z_acc_dt <= (others => '0'); chi17_z_acc_dt <= (others => '0');
      chi18_z_acc_dt <= (others => '0');

      chi0_x_acc_dt_sq <= (others => '0'); chi1_x_acc_dt_sq <= (others => '0'); chi2_x_acc_dt_sq <= (others => '0');
      chi3_x_acc_dt_sq <= (others => '0'); chi4_x_acc_dt_sq <= (others => '0'); chi5_x_acc_dt_sq <= (others => '0');
      chi6_x_acc_dt_sq <= (others => '0'); chi7_x_acc_dt_sq <= (others => '0'); chi8_x_acc_dt_sq <= (others => '0');
      chi9_x_acc_dt_sq <= (others => '0'); chi10_x_acc_dt_sq <= (others => '0'); chi11_x_acc_dt_sq <= (others => '0');
      chi12_x_acc_dt_sq <= (others => '0'); chi13_x_acc_dt_sq <= (others => '0'); chi14_x_acc_dt_sq <= (others => '0');
      chi15_x_acc_dt_sq <= (others => '0'); chi16_x_acc_dt_sq <= (others => '0'); chi17_x_acc_dt_sq <= (others => '0');
      chi18_x_acc_dt_sq <= (others => '0');

      chi0_y_acc_dt_sq <= (others => '0'); chi1_y_acc_dt_sq <= (others => '0'); chi2_y_acc_dt_sq <= (others => '0');
      chi3_y_acc_dt_sq <= (others => '0'); chi4_y_acc_dt_sq <= (others => '0'); chi5_y_acc_dt_sq <= (others => '0');
      chi6_y_acc_dt_sq <= (others => '0'); chi7_y_acc_dt_sq <= (others => '0'); chi8_y_acc_dt_sq <= (others => '0');
      chi9_y_acc_dt_sq <= (others => '0'); chi10_y_acc_dt_sq <= (others => '0'); chi11_y_acc_dt_sq <= (others => '0');
      chi12_y_acc_dt_sq <= (others => '0'); chi13_y_acc_dt_sq <= (others => '0'); chi14_y_acc_dt_sq <= (others => '0');
      chi15_y_acc_dt_sq <= (others => '0'); chi16_y_acc_dt_sq <= (others => '0'); chi17_y_acc_dt_sq <= (others => '0');
      chi18_y_acc_dt_sq <= (others => '0');

      chi0_z_acc_dt_sq <= (others => '0'); chi1_z_acc_dt_sq <= (others => '0'); chi2_z_acc_dt_sq <= (others => '0');
      chi3_z_acc_dt_sq <= (others => '0'); chi4_z_acc_dt_sq <= (others => '0'); chi5_z_acc_dt_sq <= (others => '0');
      chi6_z_acc_dt_sq <= (others => '0'); chi7_z_acc_dt_sq <= (others => '0'); chi8_z_acc_dt_sq <= (others => '0');
      chi9_z_acc_dt_sq <= (others => '0'); chi10_z_acc_dt_sq <= (others => '0'); chi11_z_acc_dt_sq <= (others => '0');
      chi12_z_acc_dt_sq <= (others => '0'); chi13_z_acc_dt_sq <= (others => '0'); chi14_z_acc_dt_sq <= (others => '0');
      chi15_z_acc_dt_sq <= (others => '0'); chi16_z_acc_dt_sq <= (others => '0'); chi17_z_acc_dt_sq <= (others => '0');
      chi18_z_acc_dt_sq <= (others => '0');

      chi0_x_pos_pred_int <= (others => '0'); chi0_x_vel_pred_int <= (others => '0'); chi0_x_acc_pred_int <= (others => '0');
      chi0_y_pos_pred_int <= (others => '0'); chi0_y_vel_pred_int <= (others => '0'); chi0_y_acc_pred_int <= (others => '0');
      chi0_z_pos_pred_int <= (others => '0'); chi0_z_vel_pred_int <= (others => '0'); chi0_z_acc_pred_int <= (others => '0');

      chi1_x_pos_pred_int <= (others => '0'); chi1_x_vel_pred_int <= (others => '0'); chi1_x_acc_pred_int <= (others => '0');
      chi1_y_pos_pred_int <= (others => '0'); chi1_y_vel_pred_int <= (others => '0'); chi1_y_acc_pred_int <= (others => '0');
      chi1_z_pos_pred_int <= (others => '0'); chi1_z_vel_pred_int <= (others => '0'); chi1_z_acc_pred_int <= (others => '0');

      chi2_x_pos_pred_int <= (others => '0'); chi2_x_vel_pred_int <= (others => '0'); chi2_x_acc_pred_int <= (others => '0');
      chi2_y_pos_pred_int <= (others => '0'); chi2_y_vel_pred_int <= (others => '0'); chi2_y_acc_pred_int <= (others => '0');
      chi2_z_pos_pred_int <= (others => '0'); chi2_z_vel_pred_int <= (others => '0'); chi2_z_acc_pred_int <= (others => '0');

      chi3_x_pos_pred_int <= (others => '0'); chi3_x_vel_pred_int <= (others => '0'); chi3_x_acc_pred_int <= (others => '0');
      chi3_y_pos_pred_int <= (others => '0'); chi3_y_vel_pred_int <= (others => '0'); chi3_y_acc_pred_int <= (others => '0');
      chi3_z_pos_pred_int <= (others => '0'); chi3_z_vel_pred_int <= (others => '0'); chi3_z_acc_pred_int <= (others => '0');

      chi4_x_pos_pred_int <= (others => '0'); chi4_x_vel_pred_int <= (others => '0'); chi4_x_acc_pred_int <= (others => '0');
      chi4_y_pos_pred_int <= (others => '0'); chi4_y_vel_pred_int <= (others => '0'); chi4_y_acc_pred_int <= (others => '0');
      chi4_z_pos_pred_int <= (others => '0'); chi4_z_vel_pred_int <= (others => '0'); chi4_z_acc_pred_int <= (others => '0');

      chi5_x_pos_pred_int <= (others => '0'); chi5_x_vel_pred_int <= (others => '0'); chi5_x_acc_pred_int <= (others => '0');
      chi5_y_pos_pred_int <= (others => '0'); chi5_y_vel_pred_int <= (others => '0'); chi5_y_acc_pred_int <= (others => '0');
      chi5_z_pos_pred_int <= (others => '0'); chi5_z_vel_pred_int <= (others => '0'); chi5_z_acc_pred_int <= (others => '0');

      chi6_x_pos_pred_int <= (others => '0'); chi6_x_vel_pred_int <= (others => '0'); chi6_x_acc_pred_int <= (others => '0');
      chi6_y_pos_pred_int <= (others => '0'); chi6_y_vel_pred_int <= (others => '0'); chi6_y_acc_pred_int <= (others => '0');
      chi6_z_pos_pred_int <= (others => '0'); chi6_z_vel_pred_int <= (others => '0'); chi6_z_acc_pred_int <= (others => '0');

      chi7_x_pos_pred_int <= (others => '0'); chi7_x_vel_pred_int <= (others => '0'); chi7_x_acc_pred_int <= (others => '0');
      chi7_y_pos_pred_int <= (others => '0'); chi7_y_vel_pred_int <= (others => '0'); chi7_y_acc_pred_int <= (others => '0');
      chi7_z_pos_pred_int <= (others => '0'); chi7_z_vel_pred_int <= (others => '0'); chi7_z_acc_pred_int <= (others => '0');

      chi8_x_pos_pred_int <= (others => '0'); chi8_x_vel_pred_int <= (others => '0'); chi8_x_acc_pred_int <= (others => '0');
      chi8_y_pos_pred_int <= (others => '0'); chi8_y_vel_pred_int <= (others => '0'); chi8_y_acc_pred_int <= (others => '0');
      chi8_z_pos_pred_int <= (others => '0'); chi8_z_vel_pred_int <= (others => '0'); chi8_z_acc_pred_int <= (others => '0');

      chi9_x_pos_pred_int <= (others => '0'); chi9_x_vel_pred_int <= (others => '0'); chi9_x_acc_pred_int <= (others => '0');
      chi9_y_pos_pred_int <= (others => '0'); chi9_y_vel_pred_int <= (others => '0'); chi9_y_acc_pred_int <= (others => '0');
      chi9_z_pos_pred_int <= (others => '0'); chi9_z_vel_pred_int <= (others => '0'); chi9_z_acc_pred_int <= (others => '0');

      chi10_x_pos_pred_int <= (others => '0'); chi10_x_vel_pred_int <= (others => '0'); chi10_x_acc_pred_int <= (others => '0');
      chi10_y_pos_pred_int <= (others => '0'); chi10_y_vel_pred_int <= (others => '0'); chi10_y_acc_pred_int <= (others => '0');
      chi10_z_pos_pred_int <= (others => '0'); chi10_z_vel_pred_int <= (others => '0'); chi10_z_acc_pred_int <= (others => '0');

      chi11_x_pos_pred_int <= (others => '0'); chi11_x_vel_pred_int <= (others => '0'); chi11_x_acc_pred_int <= (others => '0');
      chi11_y_pos_pred_int <= (others => '0'); chi11_y_vel_pred_int <= (others => '0'); chi11_y_acc_pred_int <= (others => '0');
      chi11_z_pos_pred_int <= (others => '0'); chi11_z_vel_pred_int <= (others => '0'); chi11_z_acc_pred_int <= (others => '0');

      chi12_x_pos_pred_int <= (others => '0'); chi12_x_vel_pred_int <= (others => '0'); chi12_x_acc_pred_int <= (others => '0');
      chi12_y_pos_pred_int <= (others => '0'); chi12_y_vel_pred_int <= (others => '0'); chi12_y_acc_pred_int <= (others => '0');
      chi12_z_pos_pred_int <= (others => '0'); chi12_z_vel_pred_int <= (others => '0'); chi12_z_acc_pred_int <= (others => '0');

      chi13_x_pos_pred_int <= (others => '0'); chi13_x_vel_pred_int <= (others => '0'); chi13_x_acc_pred_int <= (others => '0');
      chi13_y_pos_pred_int <= (others => '0'); chi13_y_vel_pred_int <= (others => '0'); chi13_y_acc_pred_int <= (others => '0');
      chi13_z_pos_pred_int <= (others => '0'); chi13_z_vel_pred_int <= (others => '0'); chi13_z_acc_pred_int <= (others => '0');

      chi14_x_pos_pred_int <= (others => '0'); chi14_x_vel_pred_int <= (others => '0'); chi14_x_acc_pred_int <= (others => '0');
      chi14_y_pos_pred_int <= (others => '0'); chi14_y_vel_pred_int <= (others => '0'); chi14_y_acc_pred_int <= (others => '0');
      chi14_z_pos_pred_int <= (others => '0'); chi14_z_vel_pred_int <= (others => '0'); chi14_z_acc_pred_int <= (others => '0');

      chi15_x_pos_pred_int <= (others => '0'); chi15_x_vel_pred_int <= (others => '0'); chi15_x_acc_pred_int <= (others => '0');
      chi15_y_pos_pred_int <= (others => '0'); chi15_y_vel_pred_int <= (others => '0'); chi15_y_acc_pred_int <= (others => '0');
      chi15_z_pos_pred_int <= (others => '0'); chi15_z_vel_pred_int <= (others => '0'); chi15_z_acc_pred_int <= (others => '0');

      chi16_x_pos_pred_int <= (others => '0'); chi16_x_vel_pred_int <= (others => '0'); chi16_x_acc_pred_int <= (others => '0');
      chi16_y_pos_pred_int <= (others => '0'); chi16_y_vel_pred_int <= (others => '0'); chi16_y_acc_pred_int <= (others => '0');
      chi16_z_pos_pred_int <= (others => '0'); chi16_z_vel_pred_int <= (others => '0'); chi16_z_acc_pred_int <= (others => '0');

      chi17_x_pos_pred_int <= (others => '0'); chi17_x_vel_pred_int <= (others => '0'); chi17_x_acc_pred_int <= (others => '0');
      chi17_y_pos_pred_int <= (others => '0'); chi17_y_vel_pred_int <= (others => '0'); chi17_y_acc_pred_int <= (others => '0');
      chi17_z_pos_pred_int <= (others => '0'); chi17_z_vel_pred_int <= (others => '0'); chi17_z_acc_pred_int <= (others => '0');

      chi18_x_pos_pred_int <= (others => '0'); chi18_x_vel_pred_int <= (others => '0'); chi18_x_acc_pred_int <= (others => '0');
      chi18_y_pos_pred_int <= (others => '0'); chi18_y_vel_pred_int <= (others => '0'); chi18_y_acc_pred_int <= (others => '0');
      chi18_z_pos_pred_int <= (others => '0'); chi18_z_vel_pred_int <= (others => '0'); chi18_z_acc_pred_int <= (others => '0');

    elsif rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if start = '1' then
            state <= MULTIPLY_VEL;
          end if;

        when MULTIPLY_VEL =>

          chi0_x_vel_dt <= chi0_x_vel_in * DT_Q24_24;
          chi1_x_vel_dt <= chi1_x_vel_in * DT_Q24_24;
          chi2_x_vel_dt <= chi2_x_vel_in * DT_Q24_24;
          chi3_x_vel_dt <= chi3_x_vel_in * DT_Q24_24;
          chi4_x_vel_dt <= chi4_x_vel_in * DT_Q24_24;
          chi5_x_vel_dt <= chi5_x_vel_in * DT_Q24_24;
          chi6_x_vel_dt <= chi6_x_vel_in * DT_Q24_24;
          chi7_x_vel_dt <= chi7_x_vel_in * DT_Q24_24;
          chi8_x_vel_dt <= chi8_x_vel_in * DT_Q24_24;
          chi9_x_vel_dt <= chi9_x_vel_in * DT_Q24_24;
          chi10_x_vel_dt <= chi10_x_vel_in * DT_Q24_24;
          chi11_x_vel_dt <= chi11_x_vel_in * DT_Q24_24;
          chi12_x_vel_dt <= chi12_x_vel_in * DT_Q24_24;
          chi13_x_vel_dt <= chi13_x_vel_in * DT_Q24_24;
          chi14_x_vel_dt <= chi14_x_vel_in * DT_Q24_24;
          chi15_x_vel_dt <= chi15_x_vel_in * DT_Q24_24;
          chi16_x_vel_dt <= chi16_x_vel_in * DT_Q24_24;
          chi17_x_vel_dt <= chi17_x_vel_in * DT_Q24_24;
          chi18_x_vel_dt <= chi18_x_vel_in * DT_Q24_24;

          chi0_y_vel_dt <= chi0_y_vel_in * DT_Q24_24;
          chi1_y_vel_dt <= chi1_y_vel_in * DT_Q24_24;
          chi2_y_vel_dt <= chi2_y_vel_in * DT_Q24_24;
          chi3_y_vel_dt <= chi3_y_vel_in * DT_Q24_24;
          chi4_y_vel_dt <= chi4_y_vel_in * DT_Q24_24;
          chi5_y_vel_dt <= chi5_y_vel_in * DT_Q24_24;
          chi6_y_vel_dt <= chi6_y_vel_in * DT_Q24_24;
          chi7_y_vel_dt <= chi7_y_vel_in * DT_Q24_24;
          chi8_y_vel_dt <= chi8_y_vel_in * DT_Q24_24;
          chi9_y_vel_dt <= chi9_y_vel_in * DT_Q24_24;
          chi10_y_vel_dt <= chi10_y_vel_in * DT_Q24_24;
          chi11_y_vel_dt <= chi11_y_vel_in * DT_Q24_24;
          chi12_y_vel_dt <= chi12_y_vel_in * DT_Q24_24;
          chi13_y_vel_dt <= chi13_y_vel_in * DT_Q24_24;
          chi14_y_vel_dt <= chi14_y_vel_in * DT_Q24_24;
          chi15_y_vel_dt <= chi15_y_vel_in * DT_Q24_24;
          chi16_y_vel_dt <= chi16_y_vel_in * DT_Q24_24;
          chi17_y_vel_dt <= chi17_y_vel_in * DT_Q24_24;
          chi18_y_vel_dt <= chi18_y_vel_in * DT_Q24_24;

          chi0_z_vel_dt <= chi0_z_vel_in * DT_Q24_24;
          chi1_z_vel_dt <= chi1_z_vel_in * DT_Q24_24;
          chi2_z_vel_dt <= chi2_z_vel_in * DT_Q24_24;
          chi3_z_vel_dt <= chi3_z_vel_in * DT_Q24_24;
          chi4_z_vel_dt <= chi4_z_vel_in * DT_Q24_24;
          chi5_z_vel_dt <= chi5_z_vel_in * DT_Q24_24;
          chi6_z_vel_dt <= chi6_z_vel_in * DT_Q24_24;
          chi7_z_vel_dt <= chi7_z_vel_in * DT_Q24_24;
          chi8_z_vel_dt <= chi8_z_vel_in * DT_Q24_24;
          chi9_z_vel_dt <= chi9_z_vel_in * DT_Q24_24;
          chi10_z_vel_dt <= chi10_z_vel_in * DT_Q24_24;
          chi11_z_vel_dt <= chi11_z_vel_in * DT_Q24_24;
          chi12_z_vel_dt <= chi12_z_vel_in * DT_Q24_24;
          chi13_z_vel_dt <= chi13_z_vel_in * DT_Q24_24;
          chi14_z_vel_dt <= chi14_z_vel_in * DT_Q24_24;
          chi15_z_vel_dt <= chi15_z_vel_in * DT_Q24_24;
          chi16_z_vel_dt <= chi16_z_vel_in * DT_Q24_24;
          chi17_z_vel_dt <= chi17_z_vel_in * DT_Q24_24;
          chi18_z_vel_dt <= chi18_z_vel_in * DT_Q24_24;

          state <= MULTIPLY_ACC;

        when MULTIPLY_ACC =>

          chi0_x_acc_dt <= chi0_x_acc_in * DT_Q24_24; chi0_x_acc_dt_sq <= chi0_x_acc_in * DT_SQ_Q24_24;
          chi1_x_acc_dt <= chi1_x_acc_in * DT_Q24_24; chi1_x_acc_dt_sq <= chi1_x_acc_in * DT_SQ_Q24_24;
          chi2_x_acc_dt <= chi2_x_acc_in * DT_Q24_24; chi2_x_acc_dt_sq <= chi2_x_acc_in * DT_SQ_Q24_24;
          chi3_x_acc_dt <= chi3_x_acc_in * DT_Q24_24; chi3_x_acc_dt_sq <= chi3_x_acc_in * DT_SQ_Q24_24;
          chi4_x_acc_dt <= chi4_x_acc_in * DT_Q24_24; chi4_x_acc_dt_sq <= chi4_x_acc_in * DT_SQ_Q24_24;
          chi5_x_acc_dt <= chi5_x_acc_in * DT_Q24_24; chi5_x_acc_dt_sq <= chi5_x_acc_in * DT_SQ_Q24_24;
          chi6_x_acc_dt <= chi6_x_acc_in * DT_Q24_24; chi6_x_acc_dt_sq <= chi6_x_acc_in * DT_SQ_Q24_24;
          chi7_x_acc_dt <= chi7_x_acc_in * DT_Q24_24; chi7_x_acc_dt_sq <= chi7_x_acc_in * DT_SQ_Q24_24;
          chi8_x_acc_dt <= chi8_x_acc_in * DT_Q24_24; chi8_x_acc_dt_sq <= chi8_x_acc_in * DT_SQ_Q24_24;
          chi9_x_acc_dt <= chi9_x_acc_in * DT_Q24_24; chi9_x_acc_dt_sq <= chi9_x_acc_in * DT_SQ_Q24_24;
          chi10_x_acc_dt <= chi10_x_acc_in * DT_Q24_24; chi10_x_acc_dt_sq <= chi10_x_acc_in * DT_SQ_Q24_24;
          chi11_x_acc_dt <= chi11_x_acc_in * DT_Q24_24; chi11_x_acc_dt_sq <= chi11_x_acc_in * DT_SQ_Q24_24;
          chi12_x_acc_dt <= chi12_x_acc_in * DT_Q24_24; chi12_x_acc_dt_sq <= chi12_x_acc_in * DT_SQ_Q24_24;
          chi13_x_acc_dt <= chi13_x_acc_in * DT_Q24_24; chi13_x_acc_dt_sq <= chi13_x_acc_in * DT_SQ_Q24_24;
          chi14_x_acc_dt <= chi14_x_acc_in * DT_Q24_24; chi14_x_acc_dt_sq <= chi14_x_acc_in * DT_SQ_Q24_24;
          chi15_x_acc_dt <= chi15_x_acc_in * DT_Q24_24; chi15_x_acc_dt_sq <= chi15_x_acc_in * DT_SQ_Q24_24;
          chi16_x_acc_dt <= chi16_x_acc_in * DT_Q24_24; chi16_x_acc_dt_sq <= chi16_x_acc_in * DT_SQ_Q24_24;
          chi17_x_acc_dt <= chi17_x_acc_in * DT_Q24_24; chi17_x_acc_dt_sq <= chi17_x_acc_in * DT_SQ_Q24_24;
          chi18_x_acc_dt <= chi18_x_acc_in * DT_Q24_24; chi18_x_acc_dt_sq <= chi18_x_acc_in * DT_SQ_Q24_24;

          chi0_y_acc_dt <= chi0_y_acc_in * DT_Q24_24; chi0_y_acc_dt_sq <= chi0_y_acc_in * DT_SQ_Q24_24;
          chi1_y_acc_dt <= chi1_y_acc_in * DT_Q24_24; chi1_y_acc_dt_sq <= chi1_y_acc_in * DT_SQ_Q24_24;
          chi2_y_acc_dt <= chi2_y_acc_in * DT_Q24_24; chi2_y_acc_dt_sq <= chi2_y_acc_in * DT_SQ_Q24_24;
          chi3_y_acc_dt <= chi3_y_acc_in * DT_Q24_24; chi3_y_acc_dt_sq <= chi3_y_acc_in * DT_SQ_Q24_24;
          chi4_y_acc_dt <= chi4_y_acc_in * DT_Q24_24; chi4_y_acc_dt_sq <= chi4_y_acc_in * DT_SQ_Q24_24;
          chi5_y_acc_dt <= chi5_y_acc_in * DT_Q24_24; chi5_y_acc_dt_sq <= chi5_y_acc_in * DT_SQ_Q24_24;
          chi6_y_acc_dt <= chi6_y_acc_in * DT_Q24_24; chi6_y_acc_dt_sq <= chi6_y_acc_in * DT_SQ_Q24_24;
          chi7_y_acc_dt <= chi7_y_acc_in * DT_Q24_24; chi7_y_acc_dt_sq <= chi7_y_acc_in * DT_SQ_Q24_24;
          chi8_y_acc_dt <= chi8_y_acc_in * DT_Q24_24; chi8_y_acc_dt_sq <= chi8_y_acc_in * DT_SQ_Q24_24;
          chi9_y_acc_dt <= chi9_y_acc_in * DT_Q24_24; chi9_y_acc_dt_sq <= chi9_y_acc_in * DT_SQ_Q24_24;
          chi10_y_acc_dt <= chi10_y_acc_in * DT_Q24_24; chi10_y_acc_dt_sq <= chi10_y_acc_in * DT_SQ_Q24_24;
          chi11_y_acc_dt <= chi11_y_acc_in * DT_Q24_24; chi11_y_acc_dt_sq <= chi11_y_acc_in * DT_SQ_Q24_24;
          chi12_y_acc_dt <= chi12_y_acc_in * DT_Q24_24; chi12_y_acc_dt_sq <= chi12_y_acc_in * DT_SQ_Q24_24;
          chi13_y_acc_dt <= chi13_y_acc_in * DT_Q24_24; chi13_y_acc_dt_sq <= chi13_y_acc_in * DT_SQ_Q24_24;
          chi14_y_acc_dt <= chi14_y_acc_in * DT_Q24_24; chi14_y_acc_dt_sq <= chi14_y_acc_in * DT_SQ_Q24_24;
          chi15_y_acc_dt <= chi15_y_acc_in * DT_Q24_24; chi15_y_acc_dt_sq <= chi15_y_acc_in * DT_SQ_Q24_24;
          chi16_y_acc_dt <= chi16_y_acc_in * DT_Q24_24; chi16_y_acc_dt_sq <= chi16_y_acc_in * DT_SQ_Q24_24;
          chi17_y_acc_dt <= chi17_y_acc_in * DT_Q24_24; chi17_y_acc_dt_sq <= chi17_y_acc_in * DT_SQ_Q24_24;
          chi18_y_acc_dt <= chi18_y_acc_in * DT_Q24_24; chi18_y_acc_dt_sq <= chi18_y_acc_in * DT_SQ_Q24_24;

          chi0_z_acc_dt <= chi0_z_acc_in * DT_Q24_24; chi0_z_acc_dt_sq <= chi0_z_acc_in * DT_SQ_Q24_24;
          chi1_z_acc_dt <= chi1_z_acc_in * DT_Q24_24; chi1_z_acc_dt_sq <= chi1_z_acc_in * DT_SQ_Q24_24;
          chi2_z_acc_dt <= chi2_z_acc_in * DT_Q24_24; chi2_z_acc_dt_sq <= chi2_z_acc_in * DT_SQ_Q24_24;
          chi3_z_acc_dt <= chi3_z_acc_in * DT_Q24_24; chi3_z_acc_dt_sq <= chi3_z_acc_in * DT_SQ_Q24_24;
          chi4_z_acc_dt <= chi4_z_acc_in * DT_Q24_24; chi4_z_acc_dt_sq <= chi4_z_acc_in * DT_SQ_Q24_24;
          chi5_z_acc_dt <= chi5_z_acc_in * DT_Q24_24; chi5_z_acc_dt_sq <= chi5_z_acc_in * DT_SQ_Q24_24;
          chi6_z_acc_dt <= chi6_z_acc_in * DT_Q24_24; chi6_z_acc_dt_sq <= chi6_z_acc_in * DT_SQ_Q24_24;
          chi7_z_acc_dt <= chi7_z_acc_in * DT_Q24_24; chi7_z_acc_dt_sq <= chi7_z_acc_in * DT_SQ_Q24_24;
          chi8_z_acc_dt <= chi8_z_acc_in * DT_Q24_24; chi8_z_acc_dt_sq <= chi8_z_acc_in * DT_SQ_Q24_24;
          chi9_z_acc_dt <= chi9_z_acc_in * DT_Q24_24; chi9_z_acc_dt_sq <= chi9_z_acc_in * DT_SQ_Q24_24;
          chi10_z_acc_dt <= chi10_z_acc_in * DT_Q24_24; chi10_z_acc_dt_sq <= chi10_z_acc_in * DT_SQ_Q24_24;
          chi11_z_acc_dt <= chi11_z_acc_in * DT_Q24_24; chi11_z_acc_dt_sq <= chi11_z_acc_in * DT_SQ_Q24_24;
          chi12_z_acc_dt <= chi12_z_acc_in * DT_Q24_24; chi12_z_acc_dt_sq <= chi12_z_acc_in * DT_SQ_Q24_24;
          chi13_z_acc_dt <= chi13_z_acc_in * DT_Q24_24; chi13_z_acc_dt_sq <= chi13_z_acc_in * DT_SQ_Q24_24;
          chi14_z_acc_dt <= chi14_z_acc_in * DT_Q24_24; chi14_z_acc_dt_sq <= chi14_z_acc_in * DT_SQ_Q24_24;
          chi15_z_acc_dt <= chi15_z_acc_in * DT_Q24_24; chi15_z_acc_dt_sq <= chi15_z_acc_in * DT_SQ_Q24_24;
          chi16_z_acc_dt <= chi16_z_acc_in * DT_Q24_24; chi16_z_acc_dt_sq <= chi16_z_acc_in * DT_SQ_Q24_24;
          chi17_z_acc_dt <= chi17_z_acc_in * DT_Q24_24; chi17_z_acc_dt_sq <= chi17_z_acc_in * DT_SQ_Q24_24;
          chi18_z_acc_dt <= chi18_z_acc_in * DT_Q24_24; chi18_z_acc_dt_sq <= chi18_z_acc_in * DT_SQ_Q24_24;

          state <= CALCULATE;

        when CALCULATE =>

          chi0_x_pos_pred_int <= chi0_x_pos_in +
                                 resize(shift_right(chi0_x_vel_dt, Q), 48) +
                                 resize(shift_right(resize(HALF_Q24_24 * chi0_x_acc_dt_sq, 96), 2*Q), 48);
          chi0_x_vel_pred_int <= chi0_x_vel_in + resize(shift_right(chi0_x_acc_dt, Q), 48);
          chi0_x_acc_pred_int <= chi0_x_acc_in;

          chi0_y_pos_pred_int <= chi0_y_pos_in +
                                 resize(shift_right(chi0_y_vel_dt, Q), 48) +
                                 resize(shift_right(resize(HALF_Q24_24 * chi0_y_acc_dt_sq, 96), 2*Q), 48);
          chi0_y_vel_pred_int <= chi0_y_vel_in + resize(shift_right(chi0_y_acc_dt, Q), 48);
          chi0_y_acc_pred_int <= chi0_y_acc_in;

          chi0_z_pos_pred_int <= chi0_z_pos_in +
                                 resize(shift_right(chi0_z_vel_dt, Q), 48) +
                                 resize(shift_right(resize(HALF_Q24_24 * chi0_z_acc_dt_sq, 96), 2*Q), 48);
          chi0_z_vel_pred_int <= chi0_z_vel_in + resize(shift_right(chi0_z_acc_dt, Q), 48);
          chi0_z_acc_pred_int <= chi0_z_acc_in;

          chi1_x_pos_pred_int <= chi1_x_pos_in + resize(shift_right(chi1_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi1_x_acc_dt_sq, 96), 2*Q), 48);
          chi1_x_vel_pred_int <= chi1_x_vel_in + resize(shift_right(chi1_x_acc_dt, Q), 48);
          chi1_x_acc_pred_int <= chi1_x_acc_in;
          chi1_y_pos_pred_int <= chi1_y_pos_in + resize(shift_right(chi1_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi1_y_acc_dt_sq, 96), 2*Q), 48);
          chi1_y_vel_pred_int <= chi1_y_vel_in + resize(shift_right(chi1_y_acc_dt, Q), 48);
          chi1_y_acc_pred_int <= chi1_y_acc_in;
          chi1_z_pos_pred_int <= chi1_z_pos_in + resize(shift_right(chi1_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi1_z_acc_dt_sq, 96), 2*Q), 48);
          chi1_z_vel_pred_int <= chi1_z_vel_in + resize(shift_right(chi1_z_acc_dt, Q), 48);
          chi1_z_acc_pred_int <= chi1_z_acc_in;

          chi2_x_pos_pred_int <= chi2_x_pos_in + resize(shift_right(chi2_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi2_x_acc_dt_sq, 96), 2*Q), 48);
          chi2_x_vel_pred_int <= chi2_x_vel_in + resize(shift_right(chi2_x_acc_dt, Q), 48);
          chi2_x_acc_pred_int <= chi2_x_acc_in;
          chi2_y_pos_pred_int <= chi2_y_pos_in + resize(shift_right(chi2_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi2_y_acc_dt_sq, 96), 2*Q), 48);
          chi2_y_vel_pred_int <= chi2_y_vel_in + resize(shift_right(chi2_y_acc_dt, Q), 48);
          chi2_y_acc_pred_int <= chi2_y_acc_in;
          chi2_z_pos_pred_int <= chi2_z_pos_in + resize(shift_right(chi2_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi2_z_acc_dt_sq, 96), 2*Q), 48);
          chi2_z_vel_pred_int <= chi2_z_vel_in + resize(shift_right(chi2_z_acc_dt, Q), 48);
          chi2_z_acc_pred_int <= chi2_z_acc_in;

          chi3_x_pos_pred_int <= chi3_x_pos_in + resize(shift_right(chi3_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi3_x_acc_dt_sq, 96), 2*Q), 48);
          chi3_x_vel_pred_int <= chi3_x_vel_in + resize(shift_right(chi3_x_acc_dt, Q), 48);
          chi3_x_acc_pred_int <= chi3_x_acc_in;
          chi3_y_pos_pred_int <= chi3_y_pos_in + resize(shift_right(chi3_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi3_y_acc_dt_sq, 96), 2*Q), 48);
          chi3_y_vel_pred_int <= chi3_y_vel_in + resize(shift_right(chi3_y_acc_dt, Q), 48);
          chi3_y_acc_pred_int <= chi3_y_acc_in;
          chi3_z_pos_pred_int <= chi3_z_pos_in + resize(shift_right(chi3_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi3_z_acc_dt_sq, 96), 2*Q), 48);
          chi3_z_vel_pred_int <= chi3_z_vel_in + resize(shift_right(chi3_z_acc_dt, Q), 48);
          chi3_z_acc_pred_int <= chi3_z_acc_in;

          chi4_x_pos_pred_int <= chi4_x_pos_in + resize(shift_right(chi4_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi4_x_acc_dt_sq, 96), 2*Q), 48);
          chi4_x_vel_pred_int <= chi4_x_vel_in + resize(shift_right(chi4_x_acc_dt, Q), 48);
          chi4_x_acc_pred_int <= chi4_x_acc_in;
          chi4_y_pos_pred_int <= chi4_y_pos_in + resize(shift_right(chi4_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi4_y_acc_dt_sq, 96), 2*Q), 48);
          chi4_y_vel_pred_int <= chi4_y_vel_in + resize(shift_right(chi4_y_acc_dt, Q), 48);
          chi4_y_acc_pred_int <= chi4_y_acc_in;
          chi4_z_pos_pred_int <= chi4_z_pos_in + resize(shift_right(chi4_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi4_z_acc_dt_sq, 96), 2*Q), 48);
          chi4_z_vel_pred_int <= chi4_z_vel_in + resize(shift_right(chi4_z_acc_dt, Q), 48);
          chi4_z_acc_pred_int <= chi4_z_acc_in;

          chi5_x_pos_pred_int <= chi5_x_pos_in + resize(shift_right(chi5_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi5_x_acc_dt_sq, 96), 2*Q), 48);
          chi5_x_vel_pred_int <= chi5_x_vel_in + resize(shift_right(chi5_x_acc_dt, Q), 48);
          chi5_x_acc_pred_int <= chi5_x_acc_in;
          chi5_y_pos_pred_int <= chi5_y_pos_in + resize(shift_right(chi5_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi5_y_acc_dt_sq, 96), 2*Q), 48);
          chi5_y_vel_pred_int <= chi5_y_vel_in + resize(shift_right(chi5_y_acc_dt, Q), 48);
          chi5_y_acc_pred_int <= chi5_y_acc_in;
          chi5_z_pos_pred_int <= chi5_z_pos_in + resize(shift_right(chi5_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi5_z_acc_dt_sq, 96), 2*Q), 48);
          chi5_z_vel_pred_int <= chi5_z_vel_in + resize(shift_right(chi5_z_acc_dt, Q), 48);
          chi5_z_acc_pred_int <= chi5_z_acc_in;

          chi6_x_pos_pred_int <= chi6_x_pos_in + resize(shift_right(chi6_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi6_x_acc_dt_sq, 96), 2*Q), 48);
          chi6_x_vel_pred_int <= chi6_x_vel_in + resize(shift_right(chi6_x_acc_dt, Q), 48);
          chi6_x_acc_pred_int <= chi6_x_acc_in;
          chi6_y_pos_pred_int <= chi6_y_pos_in + resize(shift_right(chi6_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi6_y_acc_dt_sq, 96), 2*Q), 48);
          chi6_y_vel_pred_int <= chi6_y_vel_in + resize(shift_right(chi6_y_acc_dt, Q), 48);
          chi6_y_acc_pred_int <= chi6_y_acc_in;
          chi6_z_pos_pred_int <= chi6_z_pos_in + resize(shift_right(chi6_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi6_z_acc_dt_sq, 96), 2*Q), 48);
          chi6_z_vel_pred_int <= chi6_z_vel_in + resize(shift_right(chi6_z_acc_dt, Q), 48);
          chi6_z_acc_pred_int <= chi6_z_acc_in;

          chi7_x_pos_pred_int <= chi7_x_pos_in + resize(shift_right(chi7_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi7_x_acc_dt_sq, 96), 2*Q), 48);
          chi7_x_vel_pred_int <= chi7_x_vel_in + resize(shift_right(chi7_x_acc_dt, Q), 48);
          chi7_x_acc_pred_int <= chi7_x_acc_in;
          chi7_y_pos_pred_int <= chi7_y_pos_in + resize(shift_right(chi7_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi7_y_acc_dt_sq, 96), 2*Q), 48);
          chi7_y_vel_pred_int <= chi7_y_vel_in + resize(shift_right(chi7_y_acc_dt, Q), 48);
          chi7_y_acc_pred_int <= chi7_y_acc_in;
          chi7_z_pos_pred_int <= chi7_z_pos_in + resize(shift_right(chi7_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi7_z_acc_dt_sq, 96), 2*Q), 48);
          chi7_z_vel_pred_int <= chi7_z_vel_in + resize(shift_right(chi7_z_acc_dt, Q), 48);
          chi7_z_acc_pred_int <= chi7_z_acc_in;

          chi8_x_pos_pred_int <= chi8_x_pos_in + resize(shift_right(chi8_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi8_x_acc_dt_sq, 96), 2*Q), 48);
          chi8_x_vel_pred_int <= chi8_x_vel_in + resize(shift_right(chi8_x_acc_dt, Q), 48);
          chi8_x_acc_pred_int <= chi8_x_acc_in;
          chi8_y_pos_pred_int <= chi8_y_pos_in + resize(shift_right(chi8_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi8_y_acc_dt_sq, 96), 2*Q), 48);
          chi8_y_vel_pred_int <= chi8_y_vel_in + resize(shift_right(chi8_y_acc_dt, Q), 48);
          chi8_y_acc_pred_int <= chi8_y_acc_in;
          chi8_z_pos_pred_int <= chi8_z_pos_in + resize(shift_right(chi8_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi8_z_acc_dt_sq, 96), 2*Q), 48);
          chi8_z_vel_pred_int <= chi8_z_vel_in + resize(shift_right(chi8_z_acc_dt, Q), 48);
          chi8_z_acc_pred_int <= chi8_z_acc_in;

          chi9_x_pos_pred_int <= chi9_x_pos_in + resize(shift_right(chi9_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi9_x_acc_dt_sq, 96), 2*Q), 48);
          chi9_x_vel_pred_int <= chi9_x_vel_in + resize(shift_right(chi9_x_acc_dt, Q), 48);
          chi9_x_acc_pred_int <= chi9_x_acc_in;
          chi9_y_pos_pred_int <= chi9_y_pos_in + resize(shift_right(chi9_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi9_y_acc_dt_sq, 96), 2*Q), 48);
          chi9_y_vel_pred_int <= chi9_y_vel_in + resize(shift_right(chi9_y_acc_dt, Q), 48);
          chi9_y_acc_pred_int <= chi9_y_acc_in;
          chi9_z_pos_pred_int <= chi9_z_pos_in + resize(shift_right(chi9_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi9_z_acc_dt_sq, 96), 2*Q), 48);
          chi9_z_vel_pred_int <= chi9_z_vel_in + resize(shift_right(chi9_z_acc_dt, Q), 48);
          chi9_z_acc_pred_int <= chi9_z_acc_in;

          chi10_x_pos_pred_int <= chi10_x_pos_in + resize(shift_right(chi10_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi10_x_acc_dt_sq, 96), 2*Q), 48);
          chi10_x_vel_pred_int <= chi10_x_vel_in + resize(shift_right(chi10_x_acc_dt, Q), 48);
          chi10_x_acc_pred_int <= chi10_x_acc_in;
          chi10_y_pos_pred_int <= chi10_y_pos_in + resize(shift_right(chi10_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi10_y_acc_dt_sq, 96), 2*Q), 48);
          chi10_y_vel_pred_int <= chi10_y_vel_in + resize(shift_right(chi10_y_acc_dt, Q), 48);
          chi10_y_acc_pred_int <= chi10_y_acc_in;
          chi10_z_pos_pred_int <= chi10_z_pos_in + resize(shift_right(chi10_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi10_z_acc_dt_sq, 96), 2*Q), 48);
          chi10_z_vel_pred_int <= chi10_z_vel_in + resize(shift_right(chi10_z_acc_dt, Q), 48);
          chi10_z_acc_pred_int <= chi10_z_acc_in;

          chi11_x_pos_pred_int <= chi11_x_pos_in + resize(shift_right(chi11_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi11_x_acc_dt_sq, 96), 2*Q), 48);
          chi11_x_vel_pred_int <= chi11_x_vel_in + resize(shift_right(chi11_x_acc_dt, Q), 48);
          chi11_x_acc_pred_int <= chi11_x_acc_in;
          chi11_y_pos_pred_int <= chi11_y_pos_in + resize(shift_right(chi11_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi11_y_acc_dt_sq, 96), 2*Q), 48);
          chi11_y_vel_pred_int <= chi11_y_vel_in + resize(shift_right(chi11_y_acc_dt, Q), 48);
          chi11_y_acc_pred_int <= chi11_y_acc_in;
          chi11_z_pos_pred_int <= chi11_z_pos_in + resize(shift_right(chi11_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi11_z_acc_dt_sq, 96), 2*Q), 48);
          chi11_z_vel_pred_int <= chi11_z_vel_in + resize(shift_right(chi11_z_acc_dt, Q), 48);
          chi11_z_acc_pred_int <= chi11_z_acc_in;

          chi12_x_pos_pred_int <= chi12_x_pos_in + resize(shift_right(chi12_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi12_x_acc_dt_sq, 96), 2*Q), 48);
          chi12_x_vel_pred_int <= chi12_x_vel_in + resize(shift_right(chi12_x_acc_dt, Q), 48);
          chi12_x_acc_pred_int <= chi12_x_acc_in;
          chi12_y_pos_pred_int <= chi12_y_pos_in + resize(shift_right(chi12_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi12_y_acc_dt_sq, 96), 2*Q), 48);
          chi12_y_vel_pred_int <= chi12_y_vel_in + resize(shift_right(chi12_y_acc_dt, Q), 48);
          chi12_y_acc_pred_int <= chi12_y_acc_in;
          chi12_z_pos_pred_int <= chi12_z_pos_in + resize(shift_right(chi12_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi12_z_acc_dt_sq, 96), 2*Q), 48);
          chi12_z_vel_pred_int <= chi12_z_vel_in + resize(shift_right(chi12_z_acc_dt, Q), 48);
          chi12_z_acc_pred_int <= chi12_z_acc_in;

          chi13_x_pos_pred_int <= chi13_x_pos_in + resize(shift_right(chi13_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi13_x_acc_dt_sq, 96), 2*Q), 48);
          chi13_x_vel_pred_int <= chi13_x_vel_in + resize(shift_right(chi13_x_acc_dt, Q), 48);
          chi13_x_acc_pred_int <= chi13_x_acc_in;
          chi13_y_pos_pred_int <= chi13_y_pos_in + resize(shift_right(chi13_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi13_y_acc_dt_sq, 96), 2*Q), 48);
          chi13_y_vel_pred_int <= chi13_y_vel_in + resize(shift_right(chi13_y_acc_dt, Q), 48);
          chi13_y_acc_pred_int <= chi13_y_acc_in;
          chi13_z_pos_pred_int <= chi13_z_pos_in + resize(shift_right(chi13_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi13_z_acc_dt_sq, 96), 2*Q), 48);
          chi13_z_vel_pred_int <= chi13_z_vel_in + resize(shift_right(chi13_z_acc_dt, Q), 48);
          chi13_z_acc_pred_int <= chi13_z_acc_in;

          chi14_x_pos_pred_int <= chi14_x_pos_in + resize(shift_right(chi14_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi14_x_acc_dt_sq, 96), 2*Q), 48);
          chi14_x_vel_pred_int <= chi14_x_vel_in + resize(shift_right(chi14_x_acc_dt, Q), 48);
          chi14_x_acc_pred_int <= chi14_x_acc_in;
          chi14_y_pos_pred_int <= chi14_y_pos_in + resize(shift_right(chi14_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi14_y_acc_dt_sq, 96), 2*Q), 48);
          chi14_y_vel_pred_int <= chi14_y_vel_in + resize(shift_right(chi14_y_acc_dt, Q), 48);
          chi14_y_acc_pred_int <= chi14_y_acc_in;
          chi14_z_pos_pred_int <= chi14_z_pos_in + resize(shift_right(chi14_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi14_z_acc_dt_sq, 96), 2*Q), 48);
          chi14_z_vel_pred_int <= chi14_z_vel_in + resize(shift_right(chi14_z_acc_dt, Q), 48);
          chi14_z_acc_pred_int <= chi14_z_acc_in;

          chi15_x_pos_pred_int <= chi15_x_pos_in + resize(shift_right(chi15_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi15_x_acc_dt_sq, 96), 2*Q), 48);
          chi15_x_vel_pred_int <= chi15_x_vel_in + resize(shift_right(chi15_x_acc_dt, Q), 48);
          chi15_x_acc_pred_int <= chi15_x_acc_in;
          chi15_y_pos_pred_int <= chi15_y_pos_in + resize(shift_right(chi15_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi15_y_acc_dt_sq, 96), 2*Q), 48);
          chi15_y_vel_pred_int <= chi15_y_vel_in + resize(shift_right(chi15_y_acc_dt, Q), 48);
          chi15_y_acc_pred_int <= chi15_y_acc_in;
          chi15_z_pos_pred_int <= chi15_z_pos_in + resize(shift_right(chi15_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi15_z_acc_dt_sq, 96), 2*Q), 48);
          chi15_z_vel_pred_int <= chi15_z_vel_in + resize(shift_right(chi15_z_acc_dt, Q), 48);
          chi15_z_acc_pred_int <= chi15_z_acc_in;

          chi16_x_pos_pred_int <= chi16_x_pos_in + resize(shift_right(chi16_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi16_x_acc_dt_sq, 96), 2*Q), 48);
          chi16_x_vel_pred_int <= chi16_x_vel_in + resize(shift_right(chi16_x_acc_dt, Q), 48);
          chi16_x_acc_pred_int <= chi16_x_acc_in;
          chi16_y_pos_pred_int <= chi16_y_pos_in + resize(shift_right(chi16_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi16_y_acc_dt_sq, 96), 2*Q), 48);
          chi16_y_vel_pred_int <= chi16_y_vel_in + resize(shift_right(chi16_y_acc_dt, Q), 48);
          chi16_y_acc_pred_int <= chi16_y_acc_in;
          chi16_z_pos_pred_int <= chi16_z_pos_in + resize(shift_right(chi16_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi16_z_acc_dt_sq, 96), 2*Q), 48);
          chi16_z_vel_pred_int <= chi16_z_vel_in + resize(shift_right(chi16_z_acc_dt, Q), 48);
          chi16_z_acc_pred_int <= chi16_z_acc_in;

          chi17_x_pos_pred_int <= chi17_x_pos_in + resize(shift_right(chi17_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi17_x_acc_dt_sq, 96), 2*Q), 48);
          chi17_x_vel_pred_int <= chi17_x_vel_in + resize(shift_right(chi17_x_acc_dt, Q), 48);
          chi17_x_acc_pred_int <= chi17_x_acc_in;
          chi17_y_pos_pred_int <= chi17_y_pos_in + resize(shift_right(chi17_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi17_y_acc_dt_sq, 96), 2*Q), 48);
          chi17_y_vel_pred_int <= chi17_y_vel_in + resize(shift_right(chi17_y_acc_dt, Q), 48);
          chi17_y_acc_pred_int <= chi17_y_acc_in;
          chi17_z_pos_pred_int <= chi17_z_pos_in + resize(shift_right(chi17_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi17_z_acc_dt_sq, 96), 2*Q), 48);
          chi17_z_vel_pred_int <= chi17_z_vel_in + resize(shift_right(chi17_z_acc_dt, Q), 48);
          chi17_z_acc_pred_int <= chi17_z_acc_in;

          chi18_x_pos_pred_int <= chi18_x_pos_in + resize(shift_right(chi18_x_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi18_x_acc_dt_sq, 96), 2*Q), 48);
          chi18_x_vel_pred_int <= chi18_x_vel_in + resize(shift_right(chi18_x_acc_dt, Q), 48);
          chi18_x_acc_pred_int <= chi18_x_acc_in;
          chi18_y_pos_pred_int <= chi18_y_pos_in + resize(shift_right(chi18_y_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi18_y_acc_dt_sq, 96), 2*Q), 48);
          chi18_y_vel_pred_int <= chi18_y_vel_in + resize(shift_right(chi18_y_acc_dt, Q), 48);
          chi18_y_acc_pred_int <= chi18_y_acc_in;
          chi18_z_pos_pred_int <= chi18_z_pos_in + resize(shift_right(chi18_z_vel_dt, Q), 48) + resize(shift_right(resize(HALF_Q24_24 * chi18_z_acc_dt_sq, 96), 2*Q), 48);
          chi18_z_vel_pred_int <= chi18_z_vel_in + resize(shift_right(chi18_z_acc_dt, Q), 48);
          chi18_z_acc_pred_int <= chi18_z_acc_in;

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

  chi0_x_pos_pred <= chi0_x_pos_pred_int;
  chi0_x_vel_pred <= chi0_x_vel_pred_int;
  chi0_x_acc_pred <= chi0_x_acc_pred_int;
  chi0_y_pos_pred <= chi0_y_pos_pred_int;
  chi0_y_vel_pred <= chi0_y_vel_pred_int;
  chi0_y_acc_pred <= chi0_y_acc_pred_int;
  chi0_z_pos_pred <= chi0_z_pos_pred_int;
  chi0_z_vel_pred <= chi0_z_vel_pred_int;
  chi0_z_acc_pred <= chi0_z_acc_pred_int;

  chi1_x_pos_pred <= chi1_x_pos_pred_int;
  chi1_x_vel_pred <= chi1_x_vel_pred_int;
  chi1_x_acc_pred <= chi1_x_acc_pred_int;
  chi1_y_pos_pred <= chi1_y_pos_pred_int;
  chi1_y_vel_pred <= chi1_y_vel_pred_int;
  chi1_y_acc_pred <= chi1_y_acc_pred_int;
  chi1_z_pos_pred <= chi1_z_pos_pred_int;
  chi1_z_vel_pred <= chi1_z_vel_pred_int;
  chi1_z_acc_pred <= chi1_z_acc_pred_int;

  chi2_x_pos_pred <= chi2_x_pos_pred_int;
  chi2_x_vel_pred <= chi2_x_vel_pred_int;
  chi2_x_acc_pred <= chi2_x_acc_pred_int;
  chi2_y_pos_pred <= chi2_y_pos_pred_int;
  chi2_y_vel_pred <= chi2_y_vel_pred_int;
  chi2_y_acc_pred <= chi2_y_acc_pred_int;
  chi2_z_pos_pred <= chi2_z_pos_pred_int;
  chi2_z_vel_pred <= chi2_z_vel_pred_int;
  chi2_z_acc_pred <= chi2_z_acc_pred_int;

  chi3_x_pos_pred <= chi3_x_pos_pred_int;
  chi3_x_vel_pred <= chi3_x_vel_pred_int;
  chi3_x_acc_pred <= chi3_x_acc_pred_int;
  chi3_y_pos_pred <= chi3_y_pos_pred_int;
  chi3_y_vel_pred <= chi3_y_vel_pred_int;
  chi3_y_acc_pred <= chi3_y_acc_pred_int;
  chi3_z_pos_pred <= chi3_z_pos_pred_int;
  chi3_z_vel_pred <= chi3_z_vel_pred_int;
  chi3_z_acc_pred <= chi3_z_acc_pred_int;

  chi4_x_pos_pred <= chi4_x_pos_pred_int;
  chi4_x_vel_pred <= chi4_x_vel_pred_int;
  chi4_x_acc_pred <= chi4_x_acc_pred_int;
  chi4_y_pos_pred <= chi4_y_pos_pred_int;
  chi4_y_vel_pred <= chi4_y_vel_pred_int;
  chi4_y_acc_pred <= chi4_y_acc_pred_int;
  chi4_z_pos_pred <= chi4_z_pos_pred_int;
  chi4_z_vel_pred <= chi4_z_vel_pred_int;
  chi4_z_acc_pred <= chi4_z_acc_pred_int;

  chi5_x_pos_pred <= chi5_x_pos_pred_int;
  chi5_x_vel_pred <= chi5_x_vel_pred_int;
  chi5_x_acc_pred <= chi5_x_acc_pred_int;
  chi5_y_pos_pred <= chi5_y_pos_pred_int;
  chi5_y_vel_pred <= chi5_y_vel_pred_int;
  chi5_y_acc_pred <= chi5_y_acc_pred_int;
  chi5_z_pos_pred <= chi5_z_pos_pred_int;
  chi5_z_vel_pred <= chi5_z_vel_pred_int;
  chi5_z_acc_pred <= chi5_z_acc_pred_int;

  chi6_x_pos_pred <= chi6_x_pos_pred_int;
  chi6_x_vel_pred <= chi6_x_vel_pred_int;
  chi6_x_acc_pred <= chi6_x_acc_pred_int;
  chi6_y_pos_pred <= chi6_y_pos_pred_int;
  chi6_y_vel_pred <= chi6_y_vel_pred_int;
  chi6_y_acc_pred <= chi6_y_acc_pred_int;
  chi6_z_pos_pred <= chi6_z_pos_pred_int;
  chi6_z_vel_pred <= chi6_z_vel_pred_int;
  chi6_z_acc_pred <= chi6_z_acc_pred_int;

  chi7_x_pos_pred <= chi7_x_pos_pred_int;
  chi7_x_vel_pred <= chi7_x_vel_pred_int;
  chi7_x_acc_pred <= chi7_x_acc_pred_int;
  chi7_y_pos_pred <= chi7_y_pos_pred_int;
  chi7_y_vel_pred <= chi7_y_vel_pred_int;
  chi7_y_acc_pred <= chi7_y_acc_pred_int;
  chi7_z_pos_pred <= chi7_z_pos_pred_int;
  chi7_z_vel_pred <= chi7_z_vel_pred_int;
  chi7_z_acc_pred <= chi7_z_acc_pred_int;

  chi8_x_pos_pred <= chi8_x_pos_pred_int;
  chi8_x_vel_pred <= chi8_x_vel_pred_int;
  chi8_x_acc_pred <= chi8_x_acc_pred_int;
  chi8_y_pos_pred <= chi8_y_pos_pred_int;
  chi8_y_vel_pred <= chi8_y_vel_pred_int;
  chi8_y_acc_pred <= chi8_y_acc_pred_int;
  chi8_z_pos_pred <= chi8_z_pos_pred_int;
  chi8_z_vel_pred <= chi8_z_vel_pred_int;
  chi8_z_acc_pred <= chi8_z_acc_pred_int;

  chi9_x_pos_pred <= chi9_x_pos_pred_int;
  chi9_x_vel_pred <= chi9_x_vel_pred_int;
  chi9_x_acc_pred <= chi9_x_acc_pred_int;
  chi9_y_pos_pred <= chi9_y_pos_pred_int;
  chi9_y_vel_pred <= chi9_y_vel_pred_int;
  chi9_y_acc_pred <= chi9_y_acc_pred_int;
  chi9_z_pos_pred <= chi9_z_pos_pred_int;
  chi9_z_vel_pred <= chi9_z_vel_pred_int;
  chi9_z_acc_pred <= chi9_z_acc_pred_int;

  chi10_x_pos_pred <= chi10_x_pos_pred_int;
  chi10_x_vel_pred <= chi10_x_vel_pred_int;
  chi10_x_acc_pred <= chi10_x_acc_pred_int;
  chi10_y_pos_pred <= chi10_y_pos_pred_int;
  chi10_y_vel_pred <= chi10_y_vel_pred_int;
  chi10_y_acc_pred <= chi10_y_acc_pred_int;
  chi10_z_pos_pred <= chi10_z_pos_pred_int;
  chi10_z_vel_pred <= chi10_z_vel_pred_int;
  chi10_z_acc_pred <= chi10_z_acc_pred_int;

  chi11_x_pos_pred <= chi11_x_pos_pred_int;
  chi11_x_vel_pred <= chi11_x_vel_pred_int;
  chi11_x_acc_pred <= chi11_x_acc_pred_int;
  chi11_y_pos_pred <= chi11_y_pos_pred_int;
  chi11_y_vel_pred <= chi11_y_vel_pred_int;
  chi11_y_acc_pred <= chi11_y_acc_pred_int;
  chi11_z_pos_pred <= chi11_z_pos_pred_int;
  chi11_z_vel_pred <= chi11_z_vel_pred_int;
  chi11_z_acc_pred <= chi11_z_acc_pred_int;

  chi12_x_pos_pred <= chi12_x_pos_pred_int;
  chi12_x_vel_pred <= chi12_x_vel_pred_int;
  chi12_x_acc_pred <= chi12_x_acc_pred_int;
  chi12_y_pos_pred <= chi12_y_pos_pred_int;
  chi12_y_vel_pred <= chi12_y_vel_pred_int;
  chi12_y_acc_pred <= chi12_y_acc_pred_int;
  chi12_z_pos_pred <= chi12_z_pos_pred_int;
  chi12_z_vel_pred <= chi12_z_vel_pred_int;
  chi12_z_acc_pred <= chi12_z_acc_pred_int;

  chi13_x_pos_pred <= chi13_x_pos_pred_int;
  chi13_x_vel_pred <= chi13_x_vel_pred_int;
  chi13_x_acc_pred <= chi13_x_acc_pred_int;
  chi13_y_pos_pred <= chi13_y_pos_pred_int;
  chi13_y_vel_pred <= chi13_y_vel_pred_int;
  chi13_y_acc_pred <= chi13_y_acc_pred_int;
  chi13_z_pos_pred <= chi13_z_pos_pred_int;
  chi13_z_vel_pred <= chi13_z_vel_pred_int;
  chi13_z_acc_pred <= chi13_z_acc_pred_int;

  chi14_x_pos_pred <= chi14_x_pos_pred_int;
  chi14_x_vel_pred <= chi14_x_vel_pred_int;
  chi14_x_acc_pred <= chi14_x_acc_pred_int;
  chi14_y_pos_pred <= chi14_y_pos_pred_int;
  chi14_y_vel_pred <= chi14_y_vel_pred_int;
  chi14_y_acc_pred <= chi14_y_acc_pred_int;
  chi14_z_pos_pred <= chi14_z_pos_pred_int;
  chi14_z_vel_pred <= chi14_z_vel_pred_int;
  chi14_z_acc_pred <= chi14_z_acc_pred_int;

  chi15_x_pos_pred <= chi15_x_pos_pred_int;
  chi15_x_vel_pred <= chi15_x_vel_pred_int;
  chi15_x_acc_pred <= chi15_x_acc_pred_int;
  chi15_y_pos_pred <= chi15_y_pos_pred_int;
  chi15_y_vel_pred <= chi15_y_vel_pred_int;
  chi15_y_acc_pred <= chi15_y_acc_pred_int;
  chi15_z_pos_pred <= chi15_z_pos_pred_int;
  chi15_z_vel_pred <= chi15_z_vel_pred_int;
  chi15_z_acc_pred <= chi15_z_acc_pred_int;

  chi16_x_pos_pred <= chi16_x_pos_pred_int;
  chi16_x_vel_pred <= chi16_x_vel_pred_int;
  chi16_x_acc_pred <= chi16_x_acc_pred_int;
  chi16_y_pos_pred <= chi16_y_pos_pred_int;
  chi16_y_vel_pred <= chi16_y_vel_pred_int;
  chi16_y_acc_pred <= chi16_y_acc_pred_int;
  chi16_z_pos_pred <= chi16_z_pos_pred_int;
  chi16_z_vel_pred <= chi16_z_vel_pred_int;
  chi16_z_acc_pred <= chi16_z_acc_pred_int;

  chi17_x_pos_pred <= chi17_x_pos_pred_int;
  chi17_x_vel_pred <= chi17_x_vel_pred_int;
  chi17_x_acc_pred <= chi17_x_acc_pred_int;
  chi17_y_pos_pred <= chi17_y_pos_pred_int;
  chi17_y_vel_pred <= chi17_y_vel_pred_int;
  chi17_y_acc_pred <= chi17_y_acc_pred_int;
  chi17_z_pos_pred <= chi17_z_pos_pred_int;
  chi17_z_vel_pred <= chi17_z_vel_pred_int;
  chi17_z_acc_pred <= chi17_z_acc_pred_int;

  chi18_x_pos_pred <= chi18_x_pos_pred_int;
  chi18_x_vel_pred <= chi18_x_vel_pred_int;
  chi18_x_acc_pred <= chi18_x_acc_pred_int;
  chi18_y_pos_pred <= chi18_y_pos_pred_int;
  chi18_y_vel_pred <= chi18_y_vel_pred_int;
  chi18_y_acc_pred <= chi18_y_acc_pred_int;
  chi18_z_pos_pred <= chi18_z_pos_pred_int;
  chi18_z_vel_pred <= chi18_z_vel_pred_int;
  chi18_z_acc_pred <= chi18_z_acc_pred_int;

end Behavioral;
