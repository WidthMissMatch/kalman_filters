library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity ukf_50cycle_test_tb is
end ukf_50cycle_test_tb;

architecture Behavioral of ukf_50cycle_test_tb is

    component ukf_supreme_3d is
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            start : in  std_logic;
            z_x_meas : in signed(47 downto 0);
            z_y_meas : in signed(47 downto 0);
            z_z_meas : in signed(47 downto 0);
            x_pos_current : out signed(47 downto 0);
            y_pos_current : out signed(47 downto 0);
            z_pos_current : out signed(47 downto 0);
            x_pos_uncertainty : out signed(47 downto 0);
            y_pos_uncertainty : out signed(47 downto 0);
            z_pos_uncertainty : out signed(47 downto 0);
            x_vel_current : out signed(47 downto 0);
            y_vel_current : out signed(47 downto 0);
            z_vel_current : out signed(47 downto 0);
            x_vel_uncertainty : out signed(47 downto 0);
            y_vel_uncertainty : out signed(47 downto 0);
            z_vel_uncertainty : out signed(47 downto 0);
            x_acc_current : out signed(47 downto 0);
            y_acc_current : out signed(47 downto 0);
            z_acc_current : out signed(47 downto 0);
            x_acc_uncertainty : out signed(47 downto 0);
            y_acc_uncertainty : out signed(47 downto 0);
            z_acc_uncertainty : out signed(47 downto 0);
            done  : out std_logic
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;
    constant NUM_CYCLES : integer := 50;
    constant BASE_CYCLES : integer := 5;
    constant MAX_WAIT_CYCLES : integer := 100000;
    constant Q_SCALE : real := 16777216.0;

    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal start : std_logic := '0';
    signal done : std_logic;

    signal z_x_meas, z_y_meas, z_z_meas : signed(47 downto 0);
    signal x_pos_current, y_pos_current, z_pos_current : signed(47 downto 0);
    signal x_pos_uncertainty, y_pos_uncertainty, z_pos_uncertainty : signed(47 downto 0);
    signal x_vel_current, y_vel_current, z_vel_current : signed(47 downto 0);
    signal x_vel_uncertainty, y_vel_uncertainty, z_vel_uncertainty : signed(47 downto 0);
    signal x_acc_current, y_acc_current, z_acc_current : signed(47 downto 0);
    signal x_acc_uncertainty, y_acc_uncertainty, z_acc_uncertainty : signed(47 downto 0);

    type meas_array_t is array (0 to BASE_CYCLES-1) of signed(47 downto 0);

    constant meas_x_data : meas_array_t := (
        0 => to_signed(847194280, 48),
        1 => to_signed(864371058, 48),
        2 => to_signed(865187827, 48),
        3 => to_signed(847585987, 48),
        4 => to_signed(842249254, 48)
    );

    constant meas_y_data : meas_array_t := (
        0 => to_signed(-2319690, 48),
        1 => to_signed(4460026, 48),
        2 => to_signed(29651515, 48),
        3 => to_signed(17387190, 48),
        4 => to_signed(1445968, 48)
    );

    constant meas_z_data : meas_array_t := (
        0 => to_signed(178638570, 48),
        1 => to_signed(163978211, 48),
        2 => to_signed(160164119, 48),
        3 => to_signed(160361154, 48),
        4 => to_signed(139369688, 48)
    );

begin

    uut: ukf_supreme_3d
        port map (
            clk => clk,
            reset => reset,
            start => start,
            z_x_meas => z_x_meas,
            z_y_meas => z_y_meas,
            z_z_meas => z_z_meas,
            x_pos_current => x_pos_current,
            x_vel_current => x_vel_current,
            x_acc_current => x_acc_current,
            y_pos_current => y_pos_current,
            y_vel_current => y_vel_current,
            y_acc_current => y_acc_current,
            z_pos_current => z_pos_current,
            z_vel_current => z_vel_current,
            z_acc_current => z_acc_current,
            x_pos_uncertainty => x_pos_uncertainty,
            x_vel_uncertainty => x_vel_uncertainty,
            x_acc_uncertainty => x_acc_uncertainty,
            y_pos_uncertainty => y_pos_uncertainty,
            y_vel_uncertainty => y_vel_uncertainty,
            y_acc_uncertainty => y_acc_uncertainty,
            z_pos_uncertainty => z_pos_uncertainty,
            z_vel_uncertainty => z_vel_uncertainty,
            z_acc_uncertainty => z_acc_uncertainty,
            done => done
        );

    clk_proc: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stim_proc: process
        variable timeout_counter : integer;
    begin
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        report "========================================";
        report "50-CYCLE EXTENDED STABILITY TEST";
        report "Testing Tier 4A: P99=0.01, K saturation";
        report "========================================";

        for i in 0 to NUM_CYCLES-1 loop
            z_x_meas <= meas_x_data(i mod BASE_CYCLES);
            z_y_meas <= meas_y_data(i mod BASE_CYCLES);
            z_z_meas <= meas_z_data(i mod BASE_CYCLES);

            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            timeout_counter := 0;
            wait until done = '1' or timeout_counter = MAX_WAIT_CYCLES;

            while done = '0' and timeout_counter < MAX_WAIT_CYCLES loop
                wait for CLK_PERIOD;
                timeout_counter := timeout_counter + 1;
            end loop;

            if timeout_counter >= MAX_WAIT_CYCLES then
                report "ERROR: Timeout at cycle " & integer'image(i);
                wait;
            end if;

            if (i mod 10) = 9 or i < 5 or i = NUM_CYCLES-1 then
                report "Cycle " & integer'image(i) &
                       ": z_pos=" & integer'image(to_integer(z_pos_current)) &
                       " (" & real'image(real(to_integer(z_pos_current))/Q_SCALE) & "m)" &
                       ", P99=" & integer'image(to_integer(z_acc_uncertainty));
            end if;

            if z_acc_uncertainty < to_signed(0, 48) then
                report "ERROR: Negative P99 at cycle " & integer'image(i) &
                       ", P99=" & integer'image(to_integer(z_acc_uncertainty));
            end if;

            wait for CLK_PERIOD * 2;
        end loop;

        report "========================================";
        report "50-CYCLE TEST COMPLETE";
        report "Final: z_pos=" & integer'image(to_integer(z_pos_current)) &
               ", P99=" & integer'image(to_integer(z_acc_uncertainty));
        report "========================================";

        wait for 1 us;
        report "Simulation complete";
        wait;
    end process;

end Behavioral;
