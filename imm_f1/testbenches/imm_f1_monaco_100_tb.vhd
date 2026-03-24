library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity imm_f1_monaco_100_tb is
end imm_f1_monaco_100_tb;

architecture Behavioral of imm_f1_monaco_100_tb is

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
    1 => signed'(X"0000071D8F1D"),
    2 => signed'(X"00000F27B7B8"),
    3 => signed'(X"00001748C27D"),
    4 => signed'(X"00001CC7E021"),
    5 => signed'(X"00002408D59B"),
    6 => signed'(X"00002D1A01B2"),
    7 => signed'(X"000032EAAB54"),
    8 => signed'(X"00003809B8F8"),
    9 => signed'(X"00003F68815F"),
    10 => signed'(X"000044C2AD54"),
    11 => signed'(X"00004B1DC985"),
    12 => signed'(X"0000522EA88A"),
    13 => signed'(X"000056629E48"),
    14 => signed'(X"00005C958457"),
    15 => signed'(X"000060A09C73"),
    16 => signed'(X"0000630EBB99"),
    17 => signed'(X"00006743ECFB"),
    18 => signed'(X"000068EC7C2C"),
    19 => signed'(X"00006B4CD9AC"),
    20 => signed'(X"0000710F1123"),
    21 => signed'(X"0000723F85E0"),
    22 => signed'(X"0000756C11D9"),
    23 => signed'(X"000075A2B24E"),
    24 => signed'(X"000077B7CCEE"),
    25 => signed'(X"000079934A02"),
    26 => signed'(X"00007983F80F"),
    27 => signed'(X"00007C3E8850"),
    28 => signed'(X"00007C785219"),
    29 => signed'(X"00007DFB241B"),
    30 => signed'(X"00007EDF8218"),
    31 => signed'(X"00008287756E"),
    32 => signed'(X"000081DD8CF7"),
    33 => signed'(X"0000821087E1"),
    34 => signed'(X"000085F8F99A"),
    35 => signed'(X"00008627FFB9"),
    36 => signed'(X"000089E601AB"),
    37 => signed'(X"00008A0ADD4A"),
    38 => signed'(X"00008CFC86E1"),
    39 => signed'(X"000090D2F106"),
    40 => signed'(X"000093AD9852"),
    41 => signed'(X"0000955EA7B1"),
    42 => signed'(X"000096DB872A"),
    43 => signed'(X"00009872668D"),
    44 => signed'(X"0000990B54A8"),
    45 => signed'(X"00009B93E6C1"),
    46 => signed'(X"00009D9C9B6F"),
    47 => signed'(X"0000A0E780D0"),
    48 => signed'(X"0000A1F73202"),
    49 => signed'(X"0000A17015CA"),
    50 => signed'(X"0000A505169A"),
    51 => signed'(X"0000A5CE3DBB"),
    52 => signed'(X"0000A7023AC4"),
    53 => signed'(X"0000A9CACF64"),
    54 => signed'(X"0000ABB4DB34"),
    55 => signed'(X"0000AD180633"),
    56 => signed'(X"0000ACBD7188"),
    57 => signed'(X"0000AEAFCA9E"),
    58 => signed'(X"0000B0BE6B81"),
    59 => signed'(X"0000B2CE05D1"),
    60 => signed'(X"0000B2C447FF"),
    61 => signed'(X"0000B47A167B"),
    62 => signed'(X"0000B4F90FB9"),
    63 => signed'(X"0000B64CB890"),
    64 => signed'(X"0000B9B99F85"),
    65 => signed'(X"0000BBAF7B0A"),
    66 => signed'(X"0000BBAC83E7"),
    67 => signed'(X"0000BE1B0AB8"),
    68 => signed'(X"0000BE4697A4"),
    69 => signed'(X"0000BE14BD2B"),
    70 => signed'(X"0000BFE6486F"),
    71 => signed'(X"0000C16A941D"),
    72 => signed'(X"0000BFFAF93E"),
    73 => signed'(X"0000C1B7FF6A"),
    74 => signed'(X"0000BDAC191A"),
    75 => signed'(X"0000C14076B5"),
    76 => signed'(X"0000C0A7A502"),
    77 => signed'(X"0000C0681E56"),
    78 => signed'(X"0000C0EF7581"),
    79 => signed'(X"0000BEFE7458"),
    80 => signed'(X"0000C0E65708"),
    81 => signed'(X"0000C19D4CF8"),
    82 => signed'(X"0000C2DF864B"),
    83 => signed'(X"0000C103CF76"),
    84 => signed'(X"0000C0DCD12B"),
    85 => signed'(X"0000C14EA53F"),
    86 => signed'(X"0000C2DCBDFA"),
    87 => signed'(X"0000C259EE55"),
    88 => signed'(X"0000C18691B5"),
    89 => signed'(X"0000C29A0056"),
    90 => signed'(X"0000C237DFB0"),
    91 => signed'(X"0000C31F6981"),
    92 => signed'(X"0000C17C2168"),
    93 => signed'(X"0000C1E46444"),
    94 => signed'(X"0000C1DC4F81"),
    95 => signed'(X"0000C0D27290"),
    96 => signed'(X"0000C29D54CA"),
    97 => signed'(X"0000C2757DEF"),
    98 => signed'(X"0000C200D3E9"),
    99 => signed'(X"0000C14ED7A1")
  );

  constant MEAS_Y : meas_array_t := (
    0 => signed'(X"FFFFFF13A6FC"),
    1 => signed'(X"FFFFFC6BB465"),
    2 => signed'(X"FFFFFA91A5F8"),
    3 => signed'(X"FFFFFA5EF0AA"),
    4 => signed'(X"FFFFF623E5CA"),
    5 => signed'(X"FFFFF77E91C9"),
    6 => signed'(X"FFFFF320B479"),
    7 => signed'(X"FFFFEFFC2D30"),
    8 => signed'(X"FFFFEBD901F0"),
    9 => signed'(X"FFFFEA4FEA4A"),
    10 => signed'(X"FFFFE5F12949"),
    11 => signed'(X"FFFFE38BA5D4"),
    12 => signed'(X"FFFFE2E3AF00"),
    13 => signed'(X"FFFFDD23996D"),
    14 => signed'(X"FFFFDB612B8E"),
    15 => signed'(X"FFFFD7539990"),
    16 => signed'(X"FFFFD5CB5016"),
    17 => signed'(X"FFFFD5664071"),
    18 => signed'(X"FFFFD0CD147E"),
    19 => signed'(X"FFFFD10A3A31"),
    20 => signed'(X"FFFFCDBC14F4"),
    21 => signed'(X"FFFFCA43900F"),
    22 => signed'(X"FFFFC9421B83"),
    23 => signed'(X"FFFFC7106013"),
    24 => signed'(X"FFFFC409257C"),
    25 => signed'(X"FFFFBF2A8C19"),
    26 => signed'(X"FFFFBD54F07C"),
    27 => signed'(X"FFFFBB224891"),
    28 => signed'(X"FFFFB8A127AE"),
    29 => signed'(X"FFFFB6A5A9EA"),
    30 => signed'(X"FFFFB386D32A"),
    31 => signed'(X"FFFFAF560C06"),
    32 => signed'(X"FFFFAE5FC999"),
    33 => signed'(X"FFFFABDA6538"),
    34 => signed'(X"FFFFA7A54A7B"),
    35 => signed'(X"FFFFA3973022"),
    36 => signed'(X"FFFF9E967F6A"),
    37 => signed'(X"FFFF997511B8"),
    38 => signed'(X"FFFF942C0FEA"),
    39 => signed'(X"FFFF8DD352F6"),
    40 => signed'(X"FFFF8B29048F"),
    41 => signed'(X"FFFF86387AC3"),
    42 => signed'(X"FFFF81E90BB7"),
    43 => signed'(X"FFFF7BFCE251"),
    44 => signed'(X"FFFF77CF30F9"),
    45 => signed'(X"FFFF7591C24E"),
    46 => signed'(X"FFFF701A3C61"),
    47 => signed'(X"FFFF6C730948"),
    48 => signed'(X"FFFF676C081C"),
    49 => signed'(X"FFFF6239DFA6"),
    50 => signed'(X"FFFF5D959D76"),
    51 => signed'(X"FFFF56947722"),
    52 => signed'(X"FFFF51A4568E"),
    53 => signed'(X"FFFF4B888C0E"),
    54 => signed'(X"FFFF4602D120"),
    55 => signed'(X"FFFF405979CA"),
    56 => signed'(X"FFFF38F6D2C9"),
    57 => signed'(X"FFFF3058BB17"),
    58 => signed'(X"FFFF2A2A18EE"),
    59 => signed'(X"FFFF2018F00B"),
    60 => signed'(X"FFFF18E3738B"),
    61 => signed'(X"FFFF10B80D7B"),
    62 => signed'(X"FFFF0AB0622C"),
    63 => signed'(X"FFFF01859BC6"),
    64 => signed'(X"FFFEFA70C6A9"),
    65 => signed'(X"FFFEF001A758"),
    66 => signed'(X"FFFEE9D7A7C5"),
    67 => signed'(X"FFFEE2C53544"),
    68 => signed'(X"FFFEDC443F9A"),
    69 => signed'(X"FFFED78DAAF9"),
    70 => signed'(X"FFFED0463340"),
    71 => signed'(X"FFFECE39C86E"),
    72 => signed'(X"FFFECBE0B801"),
    73 => signed'(X"FFFEC5FA8668"),
    74 => signed'(X"FFFEC2A892EC"),
    75 => signed'(X"FFFEC151E65C"),
    76 => signed'(X"FFFEBE356A2C"),
    77 => signed'(X"FFFEB8DE6728"),
    78 => signed'(X"FFFEB5BBE5EE"),
    79 => signed'(X"FFFEB2A28A3C"),
    80 => signed'(X"FFFEAE55B558"),
    81 => signed'(X"FFFEAB85EC75"),
    82 => signed'(X"FFFEA8333FD7"),
    83 => signed'(X"FFFEA532F6CF"),
    84 => signed'(X"FFFEA2B1DA10"),
    85 => signed'(X"FFFE9FB9E6A6"),
    86 => signed'(X"FFFE9DCE14BB"),
    87 => signed'(X"FFFE9727DD23"),
    88 => signed'(X"FFFE933677E6"),
    89 => signed'(X"FFFE8C16BD74"),
    90 => signed'(X"FFFE8653E5DB"),
    91 => signed'(X"FFFE81205A8F"),
    92 => signed'(X"FFFE796738F5"),
    93 => signed'(X"FFFE74FB935B"),
    94 => signed'(X"FFFE6ED75471"),
    95 => signed'(X"FFFE693DD332"),
    96 => signed'(X"FFFE631CD2F3"),
    97 => signed'(X"FFFE5D4F1E4E"),
    98 => signed'(X"FFFE51422E9C"),
    99 => signed'(X"FFFE4648919E")
  );

  constant MEAS_Z : meas_array_t := (
    0 => signed'(X"000000C742AC"),
    1 => signed'(X"FFFFFF26D5AA"),
    2 => signed'(X"FFFFFE966ADC"),
    3 => signed'(X"FFFFFF1AF35D"),
    4 => signed'(X"FFFFFEA42F76"),
    5 => signed'(X"FFFFFE0FAA19"),
    6 => signed'(X"FFFFFEE9E778"),
    7 => signed'(X"FFFFFEEAE51A"),
    8 => signed'(X"FFFFFDD04AD6"),
    9 => signed'(X"FFFFFEF73B32"),
    10 => signed'(X"FFFFFC1C08D4"),
    11 => signed'(X"FFFFFCD20DAE"),
    12 => signed'(X"FFFFFC0F7276"),
    13 => signed'(X"FFFFFAAC7191"),
    14 => signed'(X"FFFFFC3DC6FC"),
    15 => signed'(X"FFFFFC2C8806"),
    16 => signed'(X"FFFFFDC7E5A3"),
    17 => signed'(X"FFFFFCDEB264"),
    18 => signed'(X"FFFFFB2FC5BC"),
    19 => signed'(X"FFFFFE095DFA"),
    20 => signed'(X"FFFFFD600F28"),
    21 => signed'(X"FFFFFCB53F2B"),
    22 => signed'(X"FFFFFBDF0147"),
    23 => signed'(X"FFFFFB2531EA"),
    24 => signed'(X"FFFFFBC13DA0"),
    25 => signed'(X"FFFFFD3CF5A4"),
    26 => signed'(X"FFFFFE0E6881"),
    27 => signed'(X"FFFFFDBCBD1B"),
    28 => signed'(X"FFFFFBBA3CB4"),
    29 => signed'(X"FFFFFB1E7989"),
    30 => signed'(X"FFFFFC66E0BF"),
    31 => signed'(X"FFFFFA83CE07"),
    32 => signed'(X"FFFFFCA0F86E"),
    33 => signed'(X"FFFFFC2CA365"),
    34 => signed'(X"FFFFFBC23FCD"),
    35 => signed'(X"FFFFFA82424E"),
    36 => signed'(X"FFFFFC7C48A6"),
    37 => signed'(X"FFFFFB4EBADA"),
    38 => signed'(X"FFFFFA89E6D9"),
    39 => signed'(X"FFFFF8B46687"),
    40 => signed'(X"FFFFFB6AF478"),
    41 => signed'(X"FFFFFD18C6FE"),
    42 => signed'(X"FFFFFCF67DF8"),
    43 => signed'(X"FFFFFAD25266"),
    44 => signed'(X"FFFFFAA74D11"),
    45 => signed'(X"FFFFFBB39A33"),
    46 => signed'(X"FFFFFA362366"),
    47 => signed'(X"FFFFFB7D1CCC"),
    48 => signed'(X"FFFFFBEE1960"),
    49 => signed'(X"FFFFFC66EC92"),
    50 => signed'(X"FFFFFB19C5CA"),
    51 => signed'(X"FFFFFB05DABB"),
    52 => signed'(X"FFFFFA5FD070"),
    53 => signed'(X"FFFFFA737AAF"),
    54 => signed'(X"FFFFFB13C3CE"),
    55 => signed'(X"FFFFFBB1B6AE"),
    56 => signed'(X"FFFFFC3D8BB2"),
    57 => signed'(X"FFFFFA860DE1"),
    58 => signed'(X"FFFFFCD1CBDA"),
    59 => signed'(X"FFFFFB0E42A8"),
    60 => signed'(X"FFFFFB4E32B0"),
    61 => signed'(X"FFFFFA9461C0"),
    62 => signed'(X"FFFFF8E71001"),
    63 => signed'(X"FFFFFC35FBD0"),
    64 => signed'(X"FFFFFC104CD0"),
    65 => signed'(X"FFFFFB0BA5EE"),
    66 => signed'(X"FFFFFB64D151"),
    67 => signed'(X"FFFFFBD7AFDA"),
    68 => signed'(X"FFFFF9C2FABB"),
    69 => signed'(X"FFFFFACAF038"),
    70 => signed'(X"FFFFFC1D179F"),
    71 => signed'(X"FFFFFA109045"),
    72 => signed'(X"FFFFFB9CEF59"),
    73 => signed'(X"FFFFF9F69F25"),
    74 => signed'(X"FFFFFBC96F66"),
    75 => signed'(X"FFFFFB4906FF"),
    76 => signed'(X"FFFFF9B4CCDF"),
    77 => signed'(X"FFFFFC7C91DD"),
    78 => signed'(X"FFFFFA9676AA"),
    79 => signed'(X"FFFFFA833782"),
    80 => signed'(X"FFFFFB861C11"),
    81 => signed'(X"FFFFFC78F004"),
    82 => signed'(X"FFFFFA4EF55F"),
    83 => signed'(X"FFFFFB62EBE0"),
    84 => signed'(X"FFFFFBC107E5"),
    85 => signed'(X"FFFFFC04CFB3"),
    86 => signed'(X"FFFFFB80AAF5"),
    87 => signed'(X"FFFFFAF5B65F"),
    88 => signed'(X"FFFFFA7FE0DA"),
    89 => signed'(X"FFFFFB69DD3B"),
    90 => signed'(X"FFFFFA4169E6"),
    91 => signed'(X"FFFFF86815E0"),
    92 => signed'(X"FFFFFBC3C7C8"),
    93 => signed'(X"FFFFFC3B7F92"),
    94 => signed'(X"FFFFF8F7400E"),
    95 => signed'(X"FFFFFA51BD61"),
    96 => signed'(X"FFFFFBF2CDE2"),
    97 => signed'(X"FFFFFD62C363"),
    98 => signed'(X"FFFFFB58FBDF"),
    99 => signed'(X"FFFFFA992527")
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
    file out_file : text open write_mode is "imm_vhdl_monaco_100.txt";
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
