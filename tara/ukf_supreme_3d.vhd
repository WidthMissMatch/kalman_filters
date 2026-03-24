library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity ukf_supreme_3d is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        start : in  std_logic;
        z_x_meas : in signed(47 downto 0);
        z_y_meas : in signed(47 downto 0);
        z_z_meas : in signed(47 downto 0);
        x_pos_current : out signed(47 downto 0);
        x_vel_current : out signed(47 downto 0);
        y_pos_current : out signed(47 downto 0);
        y_vel_current : out signed(47 downto 0);
        z_pos_current : out signed(47 downto 0);
        z_vel_current : out signed(47 downto 0);
        x_pos_uncertainty : out signed(47 downto 0);
        x_vel_uncertainty : out signed(47 downto 0);
        y_pos_uncertainty : out signed(47 downto 0);
        y_vel_uncertainty : out signed(47 downto 0);
        z_pos_uncertainty : out signed(47 downto 0);
        z_vel_uncertainty : out signed(47 downto 0);
        done : out std_logic
    );
end ukf_supreme_3d;
architecture Behavioral of ukf_supreme_3d is
    component prediction_phase_3d is
        port (
            clk : in std_logic; rst : in std_logic; start : in std_logic;
            x_pos_current, x_vel_current, y_pos_current, y_vel_current, z_pos_current, z_vel_current : in signed(47 downto 0);
            p11_current, p12_current, p13_current, p14_current, p15_current, p16_current : in signed(47 downto 0);
            p22_current, p23_current, p24_current, p25_current, p26_current : in signed(47 downto 0);
            p33_current, p34_current, p35_current, p36_current : in signed(47 downto 0);
            p44_current, p45_current, p46_current : in signed(47 downto 0);
            p55_current, p56_current : in signed(47 downto 0);
            p66_current : in signed(47 downto 0);
            x_pos_pred, x_vel_pred, y_pos_pred, y_vel_pred, z_pos_pred, z_vel_pred : out signed(47 downto 0);
            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred : out signed(47 downto 0);
            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred : out signed(47 downto 0);
            p33_pred, p34_pred, p35_pred, p36_pred : out signed(47 downto 0);
            p44_pred, p45_pred, p46_pred : out signed(47 downto 0);
            p55_pred, p56_pred : out signed(47 downto 0);
            p66_pred : out signed(47 downto 0);
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
    end component;
    component measurement_update_3d is
        port (
            clk : in std_logic; start : in std_logic;
            z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);
            x_pos_pred, x_vel_pred, y_pos_pred, y_vel_pred, z_pos_pred, z_vel_pred : in signed(47 downto 0);
            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred : in signed(47 downto 0);
            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred : in signed(47 downto 0);
            p33_pred, p34_pred, p35_pred, p36_pred : in signed(47 downto 0);
            p44_pred, p45_pred, p46_pred : in signed(47 downto 0);
            p55_pred, p56_pred : in signed(47 downto 0);
            p66_pred : in signed(47 downto 0);
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
    constant P11_INIT : signed(47 downto 0) := to_signed(16777216, 48);
    constant P22_INIT : signed(47 downto 0) := to_signed(16777216, 48);
    constant P33_INIT : signed(47 downto 0) := to_signed(16777216, 48);
    constant P44_INIT : signed(47 downto 0) := to_signed(16777216, 48);
    constant P55_INIT : signed(47 downto 0) := to_signed(16777216, 48);
    constant P66_INIT : signed(47 downto 0) := to_signed(16777216, 48);
    type state_type is (IDLE, INIT_STATE, RUN_PREDICTION, WAIT_PREDICTION,
                        RUN_MEASUREMENT, WAIT_MEASUREMENT, UPDATE_STATE, FINISHED);
    signal state : state_type := IDLE;
    signal pred_start, pred_done : std_logic;
    signal meas_start, meas_done : std_logic;
    signal first_cycle : std_logic := '1';
    signal x_pos_state, x_vel_state : signed(47 downto 0) := (others => '0');
    signal y_pos_state, y_vel_state : signed(47 downto 0) := (others => '0');
    signal z_pos_state, z_vel_state : signed(47 downto 0) := (others => '0');
    signal p11_state, p12_state, p13_state, p14_state, p15_state, p16_state : signed(47 downto 0) := (others => '0');
    signal p22_state, p23_state, p24_state, p25_state, p26_state : signed(47 downto 0) := (others => '0');
    signal p33_state, p34_state, p35_state, p36_state : signed(47 downto 0) := (others => '0');
    signal p44_state, p45_state, p46_state : signed(47 downto 0) := (others => '0');
    signal p55_state, p56_state : signed(47 downto 0) := (others => '0');
    signal p66_state : signed(47 downto 0) := (others => '0');
    signal x_pos_pred, x_vel_pred, y_pos_pred, y_vel_pred, z_pos_pred, z_vel_pred : signed(47 downto 0) := (others => '0');
    signal p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred : signed(47 downto 0) := (others => '0');
    signal p22_pred, p23_pred, p24_pred, p25_pred, p26_pred : signed(47 downto 0) := (others => '0');
    signal p33_pred, p34_pred, p35_pred, p36_pred : signed(47 downto 0) := (others => '0');
    signal p44_pred, p45_pred, p46_pred : signed(47 downto 0) := (others => '0');
    signal p55_pred, p56_pred : signed(47 downto 0) := (others => '0');
    signal p66_pred : signed(47 downto 0) := (others => '0');
    signal chi_pred_0_x_pos, chi_pred_0_x_vel, chi_pred_0_y_pos, chi_pred_0_y_vel, chi_pred_0_z_pos, chi_pred_0_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_1_x_pos, chi_pred_1_x_vel, chi_pred_1_y_pos, chi_pred_1_y_vel, chi_pred_1_z_pos, chi_pred_1_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_2_x_pos, chi_pred_2_x_vel, chi_pred_2_y_pos, chi_pred_2_y_vel, chi_pred_2_z_pos, chi_pred_2_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_3_x_pos, chi_pred_3_x_vel, chi_pred_3_y_pos, chi_pred_3_y_vel, chi_pred_3_z_pos, chi_pred_3_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_4_x_pos, chi_pred_4_x_vel, chi_pred_4_y_pos, chi_pred_4_y_vel, chi_pred_4_z_pos, chi_pred_4_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_5_x_pos, chi_pred_5_x_vel, chi_pred_5_y_pos, chi_pred_5_y_vel, chi_pred_5_z_pos, chi_pred_5_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_6_x_pos, chi_pred_6_x_vel, chi_pred_6_y_pos, chi_pred_6_y_vel, chi_pred_6_z_pos, chi_pred_6_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_7_x_pos, chi_pred_7_x_vel, chi_pred_7_y_pos, chi_pred_7_y_vel, chi_pred_7_z_pos, chi_pred_7_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_8_x_pos, chi_pred_8_x_vel, chi_pred_8_y_pos, chi_pred_8_y_vel, chi_pred_8_z_pos, chi_pred_8_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_9_x_pos, chi_pred_9_x_vel, chi_pred_9_y_pos, chi_pred_9_y_vel, chi_pred_9_z_pos, chi_pred_9_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_10_x_pos, chi_pred_10_x_vel, chi_pred_10_y_pos, chi_pred_10_y_vel, chi_pred_10_z_pos, chi_pred_10_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_11_x_pos, chi_pred_11_x_vel, chi_pred_11_y_pos, chi_pred_11_y_vel, chi_pred_11_z_pos, chi_pred_11_z_vel : signed(47 downto 0) := (others => '0');
    signal chi_pred_12_x_pos, chi_pred_12_x_vel, chi_pred_12_y_pos, chi_pred_12_y_vel, chi_pred_12_z_pos, chi_pred_12_z_vel : signed(47 downto 0) := (others => '0');
    signal x_pos_upd, x_vel_upd, y_pos_upd, y_vel_upd, z_pos_upd, z_vel_upd : signed(47 downto 0) := (others => '0');
    signal p11_upd, p12_upd, p13_upd, p14_upd, p15_upd, p16_upd : signed(47 downto 0) := (others => '0');
    signal p22_upd, p23_upd, p24_upd, p25_upd, p26_upd : signed(47 downto 0) := (others => '0');
    signal p33_upd, p34_upd, p35_upd, p36_upd : signed(47 downto 0) := (others => '0');
    signal p44_upd, p45_upd, p46_upd : signed(47 downto 0) := (others => '0');
    signal p55_upd, p56_upd : signed(47 downto 0) := (others => '0');
    signal p66_upd : signed(47 downto 0) := (others => '0');
begin
    pred_phase : prediction_phase_3d
        port map (
            clk => clk, rst => reset, start => pred_start,
            x_pos_current => x_pos_state, x_vel_current => x_vel_state,
            y_pos_current => y_pos_state, y_vel_current => y_vel_state,
            z_pos_current => z_pos_state, z_vel_current => z_vel_state,
            p11_current => p11_state, p12_current => p12_state, p13_current => p13_state, p14_current => p14_state, p15_current => p15_state, p16_current => p16_state,
            p22_current => p22_state, p23_current => p23_state, p24_current => p24_state, p25_current => p25_state, p26_current => p26_state,
            p33_current => p33_state, p34_current => p34_state, p35_current => p35_state, p36_current => p36_state,
            p44_current => p44_state, p45_current => p45_state, p46_current => p46_state,
            p55_current => p55_state, p56_current => p56_state,
            p66_current => p66_state,
            x_pos_pred => x_pos_pred, x_vel_pred => x_vel_pred,
            y_pos_pred => y_pos_pred, y_vel_pred => y_vel_pred,
            z_pos_pred => z_pos_pred, z_vel_pred => z_vel_pred,
            p11_pred => p11_pred, p12_pred => p12_pred, p13_pred => p13_pred, p14_pred => p14_pred, p15_pred => p15_pred, p16_pred => p16_pred,
            p22_pred => p22_pred, p23_pred => p23_pred, p24_pred => p24_pred, p25_pred => p25_pred, p26_pred => p26_pred,
            p33_pred => p33_pred, p34_pred => p34_pred, p35_pred => p35_pred, p36_pred => p36_pred,
            p44_pred => p44_pred, p45_pred => p45_pred, p46_pred => p46_pred,
            p55_pred => p55_pred, p56_pred => p56_pred,
            p66_pred => p66_pred,
            chi_pred_0_x_pos => chi_pred_0_x_pos, chi_pred_0_x_vel => chi_pred_0_x_vel, chi_pred_0_y_pos => chi_pred_0_y_pos, chi_pred_0_y_vel => chi_pred_0_y_vel, chi_pred_0_z_pos => chi_pred_0_z_pos, chi_pred_0_z_vel => chi_pred_0_z_vel,
            chi_pred_1_x_pos => chi_pred_1_x_pos, chi_pred_1_x_vel => chi_pred_1_x_vel, chi_pred_1_y_pos => chi_pred_1_y_pos, chi_pred_1_y_vel => chi_pred_1_y_vel, chi_pred_1_z_pos => chi_pred_1_z_pos, chi_pred_1_z_vel => chi_pred_1_z_vel,
            chi_pred_2_x_pos => chi_pred_2_x_pos, chi_pred_2_x_vel => chi_pred_2_x_vel, chi_pred_2_y_pos => chi_pred_2_y_pos, chi_pred_2_y_vel => chi_pred_2_y_vel, chi_pred_2_z_pos => chi_pred_2_z_pos, chi_pred_2_z_vel => chi_pred_2_z_vel,
            chi_pred_3_x_pos => chi_pred_3_x_pos, chi_pred_3_x_vel => chi_pred_3_x_vel, chi_pred_3_y_pos => chi_pred_3_y_pos, chi_pred_3_y_vel => chi_pred_3_y_vel, chi_pred_3_z_pos => chi_pred_3_z_pos, chi_pred_3_z_vel => chi_pred_3_z_vel,
            chi_pred_4_x_pos => chi_pred_4_x_pos, chi_pred_4_x_vel => chi_pred_4_x_vel, chi_pred_4_y_pos => chi_pred_4_y_pos, chi_pred_4_y_vel => chi_pred_4_y_vel, chi_pred_4_z_pos => chi_pred_4_z_pos, chi_pred_4_z_vel => chi_pred_4_z_vel,
            chi_pred_5_x_pos => chi_pred_5_x_pos, chi_pred_5_x_vel => chi_pred_5_x_vel, chi_pred_5_y_pos => chi_pred_5_y_pos, chi_pred_5_y_vel => chi_pred_5_y_vel, chi_pred_5_z_pos => chi_pred_5_z_pos, chi_pred_5_z_vel => chi_pred_5_z_vel,
            chi_pred_6_x_pos => chi_pred_6_x_pos, chi_pred_6_x_vel => chi_pred_6_x_vel, chi_pred_6_y_pos => chi_pred_6_y_pos, chi_pred_6_y_vel => chi_pred_6_y_vel, chi_pred_6_z_pos => chi_pred_6_z_pos, chi_pred_6_z_vel => chi_pred_6_z_vel,
            chi_pred_7_x_pos => chi_pred_7_x_pos, chi_pred_7_x_vel => chi_pred_7_x_vel, chi_pred_7_y_pos => chi_pred_7_y_pos, chi_pred_7_y_vel => chi_pred_7_y_vel, chi_pred_7_z_pos => chi_pred_7_z_pos, chi_pred_7_z_vel => chi_pred_7_z_vel,
            chi_pred_8_x_pos => chi_pred_8_x_pos, chi_pred_8_x_vel => chi_pred_8_x_vel, chi_pred_8_y_pos => chi_pred_8_y_pos, chi_pred_8_y_vel => chi_pred_8_y_vel, chi_pred_8_z_pos => chi_pred_8_z_pos, chi_pred_8_z_vel => chi_pred_8_z_vel,
            chi_pred_9_x_pos => chi_pred_9_x_pos, chi_pred_9_x_vel => chi_pred_9_x_vel, chi_pred_9_y_pos => chi_pred_9_y_pos, chi_pred_9_y_vel => chi_pred_9_y_vel, chi_pred_9_z_pos => chi_pred_9_z_pos, chi_pred_9_z_vel => chi_pred_9_z_vel,
            chi_pred_10_x_pos => chi_pred_10_x_pos, chi_pred_10_x_vel => chi_pred_10_x_vel, chi_pred_10_y_pos => chi_pred_10_y_pos, chi_pred_10_y_vel => chi_pred_10_y_vel, chi_pred_10_z_pos => chi_pred_10_z_pos, chi_pred_10_z_vel => chi_pred_10_z_vel,
            chi_pred_11_x_pos => chi_pred_11_x_pos, chi_pred_11_x_vel => chi_pred_11_x_vel, chi_pred_11_y_pos => chi_pred_11_y_pos, chi_pred_11_y_vel => chi_pred_11_y_vel, chi_pred_11_z_pos => chi_pred_11_z_pos, chi_pred_11_z_vel => chi_pred_11_z_vel,
            chi_pred_12_x_pos => chi_pred_12_x_pos, chi_pred_12_x_vel => chi_pred_12_x_vel, chi_pred_12_y_pos => chi_pred_12_y_pos, chi_pred_12_y_vel => chi_pred_12_y_vel, chi_pred_12_z_pos => chi_pred_12_z_pos, chi_pred_12_z_vel => chi_pred_12_z_vel,
            done => pred_done
        );
    meas_update : measurement_update_3d
        port map (
            clk => clk, start => meas_start,
            z_x_meas => z_x_meas, z_y_meas => z_y_meas, z_z_meas => z_z_meas,
            x_pos_pred => x_pos_pred, x_vel_pred => x_vel_pred,
            y_pos_pred => y_pos_pred, y_vel_pred => y_vel_pred,
            z_pos_pred => z_pos_pred, z_vel_pred => z_vel_pred,
            p11_pred => p11_pred, p12_pred => p12_pred, p13_pred => p13_pred, p14_pred => p14_pred, p15_pred => p15_pred, p16_pred => p16_pred,
            p22_pred => p22_pred, p23_pred => p23_pred, p24_pred => p24_pred, p25_pred => p25_pred, p26_pred => p26_pred,
            p33_pred => p33_pred, p34_pred => p34_pred, p35_pred => p35_pred, p36_pred => p36_pred,
            p44_pred => p44_pred, p45_pred => p45_pred, p46_pred => p46_pred,
            p55_pred => p55_pred, p56_pred => p56_pred,
            p66_pred => p66_pred,
            chi_pred_0_x_pos => chi_pred_0_x_pos, chi_pred_0_x_vel => chi_pred_0_x_vel, chi_pred_0_y_pos => chi_pred_0_y_pos, chi_pred_0_y_vel => chi_pred_0_y_vel, chi_pred_0_z_pos => chi_pred_0_z_pos, chi_pred_0_z_vel => chi_pred_0_z_vel,
            chi_pred_1_x_pos => chi_pred_1_x_pos, chi_pred_1_x_vel => chi_pred_1_x_vel, chi_pred_1_y_pos => chi_pred_1_y_pos, chi_pred_1_y_vel => chi_pred_1_y_vel, chi_pred_1_z_pos => chi_pred_1_z_pos, chi_pred_1_z_vel => chi_pred_1_z_vel,
            chi_pred_2_x_pos => chi_pred_2_x_pos, chi_pred_2_x_vel => chi_pred_2_x_vel, chi_pred_2_y_pos => chi_pred_2_y_pos, chi_pred_2_y_vel => chi_pred_2_y_vel, chi_pred_2_z_pos => chi_pred_2_z_pos, chi_pred_2_z_vel => chi_pred_2_z_vel,
            chi_pred_3_x_pos => chi_pred_3_x_pos, chi_pred_3_x_vel => chi_pred_3_x_vel, chi_pred_3_y_pos => chi_pred_3_y_pos, chi_pred_3_y_vel => chi_pred_3_y_vel, chi_pred_3_z_pos => chi_pred_3_z_pos, chi_pred_3_z_vel => chi_pred_3_z_vel,
            chi_pred_4_x_pos => chi_pred_4_x_pos, chi_pred_4_x_vel => chi_pred_4_x_vel, chi_pred_4_y_pos => chi_pred_4_y_pos, chi_pred_4_y_vel => chi_pred_4_y_vel, chi_pred_4_z_pos => chi_pred_4_z_pos, chi_pred_4_z_vel => chi_pred_4_z_vel,
            chi_pred_5_x_pos => chi_pred_5_x_pos, chi_pred_5_x_vel => chi_pred_5_x_vel, chi_pred_5_y_pos => chi_pred_5_y_pos, chi_pred_5_y_vel => chi_pred_5_y_vel, chi_pred_5_z_pos => chi_pred_5_z_pos, chi_pred_5_z_vel => chi_pred_5_z_vel,
            chi_pred_6_x_pos => chi_pred_6_x_pos, chi_pred_6_x_vel => chi_pred_6_x_vel, chi_pred_6_y_pos => chi_pred_6_y_pos, chi_pred_6_y_vel => chi_pred_6_y_vel, chi_pred_6_z_pos => chi_pred_6_z_pos, chi_pred_6_z_vel => chi_pred_6_z_vel,
            chi_pred_7_x_pos => chi_pred_7_x_pos, chi_pred_7_x_vel => chi_pred_7_x_vel, chi_pred_7_y_pos => chi_pred_7_y_pos, chi_pred_7_y_vel => chi_pred_7_y_vel, chi_pred_7_z_pos => chi_pred_7_z_pos, chi_pred_7_z_vel => chi_pred_7_z_vel,
            chi_pred_8_x_pos => chi_pred_8_x_pos, chi_pred_8_x_vel => chi_pred_8_x_vel, chi_pred_8_y_pos => chi_pred_8_y_pos, chi_pred_8_y_vel => chi_pred_8_y_vel, chi_pred_8_z_pos => chi_pred_8_z_pos, chi_pred_8_z_vel => chi_pred_8_z_vel,
            chi_pred_9_x_pos => chi_pred_9_x_pos, chi_pred_9_x_vel => chi_pred_9_x_vel, chi_pred_9_y_pos => chi_pred_9_y_pos, chi_pred_9_y_vel => chi_pred_9_y_vel, chi_pred_9_z_pos => chi_pred_9_z_pos, chi_pred_9_z_vel => chi_pred_9_z_vel,
            chi_pred_10_x_pos => chi_pred_10_x_pos, chi_pred_10_x_vel => chi_pred_10_x_vel, chi_pred_10_y_pos => chi_pred_10_y_pos, chi_pred_10_y_vel => chi_pred_10_y_vel, chi_pred_10_z_pos => chi_pred_10_z_pos, chi_pred_10_z_vel => chi_pred_10_z_vel,
            chi_pred_11_x_pos => chi_pred_11_x_pos, chi_pred_11_x_vel => chi_pred_11_x_vel, chi_pred_11_y_pos => chi_pred_11_y_pos, chi_pred_11_y_vel => chi_pred_11_y_vel, chi_pred_11_z_pos => chi_pred_11_z_pos, chi_pred_11_z_vel => chi_pred_11_z_vel,
            chi_pred_12_x_pos => chi_pred_12_x_pos, chi_pred_12_x_vel => chi_pred_12_x_vel, chi_pred_12_y_pos => chi_pred_12_y_pos, chi_pred_12_y_vel => chi_pred_12_y_vel, chi_pred_12_z_pos => chi_pred_12_z_pos, chi_pred_12_z_vel => chi_pred_12_z_vel,
            x_pos_upd => x_pos_upd, x_vel_upd => x_vel_upd,
            y_pos_upd => y_pos_upd, y_vel_upd => y_vel_upd,
            z_pos_upd => z_pos_upd, z_vel_upd => z_vel_upd,
            p11_upd => p11_upd, p12_upd => p12_upd, p13_upd => p13_upd, p14_upd => p14_upd, p15_upd => p15_upd, p16_upd => p16_upd,
            p22_upd => p22_upd, p23_upd => p23_upd, p24_upd => p24_upd, p25_upd => p25_upd, p26_upd => p26_upd,
            p33_upd => p33_upd, p34_upd => p34_upd, p35_upd => p35_upd, p36_upd => p36_upd,
            p44_upd => p44_upd, p45_upd => p45_upd, p46_upd => p46_upd,
            p55_upd => p55_upd, p56_upd => p56_upd,
            p66_upd => p66_upd,
            done => meas_done
        );
    x_pos_current <= x_pos_state;
    x_vel_current <= x_vel_state;
    y_pos_current <= y_pos_state;
    y_vel_current <= y_vel_state;
    z_pos_current <= z_pos_state;
    z_vel_current <= z_vel_state;
    x_pos_uncertainty <= p11_state;
    x_vel_uncertainty <= p22_state;
    y_pos_uncertainty <= p33_state;
    y_vel_uncertainty <= p44_state;
    z_pos_uncertainty <= p55_state;
    z_vel_uncertainty <= p66_state;
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                first_cycle <= '1';
                x_pos_state <= (others => '0');
                x_vel_state <= (others => '0');
                y_pos_state <= (others => '0');
                y_vel_state <= (others => '0');
                z_pos_state <= (others => '0');
                z_vel_state <= (others => '0');
                p11_state <= P11_INIT;
                p22_state <= P22_INIT;
                p33_state <= P33_INIT;
                p44_state <= P44_INIT;
                p55_state <= P55_INIT;
                p66_state <= P66_INIT;
                p12_state <= (others => '0');
                p13_state <= (others => '0');
                p14_state <= (others => '0');
                p15_state <= (others => '0');
                p16_state <= (others => '0');
                p23_state <= (others => '0');
                p24_state <= (others => '0');
                p25_state <= (others => '0');
                p26_state <= (others => '0');
                p34_state <= (others => '0');
                p35_state <= (others => '0');
                p36_state <= (others => '0');
                p45_state <= (others => '0');
                p46_state <= (others => '0');
                p56_state <= (others => '0');
            else
                case state is
                    when IDLE =>
                        done <= '0';
                        pred_start <= '0';
                        meas_start <= '0';
                        if start = '1' then
                            report "UKF_SUPREME: IDLE detected start='1'" & LF &
                                   "  first_cycle=" & std_logic'image(first_cycle);
                            if first_cycle = '1' then
                                state <= INIT_STATE;
                            else
                                state <= RUN_PREDICTION;
                            end if;
                        end if;
                    when INIT_STATE =>
                        report "UKF_SUPREME: INIT_STATE" & LF &
                               "  z_x_meas=" & integer'image(to_integer(z_x_meas)) & LF &
                               "  z_y_meas=" & integer'image(to_integer(z_y_meas)) & LF &
                               "  z_z_meas=" & integer'image(to_integer(z_z_meas));
                        x_pos_state <= z_x_meas;
                        y_pos_state <= z_y_meas;
                        z_pos_state <= z_z_meas;
                        x_vel_state <= (others => '0');
                        y_vel_state <= (others => '0');
                        z_vel_state <= (others => '0');
                        p11_state <= P11_INIT;
                        p22_state <= P22_INIT;
                        p33_state <= P33_INIT;
                        p44_state <= P44_INIT;
                        p55_state <= P55_INIT;
                        p66_state <= P66_INIT;
                        p12_state <= (others => '0'); p13_state <= (others => '0'); p14_state <= (others => '0'); p15_state <= (others => '0'); p16_state <= (others => '0');
                        p23_state <= (others => '0'); p24_state <= (others => '0'); p25_state <= (others => '0'); p26_state <= (others => '0');
                        p34_state <= (others => '0'); p35_state <= (others => '0'); p36_state <= (others => '0');
                        p45_state <= (others => '0'); p46_state <= (others => '0');
                        p56_state <= (others => '0');
                        state <= FINISHED;
                    when RUN_PREDICTION =>
                        report "UKF_SUPREME: RUN_PREDICTION" & LF &
                               "  x_pos_state=" & integer'image(to_integer(x_pos_state)) & LF &
                               "  y_pos_state=" & integer'image(to_integer(y_pos_state)) & LF &
                               "  z_pos_state=" & integer'image(to_integer(z_pos_state)) & LF &
                               "  p11_state=" & integer'image(to_integer(p11_state)) & LF &
                               "  p22_state=" & integer'image(to_integer(p22_state));
                        pred_start <= '1';
                        state <= WAIT_PREDICTION;
                    when WAIT_PREDICTION =>
                        pred_start <= '0';
                        if pred_done = '1' then
                            state <= RUN_MEASUREMENT;
                        end if;
                    when RUN_MEASUREMENT =>
                        report "UKF_SUPREME: RUN_MEASUREMENT" & LF &
                               "  x_pos_pred=" & integer'image(to_integer(x_pos_pred)) & LF &
                               "  y_pos_pred=" & integer'image(to_integer(y_pos_pred)) & LF &
                               "  z_pos_pred=" & integer'image(to_integer(z_pos_pred));
                        meas_start <= '1';
                        state <= WAIT_MEASUREMENT;
                    when WAIT_MEASUREMENT =>
                        meas_start <= '0';
                        if meas_done = '1' then
                            state <= UPDATE_STATE;
                        end if;
                    when UPDATE_STATE =>
                        report "UKF_SUPREME: UPDATE_STATE" & LF &
                               "  x_pos_upd=" & integer'image(to_integer(x_pos_upd)) & LF &
                               "  y_pos_upd=" & integer'image(to_integer(y_pos_upd)) & LF &
                               "  z_pos_upd=" & integer'image(to_integer(z_pos_upd)) & LF &
                               "  p11_upd (BEFORE store)=" & integer'image(to_integer(p11_upd)) & LF &
                               "  p22_upd (BEFORE store)=" & integer'image(to_integer(p22_upd));
                        x_pos_state <= x_pos_upd;
                        x_vel_state <= x_vel_upd;
                        y_pos_state <= y_pos_upd;
                        y_vel_state <= y_vel_upd;
                        z_pos_state <= z_pos_upd;
                        z_vel_state <= z_vel_upd;
                        p11_state <= p11_upd; p12_state <= p12_upd; p13_state <= p13_upd; p14_state <= p14_upd; p15_state <= p15_upd; p16_state <= p16_upd;
                        p22_state <= p22_upd; p23_state <= p23_upd; p24_state <= p24_upd; p25_state <= p25_upd; p26_state <= p26_upd;
                        p33_state <= p33_upd; p34_state <= p34_upd; p35_state <= p35_upd; p36_state <= p36_upd;
                        p44_state <= p44_upd; p45_state <= p45_upd; p46_state <= p46_upd;
                        p55_state <= p55_upd; p56_state <= p56_upd;
                        p66_state <= p66_upd;
                        state <= FINISHED;
                    when FINISHED =>
                        done <= '1';
                        if start = '0' then
                            first_cycle <= '0';
                            state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;
end Behavioral;
