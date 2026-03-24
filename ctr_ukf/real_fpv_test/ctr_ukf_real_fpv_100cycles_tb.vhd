library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ctr_ukf_real_fpv_100cycles_tb is
end ctr_ukf_real_fpv_100cycles_tb;

architecture Behavioral of ctr_ukf_real_fpv_100cycles_tb is

    component ukf_supreme_3d is
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            start : in  std_logic;
            z_x_meas : in  signed(47 downto 0);
            z_y_meas : in  signed(47 downto 0);
            z_z_meas : in  signed(47 downto 0);
            done  : out std_logic;
            x_pos_current   : out signed(47 downto 0);
            x_vel_current   : out signed(47 downto 0);
            x_omega_current : out signed(47 downto 0);
            y_pos_current   : out signed(47 downto 0);
            y_vel_current   : out signed(47 downto 0);
            y_omega_current : out signed(47 downto 0);
            z_pos_current   : out signed(47 downto 0);
            z_vel_current   : out signed(47 downto 0);
            z_omega_current : out signed(47 downto 0);
            x_pos_uncertainty : out signed(47 downto 0);
            x_vel_uncertainty : out signed(47 downto 0);
            x_omega_uncertainty : out signed(47 downto 0);
            y_pos_uncertainty : out signed(47 downto 0);
            y_vel_uncertainty : out signed(47 downto 0);
            y_omega_uncertainty : out signed(47 downto 0);
            z_pos_uncertainty : out signed(47 downto 0);
            z_vel_uncertainty : out signed(47 downto 0);
            z_omega_uncertainty : out signed(47 downto 0)
        );
    end component;

    signal clk, reset, start, done : std_logic := '0';
    signal z_x_meas, z_y_meas, z_z_meas : signed(47 downto 0) := (others => '0');
    signal x_pos_current, x_vel_current, x_omega_current : signed(47 downto 0);
    signal y_pos_current, y_vel_current, y_omega_current : signed(47 downto 0);
    signal z_pos_current, z_vel_current, z_omega_current : signed(47 downto 0);
    signal x_pos_unc, x_vel_unc, x_omega_unc : signed(47 downto 0);
    signal y_pos_unc, y_vel_unc, y_omega_unc : signed(47 downto 0);
    signal z_pos_unc, z_vel_unc, z_omega_unc : signed(47 downto 0);

    constant CLK_PERIOD : time := 10 ns;
    constant NUM_CYCLES : integer := 100;

    type meas_array_t is array(0 to 99) of signed(47 downto 0);
    constant MEAS_X : meas_array_t := (
        signed'(X"000007483DE2"),
        signed'(X"000007CB9244"),
        signed'(X"000007D2B9F6"),
        signed'(X"0000074E0042"),
        signed'(X"000007277E44"),
        signed'(X"000006C08547"),
        signed'(X"000006943D8B"),
        signed'(X"000006EB8B83"),
        signed'(X"000006C2BE38"),
        signed'(X"000007387EF8"),
        signed'(X"000006BB5FAF"),
        signed'(X"00000680FE6D"),
        signed'(X"000007231B6F"),
        signed'(X"0000072190DF"),
        signed'(X"000006F99025"),
        signed'(X"000006AC3A53"),
        signed'(X"000007345B25"),
        signed'(X"000006D716D6"),
        signed'(X"0000078C5ADA"),
        signed'(X"000006E0D05B"),
        signed'(X"000006CB0FF5"),
        signed'(X"0000066F484E"),
        signed'(X"000006FF2D7F"),
        signed'(X"000006B5D12F"),
        signed'(X"00000703CE10"),
        signed'(X"000007719839"),
        signed'(X"0000071423DF"),
        signed'(X"000007361C95"),
        signed'(X"000006A0EC44"),
        signed'(X"00000732803C"),
        signed'(X"00000714DBD3"),
        signed'(X"000006DE814D"),
        signed'(X"0000072E5D2C"),
        signed'(X"000006EA734E"),
        signed'(X"000006DCA14C"),
        signed'(X"0000073C3D58"),
        signed'(X"0000072983E8"),
        signed'(X"000007052FD2"),
        signed'(X"000006EFFE7B"),
        signed'(X"0000067310A5"),
        signed'(X"0000076DF37F"),
        signed'(X"000006554EE8"),
        signed'(X"0000068A00AC"),
        signed'(X"000006C863AD"),
        signed'(X"00000680E564"),
        signed'(X"000007CF4A2F"),
        signed'(X"000007710B15"),
        signed'(X"000007B03A43"),
        signed'(X"0000072A2961"),
        signed'(X"0000065FD7A5"),
        signed'(X"00000728DDE0"),
        signed'(X"00000726740F"),
        signed'(X"000007F772F1"),
        signed'(X"0000075C9040"),
        signed'(X"0000079CB728"),
        signed'(X"0000073D24CA"),
        signed'(X"000006E8CCB3"),
        signed'(X"0000069FB4A7"),
        signed'(X"0000072B7E98"),
        signed'(X"000007C21E22"),
        signed'(X"000007582FC4"),
        signed'(X"00000745F300"),
        signed'(X"00000744EA1C"),
        signed'(X"00000646A43E"),
        signed'(X"000007243391"),
        signed'(X"0000073A6D03"),
        signed'(X"00000710E9E7"),
        signed'(X"00000751A54C"),
        signed'(X"00000659F6E7"),
        signed'(X"0000074C8B54"),
        signed'(X"000007545A92"),
        signed'(X"0000075F2AE7"),
        signed'(X"000006A95769"),
        signed'(X"000007172155"),
        signed'(X"00000764BE07"),
        signed'(X"0000079859C2"),
        signed'(X"000006B13CF7"),
        signed'(X"000007281269"),
        signed'(X"0000081E107F"),
        signed'(X"0000072274D3"),
        signed'(X"000006A3BE95"),
        signed'(X"000007763B9F"),
        signed'(X"000006C882D6"),
        signed'(X"00000736B8A6"),
        signed'(X"0000080FD2E6"),
        signed'(X"000006BF4488"),
        signed'(X"00000732E851"),
        signed'(X"000006EF22D1"),
        signed'(X"000006D2E8FC"),
        signed'(X"0000063882AB"),
        signed'(X"000007A43F1A"),
        signed'(X"000006E9262A"),
        signed'(X"000006FD47FC"),
        signed'(X"000006AE55A6"),
        signed'(X"000007A669C5"),
        signed'(X"000005DD2EFB"),
        signed'(X"000006F69197"),
        signed'(X"0000068EF45B"),
        signed'(X"000006F71F30"),
        signed'(X"000006EC08BF")
    );
    constant MEAS_Y : meas_array_t := (
        signed'(X"00000349DAE0"),
        signed'(X"0000033D903E"),
        signed'(X"000003BDC03A"),
        signed'(X"000003203003"),
        signed'(X"00000266979C"),
        signed'(X"000002D9D67A"),
        signed'(X"000002A6B1AF"),
        signed'(X"000003641A0A"),
        signed'(X"00000369A53C"),
        signed'(X"0000030E8DFB"),
        signed'(X"000004488437"),
        signed'(X"000003C4B2C8"),
        signed'(X"000002608FDC"),
        signed'(X"000003B9E8F7"),
        signed'(X"00000334D4C8"),
        signed'(X"000003206584"),
        signed'(X"00000279ACCB"),
        signed'(X"00000304AF39"),
        signed'(X"000003D2859B"),
        signed'(X"00000385B58C"),
        signed'(X"0000034388F7"),
        signed'(X"000003C34C22"),
        signed'(X"000003DBBE4A"),
        signed'(X"000003898C62"),
        signed'(X"00000423904E"),
        signed'(X"000003666E61"),
        signed'(X"0000025CE14C"),
        signed'(X"000004187597"),
        signed'(X"0000031B1097"),
        signed'(X"000003177B84"),
        signed'(X"000003D74840"),
        signed'(X"000003291C9A"),
        signed'(X"0000037CB95D"),
        signed'(X"000002A6265F"),
        signed'(X"000002F4A271"),
        signed'(X"0000044CC428"),
        signed'(X"00000351D029"),
        signed'(X"000003630F1D"),
        signed'(X"00000381F475"),
        signed'(X"000003EDA54B"),
        signed'(X"000002E6F88A"),
        signed'(X"000003A67FB5"),
        signed'(X"00000312E759"),
        signed'(X"00000294E9AA"),
        signed'(X"000003980616"),
        signed'(X"000002F726C7"),
        signed'(X"000002BDDBA6"),
        signed'(X"0000028DA5AE"),
        signed'(X"000003BF7821"),
        signed'(X"0000039E304C"),
        signed'(X"00000387B3AC"),
        signed'(X"00000380D61A"),
        signed'(X"00000397ED41"),
        signed'(X"000002DE73D6"),
        signed'(X"000002F21414"),
        signed'(X"000003C43CEA"),
        signed'(X"000002FA65B5"),
        signed'(X"00000350D853"),
        signed'(X"000003C46A29"),
        signed'(X"0000033877EC"),
        signed'(X"000002EC6E61"),
        signed'(X"0000033D5868"),
        signed'(X"000003506DFD"),
        signed'(X"000003206802"),
        signed'(X"000002B9EC32"),
        signed'(X"000002E81285"),
        signed'(X"000002C6BE3F"),
        signed'(X"000003E37F9F"),
        signed'(X"000002E09D54"),
        signed'(X"0000039A4F6E"),
        signed'(X"000003E96170"),
        signed'(X"0000032F35AB"),
        signed'(X"00000338A75E"),
        signed'(X"0000047E7C88"),
        signed'(X"00000286D782"),
        signed'(X"0000035C58CC"),
        signed'(X"000003A9B8ED"),
        signed'(X"00000356EC53"),
        signed'(X"000003A04E1E"),
        signed'(X"000002F838D9"),
        signed'(X"0000033BAE7B"),
        signed'(X"000002ADD287"),
        signed'(X"000002F0976C"),
        signed'(X"0000029F4288"),
        signed'(X"000003C0EF70"),
        signed'(X"000003DAC692"),
        signed'(X"000003975046"),
        signed'(X"000001908F56"),
        signed'(X"0000028AC11B"),
        signed'(X"000002ECEF34"),
        signed'(X"0000026808E1"),
        signed'(X"0000029C8B1F"),
        signed'(X"000002C77D57"),
        signed'(X"0000031CC777"),
        signed'(X"000002698845"),
        signed'(X"000002EE0FC2"),
        signed'(X"000002AB1977"),
        signed'(X"000002A87D4B"),
        signed'(X"000002942DB1"),
        signed'(X"0000034DB0FC")
    );
    constant MEAS_Z : meas_array_t := (
        signed'(X"FFFFFF8EC5EA"),
        signed'(X"FFFFFF1DF484"),
        signed'(X"FFFFFEFFE324"),
        signed'(X"FFFFFF006BC8"),
        signed'(X"FFFFFE5F4C50"),
        signed'(X"FFFFFF645CD4"),
        signed'(X"FFFFFFF7CA89"),
        signed'(X"FFFFFE85DDE8"),
        signed'(X"FFFFFEA8F366"),
        signed'(X"FFFFFF16FB1E"),
        signed'(X"FFFFFF3AA036"),
        signed'(X"FFFFFEA01DEB"),
        signed'(X"FFFFFE92676F"),
        signed'(X"FFFFFF525EA1"),
        signed'(X"FFFFFE7F33B8"),
        signed'(X"FFFFFFC3C74E"),
        signed'(X"FFFFFF65F5B0"),
        signed'(X"FFFFFF8AC757"),
        signed'(X"FFFFFED111D2"),
        signed'(X"FFFFFFB95D29"),
        signed'(X"FFFFFEAEE36F"),
        signed'(X"FFFFFFEA1AB9"),
        signed'(X"FFFFFF6ACD6B"),
        signed'(X"0000000163B9"),
        signed'(X"FFFFFDED3391"),
        signed'(X"FFFFFF164373"),
        signed'(X"FFFFFF206CED"),
        signed'(X"FFFFFEFA3639"),
        signed'(X"FFFFFFB1BAA6"),
        signed'(X"FFFFFF7E438D"),
        signed'(X"FFFFFEE2B64E"),
        signed'(X"FFFFFE814180"),
        signed'(X"FFFFFF3D40A9"),
        signed'(X"FFFFFF06C4DB"),
        signed'(X"FFFFFF27FB45"),
        signed'(X"FFFFFF52FCC7"),
        signed'(X"FFFFFE470DF4"),
        signed'(X"00000077F7B2"),
        signed'(X"FFFFFF383E53"),
        signed'(X"FFFFFF9CF218"),
        signed'(X"FFFFFFF043AF"),
        signed'(X"0000005516ED"),
        signed'(X"FFFFFF49778B"),
        signed'(X"FFFFFF457BD8"),
        signed'(X"FFFFFEC7035D"),
        signed'(X"FFFFFF13767C"),
        signed'(X"FFFFFF59C989"),
        signed'(X"FFFFFF544CD2"),
        signed'(X"FFFFFE9E5A3E"),
        signed'(X"FFFFFF62BE6F"),
        signed'(X"FFFFFEE5C74C"),
        signed'(X"FFFFFEE18C68"),
        signed'(X"FFFFFEA4CD9B"),
        signed'(X"FFFFFFA28EBC"),
        signed'(X"FFFFFFB9EF64"),
        signed'(X"000000329776"),
        signed'(X"FFFFFECF905A"),
        signed'(X"FFFFFF6F37CD"),
        signed'(X"FFFFFF47EBBC"),
        signed'(X"000000A5CA26"),
        signed'(X"FFFFFEC49936"),
        signed'(X"FFFFFFADE631"),
        signed'(X"FFFFFEEBBF79"),
        signed'(X"FFFFFFCC345C"),
        signed'(X"FFFFFF7C0A2A"),
        signed'(X"FFFFFF81B271"),
        signed'(X"FFFFFFA4D468"),
        signed'(X"00000007C1FD"),
        signed'(X"FFFFFFCD69A8"),
        signed'(X"00000183FCC2"),
        signed'(X"0000001CFC38"),
        signed'(X"00000010AE9B"),
        signed'(X"FFFFFF7E995D"),
        signed'(X"FFFFFEDB565B"),
        signed'(X"FFFFFF9BE41F"),
        signed'(X"FFFFFF5C86EC"),
        signed'(X"FFFFFF974DA2"),
        signed'(X"FFFFFFAFBDAF"),
        signed'(X"FFFFFF0E3D8A"),
        signed'(X"0000008CC0EA"),
        signed'(X"0000006E3F7C"),
        signed'(X"000000107686"),
        signed'(X"0000012A8EEE"),
        signed'(X"000000CAEE32"),
        signed'(X"FFFFFF9F52AF"),
        signed'(X"00000013012B"),
        signed'(X"0000000217E6"),
        signed'(X"000000001F34"),
        signed'(X"0000015E072C"),
        signed'(X"000000A6F77D"),
        signed'(X"0000013391F9"),
        signed'(X"000000E193D5"),
        signed'(X"000000B665C2"),
        signed'(X"000001088BBB"),
        signed'(X"000001CA7387"),
        signed'(X"00000109A945"),
        signed'(X"000000A7F604"),
        signed'(X"00000132EB0C"),
        signed'(X"0000013C39CA"),
        signed'(X"0000011BEE8B")
    );

begin

    uut: ukf_supreme_3d port map (
        clk => clk, reset => reset, start => start,
        z_x_meas => z_x_meas, z_y_meas => z_y_meas, z_z_meas => z_z_meas,
        done => done,
        x_pos_current => x_pos_current, x_vel_current => x_vel_current,
        x_omega_current => x_omega_current,
        y_pos_current => y_pos_current, y_vel_current => y_vel_current,
        y_omega_current => y_omega_current,
        z_pos_current => z_pos_current, z_vel_current => z_vel_current,
        z_omega_current => z_omega_current,
        x_pos_uncertainty => x_pos_unc, x_vel_uncertainty => x_vel_unc,
        x_omega_uncertainty => x_omega_unc,
        y_pos_uncertainty => y_pos_unc, y_vel_uncertainty => y_vel_unc,
        y_omega_uncertainty => y_omega_unc,
        z_pos_uncertainty => z_pos_unc, z_vel_uncertainty => z_vel_unc,
        z_omega_uncertainty => z_omega_unc
    );

    clk_process: process begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
        variable cycle_count : integer := 0;
    begin

        reset <= '1';
        start <= '0';
        wait for CLK_PERIOD * 5;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        for i in 0 to NUM_CYCLES - 1 loop

            z_x_meas <= MEAS_X(i);
            z_y_meas <= MEAS_Y(i);
            z_z_meas <= MEAS_Z(i);
            wait for CLK_PERIOD;

            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            wait until done = '1';
            wait for CLK_PERIOD;

            report "CYCLE " & integer'image(i);
            report "  EST_X=" & integer'image(to_integer(x_pos_current)) &
                   "  EST_Y=" & integer'image(to_integer(y_pos_current)) &
                   "  EST_Z=" & integer'image(to_integer(z_pos_current));
            report "  VEL_X=" & integer'image(to_integer(x_vel_current)) &
                   "  VEL_Y=" & integer'image(to_integer(y_vel_current)) &
                   "  VEL_Z=" & integer'image(to_integer(z_vel_current));
            report "  OMEGA_X=" & integer'image(to_integer(x_omega_current)) &
                   "  OMEGA_Y=" & integer'image(to_integer(y_omega_current)) &
                   "  OMEGA_Z=" & integer'image(to_integer(z_omega_current));
            report "  P_xpos=" & integer'image(to_integer(x_pos_unc)) &
                   "  P_xvel=" & integer'image(to_integer(x_vel_unc)) &
                   "  P_xomg=" & integer'image(to_integer(x_omega_unc)) &
                   "  P_ypos=" & integer'image(to_integer(y_pos_unc)) &
                   "  P_yvel=" & integer'image(to_integer(y_vel_unc)) &
                   "  P_yomg=" & integer'image(to_integer(y_omega_unc)) &
                   "  P_zpos=" & integer'image(to_integer(z_pos_unc)) &
                   "  P_zvel=" & integer'image(to_integer(z_vel_unc)) &
                   "  P_zomg=" & integer'image(to_integer(z_omega_unc));

            start <= '0';
            wait for CLK_PERIOD * 3;
        end loop;

        report "=== SIMULATION COMPLETE ===" severity note;
        wait;
    end process;

end Behavioral;
