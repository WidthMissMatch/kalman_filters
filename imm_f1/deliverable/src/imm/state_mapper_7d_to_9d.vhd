library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_mapper_7d_to_9d is
  port (
    clk   : in  std_logic;
    start : in  std_logic;

    px_in, py_in, v_in, theta_in, delta_in, a_in, z_in : in signed(47 downto 0);

    x_pos_out, x_vel_out, x_acc_out : out signed(47 downto 0);
    y_pos_out, y_vel_out, y_acc_out : out signed(47 downto 0);
    z_pos_out, z_vel_out, z_acc_out : out signed(47 downto 0);
    done  : out std_logic
  );
end entity;

architecture rtl of state_mapper_7d_to_9d is

  constant Q : integer := 24;

  type state_t is (
    S_IDLE,
    S_START_SINCOS,
    S_WAIT_SINCOS,
    S_MULTIPLY,
    S_OUTPUT
  );

  signal state : state_t := S_IDLE;

  signal px_r, py_r, v_r, theta_r, a_r, z_r : signed(47 downto 0);

  signal sc_start   : std_logic := '0';
  signal sc_angle   : signed(47 downto 0) := (others => '0');
  signal sc_sin_out : signed(47 downto 0);
  signal sc_cos_out : signed(47 downto 0);
  signal sc_done    : std_logic;

  signal sin_theta : signed(47 downto 0) := (others => '0');
  signal cos_theta : signed(47 downto 0) := (others => '0');

  signal x_vel_reg, y_vel_reg : signed(47 downto 0) := (others => '0');
  signal x_acc_reg, y_acc_reg : signed(47 downto 0) := (others => '0');

begin

  u_sincos : entity work.sin_cos_cordic
    port map (
      clk       => clk,
      start     => sc_start,
      angle_in  => sc_angle,
      sin_out   => sc_sin_out,
      cos_out   => sc_cos_out,
      done      => sc_done
    );

  process(clk)
    variable v_wide   : signed(95 downto 0);
    variable a_wide   : signed(95 downto 0);
    variable cos_wide : signed(95 downto 0);
    variable sin_wide : signed(95 downto 0);
  begin
    if rising_edge(clk) then

      sc_start <= '0';
      done     <= '0';

      case state is

        when S_IDLE =>
          if start = '1' then
            px_r    <= px_in;
            py_r    <= py_in;
            v_r     <= v_in;
            theta_r <= theta_in;
            a_r     <= a_in;
            z_r     <= z_in;
            state   <= S_START_SINCOS;
          end if;

        when S_START_SINCOS =>
          sc_angle <= theta_r;
          sc_start <= '1';
          state    <= S_WAIT_SINCOS;

        when S_WAIT_SINCOS =>
          if sc_done = '1' then
            sin_theta <= sc_sin_out;
            cos_theta <= sc_cos_out;
            state     <= S_MULTIPLY;
          end if;

        when S_MULTIPLY =>
          v_wide   := resize(v_r, 96);
          a_wide   := resize(a_r, 96);
          cos_wide := resize(cos_theta, 96);
          sin_wide := resize(sin_theta, 96);

          x_vel_reg <= resize(shift_right(v_wide * cos_wide, Q), 48);
          y_vel_reg <= resize(shift_right(v_wide * sin_wide, Q), 48);
          x_acc_reg <= resize(shift_right(a_wide * cos_wide, Q), 48);
          y_acc_reg <= resize(shift_right(a_wide * sin_wide, Q), 48);

          state <= S_OUTPUT;

        when S_OUTPUT =>
          x_pos_out <= px_r;
          y_pos_out <= py_r;
          z_pos_out <= z_r;

          x_vel_out <= x_vel_reg;
          y_vel_out <= y_vel_reg;

          x_acc_out <= x_acc_reg;
          y_acc_out <= y_acc_reg;

          z_vel_out <= (others => '0');
          z_acc_out <= (others => '0');

          done  <= '1';
          state <= S_IDLE;

      end case;
    end if;
  end process;

end architecture;
