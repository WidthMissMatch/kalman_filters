library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imm_prob_update is
  port (
    clk   : in  std_logic;
    start : in  std_logic;

    L_ca, L_singer, L_bicycle : in signed(47 downto 0);

    c_ca, c_singer, c_bicycle : in signed(47 downto 0);

    prob_ca_out, prob_singer_out, prob_bicycle_out : out signed(47 downto 0);
    done : out std_logic
  );
end entity;

architecture Behavioral of imm_prob_update is

  constant Q : integer := 24;
  constant ONE_Q24  : signed(47 downto 0) := to_signed(16777216, 48);

  function nr_initial_guess(s_val : signed(47 downto 0)) return signed is
    variable msb_pos : integer range 0 to 47;
    variable result : signed(47 downto 0);
    variable abs_s : signed(47 downto 0);
  begin
    if s_val < 0 then abs_s := -s_val;
    else abs_s := s_val; end if;
    msb_pos := 0;
    for i in 47 downto 0 loop
      if abs_s(i) = '1' then
        msb_pos := i;
        exit;
      end if;
    end loop;
    result := (others => '0');
    if msb_pos <= 47 then
      result(47 - msb_pos) := '1';
    end if;
    return result;
  end function;

  constant PROB_MIN : signed(47 downto 0) := to_signed(167772, 48);
  constant PROB_MAX : signed(47 downto 0) := to_signed(16441671, 48);

  constant ONE_THIRD : signed(47 downto 0) := to_signed(5592405, 48);

  type state_type is (IDLE, COMPUTE_WEIGHTED, COMPUTE_SUM, NEWTON_INIT,
                      NEWTON_ITER, NORMALIZE, CLAMP, OUTPUT);
  signal state : state_type := IDLE;

  signal w_ca, w_singer, w_bicycle : signed(47 downto 0) := (others => '0');
  signal total : signed(47 downto 0) := (others => '0');
  signal recip : signed(47 downto 0) := (others => '0');
  signal iter_count : integer range 0 to 7 := 0;

begin

  process(clk)
    variable prod : signed(95 downto 0);
    variable p1, p2, p3 : signed(47 downto 0);
    variable sum_p : signed(47 downto 0);
    variable excess : signed(47 downto 0);

    variable x_nr : signed(47 downto 0);
    variable two_minus_tx : signed(95 downto 0);
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if start = '1' then
            state <= COMPUTE_WEIGHTED;
          end if;

        when COMPUTE_WEIGHTED =>

          prod := L_ca * c_ca;
          w_ca <= resize(shift_right(prod, Q), 48);
          prod := L_singer * c_singer;
          w_singer <= resize(shift_right(prod, Q), 48);
          prod := L_bicycle * c_bicycle;
          w_bicycle <= resize(shift_right(prod, Q), 48);
          state <= COMPUTE_SUM;

        when COMPUTE_SUM =>
          total <= w_ca + w_singer + w_bicycle;
          state <= NEWTON_INIT;

        when NEWTON_INIT =>

          report "PROB_UPDATE NEWTON_INIT: (values hex-suppressed)";
          if total < to_signed(168, 48) then
            report "PROB_UPDATE: Using uniform 1/3 fallback";
            prob_ca_out <= ONE_THIRD;
            prob_singer_out <= ONE_THIRD;
            prob_bicycle_out <= ONE_THIRD;
            state <= OUTPUT;
          else

            recip <= nr_initial_guess(total);
            iter_count <= 0;
            state <= NEWTON_ITER;
          end if;

        when NEWTON_ITER =>

          prod := total * recip;

          x_nr := resize(shift_right(prod, Q), 48);

          two_minus_tx := to_signed(33554432, 96) - resize(x_nr, 96);

          prod := recip * resize(two_minus_tx, 48);
          recip <= resize(shift_right(prod, Q), 48);

          if iter_count >= 5 then
            state <= NORMALIZE;
          else
            iter_count <= iter_count + 1;
          end if;

        when NORMALIZE =>

          prod := w_ca * recip;
          p1 := resize(shift_right(prod, Q), 48);
          prod := w_singer * recip;
          p2 := resize(shift_right(prod, Q), 48);
          prod := w_bicycle * recip;
          p3 := resize(shift_right(prod, Q), 48);

          prob_ca_out <= p1;
          prob_singer_out <= p2;
          prob_bicycle_out <= p3;
          state <= CLAMP;

        when CLAMP =>

          p1 := prob_ca_out;
          p2 := prob_singer_out;
          p3 := prob_bicycle_out;

          if p1 < PROB_MIN then p1 := PROB_MIN; end if;
          if p1 > PROB_MAX then p1 := PROB_MAX; end if;
          if p2 < PROB_MIN then p2 := PROB_MIN; end if;
          if p2 > PROB_MAX then p2 := PROB_MAX; end if;
          if p3 < PROB_MIN then p3 := PROB_MIN; end if;
          if p3 > PROB_MAX then p3 := PROB_MAX; end if;

          sum_p := p1 + p2 + p3;
          excess := sum_p - ONE_Q24;

          if p1 >= p2 and p1 >= p3 then
            p1 := p1 - excess;
          elsif p2 >= p1 and p2 >= p3 then
            p2 := p2 - excess;
          else
            p3 := p3 - excess;
          end if;

          prob_ca_out <= p1;
          prob_singer_out <= p2;
          prob_bicycle_out <= p3;
          state <= OUTPUT;

        when OUTPUT =>
          done <= '1';
          if start = '0' then
            state <= IDLE;
          end if;

      end case;
    end if;
  end process;

end Behavioral;
