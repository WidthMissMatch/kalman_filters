library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cholesky_mult_types.all;

entity cholesky_col2_parallel is
  generic (
    Q : integer := 24
  );
  port (
    clk   : in std_logic;
    start : in std_logic;

    l22 : in signed(47 downto 0);

    p23, p24, p25, p26, p27, p28, p29 : in signed(47 downto 0);

    l21, l31, l41, l51, l61, l71, l81, l91 : in signed(47 downto 0);

    l32, l42, l52, l62, l72, l82, l92 : out signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of cholesky_col2_parallel is

  type state_type is (IDLE, MULTIPLY, SHIFT, SUBTRACT, DIVIDE, FINISH);
  signal state : state_type := IDLE;
  signal done_reg : std_logic := '0';

  signal mult_31, mult_41, mult_51, mult_61, mult_71, mult_81, mult_91 : signed(95 downto 0);

  signal prod_31, prod_41, prod_51, prod_61, prod_71, prod_81, prod_91 : signed(47 downto 0);

  signal num_32, num_42, num_52, num_62, num_72, num_82, num_92 : signed(47 downto 0);

begin

  done <= done_reg;

  process(clk)
    variable temp_div : signed(95 downto 0);
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done_reg <= '0';
          if start = '1' then
            state <= MULTIPLY;
          end if;

        when MULTIPLY =>

          mult_31 <= l21 * l31;
          mult_41 <= l21 * l41;
          mult_51 <= l21 * l51;
          mult_61 <= l21 * l61;
          mult_71 <= l21 * l71;
          mult_81 <= l21 * l81;
          mult_91 <= l21 * l91;
          state <= SHIFT;

        when SHIFT =>

          prod_31 <= resize(shift_right(mult_31, Q), 48);
          prod_41 <= resize(shift_right(mult_41, Q), 48);
          prod_51 <= resize(shift_right(mult_51, Q), 48);
          prod_61 <= resize(shift_right(mult_61, Q), 48);
          prod_71 <= resize(shift_right(mult_71, Q), 48);
          prod_81 <= resize(shift_right(mult_81, Q), 48);
          prod_91 <= resize(shift_right(mult_91, Q), 48);
          state <= SUBTRACT;

        when SUBTRACT =>

          num_32 <= p23 - prod_31;
          num_42 <= p24 - prod_41;
          num_52 <= p25 - prod_51;
          num_62 <= p26 - prod_61;
          num_72 <= p27 - prod_71;
          num_82 <= p28 - prod_81;
          num_92 <= p29 - prod_91;
          state <= DIVIDE;

        when DIVIDE =>

          if l22 /= 0 then
            temp_div := shift_left(resize(num_32, 96), Q) / resize(l22, 96);
            l32 <= resize(temp_div, 48);

            temp_div := shift_left(resize(num_42, 96), Q) / resize(l22, 96);
            l42 <= resize(temp_div, 48);

            temp_div := shift_left(resize(num_52, 96), Q) / resize(l22, 96);
            l52 <= resize(temp_div, 48);

            temp_div := shift_left(resize(num_62, 96), Q) / resize(l22, 96);
            l62 <= resize(temp_div, 48);

            temp_div := shift_left(resize(num_72, 96), Q) / resize(l22, 96);
            l72 <= resize(temp_div, 48);

            temp_div := shift_left(resize(num_82, 96), Q) / resize(l22, 96);
            l82 <= resize(temp_div, 48);

            temp_div := shift_left(resize(num_92, 96), Q) / resize(l22, 96);
            l92 <= resize(temp_div, 48);
          else
            l32 <= (others => '0');
            l42 <= (others => '0');
            l52 <= (others => '0');
            l62 <= (others => '0');
            l72 <= (others => '0');
            l82 <= (others => '0');
            l92 <= (others => '0');
          end if;
          state <= FINISH;

        when FINISH =>
          done_reg <= '1';
          if start = '0' then
            state <= IDLE;
          end if;
      end case;
    end if;
  end process;

end Behavioral;
