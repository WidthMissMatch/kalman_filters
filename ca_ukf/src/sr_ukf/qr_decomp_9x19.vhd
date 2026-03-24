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

    constant ROUND_144 : signed(143 downto 0) := shift_left(to_signed(1, 144), Q - 1);

    constant W_SQRT : signed(47 downto 0) := to_signed(3954427, 48);

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
                        COMPUTE_ROW_NORM, WAIT_SQRT, BUILD_V_BETA,
                        APPLY_ROW_REFLECTION,
                        EXTRACT_L, FINISHED);
    signal state : state_type := IDLE;

    type row_type is array (0 to 17) of signed(95 downto 0);
    type matrix_type is array (0 to 8) of row_type;
    signal A : matrix_type := (others => (others => (others => '0')));

    type vector_18_type is array (0 to 17) of signed(47 downto 0);
    signal v : vector_18_type := (others => (others => '0'));

    signal beta : signed(47 downto 0) := (others => '0');

    type vector_9_type is array (0 to 8) of signed(47 downto 0);
    signal alpha_diag : vector_9_type := (others => (others => '0'));

    signal sqrt_start : std_logic := '0';
    signal sqrt_in : signed(47 downto 0) := (others => '0');
    signal sqrt_out : signed(47 downto 0);
    signal sqrt_done : std_logic;

    signal row_k : integer range 0 to 8 := 0;

    signal ref_i : integer range 0 to 9 := 0;

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
        variable norm_v : signed(95 downto 0);
        variable alpha_var : signed(47 downto 0);
        variable v_first : signed(47 downto 0);
        variable vnorm_v : signed(95 downto 0);
        variable dot_v : signed(95 downto 0);
        variable scale_v : signed(95 downto 0);
        variable beta_numer : signed(95 downto 0);

        variable prod_144 : signed(143 downto 0);
        variable a_extract : signed(47 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                done <= '0';
                sqrt_start <= '0';
                row_k <= 0;
                ref_i <= 0;
            else
                case state is

                    when IDLE =>
                        done <= '0';
                        sqrt_start <= '0';
                        if start = '1' then
                            state <= BUILD_WEIGHTED_A;
                        end if;

                    when BUILD_WEIGHTED_A =>

                        delta := chi1_x_pos - x_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(0)(0) <= weighted_delta;
                        delta := chi1_x_vel - x_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(1)(0) <= weighted_delta;
                        delta := chi1_x_acc - x_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(2)(0) <= weighted_delta;
                        delta := chi1_y_pos - y_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(3)(0) <= weighted_delta;
                        delta := chi1_y_vel - y_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(4)(0) <= weighted_delta;
                        delta := chi1_y_acc - y_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(5)(0) <= weighted_delta;
                        delta := chi1_z_pos - z_pos_mean;
                        weighted_delta := W_SQRT * delta;
                        A(6)(0) <= weighted_delta;
                        delta := chi1_z_vel - z_vel_mean;
                        weighted_delta := W_SQRT * delta;
                        A(7)(0) <= weighted_delta;
                        delta := chi1_z_acc - z_acc_mean;
                        weighted_delta := W_SQRT * delta;
                        A(8)(0) <= weighted_delta;

                        delta := chi2_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(1) <= weighted_delta;
                        delta := chi2_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(1) <= weighted_delta;
                        delta := chi2_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(1) <= weighted_delta;
                        delta := chi2_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(1) <= weighted_delta;
                        delta := chi2_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(1) <= weighted_delta;
                        delta := chi2_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(1) <= weighted_delta;
                        delta := chi2_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(1) <= weighted_delta;
                        delta := chi2_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(1) <= weighted_delta;
                        delta := chi2_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(1) <= weighted_delta;

                        delta := chi3_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(2) <= weighted_delta;
                        delta := chi3_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(2) <= weighted_delta;
                        delta := chi3_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(2) <= weighted_delta;
                        delta := chi3_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(2) <= weighted_delta;
                        delta := chi3_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(2) <= weighted_delta;
                        delta := chi3_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(2) <= weighted_delta;
                        delta := chi3_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(2) <= weighted_delta;
                        delta := chi3_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(2) <= weighted_delta;
                        delta := chi3_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(2) <= weighted_delta;

                        delta := chi4_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(3) <= weighted_delta;
                        delta := chi4_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(3) <= weighted_delta;
                        delta := chi4_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(3) <= weighted_delta;
                        delta := chi4_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(3) <= weighted_delta;
                        delta := chi4_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(3) <= weighted_delta;
                        delta := chi4_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(3) <= weighted_delta;
                        delta := chi4_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(3) <= weighted_delta;
                        delta := chi4_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(3) <= weighted_delta;
                        delta := chi4_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(3) <= weighted_delta;

                        delta := chi5_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(4) <= weighted_delta;
                        delta := chi5_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(4) <= weighted_delta;
                        delta := chi5_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(4) <= weighted_delta;
                        delta := chi5_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(4) <= weighted_delta;
                        delta := chi5_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(4) <= weighted_delta;
                        delta := chi5_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(4) <= weighted_delta;
                        delta := chi5_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(4) <= weighted_delta;
                        delta := chi5_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(4) <= weighted_delta;
                        delta := chi5_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(4) <= weighted_delta;

                        delta := chi6_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(5) <= weighted_delta;
                        delta := chi6_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(5) <= weighted_delta;
                        delta := chi6_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(5) <= weighted_delta;
                        delta := chi6_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(5) <= weighted_delta;
                        delta := chi6_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(5) <= weighted_delta;
                        delta := chi6_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(5) <= weighted_delta;
                        delta := chi6_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(5) <= weighted_delta;
                        delta := chi6_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(5) <= weighted_delta;
                        delta := chi6_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(5) <= weighted_delta;

                        delta := chi7_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(6) <= weighted_delta;
                        delta := chi7_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(6) <= weighted_delta;
                        delta := chi7_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(6) <= weighted_delta;
                        delta := chi7_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(6) <= weighted_delta;
                        delta := chi7_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(6) <= weighted_delta;
                        delta := chi7_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(6) <= weighted_delta;
                        delta := chi7_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(6) <= weighted_delta;
                        delta := chi7_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(6) <= weighted_delta;
                        delta := chi7_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(6) <= weighted_delta;

                        delta := chi8_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(7) <= weighted_delta;
                        delta := chi8_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(7) <= weighted_delta;
                        delta := chi8_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(7) <= weighted_delta;
                        delta := chi8_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(7) <= weighted_delta;
                        delta := chi8_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(7) <= weighted_delta;
                        delta := chi8_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(7) <= weighted_delta;
                        delta := chi8_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(7) <= weighted_delta;
                        delta := chi8_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(7) <= weighted_delta;
                        delta := chi8_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(7) <= weighted_delta;

                        delta := chi9_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(8) <= weighted_delta;
                        delta := chi9_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(8) <= weighted_delta;
                        delta := chi9_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(8) <= weighted_delta;
                        delta := chi9_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(8) <= weighted_delta;
                        delta := chi9_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(8) <= weighted_delta;
                        delta := chi9_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(8) <= weighted_delta;
                        delta := chi9_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(8) <= weighted_delta;
                        delta := chi9_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(8) <= weighted_delta;
                        delta := chi9_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(8) <= weighted_delta;

                        delta := chi10_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(9) <= weighted_delta;
                        delta := chi10_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(9) <= weighted_delta;
                        delta := chi10_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(9) <= weighted_delta;
                        delta := chi10_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(9) <= weighted_delta;
                        delta := chi10_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(9) <= weighted_delta;
                        delta := chi10_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(9) <= weighted_delta;
                        delta := chi10_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(9) <= weighted_delta;
                        delta := chi10_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(9) <= weighted_delta;
                        delta := chi10_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(9) <= weighted_delta;

                        delta := chi11_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(10) <= weighted_delta;
                        delta := chi11_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(10) <= weighted_delta;
                        delta := chi11_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(10) <= weighted_delta;
                        delta := chi11_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(10) <= weighted_delta;
                        delta := chi11_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(10) <= weighted_delta;
                        delta := chi11_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(10) <= weighted_delta;
                        delta := chi11_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(10) <= weighted_delta;
                        delta := chi11_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(10) <= weighted_delta;
                        delta := chi11_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(10) <= weighted_delta;

                        delta := chi12_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(11) <= weighted_delta;
                        delta := chi12_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(11) <= weighted_delta;
                        delta := chi12_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(11) <= weighted_delta;
                        delta := chi12_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(11) <= weighted_delta;
                        delta := chi12_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(11) <= weighted_delta;
                        delta := chi12_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(11) <= weighted_delta;
                        delta := chi12_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(11) <= weighted_delta;
                        delta := chi12_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(11) <= weighted_delta;
                        delta := chi12_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(11) <= weighted_delta;

                        delta := chi13_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(12) <= weighted_delta;
                        delta := chi13_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(12) <= weighted_delta;
                        delta := chi13_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(12) <= weighted_delta;
                        delta := chi13_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(12) <= weighted_delta;
                        delta := chi13_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(12) <= weighted_delta;
                        delta := chi13_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(12) <= weighted_delta;
                        delta := chi13_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(12) <= weighted_delta;
                        delta := chi13_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(12) <= weighted_delta;
                        delta := chi13_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(12) <= weighted_delta;

                        delta := chi14_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(13) <= weighted_delta;
                        delta := chi14_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(13) <= weighted_delta;
                        delta := chi14_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(13) <= weighted_delta;
                        delta := chi14_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(13) <= weighted_delta;
                        delta := chi14_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(13) <= weighted_delta;
                        delta := chi14_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(13) <= weighted_delta;
                        delta := chi14_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(13) <= weighted_delta;
                        delta := chi14_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(13) <= weighted_delta;
                        delta := chi14_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(13) <= weighted_delta;

                        delta := chi15_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(14) <= weighted_delta;
                        delta := chi15_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(14) <= weighted_delta;
                        delta := chi15_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(14) <= weighted_delta;
                        delta := chi15_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(14) <= weighted_delta;
                        delta := chi15_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(14) <= weighted_delta;
                        delta := chi15_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(14) <= weighted_delta;
                        delta := chi15_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(14) <= weighted_delta;
                        delta := chi15_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(14) <= weighted_delta;
                        delta := chi15_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(14) <= weighted_delta;

                        delta := chi16_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(15) <= weighted_delta;
                        delta := chi16_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(15) <= weighted_delta;
                        delta := chi16_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(15) <= weighted_delta;
                        delta := chi16_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(15) <= weighted_delta;
                        delta := chi16_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(15) <= weighted_delta;
                        delta := chi16_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(15) <= weighted_delta;
                        delta := chi16_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(15) <= weighted_delta;
                        delta := chi16_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(15) <= weighted_delta;
                        delta := chi16_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(15) <= weighted_delta;

                        delta := chi17_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(16) <= weighted_delta;
                        delta := chi17_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(16) <= weighted_delta;
                        delta := chi17_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(16) <= weighted_delta;
                        delta := chi17_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(16) <= weighted_delta;
                        delta := chi17_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(16) <= weighted_delta;
                        delta := chi17_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(16) <= weighted_delta;
                        delta := chi17_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(16) <= weighted_delta;
                        delta := chi17_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(16) <= weighted_delta;
                        delta := chi17_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(16) <= weighted_delta;

                        delta := chi18_x_pos - x_pos_mean; weighted_delta := W_SQRT * delta; A(0)(17) <= weighted_delta;
                        delta := chi18_x_vel - x_vel_mean; weighted_delta := W_SQRT * delta; A(1)(17) <= weighted_delta;
                        delta := chi18_x_acc - x_acc_mean; weighted_delta := W_SQRT * delta; A(2)(17) <= weighted_delta;
                        delta := chi18_y_pos - y_pos_mean; weighted_delta := W_SQRT * delta; A(3)(17) <= weighted_delta;
                        delta := chi18_y_vel - y_vel_mean; weighted_delta := W_SQRT * delta; A(4)(17) <= weighted_delta;
                        delta := chi18_y_acc - y_acc_mean; weighted_delta := W_SQRT * delta; A(5)(17) <= weighted_delta;
                        delta := chi18_z_pos - z_pos_mean; weighted_delta := W_SQRT * delta; A(6)(17) <= weighted_delta;
                        delta := chi18_z_vel - z_vel_mean; weighted_delta := W_SQRT * delta; A(7)(17) <= weighted_delta;
                        delta := chi18_z_acc - z_acc_mean; weighted_delta := W_SQRT * delta; A(8)(17) <= weighted_delta;

                        row_k <= 0;
                        state <= COMPUTE_ROW_NORM;

                    when COMPUTE_ROW_NORM =>

                        norm_v := (others => '0');
                        for j in 0 to 17 loop
                            if j >= row_k then
                                a_extract := resize(shift_right(A(row_k)(j), Q), 48);
                                temp_prod := a_extract * a_extract;
                                norm_v := norm_v + shift_right(temp_prod, Q);
                            end if;
                        end loop;
                        sqrt_in <= resize(norm_v, 48);
                        sqrt_start <= '1';
                        state <= WAIT_SQRT;

                    when WAIT_SQRT =>
                        sqrt_start <= '0';
                        if sqrt_done = '1' then
                            state <= BUILD_V_BETA;
                        end if;

                    when BUILD_V_BETA =>

                        a_extract := resize(shift_right(A(row_k)(row_k), Q), 48);
                        if a_extract >= 0 then
                            alpha_var := -sqrt_out;
                        else
                            alpha_var := sqrt_out;
                        end if;
                        alpha_diag(row_k) <= alpha_var;

                        v_first := a_extract - alpha_var;
                        v(row_k) <= v_first;
                        for j in 0 to 17 loop
                            if j > row_k then
                                v(j) <= resize(shift_right(A(row_k)(j), Q), 48);
                            end if;
                        end loop;

                        vnorm_v := (others => '0');
                        temp_prod := v_first * v_first;
                        vnorm_v := vnorm_v + shift_right(temp_prod, Q);
                        for j in 0 to 17 loop
                            if j > row_k then
                                a_extract := resize(shift_right(A(row_k)(j), Q), 48);
                                temp_prod := a_extract * a_extract;
                                vnorm_v := vnorm_v + shift_right(temp_prod, Q);
                            end if;
                        end loop;

                        if vnorm_v > to_signed(0, 96) then
                            beta_numer := shift_left(to_signed(2, 96), 2*Q);
                            beta <= resize(beta_numer / vnorm_v, 48);
                        else
                            beta <= (others => '0');
                        end if;

                        ref_i <= row_k + 1;
                        state <= APPLY_ROW_REFLECTION;

                    when APPLY_ROW_REFLECTION =>

                        if ref_i <= 8 then

                            dot_v := (others => '0');
                            for j in 0 to 17 loop
                                if j >= row_k then
                                    prod_144 := A(ref_i)(j) * v(j);
                                    dot_v := dot_v + resize(shift_right(prod_144 + ROUND_144, Q), 96);
                                end if;
                            end loop;

                            prod_144 := beta * dot_v;
                            scale_v := resize(shift_right(prod_144 + ROUND_144, Q), 96);

                            for j in 0 to 17 loop
                                if j >= row_k then
                                    prod_144 := scale_v * v(j);
                                    A(ref_i)(j) <= A(ref_i)(j) - resize(shift_right(prod_144 + ROUND_144, Q), 96);
                                end if;
                            end loop;

                            ref_i <= ref_i + 1;
                        else

                            if row_k < 8 then
                                row_k <= row_k + 1;
                                state <= COMPUTE_ROW_NORM;
                            else
                                state <= EXTRACT_L;
                            end if;
                        end if;

                    when EXTRACT_L =>

                        if alpha_diag(0) < 0 then
                            l11_out <= -alpha_diag(0);
                        else
                            l11_out <= alpha_diag(0);
                        end if;

                        if alpha_diag(0) < 0 then
                            l21_out <= -resize(shift_right(A(1)(0), Q), 48);
                        else
                            l21_out <= resize(shift_right(A(1)(0), Q), 48);
                        end if;
                        if alpha_diag(1) < 0 then
                            l22_out <= -alpha_diag(1);
                        else
                            l22_out <= alpha_diag(1);
                        end if;

                        if alpha_diag(0) < 0 then l31_out <= -resize(shift_right(A(2)(0), Q), 48); else l31_out <= resize(shift_right(A(2)(0), Q), 48); end if;
                        if alpha_diag(1) < 0 then l32_out <= -resize(shift_right(A(2)(1), Q), 48); else l32_out <= resize(shift_right(A(2)(1), Q), 48); end if;
                        if alpha_diag(2) < 0 then l33_out <= -alpha_diag(2); else l33_out <= alpha_diag(2); end if;

                        if alpha_diag(0) < 0 then l41_out <= -resize(shift_right(A(3)(0), Q), 48); else l41_out <= resize(shift_right(A(3)(0), Q), 48); end if;
                        if alpha_diag(1) < 0 then l42_out <= -resize(shift_right(A(3)(1), Q), 48); else l42_out <= resize(shift_right(A(3)(1), Q), 48); end if;
                        if alpha_diag(2) < 0 then l43_out <= -resize(shift_right(A(3)(2), Q), 48); else l43_out <= resize(shift_right(A(3)(2), Q), 48); end if;
                        if alpha_diag(3) < 0 then l44_out <= -alpha_diag(3); else l44_out <= alpha_diag(3); end if;

                        if alpha_diag(0) < 0 then l51_out <= -resize(shift_right(A(4)(0), Q), 48); else l51_out <= resize(shift_right(A(4)(0), Q), 48); end if;
                        if alpha_diag(1) < 0 then l52_out <= -resize(shift_right(A(4)(1), Q), 48); else l52_out <= resize(shift_right(A(4)(1), Q), 48); end if;
                        if alpha_diag(2) < 0 then l53_out <= -resize(shift_right(A(4)(2), Q), 48); else l53_out <= resize(shift_right(A(4)(2), Q), 48); end if;
                        if alpha_diag(3) < 0 then l54_out <= -resize(shift_right(A(4)(3), Q), 48); else l54_out <= resize(shift_right(A(4)(3), Q), 48); end if;
                        if alpha_diag(4) < 0 then l55_out <= -alpha_diag(4); else l55_out <= alpha_diag(4); end if;

                        if alpha_diag(0) < 0 then l61_out <= -resize(shift_right(A(5)(0), Q), 48); else l61_out <= resize(shift_right(A(5)(0), Q), 48); end if;
                        if alpha_diag(1) < 0 then l62_out <= -resize(shift_right(A(5)(1), Q), 48); else l62_out <= resize(shift_right(A(5)(1), Q), 48); end if;
                        if alpha_diag(2) < 0 then l63_out <= -resize(shift_right(A(5)(2), Q), 48); else l63_out <= resize(shift_right(A(5)(2), Q), 48); end if;
                        if alpha_diag(3) < 0 then l64_out <= -resize(shift_right(A(5)(3), Q), 48); else l64_out <= resize(shift_right(A(5)(3), Q), 48); end if;
                        if alpha_diag(4) < 0 then l65_out <= -resize(shift_right(A(5)(4), Q), 48); else l65_out <= resize(shift_right(A(5)(4), Q), 48); end if;
                        if alpha_diag(5) < 0 then l66_out <= -alpha_diag(5); else l66_out <= alpha_diag(5); end if;

                        if alpha_diag(0) < 0 then l71_out <= -resize(shift_right(A(6)(0), Q), 48); else l71_out <= resize(shift_right(A(6)(0), Q), 48); end if;
                        if alpha_diag(1) < 0 then l72_out <= -resize(shift_right(A(6)(1), Q), 48); else l72_out <= resize(shift_right(A(6)(1), Q), 48); end if;
                        if alpha_diag(2) < 0 then l73_out <= -resize(shift_right(A(6)(2), Q), 48); else l73_out <= resize(shift_right(A(6)(2), Q), 48); end if;
                        if alpha_diag(3) < 0 then l74_out <= -resize(shift_right(A(6)(3), Q), 48); else l74_out <= resize(shift_right(A(6)(3), Q), 48); end if;
                        if alpha_diag(4) < 0 then l75_out <= -resize(shift_right(A(6)(4), Q), 48); else l75_out <= resize(shift_right(A(6)(4), Q), 48); end if;
                        if alpha_diag(5) < 0 then l76_out <= -resize(shift_right(A(6)(5), Q), 48); else l76_out <= resize(shift_right(A(6)(5), Q), 48); end if;
                        if alpha_diag(6) < 0 then l77_out <= -alpha_diag(6); else l77_out <= alpha_diag(6); end if;

                        if alpha_diag(0) < 0 then l81_out <= -resize(shift_right(A(7)(0), Q), 48); else l81_out <= resize(shift_right(A(7)(0), Q), 48); end if;
                        if alpha_diag(1) < 0 then l82_out <= -resize(shift_right(A(7)(1), Q), 48); else l82_out <= resize(shift_right(A(7)(1), Q), 48); end if;
                        if alpha_diag(2) < 0 then l83_out <= -resize(shift_right(A(7)(2), Q), 48); else l83_out <= resize(shift_right(A(7)(2), Q), 48); end if;
                        if alpha_diag(3) < 0 then l84_out <= -resize(shift_right(A(7)(3), Q), 48); else l84_out <= resize(shift_right(A(7)(3), Q), 48); end if;
                        if alpha_diag(4) < 0 then l85_out <= -resize(shift_right(A(7)(4), Q), 48); else l85_out <= resize(shift_right(A(7)(4), Q), 48); end if;
                        if alpha_diag(5) < 0 then l86_out <= -resize(shift_right(A(7)(5), Q), 48); else l86_out <= resize(shift_right(A(7)(5), Q), 48); end if;
                        if alpha_diag(6) < 0 then l87_out <= -resize(shift_right(A(7)(6), Q), 48); else l87_out <= resize(shift_right(A(7)(6), Q), 48); end if;
                        if alpha_diag(7) < 0 then l88_out <= -alpha_diag(7); else l88_out <= alpha_diag(7); end if;

                        if alpha_diag(0) < 0 then l91_out <= -resize(shift_right(A(8)(0), Q), 48); else l91_out <= resize(shift_right(A(8)(0), Q), 48); end if;
                        if alpha_diag(1) < 0 then l92_out <= -resize(shift_right(A(8)(1), Q), 48); else l92_out <= resize(shift_right(A(8)(1), Q), 48); end if;
                        if alpha_diag(2) < 0 then l93_out <= -resize(shift_right(A(8)(2), Q), 48); else l93_out <= resize(shift_right(A(8)(2), Q), 48); end if;
                        if alpha_diag(3) < 0 then l94_out <= -resize(shift_right(A(8)(3), Q), 48); else l94_out <= resize(shift_right(A(8)(3), Q), 48); end if;
                        if alpha_diag(4) < 0 then l95_out <= -resize(shift_right(A(8)(4), Q), 48); else l95_out <= resize(shift_right(A(8)(4), Q), 48); end if;
                        if alpha_diag(5) < 0 then l96_out <= -resize(shift_right(A(8)(5), Q), 48); else l96_out <= resize(shift_right(A(8)(5), Q), 48); end if;
                        if alpha_diag(6) < 0 then l97_out <= -resize(shift_right(A(8)(6), Q), 48); else l97_out <= resize(shift_right(A(8)(6), Q), 48); end if;
                        if alpha_diag(7) < 0 then l98_out <= -resize(shift_right(A(8)(7), Q), 48); else l98_out <= resize(shift_right(A(8)(7), Q), 48); end if;
                        if alpha_diag(8) < 0 then l99_out <= -alpha_diag(8); else l99_out <= alpha_diag(8); end if;

                        state <= FINISHED;

                    when FINISHED =>
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
