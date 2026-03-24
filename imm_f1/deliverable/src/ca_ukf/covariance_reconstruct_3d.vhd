library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.TEXTIO.ALL;

entity covariance_reconstruct_3d is
    port (
        clk   : in  std_logic;
        start : in  std_logic;

        x_pos_mean, x_vel_mean, x_acc_mean : in signed(47 downto 0);
        y_pos_mean, y_vel_mean, y_acc_mean : in signed(47 downto 0);
        z_pos_mean, z_vel_mean, z_acc_mean : in signed(47 downto 0);

        chi0_x_pos_pred, chi0_x_vel_pred, chi0_x_acc_pred, chi0_y_pos_pred, chi0_y_vel_pred, chi0_y_acc_pred, chi0_z_pos_pred, chi0_z_vel_pred, chi0_z_acc_pred : in signed(47 downto 0);
        chi1_x_pos_pred, chi1_x_vel_pred, chi1_x_acc_pred, chi1_y_pos_pred, chi1_y_vel_pred, chi1_y_acc_pred, chi1_z_pos_pred, chi1_z_vel_pred, chi1_z_acc_pred : in signed(47 downto 0);
        chi2_x_pos_pred, chi2_x_vel_pred, chi2_x_acc_pred, chi2_y_pos_pred, chi2_y_vel_pred, chi2_y_acc_pred, chi2_z_pos_pred, chi2_z_vel_pred, chi2_z_acc_pred : in signed(47 downto 0);
        chi3_x_pos_pred, chi3_x_vel_pred, chi3_x_acc_pred, chi3_y_pos_pred, chi3_y_vel_pred, chi3_y_acc_pred, chi3_z_pos_pred, chi3_z_vel_pred, chi3_z_acc_pred : in signed(47 downto 0);
        chi4_x_pos_pred, chi4_x_vel_pred, chi4_x_acc_pred, chi4_y_pos_pred, chi4_y_vel_pred, chi4_y_acc_pred, chi4_z_pos_pred, chi4_z_vel_pred, chi4_z_acc_pred : in signed(47 downto 0);
        chi5_x_pos_pred, chi5_x_vel_pred, chi5_x_acc_pred, chi5_y_pos_pred, chi5_y_vel_pred, chi5_y_acc_pred, chi5_z_pos_pred, chi5_z_vel_pred, chi5_z_acc_pred : in signed(47 downto 0);
        chi6_x_pos_pred, chi6_x_vel_pred, chi6_x_acc_pred, chi6_y_pos_pred, chi6_y_vel_pred, chi6_y_acc_pred, chi6_z_pos_pred, chi6_z_vel_pred, chi6_z_acc_pred : in signed(47 downto 0);
        chi7_x_pos_pred, chi7_x_vel_pred, chi7_x_acc_pred, chi7_y_pos_pred, chi7_y_vel_pred, chi7_y_acc_pred, chi7_z_pos_pred, chi7_z_vel_pred, chi7_z_acc_pred : in signed(47 downto 0);
        chi8_x_pos_pred, chi8_x_vel_pred, chi8_x_acc_pred, chi8_y_pos_pred, chi8_y_vel_pred, chi8_y_acc_pred, chi8_z_pos_pred, chi8_z_vel_pred, chi8_z_acc_pred : in signed(47 downto 0);
        chi9_x_pos_pred, chi9_x_vel_pred, chi9_x_acc_pred, chi9_y_pos_pred, chi9_y_vel_pred, chi9_y_acc_pred, chi9_z_pos_pred, chi9_z_vel_pred, chi9_z_acc_pred : in signed(47 downto 0);
        chi10_x_pos_pred, chi10_x_vel_pred, chi10_x_acc_pred, chi10_y_pos_pred, chi10_y_vel_pred, chi10_y_acc_pred, chi10_z_pos_pred, chi10_z_vel_pred, chi10_z_acc_pred : in signed(47 downto 0);
        chi11_x_pos_pred, chi11_x_vel_pred, chi11_x_acc_pred, chi11_y_pos_pred, chi11_y_vel_pred, chi11_y_acc_pred, chi11_z_pos_pred, chi11_z_vel_pred, chi11_z_acc_pred : in signed(47 downto 0);
        chi12_x_pos_pred, chi12_x_vel_pred, chi12_x_acc_pred, chi12_y_pos_pred, chi12_y_vel_pred, chi12_y_acc_pred, chi12_z_pos_pred, chi12_z_vel_pred, chi12_z_acc_pred : in signed(47 downto 0);
        chi13_x_pos_pred, chi13_x_vel_pred, chi13_x_acc_pred, chi13_y_pos_pred, chi13_y_vel_pred, chi13_y_acc_pred, chi13_z_pos_pred, chi13_z_vel_pred, chi13_z_acc_pred : in signed(47 downto 0);
        chi14_x_pos_pred, chi14_x_vel_pred, chi14_x_acc_pred, chi14_y_pos_pred, chi14_y_vel_pred, chi14_y_acc_pred, chi14_z_pos_pred, chi14_z_vel_pred, chi14_z_acc_pred : in signed(47 downto 0);
        chi15_x_pos_pred, chi15_x_vel_pred, chi15_x_acc_pred, chi15_y_pos_pred, chi15_y_vel_pred, chi15_y_acc_pred, chi15_z_pos_pred, chi15_z_vel_pred, chi15_z_acc_pred : in signed(47 downto 0);
        chi16_x_pos_pred, chi16_x_vel_pred, chi16_x_acc_pred, chi16_y_pos_pred, chi16_y_vel_pred, chi16_y_acc_pred, chi16_z_pos_pred, chi16_z_vel_pred, chi16_z_acc_pred : in signed(47 downto 0);
        chi17_x_pos_pred, chi17_x_vel_pred, chi17_x_acc_pred, chi17_y_pos_pred, chi17_y_vel_pred, chi17_y_acc_pred, chi17_z_pos_pred, chi17_z_vel_pred, chi17_z_acc_pred : in signed(47 downto 0);
        chi18_x_pos_pred, chi18_x_vel_pred, chi18_x_acc_pred, chi18_y_pos_pred, chi18_y_vel_pred, chi18_y_acc_pred, chi18_z_pos_pred, chi18_z_vel_pred, chi18_z_acc_pred : in signed(47 downto 0);

        p11_out, p12_out, p13_out, p14_out, p15_out, p16_out, p17_out, p18_out, p19_out : out signed(47 downto 0);
        p22_out, p23_out, p24_out, p25_out, p26_out, p27_out, p28_out, p29_out           : out signed(47 downto 0);
        p33_out, p34_out, p35_out, p36_out, p37_out, p38_out, p39_out                    : out signed(47 downto 0);
        p44_out, p45_out, p46_out, p47_out, p48_out, p49_out                             : out signed(47 downto 0);
        p55_out, p56_out, p57_out, p58_out, p59_out                                      : out signed(47 downto 0);
        p66_out, p67_out, p68_out, p69_out                                               : out signed(47 downto 0);
        p77_out, p78_out, p79_out                                                        : out signed(47 downto 0);
        p88_out, p89_out                                                                 : out signed(47 downto 0);
        p99_out                                                                          : out signed(47 downto 0);

        done : out std_logic
    );
end covariance_reconstruct_3d;

architecture Behavioral of covariance_reconstruct_3d is

    constant W0 : signed(47 downto 0) := to_signed(33554432, 48);
    constant W1 : signed(47 downto 0) := to_signed(932067, 48);
    constant Q : integer := 24;

    type state_type is (IDLE, LATCH_INPUTS, COMPUTE_DELTA, COMPUTE_OUTER, WEIGHT, ADD, NORMALIZE, FINISHED);
    signal state : state_type := IDLE;
    signal accumulate_idx : integer range 0 to 18 := 0;

    signal x_pos_mean_reg, x_vel_mean_reg, x_acc_mean_reg : signed(47 downto 0) := (others => '0');
    signal y_pos_mean_reg, y_vel_mean_reg, y_acc_mean_reg : signed(47 downto 0) := (others => '0');
    signal z_pos_mean_reg, z_vel_mean_reg, z_acc_mean_reg : signed(47 downto 0) := (others => '0');

    type sigma_point_array is array (0 to 18) of signed(47 downto 0);
    signal chi_x_pos, chi_x_vel, chi_x_acc : sigma_point_array := (others => (others => '0'));
    signal chi_y_pos, chi_y_vel, chi_y_acc : sigma_point_array := (others => (others => '0'));
    signal chi_z_pos, chi_z_vel, chi_z_acc : sigma_point_array := (others => (others => '0'));

    type weight_array is array (0 to 18) of signed(47 downto 0);
    constant WEIGHTS : weight_array := (W0, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1);
    signal current_weight_reg : signed(47 downto 0) := (others => '0');

    signal delta_x_pos, delta_x_vel, delta_x_acc : signed(47 downto 0) := (others => '0');
    signal delta_y_pos, delta_y_vel, delta_y_acc : signed(47 downto 0) := (others => '0');
    signal delta_z_pos, delta_z_vel, delta_z_acc : signed(47 downto 0) := (others => '0');

    signal outer_11, outer_12, outer_13, outer_14, outer_15, outer_16, outer_17, outer_18, outer_19 : signed(111 downto 0) := (others => '0');
    signal outer_22, outer_23, outer_24, outer_25, outer_26, outer_27, outer_28, outer_29           : signed(111 downto 0) := (others => '0');
    signal outer_33, outer_34, outer_35, outer_36, outer_37, outer_38, outer_39                     : signed(111 downto 0) := (others => '0');
    signal outer_44, outer_45, outer_46, outer_47, outer_48, outer_49                               : signed(111 downto 0) := (others => '0');
    signal outer_55, outer_56, outer_57, outer_58, outer_59                                         : signed(111 downto 0) := (others => '0');
    signal outer_66, outer_67, outer_68, outer_69                                                   : signed(111 downto 0) := (others => '0');
    signal outer_77, outer_78, outer_79                                                             : signed(111 downto 0) := (others => '0');
    signal outer_88, outer_89                                                                       : signed(111 downto 0) := (others => '0');
    signal outer_99                                                                                 : signed(111 downto 0) := (others => '0');

    signal weighted_11, weighted_12, weighted_13, weighted_14, weighted_15, weighted_16, weighted_17, weighted_18, weighted_19 : signed(95 downto 0) := (others => '0');
    signal weighted_22, weighted_23, weighted_24, weighted_25, weighted_26, weighted_27, weighted_28, weighted_29              : signed(95 downto 0) := (others => '0');
    signal weighted_33, weighted_34, weighted_35, weighted_36, weighted_37, weighted_38, weighted_39                           : signed(95 downto 0) := (others => '0');
    signal weighted_44, weighted_45, weighted_46, weighted_47, weighted_48, weighted_49                                        : signed(95 downto 0) := (others => '0');
    signal weighted_55, weighted_56, weighted_57, weighted_58, weighted_59                                                     : signed(95 downto 0) := (others => '0');
    signal weighted_66, weighted_67, weighted_68, weighted_69                                                                  : signed(95 downto 0) := (others => '0');
    signal weighted_77, weighted_78, weighted_79                                                                               : signed(95 downto 0) := (others => '0');
    signal weighted_88, weighted_89                                                                                            : signed(95 downto 0) := (others => '0');
    signal weighted_99                                                                                                         : signed(95 downto 0) := (others => '0');

    signal acc_p11, acc_p12, acc_p13, acc_p14, acc_p15, acc_p16, acc_p17, acc_p18, acc_p19 : signed(63 downto 0) := (others => '0');
    signal acc_p22, acc_p23, acc_p24, acc_p25, acc_p26, acc_p27, acc_p28, acc_p29          : signed(63 downto 0) := (others => '0');
    signal acc_p33, acc_p34, acc_p35, acc_p36, acc_p37, acc_p38, acc_p39                   : signed(63 downto 0) := (others => '0');
    signal acc_p44, acc_p45, acc_p46, acc_p47, acc_p48, acc_p49                            : signed(63 downto 0) := (others => '0');
    signal acc_p55, acc_p56, acc_p57, acc_p58, acc_p59                                     : signed(63 downto 0) := (others => '0');
    signal acc_p66, acc_p67, acc_p68, acc_p69                                              : signed(63 downto 0) := (others => '0');
    signal acc_p77, acc_p78, acc_p79                                                       : signed(63 downto 0) := (others => '0');
    signal acc_p88, acc_p89                                                                : signed(63 downto 0) := (others => '0');
    signal acc_p99                                                                         : signed(63 downto 0) := (others => '0');

begin

    process(clk)
    begin
        if rising_edge(clk) then
            case state is

                when IDLE =>
                    done <= '0';
                    accumulate_idx <= 0;

                    acc_p11 <= (others => '0'); acc_p12 <= (others => '0'); acc_p13 <= (others => '0'); acc_p14 <= (others => '0'); acc_p15 <= (others => '0'); acc_p16 <= (others => '0'); acc_p17 <= (others => '0'); acc_p18 <= (others => '0'); acc_p19 <= (others => '0');
                    acc_p22 <= (others => '0'); acc_p23 <= (others => '0'); acc_p24 <= (others => '0'); acc_p25 <= (others => '0'); acc_p26 <= (others => '0'); acc_p27 <= (others => '0'); acc_p28 <= (others => '0'); acc_p29 <= (others => '0');
                    acc_p33 <= (others => '0'); acc_p34 <= (others => '0'); acc_p35 <= (others => '0'); acc_p36 <= (others => '0'); acc_p37 <= (others => '0'); acc_p38 <= (others => '0'); acc_p39 <= (others => '0');
                    acc_p44 <= (others => '0'); acc_p45 <= (others => '0'); acc_p46 <= (others => '0'); acc_p47 <= (others => '0'); acc_p48 <= (others => '0'); acc_p49 <= (others => '0');
                    acc_p55 <= (others => '0'); acc_p56 <= (others => '0'); acc_p57 <= (others => '0'); acc_p58 <= (others => '0'); acc_p59 <= (others => '0');
                    acc_p66 <= (others => '0'); acc_p67 <= (others => '0'); acc_p68 <= (others => '0'); acc_p69 <= (others => '0');
                    acc_p77 <= (others => '0'); acc_p78 <= (others => '0'); acc_p79 <= (others => '0');
                    acc_p88 <= (others => '0'); acc_p89 <= (others => '0');
                    acc_p99 <= (others => '0');

                    if start = '1' then
                        state <= LATCH_INPUTS;
                    end if;

                when LATCH_INPUTS =>

                    x_pos_mean_reg <= x_pos_mean;
                    x_vel_mean_reg <= x_vel_mean;
                    x_acc_mean_reg <= x_acc_mean;
                    y_pos_mean_reg <= y_pos_mean;
                    y_vel_mean_reg <= y_vel_mean;
                    y_acc_mean_reg <= y_acc_mean;
                    z_pos_mean_reg <= z_pos_mean;
                    z_vel_mean_reg <= z_vel_mean;
                    z_acc_mean_reg <= z_acc_mean;

                    chi_x_pos(0) <= chi0_x_pos_pred; chi_x_vel(0) <= chi0_x_vel_pred; chi_x_acc(0) <= chi0_x_acc_pred;
                    chi_y_pos(0) <= chi0_y_pos_pred; chi_y_vel(0) <= chi0_y_vel_pred; chi_y_acc(0) <= chi0_y_acc_pred;
                    chi_z_pos(0) <= chi0_z_pos_pred; chi_z_vel(0) <= chi0_z_vel_pred; chi_z_acc(0) <= chi0_z_acc_pred;

                    chi_x_pos(1) <= chi1_x_pos_pred; chi_x_vel(1) <= chi1_x_vel_pred; chi_x_acc(1) <= chi1_x_acc_pred;
                    chi_y_pos(1) <= chi1_y_pos_pred; chi_y_vel(1) <= chi1_y_vel_pred; chi_y_acc(1) <= chi1_y_acc_pred;
                    chi_z_pos(1) <= chi1_z_pos_pred; chi_z_vel(1) <= chi1_z_vel_pred; chi_z_acc(1) <= chi1_z_acc_pred;

                    chi_x_pos(2) <= chi2_x_pos_pred; chi_x_vel(2) <= chi2_x_vel_pred; chi_x_acc(2) <= chi2_x_acc_pred;
                    chi_y_pos(2) <= chi2_y_pos_pred; chi_y_vel(2) <= chi2_y_vel_pred; chi_y_acc(2) <= chi2_y_acc_pred;
                    chi_z_pos(2) <= chi2_z_pos_pred; chi_z_vel(2) <= chi2_z_vel_pred; chi_z_acc(2) <= chi2_z_acc_pred;

                    chi_x_pos(3) <= chi3_x_pos_pred; chi_x_vel(3) <= chi3_x_vel_pred; chi_x_acc(3) <= chi3_x_acc_pred;
                    chi_y_pos(3) <= chi3_y_pos_pred; chi_y_vel(3) <= chi3_y_vel_pred; chi_y_acc(3) <= chi3_y_acc_pred;
                    chi_z_pos(3) <= chi3_z_pos_pred; chi_z_vel(3) <= chi3_z_vel_pred; chi_z_acc(3) <= chi3_z_acc_pred;

                    chi_x_pos(4) <= chi4_x_pos_pred; chi_x_vel(4) <= chi4_x_vel_pred; chi_x_acc(4) <= chi4_x_acc_pred;
                    chi_y_pos(4) <= chi4_y_pos_pred; chi_y_vel(4) <= chi4_y_vel_pred; chi_y_acc(4) <= chi4_y_acc_pred;
                    chi_z_pos(4) <= chi4_z_pos_pred; chi_z_vel(4) <= chi4_z_vel_pred; chi_z_acc(4) <= chi4_z_acc_pred;

                    chi_x_pos(5) <= chi5_x_pos_pred; chi_x_vel(5) <= chi5_x_vel_pred; chi_x_acc(5) <= chi5_x_acc_pred;
                    chi_y_pos(5) <= chi5_y_pos_pred; chi_y_vel(5) <= chi5_y_vel_pred; chi_y_acc(5) <= chi5_y_acc_pred;
                    chi_z_pos(5) <= chi5_z_pos_pred; chi_z_vel(5) <= chi5_z_vel_pred; chi_z_acc(5) <= chi5_z_acc_pred;

                    chi_x_pos(6) <= chi6_x_pos_pred; chi_x_vel(6) <= chi6_x_vel_pred; chi_x_acc(6) <= chi6_x_acc_pred;
                    chi_y_pos(6) <= chi6_y_pos_pred; chi_y_vel(6) <= chi6_y_vel_pred; chi_y_acc(6) <= chi6_y_acc_pred;
                    chi_z_pos(6) <= chi6_z_pos_pred; chi_z_vel(6) <= chi6_z_vel_pred; chi_z_acc(6) <= chi6_z_acc_pred;

                    chi_x_pos(7) <= chi7_x_pos_pred; chi_x_vel(7) <= chi7_x_vel_pred; chi_x_acc(7) <= chi7_x_acc_pred;
                    chi_y_pos(7) <= chi7_y_pos_pred; chi_y_vel(7) <= chi7_y_vel_pred; chi_y_acc(7) <= chi7_y_acc_pred;
                    chi_z_pos(7) <= chi7_z_pos_pred; chi_z_vel(7) <= chi7_z_vel_pred; chi_z_acc(7) <= chi7_z_acc_pred;

                    chi_x_pos(8) <= chi8_x_pos_pred; chi_x_vel(8) <= chi8_x_vel_pred; chi_x_acc(8) <= chi8_x_acc_pred;
                    chi_y_pos(8) <= chi8_y_pos_pred; chi_y_vel(8) <= chi8_y_vel_pred; chi_y_acc(8) <= chi8_y_acc_pred;
                    chi_z_pos(8) <= chi8_z_pos_pred; chi_z_vel(8) <= chi8_z_vel_pred; chi_z_acc(8) <= chi8_z_acc_pred;

                    chi_x_pos(9) <= chi9_x_pos_pred; chi_x_vel(9) <= chi9_x_vel_pred; chi_x_acc(9) <= chi9_x_acc_pred;
                    chi_y_pos(9) <= chi9_y_pos_pred; chi_y_vel(9) <= chi9_y_vel_pred; chi_y_acc(9) <= chi9_y_acc_pred;
                    chi_z_pos(9) <= chi9_z_pos_pred; chi_z_vel(9) <= chi9_z_vel_pred; chi_z_acc(9) <= chi9_z_acc_pred;

                    chi_x_pos(10) <= chi10_x_pos_pred; chi_x_vel(10) <= chi10_x_vel_pred; chi_x_acc(10) <= chi10_x_acc_pred;
                    chi_y_pos(10) <= chi10_y_pos_pred; chi_y_vel(10) <= chi10_y_vel_pred; chi_y_acc(10) <= chi10_y_acc_pred;
                    chi_z_pos(10) <= chi10_z_pos_pred; chi_z_vel(10) <= chi10_z_vel_pred; chi_z_acc(10) <= chi10_z_acc_pred;

                    chi_x_pos(11) <= chi11_x_pos_pred; chi_x_vel(11) <= chi11_x_vel_pred; chi_x_acc(11) <= chi11_x_acc_pred;
                    chi_y_pos(11) <= chi11_y_pos_pred; chi_y_vel(11) <= chi11_y_vel_pred; chi_y_acc(11) <= chi11_y_acc_pred;
                    chi_z_pos(11) <= chi11_z_pos_pred; chi_z_vel(11) <= chi11_z_vel_pred; chi_z_acc(11) <= chi11_z_acc_pred;

                    chi_x_pos(12) <= chi12_x_pos_pred; chi_x_vel(12) <= chi12_x_vel_pred; chi_x_acc(12) <= chi12_x_acc_pred;
                    chi_y_pos(12) <= chi12_y_pos_pred; chi_y_vel(12) <= chi12_y_vel_pred; chi_y_acc(12) <= chi12_y_acc_pred;
                    chi_z_pos(12) <= chi12_z_pos_pred; chi_z_vel(12) <= chi12_z_vel_pred; chi_z_acc(12) <= chi12_z_acc_pred;

                    chi_x_pos(13) <= chi13_x_pos_pred; chi_x_vel(13) <= chi13_x_vel_pred; chi_x_acc(13) <= chi13_x_acc_pred;
                    chi_y_pos(13) <= chi13_y_pos_pred; chi_y_vel(13) <= chi13_y_vel_pred; chi_y_acc(13) <= chi13_y_acc_pred;
                    chi_z_pos(13) <= chi13_z_pos_pred; chi_z_vel(13) <= chi13_z_vel_pred; chi_z_acc(13) <= chi13_z_acc_pred;

                    chi_x_pos(14) <= chi14_x_pos_pred; chi_x_vel(14) <= chi14_x_vel_pred; chi_x_acc(14) <= chi14_x_acc_pred;
                    chi_y_pos(14) <= chi14_y_pos_pred; chi_y_vel(14) <= chi14_y_vel_pred; chi_y_acc(14) <= chi14_y_acc_pred;
                    chi_z_pos(14) <= chi14_z_pos_pred; chi_z_vel(14) <= chi14_z_vel_pred; chi_z_acc(14) <= chi14_z_acc_pred;

                    chi_x_pos(15) <= chi15_x_pos_pred; chi_x_vel(15) <= chi15_x_vel_pred; chi_x_acc(15) <= chi15_x_acc_pred;
                    chi_y_pos(15) <= chi15_y_pos_pred; chi_y_vel(15) <= chi15_y_vel_pred; chi_y_acc(15) <= chi15_y_acc_pred;
                    chi_z_pos(15) <= chi15_z_pos_pred; chi_z_vel(15) <= chi15_z_vel_pred; chi_z_acc(15) <= chi15_z_acc_pred;

                    chi_x_pos(16) <= chi16_x_pos_pred; chi_x_vel(16) <= chi16_x_vel_pred; chi_x_acc(16) <= chi16_x_acc_pred;
                    chi_y_pos(16) <= chi16_y_pos_pred; chi_y_vel(16) <= chi16_y_vel_pred; chi_y_acc(16) <= chi16_y_acc_pred;
                    chi_z_pos(16) <= chi16_z_pos_pred; chi_z_vel(16) <= chi16_z_vel_pred; chi_z_acc(16) <= chi16_z_acc_pred;

                    chi_x_pos(17) <= chi17_x_pos_pred; chi_x_vel(17) <= chi17_x_vel_pred; chi_x_acc(17) <= chi17_x_acc_pred;
                    chi_y_pos(17) <= chi17_y_pos_pred; chi_y_vel(17) <= chi17_y_vel_pred; chi_y_acc(17) <= chi17_y_acc_pred;
                    chi_z_pos(17) <= chi17_z_pos_pred; chi_z_vel(17) <= chi17_z_vel_pred; chi_z_acc(17) <= chi17_z_acc_pred;

                    chi_x_pos(18) <= chi18_x_pos_pred; chi_x_vel(18) <= chi18_x_vel_pred; chi_x_acc(18) <= chi18_x_acc_pred;
                    chi_y_pos(18) <= chi18_y_pos_pred; chi_y_vel(18) <= chi18_y_vel_pred; chi_y_acc(18) <= chi18_y_acc_pred;
                    chi_z_pos(18) <= chi18_z_pos_pred; chi_z_vel(18) <= chi18_z_vel_pred; chi_z_acc(18) <= chi18_z_acc_pred;

                    state <= COMPUTE_DELTA;

                when COMPUTE_DELTA =>

                    current_weight_reg <= WEIGHTS(accumulate_idx);

                    delta_x_pos <= chi_x_pos(accumulate_idx) - x_pos_mean_reg;
                    delta_x_vel <= chi_x_vel(accumulate_idx) - x_vel_mean_reg;
                    delta_x_acc <= chi_x_acc(accumulate_idx) - x_acc_mean_reg;
                    delta_y_pos <= chi_y_pos(accumulate_idx) - y_pos_mean_reg;
                    delta_y_vel <= chi_y_vel(accumulate_idx) - y_vel_mean_reg;
                    delta_y_acc <= chi_y_acc(accumulate_idx) - y_acc_mean_reg;
                    delta_z_pos <= chi_z_pos(accumulate_idx) - z_pos_mean_reg;
                    delta_z_vel <= chi_z_vel(accumulate_idx) - z_vel_mean_reg;
                    delta_z_acc <= chi_z_acc(accumulate_idx) - z_acc_mean_reg;

                    state <= COMPUTE_OUTER;

                when COMPUTE_OUTER =>

                    if accumulate_idx = 0 then
                        report "COV_RECON: DELTA (sigma point 0, values hex-suppressed)";
                    end if;

                    outer_11 <= resize(delta_x_pos * delta_x_pos, 112);
                    outer_12 <= resize(delta_x_pos * delta_x_vel, 112);
                    outer_13 <= resize(delta_x_pos * delta_x_acc, 112);
                    outer_14 <= resize(delta_x_pos * delta_y_pos, 112);
                    outer_15 <= resize(delta_x_pos * delta_y_vel, 112);
                    outer_16 <= resize(delta_x_pos * delta_y_acc, 112);
                    outer_17 <= resize(delta_x_pos * delta_z_pos, 112);
                    outer_18 <= resize(delta_x_pos * delta_z_vel, 112);
                    outer_19 <= resize(delta_x_pos * delta_z_acc, 112);

                    outer_22 <= resize(delta_x_vel * delta_x_vel, 112);
                    outer_23 <= resize(delta_x_vel * delta_x_acc, 112);
                    outer_24 <= resize(delta_x_vel * delta_y_pos, 112);
                    outer_25 <= resize(delta_x_vel * delta_y_vel, 112);
                    outer_26 <= resize(delta_x_vel * delta_y_acc, 112);
                    outer_27 <= resize(delta_x_vel * delta_z_pos, 112);
                    outer_28 <= resize(delta_x_vel * delta_z_vel, 112);
                    outer_29 <= resize(delta_x_vel * delta_z_acc, 112);

                    outer_33 <= resize(delta_x_acc * delta_x_acc, 112);
                    outer_34 <= resize(delta_x_acc * delta_y_pos, 112);
                    outer_35 <= resize(delta_x_acc * delta_y_vel, 112);
                    outer_36 <= resize(delta_x_acc * delta_y_acc, 112);
                    outer_37 <= resize(delta_x_acc * delta_z_pos, 112);
                    outer_38 <= resize(delta_x_acc * delta_z_vel, 112);
                    outer_39 <= resize(delta_x_acc * delta_z_acc, 112);

                    outer_44 <= resize(delta_y_pos * delta_y_pos, 112);
                    outer_45 <= resize(delta_y_pos * delta_y_vel, 112);
                    outer_46 <= resize(delta_y_pos * delta_y_acc, 112);
                    outer_47 <= resize(delta_y_pos * delta_z_pos, 112);
                    outer_48 <= resize(delta_y_pos * delta_z_vel, 112);
                    outer_49 <= resize(delta_y_pos * delta_z_acc, 112);

                    outer_55 <= resize(delta_y_vel * delta_y_vel, 112);
                    outer_56 <= resize(delta_y_vel * delta_y_acc, 112);
                    outer_57 <= resize(delta_y_vel * delta_z_pos, 112);
                    outer_58 <= resize(delta_y_vel * delta_z_vel, 112);
                    outer_59 <= resize(delta_y_vel * delta_z_acc, 112);

                    outer_66 <= resize(delta_y_acc * delta_y_acc, 112);
                    outer_67 <= resize(delta_y_acc * delta_z_pos, 112);
                    outer_68 <= resize(delta_y_acc * delta_z_vel, 112);
                    outer_69 <= resize(delta_y_acc * delta_z_acc, 112);

                    outer_77 <= resize(delta_z_pos * delta_z_pos, 112);
                    outer_78 <= resize(delta_z_pos * delta_z_vel, 112);
                    outer_79 <= resize(delta_z_pos * delta_z_acc, 112);

                    outer_88 <= resize(delta_z_vel * delta_z_vel, 112);
                    outer_89 <= resize(delta_z_vel * delta_z_acc, 112);

                    outer_99 <= resize(delta_z_acc * delta_z_acc, 112);

                    state <= WEIGHT;

                when WEIGHT =>

                    if accumulate_idx = 0 then
                        report "COV_RECON: OUTER_PRODUCT (sigma point 0, values hex-suppressed)";
                    end if;

                    weighted_11 <= resize(shift_right(outer_11 * current_weight_reg, Q), 96);
                    weighted_12 <= resize(shift_right(outer_12 * current_weight_reg, Q), 96);
                    weighted_13 <= resize(shift_right(outer_13 * current_weight_reg, Q), 96);
                    weighted_14 <= resize(shift_right(outer_14 * current_weight_reg, Q), 96);
                    weighted_15 <= resize(shift_right(outer_15 * current_weight_reg, Q), 96);
                    weighted_16 <= resize(shift_right(outer_16 * current_weight_reg, Q), 96);
                    weighted_17 <= resize(shift_right(outer_17 * current_weight_reg, Q), 96);
                    weighted_18 <= resize(shift_right(outer_18 * current_weight_reg, Q), 96);
                    weighted_19 <= resize(shift_right(outer_19 * current_weight_reg, Q), 96);

                    weighted_22 <= resize(shift_right(outer_22 * current_weight_reg, Q), 96);
                    weighted_23 <= resize(shift_right(outer_23 * current_weight_reg, Q), 96);
                    weighted_24 <= resize(shift_right(outer_24 * current_weight_reg, Q), 96);
                    weighted_25 <= resize(shift_right(outer_25 * current_weight_reg, Q), 96);
                    weighted_26 <= resize(shift_right(outer_26 * current_weight_reg, Q), 96);
                    weighted_27 <= resize(shift_right(outer_27 * current_weight_reg, Q), 96);
                    weighted_28 <= resize(shift_right(outer_28 * current_weight_reg, Q), 96);
                    weighted_29 <= resize(shift_right(outer_29 * current_weight_reg, Q), 96);

                    weighted_33 <= resize(shift_right(outer_33 * current_weight_reg, Q), 96);
                    weighted_34 <= resize(shift_right(outer_34 * current_weight_reg, Q), 96);
                    weighted_35 <= resize(shift_right(outer_35 * current_weight_reg, Q), 96);
                    weighted_36 <= resize(shift_right(outer_36 * current_weight_reg, Q), 96);
                    weighted_37 <= resize(shift_right(outer_37 * current_weight_reg, Q), 96);
                    weighted_38 <= resize(shift_right(outer_38 * current_weight_reg, Q), 96);
                    weighted_39 <= resize(shift_right(outer_39 * current_weight_reg, Q), 96);

                    weighted_44 <= resize(shift_right(outer_44 * current_weight_reg, Q), 96);
                    weighted_45 <= resize(shift_right(outer_45 * current_weight_reg, Q), 96);
                    weighted_46 <= resize(shift_right(outer_46 * current_weight_reg, Q), 96);
                    weighted_47 <= resize(shift_right(outer_47 * current_weight_reg, Q), 96);
                    weighted_48 <= resize(shift_right(outer_48 * current_weight_reg, Q), 96);
                    weighted_49 <= resize(shift_right(outer_49 * current_weight_reg, Q), 96);

                    weighted_55 <= resize(shift_right(outer_55 * current_weight_reg, Q), 96);
                    weighted_56 <= resize(shift_right(outer_56 * current_weight_reg, Q), 96);
                    weighted_57 <= resize(shift_right(outer_57 * current_weight_reg, Q), 96);
                    weighted_58 <= resize(shift_right(outer_58 * current_weight_reg, Q), 96);
                    weighted_59 <= resize(shift_right(outer_59 * current_weight_reg, Q), 96);

                    weighted_66 <= resize(shift_right(outer_66 * current_weight_reg, Q), 96);
                    weighted_67 <= resize(shift_right(outer_67 * current_weight_reg, Q), 96);
                    weighted_68 <= resize(shift_right(outer_68 * current_weight_reg, Q), 96);
                    weighted_69 <= resize(shift_right(outer_69 * current_weight_reg, Q), 96);

                    weighted_77 <= resize(shift_right(outer_77 * current_weight_reg, Q), 96);
                    weighted_78 <= resize(shift_right(outer_78 * current_weight_reg, Q), 96);
                    weighted_79 <= resize(shift_right(outer_79 * current_weight_reg, Q), 96);

                    weighted_88 <= resize(shift_right(outer_88 * current_weight_reg, Q), 96);
                    weighted_89 <= resize(shift_right(outer_89 * current_weight_reg, Q), 96);

                    weighted_99 <= resize(shift_right(outer_99 * current_weight_reg, Q), 96);

                    state <= ADD;

                when ADD =>

                    if accumulate_idx = 0 then
                        report "COV_RECON: WEIGHTED (sigma point 0, values hex-suppressed)";
                    end if;

                    acc_p11 <= acc_p11 + resize(shift_right(weighted_11, Q), 56);
                    acc_p12 <= acc_p12 + resize(shift_right(weighted_12, Q), 56);
                    acc_p13 <= acc_p13 + resize(shift_right(weighted_13, Q), 56);
                    acc_p14 <= acc_p14 + resize(shift_right(weighted_14, Q), 56);
                    acc_p15 <= acc_p15 + resize(shift_right(weighted_15, Q), 56);
                    acc_p16 <= acc_p16 + resize(shift_right(weighted_16, Q), 56);
                    acc_p17 <= acc_p17 + resize(shift_right(weighted_17, Q), 56);
                    acc_p18 <= acc_p18 + resize(shift_right(weighted_18, Q), 56);
                    acc_p19 <= acc_p19 + resize(shift_right(weighted_19, Q), 56);

                    acc_p22 <= acc_p22 + resize(shift_right(weighted_22, Q), 56);
                    acc_p23 <= acc_p23 + resize(shift_right(weighted_23, Q), 56);
                    acc_p24 <= acc_p24 + resize(shift_right(weighted_24, Q), 56);
                    acc_p25 <= acc_p25 + resize(shift_right(weighted_25, Q), 56);
                    acc_p26 <= acc_p26 + resize(shift_right(weighted_26, Q), 56);
                    acc_p27 <= acc_p27 + resize(shift_right(weighted_27, Q), 56);
                    acc_p28 <= acc_p28 + resize(shift_right(weighted_28, Q), 56);
                    acc_p29 <= acc_p29 + resize(shift_right(weighted_29, Q), 56);

                    acc_p33 <= acc_p33 + resize(shift_right(weighted_33, Q), 56);
                    acc_p34 <= acc_p34 + resize(shift_right(weighted_34, Q), 56);
                    acc_p35 <= acc_p35 + resize(shift_right(weighted_35, Q), 56);
                    acc_p36 <= acc_p36 + resize(shift_right(weighted_36, Q), 56);
                    acc_p37 <= acc_p37 + resize(shift_right(weighted_37, Q), 56);
                    acc_p38 <= acc_p38 + resize(shift_right(weighted_38, Q), 56);
                    acc_p39 <= acc_p39 + resize(shift_right(weighted_39, Q), 56);

                    acc_p44 <= acc_p44 + resize(shift_right(weighted_44, Q), 56);
                    acc_p45 <= acc_p45 + resize(shift_right(weighted_45, Q), 56);
                    acc_p46 <= acc_p46 + resize(shift_right(weighted_46, Q), 56);
                    acc_p47 <= acc_p47 + resize(shift_right(weighted_47, Q), 56);
                    acc_p48 <= acc_p48 + resize(shift_right(weighted_48, Q), 56);
                    acc_p49 <= acc_p49 + resize(shift_right(weighted_49, Q), 56);

                    acc_p55 <= acc_p55 + resize(shift_right(weighted_55, Q), 56);
                    acc_p56 <= acc_p56 + resize(shift_right(weighted_56, Q), 56);
                    acc_p57 <= acc_p57 + resize(shift_right(weighted_57, Q), 56);
                    acc_p58 <= acc_p58 + resize(shift_right(weighted_58, Q), 56);
                    acc_p59 <= acc_p59 + resize(shift_right(weighted_59, Q), 56);

                    acc_p66 <= acc_p66 + resize(shift_right(weighted_66, Q), 56);
                    acc_p67 <= acc_p67 + resize(shift_right(weighted_67, Q), 56);
                    acc_p68 <= acc_p68 + resize(shift_right(weighted_68, Q), 56);
                    acc_p69 <= acc_p69 + resize(shift_right(weighted_69, Q), 56);

                    acc_p77 <= acc_p77 + resize(shift_right(weighted_77, Q), 56);
                    acc_p78 <= acc_p78 + resize(shift_right(weighted_78, Q), 56);
                    acc_p79 <= acc_p79 + resize(shift_right(weighted_79, Q), 56);

                    acc_p88 <= acc_p88 + resize(shift_right(weighted_88, Q), 56);
                    acc_p89 <= acc_p89 + resize(shift_right(weighted_89, Q), 56);

                    acc_p99 <= acc_p99 + resize(shift_right(weighted_99, Q), 56);

                    if accumulate_idx = 18 then
                        state <= NORMALIZE;
                    else
                        accumulate_idx <= accumulate_idx + 1;
                        state <= COMPUTE_DELTA;
                    end if;

                when NORMALIZE =>

                    report "COV_RECON: NORMALIZE (diagonal P values, values hex-suppressed)";

                    p11_out <= resize(acc_p11, 48);
                    p12_out <= resize(acc_p12, 48);
                    p13_out <= resize(acc_p13, 48);
                    p14_out <= resize(acc_p14, 48);
                    p15_out <= resize(acc_p15, 48);
                    p16_out <= resize(acc_p16, 48);
                    p17_out <= resize(acc_p17, 48);
                    p18_out <= resize(acc_p18, 48);
                    p19_out <= resize(acc_p19, 48);

                    p22_out <= resize(acc_p22, 48);
                    p23_out <= resize(acc_p23, 48);
                    p24_out <= resize(acc_p24, 48);
                    p25_out <= resize(acc_p25, 48);
                    p26_out <= resize(acc_p26, 48);
                    p27_out <= resize(acc_p27, 48);
                    p28_out <= resize(acc_p28, 48);
                    p29_out <= resize(acc_p29, 48);

                    p33_out <= resize(acc_p33, 48);
                    p34_out <= resize(acc_p34, 48);
                    p35_out <= resize(acc_p35, 48);
                    p36_out <= resize(acc_p36, 48);
                    p37_out <= resize(acc_p37, 48);
                    p38_out <= resize(acc_p38, 48);
                    p39_out <= resize(acc_p39, 48);

                    p44_out <= resize(acc_p44, 48);
                    p45_out <= resize(acc_p45, 48);
                    p46_out <= resize(acc_p46, 48);
                    p47_out <= resize(acc_p47, 48);
                    p48_out <= resize(acc_p48, 48);
                    p49_out <= resize(acc_p49, 48);

                    p55_out <= resize(acc_p55, 48);
                    p56_out <= resize(acc_p56, 48);
                    p57_out <= resize(acc_p57, 48);
                    p58_out <= resize(acc_p58, 48);
                    p59_out <= resize(acc_p59, 48);

                    p66_out <= resize(acc_p66, 48);
                    p67_out <= resize(acc_p67, 48);
                    p68_out <= resize(acc_p68, 48);
                    p69_out <= resize(acc_p69, 48);

                    p77_out <= resize(acc_p77, 48);
                    p78_out <= resize(acc_p78, 48);
                    p79_out <= resize(acc_p79, 48);

                    p88_out <= resize(acc_p88, 48);
                    p89_out <= resize(acc_p89, 48);

                    p99_out <= resize(acc_p99, 48);

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
