library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sr_prediction_phase_singer_3d is
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        start : in  std_logic;

        x_pos_current, x_vel_current, x_acc_current : in signed(47 downto 0);
        y_pos_current, y_vel_current, y_acc_current : in signed(47 downto 0);
        z_pos_current, z_vel_current, z_acc_current : in signed(47 downto 0);

        l11_current, l21_current, l31_current, l41_current, l51_current, l61_current, l71_current, l81_current, l91_current : in signed(47 downto 0);
        l22_current, l32_current, l42_current, l52_current, l62_current, l72_current, l82_current, l92_current : in signed(47 downto 0);
        l33_current, l43_current, l53_current, l63_current, l73_current, l83_current, l93_current : in signed(47 downto 0);
        l44_current, l54_current, l64_current, l74_current, l84_current, l94_current : in signed(47 downto 0);
        l55_current, l65_current, l75_current, l85_current, l95_current : in signed(47 downto 0);
        l66_current, l76_current, l86_current, l96_current : in signed(47 downto 0);
        l77_current, l87_current, l97_current : in signed(47 downto 0);
        l88_current, l98_current : in signed(47 downto 0);
        l99_current : in signed(47 downto 0);

        x_pos_pred, x_vel_pred, x_acc_pred : out signed(47 downto 0);
        y_pos_pred, y_vel_pred, y_acc_pred : out signed(47 downto 0);
        z_pos_pred, z_vel_pred, z_acc_pred : out signed(47 downto 0);

        l11_pred, l21_pred, l31_pred, l41_pred, l51_pred, l61_pred, l71_pred, l81_pred, l91_pred : out signed(47 downto 0);
        l22_pred, l32_pred, l42_pred, l52_pred, l62_pred, l72_pred, l82_pred, l92_pred : out signed(47 downto 0);
        l33_pred, l43_pred, l53_pred, l63_pred, l73_pred, l83_pred, l93_pred : out signed(47 downto 0);
        l44_pred, l54_pred, l64_pred, l74_pred, l84_pred, l94_pred : out signed(47 downto 0);
        l55_pred, l65_pred, l75_pred, l85_pred, l95_pred : out signed(47 downto 0);
        l66_pred, l76_pred, l86_pred, l96_pred : out signed(47 downto 0);
        l77_pred, l87_pred, l97_pred : out signed(47 downto 0);
        l88_pred, l98_pred : out signed(47 downto 0);
        l99_pred : out signed(47 downto 0);

        chi_pred_0_x_pos, chi_pred_0_x_vel, chi_pred_0_x_acc, chi_pred_0_y_pos, chi_pred_0_y_vel, chi_pred_0_y_acc, chi_pred_0_z_pos, chi_pred_0_z_vel, chi_pred_0_z_acc : out signed(47 downto 0);
        chi_pred_1_x_pos, chi_pred_1_x_vel, chi_pred_1_x_acc, chi_pred_1_y_pos, chi_pred_1_y_vel, chi_pred_1_y_acc, chi_pred_1_z_pos, chi_pred_1_z_vel, chi_pred_1_z_acc : out signed(47 downto 0);
        chi_pred_2_x_pos, chi_pred_2_x_vel, chi_pred_2_x_acc, chi_pred_2_y_pos, chi_pred_2_y_vel, chi_pred_2_y_acc, chi_pred_2_z_pos, chi_pred_2_z_vel, chi_pred_2_z_acc : out signed(47 downto 0);
        chi_pred_3_x_pos, chi_pred_3_x_vel, chi_pred_3_x_acc, chi_pred_3_y_pos, chi_pred_3_y_vel, chi_pred_3_y_acc, chi_pred_3_z_pos, chi_pred_3_z_vel, chi_pred_3_z_acc : out signed(47 downto 0);
        chi_pred_4_x_pos, chi_pred_4_x_vel, chi_pred_4_x_acc, chi_pred_4_y_pos, chi_pred_4_y_vel, chi_pred_4_y_acc, chi_pred_4_z_pos, chi_pred_4_z_vel, chi_pred_4_z_acc : out signed(47 downto 0);
        chi_pred_5_x_pos, chi_pred_5_x_vel, chi_pred_5_x_acc, chi_pred_5_y_pos, chi_pred_5_y_vel, chi_pred_5_y_acc, chi_pred_5_z_pos, chi_pred_5_z_vel, chi_pred_5_z_acc : out signed(47 downto 0);
        chi_pred_6_x_pos, chi_pred_6_x_vel, chi_pred_6_x_acc, chi_pred_6_y_pos, chi_pred_6_y_vel, chi_pred_6_y_acc, chi_pred_6_z_pos, chi_pred_6_z_vel, chi_pred_6_z_acc : out signed(47 downto 0);
        chi_pred_7_x_pos, chi_pred_7_x_vel, chi_pred_7_x_acc, chi_pred_7_y_pos, chi_pred_7_y_vel, chi_pred_7_y_acc, chi_pred_7_z_pos, chi_pred_7_z_vel, chi_pred_7_z_acc : out signed(47 downto 0);
        chi_pred_8_x_pos, chi_pred_8_x_vel, chi_pred_8_x_acc, chi_pred_8_y_pos, chi_pred_8_y_vel, chi_pred_8_y_acc, chi_pred_8_z_pos, chi_pred_8_z_vel, chi_pred_8_z_acc : out signed(47 downto 0);
        chi_pred_9_x_pos, chi_pred_9_x_vel, chi_pred_9_x_acc, chi_pred_9_y_pos, chi_pred_9_y_vel, chi_pred_9_y_acc, chi_pred_9_z_pos, chi_pred_9_z_vel, chi_pred_9_z_acc : out signed(47 downto 0);
        chi_pred_10_x_pos, chi_pred_10_x_vel, chi_pred_10_x_acc, chi_pred_10_y_pos, chi_pred_10_y_vel, chi_pred_10_y_acc, chi_pred_10_z_pos, chi_pred_10_z_vel, chi_pred_10_z_acc : out signed(47 downto 0);
        chi_pred_11_x_pos, chi_pred_11_x_vel, chi_pred_11_x_acc, chi_pred_11_y_pos, chi_pred_11_y_vel, chi_pred_11_y_acc, chi_pred_11_z_pos, chi_pred_11_z_vel, chi_pred_11_z_acc : out signed(47 downto 0);
        chi_pred_12_x_pos, chi_pred_12_x_vel, chi_pred_12_x_acc, chi_pred_12_y_pos, chi_pred_12_y_vel, chi_pred_12_y_acc, chi_pred_12_z_pos, chi_pred_12_z_vel, chi_pred_12_z_acc : out signed(47 downto 0);
        chi_pred_13_x_pos, chi_pred_13_x_vel, chi_pred_13_x_acc, chi_pred_13_y_pos, chi_pred_13_y_vel, chi_pred_13_y_acc, chi_pred_13_z_pos, chi_pred_13_z_vel, chi_pred_13_z_acc : out signed(47 downto 0);
        chi_pred_14_x_pos, chi_pred_14_x_vel, chi_pred_14_x_acc, chi_pred_14_y_pos, chi_pred_14_y_vel, chi_pred_14_y_acc, chi_pred_14_z_pos, chi_pred_14_z_vel, chi_pred_14_z_acc : out signed(47 downto 0);
        chi_pred_15_x_pos, chi_pred_15_x_vel, chi_pred_15_x_acc, chi_pred_15_y_pos, chi_pred_15_y_vel, chi_pred_15_y_acc, chi_pred_15_z_pos, chi_pred_15_z_vel, chi_pred_15_z_acc : out signed(47 downto 0);
        chi_pred_16_x_pos, chi_pred_16_x_vel, chi_pred_16_x_acc, chi_pred_16_y_pos, chi_pred_16_y_vel, chi_pred_16_y_acc, chi_pred_16_z_pos, chi_pred_16_z_vel, chi_pred_16_z_acc : out signed(47 downto 0);
        chi_pred_17_x_pos, chi_pred_17_x_vel, chi_pred_17_x_acc, chi_pred_17_y_pos, chi_pred_17_y_vel, chi_pred_17_y_acc, chi_pred_17_z_pos, chi_pred_17_z_vel, chi_pred_17_z_acc : out signed(47 downto 0);
        chi_pred_18_x_pos, chi_pred_18_x_vel, chi_pred_18_x_acc, chi_pred_18_y_pos, chi_pred_18_y_vel, chi_pred_18_y_acc, chi_pred_18_z_pos, chi_pred_18_z_vel, chi_pred_18_z_acc : out signed(47 downto 0);

        done : out std_logic
    );
end sr_prediction_phase_singer_3d;

architecture Behavioral of sr_prediction_phase_singer_3d is

    component sigma_3d is
        port (
            clk : in std_logic;
            rst : in std_logic;
            start : in std_logic;
            x_pos_mean, x_vel_mean, x_acc_mean : in signed(47 downto 0);
            y_pos_mean, y_vel_mean, y_acc_mean : in signed(47 downto 0);
            z_pos_mean, z_vel_mean, z_acc_mean : in signed(47 downto 0);
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
            chi0_x_pos, chi0_x_vel, chi0_x_acc, chi0_y_pos, chi0_y_vel, chi0_y_acc, chi0_z_pos, chi0_z_vel, chi0_z_acc : out signed(47 downto 0);
            chi1_x_pos, chi1_x_vel, chi1_x_acc, chi1_y_pos, chi1_y_vel, chi1_y_acc, chi1_z_pos, chi1_z_vel, chi1_z_acc : out signed(47 downto 0);
            chi2_x_pos, chi2_x_vel, chi2_x_acc, chi2_y_pos, chi2_y_vel, chi2_y_acc, chi2_z_pos, chi2_z_vel, chi2_z_acc : out signed(47 downto 0);
            chi3_x_pos, chi3_x_vel, chi3_x_acc, chi3_y_pos, chi3_y_vel, chi3_y_acc, chi3_z_pos, chi3_z_vel, chi3_z_acc : out signed(47 downto 0);
            chi4_x_pos, chi4_x_vel, chi4_x_acc, chi4_y_pos, chi4_y_vel, chi4_y_acc, chi4_z_pos, chi4_z_vel, chi4_z_acc : out signed(47 downto 0);
            chi5_x_pos, chi5_x_vel, chi5_x_acc, chi5_y_pos, chi5_y_vel, chi5_y_acc, chi5_z_pos, chi5_z_vel, chi5_z_acc : out signed(47 downto 0);
            chi6_x_pos, chi6_x_vel, chi6_x_acc, chi6_y_pos, chi6_y_vel, chi6_y_acc, chi6_z_pos, chi6_z_vel, chi6_z_acc : out signed(47 downto 0);
            chi7_x_pos, chi7_x_vel, chi7_x_acc, chi7_y_pos, chi7_y_vel, chi7_y_acc, chi7_z_pos, chi7_z_vel, chi7_z_acc : out signed(47 downto 0);
            chi8_x_pos, chi8_x_vel, chi8_x_acc, chi8_y_pos, chi8_y_vel, chi8_y_acc, chi8_z_pos, chi8_z_vel, chi8_z_acc : out signed(47 downto 0);
            chi9_x_pos, chi9_x_vel, chi9_x_acc, chi9_y_pos, chi9_y_vel, chi9_y_acc, chi9_z_pos, chi9_z_vel, chi9_z_acc : out signed(47 downto 0);
            chi10_x_pos, chi10_x_vel, chi10_x_acc, chi10_y_pos, chi10_y_vel, chi10_y_acc, chi10_z_pos, chi10_z_vel, chi10_z_acc : out signed(47 downto 0);
            chi11_x_pos, chi11_x_vel, chi11_x_acc, chi11_y_pos, chi11_y_vel, chi11_y_acc, chi11_z_pos, chi11_z_vel, chi11_z_acc : out signed(47 downto 0);
            chi12_x_pos, chi12_x_vel, chi12_x_acc, chi12_y_pos, chi12_y_vel, chi12_y_acc, chi12_z_pos, chi12_z_vel, chi12_z_acc : out signed(47 downto 0);
            chi13_x_pos, chi13_x_vel, chi13_x_acc, chi13_y_pos, chi13_y_vel, chi13_y_acc, chi13_z_pos, chi13_z_vel, chi13_z_acc : out signed(47 downto 0);
            chi14_x_pos, chi14_x_vel, chi14_x_acc, chi14_y_pos, chi14_y_vel, chi14_y_acc, chi14_z_pos, chi14_z_vel, chi14_z_acc : out signed(47 downto 0);
            chi15_x_pos, chi15_x_vel, chi15_x_acc, chi15_y_pos, chi15_y_vel, chi15_y_acc, chi15_z_pos, chi15_z_vel, chi15_z_acc : out signed(47 downto 0);
            chi16_x_pos, chi16_x_vel, chi16_x_acc, chi16_y_pos, chi16_y_vel, chi16_y_acc, chi16_z_pos, chi16_z_vel, chi16_z_acc : out signed(47 downto 0);
            chi17_x_pos, chi17_x_vel, chi17_x_acc, chi17_y_pos, chi17_y_vel, chi17_y_acc, chi17_z_pos, chi17_z_vel, chi17_z_acc : out signed(47 downto 0);
            chi18_x_pos, chi18_x_vel, chi18_x_acc, chi18_y_pos, chi18_y_vel, chi18_y_acc, chi18_z_pos, chi18_z_vel, chi18_z_acc : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    component predicti_singer3d is
        generic (
            TAU_Q24_24       : signed(47 downto 0) := to_signed(33554432, 48);
            SIGMA_A_SQ_Q24_24: signed(47 downto 0) := to_signed(419430400, 48);
            DT_Q24_24        : signed(47 downto 0) := to_signed(335544, 48)
        );
        port (
            clk : in std_logic; reset : in std_logic; start : in std_logic;
            a_mean_x, a_mean_y, a_mean_z : in signed(47 downto 0);
            cycle_num : in integer range 0 to 1000;
            chi0_x_pos_in, chi0_x_vel_in, chi0_x_acc_in, chi0_y_pos_in, chi0_y_vel_in, chi0_y_acc_in, chi0_z_pos_in, chi0_z_vel_in, chi0_z_acc_in : in signed(47 downto 0);
            chi1_x_pos_in, chi1_x_vel_in, chi1_x_acc_in, chi1_y_pos_in, chi1_y_vel_in, chi1_y_acc_in, chi1_z_pos_in, chi1_z_vel_in, chi1_z_acc_in : in signed(47 downto 0);
            chi2_x_pos_in, chi2_x_vel_in, chi2_x_acc_in, chi2_y_pos_in, chi2_y_vel_in, chi2_y_acc_in, chi2_z_pos_in, chi2_z_vel_in, chi2_z_acc_in : in signed(47 downto 0);
            chi3_x_pos_in, chi3_x_vel_in, chi3_x_acc_in, chi3_y_pos_in, chi3_y_vel_in, chi3_y_acc_in, chi3_z_pos_in, chi3_z_vel_in, chi3_z_acc_in : in signed(47 downto 0);
            chi4_x_pos_in, chi4_x_vel_in, chi4_x_acc_in, chi4_y_pos_in, chi4_y_vel_in, chi4_y_acc_in, chi4_z_pos_in, chi4_z_vel_in, chi4_z_acc_in : in signed(47 downto 0);
            chi5_x_pos_in, chi5_x_vel_in, chi5_x_acc_in, chi5_y_pos_in, chi5_y_vel_in, chi5_y_acc_in, chi5_z_pos_in, chi5_z_vel_in, chi5_z_acc_in : in signed(47 downto 0);
            chi6_x_pos_in, chi6_x_vel_in, chi6_x_acc_in, chi6_y_pos_in, chi6_y_vel_in, chi6_y_acc_in, chi6_z_pos_in, chi6_z_vel_in, chi6_z_acc_in : in signed(47 downto 0);
            chi7_x_pos_in, chi7_x_vel_in, chi7_x_acc_in, chi7_y_pos_in, chi7_y_vel_in, chi7_y_acc_in, chi7_z_pos_in, chi7_z_vel_in, chi7_z_acc_in : in signed(47 downto 0);
            chi8_x_pos_in, chi8_x_vel_in, chi8_x_acc_in, chi8_y_pos_in, chi8_y_vel_in, chi8_y_acc_in, chi8_z_pos_in, chi8_z_vel_in, chi8_z_acc_in : in signed(47 downto 0);
            chi9_x_pos_in, chi9_x_vel_in, chi9_x_acc_in, chi9_y_pos_in, chi9_y_vel_in, chi9_y_acc_in, chi9_z_pos_in, chi9_z_vel_in, chi9_z_acc_in : in signed(47 downto 0);
            chi10_x_pos_in, chi10_x_vel_in, chi10_x_acc_in, chi10_y_pos_in, chi10_y_vel_in, chi10_y_acc_in, chi10_z_pos_in, chi10_z_vel_in, chi10_z_acc_in : in signed(47 downto 0);
            chi11_x_pos_in, chi11_x_vel_in, chi11_x_acc_in, chi11_y_pos_in, chi11_y_vel_in, chi11_y_acc_in, chi11_z_pos_in, chi11_z_vel_in, chi11_z_acc_in : in signed(47 downto 0);
            chi12_x_pos_in, chi12_x_vel_in, chi12_x_acc_in, chi12_y_pos_in, chi12_y_vel_in, chi12_y_acc_in, chi12_z_pos_in, chi12_z_vel_in, chi12_z_acc_in : in signed(47 downto 0);
            chi13_x_pos_in, chi13_x_vel_in, chi13_x_acc_in, chi13_y_pos_in, chi13_y_vel_in, chi13_y_acc_in, chi13_z_pos_in, chi13_z_vel_in, chi13_z_acc_in : in signed(47 downto 0);
            chi14_x_pos_in, chi14_x_vel_in, chi14_x_acc_in, chi14_y_pos_in, chi14_y_vel_in, chi14_y_acc_in, chi14_z_pos_in, chi14_z_vel_in, chi14_z_acc_in : in signed(47 downto 0);
            chi15_x_pos_in, chi15_x_vel_in, chi15_x_acc_in, chi15_y_pos_in, chi15_y_vel_in, chi15_y_acc_in, chi15_z_pos_in, chi15_z_vel_in, chi15_z_acc_in : in signed(47 downto 0);
            chi16_x_pos_in, chi16_x_vel_in, chi16_x_acc_in, chi16_y_pos_in, chi16_y_vel_in, chi16_y_acc_in, chi16_z_pos_in, chi16_z_vel_in, chi16_z_acc_in : in signed(47 downto 0);
            chi17_x_pos_in, chi17_x_vel_in, chi17_x_acc_in, chi17_y_pos_in, chi17_y_vel_in, chi17_y_acc_in, chi17_z_pos_in, chi17_z_vel_in, chi17_z_acc_in : in signed(47 downto 0);
            chi18_x_pos_in, chi18_x_vel_in, chi18_x_acc_in, chi18_y_pos_in, chi18_y_vel_in, chi18_y_acc_in, chi18_z_pos_in, chi18_z_vel_in, chi18_z_acc_in : in signed(47 downto 0);
            chi0_x_pos_pred, chi0_x_vel_pred, chi0_x_acc_pred, chi0_y_pos_pred, chi0_y_vel_pred, chi0_y_acc_pred, chi0_z_pos_pred, chi0_z_vel_pred, chi0_z_acc_pred : out signed(47 downto 0);
            chi1_x_pos_pred, chi1_x_vel_pred, chi1_x_acc_pred, chi1_y_pos_pred, chi1_y_vel_pred, chi1_y_acc_pred, chi1_z_pos_pred, chi1_z_vel_pred, chi1_z_acc_pred : out signed(47 downto 0);
            chi2_x_pos_pred, chi2_x_vel_pred, chi2_x_acc_pred, chi2_y_pos_pred, chi2_y_vel_pred, chi2_y_acc_pred, chi2_z_pos_pred, chi2_z_vel_pred, chi2_z_acc_pred : out signed(47 downto 0);
            chi3_x_pos_pred, chi3_x_vel_pred, chi3_x_acc_pred, chi3_y_pos_pred, chi3_y_vel_pred, chi3_y_acc_pred, chi3_z_pos_pred, chi3_z_vel_pred, chi3_z_acc_pred : out signed(47 downto 0);
            chi4_x_pos_pred, chi4_x_vel_pred, chi4_x_acc_pred, chi4_y_pos_pred, chi4_y_vel_pred, chi4_y_acc_pred, chi4_z_pos_pred, chi4_z_vel_pred, chi4_z_acc_pred : out signed(47 downto 0);
            chi5_x_pos_pred, chi5_x_vel_pred, chi5_x_acc_pred, chi5_y_pos_pred, chi5_y_vel_pred, chi5_y_acc_pred, chi5_z_pos_pred, chi5_z_vel_pred, chi5_z_acc_pred : out signed(47 downto 0);
            chi6_x_pos_pred, chi6_x_vel_pred, chi6_x_acc_pred, chi6_y_pos_pred, chi6_y_vel_pred, chi6_y_acc_pred, chi6_z_pos_pred, chi6_z_vel_pred, chi6_z_acc_pred : out signed(47 downto 0);
            chi7_x_pos_pred, chi7_x_vel_pred, chi7_x_acc_pred, chi7_y_pos_pred, chi7_y_vel_pred, chi7_y_acc_pred, chi7_z_pos_pred, chi7_z_vel_pred, chi7_z_acc_pred : out signed(47 downto 0);
            chi8_x_pos_pred, chi8_x_vel_pred, chi8_x_acc_pred, chi8_y_pos_pred, chi8_y_vel_pred, chi8_y_acc_pred, chi8_z_pos_pred, chi8_z_vel_pred, chi8_z_acc_pred : out signed(47 downto 0);
            chi9_x_pos_pred, chi9_x_vel_pred, chi9_x_acc_pred, chi9_y_pos_pred, chi9_y_vel_pred, chi9_y_acc_pred, chi9_z_pos_pred, chi9_z_vel_pred, chi9_z_acc_pred : out signed(47 downto 0);
            chi10_x_pos_pred, chi10_x_vel_pred, chi10_x_acc_pred, chi10_y_pos_pred, chi10_y_vel_pred, chi10_y_acc_pred, chi10_z_pos_pred, chi10_z_vel_pred, chi10_z_acc_pred : out signed(47 downto 0);
            chi11_x_pos_pred, chi11_x_vel_pred, chi11_x_acc_pred, chi11_y_pos_pred, chi11_y_vel_pred, chi11_y_acc_pred, chi11_z_pos_pred, chi11_z_vel_pred, chi11_z_acc_pred : out signed(47 downto 0);
            chi12_x_pos_pred, chi12_x_vel_pred, chi12_x_acc_pred, chi12_y_pos_pred, chi12_y_vel_pred, chi12_y_acc_pred, chi12_z_pos_pred, chi12_z_vel_pred, chi12_z_acc_pred : out signed(47 downto 0);
            chi13_x_pos_pred, chi13_x_vel_pred, chi13_x_acc_pred, chi13_y_pos_pred, chi13_y_vel_pred, chi13_y_acc_pred, chi13_z_pos_pred, chi13_z_vel_pred, chi13_z_acc_pred : out signed(47 downto 0);
            chi14_x_pos_pred, chi14_x_vel_pred, chi14_x_acc_pred, chi14_y_pos_pred, chi14_y_vel_pred, chi14_y_acc_pred, chi14_z_pos_pred, chi14_z_vel_pred, chi14_z_acc_pred : out signed(47 downto 0);
            chi15_x_pos_pred, chi15_x_vel_pred, chi15_x_acc_pred, chi15_y_pos_pred, chi15_y_vel_pred, chi15_y_acc_pred, chi15_z_pos_pred, chi15_z_vel_pred, chi15_z_acc_pred : out signed(47 downto 0);
            chi16_x_pos_pred, chi16_x_vel_pred, chi16_x_acc_pred, chi16_y_pos_pred, chi16_y_vel_pred, chi16_y_acc_pred, chi16_z_pos_pred, chi16_z_vel_pred, chi16_z_acc_pred : out signed(47 downto 0);
            chi17_x_pos_pred, chi17_x_vel_pred, chi17_x_acc_pred, chi17_y_pos_pred, chi17_y_vel_pred, chi17_y_acc_pred, chi17_z_pos_pred, chi17_z_vel_pred, chi17_z_acc_pred : out signed(47 downto 0);
            chi18_x_pos_pred, chi18_x_vel_pred, chi18_x_acc_pred, chi18_y_pos_pred, chi18_y_vel_pred, chi18_y_acc_pred, chi18_z_pos_pred, chi18_z_vel_pred, chi18_z_acc_pred : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    component predicted_mean_3d is
        port (
            clk : in std_logic; rst : in std_logic; start : in std_logic;
            chi0_x_pos_pred, chi0_x_vel_pred, chi0_x_acc_pred, chi0_y_pos_pred, chi0_y_vel_pred, chi0_y_acc_pred, chi0_z_pos_pred, chi0_z_vel_pred, chi0_z_acc_pred : in signed(47 downto 0);
            chi1_x_pos_pred, chi1_x_vel_pred, chi1_x_acc_pred, chi1_y_pos_pred, chi1_y_vel_pred, chi1_y_acc_pred, chi1_z_pos_pred, chi1_z_vel_pred, chi1_z_acc_pred : in signed(47 downto 0);
            chi2_x_pos_pred, chi2_x_vel_pred, chi2_x_acc_pred, chi2_y_pos_pred, chi2_y_vel_pred, chi2_y_acc_pred, chi2_z_pos_pred, chi2_z_vel_pred, chi2_z_acc_pred : in signed(47 downto 0);
            chi3_x_pos_pred, chi3_x_vel_pred, chi3_x_acc_pred, chi3_y_pos_pred, chi3_y_vel_pred, chi3_y_acc_pred, chi3_z_pos_pred, chi3_z_vel_pred, chi3_z_acc_pred : in signed(47 downto 0);
            chi4_x_pos_pred, chi4_x_vel_pred, chi4_x_acc_pred, chi4_y_pos_pred, chi4_y_vel_pred, chi4_y_acc_pred, chi4_z_pos_pred, chi4_z_vel_pred, chi4_z_acc_pred : in signed(47 downto 0);
            chi5_x_pos_pred, chi5_x_vel_pred, chi5_x_acc_pred, chi5_y_pos_pred, chi5_y_vel_pred, chi5_y_acc_pred, chi5_z_pos_pred, chi5_z_vel_pred, chi5_z_acc_pred : in signed(47 downto 0);
            chi6_x_pos_pred, chi6_x_vel_pred, chi6_x_acc_pred, chi6_y_pos_pred, chi6_y_vel_pred, chi6_y_acc_pred, chi6_z_pos_pred, chi6_z_vel_pred, chi6_z_acc_pred : in signed(47 downto 0);
            chi7_x_pos_pred, chi7_x_vel_pred, chi7_x_acc_pred, chi7_y_pos_pred, chi7_y_vel_pred, chi7_y_acc_pred, chi7_z_pos_pred, chi7_z_vel_pred, chi7_z_acc_pred : in signed(47 downto 0);
            chi8_x_pos_pred, chi8_x_vel_pred, chi8_x_acc_pred, chi8_y_pos_pred, chi8_y_vel_pred, chi8_y_acc_pred, chi8_z_pos_pred, chi8_z_vel_pred, chi8_z_acc_pred : in signed(47 downto 0);
            chi9_x_pos_pred, chi9_x_vel_pred, chi9_x_acc_pred, chi9_y_pos_pred, chi9_y_vel_pred, chi9_y_acc_pred, chi9_z_pos_pred, chi9_z_vel_pred, chi9_z_acc_pred : in signed(47 downto 0);
            chi10_x_pos_pred, chi10_x_vel_pred, chi10_x_acc_pred, chi10_y_pos_pred, chi10_y_vel_pred, chi10_y_acc_pred, chi10_z_pos_pred, chi10_z_vel_pred, chi10_z_acc_pred : in signed(47 downto 0);
            chi11_x_pos_pred, chi11_x_vel_pred, chi11_x_acc_pred, chi11_y_pos_pred, chi11_y_vel_pred, chi11_y_acc_pred, chi11_z_pos_pred, chi11_z_vel_pred, chi11_z_acc_pred : in signed(47 downto 0);
            chi12_x_pos_pred, chi12_x_vel_pred, chi12_x_acc_pred, chi12_y_pos_pred, chi12_y_vel_pred, chi12_y_acc_pred, chi12_z_pos_pred, chi12_z_vel_pred, chi12_z_acc_pred : in signed(47 downto 0);
            chi13_x_pos_pred, chi13_x_vel_pred, chi13_x_acc_pred, chi13_y_pos_pred, chi13_y_vel_pred, chi13_y_acc_pred, chi13_z_pos_pred, chi13_z_vel_pred, chi13_z_acc_pred : in signed(47 downto 0);
            chi14_x_pos_pred, chi14_x_vel_pred, chi14_x_acc_pred, chi14_y_pos_pred, chi14_y_vel_pred, chi14_y_acc_pred, chi14_z_pos_pred, chi14_z_vel_pred, chi14_z_acc_pred : in signed(47 downto 0);
            chi15_x_pos_pred, chi15_x_vel_pred, chi15_x_acc_pred, chi15_y_pos_pred, chi15_y_vel_pred, chi15_y_acc_pred, chi15_z_pos_pred, chi15_z_vel_pred, chi15_z_acc_pred : in signed(47 downto 0);
            chi16_x_pos_pred, chi16_x_vel_pred, chi16_x_acc_pred, chi16_y_pos_pred, chi16_y_vel_pred, chi16_y_acc_pred, chi16_z_pos_pred, chi16_z_vel_pred, chi16_z_acc_pred : in signed(47 downto 0);
            chi17_x_pos_pred, chi17_x_vel_pred, chi17_x_acc_pred, chi17_y_pos_pred, chi17_y_vel_pred, chi17_y_acc_pred, chi17_z_pos_pred, chi17_z_vel_pred, chi17_z_acc_pred : in signed(47 downto 0);
            chi18_x_pos_pred, chi18_x_vel_pred, chi18_x_acc_pred, chi18_y_pos_pred, chi18_y_vel_pred, chi18_y_acc_pred, chi18_z_pos_pred, chi18_z_vel_pred, chi18_z_acc_pred : in signed(47 downto 0);
            x_pos_mean_pred, x_vel_mean_pred, x_acc_mean_pred : buffer signed(47 downto 0);
            y_pos_mean_pred, y_vel_mean_pred, y_acc_mean_pred : buffer signed(47 downto 0);
            z_pos_mean_pred, z_vel_mean_pred, z_acc_mean_pred : buffer signed(47 downto 0);
            done : out std_logic
        );
    end component;

    component qr_decomp_9x19 is
        port (
            clk : in std_logic; reset : in std_logic; start : in std_logic;
            x_pos_mean, x_vel_mean, x_acc_mean : in signed(47 downto 0);
            y_pos_mean, y_vel_mean, y_acc_mean : in signed(47 downto 0);
            z_pos_mean, z_vel_mean, z_acc_mean : in signed(47 downto 0);
            chi0_x_pos, chi0_x_vel, chi0_x_acc, chi0_y_pos, chi0_y_vel, chi0_y_acc, chi0_z_pos, chi0_z_vel, chi0_z_acc : in signed(47 downto 0);
            chi1_x_pos, chi1_x_vel, chi1_x_acc, chi1_y_pos, chi1_y_vel, chi1_y_acc, chi1_z_pos, chi1_z_vel, chi1_z_acc : in signed(47 downto 0);
            chi2_x_pos, chi2_x_vel, chi2_x_acc, chi2_y_pos, chi2_y_vel, chi2_y_acc, chi2_z_pos, chi2_z_vel, chi2_z_acc : in signed(47 downto 0);
            chi3_x_pos, chi3_x_vel, chi3_x_acc, chi3_y_pos, chi3_y_vel, chi3_y_acc, chi3_z_pos, chi3_z_vel, chi3_z_acc : in signed(47 downto 0);
            chi4_x_pos, chi4_x_vel, chi4_x_acc, chi4_y_pos, chi4_y_vel, chi4_y_acc, chi4_z_pos, chi4_z_vel, chi4_z_acc : in signed(47 downto 0);
            chi5_x_pos, chi5_x_vel, chi5_x_acc, chi5_y_pos, chi5_y_vel, chi5_y_acc, chi5_z_pos, chi5_z_vel, chi5_z_acc : in signed(47 downto 0);
            chi6_x_pos, chi6_x_vel, chi6_x_acc, chi6_y_pos, chi6_y_vel, chi6_y_acc, chi6_z_pos, chi6_z_vel, chi6_z_acc : in signed(47 downto 0);
            chi7_x_pos, chi7_x_vel, chi7_x_acc, chi7_y_pos, chi7_y_vel, chi7_y_acc, chi7_z_pos, chi7_z_vel, chi7_z_acc : in signed(47 downto 0);
            chi8_x_pos, chi8_x_vel, chi8_x_acc, chi8_y_pos, chi8_y_vel, chi8_y_acc, chi8_z_pos, chi8_z_vel, chi8_z_acc : in signed(47 downto 0);
            chi9_x_pos, chi9_x_vel, chi9_x_acc, chi9_y_pos, chi9_y_vel, chi9_y_acc, chi9_z_pos, chi9_z_vel, chi9_z_acc : in signed(47 downto 0);
            chi10_x_pos, chi10_x_vel, chi10_x_acc, chi10_y_pos, chi10_y_vel, chi10_y_acc, chi10_z_pos, chi10_z_vel, chi10_z_acc : in signed(47 downto 0);
            chi11_x_pos, chi11_x_vel, chi11_x_acc, chi11_y_pos, chi11_y_vel, chi11_y_acc, chi11_z_pos, chi11_z_vel, chi11_z_acc : in signed(47 downto 0);
            chi12_x_pos, chi12_x_vel, chi12_x_acc, chi12_y_pos, chi12_y_vel, chi12_y_acc, chi12_z_pos, chi12_z_vel, chi12_z_acc : in signed(47 downto 0);
            chi13_x_pos, chi13_x_vel, chi13_x_acc, chi13_y_pos, chi13_y_vel, chi13_y_acc, chi13_z_pos, chi13_z_vel, chi13_z_acc : in signed(47 downto 0);
            chi14_x_pos, chi14_x_vel, chi14_x_acc, chi14_y_pos, chi14_y_vel, chi14_y_acc, chi14_z_pos, chi14_z_vel, chi14_z_acc : in signed(47 downto 0);
            chi15_x_pos, chi15_x_vel, chi15_x_acc, chi15_y_pos, chi15_y_vel, chi15_y_acc, chi15_z_pos, chi15_z_vel, chi15_z_acc : in signed(47 downto 0);
            chi16_x_pos, chi16_x_vel, chi16_x_acc, chi16_y_pos, chi16_y_vel, chi16_y_acc, chi16_z_pos, chi16_z_vel, chi16_z_acc : in signed(47 downto 0);
            chi17_x_pos, chi17_x_vel, chi17_x_acc, chi17_y_pos, chi17_y_vel, chi17_y_acc, chi17_z_pos, chi17_z_vel, chi17_z_acc : in signed(47 downto 0);
            chi18_x_pos, chi18_x_vel, chi18_x_acc, chi18_y_pos, chi18_y_vel, chi18_y_acc, chi18_z_pos, chi18_z_vel, chi18_z_acc : in signed(47 downto 0);
            l11_out, l21_out, l31_out, l41_out, l51_out, l61_out, l71_out, l81_out, l91_out : out signed(47 downto 0);
            l22_out, l32_out, l42_out, l52_out, l62_out, l72_out, l82_out, l92_out : out signed(47 downto 0);
            l33_out, l43_out, l53_out, l63_out, l73_out, l83_out, l93_out : out signed(47 downto 0);
            l44_out, l54_out, l64_out, l74_out, l84_out, l94_out : out signed(47 downto 0);
            l55_out, l65_out, l75_out, l85_out, l95_out : out signed(47 downto 0);
            l66_out, l76_out, l86_out, l96_out : out signed(47 downto 0);
            l77_out, l87_out, l97_out : out signed(47 downto 0);
            l88_out, l98_out : out signed(47 downto 0);
            l99_out : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    component cholesky_rank1_update is
        port (
            clk : in std_logic; reset : in std_logic; start : in std_logic;
            l11_in, l21_in, l31_in, l41_in, l51_in, l61_in, l71_in, l81_in, l91_in : in signed(47 downto 0);
            l22_in, l32_in, l42_in, l52_in, l62_in, l72_in, l82_in, l92_in : in signed(47 downto 0);
            l33_in, l43_in, l53_in, l63_in, l73_in, l83_in, l93_in : in signed(47 downto 0);
            l44_in, l54_in, l64_in, l74_in, l84_in, l94_in : in signed(47 downto 0);
            l55_in, l65_in, l75_in, l85_in, l95_in : in signed(47 downto 0);
            l66_in, l76_in, l86_in, l96_in : in signed(47 downto 0);
            l77_in, l87_in, l97_in : in signed(47 downto 0);
            l88_in, l98_in : in signed(47 downto 0);
            l99_in : in signed(47 downto 0);
            u1_in, u2_in, u3_in, u4_in, u5_in, u6_in, u7_in, u8_in, u9_in : in signed(47 downto 0);
            l11_out, l21_out, l31_out, l41_out, l51_out, l61_out, l71_out, l81_out, l91_out : out signed(47 downto 0);
            l22_out, l32_out, l42_out, l52_out, l62_out, l72_out, l82_out, l92_out : out signed(47 downto 0);
            l33_out, l43_out, l53_out, l63_out, l73_out, l83_out, l93_out : out signed(47 downto 0);
            l44_out, l54_out, l64_out, l74_out, l84_out, l94_out : out signed(47 downto 0);
            l55_out, l65_out, l75_out, l85_out, l95_out : out signed(47 downto 0);
            l66_out, l76_out, l86_out, l96_out : out signed(47 downto 0);
            l77_out, l87_out, l97_out : out signed(47 downto 0);
            l88_out, l98_out : out signed(47 downto 0);
            l99_out : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    component process_noise_rank1_3d is
        port (
            clk : in std_logic; reset : in std_logic; start : in std_logic;
            l11_in, l21_in, l31_in, l41_in, l51_in, l61_in, l71_in, l81_in, l91_in : in signed(47 downto 0);
            l22_in, l32_in, l42_in, l52_in, l62_in, l72_in, l82_in, l92_in : in signed(47 downto 0);
            l33_in, l43_in, l53_in, l63_in, l73_in, l83_in, l93_in : in signed(47 downto 0);
            l44_in, l54_in, l64_in, l74_in, l84_in, l94_in : in signed(47 downto 0);
            l55_in, l65_in, l75_in, l85_in, l95_in : in signed(47 downto 0);
            l66_in, l76_in, l86_in, l96_in : in signed(47 downto 0);
            l77_in, l87_in, l97_in : in signed(47 downto 0);
            l88_in, l98_in : in signed(47 downto 0);
            l99_in : in signed(47 downto 0);
            l11_out, l21_out, l31_out, l41_out, l51_out, l61_out, l71_out, l81_out, l91_out : out signed(47 downto 0);
            l22_out, l32_out, l42_out, l52_out, l62_out, l72_out, l82_out, l92_out : out signed(47 downto 0);
            l33_out, l43_out, l53_out, l63_out, l73_out, l83_out, l93_out : out signed(47 downto 0);
            l44_out, l54_out, l64_out, l74_out, l84_out, l94_out : out signed(47 downto 0);
            l55_out, l65_out, l75_out, l85_out, l95_out : out signed(47 downto 0);
            l66_out, l76_out, l86_out, l96_out : out signed(47 downto 0);
            l77_out, l87_out, l97_out : out signed(47 downto 0);
            l88_out, l98_out : out signed(47 downto 0);
            l99_out : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    type state_type is (IDLE, RUN_SIGMA, WAIT_SIGMA, RUN_PREDICT, WAIT_PREDICT,
                        RUN_MEAN, WAIT_MEAN, RUN_QR, WAIT_QR,
                        COMPUTE_W0, RUN_W0_UPDATE, WAIT_W0_UPDATE,
                        RUN_NOISE, WAIT_NOISE, FINISHED);
    signal state : state_type := IDLE;

    signal sigma_start, sigma_done : std_logic;
    signal predict_start, predict_done : std_logic;
    signal mean_start, mean_done : std_logic;
    signal qr_start, qr_done : std_logic;
    signal w0_update_start, w0_update_done : std_logic;
    signal noise_start, noise_done : std_logic;

    signal     chi_0_x_pos,     chi_0_x_vel,     chi_0_x_acc,     chi_0_y_pos,     chi_0_y_vel,     chi_0_y_acc,     chi_0_z_pos,     chi_0_z_vel,     chi_0_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_1_x_pos,     chi_1_x_vel,     chi_1_x_acc,     chi_1_y_pos,     chi_1_y_vel,     chi_1_y_acc,     chi_1_z_pos,     chi_1_z_vel,     chi_1_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_2_x_pos,     chi_2_x_vel,     chi_2_x_acc,     chi_2_y_pos,     chi_2_y_vel,     chi_2_y_acc,     chi_2_z_pos,     chi_2_z_vel,     chi_2_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_3_x_pos,     chi_3_x_vel,     chi_3_x_acc,     chi_3_y_pos,     chi_3_y_vel,     chi_3_y_acc,     chi_3_z_pos,     chi_3_z_vel,     chi_3_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_4_x_pos,     chi_4_x_vel,     chi_4_x_acc,     chi_4_y_pos,     chi_4_y_vel,     chi_4_y_acc,     chi_4_z_pos,     chi_4_z_vel,     chi_4_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_5_x_pos,     chi_5_x_vel,     chi_5_x_acc,     chi_5_y_pos,     chi_5_y_vel,     chi_5_y_acc,     chi_5_z_pos,     chi_5_z_vel,     chi_5_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_6_x_pos,     chi_6_x_vel,     chi_6_x_acc,     chi_6_y_pos,     chi_6_y_vel,     chi_6_y_acc,     chi_6_z_pos,     chi_6_z_vel,     chi_6_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_7_x_pos,     chi_7_x_vel,     chi_7_x_acc,     chi_7_y_pos,     chi_7_y_vel,     chi_7_y_acc,     chi_7_z_pos,     chi_7_z_vel,     chi_7_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_8_x_pos,     chi_8_x_vel,     chi_8_x_acc,     chi_8_y_pos,     chi_8_y_vel,     chi_8_y_acc,     chi_8_z_pos,     chi_8_z_vel,     chi_8_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_9_x_pos,     chi_9_x_vel,     chi_9_x_acc,     chi_9_y_pos,     chi_9_y_vel,     chi_9_y_acc,     chi_9_z_pos,     chi_9_z_vel,     chi_9_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_10_x_pos,     chi_10_x_vel,     chi_10_x_acc,     chi_10_y_pos,     chi_10_y_vel,     chi_10_y_acc,     chi_10_z_pos,     chi_10_z_vel,     chi_10_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_11_x_pos,     chi_11_x_vel,     chi_11_x_acc,     chi_11_y_pos,     chi_11_y_vel,     chi_11_y_acc,     chi_11_z_pos,     chi_11_z_vel,     chi_11_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_12_x_pos,     chi_12_x_vel,     chi_12_x_acc,     chi_12_y_pos,     chi_12_y_vel,     chi_12_y_acc,     chi_12_z_pos,     chi_12_z_vel,     chi_12_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_13_x_pos,     chi_13_x_vel,     chi_13_x_acc,     chi_13_y_pos,     chi_13_y_vel,     chi_13_y_acc,     chi_13_z_pos,     chi_13_z_vel,     chi_13_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_14_x_pos,     chi_14_x_vel,     chi_14_x_acc,     chi_14_y_pos,     chi_14_y_vel,     chi_14_y_acc,     chi_14_z_pos,     chi_14_z_vel,     chi_14_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_15_x_pos,     chi_15_x_vel,     chi_15_x_acc,     chi_15_y_pos,     chi_15_y_vel,     chi_15_y_acc,     chi_15_z_pos,     chi_15_z_vel,     chi_15_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_16_x_pos,     chi_16_x_vel,     chi_16_x_acc,     chi_16_y_pos,     chi_16_y_vel,     chi_16_y_acc,     chi_16_z_pos,     chi_16_z_vel,     chi_16_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_17_x_pos,     chi_17_x_vel,     chi_17_x_acc,     chi_17_y_pos,     chi_17_y_vel,     chi_17_y_acc,     chi_17_z_pos,     chi_17_z_vel,     chi_17_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_18_x_pos,     chi_18_x_vel,     chi_18_x_acc,     chi_18_y_pos,     chi_18_y_vel,     chi_18_y_acc,     chi_18_z_pos,     chi_18_z_vel,     chi_18_z_acc : signed(47 downto 0) := (others => '0');

    signal     chi_pred_int_0_x_pos,     chi_pred_int_0_x_vel,     chi_pred_int_0_x_acc,     chi_pred_int_0_y_pos,     chi_pred_int_0_y_vel,     chi_pred_int_0_y_acc,     chi_pred_int_0_z_pos,     chi_pred_int_0_z_vel,     chi_pred_int_0_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_1_x_pos,     chi_pred_int_1_x_vel,     chi_pred_int_1_x_acc,     chi_pred_int_1_y_pos,     chi_pred_int_1_y_vel,     chi_pred_int_1_y_acc,     chi_pred_int_1_z_pos,     chi_pred_int_1_z_vel,     chi_pred_int_1_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_2_x_pos,     chi_pred_int_2_x_vel,     chi_pred_int_2_x_acc,     chi_pred_int_2_y_pos,     chi_pred_int_2_y_vel,     chi_pred_int_2_y_acc,     chi_pred_int_2_z_pos,     chi_pred_int_2_z_vel,     chi_pred_int_2_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_3_x_pos,     chi_pred_int_3_x_vel,     chi_pred_int_3_x_acc,     chi_pred_int_3_y_pos,     chi_pred_int_3_y_vel,     chi_pred_int_3_y_acc,     chi_pred_int_3_z_pos,     chi_pred_int_3_z_vel,     chi_pred_int_3_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_4_x_pos,     chi_pred_int_4_x_vel,     chi_pred_int_4_x_acc,     chi_pred_int_4_y_pos,     chi_pred_int_4_y_vel,     chi_pred_int_4_y_acc,     chi_pred_int_4_z_pos,     chi_pred_int_4_z_vel,     chi_pred_int_4_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_5_x_pos,     chi_pred_int_5_x_vel,     chi_pred_int_5_x_acc,     chi_pred_int_5_y_pos,     chi_pred_int_5_y_vel,     chi_pred_int_5_y_acc,     chi_pred_int_5_z_pos,     chi_pred_int_5_z_vel,     chi_pred_int_5_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_6_x_pos,     chi_pred_int_6_x_vel,     chi_pred_int_6_x_acc,     chi_pred_int_6_y_pos,     chi_pred_int_6_y_vel,     chi_pred_int_6_y_acc,     chi_pred_int_6_z_pos,     chi_pred_int_6_z_vel,     chi_pred_int_6_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_7_x_pos,     chi_pred_int_7_x_vel,     chi_pred_int_7_x_acc,     chi_pred_int_7_y_pos,     chi_pred_int_7_y_vel,     chi_pred_int_7_y_acc,     chi_pred_int_7_z_pos,     chi_pred_int_7_z_vel,     chi_pred_int_7_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_8_x_pos,     chi_pred_int_8_x_vel,     chi_pred_int_8_x_acc,     chi_pred_int_8_y_pos,     chi_pred_int_8_y_vel,     chi_pred_int_8_y_acc,     chi_pred_int_8_z_pos,     chi_pred_int_8_z_vel,     chi_pred_int_8_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_9_x_pos,     chi_pred_int_9_x_vel,     chi_pred_int_9_x_acc,     chi_pred_int_9_y_pos,     chi_pred_int_9_y_vel,     chi_pred_int_9_y_acc,     chi_pred_int_9_z_pos,     chi_pred_int_9_z_vel,     chi_pred_int_9_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_10_x_pos,     chi_pred_int_10_x_vel,     chi_pred_int_10_x_acc,     chi_pred_int_10_y_pos,     chi_pred_int_10_y_vel,     chi_pred_int_10_y_acc,     chi_pred_int_10_z_pos,     chi_pred_int_10_z_vel,     chi_pred_int_10_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_11_x_pos,     chi_pred_int_11_x_vel,     chi_pred_int_11_x_acc,     chi_pred_int_11_y_pos,     chi_pred_int_11_y_vel,     chi_pred_int_11_y_acc,     chi_pred_int_11_z_pos,     chi_pred_int_11_z_vel,     chi_pred_int_11_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_12_x_pos,     chi_pred_int_12_x_vel,     chi_pred_int_12_x_acc,     chi_pred_int_12_y_pos,     chi_pred_int_12_y_vel,     chi_pred_int_12_y_acc,     chi_pred_int_12_z_pos,     chi_pred_int_12_z_vel,     chi_pred_int_12_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_13_x_pos,     chi_pred_int_13_x_vel,     chi_pred_int_13_x_acc,     chi_pred_int_13_y_pos,     chi_pred_int_13_y_vel,     chi_pred_int_13_y_acc,     chi_pred_int_13_z_pos,     chi_pred_int_13_z_vel,     chi_pred_int_13_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_14_x_pos,     chi_pred_int_14_x_vel,     chi_pred_int_14_x_acc,     chi_pred_int_14_y_pos,     chi_pred_int_14_y_vel,     chi_pred_int_14_y_acc,     chi_pred_int_14_z_pos,     chi_pred_int_14_z_vel,     chi_pred_int_14_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_15_x_pos,     chi_pred_int_15_x_vel,     chi_pred_int_15_x_acc,     chi_pred_int_15_y_pos,     chi_pred_int_15_y_vel,     chi_pred_int_15_y_acc,     chi_pred_int_15_z_pos,     chi_pred_int_15_z_vel,     chi_pred_int_15_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_16_x_pos,     chi_pred_int_16_x_vel,     chi_pred_int_16_x_acc,     chi_pred_int_16_y_pos,     chi_pred_int_16_y_vel,     chi_pred_int_16_y_acc,     chi_pred_int_16_z_pos,     chi_pred_int_16_z_vel,     chi_pred_int_16_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_17_x_pos,     chi_pred_int_17_x_vel,     chi_pred_int_17_x_acc,     chi_pred_int_17_y_pos,     chi_pred_int_17_y_vel,     chi_pred_int_17_y_acc,     chi_pred_int_17_z_pos,     chi_pred_int_17_z_vel,     chi_pred_int_17_z_acc : signed(47 downto 0) := (others => '0');
    signal     chi_pred_int_18_x_pos,     chi_pred_int_18_x_vel,     chi_pred_int_18_x_acc,     chi_pred_int_18_y_pos,     chi_pred_int_18_y_vel,     chi_pred_int_18_y_acc,     chi_pred_int_18_z_pos,     chi_pred_int_18_z_vel,     chi_pred_int_18_z_acc : signed(47 downto 0) := (others => '0');

    signal x_pos_mean, x_vel_mean, x_acc_mean : signed(47 downto 0) := (others => '0');
    signal y_pos_mean, y_vel_mean, y_acc_mean : signed(47 downto 0) := (others => '0');
    signal z_pos_mean, z_vel_mean, z_acc_mean : signed(47 downto 0) := (others => '0');

    signal l11_qr, l21_qr, l31_qr, l41_qr, l51_qr, l61_qr, l71_qr, l81_qr, l91_qr : signed(47 downto 0) := (others => '0');
    signal l22_qr, l32_qr, l42_qr, l52_qr, l62_qr, l72_qr, l82_qr, l92_qr : signed(47 downto 0) := (others => '0');
    signal l33_qr, l43_qr, l53_qr, l63_qr, l73_qr, l83_qr, l93_qr : signed(47 downto 0) := (others => '0');
    signal l44_qr, l54_qr, l64_qr, l74_qr, l84_qr, l94_qr : signed(47 downto 0) := (others => '0');
    signal l55_qr, l65_qr, l75_qr, l85_qr, l95_qr : signed(47 downto 0) := (others => '0');
    signal l66_qr, l76_qr, l86_qr, l96_qr : signed(47 downto 0) := (others => '0');
    signal l77_qr, l87_qr, l97_qr : signed(47 downto 0) := (others => '0');
    signal l88_qr, l98_qr : signed(47 downto 0) := (others => '0');
    signal l99_qr : signed(47 downto 0) := (others => '0');

    signal w0_1, w0_2, w0_3, w0_4, w0_5, w0_6, w0_7, w0_8, w0_9 : signed(47 downto 0) := (others => '0');

    signal l11_dd, l21_dd, l31_dd, l41_dd, l51_dd, l61_dd, l71_dd, l81_dd, l91_dd : signed(47 downto 0) := (others => '0');
    signal l22_dd, l32_dd, l42_dd, l52_dd, l62_dd, l72_dd, l82_dd, l92_dd : signed(47 downto 0) := (others => '0');
    signal l33_dd, l43_dd, l53_dd, l63_dd, l73_dd, l83_dd, l93_dd : signed(47 downto 0) := (others => '0');
    signal l44_dd, l54_dd, l64_dd, l74_dd, l84_dd, l94_dd : signed(47 downto 0) := (others => '0');
    signal l55_dd, l65_dd, l75_dd, l85_dd, l95_dd : signed(47 downto 0) := (others => '0');
    signal l66_dd, l76_dd, l86_dd, l96_dd : signed(47 downto 0) := (others => '0');
    signal l77_dd, l87_dd, l97_dd : signed(47 downto 0) := (others => '0');
    signal l88_dd, l98_dd : signed(47 downto 0) := (others => '0');
    signal l99_dd : signed(47 downto 0) := (others => '0');

    constant W0_ABS_SQRT : signed(47 downto 0) := to_signed(23726566, 48);

begin

    sigma_gen : sigma_3d
        port map (
            clk => clk, rst => rst, start => sigma_start,
            x_pos_mean => x_pos_current, x_vel_mean => x_vel_current, x_acc_mean => x_acc_current,
            y_pos_mean => y_pos_current, y_vel_mean => y_vel_current, y_acc_mean => y_acc_current,
            z_pos_mean => z_pos_current, z_vel_mean => z_vel_current, z_acc_mean => z_acc_current,
            cholesky_done => sigma_start,
            l11 => l11_current, l21 => l21_current, l31 => l31_current, l41 => l41_current, l51 => l51_current, l61 => l61_current, l71 => l71_current, l81 => l81_current, l91 => l91_current,
            l22 => l22_current, l32 => l32_current, l42 => l42_current, l52 => l52_current, l62 => l62_current, l72 => l72_current, l82 => l82_current, l92 => l92_current,
            l33 => l33_current, l43 => l43_current, l53 => l53_current, l63 => l63_current, l73 => l73_current, l83 => l83_current, l93 => l93_current,
            l44 => l44_current, l54 => l54_current, l64 => l64_current, l74 => l74_current, l84 => l84_current, l94 => l94_current,
            l55 => l55_current, l65 => l65_current, l75 => l75_current, l85 => l85_current, l95 => l95_current,
            l66 => l66_current, l76 => l76_current, l86 => l86_current, l96 => l96_current,
            l77 => l77_current, l87 => l87_current, l97 => l97_current,
            l88 => l88_current, l98 => l98_current,
            l99 => l99_current,
            chi0_x_pos => chi_0_x_pos, chi0_x_vel => chi_0_x_vel, chi0_x_acc => chi_0_x_acc, chi0_y_pos => chi_0_y_pos, chi0_y_vel => chi_0_y_vel, chi0_y_acc => chi_0_y_acc, chi0_z_pos => chi_0_z_pos, chi0_z_vel => chi_0_z_vel, chi0_z_acc => chi_0_z_acc,
            chi1_x_pos => chi_1_x_pos, chi1_x_vel => chi_1_x_vel, chi1_x_acc => chi_1_x_acc, chi1_y_pos => chi_1_y_pos, chi1_y_vel => chi_1_y_vel, chi1_y_acc => chi_1_y_acc, chi1_z_pos => chi_1_z_pos, chi1_z_vel => chi_1_z_vel, chi1_z_acc => chi_1_z_acc,
            chi2_x_pos => chi_2_x_pos, chi2_x_vel => chi_2_x_vel, chi2_x_acc => chi_2_x_acc, chi2_y_pos => chi_2_y_pos, chi2_y_vel => chi_2_y_vel, chi2_y_acc => chi_2_y_acc, chi2_z_pos => chi_2_z_pos, chi2_z_vel => chi_2_z_vel, chi2_z_acc => chi_2_z_acc,
            chi3_x_pos => chi_3_x_pos, chi3_x_vel => chi_3_x_vel, chi3_x_acc => chi_3_x_acc, chi3_y_pos => chi_3_y_pos, chi3_y_vel => chi_3_y_vel, chi3_y_acc => chi_3_y_acc, chi3_z_pos => chi_3_z_pos, chi3_z_vel => chi_3_z_vel, chi3_z_acc => chi_3_z_acc,
            chi4_x_pos => chi_4_x_pos, chi4_x_vel => chi_4_x_vel, chi4_x_acc => chi_4_x_acc, chi4_y_pos => chi_4_y_pos, chi4_y_vel => chi_4_y_vel, chi4_y_acc => chi_4_y_acc, chi4_z_pos => chi_4_z_pos, chi4_z_vel => chi_4_z_vel, chi4_z_acc => chi_4_z_acc,
            chi5_x_pos => chi_5_x_pos, chi5_x_vel => chi_5_x_vel, chi5_x_acc => chi_5_x_acc, chi5_y_pos => chi_5_y_pos, chi5_y_vel => chi_5_y_vel, chi5_y_acc => chi_5_y_acc, chi5_z_pos => chi_5_z_pos, chi5_z_vel => chi_5_z_vel, chi5_z_acc => chi_5_z_acc,
            chi6_x_pos => chi_6_x_pos, chi6_x_vel => chi_6_x_vel, chi6_x_acc => chi_6_x_acc, chi6_y_pos => chi_6_y_pos, chi6_y_vel => chi_6_y_vel, chi6_y_acc => chi_6_y_acc, chi6_z_pos => chi_6_z_pos, chi6_z_vel => chi_6_z_vel, chi6_z_acc => chi_6_z_acc,
            chi7_x_pos => chi_7_x_pos, chi7_x_vel => chi_7_x_vel, chi7_x_acc => chi_7_x_acc, chi7_y_pos => chi_7_y_pos, chi7_y_vel => chi_7_y_vel, chi7_y_acc => chi_7_y_acc, chi7_z_pos => chi_7_z_pos, chi7_z_vel => chi_7_z_vel, chi7_z_acc => chi_7_z_acc,
            chi8_x_pos => chi_8_x_pos, chi8_x_vel => chi_8_x_vel, chi8_x_acc => chi_8_x_acc, chi8_y_pos => chi_8_y_pos, chi8_y_vel => chi_8_y_vel, chi8_y_acc => chi_8_y_acc, chi8_z_pos => chi_8_z_pos, chi8_z_vel => chi_8_z_vel, chi8_z_acc => chi_8_z_acc,
            chi9_x_pos => chi_9_x_pos, chi9_x_vel => chi_9_x_vel, chi9_x_acc => chi_9_x_acc, chi9_y_pos => chi_9_y_pos, chi9_y_vel => chi_9_y_vel, chi9_y_acc => chi_9_y_acc, chi9_z_pos => chi_9_z_pos, chi9_z_vel => chi_9_z_vel, chi9_z_acc => chi_9_z_acc,
            chi10_x_pos => chi_10_x_pos, chi10_x_vel => chi_10_x_vel, chi10_x_acc => chi_10_x_acc, chi10_y_pos => chi_10_y_pos, chi10_y_vel => chi_10_y_vel, chi10_y_acc => chi_10_y_acc, chi10_z_pos => chi_10_z_pos, chi10_z_vel => chi_10_z_vel, chi10_z_acc => chi_10_z_acc,
            chi11_x_pos => chi_11_x_pos, chi11_x_vel => chi_11_x_vel, chi11_x_acc => chi_11_x_acc, chi11_y_pos => chi_11_y_pos, chi11_y_vel => chi_11_y_vel, chi11_y_acc => chi_11_y_acc, chi11_z_pos => chi_11_z_pos, chi11_z_vel => chi_11_z_vel, chi11_z_acc => chi_11_z_acc,
            chi12_x_pos => chi_12_x_pos, chi12_x_vel => chi_12_x_vel, chi12_x_acc => chi_12_x_acc, chi12_y_pos => chi_12_y_pos, chi12_y_vel => chi_12_y_vel, chi12_y_acc => chi_12_y_acc, chi12_z_pos => chi_12_z_pos, chi12_z_vel => chi_12_z_vel, chi12_z_acc => chi_12_z_acc,
            chi13_x_pos => chi_13_x_pos, chi13_x_vel => chi_13_x_vel, chi13_x_acc => chi_13_x_acc, chi13_y_pos => chi_13_y_pos, chi13_y_vel => chi_13_y_vel, chi13_y_acc => chi_13_y_acc, chi13_z_pos => chi_13_z_pos, chi13_z_vel => chi_13_z_vel, chi13_z_acc => chi_13_z_acc,
            chi14_x_pos => chi_14_x_pos, chi14_x_vel => chi_14_x_vel, chi14_x_acc => chi_14_x_acc, chi14_y_pos => chi_14_y_pos, chi14_y_vel => chi_14_y_vel, chi14_y_acc => chi_14_y_acc, chi14_z_pos => chi_14_z_pos, chi14_z_vel => chi_14_z_vel, chi14_z_acc => chi_14_z_acc,
            chi15_x_pos => chi_15_x_pos, chi15_x_vel => chi_15_x_vel, chi15_x_acc => chi_15_x_acc, chi15_y_pos => chi_15_y_pos, chi15_y_vel => chi_15_y_vel, chi15_y_acc => chi_15_y_acc, chi15_z_pos => chi_15_z_pos, chi15_z_vel => chi_15_z_vel, chi15_z_acc => chi_15_z_acc,
            chi16_x_pos => chi_16_x_pos, chi16_x_vel => chi_16_x_vel, chi16_x_acc => chi_16_x_acc, chi16_y_pos => chi_16_y_pos, chi16_y_vel => chi_16_y_vel, chi16_y_acc => chi_16_y_acc, chi16_z_pos => chi_16_z_pos, chi16_z_vel => chi_16_z_vel, chi16_z_acc => chi_16_z_acc,
            chi17_x_pos => chi_17_x_pos, chi17_x_vel => chi_17_x_vel, chi17_x_acc => chi_17_x_acc, chi17_y_pos => chi_17_y_pos, chi17_y_vel => chi_17_y_vel, chi17_y_acc => chi_17_y_acc, chi17_z_pos => chi_17_z_pos, chi17_z_vel => chi_17_z_vel, chi17_z_acc => chi_17_z_acc,
            chi18_x_pos => chi_18_x_pos, chi18_x_vel => chi_18_x_vel, chi18_x_acc => chi_18_x_acc, chi18_y_pos => chi_18_y_pos, chi18_y_vel => chi_18_y_vel, chi18_y_acc => chi_18_y_acc, chi18_z_pos => chi_18_z_pos, chi18_z_vel => chi_18_z_vel, chi18_z_acc => chi_18_z_acc,
            done => sigma_done
        );

    predict_comp : predicti_singer3d
        port map (
            clk => clk, reset => rst, start => predict_start,
            a_mean_x => (others => '0'), a_mean_y => (others => '0'), a_mean_z => (others => '0'),
            cycle_num => 0,
            chi0_x_pos_in => chi_0_x_pos, chi0_x_vel_in => chi_0_x_vel, chi0_x_acc_in => chi_0_x_acc, chi0_y_pos_in => chi_0_y_pos, chi0_y_vel_in => chi_0_y_vel, chi0_y_acc_in => chi_0_y_acc, chi0_z_pos_in => chi_0_z_pos, chi0_z_vel_in => chi_0_z_vel, chi0_z_acc_in => chi_0_z_acc,
            chi1_x_pos_in => chi_1_x_pos, chi1_x_vel_in => chi_1_x_vel, chi1_x_acc_in => chi_1_x_acc, chi1_y_pos_in => chi_1_y_pos, chi1_y_vel_in => chi_1_y_vel, chi1_y_acc_in => chi_1_y_acc, chi1_z_pos_in => chi_1_z_pos, chi1_z_vel_in => chi_1_z_vel, chi1_z_acc_in => chi_1_z_acc,
            chi2_x_pos_in => chi_2_x_pos, chi2_x_vel_in => chi_2_x_vel, chi2_x_acc_in => chi_2_x_acc, chi2_y_pos_in => chi_2_y_pos, chi2_y_vel_in => chi_2_y_vel, chi2_y_acc_in => chi_2_y_acc, chi2_z_pos_in => chi_2_z_pos, chi2_z_vel_in => chi_2_z_vel, chi2_z_acc_in => chi_2_z_acc,
            chi3_x_pos_in => chi_3_x_pos, chi3_x_vel_in => chi_3_x_vel, chi3_x_acc_in => chi_3_x_acc, chi3_y_pos_in => chi_3_y_pos, chi3_y_vel_in => chi_3_y_vel, chi3_y_acc_in => chi_3_y_acc, chi3_z_pos_in => chi_3_z_pos, chi3_z_vel_in => chi_3_z_vel, chi3_z_acc_in => chi_3_z_acc,
            chi4_x_pos_in => chi_4_x_pos, chi4_x_vel_in => chi_4_x_vel, chi4_x_acc_in => chi_4_x_acc, chi4_y_pos_in => chi_4_y_pos, chi4_y_vel_in => chi_4_y_vel, chi4_y_acc_in => chi_4_y_acc, chi4_z_pos_in => chi_4_z_pos, chi4_z_vel_in => chi_4_z_vel, chi4_z_acc_in => chi_4_z_acc,
            chi5_x_pos_in => chi_5_x_pos, chi5_x_vel_in => chi_5_x_vel, chi5_x_acc_in => chi_5_x_acc, chi5_y_pos_in => chi_5_y_pos, chi5_y_vel_in => chi_5_y_vel, chi5_y_acc_in => chi_5_y_acc, chi5_z_pos_in => chi_5_z_pos, chi5_z_vel_in => chi_5_z_vel, chi5_z_acc_in => chi_5_z_acc,
            chi6_x_pos_in => chi_6_x_pos, chi6_x_vel_in => chi_6_x_vel, chi6_x_acc_in => chi_6_x_acc, chi6_y_pos_in => chi_6_y_pos, chi6_y_vel_in => chi_6_y_vel, chi6_y_acc_in => chi_6_y_acc, chi6_z_pos_in => chi_6_z_pos, chi6_z_vel_in => chi_6_z_vel, chi6_z_acc_in => chi_6_z_acc,
            chi7_x_pos_in => chi_7_x_pos, chi7_x_vel_in => chi_7_x_vel, chi7_x_acc_in => chi_7_x_acc, chi7_y_pos_in => chi_7_y_pos, chi7_y_vel_in => chi_7_y_vel, chi7_y_acc_in => chi_7_y_acc, chi7_z_pos_in => chi_7_z_pos, chi7_z_vel_in => chi_7_z_vel, chi7_z_acc_in => chi_7_z_acc,
            chi8_x_pos_in => chi_8_x_pos, chi8_x_vel_in => chi_8_x_vel, chi8_x_acc_in => chi_8_x_acc, chi8_y_pos_in => chi_8_y_pos, chi8_y_vel_in => chi_8_y_vel, chi8_y_acc_in => chi_8_y_acc, chi8_z_pos_in => chi_8_z_pos, chi8_z_vel_in => chi_8_z_vel, chi8_z_acc_in => chi_8_z_acc,
            chi9_x_pos_in => chi_9_x_pos, chi9_x_vel_in => chi_9_x_vel, chi9_x_acc_in => chi_9_x_acc, chi9_y_pos_in => chi_9_y_pos, chi9_y_vel_in => chi_9_y_vel, chi9_y_acc_in => chi_9_y_acc, chi9_z_pos_in => chi_9_z_pos, chi9_z_vel_in => chi_9_z_vel, chi9_z_acc_in => chi_9_z_acc,
            chi10_x_pos_in => chi_10_x_pos, chi10_x_vel_in => chi_10_x_vel, chi10_x_acc_in => chi_10_x_acc, chi10_y_pos_in => chi_10_y_pos, chi10_y_vel_in => chi_10_y_vel, chi10_y_acc_in => chi_10_y_acc, chi10_z_pos_in => chi_10_z_pos, chi10_z_vel_in => chi_10_z_vel, chi10_z_acc_in => chi_10_z_acc,
            chi11_x_pos_in => chi_11_x_pos, chi11_x_vel_in => chi_11_x_vel, chi11_x_acc_in => chi_11_x_acc, chi11_y_pos_in => chi_11_y_pos, chi11_y_vel_in => chi_11_y_vel, chi11_y_acc_in => chi_11_y_acc, chi11_z_pos_in => chi_11_z_pos, chi11_z_vel_in => chi_11_z_vel, chi11_z_acc_in => chi_11_z_acc,
            chi12_x_pos_in => chi_12_x_pos, chi12_x_vel_in => chi_12_x_vel, chi12_x_acc_in => chi_12_x_acc, chi12_y_pos_in => chi_12_y_pos, chi12_y_vel_in => chi_12_y_vel, chi12_y_acc_in => chi_12_y_acc, chi12_z_pos_in => chi_12_z_pos, chi12_z_vel_in => chi_12_z_vel, chi12_z_acc_in => chi_12_z_acc,
            chi13_x_pos_in => chi_13_x_pos, chi13_x_vel_in => chi_13_x_vel, chi13_x_acc_in => chi_13_x_acc, chi13_y_pos_in => chi_13_y_pos, chi13_y_vel_in => chi_13_y_vel, chi13_y_acc_in => chi_13_y_acc, chi13_z_pos_in => chi_13_z_pos, chi13_z_vel_in => chi_13_z_vel, chi13_z_acc_in => chi_13_z_acc,
            chi14_x_pos_in => chi_14_x_pos, chi14_x_vel_in => chi_14_x_vel, chi14_x_acc_in => chi_14_x_acc, chi14_y_pos_in => chi_14_y_pos, chi14_y_vel_in => chi_14_y_vel, chi14_y_acc_in => chi_14_y_acc, chi14_z_pos_in => chi_14_z_pos, chi14_z_vel_in => chi_14_z_vel, chi14_z_acc_in => chi_14_z_acc,
            chi15_x_pos_in => chi_15_x_pos, chi15_x_vel_in => chi_15_x_vel, chi15_x_acc_in => chi_15_x_acc, chi15_y_pos_in => chi_15_y_pos, chi15_y_vel_in => chi_15_y_vel, chi15_y_acc_in => chi_15_y_acc, chi15_z_pos_in => chi_15_z_pos, chi15_z_vel_in => chi_15_z_vel, chi15_z_acc_in => chi_15_z_acc,
            chi16_x_pos_in => chi_16_x_pos, chi16_x_vel_in => chi_16_x_vel, chi16_x_acc_in => chi_16_x_acc, chi16_y_pos_in => chi_16_y_pos, chi16_y_vel_in => chi_16_y_vel, chi16_y_acc_in => chi_16_y_acc, chi16_z_pos_in => chi_16_z_pos, chi16_z_vel_in => chi_16_z_vel, chi16_z_acc_in => chi_16_z_acc,
            chi17_x_pos_in => chi_17_x_pos, chi17_x_vel_in => chi_17_x_vel, chi17_x_acc_in => chi_17_x_acc, chi17_y_pos_in => chi_17_y_pos, chi17_y_vel_in => chi_17_y_vel, chi17_y_acc_in => chi_17_y_acc, chi17_z_pos_in => chi_17_z_pos, chi17_z_vel_in => chi_17_z_vel, chi17_z_acc_in => chi_17_z_acc,
            chi18_x_pos_in => chi_18_x_pos, chi18_x_vel_in => chi_18_x_vel, chi18_x_acc_in => chi_18_x_acc, chi18_y_pos_in => chi_18_y_pos, chi18_y_vel_in => chi_18_y_vel, chi18_y_acc_in => chi_18_y_acc, chi18_z_pos_in => chi_18_z_pos, chi18_z_vel_in => chi_18_z_vel, chi18_z_acc_in => chi_18_z_acc,
            chi0_x_pos_pred => chi_pred_int_0_x_pos, chi0_x_vel_pred => chi_pred_int_0_x_vel, chi0_x_acc_pred => chi_pred_int_0_x_acc, chi0_y_pos_pred => chi_pred_int_0_y_pos, chi0_y_vel_pred => chi_pred_int_0_y_vel, chi0_y_acc_pred => chi_pred_int_0_y_acc, chi0_z_pos_pred => chi_pred_int_0_z_pos, chi0_z_vel_pred => chi_pred_int_0_z_vel, chi0_z_acc_pred => chi_pred_int_0_z_acc,
            chi1_x_pos_pred => chi_pred_int_1_x_pos, chi1_x_vel_pred => chi_pred_int_1_x_vel, chi1_x_acc_pred => chi_pred_int_1_x_acc, chi1_y_pos_pred => chi_pred_int_1_y_pos, chi1_y_vel_pred => chi_pred_int_1_y_vel, chi1_y_acc_pred => chi_pred_int_1_y_acc, chi1_z_pos_pred => chi_pred_int_1_z_pos, chi1_z_vel_pred => chi_pred_int_1_z_vel, chi1_z_acc_pred => chi_pred_int_1_z_acc,
            chi2_x_pos_pred => chi_pred_int_2_x_pos, chi2_x_vel_pred => chi_pred_int_2_x_vel, chi2_x_acc_pred => chi_pred_int_2_x_acc, chi2_y_pos_pred => chi_pred_int_2_y_pos, chi2_y_vel_pred => chi_pred_int_2_y_vel, chi2_y_acc_pred => chi_pred_int_2_y_acc, chi2_z_pos_pred => chi_pred_int_2_z_pos, chi2_z_vel_pred => chi_pred_int_2_z_vel, chi2_z_acc_pred => chi_pred_int_2_z_acc,
            chi3_x_pos_pred => chi_pred_int_3_x_pos, chi3_x_vel_pred => chi_pred_int_3_x_vel, chi3_x_acc_pred => chi_pred_int_3_x_acc, chi3_y_pos_pred => chi_pred_int_3_y_pos, chi3_y_vel_pred => chi_pred_int_3_y_vel, chi3_y_acc_pred => chi_pred_int_3_y_acc, chi3_z_pos_pred => chi_pred_int_3_z_pos, chi3_z_vel_pred => chi_pred_int_3_z_vel, chi3_z_acc_pred => chi_pred_int_3_z_acc,
            chi4_x_pos_pred => chi_pred_int_4_x_pos, chi4_x_vel_pred => chi_pred_int_4_x_vel, chi4_x_acc_pred => chi_pred_int_4_x_acc, chi4_y_pos_pred => chi_pred_int_4_y_pos, chi4_y_vel_pred => chi_pred_int_4_y_vel, chi4_y_acc_pred => chi_pred_int_4_y_acc, chi4_z_pos_pred => chi_pred_int_4_z_pos, chi4_z_vel_pred => chi_pred_int_4_z_vel, chi4_z_acc_pred => chi_pred_int_4_z_acc,
            chi5_x_pos_pred => chi_pred_int_5_x_pos, chi5_x_vel_pred => chi_pred_int_5_x_vel, chi5_x_acc_pred => chi_pred_int_5_x_acc, chi5_y_pos_pred => chi_pred_int_5_y_pos, chi5_y_vel_pred => chi_pred_int_5_y_vel, chi5_y_acc_pred => chi_pred_int_5_y_acc, chi5_z_pos_pred => chi_pred_int_5_z_pos, chi5_z_vel_pred => chi_pred_int_5_z_vel, chi5_z_acc_pred => chi_pred_int_5_z_acc,
            chi6_x_pos_pred => chi_pred_int_6_x_pos, chi6_x_vel_pred => chi_pred_int_6_x_vel, chi6_x_acc_pred => chi_pred_int_6_x_acc, chi6_y_pos_pred => chi_pred_int_6_y_pos, chi6_y_vel_pred => chi_pred_int_6_y_vel, chi6_y_acc_pred => chi_pred_int_6_y_acc, chi6_z_pos_pred => chi_pred_int_6_z_pos, chi6_z_vel_pred => chi_pred_int_6_z_vel, chi6_z_acc_pred => chi_pred_int_6_z_acc,
            chi7_x_pos_pred => chi_pred_int_7_x_pos, chi7_x_vel_pred => chi_pred_int_7_x_vel, chi7_x_acc_pred => chi_pred_int_7_x_acc, chi7_y_pos_pred => chi_pred_int_7_y_pos, chi7_y_vel_pred => chi_pred_int_7_y_vel, chi7_y_acc_pred => chi_pred_int_7_y_acc, chi7_z_pos_pred => chi_pred_int_7_z_pos, chi7_z_vel_pred => chi_pred_int_7_z_vel, chi7_z_acc_pred => chi_pred_int_7_z_acc,
            chi8_x_pos_pred => chi_pred_int_8_x_pos, chi8_x_vel_pred => chi_pred_int_8_x_vel, chi8_x_acc_pred => chi_pred_int_8_x_acc, chi8_y_pos_pred => chi_pred_int_8_y_pos, chi8_y_vel_pred => chi_pred_int_8_y_vel, chi8_y_acc_pred => chi_pred_int_8_y_acc, chi8_z_pos_pred => chi_pred_int_8_z_pos, chi8_z_vel_pred => chi_pred_int_8_z_vel, chi8_z_acc_pred => chi_pred_int_8_z_acc,
            chi9_x_pos_pred => chi_pred_int_9_x_pos, chi9_x_vel_pred => chi_pred_int_9_x_vel, chi9_x_acc_pred => chi_pred_int_9_x_acc, chi9_y_pos_pred => chi_pred_int_9_y_pos, chi9_y_vel_pred => chi_pred_int_9_y_vel, chi9_y_acc_pred => chi_pred_int_9_y_acc, chi9_z_pos_pred => chi_pred_int_9_z_pos, chi9_z_vel_pred => chi_pred_int_9_z_vel, chi9_z_acc_pred => chi_pred_int_9_z_acc,
            chi10_x_pos_pred => chi_pred_int_10_x_pos, chi10_x_vel_pred => chi_pred_int_10_x_vel, chi10_x_acc_pred => chi_pred_int_10_x_acc, chi10_y_pos_pred => chi_pred_int_10_y_pos, chi10_y_vel_pred => chi_pred_int_10_y_vel, chi10_y_acc_pred => chi_pred_int_10_y_acc, chi10_z_pos_pred => chi_pred_int_10_z_pos, chi10_z_vel_pred => chi_pred_int_10_z_vel, chi10_z_acc_pred => chi_pred_int_10_z_acc,
            chi11_x_pos_pred => chi_pred_int_11_x_pos, chi11_x_vel_pred => chi_pred_int_11_x_vel, chi11_x_acc_pred => chi_pred_int_11_x_acc, chi11_y_pos_pred => chi_pred_int_11_y_pos, chi11_y_vel_pred => chi_pred_int_11_y_vel, chi11_y_acc_pred => chi_pred_int_11_y_acc, chi11_z_pos_pred => chi_pred_int_11_z_pos, chi11_z_vel_pred => chi_pred_int_11_z_vel, chi11_z_acc_pred => chi_pred_int_11_z_acc,
            chi12_x_pos_pred => chi_pred_int_12_x_pos, chi12_x_vel_pred => chi_pred_int_12_x_vel, chi12_x_acc_pred => chi_pred_int_12_x_acc, chi12_y_pos_pred => chi_pred_int_12_y_pos, chi12_y_vel_pred => chi_pred_int_12_y_vel, chi12_y_acc_pred => chi_pred_int_12_y_acc, chi12_z_pos_pred => chi_pred_int_12_z_pos, chi12_z_vel_pred => chi_pred_int_12_z_vel, chi12_z_acc_pred => chi_pred_int_12_z_acc,
            chi13_x_pos_pred => chi_pred_int_13_x_pos, chi13_x_vel_pred => chi_pred_int_13_x_vel, chi13_x_acc_pred => chi_pred_int_13_x_acc, chi13_y_pos_pred => chi_pred_int_13_y_pos, chi13_y_vel_pred => chi_pred_int_13_y_vel, chi13_y_acc_pred => chi_pred_int_13_y_acc, chi13_z_pos_pred => chi_pred_int_13_z_pos, chi13_z_vel_pred => chi_pred_int_13_z_vel, chi13_z_acc_pred => chi_pred_int_13_z_acc,
            chi14_x_pos_pred => chi_pred_int_14_x_pos, chi14_x_vel_pred => chi_pred_int_14_x_vel, chi14_x_acc_pred => chi_pred_int_14_x_acc, chi14_y_pos_pred => chi_pred_int_14_y_pos, chi14_y_vel_pred => chi_pred_int_14_y_vel, chi14_y_acc_pred => chi_pred_int_14_y_acc, chi14_z_pos_pred => chi_pred_int_14_z_pos, chi14_z_vel_pred => chi_pred_int_14_z_vel, chi14_z_acc_pred => chi_pred_int_14_z_acc,
            chi15_x_pos_pred => chi_pred_int_15_x_pos, chi15_x_vel_pred => chi_pred_int_15_x_vel, chi15_x_acc_pred => chi_pred_int_15_x_acc, chi15_y_pos_pred => chi_pred_int_15_y_pos, chi15_y_vel_pred => chi_pred_int_15_y_vel, chi15_y_acc_pred => chi_pred_int_15_y_acc, chi15_z_pos_pred => chi_pred_int_15_z_pos, chi15_z_vel_pred => chi_pred_int_15_z_vel, chi15_z_acc_pred => chi_pred_int_15_z_acc,
            chi16_x_pos_pred => chi_pred_int_16_x_pos, chi16_x_vel_pred => chi_pred_int_16_x_vel, chi16_x_acc_pred => chi_pred_int_16_x_acc, chi16_y_pos_pred => chi_pred_int_16_y_pos, chi16_y_vel_pred => chi_pred_int_16_y_vel, chi16_y_acc_pred => chi_pred_int_16_y_acc, chi16_z_pos_pred => chi_pred_int_16_z_pos, chi16_z_vel_pred => chi_pred_int_16_z_vel, chi16_z_acc_pred => chi_pred_int_16_z_acc,
            chi17_x_pos_pred => chi_pred_int_17_x_pos, chi17_x_vel_pred => chi_pred_int_17_x_vel, chi17_x_acc_pred => chi_pred_int_17_x_acc, chi17_y_pos_pred => chi_pred_int_17_y_pos, chi17_y_vel_pred => chi_pred_int_17_y_vel, chi17_y_acc_pred => chi_pred_int_17_y_acc, chi17_z_pos_pred => chi_pred_int_17_z_pos, chi17_z_vel_pred => chi_pred_int_17_z_vel, chi17_z_acc_pred => chi_pred_int_17_z_acc,
            chi18_x_pos_pred => chi_pred_int_18_x_pos, chi18_x_vel_pred => chi_pred_int_18_x_vel, chi18_x_acc_pred => chi_pred_int_18_x_acc, chi18_y_pos_pred => chi_pred_int_18_y_pos, chi18_y_vel_pred => chi_pred_int_18_y_vel, chi18_y_acc_pred => chi_pred_int_18_y_acc, chi18_z_pos_pred => chi_pred_int_18_z_pos, chi18_z_vel_pred => chi_pred_int_18_z_vel, chi18_z_acc_pred => chi_pred_int_18_z_acc,
            done => predict_done
        );

    mean_comp : predicted_mean_3d
        port map (
            clk => clk, rst => rst, start => mean_start,
            chi0_x_pos_pred => chi_pred_int_0_x_pos, chi0_x_vel_pred => chi_pred_int_0_x_vel, chi0_x_acc_pred => chi_pred_int_0_x_acc, chi0_y_pos_pred => chi_pred_int_0_y_pos, chi0_y_vel_pred => chi_pred_int_0_y_vel, chi0_y_acc_pred => chi_pred_int_0_y_acc, chi0_z_pos_pred => chi_pred_int_0_z_pos, chi0_z_vel_pred => chi_pred_int_0_z_vel, chi0_z_acc_pred => chi_pred_int_0_z_acc,
            chi1_x_pos_pred => chi_pred_int_1_x_pos, chi1_x_vel_pred => chi_pred_int_1_x_vel, chi1_x_acc_pred => chi_pred_int_1_x_acc, chi1_y_pos_pred => chi_pred_int_1_y_pos, chi1_y_vel_pred => chi_pred_int_1_y_vel, chi1_y_acc_pred => chi_pred_int_1_y_acc, chi1_z_pos_pred => chi_pred_int_1_z_pos, chi1_z_vel_pred => chi_pred_int_1_z_vel, chi1_z_acc_pred => chi_pred_int_1_z_acc,
            chi2_x_pos_pred => chi_pred_int_2_x_pos, chi2_x_vel_pred => chi_pred_int_2_x_vel, chi2_x_acc_pred => chi_pred_int_2_x_acc, chi2_y_pos_pred => chi_pred_int_2_y_pos, chi2_y_vel_pred => chi_pred_int_2_y_vel, chi2_y_acc_pred => chi_pred_int_2_y_acc, chi2_z_pos_pred => chi_pred_int_2_z_pos, chi2_z_vel_pred => chi_pred_int_2_z_vel, chi2_z_acc_pred => chi_pred_int_2_z_acc,
            chi3_x_pos_pred => chi_pred_int_3_x_pos, chi3_x_vel_pred => chi_pred_int_3_x_vel, chi3_x_acc_pred => chi_pred_int_3_x_acc, chi3_y_pos_pred => chi_pred_int_3_y_pos, chi3_y_vel_pred => chi_pred_int_3_y_vel, chi3_y_acc_pred => chi_pred_int_3_y_acc, chi3_z_pos_pred => chi_pred_int_3_z_pos, chi3_z_vel_pred => chi_pred_int_3_z_vel, chi3_z_acc_pred => chi_pred_int_3_z_acc,
            chi4_x_pos_pred => chi_pred_int_4_x_pos, chi4_x_vel_pred => chi_pred_int_4_x_vel, chi4_x_acc_pred => chi_pred_int_4_x_acc, chi4_y_pos_pred => chi_pred_int_4_y_pos, chi4_y_vel_pred => chi_pred_int_4_y_vel, chi4_y_acc_pred => chi_pred_int_4_y_acc, chi4_z_pos_pred => chi_pred_int_4_z_pos, chi4_z_vel_pred => chi_pred_int_4_z_vel, chi4_z_acc_pred => chi_pred_int_4_z_acc,
            chi5_x_pos_pred => chi_pred_int_5_x_pos, chi5_x_vel_pred => chi_pred_int_5_x_vel, chi5_x_acc_pred => chi_pred_int_5_x_acc, chi5_y_pos_pred => chi_pred_int_5_y_pos, chi5_y_vel_pred => chi_pred_int_5_y_vel, chi5_y_acc_pred => chi_pred_int_5_y_acc, chi5_z_pos_pred => chi_pred_int_5_z_pos, chi5_z_vel_pred => chi_pred_int_5_z_vel, chi5_z_acc_pred => chi_pred_int_5_z_acc,
            chi6_x_pos_pred => chi_pred_int_6_x_pos, chi6_x_vel_pred => chi_pred_int_6_x_vel, chi6_x_acc_pred => chi_pred_int_6_x_acc, chi6_y_pos_pred => chi_pred_int_6_y_pos, chi6_y_vel_pred => chi_pred_int_6_y_vel, chi6_y_acc_pred => chi_pred_int_6_y_acc, chi6_z_pos_pred => chi_pred_int_6_z_pos, chi6_z_vel_pred => chi_pred_int_6_z_vel, chi6_z_acc_pred => chi_pred_int_6_z_acc,
            chi7_x_pos_pred => chi_pred_int_7_x_pos, chi7_x_vel_pred => chi_pred_int_7_x_vel, chi7_x_acc_pred => chi_pred_int_7_x_acc, chi7_y_pos_pred => chi_pred_int_7_y_pos, chi7_y_vel_pred => chi_pred_int_7_y_vel, chi7_y_acc_pred => chi_pred_int_7_y_acc, chi7_z_pos_pred => chi_pred_int_7_z_pos, chi7_z_vel_pred => chi_pred_int_7_z_vel, chi7_z_acc_pred => chi_pred_int_7_z_acc,
            chi8_x_pos_pred => chi_pred_int_8_x_pos, chi8_x_vel_pred => chi_pred_int_8_x_vel, chi8_x_acc_pred => chi_pred_int_8_x_acc, chi8_y_pos_pred => chi_pred_int_8_y_pos, chi8_y_vel_pred => chi_pred_int_8_y_vel, chi8_y_acc_pred => chi_pred_int_8_y_acc, chi8_z_pos_pred => chi_pred_int_8_z_pos, chi8_z_vel_pred => chi_pred_int_8_z_vel, chi8_z_acc_pred => chi_pred_int_8_z_acc,
            chi9_x_pos_pred => chi_pred_int_9_x_pos, chi9_x_vel_pred => chi_pred_int_9_x_vel, chi9_x_acc_pred => chi_pred_int_9_x_acc, chi9_y_pos_pred => chi_pred_int_9_y_pos, chi9_y_vel_pred => chi_pred_int_9_y_vel, chi9_y_acc_pred => chi_pred_int_9_y_acc, chi9_z_pos_pred => chi_pred_int_9_z_pos, chi9_z_vel_pred => chi_pred_int_9_z_vel, chi9_z_acc_pred => chi_pred_int_9_z_acc,
            chi10_x_pos_pred => chi_pred_int_10_x_pos, chi10_x_vel_pred => chi_pred_int_10_x_vel, chi10_x_acc_pred => chi_pred_int_10_x_acc, chi10_y_pos_pred => chi_pred_int_10_y_pos, chi10_y_vel_pred => chi_pred_int_10_y_vel, chi10_y_acc_pred => chi_pred_int_10_y_acc, chi10_z_pos_pred => chi_pred_int_10_z_pos, chi10_z_vel_pred => chi_pred_int_10_z_vel, chi10_z_acc_pred => chi_pred_int_10_z_acc,
            chi11_x_pos_pred => chi_pred_int_11_x_pos, chi11_x_vel_pred => chi_pred_int_11_x_vel, chi11_x_acc_pred => chi_pred_int_11_x_acc, chi11_y_pos_pred => chi_pred_int_11_y_pos, chi11_y_vel_pred => chi_pred_int_11_y_vel, chi11_y_acc_pred => chi_pred_int_11_y_acc, chi11_z_pos_pred => chi_pred_int_11_z_pos, chi11_z_vel_pred => chi_pred_int_11_z_vel, chi11_z_acc_pred => chi_pred_int_11_z_acc,
            chi12_x_pos_pred => chi_pred_int_12_x_pos, chi12_x_vel_pred => chi_pred_int_12_x_vel, chi12_x_acc_pred => chi_pred_int_12_x_acc, chi12_y_pos_pred => chi_pred_int_12_y_pos, chi12_y_vel_pred => chi_pred_int_12_y_vel, chi12_y_acc_pred => chi_pred_int_12_y_acc, chi12_z_pos_pred => chi_pred_int_12_z_pos, chi12_z_vel_pred => chi_pred_int_12_z_vel, chi12_z_acc_pred => chi_pred_int_12_z_acc,
            chi13_x_pos_pred => chi_pred_int_13_x_pos, chi13_x_vel_pred => chi_pred_int_13_x_vel, chi13_x_acc_pred => chi_pred_int_13_x_acc, chi13_y_pos_pred => chi_pred_int_13_y_pos, chi13_y_vel_pred => chi_pred_int_13_y_vel, chi13_y_acc_pred => chi_pred_int_13_y_acc, chi13_z_pos_pred => chi_pred_int_13_z_pos, chi13_z_vel_pred => chi_pred_int_13_z_vel, chi13_z_acc_pred => chi_pred_int_13_z_acc,
            chi14_x_pos_pred => chi_pred_int_14_x_pos, chi14_x_vel_pred => chi_pred_int_14_x_vel, chi14_x_acc_pred => chi_pred_int_14_x_acc, chi14_y_pos_pred => chi_pred_int_14_y_pos, chi14_y_vel_pred => chi_pred_int_14_y_vel, chi14_y_acc_pred => chi_pred_int_14_y_acc, chi14_z_pos_pred => chi_pred_int_14_z_pos, chi14_z_vel_pred => chi_pred_int_14_z_vel, chi14_z_acc_pred => chi_pred_int_14_z_acc,
            chi15_x_pos_pred => chi_pred_int_15_x_pos, chi15_x_vel_pred => chi_pred_int_15_x_vel, chi15_x_acc_pred => chi_pred_int_15_x_acc, chi15_y_pos_pred => chi_pred_int_15_y_pos, chi15_y_vel_pred => chi_pred_int_15_y_vel, chi15_y_acc_pred => chi_pred_int_15_y_acc, chi15_z_pos_pred => chi_pred_int_15_z_pos, chi15_z_vel_pred => chi_pred_int_15_z_vel, chi15_z_acc_pred => chi_pred_int_15_z_acc,
            chi16_x_pos_pred => chi_pred_int_16_x_pos, chi16_x_vel_pred => chi_pred_int_16_x_vel, chi16_x_acc_pred => chi_pred_int_16_x_acc, chi16_y_pos_pred => chi_pred_int_16_y_pos, chi16_y_vel_pred => chi_pred_int_16_y_vel, chi16_y_acc_pred => chi_pred_int_16_y_acc, chi16_z_pos_pred => chi_pred_int_16_z_pos, chi16_z_vel_pred => chi_pred_int_16_z_vel, chi16_z_acc_pred => chi_pred_int_16_z_acc,
            chi17_x_pos_pred => chi_pred_int_17_x_pos, chi17_x_vel_pred => chi_pred_int_17_x_vel, chi17_x_acc_pred => chi_pred_int_17_x_acc, chi17_y_pos_pred => chi_pred_int_17_y_pos, chi17_y_vel_pred => chi_pred_int_17_y_vel, chi17_y_acc_pred => chi_pred_int_17_y_acc, chi17_z_pos_pred => chi_pred_int_17_z_pos, chi17_z_vel_pred => chi_pred_int_17_z_vel, chi17_z_acc_pred => chi_pred_int_17_z_acc,
            chi18_x_pos_pred => chi_pred_int_18_x_pos, chi18_x_vel_pred => chi_pred_int_18_x_vel, chi18_x_acc_pred => chi_pred_int_18_x_acc, chi18_y_pos_pred => chi_pred_int_18_y_pos, chi18_y_vel_pred => chi_pred_int_18_y_vel, chi18_y_acc_pred => chi_pred_int_18_y_acc, chi18_z_pos_pred => chi_pred_int_18_z_pos, chi18_z_vel_pred => chi_pred_int_18_z_vel, chi18_z_acc_pred => chi_pred_int_18_z_acc,
            x_pos_mean_pred => x_pos_mean, x_vel_mean_pred => x_vel_mean, x_acc_mean_pred => x_acc_mean,
            y_pos_mean_pred => y_pos_mean, y_vel_mean_pred => y_vel_mean, y_acc_mean_pred => y_acc_mean,
            z_pos_mean_pred => z_pos_mean, z_vel_mean_pred => z_vel_mean, z_acc_mean_pred => z_acc_mean,
            done => mean_done
        );

    qr_comp : qr_decomp_9x19
        port map (
            clk => clk, reset => rst, start => qr_start,
            x_pos_mean => x_pos_mean, x_vel_mean => x_vel_mean, x_acc_mean => x_acc_mean,
            y_pos_mean => y_pos_mean, y_vel_mean => y_vel_mean, y_acc_mean => y_acc_mean,
            z_pos_mean => z_pos_mean, z_vel_mean => z_vel_mean, z_acc_mean => z_acc_mean,
            chi0_x_pos => chi_pred_int_0_x_pos, chi0_x_vel => chi_pred_int_0_x_vel, chi0_x_acc => chi_pred_int_0_x_acc, chi0_y_pos => chi_pred_int_0_y_pos, chi0_y_vel => chi_pred_int_0_y_vel, chi0_y_acc => chi_pred_int_0_y_acc, chi0_z_pos => chi_pred_int_0_z_pos, chi0_z_vel => chi_pred_int_0_z_vel, chi0_z_acc => chi_pred_int_0_z_acc,
            chi1_x_pos => chi_pred_int_1_x_pos, chi1_x_vel => chi_pred_int_1_x_vel, chi1_x_acc => chi_pred_int_1_x_acc, chi1_y_pos => chi_pred_int_1_y_pos, chi1_y_vel => chi_pred_int_1_y_vel, chi1_y_acc => chi_pred_int_1_y_acc, chi1_z_pos => chi_pred_int_1_z_pos, chi1_z_vel => chi_pred_int_1_z_vel, chi1_z_acc => chi_pred_int_1_z_acc,
            chi2_x_pos => chi_pred_int_2_x_pos, chi2_x_vel => chi_pred_int_2_x_vel, chi2_x_acc => chi_pred_int_2_x_acc, chi2_y_pos => chi_pred_int_2_y_pos, chi2_y_vel => chi_pred_int_2_y_vel, chi2_y_acc => chi_pred_int_2_y_acc, chi2_z_pos => chi_pred_int_2_z_pos, chi2_z_vel => chi_pred_int_2_z_vel, chi2_z_acc => chi_pred_int_2_z_acc,
            chi3_x_pos => chi_pred_int_3_x_pos, chi3_x_vel => chi_pred_int_3_x_vel, chi3_x_acc => chi_pred_int_3_x_acc, chi3_y_pos => chi_pred_int_3_y_pos, chi3_y_vel => chi_pred_int_3_y_vel, chi3_y_acc => chi_pred_int_3_y_acc, chi3_z_pos => chi_pred_int_3_z_pos, chi3_z_vel => chi_pred_int_3_z_vel, chi3_z_acc => chi_pred_int_3_z_acc,
            chi4_x_pos => chi_pred_int_4_x_pos, chi4_x_vel => chi_pred_int_4_x_vel, chi4_x_acc => chi_pred_int_4_x_acc, chi4_y_pos => chi_pred_int_4_y_pos, chi4_y_vel => chi_pred_int_4_y_vel, chi4_y_acc => chi_pred_int_4_y_acc, chi4_z_pos => chi_pred_int_4_z_pos, chi4_z_vel => chi_pred_int_4_z_vel, chi4_z_acc => chi_pred_int_4_z_acc,
            chi5_x_pos => chi_pred_int_5_x_pos, chi5_x_vel => chi_pred_int_5_x_vel, chi5_x_acc => chi_pred_int_5_x_acc, chi5_y_pos => chi_pred_int_5_y_pos, chi5_y_vel => chi_pred_int_5_y_vel, chi5_y_acc => chi_pred_int_5_y_acc, chi5_z_pos => chi_pred_int_5_z_pos, chi5_z_vel => chi_pred_int_5_z_vel, chi5_z_acc => chi_pred_int_5_z_acc,
            chi6_x_pos => chi_pred_int_6_x_pos, chi6_x_vel => chi_pred_int_6_x_vel, chi6_x_acc => chi_pred_int_6_x_acc, chi6_y_pos => chi_pred_int_6_y_pos, chi6_y_vel => chi_pred_int_6_y_vel, chi6_y_acc => chi_pred_int_6_y_acc, chi6_z_pos => chi_pred_int_6_z_pos, chi6_z_vel => chi_pred_int_6_z_vel, chi6_z_acc => chi_pred_int_6_z_acc,
            chi7_x_pos => chi_pred_int_7_x_pos, chi7_x_vel => chi_pred_int_7_x_vel, chi7_x_acc => chi_pred_int_7_x_acc, chi7_y_pos => chi_pred_int_7_y_pos, chi7_y_vel => chi_pred_int_7_y_vel, chi7_y_acc => chi_pred_int_7_y_acc, chi7_z_pos => chi_pred_int_7_z_pos, chi7_z_vel => chi_pred_int_7_z_vel, chi7_z_acc => chi_pred_int_7_z_acc,
            chi8_x_pos => chi_pred_int_8_x_pos, chi8_x_vel => chi_pred_int_8_x_vel, chi8_x_acc => chi_pred_int_8_x_acc, chi8_y_pos => chi_pred_int_8_y_pos, chi8_y_vel => chi_pred_int_8_y_vel, chi8_y_acc => chi_pred_int_8_y_acc, chi8_z_pos => chi_pred_int_8_z_pos, chi8_z_vel => chi_pred_int_8_z_vel, chi8_z_acc => chi_pred_int_8_z_acc,
            chi9_x_pos => chi_pred_int_9_x_pos, chi9_x_vel => chi_pred_int_9_x_vel, chi9_x_acc => chi_pred_int_9_x_acc, chi9_y_pos => chi_pred_int_9_y_pos, chi9_y_vel => chi_pred_int_9_y_vel, chi9_y_acc => chi_pred_int_9_y_acc, chi9_z_pos => chi_pred_int_9_z_pos, chi9_z_vel => chi_pred_int_9_z_vel, chi9_z_acc => chi_pred_int_9_z_acc,
            chi10_x_pos => chi_pred_int_10_x_pos, chi10_x_vel => chi_pred_int_10_x_vel, chi10_x_acc => chi_pred_int_10_x_acc, chi10_y_pos => chi_pred_int_10_y_pos, chi10_y_vel => chi_pred_int_10_y_vel, chi10_y_acc => chi_pred_int_10_y_acc, chi10_z_pos => chi_pred_int_10_z_pos, chi10_z_vel => chi_pred_int_10_z_vel, chi10_z_acc => chi_pred_int_10_z_acc,
            chi11_x_pos => chi_pred_int_11_x_pos, chi11_x_vel => chi_pred_int_11_x_vel, chi11_x_acc => chi_pred_int_11_x_acc, chi11_y_pos => chi_pred_int_11_y_pos, chi11_y_vel => chi_pred_int_11_y_vel, chi11_y_acc => chi_pred_int_11_y_acc, chi11_z_pos => chi_pred_int_11_z_pos, chi11_z_vel => chi_pred_int_11_z_vel, chi11_z_acc => chi_pred_int_11_z_acc,
            chi12_x_pos => chi_pred_int_12_x_pos, chi12_x_vel => chi_pred_int_12_x_vel, chi12_x_acc => chi_pred_int_12_x_acc, chi12_y_pos => chi_pred_int_12_y_pos, chi12_y_vel => chi_pred_int_12_y_vel, chi12_y_acc => chi_pred_int_12_y_acc, chi12_z_pos => chi_pred_int_12_z_pos, chi12_z_vel => chi_pred_int_12_z_vel, chi12_z_acc => chi_pred_int_12_z_acc,
            chi13_x_pos => chi_pred_int_13_x_pos, chi13_x_vel => chi_pred_int_13_x_vel, chi13_x_acc => chi_pred_int_13_x_acc, chi13_y_pos => chi_pred_int_13_y_pos, chi13_y_vel => chi_pred_int_13_y_vel, chi13_y_acc => chi_pred_int_13_y_acc, chi13_z_pos => chi_pred_int_13_z_pos, chi13_z_vel => chi_pred_int_13_z_vel, chi13_z_acc => chi_pred_int_13_z_acc,
            chi14_x_pos => chi_pred_int_14_x_pos, chi14_x_vel => chi_pred_int_14_x_vel, chi14_x_acc => chi_pred_int_14_x_acc, chi14_y_pos => chi_pred_int_14_y_pos, chi14_y_vel => chi_pred_int_14_y_vel, chi14_y_acc => chi_pred_int_14_y_acc, chi14_z_pos => chi_pred_int_14_z_pos, chi14_z_vel => chi_pred_int_14_z_vel, chi14_z_acc => chi_pred_int_14_z_acc,
            chi15_x_pos => chi_pred_int_15_x_pos, chi15_x_vel => chi_pred_int_15_x_vel, chi15_x_acc => chi_pred_int_15_x_acc, chi15_y_pos => chi_pred_int_15_y_pos, chi15_y_vel => chi_pred_int_15_y_vel, chi15_y_acc => chi_pred_int_15_y_acc, chi15_z_pos => chi_pred_int_15_z_pos, chi15_z_vel => chi_pred_int_15_z_vel, chi15_z_acc => chi_pred_int_15_z_acc,
            chi16_x_pos => chi_pred_int_16_x_pos, chi16_x_vel => chi_pred_int_16_x_vel, chi16_x_acc => chi_pred_int_16_x_acc, chi16_y_pos => chi_pred_int_16_y_pos, chi16_y_vel => chi_pred_int_16_y_vel, chi16_y_acc => chi_pred_int_16_y_acc, chi16_z_pos => chi_pred_int_16_z_pos, chi16_z_vel => chi_pred_int_16_z_vel, chi16_z_acc => chi_pred_int_16_z_acc,
            chi17_x_pos => chi_pred_int_17_x_pos, chi17_x_vel => chi_pred_int_17_x_vel, chi17_x_acc => chi_pred_int_17_x_acc, chi17_y_pos => chi_pred_int_17_y_pos, chi17_y_vel => chi_pred_int_17_y_vel, chi17_y_acc => chi_pred_int_17_y_acc, chi17_z_pos => chi_pred_int_17_z_pos, chi17_z_vel => chi_pred_int_17_z_vel, chi17_z_acc => chi_pred_int_17_z_acc,
            chi18_x_pos => chi_pred_int_18_x_pos, chi18_x_vel => chi_pred_int_18_x_vel, chi18_x_acc => chi_pred_int_18_x_acc, chi18_y_pos => chi_pred_int_18_y_pos, chi18_y_vel => chi_pred_int_18_y_vel, chi18_y_acc => chi_pred_int_18_y_acc, chi18_z_pos => chi_pred_int_18_z_pos, chi18_z_vel => chi_pred_int_18_z_vel, chi18_z_acc => chi_pred_int_18_z_acc,
            l11_out => l11_qr, l21_out => l21_qr, l31_out => l31_qr, l41_out => l41_qr, l51_out => l51_qr, l61_out => l61_qr, l71_out => l71_qr, l81_out => l81_qr, l91_out => l91_qr,
            l22_out => l22_qr, l32_out => l32_qr, l42_out => l42_qr, l52_out => l52_qr, l62_out => l62_qr, l72_out => l72_qr, l82_out => l82_qr, l92_out => l92_qr,
            l33_out => l33_qr, l43_out => l43_qr, l53_out => l53_qr, l63_out => l63_qr, l73_out => l73_qr, l83_out => l83_qr, l93_out => l93_qr,
            l44_out => l44_qr, l54_out => l54_qr, l64_out => l64_qr, l74_out => l74_qr, l84_out => l84_qr, l94_out => l94_qr,
            l55_out => l55_qr, l65_out => l65_qr, l75_out => l75_qr, l85_out => l85_qr, l95_out => l95_qr,
            l66_out => l66_qr, l76_out => l76_qr, l86_out => l86_qr, l96_out => l96_qr,
            l77_out => l77_qr, l87_out => l87_qr, l97_out => l97_qr,
            l88_out => l88_qr, l98_out => l98_qr,
            l99_out => l99_qr,
            done => qr_done
        );

    w0_update_comp : cholesky_rank1_update
        port map (
            clk => clk, reset => rst, start => w0_update_start,
            l11_in => l11_qr, l21_in => l21_qr, l31_in => l31_qr, l41_in => l41_qr, l51_in => l51_qr, l61_in => l61_qr, l71_in => l71_qr, l81_in => l81_qr, l91_in => l91_qr,
            l22_in => l22_qr, l32_in => l32_qr, l42_in => l42_qr, l52_in => l52_qr, l62_in => l62_qr, l72_in => l72_qr, l82_in => l82_qr, l92_in => l92_qr,
            l33_in => l33_qr, l43_in => l43_qr, l53_in => l53_qr, l63_in => l63_qr, l73_in => l73_qr, l83_in => l83_qr, l93_in => l93_qr,
            l44_in => l44_qr, l54_in => l54_qr, l64_in => l64_qr, l74_in => l74_qr, l84_in => l84_qr, l94_in => l94_qr,
            l55_in => l55_qr, l65_in => l65_qr, l75_in => l75_qr, l85_in => l85_qr, l95_in => l95_qr,
            l66_in => l66_qr, l76_in => l76_qr, l86_in => l86_qr, l96_in => l96_qr,
            l77_in => l77_qr, l87_in => l87_qr, l97_in => l97_qr,
            l88_in => l88_qr, l98_in => l98_qr,
            l99_in => l99_qr,
            u1_in => w0_1, u2_in => w0_2, u3_in => w0_3, u4_in => w0_4, u5_in => w0_5, u6_in => w0_6, u7_in => w0_7, u8_in => w0_8, u9_in => w0_9,
            l11_out => l11_dd, l21_out => l21_dd, l31_out => l31_dd, l41_out => l41_dd, l51_out => l51_dd, l61_out => l61_dd, l71_out => l71_dd, l81_out => l81_dd, l91_out => l91_dd,
            l22_out => l22_dd, l32_out => l32_dd, l42_out => l42_dd, l52_out => l52_dd, l62_out => l62_dd, l72_out => l72_dd, l82_out => l82_dd, l92_out => l92_dd,
            l33_out => l33_dd, l43_out => l43_dd, l53_out => l53_dd, l63_out => l63_dd, l73_out => l73_dd, l83_out => l83_dd, l93_out => l93_dd,
            l44_out => l44_dd, l54_out => l54_dd, l64_out => l64_dd, l74_out => l74_dd, l84_out => l84_dd, l94_out => l94_dd,
            l55_out => l55_dd, l65_out => l65_dd, l75_out => l75_dd, l85_out => l85_dd, l95_out => l95_dd,
            l66_out => l66_dd, l76_out => l76_dd, l86_out => l86_dd, l96_out => l96_dd,
            l77_out => l77_dd, l87_out => l87_dd, l97_out => l97_dd,
            l88_out => l88_dd, l98_out => l98_dd,
            l99_out => l99_dd,
            done => w0_update_done
        );

    noise_comp : process_noise_rank1_3d
        port map (
            clk => clk, reset => rst, start => noise_start,
            l11_in => l11_dd, l21_in => l21_dd, l31_in => l31_dd, l41_in => l41_dd, l51_in => l51_dd, l61_in => l61_dd, l71_in => l71_dd, l81_in => l81_dd, l91_in => l91_dd,
            l22_in => l22_dd, l32_in => l32_dd, l42_in => l42_dd, l52_in => l52_dd, l62_in => l62_dd, l72_in => l72_dd, l82_in => l82_dd, l92_in => l92_dd,
            l33_in => l33_dd, l43_in => l43_dd, l53_in => l53_dd, l63_in => l63_dd, l73_in => l73_dd, l83_in => l83_dd, l93_in => l93_dd,
            l44_in => l44_dd, l54_in => l54_dd, l64_in => l64_dd, l74_in => l74_dd, l84_in => l84_dd, l94_in => l94_dd,
            l55_in => l55_dd, l65_in => l65_dd, l75_in => l75_dd, l85_in => l85_dd, l95_in => l95_dd,
            l66_in => l66_dd, l76_in => l76_dd, l86_in => l86_dd, l96_in => l96_dd,
            l77_in => l77_dd, l87_in => l87_dd, l97_in => l97_dd,
            l88_in => l88_dd, l98_in => l98_dd,
            l99_in => l99_dd,
            l11_out => l11_pred, l21_out => l21_pred, l31_out => l31_pred, l41_out => l41_pred, l51_out => l51_pred, l61_out => l61_pred, l71_out => l71_pred, l81_out => l81_pred, l91_out => l91_pred,
            l22_out => l22_pred, l32_out => l32_pred, l42_out => l42_pred, l52_out => l52_pred, l62_out => l62_pred, l72_out => l72_pred, l82_out => l82_pred, l92_out => l92_pred,
            l33_out => l33_pred, l43_out => l43_pred, l53_out => l53_pred, l63_out => l63_pred, l73_out => l73_pred, l83_out => l83_pred, l93_out => l93_pred,
            l44_out => l44_pred, l54_out => l54_pred, l64_out => l64_pred, l74_out => l74_pred, l84_out => l84_pred, l94_out => l94_pred,
            l55_out => l55_pred, l65_out => l65_pred, l75_out => l75_pred, l85_out => l85_pred, l95_out => l95_pred,
            l66_out => l66_pred, l76_out => l76_pred, l86_out => l86_pred, l96_out => l96_pred,
            l77_out => l77_pred, l87_out => l87_pred, l97_out => l97_pred,
            l88_out => l88_pred, l98_out => l98_pred,
            l99_out => l99_pred,
            done => noise_done
        );

    x_pos_pred <= x_pos_mean;
    x_vel_pred <= x_vel_mean;
    x_acc_pred <= x_acc_mean;
    y_pos_pred <= y_pos_mean;
    y_vel_pred <= y_vel_mean;
    y_acc_pred <= y_acc_mean;
    z_pos_pred <= z_pos_mean;
    z_vel_pred <= z_vel_mean;
    z_acc_pred <= z_acc_mean;

    chi_pred_0_x_pos <= chi_pred_int_0_x_pos;
    chi_pred_0_x_vel <= chi_pred_int_0_x_vel;
    chi_pred_0_x_acc <= chi_pred_int_0_x_acc;
    chi_pred_0_y_pos <= chi_pred_int_0_y_pos;
    chi_pred_0_y_vel <= chi_pred_int_0_y_vel;
    chi_pred_0_y_acc <= chi_pred_int_0_y_acc;
    chi_pred_0_z_pos <= chi_pred_int_0_z_pos;
    chi_pred_0_z_vel <= chi_pred_int_0_z_vel;
    chi_pred_0_z_acc <= chi_pred_int_0_z_acc;
    chi_pred_1_x_pos <= chi_pred_int_1_x_pos;
    chi_pred_1_x_vel <= chi_pred_int_1_x_vel;
    chi_pred_1_x_acc <= chi_pred_int_1_x_acc;
    chi_pred_1_y_pos <= chi_pred_int_1_y_pos;
    chi_pred_1_y_vel <= chi_pred_int_1_y_vel;
    chi_pred_1_y_acc <= chi_pred_int_1_y_acc;
    chi_pred_1_z_pos <= chi_pred_int_1_z_pos;
    chi_pred_1_z_vel <= chi_pred_int_1_z_vel;
    chi_pred_1_z_acc <= chi_pred_int_1_z_acc;
    chi_pred_2_x_pos <= chi_pred_int_2_x_pos;
    chi_pred_2_x_vel <= chi_pred_int_2_x_vel;
    chi_pred_2_x_acc <= chi_pred_int_2_x_acc;
    chi_pred_2_y_pos <= chi_pred_int_2_y_pos;
    chi_pred_2_y_vel <= chi_pred_int_2_y_vel;
    chi_pred_2_y_acc <= chi_pred_int_2_y_acc;
    chi_pred_2_z_pos <= chi_pred_int_2_z_pos;
    chi_pred_2_z_vel <= chi_pred_int_2_z_vel;
    chi_pred_2_z_acc <= chi_pred_int_2_z_acc;
    chi_pred_3_x_pos <= chi_pred_int_3_x_pos;
    chi_pred_3_x_vel <= chi_pred_int_3_x_vel;
    chi_pred_3_x_acc <= chi_pred_int_3_x_acc;
    chi_pred_3_y_pos <= chi_pred_int_3_y_pos;
    chi_pred_3_y_vel <= chi_pred_int_3_y_vel;
    chi_pred_3_y_acc <= chi_pred_int_3_y_acc;
    chi_pred_3_z_pos <= chi_pred_int_3_z_pos;
    chi_pred_3_z_vel <= chi_pred_int_3_z_vel;
    chi_pred_3_z_acc <= chi_pred_int_3_z_acc;
    chi_pred_4_x_pos <= chi_pred_int_4_x_pos;
    chi_pred_4_x_vel <= chi_pred_int_4_x_vel;
    chi_pred_4_x_acc <= chi_pred_int_4_x_acc;
    chi_pred_4_y_pos <= chi_pred_int_4_y_pos;
    chi_pred_4_y_vel <= chi_pred_int_4_y_vel;
    chi_pred_4_y_acc <= chi_pred_int_4_y_acc;
    chi_pred_4_z_pos <= chi_pred_int_4_z_pos;
    chi_pred_4_z_vel <= chi_pred_int_4_z_vel;
    chi_pred_4_z_acc <= chi_pred_int_4_z_acc;
    chi_pred_5_x_pos <= chi_pred_int_5_x_pos;
    chi_pred_5_x_vel <= chi_pred_int_5_x_vel;
    chi_pred_5_x_acc <= chi_pred_int_5_x_acc;
    chi_pred_5_y_pos <= chi_pred_int_5_y_pos;
    chi_pred_5_y_vel <= chi_pred_int_5_y_vel;
    chi_pred_5_y_acc <= chi_pred_int_5_y_acc;
    chi_pred_5_z_pos <= chi_pred_int_5_z_pos;
    chi_pred_5_z_vel <= chi_pred_int_5_z_vel;
    chi_pred_5_z_acc <= chi_pred_int_5_z_acc;
    chi_pred_6_x_pos <= chi_pred_int_6_x_pos;
    chi_pred_6_x_vel <= chi_pred_int_6_x_vel;
    chi_pred_6_x_acc <= chi_pred_int_6_x_acc;
    chi_pred_6_y_pos <= chi_pred_int_6_y_pos;
    chi_pred_6_y_vel <= chi_pred_int_6_y_vel;
    chi_pred_6_y_acc <= chi_pred_int_6_y_acc;
    chi_pred_6_z_pos <= chi_pred_int_6_z_pos;
    chi_pred_6_z_vel <= chi_pred_int_6_z_vel;
    chi_pred_6_z_acc <= chi_pred_int_6_z_acc;
    chi_pred_7_x_pos <= chi_pred_int_7_x_pos;
    chi_pred_7_x_vel <= chi_pred_int_7_x_vel;
    chi_pred_7_x_acc <= chi_pred_int_7_x_acc;
    chi_pred_7_y_pos <= chi_pred_int_7_y_pos;
    chi_pred_7_y_vel <= chi_pred_int_7_y_vel;
    chi_pred_7_y_acc <= chi_pred_int_7_y_acc;
    chi_pred_7_z_pos <= chi_pred_int_7_z_pos;
    chi_pred_7_z_vel <= chi_pred_int_7_z_vel;
    chi_pred_7_z_acc <= chi_pred_int_7_z_acc;
    chi_pred_8_x_pos <= chi_pred_int_8_x_pos;
    chi_pred_8_x_vel <= chi_pred_int_8_x_vel;
    chi_pred_8_x_acc <= chi_pred_int_8_x_acc;
    chi_pred_8_y_pos <= chi_pred_int_8_y_pos;
    chi_pred_8_y_vel <= chi_pred_int_8_y_vel;
    chi_pred_8_y_acc <= chi_pred_int_8_y_acc;
    chi_pred_8_z_pos <= chi_pred_int_8_z_pos;
    chi_pred_8_z_vel <= chi_pred_int_8_z_vel;
    chi_pred_8_z_acc <= chi_pred_int_8_z_acc;
    chi_pred_9_x_pos <= chi_pred_int_9_x_pos;
    chi_pred_9_x_vel <= chi_pred_int_9_x_vel;
    chi_pred_9_x_acc <= chi_pred_int_9_x_acc;
    chi_pred_9_y_pos <= chi_pred_int_9_y_pos;
    chi_pred_9_y_vel <= chi_pred_int_9_y_vel;
    chi_pred_9_y_acc <= chi_pred_int_9_y_acc;
    chi_pred_9_z_pos <= chi_pred_int_9_z_pos;
    chi_pred_9_z_vel <= chi_pred_int_9_z_vel;
    chi_pred_9_z_acc <= chi_pred_int_9_z_acc;
    chi_pred_10_x_pos <= chi_pred_int_10_x_pos;
    chi_pred_10_x_vel <= chi_pred_int_10_x_vel;
    chi_pred_10_x_acc <= chi_pred_int_10_x_acc;
    chi_pred_10_y_pos <= chi_pred_int_10_y_pos;
    chi_pred_10_y_vel <= chi_pred_int_10_y_vel;
    chi_pred_10_y_acc <= chi_pred_int_10_y_acc;
    chi_pred_10_z_pos <= chi_pred_int_10_z_pos;
    chi_pred_10_z_vel <= chi_pred_int_10_z_vel;
    chi_pred_10_z_acc <= chi_pred_int_10_z_acc;
    chi_pred_11_x_pos <= chi_pred_int_11_x_pos;
    chi_pred_11_x_vel <= chi_pred_int_11_x_vel;
    chi_pred_11_x_acc <= chi_pred_int_11_x_acc;
    chi_pred_11_y_pos <= chi_pred_int_11_y_pos;
    chi_pred_11_y_vel <= chi_pred_int_11_y_vel;
    chi_pred_11_y_acc <= chi_pred_int_11_y_acc;
    chi_pred_11_z_pos <= chi_pred_int_11_z_pos;
    chi_pred_11_z_vel <= chi_pred_int_11_z_vel;
    chi_pred_11_z_acc <= chi_pred_int_11_z_acc;
    chi_pred_12_x_pos <= chi_pred_int_12_x_pos;
    chi_pred_12_x_vel <= chi_pred_int_12_x_vel;
    chi_pred_12_x_acc <= chi_pred_int_12_x_acc;
    chi_pred_12_y_pos <= chi_pred_int_12_y_pos;
    chi_pred_12_y_vel <= chi_pred_int_12_y_vel;
    chi_pred_12_y_acc <= chi_pred_int_12_y_acc;
    chi_pred_12_z_pos <= chi_pred_int_12_z_pos;
    chi_pred_12_z_vel <= chi_pred_int_12_z_vel;
    chi_pred_12_z_acc <= chi_pred_int_12_z_acc;
    chi_pred_13_x_pos <= chi_pred_int_13_x_pos;
    chi_pred_13_x_vel <= chi_pred_int_13_x_vel;
    chi_pred_13_x_acc <= chi_pred_int_13_x_acc;
    chi_pred_13_y_pos <= chi_pred_int_13_y_pos;
    chi_pred_13_y_vel <= chi_pred_int_13_y_vel;
    chi_pred_13_y_acc <= chi_pred_int_13_y_acc;
    chi_pred_13_z_pos <= chi_pred_int_13_z_pos;
    chi_pred_13_z_vel <= chi_pred_int_13_z_vel;
    chi_pred_13_z_acc <= chi_pred_int_13_z_acc;
    chi_pred_14_x_pos <= chi_pred_int_14_x_pos;
    chi_pred_14_x_vel <= chi_pred_int_14_x_vel;
    chi_pred_14_x_acc <= chi_pred_int_14_x_acc;
    chi_pred_14_y_pos <= chi_pred_int_14_y_pos;
    chi_pred_14_y_vel <= chi_pred_int_14_y_vel;
    chi_pred_14_y_acc <= chi_pred_int_14_y_acc;
    chi_pred_14_z_pos <= chi_pred_int_14_z_pos;
    chi_pred_14_z_vel <= chi_pred_int_14_z_vel;
    chi_pred_14_z_acc <= chi_pred_int_14_z_acc;
    chi_pred_15_x_pos <= chi_pred_int_15_x_pos;
    chi_pred_15_x_vel <= chi_pred_int_15_x_vel;
    chi_pred_15_x_acc <= chi_pred_int_15_x_acc;
    chi_pred_15_y_pos <= chi_pred_int_15_y_pos;
    chi_pred_15_y_vel <= chi_pred_int_15_y_vel;
    chi_pred_15_y_acc <= chi_pred_int_15_y_acc;
    chi_pred_15_z_pos <= chi_pred_int_15_z_pos;
    chi_pred_15_z_vel <= chi_pred_int_15_z_vel;
    chi_pred_15_z_acc <= chi_pred_int_15_z_acc;
    chi_pred_16_x_pos <= chi_pred_int_16_x_pos;
    chi_pred_16_x_vel <= chi_pred_int_16_x_vel;
    chi_pred_16_x_acc <= chi_pred_int_16_x_acc;
    chi_pred_16_y_pos <= chi_pred_int_16_y_pos;
    chi_pred_16_y_vel <= chi_pred_int_16_y_vel;
    chi_pred_16_y_acc <= chi_pred_int_16_y_acc;
    chi_pred_16_z_pos <= chi_pred_int_16_z_pos;
    chi_pred_16_z_vel <= chi_pred_int_16_z_vel;
    chi_pred_16_z_acc <= chi_pred_int_16_z_acc;
    chi_pred_17_x_pos <= chi_pred_int_17_x_pos;
    chi_pred_17_x_vel <= chi_pred_int_17_x_vel;
    chi_pred_17_x_acc <= chi_pred_int_17_x_acc;
    chi_pred_17_y_pos <= chi_pred_int_17_y_pos;
    chi_pred_17_y_vel <= chi_pred_int_17_y_vel;
    chi_pred_17_y_acc <= chi_pred_int_17_y_acc;
    chi_pred_17_z_pos <= chi_pred_int_17_z_pos;
    chi_pred_17_z_vel <= chi_pred_int_17_z_vel;
    chi_pred_17_z_acc <= chi_pred_int_17_z_acc;
    chi_pred_18_x_pos <= chi_pred_int_18_x_pos;
    chi_pred_18_x_vel <= chi_pred_int_18_x_vel;
    chi_pred_18_x_acc <= chi_pred_int_18_x_acc;
    chi_pred_18_y_pos <= chi_pred_int_18_y_pos;
    chi_pred_18_y_vel <= chi_pred_int_18_y_vel;
    chi_pred_18_y_acc <= chi_pred_int_18_y_acc;
    chi_pred_18_z_pos <= chi_pred_int_18_z_pos;
    chi_pred_18_z_vel <= chi_pred_int_18_z_vel;
    chi_pred_18_z_acc <= chi_pred_int_18_z_acc;

    process(clk)
        variable diff : signed(47 downto 0);
        variable prod : signed(95 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                done <= '0';
                sigma_start <= '0'; predict_start <= '0'; mean_start <= '0';
                qr_start <= '0'; w0_update_start <= '0'; noise_start <= '0';
            else
                sigma_start <= '0'; predict_start <= '0'; mean_start <= '0';
                qr_start <= '0'; w0_update_start <= '0'; noise_start <= '0';

                case state is
                    when IDLE =>
                        done <= '0';
                        if start = '1' then
                            state <= RUN_SIGMA;
                        end if;

                    when RUN_SIGMA =>
                        sigma_start <= '1';
                        state <= WAIT_SIGMA;

                    when WAIT_SIGMA =>
                        if sigma_done = '1' then
                            state <= RUN_PREDICT;
                        end if;

                    when RUN_PREDICT =>
                        predict_start <= '1';
                        state <= WAIT_PREDICT;

                    when WAIT_PREDICT =>
                        if predict_done = '1' then
                            state <= RUN_MEAN;
                        end if;

                    when RUN_MEAN =>
                        mean_start <= '1';
                        state <= WAIT_MEAN;

                    when WAIT_MEAN =>
                        if mean_done = '1' then
                            state <= RUN_QR;
                        end if;

                    when RUN_QR =>
                        qr_start <= '1';
                        state <= WAIT_QR;

                    when WAIT_QR =>
                        if qr_done = '1' then
                            state <= COMPUTE_W0;
                        end if;

                    when COMPUTE_W0 =>

                        diff := chi_pred_int_0_x_pos - x_pos_mean;
                        prod := diff * W0_ABS_SQRT;
                        w0_1 <= prod(71 downto 24);
                        diff := chi_pred_int_0_x_vel - x_vel_mean;
                        prod := diff * W0_ABS_SQRT;
                        w0_2 <= prod(71 downto 24);
                        diff := chi_pred_int_0_x_acc - x_acc_mean;
                        prod := diff * W0_ABS_SQRT;
                        w0_3 <= prod(71 downto 24);
                        diff := chi_pred_int_0_y_pos - y_pos_mean;
                        prod := diff * W0_ABS_SQRT;
                        w0_4 <= prod(71 downto 24);
                        diff := chi_pred_int_0_y_vel - y_vel_mean;
                        prod := diff * W0_ABS_SQRT;
                        w0_5 <= prod(71 downto 24);
                        diff := chi_pred_int_0_y_acc - y_acc_mean;
                        prod := diff * W0_ABS_SQRT;
                        w0_6 <= prod(71 downto 24);
                        diff := chi_pred_int_0_z_pos - z_pos_mean;
                        prod := diff * W0_ABS_SQRT;
                        w0_7 <= prod(71 downto 24);
                        diff := chi_pred_int_0_z_vel - z_vel_mean;
                        prod := diff * W0_ABS_SQRT;
                        w0_8 <= prod(71 downto 24);
                        diff := chi_pred_int_0_z_acc - z_acc_mean;
                        prod := diff * W0_ABS_SQRT;
                        w0_9 <= prod(71 downto 24);
                        state <= RUN_W0_UPDATE;

                    when RUN_W0_UPDATE =>
                        w0_update_start <= '1';
                        state <= WAIT_W0_UPDATE;

                    when WAIT_W0_UPDATE =>
                        if w0_update_done = '1' then
                            state <= RUN_NOISE;
                        end if;

                    when RUN_NOISE =>
                        noise_start <= '1';
                        state <= WAIT_NOISE;

                    when WAIT_NOISE =>
                        if noise_done = '1' then
                            state <= FINISHED;
                        end if;

                    when FINISHED =>
                        done <= '1';
                        if start = '0' then
                            state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
