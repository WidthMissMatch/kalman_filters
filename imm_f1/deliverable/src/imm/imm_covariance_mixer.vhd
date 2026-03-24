library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imm_covariance_mixer is
  port (
    clk   : in  std_logic;
    start : in  std_logic;

    mu_ca_ca, mu_si_ca, mu_bi_ca : in signed(47 downto 0);
    mu_ca_si, mu_si_si, mu_bi_si : in signed(47 downto 0);
    mu_ca_bi, mu_si_bi, mu_bi_bi : in signed(47 downto 0);

    ca_p1, ca_p2, ca_p3, ca_p4, ca_p5, ca_p6, ca_p7, ca_p8, ca_p9 : in signed(47 downto 0);
    si_p1, si_p2, si_p3, si_p4, si_p5, si_p6, si_p7, si_p8, si_p9 : in signed(47 downto 0);

    bi_p1, bi_p2, bi_p3, bi_p4, bi_p5, bi_p6, bi_p7, bi_p8, bi_p9 : in signed(47 downto 0);

    ca_s1, ca_s2, ca_s3, ca_s4, ca_s5, ca_s6, ca_s7, ca_s8, ca_s9 : in signed(47 downto 0);
    si_s1, si_s2, si_s3, si_s4, si_s5, si_s6, si_s7, si_s8, si_s9 : in signed(47 downto 0);
    bi_s1, bi_s2, bi_s3, bi_s4, bi_s5, bi_s6, bi_s7, bi_s8, bi_s9 : in signed(47 downto 0);

    mix_ca_s1, mix_ca_s2, mix_ca_s3, mix_ca_s4, mix_ca_s5, mix_ca_s6, mix_ca_s7, mix_ca_s8, mix_ca_s9 : in signed(47 downto 0);
    mix_si_s1, mix_si_s2, mix_si_s3, mix_si_s4, mix_si_s5, mix_si_s6, mix_si_s7, mix_si_s8, mix_si_s9 : in signed(47 downto 0);

    mix_ca_p1, mix_ca_p2, mix_ca_p3, mix_ca_p4, mix_ca_p5, mix_ca_p6, mix_ca_p7, mix_ca_p8, mix_ca_p9 : out signed(47 downto 0);
    mix_si_p1, mix_si_p2, mix_si_p3, mix_si_p4, mix_si_p5, mix_si_p6, mix_si_p7, mix_si_p8, mix_si_p9 : out signed(47 downto 0);

    mix_bi_p1, mix_bi_p2, mix_bi_p3, mix_bi_p4, mix_bi_p5, mix_bi_p6, mix_bi_p7 : out signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of imm_covariance_mixer is
  constant Q : integer := 24;
  subtype s48 is signed(47 downto 0);
  subtype s96 is signed(95 downto 0);
  constant MAX_P : s48 := to_signed(2147483647, 48);

  type state_type is (IDLE, MIX_CA_P, MIX_SI_P, MIX_BI_P, OUTPUT);
  signal state : state_type := IDLE;

  function mix_one_p(
    mu1, mu2, mu3 : s48;
    p1, p2, p3 : s48;
    x1, x2, x3 : s48;
    x_mix : s48
  ) return s48 is
    variable d1, d2, d3 : s48;
    variable spread1, spread2, spread3 : s48;
    variable prod : s96;
    variable term1, term2, term3 : s48;
    variable result : s48;
  begin

    d1 := x1 - x_mix;
    prod := d1 * d1;
    spread1 := resize(shift_right(prod, Q), 48);

    d2 := x2 - x_mix;
    prod := d2 * d2;
    spread2 := resize(shift_right(prod, Q), 48);

    d3 := x3 - x_mix;
    prod := d3 * d3;
    spread3 := resize(shift_right(prod, Q), 48);

    prod := mu1 * (p1 + spread1);
    term1 := resize(shift_right(prod, Q), 48);

    prod := mu2 * (p2 + spread2);
    term2 := resize(shift_right(prod, Q), 48);

    prod := mu3 * (p3 + spread3);
    term3 := resize(shift_right(prod, Q), 48);

    result := term1 + term2 + term3;

    if result > MAX_P then
      result := MAX_P;
    elsif result < to_signed(168, 48) then
      result := to_signed(168, 48);
    end if;

    return result;
  end function;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if start = '1' then
            state <= MIX_CA_P;
          end if;

        when MIX_CA_P =>
          mix_ca_p1 <= mix_one_p(mu_ca_ca, mu_si_ca, mu_bi_ca, ca_p1, si_p1, bi_p1, ca_s1, si_s1, bi_s1, mix_ca_s1);
          mix_ca_p2 <= mix_one_p(mu_ca_ca, mu_si_ca, mu_bi_ca, ca_p2, si_p2, bi_p2, ca_s2, si_s2, bi_s2, mix_ca_s2);
          mix_ca_p3 <= mix_one_p(mu_ca_ca, mu_si_ca, mu_bi_ca, ca_p3, si_p3, bi_p3, ca_s3, si_s3, bi_s3, mix_ca_s3);
          mix_ca_p4 <= mix_one_p(mu_ca_ca, mu_si_ca, mu_bi_ca, ca_p4, si_p4, bi_p4, ca_s4, si_s4, bi_s4, mix_ca_s4);
          mix_ca_p5 <= mix_one_p(mu_ca_ca, mu_si_ca, mu_bi_ca, ca_p5, si_p5, bi_p5, ca_s5, si_s5, bi_s5, mix_ca_s5);
          mix_ca_p6 <= mix_one_p(mu_ca_ca, mu_si_ca, mu_bi_ca, ca_p6, si_p6, bi_p6, ca_s6, si_s6, bi_s6, mix_ca_s6);
          mix_ca_p7 <= mix_one_p(mu_ca_ca, mu_si_ca, mu_bi_ca, ca_p7, si_p7, bi_p7, ca_s7, si_s7, bi_s7, mix_ca_s7);
          mix_ca_p8 <= mix_one_p(mu_ca_ca, mu_si_ca, mu_bi_ca, ca_p8, si_p8, bi_p8, ca_s8, si_s8, bi_s8, mix_ca_s8);
          mix_ca_p9 <= mix_one_p(mu_ca_ca, mu_si_ca, mu_bi_ca, ca_p9, si_p9, bi_p9, ca_s9, si_s9, bi_s9, mix_ca_s9);
          state <= MIX_SI_P;

        when MIX_SI_P =>
          mix_si_p1 <= mix_one_p(mu_ca_si, mu_si_si, mu_bi_si, ca_p1, si_p1, bi_p1, ca_s1, si_s1, bi_s1, mix_si_s1);
          mix_si_p2 <= mix_one_p(mu_ca_si, mu_si_si, mu_bi_si, ca_p2, si_p2, bi_p2, ca_s2, si_s2, bi_s2, mix_si_s2);
          mix_si_p3 <= mix_one_p(mu_ca_si, mu_si_si, mu_bi_si, ca_p3, si_p3, bi_p3, ca_s3, si_s3, bi_s3, mix_si_s3);
          mix_si_p4 <= mix_one_p(mu_ca_si, mu_si_si, mu_bi_si, ca_p4, si_p4, bi_p4, ca_s4, si_s4, bi_s4, mix_si_s4);
          mix_si_p5 <= mix_one_p(mu_ca_si, mu_si_si, mu_bi_si, ca_p5, si_p5, bi_p5, ca_s5, si_s5, bi_s5, mix_si_s5);
          mix_si_p6 <= mix_one_p(mu_ca_si, mu_si_si, mu_bi_si, ca_p6, si_p6, bi_p6, ca_s6, si_s6, bi_s6, mix_si_s6);
          mix_si_p7 <= mix_one_p(mu_ca_si, mu_si_si, mu_bi_si, ca_p7, si_p7, bi_p7, ca_s7, si_s7, bi_s7, mix_si_s7);
          mix_si_p8 <= mix_one_p(mu_ca_si, mu_si_si, mu_bi_si, ca_p8, si_p8, bi_p8, ca_s8, si_s8, bi_s8, mix_si_s8);
          mix_si_p9 <= mix_one_p(mu_ca_si, mu_si_si, mu_bi_si, ca_p9, si_p9, bi_p9, ca_s9, si_s9, bi_s9, mix_si_s9);
          state <= MIX_BI_P;

        when MIX_BI_P =>

          mix_bi_p1 <= bi_p1;
          mix_bi_p2 <= bi_p2;
          mix_bi_p3 <= bi_p3;
          mix_bi_p4 <= bi_p4;
          mix_bi_p5 <= bi_p5;
          mix_bi_p6 <= bi_p6;
          mix_bi_p7 <= bi_p7;
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
