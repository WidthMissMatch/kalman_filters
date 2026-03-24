library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cholesky_7x7 is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    start : in  std_logic;

    p11 : in signed(47 downto 0);
    p12, p22 : in signed(47 downto 0);
    p13, p23, p33 : in signed(47 downto 0);
    p14, p24, p34, p44 : in signed(47 downto 0);
    p15, p25, p35, p45, p55 : in signed(47 downto 0);
    p16, p26, p36, p46, p56, p66 : in signed(47 downto 0);
    p17, p27, p37, p47, p57, p67, p77 : in signed(47 downto 0);

    l11_out : out signed(47 downto 0);
    l21_out, l22_out : out signed(47 downto 0);
    l31_out, l32_out, l33_out : out signed(47 downto 0);
    l41_out, l42_out, l43_out, l44_out : out signed(47 downto 0);
    l51_out, l52_out, l53_out, l54_out, l55_out : out signed(47 downto 0);
    l61_out, l62_out, l63_out, l64_out, l65_out, l66_out : out signed(47 downto 0);
    l71_out, l72_out, l73_out, l74_out, l75_out, l76_out, l77_out : out signed(47 downto 0);

    done  : out std_logic
  );
end entity;

architecture Behavioral of cholesky_7x7 is

  component sqrt_cordic is
    port (
      clk       : in  std_logic;
      start     : in  std_logic;
      value_in  : in  signed(47 downto 0);
      sqrt_out  : out signed(47 downto 0);
      done      : out std_logic
    );
  end component;

  constant Q : integer := 24;

  type state_type is (IDLE, COL1_DIAG, COL1_SQRT_WAIT, COL1_OFF,
                      COL2_DIAG, COL2_SQRT_WAIT, COL2_OFF,
                      COL3_DIAG, COL3_SQRT_WAIT, COL3_OFF,
                      COL4_DIAG, COL4_SQRT_WAIT, COL4_OFF,
                      COL5_DIAG, COL5_SQRT_WAIT, COL5_OFF,
                      COL6_DIAG, COL6_SQRT_WAIT, COL6_OFF,
                      COL7_DIAG, COL7_SQRT_WAIT,
                      FINISHED);
  signal state : state_type := IDLE;

  type l_matrix is array(1 to 7, 1 to 7) of signed(47 downto 0);
  signal L : l_matrix := (others => (others => (others => '0')));

  type p_matrix is array(1 to 7, 1 to 7) of signed(47 downto 0);
  signal P : p_matrix;

  signal sqrt_start : std_logic := '0';
  signal sqrt_in    : signed(47 downto 0) := (others => '0');
  signal sqrt_out_v : signed(47 downto 0);
  signal sqrt_done  : std_logic;

  function q_div(a, b : signed(47 downto 0)) return signed is
    variable num : signed(95 downto 0);
    variable den : signed(95 downto 0);
    variable result : signed(95 downto 0);
  begin
    if b = 0 then
      return to_signed(0, 48);
    end if;
    num := shift_left(resize(a, 96), Q);
    den := resize(b, 96);
    result := num / den;
    return resize(result, 48);
  end function;

  function q_mul(a, b : signed(47 downto 0)) return signed is
    variable prod : signed(95 downto 0);
  begin
    prod := a * b;
    return resize(shift_right(prod, Q), 48);
  end function;

begin

  sqrt_inst : sqrt_cordic
    port map (
      clk      => clk,
      start    => sqrt_start,
      value_in => sqrt_in,
      sqrt_out => sqrt_out_v,
      done     => sqrt_done
    );

  process(clk)
    variable sum_v : signed(95 downto 0);
    variable temp  : signed(47 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= IDLE;
        done <= '0';
        sqrt_start <= '0';
      else
        case state is
          when IDLE =>
            done <= '0';
            sqrt_start <= '0';
            if start = '1' then

              P(1,1) <= p11; P(1,2) <= p12; P(1,3) <= p13; P(1,4) <= p14;
              P(1,5) <= p15; P(1,6) <= p16; P(1,7) <= p17;
              P(2,1) <= p12; P(2,2) <= p22; P(2,3) <= p23; P(2,4) <= p24;
              P(2,5) <= p25; P(2,6) <= p26; P(2,7) <= p27;
              P(3,1) <= p13; P(3,2) <= p23; P(3,3) <= p33; P(3,4) <= p34;
              P(3,5) <= p35; P(3,6) <= p36; P(3,7) <= p37;
              P(4,1) <= p14; P(4,2) <= p24; P(4,3) <= p34; P(4,4) <= p44;
              P(4,5) <= p45; P(4,6) <= p46; P(4,7) <= p47;
              P(5,1) <= p15; P(5,2) <= p25; P(5,3) <= p35; P(5,4) <= p45;
              P(5,5) <= p55; P(5,6) <= p56; P(5,7) <= p57;
              P(6,1) <= p16; P(6,2) <= p26; P(6,3) <= p36; P(6,4) <= p46;
              P(6,5) <= p56; P(6,6) <= p66; P(6,7) <= p67;
              P(7,1) <= p17; P(7,2) <= p27; P(7,3) <= p37; P(7,4) <= p47;
              P(7,5) <= p57; P(7,6) <= p67; P(7,7) <= p77;

              for i in 1 to 7 loop
                for j in 1 to 7 loop
                  L(i,j) <= (others => '0');
                end loop;
              end loop;
              state <= COL1_DIAG;
            end if;

          when COL1_DIAG =>

            sqrt_in <= P(1,1);
            sqrt_start <= '1';
            state <= COL1_SQRT_WAIT;

          when COL1_SQRT_WAIT =>
            sqrt_start <= '0';
            if sqrt_done = '1' then
              L(1,1) <= sqrt_out_v;
              state <= COL1_OFF;
            end if;

          when COL1_OFF =>

            L(2,1) <= q_div(P(2,1), L(1,1));
            L(3,1) <= q_div(P(3,1), L(1,1));
            L(4,1) <= q_div(P(4,1), L(1,1));
            L(5,1) <= q_div(P(5,1), L(1,1));
            L(6,1) <= q_div(P(6,1), L(1,1));
            L(7,1) <= q_div(P(7,1), L(1,1));
            state <= COL2_DIAG;

          when COL2_DIAG =>

            temp := P(2,2) - q_mul(L(2,1), L(2,1));
            if temp < to_signed(16777, 48) then
              temp := to_signed(16777, 48);
            end if;
            sqrt_in <= temp;
            sqrt_start <= '1';
            state <= COL2_SQRT_WAIT;

          when COL2_SQRT_WAIT =>
            sqrt_start <= '0';
            if sqrt_done = '1' then
              L(2,2) <= sqrt_out_v;
              state <= COL2_OFF;
            end if;

          when COL2_OFF =>

            L(3,2) <= q_div(P(3,2) - q_mul(L(3,1), L(2,1)), L(2,2));
            L(4,2) <= q_div(P(4,2) - q_mul(L(4,1), L(2,1)), L(2,2));
            L(5,2) <= q_div(P(5,2) - q_mul(L(5,1), L(2,1)), L(2,2));
            L(6,2) <= q_div(P(6,2) - q_mul(L(6,1), L(2,1)), L(2,2));
            L(7,2) <= q_div(P(7,2) - q_mul(L(7,1), L(2,1)), L(2,2));
            state <= COL3_DIAG;

          when COL3_DIAG =>
            temp := P(3,3) - q_mul(L(3,1), L(3,1)) - q_mul(L(3,2), L(3,2));
            if temp < to_signed(16777, 48) then
              temp := to_signed(16777, 48);
            end if;
            sqrt_in <= temp;
            sqrt_start <= '1';
            state <= COL3_SQRT_WAIT;

          when COL3_SQRT_WAIT =>
            sqrt_start <= '0';
            if sqrt_done = '1' then
              L(3,3) <= sqrt_out_v;
              state <= COL3_OFF;
            end if;

          when COL3_OFF =>
            L(4,3) <= q_div(P(4,3) - q_mul(L(4,1), L(3,1)) - q_mul(L(4,2), L(3,2)), L(3,3));
            L(5,3) <= q_div(P(5,3) - q_mul(L(5,1), L(3,1)) - q_mul(L(5,2), L(3,2)), L(3,3));
            L(6,3) <= q_div(P(6,3) - q_mul(L(6,1), L(3,1)) - q_mul(L(6,2), L(3,2)), L(3,3));
            L(7,3) <= q_div(P(7,3) - q_mul(L(7,1), L(3,1)) - q_mul(L(7,2), L(3,2)), L(3,3));
            state <= COL4_DIAG;

          when COL4_DIAG =>
            temp := P(4,4) - q_mul(L(4,1), L(4,1)) - q_mul(L(4,2), L(4,2))
                    - q_mul(L(4,3), L(4,3));
            if temp < to_signed(16777, 48) then
              temp := to_signed(16777, 48);
            end if;
            sqrt_in <= temp;
            sqrt_start <= '1';
            state <= COL4_SQRT_WAIT;

          when COL4_SQRT_WAIT =>
            sqrt_start <= '0';
            if sqrt_done = '1' then
              L(4,4) <= sqrt_out_v;
              state <= COL4_OFF;
            end if;

          when COL4_OFF =>
            L(5,4) <= q_div(P(5,4) - q_mul(L(5,1), L(4,1)) - q_mul(L(5,2), L(4,2))
                      - q_mul(L(5,3), L(4,3)), L(4,4));
            L(6,4) <= q_div(P(6,4) - q_mul(L(6,1), L(4,1)) - q_mul(L(6,2), L(4,2))
                      - q_mul(L(6,3), L(4,3)), L(4,4));
            L(7,4) <= q_div(P(7,4) - q_mul(L(7,1), L(4,1)) - q_mul(L(7,2), L(4,2))
                      - q_mul(L(7,3), L(4,3)), L(4,4));
            state <= COL5_DIAG;

          when COL5_DIAG =>
            temp := P(5,5) - q_mul(L(5,1), L(5,1)) - q_mul(L(5,2), L(5,2))
                    - q_mul(L(5,3), L(5,3)) - q_mul(L(5,4), L(5,4));
            if temp < to_signed(16777, 48) then
              temp := to_signed(16777, 48);
            end if;
            sqrt_in <= temp;
            sqrt_start <= '1';
            state <= COL5_SQRT_WAIT;

          when COL5_SQRT_WAIT =>
            sqrt_start <= '0';
            if sqrt_done = '1' then
              L(5,5) <= sqrt_out_v;
              state <= COL5_OFF;
            end if;

          when COL5_OFF =>
            L(6,5) <= q_div(P(6,5) - q_mul(L(6,1), L(5,1)) - q_mul(L(6,2), L(5,2))
                      - q_mul(L(6,3), L(5,3)) - q_mul(L(6,4), L(5,4)), L(5,5));
            L(7,5) <= q_div(P(7,5) - q_mul(L(7,1), L(5,1)) - q_mul(L(7,2), L(5,2))
                      - q_mul(L(7,3), L(5,3)) - q_mul(L(7,4), L(5,4)), L(5,5));
            state <= COL6_DIAG;

          when COL6_DIAG =>
            temp := P(6,6) - q_mul(L(6,1), L(6,1)) - q_mul(L(6,2), L(6,2))
                    - q_mul(L(6,3), L(6,3)) - q_mul(L(6,4), L(6,4))
                    - q_mul(L(6,5), L(6,5));
            if temp < to_signed(16777, 48) then
              temp := to_signed(16777, 48);
            end if;
            sqrt_in <= temp;
            sqrt_start <= '1';
            state <= COL6_SQRT_WAIT;

          when COL6_SQRT_WAIT =>
            sqrt_start <= '0';
            if sqrt_done = '1' then
              L(6,6) <= sqrt_out_v;
              state <= COL6_OFF;
            end if;

          when COL6_OFF =>
            L(7,6) <= q_div(P(7,6) - q_mul(L(7,1), L(6,1)) - q_mul(L(7,2), L(6,2))
                      - q_mul(L(7,3), L(6,3)) - q_mul(L(7,4), L(6,4))
                      - q_mul(L(7,5), L(6,5)), L(6,6));
            state <= COL7_DIAG;

          when COL7_DIAG =>
            temp := P(7,7) - q_mul(L(7,1), L(7,1)) - q_mul(L(7,2), L(7,2))
                    - q_mul(L(7,3), L(7,3)) - q_mul(L(7,4), L(7,4))
                    - q_mul(L(7,5), L(7,5)) - q_mul(L(7,6), L(7,6));
            if temp < to_signed(16777, 48) then
              temp := to_signed(16777, 48);
            end if;
            sqrt_in <= temp;
            sqrt_start <= '1';
            state <= COL7_SQRT_WAIT;

          when COL7_SQRT_WAIT =>
            sqrt_start <= '0';
            if sqrt_done = '1' then
              L(7,7) <= sqrt_out_v;
              state <= FINISHED;
            end if;

          when FINISHED =>

            l11_out <= L(1,1);
            l21_out <= L(2,1); l22_out <= L(2,2);
            l31_out <= L(3,1); l32_out <= L(3,2); l33_out <= L(3,3);
            l41_out <= L(4,1); l42_out <= L(4,2); l43_out <= L(4,3); l44_out <= L(4,4);
            l51_out <= L(5,1); l52_out <= L(5,2); l53_out <= L(5,3); l54_out <= L(5,4); l55_out <= L(5,5);
            l61_out <= L(6,1); l62_out <= L(6,2); l63_out <= L(6,3); l64_out <= L(6,4); l65_out <= L(6,5); l66_out <= L(6,6);
            l71_out <= L(7,1); l72_out <= L(7,2); l73_out <= L(7,3); l74_out <= L(7,4); l75_out <= L(7,5); l76_out <= L(7,6); l77_out <= L(7,7);
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
