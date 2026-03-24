library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cholesky_rank1_update is
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
end cholesky_rank1_update;

architecture Behavioral of cholesky_rank1_update is

    constant Q : integer := 24;

    constant ROUND_144 : signed(143 downto 0) := shift_left(to_signed(1, 144), Q - 1);

    component sqrt_cordic is
        port (
            clk : in std_logic;
            start_rt : in std_logic;
            x_in : in signed(47 downto 0);
            x_out : out signed(47 downto 0);
            done : out std_logic;
            negative_input : out std_logic
        );
    end component;

    type state_type is (IDLE, LOAD, COMPUTE_NORM, START_SQRT, WAIT_SQRT, APPLY_TO_COLUMN, FINISHED);
    signal state : state_type := IDLE;

    type matrix_9x9_type is array (0 to 8, 0 to 8) of signed(95 downto 0);
    signal L_work : matrix_9x9_type := (others => (others => (others => '0')));

    type vector_9_type is array (0 to 8) of signed(95 downto 0);
    signal u_vec : vector_9_type := (others => (others => '0'));

    signal c, s : signed(47 downto 0) := (others => '0');
    signal a_val, b_val : signed(47 downto 0) := (others => '0');
    signal r_val : signed(47 downto 0) := (others => '0');

    signal col_idx : integer range 0 to 9 := 0;

    signal sqrt_start : std_logic := '0';
    signal sqrt_in : signed(47 downto 0) := (others => '0');
    signal sqrt_out : signed(47 downto 0);
    signal sqrt_done : std_logic;

    signal norm_sq : signed(95 downto 0) := (others => '0');

begin

    sqrt_inst : sqrt_cordic
        port map (
            clk => clk,
            start_rt => sqrt_start,
            x_in => sqrt_in,
            x_out => sqrt_out,
            done => sqrt_done,
            negative_input => open
        );

    process(clk)
        variable prod_a  : signed(95 downto 0);
        variable prod_b  : signed(95 downto 0);
        variable new_a   : signed(143 downto 0);
        variable new_b   : signed(143 downto 0);
        variable wide_a  : signed(95 downto 0);
        variable wide_b  : signed(95 downto 0);
        variable wide_r  : signed(95 downto 0);
        variable a_48    : signed(47 downto 0);
        variable b_48    : signed(47 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                done <= '0';
                sqrt_start <= '0';
                col_idx <= 0;
            else
                case state is

                    when IDLE =>
                        done <= '0';
                        sqrt_start <= '0';
                        if start = '1' then

                            L_work(0, 0) <= shift_left(resize(l11_in, 96), Q);
                            L_work(1, 0) <= shift_left(resize(l21_in, 96), Q); L_work(1, 1) <= shift_left(resize(l22_in, 96), Q);
                            L_work(2, 0) <= shift_left(resize(l31_in, 96), Q); L_work(2, 1) <= shift_left(resize(l32_in, 96), Q); L_work(2, 2) <= shift_left(resize(l33_in, 96), Q);
                            L_work(3, 0) <= shift_left(resize(l41_in, 96), Q); L_work(3, 1) <= shift_left(resize(l42_in, 96), Q); L_work(3, 2) <= shift_left(resize(l43_in, 96), Q); L_work(3, 3) <= shift_left(resize(l44_in, 96), Q);
                            L_work(4, 0) <= shift_left(resize(l51_in, 96), Q); L_work(4, 1) <= shift_left(resize(l52_in, 96), Q); L_work(4, 2) <= shift_left(resize(l53_in, 96), Q); L_work(4, 3) <= shift_left(resize(l54_in, 96), Q); L_work(4, 4) <= shift_left(resize(l55_in, 96), Q);
                            L_work(5, 0) <= shift_left(resize(l61_in, 96), Q); L_work(5, 1) <= shift_left(resize(l62_in, 96), Q); L_work(5, 2) <= shift_left(resize(l63_in, 96), Q); L_work(5, 3) <= shift_left(resize(l64_in, 96), Q); L_work(5, 4) <= shift_left(resize(l65_in, 96), Q); L_work(5, 5) <= shift_left(resize(l66_in, 96), Q);
                            L_work(6, 0) <= shift_left(resize(l71_in, 96), Q); L_work(6, 1) <= shift_left(resize(l72_in, 96), Q); L_work(6, 2) <= shift_left(resize(l73_in, 96), Q); L_work(6, 3) <= shift_left(resize(l74_in, 96), Q); L_work(6, 4) <= shift_left(resize(l75_in, 96), Q); L_work(6, 5) <= shift_left(resize(l76_in, 96), Q); L_work(6, 6) <= shift_left(resize(l77_in, 96), Q);
                            L_work(7, 0) <= shift_left(resize(l81_in, 96), Q); L_work(7, 1) <= shift_left(resize(l82_in, 96), Q); L_work(7, 2) <= shift_left(resize(l83_in, 96), Q); L_work(7, 3) <= shift_left(resize(l84_in, 96), Q); L_work(7, 4) <= shift_left(resize(l85_in, 96), Q); L_work(7, 5) <= shift_left(resize(l86_in, 96), Q); L_work(7, 6) <= shift_left(resize(l87_in, 96), Q); L_work(7, 7) <= shift_left(resize(l88_in, 96), Q);
                            L_work(8, 0) <= shift_left(resize(l91_in, 96), Q); L_work(8, 1) <= shift_left(resize(l92_in, 96), Q); L_work(8, 2) <= shift_left(resize(l93_in, 96), Q); L_work(8, 3) <= shift_left(resize(l94_in, 96), Q); L_work(8, 4) <= shift_left(resize(l95_in, 96), Q); L_work(8, 5) <= shift_left(resize(l96_in, 96), Q); L_work(8, 6) <= shift_left(resize(l97_in, 96), Q); L_work(8, 7) <= shift_left(resize(l98_in, 96), Q); L_work(8, 8) <= shift_left(resize(l99_in, 96), Q);

                            u_vec(0) <= shift_left(resize(u1_in, 96), Q);
                            u_vec(1) <= shift_left(resize(u2_in, 96), Q);
                            u_vec(2) <= shift_left(resize(u3_in, 96), Q);
                            u_vec(3) <= shift_left(resize(u4_in, 96), Q);
                            u_vec(4) <= shift_left(resize(u5_in, 96), Q);
                            u_vec(5) <= shift_left(resize(u6_in, 96), Q);
                            u_vec(6) <= shift_left(resize(u7_in, 96), Q);
                            u_vec(7) <= shift_left(resize(u8_in, 96), Q);
                            u_vec(8) <= shift_left(resize(u9_in, 96), Q);

                            col_idx <= 0;
                            state <= LOAD;
                        end if;

                    when LOAD =>
                        state <= COMPUTE_NORM;

                    when COMPUTE_NORM =>

                        a_48 := resize(shift_right(L_work(col_idx, col_idx), Q), 48);
                        b_48 := resize(shift_right(u_vec(col_idx), Q), 48);

                        prod_a := a_48 * a_48;
                        prod_b := b_48 * b_48;
                        norm_sq <= shift_right(prod_a, Q) + shift_right(prod_b, Q);

                        a_val <= a_48;
                        b_val <= b_48;

                        state <= START_SQRT;

                    when START_SQRT =>
                        sqrt_in <= resize(norm_sq, 48);
                        sqrt_start <= '1';
                        state <= WAIT_SQRT;

                    when WAIT_SQRT =>
                        sqrt_start <= '0';
                        if sqrt_done = '1' then
                            r_val <= sqrt_out;

                            if sqrt_out > to_signed(1, 48) then
                                wide_a := resize(a_val, 96);
                                wide_b := resize(b_val, 96);
                                wide_r := resize(sqrt_out, 96);
                                c <= resize(shift_left(wide_a, Q) / wide_r, 48);
                                s <= resize(shift_left(wide_b, Q) / wide_r, 48);
                            else
                                c <= to_signed(2**Q, 48);
                                s <= (others => '0');
                            end if;

                            state <= APPLY_TO_COLUMN;
                        end if;

                    when APPLY_TO_COLUMN =>

                        L_work(col_idx, col_idx) <= shift_left(resize(r_val, 96), Q);

                        for i in 0 to 8 loop
                            if i > col_idx then

                                new_a := c * L_work(i, col_idx) + s * u_vec(i);

                                new_b := c * u_vec(i) - s * L_work(i, col_idx);

                                L_work(i, col_idx) <= resize(shift_right(new_a + ROUND_144, Q), 96);
                                u_vec(i) <= resize(shift_right(new_b + ROUND_144, Q), 96);
                            end if;
                        end loop;

                        if col_idx < 8 then
                            col_idx <= col_idx + 1;
                            state <= COMPUTE_NORM;
                        else
                            state <= FINISHED;
                        end if;

                    when FINISHED =>

                        l11_out <= resize(shift_right(L_work(0, 0), Q), 48);
                        l21_out <= resize(shift_right(L_work(1, 0), Q), 48); l22_out <= resize(shift_right(L_work(1, 1), Q), 48);
                        l31_out <= resize(shift_right(L_work(2, 0), Q), 48); l32_out <= resize(shift_right(L_work(2, 1), Q), 48); l33_out <= resize(shift_right(L_work(2, 2), Q), 48);
                        l41_out <= resize(shift_right(L_work(3, 0), Q), 48); l42_out <= resize(shift_right(L_work(3, 1), Q), 48); l43_out <= resize(shift_right(L_work(3, 2), Q), 48); l44_out <= resize(shift_right(L_work(3, 3), Q), 48);
                        l51_out <= resize(shift_right(L_work(4, 0), Q), 48); l52_out <= resize(shift_right(L_work(4, 1), Q), 48); l53_out <= resize(shift_right(L_work(4, 2), Q), 48); l54_out <= resize(shift_right(L_work(4, 3), Q), 48); l55_out <= resize(shift_right(L_work(4, 4), Q), 48);
                        l61_out <= resize(shift_right(L_work(5, 0), Q), 48); l62_out <= resize(shift_right(L_work(5, 1), Q), 48); l63_out <= resize(shift_right(L_work(5, 2), Q), 48); l64_out <= resize(shift_right(L_work(5, 3), Q), 48); l65_out <= resize(shift_right(L_work(5, 4), Q), 48); l66_out <= resize(shift_right(L_work(5, 5), Q), 48);
                        l71_out <= resize(shift_right(L_work(6, 0), Q), 48); l72_out <= resize(shift_right(L_work(6, 1), Q), 48); l73_out <= resize(shift_right(L_work(6, 2), Q), 48); l74_out <= resize(shift_right(L_work(6, 3), Q), 48); l75_out <= resize(shift_right(L_work(6, 4), Q), 48); l76_out <= resize(shift_right(L_work(6, 5), Q), 48); l77_out <= resize(shift_right(L_work(6, 6), Q), 48);
                        l81_out <= resize(shift_right(L_work(7, 0), Q), 48); l82_out <= resize(shift_right(L_work(7, 1), Q), 48); l83_out <= resize(shift_right(L_work(7, 2), Q), 48); l84_out <= resize(shift_right(L_work(7, 3), Q), 48); l85_out <= resize(shift_right(L_work(7, 4), Q), 48); l86_out <= resize(shift_right(L_work(7, 5), Q), 48); l87_out <= resize(shift_right(L_work(7, 6), Q), 48); l88_out <= resize(shift_right(L_work(7, 7), Q), 48);
                        l91_out <= resize(shift_right(L_work(8, 0), Q), 48); l92_out <= resize(shift_right(L_work(8, 1), Q), 48); l93_out <= resize(shift_right(L_work(8, 2), Q), 48); l94_out <= resize(shift_right(L_work(8, 3), Q), 48); l95_out <= resize(shift_right(L_work(8, 4), Q), 48); l96_out <= resize(shift_right(L_work(8, 5), Q), 48); l97_out <= resize(shift_right(L_work(8, 6), Q), 48); l98_out <= resize(shift_right(L_work(8, 7), Q), 48); l99_out <= resize(shift_right(L_work(8, 8), Q), 48);

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
