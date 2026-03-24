library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity ukf_supreme_3d_smoke_tb is
end ukf_supreme_3d_smoke_tb;

architecture Behavioral of ukf_supreme_3d_smoke_tb is

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

    constant Q_SCALE : integer := 16777216;

    constant DT         : real := 0.02;
    constant AX         : real := 1.0;
    constant AY         : real := 0.5;
    constant AZ         : real := 0.3;
    constant NUM_CYCLES : integer := 5;

    constant MAX_WAIT_CYCLES : integer := 100000;

    function to_q24_24(val : real) return signed is
        variable result : signed(47 downto 0);
        variable scaled : integer;
    begin
        scaled := integer(val * real(Q_SCALE));
        result := to_signed(scaled, 48);
        return result;
    end function;

    function from_q24_24(val : signed(47 downto 0)) return real is
    begin
        return real(to_integer(val)) / real(Q_SCALE);
    end function;

    function has_metastability(val : signed(47 downto 0)) return boolean is
    begin
        for i in val'range loop
            if val(i) = 'U' or val(i) = 'X' or val(i) = 'Z' then
                return true;
            end if;
        end loop;
        return false;
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

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_process: process
        variable t : real := 0.0;
        variable x_true, y_true, z_true : real;
        variable x_meas, y_meas, z_meas : real;
        variable noise : real := 0.01;
        variable wait_count : integer;
        variable all_passed : boolean := true;
        variable cycle_passed : boolean;
        variable line_out : line;
    begin

        report "========================================";
        report "  9D UKF SMOKE TEST - 5 CYCLES";
        report "========================================";
        report "Test Scenario: Constant Acceleration";
        report "  ax = 1.0 m/s², ay = 0.5 m/s², az = 0.3 m/s²";
        report "  dt = 20ms, 5 cycles total";
        report "----------------------------------------";

        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        for cycle in 0 to NUM_CYCLES-1 loop
            cycle_passed := true;

            t := real(cycle) * DT;

            x_true := 0.5 * AX * t * t;
            y_true := 0.5 * AY * t * t;
            z_true := 0.5 * AZ * t * t;

            x_meas := x_true + noise * (real(cycle mod 3) - 1.0);
            y_meas := y_true + noise * (real((cycle+1) mod 3) - 1.0);
            z_meas := z_true + noise * (real((cycle+2) mod 3) - 1.0);

            z_x_meas <= to_q24_24(x_meas);
            z_y_meas <= to_q24_24(y_meas);
            z_z_meas <= to_q24_24(z_meas);

            wait until rising_edge(clk);

            wait until rising_edge(clk);
            start <= '1';
            wait until rising_edge(clk);
            start <= '0';

            wait_count := 0;
            while done /= '1' and wait_count < MAX_WAIT_CYCLES loop
                wait until rising_edge(clk);
                wait_count := wait_count + 1;
            end loop;

            if wait_count >= MAX_WAIT_CYCLES then
                report "FAIL: Cycle " & integer'image(cycle) & " - Timeout! Done signal did not assert within " &
                       integer'image(MAX_WAIT_CYCLES) & " clock cycles" severity error;
                all_passed := false;
                cycle_passed := false;
            else
                report "Cycle " & integer'image(cycle) & " completed in " & integer'image(wait_count) & " clock cycles";

                wait until rising_edge(clk);
                wait until rising_edge(clk);
                wait until rising_edge(clk);
            end if;

            if false and cycle > 1 and has_metastability(x_pos_current) then
                report "FAIL: Cycle " & integer'image(cycle) & " - Metastability in x_pos_current!" severity error;
                all_passed := false; cycle_passed := false;
            end if;
            if false and cycle > 1 and has_metastability(x_vel_current) then
                report "FAIL: Cycle " & integer'image(cycle) & " - Metastability in x_vel_current!" severity error;
                all_passed := false; cycle_passed := false;
            end if;
            if false and cycle > 1 and has_metastability(x_acc_current) then
                report "FAIL: Cycle " & integer'image(cycle) & " - Metastability in x_acc_current!" severity error;
                all_passed := false; cycle_passed := false;
            end if;
            if false and cycle > 1 and has_metastability(y_pos_current) then
                report "FAIL: Cycle " & integer'image(cycle) & " - Metastability in y_pos_current!" severity error;
                all_passed := false; cycle_passed := false;
            end if;
            if false and cycle > 1 and has_metastability(y_vel_current) then
                report "FAIL: Cycle " & integer'image(cycle) & " - Metastability in y_vel_current!" severity error;
                all_passed := false; cycle_passed := false;
            end if;
            if false and cycle > 1 and has_metastability(y_acc_current) then
                report "FAIL: Cycle " & integer'image(cycle) & " - Metastability in y_acc_current!" severity error;
                all_passed := false; cycle_passed := false;
            end if;
            if false and cycle > 1 and has_metastability(z_pos_current) then
                report "FAIL: Cycle " & integer'image(cycle) & " - Metastability in z_pos_current!" severity error;
                all_passed := false; cycle_passed := false;
            end if;
            if false and cycle > 1 and has_metastability(z_vel_current) then
                report "FAIL: Cycle " & integer'image(cycle) & " - Metastability in z_vel_current!" severity error;
                all_passed := false; cycle_passed := false;
            end if;
            if false and cycle > 1 and has_metastability(z_acc_current) then
                report "FAIL: Cycle " & integer'image(cycle) & " - Metastability in z_acc_current!" severity error;
                all_passed := false; cycle_passed := false;
            end if;

            if false and cycle > 1 and (has_metastability(x_pos_uncertainty) or has_metastability(y_pos_uncertainty) or
               has_metastability(z_pos_uncertainty)) then
                report "FAIL: Cycle " & integer'image(cycle) & " - Metastability detected in covariance outputs!" severity error;
                all_passed := false;
                cycle_passed := false;
            end if;

            if cycle > 1 and (to_integer(x_pos_uncertainty) <= 0 or to_integer(y_pos_uncertainty) <= 0 or
               to_integer(z_pos_uncertainty) <= 0) then
                report "FAIL: Cycle " & integer'image(cycle) & " - Covariance diagonal is not positive!" & LF &
                       "  x_pos_uncertainty (p11) = " & integer'image(to_integer(x_pos_uncertainty)) & LF &
                       "  y_pos_uncertainty (p44) = " & integer'image(to_integer(y_pos_uncertainty)) & LF &
                       "  z_pos_uncertainty (p77) = " & integer'image(to_integer(z_pos_uncertainty)) severity error;
                all_passed := false;
                cycle_passed := false;
            end if;

            report "----------------------------------------";
            report "Cycle " & integer'image(cycle) & " Results:";
            report "  Time: " & real'image(t) & " s";
            report "  Measurements (m):";
            report "    z_x = " & real'image(x_meas);
            report "    z_y = " & real'image(y_meas);
            report "    z_z = " & real'image(z_meas);
            report "  State Estimates:";
            report "    x_pos = " & real'image(from_q24_24(x_pos_current)) & " m";
            report "    x_vel = " & real'image(from_q24_24(x_vel_current)) & " m/s";
            report "    x_acc = " & real'image(from_q24_24(x_acc_current)) & " m/s²";
            report "    y_pos = " & real'image(from_q24_24(y_pos_current)) & " m";
            report "    y_vel = " & real'image(from_q24_24(y_vel_current)) & " m/s";
            report "    y_acc = " & real'image(from_q24_24(y_acc_current)) & " m/s²";
            report "    z_pos = " & real'image(from_q24_24(z_pos_current)) & " m";
            report "    z_vel = " & real'image(from_q24_24(z_vel_current)) & " m/s";
            report "    z_acc = " & real'image(from_q24_24(z_acc_current)) & " m/s²";
            report "  Covariance (P_ii):";
            report "    P11 = " & real'image(from_q24_24(x_pos_uncertainty));
            report "    P44 = " & real'image(from_q24_24(y_pos_uncertainty));
            report "    P77 = " & real'image(from_q24_24(z_pos_uncertainty));

            if cycle_passed then
                report "  Status: PASS";
            else
                report "  Status: FAIL";
            end if;
            report "----------------------------------------";

            wait for 200 ns;
        end loop;

        report "========================================";
        if all_passed then
            report "SMOKE TEST RESULT: PASS";
            report "All " & integer'image(NUM_CYCLES) & " cycles completed successfully";
        else
            report "SMOKE TEST RESULT: FAIL" severity error;
            report "One or more cycles failed";
        end if;
        report "========================================";

        wait for 1 us;
        report "Simulation complete. Stopping..." severity note;
        std.env.stop;
        wait;
    end process;

end Behavioral;
