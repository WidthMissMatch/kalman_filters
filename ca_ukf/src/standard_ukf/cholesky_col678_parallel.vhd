library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cholesky_mult_types.all;

entity cholesky_col678_parallel is
  generic (Q : integer := 24);
  port (
    clk   : in std_logic;
    start : in std_logic;

    l66 : in signed(47 downto 0);
    p67, p68, p69 : in signed(47 downto 0);
    l61, l71, l81, l91 : in signed(47 downto 0);
    l62, l72, l82, l92 : in signed(47 downto 0);
    l63, l73, l83, l93 : in signed(47 downto 0);
    l64, l74, l84, l94 : in signed(47 downto 0);
    l65, l75, l85, l95 : in signed(47 downto 0);
    l76, l86, l96 : buffer signed(47 downto 0);

    l77 : in signed(47 downto 0);
    p78, p79 : in signed(47 downto 0);
    l87, l97 : buffer signed(47 downto 0);

    l88 : in signed(47 downto 0);
    p89 : in signed(47 downto 0);
    l98 : buffer signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of cholesky_col678_parallel is

  type state_type is (IDLE,
    COL6_M1, COL6_M2, COL6_M3, COL6_M4, COL6_M5, COL6_SUB, COL6_DIV,
    COL7_M1, COL7_M2, COL7_M3, COL7_M4, COL7_M5, COL7_M6, COL7_SUB, COL7_DIV,
    COL8_M1, COL8_M2, COL8_M3, COL8_M4, COL8_M5, COL8_M6, COL8_M7, COL8_SUB, COL8_DIV,
    FINISH);
  signal state : state_type := IDLE;
  signal done_reg : std_logic := '0';

  signal acc6_76, acc6_86, acc6_96 : signed(47 downto 0);

  signal acc7_87, acc7_97 : signed(47 downto 0);

  signal acc8_98 : signed(47 downto 0);

begin

  done <= done_reg;

  process(clk)
    variable temp_mul : signed(95 downto 0);
    variable temp_prod : signed(47 downto 0);
    variable temp_div : signed(95 downto 0);
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done_reg <= '0';
          if start = '1' then
            acc6_76 <= p67; acc6_86 <= p68; acc6_96 <= p69;
            state <= COL6_M1;
          end if;

        when COL6_M1 =>
          temp_mul := l61 * l71; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_76 <= acc6_76 - temp_prod;
          temp_mul := l61 * l81; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_86 <= acc6_86 - temp_prod;
          temp_mul := l61 * l91; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_96 <= acc6_96 - temp_prod;
          state <= COL6_M2;

        when COL6_M2 =>
          temp_mul := l62 * l72; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_76 <= acc6_76 - temp_prod;
          temp_mul := l62 * l82; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_86 <= acc6_86 - temp_prod;
          temp_mul := l62 * l92; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_96 <= acc6_96 - temp_prod;
          state <= COL6_M3;

        when COL6_M3 =>
          temp_mul := l63 * l73; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_76 <= acc6_76 - temp_prod;
          temp_mul := l63 * l83; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_86 <= acc6_86 - temp_prod;
          temp_mul := l63 * l93; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_96 <= acc6_96 - temp_prod;
          state <= COL6_M4;

        when COL6_M4 =>
          temp_mul := l64 * l74; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_76 <= acc6_76 - temp_prod;
          temp_mul := l64 * l84; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_86 <= acc6_86 - temp_prod;
          temp_mul := l64 * l94; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_96 <= acc6_96 - temp_prod;
          state <= COL6_M5;

        when COL6_M5 =>
          temp_mul := l65 * l75; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_76 <= acc6_76 - temp_prod;
          temp_mul := l65 * l85; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_86 <= acc6_86 - temp_prod;
          temp_mul := l65 * l95; temp_prod := resize(shift_right(temp_mul, Q), 48); acc6_96 <= acc6_96 - temp_prod;
          state <= COL6_DIV;

        when COL6_DIV =>
          if l66 /= 0 then
            temp_div := shift_left(resize(acc6_76, 96), Q) / resize(l66, 96); l76 <= resize(temp_div, 48);
            temp_div := shift_left(resize(acc6_86, 96), Q) / resize(l66, 96); l86 <= resize(temp_div, 48);
            temp_div := shift_left(resize(acc6_96, 96), Q) / resize(l66, 96); l96 <= resize(temp_div, 48);
          else
            l76 <= (others => '0'); l86 <= (others => '0'); l96 <= (others => '0');
          end if;
          acc7_87 <= p78; acc7_97 <= p79;
          state <= COL7_M1;

        when COL7_M1 =>
          temp_mul := l71 * l81; temp_prod := resize(shift_right(temp_mul, Q), 48); acc7_87 <= acc7_87 - temp_prod;
          temp_mul := l71 * l91; temp_prod := resize(shift_right(temp_mul, Q), 48); acc7_97 <= acc7_97 - temp_prod;
          state <= COL7_M2;

        when COL7_M2 =>
          temp_mul := l72 * l82; temp_prod := resize(shift_right(temp_mul, Q), 48); acc7_87 <= acc7_87 - temp_prod;
          temp_mul := l72 * l92; temp_prod := resize(shift_right(temp_mul, Q), 48); acc7_97 <= acc7_97 - temp_prod;
          state <= COL7_M3;

        when COL7_M3 =>
          temp_mul := l73 * l83; temp_prod := resize(shift_right(temp_mul, Q), 48); acc7_87 <= acc7_87 - temp_prod;
          temp_mul := l73 * l93; temp_prod := resize(shift_right(temp_mul, Q), 48); acc7_97 <= acc7_97 - temp_prod;
          state <= COL7_M4;

        when COL7_M4 =>
          temp_mul := l74 * l84; temp_prod := resize(shift_right(temp_mul, Q), 48); acc7_87 <= acc7_87 - temp_prod;
          temp_mul := l74 * l94; temp_prod := resize(shift_right(temp_mul, Q), 48); acc7_97 <= acc7_97 - temp_prod;
          state <= COL7_M5;

        when COL7_M5 =>
          temp_mul := l75 * l85; temp_prod := resize(shift_right(temp_mul, Q), 48); acc7_87 <= acc7_87 - temp_prod;
          temp_mul := l75 * l95; temp_prod := resize(shift_right(temp_mul, Q), 48); acc7_97 <= acc7_97 - temp_prod;
          state <= COL7_M6;

        when COL7_M6 =>
          temp_mul := l76 * l86; temp_prod := resize(shift_right(temp_mul, Q), 48); acc7_87 <= acc7_87 - temp_prod;
          temp_mul := l76 * l96; temp_prod := resize(shift_right(temp_mul, Q), 48); acc7_97 <= acc7_97 - temp_prod;
          state <= COL7_DIV;

        when COL7_DIV =>
          if l77 /= 0 then
            temp_div := shift_left(resize(acc7_87, 96), Q) / resize(l77, 96); l87 <= resize(temp_div, 48);
            temp_div := shift_left(resize(acc7_97, 96), Q) / resize(l77, 96); l97 <= resize(temp_div, 48);
          else
            l87 <= (others => '0'); l97 <= (others => '0');
          end if;
          acc8_98 <= p89;
          state <= COL8_M1;

        when COL8_M1 =>
          temp_mul := l81 * l91; temp_prod := resize(shift_right(temp_mul, Q), 48); acc8_98 <= acc8_98 - temp_prod;
          state <= COL8_M2;

        when COL8_M2 =>
          temp_mul := l82 * l92; temp_prod := resize(shift_right(temp_mul, Q), 48); acc8_98 <= acc8_98 - temp_prod;
          state <= COL8_M3;

        when COL8_M3 =>
          temp_mul := l83 * l93; temp_prod := resize(shift_right(temp_mul, Q), 48); acc8_98 <= acc8_98 - temp_prod;
          state <= COL8_M4;

        when COL8_M4 =>
          temp_mul := l84 * l94; temp_prod := resize(shift_right(temp_mul, Q), 48); acc8_98 <= acc8_98 - temp_prod;
          state <= COL8_M5;

        when COL8_M5 =>
          temp_mul := l85 * l95; temp_prod := resize(shift_right(temp_mul, Q), 48); acc8_98 <= acc8_98 - temp_prod;
          state <= COL8_M6;

        when COL8_M6 =>
          temp_mul := l86 * l96; temp_prod := resize(shift_right(temp_mul, Q), 48); acc8_98 <= acc8_98 - temp_prod;
          state <= COL8_M7;

        when COL8_M7 =>
          temp_mul := l87 * l97; temp_prod := resize(shift_right(temp_mul, Q), 48); acc8_98 <= acc8_98 - temp_prod;
          state <= COL8_DIV;

        when COL8_DIV =>
          if l88 /= 0 then
            temp_div := shift_left(resize(acc8_98, 96), Q) / resize(l88, 96); l98 <= resize(temp_div, 48);
          else
            l98 <= (others => '0');
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
