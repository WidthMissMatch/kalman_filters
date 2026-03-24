library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity predicted_mean_7d is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    start : in  std_logic;

    chi0_s1, chi0_s2, chi0_s3, chi0_s4, chi0_s5, chi0_s6, chi0_s7 : in signed(47 downto 0);
    chi1_s1, chi1_s2, chi1_s3, chi1_s4, chi1_s5, chi1_s6, chi1_s7 : in signed(47 downto 0);
    chi2_s1, chi2_s2, chi2_s3, chi2_s4, chi2_s5, chi2_s6, chi2_s7 : in signed(47 downto 0);
    chi3_s1, chi3_s2, chi3_s3, chi3_s4, chi3_s5, chi3_s6, chi3_s7 : in signed(47 downto 0);
    chi4_s1, chi4_s2, chi4_s3, chi4_s4, chi4_s5, chi4_s6, chi4_s7 : in signed(47 downto 0);
    chi5_s1, chi5_s2, chi5_s3, chi5_s4, chi5_s5, chi5_s6, chi5_s7 : in signed(47 downto 0);
    chi6_s1, chi6_s2, chi6_s3, chi6_s4, chi6_s5, chi6_s6, chi6_s7 : in signed(47 downto 0);
    chi7_s1, chi7_s2, chi7_s3, chi7_s4, chi7_s5, chi7_s6, chi7_s7 : in signed(47 downto 0);
    chi8_s1, chi8_s2, chi8_s3, chi8_s4, chi8_s5, chi8_s6, chi8_s7 : in signed(47 downto 0);
    chi9_s1, chi9_s2, chi9_s3, chi9_s4, chi9_s5, chi9_s6, chi9_s7 : in signed(47 downto 0);
    chi10_s1, chi10_s2, chi10_s3, chi10_s4, chi10_s5, chi10_s6, chi10_s7 : in signed(47 downto 0);
    chi11_s1, chi11_s2, chi11_s3, chi11_s4, chi11_s5, chi11_s6, chi11_s7 : in signed(47 downto 0);
    chi12_s1, chi12_s2, chi12_s3, chi12_s4, chi12_s5, chi12_s6, chi12_s7 : in signed(47 downto 0);
    chi13_s1, chi13_s2, chi13_s3, chi13_s4, chi13_s5, chi13_s6, chi13_s7 : in signed(47 downto 0);
    chi14_s1, chi14_s2, chi14_s3, chi14_s4, chi14_s5, chi14_s6, chi14_s7 : in signed(47 downto 0);

    s1_mean, s2_mean, s3_mean, s4_mean, s5_mean, s6_mean, s7_mean : buffer signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of predicted_mean_7d is

  type state_type is (IDLE, MULTIPLY, ACCUMULATE, OUTPUT_RESULT, FINISHED);
  signal state : state_type := IDLE;

  constant Q : integer := 24;

  constant W0 : signed(47 downto 0) := to_signed(0, 48);
  constant W1 : signed(47 downto 0) := to_signed(1198373, 48);

  signal sum_s1, sum_s2, sum_s3, sum_s4 : signed(47 downto 0);
  signal sum_s5, sum_s6, sum_s7 : signed(47 downto 0);

  function w_mul(x : signed(47 downto 0)) return signed is
    variable prod : signed(95 downto 0);
  begin
    prod := W1 * x;
    return resize(shift_right(prod, Q), 48);
  end function;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= IDLE;
        done <= '0';
      else
        case state is
          when IDLE =>
            done <= '0';
            if start = '1' then
              state <= MULTIPLY;
            end if;

          when MULTIPLY =>

            sum_s1 <= w_mul(chi1_s1) + w_mul(chi2_s1) + w_mul(chi3_s1) + w_mul(chi4_s1)
                    + w_mul(chi5_s1) + w_mul(chi6_s1) + w_mul(chi7_s1)
                    + w_mul(chi8_s1) + w_mul(chi9_s1) + w_mul(chi10_s1) + w_mul(chi11_s1)
                    + w_mul(chi12_s1) + w_mul(chi13_s1) + w_mul(chi14_s1);

            sum_s2 <= w_mul(chi1_s2) + w_mul(chi2_s2) + w_mul(chi3_s2) + w_mul(chi4_s2)
                    + w_mul(chi5_s2) + w_mul(chi6_s2) + w_mul(chi7_s2)
                    + w_mul(chi8_s2) + w_mul(chi9_s2) + w_mul(chi10_s2) + w_mul(chi11_s2)
                    + w_mul(chi12_s2) + w_mul(chi13_s2) + w_mul(chi14_s2);

            sum_s3 <= w_mul(chi1_s3) + w_mul(chi2_s3) + w_mul(chi3_s3) + w_mul(chi4_s3)
                    + w_mul(chi5_s3) + w_mul(chi6_s3) + w_mul(chi7_s3)
                    + w_mul(chi8_s3) + w_mul(chi9_s3) + w_mul(chi10_s3) + w_mul(chi11_s3)
                    + w_mul(chi12_s3) + w_mul(chi13_s3) + w_mul(chi14_s3);

            sum_s4 <= w_mul(chi1_s4) + w_mul(chi2_s4) + w_mul(chi3_s4) + w_mul(chi4_s4)
                    + w_mul(chi5_s4) + w_mul(chi6_s4) + w_mul(chi7_s4)
                    + w_mul(chi8_s4) + w_mul(chi9_s4) + w_mul(chi10_s4) + w_mul(chi11_s4)
                    + w_mul(chi12_s4) + w_mul(chi13_s4) + w_mul(chi14_s4);

            sum_s5 <= w_mul(chi1_s5) + w_mul(chi2_s5) + w_mul(chi3_s5) + w_mul(chi4_s5)
                    + w_mul(chi5_s5) + w_mul(chi6_s5) + w_mul(chi7_s5)
                    + w_mul(chi8_s5) + w_mul(chi9_s5) + w_mul(chi10_s5) + w_mul(chi11_s5)
                    + w_mul(chi12_s5) + w_mul(chi13_s5) + w_mul(chi14_s5);

            sum_s6 <= w_mul(chi1_s6) + w_mul(chi2_s6) + w_mul(chi3_s6) + w_mul(chi4_s6)
                    + w_mul(chi5_s6) + w_mul(chi6_s6) + w_mul(chi7_s6)
                    + w_mul(chi8_s6) + w_mul(chi9_s6) + w_mul(chi10_s6) + w_mul(chi11_s6)
                    + w_mul(chi12_s6) + w_mul(chi13_s6) + w_mul(chi14_s6);

            sum_s7 <= w_mul(chi1_s7) + w_mul(chi2_s7) + w_mul(chi3_s7) + w_mul(chi4_s7)
                    + w_mul(chi5_s7) + w_mul(chi6_s7) + w_mul(chi7_s7)
                    + w_mul(chi8_s7) + w_mul(chi9_s7) + w_mul(chi10_s7) + w_mul(chi11_s7)
                    + w_mul(chi12_s7) + w_mul(chi13_s7) + w_mul(chi14_s7);

            state <= OUTPUT_RESULT;

          when ACCUMULATE =>

            state <= OUTPUT_RESULT;

          when OUTPUT_RESULT =>
            s1_mean <= sum_s1;
            s2_mean <= sum_s2;
            s3_mean <= sum_s3;
            s4_mean <= sum_s4;
            s5_mean <= sum_s5;
            s6_mean <= sum_s6;
            s7_mean <= sum_s7;
            state <= FINISHED;

          when FINISHED =>
            done <= '1';
            if start = '0' then
              state <= IDLE;
            end if;

          when others =>
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;

end Behavioral;
