library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cholesky_rank1_downdate is
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

        w1_in, w2_in, w3_in, w4_in, w5_in, w6_in, w7_in, w8_in, w9_in : in signed(47 downto 0);

        l11_out, l21_out, l31_out, l41_out, l51_out, l61_out, l71_out, l81_out, l91_out : buffer signed(47 downto 0);
        l22_out, l32_out, l42_out, l52_out, l62_out, l72_out, l82_out, l92_out : buffer signed(47 downto 0);
        l33_out, l43_out, l53_out, l63_out, l73_out, l83_out, l93_out : buffer signed(47 downto 0);
        l44_out, l54_out, l64_out, l74_out, l84_out, l94_out : buffer signed(47 downto 0);
        l55_out, l65_out, l75_out, l85_out, l95_out : buffer signed(47 downto 0);
        l66_out, l76_out, l86_out, l96_out : buffer signed(47 downto 0);
        l77_out, l87_out, l97_out : buffer signed(47 downto 0);
        l88_out, l98_out : buffer signed(47 downto 0);
        l99_out : buffer signed(47 downto 0);

        done : buffer std_logic;

        error : buffer std_logic
    );
end cholesky_rank1_downdate;

architecture Behavioral of cholesky_rank1_downdate is

    constant Q : integer := 24;
    constant EPSILON : signed(47 downto 0) := to_signed(168, 48);

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

    type state_type is (IDLE, LOAD, COMPUTE_DIFF, START_SQRT, WAIT_SQRT, APPLY_TO_COLUMN, FINISHED);
    signal state : state_type := IDLE;

    type matrix_9x9_type is array (0 to 8, 0 to 8) of signed(95 downto 0);
    signal L_work : matrix_9x9_type := (others => (others => (others => '0')));

    type matrix_9x9_48_type is array (0 to 8, 0 to 8) of signed(47 downto 0);
    signal L_input_backup : matrix_9x9_48_type := (others => (others => (others => '0')));

    type vector_9_type is array (0 to 8) of signed(95 downto 0);
    signal w_vec : vector_9_type := (others => (others => '0'));

    signal c, s : signed(47 downto 0) := (others => '0');
    signal a_val, b_val : signed(47 downto 0) := (others => '0');
    signal r_val : signed(47 downto 0) := (others => '0');

    signal col_idx : integer range 0 to 9 := 0;

    signal sqrt_start : std_logic := '0';
    signal sqrt_in : signed(47 downto 0) := (others => '0');
    signal sqrt_out : signed(47 downto 0);
    signal sqrt_done : std_logic;

    signal diff_sq : signed(95 downto 0) := (others => '0');
    signal error_flag : std_logic := '0';

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
        variable temp_val  : signed(95 downto 0);
        variable temp_prod : signed(95 downto 0);
        variable new_a     : signed(95 downto 0);
        variable new_b     : signed(95 downto 0);
        variable new_L     : signed(143 downto 0);
        variable new_w     : signed(143 downto 0);
        variable wide_a    : signed(95 downto 0);
        variable wide_b    : signed(95 downto 0);
        variable wide_r    : signed(95 downto 0);
        variable a_48      : signed(47 downto 0);
        variable b_48      : signed(47 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                done <= '0';
                error <= '0';
                sqrt_start <= '0';
                col_idx <= 0;
                error_flag <= '0';
            else
                case state is

                    when IDLE =>
                        done <= '0';
                        error <= '0';
                        error_flag <= '0';
                        sqrt_start <= '0';
                        if start = '1' then

                            L_work(0, 0) <= shift_left(resize(l11_in, 96), Q); L_input_backup(0, 0) <= l11_in;
                            L_work(1, 0) <= shift_left(resize(l21_in, 96), Q); L_work(1, 1) <= shift_left(resize(l22_in, 96), Q);
                            L_input_backup(1, 0) <= l21_in; L_input_backup(1, 1) <= l22_in;
                            L_work(2, 0) <= shift_left(resize(l31_in, 96), Q); L_work(2, 1) <= shift_left(resize(l32_in, 96), Q); L_work(2, 2) <= shift_left(resize(l33_in, 96), Q);
                            L_input_backup(2, 0) <= l31_in; L_input_backup(2, 1) <= l32_in; L_input_backup(2, 2) <= l33_in;
                            L_work(3, 0) <= shift_left(resize(l41_in, 96), Q); L_work(3, 1) <= shift_left(resize(l42_in, 96), Q); L_work(3, 2) <= shift_left(resize(l43_in, 96), Q); L_work(3, 3) <= shift_left(resize(l44_in, 96), Q);
                            L_input_backup(3, 0) <= l41_in; L_input_backup(3, 1) <= l42_in; L_input_backup(3, 2) <= l43_in; L_input_backup(3, 3) <= l44_in;
                            L_work(4, 0) <= shift_left(resize(l51_in, 96), Q); L_work(4, 1) <= shift_left(resize(l52_in, 96), Q); L_work(4, 2) <= shift_left(resize(l53_in, 96), Q); L_work(4, 3) <= shift_left(resize(l54_in, 96), Q); L_work(4, 4) <= shift_left(resize(l55_in, 96), Q);
                            L_input_backup(4, 0) <= l51_in; L_input_backup(4, 1) <= l52_in; L_input_backup(4, 2) <= l53_in; L_input_backup(4, 3) <= l54_in; L_input_backup(4, 4) <= l55_in;
                            L_work(5, 0) <= shift_left(resize(l61_in, 96), Q); L_work(5, 1) <= shift_left(resize(l62_in, 96), Q); L_work(5, 2) <= shift_left(resize(l63_in, 96), Q); L_work(5, 3) <= shift_left(resize(l64_in, 96), Q); L_work(5, 4) <= shift_left(resize(l65_in, 96), Q); L_work(5, 5) <= shift_left(resize(l66_in, 96), Q);
                            L_input_backup(5, 0) <= l61_in; L_input_backup(5, 1) <= l62_in; L_input_backup(5, 2) <= l63_in; L_input_backup(5, 3) <= l64_in; L_input_backup(5, 4) <= l65_in; L_input_backup(5, 5) <= l66_in;
                            L_work(6, 0) <= shift_left(resize(l71_in, 96), Q); L_work(6, 1) <= shift_left(resize(l72_in, 96), Q); L_work(6, 2) <= shift_left(resize(l73_in, 96), Q); L_work(6, 3) <= shift_left(resize(l74_in, 96), Q); L_work(6, 4) <= shift_left(resize(l75_in, 96), Q); L_work(6, 5) <= shift_left(resize(l76_in, 96), Q); L_work(6, 6) <= shift_left(resize(l77_in, 96), Q);
                            L_input_backup(6, 0) <= l71_in; L_input_backup(6, 1) <= l72_in; L_input_backup(6, 2) <= l73_in; L_input_backup(6, 3) <= l74_in; L_input_backup(6, 4) <= l75_in; L_input_backup(6, 5) <= l76_in; L_input_backup(6, 6) <= l77_in;
                            L_work(7, 0) <= shift_left(resize(l81_in, 96), Q); L_work(7, 1) <= shift_left(resize(l82_in, 96), Q); L_work(7, 2) <= shift_left(resize(l83_in, 96), Q); L_work(7, 3) <= shift_left(resize(l84_in, 96), Q); L_work(7, 4) <= shift_left(resize(l85_in, 96), Q); L_work(7, 5) <= shift_left(resize(l86_in, 96), Q); L_work(7, 6) <= shift_left(resize(l87_in, 96), Q); L_work(7, 7) <= shift_left(resize(l88_in, 96), Q);
                            L_input_backup(7, 0) <= l81_in; L_input_backup(7, 1) <= l82_in; L_input_backup(7, 2) <= l83_in; L_input_backup(7, 3) <= l84_in; L_input_backup(7, 4) <= l85_in; L_input_backup(7, 5) <= l86_in; L_input_backup(7, 6) <= l87_in; L_input_backup(7, 7) <= l88_in;
                            L_work(8, 0) <= shift_left(resize(l91_in, 96), Q); L_work(8, 1) <= shift_left(resize(l92_in, 96), Q); L_work(8, 2) <= shift_left(resize(l93_in, 96), Q); L_work(8, 3) <= shift_left(resize(l94_in, 96), Q); L_work(8, 4) <= shift_left(resize(l95_in, 96), Q); L_work(8, 5) <= shift_left(resize(l96_in, 96), Q); L_work(8, 6) <= shift_left(resize(l97_in, 96), Q); L_work(8, 7) <= shift_left(resize(l98_in, 96), Q); L_work(8, 8) <= shift_left(resize(l99_in, 96), Q);
                            L_input_backup(8, 0) <= l91_in; L_input_backup(8, 1) <= l92_in; L_input_backup(8, 2) <= l93_in; L_input_backup(8, 3) <= l94_in; L_input_backup(8, 4) <= l95_in; L_input_backup(8, 5) <= l96_in; L_input_backup(8, 6) <= l97_in; L_input_backup(8, 7) <= l98_in; L_input_backup(8, 8) <= l99_in;

                            w_vec(0) <= shift_left(resize(w1_in, 96), Q);
                            w_vec(1) <= shift_left(resize(w2_in, 96), Q);
                            w_vec(2) <= shift_left(resize(w3_in, 96), Q);
                            w_vec(3) <= shift_left(resize(w4_in, 96), Q);
                            w_vec(4) <= shift_left(resize(w5_in, 96), Q);
                            w_vec(5) <= shift_left(resize(w6_in, 96), Q);
                            w_vec(6) <= shift_left(resize(w7_in, 96), Q);
                            w_vec(7) <= shift_left(resize(w8_in, 96), Q);
                            w_vec(8) <= shift_left(resize(w9_in, 96), Q);

                            col_idx <= 0;
                            state <= LOAD;
                        end if;

                    when LOAD =>
                        state <= COMPUTE_DIFF;

                    when COMPUTE_DIFF =>

                        a_48 := resize(shift_right(L_work(col_idx, col_idx), Q), 48);
                        b_48 := resize(shift_right(w_vec(col_idx), Q), 48);

                        a_val <= a_48;
                        b_val <= b_48;

                        temp_val := a_48 * a_48;
                        temp_prod := b_48 * b_48;

                        if temp_val < temp_prod then
                            error_flag <= '1';
                            state <= FINISHED;
                        else
                            new_a := temp_val - temp_prod;
                            new_b := signed(shift_right(unsigned(new_a), Q));
                            diff_sq <= new_a;
                            sqrt_in <= new_b(47 downto 0);

                            if new_b(47 downto 0) <= EPSILON then
                                error_flag <= '1';
                                state <= FINISHED;
                            else
                                state <= START_SQRT;
                            end if;
                        end if;

                    when START_SQRT =>
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

                                new_L := (c * L_work(i, col_idx)) - (s * w_vec(i));
                                L_work(i, col_idx) <= resize(shift_right(new_L + ROUND_144, Q), 96);

                                new_w := (c * w_vec(i)) - (s * L_work(i, col_idx));
                                w_vec(i) <= resize(shift_right(new_w + ROUND_144, Q), 96);
                            end if;
                        end loop;

                        if col_idx >= 8 then
                            state <= FINISHED;
                        else
                            col_idx <= col_idx + 1;
                            state <= COMPUTE_DIFF;
                        end if;

                    when FINISHED =>
                        if error_flag = '1' then

                            l11_out <= L_input_backup(0, 0);
                            l21_out <= L_input_backup(1, 0); l22_out <= L_input_backup(1, 1);
                            l31_out <= L_input_backup(2, 0); l32_out <= L_input_backup(2, 1); l33_out <= L_input_backup(2, 2);
                            l41_out <= L_input_backup(3, 0); l42_out <= L_input_backup(3, 1); l43_out <= L_input_backup(3, 2); l44_out <= L_input_backup(3, 3);
                            l51_out <= L_input_backup(4, 0); l52_out <= L_input_backup(4, 1); l53_out <= L_input_backup(4, 2); l54_out <= L_input_backup(4, 3); l55_out <= L_input_backup(4, 4);
                            l61_out <= L_input_backup(5, 0); l62_out <= L_input_backup(5, 1); l63_out <= L_input_backup(5, 2); l64_out <= L_input_backup(5, 3); l65_out <= L_input_backup(5, 4); l66_out <= L_input_backup(5, 5);
                            l71_out <= L_input_backup(6, 0); l72_out <= L_input_backup(6, 1); l73_out <= L_input_backup(6, 2); l74_out <= L_input_backup(6, 3); l75_out <= L_input_backup(6, 4); l76_out <= L_input_backup(6, 5); l77_out <= L_input_backup(6, 6);
                            l81_out <= L_input_backup(7, 0); l82_out <= L_input_backup(7, 1); l83_out <= L_input_backup(7, 2); l84_out <= L_input_backup(7, 3); l85_out <= L_input_backup(7, 4); l86_out <= L_input_backup(7, 5); l87_out <= L_input_backup(7, 6); l88_out <= L_input_backup(7, 7);
                            l91_out <= L_input_backup(8, 0); l92_out <= L_input_backup(8, 1); l93_out <= L_input_backup(8, 2); l94_out <= L_input_backup(8, 3); l95_out <= L_input_backup(8, 4); l96_out <= L_input_backup(8, 5); l97_out <= L_input_backup(8, 6); l98_out <= L_input_backup(8, 7); l99_out <= L_input_backup(8, 8);
                        else

                            l11_out <= resize(shift_right(L_work(0, 0), Q), 48);
                            l21_out <= resize(shift_right(L_work(1, 0), Q), 48); l22_out <= resize(shift_right(L_work(1, 1), Q), 48);
                            l31_out <= resize(shift_right(L_work(2, 0), Q), 48); l32_out <= resize(shift_right(L_work(2, 1), Q), 48); l33_out <= resize(shift_right(L_work(2, 2), Q), 48);
                            l41_out <= resize(shift_right(L_work(3, 0), Q), 48); l42_out <= resize(shift_right(L_work(3, 1), Q), 48); l43_out <= resize(shift_right(L_work(3, 2), Q), 48); l44_out <= resize(shift_right(L_work(3, 3), Q), 48);
                            l51_out <= resize(shift_right(L_work(4, 0), Q), 48); l52_out <= resize(shift_right(L_work(4, 1), Q), 48); l53_out <= resize(shift_right(L_work(4, 2), Q), 48); l54_out <= resize(shift_right(L_work(4, 3), Q), 48); l55_out <= resize(shift_right(L_work(4, 4), Q), 48);
                            l61_out <= resize(shift_right(L_work(5, 0), Q), 48); l62_out <= resize(shift_right(L_work(5, 1), Q), 48); l63_out <= resize(shift_right(L_work(5, 2), Q), 48); l64_out <= resize(shift_right(L_work(5, 3), Q), 48); l65_out <= resize(shift_right(L_work(5, 4), Q), 48); l66_out <= resize(shift_right(L_work(5, 5), Q), 48);
                            l71_out <= resize(shift_right(L_work(6, 0), Q), 48); l72_out <= resize(shift_right(L_work(6, 1), Q), 48); l73_out <= resize(shift_right(L_work(6, 2), Q), 48); l74_out <= resize(shift_right(L_work(6, 3), Q), 48); l75_out <= resize(shift_right(L_work(6, 4), Q), 48); l76_out <= resize(shift_right(L_work(6, 5), Q), 48); l77_out <= resize(shift_right(L_work(6, 6), Q), 48);
                            l81_out <= resize(shift_right(L_work(7, 0), Q), 48); l82_out <= resize(shift_right(L_work(7, 1), Q), 48); l83_out <= resize(shift_right(L_work(7, 2), Q), 48); l84_out <= resize(shift_right(L_work(7, 3), Q), 48); l85_out <= resize(shift_right(L_work(7, 4), Q), 48); l86_out <= resize(shift_right(L_work(7, 5), Q), 48); l87_out <= resize(shift_right(L_work(7, 6), Q), 48); l88_out <= resize(shift_right(L_work(7, 7), Q), 48);
                            l91_out <= resize(shift_right(L_work(8, 0), Q), 48); l92_out <= resize(shift_right(L_work(8, 1), Q), 48); l93_out <= resize(shift_right(L_work(8, 2), Q), 48); l94_out <= resize(shift_right(L_work(8, 3), Q), 48); l95_out <= resize(shift_right(L_work(8, 4), Q), 48); l96_out <= resize(shift_right(L_work(8, 5), Q), 48); l97_out <= resize(shift_right(L_work(8, 6), Q), 48); l98_out <= resize(shift_right(L_work(8, 7), Q), 48); l99_out <= resize(shift_right(L_work(8, 8), Q), 48);
                        end if;

                        done <= '1';
                        error <= error_flag;
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
