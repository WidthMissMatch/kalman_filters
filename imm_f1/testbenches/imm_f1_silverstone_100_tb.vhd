library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity imm_f1_silverstone_100_tb is
end imm_f1_silverstone_100_tb;

architecture Behavioral of imm_f1_silverstone_100_tb is

  component imm_f1_top is
    port (
      clk, reset, start : in std_logic;
      z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);
      px_out, py_out, pz_out : out signed(47 downto 0);
      prob_ca_out, prob_singer_out, prob_bike_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  signal clk, reset, start, done_sig : std_logic := '0';
  signal z_x, z_y, z_z : signed(47 downto 0) := (others => '0');
  signal px, py, pz : signed(47 downto 0);
  signal p_ca, p_si, p_bi : signed(47 downto 0);
  constant CLK_PERIOD : time := 10 ns;

  constant N_CYCLES : integer := 100;
  type meas_array_t is array (0 to N_CYCLES-1) of signed(47 downto 0);

  constant MEAS_X : meas_array_t := (
    0 => signed'(X"0000007F28A9"),
    1 => signed'(X"0000080ADD17"),
    2 => signed'(X"0000110253AC"),
    3 => signed'(X"00001A10AC6B"),
    4 => signed'(X"0000207D1809"),
    5 => signed'(X"0000285752F1"),
    6 => signed'(X"000030DA0790"),
    7 => signed'(X"0000365F95C8"),
    8 => signed'(X"00003B784E9D"),
    9 => signed'(X"000042D0C235"),
    10 => signed'(X"00004824995C"),
    11 => signed'(X"00004E7960BE"),
    12 => signed'(X"00005583EAF4"),
    13 => signed'(X"000059B18BE3"),
    14 => signed'(X"00005FAA53A4"),
    15 => signed'(X"00006553F5C8"),
    16 => signed'(X"000069609EF5"),
    17 => signed'(X"00006F345A5F"),
    18 => signed'(X"0000727B7397"),
    19 => signed'(X"0000767A5B1F"),
    20 => signed'(X"00007DDB1C9D"),
    21 => signed'(X"000080AA1B62"),
    22 => signed'(X"000085753163"),
    23 => signed'(X"000088772B8F"),
    24 => signed'(X"00008DD88B31"),
    25 => signed'(X"000093004D48"),
    26 => signed'(X"0000963D4058"),
    27 => signed'(X"00009C44159A"),
    28 => signed'(X"00009F8746BF"),
    29 => signed'(X"0000A3777AE9"),
    30 => signed'(X"0000A6520CF2"),
    31 => signed'(X"0000ABA0C042"),
    32 => signed'(X"0000AC9D97C4"),
    33 => signed'(X"0000AE6CC124"),
    34 => signed'(X"0000B328948E"),
    35 => signed'(X"0000B3F7F402"),
    36 => signed'(X"0000B8407044"),
    37 => signed'(X"0000B88E7BFC"),
    38 => signed'(X"0000B970C1B1"),
    39 => signed'(X"0000BA5411A8"),
    40 => signed'(X"0000BA3B9EC4"),
    41 => signed'(X"0000B90757E1"),
    42 => signed'(X"0000B81AC46D"),
    43 => signed'(X"0000B74830E2"),
    44 => signed'(X"0000B577AC10"),
    45 => signed'(X"0000B596CB3C"),
    46 => signed'(X"0000B5360CFC"),
    47 => signed'(X"0000B6177F6F"),
    48 => signed'(X"0000B4BDBDB5"),
    49 => signed'(X"0000B1FF5634"),
    50 => signed'(X"0000B3728A6F"),
    51 => signed'(X"0000B219E4FB"),
    52 => signed'(X"0000B09A2495"),
    53 => signed'(X"0000AF5A7473"),
    54 => signed'(X"0000AD3C3B82"),
    55 => signed'(X"0000AA992296"),
    56 => signed'(X"0000A64A518B"),
    57 => signed'(X"0000A4486E40"),
    58 => signed'(X"0000A262D2C3"),
    59 => signed'(X"0000A07E30B2"),
    60 => signed'(X"00009BDD49EC"),
    61 => signed'(X"0000988F51BC"),
    62 => signed'(X"0000940A844F"),
    63 => signed'(X"0000905A667A"),
    64 => signed'(X"00008EC386C4"),
    65 => signed'(X"00008BB59B9D"),
    66 => signed'(X"000086AEDDCF"),
    67 => signed'(X"000084291898"),
    68 => signed'(X"00007FEBA93D"),
    69 => signed'(X"00007B207BE2"),
    70 => signed'(X"000077E7EA31"),
    71 => signed'(X"000074DAE5D9"),
    72 => signed'(X"00006EA1D3EC"),
    73 => signed'(X"00006B4D6FFC"),
    74 => signed'(X"0000618D7076"),
    75 => signed'(X"00005D85A78C"),
    76 => signed'(X"00005550AF55"),
    77 => signed'(X"00004D750224"),
    78 => signed'(X"0000466032CA"),
    79 => signed'(X"00003CD30B1C"),
    80 => signed'(X"0000371EC748"),
    81 => signed'(X"0000303996B2"),
    82 => signed'(X"000029DFA980"),
    83 => signed'(X"00002067CC27"),
    84 => signed'(X"000018341CD1"),
    85 => signed'(X"0000104E38D6"),
    86 => signed'(X"000009849983"),
    87 => signed'(X"000000BA007C"),
    88 => signed'(X"FFFFF7A9CED1"),
    89 => signed'(X"FFFFF0806868"),
    90 => signed'(X"FFFFE7E172B8"),
    91 => signed'(X"FFFFE0E09CCA"),
    92 => signed'(X"FFFFD81A06A4"),
    93 => signed'(X"FFFFD15EFB72"),
    94 => signed'(X"FFFFCA3398A2"),
    95 => signed'(X"FFFFC2066DA3"),
    96 => signed'(X"FFFFBD127698"),
    97 => signed'(X"FFFFB6960699"),
    98 => signed'(X"FFFFAFE10B38"),
    99 => signed'(X"FFFFA930383A")
  );

  constant MEAS_Y : meas_array_t := (
    0 => signed'(X"FFFFFF13A6FC"),
    1 => signed'(X"FFFFF0CB201C"),
    2 => signed'(X"FFFFE3507D65"),
    3 => signed'(X"FFFFD77D33CE"),
    4 => signed'(X"FFFFC7A194A5"),
    5 => signed'(X"FFFFBDAB5003"),
    6 => signed'(X"FFFFAF2ACBF3"),
    7 => signed'(X"FFFFA2E5D5A9"),
    8 => signed'(X"FFFF95E4C946"),
    9 => signed'(X"FFFF8B7DD07D"),
    10 => signed'(X"FFFF7E412E5A"),
    11 => signed'(X"FFFF72FDC9C2"),
    12 => signed'(X"FFFF6977F1CB"),
    13 => signed'(X"FFFF5AD9FB15"),
    14 => signed'(X"FFFF5009D987"),
    15 => signed'(X"FFFF41E67ACF"),
    16 => signed'(X"FFFF3648649A"),
    17 => signed'(X"FFFF2BCD883A"),
    18 => signed'(X"FFFF1D1E8F8D"),
    19 => signed'(X"FFFF1345E886"),
    20 => signed'(X"FFFF05E1F68E"),
    21 => signed'(X"FFFEF853A4EE"),
    22 => signed'(X"FFFEED3C63A7"),
    23 => signed'(X"FFFEE14A52F0"),
    24 => signed'(X"FFFED4A763FA"),
    25 => signed'(X"FFFEC62D1638"),
    26 => signed'(X"FFFEBABBC63B"),
    27 => signed'(X"FFFEAEED69F1"),
    28 => signed'(X"FFFEA03EC440"),
    29 => signed'(X"FFFE8C16DB55"),
    30 => signed'(X"FFFE75C7EE89"),
    31 => signed'(X"FFFE5DB9F4C3"),
    32 => signed'(X"FFFE48E67FB3"),
    33 => signed'(X"FFFE3296D790"),
    34 => signed'(X"FFFE1BFF33CF"),
    35 => signed'(X"FFFE05F9F097"),
    36 => signed'(X"FFFDEF301BA1"),
    37 => signed'(X"FFFDDA345099"),
    38 => signed'(X"FFFDCF832C0F"),
    39 => signed'(X"FFFDC7B776F0"),
    40 => signed'(X"FFFDC39A305D"),
    41 => signed'(X"FFFDBD2CE928"),
    42 => signed'(X"FFFDB708CD8F"),
    43 => signed'(X"FFFDAF47F79B"),
    44 => signed'(X"FFFDA94599B6"),
    45 => signed'(X"FFFDA5337E7E"),
    46 => signed'(X"FFFD9DE74C03"),
    47 => signed'(X"FFFD986B6C5C"),
    48 => signed'(X"FFFD918FBEA3"),
    49 => signed'(X"FFFD8B5BA618"),
    50 => signed'(X"FFFD860FC498"),
    51 => signed'(X"FFFD7E66FEF4"),
    52 => signed'(X"FFFD77711793"),
    53 => signed'(X"FFFD6C1E7F79"),
    54 => signed'(X"FFFD6161F6F0"),
    55 => signed'(X"FFFD56BE671E"),
    56 => signed'(X"FFFD4C82C5B9"),
    57 => signed'(X"FFFD410BB3A2"),
    58 => signed'(X"FFFD38041713"),
    59 => signed'(X"FFFD2B19F3CC"),
    60 => signed'(X"FFFD1F6E7400"),
    61 => signed'(X"FFFD11B9AF60"),
    62 => signed'(X"FFFD0628A581"),
    63 => signed'(X"FFFCF774808B"),
    64 => signed'(X"FFFCEAD64CDD"),
    65 => signed'(X"FFFCDADDCEFD"),
    66 => signed'(X"FFFCCF2A70D9"),
    67 => signed'(X"FFFCC255C90F"),
    68 => signed'(X"FFFCB413118C"),
    69 => signed'(X"FFFCA8277FD7"),
    70 => signed'(X"FFFC9AF380D3"),
    71 => signed'(X"FFFC9141EA28"),
    72 => signed'(X"FFFC86721833"),
    73 => signed'(X"FFFC780751D5"),
    74 => signed'(X"FFFC6BA4C77F"),
    75 => signed'(X"FFFC5F997DDB"),
    76 => signed'(X"FFFC51C86498"),
    77 => signed'(X"FFFC41BCC481"),
    78 => signed'(X"FFFC33E5A633"),
    79 => signed'(X"FFFC2617AD6D"),
    80 => signed'(X"FFFC17163B75"),
    81 => signed'(X"FFFC0991D57F"),
    82 => signed'(X"FFFBFB8A8BCE"),
    83 => signed'(X"FFFBEDD5A5B2"),
    84 => signed'(X"FFFBE13A39EC"),
    85 => signed'(X"FFFBD48ED62F"),
    86 => signed'(X"FFFBC8EF93F1"),
    87 => signed'(X"FFFBB972D7DE"),
    88 => signed'(X"FFFBAE7E2E35"),
    89 => signed'(X"FFFBA05B2F56"),
    90 => signed'(X"FFFB9395134F"),
    91 => signed'(X"FFFB8846F9A1"),
    92 => signed'(X"FFFB7C9247BD"),
    93 => signed'(X"FFFB742B11D8"),
    94 => signed'(X"FFFB6A0B42A4"),
    95 => signed'(X"FFFB6076311B"),
    96 => signed'(X"FFFB583F1201"),
    97 => signed'(X"FFFB53AA25CA"),
    98 => signed'(X"FFFB49D2E081"),
    99 => signed'(X"FFFB432EC035")
  );

  constant MEAS_Z : meas_array_t := (
    0 => signed'(X"000000C742AC"),
    1 => signed'(X"FFFFFF4DC438"),
    2 => signed'(X"FFFFFEE447F9"),
    3 => signed'(X"FFFFFF8FBF08"),
    4 => signed'(X"FFFFFF3FE9B0"),
    5 => signed'(X"FFFFFECD1E9D"),
    6 => signed'(X"FFFFFFBC6DC1"),
    7 => signed'(X"FFFFFFC5B940"),
    8 => signed'(X"FFFFFEAECF43"),
    9 => signed'(X"FFFFFFD96FE7"),
    10 => signed'(X"FFFFFD01EDD1"),
    11 => signed'(X"FFFFFDBBA2F3"),
    12 => signed'(X"FFFFFCFCB802"),
    13 => signed'(X"FFFFFB9D6765"),
    14 => signed'(X"FFFFFD33353C"),
    15 => signed'(X"FFFFFD04A2AA"),
    16 => signed'(X"FFFFFE82ACAB"),
    17 => signed'(X"FFFFFD7C25D0"),
    18 => signed'(X"FFFFFBAFE58B"),
    19 => signed'(X"FFFFFE6C2A2D"),
    20 => signed'(X"FFFFFDA587BF"),
    21 => signed'(X"FFFFFCDD6427"),
    22 => signed'(X"FFFFFBE9D2A6"),
    23 => signed'(X"FFFFFB099D6A"),
    24 => signed'(X"FFFFFB7B5FFF"),
    25 => signed'(X"FFFFFCCCCEE2"),
    26 => signed'(X"FFFFFD73F89D"),
    27 => signed'(X"FFFFFCF80417"),
    28 => signed'(X"FFFFFABFDA81"),
    29 => signed'(X"FFFFF9D3E35C"),
    30 => signed'(X"FFFFFAC410F8"),
    31 => signed'(X"FFFFF8836B8F"),
    32 => signed'(X"FFFFFA430346"),
    33 => signed'(X"FFFFF972A307"),
    34 => signed'(X"FFFFF8C9424C"),
    35 => signed'(X"FFFFF7507629"),
    36 => signed'(X"FFFFF9145412"),
    37 => signed'(X"FFFFF7B6B9B8"),
    38 => signed'(X"FFFFF6E51987"),
    39 => signed'(X"FFFFF510CC92"),
    40 => signed'(X"FFFFF7C88DE0"),
    41 => signed'(X"FFFFF974CB52"),
    42 => signed'(X"FFFFF937E146"),
    43 => signed'(X"FFFFF6F914AD"),
    44 => signed'(X"FFFFF6B36E50"),
    45 => signed'(X"FFFFF7A51A6C"),
    46 => signed'(X"FFFFF60D0297"),
    47 => signed'(X"FFFFF7395AF6"),
    48 => signed'(X"FFFFF78FB683"),
    49 => signed'(X"FFFFF7E530EB"),
    50 => signed'(X"FFFFF670F4DF"),
    51 => signed'(X"FFFFF635F48E"),
    52 => signed'(X"FFFFF566A4E1"),
    53 => signed'(X"FFFFF54BEECD"),
    54 => signed'(X"FFFFF5BDD798"),
    55 => signed'(X"FFFFF62E12AA"),
    56 => signed'(X"FFFFF6921C90"),
    57 => signed'(X"FFFFF4B2D3A1"),
    58 => signed'(X"FFFFF6D6C67C"),
    59 => signed'(X"FFFFF4EB722D"),
    60 => signed'(X"FFFFF4FDAFAB"),
    61 => signed'(X"FFFFF4123C94"),
    62 => signed'(X"FFFFF23348AF"),
    63 => signed'(X"FFFFF5509257"),
    64 => signed'(X"FFFFF4F94131"),
    65 => signed'(X"FFFFF3C2F828"),
    66 => signed'(X"FFFFF3EA8164"),
    67 => signed'(X"FFFFF42BCD88"),
    68 => signed'(X"FFFFF1E613C8"),
    69 => signed'(X"FFFFF2BCB1B2"),
    70 => signed'(X"FFFFF3DCBFFE"),
    71 => signed'(X"FFFFF19D9B52"),
    72 => signed'(X"FFFFF2F72B20"),
    73 => signed'(X"FFFFF11E101F"),
    74 => signed'(X"FFFFF2BE6336"),
    75 => signed'(X"FFFFF20C668D"),
    76 => signed'(X"FFFFF046982B"),
    77 => signed'(X"FFFFF2DCC8E6"),
    78 => signed'(X"FFFFF0C51971"),
    79 => signed'(X"FFFFF0804607"),
    80 => signed'(X"FFFFF1519654"),
    81 => signed'(X"FFFFF212D605"),
    82 => signed'(X"FFFFEFB7471E"),
    83 => signed'(X"FFFFF099A95D"),
    84 => signed'(X"FFFFF0CBF81D"),
    85 => signed'(X"FFFFF0E7CCA3"),
    86 => signed'(X"FFFFF03BB49D"),
    87 => signed'(X"FFFFEF88BFE0"),
    88 => signed'(X"FFFFEEEB0488"),
    89 => signed'(X"FFFFEFAD1B15"),
    90 => signed'(X"FFFFEE5CC1EE"),
    91 => signed'(X"FFFFEC5EEBE3"),
    92 => signed'(X"FFFFEF9E04AC"),
    93 => signed'(X"FFFFEFF92357"),
    94 => signed'(X"FFFFEC984AB4"),
    95 => signed'(X"FFFFEDD62EE8"),
    96 => signed'(X"FFFFEF5FFBE3"),
    97 => signed'(X"FFFFF0BC8FCB"),
    98 => signed'(X"FFFFEE9F8748"),
    99 => signed'(X"FFFFEDCC32EC")
  );

  procedure hwrite48(variable L : inout line; val : in signed(47 downto 0)) is
    variable uval : unsigned(47 downto 0);
  begin
    uval := unsigned(val);
    hwrite(L, std_logic_vector(uval));
  end procedure;

begin

  dut : imm_f1_top port map (
    clk => clk, reset => reset, start => start,
    z_x_meas => z_x, z_y_meas => z_y, z_z_meas => z_z,
    px_out => px, py_out => py, pz_out => pz,
    prob_ca_out => p_ca, prob_singer_out => p_si, prob_bike_out => p_bi,
    done => done_sig
  );

  clk_proc : process
  begin
    clk <= '0'; wait for CLK_PERIOD/2;
    clk <= '1'; wait for CLK_PERIOD/2;
  end process;

  stim_proc : process
    variable L : line;
    file out_file : text open write_mode is "imm_vhdl_silverstone_100.txt";
  begin

    reset <= '1';
    wait for CLK_PERIOD * 5;
    reset <= '0';
    wait for CLK_PERIOD * 2;

    for i in 0 to N_CYCLES-1 loop
      z_x <= MEAS_X(i);
      z_y <= MEAS_Y(i);
      z_z <= MEAS_Z(i);

      start <= '1';
      wait for CLK_PERIOD;
      start <= '0';

      wait until done_sig = '1' for 200 us;

      write(L, string'("Cycle "));
      write(L, i);
      write(L, string'(": imm_x=0x"));
      hwrite48(L, px);
      write(L, string'(" imm_y=0x"));
      hwrite48(L, py);
      write(L, string'(" imm_z=0x"));
      hwrite48(L, pz);
      write(L, string'(" p_ca=0x"));
      hwrite48(L, p_ca);
      write(L, string'(" p_si=0x"));
      hwrite48(L, p_si);
      write(L, string'(" p_bi=0x"));
      hwrite48(L, p_bi);
      writeline(out_file, L);

      if (i mod 10) = 9 then
        report "Completed cycle " & integer'image(i+1) & " of " & integer'image(N_CYCLES);
      end if;

      wait for CLK_PERIOD * 5;
    end loop;

    report "IMM simulation complete after " & integer'image(N_CYCLES) & " cycles";
    wait;
  end process;

end Behavioral;
