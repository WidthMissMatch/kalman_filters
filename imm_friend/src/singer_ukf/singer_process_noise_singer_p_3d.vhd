library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity process_noise_singer_p_3d is
    port (
        clk   : in  std_logic;
        start : in  std_logic;

        p11_in, p12_in, p13_in, p14_in, p15_in, p16_in, p17_in, p18_in, p19_in : in signed(47 downto 0);
        p22_in, p23_in, p24_in, p25_in, p26_in, p27_in, p28_in, p29_in : in signed(47 downto 0);
        p33_in, p34_in, p35_in, p36_in, p37_in, p38_in, p39_in : in signed(47 downto 0);
        p44_in, p45_in, p46_in, p47_in, p48_in, p49_in : in signed(47 downto 0);
        p55_in, p56_in, p57_in, p58_in, p59_in : in signed(47 downto 0);
        p66_in, p67_in, p68_in, p69_in : in signed(47 downto 0);
        p77_in, p78_in, p79_in : in signed(47 downto 0);
        p88_in, p89_in : in signed(47 downto 0);
        p99_in : in signed(47 downto 0);

        p11_out, p12_out, p13_out, p14_out, p15_out, p16_out, p17_out, p18_out, p19_out : out signed(47 downto 0);
        p22_out, p23_out, p24_out, p25_out, p26_out, p27_out, p28_out, p29_out : out signed(47 downto 0);
        p33_out, p34_out, p35_out, p36_out, p37_out, p38_out, p39_out : out signed(47 downto 0);
        p44_out, p45_out, p46_out, p47_out, p48_out, p49_out : out signed(47 downto 0);
        p55_out, p56_out, p57_out, p58_out, p59_out : out signed(47 downto 0);
        p66_out, p67_out, p68_out, p69_out : out signed(47 downto 0);
        p77_out, p78_out, p79_out : out signed(47 downto 0);
        p88_out, p89_out : out signed(47 downto 0);
        p99_out : out signed(47 downto 0);

        done : out std_logic
    );
end process_noise_singer_p_3d;

architecture Behavioral of process_noise_singer_p_3d is
    constant Q : integer := 24;

    constant TAU : signed(47 downto 0) := to_signed(33554432, 48);
    constant SIGMA_A : signed(47 downto 0) := to_signed(83886080, 48);
    constant DT : signed(47 downto 0) := to_signed(335544, 48);

    constant Q_POS : signed(47 downto 0) := to_signed(838861, 48);
    constant Q_VEL : signed(47 downto 0) := to_signed(4194, 48);
    constant Q_ACC : signed(47 downto 0) := to_signed(168, 48);

    type state_type is (IDLE, ADD_NOISE, DONE_STATE);
    signal state : state_type := IDLE;

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

                    p11_out <= p11_in + Q_POS;
                    p22_out <= p22_in + Q_VEL;
                    p33_out <= p33_in + Q_ACC;

                    p44_out <= p44_in + Q_POS;
                    p55_out <= p55_in + Q_VEL;
                    p66_out <= p66_in + Q_ACC;

                    p77_out <= p77_in + Q_POS;
                    p88_out <= p88_in + Q_VEL;
                    p99_out <= p99_in + Q_ACC;

                    p12_out <= p12_in;
                    p13_out <= p13_in;
                    p14_out <= p14_in;
                    p15_out <= p15_in;
                    p16_out <= p16_in;
                    p17_out <= p17_in;
                    p18_out <= p18_in;
                    p19_out <= p19_in;

                    p23_out <= p23_in;
                    p24_out <= p24_in;
                    p25_out <= p25_in;
                    p26_out <= p26_in;
                    p27_out <= p27_in;
                    p28_out <= p28_in;
                    p29_out <= p29_in;

                    p34_out <= p34_in;
                    p35_out <= p35_in;
                    p36_out <= p36_in;
                    p37_out <= p37_in;
                    p38_out <= p38_in;
                    p39_out <= p39_in;

                    p45_out <= p45_in;
                    p46_out <= p46_in;
                    p47_out <= p47_in;
                    p48_out <= p48_in;
                    p49_out <= p49_in;

                    p56_out <= p56_in;
                    p57_out <= p57_in;
                    p58_out <= p58_in;
                    p59_out <= p59_in;

                    p67_out <= p67_in;
                    p68_out <= p68_in;
                    p69_out <= p69_in;

                    p78_out <= p78_in;
                    p79_out <= p79_in;

                    p89_out <= p89_in;

                    state <= DONE_STATE;

                when DONE_STATE =>
                    done <= '1';
                    if start = '0' then
                        state <= IDLE;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;
