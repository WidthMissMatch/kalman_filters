library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity cv_ukf_10cycle_tb is
end cv_ukf_10cycle_tb;

architecture Behavioral of cv_ukf_10cycle_tb is

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
    end component;

    signal clk   : std_logic := '0';
    signal reset : std_logic := '0';
    signal start : std_logic := '0';
    signal done  : std_logic;

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
    constant SCALE : real := 16777216.0;

    type meas_array is array(0 to 9) of signed(47 downto 0);

    constant meas_x : meas_array := (
        to_signed(integer( 0.3  * 16777216.0), 48),
        to_signed(integer( 0.5  * 16777216.0), 48),
        to_signed(integer( 0.3  * 16777216.0), 48),
        to_signed(integer( 0.8  * 16777216.0), 48),
        to_signed(integer( 0.7  * 16777216.0), 48),
        to_signed(integer( 1.2  * 16777216.0), 48),
        to_signed(integer( 1.1  * 16777216.0), 48),
        to_signed(integer( 1.5  * 16777216.0), 48),
        to_signed(integer( 1.7  * 16777216.0), 48),
        to_signed(integer( 1.9  * 16777216.0), 48)
    );

    constant meas_y : meas_array := (
        to_signed(integer(-0.2  * 16777216.0), 48),
        to_signed(integer(-0.1  * 16777216.0), 48),
        to_signed(integer( 0.3  * 16777216.0), 48),
        to_signed(integer( 0.2  * 16777216.0), 48),
        to_signed(integer( 0.5  * 16777216.0), 48),
        to_signed(integer( 0.4  * 16777216.0), 48),
        to_signed(integer( 0.7  * 16777216.0), 48),
        to_signed(integer( 0.6  * 16777216.0), 48),
        to_signed(integer( 0.9  * 16777216.0), 48),
        to_signed(integer( 0.8  * 16777216.0), 48)
    );

    constant meas_z : meas_array := (
        to_signed(integer( 0.1  * 16777216.0), 48),
        to_signed(integer( 0.15 * 16777216.0), 48),
        to_signed(integer( 0.05 * 16777216.0), 48),
        to_signed(integer( 0.25 * 16777216.0), 48),
        to_signed(integer( 0.15 * 16777216.0), 48),
        to_signed(integer( 0.30 * 16777216.0), 48),
        to_signed(integer( 0.25 * 16777216.0), 48),
        to_signed(integer( 0.40 * 16777216.0), 48),
        to_signed(integer( 0.35 * 16777216.0), 48),
        to_signed(integer( 0.50 * 16777216.0), 48)
    );

    constant true_x : meas_array := (
        to_signed(integer( 0.0  * 16777216.0), 48),
        to_signed(integer( 0.2  * 16777216.0), 48),
        to_signed(integer( 0.4  * 16777216.0), 48),
        to_signed(integer( 0.6  * 16777216.0), 48),
        to_signed(integer( 0.8  * 16777216.0), 48),
        to_signed(integer( 1.0  * 16777216.0), 48),
        to_signed(integer( 1.2  * 16777216.0), 48),
        to_signed(integer( 1.4  * 16777216.0), 48),
        to_signed(integer( 1.6  * 16777216.0), 48),
        to_signed(integer( 1.8  * 16777216.0), 48)
    );

    constant true_y : meas_array := (
        to_signed(integer( 0.0  * 16777216.0), 48),
        to_signed(integer( 0.1  * 16777216.0), 48),
        to_signed(integer( 0.2  * 16777216.0), 48),
        to_signed(integer( 0.3  * 16777216.0), 48),
        to_signed(integer( 0.4  * 16777216.0), 48),
        to_signed(integer( 0.5  * 16777216.0), 48),
        to_signed(integer( 0.6  * 16777216.0), 48),
        to_signed(integer( 0.7  * 16777216.0), 48),
        to_signed(integer( 0.8  * 16777216.0), 48),
        to_signed(integer( 0.9  * 16777216.0), 48)
    );

    constant true_z : meas_array := (
        to_signed(integer( 0.0  * 16777216.0), 48),
        to_signed(integer( 0.05 * 16777216.0), 48),
        to_signed(integer( 0.10 * 16777216.0), 48),
        to_signed(integer( 0.15 * 16777216.0), 48),
        to_signed(integer( 0.20 * 16777216.0), 48),
        to_signed(integer( 0.25 * 16777216.0), 48),
        to_signed(integer( 0.30 * 16777216.0), 48),
        to_signed(integer( 0.35 * 16777216.0), 48),
        to_signed(integer( 0.40 * 16777216.0), 48),
        to_signed(integer( 0.45 * 16777216.0), 48)
    );

    file output_file : text;

begin

    uut : ukf_supreme_3d
        port map (
            clk => clk, reset => reset, start => start,
            z_x_meas => z_x_meas, z_y_meas => z_y_meas, z_z_meas => z_z_meas,
            x_pos_current => x_pos_current, x_vel_current => x_vel_current,
            y_pos_current => y_pos_current, y_vel_current => y_vel_current,
            z_pos_current => z_pos_current, z_vel_current => z_vel_current,
            x_pos_uncertainty => x_pos_uncertainty, x_vel_uncertainty => x_vel_uncertainty,
            y_pos_uncertainty => y_pos_uncertainty, y_vel_uncertainty => y_vel_uncertainty,
            z_pos_uncertainty => z_pos_uncertainty, z_vel_uncertainty => z_vel_uncertainty,
            done => done
        );

    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    stim_process : process
        variable l : line;
        variable err_x, err_y, err_z : signed(47 downto 0);
        variable cycle_count : integer := 0;
        variable all_done_ok : boolean := true;
    begin
        file_open(output_file, "cv_ukf_10cycle_output.txt", write_mode);

        write(l, string'("=== CV UKF 3D - 10 Cycle Test ==="));
        writeline(output_file, l);
        write(l, string'("Trajectory: vx=2 m/s, vy=1 m/s, vz=0.5 m/s, dt=0.1s"));
        writeline(output_file, l);
        write(l, string'("Format: Q24.24 fixed-point (scale=16777216)"));
        writeline(output_file, l);
        write(l, string'(""));
        writeline(output_file, l);

        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 50 ns;
        wait until rising_edge(clk);

        report "========================================";
        report "CV UKF 3D: Starting 10-cycle test";
        report "========================================";

        for i in 0 to 9 loop

            z_x_meas <= meas_x(i);
            z_y_meas <= meas_y(i);
            z_z_meas <= meas_z(i);

            start <= '1';
            wait until rising_edge(clk);
            start <= '0';

            cycle_count := 0;
            wait until done = '1' for 500 us;
            if done /= '1' then
                report "ERROR: Cycle " & integer'image(i) & " TIMED OUT after 500us!" severity error;
                all_done_ok := false;

                write(l, string'("Cycle ") & integer'image(i) & string'(": TIMEOUT"));
                writeline(output_file, l);

                reset <= '1';
                wait for 100 ns;
                reset <= '0';
                wait for 50 ns;
                wait until rising_edge(clk);
                next;
            end if;

            wait for CLK_PERIOD;

            err_x := x_pos_current - true_x(i);
            err_y := y_pos_current - true_y(i);
            err_z := z_pos_current - true_z(i);

            report "--- Cycle " & integer'image(i) & " COMPLETE ---";
            report "  Meas:     x=" & integer'image(to_integer(meas_x(i))) &
                   "  y=" & integer'image(to_integer(meas_y(i))) &
                   "  z=" & integer'image(to_integer(meas_z(i)));
            report "  Estimate: x=" & integer'image(to_integer(x_pos_current)) &
                   "  y=" & integer'image(to_integer(y_pos_current)) &
                   "  z=" & integer'image(to_integer(z_pos_current));
            report "  Velocity: vx=" & integer'image(to_integer(x_vel_current)) &
                   "  vy=" & integer'image(to_integer(y_vel_current)) &
                   "  vz=" & integer'image(to_integer(z_vel_current));
            report "  Error:    ex=" & integer'image(to_integer(err_x)) &
                   "  ey=" & integer'image(to_integer(err_y)) &
                   "  ez=" & integer'image(to_integer(err_z));
            report "  P_diag:   P11=" & integer'image(to_integer(x_pos_uncertainty)) &
                   "  P33=" & integer'image(to_integer(y_pos_uncertainty)) &
                   "  P55=" & integer'image(to_integer(z_pos_uncertainty));

            write(l, string'("CYCLE ") & integer'image(i));
            writeline(output_file, l);
            write(l, string'("  EST_X=") & integer'image(to_integer(x_pos_current)) &
                     string'("  EST_Y=") & integer'image(to_integer(y_pos_current)) &
                     string'("  EST_Z=") & integer'image(to_integer(z_pos_current)));
            writeline(output_file, l);
            write(l, string'("  VEL_X=") & integer'image(to_integer(x_vel_current)) &
                     string'("  VEL_Y=") & integer'image(to_integer(y_vel_current)) &
                     string'("  VEL_Z=") & integer'image(to_integer(z_vel_current)));
            writeline(output_file, l);
            write(l, string'("  ERR_X=") & integer'image(to_integer(err_x)) &
                     string'("  ERR_Y=") & integer'image(to_integer(err_y)) &
                     string'("  ERR_Z=") & integer'image(to_integer(err_z)));
            writeline(output_file, l);
            write(l, string'("  P11=") & integer'image(to_integer(x_pos_uncertainty)) &
                     string'("  P33=") & integer'image(to_integer(y_pos_uncertainty)) &
                     string'("  P55=") & integer'image(to_integer(z_pos_uncertainty)));
            writeline(output_file, l);
            write(l, string'(""));
            writeline(output_file, l);

            wait for CLK_PERIOD * 5;
        end loop;

        report "========================================";
        if all_done_ok then
            report "CV UKF 3D: ALL 10 CYCLES COMPLETED OK";
        else
            report "CV UKF 3D: SOME CYCLES FAILED" severity warning;
        end if;
        report "========================================";

        write(l, string'("=== TEST COMPLETE ==="));
        writeline(output_file, l);
        if all_done_ok then
            write(l, string'("RESULT: ALL 10 CYCLES PASSED"));
        else
            write(l, string'("RESULT: SOME CYCLES FAILED"));
        end if;
        writeline(output_file, l);

        file_close(output_file);

        assert false report "Simulation finished." severity failure;
        wait;
    end process;

end Behavioral;
