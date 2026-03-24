library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cholesky_mult_types.all;

entity cholesky_col3_parallel is
  generic (Q : integer := 24);
  port (
    clk   : in std_logic;
    start : in std_logic;

    l33 : in signed(47 downto 0);

    p34, p35, p36, p37, p38, p39 : in signed(47 downto 0);

    l31, l41, l51, l61, l71, l81, l91 : in signed(47 downto 0);

    l32, l42, l52, l62, l72, l82, l92 : in signed(47 downto 0);

    l43, l53, l63, l73, l83, l93 : buffer signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of cholesky_col3_parallel is

  type state_type is (IDLE, MULTIPLY_1, SHIFT_1, MULTIPLY_2, SHIFT_2, SUBTRACT, DIVIDE, FINISH);
  signal state : state_type := IDLE;
  signal done_reg : std_logic := '0';

  signal mult1_41, mult1_51, mult1_61, mult1_71, mult1_81, mult1_91 : signed(95 downto 0);
  signal prod1_41, prod1_51, prod1_61, prod1_71, prod1_81, prod1_91 : signed(47 downto 0);

  signal mult2_42, mult2_52, mult2_62, mult2_72, mult2_82, mult2_92 : signed(95 downto 0);
  signal prod2_42, prod2_52, prod2_62, prod2_72, prod2_82, prod2_92 : signed(47 downto 0);

  signal num_43, num_53, num_63, num_73, num_83, num_93 : signed(47 downto 0);

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
            state <= MULTIPLY_1;
          end if;

        when MULTIPLY_1 =>

          mult1_41 <= l31 * l41;
          mult1_51 <= l31 * l51;
          mult1_61 <= l31 * l61;
          mult1_71 <= l31 * l71;
          mult1_81 <= l31 * l81;
          mult1_91 <= l31 * l91;
          state <= SHIFT_1;

        when SHIFT_1 =>
          prod1_41 <= resize(shift_right(mult1_41, Q), 48);
          prod1_51 <= resize(shift_right(mult1_51, Q), 48);
          prod1_61 <= resize(shift_right(mult1_61, Q), 48);
          prod1_71 <= resize(shift_right(mult1_71, Q), 48);
          prod1_81 <= resize(shift_right(mult1_81, Q), 48);
          prod1_91 <= resize(shift_right(mult1_91, Q), 48);
          state <= MULTIPLY_2;

        when MULTIPLY_2 =>

          mult2_42 <= l32 * l42;
          mult2_52 <= l32 * l52;
          mult2_62 <= l32 * l62;
          mult2_72 <= l32 * l72;
          mult2_82 <= l32 * l82;
          mult2_92 <= l32 * l92;
          state <= SHIFT_2;

        when SHIFT_2 =>
          prod2_42 <= resize(shift_right(mult2_42, Q), 48);
          prod2_52 <= resize(shift_right(mult2_52, Q), 48);
          prod2_62 <= resize(shift_right(mult2_62, Q), 48);
          prod2_72 <= resize(shift_right(mult2_72, Q), 48);
          prod2_82 <= resize(shift_right(mult2_82, Q), 48);
          prod2_92 <= resize(shift_right(mult2_92, Q), 48);
          state <= SUBTRACT;

        when SUBTRACT =>

          num_43 <= p34 - prod1_41 - prod2_42;
          num_53 <= p35 - prod1_51 - prod2_52;
          num_63 <= p36 - prod1_61 - prod2_62;
          num_73 <= p37 - prod1_71 - prod2_72;
          num_83 <= p38 - prod1_81 - prod2_82;
          num_93 <= p39 - prod1_91 - prod2_92;
          state <= DIVIDE;

        when DIVIDE =>
          if l33 /= 0 then
            temp_div := shift_left(resize(num_43, 96), Q) / resize(l33, 96);
            l43 <= resize(temp_div, 48);

            temp_div := shift_left(resize(num_53, 96), Q) / resize(l33, 96);
            l53 <= resize(temp_div, 48);

            temp_div := shift_left(resize(num_63, 96), Q) / resize(l33, 96);
            l63 <= resize(temp_div, 48);

            temp_div := shift_left(resize(num_73, 96), Q) / resize(l33, 96);
            l73 <= resize(temp_div, 48);

            temp_div := shift_left(resize(num_83, 96), Q) / resize(l33, 96);
            l83 <= resize(temp_div, 48);

            temp_div := shift_left(resize(num_93, 96), Q) / resize(l33, 96);
            l93 <= resize(temp_div, 48);
          else
            l43 <= (others => '0');
            l53 <= (others => '0');
            l63 <= (others => '0');
            l73 <= (others => '0');
            l83 <= (others => '0');
            l93 <= (others => '0');
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
