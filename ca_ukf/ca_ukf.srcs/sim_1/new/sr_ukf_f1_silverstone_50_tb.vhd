library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity sr_ukf_ca_f1_silverstone_50_tb is
end entity sr_ukf_ca_f1_silverstone_50_tb;

architecture behavioral of sr_ukf_ca_f1_silverstone_50_tb is
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
        0 => to_signed(8333481, 48),
        1 => to_signed(134929687, 48),
        2 => to_signed(285365164, 48),
        3 => to_signed(437300331, 48),
        4 => to_signed(545069065, 48),
        5 => to_signed(676811505, 48),
        6 => to_signed(819595152, 48),
        7 => to_signed(912233928, 48),
        8 => to_signed(997740189, 48),
        9 => to_signed(1120977461, 48),
        10 => to_signed(1210358108, 48),
        11 => to_signed(1316577470, 48),
        12 => to_signed(1434708724, 48),
        13 => to_signed(1504807907, 48),
        14 => to_signed(1604998052, 48),
        15 => to_signed(1700001224, 48),
        16 => to_signed(1767939829, 48),
        17 => to_signed(1865701983, 48),
        18 => to_signed(1920693143, 48),
        19 => to_signed(1987730207, 48),
        20 => to_signed(2111511709, 48),
        21 => signed'(x"000080AA1B62"),
        22 => signed'(x"000085753163"),
        23 => signed'(x"000088772B8F"),
        24 => signed'(x"00008DD88B31"),
        25 => signed'(x"000093004D48"),
        26 => signed'(x"0000963D4058"),
        27 => signed'(x"00009C44159A"),
        28 => signed'(x"00009F8746BF"),
        29 => signed'(x"0000A3777AE9"),
        30 => signed'(x"0000A6520CF2"),
        31 => signed'(x"0000ABA0C042"),
        32 => signed'(x"0000AC9D97C4"),
        33 => signed'(x"0000AE6CC124"),
        34 => signed'(x"0000B328948E"),
        35 => signed'(x"0000B3F7F402"),
        36 => signed'(x"0000B8407044"),
        37 => signed'(x"0000B88E7BFC"),
        38 => signed'(x"0000B970C1B1"),
        39 => signed'(x"0000BA5411A8"),
        40 => signed'(x"0000BA3B9EC4"),
        41 => signed'(x"0000B90757E1"),
        42 => signed'(x"0000B81AC46D"),
        43 => signed'(x"0000B74830E2"),
        44 => signed'(x"0000B577AC10"),
        45 => signed'(x"0000B596CB3C"),
        46 => signed'(x"0000B5360CFC"),
        47 => signed'(x"0000B6177F6F"),
        48 => signed'(x"0000B4BDBDB5"),
        49 => signed'(x"0000B1FF5634")
    );

    constant meas_y_data : meas_array_t := (
        0 => to_signed(-15489284, 48),
        1 => to_signed(-255123428, 48),
        2 => to_signed(-481264283, 48),
        3 => to_signed(-679660594, 48),
        4 => to_signed(-945711963, 48),
        5 => to_signed(-1112846333, 48),
        6 => to_signed(-1356149773, 48),
        7 => to_signed(-1561995863, 48),
        8 => to_signed(-1780168378, 48),
        9 => to_signed(-1954688899, 48),
        10 => signed'(x"FFFF7E412E5A"),
        11 => signed'(x"FFFF72FDC9C2"),
        12 => signed'(x"FFFF6977F1CB"),
        13 => signed'(x"FFFF5AD9FB15"),
        14 => signed'(x"FFFF5009D987"),
        15 => signed'(x"FFFF41E67ACF"),
        16 => signed'(x"FFFF3648649A"),
        17 => signed'(x"FFFF2BCD883A"),
        18 => signed'(x"FFFF1D1E8F8D"),
        19 => signed'(x"FFFF1345E886"),
        20 => signed'(x"FFFF05E1F68E"),
        21 => signed'(x"FFFEF853A4EE"),
        22 => signed'(x"FFFEED3C63A7"),
        23 => signed'(x"FFFEE14A52F0"),
        24 => signed'(x"FFFED4A763FA"),
        25 => signed'(x"FFFEC62D1638"),
        26 => signed'(x"FFFEBABBC63B"),
        27 => signed'(x"FFFEAEED69F1"),
        28 => signed'(x"FFFEA03EC440"),
        29 => signed'(x"FFFE8C16DB55"),
        30 => signed'(x"FFFE75C7EE89"),
        31 => signed'(x"FFFE5DB9F4C3"),
        32 => signed'(x"FFFE48E67FB3"),
        33 => signed'(x"FFFE3296D790"),
        34 => signed'(x"FFFE1BFF33CF"),
        35 => signed'(x"FFFE05F9F097"),
        36 => signed'(x"FFFDEF301BA1"),
        37 => signed'(x"FFFDDA345099"),
        38 => signed'(x"FFFDCF832C0F"),
        39 => signed'(x"FFFDC7B776F0"),
        40 => signed'(x"FFFDC39A305D"),
        41 => signed'(x"FFFDBD2CE928"),
        42 => signed'(x"FFFDB708CD8F"),
        43 => signed'(x"FFFDAF47F79B"),
        44 => signed'(x"FFFDA94599B6"),
        45 => signed'(x"FFFDA5337E7E"),
        46 => signed'(x"FFFD9DE74C03"),
        47 => signed'(x"FFFD986B6C5C"),
        48 => signed'(x"FFFD918FBEA3"),
        49 => signed'(x"FFFD8B5BA618")
    );

    constant meas_z_data : meas_array_t := (
        0 => to_signed(13058732, 48),
        1 => to_signed(-11680712, 48),
        2 => to_signed(-18593799, 48),
        3 => to_signed(-7356664, 48),
        4 => to_signed(-12588624, 48),
        5 => to_signed(-20111715, 48),
        6 => to_signed(-4428351, 48),
        7 => to_signed(-3819200, 48),
        8 => to_signed(-22098109, 48),
        9 => to_signed(-2527257, 48),
        10 => to_signed(-50205231, 48),
        11 => to_signed(-38034701, 48),
        12 => to_signed(-50546686, 48),
        13 => to_signed(-73570459, 48),
        14 => to_signed(-46975684, 48),
        15 => to_signed(-50027862, 48),
        16 => to_signed(-24990549, 48),
        17 => to_signed(-42195504, 48),
        18 => to_signed(-72358517, 48),
        19 => to_signed(-26465747, 48),
        20 => to_signed(-39483457, 48),
        21 => to_signed(-52599769, 48),
        22 => to_signed(-68562266, 48),
        23 => to_signed(-83255958, 48),
        24 => to_signed(-75800577, 48),
        25 => to_signed(-53686558, 48),
        26 => to_signed(-42731363, 48),
        27 => to_signed(-50854889, 48),
        28 => to_signed(-88089983, 48),
        29 => to_signed(-103554212, 48),
        30 => to_signed(-87813896, 48),
        31 => to_signed(-125604977, 48),
        32 => to_signed(-96271546, 48),
        33 => to_signed(-109927673, 48),
        34 => to_signed(-121028020, 48),
        35 => to_signed(-145721815, 48),
        36 => to_signed(-116108270, 48),
        37 => to_signed(-139019848, 48),
        38 => to_signed(-152757881, 48),
        39 => to_signed(-183448430, 48),
        40 => to_signed(-137851424, 48),
        41 => to_signed(-109786286, 48),
        42 => to_signed(-113778362, 48),
        43 => to_signed(-151448403, 48),
        44 => to_signed(-156012976, 48),
        45 => to_signed(-140174740, 48),
        46 => to_signed(-166919529, 48),
        47 => to_signed(-147236106, 48),
        48 => to_signed(-141576573, 48),
        49 => to_signed(-135974677, 48)
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
        file output_file : text open write_mode is "sr_vhdl_f1_silverstone_50.txt";
        variable l : line;
    begin
        write(l, string'("=== SR-UKF F1 f1_silverstone (50 cycles) ==="));
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
            hwrite(l, std_logic_vector(x_pos_current));
            write(l, string'(" "));
            hwrite(l, std_logic_vector(y_pos_current));
            write(l, string'(" "));
            hwrite(l, std_logic_vector(z_pos_current));
            writeline(output_file, l);

            report "CYCLE " & integer'image(i) & " done";
        end loop;

        write(l, string'(""));
        writeline(output_file, l);
        write(l, string'("=== Simulation Complete ==="));
        writeline(output_file, l);
        report "SIMULATION COMPLETE: " & integer'image(NUM_CYCLES) & " cycles";
        wait;
    end process;
end behavioral;
