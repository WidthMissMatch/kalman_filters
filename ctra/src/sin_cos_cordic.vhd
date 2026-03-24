library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sin_cos_cordic is
  port (
    clk       : in  std_logic;
    start     : in  std_logic;
    angle_in  : in  signed(47 downto 0);
    sin_out   : out signed(47 downto 0);
    cos_out   : out signed(47 downto 0);
    done      : out std_logic
  );
end entity;

architecture Behavioral of sin_cos_cordic is

  type state_type is (IDLE, REDUCE_ANGLE, INIT_CORDIC, ITERATE, FINISH);
  signal state : state_type := IDLE;

  constant Q : integer := 24;

  constant PI_Q24     : signed(47 downto 0) := to_signed(52707178, 48);
  constant HALF_PI_Q24: signed(47 downto 0) := to_signed(26353589, 48);
  constant TWO_PI_Q24 : signed(47 downto 0) := to_signed(105414357, 48);

  constant CORDIC_K   : signed(47 downto 0) := to_signed(10188012, 48);

  type atan_lut_t is array (0 to 23) of signed(47 downto 0);
  constant ATAN_LUT : atan_lut_t := (
    0  => to_signed(13176795, 48),
    1  => to_signed(7778716, 48),
    2  => to_signed(4110060, 48),
    3  => to_signed(2086331, 48),
    4  => to_signed(1047214, 48),
    5  => to_signed(524117, 48),
    6  => to_signed(262081, 48),
    7  => to_signed(131043, 48),
    8  => to_signed(65522, 48),
    9  => to_signed(32761, 48),
    10 => to_signed(16381, 48),
    11 => to_signed(8190, 48),
    12 => to_signed(4095, 48),
    13 => to_signed(2048, 48),
    14 => to_signed(1024, 48),
    15 => to_signed(512, 48),
    16 => to_signed(256, 48),
    17 => to_signed(128, 48),
    18 => to_signed(64, 48),
    19 => to_signed(32, 48),
    20 => to_signed(16, 48),
    21 => to_signed(8, 48),
    22 => to_signed(4, 48),
    23 => to_signed(2, 48)
  );

  constant NUM_ITERATIONS : integer := 24;

  signal x_reg     : signed(47 downto 0);
  signal y_reg     : signed(47 downto 0);
  signal z_reg     : signed(47 downto 0);
  signal iteration : integer range 0 to NUM_ITERATIONS;

  signal reduced_angle : signed(47 downto 0);
  signal negate_sin    : std_logic;
  signal negate_cos    : std_logic;

begin

  process(clk)
    variable x_shifted : signed(47 downto 0);
    variable y_shifted : signed(47 downto 0);
    variable x_new     : signed(47 downto 0);
    variable y_new     : signed(47 downto 0);
    variable temp_angle : signed(47 downto 0);
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if start = '1' then
            state <= REDUCE_ANGLE;
          end if;

        when REDUCE_ANGLE =>

          temp_angle := angle_in;

          if temp_angle > PI_Q24 then
            temp_angle := temp_angle - TWO_PI_Q24;
            if temp_angle > PI_Q24 then
              temp_angle := temp_angle - TWO_PI_Q24;
            end if;
          elsif temp_angle < -PI_Q24 then
            temp_angle := temp_angle + TWO_PI_Q24;
            if temp_angle < -PI_Q24 then
              temp_angle := temp_angle + TWO_PI_Q24;
            end if;
          end if;

          if temp_angle > HALF_PI_Q24 then

            reduced_angle <= PI_Q24 - temp_angle;
            negate_sin <= '0';
            negate_cos <= '1';
          elsif temp_angle < -HALF_PI_Q24 then

            reduced_angle <= -PI_Q24 - temp_angle;
            negate_sin <= '1';
            negate_cos <= '1';
          else

            reduced_angle <= temp_angle;
            negate_sin <= '0';
            negate_cos <= '0';
          end if;

          state <= INIT_CORDIC;

        when INIT_CORDIC =>

          x_reg <= CORDIC_K;
          y_reg <= (others => '0');
          z_reg <= reduced_angle;
          iteration <= 0;
          state <= ITERATE;

        when ITERATE =>

          x_shifted := shift_right(x_reg, iteration);
          y_shifted := shift_right(y_reg, iteration);

          if z_reg >= 0 then
            x_new := x_reg - y_shifted;
            y_new := y_reg + x_shifted;
            z_reg <= z_reg - ATAN_LUT(iteration);
          else
            x_new := x_reg + y_shifted;
            y_new := y_reg - x_shifted;
            z_reg <= z_reg + ATAN_LUT(iteration);
          end if;

          x_reg <= x_new;
          y_reg <= y_new;

          if iteration = NUM_ITERATIONS - 1 then
            state <= FINISH;
          else
            iteration <= iteration + 1;
          end if;

        when FINISH =>

          if negate_cos = '1' then
            cos_out <= -x_reg;
          else
            cos_out <= x_reg;
          end if;

          if negate_sin = '1' then
            sin_out <= -y_reg;
          else
            sin_out <= y_reg;
          end if;

          done <= '1';
          if start = '0' then
            state <= IDLE;
          end if;

        when others =>
          state <= IDLE;
      end case;
    end if;
  end process;

end Behavioral;
