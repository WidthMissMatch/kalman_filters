library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity measurement_update_3d is
    port (
        clk   : in  std_logic;
        start : in  std_logic;

        z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);

        x_pos_pred, x_vel_pred, x_omega_pred : in signed(47 downto 0);
        y_pos_pred, y_vel_pred, y_omega_pred : in signed(47 downto 0);
        z_pos_pred, z_vel_pred, z_omega_pred : in signed(47 downto 0);

        p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred : in signed(47 downto 0);
        p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred           : in signed(47 downto 0);
        p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred                     : in signed(47 downto 0);
        p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred                               : in signed(47 downto 0);
        p55_pred, p56_pred, p57_pred, p58_pred, p59_pred                                         : in signed(47 downto 0);
        p66_pred, p67_pred, p68_pred, p69_pred                                                   : in signed(47 downto 0);
        p77_pred, p78_pred, p79_pred                                                             : in signed(47 downto 0);
        p88_pred, p89_pred                                                                       : in signed(47 downto 0);
        p99_pred                                                                                 : in signed(47 downto 0);

        chi_pred_0_x_pos, chi_pred_0_x_vel, chi_pred_0_x_omega, chi_pred_0_y_pos, chi_pred_0_y_vel, chi_pred_0_y_omega, chi_pred_0_z_pos, chi_pred_0_z_vel, chi_pred_0_z_omega : in signed(47 downto 0);
        chi_pred_1_x_pos, chi_pred_1_x_vel, chi_pred_1_x_omega, chi_pred_1_y_pos, chi_pred_1_y_vel, chi_pred_1_y_omega, chi_pred_1_z_pos, chi_pred_1_z_vel, chi_pred_1_z_omega : in signed(47 downto 0);
        chi_pred_2_x_pos, chi_pred_2_x_vel, chi_pred_2_x_omega, chi_pred_2_y_pos, chi_pred_2_y_vel, chi_pred_2_y_omega, chi_pred_2_z_pos, chi_pred_2_z_vel, chi_pred_2_z_omega : in signed(47 downto 0);
        chi_pred_3_x_pos, chi_pred_3_x_vel, chi_pred_3_x_omega, chi_pred_3_y_pos, chi_pred_3_y_vel, chi_pred_3_y_omega, chi_pred_3_z_pos, chi_pred_3_z_vel, chi_pred_3_z_omega : in signed(47 downto 0);
        chi_pred_4_x_pos, chi_pred_4_x_vel, chi_pred_4_x_omega, chi_pred_4_y_pos, chi_pred_4_y_vel, chi_pred_4_y_omega, chi_pred_4_z_pos, chi_pred_4_z_vel, chi_pred_4_z_omega : in signed(47 downto 0);
        chi_pred_5_x_pos, chi_pred_5_x_vel, chi_pred_5_x_omega, chi_pred_5_y_pos, chi_pred_5_y_vel, chi_pred_5_y_omega, chi_pred_5_z_pos, chi_pred_5_z_vel, chi_pred_5_z_omega : in signed(47 downto 0);
        chi_pred_6_x_pos, chi_pred_6_x_vel, chi_pred_6_x_omega, chi_pred_6_y_pos, chi_pred_6_y_vel, chi_pred_6_y_omega, chi_pred_6_z_pos, chi_pred_6_z_vel, chi_pred_6_z_omega : in signed(47 downto 0);
        chi_pred_7_x_pos, chi_pred_7_x_vel, chi_pred_7_x_omega, chi_pred_7_y_pos, chi_pred_7_y_vel, chi_pred_7_y_omega, chi_pred_7_z_pos, chi_pred_7_z_vel, chi_pred_7_z_omega : in signed(47 downto 0);
        chi_pred_8_x_pos, chi_pred_8_x_vel, chi_pred_8_x_omega, chi_pred_8_y_pos, chi_pred_8_y_vel, chi_pred_8_y_omega, chi_pred_8_z_pos, chi_pred_8_z_vel, chi_pred_8_z_omega : in signed(47 downto 0);
        chi_pred_9_x_pos, chi_pred_9_x_vel, chi_pred_9_x_omega, chi_pred_9_y_pos, chi_pred_9_y_vel, chi_pred_9_y_omega, chi_pred_9_z_pos, chi_pred_9_z_vel, chi_pred_9_z_omega : in signed(47 downto 0);
        chi_pred_10_x_pos, chi_pred_10_x_vel, chi_pred_10_x_omega, chi_pred_10_y_pos, chi_pred_10_y_vel, chi_pred_10_y_omega, chi_pred_10_z_pos, chi_pred_10_z_vel, chi_pred_10_z_omega : in signed(47 downto 0);
        chi_pred_11_x_pos, chi_pred_11_x_vel, chi_pred_11_x_omega, chi_pred_11_y_pos, chi_pred_11_y_vel, chi_pred_11_y_omega, chi_pred_11_z_pos, chi_pred_11_z_vel, chi_pred_11_z_omega : in signed(47 downto 0);
        chi_pred_12_x_pos, chi_pred_12_x_vel, chi_pred_12_x_omega, chi_pred_12_y_pos, chi_pred_12_y_vel, chi_pred_12_y_omega, chi_pred_12_z_pos, chi_pred_12_z_vel, chi_pred_12_z_omega : in signed(47 downto 0);
        chi_pred_13_x_pos, chi_pred_13_x_vel, chi_pred_13_x_omega, chi_pred_13_y_pos, chi_pred_13_y_vel, chi_pred_13_y_omega, chi_pred_13_z_pos, chi_pred_13_z_vel, chi_pred_13_z_omega : in signed(47 downto 0);
        chi_pred_14_x_pos, chi_pred_14_x_vel, chi_pred_14_x_omega, chi_pred_14_y_pos, chi_pred_14_y_vel, chi_pred_14_y_omega, chi_pred_14_z_pos, chi_pred_14_z_vel, chi_pred_14_z_omega : in signed(47 downto 0);
        chi_pred_15_x_pos, chi_pred_15_x_vel, chi_pred_15_x_omega, chi_pred_15_y_pos, chi_pred_15_y_vel, chi_pred_15_y_omega, chi_pred_15_z_pos, chi_pred_15_z_vel, chi_pred_15_z_omega : in signed(47 downto 0);
        chi_pred_16_x_pos, chi_pred_16_x_vel, chi_pred_16_x_omega, chi_pred_16_y_pos, chi_pred_16_y_vel, chi_pred_16_y_omega, chi_pred_16_z_pos, chi_pred_16_z_vel, chi_pred_16_z_omega : in signed(47 downto 0);
        chi_pred_17_x_pos, chi_pred_17_x_vel, chi_pred_17_x_omega, chi_pred_17_y_pos, chi_pred_17_y_vel, chi_pred_17_y_omega, chi_pred_17_z_pos, chi_pred_17_z_vel, chi_pred_17_z_omega : in signed(47 downto 0);
        chi_pred_18_x_pos, chi_pred_18_x_vel, chi_pred_18_x_omega, chi_pred_18_y_pos, chi_pred_18_y_vel, chi_pred_18_y_omega, chi_pred_18_z_pos, chi_pred_18_z_vel, chi_pred_18_z_omega : in signed(47 downto 0);

        x_pos_upd, x_vel_upd, x_omega_upd : buffer signed(47 downto 0);
        y_pos_upd, y_vel_upd, y_omega_upd : buffer signed(47 downto 0);
        z_pos_upd, z_vel_upd, z_omega_upd : buffer signed(47 downto 0);

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
            chi13_x_pos, chi13_y_pos, chi13_z_pos : in signed(47 downto 0);
            chi14_x_pos, chi14_y_pos, chi14_z_pos : in signed(47 downto 0);
            chi15_x_pos, chi15_y_pos, chi15_z_pos : in signed(47 downto 0);
            chi16_x_pos, chi16_y_pos, chi16_z_pos : in signed(47 downto 0);
            chi17_x_pos, chi17_y_pos, chi17_z_pos : in signed(47 downto 0);
            chi18_x_pos, chi18_y_pos, chi18_z_pos : in signed(47 downto 0);
            z_x_mean, z_y_mean, z_z_mean : buffer signed(47 downto 0);
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

            x_pos_mean, x_vel_mean, x_omega_mean : in signed(47 downto 0);
            y_pos_mean, y_vel_mean, y_omega_mean : in signed(47 downto 0);
            z_pos_mean, z_vel_mean, z_omega_mean : in signed(47 downto 0);

            z_x_mean, z_y_mean, z_z_mean : in signed(47 downto 0);

            chi0_x_pos, chi0_x_vel, chi0_x_omega, chi0_y_pos, chi0_y_vel, chi0_y_omega, chi0_z_pos, chi0_z_vel, chi0_z_omega : in signed(47 downto 0);
            chi1_x_pos, chi1_x_vel, chi1_x_omega, chi1_y_pos, chi1_y_vel, chi1_y_omega, chi1_z_pos, chi1_z_vel, chi1_z_omega : in signed(47 downto 0);
            chi2_x_pos, chi2_x_vel, chi2_x_omega, chi2_y_pos, chi2_y_vel, chi2_y_omega, chi2_z_pos, chi2_z_vel, chi2_z_omega : in signed(47 downto 0);
            chi3_x_pos, chi3_x_vel, chi3_x_omega, chi3_y_pos, chi3_y_vel, chi3_y_omega, chi3_z_pos, chi3_z_vel, chi3_z_omega : in signed(47 downto 0);
            chi4_x_pos, chi4_x_vel, chi4_x_omega, chi4_y_pos, chi4_y_vel, chi4_y_omega, chi4_z_pos, chi4_z_vel, chi4_z_omega : in signed(47 downto 0);
            chi5_x_pos, chi5_x_vel, chi5_x_omega, chi5_y_pos, chi5_y_vel, chi5_y_omega, chi5_z_pos, chi5_z_vel, chi5_z_omega : in signed(47 downto 0);
            chi6_x_pos, chi6_x_vel, chi6_x_omega, chi6_y_pos, chi6_y_vel, chi6_y_omega, chi6_z_pos, chi6_z_vel, chi6_z_omega : in signed(47 downto 0);
            chi7_x_pos, chi7_x_vel, chi7_x_omega, chi7_y_pos, chi7_y_vel, chi7_y_omega, chi7_z_pos, chi7_z_vel, chi7_z_omega : in signed(47 downto 0);
            chi8_x_pos, chi8_x_vel, chi8_x_omega, chi8_y_pos, chi8_y_vel, chi8_y_omega, chi8_z_pos, chi8_z_vel, chi8_z_omega : in signed(47 downto 0);
            chi9_x_pos, chi9_x_vel, chi9_x_omega, chi9_y_pos, chi9_y_vel, chi9_y_omega, chi9_z_pos, chi9_z_vel, chi9_z_omega : in signed(47 downto 0);
            chi10_x_pos, chi10_x_vel, chi10_x_omega, chi10_y_pos, chi10_y_vel, chi10_y_omega, chi10_z_pos, chi10_z_vel, chi10_z_omega : in signed(47 downto 0);
            chi11_x_pos, chi11_x_vel, chi11_x_omega, chi11_y_pos, chi11_y_vel, chi11_y_omega, chi11_z_pos, chi11_z_vel, chi11_z_omega : in signed(47 downto 0);
            chi12_x_pos, chi12_x_vel, chi12_x_omega, chi12_y_pos, chi12_y_vel, chi12_y_omega, chi12_z_pos, chi12_z_vel, chi12_z_omega : in signed(47 downto 0);
            chi13_x_pos, chi13_x_vel, chi13_x_omega, chi13_y_pos, chi13_y_vel, chi13_y_omega, chi13_z_pos, chi13_z_vel, chi13_z_omega : in signed(47 downto 0);
            chi14_x_pos, chi14_x_vel, chi14_x_omega, chi14_y_pos, chi14_y_vel, chi14_y_omega, chi14_z_pos, chi14_z_vel, chi14_z_omega : in signed(47 downto 0);
            chi15_x_pos, chi15_x_vel, chi15_x_omega, chi15_y_pos, chi15_y_vel, chi15_y_omega, chi15_z_pos, chi15_z_vel, chi15_z_omega : in signed(47 downto 0);
            chi16_x_pos, chi16_x_vel, chi16_x_omega, chi16_y_pos, chi16_y_vel, chi16_y_omega, chi16_z_pos, chi16_z_vel, chi16_z_omega : in signed(47 downto 0);
            chi17_x_pos, chi17_x_vel, chi17_x_omega, chi17_y_pos, chi17_y_vel, chi17_y_omega, chi17_z_pos, chi17_z_vel, chi17_z_omega : in signed(47 downto 0);
            chi18_x_pos, chi18_x_vel, chi18_x_omega, chi18_y_pos, chi18_y_vel, chi18_y_omega, chi18_z_pos, chi18_z_vel, chi18_z_omega : in signed(47 downto 0);

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

    component kalman_gain_3d is
        port (
            clk : in std_logic; start : in std_logic;

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
            done : out std_logic
        );
    end component;

    component state_update_3d is
        port (
            clk : in std_logic; start : in std_logic;

            x_pos_pred, x_vel_pred, x_omega_pred : in signed(47 downto 0);
            y_pos_pred, y_vel_pred, y_omega_pred : in signed(47 downto 0);
            z_pos_pred, z_vel_pred, z_omega_pred : in signed(47 downto 0);

            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred : in signed(47 downto 0);
            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred : in signed(47 downto 0);
            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred : in signed(47 downto 0);
            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred : in signed(47 downto 0);
            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred : in signed(47 downto 0);
            p66_pred, p67_pred, p68_pred, p69_pred : in signed(47 downto 0);
            p77_pred, p78_pred, p79_pred : in signed(47 downto 0);
            p88_pred, p89_pred : in signed(47 downto 0);
            p99_pred : in signed(47 downto 0);

            nu_x, nu_y, nu_z : in signed(47 downto 0);

            k11, k12, k13, k21, k22, k23, k31, k32, k33 : in signed(47 downto 0);
            k41, k42, k43, k51, k52, k53, k61, k62, k63 : in signed(47 downto 0);
            k71, k72, k73, k81, k82, k83, k91, k92, k93 : in signed(47 downto 0);

            x_pos_upd, x_vel_upd, x_omega_upd : buffer signed(47 downto 0);
            y_pos_upd, y_vel_upd, y_omega_upd : buffer signed(47 downto 0);
            z_pos_upd, z_vel_upd, z_omega_upd : buffer signed(47 downto 0);

            p11_upd, p12_upd, p13_upd, p14_upd, p15_upd, p16_upd, p17_upd, p18_upd, p19_upd : buffer signed(47 downto 0);
            p22_upd, p23_upd, p24_upd, p25_upd, p26_upd, p27_upd, p28_upd, p29_upd : buffer signed(47 downto 0);
            p33_upd, p34_upd, p35_upd, p36_upd, p37_upd, p38_upd, p39_upd : buffer signed(47 downto 0);
            p44_upd, p45_upd, p46_upd, p47_upd, p48_upd, p49_upd : buffer signed(47 downto 0);
            p55_upd, p56_upd, p57_upd, p58_upd, p59_upd : buffer signed(47 downto 0);
            p66_upd, p67_upd, p68_upd, p69_upd : buffer signed(47 downto 0);
            p77_upd, p78_upd, p79_upd : buffer signed(47 downto 0);
            p88_upd, p89_upd : buffer signed(47 downto 0);
            p99_upd : buffer signed(47 downto 0);
            done : out std_logic
        );
    end component;

    type state_type is (IDLE, RUN_MEAS_MEAN, WAIT_MEAS_MEAN, RUN_INNOV, WAIT_INNOV,
                        RUN_CROSS_COV, WAIT_CROSS_COV, RUN_INNOV_COV, WAIT_INNOV_COV,
                        RUN_GAIN, WAIT_GAIN, RUN_UPDATE, WAIT_UPDATE, FINISHED);
    signal state : state_type := IDLE;

    signal meas_mean_start, meas_mean_done : std_logic;
    signal innov_start, innov_done : std_logic;
    signal cross_cov_start, cross_cov_done : std_logic;
    signal innov_cov_start, innov_cov_done : std_logic;
    signal gain_start, gain_done : std_logic;
    signal update_start, update_done : std_logic;

    signal z_x_mean_sig, z_y_mean_sig, z_z_mean_sig : signed(47 downto 0) := (others => '0');
    signal nu_x_sig, nu_y_sig, nu_z_sig : signed(47 downto 0) := (others => '0');

    signal pxz_11_sig, pxz_12_sig, pxz_13_sig : signed(47 downto 0) := (others => '0');
    signal pxz_21_sig, pxz_22_sig, pxz_23_sig : signed(47 downto 0) := (others => '0');
    signal pxz_31_sig, pxz_32_sig, pxz_33_sig : signed(47 downto 0) := (others => '0');
    signal pxz_41_sig, pxz_42_sig, pxz_43_sig : signed(47 downto 0) := (others => '0');
    signal pxz_51_sig, pxz_52_sig, pxz_53_sig : signed(47 downto 0) := (others => '0');
    signal pxz_61_sig, pxz_62_sig, pxz_63_sig : signed(47 downto 0) := (others => '0');
    signal pxz_71_sig, pxz_72_sig, pxz_73_sig : signed(47 downto 0) := (others => '0');
    signal pxz_81_sig, pxz_82_sig, pxz_83_sig : signed(47 downto 0) := (others => '0');
    signal pxz_91_sig, pxz_92_sig, pxz_93_sig : signed(47 downto 0) := (others => '0');

    signal s11_sig, s12_sig, s22_sig, s13_sig, s23_sig, s33_sig : signed(47 downto 0) := (others => '0');

    signal k11_sig, k12_sig, k13_sig : signed(47 downto 0) := (others => '0');
    signal k21_sig, k22_sig, k23_sig : signed(47 downto 0) := (others => '0');
    signal k31_sig, k32_sig, k33_sig : signed(47 downto 0) := (others => '0');
    signal k41_sig, k42_sig, k43_sig : signed(47 downto 0) := (others => '0');
    signal k51_sig, k52_sig, k53_sig : signed(47 downto 0) := (others => '0');
    signal k61_sig, k62_sig, k63_sig : signed(47 downto 0) := (others => '0');
    signal k71_sig, k72_sig, k73_sig : signed(47 downto 0) := (others => '0');
    signal k81_sig, k82_sig, k83_sig : signed(47 downto 0) := (others => '0');
    signal k91_sig, k92_sig, k93_sig : signed(47 downto 0) := (others => '0');

begin

    meas_mean_comp : measurement_mean_3d
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
            chi13_x_pos => chi_pred_13_x_pos, chi13_y_pos => chi_pred_13_y_pos, chi13_z_pos => chi_pred_13_z_pos,
            chi14_x_pos => chi_pred_14_x_pos, chi14_y_pos => chi_pred_14_y_pos, chi14_z_pos => chi_pred_14_z_pos,
            chi15_x_pos => chi_pred_15_x_pos, chi15_y_pos => chi_pred_15_y_pos, chi15_z_pos => chi_pred_15_z_pos,
            chi16_x_pos => chi_pred_16_x_pos, chi16_y_pos => chi_pred_16_y_pos, chi16_z_pos => chi_pred_16_z_pos,
            chi17_x_pos => chi_pred_17_x_pos, chi17_y_pos => chi_pred_17_y_pos, chi17_z_pos => chi_pred_17_z_pos,
            chi18_x_pos => chi_pred_18_x_pos, chi18_y_pos => chi_pred_18_y_pos, chi18_z_pos => chi_pred_18_z_pos,
            z_x_mean => z_x_mean_sig, z_y_mean => z_y_mean_sig, z_z_mean => z_z_mean_sig,
            done => meas_mean_done
        );

    innov_comp : innovation_3d
        port map (
            clk => clk, start => innov_start,
            z_x_meas => z_x_meas, z_y_meas => z_y_meas, z_z_meas => z_z_meas,
            z_x_mean => z_x_mean_sig, z_y_mean => z_y_mean_sig, z_z_mean => z_z_mean_sig,
            nu_x => nu_x_sig, nu_y => nu_y_sig, nu_z => nu_z_sig,
            done => innov_done
        );

    cross_cov_comp : cross_covariance_3d
        port map (
            clk => clk, start => cross_cov_start,

            x_pos_mean => x_pos_pred, x_vel_mean => x_vel_pred, x_omega_mean => x_omega_pred,
            y_pos_mean => y_pos_pred, y_vel_mean => y_vel_pred, y_omega_mean => y_omega_pred,
            z_pos_mean => z_pos_pred, z_vel_mean => z_vel_pred, z_omega_mean => z_omega_pred,

            z_x_mean => z_x_mean_sig, z_y_mean => z_y_mean_sig, z_z_mean => z_z_mean_sig,

            chi0_x_pos => chi_pred_0_x_pos, chi0_x_vel => chi_pred_0_x_vel, chi0_x_omega => chi_pred_0_x_omega, chi0_y_pos => chi_pred_0_y_pos, chi0_y_vel => chi_pred_0_y_vel, chi0_y_omega => chi_pred_0_y_omega, chi0_z_pos => chi_pred_0_z_pos, chi0_z_vel => chi_pred_0_z_vel, chi0_z_omega => chi_pred_0_z_omega,
            chi1_x_pos => chi_pred_1_x_pos, chi1_x_vel => chi_pred_1_x_vel, chi1_x_omega => chi_pred_1_x_omega, chi1_y_pos => chi_pred_1_y_pos, chi1_y_vel => chi_pred_1_y_vel, chi1_y_omega => chi_pred_1_y_omega, chi1_z_pos => chi_pred_1_z_pos, chi1_z_vel => chi_pred_1_z_vel, chi1_z_omega => chi_pred_1_z_omega,
            chi2_x_pos => chi_pred_2_x_pos, chi2_x_vel => chi_pred_2_x_vel, chi2_x_omega => chi_pred_2_x_omega, chi2_y_pos => chi_pred_2_y_pos, chi2_y_vel => chi_pred_2_y_vel, chi2_y_omega => chi_pred_2_y_omega, chi2_z_pos => chi_pred_2_z_pos, chi2_z_vel => chi_pred_2_z_vel, chi2_z_omega => chi_pred_2_z_omega,
            chi3_x_pos => chi_pred_3_x_pos, chi3_x_vel => chi_pred_3_x_vel, chi3_x_omega => chi_pred_3_x_omega, chi3_y_pos => chi_pred_3_y_pos, chi3_y_vel => chi_pred_3_y_vel, chi3_y_omega => chi_pred_3_y_omega, chi3_z_pos => chi_pred_3_z_pos, chi3_z_vel => chi_pred_3_z_vel, chi3_z_omega => chi_pred_3_z_omega,
            chi4_x_pos => chi_pred_4_x_pos, chi4_x_vel => chi_pred_4_x_vel, chi4_x_omega => chi_pred_4_x_omega, chi4_y_pos => chi_pred_4_y_pos, chi4_y_vel => chi_pred_4_y_vel, chi4_y_omega => chi_pred_4_y_omega, chi4_z_pos => chi_pred_4_z_pos, chi4_z_vel => chi_pred_4_z_vel, chi4_z_omega => chi_pred_4_z_omega,
            chi5_x_pos => chi_pred_5_x_pos, chi5_x_vel => chi_pred_5_x_vel, chi5_x_omega => chi_pred_5_x_omega, chi5_y_pos => chi_pred_5_y_pos, chi5_y_vel => chi_pred_5_y_vel, chi5_y_omega => chi_pred_5_y_omega, chi5_z_pos => chi_pred_5_z_pos, chi5_z_vel => chi_pred_5_z_vel, chi5_z_omega => chi_pred_5_z_omega,
            chi6_x_pos => chi_pred_6_x_pos, chi6_x_vel => chi_pred_6_x_vel, chi6_x_omega => chi_pred_6_x_omega, chi6_y_pos => chi_pred_6_y_pos, chi6_y_vel => chi_pred_6_y_vel, chi6_y_omega => chi_pred_6_y_omega, chi6_z_pos => chi_pred_6_z_pos, chi6_z_vel => chi_pred_6_z_vel, chi6_z_omega => chi_pred_6_z_omega,
            chi7_x_pos => chi_pred_7_x_pos, chi7_x_vel => chi_pred_7_x_vel, chi7_x_omega => chi_pred_7_x_omega, chi7_y_pos => chi_pred_7_y_pos, chi7_y_vel => chi_pred_7_y_vel, chi7_y_omega => chi_pred_7_y_omega, chi7_z_pos => chi_pred_7_z_pos, chi7_z_vel => chi_pred_7_z_vel, chi7_z_omega => chi_pred_7_z_omega,
            chi8_x_pos => chi_pred_8_x_pos, chi8_x_vel => chi_pred_8_x_vel, chi8_x_omega => chi_pred_8_x_omega, chi8_y_pos => chi_pred_8_y_pos, chi8_y_vel => chi_pred_8_y_vel, chi8_y_omega => chi_pred_8_y_omega, chi8_z_pos => chi_pred_8_z_pos, chi8_z_vel => chi_pred_8_z_vel, chi8_z_omega => chi_pred_8_z_omega,
            chi9_x_pos => chi_pred_9_x_pos, chi9_x_vel => chi_pred_9_x_vel, chi9_x_omega => chi_pred_9_x_omega, chi9_y_pos => chi_pred_9_y_pos, chi9_y_vel => chi_pred_9_y_vel, chi9_y_omega => chi_pred_9_y_omega, chi9_z_pos => chi_pred_9_z_pos, chi9_z_vel => chi_pred_9_z_vel, chi9_z_omega => chi_pred_9_z_omega,
            chi10_x_pos => chi_pred_10_x_pos, chi10_x_vel => chi_pred_10_x_vel, chi10_x_omega => chi_pred_10_x_omega, chi10_y_pos => chi_pred_10_y_pos, chi10_y_vel => chi_pred_10_y_vel, chi10_y_omega => chi_pred_10_y_omega, chi10_z_pos => chi_pred_10_z_pos, chi10_z_vel => chi_pred_10_z_vel, chi10_z_omega => chi_pred_10_z_omega,
            chi11_x_pos => chi_pred_11_x_pos, chi11_x_vel => chi_pred_11_x_vel, chi11_x_omega => chi_pred_11_x_omega, chi11_y_pos => chi_pred_11_y_pos, chi11_y_vel => chi_pred_11_y_vel, chi11_y_omega => chi_pred_11_y_omega, chi11_z_pos => chi_pred_11_z_pos, chi11_z_vel => chi_pred_11_z_vel, chi11_z_omega => chi_pred_11_z_omega,
            chi12_x_pos => chi_pred_12_x_pos, chi12_x_vel => chi_pred_12_x_vel, chi12_x_omega => chi_pred_12_x_omega, chi12_y_pos => chi_pred_12_y_pos, chi12_y_vel => chi_pred_12_y_vel, chi12_y_omega => chi_pred_12_y_omega, chi12_z_pos => chi_pred_12_z_pos, chi12_z_vel => chi_pred_12_z_vel, chi12_z_omega => chi_pred_12_z_omega,
            chi13_x_pos => chi_pred_13_x_pos, chi13_x_vel => chi_pred_13_x_vel, chi13_x_omega => chi_pred_13_x_omega, chi13_y_pos => chi_pred_13_y_pos, chi13_y_vel => chi_pred_13_y_vel, chi13_y_omega => chi_pred_13_y_omega, chi13_z_pos => chi_pred_13_z_pos, chi13_z_vel => chi_pred_13_z_vel, chi13_z_omega => chi_pred_13_z_omega,
            chi14_x_pos => chi_pred_14_x_pos, chi14_x_vel => chi_pred_14_x_vel, chi14_x_omega => chi_pred_14_x_omega, chi14_y_pos => chi_pred_14_y_pos, chi14_y_vel => chi_pred_14_y_vel, chi14_y_omega => chi_pred_14_y_omega, chi14_z_pos => chi_pred_14_z_pos, chi14_z_vel => chi_pred_14_z_vel, chi14_z_omega => chi_pred_14_z_omega,
            chi15_x_pos => chi_pred_15_x_pos, chi15_x_vel => chi_pred_15_x_vel, chi15_x_omega => chi_pred_15_x_omega, chi15_y_pos => chi_pred_15_y_pos, chi15_y_vel => chi_pred_15_y_vel, chi15_y_omega => chi_pred_15_y_omega, chi15_z_pos => chi_pred_15_z_pos, chi15_z_vel => chi_pred_15_z_vel, chi15_z_omega => chi_pred_15_z_omega,
            chi16_x_pos => chi_pred_16_x_pos, chi16_x_vel => chi_pred_16_x_vel, chi16_x_omega => chi_pred_16_x_omega, chi16_y_pos => chi_pred_16_y_pos, chi16_y_vel => chi_pred_16_y_vel, chi16_y_omega => chi_pred_16_y_omega, chi16_z_pos => chi_pred_16_z_pos, chi16_z_vel => chi_pred_16_z_vel, chi16_z_omega => chi_pred_16_z_omega,
            chi17_x_pos => chi_pred_17_x_pos, chi17_x_vel => chi_pred_17_x_vel, chi17_x_omega => chi_pred_17_x_omega, chi17_y_pos => chi_pred_17_y_pos, chi17_y_vel => chi_pred_17_y_vel, chi17_y_omega => chi_pred_17_y_omega, chi17_z_pos => chi_pred_17_z_pos, chi17_z_vel => chi_pred_17_z_vel, chi17_z_omega => chi_pred_17_z_omega,
            chi18_x_pos => chi_pred_18_x_pos, chi18_x_vel => chi_pred_18_x_vel, chi18_x_omega => chi_pred_18_x_omega, chi18_y_pos => chi_pred_18_y_pos, chi18_y_vel => chi_pred_18_y_vel, chi18_y_omega => chi_pred_18_y_omega, chi18_z_pos => chi_pred_18_z_pos, chi18_z_vel => chi_pred_18_z_vel, chi18_z_omega => chi_pred_18_z_omega,

            pxz_11 => pxz_11_sig, pxz_12 => pxz_12_sig, pxz_13 => pxz_13_sig,
            pxz_21 => pxz_21_sig, pxz_22 => pxz_22_sig, pxz_23 => pxz_23_sig,
            pxz_31 => pxz_31_sig, pxz_32 => pxz_32_sig, pxz_33 => pxz_33_sig,
            pxz_41 => pxz_41_sig, pxz_42 => pxz_42_sig, pxz_43 => pxz_43_sig,
            pxz_51 => pxz_51_sig, pxz_52 => pxz_52_sig, pxz_53 => pxz_53_sig,
            pxz_61 => pxz_61_sig, pxz_62 => pxz_62_sig, pxz_63 => pxz_63_sig,
            pxz_71 => pxz_71_sig, pxz_72 => pxz_72_sig, pxz_73 => pxz_73_sig,
            pxz_81 => pxz_81_sig, pxz_82 => pxz_82_sig, pxz_83 => pxz_83_sig,
            pxz_91 => pxz_91_sig, pxz_92 => pxz_92_sig, pxz_93 => pxz_93_sig,
            done => cross_cov_done
        );

    innov_cov_comp : innovation_covariance_3d
        port map (
            clk => clk, start => innov_cov_start,
            z_x_mean => z_x_mean_sig, z_y_mean => z_y_mean_sig, z_z_mean => z_z_mean_sig,
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
            chi13_z_x => chi_pred_13_x_pos, chi13_z_y => chi_pred_13_y_pos, chi13_z_z => chi_pred_13_z_pos,
            chi14_z_x => chi_pred_14_x_pos, chi14_z_y => chi_pred_14_y_pos, chi14_z_z => chi_pred_14_z_pos,
            chi15_z_x => chi_pred_15_x_pos, chi15_z_y => chi_pred_15_y_pos, chi15_z_z => chi_pred_15_z_pos,
            chi16_z_x => chi_pred_16_x_pos, chi16_z_y => chi_pred_16_y_pos, chi16_z_z => chi_pred_16_z_pos,
            chi17_z_x => chi_pred_17_x_pos, chi17_z_y => chi_pred_17_y_pos, chi17_z_z => chi_pred_17_z_pos,
            chi18_z_x => chi_pred_18_x_pos, chi18_z_y => chi_pred_18_y_pos, chi18_z_z => chi_pred_18_z_pos,
            s11 => s11_sig, s12 => s12_sig, s22 => s22_sig,
            s13 => s13_sig, s23 => s23_sig, s33 => s33_sig,
            done => innov_cov_done
        );

    gain_comp : kalman_gain_3d
        port map (
            clk => clk, start => gain_start,

            pxz_11 => pxz_11_sig, pxz_12 => pxz_12_sig, pxz_13 => pxz_13_sig,
            pxz_21 => pxz_21_sig, pxz_22 => pxz_22_sig, pxz_23 => pxz_23_sig,
            pxz_31 => pxz_31_sig, pxz_32 => pxz_32_sig, pxz_33 => pxz_33_sig,
            pxz_41 => pxz_41_sig, pxz_42 => pxz_42_sig, pxz_43 => pxz_43_sig,
            pxz_51 => pxz_51_sig, pxz_52 => pxz_52_sig, pxz_53 => pxz_53_sig,
            pxz_61 => pxz_61_sig, pxz_62 => pxz_62_sig, pxz_63 => pxz_63_sig,
            pxz_71 => pxz_71_sig, pxz_72 => pxz_72_sig, pxz_73 => pxz_73_sig,
            pxz_81 => pxz_81_sig, pxz_82 => pxz_82_sig, pxz_83 => pxz_83_sig,
            pxz_91 => pxz_91_sig, pxz_92 => pxz_92_sig, pxz_93 => pxz_93_sig,

            s11 => s11_sig, s12 => s12_sig, s22 => s22_sig,
            s13 => s13_sig, s23 => s23_sig, s33 => s33_sig,

            k11 => k11_sig, k12 => k12_sig, k13 => k13_sig,
            k21 => k21_sig, k22 => k22_sig, k23 => k23_sig,
            k31 => k31_sig, k32 => k32_sig, k33 => k33_sig,
            k41 => k41_sig, k42 => k42_sig, k43 => k43_sig,
            k51 => k51_sig, k52 => k52_sig, k53 => k53_sig,
            k61 => k61_sig, k62 => k62_sig, k63 => k63_sig,
            k71 => k71_sig, k72 => k72_sig, k73 => k73_sig,
            k81 => k81_sig, k82 => k82_sig, k83 => k83_sig,
            k91 => k91_sig, k92 => k92_sig, k93 => k93_sig,
            done => gain_done
        );

    state_update_comp : state_update_3d
        port map (
            clk => clk, start => update_start,

            x_pos_pred => x_pos_pred, x_vel_pred => x_vel_pred, x_omega_pred => x_omega_pred,
            y_pos_pred => y_pos_pred, y_vel_pred => y_vel_pred, y_omega_pred => y_omega_pred,
            z_pos_pred => z_pos_pred, z_vel_pred => z_vel_pred, z_omega_pred => z_omega_pred,

            p11_pred => p11_pred, p12_pred => p12_pred, p13_pred => p13_pred, p14_pred => p14_pred, p15_pred => p15_pred, p16_pred => p16_pred, p17_pred => p17_pred, p18_pred => p18_pred, p19_pred => p19_pred,
            p22_pred => p22_pred, p23_pred => p23_pred, p24_pred => p24_pred, p25_pred => p25_pred, p26_pred => p26_pred, p27_pred => p27_pred, p28_pred => p28_pred, p29_pred => p29_pred,
            p33_pred => p33_pred, p34_pred => p34_pred, p35_pred => p35_pred, p36_pred => p36_pred, p37_pred => p37_pred, p38_pred => p38_pred, p39_pred => p39_pred,
            p44_pred => p44_pred, p45_pred => p45_pred, p46_pred => p46_pred, p47_pred => p47_pred, p48_pred => p48_pred, p49_pred => p49_pred,
            p55_pred => p55_pred, p56_pred => p56_pred, p57_pred => p57_pred, p58_pred => p58_pred, p59_pred => p59_pred,
            p66_pred => p66_pred, p67_pred => p67_pred, p68_pred => p68_pred, p69_pred => p69_pred,
            p77_pred => p77_pred, p78_pred => p78_pred, p79_pred => p79_pred,
            p88_pred => p88_pred, p89_pred => p89_pred,
            p99_pred => p99_pred,

            nu_x => nu_x_sig, nu_y => nu_y_sig, nu_z => nu_z_sig,

            k11 => k11_sig, k12 => k12_sig, k13 => k13_sig,
            k21 => k21_sig, k22 => k22_sig, k23 => k23_sig,
            k31 => k31_sig, k32 => k32_sig, k33 => k33_sig,
            k41 => k41_sig, k42 => k42_sig, k43 => k43_sig,
            k51 => k51_sig, k52 => k52_sig, k53 => k53_sig,
            k61 => k61_sig, k62 => k62_sig, k63 => k63_sig,
            k71 => k71_sig, k72 => k72_sig, k73 => k73_sig,
            k81 => k81_sig, k82 => k82_sig, k83 => k83_sig,
            k91 => k91_sig, k92 => k92_sig, k93 => k93_sig,

            x_pos_upd => x_pos_upd, x_vel_upd => x_vel_upd, x_omega_upd => x_omega_upd,
            y_pos_upd => y_pos_upd, y_vel_upd => y_vel_upd, y_omega_upd => y_omega_upd,
            z_pos_upd => z_pos_upd, z_vel_upd => z_vel_upd, z_omega_upd => z_omega_upd,

            p11_upd => p11_upd, p12_upd => p12_upd, p13_upd => p13_upd, p14_upd => p14_upd, p15_upd => p15_upd, p16_upd => p16_upd, p17_upd => p17_upd, p18_upd => p18_upd, p19_upd => p19_upd,
            p22_upd => p22_upd, p23_upd => p23_upd, p24_upd => p24_upd, p25_upd => p25_upd, p26_upd => p26_upd, p27_upd => p27_upd, p28_upd => p28_upd, p29_upd => p29_upd,
            p33_upd => p33_upd, p34_upd => p34_upd, p35_upd => p35_upd, p36_upd => p36_upd, p37_upd => p37_upd, p38_upd => p38_upd, p39_upd => p39_upd,
            p44_upd => p44_upd, p45_upd => p45_upd, p46_upd => p46_upd, p47_upd => p47_upd, p48_upd => p48_upd, p49_upd => p49_upd,
            p55_upd => p55_upd, p56_upd => p56_upd, p57_upd => p57_upd, p58_upd => p58_upd, p59_upd => p59_upd,
            p66_upd => p66_upd, p67_upd => p67_upd, p68_upd => p68_upd, p69_upd => p69_upd,
            p77_upd => p77_upd, p78_upd => p78_upd, p79_upd => p79_upd,
            p88_upd => p88_upd, p89_upd => p89_upd,
            p99_upd => p99_upd,
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
                    meas_mean_start <= '1';
                    state <= WAIT_MEAS_MEAN;

                when WAIT_MEAS_MEAN =>
                    meas_mean_start <= '0';
                    if meas_mean_done = '1' then
                        state <= RUN_INNOV;
                    end if;

                when RUN_INNOV =>
                    innov_start <= '1';
                    state <= WAIT_INNOV;

                when WAIT_INNOV =>
                    innov_start <= '0';
                    if innov_done = '1' then
                        state <= RUN_CROSS_COV;
                    end if;

                when RUN_CROSS_COV =>
                    cross_cov_start <= '1';
                    state <= WAIT_CROSS_COV;

                when WAIT_CROSS_COV =>
                    cross_cov_start <= '0';
                    if cross_cov_done = '1' then
                        state <= RUN_INNOV_COV;
                    end if;

                when RUN_INNOV_COV =>
                    innov_cov_start <= '1';
                    state <= WAIT_INNOV_COV;

                when WAIT_INNOV_COV =>
                    innov_cov_start <= '0';
                    if innov_cov_done = '1' then
                        state <= RUN_GAIN;
                    end if;

                when RUN_GAIN =>
                    gain_start <= '1';
                    state <= WAIT_GAIN;

                when WAIT_GAIN =>
                    gain_start <= '0';
                    if gain_done = '1' then
                        state <= RUN_UPDATE;
                    end if;

                when RUN_UPDATE =>
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
