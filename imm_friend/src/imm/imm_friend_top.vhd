library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity imm_friend_top is
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

    prob_ctra_out   : out signed(47 downto 0);
    prob_singer_out : out signed(47 downto 0);
    prob_bike_out   : out signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of imm_friend_top is

  constant Q : integer := 24;
  constant ONE_Q24 : signed(47 downto 0) := to_signed(2**Q, 48);
  constant ZERO48  : signed(47 downto 0) := (others => '0');

  constant P_SMALL : signed(47 downto 0) := to_signed(16777216, 48);

  constant PROB_INIT_CTRA   : signed(47 downto 0) := to_signed(6710886, 48);
  constant PROB_INIT_SINGER : signed(47 downto 0) := to_signed(5033165, 48);
  constant PROB_INIT_BIKE   : signed(47 downto 0) := to_signed(5033165, 48);

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

  component ctra_ukf_supreme_imm is
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
      inj_px, inj_py, inj_v, inj_theta, inj_omega, inj_a, inj_z : in signed(47 downto 0);
      inj_p11, inj_p22, inj_p33, inj_p44, inj_p55, inj_p66, inj_p77 : in signed(47 downto 0);
      px_current    : out signed(47 downto 0);
      py_current    : out signed(47 downto 0);
      v_current     : out signed(47 downto 0);
      theta_current : out signed(47 downto 0);
      omega_current : out signed(47 downto 0);
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

  component state_mapper_9d_to_7d_ctra is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      x_pos_in, x_vel_in, x_acc_in : in signed(47 downto 0);
      y_pos_in, y_vel_in, y_acc_in : in signed(47 downto 0);
      z_pos_in, z_vel_in, z_acc_in : in signed(47 downto 0);
      px_out, py_out, v_out, theta_out, omega_out, a_out, z_out : out signed(47 downto 0);
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

  component imm_friend_state_mixer is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      prob_ctra, prob_singer, prob_bicycle : in signed(47 downto 0);

      ct_s1, ct_s2, ct_s3, ct_s4, ct_s5, ct_s6, ct_s7, ct_s8, ct_s9 : in signed(47 downto 0);
      si_s1, si_s2, si_s3, si_s4, si_s5, si_s6, si_s7, si_s8, si_s9 : in signed(47 downto 0);
      bi_s1, bi_s2, bi_s3, bi_s4, bi_s5, bi_s6, bi_s7, bi_s8, bi_s9 : in signed(47 downto 0);

      si_c1, si_c2, si_c3, si_c4, si_c5, si_c6, si_c7 : in signed(47 downto 0);
      ct_c1, ct_c2, ct_c3, ct_c4, ct_c5, ct_c6, ct_c7 : in signed(47 downto 0);
      bi_c1, bi_c2, bi_c3, bi_c4, bi_c5, bi_c6, bi_c7 : in signed(47 downto 0);

      si_b1, si_b2, si_b3, si_b4, si_b5, si_b6, si_b7 : in signed(47 downto 0);
      ct_b1, ct_b2, ct_b3, ct_b4, ct_b5, ct_b6, ct_b7 : in signed(47 downto 0);
      bi_b1, bi_b2, bi_b3, bi_b4, bi_b5, bi_b6, bi_b7 : in signed(47 downto 0);

      mix_si_s1, mix_si_s2, mix_si_s3, mix_si_s4, mix_si_s5, mix_si_s6, mix_si_s7, mix_si_s8, mix_si_s9 : out signed(47 downto 0);
      mix_ct_c1, mix_ct_c2, mix_ct_c3, mix_ct_c4, mix_ct_c5, mix_ct_c6, mix_ct_c7 : out signed(47 downto 0);
      mix_bi_b1, mix_bi_b2, mix_bi_b3, mix_bi_b4, mix_bi_b5, mix_bi_b6, mix_bi_b7 : out signed(47 downto 0);

      c_ctra_out, c_singer_out, c_bicycle_out : out signed(47 downto 0);

      mu_ct_ct_out, mu_si_ct_out, mu_bi_ct_out : out signed(47 downto 0);
      mu_ct_si_out, mu_si_si_out, mu_bi_si_out : out signed(47 downto 0);
      mu_ct_bi_out, mu_si_bi_out, mu_bi_bi_out : out signed(47 downto 0);
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

  component imm_friend_covariance_mixer is
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      mu_ct_ct, mu_si_ct, mu_bi_ct : in signed(47 downto 0);
      mu_ct_si, mu_si_si, mu_bi_si : in signed(47 downto 0);
      mu_ct_bi, mu_si_bi, mu_bi_bi : in signed(47 downto 0);
      ct_p1, ct_p2, ct_p3, ct_p4, ct_p5, ct_p6, ct_p7, ct_p8, ct_p9 : in signed(47 downto 0);
      si_p1, si_p2, si_p3, si_p4, si_p5, si_p6, si_p7, si_p8, si_p9 : in signed(47 downto 0);
      bi_p1, bi_p2, bi_p3, bi_p4, bi_p5, bi_p6, bi_p7, bi_p8, bi_p9 : in signed(47 downto 0);
      ct_s1, ct_s2, ct_s3, ct_s4, ct_s5, ct_s6, ct_s7, ct_s8, ct_s9 : in signed(47 downto 0);
      si_s1, si_s2, si_s3, si_s4, si_s5, si_s6, si_s7, si_s8, si_s9 : in signed(47 downto 0);
      bi_s1, bi_s2, bi_s3, bi_s4, bi_s5, bi_s6, bi_s7, bi_s8, bi_s9 : in signed(47 downto 0);
      mix_si_s1, mix_si_s2, mix_si_s3, mix_si_s4, mix_si_s5, mix_si_s6, mix_si_s7, mix_si_s8, mix_si_s9 : in signed(47 downto 0);
      ctra_native_p1, ctra_native_p2, ctra_native_p3, ctra_native_p4 : in signed(47 downto 0);
      ctra_native_p5, ctra_native_p6, ctra_native_p7 : in signed(47 downto 0);
      bike_native_p1, bike_native_p2, bike_native_p3, bike_native_p4 : in signed(47 downto 0);
      bike_native_p5, bike_native_p6, bike_native_p7 : in signed(47 downto 0);
      mix_si_p1, mix_si_p2, mix_si_p3, mix_si_p4, mix_si_p5, mix_si_p6, mix_si_p7, mix_si_p8, mix_si_p9 : out signed(47 downto 0);
      mix_ct_p1, mix_ct_p2, mix_ct_p3, mix_ct_p4, mix_ct_p5, mix_ct_p6, mix_ct_p7 : out signed(47 downto 0);
      mix_bi_p1, mix_bi_p2, mix_bi_p3, mix_bi_p4, mix_bi_p5, mix_bi_p6, mix_bi_p7 : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  signal first_cycle  : std_logic := '1';
  signal skip_prob    : std_logic := '0';

  signal prob_ctra   : signed(47 downto 0) := PROB_INIT_CTRA;
  signal prob_singer : signed(47 downto 0) := PROB_INIT_SINGER;
  signal prob_bike   : signed(47 downto 0) := PROB_INIT_BIKE;

  signal ct_px, ct_py, ct_v, ct_theta, ct_omega, ct_a, ct_z : signed(47 downto 0) := (others => '0');

  signal ct_p11, ct_p22, ct_p33, ct_p44, ct_p55, ct_p66, ct_p77 : signed(47 downto 0) := (others => '0');

  signal ct_nu_x, ct_nu_y, ct_nu_z : signed(47 downto 0) := (others => '0');
  signal ct_s11, ct_s22, ct_s33   : signed(47 downto 0) := (others => '0');

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

  signal map_si_bike_px, map_si_bike_py, map_si_bike_v     : signed(47 downto 0) := (others => '0');
  signal map_si_bike_theta, map_si_bike_delta               : signed(47 downto 0) := (others => '0');
  signal map_si_bike_a, map_si_bike_z                       : signed(47 downto 0) := (others => '0');

  signal map_si_ctra_px, map_si_ctra_py, map_si_ctra_v     : signed(47 downto 0) := (others => '0');
  signal map_si_ctra_theta, map_si_ctra_omega               : signed(47 downto 0) := (others => '0');
  signal map_si_ctra_a, map_si_ctra_z                       : signed(47 downto 0) := (others => '0');

  signal map_bi_9d_xp, map_bi_9d_xv, map_bi_9d_xa : signed(47 downto 0) := (others => '0');
  signal map_bi_9d_yp, map_bi_9d_yv, map_bi_9d_ya : signed(47 downto 0) := (others => '0');
  signal map_bi_9d_zp, map_bi_9d_zv, map_bi_9d_za : signed(47 downto 0) := (others => '0');

  signal map_ct_9d_xp, map_ct_9d_xv, map_ct_9d_xa : signed(47 downto 0) := (others => '0');
  signal map_ct_9d_yp, map_ct_9d_yv, map_ct_9d_ya : signed(47 downto 0) := (others => '0');
  signal map_ct_9d_zp, map_ct_9d_zv, map_ct_9d_za : signed(47 downto 0) := (others => '0');

  signal map_si_bike_done : std_logic := '0';
  signal map_si_ctra_done : std_logic := '0';
  signal map_bi_9d_done   : std_logic := '0';
  signal map_ct_9d_done   : std_logic := '0';

  signal map_si_bike_done_latch : std_logic := '0';
  signal map_si_ctra_done_latch : std_logic := '0';
  signal map_bi_done_latch      : std_logic := '0';
  signal map_ct_done_latch      : std_logic := '0';

  signal mix_si_s1, mix_si_s2, mix_si_s3 : signed(47 downto 0) := (others => '0');
  signal mix_si_s4, mix_si_s5, mix_si_s6 : signed(47 downto 0) := (others => '0');
  signal mix_si_s7, mix_si_s8, mix_si_s9 : signed(47 downto 0) := (others => '0');

  signal mix_ct_c1, mix_ct_c2, mix_ct_c3 : signed(47 downto 0) := (others => '0');
  signal mix_ct_c4, mix_ct_c5, mix_ct_c6 : signed(47 downto 0) := (others => '0');
  signal mix_ct_c7                        : signed(47 downto 0) := (others => '0');

  signal mix_bi_b1, mix_bi_b2, mix_bi_b3 : signed(47 downto 0) := (others => '0');
  signal mix_bi_b4, mix_bi_b5, mix_bi_b6 : signed(47 downto 0) := (others => '0');
  signal mix_bi_b7                        : signed(47 downto 0) := (others => '0');

  signal c_ctra_mix    : signed(47 downto 0) := PROB_INIT_CTRA;
  signal c_singer_mix  : signed(47 downto 0) := PROB_INIT_SINGER;
  signal c_bicycle_mix : signed(47 downto 0) := PROB_INIT_BIKE;
  signal mixer_done : std_logic := '0';

  signal mu_ct_ct_sig, mu_si_ct_sig, mu_bi_ct_sig : signed(47 downto 0) := (others => '0');
  signal mu_ct_si_sig, mu_si_si_sig, mu_bi_si_sig : signed(47 downto 0) := (others => '0');
  signal mu_ct_bi_sig, mu_si_bi_sig, mu_bi_bi_sig : signed(47 downto 0) := (others => '0');

  signal mix_si_p1, mix_si_p2, mix_si_p3, mix_si_p4, mix_si_p5 : signed(47 downto 0) := (others => '0');
  signal mix_si_p6, mix_si_p7, mix_si_p8, mix_si_p9            : signed(47 downto 0) := (others => '0');
  signal mix_ct_p1_sig, mix_ct_p2_sig, mix_ct_p3_sig, mix_ct_p4_sig : signed(47 downto 0) := (others => '0');
  signal mix_ct_p5_sig, mix_ct_p6_sig, mix_ct_p7_sig                : signed(47 downto 0) := (others => '0');
  signal mix_bi_p1_sig, mix_bi_p2_sig, mix_bi_p3_sig, mix_bi_p4_sig : signed(47 downto 0) := (others => '0');
  signal mix_bi_p5_sig, mix_bi_p6_sig, mix_bi_p7_sig                : signed(47 downto 0) := (others => '0');

  signal cov_mixer_start : std_logic := '0';
  signal cov_mixer_done  : std_logic := '0';

  signal L_ctra, L_singer, L_bike : signed(47 downto 0) := (others => '0');
  signal likelihood_done : std_logic := '0';

  signal prob_ctra_new, prob_singer_new, prob_bike_new : signed(47 downto 0) := (others => '0');
  signal prob_update_done : std_logic := '0';

  signal fused_px, fused_py, fused_pz : signed(47 downto 0) := (others => '0');
  signal fusion_done : std_logic := '0';

  signal ct_start, si_start, bi_start : std_logic := '0';
  signal ct_inject_en, si_inject_en, bi_inject_en : std_logic := '0';
  signal ct_done_sig, si_done_sig, bi_done_sig : std_logic := '0';

  signal ct_done_latch, si_done_latch, bi_done_latch : std_logic := '0';

  signal map_si_bike_start, map_si_ctra_start : std_logic := '0';
  signal map_bi_start, map_ct_start           : std_logic := '0';

  signal mixer_start : std_logic := '0';

  signal likelihood_start : std_logic := '0';

  signal prob_update_start : std_logic := '0';

  signal fusion_start : std_logic := '0';

  signal ct_inj_px, ct_inj_py, ct_inj_v     : signed(47 downto 0) := (others => '0');
  signal ct_inj_theta, ct_inj_omega          : signed(47 downto 0) := (others => '0');
  signal ct_inj_a, ct_inj_z                 : signed(47 downto 0) := (others => '0');
  signal si_inj_xp, si_inj_xv, si_inj_xa : signed(47 downto 0) := (others => '0');
  signal si_inj_yp, si_inj_yv, si_inj_ya : signed(47 downto 0) := (others => '0');
  signal si_inj_zp, si_inj_zv, si_inj_za : signed(47 downto 0) := (others => '0');
  signal bi_inj_px, bi_inj_py, bi_inj_v  : signed(47 downto 0) := (others => '0');
  signal bi_inj_theta, bi_inj_delta       : signed(47 downto 0) := (others => '0');
  signal bi_inj_a, bi_inj_z              : signed(47 downto 0) := (others => '0');

  signal ct_inj_p11, ct_inj_p22, ct_inj_p33 : signed(47 downto 0) := (others => '0');
  signal ct_inj_p44, ct_inj_p55, ct_inj_p66 : signed(47 downto 0) := (others => '0');
  signal ct_inj_p77                          : signed(47 downto 0) := (others => '0');
  signal si_inj_p11, si_inj_p22, si_inj_p33 : signed(47 downto 0) := (others => '0');
  signal si_inj_p44, si_inj_p55, si_inj_p66 : signed(47 downto 0) := (others => '0');
  signal si_inj_p77, si_inj_p88, si_inj_p99 : signed(47 downto 0) := (others => '0');
  signal bi_inj_p11, bi_inj_p22, bi_inj_p33 : signed(47 downto 0) := (others => '0');
  signal bi_inj_p44, bi_inj_p55, bi_inj_p66 : signed(47 downto 0) := (others => '0');
  signal bi_inj_p77                          : signed(47 downto 0) := (others => '0');

  signal ct_inject_state_only, si_inject_state_only, bi_inject_state_only : std_logic := '0';

begin

  u_ctra_ukf : ctra_ukf_supreme_imm
    port map (
      clk        => clk,
      reset      => reset,
      start      => ct_start,
      v_init     => ZERO48,
      theta_init => ZERO48,
      z_x_meas   => z_x_meas,
      z_y_meas   => z_y_meas,
      z_z_meas   => z_z_meas,
      inject_en  => ct_inject_en,
      inject_state_only => ct_inject_state_only,
      inj_px     => ct_inj_px,
      inj_py     => ct_inj_py,
      inj_v      => ct_inj_v,
      inj_theta  => ct_inj_theta,
      inj_omega  => ct_inj_omega,
      inj_a      => ct_inj_a,
      inj_z      => ct_inj_z,
      inj_p11    => ct_inj_p11,
      inj_p22    => ct_inj_p22,
      inj_p33    => ct_inj_p33,
      inj_p44    => ct_inj_p44,
      inj_p55    => ct_inj_p55,
      inj_p66    => ct_inj_p66,
      inj_p77    => ct_inj_p77,
      px_current    => ct_px,
      py_current    => ct_py,
      v_current     => ct_v,
      theta_current => ct_theta,
      omega_current => ct_omega,
      a_current     => ct_a,
      z_current     => ct_z,
      p11_diag => ct_p11,
      p22_diag => ct_p22,
      p33_diag => ct_p33,
      p44_diag => ct_p44,
      p55_diag => ct_p55,
      p66_diag => ct_p66,
      p77_diag => ct_p77,
      nu_x_out => ct_nu_x,
      nu_y_out => ct_nu_y,
      nu_z_out => ct_nu_z,
      s11_out  => ct_s11,
      s22_out  => ct_s22,
      s33_out  => ct_s33,
      done     => ct_done_sig
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

  u_map_si_to_bike : state_mapper_9d_to_7d
    port map (
      clk       => clk,
      start     => map_si_bike_start,
      x_pos_in  => si_xp,
      x_vel_in  => si_xv,
      x_acc_in  => si_xa,
      y_pos_in  => si_yp,
      y_vel_in  => si_yv,
      y_acc_in  => si_ya,
      z_pos_in  => si_zp,
      z_vel_in  => si_zv,
      z_acc_in  => si_za,
      px_out    => map_si_bike_px,
      py_out    => map_si_bike_py,
      v_out     => map_si_bike_v,
      theta_out => map_si_bike_theta,
      delta_out => map_si_bike_delta,
      a_out     => map_si_bike_a,
      z_out     => map_si_bike_z,
      done      => map_si_bike_done
    );

  u_map_si_to_ctra : state_mapper_9d_to_7d_ctra
    port map (
      clk       => clk,
      start     => map_si_ctra_start,
      x_pos_in  => si_xp,
      x_vel_in  => si_xv,
      x_acc_in  => si_xa,
      y_pos_in  => si_yp,
      y_vel_in  => si_yv,
      y_acc_in  => si_ya,
      z_pos_in  => si_zp,
      z_vel_in  => si_zv,
      z_acc_in  => si_za,
      px_out    => map_si_ctra_px,
      py_out    => map_si_ctra_py,
      v_out     => map_si_ctra_v,
      theta_out => map_si_ctra_theta,
      omega_out => map_si_ctra_omega,
      a_out     => map_si_ctra_a,
      z_out     => map_si_ctra_z,
      done      => map_si_ctra_done
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

  u_map_ct_to_9d : state_mapper_7d_to_9d
    port map (
      clk       => clk,
      start     => map_ct_start,
      px_in     => ct_px,
      py_in     => ct_py,
      v_in      => ct_v,
      theta_in  => ct_theta,
      delta_in  => ct_omega,
      a_in      => ct_a,
      z_in      => ct_z,
      x_pos_out => map_ct_9d_xp,
      x_vel_out => map_ct_9d_xv,
      x_acc_out => map_ct_9d_xa,
      y_pos_out => map_ct_9d_yp,
      y_vel_out => map_ct_9d_yv,
      y_acc_out => map_ct_9d_ya,
      z_pos_out => map_ct_9d_zp,
      z_vel_out => map_ct_9d_zv,
      z_acc_out => map_ct_9d_za,
      done      => map_ct_9d_done
    );

  u_state_mixer : imm_friend_state_mixer
    port map (
      clk          => clk,
      start        => mixer_start,
      prob_ctra    => prob_ctra,
      prob_singer  => prob_singer,
      prob_bicycle => prob_bike,

      ct_s1 => map_ct_9d_xp, ct_s2 => map_ct_9d_xv, ct_s3 => map_ct_9d_xa,
      ct_s4 => map_ct_9d_yp, ct_s5 => map_ct_9d_yv, ct_s6 => map_ct_9d_ya,
      ct_s7 => map_ct_9d_zp, ct_s8 => map_ct_9d_zv, ct_s9 => map_ct_9d_za,

      si_s1 => si_xp, si_s2 => si_xv, si_s3 => si_xa,
      si_s4 => si_yp, si_s5 => si_yv, si_s6 => si_ya,
      si_s7 => si_zp, si_s8 => si_zv, si_s9 => si_za,

      bi_s1 => map_bi_9d_xp, bi_s2 => map_bi_9d_xv, bi_s3 => map_bi_9d_xa,
      bi_s4 => map_bi_9d_yp, bi_s5 => map_bi_9d_yv, bi_s6 => map_bi_9d_ya,
      bi_s7 => map_bi_9d_zp, bi_s8 => map_bi_9d_zv, bi_s9 => map_bi_9d_za,

      si_c1 => map_si_ctra_px, si_c2 => map_si_ctra_py, si_c3 => map_si_ctra_v,
      si_c4 => map_si_ctra_theta, si_c5 => map_si_ctra_omega,
      si_c6 => map_si_ctra_a, si_c7 => map_si_ctra_z,

      ct_c1 => ct_px, ct_c2 => ct_py, ct_c3 => ct_v,
      ct_c4 => ct_theta, ct_c5 => ct_omega,
      ct_c6 => ct_a, ct_c7 => ct_z,

      bi_c1 => bi_px, bi_c2 => bi_py, bi_c3 => bi_v,
      bi_c4 => bi_theta, bi_c5 => ZERO48,
      bi_c6 => bi_a, bi_c7 => bi_z,

      si_b1 => map_si_bike_px, si_b2 => map_si_bike_py, si_b3 => map_si_bike_v,
      si_b4 => map_si_bike_theta, si_b5 => map_si_bike_delta,
      si_b6 => map_si_bike_a, si_b7 => map_si_bike_z,

      ct_b1 => ct_px, ct_b2 => ct_py, ct_b3 => ct_v,
      ct_b4 => ct_theta, ct_b5 => ZERO48,
      ct_b6 => ct_a, ct_b7 => ct_z,

      bi_b1 => bi_px, bi_b2 => bi_py, bi_b3 => bi_v,
      bi_b4 => bi_theta, bi_b5 => bi_delta,
      bi_b6 => bi_a, bi_b7 => bi_z,

      mix_si_s1 => mix_si_s1, mix_si_s2 => mix_si_s2, mix_si_s3 => mix_si_s3,
      mix_si_s4 => mix_si_s4, mix_si_s5 => mix_si_s5, mix_si_s6 => mix_si_s6,
      mix_si_s7 => mix_si_s7, mix_si_s8 => mix_si_s8, mix_si_s9 => mix_si_s9,

      mix_ct_c1 => mix_ct_c1, mix_ct_c2 => mix_ct_c2, mix_ct_c3 => mix_ct_c3,
      mix_ct_c4 => mix_ct_c4, mix_ct_c5 => mix_ct_c5,
      mix_ct_c6 => mix_ct_c6, mix_ct_c7 => mix_ct_c7,

      mix_bi_b1 => mix_bi_b1, mix_bi_b2 => mix_bi_b2, mix_bi_b3 => mix_bi_b3,
      mix_bi_b4 => mix_bi_b4, mix_bi_b5 => mix_bi_b5,
      mix_bi_b6 => mix_bi_b6, mix_bi_b7 => mix_bi_b7,

      c_ctra_out    => c_ctra_mix,
      c_singer_out  => c_singer_mix,
      c_bicycle_out => c_bicycle_mix,

      mu_ct_ct_out => mu_ct_ct_sig, mu_si_ct_out => mu_si_ct_sig, mu_bi_ct_out => mu_bi_ct_sig,
      mu_ct_si_out => mu_ct_si_sig, mu_si_si_out => mu_si_si_sig, mu_bi_si_out => mu_bi_si_sig,
      mu_ct_bi_out => mu_ct_bi_sig, mu_si_bi_out => mu_si_bi_sig, mu_bi_bi_out => mu_bi_bi_sig,
      done          => mixer_done
    );

  u_cov_mixer : imm_friend_covariance_mixer
    port map (
      clk   => clk,
      start => cov_mixer_start,
      mu_ct_ct => mu_ct_ct_sig, mu_si_ct => mu_si_ct_sig, mu_bi_ct => mu_bi_ct_sig,
      mu_ct_si => mu_ct_si_sig, mu_si_si => mu_si_si_sig, mu_bi_si => mu_bi_si_sig,
      mu_ct_bi => mu_ct_bi_sig, mu_si_bi => mu_si_bi_sig, mu_bi_bi => mu_bi_bi_sig,

      ct_p1 => ct_p11, ct_p2 => ct_p33, ct_p3 => ct_p66,
      ct_p4 => ct_p22, ct_p5 => ct_p33, ct_p6 => ct_p66,
      ct_p7 => ct_p77, ct_p8 => P_SMALL, ct_p9 => P_SMALL,

      si_p1 => si_p11, si_p2 => si_p22, si_p3 => si_p33,
      si_p4 => si_p44, si_p5 => si_p55, si_p6 => si_p66,
      si_p7 => si_p77, si_p8 => si_p88, si_p9 => si_p99,

      bi_p1 => bi_p11, bi_p2 => bi_p33, bi_p3 => bi_p66,
      bi_p4 => bi_p22, bi_p5 => bi_p33, bi_p6 => bi_p66,
      bi_p7 => bi_p77, bi_p8 => P_SMALL, bi_p9 => P_SMALL,

      ct_s1 => map_ct_9d_xp, ct_s2 => map_ct_9d_xv, ct_s3 => map_ct_9d_xa,
      ct_s4 => map_ct_9d_yp, ct_s5 => map_ct_9d_yv, ct_s6 => map_ct_9d_ya,
      ct_s7 => map_ct_9d_zp, ct_s8 => map_ct_9d_zv, ct_s9 => map_ct_9d_za,

      si_s1 => si_xp, si_s2 => si_xv, si_s3 => si_xa,
      si_s4 => si_yp, si_s5 => si_yv, si_s6 => si_ya,
      si_s7 => si_zp, si_s8 => si_zv, si_s9 => si_za,

      bi_s1 => map_bi_9d_xp, bi_s2 => map_bi_9d_xv, bi_s3 => map_bi_9d_xa,
      bi_s4 => map_bi_9d_yp, bi_s5 => map_bi_9d_yv, bi_s6 => map_bi_9d_ya,
      bi_s7 => map_bi_9d_zp, bi_s8 => map_bi_9d_zv, bi_s9 => map_bi_9d_za,

      mix_si_s1 => mix_si_s1, mix_si_s2 => mix_si_s2, mix_si_s3 => mix_si_s3,
      mix_si_s4 => mix_si_s4, mix_si_s5 => mix_si_s5, mix_si_s6 => mix_si_s6,
      mix_si_s7 => mix_si_s7, mix_si_s8 => mix_si_s8, mix_si_s9 => mix_si_s9,

      ctra_native_p1 => ct_p11, ctra_native_p2 => ct_p22,
      ctra_native_p3 => ct_p33, ctra_native_p4 => ct_p44,
      ctra_native_p5 => ct_p55, ctra_native_p6 => ct_p66,
      ctra_native_p7 => ct_p77,

      bike_native_p1 => bi_p11, bike_native_p2 => bi_p22,
      bike_native_p3 => bi_p33, bike_native_p4 => bi_p44,
      bike_native_p5 => bi_p55, bike_native_p6 => bi_p66,
      bike_native_p7 => bi_p77,

      mix_si_p1 => mix_si_p1, mix_si_p2 => mix_si_p2, mix_si_p3 => mix_si_p3,
      mix_si_p4 => mix_si_p4, mix_si_p5 => mix_si_p5, mix_si_p6 => mix_si_p6,
      mix_si_p7 => mix_si_p7, mix_si_p8 => mix_si_p8, mix_si_p9 => mix_si_p9,
      mix_ct_p1 => mix_ct_p1_sig, mix_ct_p2 => mix_ct_p2_sig,
      mix_ct_p3 => mix_ct_p3_sig, mix_ct_p4 => mix_ct_p4_sig,
      mix_ct_p5 => mix_ct_p5_sig, mix_ct_p6 => mix_ct_p6_sig,
      mix_ct_p7 => mix_ct_p7_sig,
      mix_bi_p1 => mix_bi_p1_sig, mix_bi_p2 => mix_bi_p2_sig,
      mix_bi_p3 => mix_bi_p3_sig, mix_bi_p4 => mix_bi_p4_sig,
      mix_bi_p5 => mix_bi_p5_sig, mix_bi_p6 => mix_bi_p6_sig,
      mix_bi_p7 => mix_bi_p7_sig,
      done => cov_mixer_done
    );

  u_likelihood : imm_likelihood
    port map (
      clk    => clk,
      start  => likelihood_start,

      nu1_x  => ct_nu_x,
      nu1_y  => ct_nu_y,
      nu1_z  => ct_nu_z,
      s1_11  => ct_s11,
      s1_22  => ct_s22,
      s1_33  => ct_s33,

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

      L1_out => L_ctra,
      L2_out => L_singer,
      L3_out => L_bike,
      done   => likelihood_done
    );

  u_prob_update : imm_prob_update
    port map (
      clk             => clk,
      start           => prob_update_start,
      L_ca            => L_ctra,
      L_singer        => L_singer,
      L_bicycle       => L_bike,
      c_ca            => c_ctra_mix,
      c_singer        => c_singer_mix,
      c_bicycle       => c_bicycle_mix,
      prob_ca_out     => prob_ctra_new,
      prob_singer_out => prob_singer_new,
      prob_bicycle_out => prob_bike_new,
      done            => prob_update_done
    );

  u_fusion : imm_output_fusion
    port map (
      clk          => clk,
      start        => fusion_start,
      prob_ca      => prob_ctra,
      prob_singer  => prob_singer,
      prob_bicycle => prob_bike,
      ca_px        => ct_px,
      ca_py        => ct_py,
      ca_pz        => ct_z,
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
        prob_ctra   <= PROB_INIT_CTRA;
        prob_singer <= PROB_INIT_SINGER;
        prob_bike   <= PROB_INIT_BIKE;
        done        <= '0';

        ct_start   <= '0'; si_start   <= '0'; bi_start   <= '0';
        ct_inject_en <= '0'; si_inject_en <= '0'; bi_inject_en <= '0';
        map_si_bike_start <= '0'; map_si_ctra_start <= '0';
        map_bi_start <= '0'; map_ct_start <= '0';
        mixer_start      <= '0';
        cov_mixer_start  <= '0';
        likelihood_start <= '0';
        prob_update_start <= '0';
        fusion_start     <= '0';

      else

        ct_start   <= '0'; si_start   <= '0'; bi_start   <= '0';
        ct_inject_en <= '0'; si_inject_en <= '0'; bi_inject_en <= '0';
        ct_inject_state_only <= '0'; si_inject_state_only <= '0'; bi_inject_state_only <= '0';
        map_si_bike_start <= '0'; map_si_ctra_start <= '0';
        map_bi_start <= '0'; map_ct_start <= '0';
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
                report "IMM_FRIEND: IDLE->INIT_FIRST (first cycle)";
                state <= INIT_FIRST;
              else
                state <= MAP_STATES;
              end if;
            end if;

          when INIT_FIRST =>
            report "IMM_FRIEND: INIT_FIRST -> WAIT_FILTERS";
            ct_start <= '1';
            si_start <= '1';
            bi_start <= '1';

            ct_inject_en <= '0';
            si_inject_en <= '0';
            bi_inject_en <= '0';
            first_cycle <= '0';
            skip_prob   <= '1';

            ct_done_latch <= '0';
            si_done_latch <= '0';
            bi_done_latch <= '0';
            state <= WAIT_FILTERS;

          when MAP_STATES =>
            report "IMM_FRIEND: MAP_STATES -> WAIT_MAP";
            map_si_bike_start <= '1';
            map_si_ctra_start <= '1';
            map_bi_start      <= '1';
            map_ct_start      <= '1';

            map_si_bike_done_latch <= '0';
            map_si_ctra_done_latch <= '0';
            map_bi_done_latch      <= '0';
            map_ct_done_latch      <= '0';
            state <= WAIT_MAP;

          when WAIT_MAP =>
            if map_si_bike_done = '1' then map_si_bike_done_latch <= '1'; end if;
            if map_si_ctra_done = '1' then map_si_ctra_done_latch <= '1'; end if;
            if map_bi_9d_done   = '1' then map_bi_done_latch      <= '1'; end if;
            if map_ct_9d_done   = '1' then map_ct_done_latch      <= '1'; end if;
            if (map_si_bike_done = '1' or map_si_bike_done_latch = '1') and
               (map_si_ctra_done = '1' or map_si_ctra_done_latch = '1') and
               (map_bi_9d_done   = '1' or map_bi_done_latch      = '1') and
               (map_ct_9d_done   = '1' or map_ct_done_latch      = '1') then
              report "IMM_FRIEND: WAIT_MAP -> START_MIX (all 4 mappers done)";
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

            ct_inj_px    <= mix_ct_c1;
            ct_inj_py    <= mix_ct_c2;
            ct_inj_v     <= mix_ct_c3;
            ct_inj_theta <= mix_ct_c4;
            ct_inj_omega <= mix_ct_c5;
            ct_inj_a     <= mix_ct_c6;
            ct_inj_z     <= mix_ct_c7;

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

            report "IMM_FRIEND INJECT_MIXED: mix_si_p1=" & integer'image(to_integer(mix_si_p1)) &
              " mix_si_p2=" & integer'image(to_integer(mix_si_p2)) &
              " mix_si_p4=" & integer'image(to_integer(mix_si_p4)) &
              " ct_p11=" & integer'image(to_integer(ct_p11)) &
              " si_p11=" & integer'image(to_integer(si_p11)) &
              " bi_p11=" & integer'image(to_integer(bi_p11));

            ct_inj_p11 <= mix_ct_p1_sig; ct_inj_p22 <= mix_ct_p2_sig;
            ct_inj_p33 <= mix_ct_p3_sig; ct_inj_p44 <= mix_ct_p4_sig;
            ct_inj_p55 <= mix_ct_p5_sig; ct_inj_p66 <= mix_ct_p6_sig;
            ct_inj_p77 <= mix_ct_p7_sig;

            si_inj_p11 <= mix_si_p1; si_inj_p22 <= mix_si_p2; si_inj_p33 <= mix_si_p3;
            si_inj_p44 <= mix_si_p4; si_inj_p55 <= mix_si_p5; si_inj_p66 <= mix_si_p6;
            si_inj_p77 <= mix_si_p7; si_inj_p88 <= mix_si_p8; si_inj_p99 <= mix_si_p9;

            bi_inj_p11 <= mix_bi_p1_sig; bi_inj_p22 <= mix_bi_p2_sig;
            bi_inj_p33 <= mix_bi_p3_sig; bi_inj_p44 <= mix_bi_p4_sig;
            bi_inj_p55 <= mix_bi_p5_sig; bi_inj_p66 <= mix_bi_p6_sig;
            bi_inj_p77 <= mix_bi_p7_sig;

            ct_inject_state_only <= '0';
            si_inject_state_only <= '0';
            bi_inject_state_only <= '0';

            ct_inject_en <= '1';
            si_inject_en <= '1';
            bi_inject_en <= '1';
            ct_start <= '1';
            si_start <= '1';
            bi_start <= '1';

            ct_done_latch <= '0';
            si_done_latch <= '0';
            bi_done_latch <= '0';
            state <= WAIT_FILTERS;

          when WAIT_FILTERS =>
            if ct_done_sig = '1' then ct_done_latch <= '1'; end if;
            if si_done_sig = '1' then si_done_latch <= '1'; end if;
            if bi_done_sig = '1' then bi_done_latch <= '1'; end if;
            if (ct_done_sig = '1' or ct_done_latch = '1') and
               (si_done_sig = '1' or si_done_latch = '1') and
               (bi_done_sig = '1' or bi_done_latch = '1') then
              if skip_prob = '1' then
                report "IMM_FRIEND: All filters done (first cycle) -> START_FUSION";
                skip_prob <= '0';
                state <= START_FUSION;
              else
                report "IMM_FRIEND: All filters done -> START_LIKELIHOOD";
                state <= START_LIKELIHOOD;
              end if;
            end if;

          when START_LIKELIHOOD =>
            report "IMM_FRIEND LIKELIHOOD inputs:" &
              " ct_nu_x=" & integer'image(to_integer(ct_nu_x)) &
              " ct_nu_y=" & integer'image(to_integer(ct_nu_y)) &
              " ct_s11=" & integer'image(to_integer(ct_s11)) &
              " ct_s22=" & integer'image(to_integer(ct_s22)) &
              " bi_nu_x=" & integer'image(to_integer(bi_nu_x)) &
              " bi_nu_y=" & integer'image(to_integer(bi_nu_y)) &
              " bi_s11=" & integer'image(to_integer(bi_s11)) &
              " bi_s22=" & integer'image(to_integer(bi_s22));
            likelihood_start <= '1';
            state <= WAIT_LIKELIHOOD;

          when WAIT_LIKELIHOOD =>
            if likelihood_done = '1' then
              report "IMM_FRIEND LIKELIHOOD outputs:" &
                " L_ctra=" & integer'image(to_integer(L_ctra)) &
                " L_singer=" & integer'image(to_integer(L_singer)) &
                " L_bike=" & integer'image(to_integer(L_bike));
              state <= START_PROB_UPDATE;
            end if;

          when START_PROB_UPDATE =>
            prob_update_start <= '1';
            state <= WAIT_PROB_UPDATE;

          when WAIT_PROB_UPDATE =>
            if prob_update_done = '1' then
              report "IMM_FRIEND PROB_UPDATE outputs:" &
                " prob_ctra_new=" & integer'image(to_integer(prob_ctra_new)) &
                " prob_singer_new=" & integer'image(to_integer(prob_singer_new)) &
                " prob_bike_new=" & integer'image(to_integer(prob_bike_new));
              prob_ctra   <= prob_ctra_new;
              prob_singer <= prob_singer_new;
              prob_bike   <= prob_bike_new;
              state <= START_FUSION;
            end if;

          when START_FUSION =>
            report "IMM_FRIEND FUSION inputs:" &
              " prob_ctra=" & integer'image(to_integer(prob_ctra)) &
              " prob_si=" & integer'image(to_integer(prob_singer)) &
              " prob_bi=" & integer'image(to_integer(prob_bike));
            fusion_start <= '1';
            state <= WAIT_FUSION;

          when WAIT_FUSION =>
            if fusion_done = '1' then
              state <= DONE_STATE;
            end if;

          when DONE_STATE =>
            report "IMM_FRIEND: DONE_STATE";
            done <= '1';
            state <= IDLE;

        end case;
      end if;
    end if;
  end process;

  px_out <= fused_px when abs(fused_px - z_x_meas) < to_signed(167772160, 48)
            else z_x_meas;
  py_out <= fused_py when abs(fused_py - z_y_meas) < to_signed(167772160, 48)
            else z_y_meas;
  pz_out <= fused_pz when abs(fused_pz - z_z_meas) < to_signed(167772160, 48)
            else z_z_meas;
  prob_ctra_out   <= prob_ctra;
  prob_singer_out <= prob_singer;
  prob_bike_out   <= prob_bike;

end architecture;
