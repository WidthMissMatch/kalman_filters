library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity imm_f1_top is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    start : in  std_logic;

    z_x_meas : in signed(47 downto 0);
    z_y_meas : in signed(47 downto 0);
    z_z_meas : in signed(47 downto 0);

    px_out : out signed(47 downto 0);
    py_out : out signed(47 downto 0);
    pz_out : out signed(47 downto 0);

    prob_ca_out     : out signed(47 downto 0);
    prob_singer_out : out signed(47 downto 0);
    prob_bike_out   : out signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of imm_f1_top is

  constant Q : integer := 24;
  constant ONE_Q24 : signed(47 downto 0) := to_signed(2**Q, 48);
  constant ZERO48  : signed(47 downto 0) := (others => '0');

  constant PROB_INIT_CA     : signed(47 downto 0) := to_signed(8388608, 48);
  constant PROB_INIT_SINGER : signed(47 downto 0) := to_signed(5033165, 48);
  constant PROB_INIT_BIKE   : signed(47 downto 0) := to_signed(3355443, 48);

  type fsm_state_t is (
    IDLE,
    INIT_FIRST,
    MAP_STATES,
    WAIT_MAP,
    START_MIX,
    WAIT_MIX,
    START_COV_MIX,
    WAIT_COV_MIX,
    INJECT_MIXED,
    WAIT_FILTERS,
    START_LIKELIHOOD,
    WAIT_LIKELIHOOD,
    START_PROB_UPDATE,
    WAIT_PROB_UPDATE,
    START_FUSION,
    WAIT_FUSION,
    DONE_STATE
  );
  signal state : fsm_state_t := IDLE;

  component ca_ukf_supreme_imm is
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      start : in  std_logic;
      z_x_meas : in signed(47 downto 0);
      z_y_meas : in signed(47 downto 0);
      z_z_meas : in signed(47 downto 0);
      inject_en : in std_logic;
      inject_state_only : in std_logic;
      inj_x_pos, inj_x_vel, inj_x_acc : in signed(47 downto 0);
      inj_y_pos, inj_y_vel, inj_y_acc : in signed(47 downto 0);
      inj_z_pos, inj_z_vel, inj_z_acc : in signed(47 downto 0);
      inj_p11, inj_p22, inj_p33 : in signed(47 downto 0);
      inj_p44, inj_p55, inj_p66 : in signed(47 downto 0);
      inj_p77, inj_p88, inj_p99 : in signed(47 downto 0);
      x_pos_current : out signed(47 downto 0);
      x_vel_current : out signed(47 downto 0);
      x_acc_current : out signed(47 downto 0);
      y_pos_current : out signed(47 downto 0);
      y_vel_current : out signed(47 downto 0);
      y_acc_current : out signed(47 downto 0);
      z_pos_current : out signed(47 downto 0);
      z_vel_current : out signed(47 downto 0);
      z_acc_current : out signed(47 downto 0);
      x_pos_uncertainty : out signed(47 downto 0);
      x_vel_uncertainty : out signed(47 downto 0);
      x_acc_uncertainty : out signed(47 downto 0);
      y_pos_uncertainty : out signed(47 downto 0);
      y_vel_uncertainty : out signed(47 downto 0);
      y_acc_uncertainty : out signed(47 downto 0);
      z_pos_uncertainty : out signed(47 downto 0);
      z_vel_uncertainty : out signed(47 downto 0);
      z_acc_uncertainty : out signed(47 downto 0);
      nu_x_out, nu_y_out, nu_z_out : out signed(47 downto 0);
      s11_out, s22_out, s33_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component singer_ukf_supreme_imm is
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      start : in  std_logic;
      z_x_meas : in signed(47 downto 0);
      z_y_meas : in signed(47 downto 0);
      z_z_meas : in signed(47 downto 0);
      inject_en : in std_logic;
      inject_state_only : in std_logic;
      inj_x_pos, inj_x_vel, inj_x_acc : in signed(47 downto 0);
      inj_y_pos, inj_y_vel, inj_y_acc : in signed(47 downto 0);
      inj_z_pos, inj_z_vel, inj_z_acc : in signed(47 downto 0);
      inj_p11, inj_p22, inj_p33 : in signed(47 downto 0);
      inj_p44, inj_p55, inj_p66 : in signed(47 downto 0);
      inj_p77, inj_p88, inj_p99 : in signed(47 downto 0);
      x_pos_current : out signed(47 downto 0);
      x_vel_current : out signed(47 downto 0);
      x_acc_current : out signed(47 downto 0);
      y_pos_current : out signed(47 downto 0);
      y_vel_current : out signed(47 downto 0);
      y_acc_current : out signed(47 downto 0);
      z_pos_current : out signed(47 downto 0);
      z_vel_current : out signed(47 downto 0);
      z_acc_current : out signed(47 downto 0);
      x_pos_uncertainty : out signed(47 downto 0);
      x_vel_uncertainty : out signed(47 downto 0);
      x_acc_uncertainty : out signed(47 downto 0);
      y_pos_uncertainty : out signed(47 downto 0);
      y_vel_uncertainty : out signed(47 downto 0);
      y_acc_uncertainty : out signed(47 downto 0);
      z_pos_uncertainty : out signed(47 downto 0);
      z_vel_uncertainty : out signed(47 downto 0);
      z_acc_uncertainty : out signed(47 downto 0);
      nu_x_out, nu_y_out, nu_z_out : out signed(47 downto 0);
      s11_out, s22_out, s33_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component bicycle_ukf_supreme_imm is
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      start : in  std_logic;
      v_init     : in signed(47 downto 0);
      theta_init : in signed(47 downto 0);
      z_x_meas : in signed(47 downto 0);
      z_y_meas : in signed(47 downto 0);
      z_z_meas : in signed(47 downto 0);
      inject_en : in std_logic;
      inject_state_only : in std_logic;
      inj_px, inj_py, inj_v, inj_theta, inj_delta, inj_a, inj_z : in signed(47 downto 0);
      inj_p11, inj_p22, inj_p33, inj_p44, inj_p55, inj_p66, inj_p77 : in signed(47 downto 0);
      px_current    : out signed(47 downto 0);
      py_current    : out signed(47 downto 0);
      v_current     : out signed(47 downto 0);
      theta_current : out signed(47 downto 0);
      delta_current : out signed(47 downto 0);
      a_current     : out signed(47 downto 0);
      z_current     : out signed(47 downto 0);
      p11_diag : out signed(47 downto 0);
      p22_diag : out signed(47 downto 0);
      p33_diag : out signed(47 downto 0);
      p44_diag : out signed(47 downto 0);
      p55_diag : out signed(47 downto 0);
      p66_diag : out signed(47 downto 0);
      p77_diag : out signed(47 downto 0);
      nu_x_out, nu_y_out, nu_z_out : out signed(47 downto 0);
      s11_out, s22_out, s33_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component state_mapper_9d_to_7d is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      x_pos_in, x_vel_in, x_acc_in : in signed(47 downto 0);
      y_pos_in, y_vel_in, y_acc_in : in signed(47 downto 0);
      z_pos_in, z_vel_in, z_acc_in : in signed(47 downto 0);
      px_out, py_out, v_out, theta_out, delta_out, a_out, z_out : out signed(47 downto 0);
      done  : out std_logic
    );
  end component;

  component state_mapper_7d_to_9d is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      px_in, py_in, v_in, theta_in, delta_in, a_in, z_in : in signed(47 downto 0);
      x_pos_out, x_vel_out, x_acc_out : out signed(47 downto 0);
      y_pos_out, y_vel_out, y_acc_out : out signed(47 downto 0);
      z_pos_out, z_vel_out, z_acc_out : out signed(47 downto 0);
      done  : out std_logic
    );
  end component;

  component imm_state_mixer is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      prob_ca, prob_singer, prob_bicycle : in signed(47 downto 0);
      ca_s1, ca_s2, ca_s3, ca_s4, ca_s5, ca_s6, ca_s7, ca_s8, ca_s9 : in signed(47 downto 0);
      si_s1, si_s2, si_s3, si_s4, si_s5, si_s6, si_s7, si_s8, si_s9 : in signed(47 downto 0);
      bi_s1, bi_s2, bi_s3, bi_s4, bi_s5, bi_s6, bi_s7, bi_s8, bi_s9 : in signed(47 downto 0);
      ca_b1, ca_b2, ca_b3, ca_b4, ca_b5, ca_b6, ca_b7 : in signed(47 downto 0);
      si_b1, si_b2, si_b3, si_b4, si_b5, si_b6, si_b7 : in signed(47 downto 0);
      bi_b1, bi_b2, bi_b3, bi_b4, bi_b5, bi_b6, bi_b7 : in signed(47 downto 0);
      mix_ca_s1, mix_ca_s2, mix_ca_s3, mix_ca_s4, mix_ca_s5, mix_ca_s6, mix_ca_s7, mix_ca_s8, mix_ca_s9 : out signed(47 downto 0);
      mix_si_s1, mix_si_s2, mix_si_s3, mix_si_s4, mix_si_s5, mix_si_s6, mix_si_s7, mix_si_s8, mix_si_s9 : out signed(47 downto 0);
      mix_bi_b1, mix_bi_b2, mix_bi_b3, mix_bi_b4, mix_bi_b5, mix_bi_b6, mix_bi_b7 : out signed(47 downto 0);
      c_ca_out, c_singer_out, c_bicycle_out : out signed(47 downto 0);
      mu_ca_ca_out, mu_si_ca_out, mu_bi_ca_out : out signed(47 downto 0);
      mu_ca_si_out, mu_si_si_out, mu_bi_si_out : out signed(47 downto 0);
      mu_ca_bi_out, mu_si_bi_out, mu_bi_bi_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component imm_likelihood is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      nu1_x, nu1_y, nu1_z : in signed(47 downto 0);
      s1_11, s1_22, s1_33 : in signed(47 downto 0);
      nu2_x, nu2_y, nu2_z : in signed(47 downto 0);
      s2_11, s2_22, s2_33 : in signed(47 downto 0);
      nu3_x, nu3_y, nu3_z : in signed(47 downto 0);
      s3_11, s3_22, s3_33 : in signed(47 downto 0);
      L1_out, L2_out, L3_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component imm_prob_update is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      L_ca, L_singer, L_bicycle : in signed(47 downto 0);
      c_ca, c_singer, c_bicycle : in signed(47 downto 0);
      prob_ca_out, prob_singer_out, prob_bicycle_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component imm_output_fusion is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      prob_ca, prob_singer, prob_bicycle : in signed(47 downto 0);
      ca_px, ca_py, ca_pz       : in signed(47 downto 0);
      singer_px, singer_py, singer_pz : in signed(47 downto 0);
      bike_px, bike_py, bike_pz : in signed(47 downto 0);
      px_out, py_out, pz_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component imm_covariance_mixer is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      mu_ca_ca, mu_si_ca, mu_bi_ca : in signed(47 downto 0);
      mu_ca_si, mu_si_si, mu_bi_si : in signed(47 downto 0);
      mu_ca_bi, mu_si_bi, mu_bi_bi : in signed(47 downto 0);
      ca_p1, ca_p2, ca_p3, ca_p4, ca_p5, ca_p6, ca_p7, ca_p8, ca_p9 : in signed(47 downto 0);
      si_p1, si_p2, si_p3, si_p4, si_p5, si_p6, si_p7, si_p8, si_p9 : in signed(47 downto 0);
      bi_p1, bi_p2, bi_p3, bi_p4, bi_p5, bi_p6, bi_p7, bi_p8, bi_p9 : in signed(47 downto 0);
      ca_s1, ca_s2, ca_s3, ca_s4, ca_s5, ca_s6, ca_s7, ca_s8, ca_s9 : in signed(47 downto 0);
      si_s1, si_s2, si_s3, si_s4, si_s5, si_s6, si_s7, si_s8, si_s9 : in signed(47 downto 0);
      bi_s1, bi_s2, bi_s3, bi_s4, bi_s5, bi_s6, bi_s7, bi_s8, bi_s9 : in signed(47 downto 0);
      mix_ca_s1, mix_ca_s2, mix_ca_s3, mix_ca_s4, mix_ca_s5, mix_ca_s6, mix_ca_s7, mix_ca_s8, mix_ca_s9 : in signed(47 downto 0);
      mix_si_s1, mix_si_s2, mix_si_s3, mix_si_s4, mix_si_s5, mix_si_s6, mix_si_s7, mix_si_s8, mix_si_s9 : in signed(47 downto 0);
      mix_ca_p1, mix_ca_p2, mix_ca_p3, mix_ca_p4, mix_ca_p5, mix_ca_p6, mix_ca_p7, mix_ca_p8, mix_ca_p9 : out signed(47 downto 0);
      mix_si_p1, mix_si_p2, mix_si_p3, mix_si_p4, mix_si_p5, mix_si_p6, mix_si_p7, mix_si_p8, mix_si_p9 : out signed(47 downto 0);
      mix_bi_p1, mix_bi_p2, mix_bi_p3, mix_bi_p4, mix_bi_p5, mix_bi_p6, mix_bi_p7 : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  signal first_cycle  : std_logic := '1';
  signal skip_prob    : std_logic := '0';

  signal prob_ca     : signed(47 downto 0) := PROB_INIT_CA;
  signal prob_singer : signed(47 downto 0) := PROB_INIT_SINGER;
  signal prob_bike   : signed(47 downto 0) := PROB_INIT_BIKE;

  signal ca_xp, ca_xv, ca_xa : signed(47 downto 0) := (others => '0');
  signal ca_yp, ca_yv, ca_ya : signed(47 downto 0) := (others => '0');
  signal ca_zp, ca_zv, ca_za : signed(47 downto 0) := (others => '0');

  signal ca_p11, ca_p22, ca_p33 : signed(47 downto 0) := (others => '0');
  signal ca_p44, ca_p55, ca_p66 : signed(47 downto 0) := (others => '0');
  signal ca_p77, ca_p88, ca_p99 : signed(47 downto 0) := (others => '0');

  signal ca_nu_x, ca_nu_y, ca_nu_z : signed(47 downto 0) := (others => '0');
  signal ca_s11, ca_s22, ca_s33   : signed(47 downto 0) := (others => '0');

  signal si_xp, si_xv, si_xa : signed(47 downto 0) := (others => '0');
  signal si_yp, si_yv, si_ya : signed(47 downto 0) := (others => '0');
  signal si_zp, si_zv, si_za : signed(47 downto 0) := (others => '0');

  signal si_p11, si_p22, si_p33 : signed(47 downto 0) := (others => '0');
  signal si_p44, si_p55, si_p66 : signed(47 downto 0) := (others => '0');
  signal si_p77, si_p88, si_p99 : signed(47 downto 0) := (others => '0');

  signal si_nu_x, si_nu_y, si_nu_z : signed(47 downto 0) := (others => '0');
  signal si_s11, si_s22, si_s33   : signed(47 downto 0) := (others => '0');

  signal bi_px, bi_py, bi_v, bi_theta, bi_delta, bi_a, bi_z : signed(47 downto 0) := (others => '0');

  signal bi_p11, bi_p22, bi_p33, bi_p44, bi_p55, bi_p66, bi_p77 : signed(47 downto 0) := (others => '0');

  signal bi_nu_x, bi_nu_y, bi_nu_z : signed(47 downto 0) := (others => '0');
  signal bi_s11, bi_s22, bi_s33   : signed(47 downto 0) := (others => '0');

  signal map_ca_7d_px, map_ca_7d_py, map_ca_7d_v    : signed(47 downto 0) := (others => '0');
  signal map_ca_7d_theta, map_ca_7d_delta            : signed(47 downto 0) := (others => '0');
  signal map_ca_7d_a, map_ca_7d_z                    : signed(47 downto 0) := (others => '0');

  signal map_si_7d_px, map_si_7d_py, map_si_7d_v    : signed(47 downto 0) := (others => '0');
  signal map_si_7d_theta, map_si_7d_delta            : signed(47 downto 0) := (others => '0');
  signal map_si_7d_a, map_si_7d_z                    : signed(47 downto 0) := (others => '0');

  signal map_bi_9d_xp, map_bi_9d_xv, map_bi_9d_xa   : signed(47 downto 0) := (others => '0');
  signal map_bi_9d_yp, map_bi_9d_yv, map_bi_9d_ya   : signed(47 downto 0) := (others => '0');
  signal map_bi_9d_zp, map_bi_9d_zv, map_bi_9d_za   : signed(47 downto 0) := (others => '0');

  signal map_ca_7d_done  : std_logic := '0';
  signal map_si_7d_done  : std_logic := '0';
  signal map_bi_9d_done  : std_logic := '0';

  signal map_ca_done_latch : std_logic := '0';
  signal map_si_done_latch : std_logic := '0';
  signal map_bi_done_latch : std_logic := '0';

  signal mix_ca_s1, mix_ca_s2, mix_ca_s3 : signed(47 downto 0) := (others => '0');
  signal mix_ca_s4, mix_ca_s5, mix_ca_s6 : signed(47 downto 0) := (others => '0');
  signal mix_ca_s7, mix_ca_s8, mix_ca_s9 : signed(47 downto 0) := (others => '0');

  signal mix_si_s1, mix_si_s2, mix_si_s3 : signed(47 downto 0) := (others => '0');
  signal mix_si_s4, mix_si_s5, mix_si_s6 : signed(47 downto 0) := (others => '0');
  signal mix_si_s7, mix_si_s8, mix_si_s9 : signed(47 downto 0) := (others => '0');

  signal mix_bi_b1, mix_bi_b2, mix_bi_b3 : signed(47 downto 0) := (others => '0');
  signal mix_bi_b4, mix_bi_b5, mix_bi_b6 : signed(47 downto 0) := (others => '0');
  signal mix_bi_b7                        : signed(47 downto 0) := (others => '0');

  signal c_ca_mix      : signed(47 downto 0) := PROB_INIT_CA;
  signal c_singer_mix  : signed(47 downto 0) := PROB_INIT_SINGER;
  signal c_bicycle_mix : signed(47 downto 0) := PROB_INIT_BIKE;
  signal mixer_done : std_logic := '0';

  signal mu_ca_ca_sig, mu_si_ca_sig, mu_bi_ca_sig : signed(47 downto 0) := (others => '0');
  signal mu_ca_si_sig, mu_si_si_sig, mu_bi_si_sig : signed(47 downto 0) := (others => '0');
  signal mu_ca_bi_sig, mu_si_bi_sig, mu_bi_bi_sig : signed(47 downto 0) := (others => '0');

  signal mix_ca_p1, mix_ca_p2, mix_ca_p3, mix_ca_p4, mix_ca_p5, mix_ca_p6, mix_ca_p7, mix_ca_p8, mix_ca_p9 : signed(47 downto 0) := (others => '0');
  signal mix_si_p1, mix_si_p2, mix_si_p3, mix_si_p4, mix_si_p5, mix_si_p6, mix_si_p7, mix_si_p8, mix_si_p9 : signed(47 downto 0) := (others => '0');
  signal mix_bi_p1_sig, mix_bi_p2_sig, mix_bi_p3_sig, mix_bi_p4_sig, mix_bi_p5_sig, mix_bi_p6_sig, mix_bi_p7_sig : signed(47 downto 0) := (others => '0');

  signal cov_mixer_start : std_logic := '0';
  signal cov_mixer_done  : std_logic := '0';

  signal L_ca, L_singer, L_bike : signed(47 downto 0) := (others => '0');
  signal likelihood_done : std_logic := '0';

  signal prob_ca_new, prob_singer_new, prob_bike_new : signed(47 downto 0) := (others => '0');
  signal prob_update_done : std_logic := '0';

  signal fused_px, fused_py, fused_pz : signed(47 downto 0) := (others => '0');
  signal fusion_done : std_logic := '0';

  signal ca_start, si_start, bi_start : std_logic := '0';
  signal ca_inject_en, si_inject_en, bi_inject_en : std_logic := '0';
  signal ca_done_sig, si_done_sig, bi_done_sig : std_logic := '0';

  signal ca_done_latch, si_done_latch, bi_done_latch : std_logic := '0';

  signal map_ca_start, map_si_start, map_bi_start : std_logic := '0';

  signal mixer_start : std_logic := '0';

  signal likelihood_start : std_logic := '0';

  signal prob_update_start : std_logic := '0';

  signal fusion_start : std_logic := '0';

  signal ca_inj_xp, ca_inj_xv, ca_inj_xa : signed(47 downto 0) := (others => '0');
  signal ca_inj_yp, ca_inj_yv, ca_inj_ya : signed(47 downto 0) := (others => '0');
  signal ca_inj_zp, ca_inj_zv, ca_inj_za : signed(47 downto 0) := (others => '0');
  signal si_inj_xp, si_inj_xv, si_inj_xa : signed(47 downto 0) := (others => '0');
  signal si_inj_yp, si_inj_yv, si_inj_ya : signed(47 downto 0) := (others => '0');
  signal si_inj_zp, si_inj_zv, si_inj_za : signed(47 downto 0) := (others => '0');
  signal bi_inj_px, bi_inj_py, bi_inj_v  : signed(47 downto 0) := (others => '0');
  signal bi_inj_theta, bi_inj_delta       : signed(47 downto 0) := (others => '0');
  signal bi_inj_a, bi_inj_z              : signed(47 downto 0) := (others => '0');

  signal ca_inj_p11, ca_inj_p22, ca_inj_p33 : signed(47 downto 0) := (others => '0');
  signal ca_inj_p44, ca_inj_p55, ca_inj_p66 : signed(47 downto 0) := (others => '0');
  signal ca_inj_p77, ca_inj_p88, ca_inj_p99 : signed(47 downto 0) := (others => '0');
  signal si_inj_p11, si_inj_p22, si_inj_p33 : signed(47 downto 0) := (others => '0');
  signal si_inj_p44, si_inj_p55, si_inj_p66 : signed(47 downto 0) := (others => '0');
  signal si_inj_p77, si_inj_p88, si_inj_p99 : signed(47 downto 0) := (others => '0');
  signal bi_inj_p11, bi_inj_p22, bi_inj_p33 : signed(47 downto 0) := (others => '0');
  signal bi_inj_p44, bi_inj_p55, bi_inj_p66 : signed(47 downto 0) := (others => '0');
  signal bi_inj_p77                          : signed(47 downto 0) := (others => '0');

  signal ca_inject_state_only, si_inject_state_only, bi_inject_state_only : std_logic := '0';

begin

  u_ca_ukf : ca_ukf_supreme_imm
    port map (
      clk        => clk,
      reset      => reset,
      start      => ca_start,
      z_x_meas   => z_x_meas,
      z_y_meas   => z_y_meas,
      z_z_meas   => z_z_meas,
      inject_en  => ca_inject_en,
      inject_state_only => ca_inject_state_only,
      inj_x_pos  => ca_inj_xp,
      inj_x_vel  => ca_inj_xv,
      inj_x_acc  => ca_inj_xa,
      inj_y_pos  => ca_inj_yp,
      inj_y_vel  => ca_inj_yv,
      inj_y_acc  => ca_inj_ya,
      inj_z_pos  => ca_inj_zp,
      inj_z_vel  => ca_inj_zv,
      inj_z_acc  => ca_inj_za,
      inj_p11    => ca_inj_p11,
      inj_p22    => ca_inj_p22,
      inj_p33    => ca_inj_p33,
      inj_p44    => ca_inj_p44,
      inj_p55    => ca_inj_p55,
      inj_p66    => ca_inj_p66,
      inj_p77    => ca_inj_p77,
      inj_p88    => ca_inj_p88,
      inj_p99    => ca_inj_p99,
      x_pos_current => ca_xp,
      x_vel_current => ca_xv,
      x_acc_current => ca_xa,
      y_pos_current => ca_yp,
      y_vel_current => ca_yv,
      y_acc_current => ca_ya,
      z_pos_current => ca_zp,
      z_vel_current => ca_zv,
      z_acc_current => ca_za,
      x_pos_uncertainty => ca_p11,
      x_vel_uncertainty => ca_p22,
      x_acc_uncertainty => ca_p33,
      y_pos_uncertainty => ca_p44,
      y_vel_uncertainty => ca_p55,
      y_acc_uncertainty => ca_p66,
      z_pos_uncertainty => ca_p77,
      z_vel_uncertainty => ca_p88,
      z_acc_uncertainty => ca_p99,
      nu_x_out => ca_nu_x,
      nu_y_out => ca_nu_y,
      nu_z_out => ca_nu_z,
      s11_out  => ca_s11,
      s22_out  => ca_s22,
      s33_out  => ca_s33,
      done     => ca_done_sig
    );

  u_singer_ukf : singer_ukf_supreme_imm
    port map (
      clk        => clk,
      reset      => reset,
      start      => si_start,
      z_x_meas   => z_x_meas,
      z_y_meas   => z_y_meas,
      z_z_meas   => z_z_meas,
      inject_en  => si_inject_en,
      inject_state_only => si_inject_state_only,
      inj_x_pos  => si_inj_xp,
      inj_x_vel  => si_inj_xv,
      inj_x_acc  => si_inj_xa,
      inj_y_pos  => si_inj_yp,
      inj_y_vel  => si_inj_yv,
      inj_y_acc  => si_inj_ya,
      inj_z_pos  => si_inj_zp,
      inj_z_vel  => si_inj_zv,
      inj_z_acc  => si_inj_za,
      inj_p11    => si_inj_p11,
      inj_p22    => si_inj_p22,
      inj_p33    => si_inj_p33,
      inj_p44    => si_inj_p44,
      inj_p55    => si_inj_p55,
      inj_p66    => si_inj_p66,
      inj_p77    => si_inj_p77,
      inj_p88    => si_inj_p88,
      inj_p99    => si_inj_p99,
      x_pos_current => si_xp,
      x_vel_current => si_xv,
      x_acc_current => si_xa,
      y_pos_current => si_yp,
      y_vel_current => si_yv,
      y_acc_current => si_ya,
      z_pos_current => si_zp,
      z_vel_current => si_zv,
      z_acc_current => si_za,
      x_pos_uncertainty => si_p11,
      x_vel_uncertainty => si_p22,
      x_acc_uncertainty => si_p33,
      y_pos_uncertainty => si_p44,
      y_vel_uncertainty => si_p55,
      y_acc_uncertainty => si_p66,
      z_pos_uncertainty => si_p77,
      z_vel_uncertainty => si_p88,
      z_acc_uncertainty => si_p99,
      nu_x_out => si_nu_x,
      nu_y_out => si_nu_y,
      nu_z_out => si_nu_z,
      s11_out  => si_s11,
      s22_out  => si_s22,
      s33_out  => si_s33,
      done     => si_done_sig
    );

  u_bike_ukf : bicycle_ukf_supreme_imm
    port map (
      clk        => clk,
      reset      => reset,
      start      => bi_start,
      v_init     => ZERO48,
      theta_init => ZERO48,
      z_x_meas   => z_x_meas,
      z_y_meas   => z_y_meas,
      z_z_meas   => z_z_meas,
      inject_en  => bi_inject_en,
      inject_state_only => bi_inject_state_only,
      inj_px     => bi_inj_px,
      inj_py     => bi_inj_py,
      inj_v      => bi_inj_v,
      inj_theta  => bi_inj_theta,
      inj_delta  => bi_inj_delta,
      inj_a      => bi_inj_a,
      inj_z      => bi_inj_z,
      inj_p11    => bi_inj_p11,
      inj_p22    => bi_inj_p22,
      inj_p33    => bi_inj_p33,
      inj_p44    => bi_inj_p44,
      inj_p55    => bi_inj_p55,
      inj_p66    => bi_inj_p66,
      inj_p77    => bi_inj_p77,
      px_current    => bi_px,
      py_current    => bi_py,
      v_current     => bi_v,
      theta_current => bi_theta,
      delta_current => bi_delta,
      a_current     => bi_a,
      z_current     => bi_z,
      p11_diag => bi_p11,
      p22_diag => bi_p22,
      p33_diag => bi_p33,
      p44_diag => bi_p44,
      p55_diag => bi_p55,
      p66_diag => bi_p66,
      p77_diag => bi_p77,
      nu_x_out => bi_nu_x,
      nu_y_out => bi_nu_y,
      nu_z_out => bi_nu_z,
      s11_out  => bi_s11,
      s22_out  => bi_s22,
      s33_out  => bi_s33,
      done     => bi_done_sig
    );

  u_map_ca_to_7d : state_mapper_9d_to_7d
    port map (
      clk       => clk,
      start     => map_ca_start,
      x_pos_in  => ca_xp,
      x_vel_in  => ca_xv,
      x_acc_in  => ca_xa,
      y_pos_in  => ca_yp,
      y_vel_in  => ca_yv,
      y_acc_in  => ca_ya,
      z_pos_in  => ca_zp,
      z_vel_in  => ca_zv,
      z_acc_in  => ca_za,
      px_out    => map_ca_7d_px,
      py_out    => map_ca_7d_py,
      v_out     => map_ca_7d_v,
      theta_out => map_ca_7d_theta,
      delta_out => map_ca_7d_delta,
      a_out     => map_ca_7d_a,
      z_out     => map_ca_7d_z,
      done      => map_ca_7d_done
    );

  u_map_si_to_7d : state_mapper_9d_to_7d
    port map (
      clk       => clk,
      start     => map_si_start,
      x_pos_in  => si_xp,
      x_vel_in  => si_xv,
      x_acc_in  => si_xa,
      y_pos_in  => si_yp,
      y_vel_in  => si_yv,
      y_acc_in  => si_ya,
      z_pos_in  => si_zp,
      z_vel_in  => si_zv,
      z_acc_in  => si_za,
      px_out    => map_si_7d_px,
      py_out    => map_si_7d_py,
      v_out     => map_si_7d_v,
      theta_out => map_si_7d_theta,
      delta_out => map_si_7d_delta,
      a_out     => map_si_7d_a,
      z_out     => map_si_7d_z,
      done      => map_si_7d_done
    );

  u_map_bi_to_9d : state_mapper_7d_to_9d
    port map (
      clk       => clk,
      start     => map_bi_start,
      px_in     => bi_px,
      py_in     => bi_py,
      v_in      => bi_v,
      theta_in  => bi_theta,
      delta_in  => bi_delta,
      a_in      => bi_a,
      z_in      => bi_z,
      x_pos_out => map_bi_9d_xp,
      x_vel_out => map_bi_9d_xv,
      x_acc_out => map_bi_9d_xa,
      y_pos_out => map_bi_9d_yp,
      y_vel_out => map_bi_9d_yv,
      y_acc_out => map_bi_9d_ya,
      z_pos_out => map_bi_9d_zp,
      z_vel_out => map_bi_9d_zv,
      z_acc_out => map_bi_9d_za,
      done      => map_bi_9d_done
    );

  u_state_mixer : imm_state_mixer
    port map (
      clk          => clk,
      start        => mixer_start,
      prob_ca      => prob_ca,
      prob_singer  => prob_singer,
      prob_bicycle => prob_bike,

      ca_s1 => ca_xp, ca_s2 => ca_xv, ca_s3 => ca_xa,
      ca_s4 => ca_yp, ca_s5 => ca_yv, ca_s6 => ca_ya,
      ca_s7 => ca_zp, ca_s8 => ca_zv, ca_s9 => ca_za,

      si_s1 => si_xp, si_s2 => si_xv, si_s3 => si_xa,
      si_s4 => si_yp, si_s5 => si_yv, si_s6 => si_ya,
      si_s7 => si_zp, si_s8 => si_zv, si_s9 => si_za,

      bi_s1 => map_bi_9d_xp, bi_s2 => map_bi_9d_xv, bi_s3 => map_bi_9d_xa,
      bi_s4 => map_bi_9d_yp, bi_s5 => map_bi_9d_yv, bi_s6 => map_bi_9d_ya,
      bi_s7 => map_bi_9d_zp, bi_s8 => map_bi_9d_zv, bi_s9 => map_bi_9d_za,

      ca_b1 => map_ca_7d_px, ca_b2 => map_ca_7d_py, ca_b3 => map_ca_7d_v,
      ca_b4 => map_ca_7d_theta, ca_b5 => map_ca_7d_delta,
      ca_b6 => map_ca_7d_a, ca_b7 => map_ca_7d_z,

      si_b1 => map_si_7d_px, si_b2 => map_si_7d_py, si_b3 => map_si_7d_v,
      si_b4 => map_si_7d_theta, si_b5 => map_si_7d_delta,
      si_b6 => map_si_7d_a, si_b7 => map_si_7d_z,

      bi_b1 => bi_px, bi_b2 => bi_py, bi_b3 => bi_v,
      bi_b4 => bi_theta, bi_b5 => bi_delta,
      bi_b6 => bi_a, bi_b7 => bi_z,

      mix_ca_s1 => mix_ca_s1, mix_ca_s2 => mix_ca_s2, mix_ca_s3 => mix_ca_s3,
      mix_ca_s4 => mix_ca_s4, mix_ca_s5 => mix_ca_s5, mix_ca_s6 => mix_ca_s6,
      mix_ca_s7 => mix_ca_s7, mix_ca_s8 => mix_ca_s8, mix_ca_s9 => mix_ca_s9,

      mix_si_s1 => mix_si_s1, mix_si_s2 => mix_si_s2, mix_si_s3 => mix_si_s3,
      mix_si_s4 => mix_si_s4, mix_si_s5 => mix_si_s5, mix_si_s6 => mix_si_s6,
      mix_si_s7 => mix_si_s7, mix_si_s8 => mix_si_s8, mix_si_s9 => mix_si_s9,

      mix_bi_b1 => mix_bi_b1, mix_bi_b2 => mix_bi_b2, mix_bi_b3 => mix_bi_b3,
      mix_bi_b4 => mix_bi_b4, mix_bi_b5 => mix_bi_b5,
      mix_bi_b6 => mix_bi_b6, mix_bi_b7 => mix_bi_b7,

      c_ca_out      => c_ca_mix,
      c_singer_out  => c_singer_mix,
      c_bicycle_out => c_bicycle_mix,
      mu_ca_ca_out => mu_ca_ca_sig, mu_si_ca_out => mu_si_ca_sig, mu_bi_ca_out => mu_bi_ca_sig,
      mu_ca_si_out => mu_ca_si_sig, mu_si_si_out => mu_si_si_sig, mu_bi_si_out => mu_bi_si_sig,
      mu_ca_bi_out => mu_ca_bi_sig, mu_si_bi_out => mu_si_bi_sig, mu_bi_bi_out => mu_bi_bi_sig,
      done          => mixer_done
    );

  u_cov_mixer : imm_covariance_mixer
    port map (
      clk   => clk,
      start => cov_mixer_start,
      mu_ca_ca => mu_ca_ca_sig, mu_si_ca => mu_si_ca_sig, mu_bi_ca => mu_bi_ca_sig,
      mu_ca_si => mu_ca_si_sig, mu_si_si => mu_si_si_sig, mu_bi_si => mu_bi_si_sig,
      mu_ca_bi => mu_ca_bi_sig, mu_si_bi => mu_si_bi_sig, mu_bi_bi => mu_bi_bi_sig,
      ca_p1 => ca_p11, ca_p2 => ca_p22, ca_p3 => ca_p33,
      ca_p4 => ca_p44, ca_p5 => ca_p55, ca_p6 => ca_p66,
      ca_p7 => ca_p77, ca_p8 => ca_p88, ca_p9 => ca_p99,
      si_p1 => si_p11, si_p2 => si_p22, si_p3 => si_p33,
      si_p4 => si_p44, si_p5 => si_p55, si_p6 => si_p66,
      si_p7 => si_p77, si_p8 => si_p88, si_p9 => si_p99,
      bi_p1 => bi_p11, bi_p2 => bi_p22, bi_p3 => bi_p33,
      bi_p4 => bi_p44, bi_p5 => bi_p55, bi_p6 => bi_p66,
      bi_p7 => bi_p77, bi_p8 => ZERO48, bi_p9 => ZERO48,
      ca_s1 => ca_xp, ca_s2 => ca_xv, ca_s3 => ca_xa,
      ca_s4 => ca_yp, ca_s5 => ca_yv, ca_s6 => ca_ya,
      ca_s7 => ca_zp, ca_s8 => ca_zv, ca_s9 => ca_za,
      si_s1 => si_xp, si_s2 => si_xv, si_s3 => si_xa,
      si_s4 => si_yp, si_s5 => si_yv, si_s6 => si_ya,
      si_s7 => si_zp, si_s8 => si_zv, si_s9 => si_za,
      bi_s1 => map_bi_9d_xp, bi_s2 => map_bi_9d_xv, bi_s3 => map_bi_9d_xa,
      bi_s4 => map_bi_9d_yp, bi_s5 => map_bi_9d_yv, bi_s6 => map_bi_9d_ya,
      bi_s7 => map_bi_9d_zp, bi_s8 => map_bi_9d_zv, bi_s9 => map_bi_9d_za,
      mix_ca_s1 => mix_ca_s1, mix_ca_s2 => mix_ca_s2, mix_ca_s3 => mix_ca_s3,
      mix_ca_s4 => mix_ca_s4, mix_ca_s5 => mix_ca_s5, mix_ca_s6 => mix_ca_s6,
      mix_ca_s7 => mix_ca_s7, mix_ca_s8 => mix_ca_s8, mix_ca_s9 => mix_ca_s9,
      mix_si_s1 => mix_si_s1, mix_si_s2 => mix_si_s2, mix_si_s3 => mix_si_s3,
      mix_si_s4 => mix_si_s4, mix_si_s5 => mix_si_s5, mix_si_s6 => mix_si_s6,
      mix_si_s7 => mix_si_s7, mix_si_s8 => mix_si_s8, mix_si_s9 => mix_si_s9,
      mix_ca_p1 => mix_ca_p1, mix_ca_p2 => mix_ca_p2, mix_ca_p3 => mix_ca_p3,
      mix_ca_p4 => mix_ca_p4, mix_ca_p5 => mix_ca_p5, mix_ca_p6 => mix_ca_p6,
      mix_ca_p7 => mix_ca_p7, mix_ca_p8 => mix_ca_p8, mix_ca_p9 => mix_ca_p9,
      mix_si_p1 => mix_si_p1, mix_si_p2 => mix_si_p2, mix_si_p3 => mix_si_p3,
      mix_si_p4 => mix_si_p4, mix_si_p5 => mix_si_p5, mix_si_p6 => mix_si_p6,
      mix_si_p7 => mix_si_p7, mix_si_p8 => mix_si_p8, mix_si_p9 => mix_si_p9,
      mix_bi_p1 => mix_bi_p1_sig, mix_bi_p2 => mix_bi_p2_sig, mix_bi_p3 => mix_bi_p3_sig,
      mix_bi_p4 => mix_bi_p4_sig, mix_bi_p5 => mix_bi_p5_sig, mix_bi_p6 => mix_bi_p6_sig,
      mix_bi_p7 => mix_bi_p7_sig,
      done => cov_mixer_done
    );

  u_likelihood : imm_likelihood
    port map (
      clk    => clk,
      start  => likelihood_start,

      nu1_x  => ca_nu_x,
      nu1_y  => ca_nu_y,
      nu1_z  => ca_nu_z,
      s1_11  => ca_s11,
      s1_22  => ca_s22,
      s1_33  => ca_s33,

      nu2_x  => si_nu_x,
      nu2_y  => si_nu_y,
      nu2_z  => si_nu_z,
      s2_11  => si_s11,
      s2_22  => si_s22,
      s2_33  => si_s33,

      nu3_x  => bi_nu_x,
      nu3_y  => bi_nu_y,
      nu3_z  => bi_nu_z,
      s3_11  => bi_s11,
      s3_22  => bi_s22,
      s3_33  => bi_s33,

      L1_out => L_ca,
      L2_out => L_singer,
      L3_out => L_bike,
      done   => likelihood_done
    );

  u_prob_update : imm_prob_update
    port map (
      clk             => clk,
      start           => prob_update_start,
      L_ca            => L_ca,
      L_singer        => L_singer,
      L_bicycle       => L_bike,
      c_ca            => c_ca_mix,
      c_singer        => c_singer_mix,
      c_bicycle       => c_bicycle_mix,
      prob_ca_out     => prob_ca_new,
      prob_singer_out => prob_singer_new,
      prob_bicycle_out => prob_bike_new,
      done            => prob_update_done
    );

  u_fusion : imm_output_fusion
    port map (
      clk          => clk,
      start        => fusion_start,
      prob_ca      => prob_ca,
      prob_singer  => prob_singer,
      prob_bicycle => prob_bike,
      ca_px        => ca_xp,
      ca_py        => ca_yp,
      ca_pz        => ca_zp,
      singer_px    => si_xp,
      singer_py    => si_yp,
      singer_pz    => si_zp,
      bike_px      => bi_px,
      bike_py      => bi_py,
      bike_pz      => bi_z,
      px_out       => fused_px,
      py_out       => fused_py,
      pz_out       => fused_pz,
      done         => fusion_done
    );

  fsm_proc : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state       <= IDLE;
        first_cycle <= '1';
        prob_ca     <= PROB_INIT_CA;
        prob_singer <= PROB_INIT_SINGER;
        prob_bike   <= PROB_INIT_BIKE;
        done        <= '0';

        ca_start   <= '0'; si_start   <= '0'; bi_start   <= '0';
        ca_inject_en <= '0'; si_inject_en <= '0'; bi_inject_en <= '0';
        map_ca_start <= '0'; map_si_start <= '0'; map_bi_start <= '0';
        mixer_start      <= '0';
        cov_mixer_start  <= '0';
        likelihood_start <= '0';
        prob_update_start <= '0';
        fusion_start     <= '0';

      else

        ca_start   <= '0'; si_start   <= '0'; bi_start   <= '0';
        ca_inject_en <= '0'; si_inject_en <= '0'; bi_inject_en <= '0';
        ca_inject_state_only <= '0'; si_inject_state_only <= '0'; bi_inject_state_only <= '0';
        map_ca_start <= '0'; map_si_start <= '0'; map_bi_start <= '0';
        mixer_start      <= '0';
        cov_mixer_start  <= '0';
        likelihood_start <= '0';
        prob_update_start <= '0';
        fusion_start     <= '0';
        done             <= '0';

        case state is

          when IDLE =>
            if start = '1' then
              if first_cycle = '1' then
                report "IMM: IDLE->INIT_FIRST (first cycle)";
                state <= INIT_FIRST;
              else
                state <= MAP_STATES;
              end if;
            end if;

          when INIT_FIRST =>
            report "IMM: INIT_FIRST -> WAIT_FILTERS";
            ca_start <= '1';
            si_start <= '1';
            bi_start <= '1';

            ca_inject_en <= '0';
            si_inject_en <= '0';
            bi_inject_en <= '0';
            first_cycle <= '0';
            skip_prob   <= '1';

            ca_done_latch <= '0';
            si_done_latch <= '0';
            bi_done_latch <= '0';
            state <= WAIT_FILTERS;

          when MAP_STATES =>
            report "IMM: MAP_STATES -> WAIT_MAP";
            map_ca_start <= '1';
            map_si_start <= '1';
            map_bi_start <= '1';

            map_ca_done_latch <= '0';
            map_si_done_latch <= '0';
            map_bi_done_latch <= '0';
            state <= WAIT_MAP;

          when WAIT_MAP =>
            if map_ca_7d_done = '1' then map_ca_done_latch <= '1'; end if;
            if map_si_7d_done = '1' then map_si_done_latch <= '1'; end if;
            if map_bi_9d_done = '1' then map_bi_done_latch <= '1'; end if;
            if (map_ca_7d_done = '1' or map_ca_done_latch = '1') and
               (map_si_7d_done = '1' or map_si_done_latch = '1') and
               (map_bi_9d_done = '1' or map_bi_done_latch = '1') then
              report "IMM: WAIT_MAP -> START_MIX (all mappers done)";
              state <= START_MIX;
            end if;

          when START_MIX =>
            mixer_start <= '1';
            state <= WAIT_MIX;

          when WAIT_MIX =>
            if mixer_done = '1' then
              state <= START_COV_MIX;
            end if;

          when START_COV_MIX =>
            cov_mixer_start <= '1';
            state <= WAIT_COV_MIX;

          when WAIT_COV_MIX =>
            if cov_mixer_done = '1' then
              state <= INJECT_MIXED;
            end if;

          when INJECT_MIXED =>

            ca_inj_xp <= mix_ca_s1;
            ca_inj_xv <= mix_ca_s2;
            ca_inj_xa <= mix_ca_s3;
            ca_inj_yp <= mix_ca_s4;
            ca_inj_yv <= mix_ca_s5;
            ca_inj_ya <= mix_ca_s6;
            ca_inj_zp <= mix_ca_s7;
            ca_inj_zv <= mix_ca_s8;
            ca_inj_za <= mix_ca_s9;

            si_inj_xp <= mix_si_s1;
            si_inj_xv <= mix_si_s2;
            si_inj_xa <= mix_si_s3;
            si_inj_yp <= mix_si_s4;
            si_inj_yv <= mix_si_s5;
            si_inj_ya <= mix_si_s6;
            si_inj_zp <= mix_si_s7;
            si_inj_zv <= mix_si_s8;
            si_inj_za <= mix_si_s9;

            bi_inj_px    <= mix_bi_b1;
            bi_inj_py    <= mix_bi_b2;
            bi_inj_v     <= mix_bi_b3;
            bi_inj_theta <= mix_bi_b4;
            bi_inj_delta <= mix_bi_b5;
            bi_inj_a     <= mix_bi_b6;
            bi_inj_z     <= mix_bi_b7;

            report "IMM INJECT_MIXED: mix_ca_p1=" & integer'image(to_integer(mix_ca_p1)) &
              " mix_ca_p2=" & integer'image(to_integer(mix_ca_p2)) &
              " mix_ca_p4=" & integer'image(to_integer(mix_ca_p4)) &
              " ca_p11=" & integer'image(to_integer(ca_p11)) &
              " si_p11=" & integer'image(to_integer(si_p11)) &
              " bi_p11=" & integer'image(to_integer(bi_p11));

            ca_inj_p11 <= mix_ca_p1; ca_inj_p22 <= mix_ca_p2; ca_inj_p33 <= mix_ca_p3;
            ca_inj_p44 <= mix_ca_p4; ca_inj_p55 <= mix_ca_p5; ca_inj_p66 <= mix_ca_p6;
            ca_inj_p77 <= mix_ca_p7; ca_inj_p88 <= mix_ca_p8; ca_inj_p99 <= mix_ca_p9;

            si_inj_p11 <= mix_si_p1; si_inj_p22 <= mix_si_p2; si_inj_p33 <= mix_si_p3;
            si_inj_p44 <= mix_si_p4; si_inj_p55 <= mix_si_p5; si_inj_p66 <= mix_si_p6;
            si_inj_p77 <= mix_si_p7; si_inj_p88 <= mix_si_p8; si_inj_p99 <= mix_si_p9;

            bi_inj_p11 <= mix_bi_p1_sig; bi_inj_p22 <= mix_bi_p2_sig;
            bi_inj_p33 <= mix_bi_p3_sig; bi_inj_p44 <= mix_bi_p4_sig;
            bi_inj_p55 <= mix_bi_p5_sig; bi_inj_p66 <= mix_bi_p6_sig;
            bi_inj_p77 <= mix_bi_p7_sig;

            ca_inject_state_only <= '0';
            si_inject_state_only <= '0';
            bi_inject_state_only <= '0';

            ca_inject_en <= '1';
            si_inject_en <= '1';
            bi_inject_en <= '1';
            ca_start <= '1';
            si_start <= '1';
            bi_start <= '1';

            ca_done_latch <= '0';
            si_done_latch <= '0';
            bi_done_latch <= '0';
            state <= WAIT_FILTERS;

          when WAIT_FILTERS =>

            if ca_done_sig = '1' then ca_done_latch <= '1'; end if;
            if si_done_sig = '1' then si_done_latch <= '1'; end if;
            if bi_done_sig = '1' then bi_done_latch <= '1'; end if;
            if (ca_done_sig = '1' or ca_done_latch = '1') and
               (si_done_sig = '1' or si_done_latch = '1') and
               (bi_done_sig = '1' or bi_done_latch = '1') then
              if skip_prob = '1' then
                report "IMM: All filters done (first cycle) -> START_FUSION";
                skip_prob <= '0';
                state <= START_FUSION;
              else
                report "IMM: All filters done -> START_LIKELIHOOD";
                state <= START_LIKELIHOOD;
              end if;
            end if;

          when START_LIKELIHOOD =>
            report "IMM LIKELIHOOD inputs:" &
              " ca_nu_x=" & integer'image(to_integer(ca_nu_x)) &
              " ca_nu_y=" & integer'image(to_integer(ca_nu_y)) &
              " ca_s11=" & integer'image(to_integer(ca_s11)) &
              " ca_s22=" & integer'image(to_integer(ca_s22)) &
              " bi_nu_x=" & integer'image(to_integer(bi_nu_x)) &
              " bi_nu_y=" & integer'image(to_integer(bi_nu_y)) &
              " bi_s11=" & integer'image(to_integer(bi_s11)) &
              " bi_s22=" & integer'image(to_integer(bi_s22));
            likelihood_start <= '1';
            state <= WAIT_LIKELIHOOD;

          when WAIT_LIKELIHOOD =>
            if likelihood_done = '1' then
              report "IMM LIKELIHOOD outputs:" &
                " L_ca=" & integer'image(to_integer(L_ca)) &
                " L_singer=" & integer'image(to_integer(L_singer)) &
                " L_bike=" & integer'image(to_integer(L_bike));
              state <= START_PROB_UPDATE;
            end if;

          when START_PROB_UPDATE =>
            prob_update_start <= '1';
            state <= WAIT_PROB_UPDATE;

          when WAIT_PROB_UPDATE =>
            if prob_update_done = '1' then
              report "IMM PROB_UPDATE outputs:" &
                " prob_ca_new=" & integer'image(to_integer(prob_ca_new)) &
                " prob_singer_new=" & integer'image(to_integer(prob_singer_new)) &
                " prob_bike_new=" & integer'image(to_integer(prob_bike_new));
              prob_ca     <= prob_ca_new;
              prob_singer <= prob_singer_new;
              prob_bike   <= prob_bike_new;
              state <= START_FUSION;
            end if;

          when START_FUSION =>
            report "IMM FUSION inputs:" &
              " prob_ca=" & integer'image(to_integer(prob_ca)) &
              " prob_si=" & integer'image(to_integer(prob_singer)) &
              " prob_bi=" & integer'image(to_integer(prob_bike));
            fusion_start <= '1';
            state <= WAIT_FUSION;

          when WAIT_FUSION =>
            if fusion_done = '1' then

              null;
              state <= DONE_STATE;
            end if;

          when DONE_STATE =>
            report "IMM: DONE_STATE";
            done <= '1';
            state <= IDLE;

        end case;
      end if;
    end if;
  end process;

  px_out          <= fused_px;
  py_out          <= fused_py;
  pz_out          <= fused_pz;
  prob_ca_out     <= prob_ca;
  prob_singer_out <= prob_singer;
  prob_bike_out   <= prob_bike;

end architecture;
