library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cholesky_9x9 is
  port (
    clk       : in  std_logic;
    start     : in  std_logic;

    p11_in    : in  signed(47 downto 0);
    p12_in    : in  signed(47 downto 0);
    p13_in    : in  signed(47 downto 0);
    p14_in    : in  signed(47 downto 0);
    p15_in    : in  signed(47 downto 0);
    p16_in    : in  signed(47 downto 0);
    p17_in    : in  signed(47 downto 0);
    p18_in    : in  signed(47 downto 0);
    p19_in    : in  signed(47 downto 0);

    p22_in    : in  signed(47 downto 0);
    p23_in    : in  signed(47 downto 0);
    p24_in    : in  signed(47 downto 0);
    p25_in    : in  signed(47 downto 0);
    p26_in    : in  signed(47 downto 0);
    p27_in    : in  signed(47 downto 0);
    p28_in    : in  signed(47 downto 0);
    p29_in    : in  signed(47 downto 0);

    p33_in    : in  signed(47 downto 0);
    p34_in    : in  signed(47 downto 0);
    p35_in    : in  signed(47 downto 0);
    p36_in    : in  signed(47 downto 0);
    p37_in    : in  signed(47 downto 0);
    p38_in    : in  signed(47 downto 0);
    p39_in    : in  signed(47 downto 0);

    p44_in    : in  signed(47 downto 0);
    p45_in    : in  signed(47 downto 0);
    p46_in    : in  signed(47 downto 0);
    p47_in    : in  signed(47 downto 0);
    p48_in    : in  signed(47 downto 0);
    p49_in    : in  signed(47 downto 0);

    p55_in    : in  signed(47 downto 0);
    p56_in    : in  signed(47 downto 0);
    p57_in    : in  signed(47 downto 0);
    p58_in    : in  signed(47 downto 0);
    p59_in    : in  signed(47 downto 0);

    p66_in    : in  signed(47 downto 0);
    p67_in    : in  signed(47 downto 0);
    p68_in    : in  signed(47 downto 0);
    p69_in    : in  signed(47 downto 0);

    p77_in    : in  signed(47 downto 0);
    p78_in    : in  signed(47 downto 0);
    p79_in    : in  signed(47 downto 0);

    p88_in    : in  signed(47 downto 0);
    p89_in    : in  signed(47 downto 0);

    p99_in    : in  signed(47 downto 0);

    l11_out   : out signed(47 downto 0);
    l21_out   : out signed(47 downto 0);
    l31_out   : out signed(47 downto 0);
    l41_out   : out signed(47 downto 0);
    l51_out   : out signed(47 downto 0);
    l61_out   : out signed(47 downto 0);
    l71_out   : out signed(47 downto 0);
    l81_out   : out signed(47 downto 0);
    l91_out   : out signed(47 downto 0);

    l22_out   : out signed(47 downto 0);
    l32_out   : out signed(47 downto 0);
    l42_out   : out signed(47 downto 0);
    l52_out   : out signed(47 downto 0);
    l62_out   : out signed(47 downto 0);
    l72_out   : out signed(47 downto 0);
    l82_out   : out signed(47 downto 0);
    l92_out   : out signed(47 downto 0);

    l33_out   : out signed(47 downto 0);
    l43_out   : out signed(47 downto 0);
    l53_out   : out signed(47 downto 0);
    l63_out   : out signed(47 downto 0);
    l73_out   : out signed(47 downto 0);
    l83_out   : out signed(47 downto 0);
    l93_out   : out signed(47 downto 0);

    l44_out   : out signed(47 downto 0);
    l54_out   : out signed(47 downto 0);
    l64_out   : out signed(47 downto 0);
    l74_out   : out signed(47 downto 0);
    l84_out   : out signed(47 downto 0);
    l94_out   : out signed(47 downto 0);

    l55_out   : out signed(47 downto 0);
    l65_out   : out signed(47 downto 0);
    l75_out   : out signed(47 downto 0);
    l85_out   : out signed(47 downto 0);
    l95_out   : out signed(47 downto 0);

    l66_out   : out signed(47 downto 0);
    l76_out   : out signed(47 downto 0);
    l86_out   : out signed(47 downto 0);
    l96_out   : out signed(47 downto 0);

    l77_out   : out signed(47 downto 0);
    l87_out   : out signed(47 downto 0);
    l97_out   : out signed(47 downto 0);

    l88_out   : out signed(47 downto 0);
    l98_out   : out signed(47 downto 0);

    l99_out   : out signed(47 downto 0);

    done      : out std_logic;
    psd_error : out std_logic
  );
end entity;

architecture Behavioral of cholesky_9x9 is

  type state_type is (
    IDLE,

    START_L11, WAIT_L11,
    CALC_L21, CALC_L31, CALC_L41, CALC_L51, CALC_L61, CALC_L71, CALC_L81, CALC_L91,
    SQ_L21, SQ_L31, SQ_L41, SQ_L51, SQ_L61, SQ_L71, SQ_L81, SQ_L91,

    PREP_L22, CHECK_PSD_L22, START_L22, WAIT_L22,
    COL2_START, COL2_WAIT,
    SQ_L32, SQ_L42, SQ_L52, SQ_L62, SQ_L72, SQ_L82, SQ_L92,

    PREP_L33, CHECK_PSD_L33, START_L33, WAIT_L33,
    COL3_START, COL3_WAIT,
    SQ_L43, SQ_L53, SQ_L63, SQ_L73, SQ_L83, SQ_L93,

    PREP_L44, CHECK_PSD_L44, START_L44, WAIT_L44,
    COL4_START, COL4_WAIT,
    SQ_L54, SQ_L64, SQ_L74, SQ_L84, SQ_L94,

    PREP_L55, CHECK_PSD_L55, START_L55, WAIT_L55,
    COL5_START, COL5_WAIT,
    SQ_L65, SQ_L75, SQ_L85, SQ_L95,

    PREP_L66, CHECK_PSD_L66, START_L66, WAIT_L66,
    PREP_L77, CHECK_PSD_L77, START_L77, WAIT_L77,
    PREP_L88, CHECK_PSD_L88, START_L88, WAIT_L88,
    COL678_START, COL678_WAIT,
    SQ_L76, SQ_L86, SQ_L96, SQ_L87, SQ_L97, SQ_L98,

    PREP_L99, CHECK_PSD_L99, START_L99, WAIT_L99,
    FINISHED
  );
  signal state : state_type := IDLE;

  signal p11, p12, p13, p14, p15, p16, p17, p18, p19 : signed(47 downto 0) := (others => '0');
  signal p22, p23, p24, p25, p26, p27, p28, p29 : signed(47 downto 0) := (others => '0');
  signal p33, p34, p35, p36, p37, p38, p39 : signed(47 downto 0) := (others => '0');
  signal p44, p45, p46, p47, p48, p49 : signed(47 downto 0) := (others => '0');
  signal p55, p56, p57, p58, p59 : signed(47 downto 0) := (others => '0');
  signal p66, p67, p68, p69 : signed(47 downto 0) := (others => '0');
  signal p77, p78, p79 : signed(47 downto 0) := (others => '0');
  signal p88, p89 : signed(47 downto 0) := (others => '0');
  signal p99 : signed(47 downto 0) := (others => '0');

  signal l11, l21, l31, l41, l51, l61, l71, l81, l91 : signed(47 downto 0) := (others => '0');
  signal l22, l32, l42, l52, l62, l72, l82, l92 : signed(47 downto 0) := (others => '0');
  signal l33, l43, l53, l63, l73, l83, l93 : signed(47 downto 0) := (others => '0');
  signal l44, l54, l64, l74, l84, l94 : signed(47 downto 0) := (others => '0');
  signal l55, l65, l75, l85, l95 : signed(47 downto 0) := (others => '0');
  signal l66, l76, l86, l96 : signed(47 downto 0) := (others => '0');
  signal l77, l87, l97 : signed(47 downto 0) := (others => '0');
  signal l88, l98 : signed(47 downto 0) := (others => '0');
  signal l99 : signed(47 downto 0) := (others => '0');

  signal l11_reg, l21_reg, l31_reg, l41_reg, l51_reg, l61_reg, l71_reg, l81_reg, l91_reg : signed(47 downto 0) := (others => '0');
  signal l22_reg, l32_reg, l42_reg, l52_reg, l62_reg, l72_reg, l82_reg, l92_reg : signed(47 downto 0) := (others => '0');
  signal l33_reg, l43_reg, l53_reg, l63_reg, l73_reg, l83_reg, l93_reg : signed(47 downto 0) := (others => '0');
  signal l44_reg, l54_reg, l64_reg, l74_reg, l84_reg, l94_reg : signed(47 downto 0) := (others => '0');
  signal l55_reg, l65_reg, l75_reg, l85_reg, l95_reg : signed(47 downto 0) := (others => '0');
  signal l66_reg, l76_reg, l86_reg, l96_reg : signed(47 downto 0) := (others => '0');
  signal l77_reg, l87_reg, l97_reg : signed(47 downto 0) := (others => '0');
  signal l88_reg, l98_reg : signed(47 downto 0) := (others => '0');
  signal l99_reg : signed(47 downto 0) := (others => '0');

  signal l21_sq, l31_sq, l41_sq, l51_sq, l61_sq, l71_sq, l81_sq, l91_sq : signed(47 downto 0) := (others => '0');
  signal l32_sq, l42_sq, l52_sq, l62_sq, l72_sq, l82_sq, l92_sq : signed(47 downto 0) := (others => '0');
  signal l43_sq, l53_sq, l63_sq, l73_sq, l83_sq, l93_sq : signed(47 downto 0) := (others => '0');
  signal l54_sq, l64_sq, l74_sq, l84_sq, l94_sq : signed(47 downto 0) := (others => '0');
  signal l65_sq, l75_sq, l85_sq, l95_sq : signed(47 downto 0) := (others => '0');
  signal l76_sq, l86_sq, l96_sq : signed(47 downto 0) := (others => '0');
  signal l87_sq, l97_sq : signed(47 downto 0) := (others => '0');
  signal l98_sq : signed(47 downto 0) := (others => '0');

  signal psd_error_reg : std_logic := '0';

  signal temp_sub : signed(48 downto 0) := (others => '0');
  signal temp_mul_prod : signed(47 downto 0) := (others => '0');

  signal sqrt_l11_input, sqrt_l11_output : signed(47 downto 0) := (others => '0');
  signal sqrt_l11_start, sqrt_l11_done, sqrt_l11_neg : std_logic := '0';

  signal sqrt_l22_input, sqrt_l22_output : signed(47 downto 0) := (others => '0');
  signal sqrt_l22_start, sqrt_l22_done, sqrt_l22_neg : std_logic := '0';

  signal sqrt_l33_input, sqrt_l33_output : signed(47 downto 0) := (others => '0');
  signal sqrt_l33_start, sqrt_l33_done, sqrt_l33_neg : std_logic := '0';

  signal sqrt_l44_input, sqrt_l44_output : signed(47 downto 0) := (others => '0');
  signal sqrt_l44_start, sqrt_l44_done, sqrt_l44_neg : std_logic := '0';

  signal sqrt_l55_input, sqrt_l55_output : signed(47 downto 0) := (others => '0');
  signal sqrt_l55_start, sqrt_l55_done, sqrt_l55_neg : std_logic := '0';

  signal sqrt_l66_input, sqrt_l66_output : signed(47 downto 0) := (others => '0');
  signal sqrt_l66_start, sqrt_l66_done, sqrt_l66_neg : std_logic := '0';

  signal sqrt_l77_input, sqrt_l77_output : signed(47 downto 0) := (others => '0');
  signal sqrt_l77_start, sqrt_l77_done, sqrt_l77_neg : std_logic := '0';

  signal sqrt_l88_input, sqrt_l88_output : signed(47 downto 0) := (others => '0');
  signal sqrt_l88_start, sqrt_l88_done, sqrt_l88_neg : std_logic := '0';

  signal sqrt_l99_input, sqrt_l99_output : signed(47 downto 0) := (others => '0');
  signal sqrt_l99_start, sqrt_l99_done, sqrt_l99_neg : std_logic := '0';

  signal col2_parallel_start, col2_parallel_done : std_logic := '0';
  signal col3_parallel_start, col3_parallel_done : std_logic := '0';
  signal col4_parallel_start, col4_parallel_done : std_logic := '0';
  signal col5_parallel_start, col5_parallel_done : std_logic := '0';
  signal col678_parallel_start, col678_parallel_done : std_logic := '0';

  constant Q : integer := 24;
  constant MIN_POSITIVE : signed(47 downto 0) := to_signed(64, 48);

  component sqrt_cordic is
    port (
      clk            : in  std_logic;
      start_rt       : in  std_logic;
      x_in           : in  signed(47 downto 0);
      x_out          : out signed(47 downto 0);
      done           : out std_logic;
      negative_input : out std_logic
    );
  end component;

  component cholesky_col2_parallel is
    generic (Q : integer := 24);
    port (
      clk   : in std_logic;
      start : in std_logic;
      l22 : in signed(47 downto 0);
      p23, p24, p25, p26, p27, p28, p29 : in signed(47 downto 0);
      l21, l31, l41, l51, l61, l71, l81, l91 : in signed(47 downto 0);
      l32, l42, l52, l62, l72, l82, l92 : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component cholesky_col3_parallel is
    generic (Q : integer := 24);
    port (
      clk   : in std_logic;
      start : in std_logic;
      l33 : in signed(47 downto 0);
      p34, p35, p36, p37, p38, p39 : in signed(47 downto 0);
      l31, l41, l51, l61, l71, l81, l91 : in signed(47 downto 0);
      l32, l42, l52, l62, l72, l82, l92 : in signed(47 downto 0);
      l43, l53, l63, l73, l83, l93 : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component cholesky_col4_parallel is
    generic (Q : integer := 24);
    port (
      clk   : in std_logic;
      start : in std_logic;
      l44 : in signed(47 downto 0);
      p45, p46, p47, p48, p49 : in signed(47 downto 0);
      l41, l51, l61, l71, l81, l91 : in signed(47 downto 0);
      l42, l52, l62, l72, l82, l92 : in signed(47 downto 0);
      l43, l53, l63, l73, l83, l93 : in signed(47 downto 0);
      l54, l64, l74, l84, l94 : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component cholesky_col5_parallel is
    generic (Q : integer := 24);
    port (
      clk   : in std_logic;
      start : in std_logic;
      l55 : in signed(47 downto 0);
      p56, p57, p58, p59 : in signed(47 downto 0);
      l51, l61, l71, l81, l91 : in signed(47 downto 0);
      l52, l62, l72, l82, l92 : in signed(47 downto 0);
      l53, l63, l73, l83, l93 : in signed(47 downto 0);
      l54, l64, l74, l84, l94 : in signed(47 downto 0);
      l65, l75, l85, l95 : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component cholesky_col678_parallel is
    generic (Q : integer := 24);
    port (
      clk   : in std_logic;
      start : in std_logic;
      l66, l77, l88 : in signed(47 downto 0);
      p67, p68, p69, p78, p79, p89 : in signed(47 downto 0);
      l61, l71, l81, l91 : in signed(47 downto 0);
      l62, l72, l82, l92 : in signed(47 downto 0);
      l63, l73, l83, l93 : in signed(47 downto 0);
      l64, l74, l84, l94 : in signed(47 downto 0);
      l65, l75, l85, l95 : in signed(47 downto 0);
      l76, l86, l96 : buffer signed(47 downto 0);
      l87, l97 : buffer signed(47 downto 0);
      l98 : buffer signed(47 downto 0);
      done : out std_logic
    );
  end component;

begin

  sqrt_l11_inst : sqrt_cordic port map (clk => clk, start_rt => sqrt_l11_start, x_in => sqrt_l11_input, x_out => sqrt_l11_output, done => sqrt_l11_done, negative_input => sqrt_l11_neg);
  sqrt_l22_inst : sqrt_cordic port map (clk => clk, start_rt => sqrt_l22_start, x_in => sqrt_l22_input, x_out => sqrt_l22_output, done => sqrt_l22_done, negative_input => sqrt_l22_neg);
  sqrt_l33_inst : sqrt_cordic port map (clk => clk, start_rt => sqrt_l33_start, x_in => sqrt_l33_input, x_out => sqrt_l33_output, done => sqrt_l33_done, negative_input => sqrt_l33_neg);
  sqrt_l44_inst : sqrt_cordic port map (clk => clk, start_rt => sqrt_l44_start, x_in => sqrt_l44_input, x_out => sqrt_l44_output, done => sqrt_l44_done, negative_input => sqrt_l44_neg);
  sqrt_l55_inst : sqrt_cordic port map (clk => clk, start_rt => sqrt_l55_start, x_in => sqrt_l55_input, x_out => sqrt_l55_output, done => sqrt_l55_done, negative_input => sqrt_l55_neg);
  sqrt_l66_inst : sqrt_cordic port map (clk => clk, start_rt => sqrt_l66_start, x_in => sqrt_l66_input, x_out => sqrt_l66_output, done => sqrt_l66_done, negative_input => sqrt_l66_neg);
  sqrt_l77_inst : sqrt_cordic port map (clk => clk, start_rt => sqrt_l77_start, x_in => sqrt_l77_input, x_out => sqrt_l77_output, done => sqrt_l77_done, negative_input => sqrt_l77_neg);
  sqrt_l88_inst : sqrt_cordic port map (clk => clk, start_rt => sqrt_l88_start, x_in => sqrt_l88_input, x_out => sqrt_l88_output, done => sqrt_l88_done, negative_input => sqrt_l88_neg);
  sqrt_l99_inst : sqrt_cordic port map (clk => clk, start_rt => sqrt_l99_start, x_in => sqrt_l99_input, x_out => sqrt_l99_output, done => sqrt_l99_done, negative_input => sqrt_l99_neg);

  col2_parallel_inst: cholesky_col2_parallel
    generic map (Q => 24)
    port map (
      clk => clk, start => col2_parallel_start,
      l22 => l22,
      p23 => p23, p24 => p24, p25 => p25, p26 => p26, p27 => p27, p28 => p28, p29 => p29,
      l21 => l21, l31 => l31, l41 => l41, l51 => l51, l61 => l61, l71 => l71, l81 => l81, l91 => l91,
      l32 => l32, l42 => l42, l52 => l52, l62 => l62, l72 => l72, l82 => l82, l92 => l92,
      done => col2_parallel_done
    );

  col3_parallel_inst: cholesky_col3_parallel
    generic map (Q => 24)
    port map (
      clk => clk, start => col3_parallel_start,
      l33 => l33,
      p34 => p34, p35 => p35, p36 => p36, p37 => p37, p38 => p38, p39 => p39,
      l31 => l31, l41 => l41, l51 => l51, l61 => l61, l71 => l71, l81 => l81, l91 => l91,
      l32 => l32, l42 => l42, l52 => l52, l62 => l62, l72 => l72, l82 => l82, l92 => l92,
      l43 => l43, l53 => l53, l63 => l63, l73 => l73, l83 => l83, l93 => l93,
      done => col3_parallel_done
    );

  col4_parallel_inst: cholesky_col4_parallel
    generic map (Q => 24)
    port map (
      clk => clk, start => col4_parallel_start,
      l44 => l44,
      p45 => p45, p46 => p46, p47 => p47, p48 => p48, p49 => p49,
      l41 => l41, l51 => l51, l61 => l61, l71 => l71, l81 => l81, l91 => l91,
      l42 => l42, l52 => l52, l62 => l62, l72 => l72, l82 => l82, l92 => l92,
      l43 => l43, l53 => l53, l63 => l63, l73 => l73, l83 => l83, l93 => l93,
      l54 => l54, l64 => l64, l74 => l74, l84 => l84, l94 => l94,
      done => col4_parallel_done
    );

  col5_parallel_inst: cholesky_col5_parallel
    generic map (Q => 24)
    port map (
      clk => clk, start => col5_parallel_start,
      l55 => l55,
      p56 => p56, p57 => p57, p58 => p58, p59 => p59,
      l51 => l51, l61 => l61, l71 => l71, l81 => l81, l91 => l91,
      l52 => l52, l62 => l62, l72 => l72, l82 => l82, l92 => l92,
      l53 => l53, l63 => l63, l73 => l73, l83 => l83, l93 => l93,
      l54 => l54, l64 => l64, l74 => l74, l84 => l84, l94 => l94,
      l65 => l65, l75 => l75, l85 => l85, l95 => l95,
      done => col5_parallel_done
    );

  col678_parallel_inst: cholesky_col678_parallel
    generic map (Q => 24)
    port map (
      clk => clk, start => col678_parallel_start,
      l66 => l66, l77 => l77, l88 => l88,
      p67 => p67, p68 => p68, p69 => p69, p78 => p78, p79 => p79, p89 => p89,
      l61 => l61, l71 => l71, l81 => l81, l91 => l91,
      l62 => l62, l72 => l72, l82 => l82, l92 => l92,
      l63 => l63, l73 => l73, l83 => l83, l93 => l93,
      l64 => l64, l74 => l74, l84 => l84, l94 => l94,
      l65 => l65, l75 => l75, l85 => l85, l95 => l95,
      l76 => l76, l86 => l86, l96 => l96,
      l87 => l87, l97 => l97,
      l98 => l98,
      done => col678_parallel_done
    );

  process(clk)
    variable temp_div : signed(95 downto 0);
    variable temp_mul : signed(95 downto 0);
    variable temp_49  : signed(48 downto 0);
  begin
    if rising_edge(clk) then

      sqrt_l11_start <= '0'; sqrt_l22_start <= '0'; sqrt_l33_start <= '0';
      sqrt_l44_start <= '0'; sqrt_l55_start <= '0'; sqrt_l66_start <= '0';
      sqrt_l77_start <= '0'; sqrt_l88_start <= '0'; sqrt_l99_start <= '0';
      done <= '0';

      case state is
        when IDLE =>
          if start = '1' then
            report "CHOLESKY_9x9: IDLE - Latching inputs (values hex-suppressed)";

            p11 <= p11_in; p12 <= p12_in; p13 <= p13_in; p14 <= p14_in; p15 <= p15_in; p16 <= p16_in; p17 <= p17_in; p18 <= p18_in; p19 <= p19_in;
            p22 <= p22_in; p23 <= p23_in; p24 <= p24_in; p25 <= p25_in; p26 <= p26_in; p27 <= p27_in; p28 <= p28_in; p29 <= p29_in;
            p33 <= p33_in; p34 <= p34_in; p35 <= p35_in; p36 <= p36_in; p37 <= p37_in; p38 <= p38_in; p39 <= p39_in;
            p44 <= p44_in; p45 <= p45_in; p46 <= p46_in; p47 <= p47_in; p48 <= p48_in; p49 <= p49_in;
            p55 <= p55_in; p56 <= p56_in; p57 <= p57_in; p58 <= p58_in; p59 <= p59_in;
            p66 <= p66_in; p67 <= p67_in; p68 <= p68_in; p69 <= p69_in;
            p77 <= p77_in; p78 <= p78_in; p79 <= p79_in;
            p88 <= p88_in; p89 <= p89_in;
            p99 <= p99_in;
            psd_error_reg <= '0';
            state <= START_L11;
          end if;

        when START_L11 =>
          sqrt_l11_input <= p11;
          sqrt_l11_start <= '1';
          state <= WAIT_L11;

        when WAIT_L11 =>
          if sqrt_l11_done = '1' then
            l11 <= sqrt_l11_output;
            state <= CALC_L21;
          end if;

        when CALC_L21 =>
          if l11 /= 0 then temp_div := shift_left(resize(p12, 96), Q); temp_div := temp_div / resize(l11, 96); l21 <= resize(temp_div, 48);
          else l21 <= (others => '0'); end if;
          state <= CALC_L31;

        when CALC_L31 =>
          if l11 /= 0 then temp_div := shift_left(resize(p13, 96), Q); temp_div := temp_div / resize(l11, 96); l31 <= resize(temp_div, 48);
          else l31 <= (others => '0'); end if;
          state <= CALC_L41;

        when CALC_L41 =>
          if l11 /= 0 then temp_div := shift_left(resize(p14, 96), Q); temp_div := temp_div / resize(l11, 96); l41 <= resize(temp_div, 48);
          else l41 <= (others => '0'); end if;
          state <= CALC_L51;

        when CALC_L51 =>
          if l11 /= 0 then temp_div := shift_left(resize(p15, 96), Q); temp_div := temp_div / resize(l11, 96); l51 <= resize(temp_div, 48);
          else l51 <= (others => '0'); end if;
          state <= CALC_L61;

        when CALC_L61 =>
          if l11 /= 0 then temp_div := shift_left(resize(p16, 96), Q); temp_div := temp_div / resize(l11, 96); l61 <= resize(temp_div, 48);
          else l61 <= (others => '0'); end if;
          state <= CALC_L71;

        when CALC_L71 =>
          if l11 /= 0 then temp_div := shift_left(resize(p17, 96), Q); temp_div := temp_div / resize(l11, 96); l71 <= resize(temp_div, 48);
          else l71 <= (others => '0'); end if;
          state <= CALC_L81;

        when CALC_L81 =>
          if l11 /= 0 then temp_div := shift_left(resize(p18, 96), Q); temp_div := temp_div / resize(l11, 96); l81 <= resize(temp_div, 48);
          else l81 <= (others => '0'); end if;
          state <= CALC_L91;

        when CALC_L91 =>
          if l11 /= 0 then temp_div := shift_left(resize(p19, 96), Q); temp_div := temp_div / resize(l11, 96); l91 <= resize(temp_div, 48);
          else l91 <= (others => '0'); end if;
          state <= SQ_L21;

        when SQ_L21 => temp_mul := l21 * l21; l21_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L31;
        when SQ_L31 => temp_mul := l31 * l31; l31_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L41;
        when SQ_L41 => temp_mul := l41 * l41; l41_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L51;
        when SQ_L51 => temp_mul := l51 * l51; l51_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L61;
        when SQ_L61 => temp_mul := l61 * l61; l61_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L71;
        when SQ_L71 => temp_mul := l71 * l71; l71_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L81;
        when SQ_L81 => temp_mul := l81 * l81; l81_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L91;
        when SQ_L91 => temp_mul := l91 * l91; l91_sq <= resize(shift_right(temp_mul, Q), 48); state <= PREP_L22;

        when PREP_L22 =>
          temp_49 := resize(p22, 49) - resize(l21_sq, 49);
          temp_sub <= temp_49;
          state <= CHECK_PSD_L22;

        when CHECK_PSD_L22 =>
          if temp_sub(47 downto 0) < MIN_POSITIVE or temp_sub(48) = '1' then
            psd_error_reg <= '1';

            l11 <= (others => '0'); l21 <= (others => '0'); l31 <= (others => '0'); l41 <= (others => '0');
            l51 <= (others => '0'); l61 <= (others => '0'); l71 <= (others => '0'); l81 <= (others => '0'); l91 <= (others => '0');
            state <= FINISHED;
          else
            state <= START_L22;
          end if;

        when START_L22 =>
          sqrt_l22_input <= temp_sub(47 downto 0);
          sqrt_l22_start <= '1';
          state <= WAIT_L22;

                when WAIT_L22 =>
          if sqrt_l22_done = '1' then
            l22 <= sqrt_l22_output;
            state <= COL2_START;
          end if;

        when COL2_START =>
          col2_parallel_start <= '1';
          state <= COL2_WAIT;

        when COL2_WAIT =>
          col2_parallel_start <= '0';
          if col2_parallel_done = '1' then

            state <= SQ_L32;
          end if;

        when SQ_L32 => temp_mul := l32 * l32; l32_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L42;
        when SQ_L42 => temp_mul := l42 * l42; l42_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L52;
        when SQ_L52 => temp_mul := l52 * l52; l52_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L62;
        when SQ_L62 => temp_mul := l62 * l62; l62_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L72;
        when SQ_L72 => temp_mul := l72 * l72; l72_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L82;
        when SQ_L82 => temp_mul := l82 * l82; l82_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L92;
        when SQ_L92 => temp_mul := l92 * l92; l92_sq <= resize(shift_right(temp_mul, Q), 48); state <= PREP_L33;

        when PREP_L33 =>
          temp_49 := resize(p33, 49) - resize(l31_sq, 49) - resize(l32_sq, 49);
          temp_sub <= temp_49;
          state <= CHECK_PSD_L33;

        when CHECK_PSD_L33 =>
          if temp_sub(47 downto 0) < MIN_POSITIVE or temp_sub(48) = '1' then
            psd_error_reg <= '1';
            state <= FINISHED;
          else
            state <= START_L33;
          end if;

        when START_L33 =>
          sqrt_l33_input <= temp_sub(47 downto 0);
          sqrt_l33_start <= '1';
          state <= WAIT_L33;

                when WAIT_L33 =>
          if sqrt_l33_done = '1' then
            l33 <= sqrt_l33_output;
            state <= COL3_START;
          end if;

        when COL3_START =>
          col3_parallel_start <= '1';
          state <= COL3_WAIT;

        when COL3_WAIT =>
          col3_parallel_start <= '0';
          if col3_parallel_done = '1' then

            state <= SQ_L43;
          end if;

        when SQ_L43 => temp_mul := l43 * l43; l43_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L53;
        when SQ_L53 => temp_mul := l53 * l53; l53_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L63;
        when SQ_L63 => temp_mul := l63 * l63; l63_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L73;
        when SQ_L73 => temp_mul := l73 * l73; l73_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L83;
        when SQ_L83 => temp_mul := l83 * l83; l83_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L93;
        when SQ_L93 => temp_mul := l93 * l93; l93_sq <= resize(shift_right(temp_mul, Q), 48); state <= PREP_L44;

        when PREP_L44 =>
          temp_49 := resize(p44, 49) - resize(l41_sq, 49) - resize(l42_sq, 49) - resize(l43_sq, 49);
          temp_sub <= temp_49;
          state <= CHECK_PSD_L44;

        when CHECK_PSD_L44 =>
          if temp_sub(47 downto 0) < MIN_POSITIVE or temp_sub(48) = '1' then
            psd_error_reg <= '1';
            state <= FINISHED;
          else
            state <= START_L44;
          end if;

        when START_L44 =>
          sqrt_l44_input <= temp_sub(47 downto 0);
          sqrt_l44_start <= '1';
          state <= WAIT_L44;

        when WAIT_L44 =>
          if sqrt_l44_done = '1' then
            l44 <= sqrt_l44_output;
            state <= COL4_START;
          end if;

        when COL4_START =>
          col4_parallel_start <= '1';
          state <= COL4_WAIT;

        when COL4_WAIT =>
          col4_parallel_start <= '0';
          if col4_parallel_done = '1' then

            state <= SQ_L54;
          end if;

        when SQ_L54 => temp_mul := l54 * l54; l54_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L64;
        when SQ_L64 => temp_mul := l64 * l64; l64_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L74;
        when SQ_L74 => temp_mul := l74 * l74; l74_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L84;
        when SQ_L84 => temp_mul := l84 * l84; l84_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L94;
        when SQ_L94 => temp_mul := l94 * l94; l94_sq <= resize(shift_right(temp_mul, Q), 48); state <= PREP_L55;

        when PREP_L55 =>
          temp_49 := resize(p55, 49) - resize(l51_sq, 49) - resize(l52_sq, 49) - resize(l53_sq, 49) - resize(l54_sq, 49);
          temp_sub <= temp_49;
          state <= CHECK_PSD_L55;

        when CHECK_PSD_L55 =>
          if temp_sub(47 downto 0) < MIN_POSITIVE or temp_sub(48) = '1' then
            psd_error_reg <= '1';
            state <= FINISHED;
          else
            state <= START_L55;
          end if;

        when START_L55 =>
          sqrt_l55_input <= temp_sub(47 downto 0);
          sqrt_l55_start <= '1';
          state <= WAIT_L55;

        when WAIT_L55 =>
          if sqrt_l55_done = '1' then
            l55 <= sqrt_l55_output;
            state <= COL5_START;
          end if;

        when COL5_START =>
          col5_parallel_start <= '1';
          state <= COL5_WAIT;

        when COL5_WAIT =>
          col5_parallel_start <= '0';
          if col5_parallel_done = '1' then

            state <= SQ_L65;
          end if;

        when SQ_L65 => temp_mul := l65 * l65; l65_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L75;
        when SQ_L75 => temp_mul := l75 * l75; l75_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L85;
        when SQ_L85 => temp_mul := l85 * l85; l85_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L95;
        when SQ_L95 => temp_mul := l95 * l95; l95_sq <= resize(shift_right(temp_mul, Q), 48); state <= PREP_L66;

        when PREP_L66 =>
          temp_49 := resize(p66, 49) - resize(l61_sq, 49) - resize(l62_sq, 49) - resize(l63_sq, 49) - resize(l64_sq, 49) - resize(l65_sq, 49);
          temp_sub <= temp_49;
          state <= CHECK_PSD_L66;

        when CHECK_PSD_L66 =>
          if temp_sub(47 downto 0) < MIN_POSITIVE or temp_sub(48) = '1' then
            psd_error_reg <= '1';
            state <= FINISHED;
          else
            state <= START_L66;
          end if;

        when START_L66 =>
          sqrt_l66_input <= temp_sub(47 downto 0);
          sqrt_l66_start <= '1';
          state <= WAIT_L66;

        when WAIT_L66 =>
          if sqrt_l66_done = '1' then
            l66 <= sqrt_l66_output;
            state <= COL678_START;
          end if;

        when COL678_START =>
          col678_parallel_start <= '1';
          state <= COL678_WAIT;

        when COL678_WAIT =>
          col678_parallel_start <= '0';
          if col678_parallel_done = '1' then

            state <= SQ_L76;
          end if;

        when SQ_L76 => temp_mul := l76 * l76; l76_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L86;
        when SQ_L86 => temp_mul := l86 * l86; l86_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L96;
        when SQ_L96 => temp_mul := l96 * l96; l96_sq <= resize(shift_right(temp_mul, Q), 48); state <= PREP_L77;

        when PREP_L77 =>
          temp_49 := resize(p77, 49) - resize(l71_sq, 49) - resize(l72_sq, 49) - resize(l73_sq, 49) - resize(l74_sq, 49) - resize(l75_sq, 49) - resize(l76_sq, 49);
          temp_sub <= temp_49;
          state <= CHECK_PSD_L77;

        when CHECK_PSD_L77 =>
          if temp_sub(47 downto 0) < MIN_POSITIVE or temp_sub(48) = '1' then
            psd_error_reg <= '1';
            state <= FINISHED;
          else
            state <= START_L77;
          end if;

        when START_L77 =>
          sqrt_l77_input <= temp_sub(47 downto 0);
          sqrt_l77_start <= '1';
          state <= WAIT_L77;

        when WAIT_L77 =>
          if sqrt_l77_done = '1' then
            l77 <= sqrt_l77_output;
            state <= PREP_L88;
          end if;

        when SQ_L87 => temp_mul := l87 * l87; l87_sq <= resize(shift_right(temp_mul, Q), 48); state <= SQ_L97;
        when SQ_L97 => temp_mul := l97 * l97; l97_sq <= resize(shift_right(temp_mul, Q), 48); state <= PREP_L88;

        when PREP_L88 =>
          temp_49 := resize(p88, 49) - resize(l81_sq, 49) - resize(l82_sq, 49) - resize(l83_sq, 49) - resize(l84_sq, 49) - resize(l85_sq, 49) - resize(l86_sq, 49) - resize(l87_sq, 49);
          temp_sub <= temp_49;
          state <= CHECK_PSD_L88;

        when CHECK_PSD_L88 =>
          if temp_sub(47 downto 0) < MIN_POSITIVE or temp_sub(48) = '1' then
            psd_error_reg <= '1';
            state <= FINISHED;
          else
            state <= START_L88;
          end if;

        when START_L88 =>
          sqrt_l88_input <= temp_sub(47 downto 0);
          sqrt_l88_start <= '1';
          state <= WAIT_L88;

        when WAIT_L88 =>
          if sqrt_l88_done = '1' then
            l88 <= sqrt_l88_output;
            state <= SQ_L98;
          end if;

        when SQ_L98 => temp_mul := l98 * l98; l98_sq <= resize(shift_right(temp_mul, Q), 48); state <= PREP_L99;

        when PREP_L99 =>
          temp_49 := resize(p99, 49) - resize(l91_sq, 49) - resize(l92_sq, 49) - resize(l93_sq, 49) - resize(l94_sq, 49) - resize(l95_sq, 49) - resize(l96_sq, 49) - resize(l97_sq, 49) - resize(l98_sq, 49);
          temp_sub <= temp_49;
          state <= CHECK_PSD_L99;

        when CHECK_PSD_L99 =>
          if temp_sub(47 downto 0) < MIN_POSITIVE or temp_sub(48) = '1' then
            psd_error_reg <= '1';
            state <= FINISHED;
          else
            state <= START_L99;
          end if;

        when START_L99 =>
          sqrt_l99_input <= temp_sub(47 downto 0);
          sqrt_l99_start <= '1';
          state <= WAIT_L99;

        when WAIT_L99 =>
          if sqrt_l99_done = '1' then
            l99 <= sqrt_l99_output;
            report "CHOLESKY_9x9: L99 computed (value hex-suppressed)";
            state <= FINISHED;
          end if;

        when FINISHED =>
          done <= '1';

          l11_reg <= l11; l21_reg <= l21; l31_reg <= l31; l41_reg <= l41; l51_reg <= l51; l61_reg <= l61; l71_reg <= l71; l81_reg <= l81; l91_reg <= l91;
          l22_reg <= l22; l32_reg <= l32; l42_reg <= l42; l52_reg <= l52; l62_reg <= l62; l72_reg <= l72; l82_reg <= l82; l92_reg <= l92;
          l33_reg <= l33; l43_reg <= l43; l53_reg <= l53; l63_reg <= l63; l73_reg <= l73; l83_reg <= l83; l93_reg <= l93;
          l44_reg <= l44; l54_reg <= l54; l64_reg <= l64; l74_reg <= l74; l84_reg <= l84; l94_reg <= l94;
          l55_reg <= l55; l65_reg <= l65; l75_reg <= l75; l85_reg <= l85; l95_reg <= l95;
          l66_reg <= l66; l76_reg <= l76; l86_reg <= l86; l96_reg <= l96;
          l77_reg <= l77; l87_reg <= l87; l97_reg <= l97;
          l88_reg <= l88; l98_reg <= l98;
          l99_reg <= l99;

          if start = '0' then state <= IDLE; end if;

        when others =>
          state <= IDLE;
      end case;
    end if;
  end process;

  l11_out <= l11_reg; l21_out <= l21_reg; l31_out <= l31_reg; l41_out <= l41_reg; l51_out <= l51_reg; l61_out <= l61_reg; l71_out <= l71_reg; l81_out <= l81_reg; l91_out <= l91_reg;
  l22_out <= l22_reg; l32_out <= l32_reg; l42_out <= l42_reg; l52_out <= l52_reg; l62_out <= l62_reg; l72_out <= l72_reg; l82_out <= l82_reg; l92_out <= l92_reg;
  l33_out <= l33_reg; l43_out <= l43_reg; l53_out <= l53_reg; l63_out <= l63_reg; l73_out <= l73_reg; l83_out <= l83_reg; l93_out <= l93_reg;
  l44_out <= l44_reg; l54_out <= l54_reg; l64_out <= l64_reg; l74_out <= l74_reg; l84_out <= l84_reg; l94_out <= l94_reg;
  l55_out <= l55_reg; l65_out <= l65_reg; l75_out <= l75_reg; l85_out <= l85_reg; l95_out <= l95_reg;
  l66_out <= l66_reg; l76_out <= l76_reg; l86_out <= l86_reg; l96_out <= l96_reg;
  l77_out <= l77_reg; l87_out <= l87_reg; l97_out <= l97_reg;
  l88_out <= l88_reg; l98_out <= l98_reg;
  l99_out <= l99_reg;
  psd_error <= psd_error_reg;

end Behavioral;
