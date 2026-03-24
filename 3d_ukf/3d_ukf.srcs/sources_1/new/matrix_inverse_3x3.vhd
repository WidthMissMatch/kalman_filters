library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity matrix_inverse_3x3 is
    port (
        clk   : in  std_logic;
        start : in  std_logic;

        s11_in, s12_in, s22_in : in signed(47 downto 0);
        s13_in, s23_in, s33_in : in signed(47 downto 0);

        s11_inv_out, s12_inv_out, s22_inv_out : out signed(47 downto 0);
        s13_inv_out, s23_inv_out, s33_inv_out : out signed(47 downto 0);

        singular_error : out std_logic;
        done : out std_logic
    );
end matrix_inverse_3x3;

architecture Behavioral of matrix_inverse_3x3 is

    component reciprocal_newton is
        port (
            clk      : in  std_logic;
            start_rt : in  std_logic;
            x_in     : in  signed(47 downto 0);
            x_out    : out signed(47 downto 0);
            done     : out std_logic
        );
    end component;

    constant Q : integer := 24;

    constant MIN_DET : signed(47 downto 0) := to_signed(4096, 48);

    type state_type is (IDLE, LATCH_INPUTS,
                        COMPUTE_DET_TERM1, COMPUTE_DET_TERM2, COMPUTE_DET_TERM3,
                        COMBINE_DET, COMPUTE_DET, COMPUTE_ABS, CHECK_SINGULAR,
                        START_RECIPROCAL, WAIT_RECIPROCAL,
                        COMPUTE_COFACTOR, MULTIPLY_INVERSE, NORMALIZE_INVERSE, FINISHED);
    signal state : state_type := IDLE;

    signal s11, s12, s22, s13, s23, s33 : signed(47 downto 0);

    signal det_minor1, det_minor2, det_minor3 : signed(143 downto 0);
    signal det_term1, det_term2, det_term3 : signed(143 downto 0);
    signal det_s_128 : signed(143 downto 0);
    signal det_s : signed(47 downto 0);
    signal det_abs : signed(47 downto 0);

    signal recip_start, recip_done : std_logic;
    signal det_inv : signed(47 downto 0);

    signal cof_11, cof_12, cof_13 : signed(47 downto 0);
    signal cof_22, cof_23, cof_33 : signed(47 downto 0);

    signal inv_11_int, inv_12_int, inv_13_int : signed(95 downto 0);
    signal inv_22_int, inv_23_int, inv_33_int : signed(95 downto 0);

begin

    reciprocal_unit : reciprocal_newton
        port map (
            clk      => clk,
            start_rt => recip_start,
            x_in     => det_s,
            x_out    => det_inv,
            done     => recip_done
        );

    process(clk)
        variable temp_prod : signed(95 downto 0);
        variable temp_mul : signed(95 downto 0);
    begin
        if rising_edge(clk) then
            case state is

                when IDLE =>
                    done <= '0';
                    singular_error <= '0';
                    recip_start <= '0';

                    if start = '1' then
                        state <= LATCH_INPUTS;
                    end if;

                when LATCH_INPUTS =>

                    s11 <= s11_in;
                    s12 <= s12_in;
                    s22 <= s22_in;
                    s13 <= s13_in;
                    s23 <= s23_in;
                    s33 <= s33_in;

                    report "MATRIX_INV: LATCH_INPUTS" & LF &
                           "  s11_in=" & integer'image(to_integer(s11_in)) & LF &
                           "  s22_in=" & integer'image(to_integer(s22_in)) & LF &
                           "  s33_in=" & integer'image(to_integer(s33_in));

                    state <= COMPUTE_DET_TERM1;

                when COMPUTE_DET_TERM1 =>

                    temp_prod := s22 * s33;
                    temp_mul := s23 * s23;

                    det_minor1 <= resize(temp_prod - temp_mul, 144);
                    state <= COMPUTE_DET_TERM2;

                when COMPUTE_DET_TERM2 =>

                    temp_prod := s12 * s33;
                    temp_mul := s13 * s23;
                    det_minor2 <= resize(temp_prod - temp_mul, 144);
                    state <= COMPUTE_DET_TERM3;

                when COMPUTE_DET_TERM3 =>

                    temp_prod := s12 * s23;
                    temp_mul := s13 * s22;
                    det_minor3 <= resize(temp_prod - temp_mul, 144);
                    state <= COMBINE_DET;

                when COMBINE_DET =>

                    det_term1 <= resize(s11 * det_minor1(95 downto 0), 144);
                    det_term2 <= resize(s12 * det_minor2(95 downto 0), 144);
                    det_term3 <= resize(s13 * det_minor3(95 downto 0), 144);

                    report "MATRIX_INV: COMBINE_DET" & LF &
                           "  s11=" & integer'image(to_integer(s11)) & LF &
                           "  det_minor1(63..32)=" & integer'image(to_integer(det_minor1(63 downto 32))) & LF &
                           "  det_minor1(31..0)=" & integer'image(to_integer(det_minor1(31 downto 0)));

                    state <= COMPUTE_DET;

                when COMPUTE_DET =>

                    det_s_128 <= det_term1 - det_term2 + det_term3;

                    det_s <= resize(shift_right(det_term1 - det_term2 + det_term3, 48), 48);

                    report "MATRIX_INV: COMPUTE_DET (128-bit)" & LF &
                           "  det_term1(95..64)=" & integer'image(to_integer(det_term1(95 downto 64))) & LF &
                           "  det_term1(63..32)=" & integer'image(to_integer(det_term1(63 downto 32))) & LF &
                           "  det_s=" & integer'image(to_integer(resize(shift_right(det_term1 - det_term2 + det_term3, 48), 48)));

                    state <= COMPUTE_ABS;

                when COMPUTE_ABS =>

                    if det_s < 0 then
                        det_abs <= -det_s;
                    else
                        det_abs <= det_s;
                    end if;

                    state <= CHECK_SINGULAR;

                when CHECK_SINGULAR =>

                    report "MATRIX_INV: CHECK_SINGULAR" & LF &
                           "  det_abs=" & integer'image(to_integer(det_abs)) & " MIN_DET=" & integer'image(to_integer(MIN_DET));
                    if det_abs < MIN_DET then

                        report "MATRIX_INV: Determinant too small - SINGULAR";
                        singular_error <= '1';

                        s11_inv_out <= (others => '0');
                        s12_inv_out <= (others => '0');
                        s22_inv_out <= (others => '0');
                        s13_inv_out <= (others => '0');
                        s23_inv_out <= (others => '0');
                        s33_inv_out <= (others => '0');
                        state <= FINISHED;
                    else
                        state <= START_RECIPROCAL;
                    end if;

                when START_RECIPROCAL =>

                    recip_start <= '1';
                    state <= WAIT_RECIPROCAL;

                when WAIT_RECIPROCAL =>
                    recip_start <= '0';
                    if recip_done = '1' then
                        state <= COMPUTE_COFACTOR;
                    end if;

                when COMPUTE_COFACTOR =>

                    report "MATRIX_INV: COMPUTE_COFACTOR" & LF &
                           "  s11=" & integer'image(to_integer(s11)) &
                           " s22=" & integer'image(to_integer(s22)) &
                           " s33=" & integer'image(to_integer(s33));

                    temp_prod := s22 * s33;
                    temp_mul := s23 * s23;
                    cof_11 <= resize(shift_right(temp_prod - temp_mul, Q), 48);

                    temp_prod := s12 * s33;
                    temp_mul := s13 * s23;
                    cof_12 <= -resize(shift_right(temp_prod - temp_mul, Q), 48);

                    temp_prod := s12 * s23;
                    temp_mul := s13 * s22;
                    cof_13 <= resize(shift_right(temp_prod - temp_mul, Q), 48);

                    temp_prod := s11 * s33;
                    temp_mul := s13 * s13;
                    cof_22 <= resize(shift_right(temp_prod - temp_mul, Q), 48);

                    temp_prod := s11 * s23;
                    temp_mul := s12 * s13;
                    cof_23 <= -resize(shift_right(temp_prod - temp_mul, Q), 48);

                    temp_prod := s11 * s22;
                    temp_mul := s12 * s12;
                    cof_33 <= resize(shift_right(temp_prod - temp_mul, Q), 48);

                    report "  Cofactors computed (will be available next cycle)";
                    state <= MULTIPLY_INVERSE;

                when MULTIPLY_INVERSE =>

                    report "MATRIX_INV: MULTIPLY_INVERSE" & LF &
                           "  det_inv=" & integer'image(to_integer(det_inv)) &
                           " cof_11=" & integer'image(to_integer(cof_11));

                    inv_11_int <= det_inv * cof_11;
                    inv_12_int <= det_inv * cof_12;
                    inv_13_int <= det_inv * cof_13;
                    inv_22_int <= det_inv * cof_22;
                    inv_23_int <= det_inv * cof_23;
                    inv_33_int <= det_inv * cof_33;

                    state <= NORMALIZE_INVERSE;

                when NORMALIZE_INVERSE =>

                    report "MATRIX_INV: NORMALIZE_INVERSE" & LF &
                           "  inv_11_int(63:32)=" & integer'image(to_integer(inv_11_int(63 downto 32))) &
                           " inv_11_int(31:0)=" & integer'image(to_integer(inv_11_int(31 downto 0))) & LF &
                           "  After shift: s11_inv_out=" & integer'image(to_integer(resize(shift_right(inv_11_int, Q), 48)));

                    s11_inv_out <= resize(shift_right(inv_11_int, Q), 48);
                    s12_inv_out <= resize(shift_right(inv_12_int, Q), 48);
                    s13_inv_out <= resize(shift_right(inv_13_int, Q), 48);
                    s22_inv_out <= resize(shift_right(inv_22_int, Q), 48);
                    s23_inv_out <= resize(shift_right(inv_23_int, Q), 48);
                    s33_inv_out <= resize(shift_right(inv_33_int, Q), 48);

                    state <= FINISHED;

                when FINISHED =>
                    report "MATRIX_INV: FINISHED (done='1')";
                    done <= '1';
                    if start = '0' then
                        state <= IDLE;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;
