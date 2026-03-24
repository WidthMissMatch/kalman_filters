library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity exp_cordic is
  port (
    clk       : in  std_logic;
    start_exp : in  std_logic;
    x_in      : in  signed(47 downto 0);
    exp_out   : out signed(47 downto 0);
    done      : out std_logic;
    overflow  : out std_logic
  );
end entity;

architecture Behavioral of exp_cordic is

  type state_type is (IDLE, INIT, CHECK_RANGE, ITERATE, FINISH);
  signal state : state_type := IDLE;

  signal x_cordic : signed(63 downto 0);
  signal y_cordic : signed(63 downto 0);
  signal z_cordic : signed(63 downto 0);

  signal iteration : integer range 0 to 31;
  signal x_input   : signed(47 downto 0);
  signal overflow_reg : std_logic := '0';

  constant Q : integer := 24;
  constant ITERATIONS : integer := 24;

  constant K_HYPERBOLIC : signed(47 downto 0) := to_signed(13894930, 48);

  constant ONE_OVER_KH : signed(47 downto 0) := to_signed(20258439, 48);

  constant ONE_Q24_24 : signed(47 downto 0) := to_signed(16777216, 48);

  constant MAX_INPUT : signed(47 downto 0) := to_signed(16777216, 48);

  type atanh_lut_type is array (0 to 23) of signed(47 downto 0);
  constant ATANH_LUT : atanh_lut_type := (
    to_signed(9215828, 48),
    to_signed(4285116, 48),
    to_signed(2108178, 48),
    to_signed(1049945, 48),
    to_signed(524459, 48),
    to_signed(262165, 48),
    to_signed(131075, 48),
    to_signed(65536, 48),
    to_signed(32768, 48),
    to_signed(16384, 48),
    to_signed(8192, 48),
    to_signed(4096, 48),
    to_signed(2048, 48),
    to_signed(1024, 48),
    to_signed(512, 48),
    to_signed(256, 48),
    to_signed(128, 48),
    to_signed(64, 48),
    to_signed(32, 48),
    to_signed(16, 48),
    to_signed(8, 48),
    to_signed(4, 48),
    to_signed(2, 48),
    to_signed(1, 48)
  );

  function is_repeat_index(i : integer) return boolean is
  begin
    if i = 3 or i = 12 then
      return true;
    else
      return false;
    end if;
  end function;

begin

  process(clk)
    variable x_shifted : signed(63 downto 0);
    variable y_shifted : signed(63 downto 0);
    variable sigma : std_logic;
    variable x_temp : signed(63 downto 0);
    variable y_temp : signed(63 downto 0);
    variable z_temp : signed(63 downto 0);
    variable shift_amount : integer;
  begin
    if rising_edge(clk) then
      case state is

        when IDLE =>
          done <= '0';
          overflow_reg <= '0';
          if start_exp = '1' then
            x_input <= x_in;
            iteration <= 0;
            state <= INIT;
          end if;

        when INIT =>

          x_cordic <= resize(shift_left(resize(ONE_OVER_KH, 64), Q), 64);
          y_cordic <= (others => '0');
          z_cordic <= resize(shift_left(resize(x_input, 64), Q), 64);

          state <= CHECK_RANGE;

        when CHECK_RANGE =>

          if x_input > MAX_INPUT or x_input < -MAX_INPUT then
            overflow_reg <= '1';
            x_cordic <= resize(shift_left(resize(ONE_OVER_KH, 64), Q), 64);
            state <= FINISH;
          else
            overflow_reg <= '0';
            state <= ITERATE;
          end if;

        when ITERATE =>

          if z_cordic >= 0 then
            sigma := '1';
          else
            sigma := '0';
          end if;

          if is_repeat_index(iteration) then
            shift_amount := iteration;
          else
            shift_amount := iteration + 1;
          end if;

          x_shifted := shift_right(x_cordic, shift_amount);
          y_shifted := shift_right(y_cordic, shift_amount);

          if sigma = '1' then

            x_temp := x_cordic + y_shifted;
            y_temp := y_cordic + x_shifted;
            z_temp := z_cordic - resize(shift_left(resize(ATANH_LUT(iteration), 64), Q), 64);
          else

            x_temp := x_cordic - y_shifted;
            y_temp := y_cordic - x_shifted;
            z_temp := z_cordic + resize(shift_left(resize(ATANH_LUT(iteration), 64), Q), 64);
          end if;

          x_cordic <= x_temp;
          y_cordic <= y_temp;
          z_cordic <= z_temp;

          iteration <= iteration + 1;

          if iteration >= ITERATIONS - 1 then
            state <= FINISH;
          end if;

        when FINISH =>

          exp_out <= resize(shift_right(x_cordic + y_cordic, Q), 48);
          done <= '1';

          if start_exp = '0' then
            state <= IDLE;
          end if;

        when others =>
          state <= IDLE;

      end case;
    end if;
  end process;

  overflow <= overflow_reg;

end Behavioral;
