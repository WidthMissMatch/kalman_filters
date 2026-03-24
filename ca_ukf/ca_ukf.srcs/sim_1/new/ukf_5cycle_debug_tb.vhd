library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity ukf_5cycle_debug_tb is
end ukf_5cycle_debug_tb;

architecture Behavioral of ukf_5cycle_debug_tb is

    component ukf_supreme_3d is
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
            done : out std_logic
        );
    end component;

    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal start       : std_logic := '0';

    signal z_x_meas    : signed(47 downto 0) := (others => '0');
    signal z_y_meas    : signed(47 downto 0) := (others => '0');
    signal z_z_meas    : signed(47 downto 0) := (others => '0');

    signal x_pos_current : signed(47 downto 0);
    signal x_vel_current : signed(47 downto 0);
    signal x_acc_current : signed(47 downto 0);
    signal y_pos_current : signed(47 downto 0);
    signal y_vel_current : signed(47 downto 0);
    signal y_acc_current : signed(47 downto 0);
    signal z_pos_current : signed(47 downto 0);
    signal z_vel_current : signed(47 downto 0);
    signal z_acc_current : signed(47 downto 0);

    signal x_pos_uncertainty : signed(47 downto 0);
    signal x_vel_uncertainty : signed(47 downto 0);
    signal x_acc_uncertainty : signed(47 downto 0);
    signal y_pos_uncertainty : signed(47 downto 0);
    signal y_vel_uncertainty : signed(47 downto 0);
    signal y_acc_uncertainty : signed(47 downto 0);
    signal z_pos_uncertainty : signed(47 downto 0);
    signal z_vel_uncertainty : signed(47 downto 0);
    signal z_acc_uncertainty : signed(47 downto 0);

    signal done : std_logic;

    constant CLK_PERIOD : time := 10 ns;

    constant Q_SCALE : real := 16777216.0;

    constant NUM_CYCLES : integer := 5;
    constant MAX_WAIT_CYCLES : integer := 100000;

    type meas_array_t is array (0 to NUM_CYCLES-1) of signed(47 downto 0);

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

    function from_q24_24(val : signed(47 downto 0)) return real is
    begin
        return real(to_integer(val)) / Q_SCALE;
    end function;

    function to_hex_string(val : signed(47 downto 0)) return string is
        variable result : string(1 to 12);
        variable nibble : integer;
        variable temp : unsigned(47 downto 0);
        constant hex_chars : string(1 to 16) := "0123456789ABCDEF";
    begin
        temp := unsigned(val);
        for i in 12 downto 1 loop
            nibble := to_integer(temp(3 downto 0));
            result(i) := hex_chars(nibble + 1);
            temp := shift_right(temp, 4);
        end loop;
        return result;
    end function;

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
        wait for CLK_PERIOD * 10;
        reset <= '0';
        wait for CLK_PERIOD;

        report "========================================";
        report "UKF 5-CYCLE DEBUG TESTBENCH";
        report "Format: [Decimal] (0xHex) {Real}";
        report "========================================";
        report "";

        for cycle in 0 to NUM_CYCLES-1 loop
            report "----------------------------------------";
            report "CYCLE " & integer'image(cycle);
            report "----------------------------------------";

            z_x_meas <= meas_x_data(cycle);
            z_y_meas <= meas_y_data(cycle);
            z_z_meas <= meas_z_data(cycle);

            report "INPUTS:";
            report "  meas_x = [" & integer'image(to_integer(meas_x_data(cycle))) &
                   "] (0x" & to_hex_string(meas_x_data(cycle)) &
                   ") {" & real'image(from_q24_24(meas_x_data(cycle))) & " m}";
            report "  meas_y = [" & integer'image(to_integer(meas_y_data(cycle))) &
                   "] (0x" & to_hex_string(meas_y_data(cycle)) &
                   ") {" & real'image(from_q24_24(meas_y_data(cycle))) & " m}";
            report "  meas_z = [" & integer'image(to_integer(meas_z_data(cycle))) &
                   "] (0x" & to_hex_string(meas_z_data(cycle)) &
                   ") {" & real'image(from_q24_24(meas_z_data(cycle))) & " m}";

            wait until rising_edge(clk);
            start <= '1';
            wait until rising_edge(clk);
            start <= '0';

            timeout_counter := 0;
            while done = '0' and timeout_counter < MAX_WAIT_CYCLES loop
                wait until rising_edge(clk);
                timeout_counter := timeout_counter + 1;
            end loop;

            if done = '0' then
                report "ERROR: Timeout waiting for done signal at cycle " & integer'image(cycle) severity error;
                report "SIMULATION FAILED" severity failure;
            end if;

            wait for CLK_PERIOD;

            report "";
            report "OUTPUTS (State Estimates):";
            report "X-axis:";
            report "  x_pos = [" & integer'image(to_integer(x_pos_current)) &
                   "] (0x" & to_hex_string(x_pos_current) &
                   ") {" & real'image(from_q24_24(x_pos_current)) & " m}";
            report "  x_vel = [" & integer'image(to_integer(x_vel_current)) &
                   "] (0x" & to_hex_string(x_vel_current) &
                   ") {" & real'image(from_q24_24(x_vel_current)) & " m/s}";
            report "  x_acc = [" & integer'image(to_integer(x_acc_current)) &
                   "] (0x" & to_hex_string(x_acc_current) &
                   ") {" & real'image(from_q24_24(x_acc_current)) & " m/s²}";

            report "Y-axis:";
            report "  y_pos = [" & integer'image(to_integer(y_pos_current)) &
                   "] (0x" & to_hex_string(y_pos_current) &
                   ") {" & real'image(from_q24_24(y_pos_current)) & " m}";
            report "  y_vel = [" & integer'image(to_integer(y_vel_current)) &
                   "] (0x" & to_hex_string(y_vel_current) &
                   ") {" & real'image(from_q24_24(y_vel_current)) & " m/s}";
            report "  y_acc = [" & integer'image(to_integer(y_acc_current)) &
                   "] (0x" & to_hex_string(y_acc_current) &
                   ") {" & real'image(from_q24_24(y_acc_current)) & " m/s²}";

            report "Z-axis:";
            report "  z_pos = [" & integer'image(to_integer(z_pos_current)) &
                   "] (0x" & to_hex_string(z_pos_current) &
                   ") {" & real'image(from_q24_24(z_pos_current)) & " m}";
            report "  z_vel = [" & integer'image(to_integer(z_vel_current)) &
                   "] (0x" & to_hex_string(z_vel_current) &
                   ") {" & real'image(from_q24_24(z_vel_current)) & " m/s}";
            report "  z_acc = [" & integer'image(to_integer(z_acc_current)) &
                   "] (0x" & to_hex_string(z_acc_current) &
                   ") {" & real'image(from_q24_24(z_acc_current)) & " m/s²}";

            report "";
            report "UNCERTAINTY (sqrt of P diagonal):";
            report "  sigma_x_pos = [" & integer'image(to_integer(x_pos_uncertainty)) &
                   "] (0x" & to_hex_string(x_pos_uncertainty) &
                   ") {" & real'image(from_q24_24(x_pos_uncertainty)) & " m}";
            report "  sigma_x_vel = [" & integer'image(to_integer(x_vel_uncertainty)) &
                   "] (0x" & to_hex_string(x_vel_uncertainty) & ")";
            report "  sigma_x_acc = [" & integer'image(to_integer(x_acc_uncertainty)) &
                   "] (0x" & to_hex_string(x_acc_uncertainty) & ")";

            report "  sigma_y_pos = [" & integer'image(to_integer(y_pos_uncertainty)) &
                   "] (0x" & to_hex_string(y_pos_uncertainty) &
                   ") {" & real'image(from_q24_24(y_pos_uncertainty)) & " m}";
            report "  sigma_y_vel = [" & integer'image(to_integer(y_vel_uncertainty)) &
                   "] (0x" & to_hex_string(y_vel_uncertainty) & ")";
            report "  sigma_y_acc = [" & integer'image(to_integer(y_acc_uncertainty)) &
                   "] (0x" & to_hex_string(y_acc_uncertainty) & ")";

            report "  sigma_z_pos = [" & integer'image(to_integer(z_pos_uncertainty)) &
                   "] (0x" & to_hex_string(z_pos_uncertainty) &
                   ") {" & real'image(from_q24_24(z_pos_uncertainty)) & " m}";
            report "  sigma_z_vel = [" & integer'image(to_integer(z_vel_uncertainty)) &
                   "] (0x" & to_hex_string(z_vel_uncertainty) & ")";
            report "  sigma_z_acc = [" & integer'image(to_integer(z_acc_uncertainty)) &
                   "] (0x" & to_hex_string(z_acc_uncertainty) & ")";

            if x_pos_uncertainty < 0 or x_vel_uncertainty < 0 or x_acc_uncertainty < 0 or
               y_pos_uncertainty < 0 or y_vel_uncertainty < 0 or y_acc_uncertainty < 0 or
               z_pos_uncertainty < 0 or z_vel_uncertainty < 0 or z_acc_uncertainty < 0 then
                report "";
                report "WARNING: Negative uncertainty detected - covariance overflow likely!" severity warning;
            end if;

            report "";
        end loop;

        report "========================================";
        report "5-CYCLE TEST COMPLETE - SUCCESS";
        report "========================================";

        wait;
    end process;

end Behavioral;
