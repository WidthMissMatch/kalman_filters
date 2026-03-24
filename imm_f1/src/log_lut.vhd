library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity log_lut is
  port (
    clk   : in  std_logic;
    start : in  std_logic;
    x_in  : in  signed(47 downto 0);
    y_out : out signed(47 downto 0);
    done  : out std_logic
  );
end entity;

architecture Behavioral of log_lut is

  constant Q : integer := 24;

  constant LN2_Q24 : signed(47 downto 0) := to_signed(11629080, 48);
  constant MIN_VALUE : signed(47 downto 0) := (47 => '1', others => '0');

  type lut_t is array (0 to 16) of signed(47 downto 0);
  constant LN_LUT : lut_t := (
    0  => to_signed(-11629080, 48),
    1  => to_signed(-11117459, 48),
    2  => to_signed(-10630698, 48),
    3  => to_signed(-10166199, 48),
    4  => to_signed(-9721686, 48),
    5  => to_signed(-9295167, 48),
    6  => to_signed(-8884897, 48),
    7  => to_signed(-8489337, 48),
    8  => to_signed(-8107137, 48),
    9  => to_signed(-7737095, 48),
    10 => to_signed(-7378130, 48),
    11 => to_signed(-7029268, 48),
    12 => to_signed(-6689622, 48),
    13 => to_signed(-6358373, 48),
    14 => to_signed(-6034753, 48),
    15 => to_signed(-5718032, 48),
    16 => to_signed(0, 48)
  );

  type state_type is (IDLE, NORMALIZE, LOOKUP, INTERPOLATE, OUTPUT);
  signal state : state_type := IDLE;

  signal mantissa : signed(47 downto 0);
  signal exponent : integer range -48 to 48;
  signal lut_idx  : integer range 0 to 16;
  signal frac     : signed(47 downto 0);

begin

  process(clk)
    variable x_abs    : unsigned(47 downto 0);
    variable leading  : integer;
    variable shift_amt: integer;
    variable m_val    : signed(47 downto 0);
    variable idx      : integer;
    variable interp   : signed(95 downto 0);
    variable y0, y1   : signed(47 downto 0);
    variable exp_contrib : signed(47 downto 0);
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if start = '1' then
            if x_in <= to_signed(0, 48) then
              y_out <= MIN_VALUE;
              done <= '1';
              state <= IDLE;
            else
              state <= NORMALIZE;
            end if;
          end if;

        when NORMALIZE =>

          x_abs := unsigned(x_in);
          leading := 0;
          for i in 47 downto 0 loop
            if x_abs(i) = '1' then
              leading := i;
              exit;
            end if;
          end loop;

          shift_amt := 23 - leading;
          exponent <= leading - 23;

          if shift_amt > 0 then
            m_val := signed(shift_left(x_abs, shift_amt));
          elsif shift_amt < 0 then
            m_val := signed(shift_right(x_abs, -shift_amt));
          else
            m_val := signed(x_abs);
          end if;
          mantissa <= m_val;

          state <= LOOKUP;

        when LOOKUP =>

          idx := to_integer(shift_right(unsigned(mantissa) - 8388608, 19));
          if idx > 15 then
            idx := 15;
          end if;
          lut_idx <= idx;

          frac <= mantissa - to_signed(8388608 + idx * 524288, 48);
          state <= INTERPOLATE;

        when INTERPOLATE =>
          y0 := LN_LUT(lut_idx);
          y1 := LN_LUT(lut_idx + 1);

          interp := (y1 - y0) * shift_left(frac, 5);
          mantissa <= y0 + resize(shift_right(interp, Q), 48);

          state <= OUTPUT;

        when OUTPUT =>

          exp_contrib := resize(to_signed(exponent, 8) * LN2_Q24, 48);
          y_out <= mantissa + exp_contrib;
          done <= '1';
          if start = '0' then
            state <= IDLE;
          end if;

      end case;
    end if;
  end process;

end Behavioral;
