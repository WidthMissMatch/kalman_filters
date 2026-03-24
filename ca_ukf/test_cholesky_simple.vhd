library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity test_cholesky_simple is
end test_cholesky_simple;

architecture Behavioral of test_cholesky_simple is

    component cholesky_9x9 is
        port (
            clk   : in  std_logic;
            start : in  std_logic;

            p11, p12, p13, p14, p15, p16, p17, p18, p19 : in signed(47 downto 0);
            p22, p23, p24, p25, p26, p27, p28, p29 : in signed(47 downto 0);
            p33, p34, p35, p36, p37, p38, p39 : in signed(47 downto 0);
            p44, p45, p46, p47, p48, p49 : in signed(47 downto 0);
            p55, p56, p57, p58, p59 : in signed(47 downto 0);
            p66, p67, p68, p69 : in signed(47 downto 0);
            p77, p78, p79 : in signed(47 downto 0);
            p88, p89 : in signed(47 downto 0);
            p99 : in signed(47 downto 0);

            l11, l21, l22, l31, l32, l33, l41, l42, l43, l44 : out signed(47 downto 0);
            l51, l52, l53, l54, l55, l61, l62, l63, l64, l65, l66 : out signed(47 downto 0);
            l71, l72, l73, l74, l75, l76, l77 : out signed(47 downto 0);
            l81, l82, l83, l84, l85, l86, l87, l88 : out signed(47 downto 0);
            l91, l92, l93, l94, l95, l96, l97, l98, l99 : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal start : std_logic := '0';
    signal done : std_logic;

    constant P_DIAG : signed(47 downto 0) := to_signed(150994944, 48);
    constant P_ZERO : signed(47 downto 0) := to_signed(0, 48);

    signal p11, p22, p33, p44, p55, p66, p77, p88, p99 : signed(47 downto 0);
    signal p12, p13, p14, p15, p16, p17, p18, p19 : signed(47 downto 0);
    signal p23, p24, p25, p26, p27, p28, p29 : signed(47 downto 0);
    signal p34, p35, p36, p37, p38, p39 : signed(47 downto 0);
    signal p45, p46, p47, p48, p49 : signed(47 downto 0);
    signal p56, p57, p58, p59 : signed(47 downto 0);
    signal p67, p68, p69 : signed(47 downto 0);
    signal p78, p79 : signed(47 downto 0);
    signal p89 : signed(47 downto 0);

    signal l11, l22, l33, l44, l55, l66, l77, l88, l99 : signed(47 downto 0);
    signal l21, l31, l32, l41, l42, l43, l51, l52, l53, l54 : signed(47 downto 0);
    signal l61, l62, l63, l64, l65, l71, l72, l73, l74, l75, l76 : signed(47 downto 0);
    signal l81, l82, l83, l84, l85, l86, l87, l91, l92, l93, l94, l95, l96, l97, l98 : signed(47 downto 0);

begin

    clk <= not clk after 5 ns;

    uut: cholesky_9x9 port map (
        clk => clk, start => start,
        p11 => p11, p12 => p12, p13 => p13, p14 => p14, p15 => p15, p16 => p16, p17 => p17, p18 => p18, p19 => p19,
        p22 => p22, p23 => p23, p24 => p24, p25 => p25, p26 => p26, p27 => p27, p28 => p28, p29 => p29,
        p33 => p33, p34 => p34, p35 => p35, p36 => p36, p37 => p37, p38 => p38, p39 => p39,
        p44 => p44, p45 => p45, p46 => p46, p47 => p47, p48 => p48, p49 => p49,
        p55 => p55, p56 => p56, p57 => p57, p58 => p58, p59 => p59,
        p66 => p66, p67 => p67, p68 => p68, p69 => p69,
        p77 => p77, p78 => p78, p79 => p79,
        p88 => p88, p89 => p89,
        p99 => p99,
        l11 => l11, l21 => l21, l22 => l22, l31 => l31, l32 => l32, l33 => l33,
        l41 => l41, l42 => l42, l43 => l43, l44 => l44,
        l51 => l51, l52 => l52, l53 => l53, l54 => l54, l55 => l55,
        l61 => l61, l62 => l62, l63 => l63, l64 => l64, l65 => l65, l66 => l66,
        l71 => l71, l72 => l72, l73 => l73, l74 => l74, l75 => l75, l76 => l76, l77 => l77,
        l81 => l81, l82 => l82, l83 => l83, l84 => l84, l85 => l85, l86 => l86, l87 => l87, l88 => l88,
        l91 => l91, l92 => l92, l93 => l93, l94 => l94, l95 => l95, l96 => l96, l97 => l97, l98 => l98, l99 => l99,
        done => done
    );

    process
    begin

        p11 <= P_DIAG; p22 <= P_DIAG; p33 <= P_DIAG; p44 <= P_DIAG; p55 <= P_DIAG;
        p66 <= P_DIAG; p77 <= P_DIAG; p88 <= P_DIAG; p99 <= P_DIAG;

        p12 <= P_ZERO; p13 <= P_ZERO; p14 <= P_ZERO; p15 <= P_ZERO; p16 <= P_ZERO; p17 <= P_ZERO; p18 <= P_ZERO; p19 <= P_ZERO;
        p23 <= P_ZERO; p24 <= P_ZERO; p25 <= P_ZERO; p26 <= P_ZERO; p27 <= P_ZERO; p28 <= P_ZERO; p29 <= P_ZERO;
        p34 <= P_ZERO; p35 <= P_ZERO; p36 <= P_ZERO; p37 <= P_ZERO; p38 <= P_ZERO; p39 <= P_ZERO;
        p45 <= P_ZERO; p46 <= P_ZERO; p47 <= P_ZERO; p48 <= P_ZERO; p49 <= P_ZERO;
        p56 <= P_ZERO; p57 <= P_ZERO; p58 <= P_ZERO; p59 <= P_ZERO;
        p67 <= P_ZERO; p68 <= P_ZERO; p69 <= P_ZERO;
        p78 <= P_ZERO; p79 <= P_ZERO;
        p89 <= P_ZERO;

        wait for 20 ns;
        start <= '1';
        wait for 10 ns;
        start <= '0';

        wait until done = '1';
        wait for 10 ns;

        report "========================================";
        report "Cholesky Test Results:";
        report "Input: P = 9.0 * I (identity scaled by 9.0)";
        report "Expected: L = 3.0 * I (identity scaled by 3.0)";
        report "========================================";
        report "L diagonal elements (should all be 3.0 = 50331648):";
        report "  l11 = " & integer'image(to_integer(l11)) & " (expected: 50331648)";
        report "  l22 = " & integer'image(to_integer(l22)) & " (expected: 50331648)";
        report "  l33 = " & integer'image(to_integer(l33)) & " (expected: 50331648)";
        report "  l44 = " & integer'image(to_integer(l44)) & " (expected: 50331648)";
        report "  l55 = " & integer'image(to_integer(l55)) & " (expected: 50331648)";
        report "  l66 = " & integer'image(to_integer(l66)) & " (expected: 50331648)";
        report "  l77 = " & integer'image(to_integer(l77)) & " (expected: 50331648)";
        report "  l88 = " & integer'image(to_integer(l88)) & " (expected: 50331648)";
        report "  l99 = " & integer'image(to_integer(l99)) & " (expected: 50331648)";
        report "========================================";
        report "L off-diagonal sample (should all be 0):";
        report "  l21 = " & integer'image(to_integer(l21)) & " (expected: 0)";
        report "  l31 = " & integer'image(to_integer(l31)) & " (expected: 0)";
        report "  l32 = " & integer'image(to_integer(l32)) & " (expected: 0)";
        report "========================================";
        report "TEST COMPLETE";
        report "========================================";

        wait;
    end process;

end Behavioral;
