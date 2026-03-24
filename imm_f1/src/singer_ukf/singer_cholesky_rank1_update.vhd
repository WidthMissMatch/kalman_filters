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

    type state_type is (IDLE, LOAD, LOAD_COL, COMPUTE_NORM, WAIT_SQRT, APPLY_ROTATION, NEXT_ROW, STORE_COL, FINISHED);
    signal state : state_type := IDLE;

    type matrix_9x9_type is array (0 to 8, 0 to 8) of signed(47 downto 0);
    signal L_work : matrix_9x9_type := (others => (others => (others => '0')));

    type vector_9_type is array (0 to 8) of signed(47 downto 0);
    signal u_vec : vector_9_type := (others => (others => '0'));

    signal c, s : signed(47 downto 0) := (others => '0');
    signal a_val, b_val : signed(47 downto 0) := (others => '0');
    signal r_val : signed(47 downto 0) := (others => '0');

    signal col_idx : integer range 0 to 8 := 0;
    signal row_idx : integer range 0 to 8 := 0;

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
        variable temp_prod : signed(95 downto 0);
        variable temp_val : signed(95 downto 0);
        variable new_a, new_b : signed(95 downto 0);
        variable i : integer range 0 to 8;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                done <= '0';
                sqrt_start <= '0';
                col_idx <= 0;
                row_idx <= 0;
            else
                case state is

                    when IDLE =>
                        done <= '0';
                        sqrt_start <= '0';
                        if start = '1' then
                            report "CHOL_UPDATE: Starting rank-1 update" &
                                   " l11_in=" & integer'image(to_integer(l11_in)) &
                                   " l22_in=" & integer'image(to_integer(l22_in)) &
                                   " u1_in=" & integer'image(to_integer(u1_in)) &
                                   " u2_in=" & integer'image(to_integer(u2_in));

                            L_work(0, 0) <= l11_in;
                            L_work(1, 0) <= l21_in; L_work(1, 1) <= l22_in;
                            L_work(2, 0) <= l31_in; L_work(2, 1) <= l32_in; L_work(2, 2) <= l33_in;
                            L_work(3, 0) <= l41_in; L_work(3, 1) <= l42_in; L_work(3, 2) <= l43_in; L_work(3, 3) <= l44_in;
                            L_work(4, 0) <= l51_in; L_work(4, 1) <= l52_in; L_work(4, 2) <= l53_in; L_work(4, 3) <= l54_in; L_work(4, 4) <= l55_in;
                            L_work(5, 0) <= l61_in; L_work(5, 1) <= l62_in; L_work(5, 2) <= l63_in; L_work(5, 3) <= l64_in; L_work(5, 4) <= l65_in; L_work(5, 5) <= l66_in;
                            L_work(6, 0) <= l71_in; L_work(6, 1) <= l72_in; L_work(6, 2) <= l73_in; L_work(6, 3) <= l74_in; L_work(6, 4) <= l75_in; L_work(6, 5) <= l76_in; L_work(6, 6) <= l77_in;
                            L_work(7, 0) <= l81_in; L_work(7, 1) <= l82_in; L_work(7, 2) <= l83_in; L_work(7, 3) <= l84_in; L_work(7, 4) <= l85_in; L_work(7, 5) <= l86_in; L_work(7, 6) <= l87_in; L_work(7, 7) <= l88_in;
                            L_work(8, 0) <= l91_in; L_work(8, 1) <= l92_in; L_work(8, 2) <= l93_in; L_work(8, 3) <= l94_in; L_work(8, 4) <= l95_in; L_work(8, 5) <= l96_in; L_work(8, 6) <= l97_in; L_work(8, 7) <= l98_in; L_work(8, 8) <= l99_in;

                            u_vec(0) <= u1_in;
                            u_vec(1) <= u2_in;
                            u_vec(2) <= u3_in;
                            u_vec(3) <= u4_in;
                            u_vec(4) <= u5_in;
                            u_vec(5) <= u6_in;
                            u_vec(6) <= u7_in;
                            u_vec(7) <= u8_in;
                            u_vec(8) <= u9_in;

                            col_idx <= 0;
                            row_idx <= 8;
                            state <= LOAD;
                        end if;

                    when LOAD =>

                        report "CHOL_UPDATE: Buffers loaded" &
                               " L_work(0,0)=" & integer'image(to_integer(L_work(0, 0))) &
                               " L_work(1,1)=" & integer'image(to_integer(L_work(1, 1))) &
                               " u_vec(0)=" & integer'image(to_integer(u_vec(0))) &
                               " u_vec(1)=" & integer'image(to_integer(u_vec(1)));
                        state <= LOAD_COL;

                    when LOAD_COL =>

                        if row_idx > 0 then
                            if col_idx <= row_idx - 1 then

                                state <= COMPUTE_NORM;
                            else

                                row_idx <= row_idx - 1;
                                if row_idx = 1 then

                                    state <= STORE_COL;
                                end if;
                            end if;
                        else

                            state <= STORE_COL;
                        end if;

                    when COMPUTE_NORM =>

                        a_val <= L_work(row_idx - 1, col_idx);
                        b_val <= u_vec(row_idx);

                        temp_prod := L_work(row_idx - 1, col_idx) * L_work(row_idx - 1, col_idx);
                        temp_val := shift_right(temp_prod, Q);
                        temp_prod := u_vec(row_idx) * u_vec(row_idx);
                        norm_sq <= temp_val + shift_right(temp_prod, Q);

                        report "CHOL_UPDATE: COMPUTE_NORM col=" & integer'image(col_idx) &
                               " row=" & integer'image(row_idx) &
                               " L(" & integer'image(row_idx-1) & "," & integer'image(col_idx) & ")=" &
                               integer'image(to_integer(L_work(row_idx - 1, col_idx))) &
                               " u(" & integer'image(row_idx) & ")=" &
                               integer'image(to_integer(u_vec(row_idx))) &
                               " norm_sq=" & integer'image(to_integer(resize(temp_val + shift_right(temp_prod, Q), 48)));

                        sqrt_in <= resize(norm_sq, 48);
                        sqrt_start <= '1';
                        state <= WAIT_SQRT;

                    when WAIT_SQRT =>
                        sqrt_start <= '0';
                        if sqrt_done = '1' then
                            r_val <= sqrt_out;

                            if sqrt_out > to_signed(1, 48) then

                                c <= resize(shift_left(a_val, Q) / sqrt_out, 48);

                                s <= resize(shift_left(b_val, Q) / sqrt_out, 48);
                            else

                                c <= to_signed(2**Q, 48);
                                s <= (others => '0');
                            end if;

                            state <= APPLY_ROTATION;
                        end if;

                    when APPLY_ROTATION =>

                        L_work(row_idx - 1, col_idx) <= r_val;

                        temp_prod := (s * a_val);
                        temp_val := shift_right(temp_prod, Q);
                        temp_prod := (c * b_val);
                        new_b := shift_right(temp_prod, Q) - temp_val;
                        u_vec(row_idx) <= resize(new_b, 48);

                        state <= NEXT_ROW;

                    when NEXT_ROW =>

                        row_idx <= row_idx - 1;
                        if row_idx = 1 then

                            state <= STORE_COL;
                        else
                            state <= LOAD_COL;
                        end if;

                    when STORE_COL =>

                        col_idx <= col_idx + 1;
                        if col_idx >= 8 then

                            state <= FINISHED;
                        else

                            row_idx <= 8;
                            state <= LOAD_COL;
                        end if;

                    when FINISHED =>

                        l11_out <= L_work(0, 0);
                        l21_out <= L_work(1, 0); l22_out <= L_work(1, 1);
                        l31_out <= L_work(2, 0); l32_out <= L_work(2, 1); l33_out <= L_work(2, 2);
                        l41_out <= L_work(3, 0); l42_out <= L_work(3, 1); l43_out <= L_work(3, 2); l44_out <= L_work(3, 3);
                        l51_out <= L_work(4, 0); l52_out <= L_work(4, 1); l53_out <= L_work(4, 2); l54_out <= L_work(4, 3); l55_out <= L_work(4, 4);
                        l61_out <= L_work(5, 0); l62_out <= L_work(5, 1); l63_out <= L_work(5, 2); l64_out <= L_work(5, 3); l65_out <= L_work(5, 4); l66_out <= L_work(5, 5);
                        l71_out <= L_work(6, 0); l72_out <= L_work(6, 1); l73_out <= L_work(6, 2); l74_out <= L_work(6, 3); l75_out <= L_work(6, 4); l76_out <= L_work(6, 5); l77_out <= L_work(6, 6);
                        l81_out <= L_work(7, 0); l82_out <= L_work(7, 1); l83_out <= L_work(7, 2); l84_out <= L_work(7, 3); l85_out <= L_work(7, 4); l86_out <= L_work(7, 5); l87_out <= L_work(7, 6); l88_out <= L_work(7, 7);
                        l91_out <= L_work(8, 0); l92_out <= L_work(8, 1); l93_out <= L_work(8, 2); l94_out <= L_work(8, 3); l95_out <= L_work(8, 4); l96_out <= L_work(8, 5); l97_out <= L_work(8, 6); l98_out <= L_work(8, 7); l99_out <= L_work(8, 8);

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
