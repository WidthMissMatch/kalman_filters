library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity qr_decomp_9x19 is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        start : in  std_logic;

        x_pos_mean, x_vel_mean, x_acc_mean : in signed(47 downto 0);
        y_pos_mean, y_vel_mean, y_acc_mean : in signed(47 downto 0);
        z_pos_mean, z_vel_mean, z_acc_mean : in signed(47 downto 0);

        chi0_x_pos, chi0_x_vel, chi0_x_acc, chi0_y_pos, chi0_y_vel, chi0_y_acc, chi0_z_pos, chi0_z_vel, chi0_z_acc : in signed(47 downto 0);
        chi1_x_pos, chi1_x_vel, chi1_x_acc, chi1_y_pos, chi1_y_vel, chi1_y_acc, chi1_z_pos, chi1_z_vel, chi1_z_acc : in signed(47 downto 0);
        chi2_x_pos, chi2_x_vel, chi2_x_acc, chi2_y_pos, chi2_y_vel, chi2_y_acc, chi2_z_pos, chi2_z_vel, chi2_z_acc : in signed(47 downto 0);
        chi3_x_pos, chi3_x_vel, chi3_x_acc, chi3_y_pos, chi3_y_vel, chi3_y_acc, chi3_z_pos, chi3_z_vel, chi3_z_acc : in signed(47 downto 0);
        chi4_x_pos, chi4_x_vel, chi4_x_acc, chi4_y_pos, chi4_y_vel, chi4_y_acc, chi4_z_pos, chi4_z_vel, chi4_z_acc : in signed(47 downto 0);
        chi5_x_pos, chi5_x_vel, chi5_x_acc, chi5_y_pos, chi5_y_vel, chi5_y_acc, chi5_z_pos, chi5_z_vel, chi5_z_acc : in signed(47 downto 0);
        chi6_x_pos, chi6_x_vel, chi6_x_acc, chi6_y_pos, chi6_y_vel, chi6_y_acc, chi6_z_pos, chi6_z_vel, chi6_z_acc : in signed(47 downto 0);
        chi7_x_pos, chi7_x_vel, chi7_x_acc, chi7_y_pos, chi7_y_vel, chi7_y_acc, chi7_z_pos, chi7_z_vel, chi7_z_acc : in signed(47 downto 0);
        chi8_x_pos, chi8_x_vel, chi8_x_acc, chi8_y_pos, chi8_y_vel, chi8_y_acc, chi8_z_pos, chi8_z_vel, chi8_z_acc : in signed(47 downto 0);
        chi9_x_pos, chi9_x_vel, chi9_x_acc, chi9_y_pos, chi9_y_vel, chi9_y_acc, chi9_z_pos, chi9_z_vel, chi9_z_acc : in signed(47 downto 0);
        chi10_x_pos, chi10_x_vel, chi10_x_acc, chi10_y_pos, chi10_y_vel, chi10_y_acc, chi10_z_pos, chi10_z_vel, chi10_z_acc : in signed(47 downto 0);
        chi11_x_pos, chi11_x_vel, chi11_x_acc, chi11_y_pos, chi11_y_vel, chi11_y_acc, chi11_z_pos, chi11_z_vel, chi11_z_acc : in signed(47 downto 0);
        chi12_x_pos, chi12_x_vel, chi12_x_acc, chi12_y_pos, chi12_y_vel, chi12_y_acc, chi12_z_pos, chi12_z_vel, chi12_z_acc : in signed(47 downto 0);
        chi13_x_pos, chi13_x_vel, chi13_x_acc, chi13_y_pos, chi13_y_vel, chi13_y_acc, chi13_z_pos, chi13_z_vel, chi13_z_acc : in signed(47 downto 0);
        chi14_x_pos, chi14_x_vel, chi14_x_acc, chi14_y_pos, chi14_y_vel, chi14_y_acc, chi14_z_pos, chi14_z_vel, chi14_z_acc : in signed(47 downto 0);
        chi15_x_pos, chi15_x_vel, chi15_x_acc, chi15_y_pos, chi15_y_vel, chi15_y_acc, chi15_z_pos, chi15_z_vel, chi15_z_acc : in signed(47 downto 0);
        chi16_x_pos, chi16_x_vel, chi16_x_acc, chi16_y_pos, chi16_y_vel, chi16_y_acc, chi16_z_pos, chi16_z_vel, chi16_z_acc : in signed(47 downto 0);
        chi17_x_pos, chi17_x_vel, chi17_x_acc, chi17_y_pos, chi17_y_vel, chi17_y_acc, chi17_z_pos, chi17_z_vel, chi17_z_acc : in signed(47 downto 0);
        chi18_x_pos, chi18_x_vel, chi18_x_acc, chi18_y_pos, chi18_y_vel, chi18_y_acc, chi18_z_pos, chi18_z_vel, chi18_z_acc : in signed(47 downto 0);

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
end qr_decomp_9x19;

architecture Behavioral of qr_decomp_9x19 is

    constant Q : integer := 24;

    constant W0_ABS_SQRT : signed(47 downto 0) := to_signed(408855193, 48);
    constant W_SQRT : signed(47 downto 0) := to_signed(3954427, 48);
    constant W0_IS_NEGATIVE : std_logic := '1';

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

    type state_type is (IDLE, BUILD_WEIGHTED_A,
                        HOUSEHOLDER_COL0, WAIT_SQRT0, APPLY_REFLECTION0,
                        HOUSEHOLDER_COL1, WAIT_SQRT1, APPLY_REFLECTION1,
                        HOUSEHOLDER_COL2, WAIT_SQRT2, APPLY_REFLECTION2,
                        HOUSEHOLDER_COL3, WAIT_SQRT3, APPLY_REFLECTION3,
                        HOUSEHOLDER_COL4, WAIT_SQRT4, APPLY_REFLECTION4,
                        HOUSEHOLDER_COL5, WAIT_SQRT5, APPLY_REFLECTION5,
                        HOUSEHOLDER_COL6, WAIT_SQRT6, APPLY_REFLECTION6,
                        HOUSEHOLDER_COL7, WAIT_SQRT7, APPLY_REFLECTION7,
                        HOUSEHOLDER_COL8, WAIT_SQRT8, APPLY_REFLECTION8,
                        EXTRACT_R_TRANSPOSE, FINISHED);
    signal state : state_type := IDLE;

    type row_type is array (0 to 18) of signed(47 downto 0);
    type matrix_9x19_type is array (0 to 8) of row_type;
    signal A : matrix_9x19_type := (others => (others => (others => '0')));

    type vector_9_type is array (0 to 8) of signed(47 downto 0);
    signal v : vector_9_type := (others => (others => '0'));
    signal beta : signed(47 downto 0) := (others => '0');

    type matrix_9x9_upper_type is array (0 to 8, 0 to 8) of signed(47 downto 0);
    signal R : matrix_9x9_upper_type := (others => (others => (others => '0')));

    signal sqrt_start : std_logic := '0';
    signal sqrt_in : signed(47 downto 0) := (others => '0');
    signal sqrt_out : signed(47 downto 0);
    signal sqrt_done : std_logic;

    signal col_idx : integer range 0 to 8 := 0;
    signal row_idx : integer range 0 to 18 := 0;

    signal iteration_counter : integer := 0;
    constant MAX_ITERATIONS : integer := 10000;

    signal alpha : signed(47 downto 0) := (others => '0');
    signal norm_sq : signed(95 downto 0) := (others => '0');
    signal v_norm_sq : signed(95 downto 0) := (others => '0');

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
        variable delta : signed(47 downto 0);
        variable weighted_delta : signed(95 downto 0);
        variable temp_prod : signed(95 downto 0);
        variable temp_sum : signed(95 downto 0);
    begin
        if rising_edge(clk) then

            if state /= IDLE and state /= FINISHED then
                report "QR_DECOMP State: " & state_type'image(state) severity note;
            end if;

            if reset = '1' then
                state <= IDLE;
                done <= '0';
                sqrt_start <= '0';
                col_idx <= 0;
                row_idx <= 0;
                iteration_counter <= 0;
            else

                if state /= IDLE and state /= FINISHED then

                    if iteration_counter < 20 or iteration_counter mod 1000 = 0 then
                        report "QR_DECOMP: PRE-INCREMENT iteration_counter=" & integer'image(iteration_counter) &
                               " state=" & state_type'image(state) &
                               " col_idx=" & integer'image(col_idx) &
                               " start=" & std_logic'image(start) severity note;
                    end if;

                    iteration_counter <= iteration_counter + 1;
                end if;

                if iteration_counter > MAX_ITERATIONS then
                    report "QR_DECOMP: ERROR - Iteration limit exceeded (" &
                           integer'image(iteration_counter) & " > " &
                           integer'image(MAX_ITERATIONS) & "), aborting QR!" severity error;
                    report "QR_DECOMP: State was: " & state_type'image(state) &
                           ", col_idx=" & integer'image(col_idx) &
                           ", row_idx=" & integer'image(row_idx);

                    l11_out <= to_signed(16777216, 48);
                    l22_out <= to_signed(16777216, 48);
                    l33_out <= to_signed(16777216, 48);
                    l44_out <= to_signed(16777216, 48);
                    l55_out <= to_signed(16777216, 48);
                    l66_out <= to_signed(16777216, 48);
                    l77_out <= to_signed(16777216, 48);
                    l88_out <= to_signed(16777216, 48);
                    l99_out <= to_signed(16777216, 48);

                    done <= '1';
                    state <= FINISHED;
                    iteration_counter <= 0;
                end if;
                case state is

                    when IDLE =>
                        done <= '0';
                        sqrt_start <= '0';
                        if start = '1' then
                            report "QR_DECOMP: IDLE state, start='1', RESETTING iteration_counter to 0" severity note;
                            iteration_counter <= 0;
                            state <= BUILD_WEIGHTED_A;
                        end if;

                    when BUILD_WEIGHTED_A =>
                        report "=== ENTERED BUILD_WEIGHTED_A STATE ===";

                        delta := chi1_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(0) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi1_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(0) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi1_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(0) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi1_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(0) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi1_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(0) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi1_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(0) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi1_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(0) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi1_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(0) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi1_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(0) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi2_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(1) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi2_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(1) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi2_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(1) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi2_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(1) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi2_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(1) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi2_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(1) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi2_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(1) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi2_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(1) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi2_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(1) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi3_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(2) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi3_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(2) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi3_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(2) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi3_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(2) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi3_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(2) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi3_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(2) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi3_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(2) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi3_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(2) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi3_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(2) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi4_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(3) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi4_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(3) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi4_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(3) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi4_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(3) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi4_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(3) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi4_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(3) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi4_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(3) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi4_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(3) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi4_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(3) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi5_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(4) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi5_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(4) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi5_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(4) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi5_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(4) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi5_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(4) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi5_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(4) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi5_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(4) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi5_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(4) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi5_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(4) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi6_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(5) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi6_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(5) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi6_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(5) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi6_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(5) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi6_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(5) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi6_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(5) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi6_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(5) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi6_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(5) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi6_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(5) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi7_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(6) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi7_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(6) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi7_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(6) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi7_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(6) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi7_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(6) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi7_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(6) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi7_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(6) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi7_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(6) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi7_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(6) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi8_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(7) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi8_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(7) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi8_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(7) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi8_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(7) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi8_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(7) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi8_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(7) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi8_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(7) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi8_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(7) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi8_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(7) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi9_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(8) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi9_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(8) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi9_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(8) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi9_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(8) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi9_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(8) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi9_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(8) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi9_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(8) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi9_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(8) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi9_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(8) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi10_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(9) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi10_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(9) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi10_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(9) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi10_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(9) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi10_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(9) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi10_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(9) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi10_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(9) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi10_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(9) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi10_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(9) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi11_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(10) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi11_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(10) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi11_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(10) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi11_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(10) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi11_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(10) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi11_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(10) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi11_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(10) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi11_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(10) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi11_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(10) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi12_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(11) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi12_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(11) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi12_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(11) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi12_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(11) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi12_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(11) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi12_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(11) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi12_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(11) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi12_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(11) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi12_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(11) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi13_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(12) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi13_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(12) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi13_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(12) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi13_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(12) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi13_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(12) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi13_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(12) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi13_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(12) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi13_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(12) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi13_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(12) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi14_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(13) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi14_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(13) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi14_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(13) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi14_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(13) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi14_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(13) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi14_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(13) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi14_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(13) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi14_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(13) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi14_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(13) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi15_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(14) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi15_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(14) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi15_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(14) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi15_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(14) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi15_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(14) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi15_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(14) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi15_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(14) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi15_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(14) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi15_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(14) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi16_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(15) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi16_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(15) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi16_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(15) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi16_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(15) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi16_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(15) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi16_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(15) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi16_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(15) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi16_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(15) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi16_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(15) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi17_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(16) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi17_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(16) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi17_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(16) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi17_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(16) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi17_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(16) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi17_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(16) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi17_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(16) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi17_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(16) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi17_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(16) <= resize(shift_right(weighted_delta, Q), 48);

                        delta := chi18_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(17) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi18_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(17) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi18_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(17) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi18_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(17) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi18_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(17) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi18_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(17) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi18_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(17) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi18_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(17) <= resize(shift_right(weighted_delta, Q), 48);
                        delta := chi18_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(17) <= resize(shift_right(weighted_delta, Q), 48);

                        report "QR_DECOMP: BUILD_WEIGHTED_A completed (all 19 sigma points)";
                        report "QR_DECOMP: A(0)(0)=" & integer'image(to_integer(A(0)(0))) &
                               " A(0)(1)=" & integer'image(to_integer(A(0)(1))) &
                               " A(0)(2)=" & integer'image(to_integer(A(0)(2))) &
                               " A(1)(0)=" & integer'image(to_integer(A(1)(0)));
                        state <= HOUSEHOLDER_COL0;
                        col_idx <= 0;

                    when HOUSEHOLDER_COL0 =>

                        report "HOUSEHOLDER_COL0: A(0)(0)=" & integer'image(to_integer(A(0)(0))) & " A(0)(18)=" & integer'image(to_integer(A(0)(1))) & " A(1)(18)=" & integer'image(to_integer(A(1)(1)));

                        norm_sq <= (others => '0');
                        for i in col_idx to 8 loop
                            temp_prod := A(i)(col_idx) * A(i)(col_idx);
                            norm_sq <= norm_sq + shift_right(temp_prod, Q);
                        end loop;

                        sqrt_in <= resize(norm_sq, 48);
                        sqrt_start <= '1';
                        state <= WAIT_SQRT0;

                    when WAIT_SQRT0 =>
                        sqrt_start <= '0';
                        if sqrt_done = '1' then

                            if A(col_idx)(col_idx) >= 0 then
                                delta := -sqrt_out;
                            else
                                delta := sqrt_out;
                            end if;
                            alpha <= delta;

                            v(col_idx) <= A(col_idx)(col_idx) - delta;
                            for i in col_idx+1 to 8 loop
                                v(i) <= A(i)(col_idx);
                            end loop;

                            v_norm_sq <= (others => '0');
                            temp_prod := (A(col_idx)(col_idx) - delta) * (A(col_idx)(col_idx) - delta);
                            v_norm_sq <= shift_right(temp_prod, Q);
                            for i in col_idx+1 to 8 loop
                                temp_prod := A(i)(col_idx) * A(i)(col_idx);
                                v_norm_sq <= v_norm_sq + shift_right(temp_prod, Q);
                            end loop;

                            if v_norm_sq > to_signed(1, 96) then
                                beta <= resize(shift_left(to_signed(2, 48), Q) / v_norm_sq(47 downto 0), 48);
                            else
                                beta <= (others => '0');
                            end if;

                            R(col_idx, col_idx) <= alpha;

                            state <= APPLY_REFLECTION0;
                            row_idx <= 0;
                        end if;

                    when APPLY_REFLECTION0 =>

                        if row_idx < 18 then
                            if row_idx > col_idx then

                                temp_sum := (others => '0');
                                for i in col_idx to 8 loop
                                    temp_prod := v(i) * A(i)(row_idx);
                                    temp_sum := temp_sum + shift_right(temp_prod, Q);
                                end loop;

                                temp_prod := beta * resize(temp_sum, 48);
                                temp_sum := shift_right(temp_prod, Q);

                                for i in col_idx to 8 loop
                                    temp_prod := v(i) * resize(temp_sum, 48);
                                    A(i)(row_idx) <= A(i)(row_idx) - resize(shift_right(temp_prod, Q), 48);
                                end loop;
                            end if;

                            row_idx <= row_idx + 1;
                        else

                            if col_idx < 8 then
                                col_idx <= col_idx + 1;
                                state <= HOUSEHOLDER_COL1;
                            else
                                state <= EXTRACT_R_TRANSPOSE;
                            end if;
                        end if;

                    when HOUSEHOLDER_COL1 =>
                        norm_sq <= (others => '0');
                        for i in 1 to 8 loop
                            temp_prod := A(i)(1) * A(i)(1);
                            norm_sq <= norm_sq + shift_right(temp_prod, Q);
                        end loop;
                        sqrt_in <= resize(norm_sq, 48);
                        sqrt_start <= '1';
                        state <= WAIT_SQRT1;

                    when WAIT_SQRT1 =>
                        sqrt_start <= '0';
                        if sqrt_done = '1' then
                            if A(1)(1) >= 0 then
                                alpha <= -sqrt_out;
                            else
                                alpha <= sqrt_out;
                            end if;
                            v(1) <= A(1)(1) - alpha;
                            for i in 2 to 8 loop
                                v(i) <= A(i)(1);
                            end loop;
                            v_norm_sq <= (others => '0');
                            temp_prod := v(1) * v(1);
                            v_norm_sq <= shift_right(temp_prod, Q);
                            for i in 2 to 8 loop
                                temp_prod := v(i) * v(i);
                                v_norm_sq <= v_norm_sq + shift_right(temp_prod, Q);
                            end loop;
                            if v_norm_sq > to_signed(1, 96) then
                                beta <= resize(shift_left(to_signed(2, 48), Q) / v_norm_sq(47 downto 0), 48);
                            else
                                beta <= (others => '0');
                            end if;
                            R(1, 1) <= alpha;
                            state <= APPLY_REFLECTION1;
                            row_idx <= 0;
                        end if;

                    when APPLY_REFLECTION1 =>
                        if row_idx < 18 then
                            if row_idx > 1 then
                                temp_sum := (others => '0');
                                for i in 1 to 8 loop
                                    temp_prod := v(i) * A(i)(row_idx);
                                    temp_sum := temp_sum + shift_right(temp_prod, Q);
                                end loop;
                                temp_prod := beta * resize(temp_sum, 48);
                                temp_sum := shift_right(temp_prod, Q);
                                for i in 1 to 8 loop
                                    temp_prod := v(i) * resize(temp_sum, 48);
                                    A(i)(row_idx) <= A(i)(row_idx) - resize(shift_right(temp_prod, Q), 48);
                                end loop;
                            end if;
                            row_idx <= row_idx + 1;
                        else
                            col_idx <= col_idx + 1;
                            state <= HOUSEHOLDER_COL2;
                        end if;

                    when HOUSEHOLDER_COL2 =>
                        norm_sq <= (others => '0');
                        for i in 2 to 8 loop
                            temp_prod := A(i)(2) * A(i)(2);
                            norm_sq <= norm_sq + shift_right(temp_prod, Q);
                        end loop;
                        sqrt_in <= resize(norm_sq, 48);
                        sqrt_start <= '1';
                        state <= WAIT_SQRT2;

                    when WAIT_SQRT2 =>
                        sqrt_start <= '0';
                        if sqrt_done = '1' then
                            if A(2)(18) >= 0 then
                                alpha <= -sqrt_out;
                            else
                                alpha <= sqrt_out;
                            end if;
                            v(2) <= A(2)(2) - alpha;
                            for i in 3 to 8 loop
                                v(i) <= A(i)(2);
                            end loop;
                            v_norm_sq <= (others => '0');
                            temp_prod := v(2) * v(2);
                            v_norm_sq <= shift_right(temp_prod, Q);
                            for i in 3 to 8 loop
                                temp_prod := v(i) * v(i);
                                v_norm_sq <= v_norm_sq + shift_right(temp_prod, Q);
                            end loop;
                            if v_norm_sq > to_signed(1, 96) then
                                beta <= resize(shift_left(to_signed(2, 48), Q) / v_norm_sq(47 downto 0), 48);
                            else
                                beta <= (others => '0');
                            end if;
                            R(2, 2) <= alpha;
                            state <= APPLY_REFLECTION2;
                            row_idx <= 0;
                        end if;

                    when APPLY_REFLECTION2 =>
                        if row_idx < 18 then
                            if row_idx > 2 then
                                temp_sum := (others => '0');
                                for i in 2 to 8 loop
                                    temp_prod := v(i) * A(i)(row_idx);
                                    temp_sum := temp_sum + shift_right(temp_prod, Q);
                                end loop;
                                temp_prod := beta * resize(temp_sum, 48);
                                temp_sum := shift_right(temp_prod, Q);
                                for i in 2 to 8 loop
                                    temp_prod := v(i) * resize(temp_sum, 48);
                                    A(i)(row_idx) <= A(i)(row_idx) - resize(shift_right(temp_prod, Q), 48);
                                end loop;
                            end if;
                            row_idx <= row_idx + 1;
                        else
                            col_idx <= col_idx + 1;
                            state <= HOUSEHOLDER_COL3;
                        end if;

                    when HOUSEHOLDER_COL3 =>
                        norm_sq <= (others => '0');
                        for i in 3 to 8 loop
                            temp_prod := A(i)(3) * A(i)(3);
                            norm_sq <= norm_sq + shift_right(temp_prod, Q);
                        end loop;
                        sqrt_in <= resize(norm_sq, 48);
                        sqrt_start <= '1';
                        state <= WAIT_SQRT3;

                    when WAIT_SQRT3 =>
                        sqrt_start <= '0';
                        if sqrt_done = '1' then
                            if A(3)(18) >= 0 then
                                alpha <= -sqrt_out;
                            else
                                alpha <= sqrt_out;
                            end if;
                            v(3) <= A(3)(3) - alpha;
                            for i in 4 to 8 loop
                                v(i) <= A(i)(3);
                            end loop;
                            v_norm_sq <= (others => '0');
                            temp_prod := v(3) * v(3);
                            v_norm_sq <= shift_right(temp_prod, Q);
                            for i in 4 to 8 loop
                                temp_prod := v(i) * v(i);
                                v_norm_sq <= v_norm_sq + shift_right(temp_prod, Q);
                            end loop;
                            if v_norm_sq > to_signed(1, 96) then
                                beta <= resize(shift_left(to_signed(2, 48), Q) / v_norm_sq(47 downto 0), 48);
                            else
                                beta <= (others => '0');
                            end if;
                            R(3, 3) <= alpha;
                            state <= APPLY_REFLECTION3;
                            row_idx <= 0;
                        end if;

                    when APPLY_REFLECTION3 =>
                        if row_idx < 18 then
                            if row_idx > 3 then
                                temp_sum := (others => '0');
                                for i in 3 to 8 loop
                                    temp_prod := v(i) * A(i)(row_idx);
                                    temp_sum := temp_sum + shift_right(temp_prod, Q);
                                end loop;
                                temp_prod := beta * resize(temp_sum, 48);
                                temp_sum := shift_right(temp_prod, Q);
                                for i in 3 to 8 loop
                                    temp_prod := v(i) * resize(temp_sum, 48);
                                    A(i)(row_idx) <= A(i)(row_idx) - resize(shift_right(temp_prod, Q), 48);
                                end loop;
                            end if;
                            row_idx <= row_idx + 1;
                        else
                            col_idx <= col_idx + 1;
                            state <= HOUSEHOLDER_COL4;
                        end if;

                    when HOUSEHOLDER_COL4 =>
                        norm_sq <= (others => '0');
                        for i in 4 to 8 loop
                            temp_prod := A(i)(4) * A(i)(4);
                            norm_sq <= norm_sq + shift_right(temp_prod, Q);
                        end loop;
                        sqrt_in <= resize(norm_sq, 48);
                        sqrt_start <= '1';
                        state <= WAIT_SQRT4;

                    when WAIT_SQRT4 =>
                        sqrt_start <= '0';
                        if sqrt_done = '1' then
                            if A(4)(18) >= 0 then
                                alpha <= -sqrt_out;
                            else
                                alpha <= sqrt_out;
                            end if;
                            v(4) <= A(4)(4) - alpha;
                            for i in 5 to 8 loop
                                v(i) <= A(i)(4);
                            end loop;
                            v_norm_sq <= (others => '0');
                            temp_prod := v(4) * v(4);
                            v_norm_sq <= shift_right(temp_prod, Q);
                            for i in 5 to 8 loop
                                temp_prod := v(i) * v(i);
                                v_norm_sq <= v_norm_sq + shift_right(temp_prod, Q);
                            end loop;
                            if v_norm_sq > to_signed(1, 96) then
                                beta <= resize(shift_left(to_signed(2, 48), Q) / v_norm_sq(47 downto 0), 48);
                            else
                                beta <= (others => '0');
                            end if;
                            R(4, 4) <= alpha;
                            state <= APPLY_REFLECTION4;
                            row_idx <= 0;
                        end if;

                    when APPLY_REFLECTION4 =>
                        if row_idx < 18 then
                            if row_idx > 4 then
                                temp_sum := (others => '0');
                                for i in 4 to 8 loop
                                    temp_prod := v(i) * A(i)(row_idx);
                                    temp_sum := temp_sum + shift_right(temp_prod, Q);
                                end loop;
                                temp_prod := beta * resize(temp_sum, 48);
                                temp_sum := shift_right(temp_prod, Q);
                                for i in 4 to 8 loop
                                    temp_prod := v(i) * resize(temp_sum, 48);
                                    A(i)(row_idx) <= A(i)(row_idx) - resize(shift_right(temp_prod, Q), 48);
                                end loop;
                            end if;
                            row_idx <= row_idx + 1;
                        else
                            col_idx <= col_idx + 1;
                            state <= HOUSEHOLDER_COL5;
                        end if;

                    when HOUSEHOLDER_COL5 =>
                        norm_sq <= (others => '0');
                        for i in 5 to 8 loop
                            temp_prod := A(i)(5) * A(i)(5);
                            norm_sq <= norm_sq + shift_right(temp_prod, Q);
                        end loop;
                        sqrt_in <= resize(norm_sq, 48);
                        sqrt_start <= '1';
                        state <= WAIT_SQRT5;

                    when WAIT_SQRT5 =>
                        sqrt_start <= '0';
                        if sqrt_done = '1' then
                            if A(5)(18) >= 0 then
                                alpha <= -sqrt_out;
                            else
                                alpha <= sqrt_out;
                            end if;
                            v(5) <= A(5)(5) - alpha;
                            for i in 6 to 8 loop
                                v(i) <= A(i)(5);
                            end loop;
                            v_norm_sq <= (others => '0');
                            temp_prod := v(5) * v(5);
                            v_norm_sq <= shift_right(temp_prod, Q);
                            for i in 6 to 8 loop
                                temp_prod := v(i) * v(i);
                                v_norm_sq <= v_norm_sq + shift_right(temp_prod, Q);
                            end loop;
                            if v_norm_sq > to_signed(1, 96) then
                                beta <= resize(shift_left(to_signed(2, 48), Q) / v_norm_sq(47 downto 0), 48);
                            else
                                beta <= (others => '0');
                            end if;
                            R(5, 5) <= alpha;
                            state <= APPLY_REFLECTION5;
                            row_idx <= 0;
                        end if;

                    when APPLY_REFLECTION5 =>
                        if row_idx < 18 then
                            if row_idx > 5 then
                                temp_sum := (others => '0');
                                for i in 5 to 8 loop
                                    temp_prod := v(i) * A(i)(row_idx);
                                    temp_sum := temp_sum + shift_right(temp_prod, Q);
                                end loop;
                                temp_prod := beta * resize(temp_sum, 48);
                                temp_sum := shift_right(temp_prod, Q);
                                for i in 5 to 8 loop
                                    temp_prod := v(i) * resize(temp_sum, 48);
                                    A(i)(row_idx) <= A(i)(row_idx) - resize(shift_right(temp_prod, Q), 48);
                                end loop;
                            end if;
                            row_idx <= row_idx + 1;
                        else
                            col_idx <= col_idx + 1;
                            state <= HOUSEHOLDER_COL6;
                        end if;

                    when HOUSEHOLDER_COL6 =>
                        norm_sq <= (others => '0');
                        for i in 6 to 8 loop
                            temp_prod := A(i)(6) * A(i)(6);
                            norm_sq <= norm_sq + shift_right(temp_prod, Q);
                        end loop;
                        sqrt_in <= resize(norm_sq, 48);
                        sqrt_start <= '1';
                        state <= WAIT_SQRT6;

                    when WAIT_SQRT6 =>
                        sqrt_start <= '0';
                        if sqrt_done = '1' then
                            if A(6)(18) >= 0 then
                                alpha <= -sqrt_out;
                            else
                                alpha <= sqrt_out;
                            end if;
                            v(6) <= A(6)(6) - alpha;
                            for i in 7 to 8 loop
                                v(i) <= A(i)(6);
                            end loop;
                            v_norm_sq <= (others => '0');
                            temp_prod := v(6) * v(6);
                            v_norm_sq <= shift_right(temp_prod, Q);
                            for i in 7 to 8 loop
                                temp_prod := v(i) * v(i);
                                v_norm_sq <= v_norm_sq + shift_right(temp_prod, Q);
                            end loop;
                            if v_norm_sq > to_signed(1, 96) then
                                beta <= resize(shift_left(to_signed(2, 48), Q) / v_norm_sq(47 downto 0), 48);
                            else
                                beta <= (others => '0');
                            end if;
                            R(6, 6) <= alpha;
                            state <= APPLY_REFLECTION6;
                            row_idx <= 0;
                        end if;

                    when APPLY_REFLECTION6 =>
                        if row_idx < 18 then
                            if row_idx > 6 then
                                temp_sum := (others => '0');
                                for i in 6 to 8 loop
                                    temp_prod := v(i) * A(i)(row_idx);
                                    temp_sum := temp_sum + shift_right(temp_prod, Q);
                                end loop;
                                temp_prod := beta * resize(temp_sum, 48);
                                temp_sum := shift_right(temp_prod, Q);
                                for i in 6 to 8 loop
                                    temp_prod := v(i) * resize(temp_sum, 48);
                                    A(i)(row_idx) <= A(i)(row_idx) - resize(shift_right(temp_prod, Q), 48);
                                end loop;
                            end if;
                            row_idx <= row_idx + 1;
                        else
                            col_idx <= col_idx + 1;
                            state <= HOUSEHOLDER_COL7;
                        end if;

                    when HOUSEHOLDER_COL7 =>
                        norm_sq <= (others => '0');
                        for i in 7 to 8 loop
                            temp_prod := A(i)(7) * A(i)(7);
                            norm_sq <= norm_sq + shift_right(temp_prod, Q);
                        end loop;
                        sqrt_in <= resize(norm_sq, 48);
                        sqrt_start <= '1';
                        state <= WAIT_SQRT7;

                    when WAIT_SQRT7 =>
                        sqrt_start <= '0';
                        if sqrt_done = '1' then
                            if A(7)(18) >= 0 then
                                alpha <= -sqrt_out;
                            else
                                alpha <= sqrt_out;
                            end if;
                            v(7) <= A(7)(7) - alpha;
                            v(8) <= A(8)(7);
                            v_norm_sq <= (others => '0');
                            temp_prod := v(7) * v(7);
                            v_norm_sq <= shift_right(temp_prod, Q);
                            temp_prod := v(8) * v(8);
                            v_norm_sq <= v_norm_sq + shift_right(temp_prod, Q);
                            if v_norm_sq > to_signed(1, 96) then
                                beta <= resize(shift_left(to_signed(2, 48), Q) / v_norm_sq(47 downto 0), 48);
                            else
                                beta <= (others => '0');
                            end if;
                            R(7, 7) <= alpha;
                            state <= APPLY_REFLECTION7;
                            row_idx <= 0;
                        end if;

                    when APPLY_REFLECTION7 =>
                        if row_idx < 18 then
                            if row_idx > 7 then
                                temp_sum := (others => '0');
                                for i in 7 to 8 loop
                                    temp_prod := v(i) * A(i)(row_idx);
                                    temp_sum := temp_sum + shift_right(temp_prod, Q);
                                end loop;
                                temp_prod := beta * resize(temp_sum, 48);
                                temp_sum := shift_right(temp_prod, Q);
                                for i in 7 to 8 loop
                                    temp_prod := v(i) * resize(temp_sum, 48);
                                    A(i)(row_idx) <= A(i)(row_idx) - resize(shift_right(temp_prod, Q), 48);
                                end loop;
                            end if;
                            row_idx <= row_idx + 1;
                        else
                            col_idx <= col_idx + 1;
                            state <= HOUSEHOLDER_COL8;
                        end if;

                    when HOUSEHOLDER_COL8 =>
                        norm_sq <= (others => '0');
                        temp_prod := A(8)(7) * A(8)(7);
                        norm_sq <= shift_right(temp_prod, Q);
                        sqrt_in <= resize(norm_sq, 48);
                        sqrt_start <= '1';
                        state <= WAIT_SQRT8;

                    when WAIT_SQRT8 =>
                        sqrt_start <= '0';
                        if sqrt_done = '1' then
                            if A(8)(8) >= 0 then
                                alpha <= -sqrt_out;
                            else
                                alpha <= sqrt_out;
                            end if;
                            v(8) <= A(8)(8) - alpha;
                            v_norm_sq <= (others => '0');
                            temp_prod := v(8) * v(8);
                            v_norm_sq <= shift_right(temp_prod, Q);
                            if v_norm_sq > to_signed(1, 96) then
                                beta <= resize(shift_left(to_signed(2, 48), Q) / v_norm_sq(47 downto 0), 48);
                            else
                                beta <= (others => '0');
                            end if;
                            R(8, 8) <= alpha;
                            state <= APPLY_REFLECTION8;
                            row_idx <= 0;
                        end if;

                    when APPLY_REFLECTION8 =>
                        if row_idx < 18 then
                            if row_idx > 8 then
                                temp_sum := (others => '0');
                                temp_prod := v(8) * A(8)(row_idx);
                                temp_sum := shift_right(temp_prod, Q);
                                temp_prod := beta * resize(temp_sum, 48);
                                temp_sum := shift_right(temp_prod, Q);
                                temp_prod := v(8) * resize(temp_sum, 48);
                                A(8)(row_idx) <= A(8)(row_idx) - resize(shift_right(temp_prod, Q), 48);
                            end if;
                            row_idx <= row_idx + 1;
                        else
                            state <= EXTRACT_R_TRANSPOSE;
                        end if;

                    when EXTRACT_R_TRANSPOSE =>

                        report "EXTRACT: A(0)(0)=" & integer'image(to_integer(A(0)(0))) & " A(0)(1)=" & integer'image(to_integer(A(0)(1))) & " A(1)(1)=" & integer'image(to_integer(A(1)(1)));

                        l11_out <= A(0)(0);

                        l21_out <= A(0)(1); l22_out <= A(1)(1);

                        l31_out <= A(0)(2); l32_out <= A(1)(2); l33_out <= A(2)(2);

                        l41_out <= A(0)(3); l42_out <= A(1)(3); l43_out <= A(2)(3); l44_out <= A(3)(3);

                        l51_out <= A(0)(4); l52_out <= A(1)(4); l53_out <= A(2)(4); l54_out <= A(3)(4); l55_out <= A(4)(4);

                        l61_out <= A(0)(5); l62_out <= A(1)(5); l63_out <= A(2)(5); l64_out <= A(3)(5); l65_out <= A(4)(5); l66_out <= A(5)(5);

                        l71_out <= A(0)(6); l72_out <= A(1)(6); l73_out <= A(2)(6); l74_out <= A(3)(6); l75_out <= A(4)(6); l76_out <= A(5)(6); l77_out <= A(6)(6);

                        l81_out <= A(0)(7); l82_out <= A(1)(7); l83_out <= A(2)(7); l84_out <= A(3)(7); l85_out <= A(4)(7); l86_out <= A(5)(7); l87_out <= A(6)(7); l88_out <= A(7)(7);

                        l91_out <= A(0)(8); l92_out <= A(1)(8); l93_out <= A(2)(8); l94_out <= A(3)(8); l95_out <= A(4)(8); l96_out <= A(5)(8); l97_out <= A(6)(8); l98_out <= A(7)(8); l99_out <= A(8)(8);

                        state <= FINISHED;

                    when FINISHED =>
                        report "QR_DECOMP: *** FINISHED STATE REACHED *** start=" & std_logic'image(start) severity note;
                        done <= '1';
                        if start = '0' then
                            report "QR_DECOMP: FINISHED -> IDLE (start went low)" severity note;
                            state <= IDLE;
                        end if;

                    when others =>
                        report "QR_DECOMP: *** UNEXPECTED STATE *** state=" & state_type'image(state) &
                               " Going to IDLE" severity error;
                        state <= IDLE;

                end case;
            end if;
        end if;
    end process;

end Behavioral;
