library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imm_state_mixer is
  port (
    clk   : in  std_logic;
    start : in  std_logic;

    prob_ca, prob_singer, prob_bicycle : in signed(47 downto 0);

    ca_s1, ca_s2, ca_s3, ca_s4, ca_s5, ca_s6, ca_s7, ca_s8, ca_s9 : in signed(47 downto 0);

    si_s1, si_s2, si_s3, si_s4, si_s5, si_s6, si_s7, si_s8, si_s9 : in signed(47 downto 0);

    bi_s1, bi_s2, bi_s3, bi_s4, bi_s5, bi_s6, bi_s7, bi_s8, bi_s9 : in signed(47 downto 0);

    ca_b1, ca_b2, ca_b3, ca_b4, ca_b5, ca_b6, ca_b7 : in signed(47 downto 0);

    si_b1, si_b2, si_b3, si_b4, si_b5, si_b6, si_b7 : in signed(47 downto 0);

    bi_b1, bi_b2, bi_b3, bi_b4, bi_b5, bi_b6, bi_b7 : in signed(47 downto 0);

    mix_ca_s1, mix_ca_s2, mix_ca_s3, mix_ca_s4, mix_ca_s5, mix_ca_s6, mix_ca_s7, mix_ca_s8, mix_ca_s9 : out signed(47 downto 0);

    mix_si_s1, mix_si_s2, mix_si_s3, mix_si_s4, mix_si_s5, mix_si_s6, mix_si_s7, mix_si_s8, mix_si_s9 : out signed(47 downto 0);

    mix_bi_b1, mix_bi_b2, mix_bi_b3, mix_bi_b4, mix_bi_b5, mix_bi_b6, mix_bi_b7 : out signed(47 downto 0);

    c_ca_out, c_singer_out, c_bicycle_out : out signed(47 downto 0);

    mu_ca_ca_out, mu_si_ca_out, mu_bi_ca_out : out signed(47 downto 0);
    mu_ca_si_out, mu_si_si_out, mu_bi_si_out : out signed(47 downto 0);
    mu_ca_bi_out, mu_si_bi_out, mu_bi_bi_out : out signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of imm_state_mixer is

  constant Q : integer := 24;

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

  constant T_CA_CA : signed(47 downto 0) := to_signed(16274678, 48);
  constant T_CA_SI : signed(47 downto 0) := to_signed(335544, 48);
  constant T_CA_BI : signed(47 downto 0) := to_signed(167772, 48);
  constant T_SI_CA : signed(47 downto 0) := to_signed(335544, 48);
  constant T_SI_SI : signed(47 downto 0) := to_signed(15938355, 48);
  constant T_SI_BI : signed(47 downto 0) := to_signed(503316, 48);
  constant T_BI_CA : signed(47 downto 0) := to_signed(167772, 48);
  constant T_BI_SI : signed(47 downto 0) := to_signed(335544, 48);
  constant T_BI_BI : signed(47 downto 0) := to_signed(16274678, 48);

  type state_type is (IDLE, COMPUTE_C, INIT_RECIP, COMPUTE_RECIP, COMPUTE_MU,
                      MIX_CA, MIX_SINGER, MIX_BICYCLE, OUTPUT);
  signal state : state_type := IDLE;

  signal c_ca, c_singer, c_bicycle : signed(47 downto 0);

  signal mu_ca_ca, mu_si_ca, mu_bi_ca : signed(47 downto 0);
  signal mu_ca_si, mu_si_si, mu_bi_si : signed(47 downto 0);
  signal mu_ca_bi, mu_si_bi, mu_bi_bi : signed(47 downto 0);

  signal recip_ca, recip_si, recip_bi : signed(47 downto 0);
  signal iter_count : integer range 0 to 7;
  signal recip_phase : integer range 0 to 2;

begin

  process(clk)
    variable prod : signed(95 downto 0);
    variable sum_val : signed(47 downto 0);

    variable x_nr, t_val : signed(47 downto 0);
    variable nr_prod : signed(95 downto 0);
    variable two_minus : signed(47 downto 0);
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if start = '1' then
            state <= COMPUTE_C;
          end if;

        when COMPUTE_C =>

          prod := T_CA_CA * prob_ca;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := T_SI_CA * prob_singer;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := T_BI_CA * prob_bicycle;
          c_ca <= sum_val + resize(shift_right(prod, Q), 48);

          prod := T_CA_SI * prob_ca;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := T_SI_SI * prob_singer;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := T_BI_SI * prob_bicycle;
          c_singer <= sum_val + resize(shift_right(prod, Q), 48);

          prod := T_CA_BI * prob_ca;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := T_SI_BI * prob_singer;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := T_BI_BI * prob_bicycle;
          c_bicycle <= sum_val + resize(shift_right(prod, Q), 48);

          state <= INIT_RECIP;

        when INIT_RECIP =>

          recip_ca <= nr_initial_guess(c_ca);
          recip_si <= nr_initial_guess(c_singer);
          recip_bi <= nr_initial_guess(c_bicycle);
          iter_count <= 0;
          state <= COMPUTE_RECIP;

        when COMPUTE_RECIP =>

          if iter_count < 6 then

            nr_prod := c_ca * recip_ca;
            t_val := resize(shift_right(nr_prod, Q), 48);
            two_minus := to_signed(2 * (2**Q), 48) - t_val;
            nr_prod := recip_ca * two_minus;
            recip_ca <= resize(shift_right(nr_prod, Q), 48);

            nr_prod := c_singer * recip_si;
            t_val := resize(shift_right(nr_prod, Q), 48);
            two_minus := to_signed(2 * (2**Q), 48) - t_val;
            nr_prod := recip_si * two_minus;
            recip_si <= resize(shift_right(nr_prod, Q), 48);

            nr_prod := c_bicycle * recip_bi;
            t_val := resize(shift_right(nr_prod, Q), 48);
            two_minus := to_signed(2 * (2**Q), 48) - t_val;
            nr_prod := recip_bi * two_minus;
            recip_bi <= resize(shift_right(nr_prod, Q), 48);

            iter_count <= iter_count + 1;
          else
            state <= COMPUTE_MU;
          end if;

        when COMPUTE_MU =>

          prod := T_CA_CA * prob_ca;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_ca;
          mu_ca_ca <= resize(shift_right(nr_prod, Q), 48);

          prod := T_SI_CA * prob_singer;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_ca;
          mu_si_ca <= resize(shift_right(nr_prod, Q), 48);

          prod := T_BI_CA * prob_bicycle;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_ca;
          mu_bi_ca <= resize(shift_right(nr_prod, Q), 48);

          prod := T_CA_SI * prob_ca;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_si;
          mu_ca_si <= resize(shift_right(nr_prod, Q), 48);

          prod := T_SI_SI * prob_singer;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_si;
          mu_si_si <= resize(shift_right(nr_prod, Q), 48);

          prod := T_BI_SI * prob_bicycle;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_si;
          mu_bi_si <= resize(shift_right(nr_prod, Q), 48);

          prod := T_CA_BI * prob_ca;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_bi;
          mu_ca_bi <= resize(shift_right(nr_prod, Q), 48);

          prod := T_SI_BI * prob_singer;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_bi;
          mu_si_bi <= resize(shift_right(nr_prod, Q), 48);

          prod := T_BI_BI * prob_bicycle;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_bi;
          mu_bi_bi <= resize(shift_right(nr_prod, Q), 48);

          c_ca_out <= c_ca;
          c_singer_out <= c_singer;
          c_bicycle_out <= c_bicycle;

          state <= MIX_CA;

        when MIX_CA =>

          prod := mu_ca_ca * ca_s1;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ca * si_s1;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ca * bi_s1;
          mix_ca_s1 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_ca * ca_s2;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ca * si_s2;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ca * bi_s2;
          mix_ca_s2 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_ca * ca_s3;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ca * si_s3;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ca * bi_s3;
          mix_ca_s3 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_ca * ca_s4;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ca * si_s4;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ca * bi_s4;
          mix_ca_s4 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_ca * ca_s5;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ca * si_s5;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ca * bi_s5;
          mix_ca_s5 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_ca * ca_s6;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ca * si_s6;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ca * bi_s6;
          mix_ca_s6 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_ca * ca_s7;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ca * si_s7;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ca * bi_s7;
          mix_ca_s7 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_ca * ca_s8;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ca * si_s8;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ca * bi_s8;
          mix_ca_s8 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_ca * ca_s9;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ca * si_s9;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ca * bi_s9;
          mix_ca_s9 <= sum_val + resize(shift_right(prod, Q), 48);

          state <= MIX_SINGER;

        when MIX_SINGER =>

          prod := mu_ca_si * ca_s1;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s1;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s1;
          mix_si_s1 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_si * ca_s2;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s2;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s2;
          mix_si_s2 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_si * ca_s3;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s3;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s3;
          mix_si_s3 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_si * ca_s4;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s4;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s4;
          mix_si_s4 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_si * ca_s5;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s5;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s5;
          mix_si_s5 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_si * ca_s6;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s6;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s6;
          mix_si_s6 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_si * ca_s7;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s7;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s7;
          mix_si_s7 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_si * ca_s8;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s8;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s8;
          mix_si_s8 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_si * ca_s9;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s9;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s9;
          mix_si_s9 <= sum_val + resize(shift_right(prod, Q), 48);

          state <= MIX_BICYCLE;

        when MIX_BICYCLE =>

          prod := mu_ca_bi * ca_b1;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_bi * si_b1;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_bi * bi_b1;
          mix_bi_b1 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_bi * ca_b2;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_bi * si_b2;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_bi * bi_b2;
          mix_bi_b2 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_bi * ca_b3;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_bi * si_b3;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_bi * bi_b3;
          mix_bi_b3 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_bi * ca_b4;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_bi * si_b4;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_bi * bi_b4;
          mix_bi_b4 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_bi * ca_b5;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_bi * si_b5;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_bi * bi_b5;
          mix_bi_b5 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_bi * ca_b6;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_bi * si_b6;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_bi * bi_b6;
          mix_bi_b6 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ca_bi * ca_b7;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_bi * si_b7;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_bi * bi_b7;
          mix_bi_b7 <= sum_val + resize(shift_right(prod, Q), 48);

          state <= OUTPUT;

        when OUTPUT =>

          mu_ca_ca_out <= mu_ca_ca; mu_si_ca_out <= mu_si_ca; mu_bi_ca_out <= mu_bi_ca;
          mu_ca_si_out <= mu_ca_si; mu_si_si_out <= mu_si_si; mu_bi_si_out <= mu_bi_si;
          mu_ca_bi_out <= mu_ca_bi; mu_si_bi_out <= mu_si_bi; mu_bi_bi_out <= mu_bi_bi;
          done <= '1';
          if start = '0' then
            state <= IDLE;
          end if;

      end case;
    end if;
  end process;

end Behavioral;
