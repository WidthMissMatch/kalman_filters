library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cholesky_mult_types.all;

entity cholesky_col5_parallel is
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
end entity;

architecture Behavioral of cholesky_col5_parallel is

  type state_type is (IDLE, MULT1, MULT2, MULT3, MULT4, SUBTRACT, DIVIDE, FINISH);
  signal state : state_type := IDLE;
  signal done_reg : std_logic := '0';

  signal prod1_65, prod1_75, prod1_85, prod1_95 : signed(47 downto 0);
  signal prod2_65, prod2_75, prod2_85, prod2_95 : signed(47 downto 0);
  signal prod3_65, prod3_75, prod3_85, prod3_95 : signed(47 downto 0);
  signal prod4_65, prod4_75, prod4_85, prod4_95 : signed(47 downto 0);
  signal num_65, num_75, num_85, num_95 : signed(47 downto 0);

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
          temp_mul := l51 * l61; prod1_65 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l51 * l71; prod1_75 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l51 * l81; prod1_85 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l51 * l91; prod1_95 <= resize(shift_right(temp_mul, Q), 48);
          state <= MULT2;

        when MULT2 =>
          temp_mul := l52 * l62; prod2_65 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l52 * l72; prod2_75 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l52 * l82; prod2_85 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l52 * l92; prod2_95 <= resize(shift_right(temp_mul, Q), 48);
          state <= MULT3;

        when MULT3 =>
          temp_mul := l53 * l63; prod3_65 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l53 * l73; prod3_75 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l53 * l83; prod3_85 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l53 * l93; prod3_95 <= resize(shift_right(temp_mul, Q), 48);
          state <= MULT4;

        when MULT4 =>
          temp_mul := l54 * l64; prod4_65 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l54 * l74; prod4_75 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l54 * l84; prod4_85 <= resize(shift_right(temp_mul, Q), 48);
          temp_mul := l54 * l94; prod4_95 <= resize(shift_right(temp_mul, Q), 48);
          state <= SUBTRACT;

        when SUBTRACT =>
          num_65 <= p56 - prod1_65 - prod2_65 - prod3_65 - prod4_65;
          num_75 <= p57 - prod1_75 - prod2_75 - prod3_75 - prod4_75;
          num_85 <= p58 - prod1_85 - prod2_85 - prod3_85 - prod4_85;
          num_95 <= p59 - prod1_95 - prod2_95 - prod3_95 - prod4_95;
          state <= DIVIDE;

        when DIVIDE =>
          if l55 /= 0 then
            temp_div := shift_left(resize(num_65, 96), Q) / resize(l55, 96); l65 <= resize(temp_div, 48);
            temp_div := shift_left(resize(num_75, 96), Q) / resize(l55, 96); l75 <= resize(temp_div, 48);
            temp_div := shift_left(resize(num_85, 96), Q) / resize(l55, 96); l85 <= resize(temp_div, 48);
            temp_div := shift_left(resize(num_95, 96), Q) / resize(l55, 96); l95 <= resize(temp_div, 48);
          else
            l65 <= (others => '0'); l75 <= (others => '0');
            l85 <= (others => '0'); l95 <= (others => '0');
          end if;
          state <= FINISH;

        when FINISH =>
          done_reg <= '1';
          if start = '0' then state <= IDLE; end if;
      end case;
    end if;
  end process;

end Behavioral;
