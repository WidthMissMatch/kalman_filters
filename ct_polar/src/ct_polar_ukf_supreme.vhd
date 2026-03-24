library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ct_polar_ukf_supreme is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    start : in  std_logic;

    z_x_meas : in signed(47 downto 0);
    z_y_meas : in signed(47 downto 0);
    z_z_meas : in signed(47 downto 0);

    px_current    : out signed(47 downto 0);
    py_current    : out signed(47 downto 0);
    v_current     : out signed(47 downto 0);
    theta_current : out signed(47 downto 0);
    omega_current : out signed(47 downto 0);
    a_current     : out signed(47 downto 0);
    z_current     : out signed(47 downto 0);
    vz_current    : out signed(47 downto 0);
    az_current    : out signed(47 downto 0);

    p11_diag : out signed(47 downto 0);
    p22_diag : out signed(47 downto 0);
    p33_diag : out signed(47 downto 0);
    p44_diag : out signed(47 downto 0);
    p55_diag : out signed(47 downto 0);
    p66_diag : out signed(47 downto 0);
    p77_diag : out signed(47 downto 0);
    p88_diag : out signed(47 downto 0);
    p99_diag : out signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of ct_polar_ukf_supreme is

  component cholesky_9x9 is
    port (
      clk, rst, start : in std_logic;
      p11 : in signed(47 downto 0);
      p12, p22 : in signed(47 downto 0);
      p13, p23, p33 : in signed(47 downto 0);
      p14, p24, p34, p44 : in signed(47 downto 0);
      p15, p25, p35, p45, p55 : in signed(47 downto 0);
      p16, p26, p36, p46, p56, p66 : in signed(47 downto 0);
      p17, p27, p37, p47, p57, p67, p77 : in signed(47 downto 0);
      p18, p28, p38, p48, p58, p68, p78, p88 : in signed(47 downto 0);
      p19, p29, p39, p49, p59, p69, p79, p89, p99 : in signed(47 downto 0);
      l11_out : out signed(47 downto 0);
      l21_out, l22_out : out signed(47 downto 0);
      l31_out, l32_out, l33_out : out signed(47 downto 0);
      l41_out, l42_out, l43_out, l44_out : out signed(47 downto 0);
      l51_out, l52_out, l53_out, l54_out, l55_out : out signed(47 downto 0);
      l61_out, l62_out, l63_out, l64_out, l65_out, l66_out : out signed(47 downto 0);
      l71_out, l72_out, l73_out, l74_out, l75_out, l76_out, l77_out : out signed(47 downto 0);
      l81_out, l82_out, l83_out, l84_out, l85_out, l86_out, l87_out, l88_out : out signed(47 downto 0);
      l91_out, l92_out, l93_out, l94_out, l95_out, l96_out, l97_out, l98_out, l99_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component sigma_9d is
    port (
      clk, rst : in std_logic;
      cholesky_done : in std_logic;
      px_mean, py_mean, v_mean, theta_mean, omega_mean, a_mean, z_mean, vz_mean, az_mean : in signed(47 downto 0);
      l11 : in signed(47 downto 0);
      l21, l22 : in signed(47 downto 0);
      l31, l32, l33 : in signed(47 downto 0);
      l41, l42, l43, l44 : in signed(47 downto 0);
      l51, l52, l53, l54, l55 : in signed(47 downto 0);
      l61, l62, l63, l64, l65, l66 : in signed(47 downto 0);
      l71, l72, l73, l74, l75, l76, l77 : in signed(47 downto 0);
      l81, l82, l83, l84, l85, l86, l87, l88 : in signed(47 downto 0);
      l91, l92, l93, l94, l95, l96, l97, l98, l99 : in signed(47 downto 0);
      chi0_px, chi0_py, chi0_v, chi0_theta, chi0_omega, chi0_a, chi0_z, chi0_vz, chi0_az : out signed(47 downto 0);
      chi1_px, chi1_py, chi1_v, chi1_theta, chi1_omega, chi1_a, chi1_z, chi1_vz, chi1_az : out signed(47 downto 0);
      chi2_px, chi2_py, chi2_v, chi2_theta, chi2_omega, chi2_a, chi2_z, chi2_vz, chi2_az : out signed(47 downto 0);
      chi3_px, chi3_py, chi3_v, chi3_theta, chi3_omega, chi3_a, chi3_z, chi3_vz, chi3_az : out signed(47 downto 0);
      chi4_px, chi4_py, chi4_v, chi4_theta, chi4_omega, chi4_a, chi4_z, chi4_vz, chi4_az : out signed(47 downto 0);
      chi5_px, chi5_py, chi5_v, chi5_theta, chi5_omega, chi5_a, chi5_z, chi5_vz, chi5_az : out signed(47 downto 0);
      chi6_px, chi6_py, chi6_v, chi6_theta, chi6_omega, chi6_a, chi6_z, chi6_vz, chi6_az : out signed(47 downto 0);
      chi7_px, chi7_py, chi7_v, chi7_theta, chi7_omega, chi7_a, chi7_z, chi7_vz, chi7_az : out signed(47 downto 0);
      chi8_px, chi8_py, chi8_v, chi8_theta, chi8_omega, chi8_a, chi8_z, chi8_vz, chi8_az : out signed(47 downto 0);
      chi9_px, chi9_py, chi9_v, chi9_theta, chi9_omega, chi9_a, chi9_z, chi9_vz, chi9_az : out signed(47 downto 0);
      chi10_px, chi10_py, chi10_v, chi10_theta, chi10_omega, chi10_a, chi10_z, chi10_vz, chi10_az : out signed(47 downto 0);
      chi11_px, chi11_py, chi11_v, chi11_theta, chi11_omega, chi11_a, chi11_z, chi11_vz, chi11_az : out signed(47 downto 0);
      chi12_px, chi12_py, chi12_v, chi12_theta, chi12_omega, chi12_a, chi12_z, chi12_vz, chi12_az : out signed(47 downto 0);
      chi13_px, chi13_py, chi13_v, chi13_theta, chi13_omega, chi13_a, chi13_z, chi13_vz, chi13_az : out signed(47 downto 0);
      chi14_px, chi14_py, chi14_v, chi14_theta, chi14_omega, chi14_a, chi14_z, chi14_vz, chi14_az : out signed(47 downto 0);
      chi15_px, chi15_py, chi15_v, chi15_theta, chi15_omega, chi15_a, chi15_z, chi15_vz, chi15_az : out signed(47 downto 0);
      chi16_px, chi16_py, chi16_v, chi16_theta, chi16_omega, chi16_a, chi16_z, chi16_vz, chi16_az : out signed(47 downto 0);
      chi17_px, chi17_py, chi17_v, chi17_theta, chi17_omega, chi17_a, chi17_z, chi17_vz, chi17_az : out signed(47 downto 0);
      chi18_px, chi18_py, chi18_v, chi18_theta, chi18_omega, chi18_a, chi18_z, chi18_vz, chi18_az : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component predicti_ct_polar is
    port (
      clk, rst, start : in std_logic;
      chi0_px_in, chi0_py_in, chi0_v_in, chi0_theta_in, chi0_omega_in, chi0_a_in, chi0_z_in, chi0_vz_in, chi0_az_in : in signed(47 downto 0);
      chi1_px_in, chi1_py_in, chi1_v_in, chi1_theta_in, chi1_omega_in, chi1_a_in, chi1_z_in, chi1_vz_in, chi1_az_in : in signed(47 downto 0);
      chi2_px_in, chi2_py_in, chi2_v_in, chi2_theta_in, chi2_omega_in, chi2_a_in, chi2_z_in, chi2_vz_in, chi2_az_in : in signed(47 downto 0);
      chi3_px_in, chi3_py_in, chi3_v_in, chi3_theta_in, chi3_omega_in, chi3_a_in, chi3_z_in, chi3_vz_in, chi3_az_in : in signed(47 downto 0);
      chi4_px_in, chi4_py_in, chi4_v_in, chi4_theta_in, chi4_omega_in, chi4_a_in, chi4_z_in, chi4_vz_in, chi4_az_in : in signed(47 downto 0);
      chi5_px_in, chi5_py_in, chi5_v_in, chi5_theta_in, chi5_omega_in, chi5_a_in, chi5_z_in, chi5_vz_in, chi5_az_in : in signed(47 downto 0);
      chi6_px_in, chi6_py_in, chi6_v_in, chi6_theta_in, chi6_omega_in, chi6_a_in, chi6_z_in, chi6_vz_in, chi6_az_in : in signed(47 downto 0);
      chi7_px_in, chi7_py_in, chi7_v_in, chi7_theta_in, chi7_omega_in, chi7_a_in, chi7_z_in, chi7_vz_in, chi7_az_in : in signed(47 downto 0);
      chi8_px_in, chi8_py_in, chi8_v_in, chi8_theta_in, chi8_omega_in, chi8_a_in, chi8_z_in, chi8_vz_in, chi8_az_in : in signed(47 downto 0);
      chi9_px_in, chi9_py_in, chi9_v_in, chi9_theta_in, chi9_omega_in, chi9_a_in, chi9_z_in, chi9_vz_in, chi9_az_in : in signed(47 downto 0);
      chi10_px_in, chi10_py_in, chi10_v_in, chi10_theta_in, chi10_omega_in, chi10_a_in, chi10_z_in, chi10_vz_in, chi10_az_in : in signed(47 downto 0);
      chi11_px_in, chi11_py_in, chi11_v_in, chi11_theta_in, chi11_omega_in, chi11_a_in, chi11_z_in, chi11_vz_in, chi11_az_in : in signed(47 downto 0);
      chi12_px_in, chi12_py_in, chi12_v_in, chi12_theta_in, chi12_omega_in, chi12_a_in, chi12_z_in, chi12_vz_in, chi12_az_in : in signed(47 downto 0);
      chi13_px_in, chi13_py_in, chi13_v_in, chi13_theta_in, chi13_omega_in, chi13_a_in, chi13_z_in, chi13_vz_in, chi13_az_in : in signed(47 downto 0);
      chi14_px_in, chi14_py_in, chi14_v_in, chi14_theta_in, chi14_omega_in, chi14_a_in, chi14_z_in, chi14_vz_in, chi14_az_in : in signed(47 downto 0);
      chi15_px_in, chi15_py_in, chi15_v_in, chi15_theta_in, chi15_omega_in, chi15_a_in, chi15_z_in, chi15_vz_in, chi15_az_in : in signed(47 downto 0);
      chi16_px_in, chi16_py_in, chi16_v_in, chi16_theta_in, chi16_omega_in, chi16_a_in, chi16_z_in, chi16_vz_in, chi16_az_in : in signed(47 downto 0);
      chi17_px_in, chi17_py_in, chi17_v_in, chi17_theta_in, chi17_omega_in, chi17_a_in, chi17_z_in, chi17_vz_in, chi17_az_in : in signed(47 downto 0);
      chi18_px_in, chi18_py_in, chi18_v_in, chi18_theta_in, chi18_omega_in, chi18_a_in, chi18_z_in, chi18_vz_in, chi18_az_in : in signed(47 downto 0);
      chi0_px_out, chi0_py_out, chi0_v_out, chi0_theta_out, chi0_omega_out, chi0_a_out, chi0_z_out, chi0_vz_out, chi0_az_out : out signed(47 downto 0);
      chi1_px_out, chi1_py_out, chi1_v_out, chi1_theta_out, chi1_omega_out, chi1_a_out, chi1_z_out, chi1_vz_out, chi1_az_out : out signed(47 downto 0);
      chi2_px_out, chi2_py_out, chi2_v_out, chi2_theta_out, chi2_omega_out, chi2_a_out, chi2_z_out, chi2_vz_out, chi2_az_out : out signed(47 downto 0);
      chi3_px_out, chi3_py_out, chi3_v_out, chi3_theta_out, chi3_omega_out, chi3_a_out, chi3_z_out, chi3_vz_out, chi3_az_out : out signed(47 downto 0);
      chi4_px_out, chi4_py_out, chi4_v_out, chi4_theta_out, chi4_omega_out, chi4_a_out, chi4_z_out, chi4_vz_out, chi4_az_out : out signed(47 downto 0);
      chi5_px_out, chi5_py_out, chi5_v_out, chi5_theta_out, chi5_omega_out, chi5_a_out, chi5_z_out, chi5_vz_out, chi5_az_out : out signed(47 downto 0);
      chi6_px_out, chi6_py_out, chi6_v_out, chi6_theta_out, chi6_omega_out, chi6_a_out, chi6_z_out, chi6_vz_out, chi6_az_out : out signed(47 downto 0);
      chi7_px_out, chi7_py_out, chi7_v_out, chi7_theta_out, chi7_omega_out, chi7_a_out, chi7_z_out, chi7_vz_out, chi7_az_out : out signed(47 downto 0);
      chi8_px_out, chi8_py_out, chi8_v_out, chi8_theta_out, chi8_omega_out, chi8_a_out, chi8_z_out, chi8_vz_out, chi8_az_out : out signed(47 downto 0);
      chi9_px_out, chi9_py_out, chi9_v_out, chi9_theta_out, chi9_omega_out, chi9_a_out, chi9_z_out, chi9_vz_out, chi9_az_out : out signed(47 downto 0);
      chi10_px_out, chi10_py_out, chi10_v_out, chi10_theta_out, chi10_omega_out, chi10_a_out, chi10_z_out, chi10_vz_out, chi10_az_out : out signed(47 downto 0);
      chi11_px_out, chi11_py_out, chi11_v_out, chi11_theta_out, chi11_omega_out, chi11_a_out, chi11_z_out, chi11_vz_out, chi11_az_out : out signed(47 downto 0);
      chi12_px_out, chi12_py_out, chi12_v_out, chi12_theta_out, chi12_omega_out, chi12_a_out, chi12_z_out, chi12_vz_out, chi12_az_out : out signed(47 downto 0);
      chi13_px_out, chi13_py_out, chi13_v_out, chi13_theta_out, chi13_omega_out, chi13_a_out, chi13_z_out, chi13_vz_out, chi13_az_out : out signed(47 downto 0);
      chi14_px_out, chi14_py_out, chi14_v_out, chi14_theta_out, chi14_omega_out, chi14_a_out, chi14_z_out, chi14_vz_out, chi14_az_out : out signed(47 downto 0);
      chi15_px_out, chi15_py_out, chi15_v_out, chi15_theta_out, chi15_omega_out, chi15_a_out, chi15_z_out, chi15_vz_out, chi15_az_out : out signed(47 downto 0);
      chi16_px_out, chi16_py_out, chi16_v_out, chi16_theta_out, chi16_omega_out, chi16_a_out, chi16_z_out, chi16_vz_out, chi16_az_out : out signed(47 downto 0);
      chi17_px_out, chi17_py_out, chi17_v_out, chi17_theta_out, chi17_omega_out, chi17_a_out, chi17_z_out, chi17_vz_out, chi17_az_out : out signed(47 downto 0);
      chi18_px_out, chi18_py_out, chi18_v_out, chi18_theta_out, chi18_omega_out, chi18_a_out, chi18_z_out, chi18_vz_out, chi18_az_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component predicted_mean_9d is
    port (
      clk, rst, start : in std_logic;
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
      s1_mean, s2_mean, s3_mean, s4_mean, s5_mean : buffer signed(47 downto 0);
      s6_mean, s7_mean, s8_mean, s9_mean           : buffer signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component predicted_covariance_9d is
    port (
      clk, start : in std_logic;
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
  end component;

  component process_noise_ct_polar is
    port (
      clk, rst, start : in std_logic;
      p11_in, p22_in, p33_in, p44_in, p55_in : in signed(47 downto 0);
      p66_in, p77_in, p88_in, p99_in         : in signed(47 downto 0);
      p11_out, p22_out, p33_out, p44_out, p55_out : out signed(47 downto 0);
      p66_out, p77_out, p88_out, p99_out           : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component innovation_covariance_9d is
    port (
      clk, start : in std_logic;
      z_x_mean, z_y_mean, z_z_mean : in signed(47 downto 0);
      chi0_z_x, chi0_z_y, chi0_z_z : in signed(47 downto 0);
      chi1_z_x, chi1_z_y, chi1_z_z : in signed(47 downto 0);
      chi2_z_x, chi2_z_y, chi2_z_z : in signed(47 downto 0);
      chi3_z_x, chi3_z_y, chi3_z_z : in signed(47 downto 0);
      chi4_z_x, chi4_z_y, chi4_z_z : in signed(47 downto 0);
      chi5_z_x, chi5_z_y, chi5_z_z : in signed(47 downto 0);
      chi6_z_x, chi6_z_y, chi6_z_z : in signed(47 downto 0);
      chi7_z_x, chi7_z_y, chi7_z_z : in signed(47 downto 0);
      chi8_z_x, chi8_z_y, chi8_z_z : in signed(47 downto 0);
      chi9_z_x, chi9_z_y, chi9_z_z : in signed(47 downto 0);
      chi10_z_x, chi10_z_y, chi10_z_z : in signed(47 downto 0);
      chi11_z_x, chi11_z_y, chi11_z_z : in signed(47 downto 0);
      chi12_z_x, chi12_z_y, chi12_z_z : in signed(47 downto 0);
      chi13_z_x, chi13_z_y, chi13_z_z : in signed(47 downto 0);
      chi14_z_x, chi14_z_y, chi14_z_z : in signed(47 downto 0);
      chi15_z_x, chi15_z_y, chi15_z_z : in signed(47 downto 0);
      chi16_z_x, chi16_z_y, chi16_z_z : in signed(47 downto 0);
      chi17_z_x, chi17_z_y, chi17_z_z : in signed(47 downto 0);
      chi18_z_x, chi18_z_y, chi18_z_z : in signed(47 downto 0);
      s11, s12, s22, s13, s23, s33 : buffer signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component innovation_3d is
    port (
      clk, start : in std_logic;
      z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);
      z_x_pred, z_y_pred, z_z_pred : in signed(47 downto 0);
      nu_x, nu_y, nu_z : buffer signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component cross_covariance_9d is
    port (
      clk, rst, start : in std_logic;
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
  end component;

  component kalman_gain_9d is
    port (
      clk, start : in std_logic;
      pxz_11, pxz_12, pxz_13 : in signed(47 downto 0);
      pxz_21, pxz_22, pxz_23 : in signed(47 downto 0);
      pxz_31, pxz_32, pxz_33 : in signed(47 downto 0);
      pxz_41, pxz_42, pxz_43 : in signed(47 downto 0);
      pxz_51, pxz_52, pxz_53 : in signed(47 downto 0);
      pxz_61, pxz_62, pxz_63 : in signed(47 downto 0);
      pxz_71, pxz_72, pxz_73 : in signed(47 downto 0);
      pxz_81, pxz_82, pxz_83 : in signed(47 downto 0);
      pxz_91, pxz_92, pxz_93 : in signed(47 downto 0);
      s11, s12, s22, s13, s23, s33 : in signed(47 downto 0);
      k11, k12, k13 : buffer signed(47 downto 0);
      k21, k22, k23 : buffer signed(47 downto 0);
      k31, k32, k33 : buffer signed(47 downto 0);
      k41, k42, k43 : buffer signed(47 downto 0);
      k51, k52, k53 : buffer signed(47 downto 0);
      k61, k62, k63 : buffer signed(47 downto 0);
      k71, k72, k73 : buffer signed(47 downto 0);
      k81, k82, k83 : buffer signed(47 downto 0);
      k91, k92, k93 : buffer signed(47 downto 0);
      error : out std_logic;
      done  : out std_logic
    );
  end component;

  component state_update_9d is
    port (
      clk, start : in std_logic;
      s1_pred, s2_pred, s3_pred : in signed(47 downto 0);
      s4_pred, s5_pred, s6_pred : in signed(47 downto 0);
      s7_pred, s8_pred, s9_pred : in signed(47 downto 0);
      p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred : in signed(47 downto 0);
      p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred           : in signed(47 downto 0);
      p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred                     : in signed(47 downto 0);
      p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred                               : in signed(47 downto 0);
      p55_pred, p56_pred, p57_pred, p58_pred, p59_pred                                         : in signed(47 downto 0);
      p66_pred, p67_pred, p68_pred, p69_pred                                                   : in signed(47 downto 0);
      p77_pred, p78_pred, p79_pred                                                             : in signed(47 downto 0);
      p88_pred, p89_pred                                                                       : in signed(47 downto 0);
      p99_pred                                                                                 : in signed(47 downto 0);
      k11, k12, k13 : in signed(47 downto 0);
      k21, k22, k23 : in signed(47 downto 0);
      k31, k32, k33 : in signed(47 downto 0);
      k41, k42, k43 : in signed(47 downto 0);
      k51, k52, k53 : in signed(47 downto 0);
      k61, k62, k63 : in signed(47 downto 0);
      k71, k72, k73 : in signed(47 downto 0);
      k81, k82, k83 : in signed(47 downto 0);
      k91, k92, k93 : in signed(47 downto 0);
      nu_1, nu_2, nu_3 : in signed(47 downto 0);
      s1_upd, s2_upd, s3_upd : buffer signed(47 downto 0);
      s4_upd, s5_upd, s6_upd : buffer signed(47 downto 0);
      s7_upd, s8_upd, s9_upd : buffer signed(47 downto 0);
      p11_upd, p12_upd, p13_upd, p14_upd, p15_upd, p16_upd, p17_upd, p18_upd, p19_upd : buffer signed(47 downto 0);
      p22_upd, p23_upd, p24_upd, p25_upd, p26_upd, p27_upd, p28_upd, p29_upd           : buffer signed(47 downto 0);
      p33_upd, p34_upd, p35_upd, p36_upd, p37_upd, p38_upd, p39_upd                    : buffer signed(47 downto 0);
      p44_upd, p45_upd, p46_upd, p47_upd, p48_upd, p49_upd                             : buffer signed(47 downto 0);
      p55_upd, p56_upd, p57_upd, p58_upd, p59_upd                                      : buffer signed(47 downto 0);
      p66_upd, p67_upd, p68_upd, p69_upd                                               : buffer signed(47 downto 0);
      p77_upd, p78_upd, p79_upd                                                        : buffer signed(47 downto 0);
      p88_upd, p89_upd                                                                 : buffer signed(47 downto 0);
      p99_upd                                                                          : buffer signed(47 downto 0);
      done : out std_logic
    );
  end component;

  type state_type is (
    IDLE, INIT_STATE,
    START_CHOLESKY, WAIT_CHOLESKY,
    WAIT_SIGMA,
    START_PROPAGATE, WAIT_PROPAGATE,
    START_MEAN_COV, WAIT_MEAN,
    START_PCOV, WAIT_PCOV,
    START_PROC_NOISE, WAIT_PROC_NOISE,
    START_MEAS_UPDATE, WAIT_INNOV_COV,
    START_KALMAN, WAIT_KALMAN,
    START_STATE_UPD, WAIT_STATE_UPD,
    LATCH_OUTPUT, CYCLE_DONE
  );
  signal fsm_state : state_type := IDLE;

  constant P_INIT_1 : signed(47 downto 0) := to_signed(83886080, 48);
  constant P_INIT_2 : signed(47 downto 0) := to_signed(83886080, 48);
  constant P_INIT_3 : signed(47 downto 0) := to_signed(335544320, 48);
  constant P_INIT_4 : signed(47 downto 0) := to_signed(1677722, 48);
  constant P_INIT_5 : signed(47 downto 0) := to_signed(1677722, 48);
  constant P_INIT_6 : signed(47 downto 0) := to_signed(16777216, 48);
  constant P_INIT_7 : signed(47 downto 0) := to_signed(83886080, 48);
  constant P_INIT_8 : signed(47 downto 0) := to_signed(1677721600, 48);
  constant P_INIT_9 : signed(47 downto 0) := to_signed(167772, 48);

  signal x_state  : signed(47 downto 0) := (others => '0');
  signal y_state  : signed(47 downto 0) := (others => '0');
  signal v_state  : signed(47 downto 0) := (others => '0');
  signal t_state  : signed(47 downto 0) := (others => '0');
  signal w_state  : signed(47 downto 0) := (others => '0');
  signal a_state  : signed(47 downto 0) := (others => '0');
  signal z_state  : signed(47 downto 0) := (others => '0');
  signal vz_state : signed(47 downto 0) := (others => '0');
  signal az_state : signed(47 downto 0) := (others => '0');

  signal cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19 : signed(47 downto 0) := (others => '0');
  signal cp22, cp23, cp24, cp25, cp26, cp27, cp28, cp29 : signed(47 downto 0) := (others => '0');
  signal cp33, cp34, cp35, cp36, cp37, cp38, cp39 : signed(47 downto 0) := (others => '0');
  signal cp44, cp45, cp46, cp47, cp48, cp49 : signed(47 downto 0) := (others => '0');
  signal cp55, cp56, cp57, cp58, cp59 : signed(47 downto 0) := (others => '0');
  signal cp66, cp67, cp68, cp69 : signed(47 downto 0) := (others => '0');
  signal cp77, cp78, cp79 : signed(47 downto 0) := (others => '0');
  signal cp88, cp89 : signed(47 downto 0) := (others => '0');
  signal cp99 : signed(47 downto 0) := (others => '0');

  signal first_cycle : std_logic := '1';

  signal chol_start, chol_done : std_logic;
  signal l11_s : signed(47 downto 0);
  signal l21_s, l22_s : signed(47 downto 0);
  signal l31_s, l32_s, l33_s : signed(47 downto 0);
  signal l41_s, l42_s, l43_s, l44_s : signed(47 downto 0);
  signal l51_s, l52_s, l53_s, l54_s, l55_s : signed(47 downto 0);
  signal l61_s, l62_s, l63_s, l64_s, l65_s, l66_s : signed(47 downto 0);
  signal l71_s, l72_s, l73_s, l74_s, l75_s, l76_s, l77_s : signed(47 downto 0);
  signal l81_s, l82_s, l83_s, l84_s, l85_s, l86_s, l87_s, l88_s : signed(47 downto 0);
  signal l91_s, l92_s, l93_s, l94_s, l95_s, l96_s, l97_s, l98_s, l99_s : signed(47 downto 0);

  signal sigma_done : std_logic;

  signal sig0_px, sig0_py, sig0_v, sig0_th, sig0_om, sig0_ac, sig0_z, sig0_vz, sig0_az : signed(47 downto 0);
  signal sig1_px, sig1_py, sig1_v, sig1_th, sig1_om, sig1_ac, sig1_z, sig1_vz, sig1_az : signed(47 downto 0);
  signal sig2_px, sig2_py, sig2_v, sig2_th, sig2_om, sig2_ac, sig2_z, sig2_vz, sig2_az : signed(47 downto 0);
  signal sig3_px, sig3_py, sig3_v, sig3_th, sig3_om, sig3_ac, sig3_z, sig3_vz, sig3_az : signed(47 downto 0);
  signal sig4_px, sig4_py, sig4_v, sig4_th, sig4_om, sig4_ac, sig4_z, sig4_vz, sig4_az : signed(47 downto 0);
  signal sig5_px, sig5_py, sig5_v, sig5_th, sig5_om, sig5_ac, sig5_z, sig5_vz, sig5_az : signed(47 downto 0);
  signal sig6_px, sig6_py, sig6_v, sig6_th, sig6_om, sig6_ac, sig6_z, sig6_vz, sig6_az : signed(47 downto 0);
  signal sig7_px, sig7_py, sig7_v, sig7_th, sig7_om, sig7_ac, sig7_z, sig7_vz, sig7_az : signed(47 downto 0);
  signal sig8_px, sig8_py, sig8_v, sig8_th, sig8_om, sig8_ac, sig8_z, sig8_vz, sig8_az : signed(47 downto 0);
  signal sig9_px, sig9_py, sig9_v, sig9_th, sig9_om, sig9_ac, sig9_z, sig9_vz, sig9_az : signed(47 downto 0);
  signal sig10_px, sig10_py, sig10_v, sig10_th, sig10_om, sig10_ac, sig10_z, sig10_vz, sig10_az : signed(47 downto 0);
  signal sig11_px, sig11_py, sig11_v, sig11_th, sig11_om, sig11_ac, sig11_z, sig11_vz, sig11_az : signed(47 downto 0);
  signal sig12_px, sig12_py, sig12_v, sig12_th, sig12_om, sig12_ac, sig12_z, sig12_vz, sig12_az : signed(47 downto 0);
  signal sig13_px, sig13_py, sig13_v, sig13_th, sig13_om, sig13_ac, sig13_z, sig13_vz, sig13_az : signed(47 downto 0);
  signal sig14_px, sig14_py, sig14_v, sig14_th, sig14_om, sig14_ac, sig14_z, sig14_vz, sig14_az : signed(47 downto 0);
  signal sig15_px, sig15_py, sig15_v, sig15_th, sig15_om, sig15_ac, sig15_z, sig15_vz, sig15_az : signed(47 downto 0);
  signal sig16_px, sig16_py, sig16_v, sig16_th, sig16_om, sig16_ac, sig16_z, sig16_vz, sig16_az : signed(47 downto 0);
  signal sig17_px, sig17_py, sig17_v, sig17_th, sig17_om, sig17_ac, sig17_z, sig17_vz, sig17_az : signed(47 downto 0);
  signal sig18_px, sig18_py, sig18_v, sig18_th, sig18_om, sig18_ac, sig18_z, sig18_vz, sig18_az : signed(47 downto 0);

  signal prop_start, prop_done : std_logic;
  signal pr0_px, pr0_py, pr0_v, pr0_th, pr0_om, pr0_ac, pr0_z, pr0_vz, pr0_az : signed(47 downto 0);
  signal pr1_px, pr1_py, pr1_v, pr1_th, pr1_om, pr1_ac, pr1_z, pr1_vz, pr1_az : signed(47 downto 0);
  signal pr2_px, pr2_py, pr2_v, pr2_th, pr2_om, pr2_ac, pr2_z, pr2_vz, pr2_az : signed(47 downto 0);
  signal pr3_px, pr3_py, pr3_v, pr3_th, pr3_om, pr3_ac, pr3_z, pr3_vz, pr3_az : signed(47 downto 0);
  signal pr4_px, pr4_py, pr4_v, pr4_th, pr4_om, pr4_ac, pr4_z, pr4_vz, pr4_az : signed(47 downto 0);
  signal pr5_px, pr5_py, pr5_v, pr5_th, pr5_om, pr5_ac, pr5_z, pr5_vz, pr5_az : signed(47 downto 0);
  signal pr6_px, pr6_py, pr6_v, pr6_th, pr6_om, pr6_ac, pr6_z, pr6_vz, pr6_az : signed(47 downto 0);
  signal pr7_px, pr7_py, pr7_v, pr7_th, pr7_om, pr7_ac, pr7_z, pr7_vz, pr7_az : signed(47 downto 0);
  signal pr8_px, pr8_py, pr8_v, pr8_th, pr8_om, pr8_ac, pr8_z, pr8_vz, pr8_az : signed(47 downto 0);
  signal pr9_px, pr9_py, pr9_v, pr9_th, pr9_om, pr9_ac, pr9_z, pr9_vz, pr9_az : signed(47 downto 0);
  signal pr10_px, pr10_py, pr10_v, pr10_th, pr10_om, pr10_ac, pr10_z, pr10_vz, pr10_az : signed(47 downto 0);
  signal pr11_px, pr11_py, pr11_v, pr11_th, pr11_om, pr11_ac, pr11_z, pr11_vz, pr11_az : signed(47 downto 0);
  signal pr12_px, pr12_py, pr12_v, pr12_th, pr12_om, pr12_ac, pr12_z, pr12_vz, pr12_az : signed(47 downto 0);
  signal pr13_px, pr13_py, pr13_v, pr13_th, pr13_om, pr13_ac, pr13_z, pr13_vz, pr13_az : signed(47 downto 0);
  signal pr14_px, pr14_py, pr14_v, pr14_th, pr14_om, pr14_ac, pr14_z, pr14_vz, pr14_az : signed(47 downto 0);
  signal pr15_px, pr15_py, pr15_v, pr15_th, pr15_om, pr15_ac, pr15_z, pr15_vz, pr15_az : signed(47 downto 0);
  signal pr16_px, pr16_py, pr16_v, pr16_th, pr16_om, pr16_ac, pr16_z, pr16_vz, pr16_az : signed(47 downto 0);
  signal pr17_px, pr17_py, pr17_v, pr17_th, pr17_om, pr17_ac, pr17_z, pr17_vz, pr17_az : signed(47 downto 0);
  signal pr18_px, pr18_py, pr18_v, pr18_th, pr18_om, pr18_ac, pr18_z, pr18_vz, pr18_az : signed(47 downto 0);

  signal mean_start, mean_done : std_logic;
  signal xp1, xp2, xp3, xp4, xp5, xp6, xp7, xp8, xp9 : signed(47 downto 0);

  signal pcov_start, pcov_done : std_logic;
  signal pp11_s, pp12_s, pp13_s, pp14_s, pp15_s, pp16_s, pp17_s, pp18_s, pp19_s : signed(47 downto 0);
  signal pp22_s, pp23_s, pp24_s, pp25_s, pp26_s, pp27_s, pp28_s, pp29_s : signed(47 downto 0);
  signal pp33_s, pp34_s, pp35_s, pp36_s, pp37_s, pp38_s, pp39_s : signed(47 downto 0);
  signal pp44_s, pp45_s, pp46_s, pp47_s, pp48_s, pp49_s : signed(47 downto 0);
  signal pp55_s, pp56_s, pp57_s, pp58_s, pp59_s : signed(47 downto 0);
  signal pp66_s, pp67_s, pp68_s, pp69_s : signed(47 downto 0);
  signal pp77_s, pp78_s, pp79_s : signed(47 downto 0);
  signal pp88_s, pp89_s : signed(47 downto 0);
  signal pp99_s : signed(47 downto 0);

  signal pn_start, pn_done : std_logic;
  signal pn11, pn22, pn33, pn44, pn55, pn66, pn77, pn88, pn99 : signed(47 downto 0);

  signal ppred11, ppred12, ppred13, ppred14, ppred15, ppred16, ppred17, ppred18, ppred19 : signed(47 downto 0);
  signal ppred22, ppred23, ppred24, ppred25, ppred26, ppred27, ppred28, ppred29 : signed(47 downto 0);
  signal ppred33, ppred34, ppred35, ppred36, ppred37, ppred38, ppred39 : signed(47 downto 0);
  signal ppred44, ppred45, ppred46, ppred47, ppred48, ppred49 : signed(47 downto 0);
  signal ppred55, ppred56, ppred57, ppred58, ppred59 : signed(47 downto 0);
  signal ppred66, ppred67, ppred68, ppred69 : signed(47 downto 0);
  signal ppred77, ppred78, ppred79 : signed(47 downto 0);
  signal ppred88, ppred89 : signed(47 downto 0);
  signal ppred99 : signed(47 downto 0);

  signal ic_start, ic_done : std_logic;
  signal ic_done_latch, inn_done_latch, cc_done_latch : std_logic := '0';
  signal ss11, ss12, ss22, ss13, ss23, ss33 : signed(47 downto 0);

  signal inn_start, inn_done : std_logic;
  signal nu1, nu2, nu3 : signed(47 downto 0);

  signal cc_start, cc_done : std_logic;
  signal pxz11, pxz12, pxz13 : signed(47 downto 0);
  signal pxz21, pxz22, pxz23 : signed(47 downto 0);
  signal pxz31, pxz32, pxz33 : signed(47 downto 0);
  signal pxz41, pxz42, pxz43 : signed(47 downto 0);
  signal pxz51, pxz52, pxz53 : signed(47 downto 0);
  signal pxz61, pxz62, pxz63 : signed(47 downto 0);
  signal pxz71, pxz72, pxz73 : signed(47 downto 0);
  signal pxz81, pxz82, pxz83 : signed(47 downto 0);
  signal pxz91, pxz92, pxz93 : signed(47 downto 0);

  signal kg_start, kg_done, kg_error : std_logic;
  signal kk11, kk12, kk13 : signed(47 downto 0);
  signal kk21, kk22, kk23 : signed(47 downto 0);
  signal kk31, kk32, kk33 : signed(47 downto 0);
  signal kk41, kk42, kk43 : signed(47 downto 0);
  signal kk51, kk52, kk53 : signed(47 downto 0);
  signal kk61, kk62, kk63 : signed(47 downto 0);
  signal kk71, kk72, kk73 : signed(47 downto 0);
  signal kk81, kk82, kk83 : signed(47 downto 0);
  signal kk91, kk92, kk93 : signed(47 downto 0);

  signal su_start, su_done : std_logic;
  signal xu1, xu2, xu3, xu4, xu5, xu6, xu7, xu8, xu9 : signed(47 downto 0);
  signal pu11, pu12, pu13, pu14, pu15, pu16, pu17, pu18, pu19 : signed(47 downto 0);
  signal pu22, pu23, pu24, pu25, pu26, pu27, pu28, pu29 : signed(47 downto 0);
  signal pu33, pu34, pu35, pu36, pu37, pu38, pu39 : signed(47 downto 0);
  signal pu44, pu45, pu46, pu47, pu48, pu49 : signed(47 downto 0);
  signal pu55, pu56, pu57, pu58, pu59 : signed(47 downto 0);
  signal pu66, pu67, pu68, pu69 : signed(47 downto 0);
  signal pu77, pu78, pu79 : signed(47 downto 0);
  signal pu88, pu89 : signed(47 downto 0);
  signal pu99 : signed(47 downto 0);

begin

  chol_inst : cholesky_9x9
    port map (
      clk => clk, rst => reset, start => chol_start,
      p11 => cp11, p12 => cp12, p13 => cp13, p14 => cp14, p15 => cp15, p16 => cp16, p17 => cp17, p18 => cp18, p19 => cp19,
      p22 => cp22, p23 => cp23, p24 => cp24, p25 => cp25, p26 => cp26, p27 => cp27, p28 => cp28, p29 => cp29,
      p33 => cp33, p34 => cp34, p35 => cp35, p36 => cp36, p37 => cp37, p38 => cp38, p39 => cp39,
      p44 => cp44, p45 => cp45, p46 => cp46, p47 => cp47, p48 => cp48, p49 => cp49,
      p55 => cp55, p56 => cp56, p57 => cp57, p58 => cp58, p59 => cp59,
      p66 => cp66, p67 => cp67, p68 => cp68, p69 => cp69,
      p77 => cp77, p78 => cp78, p79 => cp79,
      p88 => cp88, p89 => cp89, p99 => cp99,
      l11_out => l11_s,
      l21_out => l21_s, l22_out => l22_s,
      l31_out => l31_s, l32_out => l32_s, l33_out => l33_s,
      l41_out => l41_s, l42_out => l42_s, l43_out => l43_s, l44_out => l44_s,
      l51_out => l51_s, l52_out => l52_s, l53_out => l53_s, l54_out => l54_s, l55_out => l55_s,
      l61_out => l61_s, l62_out => l62_s, l63_out => l63_s, l64_out => l64_s, l65_out => l65_s, l66_out => l66_s,
      l71_out => l71_s, l72_out => l72_s, l73_out => l73_s, l74_out => l74_s, l75_out => l75_s, l76_out => l76_s, l77_out => l77_s,
      l81_out => l81_s, l82_out => l82_s, l83_out => l83_s, l84_out => l84_s, l85_out => l85_s, l86_out => l86_s, l87_out => l87_s, l88_out => l88_s,
      l91_out => l91_s, l92_out => l92_s, l93_out => l93_s, l94_out => l94_s, l95_out => l95_s, l96_out => l96_s, l97_out => l97_s, l98_out => l98_s, l99_out => l99_s,
      done => chol_done
    );

  sigma_inst : sigma_9d
    port map (
      clk => clk, rst => reset, cholesky_done => chol_done,
      px_mean => x_state, py_mean => y_state, v_mean => v_state,
      theta_mean => t_state, omega_mean => w_state, a_mean => a_state,
      z_mean => z_state, vz_mean => vz_state, az_mean => az_state,
      l11 => l11_s,
      l21 => l21_s, l22 => l22_s,
      l31 => l31_s, l32 => l32_s, l33 => l33_s,
      l41 => l41_s, l42 => l42_s, l43 => l43_s, l44 => l44_s,
      l51 => l51_s, l52 => l52_s, l53 => l53_s, l54 => l54_s, l55 => l55_s,
      l61 => l61_s, l62 => l62_s, l63 => l63_s, l64 => l64_s, l65 => l65_s, l66 => l66_s,
      l71 => l71_s, l72 => l72_s, l73 => l73_s, l74 => l74_s, l75 => l75_s, l76 => l76_s, l77 => l77_s,
      l81 => l81_s, l82 => l82_s, l83 => l83_s, l84 => l84_s, l85 => l85_s, l86 => l86_s, l87 => l87_s, l88 => l88_s,
      l91 => l91_s, l92 => l92_s, l93 => l93_s, l94 => l94_s, l95 => l95_s, l96 => l96_s, l97 => l97_s, l98 => l98_s, l99 => l99_s,
      chi0_px => sig0_px, chi0_py => sig0_py, chi0_v => sig0_v, chi0_theta => sig0_th, chi0_omega => sig0_om, chi0_a => sig0_ac, chi0_z => sig0_z, chi0_vz => sig0_vz, chi0_az => sig0_az,
      chi1_px => sig1_px, chi1_py => sig1_py, chi1_v => sig1_v, chi1_theta => sig1_th, chi1_omega => sig1_om, chi1_a => sig1_ac, chi1_z => sig1_z, chi1_vz => sig1_vz, chi1_az => sig1_az,
      chi2_px => sig2_px, chi2_py => sig2_py, chi2_v => sig2_v, chi2_theta => sig2_th, chi2_omega => sig2_om, chi2_a => sig2_ac, chi2_z => sig2_z, chi2_vz => sig2_vz, chi2_az => sig2_az,
      chi3_px => sig3_px, chi3_py => sig3_py, chi3_v => sig3_v, chi3_theta => sig3_th, chi3_omega => sig3_om, chi3_a => sig3_ac, chi3_z => sig3_z, chi3_vz => sig3_vz, chi3_az => sig3_az,
      chi4_px => sig4_px, chi4_py => sig4_py, chi4_v => sig4_v, chi4_theta => sig4_th, chi4_omega => sig4_om, chi4_a => sig4_ac, chi4_z => sig4_z, chi4_vz => sig4_vz, chi4_az => sig4_az,
      chi5_px => sig5_px, chi5_py => sig5_py, chi5_v => sig5_v, chi5_theta => sig5_th, chi5_omega => sig5_om, chi5_a => sig5_ac, chi5_z => sig5_z, chi5_vz => sig5_vz, chi5_az => sig5_az,
      chi6_px => sig6_px, chi6_py => sig6_py, chi6_v => sig6_v, chi6_theta => sig6_th, chi6_omega => sig6_om, chi6_a => sig6_ac, chi6_z => sig6_z, chi6_vz => sig6_vz, chi6_az => sig6_az,
      chi7_px => sig7_px, chi7_py => sig7_py, chi7_v => sig7_v, chi7_theta => sig7_th, chi7_omega => sig7_om, chi7_a => sig7_ac, chi7_z => sig7_z, chi7_vz => sig7_vz, chi7_az => sig7_az,
      chi8_px => sig8_px, chi8_py => sig8_py, chi8_v => sig8_v, chi8_theta => sig8_th, chi8_omega => sig8_om, chi8_a => sig8_ac, chi8_z => sig8_z, chi8_vz => sig8_vz, chi8_az => sig8_az,
      chi9_px => sig9_px, chi9_py => sig9_py, chi9_v => sig9_v, chi9_theta => sig9_th, chi9_omega => sig9_om, chi9_a => sig9_ac, chi9_z => sig9_z, chi9_vz => sig9_vz, chi9_az => sig9_az,
      chi10_px => sig10_px, chi10_py => sig10_py, chi10_v => sig10_v, chi10_theta => sig10_th, chi10_omega => sig10_om, chi10_a => sig10_ac, chi10_z => sig10_z, chi10_vz => sig10_vz, chi10_az => sig10_az,
      chi11_px => sig11_px, chi11_py => sig11_py, chi11_v => sig11_v, chi11_theta => sig11_th, chi11_omega => sig11_om, chi11_a => sig11_ac, chi11_z => sig11_z, chi11_vz => sig11_vz, chi11_az => sig11_az,
      chi12_px => sig12_px, chi12_py => sig12_py, chi12_v => sig12_v, chi12_theta => sig12_th, chi12_omega => sig12_om, chi12_a => sig12_ac, chi12_z => sig12_z, chi12_vz => sig12_vz, chi12_az => sig12_az,
      chi13_px => sig13_px, chi13_py => sig13_py, chi13_v => sig13_v, chi13_theta => sig13_th, chi13_omega => sig13_om, chi13_a => sig13_ac, chi13_z => sig13_z, chi13_vz => sig13_vz, chi13_az => sig13_az,
      chi14_px => sig14_px, chi14_py => sig14_py, chi14_v => sig14_v, chi14_theta => sig14_th, chi14_omega => sig14_om, chi14_a => sig14_ac, chi14_z => sig14_z, chi14_vz => sig14_vz, chi14_az => sig14_az,
      chi15_px => sig15_px, chi15_py => sig15_py, chi15_v => sig15_v, chi15_theta => sig15_th, chi15_omega => sig15_om, chi15_a => sig15_ac, chi15_z => sig15_z, chi15_vz => sig15_vz, chi15_az => sig15_az,
      chi16_px => sig16_px, chi16_py => sig16_py, chi16_v => sig16_v, chi16_theta => sig16_th, chi16_omega => sig16_om, chi16_a => sig16_ac, chi16_z => sig16_z, chi16_vz => sig16_vz, chi16_az => sig16_az,
      chi17_px => sig17_px, chi17_py => sig17_py, chi17_v => sig17_v, chi17_theta => sig17_th, chi17_omega => sig17_om, chi17_a => sig17_ac, chi17_z => sig17_z, chi17_vz => sig17_vz, chi17_az => sig17_az,
      chi18_px => sig18_px, chi18_py => sig18_py, chi18_v => sig18_v, chi18_theta => sig18_th, chi18_omega => sig18_om, chi18_a => sig18_ac, chi18_z => sig18_z, chi18_vz => sig18_vz, chi18_az => sig18_az,
      done => sigma_done
    );

  prop_inst : predicti_ct_polar
    port map (
      clk => clk, rst => reset, start => prop_start,
      chi0_px_in => sig0_px, chi0_py_in => sig0_py, chi0_v_in => sig0_v, chi0_theta_in => sig0_th, chi0_omega_in => sig0_om, chi0_a_in => sig0_ac, chi0_z_in => sig0_z, chi0_vz_in => sig0_vz, chi0_az_in => sig0_az,
      chi1_px_in => sig1_px, chi1_py_in => sig1_py, chi1_v_in => sig1_v, chi1_theta_in => sig1_th, chi1_omega_in => sig1_om, chi1_a_in => sig1_ac, chi1_z_in => sig1_z, chi1_vz_in => sig1_vz, chi1_az_in => sig1_az,
      chi2_px_in => sig2_px, chi2_py_in => sig2_py, chi2_v_in => sig2_v, chi2_theta_in => sig2_th, chi2_omega_in => sig2_om, chi2_a_in => sig2_ac, chi2_z_in => sig2_z, chi2_vz_in => sig2_vz, chi2_az_in => sig2_az,
      chi3_px_in => sig3_px, chi3_py_in => sig3_py, chi3_v_in => sig3_v, chi3_theta_in => sig3_th, chi3_omega_in => sig3_om, chi3_a_in => sig3_ac, chi3_z_in => sig3_z, chi3_vz_in => sig3_vz, chi3_az_in => sig3_az,
      chi4_px_in => sig4_px, chi4_py_in => sig4_py, chi4_v_in => sig4_v, chi4_theta_in => sig4_th, chi4_omega_in => sig4_om, chi4_a_in => sig4_ac, chi4_z_in => sig4_z, chi4_vz_in => sig4_vz, chi4_az_in => sig4_az,
      chi5_px_in => sig5_px, chi5_py_in => sig5_py, chi5_v_in => sig5_v, chi5_theta_in => sig5_th, chi5_omega_in => sig5_om, chi5_a_in => sig5_ac, chi5_z_in => sig5_z, chi5_vz_in => sig5_vz, chi5_az_in => sig5_az,
      chi6_px_in => sig6_px, chi6_py_in => sig6_py, chi6_v_in => sig6_v, chi6_theta_in => sig6_th, chi6_omega_in => sig6_om, chi6_a_in => sig6_ac, chi6_z_in => sig6_z, chi6_vz_in => sig6_vz, chi6_az_in => sig6_az,
      chi7_px_in => sig7_px, chi7_py_in => sig7_py, chi7_v_in => sig7_v, chi7_theta_in => sig7_th, chi7_omega_in => sig7_om, chi7_a_in => sig7_ac, chi7_z_in => sig7_z, chi7_vz_in => sig7_vz, chi7_az_in => sig7_az,
      chi8_px_in => sig8_px, chi8_py_in => sig8_py, chi8_v_in => sig8_v, chi8_theta_in => sig8_th, chi8_omega_in => sig8_om, chi8_a_in => sig8_ac, chi8_z_in => sig8_z, chi8_vz_in => sig8_vz, chi8_az_in => sig8_az,
      chi9_px_in => sig9_px, chi9_py_in => sig9_py, chi9_v_in => sig9_v, chi9_theta_in => sig9_th, chi9_omega_in => sig9_om, chi9_a_in => sig9_ac, chi9_z_in => sig9_z, chi9_vz_in => sig9_vz, chi9_az_in => sig9_az,
      chi10_px_in => sig10_px, chi10_py_in => sig10_py, chi10_v_in => sig10_v, chi10_theta_in => sig10_th, chi10_omega_in => sig10_om, chi10_a_in => sig10_ac, chi10_z_in => sig10_z, chi10_vz_in => sig10_vz, chi10_az_in => sig10_az,
      chi11_px_in => sig11_px, chi11_py_in => sig11_py, chi11_v_in => sig11_v, chi11_theta_in => sig11_th, chi11_omega_in => sig11_om, chi11_a_in => sig11_ac, chi11_z_in => sig11_z, chi11_vz_in => sig11_vz, chi11_az_in => sig11_az,
      chi12_px_in => sig12_px, chi12_py_in => sig12_py, chi12_v_in => sig12_v, chi12_theta_in => sig12_th, chi12_omega_in => sig12_om, chi12_a_in => sig12_ac, chi12_z_in => sig12_z, chi12_vz_in => sig12_vz, chi12_az_in => sig12_az,
      chi13_px_in => sig13_px, chi13_py_in => sig13_py, chi13_v_in => sig13_v, chi13_theta_in => sig13_th, chi13_omega_in => sig13_om, chi13_a_in => sig13_ac, chi13_z_in => sig13_z, chi13_vz_in => sig13_vz, chi13_az_in => sig13_az,
      chi14_px_in => sig14_px, chi14_py_in => sig14_py, chi14_v_in => sig14_v, chi14_theta_in => sig14_th, chi14_omega_in => sig14_om, chi14_a_in => sig14_ac, chi14_z_in => sig14_z, chi14_vz_in => sig14_vz, chi14_az_in => sig14_az,
      chi15_px_in => sig15_px, chi15_py_in => sig15_py, chi15_v_in => sig15_v, chi15_theta_in => sig15_th, chi15_omega_in => sig15_om, chi15_a_in => sig15_ac, chi15_z_in => sig15_z, chi15_vz_in => sig15_vz, chi15_az_in => sig15_az,
      chi16_px_in => sig16_px, chi16_py_in => sig16_py, chi16_v_in => sig16_v, chi16_theta_in => sig16_th, chi16_omega_in => sig16_om, chi16_a_in => sig16_ac, chi16_z_in => sig16_z, chi16_vz_in => sig16_vz, chi16_az_in => sig16_az,
      chi17_px_in => sig17_px, chi17_py_in => sig17_py, chi17_v_in => sig17_v, chi17_theta_in => sig17_th, chi17_omega_in => sig17_om, chi17_a_in => sig17_ac, chi17_z_in => sig17_z, chi17_vz_in => sig17_vz, chi17_az_in => sig17_az,
      chi18_px_in => sig18_px, chi18_py_in => sig18_py, chi18_v_in => sig18_v, chi18_theta_in => sig18_th, chi18_omega_in => sig18_om, chi18_a_in => sig18_ac, chi18_z_in => sig18_z, chi18_vz_in => sig18_vz, chi18_az_in => sig18_az,
      chi0_px_out => pr0_px, chi0_py_out => pr0_py, chi0_v_out => pr0_v, chi0_theta_out => pr0_th, chi0_omega_out => pr0_om, chi0_a_out => pr0_ac, chi0_z_out => pr0_z, chi0_vz_out => pr0_vz, chi0_az_out => pr0_az,
      chi1_px_out => pr1_px, chi1_py_out => pr1_py, chi1_v_out => pr1_v, chi1_theta_out => pr1_th, chi1_omega_out => pr1_om, chi1_a_out => pr1_ac, chi1_z_out => pr1_z, chi1_vz_out => pr1_vz, chi1_az_out => pr1_az,
      chi2_px_out => pr2_px, chi2_py_out => pr2_py, chi2_v_out => pr2_v, chi2_theta_out => pr2_th, chi2_omega_out => pr2_om, chi2_a_out => pr2_ac, chi2_z_out => pr2_z, chi2_vz_out => pr2_vz, chi2_az_out => pr2_az,
      chi3_px_out => pr3_px, chi3_py_out => pr3_py, chi3_v_out => pr3_v, chi3_theta_out => pr3_th, chi3_omega_out => pr3_om, chi3_a_out => pr3_ac, chi3_z_out => pr3_z, chi3_vz_out => pr3_vz, chi3_az_out => pr3_az,
      chi4_px_out => pr4_px, chi4_py_out => pr4_py, chi4_v_out => pr4_v, chi4_theta_out => pr4_th, chi4_omega_out => pr4_om, chi4_a_out => pr4_ac, chi4_z_out => pr4_z, chi4_vz_out => pr4_vz, chi4_az_out => pr4_az,
      chi5_px_out => pr5_px, chi5_py_out => pr5_py, chi5_v_out => pr5_v, chi5_theta_out => pr5_th, chi5_omega_out => pr5_om, chi5_a_out => pr5_ac, chi5_z_out => pr5_z, chi5_vz_out => pr5_vz, chi5_az_out => pr5_az,
      chi6_px_out => pr6_px, chi6_py_out => pr6_py, chi6_v_out => pr6_v, chi6_theta_out => pr6_th, chi6_omega_out => pr6_om, chi6_a_out => pr6_ac, chi6_z_out => pr6_z, chi6_vz_out => pr6_vz, chi6_az_out => pr6_az,
      chi7_px_out => pr7_px, chi7_py_out => pr7_py, chi7_v_out => pr7_v, chi7_theta_out => pr7_th, chi7_omega_out => pr7_om, chi7_a_out => pr7_ac, chi7_z_out => pr7_z, chi7_vz_out => pr7_vz, chi7_az_out => pr7_az,
      chi8_px_out => pr8_px, chi8_py_out => pr8_py, chi8_v_out => pr8_v, chi8_theta_out => pr8_th, chi8_omega_out => pr8_om, chi8_a_out => pr8_ac, chi8_z_out => pr8_z, chi8_vz_out => pr8_vz, chi8_az_out => pr8_az,
      chi9_px_out => pr9_px, chi9_py_out => pr9_py, chi9_v_out => pr9_v, chi9_theta_out => pr9_th, chi9_omega_out => pr9_om, chi9_a_out => pr9_ac, chi9_z_out => pr9_z, chi9_vz_out => pr9_vz, chi9_az_out => pr9_az,
      chi10_px_out => pr10_px, chi10_py_out => pr10_py, chi10_v_out => pr10_v, chi10_theta_out => pr10_th, chi10_omega_out => pr10_om, chi10_a_out => pr10_ac, chi10_z_out => pr10_z, chi10_vz_out => pr10_vz, chi10_az_out => pr10_az,
      chi11_px_out => pr11_px, chi11_py_out => pr11_py, chi11_v_out => pr11_v, chi11_theta_out => pr11_th, chi11_omega_out => pr11_om, chi11_a_out => pr11_ac, chi11_z_out => pr11_z, chi11_vz_out => pr11_vz, chi11_az_out => pr11_az,
      chi12_px_out => pr12_px, chi12_py_out => pr12_py, chi12_v_out => pr12_v, chi12_theta_out => pr12_th, chi12_omega_out => pr12_om, chi12_a_out => pr12_ac, chi12_z_out => pr12_z, chi12_vz_out => pr12_vz, chi12_az_out => pr12_az,
      chi13_px_out => pr13_px, chi13_py_out => pr13_py, chi13_v_out => pr13_v, chi13_theta_out => pr13_th, chi13_omega_out => pr13_om, chi13_a_out => pr13_ac, chi13_z_out => pr13_z, chi13_vz_out => pr13_vz, chi13_az_out => pr13_az,
      chi14_px_out => pr14_px, chi14_py_out => pr14_py, chi14_v_out => pr14_v, chi14_theta_out => pr14_th, chi14_omega_out => pr14_om, chi14_a_out => pr14_ac, chi14_z_out => pr14_z, chi14_vz_out => pr14_vz, chi14_az_out => pr14_az,
      chi15_px_out => pr15_px, chi15_py_out => pr15_py, chi15_v_out => pr15_v, chi15_theta_out => pr15_th, chi15_omega_out => pr15_om, chi15_a_out => pr15_ac, chi15_z_out => pr15_z, chi15_vz_out => pr15_vz, chi15_az_out => pr15_az,
      chi16_px_out => pr16_px, chi16_py_out => pr16_py, chi16_v_out => pr16_v, chi16_theta_out => pr16_th, chi16_omega_out => pr16_om, chi16_a_out => pr16_ac, chi16_z_out => pr16_z, chi16_vz_out => pr16_vz, chi16_az_out => pr16_az,
      chi17_px_out => pr17_px, chi17_py_out => pr17_py, chi17_v_out => pr17_v, chi17_theta_out => pr17_th, chi17_omega_out => pr17_om, chi17_a_out => pr17_ac, chi17_z_out => pr17_z, chi17_vz_out => pr17_vz, chi17_az_out => pr17_az,
      chi18_px_out => pr18_px, chi18_py_out => pr18_py, chi18_v_out => pr18_v, chi18_theta_out => pr18_th, chi18_omega_out => pr18_om, chi18_a_out => pr18_ac, chi18_z_out => pr18_z, chi18_vz_out => pr18_vz, chi18_az_out => pr18_az,
      done => prop_done
    );

  mean_inst : predicted_mean_9d
    port map (
      clk => clk, rst => reset, start => mean_start,
      chi0_s1 => pr0_px, chi0_s2 => pr0_py, chi0_s3 => pr0_v, chi0_s4 => pr0_th, chi0_s5 => pr0_om, chi0_s6 => pr0_ac, chi0_s7 => pr0_z, chi0_s8 => pr0_vz, chi0_s9 => pr0_az,
      chi1_s1 => pr1_px, chi1_s2 => pr1_py, chi1_s3 => pr1_v, chi1_s4 => pr1_th, chi1_s5 => pr1_om, chi1_s6 => pr1_ac, chi1_s7 => pr1_z, chi1_s8 => pr1_vz, chi1_s9 => pr1_az,
      chi2_s1 => pr2_px, chi2_s2 => pr2_py, chi2_s3 => pr2_v, chi2_s4 => pr2_th, chi2_s5 => pr2_om, chi2_s6 => pr2_ac, chi2_s7 => pr2_z, chi2_s8 => pr2_vz, chi2_s9 => pr2_az,
      chi3_s1 => pr3_px, chi3_s2 => pr3_py, chi3_s3 => pr3_v, chi3_s4 => pr3_th, chi3_s5 => pr3_om, chi3_s6 => pr3_ac, chi3_s7 => pr3_z, chi3_s8 => pr3_vz, chi3_s9 => pr3_az,
      chi4_s1 => pr4_px, chi4_s2 => pr4_py, chi4_s3 => pr4_v, chi4_s4 => pr4_th, chi4_s5 => pr4_om, chi4_s6 => pr4_ac, chi4_s7 => pr4_z, chi4_s8 => pr4_vz, chi4_s9 => pr4_az,
      chi5_s1 => pr5_px, chi5_s2 => pr5_py, chi5_s3 => pr5_v, chi5_s4 => pr5_th, chi5_s5 => pr5_om, chi5_s6 => pr5_ac, chi5_s7 => pr5_z, chi5_s8 => pr5_vz, chi5_s9 => pr5_az,
      chi6_s1 => pr6_px, chi6_s2 => pr6_py, chi6_s3 => pr6_v, chi6_s4 => pr6_th, chi6_s5 => pr6_om, chi6_s6 => pr6_ac, chi6_s7 => pr6_z, chi6_s8 => pr6_vz, chi6_s9 => pr6_az,
      chi7_s1 => pr7_px, chi7_s2 => pr7_py, chi7_s3 => pr7_v, chi7_s4 => pr7_th, chi7_s5 => pr7_om, chi7_s6 => pr7_ac, chi7_s7 => pr7_z, chi7_s8 => pr7_vz, chi7_s9 => pr7_az,
      chi8_s1 => pr8_px, chi8_s2 => pr8_py, chi8_s3 => pr8_v, chi8_s4 => pr8_th, chi8_s5 => pr8_om, chi8_s6 => pr8_ac, chi8_s7 => pr8_z, chi8_s8 => pr8_vz, chi8_s9 => pr8_az,
      chi9_s1 => pr9_px, chi9_s2 => pr9_py, chi9_s3 => pr9_v, chi9_s4 => pr9_th, chi9_s5 => pr9_om, chi9_s6 => pr9_ac, chi9_s7 => pr9_z, chi9_s8 => pr9_vz, chi9_s9 => pr9_az,
      chi10_s1 => pr10_px, chi10_s2 => pr10_py, chi10_s3 => pr10_v, chi10_s4 => pr10_th, chi10_s5 => pr10_om, chi10_s6 => pr10_ac, chi10_s7 => pr10_z, chi10_s8 => pr10_vz, chi10_s9 => pr10_az,
      chi11_s1 => pr11_px, chi11_s2 => pr11_py, chi11_s3 => pr11_v, chi11_s4 => pr11_th, chi11_s5 => pr11_om, chi11_s6 => pr11_ac, chi11_s7 => pr11_z, chi11_s8 => pr11_vz, chi11_s9 => pr11_az,
      chi12_s1 => pr12_px, chi12_s2 => pr12_py, chi12_s3 => pr12_v, chi12_s4 => pr12_th, chi12_s5 => pr12_om, chi12_s6 => pr12_ac, chi12_s7 => pr12_z, chi12_s8 => pr12_vz, chi12_s9 => pr12_az,
      chi13_s1 => pr13_px, chi13_s2 => pr13_py, chi13_s3 => pr13_v, chi13_s4 => pr13_th, chi13_s5 => pr13_om, chi13_s6 => pr13_ac, chi13_s7 => pr13_z, chi13_s8 => pr13_vz, chi13_s9 => pr13_az,
      chi14_s1 => pr14_px, chi14_s2 => pr14_py, chi14_s3 => pr14_v, chi14_s4 => pr14_th, chi14_s5 => pr14_om, chi14_s6 => pr14_ac, chi14_s7 => pr14_z, chi14_s8 => pr14_vz, chi14_s9 => pr14_az,
      chi15_s1 => pr15_px, chi15_s2 => pr15_py, chi15_s3 => pr15_v, chi15_s4 => pr15_th, chi15_s5 => pr15_om, chi15_s6 => pr15_ac, chi15_s7 => pr15_z, chi15_s8 => pr15_vz, chi15_s9 => pr15_az,
      chi16_s1 => pr16_px, chi16_s2 => pr16_py, chi16_s3 => pr16_v, chi16_s4 => pr16_th, chi16_s5 => pr16_om, chi16_s6 => pr16_ac, chi16_s7 => pr16_z, chi16_s8 => pr16_vz, chi16_s9 => pr16_az,
      chi17_s1 => pr17_px, chi17_s2 => pr17_py, chi17_s3 => pr17_v, chi17_s4 => pr17_th, chi17_s5 => pr17_om, chi17_s6 => pr17_ac, chi17_s7 => pr17_z, chi17_s8 => pr17_vz, chi17_s9 => pr17_az,
      chi18_s1 => pr18_px, chi18_s2 => pr18_py, chi18_s3 => pr18_v, chi18_s4 => pr18_th, chi18_s5 => pr18_om, chi18_s6 => pr18_ac, chi18_s7 => pr18_z, chi18_s8 => pr18_vz, chi18_s9 => pr18_az,
      s1_mean => xp1, s2_mean => xp2, s3_mean => xp3, s4_mean => xp4, s5_mean => xp5,
      s6_mean => xp6, s7_mean => xp7, s8_mean => xp8, s9_mean => xp9,
      done => mean_done
    );

  pcov_inst : predicted_covariance_9d
    port map (
      clk => clk, start => pcov_start,
      s1_mean => xp1, s2_mean => xp2, s3_mean => xp3, s4_mean => xp4, s5_mean => xp5,
      s6_mean => xp6, s7_mean => xp7, s8_mean => xp8, s9_mean => xp9,
      chi0_s1 => pr0_px, chi0_s2 => pr0_py, chi0_s3 => pr0_v, chi0_s4 => pr0_th, chi0_s5 => pr0_om, chi0_s6 => pr0_ac, chi0_s7 => pr0_z, chi0_s8 => pr0_vz, chi0_s9 => pr0_az,
      chi1_s1 => pr1_px, chi1_s2 => pr1_py, chi1_s3 => pr1_v, chi1_s4 => pr1_th, chi1_s5 => pr1_om, chi1_s6 => pr1_ac, chi1_s7 => pr1_z, chi1_s8 => pr1_vz, chi1_s9 => pr1_az,
      chi2_s1 => pr2_px, chi2_s2 => pr2_py, chi2_s3 => pr2_v, chi2_s4 => pr2_th, chi2_s5 => pr2_om, chi2_s6 => pr2_ac, chi2_s7 => pr2_z, chi2_s8 => pr2_vz, chi2_s9 => pr2_az,
      chi3_s1 => pr3_px, chi3_s2 => pr3_py, chi3_s3 => pr3_v, chi3_s4 => pr3_th, chi3_s5 => pr3_om, chi3_s6 => pr3_ac, chi3_s7 => pr3_z, chi3_s8 => pr3_vz, chi3_s9 => pr3_az,
      chi4_s1 => pr4_px, chi4_s2 => pr4_py, chi4_s3 => pr4_v, chi4_s4 => pr4_th, chi4_s5 => pr4_om, chi4_s6 => pr4_ac, chi4_s7 => pr4_z, chi4_s8 => pr4_vz, chi4_s9 => pr4_az,
      chi5_s1 => pr5_px, chi5_s2 => pr5_py, chi5_s3 => pr5_v, chi5_s4 => pr5_th, chi5_s5 => pr5_om, chi5_s6 => pr5_ac, chi5_s7 => pr5_z, chi5_s8 => pr5_vz, chi5_s9 => pr5_az,
      chi6_s1 => pr6_px, chi6_s2 => pr6_py, chi6_s3 => pr6_v, chi6_s4 => pr6_th, chi6_s5 => pr6_om, chi6_s6 => pr6_ac, chi6_s7 => pr6_z, chi6_s8 => pr6_vz, chi6_s9 => pr6_az,
      chi7_s1 => pr7_px, chi7_s2 => pr7_py, chi7_s3 => pr7_v, chi7_s4 => pr7_th, chi7_s5 => pr7_om, chi7_s6 => pr7_ac, chi7_s7 => pr7_z, chi7_s8 => pr7_vz, chi7_s9 => pr7_az,
      chi8_s1 => pr8_px, chi8_s2 => pr8_py, chi8_s3 => pr8_v, chi8_s4 => pr8_th, chi8_s5 => pr8_om, chi8_s6 => pr8_ac, chi8_s7 => pr8_z, chi8_s8 => pr8_vz, chi8_s9 => pr8_az,
      chi9_s1 => pr9_px, chi9_s2 => pr9_py, chi9_s3 => pr9_v, chi9_s4 => pr9_th, chi9_s5 => pr9_om, chi9_s6 => pr9_ac, chi9_s7 => pr9_z, chi9_s8 => pr9_vz, chi9_s9 => pr9_az,
      chi10_s1 => pr10_px, chi10_s2 => pr10_py, chi10_s3 => pr10_v, chi10_s4 => pr10_th, chi10_s5 => pr10_om, chi10_s6 => pr10_ac, chi10_s7 => pr10_z, chi10_s8 => pr10_vz, chi10_s9 => pr10_az,
      chi11_s1 => pr11_px, chi11_s2 => pr11_py, chi11_s3 => pr11_v, chi11_s4 => pr11_th, chi11_s5 => pr11_om, chi11_s6 => pr11_ac, chi11_s7 => pr11_z, chi11_s8 => pr11_vz, chi11_s9 => pr11_az,
      chi12_s1 => pr12_px, chi12_s2 => pr12_py, chi12_s3 => pr12_v, chi12_s4 => pr12_th, chi12_s5 => pr12_om, chi12_s6 => pr12_ac, chi12_s7 => pr12_z, chi12_s8 => pr12_vz, chi12_s9 => pr12_az,
      chi13_s1 => pr13_px, chi13_s2 => pr13_py, chi13_s3 => pr13_v, chi13_s4 => pr13_th, chi13_s5 => pr13_om, chi13_s6 => pr13_ac, chi13_s7 => pr13_z, chi13_s8 => pr13_vz, chi13_s9 => pr13_az,
      chi14_s1 => pr14_px, chi14_s2 => pr14_py, chi14_s3 => pr14_v, chi14_s4 => pr14_th, chi14_s5 => pr14_om, chi14_s6 => pr14_ac, chi14_s7 => pr14_z, chi14_s8 => pr14_vz, chi14_s9 => pr14_az,
      chi15_s1 => pr15_px, chi15_s2 => pr15_py, chi15_s3 => pr15_v, chi15_s4 => pr15_th, chi15_s5 => pr15_om, chi15_s6 => pr15_ac, chi15_s7 => pr15_z, chi15_s8 => pr15_vz, chi15_s9 => pr15_az,
      chi16_s1 => pr16_px, chi16_s2 => pr16_py, chi16_s3 => pr16_v, chi16_s4 => pr16_th, chi16_s5 => pr16_om, chi16_s6 => pr16_ac, chi16_s7 => pr16_z, chi16_s8 => pr16_vz, chi16_s9 => pr16_az,
      chi17_s1 => pr17_px, chi17_s2 => pr17_py, chi17_s3 => pr17_v, chi17_s4 => pr17_th, chi17_s5 => pr17_om, chi17_s6 => pr17_ac, chi17_s7 => pr17_z, chi17_s8 => pr17_vz, chi17_s9 => pr17_az,
      chi18_s1 => pr18_px, chi18_s2 => pr18_py, chi18_s3 => pr18_v, chi18_s4 => pr18_th, chi18_s5 => pr18_om, chi18_s6 => pr18_ac, chi18_s7 => pr18_z, chi18_s8 => pr18_vz, chi18_s9 => pr18_az,
      p11_out => pp11_s, p12_out => pp12_s, p13_out => pp13_s, p14_out => pp14_s, p15_out => pp15_s, p16_out => pp16_s, p17_out => pp17_s, p18_out => pp18_s, p19_out => pp19_s,
      p22_out => pp22_s, p23_out => pp23_s, p24_out => pp24_s, p25_out => pp25_s, p26_out => pp26_s, p27_out => pp27_s, p28_out => pp28_s, p29_out => pp29_s,
      p33_out => pp33_s, p34_out => pp34_s, p35_out => pp35_s, p36_out => pp36_s, p37_out => pp37_s, p38_out => pp38_s, p39_out => pp39_s,
      p44_out => pp44_s, p45_out => pp45_s, p46_out => pp46_s, p47_out => pp47_s, p48_out => pp48_s, p49_out => pp49_s,
      p55_out => pp55_s, p56_out => pp56_s, p57_out => pp57_s, p58_out => pp58_s, p59_out => pp59_s,
      p66_out => pp66_s, p67_out => pp67_s, p68_out => pp68_s, p69_out => pp69_s,
      p77_out => pp77_s, p78_out => pp78_s, p79_out => pp79_s,
      p88_out => pp88_s, p89_out => pp89_s,
      p99_out => pp99_s,
      done => pcov_done
    );

  pn_inst : process_noise_ct_polar
    port map (
      clk => clk, rst => reset, start => pn_start,
      p11_in => pp11_s, p22_in => pp22_s, p33_in => pp33_s, p44_in => pp44_s, p55_in => pp55_s,
      p66_in => pp66_s, p77_in => pp77_s, p88_in => pp88_s, p99_in => pp99_s,
      p11_out => pn11, p22_out => pn22, p33_out => pn33, p44_out => pn44, p55_out => pn55,
      p66_out => pn66, p77_out => pn77, p88_out => pn88, p99_out => pn99,
      done => pn_done
    );

  ic_inst : innovation_covariance_9d
    port map (
      clk => clk, start => ic_start,
      z_x_mean => xp1, z_y_mean => xp2, z_z_mean => xp7,
      chi0_z_x => pr0_px, chi0_z_y => pr0_py, chi0_z_z => pr0_z,
      chi1_z_x => pr1_px, chi1_z_y => pr1_py, chi1_z_z => pr1_z,
      chi2_z_x => pr2_px, chi2_z_y => pr2_py, chi2_z_z => pr2_z,
      chi3_z_x => pr3_px, chi3_z_y => pr3_py, chi3_z_z => pr3_z,
      chi4_z_x => pr4_px, chi4_z_y => pr4_py, chi4_z_z => pr4_z,
      chi5_z_x => pr5_px, chi5_z_y => pr5_py, chi5_z_z => pr5_z,
      chi6_z_x => pr6_px, chi6_z_y => pr6_py, chi6_z_z => pr6_z,
      chi7_z_x => pr7_px, chi7_z_y => pr7_py, chi7_z_z => pr7_z,
      chi8_z_x => pr8_px, chi8_z_y => pr8_py, chi8_z_z => pr8_z,
      chi9_z_x => pr9_px, chi9_z_y => pr9_py, chi9_z_z => pr9_z,
      chi10_z_x => pr10_px, chi10_z_y => pr10_py, chi10_z_z => pr10_z,
      chi11_z_x => pr11_px, chi11_z_y => pr11_py, chi11_z_z => pr11_z,
      chi12_z_x => pr12_px, chi12_z_y => pr12_py, chi12_z_z => pr12_z,
      chi13_z_x => pr13_px, chi13_z_y => pr13_py, chi13_z_z => pr13_z,
      chi14_z_x => pr14_px, chi14_z_y => pr14_py, chi14_z_z => pr14_z,
      chi15_z_x => pr15_px, chi15_z_y => pr15_py, chi15_z_z => pr15_z,
      chi16_z_x => pr16_px, chi16_z_y => pr16_py, chi16_z_z => pr16_z,
      chi17_z_x => pr17_px, chi17_z_y => pr17_py, chi17_z_z => pr17_z,
      chi18_z_x => pr18_px, chi18_z_y => pr18_py, chi18_z_z => pr18_z,
      s11 => ss11, s12 => ss12, s22 => ss22, s13 => ss13, s23 => ss23, s33 => ss33,
      done => ic_done
    );

  inn_inst : innovation_3d
    port map (
      clk => clk, start => inn_start,
      z_x_meas => z_x_meas, z_y_meas => z_y_meas, z_z_meas => z_z_meas,
      z_x_pred => xp1, z_y_pred => xp2, z_z_pred => xp7,
      nu_x => nu1, nu_y => nu2, nu_z => nu3,
      done => inn_done
    );

  cc_inst : cross_covariance_9d
    port map (
      clk => clk, rst => reset, start => cc_start,
      s1_mean => xp1, s2_mean => xp2, s3_mean => xp3, s4_mean => xp4, s5_mean => xp5,
      s6_mean => xp6, s7_mean => xp7, s8_mean => xp8, s9_mean => xp9,
      z1_mean => xp1, z2_mean => xp2, z3_mean => xp7,
      chi0_s1 => pr0_px, chi0_s2 => pr0_py, chi0_s3 => pr0_v, chi0_s4 => pr0_th, chi0_s5 => pr0_om, chi0_s6 => pr0_ac, chi0_s7 => pr0_z, chi0_s8 => pr0_vz, chi0_s9 => pr0_az,
      chi1_s1 => pr1_px, chi1_s2 => pr1_py, chi1_s3 => pr1_v, chi1_s4 => pr1_th, chi1_s5 => pr1_om, chi1_s6 => pr1_ac, chi1_s7 => pr1_z, chi1_s8 => pr1_vz, chi1_s9 => pr1_az,
      chi2_s1 => pr2_px, chi2_s2 => pr2_py, chi2_s3 => pr2_v, chi2_s4 => pr2_th, chi2_s5 => pr2_om, chi2_s6 => pr2_ac, chi2_s7 => pr2_z, chi2_s8 => pr2_vz, chi2_s9 => pr2_az,
      chi3_s1 => pr3_px, chi3_s2 => pr3_py, chi3_s3 => pr3_v, chi3_s4 => pr3_th, chi3_s5 => pr3_om, chi3_s6 => pr3_ac, chi3_s7 => pr3_z, chi3_s8 => pr3_vz, chi3_s9 => pr3_az,
      chi4_s1 => pr4_px, chi4_s2 => pr4_py, chi4_s3 => pr4_v, chi4_s4 => pr4_th, chi4_s5 => pr4_om, chi4_s6 => pr4_ac, chi4_s7 => pr4_z, chi4_s8 => pr4_vz, chi4_s9 => pr4_az,
      chi5_s1 => pr5_px, chi5_s2 => pr5_py, chi5_s3 => pr5_v, chi5_s4 => pr5_th, chi5_s5 => pr5_om, chi5_s6 => pr5_ac, chi5_s7 => pr5_z, chi5_s8 => pr5_vz, chi5_s9 => pr5_az,
      chi6_s1 => pr6_px, chi6_s2 => pr6_py, chi6_s3 => pr6_v, chi6_s4 => pr6_th, chi6_s5 => pr6_om, chi6_s6 => pr6_ac, chi6_s7 => pr6_z, chi6_s8 => pr6_vz, chi6_s9 => pr6_az,
      chi7_s1 => pr7_px, chi7_s2 => pr7_py, chi7_s3 => pr7_v, chi7_s4 => pr7_th, chi7_s5 => pr7_om, chi7_s6 => pr7_ac, chi7_s7 => pr7_z, chi7_s8 => pr7_vz, chi7_s9 => pr7_az,
      chi8_s1 => pr8_px, chi8_s2 => pr8_py, chi8_s3 => pr8_v, chi8_s4 => pr8_th, chi8_s5 => pr8_om, chi8_s6 => pr8_ac, chi8_s7 => pr8_z, chi8_s8 => pr8_vz, chi8_s9 => pr8_az,
      chi9_s1 => pr9_px, chi9_s2 => pr9_py, chi9_s3 => pr9_v, chi9_s4 => pr9_th, chi9_s5 => pr9_om, chi9_s6 => pr9_ac, chi9_s7 => pr9_z, chi9_s8 => pr9_vz, chi9_s9 => pr9_az,
      chi10_s1 => pr10_px, chi10_s2 => pr10_py, chi10_s3 => pr10_v, chi10_s4 => pr10_th, chi10_s5 => pr10_om, chi10_s6 => pr10_ac, chi10_s7 => pr10_z, chi10_s8 => pr10_vz, chi10_s9 => pr10_az,
      chi11_s1 => pr11_px, chi11_s2 => pr11_py, chi11_s3 => pr11_v, chi11_s4 => pr11_th, chi11_s5 => pr11_om, chi11_s6 => pr11_ac, chi11_s7 => pr11_z, chi11_s8 => pr11_vz, chi11_s9 => pr11_az,
      chi12_s1 => pr12_px, chi12_s2 => pr12_py, chi12_s3 => pr12_v, chi12_s4 => pr12_th, chi12_s5 => pr12_om, chi12_s6 => pr12_ac, chi12_s7 => pr12_z, chi12_s8 => pr12_vz, chi12_s9 => pr12_az,
      chi13_s1 => pr13_px, chi13_s2 => pr13_py, chi13_s3 => pr13_v, chi13_s4 => pr13_th, chi13_s5 => pr13_om, chi13_s6 => pr13_ac, chi13_s7 => pr13_z, chi13_s8 => pr13_vz, chi13_s9 => pr13_az,
      chi14_s1 => pr14_px, chi14_s2 => pr14_py, chi14_s3 => pr14_v, chi14_s4 => pr14_th, chi14_s5 => pr14_om, chi14_s6 => pr14_ac, chi14_s7 => pr14_z, chi14_s8 => pr14_vz, chi14_s9 => pr14_az,
      chi15_s1 => pr15_px, chi15_s2 => pr15_py, chi15_s3 => pr15_v, chi15_s4 => pr15_th, chi15_s5 => pr15_om, chi15_s6 => pr15_ac, chi15_s7 => pr15_z, chi15_s8 => pr15_vz, chi15_s9 => pr15_az,
      chi16_s1 => pr16_px, chi16_s2 => pr16_py, chi16_s3 => pr16_v, chi16_s4 => pr16_th, chi16_s5 => pr16_om, chi16_s6 => pr16_ac, chi16_s7 => pr16_z, chi16_s8 => pr16_vz, chi16_s9 => pr16_az,
      chi17_s1 => pr17_px, chi17_s2 => pr17_py, chi17_s3 => pr17_v, chi17_s4 => pr17_th, chi17_s5 => pr17_om, chi17_s6 => pr17_ac, chi17_s7 => pr17_z, chi17_s8 => pr17_vz, chi17_s9 => pr17_az,
      chi18_s1 => pr18_px, chi18_s2 => pr18_py, chi18_s3 => pr18_v, chi18_s4 => pr18_th, chi18_s5 => pr18_om, chi18_s6 => pr18_ac, chi18_s7 => pr18_z, chi18_s8 => pr18_vz, chi18_s9 => pr18_az,
      pxz_11 => pxz11, pxz_12 => pxz12, pxz_13 => pxz13,
      pxz_21 => pxz21, pxz_22 => pxz22, pxz_23 => pxz23,
      pxz_31 => pxz31, pxz_32 => pxz32, pxz_33 => pxz33,
      pxz_41 => pxz41, pxz_42 => pxz42, pxz_43 => pxz43,
      pxz_51 => pxz51, pxz_52 => pxz52, pxz_53 => pxz53,
      pxz_61 => pxz61, pxz_62 => pxz62, pxz_63 => pxz63,
      pxz_71 => pxz71, pxz_72 => pxz72, pxz_73 => pxz73,
      pxz_81 => pxz81, pxz_82 => pxz82, pxz_83 => pxz83,
      pxz_91 => pxz91, pxz_92 => pxz92, pxz_93 => pxz93,
      done => cc_done
    );

  kg_inst : kalman_gain_9d
    port map (
      clk => clk, start => kg_start,
      pxz_11 => pxz11, pxz_12 => pxz12, pxz_13 => pxz13,
      pxz_21 => pxz21, pxz_22 => pxz22, pxz_23 => pxz23,
      pxz_31 => pxz31, pxz_32 => pxz32, pxz_33 => pxz33,
      pxz_41 => pxz41, pxz_42 => pxz42, pxz_43 => pxz43,
      pxz_51 => pxz51, pxz_52 => pxz52, pxz_53 => pxz53,
      pxz_61 => pxz61, pxz_62 => pxz62, pxz_63 => pxz63,
      pxz_71 => pxz71, pxz_72 => pxz72, pxz_73 => pxz73,
      pxz_81 => pxz81, pxz_82 => pxz82, pxz_83 => pxz83,
      pxz_91 => pxz91, pxz_92 => pxz92, pxz_93 => pxz93,
      s11 => ss11, s12 => ss12, s22 => ss22, s13 => ss13, s23 => ss23, s33 => ss33,
      k11 => kk11, k12 => kk12, k13 => kk13,
      k21 => kk21, k22 => kk22, k23 => kk23,
      k31 => kk31, k32 => kk32, k33 => kk33,
      k41 => kk41, k42 => kk42, k43 => kk43,
      k51 => kk51, k52 => kk52, k53 => kk53,
      k61 => kk61, k62 => kk62, k63 => kk63,
      k71 => kk71, k72 => kk72, k73 => kk73,
      k81 => kk81, k82 => kk82, k83 => kk83,
      k91 => kk91, k92 => kk92, k93 => kk93,
      error => kg_error, done => kg_done
    );

  su_inst : state_update_9d
    port map (
      clk => clk, start => su_start,
      s1_pred => xp1, s2_pred => xp2, s3_pred => xp3,
      s4_pred => xp4, s5_pred => xp5, s6_pred => xp6,
      s7_pred => xp7, s8_pred => xp8, s9_pred => xp9,
      p11_pred => ppred11, p12_pred => ppred12, p13_pred => ppred13, p14_pred => ppred14, p15_pred => ppred15, p16_pred => ppred16, p17_pred => ppred17, p18_pred => ppred18, p19_pred => ppred19,
      p22_pred => ppred22, p23_pred => ppred23, p24_pred => ppred24, p25_pred => ppred25, p26_pred => ppred26, p27_pred => ppred27, p28_pred => ppred28, p29_pred => ppred29,
      p33_pred => ppred33, p34_pred => ppred34, p35_pred => ppred35, p36_pred => ppred36, p37_pred => ppred37, p38_pred => ppred38, p39_pred => ppred39,
      p44_pred => ppred44, p45_pred => ppred45, p46_pred => ppred46, p47_pred => ppred47, p48_pred => ppred48, p49_pred => ppred49,
      p55_pred => ppred55, p56_pred => ppred56, p57_pred => ppred57, p58_pred => ppred58, p59_pred => ppred59,
      p66_pred => ppred66, p67_pred => ppred67, p68_pred => ppred68, p69_pred => ppred69,
      p77_pred => ppred77, p78_pred => ppred78, p79_pred => ppred79,
      p88_pred => ppred88, p89_pred => ppred89,
      p99_pred => ppred99,
      k11 => kk11, k12 => kk12, k13 => kk13,
      k21 => kk21, k22 => kk22, k23 => kk23,
      k31 => kk31, k32 => kk32, k33 => kk33,
      k41 => kk41, k42 => kk42, k43 => kk43,
      k51 => kk51, k52 => kk52, k53 => kk53,
      k61 => kk61, k62 => kk62, k63 => kk63,
      k71 => kk71, k72 => kk72, k73 => kk73,
      k81 => kk81, k82 => kk82, k83 => kk83,
      k91 => kk91, k92 => kk92, k93 => kk93,
      nu_1 => nu1, nu_2 => nu2, nu_3 => nu3,
      s1_upd => xu1, s2_upd => xu2, s3_upd => xu3,
      s4_upd => xu4, s5_upd => xu5, s6_upd => xu6,
      s7_upd => xu7, s8_upd => xu8, s9_upd => xu9,
      p11_upd => pu11, p12_upd => pu12, p13_upd => pu13, p14_upd => pu14, p15_upd => pu15, p16_upd => pu16, p17_upd => pu17, p18_upd => pu18, p19_upd => pu19,
      p22_upd => pu22, p23_upd => pu23, p24_upd => pu24, p25_upd => pu25, p26_upd => pu26, p27_upd => pu27, p28_upd => pu28, p29_upd => pu29,
      p33_upd => pu33, p34_upd => pu34, p35_upd => pu35, p36_upd => pu36, p37_upd => pu37, p38_upd => pu38, p39_upd => pu39,
      p44_upd => pu44, p45_upd => pu45, p46_upd => pu46, p47_upd => pu47, p48_upd => pu48, p49_upd => pu49,
      p55_upd => pu55, p56_upd => pu56, p57_upd => pu57, p58_upd => pu58, p59_upd => pu59,
      p66_upd => pu66, p67_upd => pu67, p68_upd => pu68, p69_upd => pu69,
      p77_upd => pu77, p78_upd => pu78, p79_upd => pu79,
      p88_upd => pu88, p89_upd => pu89,
      p99_upd => pu99,
      done => su_done
    );

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        fsm_state <= IDLE;
        done <= '0';
        first_cycle <= '1';
        chol_start <= '0'; prop_start <= '0'; mean_start <= '0';
        pcov_start <= '0'; pn_start <= '0';
        ic_start <= '0'; inn_start <= '0'; cc_start <= '0';
        kg_start <= '0'; su_start <= '0';
      else
        case fsm_state is

          when IDLE =>
            done <= '0';
            chol_start <= '0'; prop_start <= '0'; mean_start <= '0';
            pcov_start <= '0'; pn_start <= '0';
            ic_start <= '0'; inn_start <= '0'; cc_start <= '0';
            kg_start <= '0'; su_start <= '0';
            if start = '1' then
              if first_cycle = '1' then

                fsm_state <= INIT_STATE;
              else
                fsm_state <= START_CHOLESKY;
              end if;
            end if;

          when INIT_STATE =>

            x_state  <= z_x_meas;
            y_state  <= z_y_meas;
            v_state  <= (others => '0');
            t_state  <= (others => '0');
            w_state  <= (others => '0');
            a_state  <= (others => '0');
            z_state  <= z_z_meas;
            vz_state <= (others => '0');
            az_state <= (others => '0');

            cp11 <= P_INIT_1; cp12 <= (others => '0'); cp13 <= (others => '0'); cp14 <= (others => '0');
            cp15 <= (others => '0'); cp16 <= (others => '0'); cp17 <= (others => '0'); cp18 <= (others => '0'); cp19 <= (others => '0');
            cp22 <= P_INIT_2; cp23 <= (others => '0'); cp24 <= (others => '0');
            cp25 <= (others => '0'); cp26 <= (others => '0'); cp27 <= (others => '0'); cp28 <= (others => '0'); cp29 <= (others => '0');
            cp33 <= P_INIT_3; cp34 <= (others => '0'); cp35 <= (others => '0');
            cp36 <= (others => '0'); cp37 <= (others => '0'); cp38 <= (others => '0'); cp39 <= (others => '0');
            cp44 <= P_INIT_4; cp45 <= (others => '0'); cp46 <= (others => '0');
            cp47 <= (others => '0'); cp48 <= (others => '0'); cp49 <= (others => '0');
            cp55 <= P_INIT_5; cp56 <= (others => '0'); cp57 <= (others => '0'); cp58 <= (others => '0'); cp59 <= (others => '0');
            cp66 <= P_INIT_6; cp67 <= (others => '0'); cp68 <= (others => '0'); cp69 <= (others => '0');
            cp77 <= P_INIT_7; cp78 <= (others => '0'); cp79 <= (others => '0');
            cp88 <= P_INIT_8; cp89 <= (others => '0');
            cp99 <= P_INIT_9;
            first_cycle <= '0';

            px_current    <= z_x_meas;
            py_current    <= z_y_meas;
            v_current     <= (others => '0');
            theta_current <= (others => '0');
            omega_current <= (others => '0');
            a_current     <= (others => '0');
            z_current     <= z_z_meas;
            vz_current    <= (others => '0');
            az_current    <= (others => '0');
            p11_diag <= P_INIT_1; p22_diag <= P_INIT_2; p33_diag <= P_INIT_3;
            p44_diag <= P_INIT_4; p55_diag <= P_INIT_5; p66_diag <= P_INIT_6;
            p77_diag <= P_INIT_7; p88_diag <= P_INIT_8; p99_diag <= P_INIT_9;
            fsm_state <= CYCLE_DONE;

          when START_CHOLESKY =>
            chol_start <= '1';
            fsm_state <= WAIT_CHOLESKY;

          when WAIT_CHOLESKY =>
            chol_start <= '0';
            if chol_done = '1' then
              fsm_state <= WAIT_SIGMA;
            end if;

          when WAIT_SIGMA =>
            if sigma_done = '1' then
              prop_start <= '1';
              fsm_state <= START_PROPAGATE;
            end if;

          when START_PROPAGATE =>
            prop_start <= '0';
            fsm_state <= WAIT_PROPAGATE;

          when WAIT_PROPAGATE =>
            if prop_done = '1' then
              mean_start <= '1';
              fsm_state <= START_MEAN_COV;
            end if;

          when START_MEAN_COV =>
            mean_start <= '0';
            fsm_state <= WAIT_MEAN;

          when WAIT_MEAN =>
            if mean_done = '1' then
              pcov_start <= '1';
              fsm_state <= START_PCOV;
            end if;

          when START_PCOV =>
            pcov_start <= '0';
            fsm_state <= WAIT_PCOV;

          when WAIT_PCOV =>
            if pcov_done = '1' then
              pn_start <= '1';
              fsm_state <= START_PROC_NOISE;
            end if;

          when START_PROC_NOISE =>
            pn_start <= '0';
            fsm_state <= WAIT_PROC_NOISE;

          when WAIT_PROC_NOISE =>
            if pn_done = '1' then

              ppred11 <= pn11; ppred12 <= pp12_s; ppred13 <= pp13_s; ppred14 <= pp14_s;
              ppred15 <= pp15_s; ppred16 <= pp16_s; ppred17 <= pp17_s; ppred18 <= pp18_s; ppred19 <= pp19_s;
              ppred22 <= pn22; ppred23 <= pp23_s; ppred24 <= pp24_s;
              ppred25 <= pp25_s; ppred26 <= pp26_s; ppred27 <= pp27_s; ppred28 <= pp28_s; ppred29 <= pp29_s;
              ppred33 <= pn33; ppred34 <= pp34_s; ppred35 <= pp35_s;
              ppred36 <= pp36_s; ppred37 <= pp37_s; ppred38 <= pp38_s; ppred39 <= pp39_s;
              ppred44 <= pn44; ppred45 <= pp45_s; ppred46 <= pp46_s;
              ppred47 <= pp47_s; ppred48 <= pp48_s; ppred49 <= pp49_s;
              ppred55 <= pn55; ppred56 <= pp56_s; ppred57 <= pp57_s; ppred58 <= pp58_s; ppred59 <= pp59_s;
              ppred66 <= pn66; ppred67 <= pp67_s; ppred68 <= pp68_s; ppred69 <= pp69_s;
              ppred77 <= pn77; ppred78 <= pp78_s; ppred79 <= pp79_s;
              ppred88 <= pn88; ppred89 <= pp89_s;
              ppred99 <= pn99;

              ic_start <= '1';
              inn_start <= '1';
              cc_start <= '1';
              ic_done_latch <= '0';
              inn_done_latch <= '0';
              cc_done_latch <= '0';
              fsm_state <= START_MEAS_UPDATE;
            end if;

          when START_MEAS_UPDATE =>
            ic_start <= '0';
            inn_start <= '0';
            cc_start <= '0';
            fsm_state <= WAIT_INNOV_COV;

          when WAIT_INNOV_COV =>

            if ic_done = '1' then ic_done_latch <= '1'; end if;
            if inn_done = '1' then inn_done_latch <= '1'; end if;
            if cc_done = '1' then cc_done_latch <= '1'; end if;
            if (ic_done = '1' or ic_done_latch = '1') and
               (inn_done = '1' or inn_done_latch = '1') and
               (cc_done = '1' or cc_done_latch = '1') then
              kg_start <= '1';
              fsm_state <= START_KALMAN;
            end if;

          when START_KALMAN =>
            kg_start <= '0';
            fsm_state <= WAIT_KALMAN;

          when WAIT_KALMAN =>
            if kg_done = '1' then
              su_start <= '1';
              fsm_state <= START_STATE_UPD;
            end if;

          when START_STATE_UPD =>
            su_start <= '0';
            fsm_state <= WAIT_STATE_UPD;

          when WAIT_STATE_UPD =>
            if su_done = '1' then
              fsm_state <= LATCH_OUTPUT;
            end if;

          when LATCH_OUTPUT =>

            x_state <= xu1; y_state <= xu2; v_state <= xu3;
            t_state <= xu4; w_state <= xu5; a_state <= xu6;
            z_state <= xu7; vz_state <= xu8; az_state <= xu9;

            cp11 <= pu11; cp12 <= pu12; cp13 <= pu13; cp14 <= pu14;
            cp15 <= pu15; cp16 <= pu16; cp17 <= pu17; cp18 <= pu18; cp19 <= pu19;
            cp22 <= pu22; cp23 <= pu23; cp24 <= pu24;
            cp25 <= pu25; cp26 <= pu26; cp27 <= pu27; cp28 <= pu28; cp29 <= pu29;
            cp33 <= pu33; cp34 <= pu34; cp35 <= pu35;
            cp36 <= pu36; cp37 <= pu37; cp38 <= pu38; cp39 <= pu39;
            cp44 <= pu44; cp45 <= pu45; cp46 <= pu46;
            cp47 <= pu47; cp48 <= pu48; cp49 <= pu49;
            cp55 <= pu55; cp56 <= pu56; cp57 <= pu57; cp58 <= pu58; cp59 <= pu59;
            cp66 <= pu66; cp67 <= pu67; cp68 <= pu68; cp69 <= pu69;
            cp77 <= pu77; cp78 <= pu78; cp79 <= pu79;
            cp88 <= pu88; cp89 <= pu89;
            cp99 <= pu99;

            px_current <= xu1; py_current <= xu2; v_current <= xu3;
            theta_current <= xu4; omega_current <= xu5; a_current <= xu6;
            z_current <= xu7; vz_current <= xu8; az_current <= xu9;
            p11_diag <= pu11; p22_diag <= pu22; p33_diag <= pu33;
            p44_diag <= pu44; p55_diag <= pu55; p66_diag <= pu66;
            p77_diag <= pu77; p88_diag <= pu88; p99_diag <= pu99;

            fsm_state <= CYCLE_DONE;

          when CYCLE_DONE =>
            done <= '1';
            if start = '0' then
              fsm_state <= IDLE;
            end if;

          when others =>
            fsm_state <= IDLE;

        end case;
      end if;
    end if;
  end process;

end Behavioral;
