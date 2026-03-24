library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity prediction_phase_3d_tb is
end prediction_phase_3d_tb;

architecture Behavioral of prediction_phase_3d_tb is

    component prediction_phase_3d is
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            start : in  std_logic;
            x_pos_current, x_vel_current : in signed(31 downto 0);
            y_pos_current, y_vel_current : in signed(31 downto 0);
            z_pos_current, z_vel_current : in signed(31 downto 0);
            p11_current, p12_current, p13_current, p14_current, p15_current, p16_current : in signed(31 downto 0);
            p22_current, p23_current, p24_current, p25_current, p26_current             : in signed(31 downto 0);
            p33_current, p34_current, p35_current, p36_current                          : in signed(31 downto 0);
            p44_current, p45_current, p46_current                                       : in signed(31 downto 0);
            p55_current, p56_current                                                    : in signed(31 downto 0);
            p66_current                                                                 : in signed(31 downto 0);
            x_pos_pred, x_vel_pred : out signed(31 downto 0);
            y_pos_pred, y_vel_pred : out signed(31 downto 0);
            z_pos_pred, z_vel_pred : out signed(31 downto 0);
            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred : out signed(31 downto 0);
            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred           : out signed(31 downto 0);
            p33_pred, p34_pred, p35_pred, p36_pred                     : out signed(31 downto 0);
            p44_pred, p45_pred, p46_pred                               : out signed(31 downto 0);
            p55_pred, p56_pred                                         : out signed(31 downto 0);
            p66_pred                                                   : out signed(31 downto 0);
            chi_pred_0_x_pos, chi_pred_0_x_vel, chi_pred_0_y_pos, chi_pred_0_y_vel, chi_pred_0_z_pos, chi_pred_0_z_vel : out signed(31 downto 0);
            chi_pred_1_x_pos, chi_pred_1_x_vel, chi_pred_1_y_pos, chi_pred_1_y_vel, chi_pred_1_z_pos, chi_pred_1_z_vel : out signed(31 downto 0);
            chi_pred_2_x_pos, chi_pred_2_x_vel, chi_pred_2_y_pos, chi_pred_2_y_vel, chi_pred_2_z_pos, chi_pred_2_z_vel : out signed(31 downto 0);
            chi_pred_3_x_pos, chi_pred_3_x_vel, chi_pred_3_y_pos, chi_pred_3_y_vel, chi_pred_3_z_pos, chi_pred_3_z_vel : out signed(31 downto 0);
            chi_pred_4_x_pos, chi_pred_4_x_vel, chi_pred_4_y_pos, chi_pred_4_y_vel, chi_pred_4_z_pos, chi_pred_4_z_vel : out signed(31 downto 0);
            chi_pred_5_x_pos, chi_pred_5_x_vel, chi_pred_5_y_pos, chi_pred_5_y_vel, chi_pred_5_z_pos, chi_pred_5_z_vel : out signed(31 downto 0);
            chi_pred_6_x_pos, chi_pred_6_x_vel, chi_pred_6_y_pos, chi_pred_6_y_vel, chi_pred_6_z_pos, chi_pred_6_z_vel : out signed(31 downto 0);
            chi_pred_7_x_pos, chi_pred_7_x_vel, chi_pred_7_y_pos, chi_pred_7_y_vel, chi_pred_7_z_pos, chi_pred_7_z_vel : out signed(31 downto 0);
            chi_pred_8_x_pos, chi_pred_8_x_vel, chi_pred_8_y_pos, chi_pred_8_y_vel, chi_pred_8_z_pos, chi_pred_8_z_vel : out signed(31 downto 0);
            chi_pred_9_x_pos, chi_pred_9_x_vel, chi_pred_9_y_pos, chi_pred_9_y_vel, chi_pred_9_z_pos, chi_pred_9_z_vel : out signed(31 downto 0);
            chi_pred_10_x_pos, chi_pred_10_x_vel, chi_pred_10_y_pos, chi_pred_10_y_vel, chi_pred_10_z_pos, chi_pred_10_z_vel : out signed(31 downto 0);
            chi_pred_11_x_pos, chi_pred_11_x_vel, chi_pred_11_y_pos, chi_pred_11_y_vel, chi_pred_11_z_pos, chi_pred_11_z_vel : out signed(31 downto 0);
            chi_pred_12_x_pos, chi_pred_12_x_vel, chi_pred_12_y_pos, chi_pred_12_y_vel, chi_pred_12_z_pos, chi_pred_12_z_vel : out signed(31 downto 0);
            done : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal start : std_logic := '0';
    signal done : std_logic;

    signal x_pos_current : signed(31 downto 0) := to_signed(410, 32);
    signal x_vel_current : signed(31 downto 0) := to_signed(0, 32);
    signal y_pos_current : signed(31 downto 0) := to_signed(-205, 32);
    signal y_vel_current : signed(31 downto 0) := to_signed(0, 32);
    signal z_pos_current : signed(31 downto 0) := to_signed(328, 32);
    signal z_vel_current : signed(31 downto 0) := to_signed(0, 32);

    signal p11_current : signed(31 downto 0) := to_signed(409600, 32);
    signal p22_current : signed(31 downto 0) := to_signed(40960, 32);
    signal p33_current : signed(31 downto 0) := to_signed(409600, 32);
    signal p44_current : signed(31 downto 0) := to_signed(40960, 32);
    signal p55_current : signed(31 downto 0) := to_signed(409600, 32);
    signal p66_current : signed(31 downto 0) := to_signed(40960, 32);

    signal p12_current, p13_current, p14_current, p15_current, p16_current : signed(31 downto 0) := (others => '0');
    signal p23_current, p24_current, p25_current, p26_current             : signed(31 downto 0) := (others => '0');
    signal p34_current, p35_current, p36_current                          : signed(31 downto 0) := (others => '0');
    signal p45_current, p46_current                                       : signed(31 downto 0) := (others => '0');
    signal p56_current                                                    : signed(31 downto 0) := (others => '0');

    signal x_pos_pred, x_vel_pred : signed(31 downto 0);
    signal y_pos_pred, y_vel_pred : signed(31 downto 0);
    signal z_pos_pred, z_vel_pred : signed(31 downto 0);

    signal p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred : signed(31 downto 0);
    signal p22_pred, p23_pred, p24_pred, p25_pred, p26_pred           : signed(31 downto 0);
    signal p33_pred, p34_pred, p35_pred, p36_pred                     : signed(31 downto 0);
    signal p44_pred, p45_pred, p46_pred                               : signed(31 downto 0);
    signal p55_pred, p56_pred                                         : signed(31 downto 0);
    signal p66_pred                                                   : signed(31 downto 0);

    signal chi_pred_0_x_pos, chi_pred_0_x_vel, chi_pred_0_y_pos, chi_pred_0_y_vel, chi_pred_0_z_pos, chi_pred_0_z_vel : signed(31 downto 0);
    signal chi_pred_1_x_pos, chi_pred_1_x_vel, chi_pred_1_y_pos, chi_pred_1_y_vel, chi_pred_1_z_pos, chi_pred_1_z_vel : signed(31 downto 0);
    signal chi_pred_2_x_pos, chi_pred_2_x_vel, chi_pred_2_y_pos, chi_pred_2_y_vel, chi_pred_2_z_pos, chi_pred_2_z_vel : signed(31 downto 0);
    signal chi_pred_3_x_pos, chi_pred_3_x_vel, chi_pred_3_y_pos, chi_pred_3_y_vel, chi_pred_3_z_pos, chi_pred_3_z_vel : signed(31 downto 0);
    signal chi_pred_4_x_pos, chi_pred_4_x_vel, chi_pred_4_y_pos, chi_pred_4_y_vel, chi_pred_4_z_pos, chi_pred_4_z_vel : signed(31 downto 0);
    signal chi_pred_5_x_pos, chi_pred_5_x_vel, chi_pred_5_y_pos, chi_pred_5_y_vel, chi_pred_5_z_pos, chi_pred_5_z_vel : signed(31 downto 0);
    signal chi_pred_6_x_pos, chi_pred_6_x_vel, chi_pred_6_y_pos, chi_pred_6_y_vel, chi_pred_6_z_pos, chi_pred_6_z_vel : signed(31 downto 0);
    signal chi_pred_7_x_pos, chi_pred_7_x_vel, chi_pred_7_y_pos, chi_pred_7_y_vel, chi_pred_7_z_pos, chi_pred_7_z_vel : signed(31 downto 0);
    signal chi_pred_8_x_pos, chi_pred_8_x_vel, chi_pred_8_y_pos, chi_pred_8_y_vel, chi_pred_8_z_pos, chi_pred_8_z_vel : signed(31 downto 0);
    signal chi_pred_9_x_pos, chi_pred_9_x_vel, chi_pred_9_y_pos, chi_pred_9_y_vel, chi_pred_9_z_pos, chi_pred_9_z_vel : signed(31 downto 0);
    signal chi_pred_10_x_pos, chi_pred_10_x_vel, chi_pred_10_y_pos, chi_pred_10_y_vel, chi_pred_10_z_pos, chi_pred_10_z_vel : signed(31 downto 0);
    signal chi_pred_11_x_pos, chi_pred_11_x_vel, chi_pred_11_y_pos, chi_pred_11_y_vel, chi_pred_11_z_pos, chi_pred_11_z_vel : signed(31 downto 0);
    signal chi_pred_12_x_pos, chi_pred_12_x_vel, chi_pred_12_y_pos, chi_pred_12_y_vel, chi_pred_12_z_pos, chi_pred_12_z_vel : signed(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    clk <= not clk after CLK_PERIOD/2;

    dut : prediction_phase_3d
        port map (
            clk => clk,
            rst => rst,
            start => start,
            x_pos_current => x_pos_current, x_vel_current => x_vel_current,
            y_pos_current => y_pos_current, y_vel_current => y_vel_current,
            z_pos_current => z_pos_current, z_vel_current => z_vel_current,
            p11_current => p11_current, p12_current => p12_current, p13_current => p13_current,
            p14_current => p14_current, p15_current => p15_current, p16_current => p16_current,
            p22_current => p22_current, p23_current => p23_current, p24_current => p24_current,
            p25_current => p25_current, p26_current => p26_current,
            p33_current => p33_current, p34_current => p34_current, p35_current => p35_current,
            p36_current => p36_current,
            p44_current => p44_current, p45_current => p45_current, p46_current => p46_current,
            p55_current => p55_current, p56_current => p56_current,
            p66_current => p66_current,
            x_pos_pred => x_pos_pred, x_vel_pred => x_vel_pred,
            y_pos_pred => y_pos_pred, y_vel_pred => y_vel_pred,
            z_pos_pred => z_pos_pred, z_vel_pred => z_vel_pred,
            p11_pred => p11_pred, p12_pred => p12_pred, p13_pred => p13_pred,
            p14_pred => p14_pred, p15_pred => p15_pred, p16_pred => p16_pred,
            p22_pred => p22_pred, p23_pred => p23_pred, p24_pred => p24_pred,
            p25_pred => p25_pred, p26_pred => p26_pred,
            p33_pred => p33_pred, p34_pred => p34_pred, p35_pred => p35_pred,
            p36_pred => p36_pred,
            p44_pred => p44_pred, p45_pred => p45_pred, p46_pred => p46_pred,
            p55_pred => p55_pred, p56_pred => p56_pred,
            p66_pred => p66_pred,
            chi_pred_0_x_pos => chi_pred_0_x_pos, chi_pred_0_x_vel => chi_pred_0_x_vel,
            chi_pred_0_y_pos => chi_pred_0_y_pos, chi_pred_0_y_vel => chi_pred_0_y_vel,
            chi_pred_0_z_pos => chi_pred_0_z_pos, chi_pred_0_z_vel => chi_pred_0_z_vel,
            chi_pred_1_x_pos => chi_pred_1_x_pos, chi_pred_1_x_vel => chi_pred_1_x_vel,
            chi_pred_1_y_pos => chi_pred_1_y_pos, chi_pred_1_y_vel => chi_pred_1_y_vel,
            chi_pred_1_z_pos => chi_pred_1_z_pos, chi_pred_1_z_vel => chi_pred_1_z_vel,
            chi_pred_2_x_pos => chi_pred_2_x_pos, chi_pred_2_x_vel => chi_pred_2_x_vel,
            chi_pred_2_y_pos => chi_pred_2_y_pos, chi_pred_2_y_vel => chi_pred_2_y_vel,
            chi_pred_2_z_pos => chi_pred_2_z_pos, chi_pred_2_z_vel => chi_pred_2_z_vel,
            chi_pred_3_x_pos => chi_pred_3_x_pos, chi_pred_3_x_vel => chi_pred_3_x_vel,
            chi_pred_3_y_pos => chi_pred_3_y_pos, chi_pred_3_y_vel => chi_pred_3_y_vel,
            chi_pred_3_z_pos => chi_pred_3_z_pos, chi_pred_3_z_vel => chi_pred_3_z_vel,
            chi_pred_4_x_pos => chi_pred_4_x_pos, chi_pred_4_x_vel => chi_pred_4_x_vel,
            chi_pred_4_y_pos => chi_pred_4_y_pos, chi_pred_4_y_vel => chi_pred_4_y_vel,
            chi_pred_4_z_pos => chi_pred_4_z_pos, chi_pred_4_z_vel => chi_pred_4_z_vel,
            chi_pred_5_x_pos => chi_pred_5_x_pos, chi_pred_5_x_vel => chi_pred_5_x_vel,
            chi_pred_5_y_pos => chi_pred_5_y_pos, chi_pred_5_y_vel => chi_pred_5_y_vel,
            chi_pred_5_z_pos => chi_pred_5_z_pos, chi_pred_5_z_vel => chi_pred_5_z_vel,
            chi_pred_6_x_pos => chi_pred_6_x_pos, chi_pred_6_x_vel => chi_pred_6_x_vel,
            chi_pred_6_y_pos => chi_pred_6_y_pos, chi_pred_6_y_vel => chi_pred_6_y_vel,
            chi_pred_6_z_pos => chi_pred_6_z_pos, chi_pred_6_z_vel => chi_pred_6_z_vel,
            chi_pred_7_x_pos => chi_pred_7_x_pos, chi_pred_7_x_vel => chi_pred_7_x_vel,
            chi_pred_7_y_pos => chi_pred_7_y_pos, chi_pred_7_y_vel => chi_pred_7_y_vel,
            chi_pred_7_z_pos => chi_pred_7_z_pos, chi_pred_7_z_vel => chi_pred_7_z_vel,
            chi_pred_8_x_pos => chi_pred_8_x_pos, chi_pred_8_x_vel => chi_pred_8_x_vel,
            chi_pred_8_y_pos => chi_pred_8_y_pos, chi_pred_8_y_vel => chi_pred_8_y_vel,
            chi_pred_8_z_pos => chi_pred_8_z_pos, chi_pred_8_z_vel => chi_pred_8_z_vel,
            chi_pred_9_x_pos => chi_pred_9_x_pos, chi_pred_9_x_vel => chi_pred_9_x_vel,
            chi_pred_9_y_pos => chi_pred_9_y_pos, chi_pred_9_y_vel => chi_pred_9_y_vel,
            chi_pred_9_z_pos => chi_pred_9_z_pos, chi_pred_9_z_vel => chi_pred_9_z_vel,
            chi_pred_10_x_pos => chi_pred_10_x_pos, chi_pred_10_x_vel => chi_pred_10_x_vel,
            chi_pred_10_y_pos => chi_pred_10_y_pos, chi_pred_10_y_vel => chi_pred_10_y_vel,
            chi_pred_10_z_pos => chi_pred_10_z_pos, chi_pred_10_z_vel => chi_pred_10_z_vel,
            chi_pred_11_x_pos => chi_pred_11_x_pos, chi_pred_11_x_vel => chi_pred_11_x_vel,
            chi_pred_11_y_pos => chi_pred_11_y_pos, chi_pred_11_y_vel => chi_pred_11_y_vel,
            chi_pred_11_z_pos => chi_pred_11_z_pos, chi_pred_11_z_vel => chi_pred_11_z_vel,
            chi_pred_12_x_pos => chi_pred_12_x_pos, chi_pred_12_x_vel => chi_pred_12_x_vel,
            chi_pred_12_y_pos => chi_pred_12_y_pos, chi_pred_12_y_vel => chi_pred_12_y_vel,
            chi_pred_12_z_pos => chi_pred_12_z_pos, chi_pred_12_z_vel => chi_pred_12_z_vel,
            done => done
        );

    stim_proc : process
        variable line_v : line;
    begin

        report "=== Starting Prediction Phase Testbench ===";
        report "Feeding Cycle 0 INIT_STATE inputs:";
        report "  State: x_pos=410 (0.1m), x_vel=0, y_pos=-205 (-0.05m), y_vel=0, z_pos=328 (0.08m), z_vel=0";
        report "  P11=409600 (100m²), P22=40960 (10(m/s)²), P33=409600, P44=40960, P55=409600, P66=40960";

        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 20 ns;

        report "Starting prediction phase at " & time'image(now);
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        for i in 0 to 10000 loop
            if done = '1' then
                report "Prediction phase completed at " & time'image(now);
                exit;
            end if;
            wait for CLK_PERIOD;
        end loop;

        if done /= '1' then
            report "ERROR: Prediction phase timed out after " & time'image(now) severity error;
        else

            report "=== Prediction Phase Results ===";
            report "Predicted State:";
            report "  x_pos_pred = " & integer'image(to_integer(x_pos_pred));
            report "  x_vel_pred = " & integer'image(to_integer(x_vel_pred));
            report "  y_pos_pred = " & integer'image(to_integer(y_pos_pred));
            report "  y_vel_pred = " & integer'image(to_integer(y_vel_pred));
            report "  z_pos_pred = " & integer'image(to_integer(z_pos_pred));
            report "  z_vel_pred = " & integer'image(to_integer(z_vel_pred));

            report "Predicted Covariance (diagonal elements):";
            report "  p11_pred = " & integer'image(to_integer(p11_pred));
            report "  p22_pred = " & integer'image(to_integer(p22_pred));
            report "  p33_pred = " & integer'image(to_integer(p33_pred));
            report "  p44_pred = " & integer'image(to_integer(p44_pred));
            report "  p55_pred = " & integer'image(to_integer(p55_pred));
            report "  p66_pred = " & integer'image(to_integer(p66_pred));

            report "Predicted Sigma Points (first 3 points):";
            report "  chi0: x_pos=" & integer'image(to_integer(chi_pred_0_x_pos)) &
                   " y_pos=" & integer'image(to_integer(chi_pred_0_y_pos)) &
                   " z_pos=" & integer'image(to_integer(chi_pred_0_z_pos));
            report "  chi1: x_pos=" & integer'image(to_integer(chi_pred_1_x_pos)) &
                   " y_pos=" & integer'image(to_integer(chi_pred_1_y_pos)) &
                   " z_pos=" & integer'image(to_integer(chi_pred_1_z_pos));
            report "  chi2: x_pos=" & integer'image(to_integer(chi_pred_2_x_pos)) &
                   " y_pos=" & integer'image(to_integer(chi_pred_2_y_pos)) &
                   " z_pos=" & integer'image(to_integer(chi_pred_2_z_pos));

            if x_pos_pred = x_pos_current and x_vel_pred = x_vel_current then
                report "PASS: X-axis prediction correct (velocity=0 implies no position change)";
            else
                report "INFO: X-axis changed: x_pos " & integer'image(to_integer(x_pos_current)) &
                       " -> " & integer'image(to_integer(x_pos_pred));
            end if;

            report "=== Testbench Complete ===";
            report "Watch for metavalue warnings in log above to identify problematic module";
        end if;

        wait;
    end process;

end Behavioral;
