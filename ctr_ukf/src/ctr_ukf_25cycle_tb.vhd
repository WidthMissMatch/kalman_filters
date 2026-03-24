library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity ctr_ukf_25cycle_tb is
end ctr_ukf_25cycle_tb;

architecture Behavioral of ctr_ukf_25cycle_tb is

    component ukf_supreme_3d is
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            start : in  std_logic;
            z_x_meas : in signed(47 downto 0);
            z_y_meas : in signed(47 downto 0);
            z_z_meas : in signed(47 downto 0);
            x_pos_current   : out signed(47 downto 0);
            x_vel_current   : out signed(47 downto 0);
            x_omega_current : out signed(47 downto 0);
            y_pos_current   : out signed(47 downto 0);
            y_vel_current   : out signed(47 downto 0);
            y_omega_current : out signed(47 downto 0);
            z_pos_current   : out signed(47 downto 0);
            z_vel_current   : out signed(47 downto 0);
            z_omega_current : out signed(47 downto 0);
            x_pos_uncertainty   : out signed(47 downto 0);
            x_vel_uncertainty   : out signed(47 downto 0);
            x_omega_uncertainty : out signed(47 downto 0);
            y_pos_uncertainty   : out signed(47 downto 0);
            y_vel_uncertainty   : out signed(47 downto 0);
            y_omega_uncertainty : out signed(47 downto 0);
            z_pos_uncertainty   : out signed(47 downto 0);
            z_vel_uncertainty   : out signed(47 downto 0);
            z_omega_uncertainty : out signed(47 downto 0);
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

    signal x_pos_current, x_vel_current, x_omega_current : signed(47 downto 0);
    signal y_pos_current, y_vel_current, y_omega_current : signed(47 downto 0);
    signal z_pos_current, z_vel_current, z_omega_current : signed(47 downto 0);

    signal x_pos_uncertainty, x_vel_uncertainty, x_omega_uncertainty : signed(47 downto 0);
    signal y_pos_uncertainty, y_vel_uncertainty, y_omega_uncertainty : signed(47 downto 0);
    signal z_pos_uncertainty, z_vel_uncertainty, z_omega_uncertainty : signed(47 downto 0);

    constant CLK_PERIOD : time := 10 ns;
    constant NUM_CYCLES : integer := 25;

    type meas_array is array(0 to NUM_CYCLES-1) of signed(47 downto 0);

    constant meas_x : meas_array := (
        signed'(X"0000004CCCCD"),
        signed'(X"000000CCCBB5"),
        signed'(X"0000021990DD"),
        signed'(X"000002B315B6"),
        signed'(X"00000432ED4D"),
        signed'(X"000004E5DDE2"),
        signed'(X"0000064BE0EA"),
        signed'(X"000006CB563F"),
        signed'(X"000008176A8A"),
        signed'(X"000008B01743"),
        signed'(X"00000A2EEF7B"),
        signed'(X"00000AE0B979"),
        signed'(X"00000C456EB9"),
        signed'(X"00000CC36F1E"),
        signed'(X"00000E0DE75B"),
        signed'(X"00000EA4D0F2"),
        signed'(X"00001021BF00"),
        signed'(X"000010D177D8"),
        signed'(X"00001233F503"),
        signed'(X"000012AF9674"),
        signed'(X"000013F788ED"),
        signed'(X"0000148BC600"),
        signed'(X"00001605E0DC"),
        signed'(X"000016B29FE6"),
        signed'(X"00001811FCBC")
    );

    constant meas_y : meas_array := (
        signed'(X"FFFFFFCCCCCD"),
        signed'(X"0000001AE147"),
        signed'(X"FFFFFFB851E0"),
        signed'(X"0000003EB819"),
        signed'(X"FFFFFFFAE095"),
        signed'(X"0000006CCB18"),
        signed'(X"FFFFFFFADDBE"),
        signed'(X"000000584B5D"),
        signed'(X"00000005138A"),
        signed'(X"0000009ACF5E"),
        signed'(X"000000664B1A"),
        signed'(X"000000E7861E"),
        signed'(X"00000084E620"),
        signed'(X"000000F19D93"),
        signed'(X"000000ADABA6"),
        signed'(X"00000152A910"),
        signed'(X"0000012D61AD"),
        signed'(X"000001BDD479"),
        signed'(X"0000016A66C6"),
        signed'(X"000001E64AA5"),
        signed'(X"000001B17EE0"),
        signed'(X"000002659BCC"),
        signed'(X"0000024F6CE0"),
        signed'(X"000002EEF0B7"),
        signed'(X"000002AA8C3F")
    );

    constant meas_z : meas_array := (
        signed'(X"00000019999A"),
        signed'(X"FFFFFFF0A3D7"),
        signed'(X"00000047AE14"),
        signed'(X"FFFFFFEB851F"),
        signed'(X"000000428F5C"),
        signed'(X"00000019999A"),
        signed'(X"00000070A3D7"),
        signed'(X"000000147AE1"),
        signed'(X"0000006B851F"),
        signed'(X"000000428F5C"),
        signed'(X"00000099999A"),
        signed'(X"0000003D70A4"),
        signed'(X"000000947AE1"),
        signed'(X"0000006B851F"),
        signed'(X"000000C28F5C"),
        signed'(X"000000666666"),
        signed'(X"000000BD70A4"),
        signed'(X"000000947AE1"),
        signed'(X"000000EB851F"),
        signed'(X"0000008F5C29"),
        signed'(X"000000E66666"),
        signed'(X"000000BD70A4"),
        signed'(X"000001147AE1"),
        signed'(X"000000B851EC"),
        signed'(X"0000010F5C29")
    );

    constant true_x : meas_array := (
        signed'(X"000000000000"),
        signed'(X"000000FFFEE8"),
        signed'(X"000001FFF743"),
        signed'(X"000002FFE283"),
        signed'(X"000003FFBA1A"),
        signed'(X"000004FF777C"),
        signed'(X"000005FF141D"),
        signed'(X"000006FE8972"),
        signed'(X"000007FDD0F0"),
        signed'(X"000008FCE40F"),
        signed'(X"000009FBBC48"),
        signed'(X"00000AFA5313"),
        signed'(X"00000BF8A1EC"),
        signed'(X"00000CF6A251"),
        signed'(X"00000DF44DC2"),
        signed'(X"00000EF19DBF"),
        signed'(X"00000FEE8BCD"),
        signed'(X"000010EB1171"),
        signed'(X"000011E72836"),
        signed'(X"000012E2C9A7"),
        signed'(X"000013DDEF54"),
        signed'(X"000014D892CD"),
        signed'(X"000015D2ADA8"),
        signed'(X"000016CC3980"),
        signed'(X"000017C52FEF")
    );

    constant true_y : meas_array := (
        signed'(X"000000000000"),
        signed'(X"0000000147AD"),
        signed'(X"000000051EAD"),
        signed'(X"0000000B84E6"),
        signed'(X"000000147A2E"),
        signed'(X"0000001FFE4B"),
        signed'(X"0000002E10F1"),
        signed'(X"0000003EB1C4"),
        signed'(X"00000051E056"),
        signed'(X"000000679C2B"),
        signed'(X"0000007FE4B4"),
        signed'(X"0000009AB951"),
        signed'(X"000000B81953"),
        signed'(X"000000D803F9"),
        signed'(X"000000FA7872"),
        signed'(X"0000011F75DD"),
        signed'(X"00000146FB47"),
        signed'(X"0000017107AC"),
        signed'(X"0000019D99FA"),
        signed'(X"000001CCB10B"),
        signed'(X"000001FE4BAD"),
        signed'(X"000002326899"),
        signed'(X"00000269067A"),
        signed'(X"000002A223EA"),
        signed'(X"000002DDBF73")
    );

    constant true_z : meas_array := (
        signed'(X"000000000000"),
        signed'(X"0000000A3D71"),
        signed'(X"000000147AE1"),
        signed'(X"0000001EB852"),
        signed'(X"00000028F5C3"),
        signed'(X"000000333333"),
        signed'(X"0000003D70A4"),
        signed'(X"00000047AE14"),
        signed'(X"00000051EB85"),
        signed'(X"0000005C28F6"),
        signed'(X"000000666666"),
        signed'(X"00000070A3D7"),
        signed'(X"0000007AE148"),
        signed'(X"000000851EB8"),
        signed'(X"0000008F5C29"),
        signed'(X"00000099999A"),
        signed'(X"000000A3D70A"),
        signed'(X"000000AE147B"),
        signed'(X"000000B851EC"),
        signed'(X"000000C28F5C"),
        signed'(X"000000CCCCCD"),
        signed'(X"000000D70A3D"),
        signed'(X"000000E147AE"),
        signed'(X"000000EB851F"),
        signed'(X"000000F5C28F")
    );

    file output_file : text;

begin

    uut : ukf_supreme_3d
        port map (
            clk => clk, reset => reset, start => start,
            z_x_meas => z_x_meas, z_y_meas => z_y_meas, z_z_meas => z_z_meas,
            x_pos_current => x_pos_current, x_vel_current => x_vel_current, x_omega_current => x_omega_current,
            y_pos_current => y_pos_current, y_vel_current => y_vel_current, y_omega_current => y_omega_current,
            z_pos_current => z_pos_current, z_vel_current => z_vel_current, z_omega_current => z_omega_current,
            x_pos_uncertainty => x_pos_uncertainty, x_vel_uncertainty => x_vel_uncertainty, x_omega_uncertainty => x_omega_uncertainty,
            y_pos_uncertainty => y_pos_uncertainty, y_vel_uncertainty => y_vel_uncertainty, y_omega_uncertainty => y_omega_uncertainty,
            z_pos_uncertainty => z_pos_uncertainty, z_vel_uncertainty => z_vel_uncertainty, z_omega_uncertainty => z_omega_uncertainty,
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
        variable all_done_ok : boolean := true;
        variable timeout_count : integer;
    begin
        file_open(output_file, "vhdl_output_ctr_25cycles.txt", write_mode);

        write(l, string'("=== CTR UKF 3D - 25 Cycle Helical Turn Test ==="));
        writeline(output_file, l);
        write(l, string'("Trajectory: R=100m, omega=0.5 rad/s, vz=2.0 m/s, dt=0.02s"));
        writeline(output_file, l);
        write(l, string'("State: [x_pos, x_vel, x_omega, y_pos, y_vel, y_omega, z_pos, z_vel, z_omega]"));
        writeline(output_file, l);
        write(l, string'("Format: Q24.24 fixed-point (scale=16777216)"));
        writeline(output_file, l);
        write(l, string'(""));
        writeline(output_file, l);

        reset <= '1';
        for r in 0 to 4 loop
            wait until rising_edge(clk);
        end loop;
        reset <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        report "========================================";
        report "CTR UKF 3D: Starting 25-cycle helical turn test";
        report "  R=100m, omega=0.5 rad/s, vz=2.0 m/s, dt=0.02s";
        report "  omega_z true = 0x000000800000 (0.5 rad/s)";
        report "========================================";

        for i in 0 to NUM_CYCLES-1 loop

            z_x_meas <= meas_x(i);
            z_y_meas <= meas_y(i);
            z_z_meas <= meas_z(i);

            start <= '1';
            wait until rising_edge(clk);
            start <= '0';

            timeout_count := 0;
            while done /= '1' and timeout_count < 100000 loop
                wait until rising_edge(clk);
                timeout_count := timeout_count + 1;
            end loop;

            if done /= '1' then
                report "ERROR: Cycle " & integer'image(i) & " TIMED OUT after 100000 clocks!" severity error;
                all_done_ok := false;
                write(l, string'("Cycle ") & integer'image(i) & string'(": TIMEOUT"));
                writeline(output_file, l);

                reset <= '1';
                for r in 0 to 4 loop
                    wait until rising_edge(clk);
                end loop;
                reset <= '0';
                wait until rising_edge(clk);
                wait until rising_edge(clk);
                next;
            end if;

            wait for CLK_PERIOD;

            err_x := x_pos_current - true_x(i);
            err_y := y_pos_current - true_y(i);
            err_z := z_pos_current - true_z(i);

            report "--- Cycle " & integer'image(i) & " (clks=" & integer'image(timeout_count) & ") ---" &
                   "  est_x=" & integer'image(to_integer(x_pos_current)) &
                   "  est_y=" & integer'image(to_integer(y_pos_current)) &
                   "  est_z=" & integer'image(to_integer(z_pos_current)) &
                   "  omega_x=" & integer'image(to_integer(x_omega_current)) &
                   "  omega_y=" & integer'image(to_integer(y_omega_current)) &
                   "  omega_z=" & integer'image(to_integer(z_omega_current));

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
            write(l, string'("  OMEGA_X=") & integer'image(to_integer(x_omega_current)) &
                     string'("  OMEGA_Y=") & integer'image(to_integer(y_omega_current)) &
                     string'("  OMEGA_Z=") & integer'image(to_integer(z_omega_current)));
            writeline(output_file, l);
            write(l, string'("  ERR_X=") & integer'image(to_integer(err_x)) &
                     string'("  ERR_Y=") & integer'image(to_integer(err_y)) &
                     string'("  ERR_Z=") & integer'image(to_integer(err_z)));
            writeline(output_file, l);
            write(l, string'("  P_xpos=") & integer'image(to_integer(x_pos_uncertainty)) &
                     string'("  P_xvel=") & integer'image(to_integer(x_vel_uncertainty)) &
                     string'("  P_xomg=") & integer'image(to_integer(x_omega_uncertainty)) &
                     string'("  P_ypos=") & integer'image(to_integer(y_pos_uncertainty)) &
                     string'("  P_yvel=") & integer'image(to_integer(y_vel_uncertainty)) &
                     string'("  P_yomg=") & integer'image(to_integer(y_omega_uncertainty)) &
                     string'("  P_zpos=") & integer'image(to_integer(z_pos_uncertainty)) &
                     string'("  P_zvel=") & integer'image(to_integer(z_vel_uncertainty)) &
                     string'("  P_zomg=") & integer'image(to_integer(z_omega_uncertainty)));
            writeline(output_file, l);
            write(l, string'(""));
            writeline(output_file, l);

            wait for CLK_PERIOD * 5;
        end loop;

        report "========================================";
        if all_done_ok then
            report "CTR UKF 3D: ALL 25 CYCLES COMPLETED OK";
        else
            report "CTR UKF 3D: SOME CYCLES FAILED" severity warning;
        end if;
        report "========================================";

        write(l, string'("=== TEST COMPLETE ==="));
        writeline(output_file, l);
        if all_done_ok then
            write(l, string'("RESULT: ALL 25 CYCLES PASSED"));
        else
            write(l, string'("RESULT: SOME CYCLES FAILED"));
        end if;
        writeline(output_file, l);

        file_close(output_file);
        std.env.stop;
        wait;
    end process;

end Behavioral;
