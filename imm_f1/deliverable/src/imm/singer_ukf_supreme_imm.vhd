library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity singer_ukf_supreme_imm is
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
end singer_ukf_supreme_imm;
architecture Behavioral of singer_ukf_supreme_imm is

    component prediction_phase_p_3d is
        port (
            clk, rst, start : in std_logic;
            x_pos_current, x_vel_current, x_acc_current : in signed(47 downto 0);
            y_pos_current, y_vel_current, y_acc_current : in signed(47 downto 0);
            z_pos_current, z_vel_current, z_acc_current : in signed(47 downto 0);
            p11_current, p12_current, p13_current, p14_current, p15_current, p16_current, p17_current, p18_current, p19_current : in signed(47 downto 0);
            p22_current, p23_current, p24_current, p25_current, p26_current, p27_current, p28_current, p29_current : in signed(47 downto 0);
            p33_current, p34_current, p35_current, p36_current, p37_current, p38_current, p39_current : in signed(47 downto 0);
            p44_current, p45_current, p46_current, p47_current, p48_current, p49_current : in signed(47 downto 0);
            p55_current, p56_current, p57_current, p58_current, p59_current : in signed(47 downto 0);
            p66_current, p67_current, p68_current, p69_current : in signed(47 downto 0);
            p77_current, p78_current, p79_current : in signed(47 downto 0);
            p88_current, p89_current : in signed(47 downto 0);
            p99_current : in signed(47 downto 0);
            x_pos_pred, x_vel_pred, x_acc_pred : out signed(47 downto 0);
            y_pos_pred, y_vel_pred, y_acc_pred : out signed(47 downto 0);
            z_pos_pred, z_vel_pred, z_acc_pred : out signed(47 downto 0);
            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred : out signed(47 downto 0);
            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred : out signed(47 downto 0);
            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred : out signed(47 downto 0);
            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred : out signed(47 downto 0);
            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred : out signed(47 downto 0);
            p66_pred, p67_pred, p68_pred, p69_pred : out signed(47 downto 0);
            p77_pred, p78_pred, p79_pred : out signed(47 downto 0);
            p88_pred, p89_pred : out signed(47 downto 0);
            p99_pred : out signed(47 downto 0);
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

    component singer_measurement_update_imm is
        port (
            clk, start : in std_logic;
            z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);
            x_pos_pred, x_vel_pred, x_acc_pred : in signed(47 downto 0);
            y_pos_pred, y_vel_pred, y_acc_pred : in signed(47 downto 0);
            z_pos_pred, z_vel_pred, z_acc_pred : in signed(47 downto 0);
            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred : in signed(47 downto 0);
            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred : in signed(47 downto 0);
            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred : in signed(47 downto 0);
            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred : in signed(47 downto 0);
            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred : in signed(47 downto 0);
            p66_pred, p67_pred, p68_pred, p69_pred : in signed(47 downto 0);
            p77_pred, p78_pred, p79_pred : in signed(47 downto 0);
            p88_pred, p89_pred : in signed(47 downto 0);
            p99_pred : in signed(47 downto 0);
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
            p11_upd, p12_upd, p13_upd, p14_upd, p15_upd, p16_upd, p17_upd, p18_upd, p19_upd : buffer signed(47 downto 0);
            p22_upd, p23_upd, p24_upd, p25_upd, p26_upd, p27_upd, p28_upd, p29_upd : buffer signed(47 downto 0);
            p33_upd, p34_upd, p35_upd, p36_upd, p37_upd, p38_upd, p39_upd : buffer signed(47 downto 0);
            p44_upd, p45_upd, p46_upd, p47_upd, p48_upd, p49_upd : buffer signed(47 downto 0);
            p55_upd, p56_upd, p57_upd, p58_upd, p59_upd : buffer signed(47 downto 0);
            p66_upd, p67_upd, p68_upd, p69_upd : buffer signed(47 downto 0);
            p77_upd, p78_upd, p79_upd : buffer signed(47 downto 0);
            p88_upd, p89_upd : buffer signed(47 downto 0);
            p99_upd : buffer signed(47 downto 0);
            nu_x_out, nu_y_out, nu_z_out : out signed(47 downto 0);
            s11_out, s22_out, s33_out : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    constant P11_INIT : signed(47 downto 0) := signed'(X"00000A000000");
    constant P22_INIT : signed(47 downto 0) := signed'(X"000064000000");
    constant P33_INIT : signed(47 downto 0) := signed'(X"000000028F5C");
    constant P44_INIT : signed(47 downto 0) := signed'(X"00000A000000");
    constant P55_INIT : signed(47 downto 0) := signed'(X"000064000000");
    constant P66_INIT : signed(47 downto 0) := signed'(X"000000028F5C");
    constant P77_INIT : signed(47 downto 0) := signed'(X"00000A000000");
    constant P88_INIT : signed(47 downto 0) := signed'(X"000064000000");
    constant P99_INIT : signed(47 downto 0) := signed'(X"000000028F5C");

    type state_type is (IDLE, INIT_STATE, WAIT_INIT, RUN_PREDICTION, WAIT_PREDICTION,
                        RUN_UPDATE, WAIT_UPDATE, FINISHED);
    signal state : state_type := IDLE;

    signal pred_start, pred_done : std_logic := '0';
    signal update_start, update_done : std_logic := '0';
    signal first_cycle : std_logic := '1';

    signal inject_en_latched : std_logic := '0';
    signal inject_state_only_latched : std_logic := '0';

    signal x_pos_state, x_vel_state, x_acc_state : signed(47 downto 0) := (others => '0');
    signal y_pos_state, y_vel_state, y_acc_state : signed(47 downto 0) := (others => '0');
    signal z_pos_state, z_vel_state, z_acc_state : signed(47 downto 0) := (others => '0');

    signal p11_state, p12_state, p13_state, p14_state, p15_state, p16_state, p17_state, p18_state, p19_state : signed(47 downto 0) := (others => '0');
    signal p22_state, p23_state, p24_state, p25_state, p26_state, p27_state, p28_state, p29_state : signed(47 downto 0) := (others => '0');
    signal p33_state, p34_state, p35_state, p36_state, p37_state, p38_state, p39_state : signed(47 downto 0) := (others => '0');
    signal p44_state, p45_state, p46_state, p47_state, p48_state, p49_state : signed(47 downto 0) := (others => '0');
    signal p55_state, p56_state, p57_state, p58_state, p59_state : signed(47 downto 0) := (others => '0');
    signal p66_state, p67_state, p68_state, p69_state : signed(47 downto 0) := (others => '0');
    signal p77_state, p78_state, p79_state : signed(47 downto 0) := (others => '0');
    signal p88_state, p89_state : signed(47 downto 0) := (others => '0');
    signal p99_state : signed(47 downto 0) := (others => '0');

    signal x_pos_pred_buf, x_vel_pred_buf, x_acc_pred_buf : signed(47 downto 0) := (others => '0');
    signal y_pos_pred_buf, y_vel_pred_buf, y_acc_pred_buf : signed(47 downto 0) := (others => '0');
    signal z_pos_pred_buf, z_vel_pred_buf, z_acc_pred_buf : signed(47 downto 0) := (others => '0');

    signal p11_pred_buf, p12_pred_buf, p13_pred_buf, p14_pred_buf, p15_pred_buf, p16_pred_buf, p17_pred_buf, p18_pred_buf, p19_pred_buf : signed(47 downto 0) := (others => '0');
    signal p22_pred_buf, p23_pred_buf, p24_pred_buf, p25_pred_buf, p26_pred_buf, p27_pred_buf, p28_pred_buf, p29_pred_buf : signed(47 downto 0) := (others => '0');
    signal p33_pred_buf, p34_pred_buf, p35_pred_buf, p36_pred_buf, p37_pred_buf, p38_pred_buf, p39_pred_buf : signed(47 downto 0) := (others => '0');
    signal p44_pred_buf, p45_pred_buf, p46_pred_buf, p47_pred_buf, p48_pred_buf, p49_pred_buf : signed(47 downto 0) := (others => '0');
    signal p55_pred_buf, p56_pred_buf, p57_pred_buf, p58_pred_buf, p59_pred_buf : signed(47 downto 0) := (others => '0');
    signal p66_pred_buf, p67_pred_buf, p68_pred_buf, p69_pred_buf : signed(47 downto 0) := (others => '0');
    signal p77_pred_buf, p78_pred_buf, p79_pred_buf : signed(47 downto 0) := (others => '0');
    signal p88_pred_buf, p89_pred_buf : signed(47 downto 0) := (others => '0');
    signal p99_pred_buf : signed(47 downto 0) := (others => '0');

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

    signal nu_x_sig, nu_y_sig, nu_z_sig : signed(47 downto 0) := (others => '0');
    signal s11_sig, s22_sig, s33_sig : signed(47 downto 0) := (others => '0');

    signal p11_upd_buf, p12_upd_buf, p13_upd_buf, p14_upd_buf, p15_upd_buf, p16_upd_buf, p17_upd_buf, p18_upd_buf, p19_upd_buf : signed(47 downto 0) := (others => '0');
    signal p22_upd_buf, p23_upd_buf, p24_upd_buf, p25_upd_buf, p26_upd_buf, p27_upd_buf, p28_upd_buf, p29_upd_buf : signed(47 downto 0) := (others => '0');
    signal p33_upd_buf, p34_upd_buf, p35_upd_buf, p36_upd_buf, p37_upd_buf, p38_upd_buf, p39_upd_buf : signed(47 downto 0) := (others => '0');
    signal p44_upd_buf, p45_upd_buf, p46_upd_buf, p47_upd_buf, p48_upd_buf, p49_upd_buf : signed(47 downto 0) := (others => '0');
    signal p55_upd_buf, p56_upd_buf, p57_upd_buf, p58_upd_buf, p59_upd_buf : signed(47 downto 0) := (others => '0');
    signal p66_upd_buf, p67_upd_buf, p68_upd_buf, p69_upd_buf : signed(47 downto 0) := (others => '0');
    signal p77_upd_buf, p78_upd_buf, p79_upd_buf : signed(47 downto 0) := (others => '0');
    signal p88_upd_buf, p89_upd_buf : signed(47 downto 0) := (others => '0');
    signal p99_upd_buf : signed(47 downto 0) := (others => '0');

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

    x_pos_uncertainty <= p11_state;
    x_vel_uncertainty <= p22_state;
    x_acc_uncertainty <= p33_state;
    y_pos_uncertainty <= p44_state;
    y_vel_uncertainty <= p55_state;
    y_acc_uncertainty <= p66_state;
    z_pos_uncertainty <= p77_state;
    z_vel_uncertainty <= p88_state;
    z_acc_uncertainty <= p99_state;

    prediction_inst : prediction_phase_p_3d
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

            p11_current => p11_state, p12_current => p12_state, p13_current => p13_state, p14_current => p14_state, p15_current => p15_state, p16_current => p16_state, p17_current => p17_state, p18_current => p18_state, p19_current => p19_state,
            p22_current => p22_state, p23_current => p23_state, p24_current => p24_state, p25_current => p25_state, p26_current => p26_state, p27_current => p27_state, p28_current => p28_state, p29_current => p29_state,
            p33_current => p33_state, p34_current => p34_state, p35_current => p35_state, p36_current => p36_state, p37_current => p37_state, p38_current => p38_state, p39_current => p39_state,
            p44_current => p44_state, p45_current => p45_state, p46_current => p46_state, p47_current => p47_state, p48_current => p48_state, p49_current => p49_state,
            p55_current => p55_state, p56_current => p56_state, p57_current => p57_state, p58_current => p58_state, p59_current => p59_state,
            p66_current => p66_state, p67_current => p67_state, p68_current => p68_state, p69_current => p69_state,
            p77_current => p77_state, p78_current => p78_state, p79_current => p79_state,
            p88_current => p88_state, p89_current => p89_state,
            p99_current => p99_state,

            x_pos_pred => x_pos_pred_buf,
            x_vel_pred => x_vel_pred_buf,
            x_acc_pred => x_acc_pred_buf,
            y_pos_pred => y_pos_pred_buf,
            y_vel_pred => y_vel_pred_buf,
            y_acc_pred => y_acc_pred_buf,
            z_pos_pred => z_pos_pred_buf,
            z_vel_pred => z_vel_pred_buf,
            z_acc_pred => z_acc_pred_buf,

            p11_pred => p11_pred_buf, p12_pred => p12_pred_buf, p13_pred => p13_pred_buf, p14_pred => p14_pred_buf, p15_pred => p15_pred_buf, p16_pred => p16_pred_buf, p17_pred => p17_pred_buf, p18_pred => p18_pred_buf, p19_pred => p19_pred_buf,
            p22_pred => p22_pred_buf, p23_pred => p23_pred_buf, p24_pred => p24_pred_buf, p25_pred => p25_pred_buf, p26_pred => p26_pred_buf, p27_pred => p27_pred_buf, p28_pred => p28_pred_buf, p29_pred => p29_pred_buf,
            p33_pred => p33_pred_buf, p34_pred => p34_pred_buf, p35_pred => p35_pred_buf, p36_pred => p36_pred_buf, p37_pred => p37_pred_buf, p38_pred => p38_pred_buf, p39_pred => p39_pred_buf,
            p44_pred => p44_pred_buf, p45_pred => p45_pred_buf, p46_pred => p46_pred_buf, p47_pred => p47_pred_buf, p48_pred => p48_pred_buf, p49_pred => p49_pred_buf,
            p55_pred => p55_pred_buf, p56_pred => p56_pred_buf, p57_pred => p57_pred_buf, p58_pred => p58_pred_buf, p59_pred => p59_pred_buf,
            p66_pred => p66_pred_buf, p67_pred => p67_pred_buf, p68_pred => p68_pred_buf, p69_pred => p69_pred_buf,
            p77_pred => p77_pred_buf, p78_pred => p78_pred_buf, p79_pred => p79_pred_buf,
            p88_pred => p88_pred_buf, p89_pred => p89_pred_buf,
            p99_pred => p99_pred_buf,

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

    measurement_update_inst : singer_measurement_update_imm
        port map (
            clk => clk,
            start => update_start,

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

            p11_pred => p11_pred_buf, p12_pred => p12_pred_buf, p13_pred => p13_pred_buf, p14_pred => p14_pred_buf, p15_pred => p15_pred_buf, p16_pred => p16_pred_buf, p17_pred => p17_pred_buf, p18_pred => p18_pred_buf, p19_pred => p19_pred_buf,
            p22_pred => p22_pred_buf, p23_pred => p23_pred_buf, p24_pred => p24_pred_buf, p25_pred => p25_pred_buf, p26_pred => p26_pred_buf, p27_pred => p27_pred_buf, p28_pred => p28_pred_buf, p29_pred => p29_pred_buf,
            p33_pred => p33_pred_buf, p34_pred => p34_pred_buf, p35_pred => p35_pred_buf, p36_pred => p36_pred_buf, p37_pred => p37_pred_buf, p38_pred => p38_pred_buf, p39_pred => p39_pred_buf,
            p44_pred => p44_pred_buf, p45_pred => p45_pred_buf, p46_pred => p46_pred_buf, p47_pred => p47_pred_buf, p48_pred => p48_pred_buf, p49_pred => p49_pred_buf,
            p55_pred => p55_pred_buf, p56_pred => p56_pred_buf, p57_pred => p57_pred_buf, p58_pred => p58_pred_buf, p59_pred => p59_pred_buf,
            p66_pred => p66_pred_buf, p67_pred => p67_pred_buf, p68_pred => p68_pred_buf, p69_pred => p69_pred_buf,
            p77_pred => p77_pred_buf, p78_pred => p78_pred_buf, p79_pred => p79_pred_buf,
            p88_pred => p88_pred_buf, p89_pred => p89_pred_buf,
            p99_pred => p99_pred_buf,

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

            p11_upd => p11_upd_buf, p12_upd => p12_upd_buf, p13_upd => p13_upd_buf, p14_upd => p14_upd_buf, p15_upd => p15_upd_buf, p16_upd => p16_upd_buf, p17_upd => p17_upd_buf, p18_upd => p18_upd_buf, p19_upd => p19_upd_buf,
            p22_upd => p22_upd_buf, p23_upd => p23_upd_buf, p24_upd => p24_upd_buf, p25_upd => p25_upd_buf, p26_upd => p26_upd_buf, p27_upd => p27_upd_buf, p28_upd => p28_upd_buf, p29_upd => p29_upd_buf,
            p33_upd => p33_upd_buf, p34_upd => p34_upd_buf, p35_upd => p35_upd_buf, p36_upd => p36_upd_buf, p37_upd => p37_upd_buf, p38_upd => p38_upd_buf, p39_upd => p39_upd_buf,
            p44_upd => p44_upd_buf, p45_upd => p45_upd_buf, p46_upd => p46_upd_buf, p47_upd => p47_upd_buf, p48_upd => p48_upd_buf, p49_upd => p49_upd_buf,
            p55_upd => p55_upd_buf, p56_upd => p56_upd_buf, p57_upd => p57_upd_buf, p58_upd => p58_upd_buf, p59_upd => p59_upd_buf,
            p66_upd => p66_upd_buf, p67_upd => p67_upd_buf, p68_upd => p68_upd_buf, p69_upd => p69_upd_buf,
            p77_upd => p77_upd_buf, p78_upd => p78_upd_buf, p79_upd => p79_upd_buf,
            p88_upd => p88_upd_buf, p89_upd => p89_upd_buf,
            p99_upd => p99_upd_buf,
            nu_x_out => nu_x_sig, nu_y_out => nu_y_sig, nu_z_out => nu_z_sig,
            s11_out => s11_sig, s22_out => s22_sig, s33_out => s33_sig,
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

                            inject_en_latched <= inject_en;
                            inject_state_only_latched <= inject_state_only;
                            state <= INIT_STATE;
                        end if;

                    when INIT_STATE =>
                        report "UKF_SUPREME: INIT_STATE" & LF &
                               "  first_cycle = " & std_logic'image(first_cycle) &
                               " (P99_INIT hex-suppressed)";

                        if first_cycle = '1' then

                            p11_state <= P11_INIT; p22_state <= P22_INIT; p33_state <= P33_INIT;
                            p44_state <= P44_INIT; p55_state <= P55_INIT; p66_state <= P66_INIT;
                            p77_state <= P77_INIT; p88_state <= P88_INIT; p99_state <= P99_INIT;

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
                        elsif inject_en_latched = '1' then

                            x_pos_state <= inj_x_pos; x_vel_state <= inj_x_vel; x_acc_state <= inj_x_acc;
                            y_pos_state <= inj_y_pos; y_vel_state <= inj_y_vel; y_acc_state <= inj_y_acc;
                            z_pos_state <= inj_z_pos; z_vel_state <= inj_z_vel; z_acc_state <= inj_z_acc;

                            if inject_state_only_latched = '0' then
                                p11_state <= inj_p11; p22_state <= inj_p22; p33_state <= inj_p33;
                                p44_state <= inj_p44; p55_state <= inj_p55; p66_state <= inj_p66;
                                p77_state <= inj_p77; p88_state <= inj_p88; p99_state <= inj_p99;

                                p12_state <= (others => '0'); p13_state <= (others => '0'); p14_state <= (others => '0');
                                p15_state <= (others => '0'); p16_state <= (others => '0'); p17_state <= (others => '0');
                                p18_state <= (others => '0'); p19_state <= (others => '0');
                                p23_state <= (others => '0'); p24_state <= (others => '0'); p25_state <= (others => '0');
                                p26_state <= (others => '0'); p27_state <= (others => '0'); p28_state <= (others => '0');
                                p29_state <= (others => '0');
                                p34_state <= (others => '0'); p35_state <= (others => '0'); p36_state <= (others => '0');
                                p37_state <= (others => '0'); p38_state <= (others => '0'); p39_state <= (others => '0');
                                p45_state <= (others => '0'); p46_state <= (others => '0'); p47_state <= (others => '0');
                                p48_state <= (others => '0'); p49_state <= (others => '0');
                                p56_state <= (others => '0'); p57_state <= (others => '0'); p58_state <= (others => '0');
                                p59_state <= (others => '0');
                                p67_state <= (others => '0'); p68_state <= (others => '0'); p69_state <= (others => '0');
                                p78_state <= (others => '0'); p79_state <= (others => '0');
                                p89_state <= (others => '0');
                            end if;
                        end if;

                        state <= WAIT_INIT;

                    when WAIT_INIT =>

                        report "UKF_SUPREME: WAIT_INIT (values hex-suppressed)";
                        state <= RUN_PREDICTION;

                    when RUN_PREDICTION =>
                        report "UKF_SUPREME: RUN_PREDICTION (values hex-suppressed)";
                        pred_start <= '1';
                        state <= WAIT_PREDICTION;

                    when WAIT_PREDICTION =>
                        pred_start <= '0';
                        if pred_done = '1' then
                            state <= RUN_UPDATE;
                        end if;

                    when RUN_UPDATE =>
                        report "P_PRED: (values hex-suppressed)";
                        update_start <= '1';
                        state <= WAIT_UPDATE;

                    when WAIT_UPDATE =>
                        update_start <= '0';
                        if update_done = '1' then
                            report "P_UPD: (values hex-suppressed)";

                            x_pos_state <= x_pos_upd_buf;
                            x_vel_state <= x_vel_upd_buf;
                            x_acc_state <= x_acc_upd_buf;
                            y_pos_state <= y_pos_upd_buf;
                            y_vel_state <= y_vel_upd_buf;
                            y_acc_state <= y_acc_upd_buf;
                            z_pos_state <= z_pos_upd_buf;
                            z_vel_state <= z_vel_upd_buf;
                            z_acc_state <= z_acc_upd_buf;

                            p11_state <= p11_upd_buf;
                            p22_state <= p22_upd_buf;
                            p33_state <= p33_upd_buf;
                            p44_state <= p44_upd_buf;
                            p55_state <= p55_upd_buf;
                            p66_state <= p66_upd_buf;
                            p77_state <= p77_upd_buf;
                            p88_state <= p88_upd_buf;
                            p99_state <= p99_upd_buf;

                            p12_state <= (others => '0'); p13_state <= (others => '0');
                            p14_state <= (others => '0'); p15_state <= (others => '0');
                            p16_state <= (others => '0'); p17_state <= (others => '0');
                            p18_state <= (others => '0'); p19_state <= (others => '0');
                            p23_state <= (others => '0'); p24_state <= (others => '0');
                            p25_state <= (others => '0'); p26_state <= (others => '0');
                            p27_state <= (others => '0'); p28_state <= (others => '0');
                            p29_state <= (others => '0'); p34_state <= (others => '0');
                            p35_state <= (others => '0'); p36_state <= (others => '0');
                            p37_state <= (others => '0'); p38_state <= (others => '0');
                            p39_state <= (others => '0'); p45_state <= (others => '0');
                            p46_state <= (others => '0'); p47_state <= (others => '0');
                            p48_state <= (others => '0'); p49_state <= (others => '0');
                            p56_state <= (others => '0'); p57_state <= (others => '0');
                            p58_state <= (others => '0'); p59_state <= (others => '0');
                            p67_state <= (others => '0'); p68_state <= (others => '0');
                            p69_state <= (others => '0'); p78_state <= (others => '0');
                            p79_state <= (others => '0'); p89_state <= (others => '0');

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

    nu_x_out <= nu_x_sig;
    nu_y_out <= nu_y_sig;
    nu_z_out <= nu_z_sig;
    s11_out  <= s11_sig;
    s22_out  <= s22_sig;
    s33_out  <= s33_sig;

end Behavioral;
