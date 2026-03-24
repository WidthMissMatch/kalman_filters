library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity process_noise_3d is
    port (
        clk   : in  std_logic;
        start : in  std_logic;
        p11_in, p12_in, p13_in, p14_in, p15_in, p16_in : in signed(47 downto 0);
        p22_in, p23_in, p24_in, p25_in, p26_in          : in signed(47 downto 0);
        p33_in, p34_in, p35_in, p36_in                  : in signed(47 downto 0);
        p44_in, p45_in, p46_in                          : in signed(47 downto 0);
        p55_in, p56_in                                  : in signed(47 downto 0);
        p66_in                                          : in signed(47 downto 0);
        p11_out, p12_out, p13_out, p14_out, p15_out, p16_out : out signed(47 downto 0);
        p22_out, p23_out, p24_out, p25_out, p26_out           : out signed(47 downto 0);
        p33_out, p34_out, p35_out, p36_out                    : out signed(47 downto 0);
        p44_out, p45_out, p46_out                             : out signed(47 downto 0);
        p55_out, p56_out                                      : out signed(47 downto 0);
        p66_out                                               : out signed(47 downto 0);
        done : out std_logic
    );
end process_noise_3d;
architecture Behavioral of process_noise_3d is
    constant Q11_Q24_24 : signed(47 downto 0) := to_signed(16777216, 48);
    constant Q12_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q13_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q14_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q15_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q16_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q22_Q24_24 : signed(47 downto 0) := to_signed(167772160, 48);
    constant Q23_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q24_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q25_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q26_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q33_Q24_24 : signed(47 downto 0) := to_signed(16777216, 48);
    constant Q34_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q35_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q36_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q44_Q24_24 : signed(47 downto 0) := to_signed(167772160, 48);
    constant Q45_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q46_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q55_Q24_24 : signed(47 downto 0) := to_signed(16777216, 48);
    constant Q56_Q16_16 : signed(47 downto 0) := to_signed(0, 48);
    constant Q66_Q24_24 : signed(47 downto 0) := to_signed(167772160, 48);
    type state_type is (IDLE, ADD_NOISE, SATURATE, FINISHED);
    signal state : state_type := IDLE;
    signal sum_p11, sum_p12, sum_p13, sum_p14, sum_p15, sum_p16 : signed(32 downto 0);
    signal sum_p22, sum_p23, sum_p24, sum_p25, sum_p26          : signed(32 downto 0);
    signal sum_p33, sum_p34, sum_p35, sum_p36                   : signed(32 downto 0);
    signal sum_p44, sum_p45, sum_p46                            : signed(32 downto 0);
    signal sum_p55, sum_p56                                     : signed(32 downto 0);
    signal sum_p66                                              : signed(32 downto 0);
    constant MAX_VALUE : signed(47 downto 0) := to_signed(2147483647, 48);
    constant MIN_VALUE : signed(47 downto 0) := to_signed(-2147483648, 48);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when IDLE =>
                    done <= '0';
                    if start = '1' then
                        state <= ADD_NOISE;
                    end if;
                when ADD_NOISE =>
                    report "PROCESS_NOISE: ADD_NOISE state" & LF &
                           "  p11_in=" & integer'image(to_integer(p11_in)) & LF &
                           "  p22_in=" & integer'image(to_integer(p22_in)) & LF &
                           "  Q11=" & integer'image(to_integer(Q11_Q24_24));
                    sum_p11 <= resize(p11_in, 33) + resize(Q11_Q24_24, 33);
                    sum_p12 <= resize(p12_in, 33) + resize(Q12_Q16_16, 33);
                    sum_p13 <= resize(p13_in, 33) + resize(Q13_Q16_16, 33);
                    sum_p14 <= resize(p14_in, 33) + resize(Q14_Q16_16, 33);
                    sum_p15 <= resize(p15_in, 33) + resize(Q15_Q16_16, 33);
                    sum_p16 <= resize(p16_in, 33) + resize(Q16_Q16_16, 33);
                    sum_p22 <= resize(p22_in, 33) + resize(Q22_Q24_24, 33);
                    sum_p23 <= resize(p23_in, 33) + resize(Q23_Q16_16, 33);
                    sum_p24 <= resize(p24_in, 33) + resize(Q24_Q16_16, 33);
                    sum_p25 <= resize(p25_in, 33) + resize(Q25_Q16_16, 33);
                    sum_p26 <= resize(p26_in, 33) + resize(Q26_Q16_16, 33);
                    sum_p33 <= resize(p33_in, 33) + resize(Q33_Q24_24, 33);
                    sum_p34 <= resize(p34_in, 33) + resize(Q34_Q16_16, 33);
                    sum_p35 <= resize(p35_in, 33) + resize(Q35_Q16_16, 33);
                    sum_p36 <= resize(p36_in, 33) + resize(Q36_Q16_16, 33);
                    sum_p44 <= resize(p44_in, 33) + resize(Q44_Q24_24, 33);
                    sum_p45 <= resize(p45_in, 33) + resize(Q45_Q16_16, 33);
                    sum_p46 <= resize(p46_in, 33) + resize(Q46_Q16_16, 33);
                    sum_p55 <= resize(p55_in, 33) + resize(Q55_Q24_24, 33);
                    sum_p56 <= resize(p56_in, 33) + resize(Q56_Q16_16, 33);
                    sum_p66 <= resize(p66_in, 33) + resize(Q66_Q24_24, 33);
                    state <= SATURATE;
                when SATURATE =>
                    report "PROCESS_NOISE: SATURATE state" & LF &
                           "  sum_p11(32:0)=" & integer'image(to_integer(sum_p11(31 downto 0))) & LF &
                           "  sum_p22(32:0)=" & integer'image(to_integer(sum_p22(31 downto 0)));
                    if sum_p11 > MAX_VALUE then
                        p11_out <= MAX_VALUE;
                    elsif sum_p11 < 0 then
                        p11_out <= to_signed(0, 48);
                    else
                        p11_out <= resize(sum_p11, 48);
                    end if;
                    if sum_p12 > MAX_VALUE then p12_out <= MAX_VALUE;
                    elsif sum_p12 < MIN_VALUE then p12_out <= MIN_VALUE;
                    else p12_out <= resize(sum_p12, 48); end if;
                    if sum_p13 > MAX_VALUE then p13_out <= MAX_VALUE;
                    elsif sum_p13 < MIN_VALUE then p13_out <= MIN_VALUE;
                    else p13_out <= resize(sum_p13, 48); end if;
                    if sum_p14 > MAX_VALUE then p14_out <= MAX_VALUE;
                    elsif sum_p14 < MIN_VALUE then p14_out <= MIN_VALUE;
                    else p14_out <= resize(sum_p14, 48); end if;
                    if sum_p15 > MAX_VALUE then p15_out <= MAX_VALUE;
                    elsif sum_p15 < MIN_VALUE then p15_out <= MIN_VALUE;
                    else p15_out <= resize(sum_p15, 48); end if;
                    if sum_p16 > MAX_VALUE then p16_out <= MAX_VALUE;
                    elsif sum_p16 < MIN_VALUE then p16_out <= MIN_VALUE;
                    else p16_out <= resize(sum_p16, 48); end if;
                    if sum_p22 > MAX_VALUE then
                        p22_out <= MAX_VALUE;
                    elsif sum_p22 < 0 then
                        p22_out <= to_signed(0, 48);
                    else
                        p22_out <= resize(sum_p22, 48);
                    end if;
                    if sum_p23 > MAX_VALUE then p23_out <= MAX_VALUE;
                    elsif sum_p23 < MIN_VALUE then p23_out <= MIN_VALUE;
                    else p23_out <= resize(sum_p23, 48); end if;
                    if sum_p24 > MAX_VALUE then p24_out <= MAX_VALUE;
                    elsif sum_p24 < MIN_VALUE then p24_out <= MIN_VALUE;
                    else p24_out <= resize(sum_p24, 48); end if;
                    if sum_p25 > MAX_VALUE then p25_out <= MAX_VALUE;
                    elsif sum_p25 < MIN_VALUE then p25_out <= MIN_VALUE;
                    else p25_out <= resize(sum_p25, 48); end if;
                    if sum_p26 > MAX_VALUE then p26_out <= MAX_VALUE;
                    elsif sum_p26 < MIN_VALUE then p26_out <= MIN_VALUE;
                    else p26_out <= resize(sum_p26, 48); end if;
                    if sum_p33 > MAX_VALUE then
                        p33_out <= MAX_VALUE;
                    elsif sum_p33 < 0 then
                        p33_out <= to_signed(0, 48);
                    else
                        p33_out <= resize(sum_p33, 48);
                    end if;
                    if sum_p34 > MAX_VALUE then p34_out <= MAX_VALUE;
                    elsif sum_p34 < MIN_VALUE then p34_out <= MIN_VALUE;
                    else p34_out <= resize(sum_p34, 48); end if;
                    if sum_p35 > MAX_VALUE then p35_out <= MAX_VALUE;
                    elsif sum_p35 < MIN_VALUE then p35_out <= MIN_VALUE;
                    else p35_out <= resize(sum_p35, 48); end if;
                    if sum_p36 > MAX_VALUE then p36_out <= MAX_VALUE;
                    elsif sum_p36 < MIN_VALUE then p36_out <= MIN_VALUE;
                    else p36_out <= resize(sum_p36, 48); end if;
                    if sum_p44 > MAX_VALUE then
                        p44_out <= MAX_VALUE;
                    elsif sum_p44 < 0 then
                        p44_out <= to_signed(0, 48);
                    else
                        p44_out <= resize(sum_p44, 48);
                    end if;
                    if sum_p45 > MAX_VALUE then p45_out <= MAX_VALUE;
                    elsif sum_p45 < MIN_VALUE then p45_out <= MIN_VALUE;
                    else p45_out <= resize(sum_p45, 48); end if;
                    if sum_p46 > MAX_VALUE then p46_out <= MAX_VALUE;
                    elsif sum_p46 < MIN_VALUE then p46_out <= MIN_VALUE;
                    else p46_out <= resize(sum_p46, 48); end if;
                    if sum_p55 > MAX_VALUE then
                        p55_out <= MAX_VALUE;
                    elsif sum_p55 < 0 then
                        p55_out <= to_signed(0, 48);
                    else
                        p55_out <= resize(sum_p55, 48);
                    end if;
                    if sum_p56 > MAX_VALUE then p56_out <= MAX_VALUE;
                    elsif sum_p56 < MIN_VALUE then p56_out <= MIN_VALUE;
                    else p56_out <= resize(sum_p56, 48); end if;
                    if sum_p66 > MAX_VALUE then
                        p66_out <= MAX_VALUE;
                    elsif sum_p66 < 0 then
                        p66_out <= to_signed(0, 48);
                    else
                        p66_out <= resize(sum_p66, 48);
                    end if;
                    state <= FINISHED;
                when FINISHED =>
                    done <= '1';
                    if start = '0' then
                        state <= IDLE;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
