library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.TEXTIO.ALL;

entity predicti_ctr3d is
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    start       : in  std_logic;

    chi0_x_pos_in : in signed(47 downto 0);
    chi0_x_vel_in : in signed(47 downto 0);
    chi0_x_omega_in : in signed(47 downto 0);
    chi0_y_pos_in : in signed(47 downto 0);
    chi0_y_vel_in : in signed(47 downto 0);
    chi0_y_omega_in : in signed(47 downto 0);
    chi0_z_pos_in : in signed(47 downto 0);
    chi0_z_vel_in : in signed(47 downto 0);
    chi0_z_omega_in : in signed(47 downto 0);

    chi1_x_pos_in, chi1_x_vel_in, chi1_x_omega_in : in signed(47 downto 0);
    chi1_y_pos_in, chi1_y_vel_in, chi1_y_omega_in : in signed(47 downto 0);
    chi1_z_pos_in, chi1_z_vel_in, chi1_z_omega_in : in signed(47 downto 0);

    chi2_x_pos_in, chi2_x_vel_in, chi2_x_omega_in : in signed(47 downto 0);
    chi2_y_pos_in, chi2_y_vel_in, chi2_y_omega_in : in signed(47 downto 0);
    chi2_z_pos_in, chi2_z_vel_in, chi2_z_omega_in : in signed(47 downto 0);

    chi3_x_pos_in, chi3_x_vel_in, chi3_x_omega_in : in signed(47 downto 0);
    chi3_y_pos_in, chi3_y_vel_in, chi3_y_omega_in : in signed(47 downto 0);
    chi3_z_pos_in, chi3_z_vel_in, chi3_z_omega_in : in signed(47 downto 0);

    chi4_x_pos_in, chi4_x_vel_in, chi4_x_omega_in : in signed(47 downto 0);
    chi4_y_pos_in, chi4_y_vel_in, chi4_y_omega_in : in signed(47 downto 0);
    chi4_z_pos_in, chi4_z_vel_in, chi4_z_omega_in : in signed(47 downto 0);

    chi5_x_pos_in, chi5_x_vel_in, chi5_x_omega_in : in signed(47 downto 0);
    chi5_y_pos_in, chi5_y_vel_in, chi5_y_omega_in : in signed(47 downto 0);
    chi5_z_pos_in, chi5_z_vel_in, chi5_z_omega_in : in signed(47 downto 0);

    chi6_x_pos_in, chi6_x_vel_in, chi6_x_omega_in : in signed(47 downto 0);
    chi6_y_pos_in, chi6_y_vel_in, chi6_y_omega_in : in signed(47 downto 0);
    chi6_z_pos_in, chi6_z_vel_in, chi6_z_omega_in : in signed(47 downto 0);

    chi7_x_pos_in, chi7_x_vel_in, chi7_x_omega_in : in signed(47 downto 0);
    chi7_y_pos_in, chi7_y_vel_in, chi7_y_omega_in : in signed(47 downto 0);
    chi7_z_pos_in, chi7_z_vel_in, chi7_z_omega_in : in signed(47 downto 0);

    chi8_x_pos_in, chi8_x_vel_in, chi8_x_omega_in : in signed(47 downto 0);
    chi8_y_pos_in, chi8_y_vel_in, chi8_y_omega_in : in signed(47 downto 0);
    chi8_z_pos_in, chi8_z_vel_in, chi8_z_omega_in : in signed(47 downto 0);

    chi9_x_pos_in, chi9_x_vel_in, chi9_x_omega_in : in signed(47 downto 0);
    chi9_y_pos_in, chi9_y_vel_in, chi9_y_omega_in : in signed(47 downto 0);
    chi9_z_pos_in, chi9_z_vel_in, chi9_z_omega_in : in signed(47 downto 0);

    chi10_x_pos_in, chi10_x_vel_in, chi10_x_omega_in : in signed(47 downto 0);
    chi10_y_pos_in, chi10_y_vel_in, chi10_y_omega_in : in signed(47 downto 0);
    chi10_z_pos_in, chi10_z_vel_in, chi10_z_omega_in : in signed(47 downto 0);

    chi11_x_pos_in, chi11_x_vel_in, chi11_x_omega_in : in signed(47 downto 0);
    chi11_y_pos_in, chi11_y_vel_in, chi11_y_omega_in : in signed(47 downto 0);
    chi11_z_pos_in, chi11_z_vel_in, chi11_z_omega_in : in signed(47 downto 0);

    chi12_x_pos_in, chi12_x_vel_in, chi12_x_omega_in : in signed(47 downto 0);
    chi12_y_pos_in, chi12_y_vel_in, chi12_y_omega_in : in signed(47 downto 0);
    chi12_z_pos_in, chi12_z_vel_in, chi12_z_omega_in : in signed(47 downto 0);

    chi13_x_pos_in, chi13_x_vel_in, chi13_x_omega_in : in signed(47 downto 0);
    chi13_y_pos_in, chi13_y_vel_in, chi13_y_omega_in : in signed(47 downto 0);
    chi13_z_pos_in, chi13_z_vel_in, chi13_z_omega_in : in signed(47 downto 0);

    chi14_x_pos_in, chi14_x_vel_in, chi14_x_omega_in : in signed(47 downto 0);
    chi14_y_pos_in, chi14_y_vel_in, chi14_y_omega_in : in signed(47 downto 0);
    chi14_z_pos_in, chi14_z_vel_in, chi14_z_omega_in : in signed(47 downto 0);

    chi15_x_pos_in, chi15_x_vel_in, chi15_x_omega_in : in signed(47 downto 0);
    chi15_y_pos_in, chi15_y_vel_in, chi15_y_omega_in : in signed(47 downto 0);
    chi15_z_pos_in, chi15_z_vel_in, chi15_z_omega_in : in signed(47 downto 0);

    chi16_x_pos_in, chi16_x_vel_in, chi16_x_omega_in : in signed(47 downto 0);
    chi16_y_pos_in, chi16_y_vel_in, chi16_y_omega_in : in signed(47 downto 0);
    chi16_z_pos_in, chi16_z_vel_in, chi16_z_omega_in : in signed(47 downto 0);

    chi17_x_pos_in, chi17_x_vel_in, chi17_x_omega_in : in signed(47 downto 0);
    chi17_y_pos_in, chi17_y_vel_in, chi17_y_omega_in : in signed(47 downto 0);
    chi17_z_pos_in, chi17_z_vel_in, chi17_z_omega_in : in signed(47 downto 0);

    chi18_x_pos_in, chi18_x_vel_in, chi18_x_omega_in : in signed(47 downto 0);
    chi18_y_pos_in, chi18_y_vel_in, chi18_y_omega_in : in signed(47 downto 0);
    chi18_z_pos_in, chi18_z_vel_in, chi18_z_omega_in : in signed(47 downto 0);

    chi0_x_pos_pred, chi0_x_vel_pred, chi0_x_omega_pred : out signed(47 downto 0);
    chi0_y_pos_pred, chi0_y_vel_pred, chi0_y_omega_pred : out signed(47 downto 0);
    chi0_z_pos_pred, chi0_z_vel_pred, chi0_z_omega_pred : out signed(47 downto 0);

    chi1_x_pos_pred, chi1_x_vel_pred, chi1_x_omega_pred : out signed(47 downto 0);
    chi1_y_pos_pred, chi1_y_vel_pred, chi1_y_omega_pred : out signed(47 downto 0);
    chi1_z_pos_pred, chi1_z_vel_pred, chi1_z_omega_pred : out signed(47 downto 0);

    chi2_x_pos_pred, chi2_x_vel_pred, chi2_x_omega_pred : out signed(47 downto 0);
    chi2_y_pos_pred, chi2_y_vel_pred, chi2_y_omega_pred : out signed(47 downto 0);
    chi2_z_pos_pred, chi2_z_vel_pred, chi2_z_omega_pred : out signed(47 downto 0);

    chi3_x_pos_pred, chi3_x_vel_pred, chi3_x_omega_pred : out signed(47 downto 0);
    chi3_y_pos_pred, chi3_y_vel_pred, chi3_y_omega_pred : out signed(47 downto 0);
    chi3_z_pos_pred, chi3_z_vel_pred, chi3_z_omega_pred : out signed(47 downto 0);

    chi4_x_pos_pred, chi4_x_vel_pred, chi4_x_omega_pred : out signed(47 downto 0);
    chi4_y_pos_pred, chi4_y_vel_pred, chi4_y_omega_pred : out signed(47 downto 0);
    chi4_z_pos_pred, chi4_z_vel_pred, chi4_z_omega_pred : out signed(47 downto 0);

    chi5_x_pos_pred, chi5_x_vel_pred, chi5_x_omega_pred : out signed(47 downto 0);
    chi5_y_pos_pred, chi5_y_vel_pred, chi5_y_omega_pred : out signed(47 downto 0);
    chi5_z_pos_pred, chi5_z_vel_pred, chi5_z_omega_pred : out signed(47 downto 0);

    chi6_x_pos_pred, chi6_x_vel_pred, chi6_x_omega_pred : out signed(47 downto 0);
    chi6_y_pos_pred, chi6_y_vel_pred, chi6_y_omega_pred : out signed(47 downto 0);
    chi6_z_pos_pred, chi6_z_vel_pred, chi6_z_omega_pred : out signed(47 downto 0);

    chi7_x_pos_pred, chi7_x_vel_pred, chi7_x_omega_pred : out signed(47 downto 0);
    chi7_y_pos_pred, chi7_y_vel_pred, chi7_y_omega_pred : out signed(47 downto 0);
    chi7_z_pos_pred, chi7_z_vel_pred, chi7_z_omega_pred : out signed(47 downto 0);

    chi8_x_pos_pred, chi8_x_vel_pred, chi8_x_omega_pred : out signed(47 downto 0);
    chi8_y_pos_pred, chi8_y_vel_pred, chi8_y_omega_pred : out signed(47 downto 0);
    chi8_z_pos_pred, chi8_z_vel_pred, chi8_z_omega_pred : out signed(47 downto 0);

    chi9_x_pos_pred, chi9_x_vel_pred, chi9_x_omega_pred : out signed(47 downto 0);
    chi9_y_pos_pred, chi9_y_vel_pred, chi9_y_omega_pred : out signed(47 downto 0);
    chi9_z_pos_pred, chi9_z_vel_pred, chi9_z_omega_pred : out signed(47 downto 0);

    chi10_x_pos_pred, chi10_x_vel_pred, chi10_x_omega_pred : out signed(47 downto 0);
    chi10_y_pos_pred, chi10_y_vel_pred, chi10_y_omega_pred : out signed(47 downto 0);
    chi10_z_pos_pred, chi10_z_vel_pred, chi10_z_omega_pred : out signed(47 downto 0);

    chi11_x_pos_pred, chi11_x_vel_pred, chi11_x_omega_pred : out signed(47 downto 0);
    chi11_y_pos_pred, chi11_y_vel_pred, chi11_y_omega_pred : out signed(47 downto 0);
    chi11_z_pos_pred, chi11_z_vel_pred, chi11_z_omega_pred : out signed(47 downto 0);

    chi12_x_pos_pred, chi12_x_vel_pred, chi12_x_omega_pred : out signed(47 downto 0);
    chi12_y_pos_pred, chi12_y_vel_pred, chi12_y_omega_pred : out signed(47 downto 0);
    chi12_z_pos_pred, chi12_z_vel_pred, chi12_z_omega_pred : out signed(47 downto 0);

    chi13_x_pos_pred, chi13_x_vel_pred, chi13_x_omega_pred : out signed(47 downto 0);
    chi13_y_pos_pred, chi13_y_vel_pred, chi13_y_omega_pred : out signed(47 downto 0);
    chi13_z_pos_pred, chi13_z_vel_pred, chi13_z_omega_pred : out signed(47 downto 0);

    chi14_x_pos_pred, chi14_x_vel_pred, chi14_x_omega_pred : out signed(47 downto 0);
    chi14_y_pos_pred, chi14_y_vel_pred, chi14_y_omega_pred : out signed(47 downto 0);
    chi14_z_pos_pred, chi14_z_vel_pred, chi14_z_omega_pred : out signed(47 downto 0);

    chi15_x_pos_pred, chi15_x_vel_pred, chi15_x_omega_pred : out signed(47 downto 0);
    chi15_y_pos_pred, chi15_y_vel_pred, chi15_y_omega_pred : out signed(47 downto 0);
    chi15_z_pos_pred, chi15_z_vel_pred, chi15_z_omega_pred : out signed(47 downto 0);

    chi16_x_pos_pred, chi16_x_vel_pred, chi16_x_omega_pred : out signed(47 downto 0);
    chi16_y_pos_pred, chi16_y_vel_pred, chi16_y_omega_pred : out signed(47 downto 0);
    chi16_z_pos_pred, chi16_z_vel_pred, chi16_z_omega_pred : out signed(47 downto 0);

    chi17_x_pos_pred, chi17_x_vel_pred, chi17_x_omega_pred : out signed(47 downto 0);
    chi17_y_pos_pred, chi17_y_vel_pred, chi17_y_omega_pred : out signed(47 downto 0);
    chi17_z_pos_pred, chi17_z_vel_pred, chi17_z_omega_pred : out signed(47 downto 0);

    chi18_x_pos_pred, chi18_x_vel_pred, chi18_x_omega_pred : out signed(47 downto 0);
    chi18_y_pos_pred, chi18_y_vel_pred, chi18_y_omega_pred : out signed(47 downto 0);
    chi18_z_pos_pred, chi18_z_vel_pred, chi18_z_omega_pred : out signed(47 downto 0);

    done        : out std_logic
  );
end entity;

architecture Behavioral of predicti_ctr3d is

  constant DT_Q24_24      : signed(47 downto 0) := to_signed(335544, 48);
  constant DT_SQ_Q24_24   : signed(47 downto 0) := to_signed(6711, 48);
  constant HALF_Q24_24    : signed(47 downto 0) := to_signed(8388608, 48);
  constant Q : integer := 24;

  type state_type is (IDLE, MULTIPLY_CROSS_VEL, COMPUTE_CROSS_OMEGASQ, COMPUTE_CORRECTION, CALCULATE, FINISHED);
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

  signal chi0_wy_vz, chi1_wy_vz, chi2_wy_vz, chi3_wy_vz : signed(95 downto 0) := (others => '0');
  signal chi4_wy_vz, chi5_wy_vz, chi6_wy_vz, chi7_wy_vz : signed(95 downto 0) := (others => '0');
  signal chi8_wy_vz, chi9_wy_vz, chi10_wy_vz, chi11_wy_vz : signed(95 downto 0) := (others => '0');
  signal chi12_wy_vz, chi13_wy_vz, chi14_wy_vz, chi15_wy_vz : signed(95 downto 0) := (others => '0');
  signal chi16_wy_vz, chi17_wy_vz, chi18_wy_vz : signed(95 downto 0) := (others => '0');

  signal chi0_wz_vy, chi1_wz_vy, chi2_wz_vy, chi3_wz_vy : signed(95 downto 0) := (others => '0');
  signal chi4_wz_vy, chi5_wz_vy, chi6_wz_vy, chi7_wz_vy : signed(95 downto 0) := (others => '0');
  signal chi8_wz_vy, chi9_wz_vy, chi10_wz_vy, chi11_wz_vy : signed(95 downto 0) := (others => '0');
  signal chi12_wz_vy, chi13_wz_vy, chi14_wz_vy, chi15_wz_vy : signed(95 downto 0) := (others => '0');
  signal chi16_wz_vy, chi17_wz_vy, chi18_wz_vy : signed(95 downto 0) := (others => '0');

  signal chi0_wz_vx, chi1_wz_vx, chi2_wz_vx, chi3_wz_vx : signed(95 downto 0) := (others => '0');
  signal chi4_wz_vx, chi5_wz_vx, chi6_wz_vx, chi7_wz_vx : signed(95 downto 0) := (others => '0');
  signal chi8_wz_vx, chi9_wz_vx, chi10_wz_vx, chi11_wz_vx : signed(95 downto 0) := (others => '0');
  signal chi12_wz_vx, chi13_wz_vx, chi14_wz_vx, chi15_wz_vx : signed(95 downto 0) := (others => '0');
  signal chi16_wz_vx, chi17_wz_vx, chi18_wz_vx : signed(95 downto 0) := (others => '0');

  signal chi0_wx_vz, chi1_wx_vz, chi2_wx_vz, chi3_wx_vz : signed(95 downto 0) := (others => '0');
  signal chi4_wx_vz, chi5_wx_vz, chi6_wx_vz, chi7_wx_vz : signed(95 downto 0) := (others => '0');
  signal chi8_wx_vz, chi9_wx_vz, chi10_wx_vz, chi11_wx_vz : signed(95 downto 0) := (others => '0');
  signal chi12_wx_vz, chi13_wx_vz, chi14_wx_vz, chi15_wx_vz : signed(95 downto 0) := (others => '0');
  signal chi16_wx_vz, chi17_wx_vz, chi18_wx_vz : signed(95 downto 0) := (others => '0');

  signal chi0_wx_vy, chi1_wx_vy, chi2_wx_vy, chi3_wx_vy : signed(95 downto 0) := (others => '0');
  signal chi4_wx_vy, chi5_wx_vy, chi6_wx_vy, chi7_wx_vy : signed(95 downto 0) := (others => '0');
  signal chi8_wx_vy, chi9_wx_vy, chi10_wx_vy, chi11_wx_vy : signed(95 downto 0) := (others => '0');
  signal chi12_wx_vy, chi13_wx_vy, chi14_wx_vy, chi15_wx_vy : signed(95 downto 0) := (others => '0');
  signal chi16_wx_vy, chi17_wx_vy, chi18_wx_vy : signed(95 downto 0) := (others => '0');

  signal chi0_wy_vx, chi1_wy_vx, chi2_wy_vx, chi3_wy_vx : signed(95 downto 0) := (others => '0');
  signal chi4_wy_vx, chi5_wy_vx, chi6_wy_vx, chi7_wy_vx : signed(95 downto 0) := (others => '0');
  signal chi8_wy_vx, chi9_wy_vx, chi10_wy_vx, chi11_wy_vx : signed(95 downto 0) := (others => '0');
  signal chi12_wy_vx, chi13_wy_vx, chi14_wy_vx, chi15_wy_vx : signed(95 downto 0) := (others => '0');
  signal chi16_wy_vx, chi17_wy_vx, chi18_wy_vx : signed(95 downto 0) := (others => '0');

  signal chi0_wx_sq, chi1_wx_sq, chi2_wx_sq, chi3_wx_sq : signed(95 downto 0) := (others => '0');
  signal chi4_wx_sq, chi5_wx_sq, chi6_wx_sq, chi7_wx_sq : signed(95 downto 0) := (others => '0');
  signal chi8_wx_sq, chi9_wx_sq, chi10_wx_sq, chi11_wx_sq : signed(95 downto 0) := (others => '0');
  signal chi12_wx_sq, chi13_wx_sq, chi14_wx_sq, chi15_wx_sq : signed(95 downto 0) := (others => '0');
  signal chi16_wx_sq, chi17_wx_sq, chi18_wx_sq : signed(95 downto 0) := (others => '0');

  signal chi0_wy_sq, chi1_wy_sq, chi2_wy_sq, chi3_wy_sq : signed(95 downto 0) := (others => '0');
  signal chi4_wy_sq, chi5_wy_sq, chi6_wy_sq, chi7_wy_sq : signed(95 downto 0) := (others => '0');
  signal chi8_wy_sq, chi9_wy_sq, chi10_wy_sq, chi11_wy_sq : signed(95 downto 0) := (others => '0');
  signal chi12_wy_sq, chi13_wy_sq, chi14_wy_sq, chi15_wy_sq : signed(95 downto 0) := (others => '0');
  signal chi16_wy_sq, chi17_wy_sq, chi18_wy_sq : signed(95 downto 0) := (others => '0');

  signal chi0_wz_sq, chi1_wz_sq, chi2_wz_sq, chi3_wz_sq : signed(95 downto 0) := (others => '0');
  signal chi4_wz_sq, chi5_wz_sq, chi6_wz_sq, chi7_wz_sq : signed(95 downto 0) := (others => '0');
  signal chi8_wz_sq, chi9_wz_sq, chi10_wz_sq, chi11_wz_sq : signed(95 downto 0) := (others => '0');
  signal chi12_wz_sq, chi13_wz_sq, chi14_wz_sq, chi15_wz_sq : signed(95 downto 0) := (others => '0');
  signal chi16_wz_sq, chi17_wz_sq, chi18_wz_sq : signed(95 downto 0) := (others => '0');

  signal chi0_cx, chi1_cx, chi2_cx, chi3_cx : signed(47 downto 0) := (others => '0');
  signal chi4_cx, chi5_cx, chi6_cx, chi7_cx : signed(47 downto 0) := (others => '0');
  signal chi8_cx, chi9_cx, chi10_cx, chi11_cx : signed(47 downto 0) := (others => '0');
  signal chi12_cx, chi13_cx, chi14_cx, chi15_cx : signed(47 downto 0) := (others => '0');
  signal chi16_cx, chi17_cx, chi18_cx : signed(47 downto 0) := (others => '0');

  signal chi0_cy, chi1_cy, chi2_cy, chi3_cy : signed(47 downto 0) := (others => '0');
  signal chi4_cy, chi5_cy, chi6_cy, chi7_cy : signed(47 downto 0) := (others => '0');
  signal chi8_cy, chi9_cy, chi10_cy, chi11_cy : signed(47 downto 0) := (others => '0');
  signal chi12_cy, chi13_cy, chi14_cy, chi15_cy : signed(47 downto 0) := (others => '0');
  signal chi16_cy, chi17_cy, chi18_cy : signed(47 downto 0) := (others => '0');

  signal chi0_cz, chi1_cz, chi2_cz, chi3_cz : signed(47 downto 0) := (others => '0');
  signal chi4_cz, chi5_cz, chi6_cz, chi7_cz : signed(47 downto 0) := (others => '0');
  signal chi8_cz, chi9_cz, chi10_cz, chi11_cz : signed(47 downto 0) := (others => '0');
  signal chi12_cz, chi13_cz, chi14_cz, chi15_cz : signed(47 downto 0) := (others => '0');
  signal chi16_cz, chi17_cz, chi18_cz : signed(47 downto 0) := (others => '0');

  signal chi0_omega_sq, chi1_omega_sq, chi2_omega_sq, chi3_omega_sq : signed(47 downto 0) := (others => '0');
  signal chi4_omega_sq, chi5_omega_sq, chi6_omega_sq, chi7_omega_sq : signed(47 downto 0) := (others => '0');
  signal chi8_omega_sq, chi9_omega_sq, chi10_omega_sq, chi11_omega_sq : signed(47 downto 0) := (others => '0');
  signal chi12_omega_sq, chi13_omega_sq, chi14_omega_sq, chi15_omega_sq : signed(47 downto 0) := (others => '0');
  signal chi16_omega_sq, chi17_omega_sq, chi18_omega_sq : signed(47 downto 0) := (others => '0');

  signal chi0_cx_dt, chi1_cx_dt, chi2_cx_dt, chi3_cx_dt : signed(95 downto 0) := (others => '0');
  signal chi4_cx_dt, chi5_cx_dt, chi6_cx_dt, chi7_cx_dt : signed(95 downto 0) := (others => '0');
  signal chi8_cx_dt, chi9_cx_dt, chi10_cx_dt, chi11_cx_dt : signed(95 downto 0) := (others => '0');
  signal chi12_cx_dt, chi13_cx_dt, chi14_cx_dt, chi15_cx_dt : signed(95 downto 0) := (others => '0');
  signal chi16_cx_dt, chi17_cx_dt, chi18_cx_dt : signed(95 downto 0) := (others => '0');

  signal chi0_cy_dt, chi1_cy_dt, chi2_cy_dt, chi3_cy_dt : signed(95 downto 0) := (others => '0');
  signal chi4_cy_dt, chi5_cy_dt, chi6_cy_dt, chi7_cy_dt : signed(95 downto 0) := (others => '0');
  signal chi8_cy_dt, chi9_cy_dt, chi10_cy_dt, chi11_cy_dt : signed(95 downto 0) := (others => '0');
  signal chi12_cy_dt, chi13_cy_dt, chi14_cy_dt, chi15_cy_dt : signed(95 downto 0) := (others => '0');
  signal chi16_cy_dt, chi17_cy_dt, chi18_cy_dt : signed(95 downto 0) := (others => '0');

  signal chi0_cz_dt, chi1_cz_dt, chi2_cz_dt, chi3_cz_dt : signed(95 downto 0) := (others => '0');
  signal chi4_cz_dt, chi5_cz_dt, chi6_cz_dt, chi7_cz_dt : signed(95 downto 0) := (others => '0');
  signal chi8_cz_dt, chi9_cz_dt, chi10_cz_dt, chi11_cz_dt : signed(95 downto 0) := (others => '0');
  signal chi12_cz_dt, chi13_cz_dt, chi14_cz_dt, chi15_cz_dt : signed(95 downto 0) := (others => '0');
  signal chi16_cz_dt, chi17_cz_dt, chi18_cz_dt : signed(95 downto 0) := (others => '0');

  signal chi0_osq_vx, chi1_osq_vx, chi2_osq_vx, chi3_osq_vx : signed(95 downto 0) := (others => '0');
  signal chi4_osq_vx, chi5_osq_vx, chi6_osq_vx, chi7_osq_vx : signed(95 downto 0) := (others => '0');
  signal chi8_osq_vx, chi9_osq_vx, chi10_osq_vx, chi11_osq_vx : signed(95 downto 0) := (others => '0');
  signal chi12_osq_vx, chi13_osq_vx, chi14_osq_vx, chi15_osq_vx : signed(95 downto 0) := (others => '0');
  signal chi16_osq_vx, chi17_osq_vx, chi18_osq_vx : signed(95 downto 0) := (others => '0');

  signal chi0_osq_vy, chi1_osq_vy, chi2_osq_vy, chi3_osq_vy : signed(95 downto 0) := (others => '0');
  signal chi4_osq_vy, chi5_osq_vy, chi6_osq_vy, chi7_osq_vy : signed(95 downto 0) := (others => '0');
  signal chi8_osq_vy, chi9_osq_vy, chi10_osq_vy, chi11_osq_vy : signed(95 downto 0) := (others => '0');
  signal chi12_osq_vy, chi13_osq_vy, chi14_osq_vy, chi15_osq_vy : signed(95 downto 0) := (others => '0');
  signal chi16_osq_vy, chi17_osq_vy, chi18_osq_vy : signed(95 downto 0) := (others => '0');

  signal chi0_osq_vz, chi1_osq_vz, chi2_osq_vz, chi3_osq_vz : signed(95 downto 0) := (others => '0');
  signal chi4_osq_vz, chi5_osq_vz, chi6_osq_vz, chi7_osq_vz : signed(95 downto 0) := (others => '0');
  signal chi8_osq_vz, chi9_osq_vz, chi10_osq_vz, chi11_osq_vz : signed(95 downto 0) := (others => '0');
  signal chi12_osq_vz, chi13_osq_vz, chi14_osq_vz, chi15_osq_vz : signed(95 downto 0) := (others => '0');
  signal chi16_osq_vz, chi17_osq_vz, chi18_osq_vz : signed(95 downto 0) := (others => '0');

  signal chi0_osq_vx_dtsq, chi1_osq_vx_dtsq, chi2_osq_vx_dtsq, chi3_osq_vx_dtsq : signed(95 downto 0) := (others => '0');
  signal chi4_osq_vx_dtsq, chi5_osq_vx_dtsq, chi6_osq_vx_dtsq, chi7_osq_vx_dtsq : signed(95 downto 0) := (others => '0');
  signal chi8_osq_vx_dtsq, chi9_osq_vx_dtsq, chi10_osq_vx_dtsq, chi11_osq_vx_dtsq : signed(95 downto 0) := (others => '0');
  signal chi12_osq_vx_dtsq, chi13_osq_vx_dtsq, chi14_osq_vx_dtsq, chi15_osq_vx_dtsq : signed(95 downto 0) := (others => '0');
  signal chi16_osq_vx_dtsq, chi17_osq_vx_dtsq, chi18_osq_vx_dtsq : signed(95 downto 0) := (others => '0');

  signal chi0_osq_vy_dtsq, chi1_osq_vy_dtsq, chi2_osq_vy_dtsq, chi3_osq_vy_dtsq : signed(95 downto 0) := (others => '0');
  signal chi4_osq_vy_dtsq, chi5_osq_vy_dtsq, chi6_osq_vy_dtsq, chi7_osq_vy_dtsq : signed(95 downto 0) := (others => '0');
  signal chi8_osq_vy_dtsq, chi9_osq_vy_dtsq, chi10_osq_vy_dtsq, chi11_osq_vy_dtsq : signed(95 downto 0) := (others => '0');
  signal chi12_osq_vy_dtsq, chi13_osq_vy_dtsq, chi14_osq_vy_dtsq, chi15_osq_vy_dtsq : signed(95 downto 0) := (others => '0');
  signal chi16_osq_vy_dtsq, chi17_osq_vy_dtsq, chi18_osq_vy_dtsq : signed(95 downto 0) := (others => '0');

  signal chi0_osq_vz_dtsq, chi1_osq_vz_dtsq, chi2_osq_vz_dtsq, chi3_osq_vz_dtsq : signed(95 downto 0) := (others => '0');
  signal chi4_osq_vz_dtsq, chi5_osq_vz_dtsq, chi6_osq_vz_dtsq, chi7_osq_vz_dtsq : signed(95 downto 0) := (others => '0');
  signal chi8_osq_vz_dtsq, chi9_osq_vz_dtsq, chi10_osq_vz_dtsq, chi11_osq_vz_dtsq : signed(95 downto 0) := (others => '0');
  signal chi12_osq_vz_dtsq, chi13_osq_vz_dtsq, chi14_osq_vz_dtsq, chi15_osq_vz_dtsq : signed(95 downto 0) := (others => '0');
  signal chi16_osq_vz_dtsq, chi17_osq_vz_dtsq, chi18_osq_vz_dtsq : signed(95 downto 0) := (others => '0');

  signal chi0_x_pos_pred_int, chi0_x_vel_pred_int, chi0_x_omega_pred_int, chi0_y_pos_pred_int, chi0_y_vel_pred_int, chi0_y_omega_pred_int, chi0_z_pos_pred_int, chi0_z_vel_pred_int, chi0_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi1_x_pos_pred_int, chi1_x_vel_pred_int, chi1_x_omega_pred_int, chi1_y_pos_pred_int, chi1_y_vel_pred_int, chi1_y_omega_pred_int, chi1_z_pos_pred_int, chi1_z_vel_pred_int, chi1_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi2_x_pos_pred_int, chi2_x_vel_pred_int, chi2_x_omega_pred_int, chi2_y_pos_pred_int, chi2_y_vel_pred_int, chi2_y_omega_pred_int, chi2_z_pos_pred_int, chi2_z_vel_pred_int, chi2_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi3_x_pos_pred_int, chi3_x_vel_pred_int, chi3_x_omega_pred_int, chi3_y_pos_pred_int, chi3_y_vel_pred_int, chi3_y_omega_pred_int, chi3_z_pos_pred_int, chi3_z_vel_pred_int, chi3_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi4_x_pos_pred_int, chi4_x_vel_pred_int, chi4_x_omega_pred_int, chi4_y_pos_pred_int, chi4_y_vel_pred_int, chi4_y_omega_pred_int, chi4_z_pos_pred_int, chi4_z_vel_pred_int, chi4_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi5_x_pos_pred_int, chi5_x_vel_pred_int, chi5_x_omega_pred_int, chi5_y_pos_pred_int, chi5_y_vel_pred_int, chi5_y_omega_pred_int, chi5_z_pos_pred_int, chi5_z_vel_pred_int, chi5_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi6_x_pos_pred_int, chi6_x_vel_pred_int, chi6_x_omega_pred_int, chi6_y_pos_pred_int, chi6_y_vel_pred_int, chi6_y_omega_pred_int, chi6_z_pos_pred_int, chi6_z_vel_pred_int, chi6_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi7_x_pos_pred_int, chi7_x_vel_pred_int, chi7_x_omega_pred_int, chi7_y_pos_pred_int, chi7_y_vel_pred_int, chi7_y_omega_pred_int, chi7_z_pos_pred_int, chi7_z_vel_pred_int, chi7_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi8_x_pos_pred_int, chi8_x_vel_pred_int, chi8_x_omega_pred_int, chi8_y_pos_pred_int, chi8_y_vel_pred_int, chi8_y_omega_pred_int, chi8_z_pos_pred_int, chi8_z_vel_pred_int, chi8_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi9_x_pos_pred_int, chi9_x_vel_pred_int, chi9_x_omega_pred_int, chi9_y_pos_pred_int, chi9_y_vel_pred_int, chi9_y_omega_pred_int, chi9_z_pos_pred_int, chi9_z_vel_pred_int, chi9_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi10_x_pos_pred_int, chi10_x_vel_pred_int, chi10_x_omega_pred_int, chi10_y_pos_pred_int, chi10_y_vel_pred_int, chi10_y_omega_pred_int, chi10_z_pos_pred_int, chi10_z_vel_pred_int, chi10_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi11_x_pos_pred_int, chi11_x_vel_pred_int, chi11_x_omega_pred_int, chi11_y_pos_pred_int, chi11_y_vel_pred_int, chi11_y_omega_pred_int, chi11_z_pos_pred_int, chi11_z_vel_pred_int, chi11_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi12_x_pos_pred_int, chi12_x_vel_pred_int, chi12_x_omega_pred_int, chi12_y_pos_pred_int, chi12_y_vel_pred_int, chi12_y_omega_pred_int, chi12_z_pos_pred_int, chi12_z_vel_pred_int, chi12_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi13_x_pos_pred_int, chi13_x_vel_pred_int, chi13_x_omega_pred_int, chi13_y_pos_pred_int, chi13_y_vel_pred_int, chi13_y_omega_pred_int, chi13_z_pos_pred_int, chi13_z_vel_pred_int, chi13_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi14_x_pos_pred_int, chi14_x_vel_pred_int, chi14_x_omega_pred_int, chi14_y_pos_pred_int, chi14_y_vel_pred_int, chi14_y_omega_pred_int, chi14_z_pos_pred_int, chi14_z_vel_pred_int, chi14_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi15_x_pos_pred_int, chi15_x_vel_pred_int, chi15_x_omega_pred_int, chi15_y_pos_pred_int, chi15_y_vel_pred_int, chi15_y_omega_pred_int, chi15_z_pos_pred_int, chi15_z_vel_pred_int, chi15_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi16_x_pos_pred_int, chi16_x_vel_pred_int, chi16_x_omega_pred_int, chi16_y_pos_pred_int, chi16_y_vel_pred_int, chi16_y_omega_pred_int, chi16_z_pos_pred_int, chi16_z_vel_pred_int, chi16_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi17_x_pos_pred_int, chi17_x_vel_pred_int, chi17_x_omega_pred_int, chi17_y_pos_pred_int, chi17_y_vel_pred_int, chi17_y_omega_pred_int, chi17_z_pos_pred_int, chi17_z_vel_pred_int, chi17_z_omega_pred_int : signed(47 downto 0) := (others => '0');
  signal chi18_x_pos_pred_int, chi18_x_vel_pred_int, chi18_x_omega_pred_int, chi18_y_pos_pred_int, chi18_y_vel_pred_int, chi18_y_omega_pred_int, chi18_z_pos_pred_int, chi18_z_vel_pred_int, chi18_z_omega_pred_int : signed(47 downto 0) := (others => '0');

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

      chi0_wy_vz <= (others => '0'); chi1_wy_vz <= (others => '0'); chi2_wy_vz <= (others => '0');
      chi3_wy_vz <= (others => '0'); chi4_wy_vz <= (others => '0'); chi5_wy_vz <= (others => '0');
      chi6_wy_vz <= (others => '0'); chi7_wy_vz <= (others => '0'); chi8_wy_vz <= (others => '0');
      chi9_wy_vz <= (others => '0'); chi10_wy_vz <= (others => '0'); chi11_wy_vz <= (others => '0');
      chi12_wy_vz <= (others => '0'); chi13_wy_vz <= (others => '0'); chi14_wy_vz <= (others => '0');
      chi15_wy_vz <= (others => '0'); chi16_wy_vz <= (others => '0'); chi17_wy_vz <= (others => '0');
      chi18_wy_vz <= (others => '0');
      chi0_wz_vy <= (others => '0'); chi1_wz_vy <= (others => '0'); chi2_wz_vy <= (others => '0');
      chi3_wz_vy <= (others => '0'); chi4_wz_vy <= (others => '0'); chi5_wz_vy <= (others => '0');
      chi6_wz_vy <= (others => '0'); chi7_wz_vy <= (others => '0'); chi8_wz_vy <= (others => '0');
      chi9_wz_vy <= (others => '0'); chi10_wz_vy <= (others => '0'); chi11_wz_vy <= (others => '0');
      chi12_wz_vy <= (others => '0'); chi13_wz_vy <= (others => '0'); chi14_wz_vy <= (others => '0');
      chi15_wz_vy <= (others => '0'); chi16_wz_vy <= (others => '0'); chi17_wz_vy <= (others => '0');
      chi18_wz_vy <= (others => '0');
      chi0_wz_vx <= (others => '0'); chi1_wz_vx <= (others => '0'); chi2_wz_vx <= (others => '0');
      chi3_wz_vx <= (others => '0'); chi4_wz_vx <= (others => '0'); chi5_wz_vx <= (others => '0');
      chi6_wz_vx <= (others => '0'); chi7_wz_vx <= (others => '0'); chi8_wz_vx <= (others => '0');
      chi9_wz_vx <= (others => '0'); chi10_wz_vx <= (others => '0'); chi11_wz_vx <= (others => '0');
      chi12_wz_vx <= (others => '0'); chi13_wz_vx <= (others => '0'); chi14_wz_vx <= (others => '0');
      chi15_wz_vx <= (others => '0'); chi16_wz_vx <= (others => '0'); chi17_wz_vx <= (others => '0');
      chi18_wz_vx <= (others => '0');
      chi0_wx_vz <= (others => '0'); chi1_wx_vz <= (others => '0'); chi2_wx_vz <= (others => '0');
      chi3_wx_vz <= (others => '0'); chi4_wx_vz <= (others => '0'); chi5_wx_vz <= (others => '0');
      chi6_wx_vz <= (others => '0'); chi7_wx_vz <= (others => '0'); chi8_wx_vz <= (others => '0');
      chi9_wx_vz <= (others => '0'); chi10_wx_vz <= (others => '0'); chi11_wx_vz <= (others => '0');
      chi12_wx_vz <= (others => '0'); chi13_wx_vz <= (others => '0'); chi14_wx_vz <= (others => '0');
      chi15_wx_vz <= (others => '0'); chi16_wx_vz <= (others => '0'); chi17_wx_vz <= (others => '0');
      chi18_wx_vz <= (others => '0');
      chi0_wx_vy <= (others => '0'); chi1_wx_vy <= (others => '0'); chi2_wx_vy <= (others => '0');
      chi3_wx_vy <= (others => '0'); chi4_wx_vy <= (others => '0'); chi5_wx_vy <= (others => '0');
      chi6_wx_vy <= (others => '0'); chi7_wx_vy <= (others => '0'); chi8_wx_vy <= (others => '0');
      chi9_wx_vy <= (others => '0'); chi10_wx_vy <= (others => '0'); chi11_wx_vy <= (others => '0');
      chi12_wx_vy <= (others => '0'); chi13_wx_vy <= (others => '0'); chi14_wx_vy <= (others => '0');
      chi15_wx_vy <= (others => '0'); chi16_wx_vy <= (others => '0'); chi17_wx_vy <= (others => '0');
      chi18_wx_vy <= (others => '0');
      chi0_wy_vx <= (others => '0'); chi1_wy_vx <= (others => '0'); chi2_wy_vx <= (others => '0');
      chi3_wy_vx <= (others => '0'); chi4_wy_vx <= (others => '0'); chi5_wy_vx <= (others => '0');
      chi6_wy_vx <= (others => '0'); chi7_wy_vx <= (others => '0'); chi8_wy_vx <= (others => '0');
      chi9_wy_vx <= (others => '0'); chi10_wy_vx <= (others => '0'); chi11_wy_vx <= (others => '0');
      chi12_wy_vx <= (others => '0'); chi13_wy_vx <= (others => '0'); chi14_wy_vx <= (others => '0');
      chi15_wy_vx <= (others => '0'); chi16_wy_vx <= (others => '0'); chi17_wy_vx <= (others => '0');
      chi18_wy_vx <= (others => '0');

      chi0_wx_sq <= (others => '0'); chi1_wx_sq <= (others => '0'); chi2_wx_sq <= (others => '0');
      chi3_wx_sq <= (others => '0'); chi4_wx_sq <= (others => '0'); chi5_wx_sq <= (others => '0');
      chi6_wx_sq <= (others => '0'); chi7_wx_sq <= (others => '0'); chi8_wx_sq <= (others => '0');
      chi9_wx_sq <= (others => '0'); chi10_wx_sq <= (others => '0'); chi11_wx_sq <= (others => '0');
      chi12_wx_sq <= (others => '0'); chi13_wx_sq <= (others => '0'); chi14_wx_sq <= (others => '0');
      chi15_wx_sq <= (others => '0'); chi16_wx_sq <= (others => '0'); chi17_wx_sq <= (others => '0');
      chi18_wx_sq <= (others => '0');
      chi0_wy_sq <= (others => '0'); chi1_wy_sq <= (others => '0'); chi2_wy_sq <= (others => '0');
      chi3_wy_sq <= (others => '0'); chi4_wy_sq <= (others => '0'); chi5_wy_sq <= (others => '0');
      chi6_wy_sq <= (others => '0'); chi7_wy_sq <= (others => '0'); chi8_wy_sq <= (others => '0');
      chi9_wy_sq <= (others => '0'); chi10_wy_sq <= (others => '0'); chi11_wy_sq <= (others => '0');
      chi12_wy_sq <= (others => '0'); chi13_wy_sq <= (others => '0'); chi14_wy_sq <= (others => '0');
      chi15_wy_sq <= (others => '0'); chi16_wy_sq <= (others => '0'); chi17_wy_sq <= (others => '0');
      chi18_wy_sq <= (others => '0');
      chi0_wz_sq <= (others => '0'); chi1_wz_sq <= (others => '0'); chi2_wz_sq <= (others => '0');
      chi3_wz_sq <= (others => '0'); chi4_wz_sq <= (others => '0'); chi5_wz_sq <= (others => '0');
      chi6_wz_sq <= (others => '0'); chi7_wz_sq <= (others => '0'); chi8_wz_sq <= (others => '0');
      chi9_wz_sq <= (others => '0'); chi10_wz_sq <= (others => '0'); chi11_wz_sq <= (others => '0');
      chi12_wz_sq <= (others => '0'); chi13_wz_sq <= (others => '0'); chi14_wz_sq <= (others => '0');
      chi15_wz_sq <= (others => '0'); chi16_wz_sq <= (others => '0'); chi17_wz_sq <= (others => '0');
      chi18_wz_sq <= (others => '0');

      chi0_cx <= (others => '0'); chi1_cx <= (others => '0'); chi2_cx <= (others => '0');
      chi3_cx <= (others => '0'); chi4_cx <= (others => '0'); chi5_cx <= (others => '0');
      chi6_cx <= (others => '0'); chi7_cx <= (others => '0'); chi8_cx <= (others => '0');
      chi9_cx <= (others => '0'); chi10_cx <= (others => '0'); chi11_cx <= (others => '0');
      chi12_cx <= (others => '0'); chi13_cx <= (others => '0'); chi14_cx <= (others => '0');
      chi15_cx <= (others => '0'); chi16_cx <= (others => '0'); chi17_cx <= (others => '0');
      chi18_cx <= (others => '0');
      chi0_cy <= (others => '0'); chi1_cy <= (others => '0'); chi2_cy <= (others => '0');
      chi3_cy <= (others => '0'); chi4_cy <= (others => '0'); chi5_cy <= (others => '0');
      chi6_cy <= (others => '0'); chi7_cy <= (others => '0'); chi8_cy <= (others => '0');
      chi9_cy <= (others => '0'); chi10_cy <= (others => '0'); chi11_cy <= (others => '0');
      chi12_cy <= (others => '0'); chi13_cy <= (others => '0'); chi14_cy <= (others => '0');
      chi15_cy <= (others => '0'); chi16_cy <= (others => '0'); chi17_cy <= (others => '0');
      chi18_cy <= (others => '0');
      chi0_cz <= (others => '0'); chi1_cz <= (others => '0'); chi2_cz <= (others => '0');
      chi3_cz <= (others => '0'); chi4_cz <= (others => '0'); chi5_cz <= (others => '0');
      chi6_cz <= (others => '0'); chi7_cz <= (others => '0'); chi8_cz <= (others => '0');
      chi9_cz <= (others => '0'); chi10_cz <= (others => '0'); chi11_cz <= (others => '0');
      chi12_cz <= (others => '0'); chi13_cz <= (others => '0'); chi14_cz <= (others => '0');
      chi15_cz <= (others => '0'); chi16_cz <= (others => '0'); chi17_cz <= (others => '0');
      chi18_cz <= (others => '0');

      chi0_omega_sq <= (others => '0'); chi1_omega_sq <= (others => '0'); chi2_omega_sq <= (others => '0');
      chi3_omega_sq <= (others => '0'); chi4_omega_sq <= (others => '0'); chi5_omega_sq <= (others => '0');
      chi6_omega_sq <= (others => '0'); chi7_omega_sq <= (others => '0'); chi8_omega_sq <= (others => '0');
      chi9_omega_sq <= (others => '0'); chi10_omega_sq <= (others => '0'); chi11_omega_sq <= (others => '0');
      chi12_omega_sq <= (others => '0'); chi13_omega_sq <= (others => '0'); chi14_omega_sq <= (others => '0');
      chi15_omega_sq <= (others => '0'); chi16_omega_sq <= (others => '0'); chi17_omega_sq <= (others => '0');
      chi18_omega_sq <= (others => '0');

      chi0_cx_dt <= (others => '0'); chi1_cx_dt <= (others => '0'); chi2_cx_dt <= (others => '0');
      chi3_cx_dt <= (others => '0'); chi4_cx_dt <= (others => '0'); chi5_cx_dt <= (others => '0');
      chi6_cx_dt <= (others => '0'); chi7_cx_dt <= (others => '0'); chi8_cx_dt <= (others => '0');
      chi9_cx_dt <= (others => '0'); chi10_cx_dt <= (others => '0'); chi11_cx_dt <= (others => '0');
      chi12_cx_dt <= (others => '0'); chi13_cx_dt <= (others => '0'); chi14_cx_dt <= (others => '0');
      chi15_cx_dt <= (others => '0'); chi16_cx_dt <= (others => '0'); chi17_cx_dt <= (others => '0');
      chi18_cx_dt <= (others => '0');
      chi0_cy_dt <= (others => '0'); chi1_cy_dt <= (others => '0'); chi2_cy_dt <= (others => '0');
      chi3_cy_dt <= (others => '0'); chi4_cy_dt <= (others => '0'); chi5_cy_dt <= (others => '0');
      chi6_cy_dt <= (others => '0'); chi7_cy_dt <= (others => '0'); chi8_cy_dt <= (others => '0');
      chi9_cy_dt <= (others => '0'); chi10_cy_dt <= (others => '0'); chi11_cy_dt <= (others => '0');
      chi12_cy_dt <= (others => '0'); chi13_cy_dt <= (others => '0'); chi14_cy_dt <= (others => '0');
      chi15_cy_dt <= (others => '0'); chi16_cy_dt <= (others => '0'); chi17_cy_dt <= (others => '0');
      chi18_cy_dt <= (others => '0');
      chi0_cz_dt <= (others => '0'); chi1_cz_dt <= (others => '0'); chi2_cz_dt <= (others => '0');
      chi3_cz_dt <= (others => '0'); chi4_cz_dt <= (others => '0'); chi5_cz_dt <= (others => '0');
      chi6_cz_dt <= (others => '0'); chi7_cz_dt <= (others => '0'); chi8_cz_dt <= (others => '0');
      chi9_cz_dt <= (others => '0'); chi10_cz_dt <= (others => '0'); chi11_cz_dt <= (others => '0');
      chi12_cz_dt <= (others => '0'); chi13_cz_dt <= (others => '0'); chi14_cz_dt <= (others => '0');
      chi15_cz_dt <= (others => '0'); chi16_cz_dt <= (others => '0'); chi17_cz_dt <= (others => '0');
      chi18_cz_dt <= (others => '0');

      chi0_osq_vx <= (others => '0'); chi1_osq_vx <= (others => '0'); chi2_osq_vx <= (others => '0');
      chi3_osq_vx <= (others => '0'); chi4_osq_vx <= (others => '0'); chi5_osq_vx <= (others => '0');
      chi6_osq_vx <= (others => '0'); chi7_osq_vx <= (others => '0'); chi8_osq_vx <= (others => '0');
      chi9_osq_vx <= (others => '0'); chi10_osq_vx <= (others => '0'); chi11_osq_vx <= (others => '0');
      chi12_osq_vx <= (others => '0'); chi13_osq_vx <= (others => '0'); chi14_osq_vx <= (others => '0');
      chi15_osq_vx <= (others => '0'); chi16_osq_vx <= (others => '0'); chi17_osq_vx <= (others => '0');
      chi18_osq_vx <= (others => '0');
      chi0_osq_vy <= (others => '0'); chi1_osq_vy <= (others => '0'); chi2_osq_vy <= (others => '0');
      chi3_osq_vy <= (others => '0'); chi4_osq_vy <= (others => '0'); chi5_osq_vy <= (others => '0');
      chi6_osq_vy <= (others => '0'); chi7_osq_vy <= (others => '0'); chi8_osq_vy <= (others => '0');
      chi9_osq_vy <= (others => '0'); chi10_osq_vy <= (others => '0'); chi11_osq_vy <= (others => '0');
      chi12_osq_vy <= (others => '0'); chi13_osq_vy <= (others => '0'); chi14_osq_vy <= (others => '0');
      chi15_osq_vy <= (others => '0'); chi16_osq_vy <= (others => '0'); chi17_osq_vy <= (others => '0');
      chi18_osq_vy <= (others => '0');
      chi0_osq_vz <= (others => '0'); chi1_osq_vz <= (others => '0'); chi2_osq_vz <= (others => '0');
      chi3_osq_vz <= (others => '0'); chi4_osq_vz <= (others => '0'); chi5_osq_vz <= (others => '0');
      chi6_osq_vz <= (others => '0'); chi7_osq_vz <= (others => '0'); chi8_osq_vz <= (others => '0');
      chi9_osq_vz <= (others => '0'); chi10_osq_vz <= (others => '0'); chi11_osq_vz <= (others => '0');
      chi12_osq_vz <= (others => '0'); chi13_osq_vz <= (others => '0'); chi14_osq_vz <= (others => '0');
      chi15_osq_vz <= (others => '0'); chi16_osq_vz <= (others => '0'); chi17_osq_vz <= (others => '0');
      chi18_osq_vz <= (others => '0');

      chi0_osq_vx_dtsq <= (others => '0'); chi1_osq_vx_dtsq <= (others => '0'); chi2_osq_vx_dtsq <= (others => '0');
      chi3_osq_vx_dtsq <= (others => '0'); chi4_osq_vx_dtsq <= (others => '0'); chi5_osq_vx_dtsq <= (others => '0');
      chi6_osq_vx_dtsq <= (others => '0'); chi7_osq_vx_dtsq <= (others => '0'); chi8_osq_vx_dtsq <= (others => '0');
      chi9_osq_vx_dtsq <= (others => '0'); chi10_osq_vx_dtsq <= (others => '0'); chi11_osq_vx_dtsq <= (others => '0');
      chi12_osq_vx_dtsq <= (others => '0'); chi13_osq_vx_dtsq <= (others => '0'); chi14_osq_vx_dtsq <= (others => '0');
      chi15_osq_vx_dtsq <= (others => '0'); chi16_osq_vx_dtsq <= (others => '0'); chi17_osq_vx_dtsq <= (others => '0');
      chi18_osq_vx_dtsq <= (others => '0');
      chi0_osq_vy_dtsq <= (others => '0'); chi1_osq_vy_dtsq <= (others => '0'); chi2_osq_vy_dtsq <= (others => '0');
      chi3_osq_vy_dtsq <= (others => '0'); chi4_osq_vy_dtsq <= (others => '0'); chi5_osq_vy_dtsq <= (others => '0');
      chi6_osq_vy_dtsq <= (others => '0'); chi7_osq_vy_dtsq <= (others => '0'); chi8_osq_vy_dtsq <= (others => '0');
      chi9_osq_vy_dtsq <= (others => '0'); chi10_osq_vy_dtsq <= (others => '0'); chi11_osq_vy_dtsq <= (others => '0');
      chi12_osq_vy_dtsq <= (others => '0'); chi13_osq_vy_dtsq <= (others => '0'); chi14_osq_vy_dtsq <= (others => '0');
      chi15_osq_vy_dtsq <= (others => '0'); chi16_osq_vy_dtsq <= (others => '0'); chi17_osq_vy_dtsq <= (others => '0');
      chi18_osq_vy_dtsq <= (others => '0');
      chi0_osq_vz_dtsq <= (others => '0'); chi1_osq_vz_dtsq <= (others => '0'); chi2_osq_vz_dtsq <= (others => '0');
      chi3_osq_vz_dtsq <= (others => '0'); chi4_osq_vz_dtsq <= (others => '0'); chi5_osq_vz_dtsq <= (others => '0');
      chi6_osq_vz_dtsq <= (others => '0'); chi7_osq_vz_dtsq <= (others => '0'); chi8_osq_vz_dtsq <= (others => '0');
      chi9_osq_vz_dtsq <= (others => '0'); chi10_osq_vz_dtsq <= (others => '0'); chi11_osq_vz_dtsq <= (others => '0');
      chi12_osq_vz_dtsq <= (others => '0'); chi13_osq_vz_dtsq <= (others => '0'); chi14_osq_vz_dtsq <= (others => '0');
      chi15_osq_vz_dtsq <= (others => '0'); chi16_osq_vz_dtsq <= (others => '0'); chi17_osq_vz_dtsq <= (others => '0');
      chi18_osq_vz_dtsq <= (others => '0');

      chi0_x_pos_pred_int <= (others => '0'); chi0_x_vel_pred_int <= (others => '0'); chi0_x_omega_pred_int <= (others => '0'); chi0_y_pos_pred_int <= (others => '0'); chi0_y_vel_pred_int <= (others => '0'); chi0_y_omega_pred_int <= (others => '0'); chi0_z_pos_pred_int <= (others => '0'); chi0_z_vel_pred_int <= (others => '0'); chi0_z_omega_pred_int <= (others => '0');
      chi1_x_pos_pred_int <= (others => '0'); chi1_x_vel_pred_int <= (others => '0'); chi1_x_omega_pred_int <= (others => '0'); chi1_y_pos_pred_int <= (others => '0'); chi1_y_vel_pred_int <= (others => '0'); chi1_y_omega_pred_int <= (others => '0'); chi1_z_pos_pred_int <= (others => '0'); chi1_z_vel_pred_int <= (others => '0'); chi1_z_omega_pred_int <= (others => '0');
      chi2_x_pos_pred_int <= (others => '0'); chi2_x_vel_pred_int <= (others => '0'); chi2_x_omega_pred_int <= (others => '0'); chi2_y_pos_pred_int <= (others => '0'); chi2_y_vel_pred_int <= (others => '0'); chi2_y_omega_pred_int <= (others => '0'); chi2_z_pos_pred_int <= (others => '0'); chi2_z_vel_pred_int <= (others => '0'); chi2_z_omega_pred_int <= (others => '0');
      chi3_x_pos_pred_int <= (others => '0'); chi3_x_vel_pred_int <= (others => '0'); chi3_x_omega_pred_int <= (others => '0'); chi3_y_pos_pred_int <= (others => '0'); chi3_y_vel_pred_int <= (others => '0'); chi3_y_omega_pred_int <= (others => '0'); chi3_z_pos_pred_int <= (others => '0'); chi3_z_vel_pred_int <= (others => '0'); chi3_z_omega_pred_int <= (others => '0');
      chi4_x_pos_pred_int <= (others => '0'); chi4_x_vel_pred_int <= (others => '0'); chi4_x_omega_pred_int <= (others => '0'); chi4_y_pos_pred_int <= (others => '0'); chi4_y_vel_pred_int <= (others => '0'); chi4_y_omega_pred_int <= (others => '0'); chi4_z_pos_pred_int <= (others => '0'); chi4_z_vel_pred_int <= (others => '0'); chi4_z_omega_pred_int <= (others => '0');
      chi5_x_pos_pred_int <= (others => '0'); chi5_x_vel_pred_int <= (others => '0'); chi5_x_omega_pred_int <= (others => '0'); chi5_y_pos_pred_int <= (others => '0'); chi5_y_vel_pred_int <= (others => '0'); chi5_y_omega_pred_int <= (others => '0'); chi5_z_pos_pred_int <= (others => '0'); chi5_z_vel_pred_int <= (others => '0'); chi5_z_omega_pred_int <= (others => '0');
      chi6_x_pos_pred_int <= (others => '0'); chi6_x_vel_pred_int <= (others => '0'); chi6_x_omega_pred_int <= (others => '0'); chi6_y_pos_pred_int <= (others => '0'); chi6_y_vel_pred_int <= (others => '0'); chi6_y_omega_pred_int <= (others => '0'); chi6_z_pos_pred_int <= (others => '0'); chi6_z_vel_pred_int <= (others => '0'); chi6_z_omega_pred_int <= (others => '0');
      chi7_x_pos_pred_int <= (others => '0'); chi7_x_vel_pred_int <= (others => '0'); chi7_x_omega_pred_int <= (others => '0'); chi7_y_pos_pred_int <= (others => '0'); chi7_y_vel_pred_int <= (others => '0'); chi7_y_omega_pred_int <= (others => '0'); chi7_z_pos_pred_int <= (others => '0'); chi7_z_vel_pred_int <= (others => '0'); chi7_z_omega_pred_int <= (others => '0');
      chi8_x_pos_pred_int <= (others => '0'); chi8_x_vel_pred_int <= (others => '0'); chi8_x_omega_pred_int <= (others => '0'); chi8_y_pos_pred_int <= (others => '0'); chi8_y_vel_pred_int <= (others => '0'); chi8_y_omega_pred_int <= (others => '0'); chi8_z_pos_pred_int <= (others => '0'); chi8_z_vel_pred_int <= (others => '0'); chi8_z_omega_pred_int <= (others => '0');
      chi9_x_pos_pred_int <= (others => '0'); chi9_x_vel_pred_int <= (others => '0'); chi9_x_omega_pred_int <= (others => '0'); chi9_y_pos_pred_int <= (others => '0'); chi9_y_vel_pred_int <= (others => '0'); chi9_y_omega_pred_int <= (others => '0'); chi9_z_pos_pred_int <= (others => '0'); chi9_z_vel_pred_int <= (others => '0'); chi9_z_omega_pred_int <= (others => '0');
      chi10_x_pos_pred_int <= (others => '0'); chi10_x_vel_pred_int <= (others => '0'); chi10_x_omega_pred_int <= (others => '0'); chi10_y_pos_pred_int <= (others => '0'); chi10_y_vel_pred_int <= (others => '0'); chi10_y_omega_pred_int <= (others => '0'); chi10_z_pos_pred_int <= (others => '0'); chi10_z_vel_pred_int <= (others => '0'); chi10_z_omega_pred_int <= (others => '0');
      chi11_x_pos_pred_int <= (others => '0'); chi11_x_vel_pred_int <= (others => '0'); chi11_x_omega_pred_int <= (others => '0'); chi11_y_pos_pred_int <= (others => '0'); chi11_y_vel_pred_int <= (others => '0'); chi11_y_omega_pred_int <= (others => '0'); chi11_z_pos_pred_int <= (others => '0'); chi11_z_vel_pred_int <= (others => '0'); chi11_z_omega_pred_int <= (others => '0');
      chi12_x_pos_pred_int <= (others => '0'); chi12_x_vel_pred_int <= (others => '0'); chi12_x_omega_pred_int <= (others => '0'); chi12_y_pos_pred_int <= (others => '0'); chi12_y_vel_pred_int <= (others => '0'); chi12_y_omega_pred_int <= (others => '0'); chi12_z_pos_pred_int <= (others => '0'); chi12_z_vel_pred_int <= (others => '0'); chi12_z_omega_pred_int <= (others => '0');
      chi13_x_pos_pred_int <= (others => '0'); chi13_x_vel_pred_int <= (others => '0'); chi13_x_omega_pred_int <= (others => '0'); chi13_y_pos_pred_int <= (others => '0'); chi13_y_vel_pred_int <= (others => '0'); chi13_y_omega_pred_int <= (others => '0'); chi13_z_pos_pred_int <= (others => '0'); chi13_z_vel_pred_int <= (others => '0'); chi13_z_omega_pred_int <= (others => '0');
      chi14_x_pos_pred_int <= (others => '0'); chi14_x_vel_pred_int <= (others => '0'); chi14_x_omega_pred_int <= (others => '0'); chi14_y_pos_pred_int <= (others => '0'); chi14_y_vel_pred_int <= (others => '0'); chi14_y_omega_pred_int <= (others => '0'); chi14_z_pos_pred_int <= (others => '0'); chi14_z_vel_pred_int <= (others => '0'); chi14_z_omega_pred_int <= (others => '0');
      chi15_x_pos_pred_int <= (others => '0'); chi15_x_vel_pred_int <= (others => '0'); chi15_x_omega_pred_int <= (others => '0'); chi15_y_pos_pred_int <= (others => '0'); chi15_y_vel_pred_int <= (others => '0'); chi15_y_omega_pred_int <= (others => '0'); chi15_z_pos_pred_int <= (others => '0'); chi15_z_vel_pred_int <= (others => '0'); chi15_z_omega_pred_int <= (others => '0');
      chi16_x_pos_pred_int <= (others => '0'); chi16_x_vel_pred_int <= (others => '0'); chi16_x_omega_pred_int <= (others => '0'); chi16_y_pos_pred_int <= (others => '0'); chi16_y_vel_pred_int <= (others => '0'); chi16_y_omega_pred_int <= (others => '0'); chi16_z_pos_pred_int <= (others => '0'); chi16_z_vel_pred_int <= (others => '0'); chi16_z_omega_pred_int <= (others => '0');
      chi17_x_pos_pred_int <= (others => '0'); chi17_x_vel_pred_int <= (others => '0'); chi17_x_omega_pred_int <= (others => '0'); chi17_y_pos_pred_int <= (others => '0'); chi17_y_vel_pred_int <= (others => '0'); chi17_y_omega_pred_int <= (others => '0'); chi17_z_pos_pred_int <= (others => '0'); chi17_z_vel_pred_int <= (others => '0'); chi17_z_omega_pred_int <= (others => '0');
      chi18_x_pos_pred_int <= (others => '0'); chi18_x_vel_pred_int <= (others => '0'); chi18_x_omega_pred_int <= (others => '0'); chi18_y_pos_pred_int <= (others => '0'); chi18_y_vel_pred_int <= (others => '0'); chi18_y_omega_pred_int <= (others => '0'); chi18_z_pos_pred_int <= (others => '0'); chi18_z_vel_pred_int <= (others => '0'); chi18_z_omega_pred_int <= (others => '0');

    elsif rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if start = '1' then
            state <= MULTIPLY_CROSS_VEL;
          end if;

        when MULTIPLY_CROSS_VEL =>

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

          chi0_wy_vz <= chi0_y_omega_in * chi0_z_vel_in;
          chi1_wy_vz <= chi1_y_omega_in * chi1_z_vel_in;
          chi2_wy_vz <= chi2_y_omega_in * chi2_z_vel_in;
          chi3_wy_vz <= chi3_y_omega_in * chi3_z_vel_in;
          chi4_wy_vz <= chi4_y_omega_in * chi4_z_vel_in;
          chi5_wy_vz <= chi5_y_omega_in * chi5_z_vel_in;
          chi6_wy_vz <= chi6_y_omega_in * chi6_z_vel_in;
          chi7_wy_vz <= chi7_y_omega_in * chi7_z_vel_in;
          chi8_wy_vz <= chi8_y_omega_in * chi8_z_vel_in;
          chi9_wy_vz <= chi9_y_omega_in * chi9_z_vel_in;
          chi10_wy_vz <= chi10_y_omega_in * chi10_z_vel_in;
          chi11_wy_vz <= chi11_y_omega_in * chi11_z_vel_in;
          chi12_wy_vz <= chi12_y_omega_in * chi12_z_vel_in;
          chi13_wy_vz <= chi13_y_omega_in * chi13_z_vel_in;
          chi14_wy_vz <= chi14_y_omega_in * chi14_z_vel_in;
          chi15_wy_vz <= chi15_y_omega_in * chi15_z_vel_in;
          chi16_wy_vz <= chi16_y_omega_in * chi16_z_vel_in;
          chi17_wy_vz <= chi17_y_omega_in * chi17_z_vel_in;
          chi18_wy_vz <= chi18_y_omega_in * chi18_z_vel_in;
          chi0_wz_vy <= chi0_z_omega_in * chi0_y_vel_in;
          chi1_wz_vy <= chi1_z_omega_in * chi1_y_vel_in;
          chi2_wz_vy <= chi2_z_omega_in * chi2_y_vel_in;
          chi3_wz_vy <= chi3_z_omega_in * chi3_y_vel_in;
          chi4_wz_vy <= chi4_z_omega_in * chi4_y_vel_in;
          chi5_wz_vy <= chi5_z_omega_in * chi5_y_vel_in;
          chi6_wz_vy <= chi6_z_omega_in * chi6_y_vel_in;
          chi7_wz_vy <= chi7_z_omega_in * chi7_y_vel_in;
          chi8_wz_vy <= chi8_z_omega_in * chi8_y_vel_in;
          chi9_wz_vy <= chi9_z_omega_in * chi9_y_vel_in;
          chi10_wz_vy <= chi10_z_omega_in * chi10_y_vel_in;
          chi11_wz_vy <= chi11_z_omega_in * chi11_y_vel_in;
          chi12_wz_vy <= chi12_z_omega_in * chi12_y_vel_in;
          chi13_wz_vy <= chi13_z_omega_in * chi13_y_vel_in;
          chi14_wz_vy <= chi14_z_omega_in * chi14_y_vel_in;
          chi15_wz_vy <= chi15_z_omega_in * chi15_y_vel_in;
          chi16_wz_vy <= chi16_z_omega_in * chi16_y_vel_in;
          chi17_wz_vy <= chi17_z_omega_in * chi17_y_vel_in;
          chi18_wz_vy <= chi18_z_omega_in * chi18_y_vel_in;
          chi0_wz_vx <= chi0_z_omega_in * chi0_x_vel_in;
          chi1_wz_vx <= chi1_z_omega_in * chi1_x_vel_in;
          chi2_wz_vx <= chi2_z_omega_in * chi2_x_vel_in;
          chi3_wz_vx <= chi3_z_omega_in * chi3_x_vel_in;
          chi4_wz_vx <= chi4_z_omega_in * chi4_x_vel_in;
          chi5_wz_vx <= chi5_z_omega_in * chi5_x_vel_in;
          chi6_wz_vx <= chi6_z_omega_in * chi6_x_vel_in;
          chi7_wz_vx <= chi7_z_omega_in * chi7_x_vel_in;
          chi8_wz_vx <= chi8_z_omega_in * chi8_x_vel_in;
          chi9_wz_vx <= chi9_z_omega_in * chi9_x_vel_in;
          chi10_wz_vx <= chi10_z_omega_in * chi10_x_vel_in;
          chi11_wz_vx <= chi11_z_omega_in * chi11_x_vel_in;
          chi12_wz_vx <= chi12_z_omega_in * chi12_x_vel_in;
          chi13_wz_vx <= chi13_z_omega_in * chi13_x_vel_in;
          chi14_wz_vx <= chi14_z_omega_in * chi14_x_vel_in;
          chi15_wz_vx <= chi15_z_omega_in * chi15_x_vel_in;
          chi16_wz_vx <= chi16_z_omega_in * chi16_x_vel_in;
          chi17_wz_vx <= chi17_z_omega_in * chi17_x_vel_in;
          chi18_wz_vx <= chi18_z_omega_in * chi18_x_vel_in;
          chi0_wx_vz <= chi0_x_omega_in * chi0_z_vel_in;
          chi1_wx_vz <= chi1_x_omega_in * chi1_z_vel_in;
          chi2_wx_vz <= chi2_x_omega_in * chi2_z_vel_in;
          chi3_wx_vz <= chi3_x_omega_in * chi3_z_vel_in;
          chi4_wx_vz <= chi4_x_omega_in * chi4_z_vel_in;
          chi5_wx_vz <= chi5_x_omega_in * chi5_z_vel_in;
          chi6_wx_vz <= chi6_x_omega_in * chi6_z_vel_in;
          chi7_wx_vz <= chi7_x_omega_in * chi7_z_vel_in;
          chi8_wx_vz <= chi8_x_omega_in * chi8_z_vel_in;
          chi9_wx_vz <= chi9_x_omega_in * chi9_z_vel_in;
          chi10_wx_vz <= chi10_x_omega_in * chi10_z_vel_in;
          chi11_wx_vz <= chi11_x_omega_in * chi11_z_vel_in;
          chi12_wx_vz <= chi12_x_omega_in * chi12_z_vel_in;
          chi13_wx_vz <= chi13_x_omega_in * chi13_z_vel_in;
          chi14_wx_vz <= chi14_x_omega_in * chi14_z_vel_in;
          chi15_wx_vz <= chi15_x_omega_in * chi15_z_vel_in;
          chi16_wx_vz <= chi16_x_omega_in * chi16_z_vel_in;
          chi17_wx_vz <= chi17_x_omega_in * chi17_z_vel_in;
          chi18_wx_vz <= chi18_x_omega_in * chi18_z_vel_in;
          chi0_wx_vy <= chi0_x_omega_in * chi0_y_vel_in;
          chi1_wx_vy <= chi1_x_omega_in * chi1_y_vel_in;
          chi2_wx_vy <= chi2_x_omega_in * chi2_y_vel_in;
          chi3_wx_vy <= chi3_x_omega_in * chi3_y_vel_in;
          chi4_wx_vy <= chi4_x_omega_in * chi4_y_vel_in;
          chi5_wx_vy <= chi5_x_omega_in * chi5_y_vel_in;
          chi6_wx_vy <= chi6_x_omega_in * chi6_y_vel_in;
          chi7_wx_vy <= chi7_x_omega_in * chi7_y_vel_in;
          chi8_wx_vy <= chi8_x_omega_in * chi8_y_vel_in;
          chi9_wx_vy <= chi9_x_omega_in * chi9_y_vel_in;
          chi10_wx_vy <= chi10_x_omega_in * chi10_y_vel_in;
          chi11_wx_vy <= chi11_x_omega_in * chi11_y_vel_in;
          chi12_wx_vy <= chi12_x_omega_in * chi12_y_vel_in;
          chi13_wx_vy <= chi13_x_omega_in * chi13_y_vel_in;
          chi14_wx_vy <= chi14_x_omega_in * chi14_y_vel_in;
          chi15_wx_vy <= chi15_x_omega_in * chi15_y_vel_in;
          chi16_wx_vy <= chi16_x_omega_in * chi16_y_vel_in;
          chi17_wx_vy <= chi17_x_omega_in * chi17_y_vel_in;
          chi18_wx_vy <= chi18_x_omega_in * chi18_y_vel_in;
          chi0_wy_vx <= chi0_y_omega_in * chi0_x_vel_in;
          chi1_wy_vx <= chi1_y_omega_in * chi1_x_vel_in;
          chi2_wy_vx <= chi2_y_omega_in * chi2_x_vel_in;
          chi3_wy_vx <= chi3_y_omega_in * chi3_x_vel_in;
          chi4_wy_vx <= chi4_y_omega_in * chi4_x_vel_in;
          chi5_wy_vx <= chi5_y_omega_in * chi5_x_vel_in;
          chi6_wy_vx <= chi6_y_omega_in * chi6_x_vel_in;
          chi7_wy_vx <= chi7_y_omega_in * chi7_x_vel_in;
          chi8_wy_vx <= chi8_y_omega_in * chi8_x_vel_in;
          chi9_wy_vx <= chi9_y_omega_in * chi9_x_vel_in;
          chi10_wy_vx <= chi10_y_omega_in * chi10_x_vel_in;
          chi11_wy_vx <= chi11_y_omega_in * chi11_x_vel_in;
          chi12_wy_vx <= chi12_y_omega_in * chi12_x_vel_in;
          chi13_wy_vx <= chi13_y_omega_in * chi13_x_vel_in;
          chi14_wy_vx <= chi14_y_omega_in * chi14_x_vel_in;
          chi15_wy_vx <= chi15_y_omega_in * chi15_x_vel_in;
          chi16_wy_vx <= chi16_y_omega_in * chi16_x_vel_in;
          chi17_wy_vx <= chi17_y_omega_in * chi17_x_vel_in;
          chi18_wy_vx <= chi18_y_omega_in * chi18_x_vel_in;

          chi0_wx_sq <= chi0_x_omega_in * chi0_x_omega_in;
          chi1_wx_sq <= chi1_x_omega_in * chi1_x_omega_in;
          chi2_wx_sq <= chi2_x_omega_in * chi2_x_omega_in;
          chi3_wx_sq <= chi3_x_omega_in * chi3_x_omega_in;
          chi4_wx_sq <= chi4_x_omega_in * chi4_x_omega_in;
          chi5_wx_sq <= chi5_x_omega_in * chi5_x_omega_in;
          chi6_wx_sq <= chi6_x_omega_in * chi6_x_omega_in;
          chi7_wx_sq <= chi7_x_omega_in * chi7_x_omega_in;
          chi8_wx_sq <= chi8_x_omega_in * chi8_x_omega_in;
          chi9_wx_sq <= chi9_x_omega_in * chi9_x_omega_in;
          chi10_wx_sq <= chi10_x_omega_in * chi10_x_omega_in;
          chi11_wx_sq <= chi11_x_omega_in * chi11_x_omega_in;
          chi12_wx_sq <= chi12_x_omega_in * chi12_x_omega_in;
          chi13_wx_sq <= chi13_x_omega_in * chi13_x_omega_in;
          chi14_wx_sq <= chi14_x_omega_in * chi14_x_omega_in;
          chi15_wx_sq <= chi15_x_omega_in * chi15_x_omega_in;
          chi16_wx_sq <= chi16_x_omega_in * chi16_x_omega_in;
          chi17_wx_sq <= chi17_x_omega_in * chi17_x_omega_in;
          chi18_wx_sq <= chi18_x_omega_in * chi18_x_omega_in;
          chi0_wy_sq <= chi0_y_omega_in * chi0_y_omega_in;
          chi1_wy_sq <= chi1_y_omega_in * chi1_y_omega_in;
          chi2_wy_sq <= chi2_y_omega_in * chi2_y_omega_in;
          chi3_wy_sq <= chi3_y_omega_in * chi3_y_omega_in;
          chi4_wy_sq <= chi4_y_omega_in * chi4_y_omega_in;
          chi5_wy_sq <= chi5_y_omega_in * chi5_y_omega_in;
          chi6_wy_sq <= chi6_y_omega_in * chi6_y_omega_in;
          chi7_wy_sq <= chi7_y_omega_in * chi7_y_omega_in;
          chi8_wy_sq <= chi8_y_omega_in * chi8_y_omega_in;
          chi9_wy_sq <= chi9_y_omega_in * chi9_y_omega_in;
          chi10_wy_sq <= chi10_y_omega_in * chi10_y_omega_in;
          chi11_wy_sq <= chi11_y_omega_in * chi11_y_omega_in;
          chi12_wy_sq <= chi12_y_omega_in * chi12_y_omega_in;
          chi13_wy_sq <= chi13_y_omega_in * chi13_y_omega_in;
          chi14_wy_sq <= chi14_y_omega_in * chi14_y_omega_in;
          chi15_wy_sq <= chi15_y_omega_in * chi15_y_omega_in;
          chi16_wy_sq <= chi16_y_omega_in * chi16_y_omega_in;
          chi17_wy_sq <= chi17_y_omega_in * chi17_y_omega_in;
          chi18_wy_sq <= chi18_y_omega_in * chi18_y_omega_in;
          chi0_wz_sq <= chi0_z_omega_in * chi0_z_omega_in;
          chi1_wz_sq <= chi1_z_omega_in * chi1_z_omega_in;
          chi2_wz_sq <= chi2_z_omega_in * chi2_z_omega_in;
          chi3_wz_sq <= chi3_z_omega_in * chi3_z_omega_in;
          chi4_wz_sq <= chi4_z_omega_in * chi4_z_omega_in;
          chi5_wz_sq <= chi5_z_omega_in * chi5_z_omega_in;
          chi6_wz_sq <= chi6_z_omega_in * chi6_z_omega_in;
          chi7_wz_sq <= chi7_z_omega_in * chi7_z_omega_in;
          chi8_wz_sq <= chi8_z_omega_in * chi8_z_omega_in;
          chi9_wz_sq <= chi9_z_omega_in * chi9_z_omega_in;
          chi10_wz_sq <= chi10_z_omega_in * chi10_z_omega_in;
          chi11_wz_sq <= chi11_z_omega_in * chi11_z_omega_in;
          chi12_wz_sq <= chi12_z_omega_in * chi12_z_omega_in;
          chi13_wz_sq <= chi13_z_omega_in * chi13_z_omega_in;
          chi14_wz_sq <= chi14_z_omega_in * chi14_z_omega_in;
          chi15_wz_sq <= chi15_z_omega_in * chi15_z_omega_in;
          chi16_wz_sq <= chi16_z_omega_in * chi16_z_omega_in;
          chi17_wz_sq <= chi17_z_omega_in * chi17_z_omega_in;
          chi18_wz_sq <= chi18_z_omega_in * chi18_z_omega_in;

          state <= COMPUTE_CROSS_OMEGASQ;

        when COMPUTE_CROSS_OMEGASQ =>

          chi0_cx <= resize(shift_right(chi0_wy_vz, Q), 48) - resize(shift_right(chi0_wz_vy, Q), 48);
          chi1_cx <= resize(shift_right(chi1_wy_vz, Q), 48) - resize(shift_right(chi1_wz_vy, Q), 48);
          chi2_cx <= resize(shift_right(chi2_wy_vz, Q), 48) - resize(shift_right(chi2_wz_vy, Q), 48);
          chi3_cx <= resize(shift_right(chi3_wy_vz, Q), 48) - resize(shift_right(chi3_wz_vy, Q), 48);
          chi4_cx <= resize(shift_right(chi4_wy_vz, Q), 48) - resize(shift_right(chi4_wz_vy, Q), 48);
          chi5_cx <= resize(shift_right(chi5_wy_vz, Q), 48) - resize(shift_right(chi5_wz_vy, Q), 48);
          chi6_cx <= resize(shift_right(chi6_wy_vz, Q), 48) - resize(shift_right(chi6_wz_vy, Q), 48);
          chi7_cx <= resize(shift_right(chi7_wy_vz, Q), 48) - resize(shift_right(chi7_wz_vy, Q), 48);
          chi8_cx <= resize(shift_right(chi8_wy_vz, Q), 48) - resize(shift_right(chi8_wz_vy, Q), 48);
          chi9_cx <= resize(shift_right(chi9_wy_vz, Q), 48) - resize(shift_right(chi9_wz_vy, Q), 48);
          chi10_cx <= resize(shift_right(chi10_wy_vz, Q), 48) - resize(shift_right(chi10_wz_vy, Q), 48);
          chi11_cx <= resize(shift_right(chi11_wy_vz, Q), 48) - resize(shift_right(chi11_wz_vy, Q), 48);
          chi12_cx <= resize(shift_right(chi12_wy_vz, Q), 48) - resize(shift_right(chi12_wz_vy, Q), 48);
          chi13_cx <= resize(shift_right(chi13_wy_vz, Q), 48) - resize(shift_right(chi13_wz_vy, Q), 48);
          chi14_cx <= resize(shift_right(chi14_wy_vz, Q), 48) - resize(shift_right(chi14_wz_vy, Q), 48);
          chi15_cx <= resize(shift_right(chi15_wy_vz, Q), 48) - resize(shift_right(chi15_wz_vy, Q), 48);
          chi16_cx <= resize(shift_right(chi16_wy_vz, Q), 48) - resize(shift_right(chi16_wz_vy, Q), 48);
          chi17_cx <= resize(shift_right(chi17_wy_vz, Q), 48) - resize(shift_right(chi17_wz_vy, Q), 48);
          chi18_cx <= resize(shift_right(chi18_wy_vz, Q), 48) - resize(shift_right(chi18_wz_vy, Q), 48);
          chi0_cy <= resize(shift_right(chi0_wz_vx, Q), 48) - resize(shift_right(chi0_wx_vz, Q), 48);
          chi1_cy <= resize(shift_right(chi1_wz_vx, Q), 48) - resize(shift_right(chi1_wx_vz, Q), 48);
          chi2_cy <= resize(shift_right(chi2_wz_vx, Q), 48) - resize(shift_right(chi2_wx_vz, Q), 48);
          chi3_cy <= resize(shift_right(chi3_wz_vx, Q), 48) - resize(shift_right(chi3_wx_vz, Q), 48);
          chi4_cy <= resize(shift_right(chi4_wz_vx, Q), 48) - resize(shift_right(chi4_wx_vz, Q), 48);
          chi5_cy <= resize(shift_right(chi5_wz_vx, Q), 48) - resize(shift_right(chi5_wx_vz, Q), 48);
          chi6_cy <= resize(shift_right(chi6_wz_vx, Q), 48) - resize(shift_right(chi6_wx_vz, Q), 48);
          chi7_cy <= resize(shift_right(chi7_wz_vx, Q), 48) - resize(shift_right(chi7_wx_vz, Q), 48);
          chi8_cy <= resize(shift_right(chi8_wz_vx, Q), 48) - resize(shift_right(chi8_wx_vz, Q), 48);
          chi9_cy <= resize(shift_right(chi9_wz_vx, Q), 48) - resize(shift_right(chi9_wx_vz, Q), 48);
          chi10_cy <= resize(shift_right(chi10_wz_vx, Q), 48) - resize(shift_right(chi10_wx_vz, Q), 48);
          chi11_cy <= resize(shift_right(chi11_wz_vx, Q), 48) - resize(shift_right(chi11_wx_vz, Q), 48);
          chi12_cy <= resize(shift_right(chi12_wz_vx, Q), 48) - resize(shift_right(chi12_wx_vz, Q), 48);
          chi13_cy <= resize(shift_right(chi13_wz_vx, Q), 48) - resize(shift_right(chi13_wx_vz, Q), 48);
          chi14_cy <= resize(shift_right(chi14_wz_vx, Q), 48) - resize(shift_right(chi14_wx_vz, Q), 48);
          chi15_cy <= resize(shift_right(chi15_wz_vx, Q), 48) - resize(shift_right(chi15_wx_vz, Q), 48);
          chi16_cy <= resize(shift_right(chi16_wz_vx, Q), 48) - resize(shift_right(chi16_wx_vz, Q), 48);
          chi17_cy <= resize(shift_right(chi17_wz_vx, Q), 48) - resize(shift_right(chi17_wx_vz, Q), 48);
          chi18_cy <= resize(shift_right(chi18_wz_vx, Q), 48) - resize(shift_right(chi18_wx_vz, Q), 48);
          chi0_cz <= resize(shift_right(chi0_wx_vy, Q), 48) - resize(shift_right(chi0_wy_vx, Q), 48);
          chi1_cz <= resize(shift_right(chi1_wx_vy, Q), 48) - resize(shift_right(chi1_wy_vx, Q), 48);
          chi2_cz <= resize(shift_right(chi2_wx_vy, Q), 48) - resize(shift_right(chi2_wy_vx, Q), 48);
          chi3_cz <= resize(shift_right(chi3_wx_vy, Q), 48) - resize(shift_right(chi3_wy_vx, Q), 48);
          chi4_cz <= resize(shift_right(chi4_wx_vy, Q), 48) - resize(shift_right(chi4_wy_vx, Q), 48);
          chi5_cz <= resize(shift_right(chi5_wx_vy, Q), 48) - resize(shift_right(chi5_wy_vx, Q), 48);
          chi6_cz <= resize(shift_right(chi6_wx_vy, Q), 48) - resize(shift_right(chi6_wy_vx, Q), 48);
          chi7_cz <= resize(shift_right(chi7_wx_vy, Q), 48) - resize(shift_right(chi7_wy_vx, Q), 48);
          chi8_cz <= resize(shift_right(chi8_wx_vy, Q), 48) - resize(shift_right(chi8_wy_vx, Q), 48);
          chi9_cz <= resize(shift_right(chi9_wx_vy, Q), 48) - resize(shift_right(chi9_wy_vx, Q), 48);
          chi10_cz <= resize(shift_right(chi10_wx_vy, Q), 48) - resize(shift_right(chi10_wy_vx, Q), 48);
          chi11_cz <= resize(shift_right(chi11_wx_vy, Q), 48) - resize(shift_right(chi11_wy_vx, Q), 48);
          chi12_cz <= resize(shift_right(chi12_wx_vy, Q), 48) - resize(shift_right(chi12_wy_vx, Q), 48);
          chi13_cz <= resize(shift_right(chi13_wx_vy, Q), 48) - resize(shift_right(chi13_wy_vx, Q), 48);
          chi14_cz <= resize(shift_right(chi14_wx_vy, Q), 48) - resize(shift_right(chi14_wy_vx, Q), 48);
          chi15_cz <= resize(shift_right(chi15_wx_vy, Q), 48) - resize(shift_right(chi15_wy_vx, Q), 48);
          chi16_cz <= resize(shift_right(chi16_wx_vy, Q), 48) - resize(shift_right(chi16_wy_vx, Q), 48);
          chi17_cz <= resize(shift_right(chi17_wx_vy, Q), 48) - resize(shift_right(chi17_wy_vx, Q), 48);
          chi18_cz <= resize(shift_right(chi18_wx_vy, Q), 48) - resize(shift_right(chi18_wy_vx, Q), 48);

          chi0_omega_sq <= resize(shift_right(chi0_wx_sq, Q), 48) + resize(shift_right(chi0_wy_sq, Q), 48) + resize(shift_right(chi0_wz_sq, Q), 48);
          chi1_omega_sq <= resize(shift_right(chi1_wx_sq, Q), 48) + resize(shift_right(chi1_wy_sq, Q), 48) + resize(shift_right(chi1_wz_sq, Q), 48);
          chi2_omega_sq <= resize(shift_right(chi2_wx_sq, Q), 48) + resize(shift_right(chi2_wy_sq, Q), 48) + resize(shift_right(chi2_wz_sq, Q), 48);
          chi3_omega_sq <= resize(shift_right(chi3_wx_sq, Q), 48) + resize(shift_right(chi3_wy_sq, Q), 48) + resize(shift_right(chi3_wz_sq, Q), 48);
          chi4_omega_sq <= resize(shift_right(chi4_wx_sq, Q), 48) + resize(shift_right(chi4_wy_sq, Q), 48) + resize(shift_right(chi4_wz_sq, Q), 48);
          chi5_omega_sq <= resize(shift_right(chi5_wx_sq, Q), 48) + resize(shift_right(chi5_wy_sq, Q), 48) + resize(shift_right(chi5_wz_sq, Q), 48);
          chi6_omega_sq <= resize(shift_right(chi6_wx_sq, Q), 48) + resize(shift_right(chi6_wy_sq, Q), 48) + resize(shift_right(chi6_wz_sq, Q), 48);
          chi7_omega_sq <= resize(shift_right(chi7_wx_sq, Q), 48) + resize(shift_right(chi7_wy_sq, Q), 48) + resize(shift_right(chi7_wz_sq, Q), 48);
          chi8_omega_sq <= resize(shift_right(chi8_wx_sq, Q), 48) + resize(shift_right(chi8_wy_sq, Q), 48) + resize(shift_right(chi8_wz_sq, Q), 48);
          chi9_omega_sq <= resize(shift_right(chi9_wx_sq, Q), 48) + resize(shift_right(chi9_wy_sq, Q), 48) + resize(shift_right(chi9_wz_sq, Q), 48);
          chi10_omega_sq <= resize(shift_right(chi10_wx_sq, Q), 48) + resize(shift_right(chi10_wy_sq, Q), 48) + resize(shift_right(chi10_wz_sq, Q), 48);
          chi11_omega_sq <= resize(shift_right(chi11_wx_sq, Q), 48) + resize(shift_right(chi11_wy_sq, Q), 48) + resize(shift_right(chi11_wz_sq, Q), 48);
          chi12_omega_sq <= resize(shift_right(chi12_wx_sq, Q), 48) + resize(shift_right(chi12_wy_sq, Q), 48) + resize(shift_right(chi12_wz_sq, Q), 48);
          chi13_omega_sq <= resize(shift_right(chi13_wx_sq, Q), 48) + resize(shift_right(chi13_wy_sq, Q), 48) + resize(shift_right(chi13_wz_sq, Q), 48);
          chi14_omega_sq <= resize(shift_right(chi14_wx_sq, Q), 48) + resize(shift_right(chi14_wy_sq, Q), 48) + resize(shift_right(chi14_wz_sq, Q), 48);
          chi15_omega_sq <= resize(shift_right(chi15_wx_sq, Q), 48) + resize(shift_right(chi15_wy_sq, Q), 48) + resize(shift_right(chi15_wz_sq, Q), 48);
          chi16_omega_sq <= resize(shift_right(chi16_wx_sq, Q), 48) + resize(shift_right(chi16_wy_sq, Q), 48) + resize(shift_right(chi16_wz_sq, Q), 48);
          chi17_omega_sq <= resize(shift_right(chi17_wx_sq, Q), 48) + resize(shift_right(chi17_wy_sq, Q), 48) + resize(shift_right(chi17_wz_sq, Q), 48);
          chi18_omega_sq <= resize(shift_right(chi18_wx_sq, Q), 48) + resize(shift_right(chi18_wy_sq, Q), 48) + resize(shift_right(chi18_wz_sq, Q), 48);

          chi0_cx_dt <= chi0_cx * DT_Q24_24;
          chi1_cx_dt <= chi1_cx * DT_Q24_24;
          chi2_cx_dt <= chi2_cx * DT_Q24_24;
          chi3_cx_dt <= chi3_cx * DT_Q24_24;
          chi4_cx_dt <= chi4_cx * DT_Q24_24;
          chi5_cx_dt <= chi5_cx * DT_Q24_24;
          chi6_cx_dt <= chi6_cx * DT_Q24_24;
          chi7_cx_dt <= chi7_cx * DT_Q24_24;
          chi8_cx_dt <= chi8_cx * DT_Q24_24;
          chi9_cx_dt <= chi9_cx * DT_Q24_24;
          chi10_cx_dt <= chi10_cx * DT_Q24_24;
          chi11_cx_dt <= chi11_cx * DT_Q24_24;
          chi12_cx_dt <= chi12_cx * DT_Q24_24;
          chi13_cx_dt <= chi13_cx * DT_Q24_24;
          chi14_cx_dt <= chi14_cx * DT_Q24_24;
          chi15_cx_dt <= chi15_cx * DT_Q24_24;
          chi16_cx_dt <= chi16_cx * DT_Q24_24;
          chi17_cx_dt <= chi17_cx * DT_Q24_24;
          chi18_cx_dt <= chi18_cx * DT_Q24_24;
          chi0_cy_dt <= chi0_cy * DT_Q24_24;
          chi1_cy_dt <= chi1_cy * DT_Q24_24;
          chi2_cy_dt <= chi2_cy * DT_Q24_24;
          chi3_cy_dt <= chi3_cy * DT_Q24_24;
          chi4_cy_dt <= chi4_cy * DT_Q24_24;
          chi5_cy_dt <= chi5_cy * DT_Q24_24;
          chi6_cy_dt <= chi6_cy * DT_Q24_24;
          chi7_cy_dt <= chi7_cy * DT_Q24_24;
          chi8_cy_dt <= chi8_cy * DT_Q24_24;
          chi9_cy_dt <= chi9_cy * DT_Q24_24;
          chi10_cy_dt <= chi10_cy * DT_Q24_24;
          chi11_cy_dt <= chi11_cy * DT_Q24_24;
          chi12_cy_dt <= chi12_cy * DT_Q24_24;
          chi13_cy_dt <= chi13_cy * DT_Q24_24;
          chi14_cy_dt <= chi14_cy * DT_Q24_24;
          chi15_cy_dt <= chi15_cy * DT_Q24_24;
          chi16_cy_dt <= chi16_cy * DT_Q24_24;
          chi17_cy_dt <= chi17_cy * DT_Q24_24;
          chi18_cy_dt <= chi18_cy * DT_Q24_24;
          chi0_cz_dt <= chi0_cz * DT_Q24_24;
          chi1_cz_dt <= chi1_cz * DT_Q24_24;
          chi2_cz_dt <= chi2_cz * DT_Q24_24;
          chi3_cz_dt <= chi3_cz * DT_Q24_24;
          chi4_cz_dt <= chi4_cz * DT_Q24_24;
          chi5_cz_dt <= chi5_cz * DT_Q24_24;
          chi6_cz_dt <= chi6_cz * DT_Q24_24;
          chi7_cz_dt <= chi7_cz * DT_Q24_24;
          chi8_cz_dt <= chi8_cz * DT_Q24_24;
          chi9_cz_dt <= chi9_cz * DT_Q24_24;
          chi10_cz_dt <= chi10_cz * DT_Q24_24;
          chi11_cz_dt <= chi11_cz * DT_Q24_24;
          chi12_cz_dt <= chi12_cz * DT_Q24_24;
          chi13_cz_dt <= chi13_cz * DT_Q24_24;
          chi14_cz_dt <= chi14_cz * DT_Q24_24;
          chi15_cz_dt <= chi15_cz * DT_Q24_24;
          chi16_cz_dt <= chi16_cz * DT_Q24_24;
          chi17_cz_dt <= chi17_cz * DT_Q24_24;
          chi18_cz_dt <= chi18_cz * DT_Q24_24;

          chi0_osq_vx <= chi0_omega_sq * chi0_x_vel_in;
          chi1_osq_vx <= chi1_omega_sq * chi1_x_vel_in;
          chi2_osq_vx <= chi2_omega_sq * chi2_x_vel_in;
          chi3_osq_vx <= chi3_omega_sq * chi3_x_vel_in;
          chi4_osq_vx <= chi4_omega_sq * chi4_x_vel_in;
          chi5_osq_vx <= chi5_omega_sq * chi5_x_vel_in;
          chi6_osq_vx <= chi6_omega_sq * chi6_x_vel_in;
          chi7_osq_vx <= chi7_omega_sq * chi7_x_vel_in;
          chi8_osq_vx <= chi8_omega_sq * chi8_x_vel_in;
          chi9_osq_vx <= chi9_omega_sq * chi9_x_vel_in;
          chi10_osq_vx <= chi10_omega_sq * chi10_x_vel_in;
          chi11_osq_vx <= chi11_omega_sq * chi11_x_vel_in;
          chi12_osq_vx <= chi12_omega_sq * chi12_x_vel_in;
          chi13_osq_vx <= chi13_omega_sq * chi13_x_vel_in;
          chi14_osq_vx <= chi14_omega_sq * chi14_x_vel_in;
          chi15_osq_vx <= chi15_omega_sq * chi15_x_vel_in;
          chi16_osq_vx <= chi16_omega_sq * chi16_x_vel_in;
          chi17_osq_vx <= chi17_omega_sq * chi17_x_vel_in;
          chi18_osq_vx <= chi18_omega_sq * chi18_x_vel_in;
          chi0_osq_vy <= chi0_omega_sq * chi0_y_vel_in;
          chi1_osq_vy <= chi1_omega_sq * chi1_y_vel_in;
          chi2_osq_vy <= chi2_omega_sq * chi2_y_vel_in;
          chi3_osq_vy <= chi3_omega_sq * chi3_y_vel_in;
          chi4_osq_vy <= chi4_omega_sq * chi4_y_vel_in;
          chi5_osq_vy <= chi5_omega_sq * chi5_y_vel_in;
          chi6_osq_vy <= chi6_omega_sq * chi6_y_vel_in;
          chi7_osq_vy <= chi7_omega_sq * chi7_y_vel_in;
          chi8_osq_vy <= chi8_omega_sq * chi8_y_vel_in;
          chi9_osq_vy <= chi9_omega_sq * chi9_y_vel_in;
          chi10_osq_vy <= chi10_omega_sq * chi10_y_vel_in;
          chi11_osq_vy <= chi11_omega_sq * chi11_y_vel_in;
          chi12_osq_vy <= chi12_omega_sq * chi12_y_vel_in;
          chi13_osq_vy <= chi13_omega_sq * chi13_y_vel_in;
          chi14_osq_vy <= chi14_omega_sq * chi14_y_vel_in;
          chi15_osq_vy <= chi15_omega_sq * chi15_y_vel_in;
          chi16_osq_vy <= chi16_omega_sq * chi16_y_vel_in;
          chi17_osq_vy <= chi17_omega_sq * chi17_y_vel_in;
          chi18_osq_vy <= chi18_omega_sq * chi18_y_vel_in;
          chi0_osq_vz <= chi0_omega_sq * chi0_z_vel_in;
          chi1_osq_vz <= chi1_omega_sq * chi1_z_vel_in;
          chi2_osq_vz <= chi2_omega_sq * chi2_z_vel_in;
          chi3_osq_vz <= chi3_omega_sq * chi3_z_vel_in;
          chi4_osq_vz <= chi4_omega_sq * chi4_z_vel_in;
          chi5_osq_vz <= chi5_omega_sq * chi5_z_vel_in;
          chi6_osq_vz <= chi6_omega_sq * chi6_z_vel_in;
          chi7_osq_vz <= chi7_omega_sq * chi7_z_vel_in;
          chi8_osq_vz <= chi8_omega_sq * chi8_z_vel_in;
          chi9_osq_vz <= chi9_omega_sq * chi9_z_vel_in;
          chi10_osq_vz <= chi10_omega_sq * chi10_z_vel_in;
          chi11_osq_vz <= chi11_omega_sq * chi11_z_vel_in;
          chi12_osq_vz <= chi12_omega_sq * chi12_z_vel_in;
          chi13_osq_vz <= chi13_omega_sq * chi13_z_vel_in;
          chi14_osq_vz <= chi14_omega_sq * chi14_z_vel_in;
          chi15_osq_vz <= chi15_omega_sq * chi15_z_vel_in;
          chi16_osq_vz <= chi16_omega_sq * chi16_z_vel_in;
          chi17_osq_vz <= chi17_omega_sq * chi17_z_vel_in;
          chi18_osq_vz <= chi18_omega_sq * chi18_z_vel_in;

          state <= COMPUTE_CORRECTION;

        when COMPUTE_CORRECTION =>

          chi0_osq_vx_dtsq <= resize(shift_right(chi0_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi1_osq_vx_dtsq <= resize(shift_right(chi1_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi2_osq_vx_dtsq <= resize(shift_right(chi2_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi3_osq_vx_dtsq <= resize(shift_right(chi3_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi4_osq_vx_dtsq <= resize(shift_right(chi4_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi5_osq_vx_dtsq <= resize(shift_right(chi5_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi6_osq_vx_dtsq <= resize(shift_right(chi6_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi7_osq_vx_dtsq <= resize(shift_right(chi7_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi8_osq_vx_dtsq <= resize(shift_right(chi8_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi9_osq_vx_dtsq <= resize(shift_right(chi9_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi10_osq_vx_dtsq <= resize(shift_right(chi10_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi11_osq_vx_dtsq <= resize(shift_right(chi11_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi12_osq_vx_dtsq <= resize(shift_right(chi12_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi13_osq_vx_dtsq <= resize(shift_right(chi13_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi14_osq_vx_dtsq <= resize(shift_right(chi14_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi15_osq_vx_dtsq <= resize(shift_right(chi15_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi16_osq_vx_dtsq <= resize(shift_right(chi16_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi17_osq_vx_dtsq <= resize(shift_right(chi17_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi18_osq_vx_dtsq <= resize(shift_right(chi18_osq_vx, Q), 48) * DT_SQ_Q24_24;
          chi0_osq_vy_dtsq <= resize(shift_right(chi0_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi1_osq_vy_dtsq <= resize(shift_right(chi1_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi2_osq_vy_dtsq <= resize(shift_right(chi2_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi3_osq_vy_dtsq <= resize(shift_right(chi3_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi4_osq_vy_dtsq <= resize(shift_right(chi4_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi5_osq_vy_dtsq <= resize(shift_right(chi5_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi6_osq_vy_dtsq <= resize(shift_right(chi6_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi7_osq_vy_dtsq <= resize(shift_right(chi7_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi8_osq_vy_dtsq <= resize(shift_right(chi8_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi9_osq_vy_dtsq <= resize(shift_right(chi9_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi10_osq_vy_dtsq <= resize(shift_right(chi10_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi11_osq_vy_dtsq <= resize(shift_right(chi11_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi12_osq_vy_dtsq <= resize(shift_right(chi12_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi13_osq_vy_dtsq <= resize(shift_right(chi13_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi14_osq_vy_dtsq <= resize(shift_right(chi14_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi15_osq_vy_dtsq <= resize(shift_right(chi15_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi16_osq_vy_dtsq <= resize(shift_right(chi16_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi17_osq_vy_dtsq <= resize(shift_right(chi17_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi18_osq_vy_dtsq <= resize(shift_right(chi18_osq_vy, Q), 48) * DT_SQ_Q24_24;
          chi0_osq_vz_dtsq <= resize(shift_right(chi0_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi1_osq_vz_dtsq <= resize(shift_right(chi1_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi2_osq_vz_dtsq <= resize(shift_right(chi2_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi3_osq_vz_dtsq <= resize(shift_right(chi3_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi4_osq_vz_dtsq <= resize(shift_right(chi4_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi5_osq_vz_dtsq <= resize(shift_right(chi5_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi6_osq_vz_dtsq <= resize(shift_right(chi6_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi7_osq_vz_dtsq <= resize(shift_right(chi7_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi8_osq_vz_dtsq <= resize(shift_right(chi8_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi9_osq_vz_dtsq <= resize(shift_right(chi9_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi10_osq_vz_dtsq <= resize(shift_right(chi10_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi11_osq_vz_dtsq <= resize(shift_right(chi11_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi12_osq_vz_dtsq <= resize(shift_right(chi12_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi13_osq_vz_dtsq <= resize(shift_right(chi13_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi14_osq_vz_dtsq <= resize(shift_right(chi14_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi15_osq_vz_dtsq <= resize(shift_right(chi15_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi16_osq_vz_dtsq <= resize(shift_right(chi16_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi17_osq_vz_dtsq <= resize(shift_right(chi17_osq_vz, Q), 48) * DT_SQ_Q24_24;
          chi18_osq_vz_dtsq <= resize(shift_right(chi18_osq_vz, Q), 48) * DT_SQ_Q24_24;

          state <= CALCULATE;

        when CALCULATE =>

          chi0_x_pos_pred_int <= chi0_x_pos_in + resize(shift_right(chi0_x_vel_dt, Q), 48);
          chi0_x_vel_pred_int <= chi0_x_vel_in + resize(shift_right(chi0_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi0_osq_vx_dtsq, 96), 2*Q), 48);
          chi0_x_omega_pred_int <= chi0_x_omega_in;
          chi0_y_pos_pred_int <= chi0_y_pos_in + resize(shift_right(chi0_y_vel_dt, Q), 48);
          chi0_y_vel_pred_int <= chi0_y_vel_in + resize(shift_right(chi0_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi0_osq_vy_dtsq, 96), 2*Q), 48);
          chi0_y_omega_pred_int <= chi0_y_omega_in;
          chi0_z_pos_pred_int <= chi0_z_pos_in + resize(shift_right(chi0_z_vel_dt, Q), 48);
          chi0_z_vel_pred_int <= chi0_z_vel_in + resize(shift_right(chi0_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi0_osq_vz_dtsq, 96), 2*Q), 48);
          chi0_z_omega_pred_int <= chi0_z_omega_in;

          chi1_x_pos_pred_int <= chi1_x_pos_in + resize(shift_right(chi1_x_vel_dt, Q), 48);
          chi1_x_vel_pred_int <= chi1_x_vel_in + resize(shift_right(chi1_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi1_osq_vx_dtsq, 96), 2*Q), 48);
          chi1_x_omega_pred_int <= chi1_x_omega_in;
          chi1_y_pos_pred_int <= chi1_y_pos_in + resize(shift_right(chi1_y_vel_dt, Q), 48);
          chi1_y_vel_pred_int <= chi1_y_vel_in + resize(shift_right(chi1_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi1_osq_vy_dtsq, 96), 2*Q), 48);
          chi1_y_omega_pred_int <= chi1_y_omega_in;
          chi1_z_pos_pred_int <= chi1_z_pos_in + resize(shift_right(chi1_z_vel_dt, Q), 48);
          chi1_z_vel_pred_int <= chi1_z_vel_in + resize(shift_right(chi1_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi1_osq_vz_dtsq, 96), 2*Q), 48);
          chi1_z_omega_pred_int <= chi1_z_omega_in;

          chi2_x_pos_pred_int <= chi2_x_pos_in + resize(shift_right(chi2_x_vel_dt, Q), 48);
          chi2_x_vel_pred_int <= chi2_x_vel_in + resize(shift_right(chi2_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi2_osq_vx_dtsq, 96), 2*Q), 48);
          chi2_x_omega_pred_int <= chi2_x_omega_in;
          chi2_y_pos_pred_int <= chi2_y_pos_in + resize(shift_right(chi2_y_vel_dt, Q), 48);
          chi2_y_vel_pred_int <= chi2_y_vel_in + resize(shift_right(chi2_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi2_osq_vy_dtsq, 96), 2*Q), 48);
          chi2_y_omega_pred_int <= chi2_y_omega_in;
          chi2_z_pos_pred_int <= chi2_z_pos_in + resize(shift_right(chi2_z_vel_dt, Q), 48);
          chi2_z_vel_pred_int <= chi2_z_vel_in + resize(shift_right(chi2_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi2_osq_vz_dtsq, 96), 2*Q), 48);
          chi2_z_omega_pred_int <= chi2_z_omega_in;

          chi3_x_pos_pred_int <= chi3_x_pos_in + resize(shift_right(chi3_x_vel_dt, Q), 48);
          chi3_x_vel_pred_int <= chi3_x_vel_in + resize(shift_right(chi3_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi3_osq_vx_dtsq, 96), 2*Q), 48);
          chi3_x_omega_pred_int <= chi3_x_omega_in;
          chi3_y_pos_pred_int <= chi3_y_pos_in + resize(shift_right(chi3_y_vel_dt, Q), 48);
          chi3_y_vel_pred_int <= chi3_y_vel_in + resize(shift_right(chi3_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi3_osq_vy_dtsq, 96), 2*Q), 48);
          chi3_y_omega_pred_int <= chi3_y_omega_in;
          chi3_z_pos_pred_int <= chi3_z_pos_in + resize(shift_right(chi3_z_vel_dt, Q), 48);
          chi3_z_vel_pred_int <= chi3_z_vel_in + resize(shift_right(chi3_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi3_osq_vz_dtsq, 96), 2*Q), 48);
          chi3_z_omega_pred_int <= chi3_z_omega_in;

          chi4_x_pos_pred_int <= chi4_x_pos_in + resize(shift_right(chi4_x_vel_dt, Q), 48);
          chi4_x_vel_pred_int <= chi4_x_vel_in + resize(shift_right(chi4_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi4_osq_vx_dtsq, 96), 2*Q), 48);
          chi4_x_omega_pred_int <= chi4_x_omega_in;
          chi4_y_pos_pred_int <= chi4_y_pos_in + resize(shift_right(chi4_y_vel_dt, Q), 48);
          chi4_y_vel_pred_int <= chi4_y_vel_in + resize(shift_right(chi4_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi4_osq_vy_dtsq, 96), 2*Q), 48);
          chi4_y_omega_pred_int <= chi4_y_omega_in;
          chi4_z_pos_pred_int <= chi4_z_pos_in + resize(shift_right(chi4_z_vel_dt, Q), 48);
          chi4_z_vel_pred_int <= chi4_z_vel_in + resize(shift_right(chi4_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi4_osq_vz_dtsq, 96), 2*Q), 48);
          chi4_z_omega_pred_int <= chi4_z_omega_in;

          chi5_x_pos_pred_int <= chi5_x_pos_in + resize(shift_right(chi5_x_vel_dt, Q), 48);
          chi5_x_vel_pred_int <= chi5_x_vel_in + resize(shift_right(chi5_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi5_osq_vx_dtsq, 96), 2*Q), 48);
          chi5_x_omega_pred_int <= chi5_x_omega_in;
          chi5_y_pos_pred_int <= chi5_y_pos_in + resize(shift_right(chi5_y_vel_dt, Q), 48);
          chi5_y_vel_pred_int <= chi5_y_vel_in + resize(shift_right(chi5_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi5_osq_vy_dtsq, 96), 2*Q), 48);
          chi5_y_omega_pred_int <= chi5_y_omega_in;
          chi5_z_pos_pred_int <= chi5_z_pos_in + resize(shift_right(chi5_z_vel_dt, Q), 48);
          chi5_z_vel_pred_int <= chi5_z_vel_in + resize(shift_right(chi5_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi5_osq_vz_dtsq, 96), 2*Q), 48);
          chi5_z_omega_pred_int <= chi5_z_omega_in;

          chi6_x_pos_pred_int <= chi6_x_pos_in + resize(shift_right(chi6_x_vel_dt, Q), 48);
          chi6_x_vel_pred_int <= chi6_x_vel_in + resize(shift_right(chi6_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi6_osq_vx_dtsq, 96), 2*Q), 48);
          chi6_x_omega_pred_int <= chi6_x_omega_in;
          chi6_y_pos_pred_int <= chi6_y_pos_in + resize(shift_right(chi6_y_vel_dt, Q), 48);
          chi6_y_vel_pred_int <= chi6_y_vel_in + resize(shift_right(chi6_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi6_osq_vy_dtsq, 96), 2*Q), 48);
          chi6_y_omega_pred_int <= chi6_y_omega_in;
          chi6_z_pos_pred_int <= chi6_z_pos_in + resize(shift_right(chi6_z_vel_dt, Q), 48);
          chi6_z_vel_pred_int <= chi6_z_vel_in + resize(shift_right(chi6_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi6_osq_vz_dtsq, 96), 2*Q), 48);
          chi6_z_omega_pred_int <= chi6_z_omega_in;

          chi7_x_pos_pred_int <= chi7_x_pos_in + resize(shift_right(chi7_x_vel_dt, Q), 48);
          chi7_x_vel_pred_int <= chi7_x_vel_in + resize(shift_right(chi7_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi7_osq_vx_dtsq, 96), 2*Q), 48);
          chi7_x_omega_pred_int <= chi7_x_omega_in;
          chi7_y_pos_pred_int <= chi7_y_pos_in + resize(shift_right(chi7_y_vel_dt, Q), 48);
          chi7_y_vel_pred_int <= chi7_y_vel_in + resize(shift_right(chi7_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi7_osq_vy_dtsq, 96), 2*Q), 48);
          chi7_y_omega_pred_int <= chi7_y_omega_in;
          chi7_z_pos_pred_int <= chi7_z_pos_in + resize(shift_right(chi7_z_vel_dt, Q), 48);
          chi7_z_vel_pred_int <= chi7_z_vel_in + resize(shift_right(chi7_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi7_osq_vz_dtsq, 96), 2*Q), 48);
          chi7_z_omega_pred_int <= chi7_z_omega_in;

          chi8_x_pos_pred_int <= chi8_x_pos_in + resize(shift_right(chi8_x_vel_dt, Q), 48);
          chi8_x_vel_pred_int <= chi8_x_vel_in + resize(shift_right(chi8_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi8_osq_vx_dtsq, 96), 2*Q), 48);
          chi8_x_omega_pred_int <= chi8_x_omega_in;
          chi8_y_pos_pred_int <= chi8_y_pos_in + resize(shift_right(chi8_y_vel_dt, Q), 48);
          chi8_y_vel_pred_int <= chi8_y_vel_in + resize(shift_right(chi8_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi8_osq_vy_dtsq, 96), 2*Q), 48);
          chi8_y_omega_pred_int <= chi8_y_omega_in;
          chi8_z_pos_pred_int <= chi8_z_pos_in + resize(shift_right(chi8_z_vel_dt, Q), 48);
          chi8_z_vel_pred_int <= chi8_z_vel_in + resize(shift_right(chi8_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi8_osq_vz_dtsq, 96), 2*Q), 48);
          chi8_z_omega_pred_int <= chi8_z_omega_in;

          chi9_x_pos_pred_int <= chi9_x_pos_in + resize(shift_right(chi9_x_vel_dt, Q), 48);
          chi9_x_vel_pred_int <= chi9_x_vel_in + resize(shift_right(chi9_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi9_osq_vx_dtsq, 96), 2*Q), 48);
          chi9_x_omega_pred_int <= chi9_x_omega_in;
          chi9_y_pos_pred_int <= chi9_y_pos_in + resize(shift_right(chi9_y_vel_dt, Q), 48);
          chi9_y_vel_pred_int <= chi9_y_vel_in + resize(shift_right(chi9_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi9_osq_vy_dtsq, 96), 2*Q), 48);
          chi9_y_omega_pred_int <= chi9_y_omega_in;
          chi9_z_pos_pred_int <= chi9_z_pos_in + resize(shift_right(chi9_z_vel_dt, Q), 48);
          chi9_z_vel_pred_int <= chi9_z_vel_in + resize(shift_right(chi9_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi9_osq_vz_dtsq, 96), 2*Q), 48);
          chi9_z_omega_pred_int <= chi9_z_omega_in;

          chi10_x_pos_pred_int <= chi10_x_pos_in + resize(shift_right(chi10_x_vel_dt, Q), 48);
          chi10_x_vel_pred_int <= chi10_x_vel_in + resize(shift_right(chi10_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi10_osq_vx_dtsq, 96), 2*Q), 48);
          chi10_x_omega_pred_int <= chi10_x_omega_in;
          chi10_y_pos_pred_int <= chi10_y_pos_in + resize(shift_right(chi10_y_vel_dt, Q), 48);
          chi10_y_vel_pred_int <= chi10_y_vel_in + resize(shift_right(chi10_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi10_osq_vy_dtsq, 96), 2*Q), 48);
          chi10_y_omega_pred_int <= chi10_y_omega_in;
          chi10_z_pos_pred_int <= chi10_z_pos_in + resize(shift_right(chi10_z_vel_dt, Q), 48);
          chi10_z_vel_pred_int <= chi10_z_vel_in + resize(shift_right(chi10_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi10_osq_vz_dtsq, 96), 2*Q), 48);
          chi10_z_omega_pred_int <= chi10_z_omega_in;

          chi11_x_pos_pred_int <= chi11_x_pos_in + resize(shift_right(chi11_x_vel_dt, Q), 48);
          chi11_x_vel_pred_int <= chi11_x_vel_in + resize(shift_right(chi11_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi11_osq_vx_dtsq, 96), 2*Q), 48);
          chi11_x_omega_pred_int <= chi11_x_omega_in;
          chi11_y_pos_pred_int <= chi11_y_pos_in + resize(shift_right(chi11_y_vel_dt, Q), 48);
          chi11_y_vel_pred_int <= chi11_y_vel_in + resize(shift_right(chi11_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi11_osq_vy_dtsq, 96), 2*Q), 48);
          chi11_y_omega_pred_int <= chi11_y_omega_in;
          chi11_z_pos_pred_int <= chi11_z_pos_in + resize(shift_right(chi11_z_vel_dt, Q), 48);
          chi11_z_vel_pred_int <= chi11_z_vel_in + resize(shift_right(chi11_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi11_osq_vz_dtsq, 96), 2*Q), 48);
          chi11_z_omega_pred_int <= chi11_z_omega_in;

          chi12_x_pos_pred_int <= chi12_x_pos_in + resize(shift_right(chi12_x_vel_dt, Q), 48);
          chi12_x_vel_pred_int <= chi12_x_vel_in + resize(shift_right(chi12_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi12_osq_vx_dtsq, 96), 2*Q), 48);
          chi12_x_omega_pred_int <= chi12_x_omega_in;
          chi12_y_pos_pred_int <= chi12_y_pos_in + resize(shift_right(chi12_y_vel_dt, Q), 48);
          chi12_y_vel_pred_int <= chi12_y_vel_in + resize(shift_right(chi12_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi12_osq_vy_dtsq, 96), 2*Q), 48);
          chi12_y_omega_pred_int <= chi12_y_omega_in;
          chi12_z_pos_pred_int <= chi12_z_pos_in + resize(shift_right(chi12_z_vel_dt, Q), 48);
          chi12_z_vel_pred_int <= chi12_z_vel_in + resize(shift_right(chi12_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi12_osq_vz_dtsq, 96), 2*Q), 48);
          chi12_z_omega_pred_int <= chi12_z_omega_in;

          chi13_x_pos_pred_int <= chi13_x_pos_in + resize(shift_right(chi13_x_vel_dt, Q), 48);
          chi13_x_vel_pred_int <= chi13_x_vel_in + resize(shift_right(chi13_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi13_osq_vx_dtsq, 96), 2*Q), 48);
          chi13_x_omega_pred_int <= chi13_x_omega_in;
          chi13_y_pos_pred_int <= chi13_y_pos_in + resize(shift_right(chi13_y_vel_dt, Q), 48);
          chi13_y_vel_pred_int <= chi13_y_vel_in + resize(shift_right(chi13_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi13_osq_vy_dtsq, 96), 2*Q), 48);
          chi13_y_omega_pred_int <= chi13_y_omega_in;
          chi13_z_pos_pred_int <= chi13_z_pos_in + resize(shift_right(chi13_z_vel_dt, Q), 48);
          chi13_z_vel_pred_int <= chi13_z_vel_in + resize(shift_right(chi13_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi13_osq_vz_dtsq, 96), 2*Q), 48);
          chi13_z_omega_pred_int <= chi13_z_omega_in;

          chi14_x_pos_pred_int <= chi14_x_pos_in + resize(shift_right(chi14_x_vel_dt, Q), 48);
          chi14_x_vel_pred_int <= chi14_x_vel_in + resize(shift_right(chi14_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi14_osq_vx_dtsq, 96), 2*Q), 48);
          chi14_x_omega_pred_int <= chi14_x_omega_in;
          chi14_y_pos_pred_int <= chi14_y_pos_in + resize(shift_right(chi14_y_vel_dt, Q), 48);
          chi14_y_vel_pred_int <= chi14_y_vel_in + resize(shift_right(chi14_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi14_osq_vy_dtsq, 96), 2*Q), 48);
          chi14_y_omega_pred_int <= chi14_y_omega_in;
          chi14_z_pos_pred_int <= chi14_z_pos_in + resize(shift_right(chi14_z_vel_dt, Q), 48);
          chi14_z_vel_pred_int <= chi14_z_vel_in + resize(shift_right(chi14_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi14_osq_vz_dtsq, 96), 2*Q), 48);
          chi14_z_omega_pred_int <= chi14_z_omega_in;

          chi15_x_pos_pred_int <= chi15_x_pos_in + resize(shift_right(chi15_x_vel_dt, Q), 48);
          chi15_x_vel_pred_int <= chi15_x_vel_in + resize(shift_right(chi15_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi15_osq_vx_dtsq, 96), 2*Q), 48);
          chi15_x_omega_pred_int <= chi15_x_omega_in;
          chi15_y_pos_pred_int <= chi15_y_pos_in + resize(shift_right(chi15_y_vel_dt, Q), 48);
          chi15_y_vel_pred_int <= chi15_y_vel_in + resize(shift_right(chi15_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi15_osq_vy_dtsq, 96), 2*Q), 48);
          chi15_y_omega_pred_int <= chi15_y_omega_in;
          chi15_z_pos_pred_int <= chi15_z_pos_in + resize(shift_right(chi15_z_vel_dt, Q), 48);
          chi15_z_vel_pred_int <= chi15_z_vel_in + resize(shift_right(chi15_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi15_osq_vz_dtsq, 96), 2*Q), 48);
          chi15_z_omega_pred_int <= chi15_z_omega_in;

          chi16_x_pos_pred_int <= chi16_x_pos_in + resize(shift_right(chi16_x_vel_dt, Q), 48);
          chi16_x_vel_pred_int <= chi16_x_vel_in + resize(shift_right(chi16_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi16_osq_vx_dtsq, 96), 2*Q), 48);
          chi16_x_omega_pred_int <= chi16_x_omega_in;
          chi16_y_pos_pred_int <= chi16_y_pos_in + resize(shift_right(chi16_y_vel_dt, Q), 48);
          chi16_y_vel_pred_int <= chi16_y_vel_in + resize(shift_right(chi16_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi16_osq_vy_dtsq, 96), 2*Q), 48);
          chi16_y_omega_pred_int <= chi16_y_omega_in;
          chi16_z_pos_pred_int <= chi16_z_pos_in + resize(shift_right(chi16_z_vel_dt, Q), 48);
          chi16_z_vel_pred_int <= chi16_z_vel_in + resize(shift_right(chi16_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi16_osq_vz_dtsq, 96), 2*Q), 48);
          chi16_z_omega_pred_int <= chi16_z_omega_in;

          chi17_x_pos_pred_int <= chi17_x_pos_in + resize(shift_right(chi17_x_vel_dt, Q), 48);
          chi17_x_vel_pred_int <= chi17_x_vel_in + resize(shift_right(chi17_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi17_osq_vx_dtsq, 96), 2*Q), 48);
          chi17_x_omega_pred_int <= chi17_x_omega_in;
          chi17_y_pos_pred_int <= chi17_y_pos_in + resize(shift_right(chi17_y_vel_dt, Q), 48);
          chi17_y_vel_pred_int <= chi17_y_vel_in + resize(shift_right(chi17_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi17_osq_vy_dtsq, 96), 2*Q), 48);
          chi17_y_omega_pred_int <= chi17_y_omega_in;
          chi17_z_pos_pred_int <= chi17_z_pos_in + resize(shift_right(chi17_z_vel_dt, Q), 48);
          chi17_z_vel_pred_int <= chi17_z_vel_in + resize(shift_right(chi17_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi17_osq_vz_dtsq, 96), 2*Q), 48);
          chi17_z_omega_pred_int <= chi17_z_omega_in;

          chi18_x_pos_pred_int <= chi18_x_pos_in + resize(shift_right(chi18_x_vel_dt, Q), 48);
          chi18_x_vel_pred_int <= chi18_x_vel_in + resize(shift_right(chi18_cx_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi18_osq_vx_dtsq, 96), 2*Q), 48);
          chi18_x_omega_pred_int <= chi18_x_omega_in;
          chi18_y_pos_pred_int <= chi18_y_pos_in + resize(shift_right(chi18_y_vel_dt, Q), 48);
          chi18_y_vel_pred_int <= chi18_y_vel_in + resize(shift_right(chi18_cy_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi18_osq_vy_dtsq, 96), 2*Q), 48);
          chi18_y_omega_pred_int <= chi18_y_omega_in;
          chi18_z_pos_pred_int <= chi18_z_pos_in + resize(shift_right(chi18_z_vel_dt, Q), 48);
          chi18_z_vel_pred_int <= chi18_z_vel_in + resize(shift_right(chi18_cz_dt, Q), 48) - resize(shift_right(resize(HALF_Q24_24 * chi18_osq_vz_dtsq, 96), 2*Q), 48);
          chi18_z_omega_pred_int <= chi18_z_omega_in;

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
  chi0_x_omega_pred <= chi0_x_omega_pred_int;
  chi0_y_pos_pred <= chi0_y_pos_pred_int;
  chi0_y_vel_pred <= chi0_y_vel_pred_int;
  chi0_y_omega_pred <= chi0_y_omega_pred_int;
  chi0_z_pos_pred <= chi0_z_pos_pred_int;
  chi0_z_vel_pred <= chi0_z_vel_pred_int;
  chi0_z_omega_pred <= chi0_z_omega_pred_int;

  chi1_x_pos_pred <= chi1_x_pos_pred_int;
  chi1_x_vel_pred <= chi1_x_vel_pred_int;
  chi1_x_omega_pred <= chi1_x_omega_pred_int;
  chi1_y_pos_pred <= chi1_y_pos_pred_int;
  chi1_y_vel_pred <= chi1_y_vel_pred_int;
  chi1_y_omega_pred <= chi1_y_omega_pred_int;
  chi1_z_pos_pred <= chi1_z_pos_pred_int;
  chi1_z_vel_pred <= chi1_z_vel_pred_int;
  chi1_z_omega_pred <= chi1_z_omega_pred_int;

  chi2_x_pos_pred <= chi2_x_pos_pred_int;
  chi2_x_vel_pred <= chi2_x_vel_pred_int;
  chi2_x_omega_pred <= chi2_x_omega_pred_int;
  chi2_y_pos_pred <= chi2_y_pos_pred_int;
  chi2_y_vel_pred <= chi2_y_vel_pred_int;
  chi2_y_omega_pred <= chi2_y_omega_pred_int;
  chi2_z_pos_pred <= chi2_z_pos_pred_int;
  chi2_z_vel_pred <= chi2_z_vel_pred_int;
  chi2_z_omega_pred <= chi2_z_omega_pred_int;

  chi3_x_pos_pred <= chi3_x_pos_pred_int;
  chi3_x_vel_pred <= chi3_x_vel_pred_int;
  chi3_x_omega_pred <= chi3_x_omega_pred_int;
  chi3_y_pos_pred <= chi3_y_pos_pred_int;
  chi3_y_vel_pred <= chi3_y_vel_pred_int;
  chi3_y_omega_pred <= chi3_y_omega_pred_int;
  chi3_z_pos_pred <= chi3_z_pos_pred_int;
  chi3_z_vel_pred <= chi3_z_vel_pred_int;
  chi3_z_omega_pred <= chi3_z_omega_pred_int;

  chi4_x_pos_pred <= chi4_x_pos_pred_int;
  chi4_x_vel_pred <= chi4_x_vel_pred_int;
  chi4_x_omega_pred <= chi4_x_omega_pred_int;
  chi4_y_pos_pred <= chi4_y_pos_pred_int;
  chi4_y_vel_pred <= chi4_y_vel_pred_int;
  chi4_y_omega_pred <= chi4_y_omega_pred_int;
  chi4_z_pos_pred <= chi4_z_pos_pred_int;
  chi4_z_vel_pred <= chi4_z_vel_pred_int;
  chi4_z_omega_pred <= chi4_z_omega_pred_int;

  chi5_x_pos_pred <= chi5_x_pos_pred_int;
  chi5_x_vel_pred <= chi5_x_vel_pred_int;
  chi5_x_omega_pred <= chi5_x_omega_pred_int;
  chi5_y_pos_pred <= chi5_y_pos_pred_int;
  chi5_y_vel_pred <= chi5_y_vel_pred_int;
  chi5_y_omega_pred <= chi5_y_omega_pred_int;
  chi5_z_pos_pred <= chi5_z_pos_pred_int;
  chi5_z_vel_pred <= chi5_z_vel_pred_int;
  chi5_z_omega_pred <= chi5_z_omega_pred_int;

  chi6_x_pos_pred <= chi6_x_pos_pred_int;
  chi6_x_vel_pred <= chi6_x_vel_pred_int;
  chi6_x_omega_pred <= chi6_x_omega_pred_int;
  chi6_y_pos_pred <= chi6_y_pos_pred_int;
  chi6_y_vel_pred <= chi6_y_vel_pred_int;
  chi6_y_omega_pred <= chi6_y_omega_pred_int;
  chi6_z_pos_pred <= chi6_z_pos_pred_int;
  chi6_z_vel_pred <= chi6_z_vel_pred_int;
  chi6_z_omega_pred <= chi6_z_omega_pred_int;

  chi7_x_pos_pred <= chi7_x_pos_pred_int;
  chi7_x_vel_pred <= chi7_x_vel_pred_int;
  chi7_x_omega_pred <= chi7_x_omega_pred_int;
  chi7_y_pos_pred <= chi7_y_pos_pred_int;
  chi7_y_vel_pred <= chi7_y_vel_pred_int;
  chi7_y_omega_pred <= chi7_y_omega_pred_int;
  chi7_z_pos_pred <= chi7_z_pos_pred_int;
  chi7_z_vel_pred <= chi7_z_vel_pred_int;
  chi7_z_omega_pred <= chi7_z_omega_pred_int;

  chi8_x_pos_pred <= chi8_x_pos_pred_int;
  chi8_x_vel_pred <= chi8_x_vel_pred_int;
  chi8_x_omega_pred <= chi8_x_omega_pred_int;
  chi8_y_pos_pred <= chi8_y_pos_pred_int;
  chi8_y_vel_pred <= chi8_y_vel_pred_int;
  chi8_y_omega_pred <= chi8_y_omega_pred_int;
  chi8_z_pos_pred <= chi8_z_pos_pred_int;
  chi8_z_vel_pred <= chi8_z_vel_pred_int;
  chi8_z_omega_pred <= chi8_z_omega_pred_int;

  chi9_x_pos_pred <= chi9_x_pos_pred_int;
  chi9_x_vel_pred <= chi9_x_vel_pred_int;
  chi9_x_omega_pred <= chi9_x_omega_pred_int;
  chi9_y_pos_pred <= chi9_y_pos_pred_int;
  chi9_y_vel_pred <= chi9_y_vel_pred_int;
  chi9_y_omega_pred <= chi9_y_omega_pred_int;
  chi9_z_pos_pred <= chi9_z_pos_pred_int;
  chi9_z_vel_pred <= chi9_z_vel_pred_int;
  chi9_z_omega_pred <= chi9_z_omega_pred_int;

  chi10_x_pos_pred <= chi10_x_pos_pred_int;
  chi10_x_vel_pred <= chi10_x_vel_pred_int;
  chi10_x_omega_pred <= chi10_x_omega_pred_int;
  chi10_y_pos_pred <= chi10_y_pos_pred_int;
  chi10_y_vel_pred <= chi10_y_vel_pred_int;
  chi10_y_omega_pred <= chi10_y_omega_pred_int;
  chi10_z_pos_pred <= chi10_z_pos_pred_int;
  chi10_z_vel_pred <= chi10_z_vel_pred_int;
  chi10_z_omega_pred <= chi10_z_omega_pred_int;

  chi11_x_pos_pred <= chi11_x_pos_pred_int;
  chi11_x_vel_pred <= chi11_x_vel_pred_int;
  chi11_x_omega_pred <= chi11_x_omega_pred_int;
  chi11_y_pos_pred <= chi11_y_pos_pred_int;
  chi11_y_vel_pred <= chi11_y_vel_pred_int;
  chi11_y_omega_pred <= chi11_y_omega_pred_int;
  chi11_z_pos_pred <= chi11_z_pos_pred_int;
  chi11_z_vel_pred <= chi11_z_vel_pred_int;
  chi11_z_omega_pred <= chi11_z_omega_pred_int;

  chi12_x_pos_pred <= chi12_x_pos_pred_int;
  chi12_x_vel_pred <= chi12_x_vel_pred_int;
  chi12_x_omega_pred <= chi12_x_omega_pred_int;
  chi12_y_pos_pred <= chi12_y_pos_pred_int;
  chi12_y_vel_pred <= chi12_y_vel_pred_int;
  chi12_y_omega_pred <= chi12_y_omega_pred_int;
  chi12_z_pos_pred <= chi12_z_pos_pred_int;
  chi12_z_vel_pred <= chi12_z_vel_pred_int;
  chi12_z_omega_pred <= chi12_z_omega_pred_int;

  chi13_x_pos_pred <= chi13_x_pos_pred_int;
  chi13_x_vel_pred <= chi13_x_vel_pred_int;
  chi13_x_omega_pred <= chi13_x_omega_pred_int;
  chi13_y_pos_pred <= chi13_y_pos_pred_int;
  chi13_y_vel_pred <= chi13_y_vel_pred_int;
  chi13_y_omega_pred <= chi13_y_omega_pred_int;
  chi13_z_pos_pred <= chi13_z_pos_pred_int;
  chi13_z_vel_pred <= chi13_z_vel_pred_int;
  chi13_z_omega_pred <= chi13_z_omega_pred_int;

  chi14_x_pos_pred <= chi14_x_pos_pred_int;
  chi14_x_vel_pred <= chi14_x_vel_pred_int;
  chi14_x_omega_pred <= chi14_x_omega_pred_int;
  chi14_y_pos_pred <= chi14_y_pos_pred_int;
  chi14_y_vel_pred <= chi14_y_vel_pred_int;
  chi14_y_omega_pred <= chi14_y_omega_pred_int;
  chi14_z_pos_pred <= chi14_z_pos_pred_int;
  chi14_z_vel_pred <= chi14_z_vel_pred_int;
  chi14_z_omega_pred <= chi14_z_omega_pred_int;

  chi15_x_pos_pred <= chi15_x_pos_pred_int;
  chi15_x_vel_pred <= chi15_x_vel_pred_int;
  chi15_x_omega_pred <= chi15_x_omega_pred_int;
  chi15_y_pos_pred <= chi15_y_pos_pred_int;
  chi15_y_vel_pred <= chi15_y_vel_pred_int;
  chi15_y_omega_pred <= chi15_y_omega_pred_int;
  chi15_z_pos_pred <= chi15_z_pos_pred_int;
  chi15_z_vel_pred <= chi15_z_vel_pred_int;
  chi15_z_omega_pred <= chi15_z_omega_pred_int;

  chi16_x_pos_pred <= chi16_x_pos_pred_int;
  chi16_x_vel_pred <= chi16_x_vel_pred_int;
  chi16_x_omega_pred <= chi16_x_omega_pred_int;
  chi16_y_pos_pred <= chi16_y_pos_pred_int;
  chi16_y_vel_pred <= chi16_y_vel_pred_int;
  chi16_y_omega_pred <= chi16_y_omega_pred_int;
  chi16_z_pos_pred <= chi16_z_pos_pred_int;
  chi16_z_vel_pred <= chi16_z_vel_pred_int;
  chi16_z_omega_pred <= chi16_z_omega_pred_int;

  chi17_x_pos_pred <= chi17_x_pos_pred_int;
  chi17_x_vel_pred <= chi17_x_vel_pred_int;
  chi17_x_omega_pred <= chi17_x_omega_pred_int;
  chi17_y_pos_pred <= chi17_y_pos_pred_int;
  chi17_y_vel_pred <= chi17_y_vel_pred_int;
  chi17_y_omega_pred <= chi17_y_omega_pred_int;
  chi17_z_pos_pred <= chi17_z_pos_pred_int;
  chi17_z_vel_pred <= chi17_z_vel_pred_int;
  chi17_z_omega_pred <= chi17_z_omega_pred_int;

  chi18_x_pos_pred <= chi18_x_pos_pred_int;
  chi18_x_vel_pred <= chi18_x_vel_pred_int;
  chi18_x_omega_pred <= chi18_x_omega_pred_int;
  chi18_y_pos_pred <= chi18_y_pos_pred_int;
  chi18_y_vel_pred <= chi18_y_vel_pred_int;
  chi18_y_omega_pred <= chi18_y_omega_pred_int;
  chi18_z_pos_pred <= chi18_z_pos_pred_int;
  chi18_z_vel_pred <= chi18_z_vel_pred_int;
  chi18_z_omega_pred <= chi18_z_omega_pred_int;

end architecture;
