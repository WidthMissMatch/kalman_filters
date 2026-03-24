library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity process_noise_3d is
    port (
        clk   : in  std_logic;
        start : in  std_logic;

        p11_in, p12_in, p13_in, p14_in, p15_in, p16_in, p17_in, p18_in, p19_in : in signed(47 downto 0);
        p22_in, p23_in, p24_in, p25_in, p26_in, p27_in, p28_in, p29_in          : in signed(47 downto 0);
        p33_in, p34_in, p35_in, p36_in, p37_in, p38_in, p39_in                  : in signed(47 downto 0);
        p44_in, p45_in, p46_in, p47_in, p48_in, p49_in                          : in signed(47 downto 0);
        p55_in, p56_in, p57_in, p58_in, p59_in                                  : in signed(47 downto 0);
        p66_in, p67_in, p68_in, p69_in                                          : in signed(47 downto 0);
        p77_in, p78_in, p79_in                                                  : in signed(47 downto 0);
        p88_in, p89_in                                                          : in signed(47 downto 0);
        p99_in                                                                  : in signed(47 downto 0);

        p11_out, p12_out, p13_out, p14_out, p15_out, p16_out, p17_out, p18_out, p19_out : out signed(47 downto 0);
        p22_out, p23_out, p24_out, p25_out, p26_out, p27_out, p28_out, p29_out           : out signed(47 downto 0);
        p33_out, p34_out, p35_out, p36_out, p37_out, p38_out, p39_out                    : out signed(47 downto 0);
        p44_out, p45_out, p46_out, p47_out, p48_out, p49_out                             : out signed(47 downto 0);
        p55_out, p56_out, p57_out, p58_out, p59_out                                      : out signed(47 downto 0);
        p66_out, p67_out, p68_out, p69_out                                               : out signed(47 downto 0);
        p77_out, p78_out, p79_out                                                        : out signed(47 downto 0);
        p88_out, p89_out                                                                 : out signed(47 downto 0);
        p99_out                                                                          : out signed(47 downto 0);

        done : out std_logic
    );
end process_noise_3d;

architecture Behavioral of process_noise_3d is

    constant ZERO_Q24_24 : signed(47 downto 0) := to_signed(0, 48);

    constant Q11_Q24_24 : signed(47 downto 0) := to_signed(838861, 48);
    constant Q22_Q24_24 : signed(47 downto 0) := to_signed(4194, 48);
    constant Q33_Q24_24 : signed(47 downto 0) := to_signed(168, 48);

    constant Q44_Q24_24 : signed(47 downto 0) := to_signed(838861, 48);
    constant Q55_Q24_24 : signed(47 downto 0) := to_signed(4194, 48);
    constant Q66_Q24_24 : signed(47 downto 0) := to_signed(168, 48);

    constant Q77_Q24_24 : signed(47 downto 0) := to_signed(838861, 48);
    constant Q88_Q24_24 : signed(47 downto 0) := to_signed(4194, 48);
    constant Q99_Q24_24 : signed(47 downto 0) := to_signed(168, 48);

    type state_type is (IDLE, ADD_NOISE, SATURATE, FINISHED);
    signal state : state_type := IDLE;

    signal sum_p11, sum_p12, sum_p13, sum_p14, sum_p15, sum_p16, sum_p17, sum_p18, sum_p19 : signed(48 downto 0);
    signal sum_p22, sum_p23, sum_p24, sum_p25, sum_p26, sum_p27, sum_p28, sum_p29          : signed(48 downto 0);
    signal sum_p33, sum_p34, sum_p35, sum_p36, sum_p37, sum_p38, sum_p39                   : signed(48 downto 0);
    signal sum_p44, sum_p45, sum_p46, sum_p47, sum_p48, sum_p49                            : signed(48 downto 0);
    signal sum_p55, sum_p56, sum_p57, sum_p58, sum_p59                                     : signed(48 downto 0);
    signal sum_p66, sum_p67, sum_p68, sum_p69                                              : signed(48 downto 0);
    signal sum_p77, sum_p78, sum_p79                                                       : signed(48 downto 0);
    signal sum_p88, sum_p89                                                                : signed(48 downto 0);
    signal sum_p99                                                                         : signed(48 downto 0);

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

                    report "PROCESS_NOISE: ADD_NOISE state (values hex-suppressed)";

                    sum_p11 <= resize(p11_in, 49) + resize(Q11_Q24_24, 49);
                    sum_p12 <= resize(p12_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p13 <= resize(p13_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p14 <= resize(p14_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p15 <= resize(p15_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p16 <= resize(p16_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p17 <= resize(p17_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p18 <= resize(p18_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p19 <= resize(p19_in, 49) + resize(ZERO_Q24_24, 49);

                    sum_p22 <= resize(p22_in, 49) + resize(Q22_Q24_24, 49);
                    sum_p23 <= resize(p23_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p24 <= resize(p24_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p25 <= resize(p25_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p26 <= resize(p26_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p27 <= resize(p27_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p28 <= resize(p28_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p29 <= resize(p29_in, 49) + resize(ZERO_Q24_24, 49);

                    sum_p33 <= resize(p33_in, 49) + resize(Q33_Q24_24, 49);
                    sum_p34 <= resize(p34_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p35 <= resize(p35_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p36 <= resize(p36_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p37 <= resize(p37_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p38 <= resize(p38_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p39 <= resize(p39_in, 49) + resize(ZERO_Q24_24, 49);

                    sum_p44 <= resize(p44_in, 49) + resize(Q11_Q24_24, 49);
                    sum_p45 <= resize(p45_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p46 <= resize(p46_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p47 <= resize(p47_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p48 <= resize(p48_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p49 <= resize(p49_in, 49) + resize(ZERO_Q24_24, 49);

                    sum_p55 <= resize(p55_in, 49) + resize(Q22_Q24_24, 49);
                    sum_p56 <= resize(p56_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p57 <= resize(p57_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p58 <= resize(p58_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p59 <= resize(p59_in, 49) + resize(ZERO_Q24_24, 49);

                    sum_p66 <= resize(p66_in, 49) + resize(Q33_Q24_24, 49);
                    sum_p67 <= resize(p67_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p68 <= resize(p68_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p69 <= resize(p69_in, 49) + resize(ZERO_Q24_24, 49);

                    sum_p77 <= resize(p77_in, 49) + resize(Q11_Q24_24, 49);
                    sum_p78 <= resize(p78_in, 49) + resize(ZERO_Q24_24, 49);
                    sum_p79 <= resize(p79_in, 49) + resize(ZERO_Q24_24, 49);

                    sum_p88 <= resize(p88_in, 49) + resize(Q22_Q24_24, 49);
                    sum_p89 <= resize(p89_in, 49) + resize(ZERO_Q24_24, 49);

                    sum_p99 <= resize(p99_in, 49) + resize(Q33_Q24_24, 49);

                    state <= SATURATE;

                when SATURATE =>

                    report "PROCESS_NOISE: SATURATE state (values hex-suppressed)";

                    if sum_p11 > MAX_VALUE then p11_out <= MAX_VALUE;
                    elsif sum_p11 < 0 then p11_out <= to_signed(0, 48);
                    else p11_out <= resize(sum_p11, 48); end if;

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

                    if sum_p17 > MAX_VALUE then p17_out <= MAX_VALUE;
                    elsif sum_p17 < MIN_VALUE then p17_out <= MIN_VALUE;
                    else p17_out <= resize(sum_p17, 48); end if;

                    if sum_p18 > MAX_VALUE then p18_out <= MAX_VALUE;
                    elsif sum_p18 < MIN_VALUE then p18_out <= MIN_VALUE;
                    else p18_out <= resize(sum_p18, 48); end if;

                    if sum_p19 > MAX_VALUE then p19_out <= MAX_VALUE;
                    elsif sum_p19 < MIN_VALUE then p19_out <= MIN_VALUE;
                    else p19_out <= resize(sum_p19, 48); end if;

                    if sum_p22 > MAX_VALUE then p22_out <= MAX_VALUE;
                    elsif sum_p22 < 0 then p22_out <= to_signed(0, 48);
                    else p22_out <= resize(sum_p22, 48); end if;

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

                    if sum_p27 > MAX_VALUE then p27_out <= MAX_VALUE;
                    elsif sum_p27 < MIN_VALUE then p27_out <= MIN_VALUE;
                    else p27_out <= resize(sum_p27, 48); end if;

                    if sum_p28 > MAX_VALUE then p28_out <= MAX_VALUE;
                    elsif sum_p28 < MIN_VALUE then p28_out <= MIN_VALUE;
                    else p28_out <= resize(sum_p28, 48); end if;

                    if sum_p29 > MAX_VALUE then p29_out <= MAX_VALUE;
                    elsif sum_p29 < MIN_VALUE then p29_out <= MIN_VALUE;
                    else p29_out <= resize(sum_p29, 48); end if;

                    if sum_p33 > MAX_VALUE then p33_out <= MAX_VALUE;
                    elsif sum_p33 < 0 then p33_out <= to_signed(0, 48);
                    else p33_out <= resize(sum_p33, 48); end if;

                    if sum_p34 > MAX_VALUE then p34_out <= MAX_VALUE;
                    elsif sum_p34 < MIN_VALUE then p34_out <= MIN_VALUE;
                    else p34_out <= resize(sum_p34, 48); end if;

                    if sum_p35 > MAX_VALUE then p35_out <= MAX_VALUE;
                    elsif sum_p35 < MIN_VALUE then p35_out <= MIN_VALUE;
                    else p35_out <= resize(sum_p35, 48); end if;

                    if sum_p36 > MAX_VALUE then p36_out <= MAX_VALUE;
                    elsif sum_p36 < MIN_VALUE then p36_out <= MIN_VALUE;
                    else p36_out <= resize(sum_p36, 48); end if;

                    if sum_p37 > MAX_VALUE then p37_out <= MAX_VALUE;
                    elsif sum_p37 < MIN_VALUE then p37_out <= MIN_VALUE;
                    else p37_out <= resize(sum_p37, 48); end if;

                    if sum_p38 > MAX_VALUE then p38_out <= MAX_VALUE;
                    elsif sum_p38 < MIN_VALUE then p38_out <= MIN_VALUE;
                    else p38_out <= resize(sum_p38, 48); end if;

                    if sum_p39 > MAX_VALUE then p39_out <= MAX_VALUE;
                    elsif sum_p39 < MIN_VALUE then p39_out <= MIN_VALUE;
                    else p39_out <= resize(sum_p39, 48); end if;

                    if sum_p44 > MAX_VALUE then p44_out <= MAX_VALUE;
                    elsif sum_p44 < 0 then p44_out <= to_signed(0, 48);
                    else p44_out <= resize(sum_p44, 48); end if;

                    if sum_p45 > MAX_VALUE then p45_out <= MAX_VALUE;
                    elsif sum_p45 < MIN_VALUE then p45_out <= MIN_VALUE;
                    else p45_out <= resize(sum_p45, 48); end if;

                    if sum_p46 > MAX_VALUE then p46_out <= MAX_VALUE;
                    elsif sum_p46 < MIN_VALUE then p46_out <= MIN_VALUE;
                    else p46_out <= resize(sum_p46, 48); end if;

                    if sum_p47 > MAX_VALUE then p47_out <= MAX_VALUE;
                    elsif sum_p47 < MIN_VALUE then p47_out <= MIN_VALUE;
                    else p47_out <= resize(sum_p47, 48); end if;

                    if sum_p48 > MAX_VALUE then p48_out <= MAX_VALUE;
                    elsif sum_p48 < MIN_VALUE then p48_out <= MIN_VALUE;
                    else p48_out <= resize(sum_p48, 48); end if;

                    if sum_p49 > MAX_VALUE then p49_out <= MAX_VALUE;
                    elsif sum_p49 < MIN_VALUE then p49_out <= MIN_VALUE;
                    else p49_out <= resize(sum_p49, 48); end if;

                    if sum_p55 > MAX_VALUE then p55_out <= MAX_VALUE;
                    elsif sum_p55 < 0 then p55_out <= to_signed(0, 48);
                    else p55_out <= resize(sum_p55, 48); end if;

                    if sum_p56 > MAX_VALUE then p56_out <= MAX_VALUE;
                    elsif sum_p56 < MIN_VALUE then p56_out <= MIN_VALUE;
                    else p56_out <= resize(sum_p56, 48); end if;

                    if sum_p57 > MAX_VALUE then p57_out <= MAX_VALUE;
                    elsif sum_p57 < MIN_VALUE then p57_out <= MIN_VALUE;
                    else p57_out <= resize(sum_p57, 48); end if;

                    if sum_p58 > MAX_VALUE then p58_out <= MAX_VALUE;
                    elsif sum_p58 < MIN_VALUE then p58_out <= MIN_VALUE;
                    else p58_out <= resize(sum_p58, 48); end if;

                    if sum_p59 > MAX_VALUE then p59_out <= MAX_VALUE;
                    elsif sum_p59 < MIN_VALUE then p59_out <= MIN_VALUE;
                    else p59_out <= resize(sum_p59, 48); end if;

                    if sum_p66 > MAX_VALUE then p66_out <= MAX_VALUE;
                    elsif sum_p66 < 0 then p66_out <= to_signed(0, 48);
                    else p66_out <= resize(sum_p66, 48); end if;

                    if sum_p67 > MAX_VALUE then p67_out <= MAX_VALUE;
                    elsif sum_p67 < MIN_VALUE then p67_out <= MIN_VALUE;
                    else p67_out <= resize(sum_p67, 48); end if;

                    if sum_p68 > MAX_VALUE then p68_out <= MAX_VALUE;
                    elsif sum_p68 < MIN_VALUE then p68_out <= MIN_VALUE;
                    else p68_out <= resize(sum_p68, 48); end if;

                    if sum_p69 > MAX_VALUE then p69_out <= MAX_VALUE;
                    elsif sum_p69 < MIN_VALUE then p69_out <= MIN_VALUE;
                    else p69_out <= resize(sum_p69, 48); end if;

                    if sum_p77 > MAX_VALUE then p77_out <= MAX_VALUE;
                    elsif sum_p77 < 0 then p77_out <= to_signed(0, 48);
                    else p77_out <= resize(sum_p77, 48); end if;

                    if sum_p78 > MAX_VALUE then p78_out <= MAX_VALUE;
                    elsif sum_p78 < MIN_VALUE then p78_out <= MIN_VALUE;
                    else p78_out <= resize(sum_p78, 48); end if;

                    if sum_p79 > MAX_VALUE then p79_out <= MAX_VALUE;
                    elsif sum_p79 < MIN_VALUE then p79_out <= MIN_VALUE;
                    else p79_out <= resize(sum_p79, 48); end if;

                    if sum_p88 > MAX_VALUE then p88_out <= MAX_VALUE;
                    elsif sum_p88 < 0 then p88_out <= to_signed(0, 48);
                    else p88_out <= resize(sum_p88, 48); end if;

                    if sum_p89 > MAX_VALUE then p89_out <= MAX_VALUE;
                    elsif sum_p89 < MIN_VALUE then p89_out <= MIN_VALUE;
                    else p89_out <= resize(sum_p89, 48); end if;

                    if sum_p99 > MAX_VALUE then p99_out <= MAX_VALUE;
                    elsif sum_p99 < 0 then p99_out <= to_signed(0, 48);
                    else p99_out <= resize(sum_p99, 48); end if;

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
