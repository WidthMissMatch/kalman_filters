library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reciprocal_newton is
  port (
    clk      : in  std_logic;
    start_rt : in  std_logic;
    x_in     : in  signed(47 downto 0);
    x_out    : out signed(47 downto 0);
    done     : out std_logic
  );
end entity;

architecture Behavioral of reciprocal_newton is
  type state_type is (IDLE, INIT, ITERATE, FINISH);
  signal state : state_type := IDLE;

  signal x_current : signed(47 downto 0);
  signal x_next    : signed(47 downto 0);
  signal iteration : integer range 0 to 15;
  signal x_input   : signed(47 downto 0);

  constant Q : integer := 24;
  constant ITERATIONS : integer := 10;
  constant TWO : signed(47 downto 0) := to_signed(33554432, 48);
  constant VERY_SMALL : signed(47 downto 0) := to_signed(4096, 48);

begin

  process(clk)
    variable temp_mul : signed(95 downto 0);
    variable temp_scaled : signed(47 downto 0);
    variable temp_sub : signed(47 downto 0);
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if start_rt = '1' then
            x_input <= x_in;
            iteration <= 0;
            state <= INIT;
          end if;

        when INIT =>

          if abs(x_input) < VERY_SMALL then

            x_current <= (others => '0');
            state <= FINISH;
          elsif abs(x_input) >= to_signed(67108864, 48) then
            x_current <= to_signed(1677722, 48);
          elsif abs(x_input) >= to_signed(16777216, 48) then
            x_current <= to_signed(8388608, 48);
          else
            x_current <= to_signed(25165824, 48);
          end if;
          state <= ITERATE;

        when ITERATE =>

          temp_mul := x_input * x_current;
          temp_scaled := resize(shift_right(temp_mul, Q), 48);

          temp_sub := TWO - temp_scaled;

          temp_mul := x_current * temp_sub;
          x_next <= resize(shift_right(temp_mul, Q), 48);

          x_current <= x_next;
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

end Behavioral;
