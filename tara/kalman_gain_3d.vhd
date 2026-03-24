library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity kalman_gain_3d is
    port (
        clk   : in  std_logic;
        start : in  std_logic;
        pxz_11, pxz_12, pxz_13 : in signed(47 downto 0);
        pxz_21, pxz_22, pxz_23 : in signed(47 downto 0);
        pxz_31, pxz_32, pxz_33 : in signed(47 downto 0);
        pxz_41, pxz_42, pxz_43 : in signed(47 downto 0);
        pxz_51, pxz_52, pxz_53 : in signed(47 downto 0);
        pxz_61, pxz_62, pxz_63 : in signed(47 downto 0);
        s11, s12, s22, s13, s23, s33 : in signed(47 downto 0);
        k11, k12, k13 : out signed(47 downto 0);
        k21, k22, k23 : out signed(47 downto 0);
        k31, k32, k33 : out signed(47 downto 0);
        k41, k42, k43 : out signed(47 downto 0);
        k51, k52, k53 : out signed(47 downto 0);
        k61, k62, k63 : out signed(47 downto 0);
        error : out std_logic;
        done  : out std_logic
    );
end kalman_gain_3d;
architecture Behavioral of kalman_gain_3d is
    constant Q : integer := 24;
    component matrix_inverse_3x3 is
        port (
            clk   : in  std_logic;
            start : in  std_logic;
            s11_in, s12_in, s22_in : in signed(47 downto 0);
            s13_in, s23_in, s33_in : in signed(47 downto 0);
            s11_inv_out, s12_inv_out, s22_inv_out : out signed(47 downto 0);
            s13_inv_out, s23_inv_out, s33_inv_out : out signed(47 downto 0);
            singular_error : out std_logic;
            done  : out std_logic
        );
    end component;
    type state_type is (IDLE, INVERT_S, LATCH_S_INV, MULTIPLY, NORMALIZE, ERROR_STATE, FINISHED);
    signal state : state_type := IDLE;
    signal inv_start : std_logic := '0';
    signal inv_done : std_logic;
    signal inv_error : std_logic;
    signal s_inv_11, s_inv_12, s_inv_22 : signed(47 downto 0) := (others => '0');
    signal s_inv_13, s_inv_23, s_inv_33 : signed(47 downto 0) := (others => '0');
    signal s_inv_11_reg, s_inv_12_reg, s_inv_22_reg : signed(47 downto 0) := (others => '0');
    signal s_inv_13_reg, s_inv_23_reg, s_inv_33_reg : signed(47 downto 0) := (others => '0');
    signal pxz_11_reg, pxz_12_reg, pxz_13_reg : signed(47 downto 0) := (others => '0');
    signal pxz_21_reg, pxz_22_reg, pxz_23_reg : signed(47 downto 0) := (others => '0');
    signal pxz_31_reg, pxz_32_reg, pxz_33_reg : signed(47 downto 0) := (others => '0');
    signal pxz_41_reg, pxz_42_reg, pxz_43_reg : signed(47 downto 0) := (others => '0');
    signal pxz_51_reg, pxz_52_reg, pxz_53_reg : signed(47 downto 0) := (others => '0');
    signal pxz_61_reg, pxz_62_reg, pxz_63_reg : signed(47 downto 0) := (others => '0');
    signal k11_int, k12_int, k13_int : signed(95 downto 0) := (others => '0');
    signal k21_int, k22_int, k23_int : signed(95 downto 0) := (others => '0');
    signal k31_int, k32_int, k33_int : signed(95 downto 0) := (others => '0');
    signal k41_int, k42_int, k43_int : signed(95 downto 0) := (others => '0');
    signal k51_int, k52_int, k53_int : signed(95 downto 0) := (others => '0');
    signal k61_int, k62_int, k63_int : signed(95 downto 0) := (others => '0');
begin
    inv_3x3 : matrix_inverse_3x3
        port map (
            clk => clk,
            start => inv_start,
            s11_in => s11, s12_in => s12, s22_in => s22,
            s13_in => s13, s23_in => s23, s33_in => s33,
            s11_inv_out => s_inv_11, s12_inv_out => s_inv_12, s22_inv_out => s_inv_22,
            s13_inv_out => s_inv_13, s23_inv_out => s_inv_23, s33_inv_out => s_inv_33,
            singular_error => inv_error,
            done => inv_done
        );
    process(clk)
        variable temp_sum : signed(95 downto 0);
    begin
        if rising_edge(clk) then
            case state is
                when IDLE =>
                    done <= '0';
                    error <= '0';
                    inv_start <= '0';
                    if start = '1' then
                        pxz_11_reg <= pxz_11; pxz_12_reg <= pxz_12; pxz_13_reg <= pxz_13;
                        pxz_21_reg <= pxz_21; pxz_22_reg <= pxz_22; pxz_23_reg <= pxz_23;
                        pxz_31_reg <= pxz_31; pxz_32_reg <= pxz_32; pxz_33_reg <= pxz_33;
                        pxz_41_reg <= pxz_41; pxz_42_reg <= pxz_42; pxz_43_reg <= pxz_43;
                        pxz_51_reg <= pxz_51; pxz_52_reg <= pxz_52; pxz_53_reg <= pxz_53;
                        pxz_61_reg <= pxz_61; pxz_62_reg <= pxz_62; pxz_63_reg <= pxz_63;
                        report "KALMAN_GAIN: Starting matrix inversion";
                        inv_start <= '1';
                        state <= INVERT_S;
                    end if;
                when INVERT_S =>
                    inv_start <= '0';
                    if inv_done = '1' then
                        report "KALMAN_GAIN: Matrix inverse done, inv_error=" & std_logic'image(inv_error);
                        if inv_error = '1' then
                            state <= ERROR_STATE;
                        else
                            state <= LATCH_S_INV;
                        end if;
                    end if;
                when LATCH_S_INV =>
                    s_inv_11_reg <= s_inv_11; s_inv_12_reg <= s_inv_12; s_inv_22_reg <= s_inv_22;
                    s_inv_13_reg <= s_inv_13; s_inv_23_reg <= s_inv_23; s_inv_33_reg <= s_inv_33;
                    report "KALMAN_GAIN: LATCH_S_INV" & LF &
                           "  Pxz: pxz_11=" & integer'image(to_integer(pxz_11_reg)) & " pxz_12=" & integer'image(to_integer(pxz_12_reg)) & " pxz_13=" & integer'image(to_integer(pxz_13_reg)) & LF &
                           "  S_inv: s_inv_11=" & integer'image(to_integer(s_inv_11)) & " s_inv_12=" & integer'image(to_integer(s_inv_12)) & " s_inv_22=" & integer'image(to_integer(s_inv_22)) & LF &
                           "         s_inv_13=" & integer'image(to_integer(s_inv_13)) & " s_inv_23=" & integer'image(to_integer(s_inv_23)) & " s_inv_33=" & integer'image(to_integer(s_inv_33));
                    state <= MULTIPLY;
                when MULTIPLY =>
                    report "KALMAN_GAIN: MULTIPLY" & LF &
                           "  Inputs: pxz_11_reg=" & integer'image(to_integer(pxz_11_reg)) &
                           " s_inv_11_reg=" & integer'image(to_integer(s_inv_11_reg));
                    temp_sum := (pxz_11_reg * s_inv_11_reg) + (pxz_12_reg * s_inv_12_reg) + (pxz_13_reg * s_inv_13_reg);
                    k11_int <= temp_sum;
                    report "  k11_int (Q32.32) = " & integer'image(to_integer(temp_sum(63 downto 32))) &
                           " (upper) " & integer'image(to_integer(temp_sum(31 downto 0))) & " (lower)";
                    temp_sum := (pxz_11_reg * s_inv_12_reg) + (pxz_12_reg * s_inv_22_reg) + (pxz_13_reg * s_inv_23_reg);
                    k12_int <= temp_sum;
                    temp_sum := (pxz_11_reg * s_inv_13_reg) + (pxz_12_reg * s_inv_23_reg) + (pxz_13_reg * s_inv_33_reg);
                    k13_int <= temp_sum;
                    temp_sum := (pxz_21_reg * s_inv_11_reg) + (pxz_22_reg * s_inv_12_reg) + (pxz_23_reg * s_inv_13_reg);
                    k21_int <= temp_sum;
                    temp_sum := (pxz_21_reg * s_inv_12_reg) + (pxz_22_reg * s_inv_22_reg) + (pxz_23_reg * s_inv_23_reg);
                    k22_int <= temp_sum;
                    temp_sum := (pxz_21_reg * s_inv_13_reg) + (pxz_22_reg * s_inv_23_reg) + (pxz_23_reg * s_inv_33_reg);
                    k23_int <= temp_sum;
                    temp_sum := (pxz_31_reg * s_inv_11_reg) + (pxz_32_reg * s_inv_12_reg) + (pxz_33_reg * s_inv_13_reg);
                    k31_int <= temp_sum;
                    temp_sum := (pxz_31_reg * s_inv_12_reg) + (pxz_32_reg * s_inv_22_reg) + (pxz_33_reg * s_inv_23_reg);
                    k32_int <= temp_sum;
                    temp_sum := (pxz_31_reg * s_inv_13_reg) + (pxz_32_reg * s_inv_23_reg) + (pxz_33_reg * s_inv_33_reg);
                    k33_int <= temp_sum;
                    temp_sum := (pxz_41_reg * s_inv_11_reg) + (pxz_42_reg * s_inv_12_reg) + (pxz_43_reg * s_inv_13_reg);
                    k41_int <= temp_sum;
                    temp_sum := (pxz_41_reg * s_inv_12_reg) + (pxz_42_reg * s_inv_22_reg) + (pxz_43_reg * s_inv_23_reg);
                    k42_int <= temp_sum;
                    temp_sum := (pxz_41_reg * s_inv_13_reg) + (pxz_42_reg * s_inv_23_reg) + (pxz_43_reg * s_inv_33_reg);
                    k43_int <= temp_sum;
                    temp_sum := (pxz_51_reg * s_inv_11_reg) + (pxz_52_reg * s_inv_12_reg) + (pxz_53_reg * s_inv_13_reg);
                    k51_int <= temp_sum;
                    temp_sum := (pxz_51_reg * s_inv_12_reg) + (pxz_52_reg * s_inv_22_reg) + (pxz_53_reg * s_inv_23_reg);
                    k52_int <= temp_sum;
                    temp_sum := (pxz_51_reg * s_inv_13_reg) + (pxz_52_reg * s_inv_23_reg) + (pxz_53_reg * s_inv_33_reg);
                    k53_int <= temp_sum;
                    temp_sum := (pxz_61_reg * s_inv_11_reg) + (pxz_62_reg * s_inv_12_reg) + (pxz_63_reg * s_inv_13_reg);
                    k61_int <= temp_sum;
                    temp_sum := (pxz_61_reg * s_inv_12_reg) + (pxz_62_reg * s_inv_22_reg) + (pxz_63_reg * s_inv_23_reg);
                    k62_int <= temp_sum;
                    temp_sum := (pxz_61_reg * s_inv_13_reg) + (pxz_62_reg * s_inv_23_reg) + (pxz_63_reg * s_inv_33_reg);
                    k63_int <= temp_sum;
                    state <= NORMALIZE;
                when NORMALIZE =>
                    report "KALMAN_GAIN: NORMALIZE" & LF &
                           "  k11_int before shift=" & integer'image(to_integer(k11_int(63 downto 32))) &
                           " (upper) " & integer'image(to_integer(k11_int(31 downto 0))) & " (lower)" & LF &
                           "  After shift_right by Q=" & integer'image(to_integer(shift_right(k11_int, Q)));
                    k11 <= resize(shift_right(k11_int, Q), 48);
                    k12 <= resize(shift_right(k12_int, Q), 48);
                    k13 <= resize(shift_right(k13_int, Q), 48);
                    k21 <= resize(shift_right(k21_int, Q), 48);
                    k22 <= resize(shift_right(k22_int, Q), 48);
                    k23 <= resize(shift_right(k23_int, Q), 48);
                    k31 <= resize(shift_right(k31_int, Q), 48);
                    k32 <= resize(shift_right(k32_int, Q), 48);
                    k33 <= resize(shift_right(k33_int, Q), 48);
                    k41 <= resize(shift_right(k41_int, Q), 48);
                    k42 <= resize(shift_right(k42_int, Q), 48);
                    k43 <= resize(shift_right(k43_int, Q), 48);
                    k51 <= resize(shift_right(k51_int, Q), 48);
                    k52 <= resize(shift_right(k52_int, Q), 48);
                    k53 <= resize(shift_right(k53_int, Q), 48);
                    k61 <= resize(shift_right(k61_int, Q), 48);
                    k62 <= resize(shift_right(k62_int, Q), 48);
                    k63 <= resize(shift_right(k63_int, Q), 48);
                    state <= FINISHED;
                when ERROR_STATE =>
                    error <= '1';
                    done <= '1';
                    if start = '0' then
                        state <= IDLE;
                    end if;
                when FINISHED =>
                    report "KALMAN_GAIN: FINISHED (done='1')";
                    done <= '1';
                    if start = '0' then
                        state <= IDLE;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
