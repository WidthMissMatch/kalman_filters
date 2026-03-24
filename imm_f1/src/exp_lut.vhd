library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity exp_lut is
  port (
    clk   : in  std_logic;
    start : in  std_logic;
    x_in  : in  signed(47 downto 0);
    y_out : out signed(47 downto 0);
    done  : out std_logic
  );
end entity;

architecture Behavioral of exp_lut is

  constant Q : integer := 24;
  constant ONE_Q24 : signed(47 downto 0) := to_signed(16777216, 48);

  type lut_t is array (0 to 16) of signed(47 downto 0);
  constant EXP_LUT : lut_t := (
    0  => to_signed(5627, 48),
    1  => to_signed(9281, 48),
    2  => to_signed(15307, 48),
    3  => to_signed(25247, 48),
    4  => to_signed(41645, 48),
    5  => to_signed(68700, 48),
    6  => to_signed(113337, 48),
    7  => to_signed(186939, 48),
    8  => to_signed(308380, 48),
    9  => to_signed(508738, 48),
    10 => to_signed(839334, 48),
    11 => to_signed(1384636, 48),
    12 => to_signed(2283965, 48),
    13 => to_signed(3767270, 48),
    14 => to_signed(6214389, 48),
    15 => to_signed(10252487, 48),
    16 => to_signed(16777216, 48)
  );

  constant HALF_Q24 : signed(47 downto 0) := to_signed(8388608, 48);

  constant NEG8_Q24 : signed(47 downto 0) := to_signed(-134217728, 48);

  type state_type is (IDLE, COMPUTE_INDEX, INTERPOLATE, OUTPUT);
  signal state : state_type := IDLE;

  signal lut_idx : integer range 0 to 16;
  signal frac    : signed(47 downto 0);
  signal y0, y1  : signed(47 downto 0);

begin

  process(clk)
    variable x_clamped : signed(47 downto 0);
    variable offset    : signed(47 downto 0);
    variable idx_val   : integer;
    variable interp    : signed(95 downto 0);
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if start = '1' then
            state <= COMPUTE_INDEX;
          end if;

        when COMPUTE_INDEX =>

          if x_in > 0 then
            x_clamped := (others => '0');
          elsif x_in < NEG8_Q24 then
            x_clamped := NEG8_Q24;
          else
            x_clamped := x_in;
          end if;

          offset := x_clamped - NEG8_Q24;

          idx_val := to_integer(shift_right(offset, 23));
          if idx_val > 15 then
            idx_val := 15;
          end if;
          lut_idx <= idx_val;

          frac <= offset - to_signed(idx_val * 8388608, 48);

          state <= INTERPOLATE;

        when INTERPOLATE =>
          y0 <= EXP_LUT(lut_idx);
          y1 <= EXP_LUT(lut_idx + 1);
          state <= OUTPUT;

        when OUTPUT =>

          interp := (y1 - y0) * (shift_left(frac, 1));
          y_out <= y0 + resize(shift_right(interp, Q), 48);
          done <= '1';
          if start = '0' then
            state <= IDLE;
          end if;

      end case;
    end if;
  end process;

end Behavioral;
