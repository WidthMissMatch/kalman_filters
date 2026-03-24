library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sr_ukf_supreme_ca_3d is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        start : in  std_logic;

        z_x_meas : in signed(47 downto 0);
        z_y_meas : in signed(47 downto 0);
        z_z_meas : in signed(47 downto 0);

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

        inject_en : in std_logic;
        inj_x_pos, inj_x_vel, inj_x_acc : in signed(47 downto 0);
        inj_y_pos, inj_y_vel, inj_y_acc : in signed(47 downto 0);
        inj_z_pos, inj_z_vel, inj_z_acc : in signed(47 downto 0);

        inj_l11, inj_l22, inj_l33 : in signed(47 downto 0);
        inj_l44, inj_l55, inj_l66 : in signed(47 downto 0);
        inj_l77, inj_l88, inj_l99 : in signed(47 downto 0);

        nu_x_out, nu_y_out, nu_z_out : out signed(47 downto 0);
        s11_out, s22_out, s33_out : out signed(47 downto 0);

        done : out std_logic
    );
end sr_ukf_supreme_ca_3d;

architecture Behavioral of sr_ukf_supreme_ca_3d is

    component sr_prediction_phase_ca_3d is
        port (
            clk, rst, start : in std_logic;

            x_pos_current, x_vel_current, x_acc_current : in signed(47 downto 0);
            y_pos_current, y_vel_current, y_acc_current : in signed(47 downto 0);
            z_pos_current, z_vel_current, z_acc_current : in signed(47 downto 0);

            l11_current : in signed(47 downto 0);
            l21_current, l22_current : in signed(47 downto 0);
            l31_current, l32_current, l33_current : in signed(47 downto 0);
            l41_current, l42_current, l43_current, l44_current : in signed(47 downto 0);
            l51_current, l52_current, l53_current, l54_current, l55_current : in signed(47 downto 0);
            l61_current, l62_current, l63_current, l64_current, l65_current, l66_current : in signed(47 downto 0);
            l71_current, l72_current, l73_current, l74_current, l75_current, l76_current, l77_current : in signed(47 downto 0);
            l81_current, l82_current, l83_current, l84_current, l85_current, l86_current, l87_current, l88_current : in signed(47 downto 0);
            l91_current, l92_current, l93_current, l94_current, l95_current, l96_current, l97_current, l98_current, l99_current : in signed(47 downto 0);

            x_pos_pred, x_vel_pred, x_acc_pred : out signed(47 downto 0);
            y_pos_pred, y_vel_pred, y_acc_pred : out signed(47 downto 0);
            z_pos_pred, z_vel_pred, z_acc_pred : out signed(47 downto 0);

            l11_pred : out signed(47 downto 0);
            l21_pred, l22_pred : out signed(47 downto 0);
            l31_pred, l32_pred, l33_pred : out signed(47 downto 0);
            l41_pred, l42_pred, l43_pred, l44_pred : out signed(47 downto 0);
            l51_pred, l52_pred, l53_pred, l54_pred, l55_pred : out signed(47 downto 0);
            l61_pred, l62_pred, l63_pred, l64_pred, l65_pred, l66_pred : out signed(47 downto 0);
            l71_pred, l72_pred, l73_pred, l74_pred, l75_pred, l76_pred, l77_pred : out signed(47 downto 0);
            l81_pred, l82_pred, l83_pred, l84_pred, l85_pred, l86_pred, l87_pred, l88_pred : out signed(47 downto 0);
            l91_pred, l92_pred, l93_pred, l94_pred, l95_pred, l96_pred, l97_pred, l98_pred, l99_pred : out signed(47 downto 0);

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
    end component;

    component sr_measurement_update_ca_3d is
        port (
            clk   : in std_logic;
            reset : in std_logic;
            start : in std_logic;
            cycle_num : in integer range 0 to 1000;

            z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);

            x_pos_pred, x_vel_pred, x_acc_pred : in signed(47 downto 0);
            y_pos_pred, y_vel_pred, y_acc_pred : in signed(47 downto 0);
            z_pos_pred, z_vel_pred, z_acc_pred : in signed(47 downto 0);

            l11_pred : in signed(47 downto 0);
            l21_pred, l22_pred : in signed(47 downto 0);
            l31_pred, l32_pred, l33_pred : in signed(47 downto 0);
            l41_pred, l42_pred, l43_pred, l44_pred : in signed(47 downto 0);
            l51_pred, l52_pred, l53_pred, l54_pred, l55_pred : in signed(47 downto 0);
            l61_pred, l62_pred, l63_pred, l64_pred, l65_pred, l66_pred : in signed(47 downto 0);
            l71_pred, l72_pred, l73_pred, l74_pred, l75_pred, l76_pred, l77_pred : in signed(47 downto 0);
            l81_pred, l82_pred, l83_pred, l84_pred, l85_pred, l86_pred, l87_pred, l88_pred : in signed(47 downto 0);
            l91_pred, l92_pred, l93_pred, l94_pred, l95_pred, l96_pred, l97_pred, l98_pred, l99_pred : in signed(47 downto 0);

            chi_pred_0_x_pos, chi_pred_0_x_vel, chi_pred_0_x_acc, chi_pred_0_y_pos, chi_pred_0_y_vel, chi_pred_0_y_acc, chi_pred_0_z_pos, chi_pred_0_z_vel, chi_pred_0_z_acc : in signed(47 downto 0);
            chi_pred_1_x_pos, chi_pred_1_x_vel, chi_pred_1_x_acc, chi_pred_1_y_pos, chi_pred_1_y_vel, chi_pred_1_y_acc, chi_pred_1_z_pos, chi_pred_1_z_vel, chi_pred_1_z_acc : in signed(47 downto 0);
            chi_pred_2_x_pos, chi_pred_2_x_vel, chi_pred_2_x_acc, chi_pred_2_y_pos, chi_pred_2_y_vel, chi_pred_2_y_acc, chi_pred_2_z_pos, chi_pred_2_z_vel, chi_pred_2_z_acc : in signed(47 downto 0);
            chi_pred_3_x_pos, chi_pred_3_x_vel, chi_pred_3_x_acc, chi_pred_3_y_pos, chi_pred_3_y_vel, chi_pred_3_y_acc, chi_pred_3_z_pos, chi_pred_3_z_vel, chi_pred_3_z_acc : in signed(47 downto 0);
            chi_pred_4_x_pos, chi_pred_4_x_vel, chi_pred_4_x_acc, chi_pred_4_y_pos, chi_pred_4_y_vel, chi_pred_4_y_acc, chi_pred_4_z_pos, chi_pred_4_z_vel, chi_pred_4_z_acc : in signed(47 downto 0);
            chi_pred_5_x_pos, chi_pred_5_x_vel, chi_pred_5_x_acc, chi_pred_5_y_pos, chi_pred_5_y_vel, chi_pred_5_y_acc, chi_pred_5_z_pos, chi_pred_5_z_vel, chi_pred_5_z_acc : in signed(47 downto 0);
            chi_pred_6_x_pos, chi_pred_6_x_vel, chi_pred_6_x_acc, chi_pred_6_y_pos, chi_pred_6_y_vel, chi_pred_6_y_acc, chi_pred_6_z_pos, chi_pred_6_z_vel, chi_pred_6_z_acc : in signed(47 downto 0);
            chi_pred_7_x_pos, chi_pred_7_x_vel, chi_pred_7_x_acc, chi_pred_7_y_pos, chi_pred_7_y_vel, chi_pred_7_y_acc, chi_pred_7_z_pos, chi_pred_7_z_vel, chi_pred_7_z_acc : in signed(47 downto 0);
            chi_pred_8_x_pos, chi_pred_8_x_vel, chi_pred_8_x_acc, chi_pred_8_y_pos, chi_pred_8_y_vel, chi_pred_8_y_acc, chi_pred_8_z_pos, chi_pred_8_z_vel, chi_pred_8_z_acc : in signed(47 downto 0);
            chi_pred_9_x_pos, chi_pred_9_x_vel, chi_pred_9_x_acc, chi_pred_9_y_pos, chi_pred_9_y_vel, chi_pred_9_y_acc, chi_pred_9_z_pos, chi_pred_9_z_vel, chi_pred_9_z_acc : in signed(47 downto 0);
            chi_pred_10_x_pos, chi_pred_10_x_vel, chi_pred_10_x_acc, chi_pred_10_y_pos, chi_pred_10_y_vel, chi_pred_10_y_acc, chi_pred_10_z_pos, chi_pred_10_z_vel, chi_pred_10_z_acc : in signed(47 downto 0);
            chi_pred_11_x_pos, chi_pred_11_x_vel, chi_pred_11_x_acc, chi_pred_11_y_pos, chi_pred_11_y_vel, chi_pred_11_y_acc, chi_pred_11_z_pos, chi_pred_11_z_vel, chi_pred_11_z_acc : in signed(47 downto 0);
            chi_pred_12_x_pos, chi_pred_12_x_vel, chi_pred_12_x_acc, chi_pred_12_y_pos, chi_pred_12_y_vel, chi_pred_12_y_acc, chi_pred_12_z_pos, chi_pred_12_z_vel, chi_pred_12_z_acc : in signed(47 downto 0);
            chi_pred_13_x_pos, chi_pred_13_x_vel, chi_pred_13_x_acc, chi_pred_13_y_pos, chi_pred_13_y_vel, chi_pred_13_y_acc, chi_pred_13_z_pos, chi_pred_13_z_vel, chi_pred_13_z_acc : in signed(47 downto 0);
            chi_pred_14_x_pos, chi_pred_14_x_vel, chi_pred_14_x_acc, chi_pred_14_y_pos, chi_pred_14_y_vel, chi_pred_14_y_acc, chi_pred_14_z_pos, chi_pred_14_z_vel, chi_pred_14_z_acc : in signed(47 downto 0);
            chi_pred_15_x_pos, chi_pred_15_x_vel, chi_pred_15_x_acc, chi_pred_15_y_pos, chi_pred_15_y_vel, chi_pred_15_y_acc, chi_pred_15_z_pos, chi_pred_15_z_vel, chi_pred_15_z_acc : in signed(47 downto 0);
            chi_pred_16_x_pos, chi_pred_16_x_vel, chi_pred_16_x_acc, chi_pred_16_y_pos, chi_pred_16_y_vel, chi_pred_16_y_acc, chi_pred_16_z_pos, chi_pred_16_z_vel, chi_pred_16_z_acc : in signed(47 downto 0);
            chi_pred_17_x_pos, chi_pred_17_x_vel, chi_pred_17_x_acc, chi_pred_17_y_pos, chi_pred_17_y_vel, chi_pred_17_y_acc, chi_pred_17_z_pos, chi_pred_17_z_vel, chi_pred_17_z_acc : in signed(47 downto 0);
            chi_pred_18_x_pos, chi_pred_18_x_vel, chi_pred_18_x_acc, chi_pred_18_y_pos, chi_pred_18_y_vel, chi_pred_18_y_acc, chi_pred_18_z_pos, chi_pred_18_z_vel, chi_pred_18_z_acc : in signed(47 downto 0);

            x_pos_upd, x_vel_upd, x_acc_upd : buffer signed(47 downto 0);
            y_pos_upd, y_vel_upd, y_acc_upd : buffer signed(47 downto 0);
            z_pos_upd, z_vel_upd, z_acc_upd : buffer signed(47 downto 0);

            l11_upd : buffer signed(47 downto 0);
            l21_upd, l22_upd : buffer signed(47 downto 0);
            l31_upd, l32_upd, l33_upd : buffer signed(47 downto 0);
            l41_upd, l42_upd, l43_upd, l44_upd : buffer signed(47 downto 0);
            l51_upd, l52_upd, l53_upd, l54_upd, l55_upd : buffer signed(47 downto 0);
            l61_upd, l62_upd, l63_upd, l64_upd, l65_upd, l66_upd : buffer signed(47 downto 0);
            l71_upd, l72_upd, l73_upd, l74_upd, l75_upd, l76_upd, l77_upd : buffer signed(47 downto 0);
            l81_upd, l82_upd, l83_upd, l84_upd, l85_upd, l86_upd, l87_upd, l88_upd : buffer signed(47 downto 0);
            l91_upd, l92_upd, l93_upd, l94_upd, l95_upd, l96_upd, l97_upd, l98_upd, l99_upd : buffer signed(47 downto 0);

            nu_x_out, nu_y_out, nu_z_out : out signed(47 downto 0);
            s11_out, s22_out, s33_out : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    signal nu_x_buf, nu_y_buf, nu_z_buf : signed(47 downto 0) := (others => '0');
    signal s11_buf, s22_buf, s33_buf : signed(47 downto 0) := (others => '0');

    constant L11_INIT : signed(47 downto 0) := to_signed(37480968, 48);
    constant L22_INIT : signed(47 downto 0) := to_signed(74961936, 48);
    constant L33_INIT : signed(47 downto 0) := to_signed(1677722, 48);
    constant L44_INIT : signed(47 downto 0) := to_signed(37480968, 48);
    constant L55_INIT : signed(47 downto 0) := to_signed(74961936, 48);
    constant L66_INIT : signed(47 downto 0) := to_signed(1677722, 48);
    constant L77_INIT : signed(47 downto 0) := to_signed(37480968, 48);
    constant L88_INIT : signed(47 downto 0) := to_signed(74961936, 48);
    constant L99_INIT : signed(47 downto 0) := to_signed(1677722, 48);

    type state_type is (IDLE, INIT_STATE, WAIT_INIT, RUN_PREDICTION, WAIT_PREDICTION,
                        RUN_UPDATE, WAIT_UPDATE, FINISHED);
    signal state : state_type := IDLE;

    signal pred_start, pred_done : std_logic := '0';
    signal update_start, update_done : std_logic := '0';
    signal first_cycle : std_logic := '1';

    signal x_pos_state, x_vel_state, x_acc_state : signed(47 downto 0) := (others => '0');
    signal y_pos_state, y_vel_state, y_acc_state : signed(47 downto 0) := (others => '0');
    signal z_pos_state, z_vel_state, z_acc_state : signed(47 downto 0) := (others => '0');

    signal l11_state : signed(47 downto 0) := (others => '0');

    signal l21_state, l22_state : signed(47 downto 0) := (others => '0');

    signal l31_state, l32_state, l33_state : signed(47 downto 0) := (others => '0');

    signal l41_state, l42_state, l43_state, l44_state : signed(47 downto 0) := (others => '0');

    signal l51_state, l52_state, l53_state, l54_state, l55_state : signed(47 downto 0) := (others => '0');

    signal l61_state, l62_state, l63_state, l64_state, l65_state, l66_state : signed(47 downto 0) := (others => '0');

    signal l71_state, l72_state, l73_state, l74_state, l75_state, l76_state, l77_state : signed(47 downto 0) := (others => '0');

    signal l81_state, l82_state, l83_state, l84_state, l85_state, l86_state, l87_state, l88_state : signed(47 downto 0) := (others => '0');

    signal l91_state, l92_state, l93_state, l94_state, l95_state, l96_state, l97_state, l98_state, l99_state : signed(47 downto 0) := (others => '0');

    signal x_pos_pred_buf, x_vel_pred_buf, x_acc_pred_buf : signed(47 downto 0) := (others => '0');
    signal y_pos_pred_buf, y_vel_pred_buf, y_acc_pred_buf : signed(47 downto 0) := (others => '0');
    signal z_pos_pred_buf, z_vel_pred_buf, z_acc_pred_buf : signed(47 downto 0) := (others => '0');

    signal l11_pred_buf : signed(47 downto 0) := (others => '0');
    signal l21_pred_buf, l22_pred_buf : signed(47 downto 0) := (others => '0');
    signal l31_pred_buf, l32_pred_buf, l33_pred_buf : signed(47 downto 0) := (others => '0');
    signal l41_pred_buf, l42_pred_buf, l43_pred_buf, l44_pred_buf : signed(47 downto 0) := (others => '0');
    signal l51_pred_buf, l52_pred_buf, l53_pred_buf, l54_pred_buf, l55_pred_buf : signed(47 downto 0) := (others => '0');
    signal l61_pred_buf, l62_pred_buf, l63_pred_buf, l64_pred_buf, l65_pred_buf, l66_pred_buf : signed(47 downto 0) := (others => '0');
    signal l71_pred_buf, l72_pred_buf, l73_pred_buf, l74_pred_buf, l75_pred_buf, l76_pred_buf, l77_pred_buf : signed(47 downto 0) := (others => '0');
    signal l81_pred_buf, l82_pred_buf, l83_pred_buf, l84_pred_buf, l85_pred_buf, l86_pred_buf, l87_pred_buf, l88_pred_buf : signed(47 downto 0) := (others => '0');
    signal l91_pred_buf, l92_pred_buf, l93_pred_buf, l94_pred_buf, l95_pred_buf, l96_pred_buf, l97_pred_buf, l98_pred_buf, l99_pred_buf : signed(47 downto 0) := (others => '0');

    signal chi_pred_0_x_pos, chi_pred_0_x_vel, chi_pred_0_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_0_y_pos, chi_pred_0_y_vel, chi_pred_0_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_0_z_pos, chi_pred_0_z_vel, chi_pred_0_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_1_x_pos, chi_pred_1_x_vel, chi_pred_1_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_1_y_pos, chi_pred_1_y_vel, chi_pred_1_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_1_z_pos, chi_pred_1_z_vel, chi_pred_1_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_2_x_pos, chi_pred_2_x_vel, chi_pred_2_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_2_y_pos, chi_pred_2_y_vel, chi_pred_2_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_2_z_pos, chi_pred_2_z_vel, chi_pred_2_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_3_x_pos, chi_pred_3_x_vel, chi_pred_3_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_3_y_pos, chi_pred_3_y_vel, chi_pred_3_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_3_z_pos, chi_pred_3_z_vel, chi_pred_3_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_4_x_pos, chi_pred_4_x_vel, chi_pred_4_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_4_y_pos, chi_pred_4_y_vel, chi_pred_4_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_4_z_pos, chi_pred_4_z_vel, chi_pred_4_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_5_x_pos, chi_pred_5_x_vel, chi_pred_5_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_5_y_pos, chi_pred_5_y_vel, chi_pred_5_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_5_z_pos, chi_pred_5_z_vel, chi_pred_5_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_6_x_pos, chi_pred_6_x_vel, chi_pred_6_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_6_y_pos, chi_pred_6_y_vel, chi_pred_6_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_6_z_pos, chi_pred_6_z_vel, chi_pred_6_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_7_x_pos, chi_pred_7_x_vel, chi_pred_7_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_7_y_pos, chi_pred_7_y_vel, chi_pred_7_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_7_z_pos, chi_pred_7_z_vel, chi_pred_7_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_8_x_pos, chi_pred_8_x_vel, chi_pred_8_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_8_y_pos, chi_pred_8_y_vel, chi_pred_8_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_8_z_pos, chi_pred_8_z_vel, chi_pred_8_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_9_x_pos, chi_pred_9_x_vel, chi_pred_9_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_9_y_pos, chi_pred_9_y_vel, chi_pred_9_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_9_z_pos, chi_pred_9_z_vel, chi_pred_9_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_10_x_pos, chi_pred_10_x_vel, chi_pred_10_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_10_y_pos, chi_pred_10_y_vel, chi_pred_10_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_10_z_pos, chi_pred_10_z_vel, chi_pred_10_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_11_x_pos, chi_pred_11_x_vel, chi_pred_11_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_11_y_pos, chi_pred_11_y_vel, chi_pred_11_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_11_z_pos, chi_pred_11_z_vel, chi_pred_11_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_12_x_pos, chi_pred_12_x_vel, chi_pred_12_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_12_y_pos, chi_pred_12_y_vel, chi_pred_12_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_12_z_pos, chi_pred_12_z_vel, chi_pred_12_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_13_x_pos, chi_pred_13_x_vel, chi_pred_13_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_13_y_pos, chi_pred_13_y_vel, chi_pred_13_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_13_z_pos, chi_pred_13_z_vel, chi_pred_13_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_14_x_pos, chi_pred_14_x_vel, chi_pred_14_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_14_y_pos, chi_pred_14_y_vel, chi_pred_14_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_14_z_pos, chi_pred_14_z_vel, chi_pred_14_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_15_x_pos, chi_pred_15_x_vel, chi_pred_15_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_15_y_pos, chi_pred_15_y_vel, chi_pred_15_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_15_z_pos, chi_pred_15_z_vel, chi_pred_15_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_16_x_pos, chi_pred_16_x_vel, chi_pred_16_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_16_y_pos, chi_pred_16_y_vel, chi_pred_16_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_16_z_pos, chi_pred_16_z_vel, chi_pred_16_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_17_x_pos, chi_pred_17_x_vel, chi_pred_17_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_17_y_pos, chi_pred_17_y_vel, chi_pred_17_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_17_z_pos, chi_pred_17_z_vel, chi_pred_17_z_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_18_x_pos, chi_pred_18_x_vel, chi_pred_18_x_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_18_y_pos, chi_pred_18_y_vel, chi_pred_18_y_acc : signed(47 downto 0) := (others => '0');
    signal chi_pred_18_z_pos, chi_pred_18_z_vel, chi_pred_18_z_acc : signed(47 downto 0) := (others => '0');

    signal x_pos_upd_buf, x_vel_upd_buf, x_acc_upd_buf : signed(47 downto 0) := (others => '0');
    signal y_pos_upd_buf, y_vel_upd_buf, y_acc_upd_buf : signed(47 downto 0) := (others => '0');
    signal z_pos_upd_buf, z_vel_upd_buf, z_acc_upd_buf : signed(47 downto 0) := (others => '0');

    signal l11_upd_buf : signed(47 downto 0) := (others => '0');
    signal l21_upd_buf, l22_upd_buf : signed(47 downto 0) := (others => '0');
    signal l31_upd_buf, l32_upd_buf, l33_upd_buf : signed(47 downto 0) := (others => '0');
    signal l41_upd_buf, l42_upd_buf, l43_upd_buf, l44_upd_buf : signed(47 downto 0) := (others => '0');
    signal l51_upd_buf, l52_upd_buf, l53_upd_buf, l54_upd_buf, l55_upd_buf : signed(47 downto 0) := (others => '0');
    signal l61_upd_buf, l62_upd_buf, l63_upd_buf, l64_upd_buf, l65_upd_buf, l66_upd_buf : signed(47 downto 0) := (others => '0');
    signal l71_upd_buf, l72_upd_buf, l73_upd_buf, l74_upd_buf, l75_upd_buf, l76_upd_buf, l77_upd_buf : signed(47 downto 0) := (others => '0');
    signal l81_upd_buf, l82_upd_buf, l83_upd_buf, l84_upd_buf, l85_upd_buf, l86_upd_buf, l87_upd_buf, l88_upd_buf : signed(47 downto 0) := (others => '0');
    signal l91_upd_buf, l92_upd_buf, l93_upd_buf, l94_upd_buf, l95_upd_buf, l96_upd_buf, l97_upd_buf, l98_upd_buf, l99_upd_buf : signed(47 downto 0) := (others => '0');

begin

    x_pos_current <= x_pos_state;
    x_vel_current <= x_vel_state;
    x_acc_current <= x_acc_state;
    y_pos_current <= y_pos_state;
    y_vel_current <= y_vel_state;
    y_acc_current <= y_acc_state;
    z_pos_current <= z_pos_state;
    z_vel_current <= z_vel_state;
    z_acc_current <= z_acc_state;

    x_pos_uncertainty <= resize(shift_right(l11_state * l11_state, 24), 48);
    x_vel_uncertainty <= resize(shift_right(l22_state * l22_state, 24), 48);
    x_acc_uncertainty <= resize(shift_right(l33_state * l33_state, 24), 48);
    y_pos_uncertainty <= resize(shift_right(l44_state * l44_state, 24), 48);
    y_vel_uncertainty <= resize(shift_right(l55_state * l55_state, 24), 48);
    y_acc_uncertainty <= resize(shift_right(l66_state * l66_state, 24), 48);
    z_pos_uncertainty <= resize(shift_right(l77_state * l77_state, 24), 48);
    z_vel_uncertainty <= resize(shift_right(l88_state * l88_state, 24), 48);
    z_acc_uncertainty <= resize(shift_right(l99_state * l99_state, 24), 48);

    nu_x_out <= nu_x_buf;
    nu_y_out <= nu_y_buf;
    nu_z_out <= nu_z_buf;
    s11_out <= s11_buf;
    s22_out <= s22_buf;
    s33_out <= s33_buf;

    prediction_inst : sr_prediction_phase_ca_3d
        port map (
            clk => clk,
            rst => reset,
            start => pred_start,

            x_pos_current => x_pos_state,
            x_vel_current => x_vel_state,
            x_acc_current => x_acc_state,
            y_pos_current => y_pos_state,
            y_vel_current => y_vel_state,
            y_acc_current => y_acc_state,
            z_pos_current => z_pos_state,
            z_vel_current => z_vel_state,
            z_acc_current => z_acc_state,

            l11_current => l11_state,
            l21_current => l21_state, l22_current => l22_state,
            l31_current => l31_state, l32_current => l32_state, l33_current => l33_state,
            l41_current => l41_state, l42_current => l42_state, l43_current => l43_state, l44_current => l44_state,
            l51_current => l51_state, l52_current => l52_state, l53_current => l53_state, l54_current => l54_state, l55_current => l55_state,
            l61_current => l61_state, l62_current => l62_state, l63_current => l63_state, l64_current => l64_state, l65_current => l65_state, l66_current => l66_state,
            l71_current => l71_state, l72_current => l72_state, l73_current => l73_state, l74_current => l74_state, l75_current => l75_state, l76_current => l76_state, l77_current => l77_state,
            l81_current => l81_state, l82_current => l82_state, l83_current => l83_state, l84_current => l84_state, l85_current => l85_state, l86_current => l86_state, l87_current => l87_state, l88_current => l88_state,
            l91_current => l91_state, l92_current => l92_state, l93_current => l93_state, l94_current => l94_state, l95_current => l95_state, l96_current => l96_state, l97_current => l97_state, l98_current => l98_state, l99_current => l99_state,

            x_pos_pred => x_pos_pred_buf,
            x_vel_pred => x_vel_pred_buf,
            x_acc_pred => x_acc_pred_buf,
            y_pos_pred => y_pos_pred_buf,
            y_vel_pred => y_vel_pred_buf,
            y_acc_pred => y_acc_pred_buf,
            z_pos_pred => z_pos_pred_buf,
            z_vel_pred => z_vel_pred_buf,
            z_acc_pred => z_acc_pred_buf,

            l11_pred => l11_pred_buf,
            l21_pred => l21_pred_buf, l22_pred => l22_pred_buf,
            l31_pred => l31_pred_buf, l32_pred => l32_pred_buf, l33_pred => l33_pred_buf,
            l41_pred => l41_pred_buf, l42_pred => l42_pred_buf, l43_pred => l43_pred_buf, l44_pred => l44_pred_buf,
            l51_pred => l51_pred_buf, l52_pred => l52_pred_buf, l53_pred => l53_pred_buf, l54_pred => l54_pred_buf, l55_pred => l55_pred_buf,
            l61_pred => l61_pred_buf, l62_pred => l62_pred_buf, l63_pred => l63_pred_buf, l64_pred => l64_pred_buf, l65_pred => l65_pred_buf, l66_pred => l66_pred_buf,
            l71_pred => l71_pred_buf, l72_pred => l72_pred_buf, l73_pred => l73_pred_buf, l74_pred => l74_pred_buf, l75_pred => l75_pred_buf, l76_pred => l76_pred_buf, l77_pred => l77_pred_buf,
            l81_pred => l81_pred_buf, l82_pred => l82_pred_buf, l83_pred => l83_pred_buf, l84_pred => l84_pred_buf, l85_pred => l85_pred_buf, l86_pred => l86_pred_buf, l87_pred => l87_pred_buf, l88_pred => l88_pred_buf,
            l91_pred => l91_pred_buf, l92_pred => l92_pred_buf, l93_pred => l93_pred_buf, l94_pred => l94_pred_buf, l95_pred => l95_pred_buf, l96_pred => l96_pred_buf, l97_pred => l97_pred_buf, l98_pred => l98_pred_buf, l99_pred => l99_pred_buf,

            chi_pred_0_x_pos => chi_pred_0_x_pos, chi_pred_0_x_vel => chi_pred_0_x_vel, chi_pred_0_x_acc => chi_pred_0_x_acc,
            chi_pred_0_y_pos => chi_pred_0_y_pos, chi_pred_0_y_vel => chi_pred_0_y_vel, chi_pred_0_y_acc => chi_pred_0_y_acc,
            chi_pred_0_z_pos => chi_pred_0_z_pos, chi_pred_0_z_vel => chi_pred_0_z_vel, chi_pred_0_z_acc => chi_pred_0_z_acc,
            chi_pred_1_x_pos => chi_pred_1_x_pos, chi_pred_1_x_vel => chi_pred_1_x_vel, chi_pred_1_x_acc => chi_pred_1_x_acc,
            chi_pred_1_y_pos => chi_pred_1_y_pos, chi_pred_1_y_vel => chi_pred_1_y_vel, chi_pred_1_y_acc => chi_pred_1_y_acc,
            chi_pred_1_z_pos => chi_pred_1_z_pos, chi_pred_1_z_vel => chi_pred_1_z_vel, chi_pred_1_z_acc => chi_pred_1_z_acc,
            chi_pred_2_x_pos => chi_pred_2_x_pos, chi_pred_2_x_vel => chi_pred_2_x_vel, chi_pred_2_x_acc => chi_pred_2_x_acc,
            chi_pred_2_y_pos => chi_pred_2_y_pos, chi_pred_2_y_vel => chi_pred_2_y_vel, chi_pred_2_y_acc => chi_pred_2_y_acc,
            chi_pred_2_z_pos => chi_pred_2_z_pos, chi_pred_2_z_vel => chi_pred_2_z_vel, chi_pred_2_z_acc => chi_pred_2_z_acc,
            chi_pred_3_x_pos => chi_pred_3_x_pos, chi_pred_3_x_vel => chi_pred_3_x_vel, chi_pred_3_x_acc => chi_pred_3_x_acc,
            chi_pred_3_y_pos => chi_pred_3_y_pos, chi_pred_3_y_vel => chi_pred_3_y_vel, chi_pred_3_y_acc => chi_pred_3_y_acc,
            chi_pred_3_z_pos => chi_pred_3_z_pos, chi_pred_3_z_vel => chi_pred_3_z_vel, chi_pred_3_z_acc => chi_pred_3_z_acc,
            chi_pred_4_x_pos => chi_pred_4_x_pos, chi_pred_4_x_vel => chi_pred_4_x_vel, chi_pred_4_x_acc => chi_pred_4_x_acc,
            chi_pred_4_y_pos => chi_pred_4_y_pos, chi_pred_4_y_vel => chi_pred_4_y_vel, chi_pred_4_y_acc => chi_pred_4_y_acc,
            chi_pred_4_z_pos => chi_pred_4_z_pos, chi_pred_4_z_vel => chi_pred_4_z_vel, chi_pred_4_z_acc => chi_pred_4_z_acc,
            chi_pred_5_x_pos => chi_pred_5_x_pos, chi_pred_5_x_vel => chi_pred_5_x_vel, chi_pred_5_x_acc => chi_pred_5_x_acc,
            chi_pred_5_y_pos => chi_pred_5_y_pos, chi_pred_5_y_vel => chi_pred_5_y_vel, chi_pred_5_y_acc => chi_pred_5_y_acc,
            chi_pred_5_z_pos => chi_pred_5_z_pos, chi_pred_5_z_vel => chi_pred_5_z_vel, chi_pred_5_z_acc => chi_pred_5_z_acc,
            chi_pred_6_x_pos => chi_pred_6_x_pos, chi_pred_6_x_vel => chi_pred_6_x_vel, chi_pred_6_x_acc => chi_pred_6_x_acc,
            chi_pred_6_y_pos => chi_pred_6_y_pos, chi_pred_6_y_vel => chi_pred_6_y_vel, chi_pred_6_y_acc => chi_pred_6_y_acc,
            chi_pred_6_z_pos => chi_pred_6_z_pos, chi_pred_6_z_vel => chi_pred_6_z_vel, chi_pred_6_z_acc => chi_pred_6_z_acc,
            chi_pred_7_x_pos => chi_pred_7_x_pos, chi_pred_7_x_vel => chi_pred_7_x_vel, chi_pred_7_x_acc => chi_pred_7_x_acc,
            chi_pred_7_y_pos => chi_pred_7_y_pos, chi_pred_7_y_vel => chi_pred_7_y_vel, chi_pred_7_y_acc => chi_pred_7_y_acc,
            chi_pred_7_z_pos => chi_pred_7_z_pos, chi_pred_7_z_vel => chi_pred_7_z_vel, chi_pred_7_z_acc => chi_pred_7_z_acc,
            chi_pred_8_x_pos => chi_pred_8_x_pos, chi_pred_8_x_vel => chi_pred_8_x_vel, chi_pred_8_x_acc => chi_pred_8_x_acc,
            chi_pred_8_y_pos => chi_pred_8_y_pos, chi_pred_8_y_vel => chi_pred_8_y_vel, chi_pred_8_y_acc => chi_pred_8_y_acc,
            chi_pred_8_z_pos => chi_pred_8_z_pos, chi_pred_8_z_vel => chi_pred_8_z_vel, chi_pred_8_z_acc => chi_pred_8_z_acc,
            chi_pred_9_x_pos => chi_pred_9_x_pos, chi_pred_9_x_vel => chi_pred_9_x_vel, chi_pred_9_x_acc => chi_pred_9_x_acc,
            chi_pred_9_y_pos => chi_pred_9_y_pos, chi_pred_9_y_vel => chi_pred_9_y_vel, chi_pred_9_y_acc => chi_pred_9_y_acc,
            chi_pred_9_z_pos => chi_pred_9_z_pos, chi_pred_9_z_vel => chi_pred_9_z_vel, chi_pred_9_z_acc => chi_pred_9_z_acc,
            chi_pred_10_x_pos => chi_pred_10_x_pos, chi_pred_10_x_vel => chi_pred_10_x_vel, chi_pred_10_x_acc => chi_pred_10_x_acc,
            chi_pred_10_y_pos => chi_pred_10_y_pos, chi_pred_10_y_vel => chi_pred_10_y_vel, chi_pred_10_y_acc => chi_pred_10_y_acc,
            chi_pred_10_z_pos => chi_pred_10_z_pos, chi_pred_10_z_vel => chi_pred_10_z_vel, chi_pred_10_z_acc => chi_pred_10_z_acc,
            chi_pred_11_x_pos => chi_pred_11_x_pos, chi_pred_11_x_vel => chi_pred_11_x_vel, chi_pred_11_x_acc => chi_pred_11_x_acc,
            chi_pred_11_y_pos => chi_pred_11_y_pos, chi_pred_11_y_vel => chi_pred_11_y_vel, chi_pred_11_y_acc => chi_pred_11_y_acc,
            chi_pred_11_z_pos => chi_pred_11_z_pos, chi_pred_11_z_vel => chi_pred_11_z_vel, chi_pred_11_z_acc => chi_pred_11_z_acc,
            chi_pred_12_x_pos => chi_pred_12_x_pos, chi_pred_12_x_vel => chi_pred_12_x_vel, chi_pred_12_x_acc => chi_pred_12_x_acc,
            chi_pred_12_y_pos => chi_pred_12_y_pos, chi_pred_12_y_vel => chi_pred_12_y_vel, chi_pred_12_y_acc => chi_pred_12_y_acc,
            chi_pred_12_z_pos => chi_pred_12_z_pos, chi_pred_12_z_vel => chi_pred_12_z_vel, chi_pred_12_z_acc => chi_pred_12_z_acc,
            chi_pred_13_x_pos => chi_pred_13_x_pos, chi_pred_13_x_vel => chi_pred_13_x_vel, chi_pred_13_x_acc => chi_pred_13_x_acc,
            chi_pred_13_y_pos => chi_pred_13_y_pos, chi_pred_13_y_vel => chi_pred_13_y_vel, chi_pred_13_y_acc => chi_pred_13_y_acc,
            chi_pred_13_z_pos => chi_pred_13_z_pos, chi_pred_13_z_vel => chi_pred_13_z_vel, chi_pred_13_z_acc => chi_pred_13_z_acc,
            chi_pred_14_x_pos => chi_pred_14_x_pos, chi_pred_14_x_vel => chi_pred_14_x_vel, chi_pred_14_x_acc => chi_pred_14_x_acc,
            chi_pred_14_y_pos => chi_pred_14_y_pos, chi_pred_14_y_vel => chi_pred_14_y_vel, chi_pred_14_y_acc => chi_pred_14_y_acc,
            chi_pred_14_z_pos => chi_pred_14_z_pos, chi_pred_14_z_vel => chi_pred_14_z_vel, chi_pred_14_z_acc => chi_pred_14_z_acc,
            chi_pred_15_x_pos => chi_pred_15_x_pos, chi_pred_15_x_vel => chi_pred_15_x_vel, chi_pred_15_x_acc => chi_pred_15_x_acc,
            chi_pred_15_y_pos => chi_pred_15_y_pos, chi_pred_15_y_vel => chi_pred_15_y_vel, chi_pred_15_y_acc => chi_pred_15_y_acc,
            chi_pred_15_z_pos => chi_pred_15_z_pos, chi_pred_15_z_vel => chi_pred_15_z_vel, chi_pred_15_z_acc => chi_pred_15_z_acc,
            chi_pred_16_x_pos => chi_pred_16_x_pos, chi_pred_16_x_vel => chi_pred_16_x_vel, chi_pred_16_x_acc => chi_pred_16_x_acc,
            chi_pred_16_y_pos => chi_pred_16_y_pos, chi_pred_16_y_vel => chi_pred_16_y_vel, chi_pred_16_y_acc => chi_pred_16_y_acc,
            chi_pred_16_z_pos => chi_pred_16_z_pos, chi_pred_16_z_vel => chi_pred_16_z_vel, chi_pred_16_z_acc => chi_pred_16_z_acc,
            chi_pred_17_x_pos => chi_pred_17_x_pos, chi_pred_17_x_vel => chi_pred_17_x_vel, chi_pred_17_x_acc => chi_pred_17_x_acc,
            chi_pred_17_y_pos => chi_pred_17_y_pos, chi_pred_17_y_vel => chi_pred_17_y_vel, chi_pred_17_y_acc => chi_pred_17_y_acc,
            chi_pred_17_z_pos => chi_pred_17_z_pos, chi_pred_17_z_vel => chi_pred_17_z_vel, chi_pred_17_z_acc => chi_pred_17_z_acc,
            chi_pred_18_x_pos => chi_pred_18_x_pos, chi_pred_18_x_vel => chi_pred_18_x_vel, chi_pred_18_x_acc => chi_pred_18_x_acc,
            chi_pred_18_y_pos => chi_pred_18_y_pos, chi_pred_18_y_vel => chi_pred_18_y_vel, chi_pred_18_y_acc => chi_pred_18_y_acc,
            chi_pred_18_z_pos => chi_pred_18_z_pos, chi_pred_18_z_vel => chi_pred_18_z_vel, chi_pred_18_z_acc => chi_pred_18_z_acc,
            done => pred_done
        );

    measurement_inst : sr_measurement_update_ca_3d
        port map (
            clk => clk,
            reset => reset,
            start => update_start,
            cycle_num => 0,

            z_x_meas => z_x_meas,
            z_y_meas => z_y_meas,
            z_z_meas => z_z_meas,

            x_pos_pred => x_pos_pred_buf,
            x_vel_pred => x_vel_pred_buf,
            x_acc_pred => x_acc_pred_buf,
            y_pos_pred => y_pos_pred_buf,
            y_vel_pred => y_vel_pred_buf,
            y_acc_pred => y_acc_pred_buf,
            z_pos_pred => z_pos_pred_buf,
            z_vel_pred => z_vel_pred_buf,
            z_acc_pred => z_acc_pred_buf,

            l11_pred => l11_pred_buf,
            l21_pred => l21_pred_buf, l22_pred => l22_pred_buf,
            l31_pred => l31_pred_buf, l32_pred => l32_pred_buf, l33_pred => l33_pred_buf,
            l41_pred => l41_pred_buf, l42_pred => l42_pred_buf, l43_pred => l43_pred_buf, l44_pred => l44_pred_buf,
            l51_pred => l51_pred_buf, l52_pred => l52_pred_buf, l53_pred => l53_pred_buf, l54_pred => l54_pred_buf, l55_pred => l55_pred_buf,
            l61_pred => l61_pred_buf, l62_pred => l62_pred_buf, l63_pred => l63_pred_buf, l64_pred => l64_pred_buf, l65_pred => l65_pred_buf, l66_pred => l66_pred_buf,
            l71_pred => l71_pred_buf, l72_pred => l72_pred_buf, l73_pred => l73_pred_buf, l74_pred => l74_pred_buf, l75_pred => l75_pred_buf, l76_pred => l76_pred_buf, l77_pred => l77_pred_buf,
            l81_pred => l81_pred_buf, l82_pred => l82_pred_buf, l83_pred => l83_pred_buf, l84_pred => l84_pred_buf, l85_pred => l85_pred_buf, l86_pred => l86_pred_buf, l87_pred => l87_pred_buf, l88_pred => l88_pred_buf,
            l91_pred => l91_pred_buf, l92_pred => l92_pred_buf, l93_pred => l93_pred_buf, l94_pred => l94_pred_buf, l95_pred => l95_pred_buf, l96_pred => l96_pred_buf, l97_pred => l97_pred_buf, l98_pred => l98_pred_buf, l99_pred => l99_pred_buf,

            chi_pred_0_x_pos => chi_pred_0_x_pos, chi_pred_0_x_vel => chi_pred_0_x_vel, chi_pred_0_x_acc => chi_pred_0_x_acc,
            chi_pred_0_y_pos => chi_pred_0_y_pos, chi_pred_0_y_vel => chi_pred_0_y_vel, chi_pred_0_y_acc => chi_pred_0_y_acc,
            chi_pred_0_z_pos => chi_pred_0_z_pos, chi_pred_0_z_vel => chi_pred_0_z_vel, chi_pred_0_z_acc => chi_pred_0_z_acc,
            chi_pred_1_x_pos => chi_pred_1_x_pos, chi_pred_1_x_vel => chi_pred_1_x_vel, chi_pred_1_x_acc => chi_pred_1_x_acc,
            chi_pred_1_y_pos => chi_pred_1_y_pos, chi_pred_1_y_vel => chi_pred_1_y_vel, chi_pred_1_y_acc => chi_pred_1_y_acc,
            chi_pred_1_z_pos => chi_pred_1_z_pos, chi_pred_1_z_vel => chi_pred_1_z_vel, chi_pred_1_z_acc => chi_pred_1_z_acc,
            chi_pred_2_x_pos => chi_pred_2_x_pos, chi_pred_2_x_vel => chi_pred_2_x_vel, chi_pred_2_x_acc => chi_pred_2_x_acc,
            chi_pred_2_y_pos => chi_pred_2_y_pos, chi_pred_2_y_vel => chi_pred_2_y_vel, chi_pred_2_y_acc => chi_pred_2_y_acc,
            chi_pred_2_z_pos => chi_pred_2_z_pos, chi_pred_2_z_vel => chi_pred_2_z_vel, chi_pred_2_z_acc => chi_pred_2_z_acc,
            chi_pred_3_x_pos => chi_pred_3_x_pos, chi_pred_3_x_vel => chi_pred_3_x_vel, chi_pred_3_x_acc => chi_pred_3_x_acc,
            chi_pred_3_y_pos => chi_pred_3_y_pos, chi_pred_3_y_vel => chi_pred_3_y_vel, chi_pred_3_y_acc => chi_pred_3_y_acc,
            chi_pred_3_z_pos => chi_pred_3_z_pos, chi_pred_3_z_vel => chi_pred_3_z_vel, chi_pred_3_z_acc => chi_pred_3_z_acc,
            chi_pred_4_x_pos => chi_pred_4_x_pos, chi_pred_4_x_vel => chi_pred_4_x_vel, chi_pred_4_x_acc => chi_pred_4_x_acc,
            chi_pred_4_y_pos => chi_pred_4_y_pos, chi_pred_4_y_vel => chi_pred_4_y_vel, chi_pred_4_y_acc => chi_pred_4_y_acc,
            chi_pred_4_z_pos => chi_pred_4_z_pos, chi_pred_4_z_vel => chi_pred_4_z_vel, chi_pred_4_z_acc => chi_pred_4_z_acc,
            chi_pred_5_x_pos => chi_pred_5_x_pos, chi_pred_5_x_vel => chi_pred_5_x_vel, chi_pred_5_x_acc => chi_pred_5_x_acc,
            chi_pred_5_y_pos => chi_pred_5_y_pos, chi_pred_5_y_vel => chi_pred_5_y_vel, chi_pred_5_y_acc => chi_pred_5_y_acc,
            chi_pred_5_z_pos => chi_pred_5_z_pos, chi_pred_5_z_vel => chi_pred_5_z_vel, chi_pred_5_z_acc => chi_pred_5_z_acc,
            chi_pred_6_x_pos => chi_pred_6_x_pos, chi_pred_6_x_vel => chi_pred_6_x_vel, chi_pred_6_x_acc => chi_pred_6_x_acc,
            chi_pred_6_y_pos => chi_pred_6_y_pos, chi_pred_6_y_vel => chi_pred_6_y_vel, chi_pred_6_y_acc => chi_pred_6_y_acc,
            chi_pred_6_z_pos => chi_pred_6_z_pos, chi_pred_6_z_vel => chi_pred_6_z_vel, chi_pred_6_z_acc => chi_pred_6_z_acc,
            chi_pred_7_x_pos => chi_pred_7_x_pos, chi_pred_7_x_vel => chi_pred_7_x_vel, chi_pred_7_x_acc => chi_pred_7_x_acc,
            chi_pred_7_y_pos => chi_pred_7_y_pos, chi_pred_7_y_vel => chi_pred_7_y_vel, chi_pred_7_y_acc => chi_pred_7_y_acc,
            chi_pred_7_z_pos => chi_pred_7_z_pos, chi_pred_7_z_vel => chi_pred_7_z_vel, chi_pred_7_z_acc => chi_pred_7_z_acc,
            chi_pred_8_x_pos => chi_pred_8_x_pos, chi_pred_8_x_vel => chi_pred_8_x_vel, chi_pred_8_x_acc => chi_pred_8_x_acc,
            chi_pred_8_y_pos => chi_pred_8_y_pos, chi_pred_8_y_vel => chi_pred_8_y_vel, chi_pred_8_y_acc => chi_pred_8_y_acc,
            chi_pred_8_z_pos => chi_pred_8_z_pos, chi_pred_8_z_vel => chi_pred_8_z_vel, chi_pred_8_z_acc => chi_pred_8_z_acc,
            chi_pred_9_x_pos => chi_pred_9_x_pos, chi_pred_9_x_vel => chi_pred_9_x_vel, chi_pred_9_x_acc => chi_pred_9_x_acc,
            chi_pred_9_y_pos => chi_pred_9_y_pos, chi_pred_9_y_vel => chi_pred_9_y_vel, chi_pred_9_y_acc => chi_pred_9_y_acc,
            chi_pred_9_z_pos => chi_pred_9_z_pos, chi_pred_9_z_vel => chi_pred_9_z_vel, chi_pred_9_z_acc => chi_pred_9_z_acc,
            chi_pred_10_x_pos => chi_pred_10_x_pos, chi_pred_10_x_vel => chi_pred_10_x_vel, chi_pred_10_x_acc => chi_pred_10_x_acc,
            chi_pred_10_y_pos => chi_pred_10_y_pos, chi_pred_10_y_vel => chi_pred_10_y_vel, chi_pred_10_y_acc => chi_pred_10_y_acc,
            chi_pred_10_z_pos => chi_pred_10_z_pos, chi_pred_10_z_vel => chi_pred_10_z_vel, chi_pred_10_z_acc => chi_pred_10_z_acc,
            chi_pred_11_x_pos => chi_pred_11_x_pos, chi_pred_11_x_vel => chi_pred_11_x_vel, chi_pred_11_x_acc => chi_pred_11_x_acc,
            chi_pred_11_y_pos => chi_pred_11_y_pos, chi_pred_11_y_vel => chi_pred_11_y_vel, chi_pred_11_y_acc => chi_pred_11_y_acc,
            chi_pred_11_z_pos => chi_pred_11_z_pos, chi_pred_11_z_vel => chi_pred_11_z_vel, chi_pred_11_z_acc => chi_pred_11_z_acc,
            chi_pred_12_x_pos => chi_pred_12_x_pos, chi_pred_12_x_vel => chi_pred_12_x_vel, chi_pred_12_x_acc => chi_pred_12_x_acc,
            chi_pred_12_y_pos => chi_pred_12_y_pos, chi_pred_12_y_vel => chi_pred_12_y_vel, chi_pred_12_y_acc => chi_pred_12_y_acc,
            chi_pred_12_z_pos => chi_pred_12_z_pos, chi_pred_12_z_vel => chi_pred_12_z_vel, chi_pred_12_z_acc => chi_pred_12_z_acc,
            chi_pred_13_x_pos => chi_pred_13_x_pos, chi_pred_13_x_vel => chi_pred_13_x_vel, chi_pred_13_x_acc => chi_pred_13_x_acc,
            chi_pred_13_y_pos => chi_pred_13_y_pos, chi_pred_13_y_vel => chi_pred_13_y_vel, chi_pred_13_y_acc => chi_pred_13_y_acc,
            chi_pred_13_z_pos => chi_pred_13_z_pos, chi_pred_13_z_vel => chi_pred_13_z_vel, chi_pred_13_z_acc => chi_pred_13_z_acc,
            chi_pred_14_x_pos => chi_pred_14_x_pos, chi_pred_14_x_vel => chi_pred_14_x_vel, chi_pred_14_x_acc => chi_pred_14_x_acc,
            chi_pred_14_y_pos => chi_pred_14_y_pos, chi_pred_14_y_vel => chi_pred_14_y_vel, chi_pred_14_y_acc => chi_pred_14_y_acc,
            chi_pred_14_z_pos => chi_pred_14_z_pos, chi_pred_14_z_vel => chi_pred_14_z_vel, chi_pred_14_z_acc => chi_pred_14_z_acc,
            chi_pred_15_x_pos => chi_pred_15_x_pos, chi_pred_15_x_vel => chi_pred_15_x_vel, chi_pred_15_x_acc => chi_pred_15_x_acc,
            chi_pred_15_y_pos => chi_pred_15_y_pos, chi_pred_15_y_vel => chi_pred_15_y_vel, chi_pred_15_y_acc => chi_pred_15_y_acc,
            chi_pred_15_z_pos => chi_pred_15_z_pos, chi_pred_15_z_vel => chi_pred_15_z_vel, chi_pred_15_z_acc => chi_pred_15_z_acc,
            chi_pred_16_x_pos => chi_pred_16_x_pos, chi_pred_16_x_vel => chi_pred_16_x_vel, chi_pred_16_x_acc => chi_pred_16_x_acc,
            chi_pred_16_y_pos => chi_pred_16_y_pos, chi_pred_16_y_vel => chi_pred_16_y_vel, chi_pred_16_y_acc => chi_pred_16_y_acc,
            chi_pred_16_z_pos => chi_pred_16_z_pos, chi_pred_16_z_vel => chi_pred_16_z_vel, chi_pred_16_z_acc => chi_pred_16_z_acc,
            chi_pred_17_x_pos => chi_pred_17_x_pos, chi_pred_17_x_vel => chi_pred_17_x_vel, chi_pred_17_x_acc => chi_pred_17_x_acc,
            chi_pred_17_y_pos => chi_pred_17_y_pos, chi_pred_17_y_vel => chi_pred_17_y_vel, chi_pred_17_y_acc => chi_pred_17_y_acc,
            chi_pred_17_z_pos => chi_pred_17_z_pos, chi_pred_17_z_vel => chi_pred_17_z_vel, chi_pred_17_z_acc => chi_pred_17_z_acc,
            chi_pred_18_x_pos => chi_pred_18_x_pos, chi_pred_18_x_vel => chi_pred_18_x_vel, chi_pred_18_x_acc => chi_pred_18_x_acc,
            chi_pred_18_y_pos => chi_pred_18_y_pos, chi_pred_18_y_vel => chi_pred_18_y_vel, chi_pred_18_y_acc => chi_pred_18_y_acc,
            chi_pred_18_z_pos => chi_pred_18_z_pos, chi_pred_18_z_vel => chi_pred_18_z_vel, chi_pred_18_z_acc => chi_pred_18_z_acc,

            x_pos_upd => x_pos_upd_buf,
            x_vel_upd => x_vel_upd_buf,
            x_acc_upd => x_acc_upd_buf,
            y_pos_upd => y_pos_upd_buf,
            y_vel_upd => y_vel_upd_buf,
            y_acc_upd => y_acc_upd_buf,
            z_pos_upd => z_pos_upd_buf,
            z_vel_upd => z_vel_upd_buf,
            z_acc_upd => z_acc_upd_buf,

            l11_upd => l11_upd_buf,
            l21_upd => l21_upd_buf, l22_upd => l22_upd_buf,
            l31_upd => l31_upd_buf, l32_upd => l32_upd_buf, l33_upd => l33_upd_buf,
            l41_upd => l41_upd_buf, l42_upd => l42_upd_buf, l43_upd => l43_upd_buf, l44_upd => l44_upd_buf,
            l51_upd => l51_upd_buf, l52_upd => l52_upd_buf, l53_upd => l53_upd_buf, l54_upd => l54_upd_buf, l55_upd => l55_upd_buf,
            l61_upd => l61_upd_buf, l62_upd => l62_upd_buf, l63_upd => l63_upd_buf, l64_upd => l64_upd_buf, l65_upd => l65_upd_buf, l66_upd => l66_upd_buf,
            l71_upd => l71_upd_buf, l72_upd => l72_upd_buf, l73_upd => l73_upd_buf, l74_upd => l74_upd_buf, l75_upd => l75_upd_buf, l76_upd => l76_upd_buf, l77_upd => l77_upd_buf,
            l81_upd => l81_upd_buf, l82_upd => l82_upd_buf, l83_upd => l83_upd_buf, l84_upd => l84_upd_buf, l85_upd => l85_upd_buf, l86_upd => l86_upd_buf, l87_upd => l87_upd_buf, l88_upd => l88_upd_buf,
            l91_upd => l91_upd_buf, l92_upd => l92_upd_buf, l93_upd => l93_upd_buf, l94_upd => l94_upd_buf, l95_upd => l95_upd_buf, l96_upd => l96_upd_buf, l97_upd => l97_upd_buf, l98_upd => l98_upd_buf, l99_upd => l99_upd_buf,

            nu_x_out => nu_x_buf, nu_y_out => nu_y_buf, nu_z_out => nu_z_buf,
            s11_out => s11_buf, s22_out => s22_buf, s33_out => s33_buf,
            done => update_done
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                first_cycle <= '1';
                pred_start <= '0';
                update_start <= '0';
                done <= '0';
            else
                case state is
                    when IDLE =>
                        done <= '0';
                        pred_start <= '0';
                        update_start <= '0';
                        if start = '1' then
                            if first_cycle = '1' then
                                state <= INIT_STATE;
                            elsif inject_en = '1' then
                                state <= INIT_STATE;
                            else
                                state <= RUN_PREDICTION;
                            end if;
                        end if;

                    when INIT_STATE =>
                        report "SR_UKF_SUPREME_CA: INIT_STATE" & LF &
                               "  first_cycle = " & std_logic'image(first_cycle) & LF &
                               "  z_x_meas = " & integer'image(to_integer(z_x_meas)) & LF &
                               "  z_y_meas = " & integer'image(to_integer(z_y_meas));

                        if first_cycle = '1' then

                            l11_state <= L11_INIT;
                            l22_state <= L22_INIT;
                            l33_state <= L33_INIT;
                            l44_state <= L44_INIT;
                            l55_state <= L55_INIT;
                            l66_state <= L66_INIT;
                            l77_state <= L77_INIT;
                            l88_state <= L88_INIT;
                            l99_state <= L99_INIT;

                            x_pos_state <= z_x_meas;
                            x_vel_state <= (others => '0');
                            x_acc_state <= (others => '0');
                            y_pos_state <= z_y_meas;
                            y_vel_state <= (others => '0');
                            y_acc_state <= (others => '0');
                            z_pos_state <= z_z_meas;
                            z_vel_state <= (others => '0');
                            z_acc_state <= (others => '0');
                            first_cycle <= '0';
                        elsif inject_en = '1' then

                            x_pos_state <= inj_x_pos;
                            x_vel_state <= inj_x_vel;
                            x_acc_state <= inj_x_acc;
                            y_pos_state <= inj_y_pos;
                            y_vel_state <= inj_y_vel;
                            y_acc_state <= inj_y_acc;
                            z_pos_state <= inj_z_pos;
                            z_vel_state <= inj_z_vel;
                            z_acc_state <= inj_z_acc;

                            l11_state <= inj_l11;
                            l22_state <= inj_l22;
                            l33_state <= inj_l33;
                            l44_state <= inj_l44;
                            l55_state <= inj_l55;
                            l66_state <= inj_l66;
                            l77_state <= inj_l77;
                            l88_state <= inj_l88;
                            l99_state <= inj_l99;

                            l21_state <= (others => '0'); l31_state <= (others => '0'); l32_state <= (others => '0');
                            l41_state <= (others => '0'); l42_state <= (others => '0'); l43_state <= (others => '0');
                            l51_state <= (others => '0'); l52_state <= (others => '0'); l53_state <= (others => '0'); l54_state <= (others => '0');
                            l61_state <= (others => '0'); l62_state <= (others => '0'); l63_state <= (others => '0'); l64_state <= (others => '0'); l65_state <= (others => '0');
                            l71_state <= (others => '0'); l72_state <= (others => '0'); l73_state <= (others => '0'); l74_state <= (others => '0'); l75_state <= (others => '0'); l76_state <= (others => '0');
                            l81_state <= (others => '0'); l82_state <= (others => '0'); l83_state <= (others => '0'); l84_state <= (others => '0'); l85_state <= (others => '0'); l86_state <= (others => '0'); l87_state <= (others => '0');
                            l91_state <= (others => '0'); l92_state <= (others => '0'); l93_state <= (others => '0'); l94_state <= (others => '0'); l95_state <= (others => '0'); l96_state <= (others => '0'); l97_state <= (others => '0'); l98_state <= (others => '0');
                        end if;

                        state <= WAIT_INIT;

                    when WAIT_INIT =>
                        report "SR_UKF_SUPREME_CA: WAIT_INIT - l11_state=" & integer'image(to_integer(l11_state));
                        state <= RUN_PREDICTION;

                    when RUN_PREDICTION =>
                        report "SR_UKF_SUPREME_CA: RUN_PREDICTION" & LF &
                               "  l44_state=" & integer'image(to_integer(l44_state)) & LF &
                               "  l55_state=" & integer'image(to_integer(l55_state)) & LF &
                               "  l66_state=" & integer'image(to_integer(l66_state));
                        pred_start <= '1';
                        state <= WAIT_PREDICTION;

                    when WAIT_PREDICTION =>
                        pred_start <= '0';
                        if pred_done = '1' then
                            state <= RUN_UPDATE;
                        end if;

                    when RUN_UPDATE =>
                        report "L_PRED: l44=" & integer'image(to_integer(l44_pred_buf)) &
                               " l55=" & integer'image(to_integer(l55_pred_buf)) &
                               " l66=" & integer'image(to_integer(l66_pred_buf));
                        update_start <= '1';
                        state <= WAIT_UPDATE;

                    when WAIT_UPDATE =>
                        update_start <= '0';
                        if update_done = '1' then
                            report "L_UPD: l44=" & integer'image(to_integer(l44_upd_buf)) &
                                   " l55=" & integer'image(to_integer(l55_upd_buf)) &
                                   " l66=" & integer'image(to_integer(l66_upd_buf));

                            x_pos_state <= x_pos_upd_buf;
                            x_vel_state <= x_vel_upd_buf;
                            x_acc_state <= x_acc_upd_buf;
                            y_pos_state <= y_pos_upd_buf;
                            y_vel_state <= y_vel_upd_buf;
                            y_acc_state <= y_acc_upd_buf;
                            z_pos_state <= z_pos_upd_buf;
                            z_vel_state <= z_vel_upd_buf;
                            z_acc_state <= z_acc_upd_buf;

                            l11_state <= l11_upd_buf;

                            l21_state <= l21_upd_buf;
                            l22_state <= l22_upd_buf;

                            l31_state <= l31_upd_buf;
                            l32_state <= l32_upd_buf;
                            l33_state <= l33_upd_buf;

                            l41_state <= l41_upd_buf;
                            l42_state <= l42_upd_buf;
                            l43_state <= l43_upd_buf;
                            l44_state <= l44_upd_buf;

                            l51_state <= l51_upd_buf;
                            l52_state <= l52_upd_buf;
                            l53_state <= l53_upd_buf;
                            l54_state <= l54_upd_buf;
                            l55_state <= l55_upd_buf;

                            l61_state <= l61_upd_buf;
                            l62_state <= l62_upd_buf;
                            l63_state <= l63_upd_buf;
                            l64_state <= l64_upd_buf;
                            l65_state <= l65_upd_buf;
                            l66_state <= l66_upd_buf;

                            l71_state <= l71_upd_buf;
                            l72_state <= l72_upd_buf;
                            l73_state <= l73_upd_buf;
                            l74_state <= l74_upd_buf;
                            l75_state <= l75_upd_buf;
                            l76_state <= l76_upd_buf;
                            l77_state <= l77_upd_buf;

                            l81_state <= l81_upd_buf;
                            l82_state <= l82_upd_buf;
                            l83_state <= l83_upd_buf;
                            l84_state <= l84_upd_buf;
                            l85_state <= l85_upd_buf;
                            l86_state <= l86_upd_buf;
                            l87_state <= l87_upd_buf;
                            l88_state <= l88_upd_buf;

                            l91_state <= l91_upd_buf;
                            l92_state <= l92_upd_buf;
                            l93_state <= l93_upd_buf;
                            l94_state <= l94_upd_buf;
                            l95_state <= l95_upd_buf;
                            l96_state <= l96_upd_buf;
                            l97_state <= l97_upd_buf;
                            l98_state <= l98_upd_buf;
                            l99_state <= l99_upd_buf;

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
