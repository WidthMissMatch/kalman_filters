library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity measurement_update_3d is
    port (
        clk   : in  std_logic;
        start : in  std_logic;

        z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);

        x_pos_pred, x_vel_pred : in signed(47 downto 0);
        y_pos_pred, y_vel_pred : in signed(47 downto 0);
        z_pos_pred, z_vel_pred : in signed(47 downto 0);

        p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred : in signed(47 downto 0);
        p22_pred, p23_pred, p24_pred, p25_pred, p26_pred           : in signed(47 downto 0);
        p33_pred, p34_pred, p35_pred, p36_pred                     : in signed(47 downto 0);
        p44_pred, p45_pred, p46_pred                               : in signed(47 downto 0);
        p55_pred, p56_pred                                         : in signed(47 downto 0);
        p66_pred                                                   : in signed(47 downto 0);

        chi_pred_0_x_pos, chi_pred_0_x_vel, chi_pred_0_y_pos, chi_pred_0_y_vel, chi_pred_0_z_pos, chi_pred_0_z_vel : in signed(47 downto 0);
        chi_pred_1_x_pos, chi_pred_1_x_vel, chi_pred_1_y_pos, chi_pred_1_y_vel, chi_pred_1_z_pos, chi_pred_1_z_vel : in signed(47 downto 0);
        chi_pred_2_x_pos, chi_pred_2_x_vel, chi_pred_2_y_pos, chi_pred_2_y_vel, chi_pred_2_z_pos, chi_pred_2_z_vel : in signed(47 downto 0);
        chi_pred_3_x_pos, chi_pred_3_x_vel, chi_pred_3_y_pos, chi_pred_3_y_vel, chi_pred_3_z_pos, chi_pred_3_z_vel : in signed(47 downto 0);
        chi_pred_4_x_pos, chi_pred_4_x_vel, chi_pred_4_y_pos, chi_pred_4_y_vel, chi_pred_4_z_pos, chi_pred_4_z_vel : in signed(47 downto 0);
        chi_pred_5_x_pos, chi_pred_5_x_vel, chi_pred_5_y_pos, chi_pred_5_y_vel, chi_pred_5_z_pos, chi_pred_5_z_vel : in signed(47 downto 0);
        chi_pred_6_x_pos, chi_pred_6_x_vel, chi_pred_6_y_pos, chi_pred_6_y_vel, chi_pred_6_z_pos, chi_pred_6_z_vel : in signed(47 downto 0);
        chi_pred_7_x_pos, chi_pred_7_x_vel, chi_pred_7_y_pos, chi_pred_7_y_vel, chi_pred_7_z_pos, chi_pred_7_z_vel : in signed(47 downto 0);
        chi_pred_8_x_pos, chi_pred_8_x_vel, chi_pred_8_y_pos, chi_pred_8_y_vel, chi_pred_8_z_pos, chi_pred_8_z_vel : in signed(47 downto 0);
        chi_pred_9_x_pos, chi_pred_9_x_vel, chi_pred_9_y_pos, chi_pred_9_y_vel, chi_pred_9_z_pos, chi_pred_9_z_vel : in signed(47 downto 0);
        chi_pred_10_x_pos, chi_pred_10_x_vel, chi_pred_10_y_pos, chi_pred_10_y_vel, chi_pred_10_z_pos, chi_pred_10_z_vel : in signed(47 downto 0);
        chi_pred_11_x_pos, chi_pred_11_x_vel, chi_pred_11_y_pos, chi_pred_11_y_vel, chi_pred_11_z_pos, chi_pred_11_z_vel : in signed(47 downto 0);
        chi_pred_12_x_pos, chi_pred_12_x_vel, chi_pred_12_y_pos, chi_pred_12_y_vel, chi_pred_12_z_pos, chi_pred_12_z_vel : in signed(47 downto 0);

        x_pos_upd, x_vel_upd : out signed(47 downto 0);
        y_pos_upd, y_vel_upd : out signed(47 downto 0);
        z_pos_upd, z_vel_upd : out signed(47 downto 0);

        p11_upd, p12_upd, p13_upd, p14_upd, p15_upd, p16_upd : out signed(47 downto 0);
        p22_upd, p23_upd, p24_upd, p25_upd, p26_upd           : out signed(47 downto 0);
        p33_upd, p34_upd, p35_upd, p36_upd                    : out signed(47 downto 0);
        p44_upd, p45_upd, p46_upd                             : out signed(47 downto 0);
        p55_upd, p56_upd                                      : out signed(47 downto 0);
        p66_upd                                               : out signed(47 downto 0);

        done : out std_logic
    );
end measurement_update_3d;

architecture Behavioral of measurement_update_3d is

    component measurement_mean_3d is
        port (
            clk : in std_logic; start : in std_logic;
            chi0_x_pos, chi0_y_pos, chi0_z_pos : in signed(47 downto 0);
            chi1_x_pos, chi1_y_pos, chi1_z_pos : in signed(47 downto 0);
            chi2_x_pos, chi2_y_pos, chi2_z_pos : in signed(47 downto 0);
            chi3_x_pos, chi3_y_pos, chi3_z_pos : in signed(47 downto 0);
            chi4_x_pos, chi4_y_pos, chi4_z_pos : in signed(47 downto 0);
            chi5_x_pos, chi5_y_pos, chi5_z_pos : in signed(47 downto 0);
            chi6_x_pos, chi6_y_pos, chi6_z_pos : in signed(47 downto 0);
            chi7_x_pos, chi7_y_pos, chi7_z_pos : in signed(47 downto 0);
            chi8_x_pos, chi8_y_pos, chi8_z_pos : in signed(47 downto 0);
            chi9_x_pos, chi9_y_pos, chi9_z_pos : in signed(47 downto 0);
            chi10_x_pos, chi10_y_pos, chi10_z_pos : in signed(47 downto 0);
            chi11_x_pos, chi11_y_pos, chi11_z_pos : in signed(47 downto 0);
            chi12_x_pos, chi12_y_pos, chi12_z_pos : in signed(47 downto 0);
            z_x_mean, z_y_mean, z_z_mean : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    component innovation_3d is
        port (
            clk : in std_logic; start : in std_logic;
            z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);
            z_x_mean, z_y_mean, z_z_mean : in signed(47 downto 0);
            nu_x, nu_y, nu_z : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    component cross_covariance_3d is
        port (
            clk : in std_logic; start : in std_logic;
            x_pos_mean, x_vel_mean, y_pos_mean, y_vel_mean, z_pos_mean, z_vel_mean : in signed(47 downto 0);
            z_x_mean, z_y_mean, z_z_mean : in signed(47 downto 0);
            chi0_x_pos, chi0_x_vel, chi0_y_pos, chi0_y_vel, chi0_z_pos, chi0_z_vel : in signed(47 downto 0);
            chi1_x_pos, chi1_x_vel, chi1_y_pos, chi1_y_vel, chi1_z_pos, chi1_z_vel : in signed(47 downto 0);
            chi2_x_pos, chi2_x_vel, chi2_y_pos, chi2_y_vel, chi2_z_pos, chi2_z_vel : in signed(47 downto 0);
            chi3_x_pos, chi3_x_vel, chi3_y_pos, chi3_y_vel, chi3_z_pos, chi3_z_vel : in signed(47 downto 0);
            chi4_x_pos, chi4_x_vel, chi4_y_pos, chi4_y_vel, chi4_z_pos, chi4_z_vel : in signed(47 downto 0);
            chi5_x_pos, chi5_x_vel, chi5_y_pos, chi5_y_vel, chi5_z_pos, chi5_z_vel : in signed(47 downto 0);
            chi6_x_pos, chi6_x_vel, chi6_y_pos, chi6_y_vel, chi6_z_pos, chi6_z_vel : in signed(47 downto 0);
            chi7_x_pos, chi7_x_vel, chi7_y_pos, chi7_y_vel, chi7_z_pos, chi7_z_vel : in signed(47 downto 0);
            chi8_x_pos, chi8_x_vel, chi8_y_pos, chi8_y_vel, chi8_z_pos, chi8_z_vel : in signed(47 downto 0);
            chi9_x_pos, chi9_x_vel, chi9_y_pos, chi9_y_vel, chi9_z_pos, chi9_z_vel : in signed(47 downto 0);
            chi10_x_pos, chi10_x_vel, chi10_y_pos, chi10_y_vel, chi10_z_pos, chi10_z_vel : in signed(47 downto 0);
            chi11_x_pos, chi11_x_vel, chi11_y_pos, chi11_y_vel, chi11_z_pos, chi11_z_vel : in signed(47 downto 0);
            chi12_x_pos, chi12_x_vel, chi12_y_pos, chi12_y_vel, chi12_z_pos, chi12_z_vel : in signed(47 downto 0);
            pxz_11, pxz_12, pxz_13 : out signed(47 downto 0);
            pxz_21, pxz_22, pxz_23 : out signed(47 downto 0);
            pxz_31, pxz_32, pxz_33 : out signed(47 downto 0);
            pxz_41, pxz_42, pxz_43 : out signed(47 downto 0);
            pxz_51, pxz_52, pxz_53 : out signed(47 downto 0);
            pxz_61, pxz_62, pxz_63 : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    component innovation_covariance_3d is
        port (
            clk : in std_logic; start : in std_logic;
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
            s11, s12, s22, s13, s23, s33 : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    component kalman_gain_3d is
        port (
            clk : in std_logic; start : in std_logic;
            pxz_11, pxz_12, pxz_13 : in signed(47 downto 0);
            pxz_21, pxz_22, pxz_23 : in signed(47 downto 0);
            pxz_31, pxz_32, pxz_33 : in signed(47 downto 0);
            pxz_41, pxz_42, pxz_43 : in signed(47 downto 0);
            pxz_51, pxz_52, pxz_53 : in signed(47 downto 0);
            pxz_61, pxz_62, pxz_63 : in signed(47 downto 0);
            s11, s12, s22, s13, s23, s33 : in signed(47 downto 0);
            k11, k12, k13 : out signed(47 downto 0);
            k21, k22, k23 : out signed(47 downto 0);
            k31, k32, k33 : out signed(47 downto 0);
            k41, k42, k43 : out signed(47 downto 0);
            k51, k52, k53 : out signed(47 downto 0);
            k61, k62, k63 : out signed(47 downto 0);
            error : out std_logic;
            done : out std_logic
        );
    end component;

    component state_update_3d is
        port (
            clk : in std_logic; start : in std_logic;
            x_pos_pred, x_vel_pred, y_pos_pred, y_vel_pred, z_pos_pred, z_vel_pred : in signed(47 downto 0);
            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred : in signed(47 downto 0);
            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred : in signed(47 downto 0);
            p33_pred, p34_pred, p35_pred, p36_pred : in signed(47 downto 0);
            p44_pred, p45_pred, p46_pred : in signed(47 downto 0);
            p55_pred, p56_pred : in signed(47 downto 0);
            p66_pred : in signed(47 downto 0);
            k11, k12, k13 : in signed(47 downto 0);
            k21, k22, k23 : in signed(47 downto 0);
            k31, k32, k33 : in signed(47 downto 0);
            k41, k42, k43 : in signed(47 downto 0);
            k51, k52, k53 : in signed(47 downto 0);
            k61, k62, k63 : in signed(47 downto 0);
            nu_x, nu_y, nu_z : in signed(47 downto 0);
            x_pos_upd, x_vel_upd, y_pos_upd, y_vel_upd, z_pos_upd, z_vel_upd : out signed(47 downto 0);
            p11_upd, p12_upd, p13_upd, p14_upd, p15_upd, p16_upd : out signed(47 downto 0);
            p22_upd, p23_upd, p24_upd, p25_upd, p26_upd : out signed(47 downto 0);
            p33_upd, p34_upd, p35_upd, p36_upd : out signed(47 downto 0);
            p44_upd, p45_upd, p46_upd : out signed(47 downto 0);
            p55_upd, p56_upd : out signed(47 downto 0);
            p66_upd : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    type state_type is (IDLE, RUN_MEAS_MEAN, WAIT_MEAS_MEAN,
                        RUN_INNOVATION, WAIT_INNOVATION,
                        RUN_CROSS_COV, WAIT_CROSS_COV,
                        RUN_INNOV_COV, WAIT_INNOV_COV,
                        RUN_GAIN, WAIT_GAIN,
                        RUN_UPDATE, WAIT_UPDATE, FINISHED);
    signal state : state_type := IDLE;

    signal meas_mean_start, meas_mean_done : std_logic;
    signal innov_start, innov_done : std_logic;
    signal cross_cov_start, cross_cov_done : std_logic;
    signal innov_cov_start, innov_cov_done : std_logic;
    signal gain_start, gain_done, gain_error : std_logic;
    signal update_start, update_done : std_logic;

    signal z_x_mean, z_y_mean, z_z_mean : signed(47 downto 0);
    signal nu_x, nu_y, nu_z : signed(47 downto 0);
    signal pxz_11, pxz_12, pxz_13 : signed(47 downto 0);
    signal pxz_21, pxz_22, pxz_23 : signed(47 downto 0);
    signal pxz_31, pxz_32, pxz_33 : signed(47 downto 0);
    signal pxz_41, pxz_42, pxz_43 : signed(47 downto 0);
    signal pxz_51, pxz_52, pxz_53 : signed(47 downto 0);
    signal pxz_61, pxz_62, pxz_63 : signed(47 downto 0);
    signal s11, s12, s22, s13, s23, s33 : signed(47 downto 0);
    signal k11, k12, k13 : signed(47 downto 0);
    signal k21, k22, k23 : signed(47 downto 0);
    signal k31, k32, k33 : signed(47 downto 0);
    signal k41, k42, k43 : signed(47 downto 0);
    signal k51, k52, k53 : signed(47 downto 0);
    signal k61, k62, k63 : signed(47 downto 0);

begin

    meas_mean_inst : measurement_mean_3d
        port map (
            clk => clk, start => meas_mean_start,
            chi0_x_pos => chi_pred_0_x_pos, chi0_y_pos => chi_pred_0_y_pos, chi0_z_pos => chi_pred_0_z_pos,
            chi1_x_pos => chi_pred_1_x_pos, chi1_y_pos => chi_pred_1_y_pos, chi1_z_pos => chi_pred_1_z_pos,
            chi2_x_pos => chi_pred_2_x_pos, chi2_y_pos => chi_pred_2_y_pos, chi2_z_pos => chi_pred_2_z_pos,
            chi3_x_pos => chi_pred_3_x_pos, chi3_y_pos => chi_pred_3_y_pos, chi3_z_pos => chi_pred_3_z_pos,
            chi4_x_pos => chi_pred_4_x_pos, chi4_y_pos => chi_pred_4_y_pos, chi4_z_pos => chi_pred_4_z_pos,
            chi5_x_pos => chi_pred_5_x_pos, chi5_y_pos => chi_pred_5_y_pos, chi5_z_pos => chi_pred_5_z_pos,
            chi6_x_pos => chi_pred_6_x_pos, chi6_y_pos => chi_pred_6_y_pos, chi6_z_pos => chi_pred_6_z_pos,
            chi7_x_pos => chi_pred_7_x_pos, chi7_y_pos => chi_pred_7_y_pos, chi7_z_pos => chi_pred_7_z_pos,
            chi8_x_pos => chi_pred_8_x_pos, chi8_y_pos => chi_pred_8_y_pos, chi8_z_pos => chi_pred_8_z_pos,
            chi9_x_pos => chi_pred_9_x_pos, chi9_y_pos => chi_pred_9_y_pos, chi9_z_pos => chi_pred_9_z_pos,
            chi10_x_pos => chi_pred_10_x_pos, chi10_y_pos => chi_pred_10_y_pos, chi10_z_pos => chi_pred_10_z_pos,
            chi11_x_pos => chi_pred_11_x_pos, chi11_y_pos => chi_pred_11_y_pos, chi11_z_pos => chi_pred_11_z_pos,
            chi12_x_pos => chi_pred_12_x_pos, chi12_y_pos => chi_pred_12_y_pos, chi12_z_pos => chi_pred_12_z_pos,
            z_x_mean => z_x_mean, z_y_mean => z_y_mean, z_z_mean => z_z_mean,
            done => meas_mean_done
        );

    innov_inst : innovation_3d
        port map (
            clk => clk, start => innov_start,
            z_x_meas => z_x_meas, z_y_meas => z_y_meas, z_z_meas => z_z_meas,
            z_x_mean => z_x_mean, z_y_mean => z_y_mean, z_z_mean => z_z_mean,
            nu_x => nu_x, nu_y => nu_y, nu_z => nu_z,
            done => innov_done
        );

    cross_cov_inst : cross_covariance_3d
        port map (
            clk => clk, start => cross_cov_start,
            x_pos_mean => x_pos_pred, x_vel_mean => x_vel_pred,
            y_pos_mean => y_pos_pred, y_vel_mean => y_vel_pred,
            z_pos_mean => z_pos_pred, z_vel_mean => z_vel_pred,
            z_x_mean => z_x_mean, z_y_mean => z_y_mean, z_z_mean => z_z_mean,
            chi0_x_pos => chi_pred_0_x_pos, chi0_x_vel => chi_pred_0_x_vel, chi0_y_pos => chi_pred_0_y_pos, chi0_y_vel => chi_pred_0_y_vel, chi0_z_pos => chi_pred_0_z_pos, chi0_z_vel => chi_pred_0_z_vel,
            chi1_x_pos => chi_pred_1_x_pos, chi1_x_vel => chi_pred_1_x_vel, chi1_y_pos => chi_pred_1_y_pos, chi1_y_vel => chi_pred_1_y_vel, chi1_z_pos => chi_pred_1_z_pos, chi1_z_vel => chi_pred_1_z_vel,
            chi2_x_pos => chi_pred_2_x_pos, chi2_x_vel => chi_pred_2_x_vel, chi2_y_pos => chi_pred_2_y_pos, chi2_y_vel => chi_pred_2_y_vel, chi2_z_pos => chi_pred_2_z_pos, chi2_z_vel => chi_pred_2_z_vel,
            chi3_x_pos => chi_pred_3_x_pos, chi3_x_vel => chi_pred_3_x_vel, chi3_y_pos => chi_pred_3_y_pos, chi3_y_vel => chi_pred_3_y_vel, chi3_z_pos => chi_pred_3_z_pos, chi3_z_vel => chi_pred_3_z_vel,
            chi4_x_pos => chi_pred_4_x_pos, chi4_x_vel => chi_pred_4_x_vel, chi4_y_pos => chi_pred_4_y_pos, chi4_y_vel => chi_pred_4_y_vel, chi4_z_pos => chi_pred_4_z_pos, chi4_z_vel => chi_pred_4_z_vel,
            chi5_x_pos => chi_pred_5_x_pos, chi5_x_vel => chi_pred_5_x_vel, chi5_y_pos => chi_pred_5_y_pos, chi5_y_vel => chi_pred_5_y_vel, chi5_z_pos => chi_pred_5_z_pos, chi5_z_vel => chi_pred_5_z_vel,
            chi6_x_pos => chi_pred_6_x_pos, chi6_x_vel => chi_pred_6_x_vel, chi6_y_pos => chi_pred_6_y_pos, chi6_y_vel => chi_pred_6_y_vel, chi6_z_pos => chi_pred_6_z_pos, chi6_z_vel => chi_pred_6_z_vel,
            chi7_x_pos => chi_pred_7_x_pos, chi7_x_vel => chi_pred_7_x_vel, chi7_y_pos => chi_pred_7_y_pos, chi7_y_vel => chi_pred_7_y_vel, chi7_z_pos => chi_pred_7_z_pos, chi7_z_vel => chi_pred_7_z_vel,
            chi8_x_pos => chi_pred_8_x_pos, chi8_x_vel => chi_pred_8_x_vel, chi8_y_pos => chi_pred_8_y_pos, chi8_y_vel => chi_pred_8_y_vel, chi8_z_pos => chi_pred_8_z_pos, chi8_z_vel => chi_pred_8_z_vel,
            chi9_x_pos => chi_pred_9_x_pos, chi9_x_vel => chi_pred_9_x_vel, chi9_y_pos => chi_pred_9_y_pos, chi9_y_vel => chi_pred_9_y_vel, chi9_z_pos => chi_pred_9_z_pos, chi9_z_vel => chi_pred_9_z_vel,
            chi10_x_pos => chi_pred_10_x_pos, chi10_x_vel => chi_pred_10_x_vel, chi10_y_pos => chi_pred_10_y_pos, chi10_y_vel => chi_pred_10_y_vel, chi10_z_pos => chi_pred_10_z_pos, chi10_z_vel => chi_pred_10_z_vel,
            chi11_x_pos => chi_pred_11_x_pos, chi11_x_vel => chi_pred_11_x_vel, chi11_y_pos => chi_pred_11_y_pos, chi11_y_vel => chi_pred_11_y_vel, chi11_z_pos => chi_pred_11_z_pos, chi11_z_vel => chi_pred_11_z_vel,
            chi12_x_pos => chi_pred_12_x_pos, chi12_x_vel => chi_pred_12_x_vel, chi12_y_pos => chi_pred_12_y_pos, chi12_y_vel => chi_pred_12_y_vel, chi12_z_pos => chi_pred_12_z_pos, chi12_z_vel => chi_pred_12_z_vel,
            pxz_11 => pxz_11, pxz_12 => pxz_12, pxz_13 => pxz_13,
            pxz_21 => pxz_21, pxz_22 => pxz_22, pxz_23 => pxz_23,
            pxz_31 => pxz_31, pxz_32 => pxz_32, pxz_33 => pxz_33,
            pxz_41 => pxz_41, pxz_42 => pxz_42, pxz_43 => pxz_43,
            pxz_51 => pxz_51, pxz_52 => pxz_52, pxz_53 => pxz_53,
            pxz_61 => pxz_61, pxz_62 => pxz_62, pxz_63 => pxz_63,
            done => cross_cov_done
        );

    innov_cov_inst : innovation_covariance_3d
        port map (
            clk => clk, start => innov_cov_start,
            z_x_mean => z_x_mean, z_y_mean => z_y_mean, z_z_mean => z_z_mean,
            chi0_z_x => chi_pred_0_x_pos, chi0_z_y => chi_pred_0_y_pos, chi0_z_z => chi_pred_0_z_pos,
            chi1_z_x => chi_pred_1_x_pos, chi1_z_y => chi_pred_1_y_pos, chi1_z_z => chi_pred_1_z_pos,
            chi2_z_x => chi_pred_2_x_pos, chi2_z_y => chi_pred_2_y_pos, chi2_z_z => chi_pred_2_z_pos,
            chi3_z_x => chi_pred_3_x_pos, chi3_z_y => chi_pred_3_y_pos, chi3_z_z => chi_pred_3_z_pos,
            chi4_z_x => chi_pred_4_x_pos, chi4_z_y => chi_pred_4_y_pos, chi4_z_z => chi_pred_4_z_pos,
            chi5_z_x => chi_pred_5_x_pos, chi5_z_y => chi_pred_5_y_pos, chi5_z_z => chi_pred_5_z_pos,
            chi6_z_x => chi_pred_6_x_pos, chi6_z_y => chi_pred_6_y_pos, chi6_z_z => chi_pred_6_z_pos,
            chi7_z_x => chi_pred_7_x_pos, chi7_z_y => chi_pred_7_y_pos, chi7_z_z => chi_pred_7_z_pos,
            chi8_z_x => chi_pred_8_x_pos, chi8_z_y => chi_pred_8_y_pos, chi8_z_z => chi_pred_8_z_pos,
            chi9_z_x => chi_pred_9_x_pos, chi9_z_y => chi_pred_9_y_pos, chi9_z_z => chi_pred_9_z_pos,
            chi10_z_x => chi_pred_10_x_pos, chi10_z_y => chi_pred_10_y_pos, chi10_z_z => chi_pred_10_z_pos,
            chi11_z_x => chi_pred_11_x_pos, chi11_z_y => chi_pred_11_y_pos, chi11_z_z => chi_pred_11_z_pos,
            chi12_z_x => chi_pred_12_x_pos, chi12_z_y => chi_pred_12_y_pos, chi12_z_z => chi_pred_12_z_pos,
            s11 => s11, s12 => s12, s22 => s22, s13 => s13, s23 => s23, s33 => s33,
            done => innov_cov_done
        );

    gain_inst : kalman_gain_3d
        port map (
            clk => clk, start => gain_start,
            pxz_11 => pxz_11, pxz_12 => pxz_12, pxz_13 => pxz_13,
            pxz_21 => pxz_21, pxz_22 => pxz_22, pxz_23 => pxz_23,
            pxz_31 => pxz_31, pxz_32 => pxz_32, pxz_33 => pxz_33,
            pxz_41 => pxz_41, pxz_42 => pxz_42, pxz_43 => pxz_43,
            pxz_51 => pxz_51, pxz_52 => pxz_52, pxz_53 => pxz_53,
            pxz_61 => pxz_61, pxz_62 => pxz_62, pxz_63 => pxz_63,
            s11 => s11, s12 => s12, s22 => s22, s13 => s13, s23 => s23, s33 => s33,
            k11 => k11, k12 => k12, k13 => k13,
            k21 => k21, k22 => k22, k23 => k23,
            k31 => k31, k32 => k32, k33 => k33,
            k41 => k41, k42 => k42, k43 => k43,
            k51 => k51, k52 => k52, k53 => k53,
            k61 => k61, k62 => k62, k63 => k63,
            error => gain_error,
            done => gain_done
        );

    update_inst : state_update_3d
        port map (
            clk => clk, start => update_start,
            x_pos_pred => x_pos_pred, x_vel_pred => x_vel_pred,
            y_pos_pred => y_pos_pred, y_vel_pred => y_vel_pred,
            z_pos_pred => z_pos_pred, z_vel_pred => z_vel_pred,
            p11_pred => p11_pred, p12_pred => p12_pred, p13_pred => p13_pred, p14_pred => p14_pred, p15_pred => p15_pred, p16_pred => p16_pred,
            p22_pred => p22_pred, p23_pred => p23_pred, p24_pred => p24_pred, p25_pred => p25_pred, p26_pred => p26_pred,
            p33_pred => p33_pred, p34_pred => p34_pred, p35_pred => p35_pred, p36_pred => p36_pred,
            p44_pred => p44_pred, p45_pred => p45_pred, p46_pred => p46_pred,
            p55_pred => p55_pred, p56_pred => p56_pred,
            p66_pred => p66_pred,
            k11 => k11, k12 => k12, k13 => k13,
            k21 => k21, k22 => k22, k23 => k23,
            k31 => k31, k32 => k32, k33 => k33,
            k41 => k41, k42 => k42, k43 => k43,
            k51 => k51, k52 => k52, k53 => k53,
            k61 => k61, k62 => k62, k63 => k63,
            nu_x => nu_x, nu_y => nu_y, nu_z => nu_z,
            x_pos_upd => x_pos_upd, x_vel_upd => x_vel_upd,
            y_pos_upd => y_pos_upd, y_vel_upd => y_vel_upd,
            z_pos_upd => z_pos_upd, z_vel_upd => z_vel_upd,
            p11_upd => p11_upd, p12_upd => p12_upd, p13_upd => p13_upd, p14_upd => p14_upd, p15_upd => p15_upd, p16_upd => p16_upd,
            p22_upd => p22_upd, p23_upd => p23_upd, p24_upd => p24_upd, p25_upd => p25_upd, p26_upd => p26_upd,
            p33_upd => p33_upd, p34_upd => p34_upd, p35_upd => p35_upd, p36_upd => p36_upd,
            p44_upd => p44_upd, p45_upd => p45_upd, p46_upd => p46_upd,
            p55_upd => p55_upd, p56_upd => p56_upd,
            p66_upd => p66_upd,
            done => update_done
        );

    process(clk)
    begin
        if rising_edge(clk) then
            case state is

                when IDLE =>
                    done <= '0';
                    meas_mean_start <= '0';
                    innov_start <= '0';
                    cross_cov_start <= '0';
                    innov_cov_start <= '0';
                    gain_start <= '0';
                    update_start <= '0';

                    if start = '1' then
                        state <= RUN_MEAS_MEAN;
                    end if;

                when RUN_MEAS_MEAN =>
                    report "MEAS_UPDATE: RUN_MEAS_MEAN";
                    meas_mean_start <= '1';
                    state <= WAIT_MEAS_MEAN;

                when WAIT_MEAS_MEAN =>
                    meas_mean_start <= '0';
                    if meas_mean_done = '1' then
                        state <= RUN_INNOVATION;
                    end if;

                when RUN_INNOVATION =>
                    report "MEAS_UPDATE: RUN_INNOVATION";
                    innov_start <= '1';
                    state <= WAIT_INNOVATION;

                when WAIT_INNOVATION =>
                    innov_start <= '0';
                    if innov_done = '1' then
                        state <= RUN_CROSS_COV;
                    end if;

                when RUN_CROSS_COV =>
                    report "MEAS_UPDATE: RUN_CROSS_COV";
                    cross_cov_start <= '1';
                    state <= WAIT_CROSS_COV;

                when WAIT_CROSS_COV =>
                    cross_cov_start <= '0';
                    if cross_cov_done = '1' then
                        state <= RUN_INNOV_COV;
                    end if;

                when RUN_INNOV_COV =>
                    report "MEAS_UPDATE: RUN_INNOV_COV";
                    innov_cov_start <= '1';
                    state <= WAIT_INNOV_COV;

                when WAIT_INNOV_COV =>
                    innov_cov_start <= '0';
                    if innov_cov_done = '1' then
                        state <= RUN_GAIN;
                    end if;

                when RUN_GAIN =>
                    report "MEAS_UPDATE: RUN_GAIN";
                    gain_start <= '1';
                    state <= WAIT_GAIN;

                when WAIT_GAIN =>
                    gain_start <= '0';
                    if gain_done = '1' then
                        state <= RUN_UPDATE;
                    end if;

                when RUN_UPDATE =>
                    report "MEAS_UPDATE: RUN_UPDATE";
                    update_start <= '1';
                    state <= WAIT_UPDATE;

                when WAIT_UPDATE =>
                    update_start <= '0';
                    if update_done = '1' then
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
