library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity cholesky_6x6 is
  port (
    clk       : in  std_logic;
    start     : in  std_logic;
    p11_in    : in  signed(47 downto 0);
    p12_in    : in  signed(47 downto 0);
    p13_in    : in  signed(47 downto 0);
    p14_in    : in  signed(47 downto 0);
    p15_in    : in  signed(47 downto 0);
    p16_in    : in  signed(47 downto 0);
    p22_in    : in  signed(47 downto 0);
    p23_in    : in  signed(47 downto 0);
    p24_in    : in  signed(47 downto 0);
    p25_in    : in  signed(47 downto 0);
    p26_in    : in  signed(47 downto 0);
    p33_in    : in  signed(47 downto 0);
    p34_in    : in  signed(47 downto 0);
    p35_in    : in  signed(47 downto 0);
    p36_in    : in  signed(47 downto 0);
    p44_in    : in  signed(47 downto 0);
    p45_in    : in  signed(47 downto 0);
    p46_in    : in  signed(47 downto 0);
    p55_in    : in  signed(47 downto 0);
    p56_in    : in  signed(47 downto 0);
    p66_in    : in  signed(47 downto 0);
    l11_out   : out signed(47 downto 0);
    l21_out   : out signed(47 downto 0);
    l31_out   : out signed(47 downto 0);
    l41_out   : out signed(47 downto 0);
    l51_out   : out signed(47 downto 0);
    l61_out   : out signed(47 downto 0);
    l22_out   : out signed(47 downto 0);
    l32_out   : out signed(47 downto 0);
    l42_out   : out signed(47 downto 0);
    l52_out   : out signed(47 downto 0);
    l62_out   : out signed(47 downto 0);
    l33_out   : out signed(47 downto 0);
    l43_out   : out signed(47 downto 0);
    l53_out   : out signed(47 downto 0);
    l63_out   : out signed(47 downto 0);
    l44_out   : out signed(47 downto 0);
    l54_out   : out signed(47 downto 0);
    l64_out   : out signed(47 downto 0);
    l55_out   : out signed(47 downto 0);
    l65_out   : out signed(47 downto 0);
    l66_out   : out signed(47 downto 0);
    done      : out std_logic;
    psd_error : out std_logic
  );
end entity;
architecture Behavioral of cholesky_6x6 is
  type state_type is (
    IDLE,
    START_L11, WAIT_L11,
    CALC_L21, CALC_L31, CALC_L41, CALC_L51, CALC_L61,
    SQ_L21, SQ_L31, SQ_L41, SQ_L51, SQ_L61,
    PREP_L22, CHECK_PSD_L22, START_L22, WAIT_L22,
    CALC_L32_PREP, CALC_L32,
    CALC_L42_PREP, CALC_L42,
    CALC_L52_PREP, CALC_L52,
    CALC_L62_PREP, CALC_L62,
    SQ_L32, SQ_L42, SQ_L52, SQ_L62,
    PREP_L33, CHECK_PSD_L33, START_L33, WAIT_L33,
    CALC_L43_PREP, CALC_L43,
    CALC_L53_PREP, CALC_L53,
    CALC_L63_PREP, CALC_L63,
    SQ_L43, SQ_L53, SQ_L63,
    PREP_L44, CHECK_PSD_L44, START_L44, WAIT_L44,
    CALC_L54_PREP, CALC_L54,
    CALC_L64_PREP, CALC_L64,
    SQ_L54, SQ_L64,
    PREP_L55, CHECK_PSD_L55, START_L55, WAIT_L55,
    CALC_L65_PREP, CALC_L65,
    SQ_L65,
    PREP_L66, CHECK_PSD_L66, START_L66, WAIT_L66,
    FINISHED
  );
  signal state : state_type := IDLE;
  signal p11, p12, p13, p14, p15, p16 : signed(47 downto 0) := (others => '0');
  signal p22, p23, p24, p25, p26 : signed(47 downto 0) := (others => '0');
  signal p33, p34, p35, p36 : signed(47 downto 0) := (others => '0');
  signal p44, p45, p46 : signed(47 downto 0) := (others => '0');
  signal p55, p56 : signed(47 downto 0) := (others => '0');
  signal p66 : signed(47 downto 0) := (others => '0');
  signal l11, l21, l31, l41, l51, l61 : signed(47 downto 0) := (others => '0');
  signal l22, l32, l42, l52, l62 : signed(47 downto 0) := (others => '0');
  signal l33, l43, l53, l63 : signed(47 downto 0) := (others => '0');
  signal l44, l54, l64 : signed(47 downto 0) := (others => '0');
  signal l55, l65 : signed(47 downto 0) := (others => '0');
  signal l66 : signed(47 downto 0) := (others => '0');
  signal l21_sq, l31_sq, l41_sq, l51_sq, l61_sq : signed(47 downto 0) := (others => '0');
  signal l32_sq, l42_sq, l52_sq, l62_sq : signed(47 downto 0) := (others => '0');
  signal l43_sq, l53_sq, l63_sq : signed(47 downto 0) := (others => '0');
  signal l54_sq, l64_sq : signed(47 downto 0) := (others => '0');
  signal l65_sq : signed(47 downto 0) := (others => '0');
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
  constant Q : integer := 24;
  constant MIN_POSITIVE : signed(47 downto 0) := to_signed(4096, 48);
  component sqrt_newton is
    port (
      clk            : in  std_logic;
      start_rt       : in  std_logic;
      x_in           : in  signed(47 downto 0);
      x_out          : out signed(47 downto 0);
      done           : out std_logic;
      negative_input : out std_logic
    );
  end component;
begin
  sqrt_l11_inst : sqrt_newton
    port map (
      clk => clk, start_rt => sqrt_l11_start, x_in => sqrt_l11_input,
      x_out => sqrt_l11_output, done => sqrt_l11_done, negative_input => sqrt_l11_neg
    );
  sqrt_l22_inst : sqrt_newton
    port map (
      clk => clk, start_rt => sqrt_l22_start, x_in => sqrt_l22_input,
      x_out => sqrt_l22_output, done => sqrt_l22_done, negative_input => sqrt_l22_neg
    );
  sqrt_l33_inst : sqrt_newton
    port map (
      clk => clk, start_rt => sqrt_l33_start, x_in => sqrt_l33_input,
      x_out => sqrt_l33_output, done => sqrt_l33_done, negative_input => sqrt_l33_neg
    );
  sqrt_l44_inst : sqrt_newton
    port map (
      clk => clk, start_rt => sqrt_l44_start, x_in => sqrt_l44_input,
      x_out => sqrt_l44_output, done => sqrt_l44_done, negative_input => sqrt_l44_neg
    );
  sqrt_l55_inst : sqrt_newton
    port map (
      clk => clk, start_rt => sqrt_l55_start, x_in => sqrt_l55_input,
      x_out => sqrt_l55_output, done => sqrt_l55_done, negative_input => sqrt_l55_neg
    );
  sqrt_l66_inst : sqrt_newton
    port map (
      clk => clk, start_rt => sqrt_l66_start, x_in => sqrt_l66_input,
      x_out => sqrt_l66_output, done => sqrt_l66_done, negative_input => sqrt_l66_neg
    );
  process(clk)
    variable temp_div : signed(95 downto 0);
    variable temp_mul : signed(95 downto 0);
    variable temp_33  : signed(48 downto 0);
  begin
    if rising_edge(clk) then
      sqrt_l11_start <= '0';
      sqrt_l22_start <= '0';
      sqrt_l33_start <= '0';
      sqrt_l44_start <= '0';
      sqrt_l55_start <= '0';
      sqrt_l66_start <= '0';
      done <= '0';
      case state is
        when IDLE =>
          if start = '1' then
            p11 <= p11_in; p12 <= p12_in; p13 <= p13_in; p14 <= p14_in; p15 <= p15_in; p16 <= p16_in;
            p22 <= p22_in; p23 <= p23_in; p24 <= p24_in; p25 <= p25_in; p26 <= p26_in;
            p33 <= p33_in; p34 <= p34_in; p35 <= p35_in; p36 <= p36_in;
            p44 <= p44_in; p45 <= p45_in; p46 <= p46_in;
            p55 <= p55_in; p56 <= p56_in;
            p66 <= p66_in;
            psd_error_reg <= '0';
            report "CHOLESKY: START" & LF &
                   "  p11=" & integer'image(to_integer(p11_in)) & " p22=" & integer'image(to_integer(p22_in)) &
                   " p33=" & integer'image(to_integer(p33_in)) & " p44=" & integer'image(to_integer(p44_in)) &
                   " p55=" & integer'image(to_integer(p55_in)) & " p66=" & integer'image(to_integer(p66_in));
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
          if l11 /= 0 then
            temp_div := shift_left(resize(p12, 96), Q);
            temp_div := temp_div / resize(l11, 96);
            l21 <= resize(temp_div, 48);
          else
            l21 <= (others => '0');
          end if;
          state <= CALC_L31;
        when CALC_L31 =>
          if l11 /= 0 then
            temp_div := shift_left(resize(p13, 96), Q);
            temp_div := temp_div / resize(l11, 96);
            l31 <= resize(temp_div, 48);
          else
            l31 <= (others => '0');
          end if;
          state <= CALC_L41;
        when CALC_L41 =>
          if l11 /= 0 then
            temp_div := shift_left(resize(p14, 96), Q);
            temp_div := temp_div / resize(l11, 96);
            l41 <= resize(temp_div, 48);
          else
            l41 <= (others => '0');
          end if;
          state <= CALC_L51;
        when CALC_L51 =>
          if l11 /= 0 then
            temp_div := shift_left(resize(p15, 96), Q);
            temp_div := temp_div / resize(l11, 96);
            l51 <= resize(temp_div, 48);
          else
            l51 <= (others => '0');
          end if;
          state <= CALC_L61;
        when CALC_L61 =>
          if l11 /= 0 then
            temp_div := shift_left(resize(p16, 96), Q);
            temp_div := temp_div / resize(l11, 96);
            l61 <= resize(temp_div, 48);
          else
            l61 <= (others => '0');
          end if;
          state <= SQ_L21;
        when SQ_L21 =>
          temp_mul := l21 * l21;
          l21_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= SQ_L31;
        when SQ_L31 =>
          temp_mul := l31 * l31;
          l31_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= SQ_L41;
        when SQ_L41 =>
          temp_mul := l41 * l41;
          l41_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= SQ_L51;
        when SQ_L51 =>
          temp_mul := l51 * l51;
          l51_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= SQ_L61;
        when SQ_L61 =>
          temp_mul := l61 * l61;
          l61_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= PREP_L22;
        when PREP_L22 =>
          temp_33 := resize(p22, 49) - resize(l21_sq, 49);
          temp_sub <= temp_33;
          state <= CHECK_PSD_L22;
        when CHECK_PSD_L22 =>
          report "CHOLESKY: CHECK_PSD_L22" & LF &
                 "  temp_sub(31..0)=" & integer'image(to_integer(temp_sub(47 downto 0))) &
                 " temp_sub(48)=" & std_logic'image(temp_sub(48)) &
                 " MIN_POSITIVE=" & integer'image(to_integer(MIN_POSITIVE));
          if temp_sub(47 downto 0) < MIN_POSITIVE or temp_sub(48) = '1' then
            report "CHOLESKY: PSD ERROR at L22 - Matrix not positive semi-definite";
            psd_error_reg <= '1';
            l11 <= (others => '0'); l21 <= (others => '0'); l31 <= (others => '0'); l41 <= (others => '0'); l51 <= (others => '0'); l61 <= (others => '0');
            l22 <= (others => '0'); l32 <= (others => '0'); l42 <= (others => '0'); l52 <= (others => '0'); l62 <= (others => '0');
            l33 <= (others => '0'); l43 <= (others => '0'); l53 <= (others => '0'); l63 <= (others => '0');
            l44 <= (others => '0'); l54 <= (others => '0'); l64 <= (others => '0');
            l55 <= (others => '0'); l65 <= (others => '0');
            l66 <= (others => '0');
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
            state <= CALC_L32_PREP;
          end if;
        when CALC_L32_PREP =>
          temp_mul := l21 * l31;
          temp_mul_prod <= resize(shift_right(temp_mul, Q), 48);
          state <= CALC_L32;
        when CALC_L32 =>
          if l22 /= 0 then
            temp_33 := resize(p23, 49) - resize(temp_mul_prod, 49);
            temp_div := shift_left(resize(temp_33, 96), Q);
            temp_div := temp_div / resize(l22, 96);
            l32 <= resize(temp_div, 48);
          else
            l32 <= (others => '0');
          end if;
          state <= CALC_L42_PREP;
        when CALC_L42_PREP =>
          temp_mul := l21 * l41;
          temp_mul_prod <= resize(shift_right(temp_mul, Q), 48);
          state <= CALC_L42;
        when CALC_L42 =>
          if l22 /= 0 then
            temp_33 := resize(p24, 49) - resize(temp_mul_prod, 49);
            temp_div := shift_left(resize(temp_33, 96), Q);
            temp_div := temp_div / resize(l22, 96);
            l42 <= resize(temp_div, 48);
          else
            l42 <= (others => '0');
          end if;
          state <= CALC_L52_PREP;
        when CALC_L52_PREP =>
          temp_mul := l21 * l51;
          temp_mul_prod <= resize(shift_right(temp_mul, Q), 48);
          state <= CALC_L52;
        when CALC_L52 =>
          if l22 /= 0 then
            temp_33 := resize(p25, 49) - resize(temp_mul_prod, 49);
            temp_div := shift_left(resize(temp_33, 96), Q);
            temp_div := temp_div / resize(l22, 96);
            l52 <= resize(temp_div, 48);
          else
            l52 <= (others => '0');
          end if;
          state <= CALC_L62_PREP;
        when CALC_L62_PREP =>
          temp_mul := l21 * l61;
          temp_mul_prod <= resize(shift_right(temp_mul, Q), 48);
          state <= CALC_L62;
        when CALC_L62 =>
          if l22 /= 0 then
            temp_33 := resize(p26, 49) - resize(temp_mul_prod, 49);
            temp_div := shift_left(resize(temp_33, 96), Q);
            temp_div := temp_div / resize(l22, 96);
            l62 <= resize(temp_div, 48);
          else
            l62 <= (others => '0');
          end if;
          state <= SQ_L32;
        when SQ_L32 =>
          temp_mul := l32 * l32;
          l32_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= SQ_L42;
        when SQ_L42 =>
          temp_mul := l42 * l42;
          l42_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= SQ_L52;
        when SQ_L52 =>
          temp_mul := l52 * l52;
          l52_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= SQ_L62;
        when SQ_L62 =>
          temp_mul := l62 * l62;
          l62_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= PREP_L33;
        when PREP_L33 =>
          temp_33 := resize(p33, 49) - resize(l31_sq, 49) - resize(l32_sq, 49);
          temp_sub <= temp_33;
          state <= CHECK_PSD_L33;
        when CHECK_PSD_L33 =>
          report "CHOLESKY: CHECK_PSD_L33" & LF &
                 "  temp_sub(31..0)=" & integer'image(to_integer(temp_sub(47 downto 0))) &
                 " temp_sub(48)=" & std_logic'image(temp_sub(48));
          if temp_sub(47 downto 0) < MIN_POSITIVE or temp_sub(48) = '1' then
            report "CHOLESKY: PSD ERROR at L33 - Matrix not positive semi-definite";
            psd_error_reg <= '1';
            l11 <= (others => '0'); l21 <= (others => '0'); l31 <= (others => '0'); l41 <= (others => '0'); l51 <= (others => '0'); l61 <= (others => '0');
            l22 <= (others => '0'); l32 <= (others => '0'); l42 <= (others => '0'); l52 <= (others => '0'); l62 <= (others => '0');
            l33 <= (others => '0'); l43 <= (others => '0'); l53 <= (others => '0'); l63 <= (others => '0');
            l44 <= (others => '0'); l54 <= (others => '0'); l64 <= (others => '0');
            l55 <= (others => '0'); l65 <= (others => '0');
            l66 <= (others => '0');
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
            state <= CALC_L43_PREP;
          end if;
        when CALC_L43_PREP =>
          temp_mul := l31 * l41;
          temp_mul_prod <= resize(shift_right(temp_mul, Q), 48);
          state <= CALC_L43;
        when CALC_L43 =>
          if l33 /= 0 then
            temp_mul := l32 * l42;
            temp_33 := resize(p34, 49) - resize(temp_mul_prod, 49) - resize(shift_right(temp_mul, Q), 33);
            temp_div := shift_left(resize(temp_33, 96), Q);
            temp_div := temp_div / resize(l33, 96);
            l43 <= resize(temp_div, 48);
          else
            l43 <= (others => '0');
          end if;
          state <= CALC_L53_PREP;
        when CALC_L53_PREP =>
          temp_mul := l31 * l51;
          temp_mul_prod <= resize(shift_right(temp_mul, Q), 48);
          state <= CALC_L53;
        when CALC_L53 =>
          if l33 /= 0 then
            temp_mul := l32 * l52;
            temp_33 := resize(p35, 49) - resize(temp_mul_prod, 49) - resize(shift_right(temp_mul, Q), 33);
            temp_div := shift_left(resize(temp_33, 96), Q);
            temp_div := temp_div / resize(l33, 96);
            l53 <= resize(temp_div, 48);
          else
            l53 <= (others => '0');
          end if;
          state <= CALC_L63_PREP;
        when CALC_L63_PREP =>
          temp_mul := l31 * l61;
          temp_mul_prod <= resize(shift_right(temp_mul, Q), 48);
          state <= CALC_L63;
        when CALC_L63 =>
          if l33 /= 0 then
            temp_mul := l32 * l62;
            temp_33 := resize(p36, 49) - resize(temp_mul_prod, 49) - resize(shift_right(temp_mul, Q), 33);
            temp_div := shift_left(resize(temp_33, 96), Q);
            temp_div := temp_div / resize(l33, 96);
            l63 <= resize(temp_div, 48);
          else
            l63 <= (others => '0');
          end if;
          state <= SQ_L43;
        when SQ_L43 =>
          temp_mul := l43 * l43;
          l43_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= SQ_L53;
        when SQ_L53 =>
          temp_mul := l53 * l53;
          l53_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= SQ_L63;
        when SQ_L63 =>
          temp_mul := l63 * l63;
          l63_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= PREP_L44;
        when PREP_L44 =>
          temp_33 := resize(p44, 49) - resize(l41_sq, 49) - resize(l42_sq, 49) - resize(l43_sq, 49);
          temp_sub <= temp_33;
          state <= CHECK_PSD_L44;
        when CHECK_PSD_L44 =>
          report "CHOLESKY: CHECK_PSD_L44" & LF &
                 "  temp_sub(31..0)=" & integer'image(to_integer(temp_sub(47 downto 0))) &
                 " temp_sub(48)=" & std_logic'image(temp_sub(48));
          if temp_sub(47 downto 0) < MIN_POSITIVE or temp_sub(48) = '1' then
            report "CHOLESKY: PSD ERROR at L44 - Matrix not positive semi-definite";
            psd_error_reg <= '1';
            l11 <= (others => '0'); l21 <= (others => '0'); l31 <= (others => '0'); l41 <= (others => '0'); l51 <= (others => '0'); l61 <= (others => '0');
            l22 <= (others => '0'); l32 <= (others => '0'); l42 <= (others => '0'); l52 <= (others => '0'); l62 <= (others => '0');
            l33 <= (others => '0'); l43 <= (others => '0'); l53 <= (others => '0'); l63 <= (others => '0');
            l44 <= (others => '0'); l54 <= (others => '0'); l64 <= (others => '0');
            l55 <= (others => '0'); l65 <= (others => '0');
            l66 <= (others => '0');
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
            state <= CALC_L54_PREP;
          end if;
        when CALC_L54_PREP =>
          temp_mul := l41 * l51;
          temp_mul_prod <= resize(shift_right(temp_mul, Q), 48);
          state <= CALC_L54;
        when CALC_L54 =>
          if l44 /= 0 then
            temp_mul := l42 * l52;
            temp_33 := resize(p45, 49) - resize(temp_mul_prod, 49) - resize(shift_right(temp_mul, Q), 33);
            temp_mul := l43 * l53;
            temp_33 := temp_33 - resize(shift_right(temp_mul, Q), 33);
            temp_div := shift_left(resize(temp_33, 96), Q);
            temp_div := temp_div / resize(l44, 96);
            l54 <= resize(temp_div, 48);
          else
            l54 <= (others => '0');
          end if;
          state <= CALC_L64_PREP;
        when CALC_L64_PREP =>
          temp_mul := l41 * l61;
          temp_mul_prod <= resize(shift_right(temp_mul, Q), 48);
          state <= CALC_L64;
        when CALC_L64 =>
          if l44 /= 0 then
            temp_mul := l42 * l62;
            temp_33 := resize(p46, 49) - resize(temp_mul_prod, 49) - resize(shift_right(temp_mul, Q), 33);
            temp_mul := l43 * l63;
            temp_33 := temp_33 - resize(shift_right(temp_mul, Q), 33);
            temp_div := shift_left(resize(temp_33, 96), Q);
            temp_div := temp_div / resize(l44, 96);
            l64 <= resize(temp_div, 48);
          else
            l64 <= (others => '0');
          end if;
          state <= SQ_L54;
        when SQ_L54 =>
          temp_mul := l54 * l54;
          l54_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= SQ_L64;
        when SQ_L64 =>
          temp_mul := l64 * l64;
          l64_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= PREP_L55;
        when PREP_L55 =>
          temp_33 := resize(p55, 49) - resize(l51_sq, 49) - resize(l52_sq, 49) - resize(l53_sq, 49) - resize(l54_sq, 49);
          temp_sub <= temp_33;
          state <= CHECK_PSD_L55;
        when CHECK_PSD_L55 =>
          report "CHOLESKY: CHECK_PSD_L55" & LF &
                 "  temp_sub(31..0)=" & integer'image(to_integer(temp_sub(47 downto 0))) &
                 " temp_sub(48)=" & std_logic'image(temp_sub(48));
          if temp_sub(47 downto 0) < MIN_POSITIVE or temp_sub(48) = '1' then
            report "CHOLESKY: PSD ERROR at L55 - Matrix not positive semi-definite";
            psd_error_reg <= '1';
            l11 <= (others => '0'); l21 <= (others => '0'); l31 <= (others => '0'); l41 <= (others => '0'); l51 <= (others => '0'); l61 <= (others => '0');
            l22 <= (others => '0'); l32 <= (others => '0'); l42 <= (others => '0'); l52 <= (others => '0'); l62 <= (others => '0');
            l33 <= (others => '0'); l43 <= (others => '0'); l53 <= (others => '0'); l63 <= (others => '0');
            l44 <= (others => '0'); l54 <= (others => '0'); l64 <= (others => '0');
            l55 <= (others => '0'); l65 <= (others => '0');
            l66 <= (others => '0');
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
            state <= CALC_L65_PREP;
          end if;
        when CALC_L65_PREP =>
          temp_mul := l51 * l61;
          temp_mul_prod <= resize(shift_right(temp_mul, Q), 48);
          state <= CALC_L65;
        when CALC_L65 =>
          if l55 /= 0 then
            temp_mul := l52 * l62;
            temp_33 := resize(p56, 49) - resize(temp_mul_prod, 49) - resize(shift_right(temp_mul, Q), 33);
            temp_mul := l53 * l63;
            temp_33 := temp_33 - resize(shift_right(temp_mul, Q), 33);
            temp_mul := l54 * l64;
            temp_33 := temp_33 - resize(shift_right(temp_mul, Q), 33);
            temp_div := shift_left(resize(temp_33, 96), Q);
            temp_div := temp_div / resize(l55, 96);
            l65 <= resize(temp_div, 48);
          else
            l65 <= (others => '0');
          end if;
          state <= SQ_L65;
        when SQ_L65 =>
          temp_mul := l65 * l65;
          l65_sq <= resize(shift_right(temp_mul, Q), 48);
          state <= PREP_L66;
        when PREP_L66 =>
          temp_33 := resize(p66, 49) - resize(l61_sq, 49) - resize(l62_sq, 49) - resize(l63_sq, 49) - resize(l64_sq, 49) - resize(l65_sq, 49);
          temp_sub <= temp_33;
          state <= CHECK_PSD_L66;
        when CHECK_PSD_L66 =>
          report "CHOLESKY: CHECK_PSD_L66" & LF &
                 "  temp_sub(31..0)=" & integer'image(to_integer(temp_sub(47 downto 0))) &
                 " temp_sub(48)=" & std_logic'image(temp_sub(48));
          if temp_sub(47 downto 0) < MIN_POSITIVE or temp_sub(48) = '1' then
            report "CHOLESKY: PSD ERROR at L66 - Matrix not positive semi-definite";
            psd_error_reg <= '1';
            l11 <= (others => '0'); l21 <= (others => '0'); l31 <= (others => '0'); l41 <= (others => '0'); l51 <= (others => '0'); l61 <= (others => '0');
            l22 <= (others => '0'); l32 <= (others => '0'); l42 <= (others => '0'); l52 <= (others => '0'); l62 <= (others => '0');
            l33 <= (others => '0'); l43 <= (others => '0'); l53 <= (others => '0'); l63 <= (others => '0');
            l44 <= (others => '0'); l54 <= (others => '0'); l64 <= (others => '0');
            l55 <= (others => '0'); l65 <= (others => '0');
            l66 <= (others => '0');
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
            state <= FINISHED;
          end if;
        when FINISHED =>
          done <= '1';
          if start = '0' then
            state <= IDLE;
          end if;
        when others =>
          state <= IDLE;
      end case;
    end if;
  end process;
  l11_out <= l11;
  l21_out <= l21;
  l31_out <= l31;
  l41_out <= l41;
  l51_out <= l51;
  l61_out <= l61;
  l22_out <= l22;
  l32_out <= l32;
  l42_out <= l42;
  l52_out <= l52;
  l62_out <= l62;
  l33_out <= l33;
  l43_out <= l43;
  l53_out <= l53;
  l63_out <= l63;
  l44_out <= l44;
  l54_out <= l54;
  l64_out <= l64;
  l55_out <= l55;
  l65_out <= l65;
  l66_out <= l66;
  psd_error <= psd_error_reg;
end Behavioral;
