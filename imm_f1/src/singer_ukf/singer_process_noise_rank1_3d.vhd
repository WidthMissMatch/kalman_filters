library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity process_noise_rank1_3d is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        start : in  std_logic;

        l11_in, l21_in, l31_in, l41_in, l51_in, l61_in, l71_in, l81_in, l91_in : in signed(47 downto 0);
        l22_in, l32_in, l42_in, l52_in, l62_in, l72_in, l82_in, l92_in : in signed(47 downto 0);
        l33_in, l43_in, l53_in, l63_in, l73_in, l83_in, l93_in : in signed(47 downto 0);
        l44_in, l54_in, l64_in, l74_in, l84_in, l94_in : in signed(47 downto 0);
        l55_in, l65_in, l75_in, l85_in, l95_in : in signed(47 downto 0);
        l66_in, l76_in, l86_in, l96_in : in signed(47 downto 0);
        l77_in, l87_in, l97_in : in signed(47 downto 0);
        l88_in, l98_in : in signed(47 downto 0);
        l99_in : in signed(47 downto 0);

        l11_out, l21_out, l31_out, l41_out, l51_out, l61_out, l71_out, l81_out, l91_out : out signed(47 downto 0);
        l22_out, l32_out, l42_out, l52_out, l62_out, l72_out, l82_out, l92_out : out signed(47 downto 0);
        l33_out, l43_out, l53_out, l63_out, l73_out, l83_out, l93_out : out signed(47 downto 0);
        l44_out, l54_out, l64_out, l74_out, l84_out, l94_out : out signed(47 downto 0);
        l55_out, l65_out, l75_out, l85_out, l95_out : out signed(47 downto 0);
        l66_out, l76_out, l86_out, l96_out : out signed(47 downto 0);
        l77_out, l87_out, l97_out : out signed(47 downto 0);
        l88_out, l98_out : out signed(47 downto 0);
        l99_out : out signed(47 downto 0);

        done : out std_logic
    );
end process_noise_rank1_3d;

architecture Behavioral of process_noise_rank1_3d is

    constant LQ11_SINGER : signed(47 downto 0) := to_signed(18626, 48);
    constant LQ21_SINGER : signed(47 downto 0) := to_signed(2246493, 48);
    constant LQ22_SINGER : signed(47 downto 0) := to_signed(725837, 48);
    constant LQ31_SINGER : signed(47 downto 0) := to_signed(149121552, 48);
    constant LQ32_SINGER : signed(47 downto 0) := to_signed(112457676, 48);
    constant LQ33_SINGER : signed(47 downto 0) := to_signed(82336512, 48);

    component cholesky_rank1_update is
        port (
            clk, reset, start : in std_logic;
            l11_in, l21_in, l31_in, l41_in, l51_in, l61_in, l71_in, l81_in, l91_in : in signed(47 downto 0);
            l22_in, l32_in, l42_in, l52_in, l62_in, l72_in, l82_in, l92_in : in signed(47 downto 0);
            l33_in, l43_in, l53_in, l63_in, l73_in, l83_in, l93_in : in signed(47 downto 0);
            l44_in, l54_in, l64_in, l74_in, l84_in, l94_in : in signed(47 downto 0);
            l55_in, l65_in, l75_in, l85_in, l95_in : in signed(47 downto 0);
            l66_in, l76_in, l86_in, l96_in : in signed(47 downto 0);
            l77_in, l87_in, l97_in : in signed(47 downto 0);
            l88_in, l98_in : in signed(47 downto 0);
            l99_in : in signed(47 downto 0);
            u1_in, u2_in, u3_in, u4_in, u5_in, u6_in, u7_in, u8_in, u9_in : in signed(47 downto 0);
            l11_out, l21_out, l31_out, l41_out, l51_out, l61_out, l71_out, l81_out, l91_out : out signed(47 downto 0);
            l22_out, l32_out, l42_out, l52_out, l62_out, l72_out, l82_out, l92_out : out signed(47 downto 0);
            l33_out, l43_out, l53_out, l63_out, l73_out, l83_out, l93_out : out signed(47 downto 0);
            l44_out, l54_out, l64_out, l74_out, l84_out, l94_out : out signed(47 downto 0);
            l55_out, l65_out, l75_out, l85_out, l95_out : out signed(47 downto 0);
            l66_out, l76_out, l86_out, l96_out : out signed(47 downto 0);
            l77_out, l87_out, l97_out : out signed(47 downto 0);
            l88_out, l98_out : out signed(47 downto 0);
            l99_out : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    type state_type is (IDLE, LOAD, UPDATE_1, WAIT_1, LOAD_2,
                        UPDATE_2, WAIT_2, LOAD_3, UPDATE_3, WAIT_3, LOAD_4,
                        UPDATE_4, WAIT_4, LOAD_5, UPDATE_5, WAIT_5, LOAD_6,
                        UPDATE_6, WAIT_6, LOAD_7, UPDATE_7, WAIT_7, LOAD_8,
                        UPDATE_8, WAIT_8, LOAD_9, UPDATE_9, WAIT_9, FINISHED);
    signal state : state_type := IDLE;

    signal chol_start : std_logic := '0';
    signal chol_done : std_logic;

    signal l11_in_buf, l21_in_buf, l31_in_buf, l41_in_buf, l51_in_buf, l61_in_buf, l71_in_buf, l81_in_buf, l91_in_buf : signed(47 downto 0) := (others => '0');
    signal l22_in_buf, l32_in_buf, l42_in_buf, l52_in_buf, l62_in_buf, l72_in_buf, l82_in_buf, l92_in_buf : signed(47 downto 0) := (others => '0');
    signal l33_in_buf, l43_in_buf, l53_in_buf, l63_in_buf, l73_in_buf, l83_in_buf, l93_in_buf : signed(47 downto 0) := (others => '0');
    signal l44_in_buf, l54_in_buf, l64_in_buf, l74_in_buf, l84_in_buf, l94_in_buf : signed(47 downto 0) := (others => '0');
    signal l55_in_buf, l65_in_buf, l75_in_buf, l85_in_buf, l95_in_buf : signed(47 downto 0) := (others => '0');
    signal l66_in_buf, l76_in_buf, l86_in_buf, l96_in_buf : signed(47 downto 0) := (others => '0');
    signal l77_in_buf, l87_in_buf, l97_in_buf : signed(47 downto 0) := (others => '0');
    signal l88_in_buf, l98_in_buf : signed(47 downto 0) := (others => '0');
    signal l99_in_buf : signed(47 downto 0) := (others => '0');

    signal l11_out_buf, l21_out_buf, l31_out_buf, l41_out_buf, l51_out_buf, l61_out_buf, l71_out_buf, l81_out_buf, l91_out_buf : signed(47 downto 0) := (others => '0');
    signal l22_out_buf, l32_out_buf, l42_out_buf, l52_out_buf, l62_out_buf, l72_out_buf, l82_out_buf, l92_out_buf : signed(47 downto 0) := (others => '0');
    signal l33_out_buf, l43_out_buf, l53_out_buf, l63_out_buf, l73_out_buf, l83_out_buf, l93_out_buf : signed(47 downto 0) := (others => '0');
    signal l44_out_buf, l54_out_buf, l64_out_buf, l74_out_buf, l84_out_buf, l94_out_buf : signed(47 downto 0) := (others => '0');
    signal l55_out_buf, l65_out_buf, l75_out_buf, l85_out_buf, l95_out_buf : signed(47 downto 0) := (others => '0');
    signal l66_out_buf, l76_out_buf, l86_out_buf, l96_out_buf : signed(47 downto 0) := (others => '0');
    signal l77_out_buf, l87_out_buf, l97_out_buf : signed(47 downto 0) := (others => '0');
    signal l88_out_buf, l98_out_buf : signed(47 downto 0) := (others => '0');
    signal l99_out_buf : signed(47 downto 0) := (others => '0');

    signal u1, u2, u3, u4, u5, u6, u7, u8, u9 : signed(47 downto 0) := (others => '0');

begin

    chol_update_inst : cholesky_rank1_update
        port map (
            clk => clk, reset => reset, start => chol_start,

            l11_in => l11_in_buf, l21_in => l21_in_buf, l31_in => l31_in_buf, l41_in => l41_in_buf, l51_in => l51_in_buf, l61_in => l61_in_buf, l71_in => l71_in_buf, l81_in => l81_in_buf, l91_in => l91_in_buf,
            l22_in => l22_in_buf, l32_in => l32_in_buf, l42_in => l42_in_buf, l52_in => l52_in_buf, l62_in => l62_in_buf, l72_in => l72_in_buf, l82_in => l82_in_buf, l92_in => l92_in_buf,
            l33_in => l33_in_buf, l43_in => l43_in_buf, l53_in => l53_in_buf, l63_in => l63_in_buf, l73_in => l73_in_buf, l83_in => l83_in_buf, l93_in => l93_in_buf,
            l44_in => l44_in_buf, l54_in => l54_in_buf, l64_in => l64_in_buf, l74_in => l74_in_buf, l84_in => l84_in_buf, l94_in => l94_in_buf,
            l55_in => l55_in_buf, l65_in => l65_in_buf, l75_in => l75_in_buf, l85_in => l85_in_buf, l95_in => l95_in_buf,
            l66_in => l66_in_buf, l76_in => l76_in_buf, l86_in => l86_in_buf, l96_in => l96_in_buf,
            l77_in => l77_in_buf, l87_in => l87_in_buf, l97_in => l97_in_buf,
            l88_in => l88_in_buf, l98_in => l98_in_buf,
            l99_in => l99_in_buf,
            u1_in => u1, u2_in => u2, u3_in => u3, u4_in => u4, u5_in => u5, u6_in => u6, u7_in => u7, u8_in => u8, u9_in => u9,

            l11_out => l11_out_buf, l21_out => l21_out_buf, l31_out => l31_out_buf, l41_out => l41_out_buf, l51_out => l51_out_buf, l61_out => l61_out_buf, l71_out => l71_out_buf, l81_out => l81_out_buf, l91_out => l91_out_buf,
            l22_out => l22_out_buf, l32_out => l32_out_buf, l42_out => l42_out_buf, l52_out => l52_out_buf, l62_out => l62_out_buf, l72_out => l72_out_buf, l82_out => l82_out_buf, l92_out => l92_out_buf,
            l33_out => l33_out_buf, l43_out => l43_out_buf, l53_out => l53_out_buf, l63_out => l63_out_buf, l73_out => l73_out_buf, l83_out => l83_out_buf, l93_out => l93_out_buf,
            l44_out => l44_out_buf, l54_out => l54_out_buf, l64_out => l64_out_buf, l74_out => l74_out_buf, l84_out => l84_out_buf, l94_out => l94_out_buf,
            l55_out => l55_out_buf, l65_out => l65_out_buf, l75_out => l75_out_buf, l85_out => l85_out_buf, l95_out => l95_out_buf,
            l66_out => l66_out_buf, l76_out => l76_out_buf, l86_out => l86_out_buf, l96_out => l96_out_buf,
            l77_out => l77_out_buf, l87_out => l87_out_buf, l97_out => l97_out_buf,
            l88_out => l88_out_buf, l98_out => l98_out_buf,
            l99_out => l99_out_buf,
            done => chol_done
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                done <= '0';
                chol_start <= '0';
            else
                case state is

                    when IDLE =>
                        done <= '0';
                        chol_start <= '0';
                        report "STATE: IDLE";
                        if start = '1' then
                            report "PROCESS_NOISE: IDLE state received inputs" &
                                   " l11_in=" & integer'image(to_integer(l11_in)) &
                                   " l22_in=" & integer'image(to_integer(l22_in)) &
                                   " l33_in=" & integer'image(to_integer(l33_in));

                            l11_in_buf <= l11_in; l21_in_buf <= l21_in; l31_in_buf <= l31_in; l41_in_buf <= l41_in; l51_in_buf <= l51_in; l61_in_buf <= l61_in; l71_in_buf <= l71_in; l81_in_buf <= l81_in; l91_in_buf <= l91_in;
                            l22_in_buf <= l22_in; l32_in_buf <= l32_in; l42_in_buf <= l42_in; l52_in_buf <= l52_in; l62_in_buf <= l62_in; l72_in_buf <= l72_in; l82_in_buf <= l82_in; l92_in_buf <= l92_in;
                            l33_in_buf <= l33_in; l43_in_buf <= l43_in; l53_in_buf <= l53_in; l63_in_buf <= l63_in; l73_in_buf <= l73_in; l83_in_buf <= l83_in; l93_in_buf <= l93_in;
                            l44_in_buf <= l44_in; l54_in_buf <= l54_in; l64_in_buf <= l64_in; l74_in_buf <= l74_in; l84_in_buf <= l84_in; l94_in_buf <= l94_in;
                            l55_in_buf <= l55_in; l65_in_buf <= l65_in; l75_in_buf <= l75_in; l85_in_buf <= l85_in; l95_in_buf <= l95_in;
                            l66_in_buf <= l66_in; l76_in_buf <= l76_in; l86_in_buf <= l86_in; l96_in_buf <= l96_in;
                            l77_in_buf <= l77_in; l87_in_buf <= l87_in; l97_in_buf <= l97_in;
                            l88_in_buf <= l88_in; l98_in_buf <= l98_in;
                            l99_in_buf <= l99_in;
                            state <= LOAD;
                        end if;

                    when LOAD =>
                        report "PROCESS_NOISE: Input buffers loaded" &
                               " l11_in_buf=" & integer'image(to_integer(l11_in_buf)) &
                               " l22_in_buf=" & integer'image(to_integer(l22_in_buf)) &
                               " l33_in_buf=" & integer'image(to_integer(l33_in_buf)) &
                               " - starting update 1";
                        state <= UPDATE_1;

                    when UPDATE_1 =>
                        report "STATE: UPDATE_1";
                        u1 <= LQ11_SINGER; u2 <= LQ21_SINGER; u3 <= LQ31_SINGER;
                        u4 <= (others => '0'); u5 <= (others => '0'); u6 <= (others => '0');
                        u7 <= (others => '0'); u8 <= (others => '0'); u9 <= (others => '0');
                        chol_start <= '1';
                        state <= WAIT_1;

                    when WAIT_1 =>
                        chol_start <= '0';
                        report "WAIT_1: Entered state, chol_done=" & std_logic'image(chol_done);
                        if chol_done = '1' then
                            report "WAIT_1: Copying outputs to inputs" &
                                   " l11_out_buf=" & integer'image(to_integer(l11_out_buf)) &
                                   " l22_out_buf=" & integer'image(to_integer(l22_out_buf)) &
                                   " l33_out_buf=" & integer'image(to_integer(l33_out_buf));

                            l11_in_buf <= l11_out_buf; l21_in_buf <= l21_out_buf; l31_in_buf <= l31_out_buf; l41_in_buf <= l41_out_buf; l51_in_buf <= l51_out_buf; l61_in_buf <= l61_out_buf; l71_in_buf <= l71_out_buf; l81_in_buf <= l81_out_buf; l91_in_buf <= l91_out_buf;
                            l22_in_buf <= l22_out_buf; l32_in_buf <= l32_out_buf; l42_in_buf <= l42_out_buf; l52_in_buf <= l52_out_buf; l62_in_buf <= l62_out_buf; l72_in_buf <= l72_out_buf; l82_in_buf <= l82_out_buf; l92_in_buf <= l92_out_buf;
                            l33_in_buf <= l33_out_buf; l43_in_buf <= l43_out_buf; l53_in_buf <= l53_out_buf; l63_in_buf <= l63_out_buf; l73_in_buf <= l73_out_buf; l83_in_buf <= l83_out_buf; l93_in_buf <= l93_out_buf;
                            l44_in_buf <= l44_out_buf; l54_in_buf <= l54_out_buf; l64_in_buf <= l64_out_buf; l74_in_buf <= l74_out_buf; l84_in_buf <= l84_out_buf; l94_in_buf <= l94_out_buf;
                            l55_in_buf <= l55_out_buf; l65_in_buf <= l65_out_buf; l75_in_buf <= l75_out_buf; l85_in_buf <= l85_out_buf; l95_in_buf <= l95_out_buf;
                            l66_in_buf <= l66_out_buf; l76_in_buf <= l76_out_buf; l86_in_buf <= l86_out_buf; l96_in_buf <= l96_out_buf;
                            l77_in_buf <= l77_out_buf; l87_in_buf <= l87_out_buf; l97_in_buf <= l97_out_buf;
                            l88_in_buf <= l88_out_buf; l98_in_buf <= l98_out_buf;
                            l99_in_buf <= l99_out_buf;
                            state <= LOAD_2;
                        end if;

                    when LOAD_2 =>
                        report "STATE: LOAD_2";

                        report "LOAD_2: Buffers should be settled" &
                               " l11_in_buf=" & integer'image(to_integer(l11_in_buf)) &
                               " l22_in_buf=" & integer'image(to_integer(l22_in_buf)) &
                               " l33_in_buf=" & integer'image(to_integer(l33_in_buf));
                        state <= UPDATE_2;

                    when UPDATE_2 =>
                        u1 <= (others => '0'); u2 <= LQ22_SINGER; u3 <= LQ32_SINGER;
                        u4 <= (others => '0'); u5 <= (others => '0'); u6 <= (others => '0');
                        u7 <= (others => '0'); u8 <= (others => '0'); u9 <= (others => '0');
                        chol_start <= '1';
                        state <= WAIT_2;

                    when WAIT_2 =>
                        chol_start <= '0';
                        if chol_done = '1' then

                            l11_in_buf <= l11_out_buf; l21_in_buf <= l21_out_buf; l31_in_buf <= l31_out_buf; l41_in_buf <= l41_out_buf; l51_in_buf <= l51_out_buf; l61_in_buf <= l61_out_buf; l71_in_buf <= l71_out_buf; l81_in_buf <= l81_out_buf; l91_in_buf <= l91_out_buf;
                            l22_in_buf <= l22_out_buf; l32_in_buf <= l32_out_buf; l42_in_buf <= l42_out_buf; l52_in_buf <= l52_out_buf; l62_in_buf <= l62_out_buf; l72_in_buf <= l72_out_buf; l82_in_buf <= l82_out_buf; l92_in_buf <= l92_out_buf;
                            l33_in_buf <= l33_out_buf; l43_in_buf <= l43_out_buf; l53_in_buf <= l53_out_buf; l63_in_buf <= l63_out_buf; l73_in_buf <= l73_out_buf; l83_in_buf <= l83_out_buf; l93_in_buf <= l93_out_buf;
                            l44_in_buf <= l44_out_buf; l54_in_buf <= l54_out_buf; l64_in_buf <= l64_out_buf; l74_in_buf <= l74_out_buf; l84_in_buf <= l84_out_buf; l94_in_buf <= l94_out_buf;
                            l55_in_buf <= l55_out_buf; l65_in_buf <= l65_out_buf; l75_in_buf <= l75_out_buf; l85_in_buf <= l85_out_buf; l95_in_buf <= l95_out_buf;
                            l66_in_buf <= l66_out_buf; l76_in_buf <= l76_out_buf; l86_in_buf <= l86_out_buf; l96_in_buf <= l96_out_buf;
                            l77_in_buf <= l77_out_buf; l87_in_buf <= l87_out_buf; l97_in_buf <= l97_out_buf;
                            l88_in_buf <= l88_out_buf; l98_in_buf <= l98_out_buf;
                            l99_in_buf <= l99_out_buf;
                            state <= LOAD_3;
                        end if;

                    when LOAD_3 =>

                        state <= UPDATE_3;

                    when UPDATE_3 =>
                        u1 <= (others => '0'); u2 <= (others => '0'); u3 <= LQ33_SINGER;
                        u4 <= (others => '0'); u5 <= (others => '0'); u6 <= (others => '0');
                        u7 <= (others => '0'); u8 <= (others => '0'); u9 <= (others => '0');
                        chol_start <= '1';
                        state <= WAIT_3;

                    when WAIT_3 =>
                        chol_start <= '0';
                        if chol_done = '1' then

                            l11_in_buf <= l11_out_buf; l21_in_buf <= l21_out_buf; l31_in_buf <= l31_out_buf; l41_in_buf <= l41_out_buf; l51_in_buf <= l51_out_buf; l61_in_buf <= l61_out_buf; l71_in_buf <= l71_out_buf; l81_in_buf <= l81_out_buf; l91_in_buf <= l91_out_buf;
                            l22_in_buf <= l22_out_buf; l32_in_buf <= l32_out_buf; l42_in_buf <= l42_out_buf; l52_in_buf <= l52_out_buf; l62_in_buf <= l62_out_buf; l72_in_buf <= l72_out_buf; l82_in_buf <= l82_out_buf; l92_in_buf <= l92_out_buf;
                            l33_in_buf <= l33_out_buf; l43_in_buf <= l43_out_buf; l53_in_buf <= l53_out_buf; l63_in_buf <= l63_out_buf; l73_in_buf <= l73_out_buf; l83_in_buf <= l83_out_buf; l93_in_buf <= l93_out_buf;
                            l44_in_buf <= l44_out_buf; l54_in_buf <= l54_out_buf; l64_in_buf <= l64_out_buf; l74_in_buf <= l74_out_buf; l84_in_buf <= l84_out_buf; l94_in_buf <= l94_out_buf;
                            l55_in_buf <= l55_out_buf; l65_in_buf <= l65_out_buf; l75_in_buf <= l75_out_buf; l85_in_buf <= l85_out_buf; l95_in_buf <= l95_out_buf;
                            l66_in_buf <= l66_out_buf; l76_in_buf <= l76_out_buf; l86_in_buf <= l86_out_buf; l96_in_buf <= l96_out_buf;
                            l77_in_buf <= l77_out_buf; l87_in_buf <= l87_out_buf; l97_in_buf <= l97_out_buf;
                            l88_in_buf <= l88_out_buf; l98_in_buf <= l98_out_buf;
                            l99_in_buf <= l99_out_buf;
                            state <= LOAD_4;
                        end if;

                    when LOAD_4 =>

                        state <= UPDATE_4;

                    when UPDATE_4 =>
                        u1 <= (others => '0'); u2 <= (others => '0'); u3 <= (others => '0');
                        u4 <= LQ11_SINGER; u5 <= LQ21_SINGER; u6 <= LQ31_SINGER;
                        u7 <= (others => '0'); u8 <= (others => '0'); u9 <= (others => '0');
                        chol_start <= '1';
                        state <= WAIT_4;

                    when WAIT_4 =>
                        chol_start <= '0';
                        if chol_done = '1' then

                            l11_in_buf <= l11_out_buf; l21_in_buf <= l21_out_buf; l31_in_buf <= l31_out_buf; l41_in_buf <= l41_out_buf; l51_in_buf <= l51_out_buf; l61_in_buf <= l61_out_buf; l71_in_buf <= l71_out_buf; l81_in_buf <= l81_out_buf; l91_in_buf <= l91_out_buf;
                            l22_in_buf <= l22_out_buf; l32_in_buf <= l32_out_buf; l42_in_buf <= l42_out_buf; l52_in_buf <= l52_out_buf; l62_in_buf <= l62_out_buf; l72_in_buf <= l72_out_buf; l82_in_buf <= l82_out_buf; l92_in_buf <= l92_out_buf;
                            l33_in_buf <= l33_out_buf; l43_in_buf <= l43_out_buf; l53_in_buf <= l53_out_buf; l63_in_buf <= l63_out_buf; l73_in_buf <= l73_out_buf; l83_in_buf <= l83_out_buf; l93_in_buf <= l93_out_buf;
                            l44_in_buf <= l44_out_buf; l54_in_buf <= l54_out_buf; l64_in_buf <= l64_out_buf; l74_in_buf <= l74_out_buf; l84_in_buf <= l84_out_buf; l94_in_buf <= l94_out_buf;
                            l55_in_buf <= l55_out_buf; l65_in_buf <= l65_out_buf; l75_in_buf <= l75_out_buf; l85_in_buf <= l85_out_buf; l95_in_buf <= l95_out_buf;
                            l66_in_buf <= l66_out_buf; l76_in_buf <= l76_out_buf; l86_in_buf <= l86_out_buf; l96_in_buf <= l96_out_buf;
                            l77_in_buf <= l77_out_buf; l87_in_buf <= l87_out_buf; l97_in_buf <= l97_out_buf;
                            l88_in_buf <= l88_out_buf; l98_in_buf <= l98_out_buf;
                            l99_in_buf <= l99_out_buf;
                            state <= LOAD_5;
                        end if;

                    when LOAD_5 =>

                        state <= UPDATE_5;

                    when UPDATE_5 =>
                        u1 <= (others => '0'); u2 <= (others => '0'); u3 <= (others => '0');
                        u4 <= (others => '0'); u5 <= LQ22_SINGER; u6 <= LQ32_SINGER;
                        u7 <= (others => '0'); u8 <= (others => '0'); u9 <= (others => '0');
                        chol_start <= '1';
                        state <= WAIT_5;

                    when WAIT_5 =>
                        chol_start <= '0';
                        if chol_done = '1' then

                            l11_in_buf <= l11_out_buf; l21_in_buf <= l21_out_buf; l31_in_buf <= l31_out_buf; l41_in_buf <= l41_out_buf; l51_in_buf <= l51_out_buf; l61_in_buf <= l61_out_buf; l71_in_buf <= l71_out_buf; l81_in_buf <= l81_out_buf; l91_in_buf <= l91_out_buf;
                            l22_in_buf <= l22_out_buf; l32_in_buf <= l32_out_buf; l42_in_buf <= l42_out_buf; l52_in_buf <= l52_out_buf; l62_in_buf <= l62_out_buf; l72_in_buf <= l72_out_buf; l82_in_buf <= l82_out_buf; l92_in_buf <= l92_out_buf;
                            l33_in_buf <= l33_out_buf; l43_in_buf <= l43_out_buf; l53_in_buf <= l53_out_buf; l63_in_buf <= l63_out_buf; l73_in_buf <= l73_out_buf; l83_in_buf <= l83_out_buf; l93_in_buf <= l93_out_buf;
                            l44_in_buf <= l44_out_buf; l54_in_buf <= l54_out_buf; l64_in_buf <= l64_out_buf; l74_in_buf <= l74_out_buf; l84_in_buf <= l84_out_buf; l94_in_buf <= l94_out_buf;
                            l55_in_buf <= l55_out_buf; l65_in_buf <= l65_out_buf; l75_in_buf <= l75_out_buf; l85_in_buf <= l85_out_buf; l95_in_buf <= l95_out_buf;
                            l66_in_buf <= l66_out_buf; l76_in_buf <= l76_out_buf; l86_in_buf <= l86_out_buf; l96_in_buf <= l96_out_buf;
                            l77_in_buf <= l77_out_buf; l87_in_buf <= l87_out_buf; l97_in_buf <= l97_out_buf;
                            l88_in_buf <= l88_out_buf; l98_in_buf <= l98_out_buf;
                            l99_in_buf <= l99_out_buf;
                            state <= LOAD_6;
                        end if;

                    when LOAD_6 =>

                        state <= UPDATE_6;

                    when UPDATE_6 =>
                        u1 <= (others => '0'); u2 <= (others => '0'); u3 <= (others => '0');
                        u4 <= (others => '0'); u5 <= (others => '0'); u6 <= LQ33_SINGER;
                        u7 <= (others => '0'); u8 <= (others => '0'); u9 <= (others => '0');
                        chol_start <= '1';
                        state <= WAIT_6;

                    when WAIT_6 =>
                        chol_start <= '0';
                        if chol_done = '1' then

                            l11_in_buf <= l11_out_buf; l21_in_buf <= l21_out_buf; l31_in_buf <= l31_out_buf; l41_in_buf <= l41_out_buf; l51_in_buf <= l51_out_buf; l61_in_buf <= l61_out_buf; l71_in_buf <= l71_out_buf; l81_in_buf <= l81_out_buf; l91_in_buf <= l91_out_buf;
                            l22_in_buf <= l22_out_buf; l32_in_buf <= l32_out_buf; l42_in_buf <= l42_out_buf; l52_in_buf <= l52_out_buf; l62_in_buf <= l62_out_buf; l72_in_buf <= l72_out_buf; l82_in_buf <= l82_out_buf; l92_in_buf <= l92_out_buf;
                            l33_in_buf <= l33_out_buf; l43_in_buf <= l43_out_buf; l53_in_buf <= l53_out_buf; l63_in_buf <= l63_out_buf; l73_in_buf <= l73_out_buf; l83_in_buf <= l83_out_buf; l93_in_buf <= l93_out_buf;
                            l44_in_buf <= l44_out_buf; l54_in_buf <= l54_out_buf; l64_in_buf <= l64_out_buf; l74_in_buf <= l74_out_buf; l84_in_buf <= l84_out_buf; l94_in_buf <= l94_out_buf;
                            l55_in_buf <= l55_out_buf; l65_in_buf <= l65_out_buf; l75_in_buf <= l75_out_buf; l85_in_buf <= l85_out_buf; l95_in_buf <= l95_out_buf;
                            l66_in_buf <= l66_out_buf; l76_in_buf <= l76_out_buf; l86_in_buf <= l86_out_buf; l96_in_buf <= l96_out_buf;
                            l77_in_buf <= l77_out_buf; l87_in_buf <= l87_out_buf; l97_in_buf <= l97_out_buf;
                            l88_in_buf <= l88_out_buf; l98_in_buf <= l98_out_buf;
                            l99_in_buf <= l99_out_buf;
                            state <= LOAD_7;
                        end if;

                    when LOAD_7 =>

                        state <= UPDATE_7;

                    when UPDATE_7 =>
                        u1 <= (others => '0'); u2 <= (others => '0'); u3 <= (others => '0');
                        u4 <= (others => '0'); u5 <= (others => '0'); u6 <= (others => '0');
                        u7 <= LQ11_SINGER; u8 <= LQ21_SINGER; u9 <= LQ31_SINGER;
                        chol_start <= '1';
                        state <= WAIT_7;

                    when WAIT_7 =>
                        chol_start <= '0';
                        if chol_done = '1' then

                            l11_in_buf <= l11_out_buf; l21_in_buf <= l21_out_buf; l31_in_buf <= l31_out_buf; l41_in_buf <= l41_out_buf; l51_in_buf <= l51_out_buf; l61_in_buf <= l61_out_buf; l71_in_buf <= l71_out_buf; l81_in_buf <= l81_out_buf; l91_in_buf <= l91_out_buf;
                            l22_in_buf <= l22_out_buf; l32_in_buf <= l32_out_buf; l42_in_buf <= l42_out_buf; l52_in_buf <= l52_out_buf; l62_in_buf <= l62_out_buf; l72_in_buf <= l72_out_buf; l82_in_buf <= l82_out_buf; l92_in_buf <= l92_out_buf;
                            l33_in_buf <= l33_out_buf; l43_in_buf <= l43_out_buf; l53_in_buf <= l53_out_buf; l63_in_buf <= l63_out_buf; l73_in_buf <= l73_out_buf; l83_in_buf <= l83_out_buf; l93_in_buf <= l93_out_buf;
                            l44_in_buf <= l44_out_buf; l54_in_buf <= l54_out_buf; l64_in_buf <= l64_out_buf; l74_in_buf <= l74_out_buf; l84_in_buf <= l84_out_buf; l94_in_buf <= l94_out_buf;
                            l55_in_buf <= l55_out_buf; l65_in_buf <= l65_out_buf; l75_in_buf <= l75_out_buf; l85_in_buf <= l85_out_buf; l95_in_buf <= l95_out_buf;
                            l66_in_buf <= l66_out_buf; l76_in_buf <= l76_out_buf; l86_in_buf <= l86_out_buf; l96_in_buf <= l96_out_buf;
                            l77_in_buf <= l77_out_buf; l87_in_buf <= l87_out_buf; l97_in_buf <= l97_out_buf;
                            l88_in_buf <= l88_out_buf; l98_in_buf <= l98_out_buf;
                            l99_in_buf <= l99_out_buf;
                            state <= LOAD_8;
                        end if;

                    when LOAD_8 =>

                        state <= UPDATE_8;

                    when UPDATE_8 =>
                        u1 <= (others => '0'); u2 <= (others => '0'); u3 <= (others => '0');
                        u4 <= (others => '0'); u5 <= (others => '0'); u6 <= (others => '0');
                        u7 <= (others => '0'); u8 <= LQ22_SINGER; u9 <= LQ32_SINGER;
                        chol_start <= '1';
                        state <= WAIT_8;

                    when WAIT_8 =>
                        chol_start <= '0';
                        if chol_done = '1' then

                            l11_in_buf <= l11_out_buf; l21_in_buf <= l21_out_buf; l31_in_buf <= l31_out_buf; l41_in_buf <= l41_out_buf; l51_in_buf <= l51_out_buf; l61_in_buf <= l61_out_buf; l71_in_buf <= l71_out_buf; l81_in_buf <= l81_out_buf; l91_in_buf <= l91_out_buf;
                            l22_in_buf <= l22_out_buf; l32_in_buf <= l32_out_buf; l42_in_buf <= l42_out_buf; l52_in_buf <= l52_out_buf; l62_in_buf <= l62_out_buf; l72_in_buf <= l72_out_buf; l82_in_buf <= l82_out_buf; l92_in_buf <= l92_out_buf;
                            l33_in_buf <= l33_out_buf; l43_in_buf <= l43_out_buf; l53_in_buf <= l53_out_buf; l63_in_buf <= l63_out_buf; l73_in_buf <= l73_out_buf; l83_in_buf <= l83_out_buf; l93_in_buf <= l93_out_buf;
                            l44_in_buf <= l44_out_buf; l54_in_buf <= l54_out_buf; l64_in_buf <= l64_out_buf; l74_in_buf <= l74_out_buf; l84_in_buf <= l84_out_buf; l94_in_buf <= l94_out_buf;
                            l55_in_buf <= l55_out_buf; l65_in_buf <= l65_out_buf; l75_in_buf <= l75_out_buf; l85_in_buf <= l85_out_buf; l95_in_buf <= l95_out_buf;
                            l66_in_buf <= l66_out_buf; l76_in_buf <= l76_out_buf; l86_in_buf <= l86_out_buf; l96_in_buf <= l96_out_buf;
                            l77_in_buf <= l77_out_buf; l87_in_buf <= l87_out_buf; l97_in_buf <= l97_out_buf;
                            l88_in_buf <= l88_out_buf; l98_in_buf <= l98_out_buf;
                            l99_in_buf <= l99_out_buf;
                            state <= LOAD_9;
                        end if;

                    when LOAD_9 =>

                        state <= UPDATE_9;

                    when UPDATE_9 =>
                        u1 <= (others => '0'); u2 <= (others => '0'); u3 <= (others => '0');
                        u4 <= (others => '0'); u5 <= (others => '0'); u6 <= (others => '0');
                        u7 <= (others => '0'); u8 <= (others => '0'); u9 <= LQ33_SINGER;
                        chol_start <= '1';
                        state <= WAIT_9;

                    when WAIT_9 =>
                        chol_start <= '0';
                        if chol_done = '1' then

                            l11_in_buf <= l11_out_buf; l21_in_buf <= l21_out_buf; l31_in_buf <= l31_out_buf; l41_in_buf <= l41_out_buf; l51_in_buf <= l51_out_buf; l61_in_buf <= l61_out_buf; l71_in_buf <= l71_out_buf; l81_in_buf <= l81_out_buf; l91_in_buf <= l91_out_buf;
                            l22_in_buf <= l22_out_buf; l32_in_buf <= l32_out_buf; l42_in_buf <= l42_out_buf; l52_in_buf <= l52_out_buf; l62_in_buf <= l62_out_buf; l72_in_buf <= l72_out_buf; l82_in_buf <= l82_out_buf; l92_in_buf <= l92_out_buf;
                            l33_in_buf <= l33_out_buf; l43_in_buf <= l43_out_buf; l53_in_buf <= l53_out_buf; l63_in_buf <= l63_out_buf; l73_in_buf <= l73_out_buf; l83_in_buf <= l83_out_buf; l93_in_buf <= l93_out_buf;
                            l44_in_buf <= l44_out_buf; l54_in_buf <= l54_out_buf; l64_in_buf <= l64_out_buf; l74_in_buf <= l74_out_buf; l84_in_buf <= l84_out_buf; l94_in_buf <= l94_out_buf;
                            l55_in_buf <= l55_out_buf; l65_in_buf <= l65_out_buf; l75_in_buf <= l75_out_buf; l85_in_buf <= l85_out_buf; l95_in_buf <= l95_out_buf;
                            l66_in_buf <= l66_out_buf; l76_in_buf <= l76_out_buf; l86_in_buf <= l86_out_buf; l96_in_buf <= l96_out_buf;
                            l77_in_buf <= l77_out_buf; l87_in_buf <= l87_out_buf; l97_in_buf <= l97_out_buf;
                            l88_in_buf <= l88_out_buf; l98_in_buf <= l98_out_buf;
                            l99_in_buf <= l99_out_buf;
                            state <= FINISHED;
                        end if;

                    when FINISHED =>

                        l11_out <= l11_out_buf; l21_out <= l21_out_buf; l31_out <= l31_out_buf; l41_out <= l41_out_buf; l51_out <= l51_out_buf; l61_out <= l61_out_buf; l71_out <= l71_out_buf; l81_out <= l81_out_buf; l91_out <= l91_out_buf;
                        l22_out <= l22_out_buf; l32_out <= l32_out_buf; l42_out <= l42_out_buf; l52_out <= l52_out_buf; l62_out <= l62_out_buf; l72_out <= l72_out_buf; l82_out <= l82_out_buf; l92_out <= l92_out_buf;
                        l33_out <= l33_out_buf; l43_out <= l43_out_buf; l53_out <= l53_out_buf; l63_out <= l63_out_buf; l73_out <= l73_out_buf; l83_out <= l83_out_buf; l93_out <= l93_out_buf;
                        l44_out <= l44_out_buf; l54_out <= l54_out_buf; l64_out <= l64_out_buf; l74_out <= l74_out_buf; l84_out <= l84_out_buf; l94_out <= l94_out_buf;
                        l55_out <= l55_out_buf; l65_out <= l65_out_buf; l75_out <= l75_out_buf; l85_out <= l85_out_buf; l95_out <= l95_out_buf;
                        l66_out <= l66_out_buf; l76_out <= l76_out_buf; l86_out <= l86_out_buf; l96_out <= l96_out_buf;
                        l77_out <= l77_out_buf; l87_out <= l87_out_buf; l97_out <= l97_out_buf;
                        l88_out <= l88_out_buf; l98_out <= l98_out_buf;
                        l99_out <= l99_out_buf;
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
