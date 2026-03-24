library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prediction_phase_3d is
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        start : in  std_logic;

        x_pos_current, x_vel_current, x_omega_current : in signed(47 downto 0);
        y_pos_current, y_vel_current, y_omega_current : in signed(47 downto 0);
        z_pos_current, z_vel_current, z_omega_current : in signed(47 downto 0);

        p11_current, p12_current, p13_current, p14_current, p15_current, p16_current, p17_current, p18_current, p19_current : in signed(47 downto 0);
        p22_current, p23_current, p24_current, p25_current, p26_current, p27_current, p28_current, p29_current             : in signed(47 downto 0);
        p33_current, p34_current, p35_current, p36_current, p37_current, p38_current, p39_current                          : in signed(47 downto 0);
        p44_current, p45_current, p46_current, p47_current, p48_current, p49_current                                       : in signed(47 downto 0);
        p55_current, p56_current, p57_current, p58_current, p59_current                                                    : in signed(47 downto 0);
        p66_current, p67_current, p68_current, p69_current                                                                 : in signed(47 downto 0);
        p77_current, p78_current, p79_current                                                                              : in signed(47 downto 0);
        p88_current, p89_current                                                                                           : in signed(47 downto 0);
        p99_current                                                                                                        : in signed(47 downto 0);

        x_pos_pred, x_vel_pred, x_omega_pred : out signed(47 downto 0);
        y_pos_pred, y_vel_pred, y_omega_pred : out signed(47 downto 0);
        z_pos_pred, z_vel_pred, z_omega_pred : out signed(47 downto 0);

        p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred : out signed(47 downto 0);
        p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred           : out signed(47 downto 0);
        p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred                     : out signed(47 downto 0);
        p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred                               : out signed(47 downto 0);
        p55_pred, p56_pred, p57_pred, p58_pred, p59_pred                                         : out signed(47 downto 0);
        p66_pred, p67_pred, p68_pred, p69_pred                                                   : out signed(47 downto 0);
        p77_pred, p78_pred, p79_pred                                                             : out signed(47 downto 0);
        p88_pred, p89_pred                                                                       : out signed(47 downto 0);
        p99_pred                                                                                 : out signed(47 downto 0);

        chi_pred_0_x_pos, chi_pred_0_x_vel, chi_pred_0_x_omega, chi_pred_0_y_pos, chi_pred_0_y_vel, chi_pred_0_y_omega, chi_pred_0_z_pos, chi_pred_0_z_vel, chi_pred_0_z_omega : out signed(47 downto 0);
        chi_pred_1_x_pos, chi_pred_1_x_vel, chi_pred_1_x_omega, chi_pred_1_y_pos, chi_pred_1_y_vel, chi_pred_1_y_omega, chi_pred_1_z_pos, chi_pred_1_z_vel, chi_pred_1_z_omega : out signed(47 downto 0);
        chi_pred_2_x_pos, chi_pred_2_x_vel, chi_pred_2_x_omega, chi_pred_2_y_pos, chi_pred_2_y_vel, chi_pred_2_y_omega, chi_pred_2_z_pos, chi_pred_2_z_vel, chi_pred_2_z_omega : out signed(47 downto 0);
        chi_pred_3_x_pos, chi_pred_3_x_vel, chi_pred_3_x_omega, chi_pred_3_y_pos, chi_pred_3_y_vel, chi_pred_3_y_omega, chi_pred_3_z_pos, chi_pred_3_z_vel, chi_pred_3_z_omega : out signed(47 downto 0);
        chi_pred_4_x_pos, chi_pred_4_x_vel, chi_pred_4_x_omega, chi_pred_4_y_pos, chi_pred_4_y_vel, chi_pred_4_y_omega, chi_pred_4_z_pos, chi_pred_4_z_vel, chi_pred_4_z_omega : out signed(47 downto 0);
        chi_pred_5_x_pos, chi_pred_5_x_vel, chi_pred_5_x_omega, chi_pred_5_y_pos, chi_pred_5_y_vel, chi_pred_5_y_omega, chi_pred_5_z_pos, chi_pred_5_z_vel, chi_pred_5_z_omega : out signed(47 downto 0);
        chi_pred_6_x_pos, chi_pred_6_x_vel, chi_pred_6_x_omega, chi_pred_6_y_pos, chi_pred_6_y_vel, chi_pred_6_y_omega, chi_pred_6_z_pos, chi_pred_6_z_vel, chi_pred_6_z_omega : out signed(47 downto 0);
        chi_pred_7_x_pos, chi_pred_7_x_vel, chi_pred_7_x_omega, chi_pred_7_y_pos, chi_pred_7_y_vel, chi_pred_7_y_omega, chi_pred_7_z_pos, chi_pred_7_z_vel, chi_pred_7_z_omega : out signed(47 downto 0);
        chi_pred_8_x_pos, chi_pred_8_x_vel, chi_pred_8_x_omega, chi_pred_8_y_pos, chi_pred_8_y_vel, chi_pred_8_y_omega, chi_pred_8_z_pos, chi_pred_8_z_vel, chi_pred_8_z_omega : out signed(47 downto 0);
        chi_pred_9_x_pos, chi_pred_9_x_vel, chi_pred_9_x_omega, chi_pred_9_y_pos, chi_pred_9_y_vel, chi_pred_9_y_omega, chi_pred_9_z_pos, chi_pred_9_z_vel, chi_pred_9_z_omega : out signed(47 downto 0);
        chi_pred_10_x_pos, chi_pred_10_x_vel, chi_pred_10_x_omega, chi_pred_10_y_pos, chi_pred_10_y_vel, chi_pred_10_y_omega, chi_pred_10_z_pos, chi_pred_10_z_vel, chi_pred_10_z_omega : out signed(47 downto 0);
        chi_pred_11_x_pos, chi_pred_11_x_vel, chi_pred_11_x_omega, chi_pred_11_y_pos, chi_pred_11_y_vel, chi_pred_11_y_omega, chi_pred_11_z_pos, chi_pred_11_z_vel, chi_pred_11_z_omega : out signed(47 downto 0);
        chi_pred_12_x_pos, chi_pred_12_x_vel, chi_pred_12_x_omega, chi_pred_12_y_pos, chi_pred_12_y_vel, chi_pred_12_y_omega, chi_pred_12_z_pos, chi_pred_12_z_vel, chi_pred_12_z_omega : out signed(47 downto 0);
        chi_pred_13_x_pos, chi_pred_13_x_vel, chi_pred_13_x_omega, chi_pred_13_y_pos, chi_pred_13_y_vel, chi_pred_13_y_omega, chi_pred_13_z_pos, chi_pred_13_z_vel, chi_pred_13_z_omega : out signed(47 downto 0);
        chi_pred_14_x_pos, chi_pred_14_x_vel, chi_pred_14_x_omega, chi_pred_14_y_pos, chi_pred_14_y_vel, chi_pred_14_y_omega, chi_pred_14_z_pos, chi_pred_14_z_vel, chi_pred_14_z_omega : out signed(47 downto 0);
        chi_pred_15_x_pos, chi_pred_15_x_vel, chi_pred_15_x_omega, chi_pred_15_y_pos, chi_pred_15_y_vel, chi_pred_15_y_omega, chi_pred_15_z_pos, chi_pred_15_z_vel, chi_pred_15_z_omega : out signed(47 downto 0);
        chi_pred_16_x_pos, chi_pred_16_x_vel, chi_pred_16_x_omega, chi_pred_16_y_pos, chi_pred_16_y_vel, chi_pred_16_y_omega, chi_pred_16_z_pos, chi_pred_16_z_vel, chi_pred_16_z_omega : out signed(47 downto 0);
        chi_pred_17_x_pos, chi_pred_17_x_vel, chi_pred_17_x_omega, chi_pred_17_y_pos, chi_pred_17_y_vel, chi_pred_17_y_omega, chi_pred_17_z_pos, chi_pred_17_z_vel, chi_pred_17_z_omega : out signed(47 downto 0);
        chi_pred_18_x_pos, chi_pred_18_x_vel, chi_pred_18_x_omega, chi_pred_18_y_pos, chi_pred_18_y_vel, chi_pred_18_y_omega, chi_pred_18_z_pos, chi_pred_18_z_vel, chi_pred_18_z_omega : out signed(47 downto 0);

        done : out std_logic
    );
end prediction_phase_3d;
architecture Behavioral of prediction_phase_3d is

    component cholesky_9x9 is
        port (
            clk : in std_logic;
            start : in std_logic;

            p11_in, p12_in, p13_in, p14_in, p15_in, p16_in, p17_in, p18_in, p19_in : in signed(47 downto 0);
            p22_in, p23_in, p24_in, p25_in, p26_in, p27_in, p28_in, p29_in : in signed(47 downto 0);
            p33_in, p34_in, p35_in, p36_in, p37_in, p38_in, p39_in : in signed(47 downto 0);
            p44_in, p45_in, p46_in, p47_in, p48_in, p49_in : in signed(47 downto 0);
            p55_in, p56_in, p57_in, p58_in, p59_in : in signed(47 downto 0);
            p66_in, p67_in, p68_in, p69_in : in signed(47 downto 0);
            p77_in, p78_in, p79_in : in signed(47 downto 0);
            p88_in, p89_in : in signed(47 downto 0);
            p99_in : in signed(47 downto 0);

            l11_out, l21_out, l31_out, l41_out, l51_out, l61_out, l71_out, l81_out, l91_out : out signed(47 downto 0);
            l22_out, l32_out, l42_out, l52_out, l62_out, l72_out, l82_out, l92_out : out signed(47 downto 0);
            l33_out, l43_out, l53_out, l63_out, l73_out, l83_out, l93_out : out signed(47 downto 0);
            l44_out, l54_out, l64_out, l74_out, l84_out, l94_out : out signed(47 downto 0);
            l55_out, l65_out, l75_out, l85_out, l95_out : out signed(47 downto 0);
            l66_out, l76_out, l86_out, l96_out : out signed(47 downto 0);
            l77_out, l87_out, l97_out : out signed(47 downto 0);
            l88_out, l98_out : out signed(47 downto 0);
            l99_out : out signed(47 downto 0);
            done : out std_logic;
            psd_error : out std_logic
        );
    end component;

    component sigma_3d is
        port (
            clk : in std_logic;
            rst : in std_logic;
            start : in std_logic;

            x_pos_mean, x_vel_mean, x_omega_mean : in signed(47 downto 0);
            y_pos_mean, y_vel_mean, y_omega_mean : in signed(47 downto 0);
            z_pos_mean, z_vel_mean, z_omega_mean : in signed(47 downto 0);

            cholesky_done : in std_logic;
            l11, l21, l31, l41, l51, l61, l71, l81, l91 : in signed(47 downto 0);
            l22, l32, l42, l52, l62, l72, l82, l92 : in signed(47 downto 0);
            l33, l43, l53, l63, l73, l83, l93 : in signed(47 downto 0);
            l44, l54, l64, l74, l84, l94 : in signed(47 downto 0);
            l55, l65, l75, l85, l95 : in signed(47 downto 0);
            l66, l76, l86, l96 : in signed(47 downto 0);
            l77, l87, l97 : in signed(47 downto 0);
            l88, l98 : in signed(47 downto 0);
            l99 : in signed(47 downto 0);

            chi0_x_pos, chi0_x_vel, chi0_x_omega, chi0_y_pos, chi0_y_vel, chi0_y_omega, chi0_z_pos, chi0_z_vel, chi0_z_omega : out signed(47 downto 0);
            chi1_x_pos, chi1_x_vel, chi1_x_omega, chi1_y_pos, chi1_y_vel, chi1_y_omega, chi1_z_pos, chi1_z_vel, chi1_z_omega : out signed(47 downto 0);
            chi2_x_pos, chi2_x_vel, chi2_x_omega, chi2_y_pos, chi2_y_vel, chi2_y_omega, chi2_z_pos, chi2_z_vel, chi2_z_omega : out signed(47 downto 0);
            chi3_x_pos, chi3_x_vel, chi3_x_omega, chi3_y_pos, chi3_y_vel, chi3_y_omega, chi3_z_pos, chi3_z_vel, chi3_z_omega : out signed(47 downto 0);
            chi4_x_pos, chi4_x_vel, chi4_x_omega, chi4_y_pos, chi4_y_vel, chi4_y_omega, chi4_z_pos, chi4_z_vel, chi4_z_omega : out signed(47 downto 0);
            chi5_x_pos, chi5_x_vel, chi5_x_omega, chi5_y_pos, chi5_y_vel, chi5_y_omega, chi5_z_pos, chi5_z_vel, chi5_z_omega : out signed(47 downto 0);
            chi6_x_pos, chi6_x_vel, chi6_x_omega, chi6_y_pos, chi6_y_vel, chi6_y_omega, chi6_z_pos, chi6_z_vel, chi6_z_omega : out signed(47 downto 0);
            chi7_x_pos, chi7_x_vel, chi7_x_omega, chi7_y_pos, chi7_y_vel, chi7_y_omega, chi7_z_pos, chi7_z_vel, chi7_z_omega : out signed(47 downto 0);
            chi8_x_pos, chi8_x_vel, chi8_x_omega, chi8_y_pos, chi8_y_vel, chi8_y_omega, chi8_z_pos, chi8_z_vel, chi8_z_omega : out signed(47 downto 0);
            chi9_x_pos, chi9_x_vel, chi9_x_omega, chi9_y_pos, chi9_y_vel, chi9_y_omega, chi9_z_pos, chi9_z_vel, chi9_z_omega : out signed(47 downto 0);
            chi10_x_pos, chi10_x_vel, chi10_x_omega, chi10_y_pos, chi10_y_vel, chi10_y_omega, chi10_z_pos, chi10_z_vel, chi10_z_omega : out signed(47 downto 0);
            chi11_x_pos, chi11_x_vel, chi11_x_omega, chi11_y_pos, chi11_y_vel, chi11_y_omega, chi11_z_pos, chi11_z_vel, chi11_z_omega : out signed(47 downto 0);
            chi12_x_pos, chi12_x_vel, chi12_x_omega, chi12_y_pos, chi12_y_vel, chi12_y_omega, chi12_z_pos, chi12_z_vel, chi12_z_omega : out signed(47 downto 0);
            chi13_x_pos, chi13_x_vel, chi13_x_omega, chi13_y_pos, chi13_y_vel, chi13_y_omega, chi13_z_pos, chi13_z_vel, chi13_z_omega : out signed(47 downto 0);
            chi14_x_pos, chi14_x_vel, chi14_x_omega, chi14_y_pos, chi14_y_vel, chi14_y_omega, chi14_z_pos, chi14_z_vel, chi14_z_omega : out signed(47 downto 0);
            chi15_x_pos, chi15_x_vel, chi15_x_omega, chi15_y_pos, chi15_y_vel, chi15_y_omega, chi15_z_pos, chi15_z_vel, chi15_z_omega : out signed(47 downto 0);
            chi16_x_pos, chi16_x_vel, chi16_x_omega, chi16_y_pos, chi16_y_vel, chi16_y_omega, chi16_z_pos, chi16_z_vel, chi16_z_omega : out signed(47 downto 0);
            chi17_x_pos, chi17_x_vel, chi17_x_omega, chi17_y_pos, chi17_y_vel, chi17_y_omega, chi17_z_pos, chi17_z_vel, chi17_z_omega : out signed(47 downto 0);
            chi18_x_pos, chi18_x_vel, chi18_x_omega, chi18_y_pos, chi18_y_vel, chi18_y_omega, chi18_z_pos, chi18_z_vel, chi18_z_omega : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    component predicti_ctr3d is
        port (
            clk : in std_logic; rst : in std_logic; start : in std_logic;

            chi0_x_pos_in, chi0_x_vel_in, chi0_x_omega_in, chi0_y_pos_in, chi0_y_vel_in, chi0_y_omega_in, chi0_z_pos_in, chi0_z_vel_in, chi0_z_omega_in : in signed(47 downto 0);
            chi1_x_pos_in, chi1_x_vel_in, chi1_x_omega_in, chi1_y_pos_in, chi1_y_vel_in, chi1_y_omega_in, chi1_z_pos_in, chi1_z_vel_in, chi1_z_omega_in : in signed(47 downto 0);
            chi2_x_pos_in, chi2_x_vel_in, chi2_x_omega_in, chi2_y_pos_in, chi2_y_vel_in, chi2_y_omega_in, chi2_z_pos_in, chi2_z_vel_in, chi2_z_omega_in : in signed(47 downto 0);
            chi3_x_pos_in, chi3_x_vel_in, chi3_x_omega_in, chi3_y_pos_in, chi3_y_vel_in, chi3_y_omega_in, chi3_z_pos_in, chi3_z_vel_in, chi3_z_omega_in : in signed(47 downto 0);
            chi4_x_pos_in, chi4_x_vel_in, chi4_x_omega_in, chi4_y_pos_in, chi4_y_vel_in, chi4_y_omega_in, chi4_z_pos_in, chi4_z_vel_in, chi4_z_omega_in : in signed(47 downto 0);
            chi5_x_pos_in, chi5_x_vel_in, chi5_x_omega_in, chi5_y_pos_in, chi5_y_vel_in, chi5_y_omega_in, chi5_z_pos_in, chi5_z_vel_in, chi5_z_omega_in : in signed(47 downto 0);
            chi6_x_pos_in, chi6_x_vel_in, chi6_x_omega_in, chi6_y_pos_in, chi6_y_vel_in, chi6_y_omega_in, chi6_z_pos_in, chi6_z_vel_in, chi6_z_omega_in : in signed(47 downto 0);
            chi7_x_pos_in, chi7_x_vel_in, chi7_x_omega_in, chi7_y_pos_in, chi7_y_vel_in, chi7_y_omega_in, chi7_z_pos_in, chi7_z_vel_in, chi7_z_omega_in : in signed(47 downto 0);
            chi8_x_pos_in, chi8_x_vel_in, chi8_x_omega_in, chi8_y_pos_in, chi8_y_vel_in, chi8_y_omega_in, chi8_z_pos_in, chi8_z_vel_in, chi8_z_omega_in : in signed(47 downto 0);
            chi9_x_pos_in, chi9_x_vel_in, chi9_x_omega_in, chi9_y_pos_in, chi9_y_vel_in, chi9_y_omega_in, chi9_z_pos_in, chi9_z_vel_in, chi9_z_omega_in : in signed(47 downto 0);
            chi10_x_pos_in, chi10_x_vel_in, chi10_x_omega_in, chi10_y_pos_in, chi10_y_vel_in, chi10_y_omega_in, chi10_z_pos_in, chi10_z_vel_in, chi10_z_omega_in : in signed(47 downto 0);
            chi11_x_pos_in, chi11_x_vel_in, chi11_x_omega_in, chi11_y_pos_in, chi11_y_vel_in, chi11_y_omega_in, chi11_z_pos_in, chi11_z_vel_in, chi11_z_omega_in : in signed(47 downto 0);
            chi12_x_pos_in, chi12_x_vel_in, chi12_x_omega_in, chi12_y_pos_in, chi12_y_vel_in, chi12_y_omega_in, chi12_z_pos_in, chi12_z_vel_in, chi12_z_omega_in : in signed(47 downto 0);
            chi13_x_pos_in, chi13_x_vel_in, chi13_x_omega_in, chi13_y_pos_in, chi13_y_vel_in, chi13_y_omega_in, chi13_z_pos_in, chi13_z_vel_in, chi13_z_omega_in : in signed(47 downto 0);
            chi14_x_pos_in, chi14_x_vel_in, chi14_x_omega_in, chi14_y_pos_in, chi14_y_vel_in, chi14_y_omega_in, chi14_z_pos_in, chi14_z_vel_in, chi14_z_omega_in : in signed(47 downto 0);
            chi15_x_pos_in, chi15_x_vel_in, chi15_x_omega_in, chi15_y_pos_in, chi15_y_vel_in, chi15_y_omega_in, chi15_z_pos_in, chi15_z_vel_in, chi15_z_omega_in : in signed(47 downto 0);
            chi16_x_pos_in, chi16_x_vel_in, chi16_x_omega_in, chi16_y_pos_in, chi16_y_vel_in, chi16_y_omega_in, chi16_z_pos_in, chi16_z_vel_in, chi16_z_omega_in : in signed(47 downto 0);
            chi17_x_pos_in, chi17_x_vel_in, chi17_x_omega_in, chi17_y_pos_in, chi17_y_vel_in, chi17_y_omega_in, chi17_z_pos_in, chi17_z_vel_in, chi17_z_omega_in : in signed(47 downto 0);
            chi18_x_pos_in, chi18_x_vel_in, chi18_x_omega_in, chi18_y_pos_in, chi18_y_vel_in, chi18_y_omega_in, chi18_z_pos_in, chi18_z_vel_in, chi18_z_omega_in : in signed(47 downto 0);

            chi0_x_pos_pred, chi0_x_vel_pred, chi0_x_omega_pred, chi0_y_pos_pred, chi0_y_vel_pred, chi0_y_omega_pred, chi0_z_pos_pred, chi0_z_vel_pred, chi0_z_omega_pred : out signed(47 downto 0);
            chi1_x_pos_pred, chi1_x_vel_pred, chi1_x_omega_pred, chi1_y_pos_pred, chi1_y_vel_pred, chi1_y_omega_pred, chi1_z_pos_pred, chi1_z_vel_pred, chi1_z_omega_pred : out signed(47 downto 0);
            chi2_x_pos_pred, chi2_x_vel_pred, chi2_x_omega_pred, chi2_y_pos_pred, chi2_y_vel_pred, chi2_y_omega_pred, chi2_z_pos_pred, chi2_z_vel_pred, chi2_z_omega_pred : out signed(47 downto 0);
            chi3_x_pos_pred, chi3_x_vel_pred, chi3_x_omega_pred, chi3_y_pos_pred, chi3_y_vel_pred, chi3_y_omega_pred, chi3_z_pos_pred, chi3_z_vel_pred, chi3_z_omega_pred : out signed(47 downto 0);
            chi4_x_pos_pred, chi4_x_vel_pred, chi4_x_omega_pred, chi4_y_pos_pred, chi4_y_vel_pred, chi4_y_omega_pred, chi4_z_pos_pred, chi4_z_vel_pred, chi4_z_omega_pred : out signed(47 downto 0);
            chi5_x_pos_pred, chi5_x_vel_pred, chi5_x_omega_pred, chi5_y_pos_pred, chi5_y_vel_pred, chi5_y_omega_pred, chi5_z_pos_pred, chi5_z_vel_pred, chi5_z_omega_pred : out signed(47 downto 0);
            chi6_x_pos_pred, chi6_x_vel_pred, chi6_x_omega_pred, chi6_y_pos_pred, chi6_y_vel_pred, chi6_y_omega_pred, chi6_z_pos_pred, chi6_z_vel_pred, chi6_z_omega_pred : out signed(47 downto 0);
            chi7_x_pos_pred, chi7_x_vel_pred, chi7_x_omega_pred, chi7_y_pos_pred, chi7_y_vel_pred, chi7_y_omega_pred, chi7_z_pos_pred, chi7_z_vel_pred, chi7_z_omega_pred : out signed(47 downto 0);
            chi8_x_pos_pred, chi8_x_vel_pred, chi8_x_omega_pred, chi8_y_pos_pred, chi8_y_vel_pred, chi8_y_omega_pred, chi8_z_pos_pred, chi8_z_vel_pred, chi8_z_omega_pred : out signed(47 downto 0);
            chi9_x_pos_pred, chi9_x_vel_pred, chi9_x_omega_pred, chi9_y_pos_pred, chi9_y_vel_pred, chi9_y_omega_pred, chi9_z_pos_pred, chi9_z_vel_pred, chi9_z_omega_pred : out signed(47 downto 0);
            chi10_x_pos_pred, chi10_x_vel_pred, chi10_x_omega_pred, chi10_y_pos_pred, chi10_y_vel_pred, chi10_y_omega_pred, chi10_z_pos_pred, chi10_z_vel_pred, chi10_z_omega_pred : out signed(47 downto 0);
            chi11_x_pos_pred, chi11_x_vel_pred, chi11_x_omega_pred, chi11_y_pos_pred, chi11_y_vel_pred, chi11_y_omega_pred, chi11_z_pos_pred, chi11_z_vel_pred, chi11_z_omega_pred : out signed(47 downto 0);
            chi12_x_pos_pred, chi12_x_vel_pred, chi12_x_omega_pred, chi12_y_pos_pred, chi12_y_vel_pred, chi12_y_omega_pred, chi12_z_pos_pred, chi12_z_vel_pred, chi12_z_omega_pred : out signed(47 downto 0);
            chi13_x_pos_pred, chi13_x_vel_pred, chi13_x_omega_pred, chi13_y_pos_pred, chi13_y_vel_pred, chi13_y_omega_pred, chi13_z_pos_pred, chi13_z_vel_pred, chi13_z_omega_pred : out signed(47 downto 0);
            chi14_x_pos_pred, chi14_x_vel_pred, chi14_x_omega_pred, chi14_y_pos_pred, chi14_y_vel_pred, chi14_y_omega_pred, chi14_z_pos_pred, chi14_z_vel_pred, chi14_z_omega_pred : out signed(47 downto 0);
            chi15_x_pos_pred, chi15_x_vel_pred, chi15_x_omega_pred, chi15_y_pos_pred, chi15_y_vel_pred, chi15_y_omega_pred, chi15_z_pos_pred, chi15_z_vel_pred, chi15_z_omega_pred : out signed(47 downto 0);
            chi16_x_pos_pred, chi16_x_vel_pred, chi16_x_omega_pred, chi16_y_pos_pred, chi16_y_vel_pred, chi16_y_omega_pred, chi16_z_pos_pred, chi16_z_vel_pred, chi16_z_omega_pred : out signed(47 downto 0);
            chi17_x_pos_pred, chi17_x_vel_pred, chi17_x_omega_pred, chi17_y_pos_pred, chi17_y_vel_pred, chi17_y_omega_pred, chi17_z_pos_pred, chi17_z_vel_pred, chi17_z_omega_pred : out signed(47 downto 0);
            chi18_x_pos_pred, chi18_x_vel_pred, chi18_x_omega_pred, chi18_y_pos_pred, chi18_y_vel_pred, chi18_y_omega_pred, chi18_z_pos_pred, chi18_z_vel_pred, chi18_z_omega_pred : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    component predicted_mean_3d is
        port (
            clk : in std_logic;
            rst : in std_logic;
            start : in std_logic;

            chi0_x_pos_pred, chi0_x_vel_pred, chi0_x_omega_pred, chi0_y_pos_pred, chi0_y_vel_pred, chi0_y_omega_pred, chi0_z_pos_pred, chi0_z_vel_pred, chi0_z_omega_pred : in signed(47 downto 0);
            chi1_x_pos_pred, chi1_x_vel_pred, chi1_x_omega_pred, chi1_y_pos_pred, chi1_y_vel_pred, chi1_y_omega_pred, chi1_z_pos_pred, chi1_z_vel_pred, chi1_z_omega_pred : in signed(47 downto 0);
            chi2_x_pos_pred, chi2_x_vel_pred, chi2_x_omega_pred, chi2_y_pos_pred, chi2_y_vel_pred, chi2_y_omega_pred, chi2_z_pos_pred, chi2_z_vel_pred, chi2_z_omega_pred : in signed(47 downto 0);
            chi3_x_pos_pred, chi3_x_vel_pred, chi3_x_omega_pred, chi3_y_pos_pred, chi3_y_vel_pred, chi3_y_omega_pred, chi3_z_pos_pred, chi3_z_vel_pred, chi3_z_omega_pred : in signed(47 downto 0);
            chi4_x_pos_pred, chi4_x_vel_pred, chi4_x_omega_pred, chi4_y_pos_pred, chi4_y_vel_pred, chi4_y_omega_pred, chi4_z_pos_pred, chi4_z_vel_pred, chi4_z_omega_pred : in signed(47 downto 0);
            chi5_x_pos_pred, chi5_x_vel_pred, chi5_x_omega_pred, chi5_y_pos_pred, chi5_y_vel_pred, chi5_y_omega_pred, chi5_z_pos_pred, chi5_z_vel_pred, chi5_z_omega_pred : in signed(47 downto 0);
            chi6_x_pos_pred, chi6_x_vel_pred, chi6_x_omega_pred, chi6_y_pos_pred, chi6_y_vel_pred, chi6_y_omega_pred, chi6_z_pos_pred, chi6_z_vel_pred, chi6_z_omega_pred : in signed(47 downto 0);
            chi7_x_pos_pred, chi7_x_vel_pred, chi7_x_omega_pred, chi7_y_pos_pred, chi7_y_vel_pred, chi7_y_omega_pred, chi7_z_pos_pred, chi7_z_vel_pred, chi7_z_omega_pred : in signed(47 downto 0);
            chi8_x_pos_pred, chi8_x_vel_pred, chi8_x_omega_pred, chi8_y_pos_pred, chi8_y_vel_pred, chi8_y_omega_pred, chi8_z_pos_pred, chi8_z_vel_pred, chi8_z_omega_pred : in signed(47 downto 0);
            chi9_x_pos_pred, chi9_x_vel_pred, chi9_x_omega_pred, chi9_y_pos_pred, chi9_y_vel_pred, chi9_y_omega_pred, chi9_z_pos_pred, chi9_z_vel_pred, chi9_z_omega_pred : in signed(47 downto 0);
            chi10_x_pos_pred, chi10_x_vel_pred, chi10_x_omega_pred, chi10_y_pos_pred, chi10_y_vel_pred, chi10_y_omega_pred, chi10_z_pos_pred, chi10_z_vel_pred, chi10_z_omega_pred : in signed(47 downto 0);
            chi11_x_pos_pred, chi11_x_vel_pred, chi11_x_omega_pred, chi11_y_pos_pred, chi11_y_vel_pred, chi11_y_omega_pred, chi11_z_pos_pred, chi11_z_vel_pred, chi11_z_omega_pred : in signed(47 downto 0);
            chi12_x_pos_pred, chi12_x_vel_pred, chi12_x_omega_pred, chi12_y_pos_pred, chi12_y_vel_pred, chi12_y_omega_pred, chi12_z_pos_pred, chi12_z_vel_pred, chi12_z_omega_pred : in signed(47 downto 0);
            chi13_x_pos_pred, chi13_x_vel_pred, chi13_x_omega_pred, chi13_y_pos_pred, chi13_y_vel_pred, chi13_y_omega_pred, chi13_z_pos_pred, chi13_z_vel_pred, chi13_z_omega_pred : in signed(47 downto 0);
            chi14_x_pos_pred, chi14_x_vel_pred, chi14_x_omega_pred, chi14_y_pos_pred, chi14_y_vel_pred, chi14_y_omega_pred, chi14_z_pos_pred, chi14_z_vel_pred, chi14_z_omega_pred : in signed(47 downto 0);
            chi15_x_pos_pred, chi15_x_vel_pred, chi15_x_omega_pred, chi15_y_pos_pred, chi15_y_vel_pred, chi15_y_omega_pred, chi15_z_pos_pred, chi15_z_vel_pred, chi15_z_omega_pred : in signed(47 downto 0);
            chi16_x_pos_pred, chi16_x_vel_pred, chi16_x_omega_pred, chi16_y_pos_pred, chi16_y_vel_pred, chi16_y_omega_pred, chi16_z_pos_pred, chi16_z_vel_pred, chi16_z_omega_pred : in signed(47 downto 0);
            chi17_x_pos_pred, chi17_x_vel_pred, chi17_x_omega_pred, chi17_y_pos_pred, chi17_y_vel_pred, chi17_y_omega_pred, chi17_z_pos_pred, chi17_z_vel_pred, chi17_z_omega_pred : in signed(47 downto 0);
            chi18_x_pos_pred, chi18_x_vel_pred, chi18_x_omega_pred, chi18_y_pos_pred, chi18_y_vel_pred, chi18_y_omega_pred, chi18_z_pos_pred, chi18_z_vel_pred, chi18_z_omega_pred : in signed(47 downto 0);

            x_pos_mean_pred, x_vel_mean_pred, x_omega_mean_pred : buffer signed(47 downto 0);
            y_pos_mean_pred, y_vel_mean_pred, y_omega_mean_pred : buffer signed(47 downto 0);
            z_pos_mean_pred, z_vel_mean_pred, z_omega_mean_pred : buffer signed(47 downto 0);
            done : out std_logic
        );
    end component;

    component covariance_reconstruct_3d is
        port (
            clk : in std_logic; start : in std_logic;

            x_pos_mean, x_vel_mean, x_omega_mean : in signed(47 downto 0);
            y_pos_mean, y_vel_mean, y_omega_mean : in signed(47 downto 0);
            z_pos_mean, z_vel_mean, z_omega_mean : in signed(47 downto 0);

            chi0_x_pos_pred, chi0_x_vel_pred, chi0_x_omega_pred, chi0_y_pos_pred, chi0_y_vel_pred, chi0_y_omega_pred, chi0_z_pos_pred, chi0_z_vel_pred, chi0_z_omega_pred : in signed(47 downto 0);
            chi1_x_pos_pred, chi1_x_vel_pred, chi1_x_omega_pred, chi1_y_pos_pred, chi1_y_vel_pred, chi1_y_omega_pred, chi1_z_pos_pred, chi1_z_vel_pred, chi1_z_omega_pred : in signed(47 downto 0);
            chi2_x_pos_pred, chi2_x_vel_pred, chi2_x_omega_pred, chi2_y_pos_pred, chi2_y_vel_pred, chi2_y_omega_pred, chi2_z_pos_pred, chi2_z_vel_pred, chi2_z_omega_pred : in signed(47 downto 0);
            chi3_x_pos_pred, chi3_x_vel_pred, chi3_x_omega_pred, chi3_y_pos_pred, chi3_y_vel_pred, chi3_y_omega_pred, chi3_z_pos_pred, chi3_z_vel_pred, chi3_z_omega_pred : in signed(47 downto 0);
            chi4_x_pos_pred, chi4_x_vel_pred, chi4_x_omega_pred, chi4_y_pos_pred, chi4_y_vel_pred, chi4_y_omega_pred, chi4_z_pos_pred, chi4_z_vel_pred, chi4_z_omega_pred : in signed(47 downto 0);
            chi5_x_pos_pred, chi5_x_vel_pred, chi5_x_omega_pred, chi5_y_pos_pred, chi5_y_vel_pred, chi5_y_omega_pred, chi5_z_pos_pred, chi5_z_vel_pred, chi5_z_omega_pred : in signed(47 downto 0);
            chi6_x_pos_pred, chi6_x_vel_pred, chi6_x_omega_pred, chi6_y_pos_pred, chi6_y_vel_pred, chi6_y_omega_pred, chi6_z_pos_pred, chi6_z_vel_pred, chi6_z_omega_pred : in signed(47 downto 0);
            chi7_x_pos_pred, chi7_x_vel_pred, chi7_x_omega_pred, chi7_y_pos_pred, chi7_y_vel_pred, chi7_y_omega_pred, chi7_z_pos_pred, chi7_z_vel_pred, chi7_z_omega_pred : in signed(47 downto 0);
            chi8_x_pos_pred, chi8_x_vel_pred, chi8_x_omega_pred, chi8_y_pos_pred, chi8_y_vel_pred, chi8_y_omega_pred, chi8_z_pos_pred, chi8_z_vel_pred, chi8_z_omega_pred : in signed(47 downto 0);
            chi9_x_pos_pred, chi9_x_vel_pred, chi9_x_omega_pred, chi9_y_pos_pred, chi9_y_vel_pred, chi9_y_omega_pred, chi9_z_pos_pred, chi9_z_vel_pred, chi9_z_omega_pred : in signed(47 downto 0);
            chi10_x_pos_pred, chi10_x_vel_pred, chi10_x_omega_pred, chi10_y_pos_pred, chi10_y_vel_pred, chi10_y_omega_pred, chi10_z_pos_pred, chi10_z_vel_pred, chi10_z_omega_pred : in signed(47 downto 0);
            chi11_x_pos_pred, chi11_x_vel_pred, chi11_x_omega_pred, chi11_y_pos_pred, chi11_y_vel_pred, chi11_y_omega_pred, chi11_z_pos_pred, chi11_z_vel_pred, chi11_z_omega_pred : in signed(47 downto 0);
            chi12_x_pos_pred, chi12_x_vel_pred, chi12_x_omega_pred, chi12_y_pos_pred, chi12_y_vel_pred, chi12_y_omega_pred, chi12_z_pos_pred, chi12_z_vel_pred, chi12_z_omega_pred : in signed(47 downto 0);
            chi13_x_pos_pred, chi13_x_vel_pred, chi13_x_omega_pred, chi13_y_pos_pred, chi13_y_vel_pred, chi13_y_omega_pred, chi13_z_pos_pred, chi13_z_vel_pred, chi13_z_omega_pred : in signed(47 downto 0);
            chi14_x_pos_pred, chi14_x_vel_pred, chi14_x_omega_pred, chi14_y_pos_pred, chi14_y_vel_pred, chi14_y_omega_pred, chi14_z_pos_pred, chi14_z_vel_pred, chi14_z_omega_pred : in signed(47 downto 0);
            chi15_x_pos_pred, chi15_x_vel_pred, chi15_x_omega_pred, chi15_y_pos_pred, chi15_y_vel_pred, chi15_y_omega_pred, chi15_z_pos_pred, chi15_z_vel_pred, chi15_z_omega_pred : in signed(47 downto 0);
            chi16_x_pos_pred, chi16_x_vel_pred, chi16_x_omega_pred, chi16_y_pos_pred, chi16_y_vel_pred, chi16_y_omega_pred, chi16_z_pos_pred, chi16_z_vel_pred, chi16_z_omega_pred : in signed(47 downto 0);
            chi17_x_pos_pred, chi17_x_vel_pred, chi17_x_omega_pred, chi17_y_pos_pred, chi17_y_vel_pred, chi17_y_omega_pred, chi17_z_pos_pred, chi17_z_vel_pred, chi17_z_omega_pred : in signed(47 downto 0);
            chi18_x_pos_pred, chi18_x_vel_pred, chi18_x_omega_pred, chi18_y_pos_pred, chi18_y_vel_pred, chi18_y_omega_pred, chi18_z_pos_pred, chi18_z_vel_pred, chi18_z_omega_pred : in signed(47 downto 0);

            p11_out, p12_out, p13_out, p14_out, p15_out, p16_out, p17_out, p18_out, p19_out : out signed(47 downto 0);
            p22_out, p23_out, p24_out, p25_out, p26_out, p27_out, p28_out, p29_out : out signed(47 downto 0);
            p33_out, p34_out, p35_out, p36_out, p37_out, p38_out, p39_out : out signed(47 downto 0);
            p44_out, p45_out, p46_out, p47_out, p48_out, p49_out : out signed(47 downto 0);
            p55_out, p56_out, p57_out, p58_out, p59_out : out signed(47 downto 0);
            p66_out, p67_out, p68_out, p69_out : out signed(47 downto 0);
            p77_out, p78_out, p79_out : out signed(47 downto 0);
            p88_out, p89_out : out signed(47 downto 0);
            p99_out : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    component process_noise_3d is
        port (
            clk : in std_logic; start : in std_logic;

            p11_in, p12_in, p13_in, p14_in, p15_in, p16_in, p17_in, p18_in, p19_in : in signed(47 downto 0);
            p22_in, p23_in, p24_in, p25_in, p26_in, p27_in, p28_in, p29_in : in signed(47 downto 0);
            p33_in, p34_in, p35_in, p36_in, p37_in, p38_in, p39_in : in signed(47 downto 0);
            p44_in, p45_in, p46_in, p47_in, p48_in, p49_in : in signed(47 downto 0);
            p55_in, p56_in, p57_in, p58_in, p59_in : in signed(47 downto 0);
            p66_in, p67_in, p68_in, p69_in : in signed(47 downto 0);
            p77_in, p78_in, p79_in : in signed(47 downto 0);
            p88_in, p89_in : in signed(47 downto 0);
            p99_in : in signed(47 downto 0);

            p11_out, p12_out, p13_out, p14_out, p15_out, p16_out, p17_out, p18_out, p19_out : out signed(47 downto 0);
            p22_out, p23_out, p24_out, p25_out, p26_out, p27_out, p28_out, p29_out : out signed(47 downto 0);
            p33_out, p34_out, p35_out, p36_out, p37_out, p38_out, p39_out : out signed(47 downto 0);
            p44_out, p45_out, p46_out, p47_out, p48_out, p49_out : out signed(47 downto 0);
            p55_out, p56_out, p57_out, p58_out, p59_out : out signed(47 downto 0);
            p66_out, p67_out, p68_out, p69_out : out signed(47 downto 0);
            p77_out, p78_out, p79_out : out signed(47 downto 0);
            p88_out, p89_out : out signed(47 downto 0);
            p99_out : out signed(47 downto 0);
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

    signal l11_sig, l21_sig, l31_sig, l41_sig, l51_sig, l61_sig, l71_sig, l81_sig, l91_sig : signed(47 downto 0) := (others => '0');
    signal l22_sig, l32_sig, l42_sig, l52_sig, l62_sig, l72_sig, l82_sig, l92_sig : signed(47 downto 0) := (others => '0');
    signal l33_sig, l43_sig, l53_sig, l63_sig, l73_sig, l83_sig, l93_sig : signed(47 downto 0) := (others => '0');
    signal l44_sig, l54_sig, l64_sig, l74_sig, l84_sig, l94_sig : signed(47 downto 0) := (others => '0');
    signal l55_sig, l65_sig, l75_sig, l85_sig, l95_sig : signed(47 downto 0) := (others => '0');
    signal l66_sig, l76_sig, l86_sig, l96_sig : signed(47 downto 0) := (others => '0');
    signal l77_sig, l87_sig, l97_sig : signed(47 downto 0) := (others => '0');
    signal l88_sig, l98_sig : signed(47 downto 0) := (others => '0');
    signal l99_sig : signed(47 downto 0) := (others => '0');

    signal chi_0_x_pos, chi_0_x_vel, chi_0_x_omega, chi_0_y_pos, chi_0_y_vel, chi_0_y_omega, chi_0_z_pos, chi_0_z_vel, chi_0_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_1_x_pos, chi_1_x_vel, chi_1_x_omega, chi_1_y_pos, chi_1_y_vel, chi_1_y_omega, chi_1_z_pos, chi_1_z_vel, chi_1_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_2_x_pos, chi_2_x_vel, chi_2_x_omega, chi_2_y_pos, chi_2_y_vel, chi_2_y_omega, chi_2_z_pos, chi_2_z_vel, chi_2_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_3_x_pos, chi_3_x_vel, chi_3_x_omega, chi_3_y_pos, chi_3_y_vel, chi_3_y_omega, chi_3_z_pos, chi_3_z_vel, chi_3_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_4_x_pos, chi_4_x_vel, chi_4_x_omega, chi_4_y_pos, chi_4_y_vel, chi_4_y_omega, chi_4_z_pos, chi_4_z_vel, chi_4_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_5_x_pos, chi_5_x_vel, chi_5_x_omega, chi_5_y_pos, chi_5_y_vel, chi_5_y_omega, chi_5_z_pos, chi_5_z_vel, chi_5_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_6_x_pos, chi_6_x_vel, chi_6_x_omega, chi_6_y_pos, chi_6_y_vel, chi_6_y_omega, chi_6_z_pos, chi_6_z_vel, chi_6_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_7_x_pos, chi_7_x_vel, chi_7_x_omega, chi_7_y_pos, chi_7_y_vel, chi_7_y_omega, chi_7_z_pos, chi_7_z_vel, chi_7_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_8_x_pos, chi_8_x_vel, chi_8_x_omega, chi_8_y_pos, chi_8_y_vel, chi_8_y_omega, chi_8_z_pos, chi_8_z_vel, chi_8_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_9_x_pos, chi_9_x_vel, chi_9_x_omega, chi_9_y_pos, chi_9_y_vel, chi_9_y_omega, chi_9_z_pos, chi_9_z_vel, chi_9_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_10_x_pos, chi_10_x_vel, chi_10_x_omega, chi_10_y_pos, chi_10_y_vel, chi_10_y_omega, chi_10_z_pos, chi_10_z_vel, chi_10_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_11_x_pos, chi_11_x_vel, chi_11_x_omega, chi_11_y_pos, chi_11_y_vel, chi_11_y_omega, chi_11_z_pos, chi_11_z_vel, chi_11_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_12_x_pos, chi_12_x_vel, chi_12_x_omega, chi_12_y_pos, chi_12_y_vel, chi_12_y_omega, chi_12_z_pos, chi_12_z_vel, chi_12_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_13_x_pos, chi_13_x_vel, chi_13_x_omega, chi_13_y_pos, chi_13_y_vel, chi_13_y_omega, chi_13_z_pos, chi_13_z_vel, chi_13_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_14_x_pos, chi_14_x_vel, chi_14_x_omega, chi_14_y_pos, chi_14_y_vel, chi_14_y_omega, chi_14_z_pos, chi_14_z_vel, chi_14_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_15_x_pos, chi_15_x_vel, chi_15_x_omega, chi_15_y_pos, chi_15_y_vel, chi_15_y_omega, chi_15_z_pos, chi_15_z_vel, chi_15_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_16_x_pos, chi_16_x_vel, chi_16_x_omega, chi_16_y_pos, chi_16_y_vel, chi_16_y_omega, chi_16_z_pos, chi_16_z_vel, chi_16_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_17_x_pos, chi_17_x_vel, chi_17_x_omega, chi_17_y_pos, chi_17_y_vel, chi_17_y_omega, chi_17_z_pos, chi_17_z_vel, chi_17_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_18_x_pos, chi_18_x_vel, chi_18_x_omega, chi_18_y_pos, chi_18_y_vel, chi_18_y_omega, chi_18_z_pos, chi_18_z_vel, chi_18_z_omega : signed(47 downto 0) := (others => '0');

    signal chi_pred_int_0_x_pos, chi_pred_int_0_x_vel, chi_pred_int_0_x_omega, chi_pred_int_0_y_pos, chi_pred_int_0_y_vel, chi_pred_int_0_y_omega, chi_pred_int_0_z_pos, chi_pred_int_0_z_vel, chi_pred_int_0_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_1_x_pos, chi_pred_int_1_x_vel, chi_pred_int_1_x_omega, chi_pred_int_1_y_pos, chi_pred_int_1_y_vel, chi_pred_int_1_y_omega, chi_pred_int_1_z_pos, chi_pred_int_1_z_vel, chi_pred_int_1_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_2_x_pos, chi_pred_int_2_x_vel, chi_pred_int_2_x_omega, chi_pred_int_2_y_pos, chi_pred_int_2_y_vel, chi_pred_int_2_y_omega, chi_pred_int_2_z_pos, chi_pred_int_2_z_vel, chi_pred_int_2_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_3_x_pos, chi_pred_int_3_x_vel, chi_pred_int_3_x_omega, chi_pred_int_3_y_pos, chi_pred_int_3_y_vel, chi_pred_int_3_y_omega, chi_pred_int_3_z_pos, chi_pred_int_3_z_vel, chi_pred_int_3_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_4_x_pos, chi_pred_int_4_x_vel, chi_pred_int_4_x_omega, chi_pred_int_4_y_pos, chi_pred_int_4_y_vel, chi_pred_int_4_y_omega, chi_pred_int_4_z_pos, chi_pred_int_4_z_vel, chi_pred_int_4_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_5_x_pos, chi_pred_int_5_x_vel, chi_pred_int_5_x_omega, chi_pred_int_5_y_pos, chi_pred_int_5_y_vel, chi_pred_int_5_y_omega, chi_pred_int_5_z_pos, chi_pred_int_5_z_vel, chi_pred_int_5_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_6_x_pos, chi_pred_int_6_x_vel, chi_pred_int_6_x_omega, chi_pred_int_6_y_pos, chi_pred_int_6_y_vel, chi_pred_int_6_y_omega, chi_pred_int_6_z_pos, chi_pred_int_6_z_vel, chi_pred_int_6_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_7_x_pos, chi_pred_int_7_x_vel, chi_pred_int_7_x_omega, chi_pred_int_7_y_pos, chi_pred_int_7_y_vel, chi_pred_int_7_y_omega, chi_pred_int_7_z_pos, chi_pred_int_7_z_vel, chi_pred_int_7_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_8_x_pos, chi_pred_int_8_x_vel, chi_pred_int_8_x_omega, chi_pred_int_8_y_pos, chi_pred_int_8_y_vel, chi_pred_int_8_y_omega, chi_pred_int_8_z_pos, chi_pred_int_8_z_vel, chi_pred_int_8_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_9_x_pos, chi_pred_int_9_x_vel, chi_pred_int_9_x_omega, chi_pred_int_9_y_pos, chi_pred_int_9_y_vel, chi_pred_int_9_y_omega, chi_pred_int_9_z_pos, chi_pred_int_9_z_vel, chi_pred_int_9_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_10_x_pos, chi_pred_int_10_x_vel, chi_pred_int_10_x_omega, chi_pred_int_10_y_pos, chi_pred_int_10_y_vel, chi_pred_int_10_y_omega, chi_pred_int_10_z_pos, chi_pred_int_10_z_vel, chi_pred_int_10_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_11_x_pos, chi_pred_int_11_x_vel, chi_pred_int_11_x_omega, chi_pred_int_11_y_pos, chi_pred_int_11_y_vel, chi_pred_int_11_y_omega, chi_pred_int_11_z_pos, chi_pred_int_11_z_vel, chi_pred_int_11_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_12_x_pos, chi_pred_int_12_x_vel, chi_pred_int_12_x_omega, chi_pred_int_12_y_pos, chi_pred_int_12_y_vel, chi_pred_int_12_y_omega, chi_pred_int_12_z_pos, chi_pred_int_12_z_vel, chi_pred_int_12_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_13_x_pos, chi_pred_int_13_x_vel, chi_pred_int_13_x_omega, chi_pred_int_13_y_pos, chi_pred_int_13_y_vel, chi_pred_int_13_y_omega, chi_pred_int_13_z_pos, chi_pred_int_13_z_vel, chi_pred_int_13_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_14_x_pos, chi_pred_int_14_x_vel, chi_pred_int_14_x_omega, chi_pred_int_14_y_pos, chi_pred_int_14_y_vel, chi_pred_int_14_y_omega, chi_pred_int_14_z_pos, chi_pred_int_14_z_vel, chi_pred_int_14_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_15_x_pos, chi_pred_int_15_x_vel, chi_pred_int_15_x_omega, chi_pred_int_15_y_pos, chi_pred_int_15_y_vel, chi_pred_int_15_y_omega, chi_pred_int_15_z_pos, chi_pred_int_15_z_vel, chi_pred_int_15_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_16_x_pos, chi_pred_int_16_x_vel, chi_pred_int_16_x_omega, chi_pred_int_16_y_pos, chi_pred_int_16_y_vel, chi_pred_int_16_y_omega, chi_pred_int_16_z_pos, chi_pred_int_16_z_vel, chi_pred_int_16_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_17_x_pos, chi_pred_int_17_x_vel, chi_pred_int_17_x_omega, chi_pred_int_17_y_pos, chi_pred_int_17_y_vel, chi_pred_int_17_y_omega, chi_pred_int_17_z_pos, chi_pred_int_17_z_vel, chi_pred_int_17_z_omega : signed(47 downto 0) := (others => '0');
    signal chi_pred_int_18_x_pos, chi_pred_int_18_x_vel, chi_pred_int_18_x_omega, chi_pred_int_18_y_pos, chi_pred_int_18_y_vel, chi_pred_int_18_y_omega, chi_pred_int_18_z_pos, chi_pred_int_18_z_vel, chi_pred_int_18_z_omega : signed(47 downto 0) := (others => '0');

    signal x_pos_mean, x_vel_mean, x_omega_mean : signed(47 downto 0) := (others => '0');
    signal y_pos_mean, y_vel_mean, y_omega_mean : signed(47 downto 0) := (others => '0');
    signal z_pos_mean, z_vel_mean, z_omega_mean : signed(47 downto 0) := (others => '0');

    signal p11_cov, p12_cov, p13_cov, p14_cov, p15_cov, p16_cov, p17_cov, p18_cov, p19_cov : signed(47 downto 0) := (others => '0');
    signal p22_cov, p23_cov, p24_cov, p25_cov, p26_cov, p27_cov, p28_cov, p29_cov : signed(47 downto 0) := (others => '0');
    signal p33_cov, p34_cov, p35_cov, p36_cov, p37_cov, p38_cov, p39_cov : signed(47 downto 0) := (others => '0');
    signal p44_cov, p45_cov, p46_cov, p47_cov, p48_cov, p49_cov : signed(47 downto 0) := (others => '0');
    signal p55_cov, p56_cov, p57_cov, p58_cov, p59_cov : signed(47 downto 0) := (others => '0');
    signal p66_cov, p67_cov, p68_cov, p69_cov : signed(47 downto 0) := (others => '0');
    signal p77_cov, p78_cov, p79_cov : signed(47 downto 0) := (others => '0');
    signal p88_cov, p89_cov : signed(47 downto 0) := (others => '0');
    signal p99_cov : signed(47 downto 0) := (others => '0');

begin

    cholesky_comp : cholesky_9x9
        port map (
            clk => clk, start => cholesky_start,

            p11_in => p11_current, p12_in => (others => '0'), p13_in => (others => '0'), p14_in => (others => '0'), p15_in => (others => '0'), p16_in => (others => '0'), p17_in => (others => '0'), p18_in => (others => '0'), p19_in => (others => '0'),
            p22_in => p22_current, p23_in => (others => '0'), p24_in => (others => '0'), p25_in => (others => '0'), p26_in => (others => '0'), p27_in => (others => '0'), p28_in => (others => '0'), p29_in => (others => '0'),
            p33_in => p33_current, p34_in => (others => '0'), p35_in => (others => '0'), p36_in => (others => '0'), p37_in => (others => '0'), p38_in => (others => '0'), p39_in => (others => '0'),
            p44_in => p44_current, p45_in => (others => '0'), p46_in => (others => '0'), p47_in => (others => '0'), p48_in => (others => '0'), p49_in => (others => '0'),
            p55_in => p55_current, p56_in => (others => '0'), p57_in => (others => '0'), p58_in => (others => '0'), p59_in => (others => '0'),
            p66_in => p66_current, p67_in => (others => '0'), p68_in => (others => '0'), p69_in => (others => '0'),
            p77_in => p77_current, p78_in => (others => '0'), p79_in => (others => '0'),
            p88_in => p88_current, p89_in => (others => '0'),
            p99_in => p99_current,

            l11_out => l11_sig, l21_out => l21_sig, l31_out => l31_sig, l41_out => l41_sig, l51_out => l51_sig, l61_out => l61_sig, l71_out => l71_sig, l81_out => l81_sig, l91_out => l91_sig,
            l22_out => l22_sig, l32_out => l32_sig, l42_out => l42_sig, l52_out => l52_sig, l62_out => l62_sig, l72_out => l72_sig, l82_out => l82_sig, l92_out => l92_sig,
            l33_out => l33_sig, l43_out => l43_sig, l53_out => l53_sig, l63_out => l63_sig, l73_out => l73_sig, l83_out => l83_sig, l93_out => l93_sig,
            l44_out => l44_sig, l54_out => l54_sig, l64_out => l64_sig, l74_out => l74_sig, l84_out => l84_sig, l94_out => l94_sig,
            l55_out => l55_sig, l65_out => l65_sig, l75_out => l75_sig, l85_out => l85_sig, l95_out => l95_sig,
            l66_out => l66_sig, l76_out => l76_sig, l86_out => l86_sig, l96_out => l96_sig,
            l77_out => l77_sig, l87_out => l87_sig, l97_out => l97_sig,
            l88_out => l88_sig, l98_out => l98_sig,
            l99_out => l99_sig,
            done => cholesky_done,
            psd_error => cholesky_error
        );

    sigma_gen : sigma_3d
        port map (
            clk => clk,
            rst => rst,
            start => sigma_start,

            x_pos_mean => x_pos_current, x_vel_mean => x_vel_current, x_omega_mean => x_omega_current,
            y_pos_mean => y_pos_current, y_vel_mean => y_vel_current, y_omega_mean => y_omega_current,
            z_pos_mean => z_pos_current, z_vel_mean => z_vel_current, z_omega_mean => z_omega_current,

            cholesky_done => cholesky_done,
            l11 => l11_sig, l21 => l21_sig, l31 => l31_sig, l41 => l41_sig, l51 => l51_sig, l61 => l61_sig, l71 => l71_sig, l81 => l81_sig, l91 => l91_sig,
            l22 => l22_sig, l32 => l32_sig, l42 => l42_sig, l52 => l52_sig, l62 => l62_sig, l72 => l72_sig, l82 => l82_sig, l92 => l92_sig,
            l33 => l33_sig, l43 => l43_sig, l53 => l53_sig, l63 => l63_sig, l73 => l73_sig, l83 => l83_sig, l93 => l93_sig,
            l44 => l44_sig, l54 => l54_sig, l64 => l64_sig, l74 => l74_sig, l84 => l84_sig, l94 => l94_sig,
            l55 => l55_sig, l65 => l65_sig, l75 => l75_sig, l85 => l85_sig, l95 => l95_sig,
            l66 => l66_sig, l76 => l76_sig, l86 => l86_sig, l96 => l96_sig,
            l77 => l77_sig, l87 => l87_sig, l97 => l97_sig,
            l88 => l88_sig, l98 => l98_sig,
            l99 => l99_sig,

            chi0_x_pos => chi_0_x_pos, chi0_x_vel => chi_0_x_vel, chi0_x_omega => chi_0_x_omega, chi0_y_pos => chi_0_y_pos, chi0_y_vel => chi_0_y_vel, chi0_y_omega => chi_0_y_omega, chi0_z_pos => chi_0_z_pos, chi0_z_vel => chi_0_z_vel, chi0_z_omega => chi_0_z_omega,
            chi1_x_pos => chi_1_x_pos, chi1_x_vel => chi_1_x_vel, chi1_x_omega => chi_1_x_omega, chi1_y_pos => chi_1_y_pos, chi1_y_vel => chi_1_y_vel, chi1_y_omega => chi_1_y_omega, chi1_z_pos => chi_1_z_pos, chi1_z_vel => chi_1_z_vel, chi1_z_omega => chi_1_z_omega,
            chi2_x_pos => chi_2_x_pos, chi2_x_vel => chi_2_x_vel, chi2_x_omega => chi_2_x_omega, chi2_y_pos => chi_2_y_pos, chi2_y_vel => chi_2_y_vel, chi2_y_omega => chi_2_y_omega, chi2_z_pos => chi_2_z_pos, chi2_z_vel => chi_2_z_vel, chi2_z_omega => chi_2_z_omega,
            chi3_x_pos => chi_3_x_pos, chi3_x_vel => chi_3_x_vel, chi3_x_omega => chi_3_x_omega, chi3_y_pos => chi_3_y_pos, chi3_y_vel => chi_3_y_vel, chi3_y_omega => chi_3_y_omega, chi3_z_pos => chi_3_z_pos, chi3_z_vel => chi_3_z_vel, chi3_z_omega => chi_3_z_omega,
            chi4_x_pos => chi_4_x_pos, chi4_x_vel => chi_4_x_vel, chi4_x_omega => chi_4_x_omega, chi4_y_pos => chi_4_y_pos, chi4_y_vel => chi_4_y_vel, chi4_y_omega => chi_4_y_omega, chi4_z_pos => chi_4_z_pos, chi4_z_vel => chi_4_z_vel, chi4_z_omega => chi_4_z_omega,
            chi5_x_pos => chi_5_x_pos, chi5_x_vel => chi_5_x_vel, chi5_x_omega => chi_5_x_omega, chi5_y_pos => chi_5_y_pos, chi5_y_vel => chi_5_y_vel, chi5_y_omega => chi_5_y_omega, chi5_z_pos => chi_5_z_pos, chi5_z_vel => chi_5_z_vel, chi5_z_omega => chi_5_z_omega,
            chi6_x_pos => chi_6_x_pos, chi6_x_vel => chi_6_x_vel, chi6_x_omega => chi_6_x_omega, chi6_y_pos => chi_6_y_pos, chi6_y_vel => chi_6_y_vel, chi6_y_omega => chi_6_y_omega, chi6_z_pos => chi_6_z_pos, chi6_z_vel => chi_6_z_vel, chi6_z_omega => chi_6_z_omega,
            chi7_x_pos => chi_7_x_pos, chi7_x_vel => chi_7_x_vel, chi7_x_omega => chi_7_x_omega, chi7_y_pos => chi_7_y_pos, chi7_y_vel => chi_7_y_vel, chi7_y_omega => chi_7_y_omega, chi7_z_pos => chi_7_z_pos, chi7_z_vel => chi_7_z_vel, chi7_z_omega => chi_7_z_omega,
            chi8_x_pos => chi_8_x_pos, chi8_x_vel => chi_8_x_vel, chi8_x_omega => chi_8_x_omega, chi8_y_pos => chi_8_y_pos, chi8_y_vel => chi_8_y_vel, chi8_y_omega => chi_8_y_omega, chi8_z_pos => chi_8_z_pos, chi8_z_vel => chi_8_z_vel, chi8_z_omega => chi_8_z_omega,
            chi9_x_pos => chi_9_x_pos, chi9_x_vel => chi_9_x_vel, chi9_x_omega => chi_9_x_omega, chi9_y_pos => chi_9_y_pos, chi9_y_vel => chi_9_y_vel, chi9_y_omega => chi_9_y_omega, chi9_z_pos => chi_9_z_pos, chi9_z_vel => chi_9_z_vel, chi9_z_omega => chi_9_z_omega,
            chi10_x_pos => chi_10_x_pos, chi10_x_vel => chi_10_x_vel, chi10_x_omega => chi_10_x_omega, chi10_y_pos => chi_10_y_pos, chi10_y_vel => chi_10_y_vel, chi10_y_omega => chi_10_y_omega, chi10_z_pos => chi_10_z_pos, chi10_z_vel => chi_10_z_vel, chi10_z_omega => chi_10_z_omega,
            chi11_x_pos => chi_11_x_pos, chi11_x_vel => chi_11_x_vel, chi11_x_omega => chi_11_x_omega, chi11_y_pos => chi_11_y_pos, chi11_y_vel => chi_11_y_vel, chi11_y_omega => chi_11_y_omega, chi11_z_pos => chi_11_z_pos, chi11_z_vel => chi_11_z_vel, chi11_z_omega => chi_11_z_omega,
            chi12_x_pos => chi_12_x_pos, chi12_x_vel => chi_12_x_vel, chi12_x_omega => chi_12_x_omega, chi12_y_pos => chi_12_y_pos, chi12_y_vel => chi_12_y_vel, chi12_y_omega => chi_12_y_omega, chi12_z_pos => chi_12_z_pos, chi12_z_vel => chi_12_z_vel, chi12_z_omega => chi_12_z_omega,
            chi13_x_pos => chi_13_x_pos, chi13_x_vel => chi_13_x_vel, chi13_x_omega => chi_13_x_omega, chi13_y_pos => chi_13_y_pos, chi13_y_vel => chi_13_y_vel, chi13_y_omega => chi_13_y_omega, chi13_z_pos => chi_13_z_pos, chi13_z_vel => chi_13_z_vel, chi13_z_omega => chi_13_z_omega,
            chi14_x_pos => chi_14_x_pos, chi14_x_vel => chi_14_x_vel, chi14_x_omega => chi_14_x_omega, chi14_y_pos => chi_14_y_pos, chi14_y_vel => chi_14_y_vel, chi14_y_omega => chi_14_y_omega, chi14_z_pos => chi_14_z_pos, chi14_z_vel => chi_14_z_vel, chi14_z_omega => chi_14_z_omega,
            chi15_x_pos => chi_15_x_pos, chi15_x_vel => chi_15_x_vel, chi15_x_omega => chi_15_x_omega, chi15_y_pos => chi_15_y_pos, chi15_y_vel => chi_15_y_vel, chi15_y_omega => chi_15_y_omega, chi15_z_pos => chi_15_z_pos, chi15_z_vel => chi_15_z_vel, chi15_z_omega => chi_15_z_omega,
            chi16_x_pos => chi_16_x_pos, chi16_x_vel => chi_16_x_vel, chi16_x_omega => chi_16_x_omega, chi16_y_pos => chi_16_y_pos, chi16_y_vel => chi_16_y_vel, chi16_y_omega => chi_16_y_omega, chi16_z_pos => chi_16_z_pos, chi16_z_vel => chi_16_z_vel, chi16_z_omega => chi_16_z_omega,
            chi17_x_pos => chi_17_x_pos, chi17_x_vel => chi_17_x_vel, chi17_x_omega => chi_17_x_omega, chi17_y_pos => chi_17_y_pos, chi17_y_vel => chi_17_y_vel, chi17_y_omega => chi_17_y_omega, chi17_z_pos => chi_17_z_pos, chi17_z_vel => chi_17_z_vel, chi17_z_omega => chi_17_z_omega,
            chi18_x_pos => chi_18_x_pos, chi18_x_vel => chi_18_x_vel, chi18_x_omega => chi_18_x_omega, chi18_y_pos => chi_18_y_pos, chi18_y_vel => chi_18_y_vel, chi18_y_omega => chi_18_y_omega, chi18_z_pos => chi_18_z_pos, chi18_z_vel => chi_18_z_vel, chi18_z_omega => chi_18_z_omega,
            done => sigma_done
        );

    predict_comp : predicti_ctr3d
        port map (
            clk => clk, rst => rst, start => predict_start,

            chi0_x_pos_in => chi_0_x_pos, chi0_x_vel_in => chi_0_x_vel, chi0_x_omega_in => chi_0_x_omega, chi0_y_pos_in => chi_0_y_pos, chi0_y_vel_in => chi_0_y_vel, chi0_y_omega_in => chi_0_y_omega, chi0_z_pos_in => chi_0_z_pos, chi0_z_vel_in => chi_0_z_vel, chi0_z_omega_in => chi_0_z_omega,
            chi1_x_pos_in => chi_1_x_pos, chi1_x_vel_in => chi_1_x_vel, chi1_x_omega_in => chi_1_x_omega, chi1_y_pos_in => chi_1_y_pos, chi1_y_vel_in => chi_1_y_vel, chi1_y_omega_in => chi_1_y_omega, chi1_z_pos_in => chi_1_z_pos, chi1_z_vel_in => chi_1_z_vel, chi1_z_omega_in => chi_1_z_omega,
            chi2_x_pos_in => chi_2_x_pos, chi2_x_vel_in => chi_2_x_vel, chi2_x_omega_in => chi_2_x_omega, chi2_y_pos_in => chi_2_y_pos, chi2_y_vel_in => chi_2_y_vel, chi2_y_omega_in => chi_2_y_omega, chi2_z_pos_in => chi_2_z_pos, chi2_z_vel_in => chi_2_z_vel, chi2_z_omega_in => chi_2_z_omega,
            chi3_x_pos_in => chi_3_x_pos, chi3_x_vel_in => chi_3_x_vel, chi3_x_omega_in => chi_3_x_omega, chi3_y_pos_in => chi_3_y_pos, chi3_y_vel_in => chi_3_y_vel, chi3_y_omega_in => chi_3_y_omega, chi3_z_pos_in => chi_3_z_pos, chi3_z_vel_in => chi_3_z_vel, chi3_z_omega_in => chi_3_z_omega,
            chi4_x_pos_in => chi_4_x_pos, chi4_x_vel_in => chi_4_x_vel, chi4_x_omega_in => chi_4_x_omega, chi4_y_pos_in => chi_4_y_pos, chi4_y_vel_in => chi_4_y_vel, chi4_y_omega_in => chi_4_y_omega, chi4_z_pos_in => chi_4_z_pos, chi4_z_vel_in => chi_4_z_vel, chi4_z_omega_in => chi_4_z_omega,
            chi5_x_pos_in => chi_5_x_pos, chi5_x_vel_in => chi_5_x_vel, chi5_x_omega_in => chi_5_x_omega, chi5_y_pos_in => chi_5_y_pos, chi5_y_vel_in => chi_5_y_vel, chi5_y_omega_in => chi_5_y_omega, chi5_z_pos_in => chi_5_z_pos, chi5_z_vel_in => chi_5_z_vel, chi5_z_omega_in => chi_5_z_omega,
            chi6_x_pos_in => chi_6_x_pos, chi6_x_vel_in => chi_6_x_vel, chi6_x_omega_in => chi_6_x_omega, chi6_y_pos_in => chi_6_y_pos, chi6_y_vel_in => chi_6_y_vel, chi6_y_omega_in => chi_6_y_omega, chi6_z_pos_in => chi_6_z_pos, chi6_z_vel_in => chi_6_z_vel, chi6_z_omega_in => chi_6_z_omega,
            chi7_x_pos_in => chi_7_x_pos, chi7_x_vel_in => chi_7_x_vel, chi7_x_omega_in => chi_7_x_omega, chi7_y_pos_in => chi_7_y_pos, chi7_y_vel_in => chi_7_y_vel, chi7_y_omega_in => chi_7_y_omega, chi7_z_pos_in => chi_7_z_pos, chi7_z_vel_in => chi_7_z_vel, chi7_z_omega_in => chi_7_z_omega,
            chi8_x_pos_in => chi_8_x_pos, chi8_x_vel_in => chi_8_x_vel, chi8_x_omega_in => chi_8_x_omega, chi8_y_pos_in => chi_8_y_pos, chi8_y_vel_in => chi_8_y_vel, chi8_y_omega_in => chi_8_y_omega, chi8_z_pos_in => chi_8_z_pos, chi8_z_vel_in => chi_8_z_vel, chi8_z_omega_in => chi_8_z_omega,
            chi9_x_pos_in => chi_9_x_pos, chi9_x_vel_in => chi_9_x_vel, chi9_x_omega_in => chi_9_x_omega, chi9_y_pos_in => chi_9_y_pos, chi9_y_vel_in => chi_9_y_vel, chi9_y_omega_in => chi_9_y_omega, chi9_z_pos_in => chi_9_z_pos, chi9_z_vel_in => chi_9_z_vel, chi9_z_omega_in => chi_9_z_omega,
            chi10_x_pos_in => chi_10_x_pos, chi10_x_vel_in => chi_10_x_vel, chi10_x_omega_in => chi_10_x_omega, chi10_y_pos_in => chi_10_y_pos, chi10_y_vel_in => chi_10_y_vel, chi10_y_omega_in => chi_10_y_omega, chi10_z_pos_in => chi_10_z_pos, chi10_z_vel_in => chi_10_z_vel, chi10_z_omega_in => chi_10_z_omega,
            chi11_x_pos_in => chi_11_x_pos, chi11_x_vel_in => chi_11_x_vel, chi11_x_omega_in => chi_11_x_omega, chi11_y_pos_in => chi_11_y_pos, chi11_y_vel_in => chi_11_y_vel, chi11_y_omega_in => chi_11_y_omega, chi11_z_pos_in => chi_11_z_pos, chi11_z_vel_in => chi_11_z_vel, chi11_z_omega_in => chi_11_z_omega,
            chi12_x_pos_in => chi_12_x_pos, chi12_x_vel_in => chi_12_x_vel, chi12_x_omega_in => chi_12_x_omega, chi12_y_pos_in => chi_12_y_pos, chi12_y_vel_in => chi_12_y_vel, chi12_y_omega_in => chi_12_y_omega, chi12_z_pos_in => chi_12_z_pos, chi12_z_vel_in => chi_12_z_vel, chi12_z_omega_in => chi_12_z_omega,
            chi13_x_pos_in => chi_13_x_pos, chi13_x_vel_in => chi_13_x_vel, chi13_x_omega_in => chi_13_x_omega, chi13_y_pos_in => chi_13_y_pos, chi13_y_vel_in => chi_13_y_vel, chi13_y_omega_in => chi_13_y_omega, chi13_z_pos_in => chi_13_z_pos, chi13_z_vel_in => chi_13_z_vel, chi13_z_omega_in => chi_13_z_omega,
            chi14_x_pos_in => chi_14_x_pos, chi14_x_vel_in => chi_14_x_vel, chi14_x_omega_in => chi_14_x_omega, chi14_y_pos_in => chi_14_y_pos, chi14_y_vel_in => chi_14_y_vel, chi14_y_omega_in => chi_14_y_omega, chi14_z_pos_in => chi_14_z_pos, chi14_z_vel_in => chi_14_z_vel, chi14_z_omega_in => chi_14_z_omega,
            chi15_x_pos_in => chi_15_x_pos, chi15_x_vel_in => chi_15_x_vel, chi15_x_omega_in => chi_15_x_omega, chi15_y_pos_in => chi_15_y_pos, chi15_y_vel_in => chi_15_y_vel, chi15_y_omega_in => chi_15_y_omega, chi15_z_pos_in => chi_15_z_pos, chi15_z_vel_in => chi_15_z_vel, chi15_z_omega_in => chi_15_z_omega,
            chi16_x_pos_in => chi_16_x_pos, chi16_x_vel_in => chi_16_x_vel, chi16_x_omega_in => chi_16_x_omega, chi16_y_pos_in => chi_16_y_pos, chi16_y_vel_in => chi_16_y_vel, chi16_y_omega_in => chi_16_y_omega, chi16_z_pos_in => chi_16_z_pos, chi16_z_vel_in => chi_16_z_vel, chi16_z_omega_in => chi_16_z_omega,
            chi17_x_pos_in => chi_17_x_pos, chi17_x_vel_in => chi_17_x_vel, chi17_x_omega_in => chi_17_x_omega, chi17_y_pos_in => chi_17_y_pos, chi17_y_vel_in => chi_17_y_vel, chi17_y_omega_in => chi_17_y_omega, chi17_z_pos_in => chi_17_z_pos, chi17_z_vel_in => chi_17_z_vel, chi17_z_omega_in => chi_17_z_omega,
            chi18_x_pos_in => chi_18_x_pos, chi18_x_vel_in => chi_18_x_vel, chi18_x_omega_in => chi_18_x_omega, chi18_y_pos_in => chi_18_y_pos, chi18_y_vel_in => chi_18_y_vel, chi18_y_omega_in => chi_18_y_omega, chi18_z_pos_in => chi_18_z_pos, chi18_z_vel_in => chi_18_z_vel, chi18_z_omega_in => chi_18_z_omega,

            chi0_x_pos_pred => chi_pred_int_0_x_pos, chi0_x_vel_pred => chi_pred_int_0_x_vel, chi0_x_omega_pred => chi_pred_int_0_x_omega, chi0_y_pos_pred => chi_pred_int_0_y_pos, chi0_y_vel_pred => chi_pred_int_0_y_vel, chi0_y_omega_pred => chi_pred_int_0_y_omega, chi0_z_pos_pred => chi_pred_int_0_z_pos, chi0_z_vel_pred => chi_pred_int_0_z_vel, chi0_z_omega_pred => chi_pred_int_0_z_omega,
            chi1_x_pos_pred => chi_pred_int_1_x_pos, chi1_x_vel_pred => chi_pred_int_1_x_vel, chi1_x_omega_pred => chi_pred_int_1_x_omega, chi1_y_pos_pred => chi_pred_int_1_y_pos, chi1_y_vel_pred => chi_pred_int_1_y_vel, chi1_y_omega_pred => chi_pred_int_1_y_omega, chi1_z_pos_pred => chi_pred_int_1_z_pos, chi1_z_vel_pred => chi_pred_int_1_z_vel, chi1_z_omega_pred => chi_pred_int_1_z_omega,
            chi2_x_pos_pred => chi_pred_int_2_x_pos, chi2_x_vel_pred => chi_pred_int_2_x_vel, chi2_x_omega_pred => chi_pred_int_2_x_omega, chi2_y_pos_pred => chi_pred_int_2_y_pos, chi2_y_vel_pred => chi_pred_int_2_y_vel, chi2_y_omega_pred => chi_pred_int_2_y_omega, chi2_z_pos_pred => chi_pred_int_2_z_pos, chi2_z_vel_pred => chi_pred_int_2_z_vel, chi2_z_omega_pred => chi_pred_int_2_z_omega,
            chi3_x_pos_pred => chi_pred_int_3_x_pos, chi3_x_vel_pred => chi_pred_int_3_x_vel, chi3_x_omega_pred => chi_pred_int_3_x_omega, chi3_y_pos_pred => chi_pred_int_3_y_pos, chi3_y_vel_pred => chi_pred_int_3_y_vel, chi3_y_omega_pred => chi_pred_int_3_y_omega, chi3_z_pos_pred => chi_pred_int_3_z_pos, chi3_z_vel_pred => chi_pred_int_3_z_vel, chi3_z_omega_pred => chi_pred_int_3_z_omega,
            chi4_x_pos_pred => chi_pred_int_4_x_pos, chi4_x_vel_pred => chi_pred_int_4_x_vel, chi4_x_omega_pred => chi_pred_int_4_x_omega, chi4_y_pos_pred => chi_pred_int_4_y_pos, chi4_y_vel_pred => chi_pred_int_4_y_vel, chi4_y_omega_pred => chi_pred_int_4_y_omega, chi4_z_pos_pred => chi_pred_int_4_z_pos, chi4_z_vel_pred => chi_pred_int_4_z_vel, chi4_z_omega_pred => chi_pred_int_4_z_omega,
            chi5_x_pos_pred => chi_pred_int_5_x_pos, chi5_x_vel_pred => chi_pred_int_5_x_vel, chi5_x_omega_pred => chi_pred_int_5_x_omega, chi5_y_pos_pred => chi_pred_int_5_y_pos, chi5_y_vel_pred => chi_pred_int_5_y_vel, chi5_y_omega_pred => chi_pred_int_5_y_omega, chi5_z_pos_pred => chi_pred_int_5_z_pos, chi5_z_vel_pred => chi_pred_int_5_z_vel, chi5_z_omega_pred => chi_pred_int_5_z_omega,
            chi6_x_pos_pred => chi_pred_int_6_x_pos, chi6_x_vel_pred => chi_pred_int_6_x_vel, chi6_x_omega_pred => chi_pred_int_6_x_omega, chi6_y_pos_pred => chi_pred_int_6_y_pos, chi6_y_vel_pred => chi_pred_int_6_y_vel, chi6_y_omega_pred => chi_pred_int_6_y_omega, chi6_z_pos_pred => chi_pred_int_6_z_pos, chi6_z_vel_pred => chi_pred_int_6_z_vel, chi6_z_omega_pred => chi_pred_int_6_z_omega,
            chi7_x_pos_pred => chi_pred_int_7_x_pos, chi7_x_vel_pred => chi_pred_int_7_x_vel, chi7_x_omega_pred => chi_pred_int_7_x_omega, chi7_y_pos_pred => chi_pred_int_7_y_pos, chi7_y_vel_pred => chi_pred_int_7_y_vel, chi7_y_omega_pred => chi_pred_int_7_y_omega, chi7_z_pos_pred => chi_pred_int_7_z_pos, chi7_z_vel_pred => chi_pred_int_7_z_vel, chi7_z_omega_pred => chi_pred_int_7_z_omega,
            chi8_x_pos_pred => chi_pred_int_8_x_pos, chi8_x_vel_pred => chi_pred_int_8_x_vel, chi8_x_omega_pred => chi_pred_int_8_x_omega, chi8_y_pos_pred => chi_pred_int_8_y_pos, chi8_y_vel_pred => chi_pred_int_8_y_vel, chi8_y_omega_pred => chi_pred_int_8_y_omega, chi8_z_pos_pred => chi_pred_int_8_z_pos, chi8_z_vel_pred => chi_pred_int_8_z_vel, chi8_z_omega_pred => chi_pred_int_8_z_omega,
            chi9_x_pos_pred => chi_pred_int_9_x_pos, chi9_x_vel_pred => chi_pred_int_9_x_vel, chi9_x_omega_pred => chi_pred_int_9_x_omega, chi9_y_pos_pred => chi_pred_int_9_y_pos, chi9_y_vel_pred => chi_pred_int_9_y_vel, chi9_y_omega_pred => chi_pred_int_9_y_omega, chi9_z_pos_pred => chi_pred_int_9_z_pos, chi9_z_vel_pred => chi_pred_int_9_z_vel, chi9_z_omega_pred => chi_pred_int_9_z_omega,
            chi10_x_pos_pred => chi_pred_int_10_x_pos, chi10_x_vel_pred => chi_pred_int_10_x_vel, chi10_x_omega_pred => chi_pred_int_10_x_omega, chi10_y_pos_pred => chi_pred_int_10_y_pos, chi10_y_vel_pred => chi_pred_int_10_y_vel, chi10_y_omega_pred => chi_pred_int_10_y_omega, chi10_z_pos_pred => chi_pred_int_10_z_pos, chi10_z_vel_pred => chi_pred_int_10_z_vel, chi10_z_omega_pred => chi_pred_int_10_z_omega,
            chi11_x_pos_pred => chi_pred_int_11_x_pos, chi11_x_vel_pred => chi_pred_int_11_x_vel, chi11_x_omega_pred => chi_pred_int_11_x_omega, chi11_y_pos_pred => chi_pred_int_11_y_pos, chi11_y_vel_pred => chi_pred_int_11_y_vel, chi11_y_omega_pred => chi_pred_int_11_y_omega, chi11_z_pos_pred => chi_pred_int_11_z_pos, chi11_z_vel_pred => chi_pred_int_11_z_vel, chi11_z_omega_pred => chi_pred_int_11_z_omega,
            chi12_x_pos_pred => chi_pred_int_12_x_pos, chi12_x_vel_pred => chi_pred_int_12_x_vel, chi12_x_omega_pred => chi_pred_int_12_x_omega, chi12_y_pos_pred => chi_pred_int_12_y_pos, chi12_y_vel_pred => chi_pred_int_12_y_vel, chi12_y_omega_pred => chi_pred_int_12_y_omega, chi12_z_pos_pred => chi_pred_int_12_z_pos, chi12_z_vel_pred => chi_pred_int_12_z_vel, chi12_z_omega_pred => chi_pred_int_12_z_omega,
            chi13_x_pos_pred => chi_pred_int_13_x_pos, chi13_x_vel_pred => chi_pred_int_13_x_vel, chi13_x_omega_pred => chi_pred_int_13_x_omega, chi13_y_pos_pred => chi_pred_int_13_y_pos, chi13_y_vel_pred => chi_pred_int_13_y_vel, chi13_y_omega_pred => chi_pred_int_13_y_omega, chi13_z_pos_pred => chi_pred_int_13_z_pos, chi13_z_vel_pred => chi_pred_int_13_z_vel, chi13_z_omega_pred => chi_pred_int_13_z_omega,
            chi14_x_pos_pred => chi_pred_int_14_x_pos, chi14_x_vel_pred => chi_pred_int_14_x_vel, chi14_x_omega_pred => chi_pred_int_14_x_omega, chi14_y_pos_pred => chi_pred_int_14_y_pos, chi14_y_vel_pred => chi_pred_int_14_y_vel, chi14_y_omega_pred => chi_pred_int_14_y_omega, chi14_z_pos_pred => chi_pred_int_14_z_pos, chi14_z_vel_pred => chi_pred_int_14_z_vel, chi14_z_omega_pred => chi_pred_int_14_z_omega,
            chi15_x_pos_pred => chi_pred_int_15_x_pos, chi15_x_vel_pred => chi_pred_int_15_x_vel, chi15_x_omega_pred => chi_pred_int_15_x_omega, chi15_y_pos_pred => chi_pred_int_15_y_pos, chi15_y_vel_pred => chi_pred_int_15_y_vel, chi15_y_omega_pred => chi_pred_int_15_y_omega, chi15_z_pos_pred => chi_pred_int_15_z_pos, chi15_z_vel_pred => chi_pred_int_15_z_vel, chi15_z_omega_pred => chi_pred_int_15_z_omega,
            chi16_x_pos_pred => chi_pred_int_16_x_pos, chi16_x_vel_pred => chi_pred_int_16_x_vel, chi16_x_omega_pred => chi_pred_int_16_x_omega, chi16_y_pos_pred => chi_pred_int_16_y_pos, chi16_y_vel_pred => chi_pred_int_16_y_vel, chi16_y_omega_pred => chi_pred_int_16_y_omega, chi16_z_pos_pred => chi_pred_int_16_z_pos, chi16_z_vel_pred => chi_pred_int_16_z_vel, chi16_z_omega_pred => chi_pred_int_16_z_omega,
            chi17_x_pos_pred => chi_pred_int_17_x_pos, chi17_x_vel_pred => chi_pred_int_17_x_vel, chi17_x_omega_pred => chi_pred_int_17_x_omega, chi17_y_pos_pred => chi_pred_int_17_y_pos, chi17_y_vel_pred => chi_pred_int_17_y_vel, chi17_y_omega_pred => chi_pred_int_17_y_omega, chi17_z_pos_pred => chi_pred_int_17_z_pos, chi17_z_vel_pred => chi_pred_int_17_z_vel, chi17_z_omega_pred => chi_pred_int_17_z_omega,
            chi18_x_pos_pred => chi_pred_int_18_x_pos, chi18_x_vel_pred => chi_pred_int_18_x_vel, chi18_x_omega_pred => chi_pred_int_18_x_omega, chi18_y_pos_pred => chi_pred_int_18_y_pos, chi18_y_vel_pred => chi_pred_int_18_y_vel, chi18_y_omega_pred => chi_pred_int_18_y_omega, chi18_z_pos_pred => chi_pred_int_18_z_pos, chi18_z_vel_pred => chi_pred_int_18_z_vel, chi18_z_omega_pred => chi_pred_int_18_z_omega,
            done => predict_done
        );

    mean_comp : predicted_mean_3d
        port map (
            clk => clk,
            rst => rst,
            start => mean_start,

            chi0_x_pos_pred => chi_pred_int_0_x_pos, chi0_x_vel_pred => chi_pred_int_0_x_vel, chi0_x_omega_pred => chi_pred_int_0_x_omega, chi0_y_pos_pred => chi_pred_int_0_y_pos, chi0_y_vel_pred => chi_pred_int_0_y_vel, chi0_y_omega_pred => chi_pred_int_0_y_omega, chi0_z_pos_pred => chi_pred_int_0_z_pos, chi0_z_vel_pred => chi_pred_int_0_z_vel, chi0_z_omega_pred => chi_pred_int_0_z_omega,
            chi1_x_pos_pred => chi_pred_int_1_x_pos, chi1_x_vel_pred => chi_pred_int_1_x_vel, chi1_x_omega_pred => chi_pred_int_1_x_omega, chi1_y_pos_pred => chi_pred_int_1_y_pos, chi1_y_vel_pred => chi_pred_int_1_y_vel, chi1_y_omega_pred => chi_pred_int_1_y_omega, chi1_z_pos_pred => chi_pred_int_1_z_pos, chi1_z_vel_pred => chi_pred_int_1_z_vel, chi1_z_omega_pred => chi_pred_int_1_z_omega,
            chi2_x_pos_pred => chi_pred_int_2_x_pos, chi2_x_vel_pred => chi_pred_int_2_x_vel, chi2_x_omega_pred => chi_pred_int_2_x_omega, chi2_y_pos_pred => chi_pred_int_2_y_pos, chi2_y_vel_pred => chi_pred_int_2_y_vel, chi2_y_omega_pred => chi_pred_int_2_y_omega, chi2_z_pos_pred => chi_pred_int_2_z_pos, chi2_z_vel_pred => chi_pred_int_2_z_vel, chi2_z_omega_pred => chi_pred_int_2_z_omega,
            chi3_x_pos_pred => chi_pred_int_3_x_pos, chi3_x_vel_pred => chi_pred_int_3_x_vel, chi3_x_omega_pred => chi_pred_int_3_x_omega, chi3_y_pos_pred => chi_pred_int_3_y_pos, chi3_y_vel_pred => chi_pred_int_3_y_vel, chi3_y_omega_pred => chi_pred_int_3_y_omega, chi3_z_pos_pred => chi_pred_int_3_z_pos, chi3_z_vel_pred => chi_pred_int_3_z_vel, chi3_z_omega_pred => chi_pred_int_3_z_omega,
            chi4_x_pos_pred => chi_pred_int_4_x_pos, chi4_x_vel_pred => chi_pred_int_4_x_vel, chi4_x_omega_pred => chi_pred_int_4_x_omega, chi4_y_pos_pred => chi_pred_int_4_y_pos, chi4_y_vel_pred => chi_pred_int_4_y_vel, chi4_y_omega_pred => chi_pred_int_4_y_omega, chi4_z_pos_pred => chi_pred_int_4_z_pos, chi4_z_vel_pred => chi_pred_int_4_z_vel, chi4_z_omega_pred => chi_pred_int_4_z_omega,
            chi5_x_pos_pred => chi_pred_int_5_x_pos, chi5_x_vel_pred => chi_pred_int_5_x_vel, chi5_x_omega_pred => chi_pred_int_5_x_omega, chi5_y_pos_pred => chi_pred_int_5_y_pos, chi5_y_vel_pred => chi_pred_int_5_y_vel, chi5_y_omega_pred => chi_pred_int_5_y_omega, chi5_z_pos_pred => chi_pred_int_5_z_pos, chi5_z_vel_pred => chi_pred_int_5_z_vel, chi5_z_omega_pred => chi_pred_int_5_z_omega,
            chi6_x_pos_pred => chi_pred_int_6_x_pos, chi6_x_vel_pred => chi_pred_int_6_x_vel, chi6_x_omega_pred => chi_pred_int_6_x_omega, chi6_y_pos_pred => chi_pred_int_6_y_pos, chi6_y_vel_pred => chi_pred_int_6_y_vel, chi6_y_omega_pred => chi_pred_int_6_y_omega, chi6_z_pos_pred => chi_pred_int_6_z_pos, chi6_z_vel_pred => chi_pred_int_6_z_vel, chi6_z_omega_pred => chi_pred_int_6_z_omega,
            chi7_x_pos_pred => chi_pred_int_7_x_pos, chi7_x_vel_pred => chi_pred_int_7_x_vel, chi7_x_omega_pred => chi_pred_int_7_x_omega, chi7_y_pos_pred => chi_pred_int_7_y_pos, chi7_y_vel_pred => chi_pred_int_7_y_vel, chi7_y_omega_pred => chi_pred_int_7_y_omega, chi7_z_pos_pred => chi_pred_int_7_z_pos, chi7_z_vel_pred => chi_pred_int_7_z_vel, chi7_z_omega_pred => chi_pred_int_7_z_omega,
            chi8_x_pos_pred => chi_pred_int_8_x_pos, chi8_x_vel_pred => chi_pred_int_8_x_vel, chi8_x_omega_pred => chi_pred_int_8_x_omega, chi8_y_pos_pred => chi_pred_int_8_y_pos, chi8_y_vel_pred => chi_pred_int_8_y_vel, chi8_y_omega_pred => chi_pred_int_8_y_omega, chi8_z_pos_pred => chi_pred_int_8_z_pos, chi8_z_vel_pred => chi_pred_int_8_z_vel, chi8_z_omega_pred => chi_pred_int_8_z_omega,
            chi9_x_pos_pred => chi_pred_int_9_x_pos, chi9_x_vel_pred => chi_pred_int_9_x_vel, chi9_x_omega_pred => chi_pred_int_9_x_omega, chi9_y_pos_pred => chi_pred_int_9_y_pos, chi9_y_vel_pred => chi_pred_int_9_y_vel, chi9_y_omega_pred => chi_pred_int_9_y_omega, chi9_z_pos_pred => chi_pred_int_9_z_pos, chi9_z_vel_pred => chi_pred_int_9_z_vel, chi9_z_omega_pred => chi_pred_int_9_z_omega,
            chi10_x_pos_pred => chi_pred_int_10_x_pos, chi10_x_vel_pred => chi_pred_int_10_x_vel, chi10_x_omega_pred => chi_pred_int_10_x_omega, chi10_y_pos_pred => chi_pred_int_10_y_pos, chi10_y_vel_pred => chi_pred_int_10_y_vel, chi10_y_omega_pred => chi_pred_int_10_y_omega, chi10_z_pos_pred => chi_pred_int_10_z_pos, chi10_z_vel_pred => chi_pred_int_10_z_vel, chi10_z_omega_pred => chi_pred_int_10_z_omega,
            chi11_x_pos_pred => chi_pred_int_11_x_pos, chi11_x_vel_pred => chi_pred_int_11_x_vel, chi11_x_omega_pred => chi_pred_int_11_x_omega, chi11_y_pos_pred => chi_pred_int_11_y_pos, chi11_y_vel_pred => chi_pred_int_11_y_vel, chi11_y_omega_pred => chi_pred_int_11_y_omega, chi11_z_pos_pred => chi_pred_int_11_z_pos, chi11_z_vel_pred => chi_pred_int_11_z_vel, chi11_z_omega_pred => chi_pred_int_11_z_omega,
            chi12_x_pos_pred => chi_pred_int_12_x_pos, chi12_x_vel_pred => chi_pred_int_12_x_vel, chi12_x_omega_pred => chi_pred_int_12_x_omega, chi12_y_pos_pred => chi_pred_int_12_y_pos, chi12_y_vel_pred => chi_pred_int_12_y_vel, chi12_y_omega_pred => chi_pred_int_12_y_omega, chi12_z_pos_pred => chi_pred_int_12_z_pos, chi12_z_vel_pred => chi_pred_int_12_z_vel, chi12_z_omega_pred => chi_pred_int_12_z_omega,
            chi13_x_pos_pred => chi_pred_int_13_x_pos, chi13_x_vel_pred => chi_pred_int_13_x_vel, chi13_x_omega_pred => chi_pred_int_13_x_omega, chi13_y_pos_pred => chi_pred_int_13_y_pos, chi13_y_vel_pred => chi_pred_int_13_y_vel, chi13_y_omega_pred => chi_pred_int_13_y_omega, chi13_z_pos_pred => chi_pred_int_13_z_pos, chi13_z_vel_pred => chi_pred_int_13_z_vel, chi13_z_omega_pred => chi_pred_int_13_z_omega,
            chi14_x_pos_pred => chi_pred_int_14_x_pos, chi14_x_vel_pred => chi_pred_int_14_x_vel, chi14_x_omega_pred => chi_pred_int_14_x_omega, chi14_y_pos_pred => chi_pred_int_14_y_pos, chi14_y_vel_pred => chi_pred_int_14_y_vel, chi14_y_omega_pred => chi_pred_int_14_y_omega, chi14_z_pos_pred => chi_pred_int_14_z_pos, chi14_z_vel_pred => chi_pred_int_14_z_vel, chi14_z_omega_pred => chi_pred_int_14_z_omega,
            chi15_x_pos_pred => chi_pred_int_15_x_pos, chi15_x_vel_pred => chi_pred_int_15_x_vel, chi15_x_omega_pred => chi_pred_int_15_x_omega, chi15_y_pos_pred => chi_pred_int_15_y_pos, chi15_y_vel_pred => chi_pred_int_15_y_vel, chi15_y_omega_pred => chi_pred_int_15_y_omega, chi15_z_pos_pred => chi_pred_int_15_z_pos, chi15_z_vel_pred => chi_pred_int_15_z_vel, chi15_z_omega_pred => chi_pred_int_15_z_omega,
            chi16_x_pos_pred => chi_pred_int_16_x_pos, chi16_x_vel_pred => chi_pred_int_16_x_vel, chi16_x_omega_pred => chi_pred_int_16_x_omega, chi16_y_pos_pred => chi_pred_int_16_y_pos, chi16_y_vel_pred => chi_pred_int_16_y_vel, chi16_y_omega_pred => chi_pred_int_16_y_omega, chi16_z_pos_pred => chi_pred_int_16_z_pos, chi16_z_vel_pred => chi_pred_int_16_z_vel, chi16_z_omega_pred => chi_pred_int_16_z_omega,
            chi17_x_pos_pred => chi_pred_int_17_x_pos, chi17_x_vel_pred => chi_pred_int_17_x_vel, chi17_x_omega_pred => chi_pred_int_17_x_omega, chi17_y_pos_pred => chi_pred_int_17_y_pos, chi17_y_vel_pred => chi_pred_int_17_y_vel, chi17_y_omega_pred => chi_pred_int_17_y_omega, chi17_z_pos_pred => chi_pred_int_17_z_pos, chi17_z_vel_pred => chi_pred_int_17_z_vel, chi17_z_omega_pred => chi_pred_int_17_z_omega,
            chi18_x_pos_pred => chi_pred_int_18_x_pos, chi18_x_vel_pred => chi_pred_int_18_x_vel, chi18_x_omega_pred => chi_pred_int_18_x_omega, chi18_y_pos_pred => chi_pred_int_18_y_pos, chi18_y_vel_pred => chi_pred_int_18_y_vel, chi18_y_omega_pred => chi_pred_int_18_y_omega, chi18_z_pos_pred => chi_pred_int_18_z_pos, chi18_z_vel_pred => chi_pred_int_18_z_vel, chi18_z_omega_pred => chi_pred_int_18_z_omega,

            x_pos_mean_pred => x_pos_mean, x_vel_mean_pred => x_vel_mean, x_omega_mean_pred => x_omega_mean,
            y_pos_mean_pred => y_pos_mean, y_vel_mean_pred => y_vel_mean, y_omega_mean_pred => y_omega_mean,
            z_pos_mean_pred => z_pos_mean, z_vel_mean_pred => z_vel_mean, z_omega_mean_pred => z_omega_mean,
            done => mean_done
        );

    cov_comp : covariance_reconstruct_3d
        port map (
            clk => clk, start => cov_start,

            x_pos_mean => x_pos_mean, x_vel_mean => x_vel_mean, x_omega_mean => x_omega_mean,
            y_pos_mean => y_pos_mean, y_vel_mean => y_vel_mean, y_omega_mean => y_omega_mean,
            z_pos_mean => z_pos_mean, z_vel_mean => z_vel_mean, z_omega_mean => z_omega_mean,

            chi0_x_pos_pred => chi_pred_int_0_x_pos, chi0_x_vel_pred => chi_pred_int_0_x_vel, chi0_x_omega_pred => chi_pred_int_0_x_omega, chi0_y_pos_pred => chi_pred_int_0_y_pos, chi0_y_vel_pred => chi_pred_int_0_y_vel, chi0_y_omega_pred => chi_pred_int_0_y_omega, chi0_z_pos_pred => chi_pred_int_0_z_pos, chi0_z_vel_pred => chi_pred_int_0_z_vel, chi0_z_omega_pred => chi_pred_int_0_z_omega,
            chi1_x_pos_pred => chi_pred_int_1_x_pos, chi1_x_vel_pred => chi_pred_int_1_x_vel, chi1_x_omega_pred => chi_pred_int_1_x_omega, chi1_y_pos_pred => chi_pred_int_1_y_pos, chi1_y_vel_pred => chi_pred_int_1_y_vel, chi1_y_omega_pred => chi_pred_int_1_y_omega, chi1_z_pos_pred => chi_pred_int_1_z_pos, chi1_z_vel_pred => chi_pred_int_1_z_vel, chi1_z_omega_pred => chi_pred_int_1_z_omega,
            chi2_x_pos_pred => chi_pred_int_2_x_pos, chi2_x_vel_pred => chi_pred_int_2_x_vel, chi2_x_omega_pred => chi_pred_int_2_x_omega, chi2_y_pos_pred => chi_pred_int_2_y_pos, chi2_y_vel_pred => chi_pred_int_2_y_vel, chi2_y_omega_pred => chi_pred_int_2_y_omega, chi2_z_pos_pred => chi_pred_int_2_z_pos, chi2_z_vel_pred => chi_pred_int_2_z_vel, chi2_z_omega_pred => chi_pred_int_2_z_omega,
            chi3_x_pos_pred => chi_pred_int_3_x_pos, chi3_x_vel_pred => chi_pred_int_3_x_vel, chi3_x_omega_pred => chi_pred_int_3_x_omega, chi3_y_pos_pred => chi_pred_int_3_y_pos, chi3_y_vel_pred => chi_pred_int_3_y_vel, chi3_y_omega_pred => chi_pred_int_3_y_omega, chi3_z_pos_pred => chi_pred_int_3_z_pos, chi3_z_vel_pred => chi_pred_int_3_z_vel, chi3_z_omega_pred => chi_pred_int_3_z_omega,
            chi4_x_pos_pred => chi_pred_int_4_x_pos, chi4_x_vel_pred => chi_pred_int_4_x_vel, chi4_x_omega_pred => chi_pred_int_4_x_omega, chi4_y_pos_pred => chi_pred_int_4_y_pos, chi4_y_vel_pred => chi_pred_int_4_y_vel, chi4_y_omega_pred => chi_pred_int_4_y_omega, chi4_z_pos_pred => chi_pred_int_4_z_pos, chi4_z_vel_pred => chi_pred_int_4_z_vel, chi4_z_omega_pred => chi_pred_int_4_z_omega,
            chi5_x_pos_pred => chi_pred_int_5_x_pos, chi5_x_vel_pred => chi_pred_int_5_x_vel, chi5_x_omega_pred => chi_pred_int_5_x_omega, chi5_y_pos_pred => chi_pred_int_5_y_pos, chi5_y_vel_pred => chi_pred_int_5_y_vel, chi5_y_omega_pred => chi_pred_int_5_y_omega, chi5_z_pos_pred => chi_pred_int_5_z_pos, chi5_z_vel_pred => chi_pred_int_5_z_vel, chi5_z_omega_pred => chi_pred_int_5_z_omega,
            chi6_x_pos_pred => chi_pred_int_6_x_pos, chi6_x_vel_pred => chi_pred_int_6_x_vel, chi6_x_omega_pred => chi_pred_int_6_x_omega, chi6_y_pos_pred => chi_pred_int_6_y_pos, chi6_y_vel_pred => chi_pred_int_6_y_vel, chi6_y_omega_pred => chi_pred_int_6_y_omega, chi6_z_pos_pred => chi_pred_int_6_z_pos, chi6_z_vel_pred => chi_pred_int_6_z_vel, chi6_z_omega_pred => chi_pred_int_6_z_omega,
            chi7_x_pos_pred => chi_pred_int_7_x_pos, chi7_x_vel_pred => chi_pred_int_7_x_vel, chi7_x_omega_pred => chi_pred_int_7_x_omega, chi7_y_pos_pred => chi_pred_int_7_y_pos, chi7_y_vel_pred => chi_pred_int_7_y_vel, chi7_y_omega_pred => chi_pred_int_7_y_omega, chi7_z_pos_pred => chi_pred_int_7_z_pos, chi7_z_vel_pred => chi_pred_int_7_z_vel, chi7_z_omega_pred => chi_pred_int_7_z_omega,
            chi8_x_pos_pred => chi_pred_int_8_x_pos, chi8_x_vel_pred => chi_pred_int_8_x_vel, chi8_x_omega_pred => chi_pred_int_8_x_omega, chi8_y_pos_pred => chi_pred_int_8_y_pos, chi8_y_vel_pred => chi_pred_int_8_y_vel, chi8_y_omega_pred => chi_pred_int_8_y_omega, chi8_z_pos_pred => chi_pred_int_8_z_pos, chi8_z_vel_pred => chi_pred_int_8_z_vel, chi8_z_omega_pred => chi_pred_int_8_z_omega,
            chi9_x_pos_pred => chi_pred_int_9_x_pos, chi9_x_vel_pred => chi_pred_int_9_x_vel, chi9_x_omega_pred => chi_pred_int_9_x_omega, chi9_y_pos_pred => chi_pred_int_9_y_pos, chi9_y_vel_pred => chi_pred_int_9_y_vel, chi9_y_omega_pred => chi_pred_int_9_y_omega, chi9_z_pos_pred => chi_pred_int_9_z_pos, chi9_z_vel_pred => chi_pred_int_9_z_vel, chi9_z_omega_pred => chi_pred_int_9_z_omega,
            chi10_x_pos_pred => chi_pred_int_10_x_pos, chi10_x_vel_pred => chi_pred_int_10_x_vel, chi10_x_omega_pred => chi_pred_int_10_x_omega, chi10_y_pos_pred => chi_pred_int_10_y_pos, chi10_y_vel_pred => chi_pred_int_10_y_vel, chi10_y_omega_pred => chi_pred_int_10_y_omega, chi10_z_pos_pred => chi_pred_int_10_z_pos, chi10_z_vel_pred => chi_pred_int_10_z_vel, chi10_z_omega_pred => chi_pred_int_10_z_omega,
            chi11_x_pos_pred => chi_pred_int_11_x_pos, chi11_x_vel_pred => chi_pred_int_11_x_vel, chi11_x_omega_pred => chi_pred_int_11_x_omega, chi11_y_pos_pred => chi_pred_int_11_y_pos, chi11_y_vel_pred => chi_pred_int_11_y_vel, chi11_y_omega_pred => chi_pred_int_11_y_omega, chi11_z_pos_pred => chi_pred_int_11_z_pos, chi11_z_vel_pred => chi_pred_int_11_z_vel, chi11_z_omega_pred => chi_pred_int_11_z_omega,
            chi12_x_pos_pred => chi_pred_int_12_x_pos, chi12_x_vel_pred => chi_pred_int_12_x_vel, chi12_x_omega_pred => chi_pred_int_12_x_omega, chi12_y_pos_pred => chi_pred_int_12_y_pos, chi12_y_vel_pred => chi_pred_int_12_y_vel, chi12_y_omega_pred => chi_pred_int_12_y_omega, chi12_z_pos_pred => chi_pred_int_12_z_pos, chi12_z_vel_pred => chi_pred_int_12_z_vel, chi12_z_omega_pred => chi_pred_int_12_z_omega,
            chi13_x_pos_pred => chi_pred_int_13_x_pos, chi13_x_vel_pred => chi_pred_int_13_x_vel, chi13_x_omega_pred => chi_pred_int_13_x_omega, chi13_y_pos_pred => chi_pred_int_13_y_pos, chi13_y_vel_pred => chi_pred_int_13_y_vel, chi13_y_omega_pred => chi_pred_int_13_y_omega, chi13_z_pos_pred => chi_pred_int_13_z_pos, chi13_z_vel_pred => chi_pred_int_13_z_vel, chi13_z_omega_pred => chi_pred_int_13_z_omega,
            chi14_x_pos_pred => chi_pred_int_14_x_pos, chi14_x_vel_pred => chi_pred_int_14_x_vel, chi14_x_omega_pred => chi_pred_int_14_x_omega, chi14_y_pos_pred => chi_pred_int_14_y_pos, chi14_y_vel_pred => chi_pred_int_14_y_vel, chi14_y_omega_pred => chi_pred_int_14_y_omega, chi14_z_pos_pred => chi_pred_int_14_z_pos, chi14_z_vel_pred => chi_pred_int_14_z_vel, chi14_z_omega_pred => chi_pred_int_14_z_omega,
            chi15_x_pos_pred => chi_pred_int_15_x_pos, chi15_x_vel_pred => chi_pred_int_15_x_vel, chi15_x_omega_pred => chi_pred_int_15_x_omega, chi15_y_pos_pred => chi_pred_int_15_y_pos, chi15_y_vel_pred => chi_pred_int_15_y_vel, chi15_y_omega_pred => chi_pred_int_15_y_omega, chi15_z_pos_pred => chi_pred_int_15_z_pos, chi15_z_vel_pred => chi_pred_int_15_z_vel, chi15_z_omega_pred => chi_pred_int_15_z_omega,
            chi16_x_pos_pred => chi_pred_int_16_x_pos, chi16_x_vel_pred => chi_pred_int_16_x_vel, chi16_x_omega_pred => chi_pred_int_16_x_omega, chi16_y_pos_pred => chi_pred_int_16_y_pos, chi16_y_vel_pred => chi_pred_int_16_y_vel, chi16_y_omega_pred => chi_pred_int_16_y_omega, chi16_z_pos_pred => chi_pred_int_16_z_pos, chi16_z_vel_pred => chi_pred_int_16_z_vel, chi16_z_omega_pred => chi_pred_int_16_z_omega,
            chi17_x_pos_pred => chi_pred_int_17_x_pos, chi17_x_vel_pred => chi_pred_int_17_x_vel, chi17_x_omega_pred => chi_pred_int_17_x_omega, chi17_y_pos_pred => chi_pred_int_17_y_pos, chi17_y_vel_pred => chi_pred_int_17_y_vel, chi17_y_omega_pred => chi_pred_int_17_y_omega, chi17_z_pos_pred => chi_pred_int_17_z_pos, chi17_z_vel_pred => chi_pred_int_17_z_vel, chi17_z_omega_pred => chi_pred_int_17_z_omega,
            chi18_x_pos_pred => chi_pred_int_18_x_pos, chi18_x_vel_pred => chi_pred_int_18_x_vel, chi18_x_omega_pred => chi_pred_int_18_x_omega, chi18_y_pos_pred => chi_pred_int_18_y_pos, chi18_y_vel_pred => chi_pred_int_18_y_vel, chi18_y_omega_pred => chi_pred_int_18_y_omega, chi18_z_pos_pred => chi_pred_int_18_z_pos, chi18_z_vel_pred => chi_pred_int_18_z_vel, chi18_z_omega_pred => chi_pred_int_18_z_omega,

            p11_out => p11_cov, p12_out => p12_cov, p13_out => p13_cov, p14_out => p14_cov, p15_out => p15_cov, p16_out => p16_cov, p17_out => p17_cov, p18_out => p18_cov, p19_out => p19_cov,
            p22_out => p22_cov, p23_out => p23_cov, p24_out => p24_cov, p25_out => p25_cov, p26_out => p26_cov, p27_out => p27_cov, p28_out => p28_cov, p29_out => p29_cov,
            p33_out => p33_cov, p34_out => p34_cov, p35_out => p35_cov, p36_out => p36_cov, p37_out => p37_cov, p38_out => p38_cov, p39_out => p39_cov,
            p44_out => p44_cov, p45_out => p45_cov, p46_out => p46_cov, p47_out => p47_cov, p48_out => p48_cov, p49_out => p49_cov,
            p55_out => p55_cov, p56_out => p56_cov, p57_out => p57_cov, p58_out => p58_cov, p59_out => p59_cov,
            p66_out => p66_cov, p67_out => p67_cov, p68_out => p68_cov, p69_out => p69_cov,
            p77_out => p77_cov, p78_out => p78_cov, p79_out => p79_cov,
            p88_out => p88_cov, p89_out => p89_cov,
            p99_out => p99_cov,
            done => cov_done
        );

    noise_comp : process_noise_3d
        port map (
            clk => clk, start => noise_start,

            p11_in => p11_cov, p12_in => p12_cov, p13_in => p13_cov, p14_in => p14_cov, p15_in => p15_cov, p16_in => p16_cov, p17_in => p17_cov, p18_in => p18_cov, p19_in => p19_cov,
            p22_in => p22_cov, p23_in => p23_cov, p24_in => p24_cov, p25_in => p25_cov, p26_in => p26_cov, p27_in => p27_cov, p28_in => p28_cov, p29_in => p29_cov,
            p33_in => p33_cov, p34_in => p34_cov, p35_in => p35_cov, p36_in => p36_cov, p37_in => p37_cov, p38_in => p38_cov, p39_in => p39_cov,
            p44_in => p44_cov, p45_in => p45_cov, p46_in => p46_cov, p47_in => p47_cov, p48_in => p48_cov, p49_in => p49_cov,
            p55_in => p55_cov, p56_in => p56_cov, p57_in => p57_cov, p58_in => p58_cov, p59_in => p59_cov,
            p66_in => p66_cov, p67_in => p67_cov, p68_in => p68_cov, p69_in => p69_cov,
            p77_in => p77_cov, p78_in => p78_cov, p79_in => p79_cov,
            p88_in => p88_cov, p89_in => p89_cov,
            p99_in => p99_cov,

            p11_out => p11_pred, p12_out => p12_pred, p13_out => p13_pred, p14_out => p14_pred, p15_out => p15_pred, p16_out => p16_pred, p17_out => p17_pred, p18_out => p18_pred, p19_out => p19_pred,
            p22_out => p22_pred, p23_out => p23_pred, p24_out => p24_pred, p25_out => p25_pred, p26_out => p26_pred, p27_out => p27_pred, p28_out => p28_pred, p29_out => p29_pred,
            p33_out => p33_pred, p34_out => p34_pred, p35_out => p35_pred, p36_out => p36_pred, p37_out => p37_pred, p38_out => p38_pred, p39_out => p39_pred,
            p44_out => p44_pred, p45_out => p45_pred, p46_out => p46_pred, p47_out => p47_pred, p48_out => p48_pred, p49_out => p49_pred,
            p55_out => p55_pred, p56_out => p56_pred, p57_out => p57_pred, p58_out => p58_pred, p59_out => p59_pred,
            p66_out => p66_pred, p67_out => p67_pred, p68_out => p68_pred, p69_out => p69_pred,
            p77_out => p77_pred, p78_out => p78_pred, p79_out => p79_pred,
            p88_out => p88_pred, p89_out => p89_pred,
            p99_out => p99_pred,
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
                        x_omega_pred <= x_omega_mean;
                        y_pos_pred <= y_pos_mean;
                        y_vel_pred <= y_vel_mean;
                        y_omega_pred <= y_omega_mean;
                        z_pos_pred <= z_pos_mean;
                        z_vel_pred <= z_vel_mean;
                        z_omega_pred <= z_omega_mean;

                        chi_pred_0_x_pos <= chi_pred_int_0_x_pos; chi_pred_0_x_vel <= chi_pred_int_0_x_vel; chi_pred_0_x_omega <= chi_pred_int_0_x_omega;
                        chi_pred_0_y_pos <= chi_pred_int_0_y_pos; chi_pred_0_y_vel <= chi_pred_int_0_y_vel; chi_pred_0_y_omega <= chi_pred_int_0_y_omega;
                        chi_pred_0_z_pos <= chi_pred_int_0_z_pos; chi_pred_0_z_vel <= chi_pred_int_0_z_vel; chi_pred_0_z_omega <= chi_pred_int_0_z_omega;

                        chi_pred_1_x_pos <= chi_pred_int_1_x_pos; chi_pred_1_x_vel <= chi_pred_int_1_x_vel; chi_pred_1_x_omega <= chi_pred_int_1_x_omega;
                        chi_pred_1_y_pos <= chi_pred_int_1_y_pos; chi_pred_1_y_vel <= chi_pred_int_1_y_vel; chi_pred_1_y_omega <= chi_pred_int_1_y_omega;
                        chi_pred_1_z_pos <= chi_pred_int_1_z_pos; chi_pred_1_z_vel <= chi_pred_int_1_z_vel; chi_pred_1_z_omega <= chi_pred_int_1_z_omega;

                        chi_pred_2_x_pos <= chi_pred_int_2_x_pos; chi_pred_2_x_vel <= chi_pred_int_2_x_vel; chi_pred_2_x_omega <= chi_pred_int_2_x_omega;
                        chi_pred_2_y_pos <= chi_pred_int_2_y_pos; chi_pred_2_y_vel <= chi_pred_int_2_y_vel; chi_pred_2_y_omega <= chi_pred_int_2_y_omega;
                        chi_pred_2_z_pos <= chi_pred_int_2_z_pos; chi_pred_2_z_vel <= chi_pred_int_2_z_vel; chi_pred_2_z_omega <= chi_pred_int_2_z_omega;

                        chi_pred_3_x_pos <= chi_pred_int_3_x_pos; chi_pred_3_x_vel <= chi_pred_int_3_x_vel; chi_pred_3_x_omega <= chi_pred_int_3_x_omega;
                        chi_pred_3_y_pos <= chi_pred_int_3_y_pos; chi_pred_3_y_vel <= chi_pred_int_3_y_vel; chi_pred_3_y_omega <= chi_pred_int_3_y_omega;
                        chi_pred_3_z_pos <= chi_pred_int_3_z_pos; chi_pred_3_z_vel <= chi_pred_int_3_z_vel; chi_pred_3_z_omega <= chi_pred_int_3_z_omega;

                        chi_pred_4_x_pos <= chi_pred_int_4_x_pos; chi_pred_4_x_vel <= chi_pred_int_4_x_vel; chi_pred_4_x_omega <= chi_pred_int_4_x_omega;
                        chi_pred_4_y_pos <= chi_pred_int_4_y_pos; chi_pred_4_y_vel <= chi_pred_int_4_y_vel; chi_pred_4_y_omega <= chi_pred_int_4_y_omega;
                        chi_pred_4_z_pos <= chi_pred_int_4_z_pos; chi_pred_4_z_vel <= chi_pred_int_4_z_vel; chi_pred_4_z_omega <= chi_pred_int_4_z_omega;

                        chi_pred_5_x_pos <= chi_pred_int_5_x_pos; chi_pred_5_x_vel <= chi_pred_int_5_x_vel; chi_pred_5_x_omega <= chi_pred_int_5_x_omega;
                        chi_pred_5_y_pos <= chi_pred_int_5_y_pos; chi_pred_5_y_vel <= chi_pred_int_5_y_vel; chi_pred_5_y_omega <= chi_pred_int_5_y_omega;
                        chi_pred_5_z_pos <= chi_pred_int_5_z_pos; chi_pred_5_z_vel <= chi_pred_int_5_z_vel; chi_pred_5_z_omega <= chi_pred_int_5_z_omega;

                        chi_pred_6_x_pos <= chi_pred_int_6_x_pos; chi_pred_6_x_vel <= chi_pred_int_6_x_vel; chi_pred_6_x_omega <= chi_pred_int_6_x_omega;
                        chi_pred_6_y_pos <= chi_pred_int_6_y_pos; chi_pred_6_y_vel <= chi_pred_int_6_y_vel; chi_pred_6_y_omega <= chi_pred_int_6_y_omega;
                        chi_pred_6_z_pos <= chi_pred_int_6_z_pos; chi_pred_6_z_vel <= chi_pred_int_6_z_vel; chi_pred_6_z_omega <= chi_pred_int_6_z_omega;

                        chi_pred_7_x_pos <= chi_pred_int_7_x_pos; chi_pred_7_x_vel <= chi_pred_int_7_x_vel; chi_pred_7_x_omega <= chi_pred_int_7_x_omega;
                        chi_pred_7_y_pos <= chi_pred_int_7_y_pos; chi_pred_7_y_vel <= chi_pred_int_7_y_vel; chi_pred_7_y_omega <= chi_pred_int_7_y_omega;
                        chi_pred_7_z_pos <= chi_pred_int_7_z_pos; chi_pred_7_z_vel <= chi_pred_int_7_z_vel; chi_pred_7_z_omega <= chi_pred_int_7_z_omega;

                        chi_pred_8_x_pos <= chi_pred_int_8_x_pos; chi_pred_8_x_vel <= chi_pred_int_8_x_vel; chi_pred_8_x_omega <= chi_pred_int_8_x_omega;
                        chi_pred_8_y_pos <= chi_pred_int_8_y_pos; chi_pred_8_y_vel <= chi_pred_int_8_y_vel; chi_pred_8_y_omega <= chi_pred_int_8_y_omega;
                        chi_pred_8_z_pos <= chi_pred_int_8_z_pos; chi_pred_8_z_vel <= chi_pred_int_8_z_vel; chi_pred_8_z_omega <= chi_pred_int_8_z_omega;

                        chi_pred_9_x_pos <= chi_pred_int_9_x_pos; chi_pred_9_x_vel <= chi_pred_int_9_x_vel; chi_pred_9_x_omega <= chi_pred_int_9_x_omega;
                        chi_pred_9_y_pos <= chi_pred_int_9_y_pos; chi_pred_9_y_vel <= chi_pred_int_9_y_vel; chi_pred_9_y_omega <= chi_pred_int_9_y_omega;
                        chi_pred_9_z_pos <= chi_pred_int_9_z_pos; chi_pred_9_z_vel <= chi_pred_int_9_z_vel; chi_pred_9_z_omega <= chi_pred_int_9_z_omega;

                        chi_pred_10_x_pos <= chi_pred_int_10_x_pos; chi_pred_10_x_vel <= chi_pred_int_10_x_vel; chi_pred_10_x_omega <= chi_pred_int_10_x_omega;
                        chi_pred_10_y_pos <= chi_pred_int_10_y_pos; chi_pred_10_y_vel <= chi_pred_int_10_y_vel; chi_pred_10_y_omega <= chi_pred_int_10_y_omega;
                        chi_pred_10_z_pos <= chi_pred_int_10_z_pos; chi_pred_10_z_vel <= chi_pred_int_10_z_vel; chi_pred_10_z_omega <= chi_pred_int_10_z_omega;

                        chi_pred_11_x_pos <= chi_pred_int_11_x_pos; chi_pred_11_x_vel <= chi_pred_int_11_x_vel; chi_pred_11_x_omega <= chi_pred_int_11_x_omega;
                        chi_pred_11_y_pos <= chi_pred_int_11_y_pos; chi_pred_11_y_vel <= chi_pred_int_11_y_vel; chi_pred_11_y_omega <= chi_pred_int_11_y_omega;
                        chi_pred_11_z_pos <= chi_pred_int_11_z_pos; chi_pred_11_z_vel <= chi_pred_int_11_z_vel; chi_pred_11_z_omega <= chi_pred_int_11_z_omega;

                        chi_pred_12_x_pos <= chi_pred_int_12_x_pos; chi_pred_12_x_vel <= chi_pred_int_12_x_vel; chi_pred_12_x_omega <= chi_pred_int_12_x_omega;
                        chi_pred_12_y_pos <= chi_pred_int_12_y_pos; chi_pred_12_y_vel <= chi_pred_int_12_y_vel; chi_pred_12_y_omega <= chi_pred_int_12_y_omega;
                        chi_pred_12_z_pos <= chi_pred_int_12_z_pos; chi_pred_12_z_vel <= chi_pred_int_12_z_vel; chi_pred_12_z_omega <= chi_pred_int_12_z_omega;

                        chi_pred_13_x_pos <= chi_pred_int_13_x_pos; chi_pred_13_x_vel <= chi_pred_int_13_x_vel; chi_pred_13_x_omega <= chi_pred_int_13_x_omega;
                        chi_pred_13_y_pos <= chi_pred_int_13_y_pos; chi_pred_13_y_vel <= chi_pred_int_13_y_vel; chi_pred_13_y_omega <= chi_pred_int_13_y_omega;
                        chi_pred_13_z_pos <= chi_pred_int_13_z_pos; chi_pred_13_z_vel <= chi_pred_int_13_z_vel; chi_pred_13_z_omega <= chi_pred_int_13_z_omega;

                        chi_pred_14_x_pos <= chi_pred_int_14_x_pos; chi_pred_14_x_vel <= chi_pred_int_14_x_vel; chi_pred_14_x_omega <= chi_pred_int_14_x_omega;
                        chi_pred_14_y_pos <= chi_pred_int_14_y_pos; chi_pred_14_y_vel <= chi_pred_int_14_y_vel; chi_pred_14_y_omega <= chi_pred_int_14_y_omega;
                        chi_pred_14_z_pos <= chi_pred_int_14_z_pos; chi_pred_14_z_vel <= chi_pred_int_14_z_vel; chi_pred_14_z_omega <= chi_pred_int_14_z_omega;

                        chi_pred_15_x_pos <= chi_pred_int_15_x_pos; chi_pred_15_x_vel <= chi_pred_int_15_x_vel; chi_pred_15_x_omega <= chi_pred_int_15_x_omega;
                        chi_pred_15_y_pos <= chi_pred_int_15_y_pos; chi_pred_15_y_vel <= chi_pred_int_15_y_vel; chi_pred_15_y_omega <= chi_pred_int_15_y_omega;
                        chi_pred_15_z_pos <= chi_pred_int_15_z_pos; chi_pred_15_z_vel <= chi_pred_int_15_z_vel; chi_pred_15_z_omega <= chi_pred_int_15_z_omega;

                        chi_pred_16_x_pos <= chi_pred_int_16_x_pos; chi_pred_16_x_vel <= chi_pred_int_16_x_vel; chi_pred_16_x_omega <= chi_pred_int_16_x_omega;
                        chi_pred_16_y_pos <= chi_pred_int_16_y_pos; chi_pred_16_y_vel <= chi_pred_int_16_y_vel; chi_pred_16_y_omega <= chi_pred_int_16_y_omega;
                        chi_pred_16_z_pos <= chi_pred_int_16_z_pos; chi_pred_16_z_vel <= chi_pred_int_16_z_vel; chi_pred_16_z_omega <= chi_pred_int_16_z_omega;

                        chi_pred_17_x_pos <= chi_pred_int_17_x_pos; chi_pred_17_x_vel <= chi_pred_int_17_x_vel; chi_pred_17_x_omega <= chi_pred_int_17_x_omega;
                        chi_pred_17_y_pos <= chi_pred_int_17_y_pos; chi_pred_17_y_vel <= chi_pred_int_17_y_vel; chi_pred_17_y_omega <= chi_pred_int_17_y_omega;
                        chi_pred_17_z_pos <= chi_pred_int_17_z_pos; chi_pred_17_z_vel <= chi_pred_int_17_z_vel; chi_pred_17_z_omega <= chi_pred_int_17_z_omega;

                        chi_pred_18_x_pos <= chi_pred_int_18_x_pos; chi_pred_18_x_vel <= chi_pred_int_18_x_vel; chi_pred_18_x_omega <= chi_pred_int_18_x_omega;
                        chi_pred_18_y_pos <= chi_pred_int_18_y_pos; chi_pred_18_y_vel <= chi_pred_int_18_y_vel; chi_pred_18_y_omega <= chi_pred_int_18_y_omega;
                        chi_pred_18_z_pos <= chi_pred_int_18_z_pos; chi_pred_18_z_vel <= chi_pred_int_18_z_vel; chi_pred_18_z_omega <= chi_pred_int_18_z_omega;

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
