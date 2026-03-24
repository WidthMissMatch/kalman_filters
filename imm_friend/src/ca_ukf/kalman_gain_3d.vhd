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
        pxz_71, pxz_72, pxz_73 : in signed(47 downto 0);
        pxz_81, pxz_82, pxz_83 : in signed(47 downto 0);
        pxz_91, pxz_92, pxz_93 : in signed(47 downto 0);

        s11, s12, s22, s13, s23, s33 : in signed(47 downto 0);

        k11, k12, k13 : buffer signed(47 downto 0);
        k21, k22, k23 : buffer signed(47 downto 0);
        k31, k32, k33 : buffer signed(47 downto 0);
        k41, k42, k43 : buffer signed(47 downto 0);
        k51, k52, k53 : buffer signed(47 downto 0);
        k61, k62, k63 : buffer signed(47 downto 0);
        k71, k72, k73 : buffer signed(47 downto 0);
        k81, k82, k83 : buffer signed(47 downto 0);
        k91, k92, k93 : buffer signed(47 downto 0);

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
    signal pxz_71_reg, pxz_72_reg, pxz_73_reg : signed(47 downto 0) := (others => '0');
    signal pxz_81_reg, pxz_82_reg, pxz_83_reg : signed(47 downto 0) := (others => '0');
    signal pxz_91_reg, pxz_92_reg, pxz_93_reg : signed(47 downto 0) := (others => '0');

    signal k11_int, k12_int, k13_int : signed(95 downto 0) := (others => '0');
    signal k21_int, k22_int, k23_int : signed(95 downto 0) := (others => '0');
    signal k31_int, k32_int, k33_int : signed(95 downto 0) := (others => '0');
    signal k41_int, k42_int, k43_int : signed(95 downto 0) := (others => '0');
    signal k51_int, k52_int, k53_int : signed(95 downto 0) := (others => '0');
    signal k61_int, k62_int, k63_int : signed(95 downto 0) := (others => '0');
    signal k71_int, k72_int, k73_int : signed(95 downto 0) := (others => '0');
    signal k81_int, k82_int, k83_int : signed(95 downto 0) := (others => '0');
    signal k91_int, k92_int, k93_int : signed(95 downto 0) := (others => '0');

    constant UNITY : signed(47 downto 0) := to_signed(16777216, 48);
    constant NEG_UNITY : signed(47 downto 0) := to_signed(-16777216, 48);

    function saturate_gain(gain_int : signed(95 downto 0)) return signed is
        variable shifted : signed(47 downto 0);
    begin
        shifted := resize(shift_right(gain_int, Q), 48);

        if shifted > UNITY then
            report "WARNING: Kalman gain saturated to +1.0 (value hex-suppressed)" severity warning;
            return UNITY;
        elsif shifted < NEG_UNITY then
            report "WARNING: Kalman gain saturated to -1.0 (value hex-suppressed)" severity warning;
            return NEG_UNITY;
        else
            return shifted;
        end if;
    end function;

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
                        report "KALMAN_GAIN: IDLE->INVERT_S (latching inputs, values hex-suppressed)";

                        pxz_11_reg <= pxz_11; pxz_12_reg <= pxz_12; pxz_13_reg <= pxz_13;
                        pxz_21_reg <= pxz_21; pxz_22_reg <= pxz_22; pxz_23_reg <= pxz_23;
                        pxz_31_reg <= pxz_31; pxz_32_reg <= pxz_32; pxz_33_reg <= pxz_33;
                        pxz_41_reg <= pxz_41; pxz_42_reg <= pxz_42; pxz_43_reg <= pxz_43;
                        pxz_51_reg <= pxz_51; pxz_52_reg <= pxz_52; pxz_53_reg <= pxz_53;
                        pxz_61_reg <= pxz_61; pxz_62_reg <= pxz_62; pxz_63_reg <= pxz_63;
                        pxz_71_reg <= pxz_71; pxz_72_reg <= pxz_72; pxz_73_reg <= pxz_73;
                        pxz_81_reg <= pxz_81; pxz_82_reg <= pxz_82; pxz_83_reg <= pxz_83;
                        pxz_91_reg <= pxz_91; pxz_92_reg <= pxz_92; pxz_93_reg <= pxz_93;

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

                    report "KALMAN_GAIN: LATCH_S_INV (matrix inverse latched, values hex-suppressed)";

                    state <= MULTIPLY;

                when MULTIPLY =>

                    report "KALMAN_GAIN: MULTIPLY (computing K = Pxz * S_inv)";

                    temp_sum := (pxz_11_reg * s_inv_11_reg) + (pxz_12_reg * s_inv_12_reg) + (pxz_13_reg * s_inv_13_reg);
                    k11_int <= temp_sum;

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

                    temp_sum := (pxz_71_reg * s_inv_11_reg) + (pxz_72_reg * s_inv_12_reg) + (pxz_73_reg * s_inv_13_reg);
                    k71_int <= temp_sum;

                    temp_sum := (pxz_71_reg * s_inv_12_reg) + (pxz_72_reg * s_inv_22_reg) + (pxz_73_reg * s_inv_23_reg);
                    k72_int <= temp_sum;

                    temp_sum := (pxz_71_reg * s_inv_13_reg) + (pxz_72_reg * s_inv_23_reg) + (pxz_73_reg * s_inv_33_reg);
                    k73_int <= temp_sum;

                    temp_sum := (pxz_81_reg * s_inv_11_reg) + (pxz_82_reg * s_inv_12_reg) + (pxz_83_reg * s_inv_13_reg);
                    k81_int <= temp_sum;

                    temp_sum := (pxz_81_reg * s_inv_12_reg) + (pxz_82_reg * s_inv_22_reg) + (pxz_83_reg * s_inv_23_reg);
                    k82_int <= temp_sum;

                    temp_sum := (pxz_81_reg * s_inv_13_reg) + (pxz_82_reg * s_inv_23_reg) + (pxz_83_reg * s_inv_33_reg);
                    k83_int <= temp_sum;

                    temp_sum := (pxz_91_reg * s_inv_11_reg) + (pxz_92_reg * s_inv_12_reg) + (pxz_93_reg * s_inv_13_reg);
                    k91_int <= temp_sum;

                    temp_sum := (pxz_91_reg * s_inv_12_reg) + (pxz_92_reg * s_inv_22_reg) + (pxz_93_reg * s_inv_23_reg);
                    k92_int <= temp_sum;

                    temp_sum := (pxz_91_reg * s_inv_13_reg) + (pxz_92_reg * s_inv_23_reg) + (pxz_93_reg * s_inv_33_reg);
                    k93_int <= temp_sum;

                    state <= NORMALIZE;

                when NORMALIZE =>

                    report "KALMAN_GAIN: NORMALIZE (converting to Q24.24 with gain saturation)";

                    k11 <= saturate_gain(k11_int);
                    k12 <= saturate_gain(k12_int);
                    k13 <= saturate_gain(k13_int);

                    k21 <= saturate_gain(k21_int);
                    k22 <= saturate_gain(k22_int);
                    k23 <= saturate_gain(k23_int);

                    k31 <= saturate_gain(k31_int);
                    k32 <= saturate_gain(k32_int);
                    k33 <= saturate_gain(k33_int);

                    k41 <= saturate_gain(k41_int);
                    k42 <= saturate_gain(k42_int);
                    k43 <= saturate_gain(k43_int);

                    k51 <= saturate_gain(k51_int);
                    k52 <= saturate_gain(k52_int);
                    k53 <= saturate_gain(k53_int);

                    k61 <= saturate_gain(k61_int);
                    k62 <= saturate_gain(k62_int);
                    k63 <= saturate_gain(k63_int);

                    k71 <= saturate_gain(k71_int);
                    k72 <= saturate_gain(k72_int);
                    k73 <= saturate_gain(k73_int);

                    k81 <= saturate_gain(k81_int);
                    k82 <= saturate_gain(k82_int);
                    k83 <= saturate_gain(k83_int);

                    k91 <= saturate_gain(k91_int);
                    k92 <= saturate_gain(k92_int);
                    k93 <= saturate_gain(k93_int);

                    state <= FINISHED;

                when ERROR_STATE =>
                    error <= '1';
                    done <= '1';
                    if start = '0' then
                        state <= IDLE;
                    end if;

                when FINISHED =>
                    report "KALMAN_GAIN: FINISHED (K matrix, values hex-suppressed)";
                    done <= '1';
                    if start = '0' then
                        state <= IDLE;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;
