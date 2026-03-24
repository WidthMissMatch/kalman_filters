library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity prediction_phase_3d is
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        start : in  std_logic;
        x_pos_current, x_vel_current : in signed(47 downto 0);
        y_pos_current, y_vel_current : in signed(47 downto 0);
        z_pos_current, z_vel_current : in signed(47 downto 0);
        p11_current, p12_current, p13_current, p14_current, p15_current, p16_current : in signed(47 downto 0);
        p22_current, p23_current, p24_current, p25_current, p26_current             : in signed(47 downto 0);
        p33_current, p34_current, p35_current, p36_current                          : in signed(47 downto 0);
        p44_current, p45_current, p46_current                                       : in signed(47 downto 0);
        p55_current, p56_current                                                    : in signed(47 downto 0);
        p66_current                                                                 : in signed(47 downto 0);
        x_pos_pred, x_vel_pred : out signed(47 downto 0);
        y_pos_pred, y_vel_pred : out signed(47 downto 0);
        z_pos_pred, z_vel_pred : out signed(47 downto 0);
        p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred : out signed(47 downto 0);
        p22_pred, p23_pred, p24_pred, p25_pred, p26_pred           : out signed(47 downto 0);
        p33_pred, p34_pred, p35_pred, p36_pred                     : out signed(47 downto 0);
        p44_pred, p45_pred, p46_pred                               : out signed(47 downto 0);
        p55_pred, p56_pred                                         : out signed(47 downto 0);
        p66_pred                                                   : out signed(47 downto 0);
        chi_pred_0_x_pos, chi_pred_0_x_vel, chi_pred_0_y_pos, chi_pred_0_y_vel, chi_pred_0_z_pos, chi_pred_0_z_vel : out signed(47 downto 0);
        chi_pred_1_x_pos, chi_pred_1_x_vel, chi_pred_1_y_pos, chi_pred_1_y_vel, chi_pred_1_z_pos, chi_pred_1_z_vel : out signed(47 downto 0);
        chi_pred_2_x_pos, chi_pred_2_x_vel, chi_pred_2_y_pos, chi_pred_2_y_vel, chi_pred_2_z_pos, chi_pred_2_z_vel : out signed(47 downto 0);
        chi_pred_3_x_pos, chi_pred_3_x_vel, chi_pred_3_y_pos, chi_pred_3_y_vel, chi_pred_3_z_pos, chi_pred_3_z_vel : out signed(47 downto 0);
        chi_pred_4_x_pos, chi_pred_4_x_vel, chi_pred_4_y_pos, chi_pred_4_y_vel, chi_pred_4_z_pos, chi_pred_4_z_vel : out signed(47 downto 0);
        chi_pred_5_x_pos, chi_pred_5_x_vel, chi_pred_5_y_pos, chi_pred_5_y_vel, chi_pred_5_z_pos, chi_pred_5_z_vel : out signed(47 downto 0);
        chi_pred_6_x_pos, chi_pred_6_x_vel, chi_pred_6_y_pos, chi_pred_6_y_vel, chi_pred_6_z_pos, chi_pred_6_z_vel : out signed(47 downto 0);
        chi_pred_7_x_pos, chi_pred_7_x_vel, chi_pred_7_y_pos, chi_pred_7_y_vel, chi_pred_7_z_pos, chi_pred_7_z_vel : out signed(47 downto 0);
        chi_pred_8_x_pos, chi_pred_8_x_vel, chi_pred_8_y_pos, chi_pred_8_y_vel, chi_pred_8_z_pos, chi_pred_8_z_vel : out signed(47 downto 0);
        chi_pred_9_x_pos, chi_pred_9_x_vel, chi_pred_9_y_pos, chi_pred_9_y_vel, chi_pred_9_z_pos, chi_pred_9_z_vel : out signed(47 downto 0);
        chi_pred_10_x_pos, chi_pred_10_x_vel, chi_pred_10_y_pos, chi_pred_10_y_vel, chi_pred_10_z_pos, chi_pred_10_z_vel : out signed(47 downto 0);
        chi_pred_11_x_pos, chi_pred_11_x_vel, chi_pred_11_y_pos, chi_pred_11_y_vel, chi_pred_11_z_pos, chi_pred_11_z_vel : out signed(47 downto 0);
        chi_pred_12_x_pos, chi_pred_12_x_vel, chi_pred_12_y_pos, chi_pred_12_y_vel, chi_pred_12_z_pos, chi_pred_12_z_vel : out signed(47 downto 0);
        done : out std_logic
    );
end prediction_phase_3d;
architecture Behavioral of prediction_phase_3d is
    component cholesky_6x6 is
        port (
            clk : in std_logic;
            start : in std_logic;
            p11_in, p12_in, p13_in, p14_in, p15_in, p16_in : in signed(47 downto 0);
            p22_in, p23_in, p24_in, p25_in, p26_in : in signed(47 downto 0);
            p33_in, p34_in, p35_in, p36_in : in signed(47 downto 0);
            p44_in, p45_in, p46_in : in signed(47 downto 0);
            p55_in, p56_in : in signed(47 downto 0);
            p66_in : in signed(47 downto 0);
            l11_out, l21_out, l31_out, l41_out, l51_out, l61_out : out signed(47 downto 0);
            l22_out, l32_out, l42_out, l52_out, l62_out : out signed(47 downto 0);
            l33_out, l43_out, l53_out, l63_out : out signed(47 downto 0);
            l44_out, l54_out, l64_out : out signed(47 downto 0);
            l55_out, l65_out : out signed(47 downto 0);
            l66_out : out signed(47 downto 0);
            done : out std_logic;
            psd_error : out std_logic
        );
    end component;
    component sigma_3d is
        port (
            clk : in std_logic;
            rst : in std_logic;
            start : in std_logic;
            x_pos_mean, x_vel_mean : in signed(47 downto 0);
            y_pos_mean, y_vel_mean : in signed(47 downto 0);
            z_pos_mean, z_vel_mean : in signed(47 downto 0);
            cholesky_done : in std_logic;
            l11, l21, l31, l41, l51, l61 : in signed(47 downto 0);
            l22, l32, l42, l52, l62 : in signed(47 downto 0);
            l33, l43, l53, l63 : in signed(47 downto 0);
            l44, l54, l64 : in signed(47 downto 0);
            l55, l65 : in signed(47 downto 0);
            l66 : in signed(47 downto 0);
            chi0_x_pos, chi0_x_vel, chi0_y_pos, chi0_y_vel, chi0_z_pos, chi0_z_vel : out signed(47 downto 0);
            chi1_x_pos, chi1_x_vel, chi1_y_pos, chi1_y_vel, chi1_z_pos, chi1_z_vel : out signed(47 downto 0);
            chi2_x_pos, chi2_x_vel, chi2_y_pos, chi2_y_vel, chi2_z_pos, chi2_z_vel : out signed(47 downto 0);
            chi3_x_pos, chi3_x_vel, chi3_y_pos, chi3_y_vel, chi3_z_pos, chi3_z_vel : out signed(47 downto 0);
            chi4_x_pos, chi4_x_vel, chi4_y_pos, chi4_y_vel, chi4_z_pos, chi4_z_vel : out signed(47 downto 0);
            chi5_x_pos, chi5_x_vel, chi5_y_pos, chi5_y_vel, chi5_z_pos, chi5_z_vel : out signed(47 downto 0);
            chi6_x_pos, chi6_x_vel, chi6_y_pos, chi6_y_vel, chi6_z_pos, chi6_z_vel : out signed(47 downto 0);
            chi7_x_pos, chi7_x_vel, chi7_y_pos, chi7_y_vel, chi7_z_pos, chi7_z_vel : out signed(47 downto 0);
            chi8_x_pos, chi8_x_vel, chi8_y_pos, chi8_y_vel, chi8_z_pos, chi8_z_vel : out signed(47 downto 0);
            chi9_x_pos, chi9_x_vel, chi9_y_pos, chi9_y_vel, chi9_z_pos, chi9_z_vel : out signed(47 downto 0);
            chi10_x_pos, chi10_x_vel, chi10_y_pos, chi10_y_vel, chi10_z_pos, chi10_z_vel : out signed(47 downto 0);
            chi11_x_pos, chi11_x_vel, chi11_y_pos, chi11_y_vel, chi11_z_pos, chi11_z_vel : out signed(47 downto 0);
            chi12_x_pos, chi12_x_vel, chi12_y_pos, chi12_y_vel, chi12_z_pos, chi12_z_vel : out signed(47 downto 0);
            done : out std_logic
        );
    end component;
    component predicti_cv3d is
        port (
            clk : in std_logic; rst : in std_logic; start : in std_logic;
            chi0_x_pos_in, chi0_x_vel_in, chi0_y_pos_in, chi0_y_vel_in, chi0_z_pos_in, chi0_z_vel_in : in signed(47 downto 0);
            chi1_x_pos_in, chi1_x_vel_in, chi1_y_pos_in, chi1_y_vel_in, chi1_z_pos_in, chi1_z_vel_in : in signed(47 downto 0);
            chi2_x_pos_in, chi2_x_vel_in, chi2_y_pos_in, chi2_y_vel_in, chi2_z_pos_in, chi2_z_vel_in : in signed(47 downto 0);
            chi3_x_pos_in, chi3_x_vel_in, chi3_y_pos_in, chi3_y_vel_in, chi3_z_pos_in, chi3_z_vel_in : in signed(47 downto 0);
            chi4_x_pos_in, chi4_x_vel_in, chi4_y_pos_in, chi4_y_vel_in, chi4_z_pos_in, chi4_z_vel_in : in signed(47 downto 0);
            chi5_x_pos_in, chi5_x_vel_in, chi5_y_pos_in, chi5_y_vel_in, chi5_z_pos_in, chi5_z_vel_in : in signed(47 downto 0);
            chi6_x_pos_in, chi6_x_vel_in, chi6_y_pos_in, chi6_y_vel_in, chi6_z_pos_in, chi6_z_vel_in : in signed(47 downto 0);
            chi7_x_pos_in, chi7_x_vel_in, chi7_y_pos_in, chi7_y_vel_in, chi7_z_pos_in, chi7_z_vel_in : in signed(47 downto 0);
            chi8_x_pos_in, chi8_x_vel_in, chi8_y_pos_in, chi8_y_vel_in, chi8_z_pos_in, chi8_z_vel_in : in signed(47 downto 0);
            chi9_x_pos_in, chi9_x_vel_in, chi9_y_pos_in, chi9_y_vel_in, chi9_z_pos_in, chi9_z_vel_in : in signed(47 downto 0);
            chi10_x_pos_in, chi10_x_vel_in, chi10_y_pos_in, chi10_y_vel_in, chi10_z_pos_in, chi10_z_vel_in : in signed(47 downto 0);
            chi11_x_pos_in, chi11_x_vel_in, chi11_y_pos_in, chi11_y_vel_in, chi11_z_pos_in, chi11_z_vel_in : in signed(47 downto 0);
            chi12_x_pos_in, chi12_x_vel_in, chi12_y_pos_in, chi12_y_vel_in, chi12_z_pos_in, chi12_z_vel_in : in signed(47 downto 0);
            chi0_x_pos_pred, chi0_x_vel_pred, chi0_y_pos_pred, chi0_y_vel_pred, chi0_z_pos_pred, chi0_z_vel_pred : out signed(47 downto 0);
            chi1_x_pos_pred, chi1_x_vel_pred, chi1_y_pos_pred, chi1_y_vel_pred, chi1_z_pos_pred, chi1_z_vel_pred : out signed(47 downto 0);
            chi2_x_pos_pred, chi2_x_vel_pred, chi2_y_pos_pred, chi2_y_vel_pred, chi2_z_pos_pred, chi2_z_vel_pred : out signed(47 downto 0);
            chi3_x_pos_pred, chi3_x_vel_pred, chi3_y_pos_pred, chi3_y_vel_pred, chi3_z_pos_pred, chi3_z_vel_pred : out signed(47 downto 0);
            chi4_x_pos_pred, chi4_x_vel_pred, chi4_y_pos_pred, chi4_y_vel_pred, chi4_z_pos_pred, chi4_z_vel_pred : out signed(47 downto 0);
            chi5_x_pos_pred, chi5_x_vel_pred, chi5_y_pos_pred, chi5_y_vel_pred, chi5_z_pos_pred, chi5_z_vel_pred : out signed(47 downto 0);
            chi6_x_pos_pred, chi6_x_vel_pred, chi6_y_pos_pred, chi6_y_vel_pred, chi6_z_pos_pred, chi6_z_vel_pred : out signed(47 downto 0);
            chi7_x_pos_pred, chi7_x_vel_pred, chi7_y_pos_pred, chi7_y_vel_pred, chi7_z_pos_pred, chi7_z_vel_pred : out signed(47 downto 0);
            chi8_x_pos_pred, chi8_x_vel_pred, chi8_y_pos_pred, chi8_y_vel_pred, chi8_z_pos_pred, chi8_z_vel_pred : out signed(47 downto 0);
            chi9_x_pos_pred, chi9_x_vel_pred, chi9_y_pos_pred, chi9_y_vel_pred, chi9_z_pos_pred, chi9_z_vel_pred : out signed(47 downto 0);
            chi10_x_pos_pred, chi10_x_vel_pred, chi10_y_pos_pred, chi10_y_vel_pred, chi10_z_pos_pred, chi10_z_vel_pred : out signed(47 downto 0);
            chi11_x_pos_pred, chi11_x_vel_pred, chi11_y_pos_pred, chi11_y_vel_pred, chi11_z_pos_pred, chi11_z_vel_pred : out signed(47 downto 0);
            chi12_x_pos_pred, chi12_x_vel_pred, chi12_y_pos_pred, chi12_y_vel_pred, chi12_z_pos_pred, chi12_z_vel_pred : out signed(47 downto 0);
            done : out std_logic
        );
    end component;
    component predicted_mean_3d is
        port (
            clk : in std_logic;
            rst : in std_logic;
            start : in std_logic;
            chi0_x_pos_pred, chi0_x_vel_pred, chi0_y_pos_pred, chi0_y_vel_pred, chi0_z_pos_pred, chi0_z_vel_pred : in signed(47 downto 0);
            chi1_x_pos_pred, chi1_x_vel_pred, chi1_y_pos_pred, chi1_y_vel_pred, chi1_z_pos_pred, chi1_z_vel_pred : in signed(47 downto 0);
            chi2_x_pos_pred, chi2_x_vel_pred, chi2_y_pos_pred, chi2_y_vel_pred, chi2_z_pos_pred, chi2_z_vel_pred : in signed(47 downto 0);
            chi3_x_pos_pred, chi3_x_vel_pred, chi3_y_pos_pred, chi3_y_vel_pred, chi3_z_pos_pred, chi3_z_vel_pred : in signed(47 downto 0);
            chi4_x_pos_pred, chi4_x_vel_pred, chi4_y_pos_pred, chi4_y_vel_pred, chi4_z_pos_pred, chi4_z_vel_pred : in signed(47 downto 0);
            chi5_x_pos_pred, chi5_x_vel_pred, chi5_y_pos_pred, chi5_y_vel_pred, chi5_z_pos_pred, chi5_z_vel_pred : in signed(47 downto 0);
            chi6_x_pos_pred, chi6_x_vel_pred, chi6_y_pos_pred, chi6_y_vel_pred, chi6_z_pos_pred, chi6_z_vel_pred : in signed(47 downto 0);
            chi7_x_pos_pred, chi7_x_vel_pred, chi7_y_pos_pred, chi7_y_vel_pred, chi7_z_pos_pred, chi7_z_vel_pred : in signed(47 downto 0);
            chi8_x_pos_pred, chi8_x_vel_pred, chi8_y_pos_pred, chi8_y_vel_pred, chi8_z_pos_pred, chi8_z_vel_pred : in signed(47 downto 0);
            chi9_x_pos_pred, chi9_x_vel_pred, chi9_y_pos_pred, chi9_y_vel_pred, chi9_z_pos_pred, chi9_z_vel_pred : in signed(47 downto 0);
            chi10_x_pos_pred, chi10_x_vel_pred, chi10_y_pos_pred, chi10_y_vel_pred, chi10_z_pos_pred, chi10_z_vel_pred : in signed(47 downto 0);
            chi11_x_pos_pred, chi11_x_vel_pred, chi11_y_pos_pred, chi11_y_vel_pred, chi11_z_pos_pred, chi11_z_vel_pred : in signed(47 downto 0);
            chi12_x_pos_pred, chi12_x_vel_pred, chi12_y_pos_pred, chi12_y_vel_pred, chi12_z_pos_pred, chi12_z_vel_pred : in signed(47 downto 0);
            x_pos_mean_pred, x_vel_mean_pred, y_pos_mean_pred, y_vel_mean_pred, z_pos_mean_pred, z_vel_mean_pred : out signed(47 downto 0);
            done : out std_logic
        );
    end component;
    component covariance_reconstruct_3d is
        port (
            clk : in std_logic; start : in std_logic;
            x_pos_mean, x_vel_mean, y_pos_mean, y_vel_mean, z_pos_mean, z_vel_mean : in signed(47 downto 0);
            chi0_x_pos_pred, chi0_x_vel_pred, chi0_y_pos_pred, chi0_y_vel_pred, chi0_z_pos_pred, chi0_z_vel_pred : in signed(47 downto 0);
            chi1_x_pos_pred, chi1_x_vel_pred, chi1_y_pos_pred, chi1_y_vel_pred, chi1_z_pos_pred, chi1_z_vel_pred : in signed(47 downto 0);
            chi2_x_pos_pred, chi2_x_vel_pred, chi2_y_pos_pred, chi2_y_vel_pred, chi2_z_pos_pred, chi2_z_vel_pred : in signed(47 downto 0);
            chi3_x_pos_pred, chi3_x_vel_pred, chi3_y_pos_pred, chi3_y_vel_pred, chi3_z_pos_pred, chi3_z_vel_pred : in signed(47 downto 0);
            chi4_x_pos_pred, chi4_x_vel_pred, chi4_y_pos_pred, chi4_y_vel_pred, chi4_z_pos_pred, chi4_z_vel_pred : in signed(47 downto 0);
            chi5_x_pos_pred, chi5_x_vel_pred, chi5_y_pos_pred, chi5_y_vel_pred, chi5_z_pos_pred, chi5_z_vel_pred : in signed(47 downto 0);
            chi6_x_pos_pred, chi6_x_vel_pred, chi6_y_pos_pred, chi6_y_vel_pred, chi6_z_pos_pred, chi6_z_vel_pred : in signed(47 downto 0);
            chi7_x_pos_pred, chi7_x_vel_pred, chi7_y_pos_pred, chi7_y_vel_pred, chi7_z_pos_pred, chi7_z_vel_pred : in signed(47 downto 0);
            chi8_x_pos_pred, chi8_x_vel_pred, chi8_y_pos_pred, chi8_y_vel_pred, chi8_z_pos_pred, chi8_z_vel_pred : in signed(47 downto 0);
            chi9_x_pos_pred, chi9_x_vel_pred, chi9_y_pos_pred, chi9_y_vel_pred, chi9_z_pos_pred, chi9_z_vel_pred : in signed(47 downto 0);
            chi10_x_pos_pred, chi10_x_vel_pred, chi10_y_pos_pred, chi10_y_vel_pred, chi10_z_pos_pred, chi10_z_vel_pred : in signed(47 downto 0);
            chi11_x_pos_pred, chi11_x_vel_pred, chi11_y_pos_pred, chi11_y_vel_pred, chi11_z_pos_pred, chi11_z_vel_pred : in signed(47 downto 0);
            chi12_x_pos_pred, chi12_x_vel_pred, chi12_y_pos_pred, chi12_y_vel_pred, chi12_z_pos_pred, chi12_z_vel_pred : in signed(47 downto 0);
            p11_out, p12_out, p13_out, p14_out, p15_out, p16_out : out signed(47 downto 0);
            p22_out, p23_out, p24_out, p25_out, p26_out : out signed(47 downto 0);
            p33_out, p34_out, p35_out, p36_out : out signed(47 downto 0);
            p44_out, p45_out, p46_out : out signed(47 downto 0);
            p55_out, p56_out : out signed(47 downto 0);
            p66_out : out signed(47 downto 0);
            done : out std_logic
        );
    end component;
    component process_noise_3d is
        port (
            clk : in std_logic; start : in std_logic;
            p11_in, p12_in, p13_in, p14_in, p15_in, p16_in : in signed(47 downto 0);
            p22_in, p23_in, p24_in, p25_in, p26_in : in signed(47 downto 0);
            p33_in, p34_in, p35_in, p36_in : in signed(47 downto 0);
            p44_in, p45_in, p46_in : in signed(47 downto 0);
            p55_in, p56_in : in signed(47 downto 0);
            p66_in : in signed(47 downto 0);
            p11_out, p12_out, p13_out, p14_out, p15_out, p16_out : out signed(47 downto 0);
            p22_out, p23_out, p24_out, p25_out, p26_out : out signed(47 downto 0);
            p33_out, p34_out, p35_out, p36_out : out signed(47 downto 0);
            p44_out, p45_out, p46_out : out signed(47 downto 0);
            p55_out, p56_out : out signed(47 downto 0);
            p66_out : out signed(47 downto 0);
            done : out std_logic
        );
    end component;
    type state_type is (IDLE, RUN_CHOLESKY, WAIT_CHOLESKY, RUN_SIGMA, WAIT_SIGMA,
                        RUN_PREDICT, WAIT_PREDICT, RUN_MEAN, WAIT_MEAN,
                        RUN_COV, WAIT_COV, RUN_NOISE, WAIT_NOISE, FINISHED);
    signal state : state_type := IDLE;
    signal cholesky_start, cholesky_done, cholesky_error : std_logic;
    signal sigma_start, sigma_done : std_logic;
    signal predict_start, predict_done : std_logic;
    signal mean_start, mean_done : std_logic;
    signal cov_start, cov_done : std_logic;
    signal noise_start, noise_done : std_logic;
    signal l11_sig, l21_sig, l31_sig, l41_sig, l51_sig, l61_sig : signed(47 downto 0) := (others => '0');
    signal l22_sig, l32_sig, l42_sig, l52_sig, l62_sig : signed(47 downto 0) := (others => '0');
    signal l33_sig, l43_sig, l53_sig, l63_sig : signed(47 downto 0) := (others => '0');
    signal l44_sig, l54_sig, l64_sig : signed(47 downto 0) := (others => '0');
    signal l55_sig, l65_sig : signed(47 downto 0) := (others => '0');
    signal l66_sig : signed(47 downto 0) := (others => '0');
    signal chi_0_x_pos, chi_0_x_vel, chi_0_y_pos, chi_0_y_vel, chi_0_z_pos, chi_0_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_1_x_pos, chi_1_x_vel, chi_1_y_pos, chi_1_y_vel, chi_1_z_pos, chi_1_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_2_x_pos, chi_2_x_vel, chi_2_y_pos, chi_2_y_vel, chi_2_z_pos, chi_2_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_3_x_pos, chi_3_x_vel, chi_3_y_pos, chi_3_y_vel, chi_3_z_pos, chi_3_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_4_x_pos, chi_4_x_vel, chi_4_y_pos, chi_4_y_vel, chi_4_z_pos, chi_4_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_5_x_pos, chi_5_x_vel, chi_5_y_pos, chi_5_y_vel, chi_5_z_pos, chi_5_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_6_x_pos, chi_6_x_vel, chi_6_y_pos, chi_6_y_vel, chi_6_z_pos, chi_6_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_7_x_pos, chi_7_x_vel, chi_7_y_pos, chi_7_y_vel, chi_7_z_pos, chi_7_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_8_x_pos, chi_8_x_vel, chi_8_y_pos, chi_8_y_vel, chi_8_z_pos, chi_8_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_9_x_pos, chi_9_x_vel, chi_9_y_pos, chi_9_y_vel, chi_9_z_pos, chi_9_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_10_x_pos, chi_10_x_vel, chi_10_y_pos, chi_10_y_vel, chi_10_z_pos, chi_10_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_11_x_pos, chi_11_x_vel, chi_11_y_pos, chi_11_y_vel, chi_11_z_pos, chi_11_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_12_x_pos, chi_12_x_vel, chi_12_y_pos, chi_12_y_vel, chi_12_z_pos, chi_12_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_0_x_pos, chi_pred_int_0_x_vel, chi_pred_int_0_y_pos, chi_pred_int_0_y_vel, chi_pred_int_0_z_pos, chi_pred_int_0_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_1_x_pos, chi_pred_int_1_x_vel, chi_pred_int_1_y_pos, chi_pred_int_1_y_vel, chi_pred_int_1_z_pos, chi_pred_int_1_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_2_x_pos, chi_pred_int_2_x_vel, chi_pred_int_2_y_pos, chi_pred_int_2_y_vel, chi_pred_int_2_z_pos, chi_pred_int_2_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_3_x_pos, chi_pred_int_3_x_vel, chi_pred_int_3_y_pos, chi_pred_int_3_y_vel, chi_pred_int_3_z_pos, chi_pred_int_3_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_4_x_pos, chi_pred_int_4_x_vel, chi_pred_int_4_y_pos, chi_pred_int_4_y_vel, chi_pred_int_4_z_pos, chi_pred_int_4_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_5_x_pos, chi_pred_int_5_x_vel, chi_pred_int_5_y_pos, chi_pred_int_5_y_vel, chi_pred_int_5_z_pos, chi_pred_int_5_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_6_x_pos, chi_pred_int_6_x_vel, chi_pred_int_6_y_pos, chi_pred_int_6_y_vel, chi_pred_int_6_z_pos, chi_pred_int_6_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_7_x_pos, chi_pred_int_7_x_vel, chi_pred_int_7_y_pos, chi_pred_int_7_y_vel, chi_pred_int_7_z_pos, chi_pred_int_7_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_8_x_pos, chi_pred_int_8_x_vel, chi_pred_int_8_y_pos, chi_pred_int_8_y_vel, chi_pred_int_8_z_pos, chi_pred_int_8_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_9_x_pos, chi_pred_int_9_x_vel, chi_pred_int_9_y_pos, chi_pred_int_9_y_vel, chi_pred_int_9_z_pos, chi_pred_int_9_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_10_x_pos, chi_pred_int_10_x_vel, chi_pred_int_10_y_pos, chi_pred_int_10_y_vel, chi_pred_int_10_z_pos, chi_pred_int_10_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_11_x_pos, chi_pred_int_11_x_vel, chi_pred_int_11_y_pos, chi_pred_int_11_y_vel, chi_pred_int_11_z_pos, chi_pred_int_11_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_12_x_pos, chi_pred_int_12_x_vel, chi_pred_int_12_y_pos, chi_pred_int_12_y_vel, chi_pred_int_12_z_pos, chi_pred_int_12_z_vel : signed(47 downto 0) := (others => '0');
    signal x_pos_mean, x_vel_mean, y_pos_mean, y_vel_mean, z_pos_mean, z_vel_mean : signed(47 downto 0) := (others => '0');
    signal p11_cov, p12_cov, p13_cov, p14_cov, p15_cov, p16_cov : signed(47 downto 0) := (others => '0');
    signal p22_cov, p23_cov, p24_cov, p25_cov, p26_cov : signed(47 downto 0) := (others => '0');
    signal p33_cov, p34_cov, p35_cov, p36_cov : signed(47 downto 0) := (others => '0');
    signal p44_cov, p45_cov, p46_cov : signed(47 downto 0) := (others => '0');
    signal p55_cov, p56_cov : signed(47 downto 0) := (others => '0');
    signal p66_cov : signed(47 downto 0) := (others => '0');
begin
    cholesky_comp : cholesky_6x6
        port map (
            clk => clk, start => cholesky_start,
            p11_in => p11_current, p12_in => p12_current, p13_in => p13_current, p14_in => p14_current, p15_in => p15_current, p16_in => p16_current,
            p22_in => p22_current, p23_in => p23_current, p24_in => p24_current, p25_in => p25_current, p26_in => p26_current,
            p33_in => p33_current, p34_in => p34_current, p35_in => p35_current, p36_in => p36_current,
            p44_in => p44_current, p45_in => p45_current, p46_in => p46_current,
            p55_in => p55_current, p56_in => p56_current,
            p66_in => p66_current,
            l11_out => l11_sig, l21_out => l21_sig, l31_out => l31_sig, l41_out => l41_sig, l51_out => l51_sig, l61_out => l61_sig,
            l22_out => l22_sig, l32_out => l32_sig, l42_out => l42_sig, l52_out => l52_sig, l62_out => l62_sig,
            l33_out => l33_sig, l43_out => l43_sig, l53_out => l53_sig, l63_out => l63_sig,
            l44_out => l44_sig, l54_out => l54_sig, l64_out => l64_sig,
            l55_out => l55_sig, l65_out => l65_sig,
            l66_out => l66_sig,
            done => cholesky_done,
            psd_error => cholesky_error
        );
    sigma_gen : sigma_3d
        port map (
            clk => clk,
            rst => rst,
            start => sigma_start,
            x_pos_mean => x_pos_current, x_vel_mean => x_vel_current,
            y_pos_mean => y_pos_current, y_vel_mean => y_vel_current,
            z_pos_mean => z_pos_current, z_vel_mean => z_vel_current,
            cholesky_done => cholesky_done,
            l11 => l11_sig, l21 => l21_sig, l31 => l31_sig, l41 => l41_sig, l51 => l51_sig, l61 => l61_sig,
            l22 => l22_sig, l32 => l32_sig, l42 => l42_sig, l52 => l52_sig, l62 => l62_sig,
            l33 => l33_sig, l43 => l43_sig, l53 => l53_sig, l63 => l63_sig,
            l44 => l44_sig, l54 => l54_sig, l64 => l64_sig,
            l55 => l55_sig, l65 => l65_sig,
            l66 => l66_sig,
            chi0_x_pos => chi_0_x_pos, chi0_x_vel => chi_0_x_vel, chi0_y_pos => chi_0_y_pos, chi0_y_vel => chi_0_y_vel, chi0_z_pos => chi_0_z_pos, chi0_z_vel => chi_0_z_vel,
            chi1_x_pos => chi_1_x_pos, chi1_x_vel => chi_1_x_vel, chi1_y_pos => chi_1_y_pos, chi1_y_vel => chi_1_y_vel, chi1_z_pos => chi_1_z_pos, chi1_z_vel => chi_1_z_vel,
            chi2_x_pos => chi_2_x_pos, chi2_x_vel => chi_2_x_vel, chi2_y_pos => chi_2_y_pos, chi2_y_vel => chi_2_y_vel, chi2_z_pos => chi_2_z_pos, chi2_z_vel => chi_2_z_vel,
            chi3_x_pos => chi_3_x_pos, chi3_x_vel => chi_3_x_vel, chi3_y_pos => chi_3_y_pos, chi3_y_vel => chi_3_y_vel, chi3_z_pos => chi_3_z_pos, chi3_z_vel => chi_3_z_vel,
            chi4_x_pos => chi_4_x_pos, chi4_x_vel => chi_4_x_vel, chi4_y_pos => chi_4_y_pos, chi4_y_vel => chi_4_y_vel, chi4_z_pos => chi_4_z_pos, chi4_z_vel => chi_4_z_vel,
            chi5_x_pos => chi_5_x_pos, chi5_x_vel => chi_5_x_vel, chi5_y_pos => chi_5_y_pos, chi5_y_vel => chi_5_y_vel, chi5_z_pos => chi_5_z_pos, chi5_z_vel => chi_5_z_vel,
            chi6_x_pos => chi_6_x_pos, chi6_x_vel => chi_6_x_vel, chi6_y_pos => chi_6_y_pos, chi6_y_vel => chi_6_y_vel, chi6_z_pos => chi_6_z_pos, chi6_z_vel => chi_6_z_vel,
            chi7_x_pos => chi_7_x_pos, chi7_x_vel => chi_7_x_vel, chi7_y_pos => chi_7_y_pos, chi7_y_vel => chi_7_y_vel, chi7_z_pos => chi_7_z_pos, chi7_z_vel => chi_7_z_vel,
            chi8_x_pos => chi_8_x_pos, chi8_x_vel => chi_8_x_vel, chi8_y_pos => chi_8_y_pos, chi8_y_vel => chi_8_y_vel, chi8_z_pos => chi_8_z_pos, chi8_z_vel => chi_8_z_vel,
            chi9_x_pos => chi_9_x_pos, chi9_x_vel => chi_9_x_vel, chi9_y_pos => chi_9_y_pos, chi9_y_vel => chi_9_y_vel, chi9_z_pos => chi_9_z_pos, chi9_z_vel => chi_9_z_vel,
            chi10_x_pos => chi_10_x_pos, chi10_x_vel => chi_10_x_vel, chi10_y_pos => chi_10_y_pos, chi10_y_vel => chi_10_y_vel, chi10_z_pos => chi_10_z_pos, chi10_z_vel => chi_10_z_vel,
            chi11_x_pos => chi_11_x_pos, chi11_x_vel => chi_11_x_vel, chi11_y_pos => chi_11_y_pos, chi11_y_vel => chi_11_y_vel, chi11_z_pos => chi_11_z_pos, chi11_z_vel => chi_11_z_vel,
            chi12_x_pos => chi_12_x_pos, chi12_x_vel => chi_12_x_vel, chi12_y_pos => chi_12_y_pos, chi12_y_vel => chi_12_y_vel, chi12_z_pos => chi_12_z_pos, chi12_z_vel => chi_12_z_vel,
            done => sigma_done
        );
    predict_comp : predicti_cv3d
        port map (
            clk => clk, rst => rst, start => predict_start,
            chi0_x_pos_in => chi_0_x_pos, chi0_x_vel_in => chi_0_x_vel, chi0_y_pos_in => chi_0_y_pos, chi0_y_vel_in => chi_0_y_vel, chi0_z_pos_in => chi_0_z_pos, chi0_z_vel_in => chi_0_z_vel,
            chi1_x_pos_in => chi_1_x_pos, chi1_x_vel_in => chi_1_x_vel, chi1_y_pos_in => chi_1_y_pos, chi1_y_vel_in => chi_1_y_vel, chi1_z_pos_in => chi_1_z_pos, chi1_z_vel_in => chi_1_z_vel,
            chi2_x_pos_in => chi_2_x_pos, chi2_x_vel_in => chi_2_x_vel, chi2_y_pos_in => chi_2_y_pos, chi2_y_vel_in => chi_2_y_vel, chi2_z_pos_in => chi_2_z_pos, chi2_z_vel_in => chi_2_z_vel,
            chi3_x_pos_in => chi_3_x_pos, chi3_x_vel_in => chi_3_x_vel, chi3_y_pos_in => chi_3_y_pos, chi3_y_vel_in => chi_3_y_vel, chi3_z_pos_in => chi_3_z_pos, chi3_z_vel_in => chi_3_z_vel,
            chi4_x_pos_in => chi_4_x_pos, chi4_x_vel_in => chi_4_x_vel, chi4_y_pos_in => chi_4_y_pos, chi4_y_vel_in => chi_4_y_vel, chi4_z_pos_in => chi_4_z_pos, chi4_z_vel_in => chi_4_z_vel,
            chi5_x_pos_in => chi_5_x_pos, chi5_x_vel_in => chi_5_x_vel, chi5_y_pos_in => chi_5_y_pos, chi5_y_vel_in => chi_5_y_vel, chi5_z_pos_in => chi_5_z_pos, chi5_z_vel_in => chi_5_z_vel,
            chi6_x_pos_in => chi_6_x_pos, chi6_x_vel_in => chi_6_x_vel, chi6_y_pos_in => chi_6_y_pos, chi6_y_vel_in => chi_6_y_vel, chi6_z_pos_in => chi_6_z_pos, chi6_z_vel_in => chi_6_z_vel,
            chi7_x_pos_in => chi_7_x_pos, chi7_x_vel_in => chi_7_x_vel, chi7_y_pos_in => chi_7_y_pos, chi7_y_vel_in => chi_7_y_vel, chi7_z_pos_in => chi_7_z_pos, chi7_z_vel_in => chi_7_z_vel,
            chi8_x_pos_in => chi_8_x_pos, chi8_x_vel_in => chi_8_x_vel, chi8_y_pos_in => chi_8_y_pos, chi8_y_vel_in => chi_8_y_vel, chi8_z_pos_in => chi_8_z_pos, chi8_z_vel_in => chi_8_z_vel,
            chi9_x_pos_in => chi_9_x_pos, chi9_x_vel_in => chi_9_x_vel, chi9_y_pos_in => chi_9_y_pos, chi9_y_vel_in => chi_9_y_vel, chi9_z_pos_in => chi_9_z_pos, chi9_z_vel_in => chi_9_z_vel,
            chi10_x_pos_in => chi_10_x_pos, chi10_x_vel_in => chi_10_x_vel, chi10_y_pos_in => chi_10_y_pos, chi10_y_vel_in => chi_10_y_vel, chi10_z_pos_in => chi_10_z_pos, chi10_z_vel_in => chi_10_z_vel,
            chi11_x_pos_in => chi_11_x_pos, chi11_x_vel_in => chi_11_x_vel, chi11_y_pos_in => chi_11_y_pos, chi11_y_vel_in => chi_11_y_vel, chi11_z_pos_in => chi_11_z_pos, chi11_z_vel_in => chi_11_z_vel,
            chi12_x_pos_in => chi_12_x_pos, chi12_x_vel_in => chi_12_x_vel, chi12_y_pos_in => chi_12_y_pos, chi12_y_vel_in => chi_12_y_vel, chi12_z_pos_in => chi_12_z_pos, chi12_z_vel_in => chi_12_z_vel,
            chi0_x_pos_pred => chi_pred_int_0_x_pos, chi0_x_vel_pred => chi_pred_int_0_x_vel, chi0_y_pos_pred => chi_pred_int_0_y_pos, chi0_y_vel_pred => chi_pred_int_0_y_vel, chi0_z_pos_pred => chi_pred_int_0_z_pos, chi0_z_vel_pred => chi_pred_int_0_z_vel,
            chi1_x_pos_pred => chi_pred_int_1_x_pos, chi1_x_vel_pred => chi_pred_int_1_x_vel, chi1_y_pos_pred => chi_pred_int_1_y_pos, chi1_y_vel_pred => chi_pred_int_1_y_vel, chi1_z_pos_pred => chi_pred_int_1_z_pos, chi1_z_vel_pred => chi_pred_int_1_z_vel,
            chi2_x_pos_pred => chi_pred_int_2_x_pos, chi2_x_vel_pred => chi_pred_int_2_x_vel, chi2_y_pos_pred => chi_pred_int_2_y_pos, chi2_y_vel_pred => chi_pred_int_2_y_vel, chi2_z_pos_pred => chi_pred_int_2_z_pos, chi2_z_vel_pred => chi_pred_int_2_z_vel,
            chi3_x_pos_pred => chi_pred_int_3_x_pos, chi3_x_vel_pred => chi_pred_int_3_x_vel, chi3_y_pos_pred => chi_pred_int_3_y_pos, chi3_y_vel_pred => chi_pred_int_3_y_vel, chi3_z_pos_pred => chi_pred_int_3_z_pos, chi3_z_vel_pred => chi_pred_int_3_z_vel,
            chi4_x_pos_pred => chi_pred_int_4_x_pos, chi4_x_vel_pred => chi_pred_int_4_x_vel, chi4_y_pos_pred => chi_pred_int_4_y_pos, chi4_y_vel_pred => chi_pred_int_4_y_vel, chi4_z_pos_pred => chi_pred_int_4_z_pos, chi4_z_vel_pred => chi_pred_int_4_z_vel,
            chi5_x_pos_pred => chi_pred_int_5_x_pos, chi5_x_vel_pred => chi_pred_int_5_x_vel, chi5_y_pos_pred => chi_pred_int_5_y_pos, chi5_y_vel_pred => chi_pred_int_5_y_vel, chi5_z_pos_pred => chi_pred_int_5_z_pos, chi5_z_vel_pred => chi_pred_int_5_z_vel,
            chi6_x_pos_pred => chi_pred_int_6_x_pos, chi6_x_vel_pred => chi_pred_int_6_x_vel, chi6_y_pos_pred => chi_pred_int_6_y_pos, chi6_y_vel_pred => chi_pred_int_6_y_vel, chi6_z_pos_pred => chi_pred_int_6_z_pos, chi6_z_vel_pred => chi_pred_int_6_z_vel,
            chi7_x_pos_pred => chi_pred_int_7_x_pos, chi7_x_vel_pred => chi_pred_int_7_x_vel, chi7_y_pos_pred => chi_pred_int_7_y_pos, chi7_y_vel_pred => chi_pred_int_7_y_vel, chi7_z_pos_pred => chi_pred_int_7_z_pos, chi7_z_vel_pred => chi_pred_int_7_z_vel,
            chi8_x_pos_pred => chi_pred_int_8_x_pos, chi8_x_vel_pred => chi_pred_int_8_x_vel, chi8_y_pos_pred => chi_pred_int_8_y_pos, chi8_y_vel_pred => chi_pred_int_8_y_vel, chi8_z_pos_pred => chi_pred_int_8_z_pos, chi8_z_vel_pred => chi_pred_int_8_z_vel,
            chi9_x_pos_pred => chi_pred_int_9_x_pos, chi9_x_vel_pred => chi_pred_int_9_x_vel, chi9_y_pos_pred => chi_pred_int_9_y_pos, chi9_y_vel_pred => chi_pred_int_9_y_vel, chi9_z_pos_pred => chi_pred_int_9_z_pos, chi9_z_vel_pred => chi_pred_int_9_z_vel,
            chi10_x_pos_pred => chi_pred_int_10_x_pos, chi10_x_vel_pred => chi_pred_int_10_x_vel, chi10_y_pos_pred => chi_pred_int_10_y_pos, chi10_y_vel_pred => chi_pred_int_10_y_vel, chi10_z_pos_pred => chi_pred_int_10_z_pos, chi10_z_vel_pred => chi_pred_int_10_z_vel,
            chi11_x_pos_pred => chi_pred_int_11_x_pos, chi11_x_vel_pred => chi_pred_int_11_x_vel, chi11_y_pos_pred => chi_pred_int_11_y_pos, chi11_y_vel_pred => chi_pred_int_11_y_vel, chi11_z_pos_pred => chi_pred_int_11_z_pos, chi11_z_vel_pred => chi_pred_int_11_z_vel,
            chi12_x_pos_pred => chi_pred_int_12_x_pos, chi12_x_vel_pred => chi_pred_int_12_x_vel, chi12_y_pos_pred => chi_pred_int_12_y_pos, chi12_y_vel_pred => chi_pred_int_12_y_vel, chi12_z_pos_pred => chi_pred_int_12_z_pos, chi12_z_vel_pred => chi_pred_int_12_z_vel,
            done => predict_done
        );
    mean_comp : predicted_mean_3d
        port map (
            clk => clk,
            rst => rst,
            start => mean_start,
            chi0_x_pos_pred => chi_pred_int_0_x_pos, chi0_x_vel_pred => chi_pred_int_0_x_vel, chi0_y_pos_pred => chi_pred_int_0_y_pos, chi0_y_vel_pred => chi_pred_int_0_y_vel, chi0_z_pos_pred => chi_pred_int_0_z_pos, chi0_z_vel_pred => chi_pred_int_0_z_vel,
            chi1_x_pos_pred => chi_pred_int_1_x_pos, chi1_x_vel_pred => chi_pred_int_1_x_vel, chi1_y_pos_pred => chi_pred_int_1_y_pos, chi1_y_vel_pred => chi_pred_int_1_y_vel, chi1_z_pos_pred => chi_pred_int_1_z_pos, chi1_z_vel_pred => chi_pred_int_1_z_vel,
            chi2_x_pos_pred => chi_pred_int_2_x_pos, chi2_x_vel_pred => chi_pred_int_2_x_vel, chi2_y_pos_pred => chi_pred_int_2_y_pos, chi2_y_vel_pred => chi_pred_int_2_y_vel, chi2_z_pos_pred => chi_pred_int_2_z_pos, chi2_z_vel_pred => chi_pred_int_2_z_vel,
            chi3_x_pos_pred => chi_pred_int_3_x_pos, chi3_x_vel_pred => chi_pred_int_3_x_vel, chi3_y_pos_pred => chi_pred_int_3_y_pos, chi3_y_vel_pred => chi_pred_int_3_y_vel, chi3_z_pos_pred => chi_pred_int_3_z_pos, chi3_z_vel_pred => chi_pred_int_3_z_vel,
            chi4_x_pos_pred => chi_pred_int_4_x_pos, chi4_x_vel_pred => chi_pred_int_4_x_vel, chi4_y_pos_pred => chi_pred_int_4_y_pos, chi4_y_vel_pred => chi_pred_int_4_y_vel, chi4_z_pos_pred => chi_pred_int_4_z_pos, chi4_z_vel_pred => chi_pred_int_4_z_vel,
            chi5_x_pos_pred => chi_pred_int_5_x_pos, chi5_x_vel_pred => chi_pred_int_5_x_vel, chi5_y_pos_pred => chi_pred_int_5_y_pos, chi5_y_vel_pred => chi_pred_int_5_y_vel, chi5_z_pos_pred => chi_pred_int_5_z_pos, chi5_z_vel_pred => chi_pred_int_5_z_vel,
            chi6_x_pos_pred => chi_pred_int_6_x_pos, chi6_x_vel_pred => chi_pred_int_6_x_vel, chi6_y_pos_pred => chi_pred_int_6_y_pos, chi6_y_vel_pred => chi_pred_int_6_y_vel, chi6_z_pos_pred => chi_pred_int_6_z_pos, chi6_z_vel_pred => chi_pred_int_6_z_vel,
            chi7_x_pos_pred => chi_pred_int_7_x_pos, chi7_x_vel_pred => chi_pred_int_7_x_vel, chi7_y_pos_pred => chi_pred_int_7_y_pos, chi7_y_vel_pred => chi_pred_int_7_y_vel, chi7_z_pos_pred => chi_pred_int_7_z_pos, chi7_z_vel_pred => chi_pred_int_7_z_vel,
            chi8_x_pos_pred => chi_pred_int_8_x_pos, chi8_x_vel_pred => chi_pred_int_8_x_vel, chi8_y_pos_pred => chi_pred_int_8_y_pos, chi8_y_vel_pred => chi_pred_int_8_y_vel, chi8_z_pos_pred => chi_pred_int_8_z_pos, chi8_z_vel_pred => chi_pred_int_8_z_vel,
            chi9_x_pos_pred => chi_pred_int_9_x_pos, chi9_x_vel_pred => chi_pred_int_9_x_vel, chi9_y_pos_pred => chi_pred_int_9_y_pos, chi9_y_vel_pred => chi_pred_int_9_y_vel, chi9_z_pos_pred => chi_pred_int_9_z_pos, chi9_z_vel_pred => chi_pred_int_9_z_vel,
            chi10_x_pos_pred => chi_pred_int_10_x_pos, chi10_x_vel_pred => chi_pred_int_10_x_vel, chi10_y_pos_pred => chi_pred_int_10_y_pos, chi10_y_vel_pred => chi_pred_int_10_y_vel, chi10_z_pos_pred => chi_pred_int_10_z_pos, chi10_z_vel_pred => chi_pred_int_10_z_vel,
            chi11_x_pos_pred => chi_pred_int_11_x_pos, chi11_x_vel_pred => chi_pred_int_11_x_vel, chi11_y_pos_pred => chi_pred_int_11_y_pos, chi11_y_vel_pred => chi_pred_int_11_y_vel, chi11_z_pos_pred => chi_pred_int_11_z_pos, chi11_z_vel_pred => chi_pred_int_11_z_vel,
            chi12_x_pos_pred => chi_pred_int_12_x_pos, chi12_x_vel_pred => chi_pred_int_12_x_vel, chi12_y_pos_pred => chi_pred_int_12_y_pos, chi12_y_vel_pred => chi_pred_int_12_y_vel, chi12_z_pos_pred => chi_pred_int_12_z_pos, chi12_z_vel_pred => chi_pred_int_12_z_vel,
            x_pos_mean_pred => x_pos_mean, x_vel_mean_pred => x_vel_mean,
            y_pos_mean_pred => y_pos_mean, y_vel_mean_pred => y_vel_mean,
            z_pos_mean_pred => z_pos_mean, z_vel_mean_pred => z_vel_mean,
            done => mean_done
        );
    cov_comp : covariance_reconstruct_3d
        port map (
            clk => clk, start => cov_start,
            chi0_x_pos_pred => chi_pred_int_0_x_pos, chi0_x_vel_pred => chi_pred_int_0_x_vel, chi0_y_pos_pred => chi_pred_int_0_y_pos, chi0_y_vel_pred => chi_pred_int_0_y_vel, chi0_z_pos_pred => chi_pred_int_0_z_pos, chi0_z_vel_pred => chi_pred_int_0_z_vel,
            chi1_x_pos_pred => chi_pred_int_1_x_pos, chi1_x_vel_pred => chi_pred_int_1_x_vel, chi1_y_pos_pred => chi_pred_int_1_y_pos, chi1_y_vel_pred => chi_pred_int_1_y_vel, chi1_z_pos_pred => chi_pred_int_1_z_pos, chi1_z_vel_pred => chi_pred_int_1_z_vel,
            chi2_x_pos_pred => chi_pred_int_2_x_pos, chi2_x_vel_pred => chi_pred_int_2_x_vel, chi2_y_pos_pred => chi_pred_int_2_y_pos, chi2_y_vel_pred => chi_pred_int_2_y_vel, chi2_z_pos_pred => chi_pred_int_2_z_pos, chi2_z_vel_pred => chi_pred_int_2_z_vel,
            chi3_x_pos_pred => chi_pred_int_3_x_pos, chi3_x_vel_pred => chi_pred_int_3_x_vel, chi3_y_pos_pred => chi_pred_int_3_y_pos, chi3_y_vel_pred => chi_pred_int_3_y_vel, chi3_z_pos_pred => chi_pred_int_3_z_pos, chi3_z_vel_pred => chi_pred_int_3_z_vel,
            chi4_x_pos_pred => chi_pred_int_4_x_pos, chi4_x_vel_pred => chi_pred_int_4_x_vel, chi4_y_pos_pred => chi_pred_int_4_y_pos, chi4_y_vel_pred => chi_pred_int_4_y_vel, chi4_z_pos_pred => chi_pred_int_4_z_pos, chi4_z_vel_pred => chi_pred_int_4_z_vel,
            chi5_x_pos_pred => chi_pred_int_5_x_pos, chi5_x_vel_pred => chi_pred_int_5_x_vel, chi5_y_pos_pred => chi_pred_int_5_y_pos, chi5_y_vel_pred => chi_pred_int_5_y_vel, chi5_z_pos_pred => chi_pred_int_5_z_pos, chi5_z_vel_pred => chi_pred_int_5_z_vel,
            chi6_x_pos_pred => chi_pred_int_6_x_pos, chi6_x_vel_pred => chi_pred_int_6_x_vel, chi6_y_pos_pred => chi_pred_int_6_y_pos, chi6_y_vel_pred => chi_pred_int_6_y_vel, chi6_z_pos_pred => chi_pred_int_6_z_pos, chi6_z_vel_pred => chi_pred_int_6_z_vel,
            chi7_x_pos_pred => chi_pred_int_7_x_pos, chi7_x_vel_pred => chi_pred_int_7_x_vel, chi7_y_pos_pred => chi_pred_int_7_y_pos, chi7_y_vel_pred => chi_pred_int_7_y_vel, chi7_z_pos_pred => chi_pred_int_7_z_pos, chi7_z_vel_pred => chi_pred_int_7_z_vel,
            chi8_x_pos_pred => chi_pred_int_8_x_pos, chi8_x_vel_pred => chi_pred_int_8_x_vel, chi8_y_pos_pred => chi_pred_int_8_y_pos, chi8_y_vel_pred => chi_pred_int_8_y_vel, chi8_z_pos_pred => chi_pred_int_8_z_pos, chi8_z_vel_pred => chi_pred_int_8_z_vel,
            chi9_x_pos_pred => chi_pred_int_9_x_pos, chi9_x_vel_pred => chi_pred_int_9_x_vel, chi9_y_pos_pred => chi_pred_int_9_y_pos, chi9_y_vel_pred => chi_pred_int_9_y_vel, chi9_z_pos_pred => chi_pred_int_9_z_pos, chi9_z_vel_pred => chi_pred_int_9_z_vel,
            chi10_x_pos_pred => chi_pred_int_10_x_pos, chi10_x_vel_pred => chi_pred_int_10_x_vel, chi10_y_pos_pred => chi_pred_int_10_y_pos, chi10_y_vel_pred => chi_pred_int_10_y_vel, chi10_z_pos_pred => chi_pred_int_10_z_pos, chi10_z_vel_pred => chi_pred_int_10_z_vel,
            chi11_x_pos_pred => chi_pred_int_11_x_pos, chi11_x_vel_pred => chi_pred_int_11_x_vel, chi11_y_pos_pred => chi_pred_int_11_y_pos, chi11_y_vel_pred => chi_pred_int_11_y_vel, chi11_z_pos_pred => chi_pred_int_11_z_pos, chi11_z_vel_pred => chi_pred_int_11_z_vel,
            chi12_x_pos_pred => chi_pred_int_12_x_pos, chi12_x_vel_pred => chi_pred_int_12_x_vel, chi12_y_pos_pred => chi_pred_int_12_y_pos, chi12_y_vel_pred => chi_pred_int_12_y_vel, chi12_z_pos_pred => chi_pred_int_12_z_pos, chi12_z_vel_pred => chi_pred_int_12_z_vel,
            x_pos_mean => x_pos_mean, x_vel_mean => x_vel_mean,
            y_pos_mean => y_pos_mean, y_vel_mean => y_vel_mean,
            z_pos_mean => z_pos_mean, z_vel_mean => z_vel_mean,
            p11_out => p11_cov, p12_out => p12_cov, p13_out => p13_cov, p14_out => p14_cov, p15_out => p15_cov, p16_out => p16_cov,
            p22_out => p22_cov, p23_out => p23_cov, p24_out => p24_cov, p25_out => p25_cov, p26_out => p26_cov,
            p33_out => p33_cov, p34_out => p34_cov, p35_out => p35_cov, p36_out => p36_cov,
            p44_out => p44_cov, p45_out => p45_cov, p46_out => p46_cov,
            p55_out => p55_cov, p56_out => p56_cov,
            p66_out => p66_cov,
            done => cov_done
        );
    noise_comp : process_noise_3d
        port map (
            clk => clk, start => noise_start,
            p11_in => p11_cov, p12_in => p12_cov, p13_in => p13_cov, p14_in => p14_cov, p15_in => p15_cov, p16_in => p16_cov,
            p22_in => p22_cov, p23_in => p23_cov, p24_in => p24_cov, p25_in => p25_cov, p26_in => p26_cov,
            p33_in => p33_cov, p34_in => p34_cov, p35_in => p35_cov, p36_in => p36_cov,
            p44_in => p44_cov, p45_in => p45_cov, p46_in => p46_cov,
            p55_in => p55_cov, p56_in => p56_cov,
            p66_in => p66_cov,
            p11_out => p11_pred, p12_out => p12_pred, p13_out => p13_pred, p14_out => p14_pred, p15_out => p15_pred, p16_out => p16_pred,
            p22_out => p22_pred, p23_out => p23_pred, p24_out => p24_pred, p25_out => p25_pred, p26_out => p26_pred,
            p33_out => p33_pred, p34_out => p34_pred, p35_out => p35_pred, p36_out => p36_pred,
            p44_out => p44_pred, p45_out => p45_pred, p46_out => p46_pred,
            p55_out => p55_pred, p56_out => p56_pred,
            p66_out => p66_pred,
            done => noise_done
        );
    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when IDLE =>
                    done <= '0';
                    cholesky_start <= '0';
                    sigma_start <= '0';
                    predict_start <= '0';
                    mean_start <= '0';
                    cov_start <= '0';
                    noise_start <= '0';
                    if start = '1' then
                        state <= RUN_CHOLESKY;
                    end if;
                when RUN_CHOLESKY =>
                    cholesky_start <= '1';
                    state <= WAIT_CHOLESKY;
                when WAIT_CHOLESKY =>
                    cholesky_start <= '0';
                    if cholesky_done = '1' then
                        if cholesky_error = '1' then
                            report "ERROR: Cholesky PSD failure - P matrix ill-conditioned, skipping prediction update" severity warning;
                            state <= FINISHED;
                        else
                            state <= RUN_SIGMA;
                        end if;
                    end if;
                when RUN_SIGMA =>
                    sigma_start <= '1';
                    state <= WAIT_SIGMA;
                when WAIT_SIGMA =>
                    sigma_start <= '0';
                    if sigma_done = '1' then
                        state <= RUN_PREDICT;
                    end if;
                when RUN_PREDICT =>
                    predict_start <= '1';
                    state <= WAIT_PREDICT;
                when WAIT_PREDICT =>
                    predict_start <= '0';
                    if predict_done = '1' then
                        state <= RUN_MEAN;
                    end if;
                when RUN_MEAN =>
                    mean_start <= '1';
                    state <= WAIT_MEAN;
                when WAIT_MEAN =>
                    mean_start <= '0';
                    if mean_done = '1' then
                        state <= RUN_COV;
                    end if;
                when RUN_COV =>
                    cov_start <= '1';
                    state <= WAIT_COV;
                when WAIT_COV =>
                    cov_start <= '0';
                    if cov_done = '1' then
                        state <= RUN_NOISE;
                    end if;
                when RUN_NOISE =>
                    noise_start <= '1';
                    state <= WAIT_NOISE;
                when WAIT_NOISE =>
                    noise_start <= '0';
                    if noise_done = '1' then
                        x_pos_pred <= x_pos_mean;
                        x_vel_pred <= x_vel_mean;
                        y_pos_pred <= y_pos_mean;
                        y_vel_pred <= y_vel_mean;
                        z_pos_pred <= z_pos_mean;
                        z_vel_pred <= z_vel_mean;
                        chi_pred_0_x_pos <= chi_pred_int_0_x_pos; chi_pred_0_x_vel <= chi_pred_int_0_x_vel;
                        chi_pred_0_y_pos <= chi_pred_int_0_y_pos; chi_pred_0_y_vel <= chi_pred_int_0_y_vel;
                        chi_pred_0_z_pos <= chi_pred_int_0_z_pos; chi_pred_0_z_vel <= chi_pred_int_0_z_vel;
                        chi_pred_1_x_pos <= chi_pred_int_1_x_pos; chi_pred_1_x_vel <= chi_pred_int_1_x_vel;
                        chi_pred_1_y_pos <= chi_pred_int_1_y_pos; chi_pred_1_y_vel <= chi_pred_int_1_y_vel;
                        chi_pred_1_z_pos <= chi_pred_int_1_z_pos; chi_pred_1_z_vel <= chi_pred_int_1_z_vel;
                        chi_pred_2_x_pos <= chi_pred_int_2_x_pos; chi_pred_2_x_vel <= chi_pred_int_2_x_vel;
                        chi_pred_2_y_pos <= chi_pred_int_2_y_pos; chi_pred_2_y_vel <= chi_pred_int_2_y_vel;
                        chi_pred_2_z_pos <= chi_pred_int_2_z_pos; chi_pred_2_z_vel <= chi_pred_int_2_z_vel;
                        chi_pred_3_x_pos <= chi_pred_int_3_x_pos; chi_pred_3_x_vel <= chi_pred_int_3_x_vel;
                        chi_pred_3_y_pos <= chi_pred_int_3_y_pos; chi_pred_3_y_vel <= chi_pred_int_3_y_vel;
                        chi_pred_3_z_pos <= chi_pred_int_3_z_pos; chi_pred_3_z_vel <= chi_pred_int_3_z_vel;
                        chi_pred_4_x_pos <= chi_pred_int_4_x_pos; chi_pred_4_x_vel <= chi_pred_int_4_x_vel;
                        chi_pred_4_y_pos <= chi_pred_int_4_y_pos; chi_pred_4_y_vel <= chi_pred_int_4_y_vel;
                        chi_pred_4_z_pos <= chi_pred_int_4_z_pos; chi_pred_4_z_vel <= chi_pred_int_4_z_vel;
                        chi_pred_5_x_pos <= chi_pred_int_5_x_pos; chi_pred_5_x_vel <= chi_pred_int_5_x_vel;
                        chi_pred_5_y_pos <= chi_pred_int_5_y_pos; chi_pred_5_y_vel <= chi_pred_int_5_y_vel;
                        chi_pred_5_z_pos <= chi_pred_int_5_z_pos; chi_pred_5_z_vel <= chi_pred_int_5_z_vel;
                        chi_pred_6_x_pos <= chi_pred_int_6_x_pos; chi_pred_6_x_vel <= chi_pred_int_6_x_vel;
                        chi_pred_6_y_pos <= chi_pred_int_6_y_pos; chi_pred_6_y_vel <= chi_pred_int_6_y_vel;
                        chi_pred_6_z_pos <= chi_pred_int_6_z_pos; chi_pred_6_z_vel <= chi_pred_int_6_z_vel;
                        chi_pred_7_x_pos <= chi_pred_int_7_x_pos; chi_pred_7_x_vel <= chi_pred_int_7_x_vel;
                        chi_pred_7_y_pos <= chi_pred_int_7_y_pos; chi_pred_7_y_vel <= chi_pred_int_7_y_vel;
                        chi_pred_7_z_pos <= chi_pred_int_7_z_pos; chi_pred_7_z_vel <= chi_pred_int_7_z_vel;
                        chi_pred_8_x_pos <= chi_pred_int_8_x_pos; chi_pred_8_x_vel <= chi_pred_int_8_x_vel;
                        chi_pred_8_y_pos <= chi_pred_int_8_y_pos; chi_pred_8_y_vel <= chi_pred_int_8_y_vel;
                        chi_pred_8_z_pos <= chi_pred_int_8_z_pos; chi_pred_8_z_vel <= chi_pred_int_8_z_vel;
                        chi_pred_9_x_pos <= chi_pred_int_9_x_pos; chi_pred_9_x_vel <= chi_pred_int_9_x_vel;
                        chi_pred_9_y_pos <= chi_pred_int_9_y_pos; chi_pred_9_y_vel <= chi_pred_int_9_y_vel;
                        chi_pred_9_z_pos <= chi_pred_int_9_z_pos; chi_pred_9_z_vel <= chi_pred_int_9_z_vel;
                        chi_pred_10_x_pos <= chi_pred_int_10_x_pos; chi_pred_10_x_vel <= chi_pred_int_10_x_vel;
                        chi_pred_10_y_pos <= chi_pred_int_10_y_pos; chi_pred_10_y_vel <= chi_pred_int_10_y_vel;
                        chi_pred_10_z_pos <= chi_pred_int_10_z_pos; chi_pred_10_z_vel <= chi_pred_int_10_z_vel;
                        chi_pred_11_x_pos <= chi_pred_int_11_x_pos; chi_pred_11_x_vel <= chi_pred_int_11_x_vel;
                        chi_pred_11_y_pos <= chi_pred_int_11_y_pos; chi_pred_11_y_vel <= chi_pred_int_11_y_vel;
                        chi_pred_11_z_pos <= chi_pred_int_11_z_pos; chi_pred_11_z_vel <= chi_pred_int_11_z_vel;
                        chi_pred_12_x_pos <= chi_pred_int_12_x_pos; chi_pred_12_x_vel <= chi_pred_int_12_x_vel;
                        chi_pred_12_y_pos <= chi_pred_int_12_y_pos; chi_pred_12_y_vel <= chi_pred_int_12_y_vel;
                        chi_pred_12_z_pos <= chi_pred_int_12_z_pos; chi_pred_12_z_vel <= chi_pred_int_12_z_vel;
                        state <= FINISHED;
                    end if;
                when FINISHED =>
                    done <= '1';
                    if start = '0' then
                        state <= IDLE;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
