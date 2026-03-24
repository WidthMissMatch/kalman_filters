library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sqrt_cordic is
  port (
    clk            : in  std_logic;
    start_rt       : in  std_logic;
    x_in           : in  signed(47 downto 0);
    x_out          : out signed(47 downto 0);
    done           : out std_logic;
    negative_input : out std_logic
  );
end entity;

architecture Behavioral of sqrt_cordic is

  type state_type is (IDLE, INIT, CHECK_INPUT, ITERATE, FINISH);
  signal state : state_type := IDLE;

  signal x_current : signed(47 downto 0);
  signal x_next    : signed(47 downto 0);
  signal iteration : integer range 0 to 15;
  signal x_input   : signed(47 downto 0);
  signal negative_input_reg : std_logic := '0';

  constant Q : integer := 24;
  constant ITERATIONS : integer := 7;
  constant HALF : signed(47 downto 0) := to_signed(8388608, 48);

  function count_leading_zeros(x : signed(47 downto 0)) return integer is
    variable count : integer := 0;
  begin
    for i in 47 downto 0 loop
      if x(i) = '1' then
        return 47 - i;
      end if;
    end loop;
    return 48;
  end function;

begin

  process(clk)
    variable temp_div : signed(95 downto 0);
    variable temp_sum : signed(47 downto 0);
    variable temp_mul : signed(95 downto 0);
    variable clz : integer;
    variable initial_guess : signed(47 downto 0);
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          negative_input_reg <= '0';
          if start_rt = '1' then
            x_input <= x_in;
            iteration <= 0;
            state <= INIT;
          end if;

        when INIT =>

          if x_input = 0 then
            x_current <= (others => '0');
            state <= FINISH;
          else

            x_current <= shift_right(x_input, 1);
            state <= CHECK_INPUT;
          end if;

        when CHECK_INPUT =>

          if x_input < 0 then

            negative_input_reg <= '1';
            x_current <= (others => '0');
            state <= FINISH;
          else

            negative_input_reg <= '0';
            state <= ITERATE;
          end if;

        when ITERATE =>

          temp_div := shift_left(resize(x_input, 96), Q);
          temp_div := temp_div / x_current;

          temp_sum := x_current + resize(temp_div(47 downto 0), 48);

          temp_mul := temp_sum * HALF;
          x_next <= resize(shift_right(temp_mul, Q), 48);

          x_current <= resize(shift_right(temp_mul, Q), 48);
          iteration <= iteration + 1;

          if iteration >= ITERATIONS - 1 then
            state <= FINISH;
          end if;

        when FINISH =>
          x_out <= x_current;
          done <= '1';
          if start_rt = '0' then
            state <= IDLE;
          end if;

        when others =>
          state <= IDLE;
      end case;
    end if;
  end process;

  negative_input <= negative_input_reg;

end Behavioral;
