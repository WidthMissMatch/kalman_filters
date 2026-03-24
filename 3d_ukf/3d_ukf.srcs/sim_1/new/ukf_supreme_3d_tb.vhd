library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity ukf_supreme_3d_tb is
end ukf_supreme_3d_tb;

architecture Behavioral of ukf_supreme_3d_tb is

    component ukf_supreme_3d is
        port (
            clk : in std_logic;
            reset : in std_logic;
            start : in std_logic;
            z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);
            x_pos_current, x_vel_current : out signed(47 downto 0);
            y_pos_current, y_vel_current : out signed(47 downto 0);
            z_pos_current, z_vel_current : out signed(47 downto 0);
            x_pos_uncertainty, x_vel_uncertainty : out signed(47 downto 0);
            y_pos_uncertainty, y_vel_uncertainty : out signed(47 downto 0);
            z_pos_uncertainty, z_vel_uncertainty : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal start : std_logic := '0';
    signal done : std_logic;

    signal z_x_meas : signed(47 downto 0) := (others => '0');
    signal z_y_meas : signed(47 downto 0) := (others => '0');
    signal z_z_meas : signed(47 downto 0) := (others => '0');

    signal x_pos_current, x_vel_current : signed(47 downto 0);
    signal y_pos_current, y_vel_current : signed(47 downto 0);
    signal z_pos_current, z_vel_current : signed(47 downto 0);

    signal x_pos_uncertainty, x_vel_uncertainty : signed(47 downto 0);
    signal y_pos_uncertainty, y_vel_uncertainty : signed(47 downto 0);
    signal z_pos_uncertainty, z_vel_uncertainty : signed(47 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    constant Q : integer := 24;
    constant SCALE : integer := 16777216;

    function to_fixed(val : real) return signed is
    begin
        return to_signed(integer(val * real(SCALE)), 48);
    end function;

    function from_fixed(val : signed) return real is
    begin
        return real(to_integer(val)) / real(SCALE);
    end function;

begin

    uut : ukf_supreme_3d
        port map (
            clk => clk,
            reset => reset,
            start => start,
            z_x_meas => z_x_meas,
            z_y_meas => z_y_meas,
            z_z_meas => z_z_meas,
            x_pos_current => x_pos_current,
            x_vel_current => x_vel_current,
            y_pos_current => y_pos_current,
            y_vel_current => y_vel_current,
            z_pos_current => z_pos_current,
            z_vel_current => z_vel_current,
            x_pos_uncertainty => x_pos_uncertainty,
            x_vel_uncertainty => x_vel_uncertainty,
            y_pos_uncertainty => y_pos_uncertainty,
            y_vel_uncertainty => y_vel_uncertainty,
            z_pos_uncertainty => z_pos_uncertainty,
            z_vel_uncertainty => z_vel_uncertainty,
            done => done
        );

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stim_process : process
        variable measurement_count : integer := 0;
    begin

        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        report "Starting 3D UKF test...";

        for i in 0 to 9 loop

            z_x_meas <= to_fixed(1.0 * real(i) * 0.02 + 0.1);
            z_y_meas <= to_fixed(0.5 * real(i) * 0.02 - 0.05);
            z_z_meas <= to_fixed(0.3 * real(i) * 0.02 + 0.08);

            start <= '1';
            wait until rising_edge(clk);
            start <= '0';

            wait until done = '1';
            wait for CLK_PERIOD;

            report "Cycle " & integer'image(i) & ":";
            report "  Measurement: x=" & real'image(from_fixed(z_x_meas)) &
                   " y=" & real'image(from_fixed(z_y_meas)) &
                   " z=" & real'image(from_fixed(z_z_meas));
            report "  Estimate: x_pos=" & real'image(from_fixed(x_pos_current)) &
                   " y_pos=" & real'image(from_fixed(y_pos_current)) &
                   " z_pos=" & real'image(from_fixed(z_pos_current));
            report "  Velocity: x_vel=" & real'image(from_fixed(x_vel_current)) &
                   " y_vel=" & real'image(from_fixed(y_vel_current)) &
                   " z_vel=" & real'image(from_fixed(z_vel_current));
            report "  Uncertainty: P11=" & real'image(from_fixed(x_pos_uncertainty)) &
                   " P33=" & real'image(from_fixed(y_pos_uncertainty)) &
                   " P55=" & real'image(from_fixed(z_pos_uncertainty));

            wait for CLK_PERIOD * 10;
        end loop;

        report "Test completed successfully!";
        wait;
    end process;

end Behavioral;
