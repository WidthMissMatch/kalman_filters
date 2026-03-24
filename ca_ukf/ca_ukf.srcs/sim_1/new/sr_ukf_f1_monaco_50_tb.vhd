library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity sr_ukf_ca_f1_monaco_50_tb is
end entity sr_ukf_ca_f1_monaco_50_tb;

architecture behavioral of sr_ukf_ca_f1_monaco_50_tb is
    component sr_ukf_supreme_ca_3d is
        port (
            clk, reset, start : in std_logic;
            z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);
            done : out std_logic;
            x_pos_current, x_vel_current, x_acc_current : out signed(47 downto 0);
            y_pos_current, y_vel_current, y_acc_current : out signed(47 downto 0);
            z_pos_current, z_vel_current, z_acc_current : out signed(47 downto 0);
            x_pos_uncertainty, x_vel_uncertainty, x_acc_uncertainty : out signed(47 downto 0);
            y_pos_uncertainty, y_vel_uncertainty, y_acc_uncertainty : out signed(47 downto 0);
            z_pos_uncertainty, z_vel_uncertainty, z_acc_uncertainty : out signed(47 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal start : std_logic := '0';
    signal done : std_logic;
    signal z_x_meas, z_y_meas, z_z_meas : signed(47 downto 0) := (others => '0');
    signal x_pos_current, x_vel_current, x_acc_current : signed(47 downto 0);
    signal y_pos_current, y_vel_current, y_acc_current : signed(47 downto 0);
    signal z_pos_current, z_vel_current, z_acc_current : signed(47 downto 0);
    signal x_pos_uncertainty, x_vel_uncertainty, x_acc_uncertainty : signed(47 downto 0);
    signal y_pos_uncertainty, y_vel_uncertainty, y_acc_uncertainty : signed(47 downto 0);
    signal z_pos_uncertainty, z_vel_uncertainty, z_acc_uncertainty : signed(47 downto 0);

    type meas_array_t is array (0 to 49) of signed(47 downto 0);

    constant meas_x_data : meas_array_t := (
        0 => to_signed(182696, 48),
        1 => to_signed(-360892, 48),
        2 => to_signed(-924169, 48),
        3 => to_signed(-1235038, 48),
        4 => to_signed(-1372689, 48),
        5 => to_signed(-1980918, 48),
        6 => to_signed(-2193744, 48),
        7 => to_signed(-2594090, 48),
        8 => to_signed(-3082733, 48),
        9 => to_signed(-2985395, 48),
        10 => to_signed(-3610412, 48),
        11 => to_signed(-4428205, 48),
        12 => to_signed(-4508765, 48),
        13 => to_signed(-5136937, 48),
        14 => to_signed(-5392914, 48),
        15 => to_signed(-6396363, 48),
        16 => to_signed(-7010122, 48),
        17 => to_signed(-7633621, 48),
        18 => to_signed(-8300566, 48),
        19 => to_signed(-9374664, 48),
        20 => to_signed(-9956879, 48),
        21 => to_signed(-10707913, 48),
        22 => to_signed(-11465313, 48),
        23 => to_signed(-11786980, 48),
        24 => to_signed(-12763289, 48),
        25 => to_signed(-13799658, 48),
        26 => to_signed(-14191008, 48),
        27 => to_signed(-14744351, 48),
        28 => to_signed(-15669125, 48),
        29 => to_signed(-16839205, 48),
        30 => to_signed(-17407492, 48),
        31 => to_signed(-17855652, 48),
        32 => to_signed(-18928886, 48),
        33 => to_signed(-19477652, 48),
        34 => to_signed(-20164104, 48),
        35 => to_signed(-21191533, 48),
        36 => to_signed(-22040991, 48),
        37 => to_signed(-23698086, 48),
        38 => to_signed(-24826831, 48),
        39 => to_signed(-26198017, 48),
        40 => to_signed(-27865662, 48),
        41 => to_signed(-28883121, 48),
        42 => to_signed(-30897608, 48),
        43 => to_signed(-32232173, 48),
        44 => to_signed(-33637087, 48),
        45 => to_signed(-34917891, 48),
        46 => to_signed(-36901270, 48),
        47 => to_signed(-37946992, 48),
        48 => to_signed(-39051682, 48),
        49 => to_signed(-39957762, 48)
    );

    constant meas_y_data : meas_array_t := (
        0 => to_signed(-317012, 48),
        1 => to_signed(-1284366, 48),
        2 => to_signed(-2823623, 48),
        3 => to_signed(-3891180, 48),
        4 => to_signed(-4706350, 48),
        5 => to_signed(-5910573, 48),
        6 => to_signed(-7179510, 48),
        7 => to_signed(-8621603, 48),
        8 => to_signed(-9675857, 48),
        9 => to_signed(-10876939, 48),
        10 => to_signed(-12279157, 48),
        11 => to_signed(-13041069, 48),
        12 => to_signed(-14487982, 48),
        13 => to_signed(-16071304, 48),
        14 => to_signed(-17498297, 48),
        15 => to_signed(-19562119, 48),
        16 => to_signed(-22033898, 48),
        17 => to_signed(-23827093, 48),
        18 => to_signed(-25994314, 48),
        19 => to_signed(-28142212, 48),
        20 => to_signed(-30115602, 48),
        21 => to_signed(-31861111, 48),
        22 => to_signed(-34149470, 48),
        23 => to_signed(-36447085, 48),
        24 => to_signed(-38373057, 48),
        25 => to_signed(-40362320, 48),
        26 => to_signed(-42569939, 48),
        27 => to_signed(-44827618, 48),
        28 => to_signed(-46919967, 48),
        29 => to_signed(-48668093, 48),
        30 => to_signed(-50693026, 48),
        31 => to_signed(-52582659, 48),
        32 => to_signed(-54600090, 48),
        33 => to_signed(-56504375, 48),
        34 => to_signed(-58744065, 48),
        35 => to_signed(-60407051, 48),
        36 => to_signed(-63121320, 48),
        37 => to_signed(-65613468, 48),
        38 => to_signed(-69719354, 48),
        39 => to_signed(-72954571, 48),
        40 => to_signed(-76854702, 48),
        41 => to_signed(-80639285, 48),
        42 => to_signed(-84253267, 48),
        43 => to_signed(-87867919, 48),
        44 => to_signed(-91385099, 48),
        45 => to_signed(-95010634, 48),
        46 => to_signed(-98836692, 48),
        47 => to_signed(-102335331, 48),
        48 => to_signed(-104086119, 48),
        49 => to_signed(-105835003, 48)
    );

    constant meas_z_data : meas_array_t := (
        0 => to_signed(182198, 48),
        1 => to_signed(-88613, 48),
        2 => to_signed(138184, 48),
        3 => to_signed(65542, 48),
        4 => to_signed(313624, 48),
        5 => to_signed(-30956, 48),
        6 => to_signed(-50763, 48),
        7 => to_signed(5891, 48),
        8 => to_signed(-40409, 48),
        9 => to_signed(145971, 48),
        10 => to_signed(-258102, 48),
        11 => to_signed(-162401, 48),
        12 => to_signed(-168742, 48),
        13 => to_signed(163608, 48),
        14 => to_signed(284146, 48),
        15 => to_signed(-34462, 48),
        16 => to_signed(-59354, 48),
        17 => to_signed(-33370, 48),
        18 => to_signed(135716, 48),
        19 => to_signed(-228890, 48),
        20 => to_signed(-47406, 48),
        21 => to_signed(62121, 48),
        22 => to_signed(-31512, 48),
        23 => to_signed(-97867, 48),
        24 => to_signed(27181, 48),
        25 => to_signed(-604102, 48),
        26 => to_signed(-46654, 48),
        27 => to_signed(-278972, 48),
        28 => to_signed(-476634, 48),
        29 => to_signed(-84007, 48),
        30 => to_signed(60422, 48),
        31 => to_signed(-193368, 48),
        32 => to_signed(-10710, 48),
        33 => to_signed(99652, 48),
        34 => to_signed(49495, 48),
        35 => to_signed(103762, 48),
        36 => to_signed(-45996, 48),
        37 => to_signed(-156554, 48),
        38 => to_signed(-437975, 48),
        39 => to_signed(-210492, 48),
        40 => to_signed(-310683, 48),
        41 => to_signed(195014, 48),
        42 => to_signed(-198719, 48),
        43 => to_signed(-148540, 48),
        44 => to_signed(-76686, 48),
        45 => to_signed(-161895, 48),
        46 => to_signed(115172, 48),
        47 => to_signed(-273684, 48),
        48 => to_signed(-136342, 48),
        49 => to_signed(-293185, 48)
    );

    constant CLK_PERIOD : time := 10 ns;
    constant NUM_CYCLES : integer := 50;

begin
    clk <= not clk after CLK_PERIOD/2;

    uut: sr_ukf_supreme_ca_3d
        port map (
            clk => clk, reset => reset, start => start,
            z_x_meas => z_x_meas, z_y_meas => z_y_meas, z_z_meas => z_z_meas,
            done => done,
            x_pos_current => x_pos_current, x_vel_current => x_vel_current, x_acc_current => x_acc_current,
            y_pos_current => y_pos_current, y_vel_current => y_vel_current, y_acc_current => y_acc_current,
            z_pos_current => z_pos_current, z_vel_current => z_vel_current, z_acc_current => z_acc_current,
            x_pos_uncertainty => x_pos_uncertainty, x_vel_uncertainty => x_vel_uncertainty, x_acc_uncertainty => x_acc_uncertainty,
            y_pos_uncertainty => y_pos_uncertainty, y_vel_uncertainty => y_vel_uncertainty, y_acc_uncertainty => y_acc_uncertainty,
            z_pos_uncertainty => z_pos_uncertainty, z_vel_uncertainty => z_vel_uncertainty, z_acc_uncertainty => z_acc_uncertainty
        );

    stim_proc: process
        file output_file : text open write_mode is "sr_vhdl_f1_monaco_50.txt";
        variable l : line;
    begin
        write(l, string'("=== SR-UKF F1 f1_monaco (50 cycles) ==="));
        writeline(output_file, l);
        write(l, string'("Cycles: " & integer'image(NUM_CYCLES)));
        writeline(output_file, l);
        write(l, string'(""));
        writeline(output_file, l);

        reset <= '1';
        wait for CLK_PERIOD * 5;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        for i in 0 to NUM_CYCLES-1 loop
            z_x_meas <= meas_x_data(i);
            z_y_meas <= meas_y_data(i);
            z_z_meas <= meas_z_data(i);
            wait for CLK_PERIOD;
            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';
            wait until done = '1';
            wait for CLK_PERIOD;

            write(l, string'("Cycle " & integer'image(i) & ": "));
            write(l, string'("x_pos=" & integer'image(to_integer(x_pos_current))));
            write(l, string'(" x_vel=" & integer'image(to_integer(x_vel_current))));
            write(l, string'(" x_acc=" & integer'image(to_integer(x_acc_current))));
            write(l, string'(" y_pos=" & integer'image(to_integer(y_pos_current))));
            write(l, string'(" y_vel=" & integer'image(to_integer(y_vel_current))));
            write(l, string'(" y_acc=" & integer'image(to_integer(y_acc_current))));
            write(l, string'(" z_pos=" & integer'image(to_integer(z_pos_current))));
            write(l, string'(" z_vel=" & integer'image(to_integer(z_vel_current))));
            write(l, string'(" z_acc=" & integer'image(to_integer(z_acc_current))));
            writeline(output_file, l);

            report "CYCLE " & integer'image(i) & " x=" & integer'image(to_integer(x_pos_current)) &
                   " y=" & integer'image(to_integer(y_pos_current)) &
                   " z=" & integer'image(to_integer(z_pos_current));
        end loop;

        write(l, string'(""));
        writeline(output_file, l);
        write(l, string'("=== Simulation Complete ==="));
        writeline(output_file, l);
        report "SIMULATION COMPLETE: " & integer'image(NUM_CYCLES) & " cycles";
        wait;
    end process;
end behavioral;
