library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cholesky_mult_types.all;

entity cholesky_col4_parallel is
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
end entity;

architecture Behavioral of cholesky_col4_parallel is

  type state_type is (IDLE, MULT1, SHIFT1, MULT2, SHIFT2, MULT3, SHIFT3, SUBTRACT, DIVIDE, FINISH);
  signal state : state_type := IDLE;
  signal done_reg : std_logic := '0';

  signal prod1_54, prod1_64, prod1_74, prod1_84, prod1_94 : signed(47 downto 0);
  signal prod2_54, prod2_64, prod2_74, prod2_84, prod2_94 : signed(47 downto 0);
  signal prod3_54, prod3_64, prod3_74, prod3_84, prod3_94 : signed(47 downto 0);
  signal num_54, num_64, num_74, num_84, num_94 : signed(47 downto 0);

begin

  done <= done_reg;

  process(clk)
    variable temp_mul : signed(95 downto 0);
    variable temp_div : signed(95 downto 0);
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done_reg <= '0';
          if start = '1' then state <= MULT1; end if;

        when MULT1 =>
          temp_mul := l41 * l51; prod1_54 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l41 * l61; prod1_64 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l41 * l71; prod1_74 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l41 * l81; prod1_84 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l41 * l91; prod1_94 <= resize(shift_right(temp_mul, Q), 48);
          state <= MULT2;

        when MULT2 =>
          temp_mul := l42 * l52; prod2_54 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l42 * l62; prod2_64 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l42 * l72; prod2_74 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l42 * l82; prod2_84 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l42 * l92; prod2_94 <= resize(shift_right(temp_mul, Q), 48);
          state <= MULT3;

        when MULT3 =>
          temp_mul := l43 * l53; prod3_54 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l43 * l63; prod3_64 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l43 * l73; prod3_74 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l43 * l83; prod3_84 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l43 * l93; prod3_94 <= resize(shift_right(temp_mul, Q), 48);
          state <= SUBTRACT;

        when SUBTRACT =>
          num_54 <= p45 - prod1_54 - prod2_54 - prod3_54;
          num_64 <= p46 - prod1_64 - prod2_64 - prod3_64;
          num_74 <= p47 - prod1_74 - prod2_74 - prod3_74;
          num_84 <= p48 - prod1_84 - prod2_84 - prod3_84;
          num_94 <= p49 - prod1_94 - prod2_94 - prod3_94;
          state <= DIVIDE;

        when DIVIDE =>
          if l44 /= 0 then
            temp_div := shift_left(resize(num_54, 96), Q) / resize(l44, 96); l54 <= resize(temp_div, 48);
            temp_div := shift_left(resize(num_64, 96), Q) / resize(l44, 96); l64 <= resize(temp_div, 48);
            temp_div := shift_left(resize(num_74, 96), Q) / resize(l44, 96); l74 <= resize(temp_div, 48);
            temp_div := shift_left(resize(num_84, 96), Q) / resize(l44, 96); l84 <= resize(temp_div, 48);
            temp_div := shift_left(resize(num_94, 96), Q) / resize(l44, 96); l94 <= resize(temp_div, 48);
          else
            l54 <= (others => '0'); l64 <= (others => '0'); l74 <= (others => '0');
            l84 <= (others => '0'); l94 <= (others => '0');
          end if;
          state <= FINISH;

        when FINISH =>
          done_reg <= '1';
          if start = '0' then state <= IDLE; end if;

        when others => state <= IDLE;
      end case;
    end if;
  end process;

end Behavioral;
