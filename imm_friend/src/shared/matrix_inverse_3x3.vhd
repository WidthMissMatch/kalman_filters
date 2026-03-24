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

    constant Q : integer := 24;

    constant MIN_DET : signed(47 downto 0) := to_signed(4096, 48);

    type state_type is (IDLE, LATCH_INPUTS,
                        COMPUTE_DET_TERM1, COMPUTE_DET_TERM2, COMPUTE_DET_TERM3,
                        COMBINE_DET, COMPUTE_DET, CHECK_SINGULAR,
                        COMPUTE_COFACTOR, DIVIDE_COFACTORS, FINISHED);
    signal state : state_type := IDLE;

    signal s11, s12, s22, s13, s23, s33 : signed(47 downto 0);

    signal det_minor1, det_minor2, det_minor3 : signed(143 downto 0);
    signal det_term1, det_term2, det_term3 : signed(143 downto 0);
    signal det_s_128 : signed(143 downto 0);
    signal det_s : signed(47 downto 0);

    signal cof_11, cof_12, cof_13 : signed(47 downto 0);
    signal cof_22, cof_23, cof_33 : signed(47 downto 0);

    signal s11_inv_reg, s12_inv_reg, s22_inv_reg : signed(47 downto 0) := (others => '0');
    signal s13_inv_reg, s23_inv_reg, s33_inv_reg : signed(47 downto 0) := (others => '0');

begin

    s11_inv_out <= s11_inv_reg;
    s12_inv_out <= s12_inv_reg;
    s22_inv_out <= s22_inv_reg;
    s13_inv_out <= s13_inv_reg;
    s23_inv_out <= s23_inv_reg;
    s33_inv_out <= s33_inv_reg;

    process(clk)
        variable temp_prod : signed(95 downto 0);
        variable temp_mul : signed(95 downto 0);
        variable temp_div : signed(95 downto 0);
    begin
        if rising_edge(clk) then
            case state is

                when IDLE =>
                    done <= '0';
                    singular_error <= '0';

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

                    det_term1 <= s11 * det_minor1(95 downto 0);
                    det_term2 <= s12 * det_minor2(95 downto 0);
                    det_term3 <= s13 * det_minor3(95 downto 0);

                    state <= COMPUTE_DET;

                when COMPUTE_DET =>

                    det_s_128 <= det_term1 - det_term2 + det_term3;

                    det_s <= shift_right(det_term1 - det_term2 + det_term3, 48)(47 downto 0);

                    state <= CHECK_SINGULAR;

                when CHECK_SINGULAR =>

                    if det_s < MIN_DET and det_s > -MIN_DET then
                        singular_error <= '1';

                        s11_inv_reg <= (others => '0');
                        s12_inv_reg <= (others => '0');
                        s22_inv_reg <= (others => '0');
                        s13_inv_reg <= (others => '0');
                        s23_inv_reg <= (others => '0');
                        s33_inv_reg <= (others => '0');
                        state <= FINISHED;
                    else

                        state <= COMPUTE_COFACTOR;
                    end if;

                when COMPUTE_COFACTOR =>

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

                    state <= DIVIDE_COFACTORS;

                when DIVIDE_COFACTORS =>

                    temp_div := shift_left(resize(cof_11, 96), Q) / resize(det_s, 96);
                    s11_inv_reg <= resize(temp_div, 48);

                    temp_div := shift_left(resize(cof_12, 96), Q) / resize(det_s, 96);
                    s12_inv_reg <= resize(temp_div, 48);

                    temp_div := shift_left(resize(cof_13, 96), Q) / resize(det_s, 96);
                    s13_inv_reg <= resize(temp_div, 48);

                    temp_div := shift_left(resize(cof_22, 96), Q) / resize(det_s, 96);
                    s22_inv_reg <= resize(temp_div, 48);

                    temp_div := shift_left(resize(cof_23, 96), Q) / resize(det_s, 96);
                    s23_inv_reg <= resize(temp_div, 48);

                    temp_div := shift_left(resize(cof_33, 96), Q) / resize(det_s, 96);
                    s33_inv_reg <= resize(temp_div, 48);

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
