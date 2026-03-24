library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity predicti_singer3d is
  generic (
    TAU_Q24_24       : signed(47 downto 0) := to_signed(33554432, 48);
    SIGMA_A_SQ_Q24_24: signed(47 downto 0) := to_signed(419430400, 48);
    DT_Q24_24        : signed(47 downto 0) := to_signed(335544, 48)
  );
  port (
    clk   : in std_logic;
    reset : in std_logic;
    start : in std_logic;

    a_mean_x : in signed(47 downto 0);
    a_mean_y : in signed(47 downto 0);
    a_mean_z : in signed(47 downto 0);

    cycle_num : in integer range 0 to 1000;

    chi0_x_pos_in, chi0_x_vel_in, chi0_x_acc_in : in signed(47 downto 0);
    chi0_y_pos_in, chi0_y_vel_in, chi0_y_acc_in : in signed(47 downto 0);
    chi0_z_pos_in, chi0_z_vel_in, chi0_z_acc_in : in signed(47 downto 0);

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

    done : out std_logic
  );
end entity;

architecture Behavioral of predicti_singer3d is

  constant Q : integer := 24;
  constant HALF_Q24_24 : signed(47 downto 0) := to_signed(8388608, 48);

  component exp_cordic is
    port (
      clk       : in  std_logic;
      start_exp : in  std_logic;
      x_in      : in  signed(47 downto 0);
      exp_out   : out signed(47 downto 0);
      done      : out std_logic;
      overflow  : out std_logic
    );
  end component;

  type state_type is (IDLE, COMPUTE_EXP_TERM, WAIT_EXP, MULTIPLY_VEL,
                      COMPUTE_SINGER_TERMS, CALCULATE, FINISHED);
  signal state : state_type := IDLE;

  signal exp_start : std_logic := '0';
  signal exp_input : signed(47 downto 0) := (others => '0');
  signal exp_output : signed(47 downto 0);
  signal exp_done : std_logic;
  signal exp_overflow : std_logic;

  signal exp_term : signed(47 downto 0);
  signal one_minus_exp : signed(47 downto 0);
  signal tau_times_one_minus_exp : signed(47 downto 0);
  signal dt_minus_tau_term : signed(47 downto 0);

  signal dt_sq : signed(47 downto 0);
  signal a_mean_x_dt, a_mean_y_dt, a_mean_z_dt : signed(47 downto 0);
  signal a_mean_x_half_dt_sq, a_mean_y_half_dt_sq, a_mean_z_half_dt_sq : signed(47 downto 0);

  signal chi0_x_vel_dt, chi0_y_vel_dt, chi0_z_vel_dt : signed(47 downto 0);
  signal chi1_x_vel_dt, chi1_y_vel_dt, chi1_z_vel_dt : signed(47 downto 0);
  signal chi2_x_vel_dt, chi2_y_vel_dt, chi2_z_vel_dt : signed(47 downto 0);
  signal chi3_x_vel_dt, chi3_y_vel_dt, chi3_z_vel_dt : signed(47 downto 0);
  signal chi4_x_vel_dt, chi4_y_vel_dt, chi4_z_vel_dt : signed(47 downto 0);
  signal chi5_x_vel_dt, chi5_y_vel_dt, chi5_z_vel_dt : signed(47 downto 0);
  signal chi6_x_vel_dt, chi6_y_vel_dt, chi6_z_vel_dt : signed(47 downto 0);
  signal chi7_x_vel_dt, chi7_y_vel_dt, chi7_z_vel_dt : signed(47 downto 0);
  signal chi8_x_vel_dt, chi8_y_vel_dt, chi8_z_vel_dt : signed(47 downto 0);
  signal chi9_x_vel_dt, chi9_y_vel_dt, chi9_z_vel_dt : signed(47 downto 0);
  signal chi10_x_vel_dt, chi10_y_vel_dt, chi10_z_vel_dt : signed(47 downto 0);
  signal chi11_x_vel_dt, chi11_y_vel_dt, chi11_z_vel_dt : signed(47 downto 0);
  signal chi12_x_vel_dt, chi12_y_vel_dt, chi12_z_vel_dt : signed(47 downto 0);
  signal chi13_x_vel_dt, chi13_y_vel_dt, chi13_z_vel_dt : signed(47 downto 0);
  signal chi14_x_vel_dt, chi14_y_vel_dt, chi14_z_vel_dt : signed(47 downto 0);
  signal chi15_x_vel_dt, chi15_y_vel_dt, chi15_z_vel_dt : signed(47 downto 0);
  signal chi16_x_vel_dt, chi16_y_vel_dt, chi16_z_vel_dt : signed(47 downto 0);
  signal chi17_x_vel_dt, chi17_y_vel_dt, chi17_z_vel_dt : signed(47 downto 0);
  signal chi18_x_vel_dt, chi18_y_vel_dt, chi18_z_vel_dt : signed(47 downto 0);

  signal chi0_x_acc_delta, chi0_y_acc_delta, chi0_z_acc_delta : signed(47 downto 0);
  signal chi1_x_acc_delta, chi1_y_acc_delta, chi1_z_acc_delta : signed(47 downto 0);
  signal chi2_x_acc_delta, chi2_y_acc_delta, chi2_z_acc_delta : signed(47 downto 0);
  signal chi3_x_acc_delta, chi3_y_acc_delta, chi3_z_acc_delta : signed(47 downto 0);
  signal chi4_x_acc_delta, chi4_y_acc_delta, chi4_z_acc_delta : signed(47 downto 0);
  signal chi5_x_acc_delta, chi5_y_acc_delta, chi5_z_acc_delta : signed(47 downto 0);
  signal chi6_x_acc_delta, chi6_y_acc_delta, chi6_z_acc_delta : signed(47 downto 0);
  signal chi7_x_acc_delta, chi7_y_acc_delta, chi7_z_acc_delta : signed(47 downto 0);
  signal chi8_x_acc_delta, chi8_y_acc_delta, chi8_z_acc_delta : signed(47 downto 0);
  signal chi9_x_acc_delta, chi9_y_acc_delta, chi9_z_acc_delta : signed(47 downto 0);
  signal chi10_x_acc_delta, chi10_y_acc_delta, chi10_z_acc_delta : signed(47 downto 0);
  signal chi11_x_acc_delta, chi11_y_acc_delta, chi11_z_acc_delta : signed(47 downto 0);
  signal chi12_x_acc_delta, chi12_y_acc_delta, chi12_z_acc_delta : signed(47 downto 0);
  signal chi13_x_acc_delta, chi13_y_acc_delta, chi13_z_acc_delta : signed(47 downto 0);
  signal chi14_x_acc_delta, chi14_y_acc_delta, chi14_z_acc_delta : signed(47 downto 0);
  signal chi15_x_acc_delta, chi15_y_acc_delta, chi15_z_acc_delta : signed(47 downto 0);
  signal chi16_x_acc_delta, chi16_y_acc_delta, chi16_z_acc_delta : signed(47 downto 0);
  signal chi17_x_acc_delta, chi17_y_acc_delta, chi17_z_acc_delta : signed(47 downto 0);
  signal chi18_x_acc_delta, chi18_y_acc_delta, chi18_z_acc_delta : signed(47 downto 0);

  signal chi0_x_vel_term, chi0_y_vel_term, chi0_z_vel_term : signed(47 downto 0);
  signal chi1_x_vel_term, chi1_y_vel_term, chi1_z_vel_term : signed(47 downto 0);
  signal chi2_x_vel_term, chi2_y_vel_term, chi2_z_vel_term : signed(47 downto 0);
  signal chi3_x_vel_term, chi3_y_vel_term, chi3_z_vel_term : signed(47 downto 0);
  signal chi4_x_vel_term, chi4_y_vel_term, chi4_z_vel_term : signed(47 downto 0);
  signal chi5_x_vel_term, chi5_y_vel_term, chi5_z_vel_term : signed(47 downto 0);
  signal chi6_x_vel_term, chi6_y_vel_term, chi6_z_vel_term : signed(47 downto 0);
  signal chi7_x_vel_term, chi7_y_vel_term, chi7_z_vel_term : signed(47 downto 0);
  signal chi8_x_vel_term, chi8_y_vel_term, chi8_z_vel_term : signed(47 downto 0);
  signal chi9_x_vel_term, chi9_y_vel_term, chi9_z_vel_term : signed(47 downto 0);
  signal chi10_x_vel_term, chi10_y_vel_term, chi10_z_vel_term : signed(47 downto 0);
  signal chi11_x_vel_term, chi11_y_vel_term, chi11_z_vel_term : signed(47 downto 0);
  signal chi12_x_vel_term, chi12_y_vel_term, chi12_z_vel_term : signed(47 downto 0);
  signal chi13_x_vel_term, chi13_y_vel_term, chi13_z_vel_term : signed(47 downto 0);
  signal chi14_x_vel_term, chi14_y_vel_term, chi14_z_vel_term : signed(47 downto 0);
  signal chi15_x_vel_term, chi15_y_vel_term, chi15_z_vel_term : signed(47 downto 0);
  signal chi16_x_vel_term, chi16_y_vel_term, chi16_z_vel_term : signed(47 downto 0);
  signal chi17_x_vel_term, chi17_y_vel_term, chi17_z_vel_term : signed(47 downto 0);
  signal chi18_x_vel_term, chi18_y_vel_term, chi18_z_vel_term : signed(47 downto 0);

  signal chi0_x_pos_term, chi0_y_pos_term, chi0_z_pos_term : signed(47 downto 0);
  signal chi1_x_pos_term, chi1_y_pos_term, chi1_z_pos_term : signed(47 downto 0);
  signal chi2_x_pos_term, chi2_y_pos_term, chi2_z_pos_term : signed(47 downto 0);
  signal chi3_x_pos_term, chi3_y_pos_term, chi3_z_pos_term : signed(47 downto 0);
  signal chi4_x_pos_term, chi4_y_pos_term, chi4_z_pos_term : signed(47 downto 0);
  signal chi5_x_pos_term, chi5_y_pos_term, chi5_z_pos_term : signed(47 downto 0);
  signal chi6_x_pos_term, chi6_y_pos_term, chi6_z_pos_term : signed(47 downto 0);
  signal chi7_x_pos_term, chi7_y_pos_term, chi7_z_pos_term : signed(47 downto 0);
  signal chi8_x_pos_term, chi8_y_pos_term, chi8_z_pos_term : signed(47 downto 0);
  signal chi9_x_pos_term, chi9_y_pos_term, chi9_z_pos_term : signed(47 downto 0);
  signal chi10_x_pos_term, chi10_y_pos_term, chi10_z_pos_term : signed(47 downto 0);
  signal chi11_x_pos_term, chi11_y_pos_term, chi11_z_pos_term : signed(47 downto 0);
  signal chi12_x_pos_term, chi12_y_pos_term, chi12_z_pos_term : signed(47 downto 0);
  signal chi13_x_pos_term, chi13_y_pos_term, chi13_z_pos_term : signed(47 downto 0);
  signal chi14_x_pos_term, chi14_y_pos_term, chi14_z_pos_term : signed(47 downto 0);
  signal chi15_x_pos_term, chi15_y_pos_term, chi15_z_pos_term : signed(47 downto 0);
  signal chi16_x_pos_term, chi16_y_pos_term, chi16_z_pos_term : signed(47 downto 0);
  signal chi17_x_pos_term, chi17_y_pos_term, chi17_z_pos_term : signed(47 downto 0);
  signal chi18_x_pos_term, chi18_y_pos_term, chi18_z_pos_term : signed(47 downto 0);

  signal chi0_x_pos_pred_int, chi0_x_vel_pred_int, chi0_x_acc_pred_int : signed(47 downto 0);
  signal chi0_y_pos_pred_int, chi0_y_vel_pred_int, chi0_y_acc_pred_int : signed(47 downto 0);
  signal chi0_z_pos_pred_int, chi0_z_vel_pred_int, chi0_z_acc_pred_int : signed(47 downto 0);

  signal chi1_x_pos_pred_int, chi1_x_vel_pred_int, chi1_x_acc_pred_int : signed(47 downto 0);
  signal chi1_y_pos_pred_int, chi1_y_vel_pred_int, chi1_y_acc_pred_int : signed(47 downto 0);
  signal chi1_z_pos_pred_int, chi1_z_vel_pred_int, chi1_z_acc_pred_int : signed(47 downto 0);

  signal chi2_x_pos_pred_int, chi2_x_vel_pred_int, chi2_x_acc_pred_int : signed(47 downto 0);
  signal chi2_y_pos_pred_int, chi2_y_vel_pred_int, chi2_y_acc_pred_int : signed(47 downto 0);
  signal chi2_z_pos_pred_int, chi2_z_vel_pred_int, chi2_z_acc_pred_int : signed(47 downto 0);

  signal chi3_x_pos_pred_int, chi3_x_vel_pred_int, chi3_x_acc_pred_int : signed(47 downto 0);
  signal chi3_y_pos_pred_int, chi3_y_vel_pred_int, chi3_y_acc_pred_int : signed(47 downto 0);
  signal chi3_z_pos_pred_int, chi3_z_vel_pred_int, chi3_z_acc_pred_int : signed(47 downto 0);

  signal chi4_x_pos_pred_int, chi4_x_vel_pred_int, chi4_x_acc_pred_int : signed(47 downto 0);
  signal chi4_y_pos_pred_int, chi4_y_vel_pred_int, chi4_y_acc_pred_int : signed(47 downto 0);
  signal chi4_z_pos_pred_int, chi4_z_vel_pred_int, chi4_z_acc_pred_int : signed(47 downto 0);

  signal chi5_x_pos_pred_int, chi5_x_vel_pred_int, chi5_x_acc_pred_int : signed(47 downto 0);
  signal chi5_y_pos_pred_int, chi5_y_vel_pred_int, chi5_y_acc_pred_int : signed(47 downto 0);
  signal chi5_z_pos_pred_int, chi5_z_vel_pred_int, chi5_z_acc_pred_int : signed(47 downto 0);

  signal chi6_x_pos_pred_int, chi6_x_vel_pred_int, chi6_x_acc_pred_int : signed(47 downto 0);
  signal chi6_y_pos_pred_int, chi6_y_vel_pred_int, chi6_y_acc_pred_int : signed(47 downto 0);
  signal chi6_z_pos_pred_int, chi6_z_vel_pred_int, chi6_z_acc_pred_int : signed(47 downto 0);

  signal chi7_x_pos_pred_int, chi7_x_vel_pred_int, chi7_x_acc_pred_int : signed(47 downto 0);
  signal chi7_y_pos_pred_int, chi7_y_vel_pred_int, chi7_y_acc_pred_int : signed(47 downto 0);
  signal chi7_z_pos_pred_int, chi7_z_vel_pred_int, chi7_z_acc_pred_int : signed(47 downto 0);

  signal chi8_x_pos_pred_int, chi8_x_vel_pred_int, chi8_x_acc_pred_int : signed(47 downto 0);
  signal chi8_y_pos_pred_int, chi8_y_vel_pred_int, chi8_y_acc_pred_int : signed(47 downto 0);
  signal chi8_z_pos_pred_int, chi8_z_vel_pred_int, chi8_z_acc_pred_int : signed(47 downto 0);

  signal chi9_x_pos_pred_int, chi9_x_vel_pred_int, chi9_x_acc_pred_int : signed(47 downto 0);
  signal chi9_y_pos_pred_int, chi9_y_vel_pred_int, chi9_y_acc_pred_int : signed(47 downto 0);
  signal chi9_z_pos_pred_int, chi9_z_vel_pred_int, chi9_z_acc_pred_int : signed(47 downto 0);

  signal chi10_x_pos_pred_int, chi10_x_vel_pred_int, chi10_x_acc_pred_int : signed(47 downto 0);
  signal chi10_y_pos_pred_int, chi10_y_vel_pred_int, chi10_y_acc_pred_int : signed(47 downto 0);
  signal chi10_z_pos_pred_int, chi10_z_vel_pred_int, chi10_z_acc_pred_int : signed(47 downto 0);

  signal chi11_x_pos_pred_int, chi11_x_vel_pred_int, chi11_x_acc_pred_int : signed(47 downto 0);
  signal chi11_y_pos_pred_int, chi11_y_vel_pred_int, chi11_y_acc_pred_int : signed(47 downto 0);
  signal chi11_z_pos_pred_int, chi11_z_vel_pred_int, chi11_z_acc_pred_int : signed(47 downto 0);

  signal chi12_x_pos_pred_int, chi12_x_vel_pred_int, chi12_x_acc_pred_int : signed(47 downto 0);
  signal chi12_y_pos_pred_int, chi12_y_vel_pred_int, chi12_y_acc_pred_int : signed(47 downto 0);
  signal chi12_z_pos_pred_int, chi12_z_vel_pred_int, chi12_z_acc_pred_int : signed(47 downto 0);

  signal chi13_x_pos_pred_int, chi13_x_vel_pred_int, chi13_x_acc_pred_int : signed(47 downto 0);
  signal chi13_y_pos_pred_int, chi13_y_vel_pred_int, chi13_y_acc_pred_int : signed(47 downto 0);
  signal chi13_z_pos_pred_int, chi13_z_vel_pred_int, chi13_z_acc_pred_int : signed(47 downto 0);

  signal chi14_x_pos_pred_int, chi14_x_vel_pred_int, chi14_x_acc_pred_int : signed(47 downto 0);
  signal chi14_y_pos_pred_int, chi14_y_vel_pred_int, chi14_y_acc_pred_int : signed(47 downto 0);
  signal chi14_z_pos_pred_int, chi14_z_vel_pred_int, chi14_z_acc_pred_int : signed(47 downto 0);

  signal chi15_x_pos_pred_int, chi15_x_vel_pred_int, chi15_x_acc_pred_int : signed(47 downto 0);
  signal chi15_y_pos_pred_int, chi15_y_vel_pred_int, chi15_y_acc_pred_int : signed(47 downto 0);
  signal chi15_z_pos_pred_int, chi15_z_vel_pred_int, chi15_z_acc_pred_int : signed(47 downto 0);

  signal chi16_x_pos_pred_int, chi16_x_vel_pred_int, chi16_x_acc_pred_int : signed(47 downto 0);
  signal chi16_y_pos_pred_int, chi16_y_vel_pred_int, chi16_y_acc_pred_int : signed(47 downto 0);
  signal chi16_z_pos_pred_int, chi16_z_vel_pred_int, chi16_z_acc_pred_int : signed(47 downto 0);

  signal chi17_x_pos_pred_int, chi17_x_vel_pred_int, chi17_x_acc_pred_int : signed(47 downto 0);
  signal chi17_y_pos_pred_int, chi17_y_vel_pred_int, chi17_y_acc_pred_int : signed(47 downto 0);
  signal chi17_z_pos_pred_int, chi17_z_vel_pred_int, chi17_z_acc_pred_int : signed(47 downto 0);

  signal chi18_x_pos_pred_int, chi18_x_vel_pred_int, chi18_x_acc_pred_int : signed(47 downto 0);
  signal chi18_y_pos_pred_int, chi18_y_vel_pred_int, chi18_y_acc_pred_int : signed(47 downto 0);
  signal chi18_z_pos_pred_int, chi18_z_vel_pred_int, chi18_z_acc_pred_int : signed(47 downto 0);

begin

  exp_cordic_inst : exp_cordic
    port map (
      clk       => clk,
      start_exp => exp_start,
      x_in      => exp_input,
      exp_out   => exp_output,
      done      => exp_done,
      overflow  => exp_overflow
    );

  process(clk)
    variable dt_over_tau : signed(47 downto 0);
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state <= IDLE;
        done <= '0';
        exp_start <= '0';
      else
        case state is

          when IDLE =>
            done <= '0';
            exp_start <= '0';
            if start = '1' then

              if cycle_num >= 1 and cycle_num <= 2 then
                report "PREDICTI[" & integer'image(cycle_num) & "]: IDLE - Input sigma points:" & LF &
                       "  chi0_x_pos_in = " & integer'image(to_integer(chi0_x_pos_in)) & LF &
                       "  chi1_x_pos_in = " & integer'image(to_integer(chi1_x_pos_in)) & LF &
                       "  chi2_x_pos_in = " & integer'image(to_integer(chi2_x_pos_in)) & LF &
                       "  chi10_x_pos_in = " & integer'image(to_integer(chi10_x_pos_in));
              end if;
              state <= COMPUTE_EXP_TERM;
            end if;

          when COMPUTE_EXP_TERM =>

            dt_over_tau := resize(DT_Q24_24 * to_signed(16777216, 48) / TAU_Q24_24, 48);
            exp_input <= -dt_over_tau;
            exp_start <= '1';
            state <= WAIT_EXP;

          when WAIT_EXP =>
            exp_start <= '0';
            if exp_done = '1' then

              exp_term <= exp_output;

              one_minus_exp <= to_signed(16777216, 48) - exp_output;

              tau_times_one_minus_exp <= resize(shift_right(TAU_Q24_24 * (to_signed(16777216, 48) - exp_output), Q), 48);

              dt_minus_tau_term <= DT_Q24_24 - resize(shift_right(TAU_Q24_24 * (to_signed(16777216, 48) - exp_output), Q), 48);

              dt_sq <= resize(shift_right(DT_Q24_24 * DT_Q24_24, Q), 48);
              a_mean_x_dt <= resize(shift_right(a_mean_x * DT_Q24_24, Q), 48);
              a_mean_y_dt <= resize(shift_right(a_mean_y * DT_Q24_24, Q), 48);
              a_mean_z_dt <= resize(shift_right(a_mean_z * DT_Q24_24, Q), 48);

              a_mean_x_half_dt_sq <= resize(shift_right(resize(HALF_Q24_24 * a_mean_x, 96) * resize(shift_right(DT_Q24_24 * DT_Q24_24, Q), 96), Q*2), 48);
              a_mean_y_half_dt_sq <= resize(shift_right(resize(HALF_Q24_24 * a_mean_y, 96) * resize(shift_right(DT_Q24_24 * DT_Q24_24, Q), 96), Q*2), 48);
              a_mean_z_half_dt_sq <= resize(shift_right(resize(HALF_Q24_24 * a_mean_z, 96) * resize(shift_right(DT_Q24_24 * DT_Q24_24, Q), 96), Q*2), 48);

              if cycle_num >= 1 and cycle_num <= 2 then
                report "PREDICTI[" & integer'image(cycle_num) & "]: WAIT_EXP - Singer terms computed:" & LF &
                       "  exp_term = " & integer'image(to_integer(exp_output)) & LF &
                       "  one_minus_exp = " & integer'image(to_integer(to_signed(16777216, 48) - exp_output)) & LF &
                       "  tau_times_one_minus_exp = " & integer'image(to_integer(resize(shift_right(TAU_Q24_24 * (to_signed(16777216, 48) - exp_output), Q), 48))) & LF &
                       "  dt_minus_tau_term = " & integer'image(to_integer(DT_Q24_24 - resize(shift_right(TAU_Q24_24 * (to_signed(16777216, 48) - exp_output), Q), 48)));
              end if;

              state <= MULTIPLY_VEL;
            end if;

          when MULTIPLY_VEL =>

            chi0_x_vel_dt <= resize(shift_right(chi0_x_vel_in * DT_Q24_24, Q), 48);
            chi0_y_vel_dt <= resize(shift_right(chi0_y_vel_in * DT_Q24_24, Q), 48);
            chi0_z_vel_dt <= resize(shift_right(chi0_z_vel_in * DT_Q24_24, Q), 48);

            chi1_x_vel_dt <= resize(shift_right(chi1_x_vel_in * DT_Q24_24, Q), 48);
            chi1_y_vel_dt <= resize(shift_right(chi1_y_vel_in * DT_Q24_24, Q), 48);
            chi1_z_vel_dt <= resize(shift_right(chi1_z_vel_in * DT_Q24_24, Q), 48);

            chi2_x_vel_dt <= resize(shift_right(chi2_x_vel_in * DT_Q24_24, Q), 48);
            chi2_y_vel_dt <= resize(shift_right(chi2_y_vel_in * DT_Q24_24, Q), 48);
            chi2_z_vel_dt <= resize(shift_right(chi2_z_vel_in * DT_Q24_24, Q), 48);

            chi3_x_vel_dt <= resize(shift_right(chi3_x_vel_in * DT_Q24_24, Q), 48);
            chi3_y_vel_dt <= resize(shift_right(chi3_y_vel_in * DT_Q24_24, Q), 48);
            chi3_z_vel_dt <= resize(shift_right(chi3_z_vel_in * DT_Q24_24, Q), 48);

            chi4_x_vel_dt <= resize(shift_right(chi4_x_vel_in * DT_Q24_24, Q), 48);
            chi4_y_vel_dt <= resize(shift_right(chi4_y_vel_in * DT_Q24_24, Q), 48);
            chi4_z_vel_dt <= resize(shift_right(chi4_z_vel_in * DT_Q24_24, Q), 48);

            chi5_x_vel_dt <= resize(shift_right(chi5_x_vel_in * DT_Q24_24, Q), 48);
            chi5_y_vel_dt <= resize(shift_right(chi5_y_vel_in * DT_Q24_24, Q), 48);
            chi5_z_vel_dt <= resize(shift_right(chi5_z_vel_in * DT_Q24_24, Q), 48);

            chi6_x_vel_dt <= resize(shift_right(chi6_x_vel_in * DT_Q24_24, Q), 48);
            chi6_y_vel_dt <= resize(shift_right(chi6_y_vel_in * DT_Q24_24, Q), 48);
            chi6_z_vel_dt <= resize(shift_right(chi6_z_vel_in * DT_Q24_24, Q), 48);

            chi7_x_vel_dt <= resize(shift_right(chi7_x_vel_in * DT_Q24_24, Q), 48);
            chi7_y_vel_dt <= resize(shift_right(chi7_y_vel_in * DT_Q24_24, Q), 48);
            chi7_z_vel_dt <= resize(shift_right(chi7_z_vel_in * DT_Q24_24, Q), 48);

            chi8_x_vel_dt <= resize(shift_right(chi8_x_vel_in * DT_Q24_24, Q), 48);
            chi8_y_vel_dt <= resize(shift_right(chi8_y_vel_in * DT_Q24_24, Q), 48);
            chi8_z_vel_dt <= resize(shift_right(chi8_z_vel_in * DT_Q24_24, Q), 48);

            chi9_x_vel_dt <= resize(shift_right(chi9_x_vel_in * DT_Q24_24, Q), 48);
            chi9_y_vel_dt <= resize(shift_right(chi9_y_vel_in * DT_Q24_24, Q), 48);
            chi9_z_vel_dt <= resize(shift_right(chi9_z_vel_in * DT_Q24_24, Q), 48);

            chi10_x_vel_dt <= resize(shift_right(chi10_x_vel_in * DT_Q24_24, Q), 48);
            chi10_y_vel_dt <= resize(shift_right(chi10_y_vel_in * DT_Q24_24, Q), 48);
            chi10_z_vel_dt <= resize(shift_right(chi10_z_vel_in * DT_Q24_24, Q), 48);

            chi11_x_vel_dt <= resize(shift_right(chi11_x_vel_in * DT_Q24_24, Q), 48);
            chi11_y_vel_dt <= resize(shift_right(chi11_y_vel_in * DT_Q24_24, Q), 48);
            chi11_z_vel_dt <= resize(shift_right(chi11_z_vel_in * DT_Q24_24, Q), 48);

            chi12_x_vel_dt <= resize(shift_right(chi12_x_vel_in * DT_Q24_24, Q), 48);
            chi12_y_vel_dt <= resize(shift_right(chi12_y_vel_in * DT_Q24_24, Q), 48);
            chi12_z_vel_dt <= resize(shift_right(chi12_z_vel_in * DT_Q24_24, Q), 48);

            chi13_x_vel_dt <= resize(shift_right(chi13_x_vel_in * DT_Q24_24, Q), 48);
            chi13_y_vel_dt <= resize(shift_right(chi13_y_vel_in * DT_Q24_24, Q), 48);
            chi13_z_vel_dt <= resize(shift_right(chi13_z_vel_in * DT_Q24_24, Q), 48);

            chi14_x_vel_dt <= resize(shift_right(chi14_x_vel_in * DT_Q24_24, Q), 48);
            chi14_y_vel_dt <= resize(shift_right(chi14_y_vel_in * DT_Q24_24, Q), 48);
            chi14_z_vel_dt <= resize(shift_right(chi14_z_vel_in * DT_Q24_24, Q), 48);

            chi15_x_vel_dt <= resize(shift_right(chi15_x_vel_in * DT_Q24_24, Q), 48);
            chi15_y_vel_dt <= resize(shift_right(chi15_y_vel_in * DT_Q24_24, Q), 48);
            chi15_z_vel_dt <= resize(shift_right(chi15_z_vel_in * DT_Q24_24, Q), 48);

            chi16_x_vel_dt <= resize(shift_right(chi16_x_vel_in * DT_Q24_24, Q), 48);
            chi16_y_vel_dt <= resize(shift_right(chi16_y_vel_in * DT_Q24_24, Q), 48);
            chi16_z_vel_dt <= resize(shift_right(chi16_z_vel_in * DT_Q24_24, Q), 48);

            chi17_x_vel_dt <= resize(shift_right(chi17_x_vel_in * DT_Q24_24, Q), 48);
            chi17_y_vel_dt <= resize(shift_right(chi17_y_vel_in * DT_Q24_24, Q), 48);
            chi17_z_vel_dt <= resize(shift_right(chi17_z_vel_in * DT_Q24_24, Q), 48);

            chi18_x_vel_dt <= resize(shift_right(chi18_x_vel_in * DT_Q24_24, Q), 48);
            chi18_y_vel_dt <= resize(shift_right(chi18_y_vel_in * DT_Q24_24, Q), 48);
            chi18_z_vel_dt <= resize(shift_right(chi18_z_vel_in * DT_Q24_24, Q), 48);

            state <= COMPUTE_SINGER_TERMS;

          when COMPUTE_SINGER_TERMS =>

            chi0_x_acc_delta <= chi0_x_acc_in - a_mean_x;
            chi0_y_acc_delta <= chi0_y_acc_in - a_mean_y;
            chi0_z_acc_delta <= chi0_z_acc_in - a_mean_z;
            chi0_x_vel_term <= resize(shift_right((chi0_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi0_y_vel_term <= resize(shift_right((chi0_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi0_z_vel_term <= resize(shift_right((chi0_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi0_x_pos_term <= resize(shift_right((chi0_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi0_y_pos_term <= resize(shift_right((chi0_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi0_z_pos_term <= resize(shift_right((chi0_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi1_x_acc_delta <= chi1_x_acc_in - a_mean_x; chi1_y_acc_delta <= chi1_y_acc_in - a_mean_y; chi1_z_acc_delta <= chi1_z_acc_in - a_mean_z;
            chi1_x_vel_term <= resize(shift_right((chi1_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi1_y_vel_term <= resize(shift_right((chi1_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi1_z_vel_term <= resize(shift_right((chi1_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi1_x_pos_term <= resize(shift_right((chi1_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi1_y_pos_term <= resize(shift_right((chi1_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi1_z_pos_term <= resize(shift_right((chi1_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi2_x_acc_delta <= chi2_x_acc_in - a_mean_x; chi2_y_acc_delta <= chi2_y_acc_in - a_mean_y; chi2_z_acc_delta <= chi2_z_acc_in - a_mean_z;
            chi2_x_vel_term <= resize(shift_right((chi2_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi2_y_vel_term <= resize(shift_right((chi2_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi2_z_vel_term <= resize(shift_right((chi2_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi2_x_pos_term <= resize(shift_right((chi2_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi2_y_pos_term <= resize(shift_right((chi2_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi2_z_pos_term <= resize(shift_right((chi2_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi3_x_acc_delta <= chi3_x_acc_in - a_mean_x; chi3_y_acc_delta <= chi3_y_acc_in - a_mean_y; chi3_z_acc_delta <= chi3_z_acc_in - a_mean_z;
            chi3_x_vel_term <= resize(shift_right((chi3_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi3_y_vel_term <= resize(shift_right((chi3_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi3_z_vel_term <= resize(shift_right((chi3_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi3_x_pos_term <= resize(shift_right((chi3_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi3_y_pos_term <= resize(shift_right((chi3_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi3_z_pos_term <= resize(shift_right((chi3_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi4_x_acc_delta <= chi4_x_acc_in - a_mean_x; chi4_y_acc_delta <= chi4_y_acc_in - a_mean_y; chi4_z_acc_delta <= chi4_z_acc_in - a_mean_z;
            chi4_x_vel_term <= resize(shift_right((chi4_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi4_y_vel_term <= resize(shift_right((chi4_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi4_z_vel_term <= resize(shift_right((chi4_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi4_x_pos_term <= resize(shift_right((chi4_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi4_y_pos_term <= resize(shift_right((chi4_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi4_z_pos_term <= resize(shift_right((chi4_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi5_x_acc_delta <= chi5_x_acc_in - a_mean_x; chi5_y_acc_delta <= chi5_y_acc_in - a_mean_y; chi5_z_acc_delta <= chi5_z_acc_in - a_mean_z;
            chi5_x_vel_term <= resize(shift_right((chi5_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi5_y_vel_term <= resize(shift_right((chi5_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi5_z_vel_term <= resize(shift_right((chi5_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi5_x_pos_term <= resize(shift_right((chi5_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi5_y_pos_term <= resize(shift_right((chi5_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi5_z_pos_term <= resize(shift_right((chi5_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi6_x_acc_delta <= chi6_x_acc_in - a_mean_x; chi6_y_acc_delta <= chi6_y_acc_in - a_mean_y; chi6_z_acc_delta <= chi6_z_acc_in - a_mean_z;
            chi6_x_vel_term <= resize(shift_right((chi6_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi6_y_vel_term <= resize(shift_right((chi6_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi6_z_vel_term <= resize(shift_right((chi6_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi6_x_pos_term <= resize(shift_right((chi6_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi6_y_pos_term <= resize(shift_right((chi6_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi6_z_pos_term <= resize(shift_right((chi6_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi7_x_acc_delta <= chi7_x_acc_in - a_mean_x; chi7_y_acc_delta <= chi7_y_acc_in - a_mean_y; chi7_z_acc_delta <= chi7_z_acc_in - a_mean_z;
            chi7_x_vel_term <= resize(shift_right((chi7_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi7_y_vel_term <= resize(shift_right((chi7_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi7_z_vel_term <= resize(shift_right((chi7_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi7_x_pos_term <= resize(shift_right((chi7_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi7_y_pos_term <= resize(shift_right((chi7_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi7_z_pos_term <= resize(shift_right((chi7_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi8_x_acc_delta <= chi8_x_acc_in - a_mean_x; chi8_y_acc_delta <= chi8_y_acc_in - a_mean_y; chi8_z_acc_delta <= chi8_z_acc_in - a_mean_z;
            chi8_x_vel_term <= resize(shift_right((chi8_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi8_y_vel_term <= resize(shift_right((chi8_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi8_z_vel_term <= resize(shift_right((chi8_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi8_x_pos_term <= resize(shift_right((chi8_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi8_y_pos_term <= resize(shift_right((chi8_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi8_z_pos_term <= resize(shift_right((chi8_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi9_x_acc_delta <= chi9_x_acc_in - a_mean_x; chi9_y_acc_delta <= chi9_y_acc_in - a_mean_y; chi9_z_acc_delta <= chi9_z_acc_in - a_mean_z;
            chi9_x_vel_term <= resize(shift_right((chi9_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi9_y_vel_term <= resize(shift_right((chi9_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi9_z_vel_term <= resize(shift_right((chi9_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi9_x_pos_term <= resize(shift_right((chi9_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi9_y_pos_term <= resize(shift_right((chi9_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi9_z_pos_term <= resize(shift_right((chi9_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi10_x_acc_delta <= chi10_x_acc_in - a_mean_x; chi10_y_acc_delta <= chi10_y_acc_in - a_mean_y; chi10_z_acc_delta <= chi10_z_acc_in - a_mean_z;
            chi10_x_vel_term <= resize(shift_right((chi10_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi10_y_vel_term <= resize(shift_right((chi10_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi10_z_vel_term <= resize(shift_right((chi10_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi10_x_pos_term <= resize(shift_right((chi10_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi10_y_pos_term <= resize(shift_right((chi10_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi10_z_pos_term <= resize(shift_right((chi10_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi11_x_acc_delta <= chi11_x_acc_in - a_mean_x; chi11_y_acc_delta <= chi11_y_acc_in - a_mean_y; chi11_z_acc_delta <= chi11_z_acc_in - a_mean_z;
            chi11_x_vel_term <= resize(shift_right((chi11_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi11_y_vel_term <= resize(shift_right((chi11_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi11_z_vel_term <= resize(shift_right((chi11_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi11_x_pos_term <= resize(shift_right((chi11_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi11_y_pos_term <= resize(shift_right((chi11_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi11_z_pos_term <= resize(shift_right((chi11_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi12_x_acc_delta <= chi12_x_acc_in - a_mean_x; chi12_y_acc_delta <= chi12_y_acc_in - a_mean_y; chi12_z_acc_delta <= chi12_z_acc_in - a_mean_z;
            chi12_x_vel_term <= resize(shift_right((chi12_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi12_y_vel_term <= resize(shift_right((chi12_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi12_z_vel_term <= resize(shift_right((chi12_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi12_x_pos_term <= resize(shift_right((chi12_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi12_y_pos_term <= resize(shift_right((chi12_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi12_z_pos_term <= resize(shift_right((chi12_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi13_x_acc_delta <= chi13_x_acc_in - a_mean_x; chi13_y_acc_delta <= chi13_y_acc_in - a_mean_y; chi13_z_acc_delta <= chi13_z_acc_in - a_mean_z;
            chi13_x_vel_term <= resize(shift_right((chi13_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi13_y_vel_term <= resize(shift_right((chi13_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi13_z_vel_term <= resize(shift_right((chi13_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi13_x_pos_term <= resize(shift_right((chi13_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi13_y_pos_term <= resize(shift_right((chi13_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi13_z_pos_term <= resize(shift_right((chi13_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi14_x_acc_delta <= chi14_x_acc_in - a_mean_x; chi14_y_acc_delta <= chi14_y_acc_in - a_mean_y; chi14_z_acc_delta <= chi14_z_acc_in - a_mean_z;
            chi14_x_vel_term <= resize(shift_right((chi14_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi14_y_vel_term <= resize(shift_right((chi14_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi14_z_vel_term <= resize(shift_right((chi14_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi14_x_pos_term <= resize(shift_right((chi14_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi14_y_pos_term <= resize(shift_right((chi14_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi14_z_pos_term <= resize(shift_right((chi14_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi15_x_acc_delta <= chi15_x_acc_in - a_mean_x; chi15_y_acc_delta <= chi15_y_acc_in - a_mean_y; chi15_z_acc_delta <= chi15_z_acc_in - a_mean_z;
            chi15_x_vel_term <= resize(shift_right((chi15_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi15_y_vel_term <= resize(shift_right((chi15_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi15_z_vel_term <= resize(shift_right((chi15_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi15_x_pos_term <= resize(shift_right((chi15_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi15_y_pos_term <= resize(shift_right((chi15_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi15_z_pos_term <= resize(shift_right((chi15_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi16_x_acc_delta <= chi16_x_acc_in - a_mean_x; chi16_y_acc_delta <= chi16_y_acc_in - a_mean_y; chi16_z_acc_delta <= chi16_z_acc_in - a_mean_z;
            chi16_x_vel_term <= resize(shift_right((chi16_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi16_y_vel_term <= resize(shift_right((chi16_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi16_z_vel_term <= resize(shift_right((chi16_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi16_x_pos_term <= resize(shift_right((chi16_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi16_y_pos_term <= resize(shift_right((chi16_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi16_z_pos_term <= resize(shift_right((chi16_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi17_x_acc_delta <= chi17_x_acc_in - a_mean_x; chi17_y_acc_delta <= chi17_y_acc_in - a_mean_y; chi17_z_acc_delta <= chi17_z_acc_in - a_mean_z;
            chi17_x_vel_term <= resize(shift_right((chi17_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi17_y_vel_term <= resize(shift_right((chi17_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi17_z_vel_term <= resize(shift_right((chi17_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi17_x_pos_term <= resize(shift_right((chi17_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi17_y_pos_term <= resize(shift_right((chi17_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi17_z_pos_term <= resize(shift_right((chi17_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            chi18_x_acc_delta <= chi18_x_acc_in - a_mean_x; chi18_y_acc_delta <= chi18_y_acc_in - a_mean_y; chi18_z_acc_delta <= chi18_z_acc_in - a_mean_z;
            chi18_x_vel_term <= resize(shift_right((chi18_x_acc_in - a_mean_x) * tau_times_one_minus_exp, Q), 48);
            chi18_y_vel_term <= resize(shift_right((chi18_y_acc_in - a_mean_y) * tau_times_one_minus_exp, Q), 48);
            chi18_z_vel_term <= resize(shift_right((chi18_z_acc_in - a_mean_z) * tau_times_one_minus_exp, Q), 48);
            chi18_x_pos_term <= resize(shift_right((chi18_x_acc_in - a_mean_x) * dt_minus_tau_term, Q), 48);
            chi18_y_pos_term <= resize(shift_right((chi18_y_acc_in - a_mean_y) * dt_minus_tau_term, Q), 48);
            chi18_z_pos_term <= resize(shift_right((chi18_z_acc_in - a_mean_z) * dt_minus_tau_term, Q), 48);

            state <= CALCULATE;

          when CALCULATE =>

            chi0_x_acc_pred_int <= a_mean_x + resize(shift_right(chi0_x_acc_delta * exp_term, Q), 48);
            chi0_y_acc_pred_int <= a_mean_y + resize(shift_right(chi0_y_acc_delta * exp_term, Q), 48);
            chi0_z_acc_pred_int <= a_mean_z + resize(shift_right(chi0_z_acc_delta * exp_term, Q), 48);

            chi0_x_vel_pred_int <= chi0_x_vel_in + chi0_x_vel_term + a_mean_x_dt;
            chi0_y_vel_pred_int <= chi0_y_vel_in + chi0_y_vel_term + a_mean_y_dt;
            chi0_z_vel_pred_int <= chi0_z_vel_in + chi0_z_vel_term + a_mean_z_dt;

            chi0_x_pos_pred_int <= chi0_x_pos_in + chi0_x_vel_dt + chi0_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48);
            chi0_y_pos_pred_int <= chi0_y_pos_in + chi0_y_vel_dt + chi0_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48);
            chi0_z_pos_pred_int <= chi0_z_pos_in + chi0_z_vel_dt + chi0_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi1_x_acc_pred_int <= a_mean_x + resize(shift_right(chi1_x_acc_delta * exp_term, Q), 48);
            chi1_y_acc_pred_int <= a_mean_y + resize(shift_right(chi1_y_acc_delta * exp_term, Q), 48);
            chi1_z_acc_pred_int <= a_mean_z + resize(shift_right(chi1_z_acc_delta * exp_term, Q), 48);
            chi1_x_vel_pred_int <= chi1_x_vel_in + chi1_x_vel_term + a_mean_x_dt;
            chi1_y_vel_pred_int <= chi1_y_vel_in + chi1_y_vel_term + a_mean_y_dt;
            chi1_z_vel_pred_int <= chi1_z_vel_in + chi1_z_vel_term + a_mean_z_dt;
            chi1_x_pos_pred_int <= chi1_x_pos_in + chi1_x_vel_dt + chi1_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48);
            chi1_y_pos_pred_int <= chi1_y_pos_in + chi1_y_vel_dt + chi1_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48);
            chi1_z_pos_pred_int <= chi1_z_pos_in + chi1_z_vel_dt + chi1_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi2_x_acc_pred_int <= a_mean_x + resize(shift_right(chi2_x_acc_delta * exp_term, Q), 48);
            chi2_y_acc_pred_int <= a_mean_y + resize(shift_right(chi2_y_acc_delta * exp_term, Q), 48);
            chi2_z_acc_pred_int <= a_mean_z + resize(shift_right(chi2_z_acc_delta * exp_term, Q), 48);
            chi2_x_vel_pred_int <= chi2_x_vel_in + chi2_x_vel_term + a_mean_x_dt;
            chi2_y_vel_pred_int <= chi2_y_vel_in + chi2_y_vel_term + a_mean_y_dt;
            chi2_z_vel_pred_int <= chi2_z_vel_in + chi2_z_vel_term + a_mean_z_dt;
            chi2_x_pos_pred_int <= chi2_x_pos_in + chi2_x_vel_dt + chi2_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48);
            chi2_y_pos_pred_int <= chi2_y_pos_in + chi2_y_vel_dt + chi2_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48);
            chi2_z_pos_pred_int <= chi2_z_pos_in + chi2_z_vel_dt + chi2_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi3_x_acc_pred_int <= a_mean_x + resize(shift_right(chi3_x_acc_delta * exp_term, Q), 48);
            chi3_y_acc_pred_int <= a_mean_y + resize(shift_right(chi3_y_acc_delta * exp_term, Q), 48);
            chi3_z_acc_pred_int <= a_mean_z + resize(shift_right(chi3_z_acc_delta * exp_term, Q), 48);
            chi3_x_vel_pred_int <= chi3_x_vel_in + chi3_x_vel_term + a_mean_x_dt; chi3_y_vel_pred_int <= chi3_y_vel_in + chi3_y_vel_term + a_mean_y_dt; chi3_z_vel_pred_int <= chi3_z_vel_in + chi3_z_vel_term + a_mean_z_dt;
            chi3_x_pos_pred_int <= chi3_x_pos_in + chi3_x_vel_dt + chi3_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48);
            chi3_y_pos_pred_int <= chi3_y_pos_in + chi3_y_vel_dt + chi3_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48);
            chi3_z_pos_pred_int <= chi3_z_pos_in + chi3_z_vel_dt + chi3_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi4_x_acc_pred_int <= a_mean_x + resize(shift_right(chi4_x_acc_delta * exp_term, Q), 48); chi4_y_acc_pred_int <= a_mean_y + resize(shift_right(chi4_y_acc_delta * exp_term, Q), 48); chi4_z_acc_pred_int <= a_mean_z + resize(shift_right(chi4_z_acc_delta * exp_term, Q), 48);
            chi4_x_vel_pred_int <= chi4_x_vel_in + chi4_x_vel_term + a_mean_x_dt; chi4_y_vel_pred_int <= chi4_y_vel_in + chi4_y_vel_term + a_mean_y_dt; chi4_z_vel_pred_int <= chi4_z_vel_in + chi4_z_vel_term + a_mean_z_dt;
            chi4_x_pos_pred_int <= chi4_x_pos_in + chi4_x_vel_dt + chi4_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi4_y_pos_pred_int <= chi4_y_pos_in + chi4_y_vel_dt + chi4_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi4_z_pos_pred_int <= chi4_z_pos_in + chi4_z_vel_dt + chi4_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi5_x_acc_pred_int <= a_mean_x + resize(shift_right(chi5_x_acc_delta * exp_term, Q), 48); chi5_y_acc_pred_int <= a_mean_y + resize(shift_right(chi5_y_acc_delta * exp_term, Q), 48); chi5_z_acc_pred_int <= a_mean_z + resize(shift_right(chi5_z_acc_delta * exp_term, Q), 48);
            chi5_x_vel_pred_int <= chi5_x_vel_in + chi5_x_vel_term + a_mean_x_dt; chi5_y_vel_pred_int <= chi5_y_vel_in + chi5_y_vel_term + a_mean_y_dt; chi5_z_vel_pred_int <= chi5_z_vel_in + chi5_z_vel_term + a_mean_z_dt;
            chi5_x_pos_pred_int <= chi5_x_pos_in + chi5_x_vel_dt + chi5_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi5_y_pos_pred_int <= chi5_y_pos_in + chi5_y_vel_dt + chi5_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi5_z_pos_pred_int <= chi5_z_pos_in + chi5_z_vel_dt + chi5_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi6_x_acc_pred_int <= a_mean_x + resize(shift_right(chi6_x_acc_delta * exp_term, Q), 48); chi6_y_acc_pred_int <= a_mean_y + resize(shift_right(chi6_y_acc_delta * exp_term, Q), 48); chi6_z_acc_pred_int <= a_mean_z + resize(shift_right(chi6_z_acc_delta * exp_term, Q), 48);
            chi6_x_vel_pred_int <= chi6_x_vel_in + chi6_x_vel_term + a_mean_x_dt; chi6_y_vel_pred_int <= chi6_y_vel_in + chi6_y_vel_term + a_mean_y_dt; chi6_z_vel_pred_int <= chi6_z_vel_in + chi6_z_vel_term + a_mean_z_dt;
            chi6_x_pos_pred_int <= chi6_x_pos_in + chi6_x_vel_dt + chi6_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi6_y_pos_pred_int <= chi6_y_pos_in + chi6_y_vel_dt + chi6_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi6_z_pos_pred_int <= chi6_z_pos_in + chi6_z_vel_dt + chi6_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi7_x_acc_pred_int <= a_mean_x + resize(shift_right(chi7_x_acc_delta * exp_term, Q), 48); chi7_y_acc_pred_int <= a_mean_y + resize(shift_right(chi7_y_acc_delta * exp_term, Q), 48); chi7_z_acc_pred_int <= a_mean_z + resize(shift_right(chi7_z_acc_delta * exp_term, Q), 48);
            chi7_x_vel_pred_int <= chi7_x_vel_in + chi7_x_vel_term + a_mean_x_dt; chi7_y_vel_pred_int <= chi7_y_vel_in + chi7_y_vel_term + a_mean_y_dt; chi7_z_vel_pred_int <= chi7_z_vel_in + chi7_z_vel_term + a_mean_z_dt;
            chi7_x_pos_pred_int <= chi7_x_pos_in + chi7_x_vel_dt + chi7_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi7_y_pos_pred_int <= chi7_y_pos_in + chi7_y_vel_dt + chi7_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi7_z_pos_pred_int <= chi7_z_pos_in + chi7_z_vel_dt + chi7_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi8_x_acc_pred_int <= a_mean_x + resize(shift_right(chi8_x_acc_delta * exp_term, Q), 48); chi8_y_acc_pred_int <= a_mean_y + resize(shift_right(chi8_y_acc_delta * exp_term, Q), 48); chi8_z_acc_pred_int <= a_mean_z + resize(shift_right(chi8_z_acc_delta * exp_term, Q), 48);
            chi8_x_vel_pred_int <= chi8_x_vel_in + chi8_x_vel_term + a_mean_x_dt; chi8_y_vel_pred_int <= chi8_y_vel_in + chi8_y_vel_term + a_mean_y_dt; chi8_z_vel_pred_int <= chi8_z_vel_in + chi8_z_vel_term + a_mean_z_dt;
            chi8_x_pos_pred_int <= chi8_x_pos_in + chi8_x_vel_dt + chi8_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi8_y_pos_pred_int <= chi8_y_pos_in + chi8_y_vel_dt + chi8_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi8_z_pos_pred_int <= chi8_z_pos_in + chi8_z_vel_dt + chi8_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi9_x_acc_pred_int <= a_mean_x + resize(shift_right(chi9_x_acc_delta * exp_term, Q), 48); chi9_y_acc_pred_int <= a_mean_y + resize(shift_right(chi9_y_acc_delta * exp_term, Q), 48); chi9_z_acc_pred_int <= a_mean_z + resize(shift_right(chi9_z_acc_delta * exp_term, Q), 48);
            chi9_x_vel_pred_int <= chi9_x_vel_in + chi9_x_vel_term + a_mean_x_dt; chi9_y_vel_pred_int <= chi9_y_vel_in + chi9_y_vel_term + a_mean_y_dt; chi9_z_vel_pred_int <= chi9_z_vel_in + chi9_z_vel_term + a_mean_z_dt;
            chi9_x_pos_pred_int <= chi9_x_pos_in + chi9_x_vel_dt + chi9_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi9_y_pos_pred_int <= chi9_y_pos_in + chi9_y_vel_dt + chi9_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi9_z_pos_pred_int <= chi9_z_pos_in + chi9_z_vel_dt + chi9_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi10_x_acc_pred_int <= a_mean_x + resize(shift_right(chi10_x_acc_delta * exp_term, Q), 48); chi10_y_acc_pred_int <= a_mean_y + resize(shift_right(chi10_y_acc_delta * exp_term, Q), 48); chi10_z_acc_pred_int <= a_mean_z + resize(shift_right(chi10_z_acc_delta * exp_term, Q), 48);
            chi10_x_vel_pred_int <= chi10_x_vel_in + chi10_x_vel_term + a_mean_x_dt; chi10_y_vel_pred_int <= chi10_y_vel_in + chi10_y_vel_term + a_mean_y_dt; chi10_z_vel_pred_int <= chi10_z_vel_in + chi10_z_vel_term + a_mean_z_dt;
            chi10_x_pos_pred_int <= chi10_x_pos_in + chi10_x_vel_dt + chi10_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi10_y_pos_pred_int <= chi10_y_pos_in + chi10_y_vel_dt + chi10_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi10_z_pos_pred_int <= chi10_z_pos_in + chi10_z_vel_dt + chi10_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi11_x_acc_pred_int <= a_mean_x + resize(shift_right(chi11_x_acc_delta * exp_term, Q), 48); chi11_y_acc_pred_int <= a_mean_y + resize(shift_right(chi11_y_acc_delta * exp_term, Q), 48); chi11_z_acc_pred_int <= a_mean_z + resize(shift_right(chi11_z_acc_delta * exp_term, Q), 48);
            chi11_x_vel_pred_int <= chi11_x_vel_in + chi11_x_vel_term + a_mean_x_dt; chi11_y_vel_pred_int <= chi11_y_vel_in + chi11_y_vel_term + a_mean_y_dt; chi11_z_vel_pred_int <= chi11_z_vel_in + chi11_z_vel_term + a_mean_z_dt;
            chi11_x_pos_pred_int <= chi11_x_pos_in + chi11_x_vel_dt + chi11_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi11_y_pos_pred_int <= chi11_y_pos_in + chi11_y_vel_dt + chi11_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi11_z_pos_pred_int <= chi11_z_pos_in + chi11_z_vel_dt + chi11_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi12_x_acc_pred_int <= a_mean_x + resize(shift_right(chi12_x_acc_delta * exp_term, Q), 48); chi12_y_acc_pred_int <= a_mean_y + resize(shift_right(chi12_y_acc_delta * exp_term, Q), 48); chi12_z_acc_pred_int <= a_mean_z + resize(shift_right(chi12_z_acc_delta * exp_term, Q), 48);
            chi12_x_vel_pred_int <= chi12_x_vel_in + chi12_x_vel_term + a_mean_x_dt; chi12_y_vel_pred_int <= chi12_y_vel_in + chi12_y_vel_term + a_mean_y_dt; chi12_z_vel_pred_int <= chi12_z_vel_in + chi12_z_vel_term + a_mean_z_dt;
            chi12_x_pos_pred_int <= chi12_x_pos_in + chi12_x_vel_dt + chi12_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi12_y_pos_pred_int <= chi12_y_pos_in + chi12_y_vel_dt + chi12_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi12_z_pos_pred_int <= chi12_z_pos_in + chi12_z_vel_dt + chi12_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi13_x_acc_pred_int <= a_mean_x + resize(shift_right(chi13_x_acc_delta * exp_term, Q), 48); chi13_y_acc_pred_int <= a_mean_y + resize(shift_right(chi13_y_acc_delta * exp_term, Q), 48); chi13_z_acc_pred_int <= a_mean_z + resize(shift_right(chi13_z_acc_delta * exp_term, Q), 48);
            chi13_x_vel_pred_int <= chi13_x_vel_in + chi13_x_vel_term + a_mean_x_dt; chi13_y_vel_pred_int <= chi13_y_vel_in + chi13_y_vel_term + a_mean_y_dt; chi13_z_vel_pred_int <= chi13_z_vel_in + chi13_z_vel_term + a_mean_z_dt;
            chi13_x_pos_pred_int <= chi13_x_pos_in + chi13_x_vel_dt + chi13_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi13_y_pos_pred_int <= chi13_y_pos_in + chi13_y_vel_dt + chi13_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi13_z_pos_pred_int <= chi13_z_pos_in + chi13_z_vel_dt + chi13_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi14_x_acc_pred_int <= a_mean_x + resize(shift_right(chi14_x_acc_delta * exp_term, Q), 48); chi14_y_acc_pred_int <= a_mean_y + resize(shift_right(chi14_y_acc_delta * exp_term, Q), 48); chi14_z_acc_pred_int <= a_mean_z + resize(shift_right(chi14_z_acc_delta * exp_term, Q), 48);
            chi14_x_vel_pred_int <= chi14_x_vel_in + chi14_x_vel_term + a_mean_x_dt; chi14_y_vel_pred_int <= chi14_y_vel_in + chi14_y_vel_term + a_mean_y_dt; chi14_z_vel_pred_int <= chi14_z_vel_in + chi14_z_vel_term + a_mean_z_dt;
            chi14_x_pos_pred_int <= chi14_x_pos_in + chi14_x_vel_dt + chi14_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi14_y_pos_pred_int <= chi14_y_pos_in + chi14_y_vel_dt + chi14_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi14_z_pos_pred_int <= chi14_z_pos_in + chi14_z_vel_dt + chi14_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi15_x_acc_pred_int <= a_mean_x + resize(shift_right(chi15_x_acc_delta * exp_term, Q), 48); chi15_y_acc_pred_int <= a_mean_y + resize(shift_right(chi15_y_acc_delta * exp_term, Q), 48); chi15_z_acc_pred_int <= a_mean_z + resize(shift_right(chi15_z_acc_delta * exp_term, Q), 48);
            chi15_x_vel_pred_int <= chi15_x_vel_in + chi15_x_vel_term + a_mean_x_dt; chi15_y_vel_pred_int <= chi15_y_vel_in + chi15_y_vel_term + a_mean_y_dt; chi15_z_vel_pred_int <= chi15_z_vel_in + chi15_z_vel_term + a_mean_z_dt;
            chi15_x_pos_pred_int <= chi15_x_pos_in + chi15_x_vel_dt + chi15_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi15_y_pos_pred_int <= chi15_y_pos_in + chi15_y_vel_dt + chi15_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi15_z_pos_pred_int <= chi15_z_pos_in + chi15_z_vel_dt + chi15_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi16_x_acc_pred_int <= a_mean_x + resize(shift_right(chi16_x_acc_delta * exp_term, Q), 48); chi16_y_acc_pred_int <= a_mean_y + resize(shift_right(chi16_y_acc_delta * exp_term, Q), 48); chi16_z_acc_pred_int <= a_mean_z + resize(shift_right(chi16_z_acc_delta * exp_term, Q), 48);
            chi16_x_vel_pred_int <= chi16_x_vel_in + chi16_x_vel_term + a_mean_x_dt; chi16_y_vel_pred_int <= chi16_y_vel_in + chi16_y_vel_term + a_mean_y_dt; chi16_z_vel_pred_int <= chi16_z_vel_in + chi16_z_vel_term + a_mean_z_dt;
            chi16_x_pos_pred_int <= chi16_x_pos_in + chi16_x_vel_dt + chi16_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi16_y_pos_pred_int <= chi16_y_pos_in + chi16_y_vel_dt + chi16_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi16_z_pos_pred_int <= chi16_z_pos_in + chi16_z_vel_dt + chi16_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi17_x_acc_pred_int <= a_mean_x + resize(shift_right(chi17_x_acc_delta * exp_term, Q), 48); chi17_y_acc_pred_int <= a_mean_y + resize(shift_right(chi17_y_acc_delta * exp_term, Q), 48); chi17_z_acc_pred_int <= a_mean_z + resize(shift_right(chi17_z_acc_delta * exp_term, Q), 48);
            chi17_x_vel_pred_int <= chi17_x_vel_in + chi17_x_vel_term + a_mean_x_dt; chi17_y_vel_pred_int <= chi17_y_vel_in + chi17_y_vel_term + a_mean_y_dt; chi17_z_vel_pred_int <= chi17_z_vel_in + chi17_z_vel_term + a_mean_z_dt;
            chi17_x_pos_pred_int <= chi17_x_pos_in + chi17_x_vel_dt + chi17_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi17_y_pos_pred_int <= chi17_y_pos_in + chi17_y_vel_dt + chi17_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi17_z_pos_pred_int <= chi17_z_pos_in + chi17_z_vel_dt + chi17_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            chi18_x_acc_pred_int <= a_mean_x + resize(shift_right(chi18_x_acc_delta * exp_term, Q), 48); chi18_y_acc_pred_int <= a_mean_y + resize(shift_right(chi18_y_acc_delta * exp_term, Q), 48); chi18_z_acc_pred_int <= a_mean_z + resize(shift_right(chi18_z_acc_delta * exp_term, Q), 48);
            chi18_x_vel_pred_int <= chi18_x_vel_in + chi18_x_vel_term + a_mean_x_dt; chi18_y_vel_pred_int <= chi18_y_vel_in + chi18_y_vel_term + a_mean_y_dt; chi18_z_vel_pred_int <= chi18_z_vel_in + chi18_z_vel_term + a_mean_z_dt;
            chi18_x_pos_pred_int <= chi18_x_pos_in + chi18_x_vel_dt + chi18_x_pos_term + resize(shift_right(a_mean_x_half_dt_sq, Q), 48); chi18_y_pos_pred_int <= chi18_y_pos_in + chi18_y_vel_dt + chi18_y_pos_term + resize(shift_right(a_mean_y_half_dt_sq, Q), 48); chi18_z_pos_pred_int <= chi18_z_pos_in + chi18_z_vel_dt + chi18_z_pos_term + resize(shift_right(a_mean_z_half_dt_sq, Q), 48);

            if cycle_num >= 1 and cycle_num <= 2 then
              report "PREDICTI[" & integer'image(cycle_num) & "]: CALCULATE - Checking computations:" & LF &
                     "  chi0_x_vel_dt = " & integer'image(to_integer(chi0_x_vel_dt)) & LF &
                     "  chi0_x_acc_delta = " & integer'image(to_integer(chi0_x_acc_delta)) & LF &
                     "  chi0_x_vel_term = " & integer'image(to_integer(chi0_x_vel_term)) & LF &
                     "  chi0_x_pos_term = " & integer'image(to_integer(chi0_x_pos_term));
              report "PREDICTI[" & integer'image(cycle_num) & "]: CALCULATE - Output values:" & LF &
                     "  chi0_x_pos_pred_int = " & integer'image(to_integer(chi0_x_pos_pred_int)) & LF &
                     "  chi1_x_pos_pred_int = " & integer'image(to_integer(chi1_x_pos_pred_int)) & LF &
                     "  chi2_x_pos_pred_int = " & integer'image(to_integer(chi2_x_pos_pred_int)) & LF &
                     "  chi10_x_pos_pred_int = " & integer'image(to_integer(chi10_x_pos_pred_int));
            end if;

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

  chi0_x_pos_pred <= chi0_x_pos_pred_int; chi0_x_vel_pred <= chi0_x_vel_pred_int; chi0_x_acc_pred <= chi0_x_acc_pred_int;
  chi0_y_pos_pred <= chi0_y_pos_pred_int; chi0_y_vel_pred <= chi0_y_vel_pred_int; chi0_y_acc_pred <= chi0_y_acc_pred_int;
  chi0_z_pos_pred <= chi0_z_pos_pred_int; chi0_z_vel_pred <= chi0_z_vel_pred_int; chi0_z_acc_pred <= chi0_z_acc_pred_int;

  chi1_x_pos_pred <= chi1_x_pos_pred_int; chi1_x_vel_pred <= chi1_x_vel_pred_int; chi1_x_acc_pred <= chi1_x_acc_pred_int;
  chi1_y_pos_pred <= chi1_y_pos_pred_int; chi1_y_vel_pred <= chi1_y_vel_pred_int; chi1_y_acc_pred <= chi1_y_acc_pred_int;
  chi1_z_pos_pred <= chi1_z_pos_pred_int; chi1_z_vel_pred <= chi1_z_vel_pred_int; chi1_z_acc_pred <= chi1_z_acc_pred_int;

  chi2_x_pos_pred <= chi2_x_pos_pred_int; chi2_x_vel_pred <= chi2_x_vel_pred_int; chi2_x_acc_pred <= chi2_x_acc_pred_int;
  chi2_y_pos_pred <= chi2_y_pos_pred_int; chi2_y_vel_pred <= chi2_y_vel_pred_int; chi2_y_acc_pred <= chi2_y_acc_pred_int;
  chi2_z_pos_pred <= chi2_z_pos_pred_int; chi2_z_vel_pred <= chi2_z_vel_pred_int; chi2_z_acc_pred <= chi2_z_acc_pred_int;

  chi3_x_pos_pred <= chi3_x_pos_pred_int; chi3_x_vel_pred <= chi3_x_vel_pred_int; chi3_x_acc_pred <= chi3_x_acc_pred_int;
  chi3_y_pos_pred <= chi3_y_pos_pred_int; chi3_y_vel_pred <= chi3_y_vel_pred_int; chi3_y_acc_pred <= chi3_y_acc_pred_int;
  chi3_z_pos_pred <= chi3_z_pos_pred_int; chi3_z_vel_pred <= chi3_z_vel_pred_int; chi3_z_acc_pred <= chi3_z_acc_pred_int;

  chi4_x_pos_pred <= chi4_x_pos_pred_int; chi4_x_vel_pred <= chi4_x_vel_pred_int; chi4_x_acc_pred <= chi4_x_acc_pred_int;
  chi4_y_pos_pred <= chi4_y_pos_pred_int; chi4_y_vel_pred <= chi4_y_vel_pred_int; chi4_y_acc_pred <= chi4_y_acc_pred_int;
  chi4_z_pos_pred <= chi4_z_pos_pred_int; chi4_z_vel_pred <= chi4_z_vel_pred_int; chi4_z_acc_pred <= chi4_z_acc_pred_int;

  chi5_x_pos_pred <= chi5_x_pos_pred_int; chi5_x_vel_pred <= chi5_x_vel_pred_int; chi5_x_acc_pred <= chi5_x_acc_pred_int;
  chi5_y_pos_pred <= chi5_y_pos_pred_int; chi5_y_vel_pred <= chi5_y_vel_pred_int; chi5_y_acc_pred <= chi5_y_acc_pred_int;
  chi5_z_pos_pred <= chi5_z_pos_pred_int; chi5_z_vel_pred <= chi5_z_vel_pred_int; chi5_z_acc_pred <= chi5_z_acc_pred_int;

  chi6_x_pos_pred <= chi6_x_pos_pred_int; chi6_x_vel_pred <= chi6_x_vel_pred_int; chi6_x_acc_pred <= chi6_x_acc_pred_int;
  chi6_y_pos_pred <= chi6_y_pos_pred_int; chi6_y_vel_pred <= chi6_y_vel_pred_int; chi6_y_acc_pred <= chi6_y_acc_pred_int;
  chi6_z_pos_pred <= chi6_z_pos_pred_int; chi6_z_vel_pred <= chi6_z_vel_pred_int; chi6_z_acc_pred <= chi6_z_acc_pred_int;

  chi7_x_pos_pred <= chi7_x_pos_pred_int; chi7_x_vel_pred <= chi7_x_vel_pred_int; chi7_x_acc_pred <= chi7_x_acc_pred_int;
  chi7_y_pos_pred <= chi7_y_pos_pred_int; chi7_y_vel_pred <= chi7_y_vel_pred_int; chi7_y_acc_pred <= chi7_y_acc_pred_int;
  chi7_z_pos_pred <= chi7_z_pos_pred_int; chi7_z_vel_pred <= chi7_z_vel_pred_int; chi7_z_acc_pred <= chi7_z_acc_pred_int;

  chi8_x_pos_pred <= chi8_x_pos_pred_int; chi8_x_vel_pred <= chi8_x_vel_pred_int; chi8_x_acc_pred <= chi8_x_acc_pred_int;
  chi8_y_pos_pred <= chi8_y_pos_pred_int; chi8_y_vel_pred <= chi8_y_vel_pred_int; chi8_y_acc_pred <= chi8_y_acc_pred_int;
  chi8_z_pos_pred <= chi8_z_pos_pred_int; chi8_z_vel_pred <= chi8_z_vel_pred_int; chi8_z_acc_pred <= chi8_z_acc_pred_int;

  chi9_x_pos_pred <= chi9_x_pos_pred_int; chi9_x_vel_pred <= chi9_x_vel_pred_int; chi9_x_acc_pred <= chi9_x_acc_pred_int;
  chi9_y_pos_pred <= chi9_y_pos_pred_int; chi9_y_vel_pred <= chi9_y_vel_pred_int; chi9_y_acc_pred <= chi9_y_acc_pred_int;
  chi9_z_pos_pred <= chi9_z_pos_pred_int; chi9_z_vel_pred <= chi9_z_vel_pred_int; chi9_z_acc_pred <= chi9_z_acc_pred_int;

  chi10_x_pos_pred <= chi10_x_pos_pred_int; chi10_x_vel_pred <= chi10_x_vel_pred_int; chi10_x_acc_pred <= chi10_x_acc_pred_int;
  chi10_y_pos_pred <= chi10_y_pos_pred_int; chi10_y_vel_pred <= chi10_y_vel_pred_int; chi10_y_acc_pred <= chi10_y_acc_pred_int;
  chi10_z_pos_pred <= chi10_z_pos_pred_int; chi10_z_vel_pred <= chi10_z_vel_pred_int; chi10_z_acc_pred <= chi10_z_acc_pred_int;

  chi11_x_pos_pred <= chi11_x_pos_pred_int; chi11_x_vel_pred <= chi11_x_vel_pred_int; chi11_x_acc_pred <= chi11_x_acc_pred_int;
  chi11_y_pos_pred <= chi11_y_pos_pred_int; chi11_y_vel_pred <= chi11_y_vel_pred_int; chi11_y_acc_pred <= chi11_y_acc_pred_int;
  chi11_z_pos_pred <= chi11_z_pos_pred_int; chi11_z_vel_pred <= chi11_z_vel_pred_int; chi11_z_acc_pred <= chi11_z_acc_pred_int;

  chi12_x_pos_pred <= chi12_x_pos_pred_int; chi12_x_vel_pred <= chi12_x_vel_pred_int; chi12_x_acc_pred <= chi12_x_acc_pred_int;
  chi12_y_pos_pred <= chi12_y_pos_pred_int; chi12_y_vel_pred <= chi12_y_vel_pred_int; chi12_y_acc_pred <= chi12_y_acc_pred_int;
  chi12_z_pos_pred <= chi12_z_pos_pred_int; chi12_z_vel_pred <= chi12_z_vel_pred_int; chi12_z_acc_pred <= chi12_z_acc_pred_int;

  chi13_x_pos_pred <= chi13_x_pos_pred_int; chi13_x_vel_pred <= chi13_x_vel_pred_int; chi13_x_acc_pred <= chi13_x_acc_pred_int;
  chi13_y_pos_pred <= chi13_y_pos_pred_int; chi13_y_vel_pred <= chi13_y_vel_pred_int; chi13_y_acc_pred <= chi13_y_acc_pred_int;
  chi13_z_pos_pred <= chi13_z_pos_pred_int; chi13_z_vel_pred <= chi13_z_vel_pred_int; chi13_z_acc_pred <= chi13_z_acc_pred_int;

  chi14_x_pos_pred <= chi14_x_pos_pred_int; chi14_x_vel_pred <= chi14_x_vel_pred_int; chi14_x_acc_pred <= chi14_x_acc_pred_int;
  chi14_y_pos_pred <= chi14_y_pos_pred_int; chi14_y_vel_pred <= chi14_y_vel_pred_int; chi14_y_acc_pred <= chi14_y_acc_pred_int;
  chi14_z_pos_pred <= chi14_z_pos_pred_int; chi14_z_vel_pred <= chi14_z_vel_pred_int; chi14_z_acc_pred <= chi14_z_acc_pred_int;

  chi15_x_pos_pred <= chi15_x_pos_pred_int; chi15_x_vel_pred <= chi15_x_vel_pred_int; chi15_x_acc_pred <= chi15_x_acc_pred_int;
  chi15_y_pos_pred <= chi15_y_pos_pred_int; chi15_y_vel_pred <= chi15_y_vel_pred_int; chi15_y_acc_pred <= chi15_y_acc_pred_int;
  chi15_z_pos_pred <= chi15_z_pos_pred_int; chi15_z_vel_pred <= chi15_z_vel_pred_int; chi15_z_acc_pred <= chi15_z_acc_pred_int;

  chi16_x_pos_pred <= chi16_x_pos_pred_int; chi16_x_vel_pred <= chi16_x_vel_pred_int; chi16_x_acc_pred <= chi16_x_acc_pred_int;
  chi16_y_pos_pred <= chi16_y_pos_pred_int; chi16_y_vel_pred <= chi16_y_vel_pred_int; chi16_y_acc_pred <= chi16_y_acc_pred_int;
  chi16_z_pos_pred <= chi16_z_pos_pred_int; chi16_z_vel_pred <= chi16_z_vel_pred_int; chi16_z_acc_pred <= chi16_z_acc_pred_int;

  chi17_x_pos_pred <= chi17_x_pos_pred_int; chi17_x_vel_pred <= chi17_x_vel_pred_int; chi17_x_acc_pred <= chi17_x_acc_pred_int;
  chi17_y_pos_pred <= chi17_y_pos_pred_int; chi17_y_vel_pred <= chi17_y_vel_pred_int; chi17_y_acc_pred <= chi17_y_acc_pred_int;
  chi17_z_pos_pred <= chi17_z_pos_pred_int; chi17_z_vel_pred <= chi17_z_vel_pred_int; chi17_z_acc_pred <= chi17_z_acc_pred_int;

  chi18_x_pos_pred <= chi18_x_pos_pred_int; chi18_x_vel_pred <= chi18_x_vel_pred_int; chi18_x_acc_pred <= chi18_x_acc_pred_int;
  chi18_y_pos_pred <= chi18_y_pos_pred_int; chi18_y_vel_pred <= chi18_y_vel_pred_int; chi18_y_acc_pred <= chi18_y_acc_pred_int;
  chi18_z_pos_pred <= chi18_z_pos_pred_int; chi18_z_vel_pred <= chi18_z_vel_pred_int; chi18_z_acc_pred <= chi18_z_acc_pred_int;

end Behavioral;
