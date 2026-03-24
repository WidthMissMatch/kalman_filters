library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_mapper_9d_to_7d_ctra is
  port (
    clk   : in  std_logic;
    start : in  std_logic;

    x_pos_in, x_vel_in, x_acc_in : in signed(47 downto 0);
    y_pos_in, y_vel_in, y_acc_in : in signed(47 downto 0);
    z_pos_in, z_vel_in, z_acc_in : in signed(47 downto 0);

    px_out, py_out, v_out, theta_out, omega_out, a_out, z_out : out signed(47 downto 0);
    done  : out std_logic
  );
end entity;

architecture rtl of state_mapper_9d_to_7d_ctra is

  constant Q : integer := 24;

  constant MAX_S48 : signed(47 downto 0) := "0" & (46 downto 0 => '1');
  constant MAX_S96 : signed(95 downto 0) := resize(MAX_S48, 96);

  type atan_lut_t is array(0 to 23) of signed(47 downto 0);
  constant ATAN_LUT : atan_lut_t := (
    to_signed(13176795, 48),
    to_signed(7778716,  48),
    to_signed(4110060,  48),
    to_signed(2086331,  48),
    to_signed(1047214,  48),
    to_signed(524117,   48),
    to_signed(262081,   48),
    to_signed(131043,   48),
    to_signed(65522,    48),
    to_signed(32761,    48),
    to_signed(16381,    48),
    to_signed(8190,     48),
    to_signed(4095,     48),
    to_signed(2048,     48),
    to_signed(1024,     48),
    to_signed(512,      48),
    to_signed(256,      48),
    to_signed(128,      48),
    to_signed(64,       48),
    to_signed(32,       48),
    to_signed(16,       48),
    to_signed(8,        48),
    to_signed(4,        48),
    to_signed(2,        48)
  );

  constant PI_Q24      : signed(47 downto 0) := to_signed(52707178, 48);
  constant V_EPSILON   : signed(47 downto 0) := to_signed(168, 48);

  type state_t is (
    S_IDLE,
    S_COMPUTE_V_SQ,
    S_WAIT_SQRT,
    S_ATAN2_INIT,
    S_ATAN2_ITER,
    S_COMPUTE_DOT,
    S_DIV_INIT,
    S_DIV_ITER,
    S_WAIT_ACC_SQRT,
    S_COMPUTE_CROSS,
    S_DIV_OMEGA_INIT,
    S_DIV_OMEGA_ITER,
    S_OUTPUT
  );

  signal state : state_t := S_IDLE;

  signal x_pos_r, x_vel_r, x_acc_r : signed(47 downto 0);
  signal y_pos_r, y_vel_r, y_acc_r : signed(47 downto 0);
  signal z_pos_r                    : signed(47 downto 0);

  signal v_reg     : signed(47 downto 0) := (others => '0');
  signal theta_reg : signed(47 downto 0) := (others => '0');
  signal a_reg     : signed(47 downto 0) := (others => '0');
  signal omega_reg : signed(47 downto 0) := (others => '0');
  signal v_sq_reg  : signed(47 downto 0) := (others => '0');

  signal sqrt_start : std_logic := '0';
  signal sqrt_x_in  : signed(47 downto 0) := (others => '0');
  signal sqrt_x_out : signed(47 downto 0);
  signal sqrt_done  : std_logic;
  signal sqrt_neg   : std_logic;

  signal dot_product   : signed(47 downto 0) := (others => '0');
  signal cross_product : signed(47 downto 0) := (others => '0');
  signal v_too_small   : std_logic := '0';

  signal cordic_x    : signed(47 downto 0) := (others => '0');
  signal cordic_y    : signed(47 downto 0) := (others => '0');
  signal cordic_z    : signed(47 downto 0) := (others => '0');
  signal cordic_iter : integer range 0 to 24 := 0;
  signal quad_adjust : signed(47 downto 0) := (others => '0');

  signal div_num   : unsigned(71 downto 0) := (others => '0');
  signal div_den   : unsigned(47 downto 0) := (others => '0');
  signal div_quot  : unsigned(71 downto 0) := (others => '0');
  signal div_rem   : unsigned(47 downto 0) := (others => '0');
  signal div_sign  : std_logic := '0';
  signal div_iter  : integer range 0 to 72 := 0;

begin

  u_sqrt : entity work.sqrt_cordic
    port map (
      clk            => clk,
      start_rt       => sqrt_start,
      x_in           => sqrt_x_in,
      x_out          => sqrt_x_out,
      done           => sqrt_done,
      negative_input => sqrt_neg
    );

  process(clk)
    variable v_sq_96   : signed(95 downto 0);
    variable x_shifted : signed(47 downto 0);
    variable y_shifted : signed(47 downto 0);
    variable abs_dot   : signed(47 downto 0);
    variable abs_v     : signed(47 downto 0);
    variable abs_cross : signed(47 downto 0);
    variable abs_vsq   : signed(47 downto 0);
    variable acc_sq_96 : signed(95 downto 0);
    variable dot_96    : signed(95 downto 0);
    variable cross_96  : signed(95 downto 0);
    variable new_rem_48: unsigned(47 downto 0);
    variable q_tmp     : unsigned(71 downto 0);
  begin
    if rising_edge(clk) then

      sqrt_start <= '0';
      done       <= '0';

      case state is

        when S_IDLE =>
          if start = '1' then
            x_pos_r <= x_pos_in;
            x_vel_r <= x_vel_in;
            x_acc_r <= x_acc_in;
            y_pos_r <= y_pos_in;
            y_vel_r <= y_vel_in;
            y_acc_r <= y_acc_in;
            z_pos_r <= z_pos_in;
            state   <= S_COMPUTE_V_SQ;
          end if;

        when S_COMPUTE_V_SQ =>
          v_sq_96 := shift_right(x_vel_r * x_vel_r, Q)
                   + shift_right(y_vel_r * y_vel_r, Q);

          if v_sq_96 > MAX_S96 then
            sqrt_x_in <= MAX_S48;
            v_sq_reg  <= MAX_S48;
          elsif v_sq_96 < to_signed(0, 96) then
            sqrt_x_in <= (others => '0');
            v_sq_reg  <= (others => '0');
          else
            sqrt_x_in <= resize(v_sq_96, 48);
            v_sq_reg  <= resize(v_sq_96, 48);
          end if;
          sqrt_start <= '1';
          state      <= S_WAIT_SQRT;

        when S_WAIT_SQRT =>
          if sqrt_done = '1' then
            v_reg <= sqrt_x_out;
            if sqrt_x_out < V_EPSILON and sqrt_x_out > -V_EPSILON then
              v_too_small <= '1';
            else
              v_too_small <= '0';
            end if;
            state <= S_ATAN2_INIT;
          end if;

        when S_ATAN2_INIT =>
          cordic_z    <= (others => '0');
          cordic_iter <= 0;

          if x_vel_r >= 0 then
            cordic_x    <= x_vel_r;
            cordic_y    <= y_vel_r;
            quad_adjust <= (others => '0');
          else
            cordic_x <= -x_vel_r;
            cordic_y <= -y_vel_r;
            if y_vel_r >= 0 then
              quad_adjust <= PI_Q24;
            else
              quad_adjust <= -PI_Q24;
            end if;
          end if;
          state <= S_ATAN2_ITER;

        when S_ATAN2_ITER =>
          if cordic_iter = 24 then
            theta_reg <= cordic_z + quad_adjust;
            state     <= S_COMPUTE_DOT;
          else
            x_shifted := shift_right(cordic_x, cordic_iter);
            y_shifted := shift_right(cordic_y, cordic_iter);

            if cordic_y < 0 then
              cordic_x <= cordic_x - y_shifted;
              cordic_y <= cordic_y + x_shifted;
              cordic_z <= cordic_z - ATAN_LUT(cordic_iter);
            else
              cordic_x <= cordic_x + y_shifted;
              cordic_y <= cordic_y - x_shifted;
              cordic_z <= cordic_z + ATAN_LUT(cordic_iter);
            end if;
            cordic_iter <= cordic_iter + 1;
          end if;

        when S_COMPUTE_DOT =>
          dot_96 := shift_right(x_vel_r * x_acc_r, Q) +
                    shift_right(y_vel_r * y_acc_r, Q);
          if dot_96 > MAX_S96 then
            dot_product <= MAX_S48;
          elsif dot_96 < -MAX_S96 then
            dot_product <= -MAX_S48;
          else
            dot_product <= resize(dot_96, 48);
          end if;

          if v_too_small = '1' then
            acc_sq_96 := shift_right(x_acc_r * x_acc_r, Q)
                       + shift_right(y_acc_r * y_acc_r, Q);
            if acc_sq_96 > MAX_S96 then
              sqrt_x_in <= MAX_S48;
            elsif acc_sq_96 < to_signed(0, 96) then
              sqrt_x_in <= (others => '0');
            else
              sqrt_x_in <= resize(acc_sq_96, 48);
            end if;
            sqrt_start <= '1';
            state      <= S_WAIT_ACC_SQRT;
          else
            state <= S_DIV_INIT;
          end if;

        when S_DIV_INIT =>
          div_sign <= dot_product(47) xor v_reg(47);

          if dot_product < 0 then
            abs_dot := -dot_product;
          else
            abs_dot := dot_product;
          end if;
          if v_reg < 0 then
            abs_v := -v_reg;
          else
            abs_v := v_reg;
          end if;

          div_num  <= unsigned(abs_dot) & to_unsigned(0, 24);
          div_den  <= unsigned(abs_v);
          div_quot <= (others => '0');
          div_rem  <= (others => '0');
          div_iter <= 0;
          state    <= S_DIV_ITER;

        when S_DIV_ITER =>
          if div_iter = 72 then
            if div_sign = '1' then
              a_reg <= -signed(div_quot(47 downto 0));
            else
              a_reg <= signed(div_quot(47 downto 0));
            end if;

            state <= S_COMPUTE_CROSS;
          else
            new_rem_48 := shift_left(div_rem, 1);
            new_rem_48(0) := div_num(71);
            div_num <= shift_left(div_num, 1);
            q_tmp := shift_left(div_quot, 1);
            if new_rem_48 >= div_den then
              div_rem  <= new_rem_48 - div_den;
              q_tmp(0) := '1';
            else
              div_rem  <= new_rem_48;
            end if;
            div_quot <= q_tmp;
            div_iter <= div_iter + 1;
          end if;

        when S_WAIT_ACC_SQRT =>
          if sqrt_done = '1' then
            a_reg     <= sqrt_x_out;
            omega_reg <= (others => '0');
            state     <= S_OUTPUT;
          end if;

        when S_COMPUTE_CROSS =>
          cross_96 := shift_right(x_vel_r * y_acc_r, Q) -
                      shift_right(y_vel_r * x_acc_r, Q);
          if cross_96 > MAX_S96 then
            cross_product <= MAX_S48;
          elsif cross_96 < -MAX_S96 then
            cross_product <= -MAX_S48;
          else
            cross_product <= resize(cross_96, 48);
          end if;

          if v_too_small = '1' then
            omega_reg <= (others => '0');
            state     <= S_OUTPUT;
          else
            state <= S_DIV_OMEGA_INIT;
          end if;

        when S_DIV_OMEGA_INIT =>
          div_sign <= cross_product(47) xor v_sq_reg(47);

          if cross_product < 0 then
            abs_cross := -cross_product;
          else
            abs_cross := cross_product;
          end if;
          if v_sq_reg < 0 then
            abs_vsq := -v_sq_reg;
          else
            abs_vsq := v_sq_reg;
          end if;

          div_num  <= unsigned(abs_cross) & to_unsigned(0, 24);
          div_den  <= unsigned(abs_vsq);
          div_quot <= (others => '0');
          div_rem  <= (others => '0');
          div_iter <= 0;
          state    <= S_DIV_OMEGA_ITER;

        when S_DIV_OMEGA_ITER =>
          if div_iter = 72 then
            if div_sign = '1' then
              omega_reg <= -signed(div_quot(47 downto 0));
            else
              omega_reg <= signed(div_quot(47 downto 0));
            end if;
            state <= S_OUTPUT;
          else
            new_rem_48 := shift_left(div_rem, 1);
            new_rem_48(0) := div_num(71);
            div_num <= shift_left(div_num, 1);
            q_tmp := shift_left(div_quot, 1);
            if new_rem_48 >= div_den then
              div_rem  <= new_rem_48 - div_den;
              q_tmp(0) := '1';
            else
              div_rem  <= new_rem_48;
            end if;
            div_quot <= q_tmp;
            div_iter <= div_iter + 1;
          end if;

        when S_OUTPUT =>
          px_out    <= x_pos_r;
          py_out    <= y_pos_r;
          z_out     <= z_pos_r;
          v_out     <= v_reg;
          theta_out <= theta_reg;
          omega_out <= omega_reg;
          a_out     <= a_reg;
          done      <= '1';
          state     <= S_IDLE;

      end case;
    end if;
  end process;

end architecture;
