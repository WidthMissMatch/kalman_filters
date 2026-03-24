library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imm_friend_state_mixer is
  port (
    clk   : in  std_logic;
    start : in  std_logic;

    prob_ctra, prob_singer, prob_bicycle : in signed(47 downto 0);

    ct_s1, ct_s2, ct_s3, ct_s4, ct_s5, ct_s6, ct_s7, ct_s8, ct_s9 : in signed(47 downto 0);

    si_s1, si_s2, si_s3, si_s4, si_s5, si_s6, si_s7, si_s8, si_s9 : in signed(47 downto 0);

    bi_s1, bi_s2, bi_s3, bi_s4, bi_s5, bi_s6, bi_s7, bi_s8, bi_s9 : in signed(47 downto 0);

    si_c1, si_c2, si_c3, si_c4, si_c5, si_c6, si_c7 : in signed(47 downto 0);

    ct_c1, ct_c2, ct_c3, ct_c4, ct_c5, ct_c6, ct_c7 : in signed(47 downto 0);

    bi_c1, bi_c2, bi_c3, bi_c4, bi_c5, bi_c6, bi_c7 : in signed(47 downto 0);

    si_b1, si_b2, si_b3, si_b4, si_b5, si_b6, si_b7 : in signed(47 downto 0);

    ct_b1, ct_b2, ct_b3, ct_b4, ct_b5, ct_b6, ct_b7 : in signed(47 downto 0);

    bi_b1, bi_b2, bi_b3, bi_b4, bi_b5, bi_b6, bi_b7 : in signed(47 downto 0);

    mix_si_s1, mix_si_s2, mix_si_s3, mix_si_s4, mix_si_s5, mix_si_s6, mix_si_s7, mix_si_s8, mix_si_s9 : out signed(47 downto 0);

    mix_ct_c1, mix_ct_c2, mix_ct_c3, mix_ct_c4, mix_ct_c5, mix_ct_c6, mix_ct_c7 : out signed(47 downto 0);

    mix_bi_b1, mix_bi_b2, mix_bi_b3, mix_bi_b4, mix_bi_b5, mix_bi_b6, mix_bi_b7 : out signed(47 downto 0);

    c_ctra_out, c_singer_out, c_bicycle_out : out signed(47 downto 0);

    mu_ct_ct_out, mu_si_ct_out, mu_bi_ct_out : out signed(47 downto 0);
    mu_ct_si_out, mu_si_si_out, mu_bi_si_out : out signed(47 downto 0);
    mu_ct_bi_out, mu_si_bi_out, mu_bi_bi_out : out signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of imm_friend_state_mixer is

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

  constant T_CT_CT : signed(47 downto 0) := to_signed(15938355, 48);
  constant T_CT_SI : signed(47 downto 0) := to_signed(503316, 48);
  constant T_CT_BI : signed(47 downto 0) := to_signed(335544, 48);
  constant T_SI_CT : signed(47 downto 0) := to_signed(503316, 48);
  constant T_SI_SI : signed(47 downto 0) := to_signed(15770583, 48);
  constant T_SI_BI : signed(47 downto 0) := to_signed(503316, 48);
  constant T_BI_CT : signed(47 downto 0) := to_signed(335544, 48);
  constant T_BI_SI : signed(47 downto 0) := to_signed(503316, 48);
  constant T_BI_BI : signed(47 downto 0) := to_signed(15938355, 48);

  type state_type is (IDLE, COMPUTE_C, INIT_RECIP, COMPUTE_RECIP, COMPUTE_MU,
                      MIX_SINGER, MIX_CTRA, MIX_BICYCLE, OUTPUT);
  signal state : state_type := IDLE;

  signal c_ctra, c_singer, c_bicycle : signed(47 downto 0);
  signal mu_ct_ct, mu_si_ct, mu_bi_ct : signed(47 downto 0);
  signal mu_ct_si, mu_si_si, mu_bi_si : signed(47 downto 0);
  signal mu_ct_bi, mu_si_bi, mu_bi_bi : signed(47 downto 0);
  signal recip_ct, recip_si, recip_bi : signed(47 downto 0);
  signal iter_count : integer range 0 to 7;

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

          prod := T_CT_CT * prob_ctra;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := T_SI_CT * prob_singer;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := T_BI_CT * prob_bicycle;
          c_ctra <= sum_val + resize(shift_right(prod, Q), 48);

          prod := T_CT_SI * prob_ctra;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := T_SI_SI * prob_singer;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := T_BI_SI * prob_bicycle;
          c_singer <= sum_val + resize(shift_right(prod, Q), 48);

          prod := T_CT_BI * prob_ctra;
          sum_val := resize(shift_right(prod, Q), 48);
          prod := T_SI_BI * prob_singer;
          sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := T_BI_BI * prob_bicycle;
          c_bicycle <= sum_val + resize(shift_right(prod, Q), 48);

          state <= INIT_RECIP;

        when INIT_RECIP =>
          recip_ct <= nr_initial_guess(c_ctra);
          recip_si <= nr_initial_guess(c_singer);
          recip_bi <= nr_initial_guess(c_bicycle);
          iter_count <= 0;
          state <= COMPUTE_RECIP;

        when COMPUTE_RECIP =>
          if iter_count < 6 then
            nr_prod := c_ctra * recip_ct;
            t_val := resize(shift_right(nr_prod, Q), 48);
            two_minus := to_signed(2 * (2**Q), 48) - t_val;
            nr_prod := recip_ct * two_minus;
            recip_ct <= resize(shift_right(nr_prod, Q), 48);

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

          prod := T_CT_CT * prob_ctra;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_ct;
          mu_ct_ct <= resize(shift_right(nr_prod, Q), 48);

          prod := T_SI_CT * prob_singer;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_ct;
          mu_si_ct <= resize(shift_right(nr_prod, Q), 48);

          prod := T_BI_CT * prob_bicycle;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_ct;
          mu_bi_ct <= resize(shift_right(nr_prod, Q), 48);

          prod := T_CT_SI * prob_ctra;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_si;
          mu_ct_si <= resize(shift_right(nr_prod, Q), 48);

          prod := T_SI_SI * prob_singer;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_si;
          mu_si_si <= resize(shift_right(nr_prod, Q), 48);

          prod := T_BI_SI * prob_bicycle;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_si;
          mu_bi_si <= resize(shift_right(nr_prod, Q), 48);

          prod := T_CT_BI * prob_ctra;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_bi;
          mu_ct_bi <= resize(shift_right(nr_prod, Q), 48);

          prod := T_SI_BI * prob_singer;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_bi;
          mu_si_bi <= resize(shift_right(nr_prod, Q), 48);

          prod := T_BI_BI * prob_bicycle;
          x_nr := resize(shift_right(prod, Q), 48);
          nr_prod := x_nr * recip_bi;
          mu_bi_bi <= resize(shift_right(nr_prod, Q), 48);

          c_ctra_out <= c_ctra;
          c_singer_out <= c_singer;
          c_bicycle_out <= c_bicycle;

          state <= MIX_SINGER;

        when MIX_SINGER =>

          for i in 1 to 9 loop
            null;
          end loop;

          prod := mu_ct_si * ct_s1; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s1; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s1; mix_si_s1 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_si * ct_s2; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s2; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s2; mix_si_s2 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_si * ct_s3; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s3; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s3; mix_si_s3 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_si * ct_s4; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s4; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s4; mix_si_s4 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_si * ct_s5; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s5; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s5; mix_si_s5 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_si * ct_s6; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s6; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s6; mix_si_s6 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_si * ct_s7; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s7; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s7; mix_si_s7 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_si * ct_s8; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s8; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s8; mix_si_s8 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_si * ct_s9; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_si * si_s9; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_si * bi_s9; mix_si_s9 <= sum_val + resize(shift_right(prod, Q), 48);

          state <= MIX_CTRA;

        when MIX_CTRA =>

          prod := mu_ct_ct * ct_c1; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ct * si_c1; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ct * bi_c1; mix_ct_c1 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_ct * ct_c2; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ct * si_c2; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ct * bi_c2; mix_ct_c2 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_ct * ct_c3; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ct * si_c3; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ct * bi_c3; mix_ct_c3 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_ct * ct_c4; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ct * si_c4; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ct * bi_c4; mix_ct_c4 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_ct * ct_c5; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ct * si_c5; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ct * bi_c5; mix_ct_c5 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_ct * ct_c6; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ct * si_c6; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ct * bi_c6; mix_ct_c6 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_ct * ct_c7; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_ct * si_c7; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_ct * bi_c7; mix_ct_c7 <= sum_val + resize(shift_right(prod, Q), 48);

          state <= MIX_BICYCLE;

        when MIX_BICYCLE =>

          prod := mu_ct_bi * ct_b1; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_bi * si_b1; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_bi * bi_b1; mix_bi_b1 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_bi * ct_b2; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_bi * si_b2; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_bi * bi_b2; mix_bi_b2 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_bi * ct_b3; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_bi * si_b3; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_bi * bi_b3; mix_bi_b3 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_bi * ct_b4; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_bi * si_b4; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_bi * bi_b4; mix_bi_b4 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_bi * ct_b5; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_bi * si_b5; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_bi * bi_b5; mix_bi_b5 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_bi * ct_b6; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_bi * si_b6; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_bi * bi_b6; mix_bi_b6 <= sum_val + resize(shift_right(prod, Q), 48);

          prod := mu_ct_bi * ct_b7; sum_val := resize(shift_right(prod, Q), 48);
          prod := mu_si_bi * si_b7; sum_val := sum_val + resize(shift_right(prod, Q), 48);
          prod := mu_bi_bi * bi_b7; mix_bi_b7 <= sum_val + resize(shift_right(prod, Q), 48);

          state <= OUTPUT;

        when OUTPUT =>
          mu_ct_ct_out <= mu_ct_ct; mu_si_ct_out <= mu_si_ct; mu_bi_ct_out <= mu_bi_ct;
          mu_ct_si_out <= mu_ct_si; mu_si_si_out <= mu_si_si; mu_bi_si_out <= mu_bi_si;
          mu_ct_bi_out <= mu_ct_bi; mu_si_bi_out <= mu_si_bi; mu_bi_bi_out <= mu_bi_bi;
          done <= '1';
          if start = '0' then
            state <= IDLE;
          end if;

      end case;
    end if;
  end process;

end Behavioral;
