library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cross_covariance_3d is
    port (
        clk   : in  std_logic;
        start : in  std_logic;

        x_pos_mean, x_vel_mean, x_acc_mean : in signed(47 downto 0);
        y_pos_mean, y_vel_mean, y_acc_mean : in signed(47 downto 0);
        z_pos_mean, z_vel_mean, z_acc_mean : in signed(47 downto 0);

        z_x_mean, z_y_mean, z_z_mean : in signed(47 downto 0);

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

        pxz_11, pxz_12, pxz_13 : buffer signed(47 downto 0);
        pxz_21, pxz_22, pxz_23 : buffer signed(47 downto 0);
        pxz_31, pxz_32, pxz_33 : buffer signed(47 downto 0);
        pxz_41, pxz_42, pxz_43 : buffer signed(47 downto 0);
        pxz_51, pxz_52, pxz_53 : buffer signed(47 downto 0);
        pxz_61, pxz_62, pxz_63 : buffer signed(47 downto 0);
        pxz_71, pxz_72, pxz_73 : buffer signed(47 downto 0);
        pxz_81, pxz_82, pxz_83 : buffer signed(47 downto 0);
        pxz_91, pxz_92, pxz_93 : buffer signed(47 downto 0);

        done : out std_logic
    );
end cross_covariance_3d;

architecture Behavioral of cross_covariance_3d is

    constant W0 : signed(47 downto 0) := to_signed(33554432, 48);
    constant W1 : signed(47 downto 0) := to_signed(932067, 48);
    constant Q : integer := 24;

    type state_type is (IDLE, COMPUTE_DELTAS, COMPUTE_OUTER, WEIGHT, ADD, NORMALIZE, FINISHED);
    signal state : state_type := IDLE;
    signal accumulate_idx : integer range 0 to 18 := 0;

    type state_array is array (0 to 18) of signed(47 downto 0);
    signal chi_x_pos, chi_x_vel, chi_x_acc : state_array := (others => (others => '0'));
    signal chi_y_pos, chi_y_vel, chi_y_acc : state_array := (others => (others => '0'));
    signal chi_z_pos, chi_z_vel, chi_z_acc : state_array := (others => (others => '0'));

    type weight_array is array (0 to 18) of signed(47 downto 0);
    constant WEIGHTS : weight_array := (W0, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1);

    signal x_pos_mean_reg, x_vel_mean_reg, x_acc_mean_reg : signed(47 downto 0);
    signal y_pos_mean_reg, y_vel_mean_reg, y_acc_mean_reg : signed(47 downto 0);
    signal z_pos_mean_reg, z_vel_mean_reg, z_acc_mean_reg : signed(47 downto 0);
    signal z_x_mean_reg, z_y_mean_reg, z_z_mean_reg : signed(47 downto 0);

    signal current_weight : signed(47 downto 0);

    signal delta_x_pos, delta_x_vel, delta_x_acc : signed(47 downto 0) := (others => '0');
    signal delta_y_pos, delta_y_vel, delta_y_acc : signed(47 downto 0) := (others => '0');
    signal delta_z_pos, delta_z_vel, delta_z_acc : signed(47 downto 0) := (others => '0');

    signal delta_z_x, delta_z_y, delta_z_z : signed(47 downto 0) := (others => '0');

    signal outer_11, outer_12, outer_13 : signed(95 downto 0) := (others => '0');
    signal outer_21, outer_22, outer_23 : signed(95 downto 0) := (others => '0');
    signal outer_31, outer_32, outer_33 : signed(95 downto 0) := (others => '0');
    signal outer_41, outer_42, outer_43 : signed(95 downto 0) := (others => '0');
    signal outer_51, outer_52, outer_53 : signed(95 downto 0) := (others => '0');
    signal outer_61, outer_62, outer_63 : signed(95 downto 0) := (others => '0');
    signal outer_71, outer_72, outer_73 : signed(95 downto 0) := (others => '0');
    signal outer_81, outer_82, outer_83 : signed(95 downto 0) := (others => '0');
    signal outer_91, outer_92, outer_93 : signed(95 downto 0) := (others => '0');

    signal weighted_11, weighted_12, weighted_13 : signed(95 downto 0) := (others => '0');
    signal weighted_21, weighted_22, weighted_23 : signed(95 downto 0) := (others => '0');
    signal weighted_31, weighted_32, weighted_33 : signed(95 downto 0) := (others => '0');
    signal weighted_41, weighted_42, weighted_43 : signed(95 downto 0) := (others => '0');
    signal weighted_51, weighted_52, weighted_53 : signed(95 downto 0) := (others => '0');
    signal weighted_61, weighted_62, weighted_63 : signed(95 downto 0) := (others => '0');
    signal weighted_71, weighted_72, weighted_73 : signed(95 downto 0) := (others => '0');
    signal weighted_81, weighted_82, weighted_83 : signed(95 downto 0) := (others => '0');
    signal weighted_91, weighted_92, weighted_93 : signed(95 downto 0) := (others => '0');

    signal acc_11, acc_12, acc_13 : signed(95 downto 0) := (others => '0');
    signal acc_21, acc_22, acc_23 : signed(95 downto 0) := (others => '0');
    signal acc_31, acc_32, acc_33 : signed(95 downto 0) := (others => '0');
    signal acc_41, acc_42, acc_43 : signed(95 downto 0) := (others => '0');
    signal acc_51, acc_52, acc_53 : signed(95 downto 0) := (others => '0');
    signal acc_61, acc_62, acc_63 : signed(95 downto 0) := (others => '0');
    signal acc_71, acc_72, acc_73 : signed(95 downto 0) := (others => '0');
    signal acc_81, acc_82, acc_83 : signed(95 downto 0) := (others => '0');
    signal acc_91, acc_92, acc_93 : signed(95 downto 0) := (others => '0');

begin

    process(clk)
    begin
        if rising_edge(clk) then
            case state is

                when IDLE =>
                    done <= '0';
                    accumulate_idx <= 0;

                    acc_11 <= (others => '0'); acc_12 <= (others => '0'); acc_13 <= (others => '0');
                    acc_21 <= (others => '0'); acc_22 <= (others => '0'); acc_23 <= (others => '0');
                    acc_31 <= (others => '0'); acc_32 <= (others => '0'); acc_33 <= (others => '0');
                    acc_41 <= (others => '0'); acc_42 <= (others => '0'); acc_43 <= (others => '0');
                    acc_51 <= (others => '0'); acc_52 <= (others => '0'); acc_53 <= (others => '0');
                    acc_61 <= (others => '0'); acc_62 <= (others => '0'); acc_63 <= (others => '0');
                    acc_71 <= (others => '0'); acc_72 <= (others => '0'); acc_73 <= (others => '0');
                    acc_81 <= (others => '0'); acc_82 <= (others => '0'); acc_83 <= (others => '0');
                    acc_91 <= (others => '0'); acc_92 <= (others => '0'); acc_93 <= (others => '0');

                    if start = '1' then

                        x_pos_mean_reg <= x_pos_mean; x_vel_mean_reg <= x_vel_mean; x_acc_mean_reg <= x_acc_mean;
                        y_pos_mean_reg <= y_pos_mean; y_vel_mean_reg <= y_vel_mean; y_acc_mean_reg <= y_acc_mean;
                        z_pos_mean_reg <= z_pos_mean; z_vel_mean_reg <= z_vel_mean; z_acc_mean_reg <= z_acc_mean;
                        z_x_mean_reg <= z_x_mean; z_y_mean_reg <= z_y_mean; z_z_mean_reg <= z_z_mean;

                        chi_x_pos(0) <= chi0_x_pos; chi_x_vel(0) <= chi0_x_vel; chi_x_acc(0) <= chi0_x_acc;
                        chi_y_pos(0) <= chi0_y_pos; chi_y_vel(0) <= chi0_y_vel; chi_y_acc(0) <= chi0_y_acc;
                        chi_z_pos(0) <= chi0_z_pos; chi_z_vel(0) <= chi0_z_vel; chi_z_acc(0) <= chi0_z_acc;

                        chi_x_pos(1) <= chi1_x_pos; chi_x_vel(1) <= chi1_x_vel; chi_x_acc(1) <= chi1_x_acc;
                        chi_y_pos(1) <= chi1_y_pos; chi_y_vel(1) <= chi1_y_vel; chi_y_acc(1) <= chi1_y_acc;
                        chi_z_pos(1) <= chi1_z_pos; chi_z_vel(1) <= chi1_z_vel; chi_z_acc(1) <= chi1_z_acc;

                        chi_x_pos(2) <= chi2_x_pos; chi_x_vel(2) <= chi2_x_vel; chi_x_acc(2) <= chi2_x_acc;
                        chi_y_pos(2) <= chi2_y_pos; chi_y_vel(2) <= chi2_y_vel; chi_y_acc(2) <= chi2_y_acc;
                        chi_z_pos(2) <= chi2_z_pos; chi_z_vel(2) <= chi2_z_vel; chi_z_acc(2) <= chi2_z_acc;

                        chi_x_pos(3) <= chi3_x_pos; chi_x_vel(3) <= chi3_x_vel; chi_x_acc(3) <= chi3_x_acc;
                        chi_y_pos(3) <= chi3_y_pos; chi_y_vel(3) <= chi3_y_vel; chi_y_acc(3) <= chi3_y_acc;
                        chi_z_pos(3) <= chi3_z_pos; chi_z_vel(3) <= chi3_z_vel; chi_z_acc(3) <= chi3_z_acc;

                        chi_x_pos(4) <= chi4_x_pos; chi_x_vel(4) <= chi4_x_vel; chi_x_acc(4) <= chi4_x_acc;
                        chi_y_pos(4) <= chi4_y_pos; chi_y_vel(4) <= chi4_y_vel; chi_y_acc(4) <= chi4_y_acc;
                        chi_z_pos(4) <= chi4_z_pos; chi_z_vel(4) <= chi4_z_vel; chi_z_acc(4) <= chi4_z_acc;

                        chi_x_pos(5) <= chi5_x_pos; chi_x_vel(5) <= chi5_x_vel; chi_x_acc(5) <= chi5_x_acc;
                        chi_y_pos(5) <= chi5_y_pos; chi_y_vel(5) <= chi5_y_vel; chi_y_acc(5) <= chi5_y_acc;
                        chi_z_pos(5) <= chi5_z_pos; chi_z_vel(5) <= chi5_z_vel; chi_z_acc(5) <= chi5_z_acc;

                        chi_x_pos(6) <= chi6_x_pos; chi_x_vel(6) <= chi6_x_vel; chi_x_acc(6) <= chi6_x_acc;
                        chi_y_pos(6) <= chi6_y_pos; chi_y_vel(6) <= chi6_y_vel; chi_y_acc(6) <= chi6_y_acc;
                        chi_z_pos(6) <= chi6_z_pos; chi_z_vel(6) <= chi6_z_vel; chi_z_acc(6) <= chi6_z_acc;

                        chi_x_pos(7) <= chi7_x_pos; chi_x_vel(7) <= chi7_x_vel; chi_x_acc(7) <= chi7_x_acc;
                        chi_y_pos(7) <= chi7_y_pos; chi_y_vel(7) <= chi7_y_vel; chi_y_acc(7) <= chi7_y_acc;
                        chi_z_pos(7) <= chi7_z_pos; chi_z_vel(7) <= chi7_z_vel; chi_z_acc(7) <= chi7_z_acc;

                        chi_x_pos(8) <= chi8_x_pos; chi_x_vel(8) <= chi8_x_vel; chi_x_acc(8) <= chi8_x_acc;
                        chi_y_pos(8) <= chi8_y_pos; chi_y_vel(8) <= chi8_y_vel; chi_y_acc(8) <= chi8_y_acc;
                        chi_z_pos(8) <= chi8_z_pos; chi_z_vel(8) <= chi8_z_vel; chi_z_acc(8) <= chi8_z_acc;

                        chi_x_pos(9) <= chi9_x_pos; chi_x_vel(9) <= chi9_x_vel; chi_x_acc(9) <= chi9_x_acc;
                        chi_y_pos(9) <= chi9_y_pos; chi_y_vel(9) <= chi9_y_vel; chi_y_acc(9) <= chi9_y_acc;
                        chi_z_pos(9) <= chi9_z_pos; chi_z_vel(9) <= chi9_z_vel; chi_z_acc(9) <= chi9_z_acc;

                        chi_x_pos(10) <= chi10_x_pos; chi_x_vel(10) <= chi10_x_vel; chi_x_acc(10) <= chi10_x_acc;
                        chi_y_pos(10) <= chi10_y_pos; chi_y_vel(10) <= chi10_y_vel; chi_y_acc(10) <= chi10_y_acc;
                        chi_z_pos(10) <= chi10_z_pos; chi_z_vel(10) <= chi10_z_vel; chi_z_acc(10) <= chi10_z_acc;

                        chi_x_pos(11) <= chi11_x_pos; chi_x_vel(11) <= chi11_x_vel; chi_x_acc(11) <= chi11_x_acc;
                        chi_y_pos(11) <= chi11_y_pos; chi_y_vel(11) <= chi11_y_vel; chi_y_acc(11) <= chi11_y_acc;
                        chi_z_pos(11) <= chi11_z_pos; chi_z_vel(11) <= chi11_z_vel; chi_z_acc(11) <= chi11_z_acc;

                        chi_x_pos(12) <= chi12_x_pos; chi_x_vel(12) <= chi12_x_vel; chi_x_acc(12) <= chi12_x_acc;
                        chi_y_pos(12) <= chi12_y_pos; chi_y_vel(12) <= chi12_y_vel; chi_y_acc(12) <= chi12_y_acc;
                        chi_z_pos(12) <= chi12_z_pos; chi_z_vel(12) <= chi12_z_vel; chi_z_acc(12) <= chi12_z_acc;

                        chi_x_pos(13) <= chi13_x_pos; chi_x_vel(13) <= chi13_x_vel; chi_x_acc(13) <= chi13_x_acc;
                        chi_y_pos(13) <= chi13_y_pos; chi_y_vel(13) <= chi13_y_vel; chi_y_acc(13) <= chi13_y_acc;
                        chi_z_pos(13) <= chi13_z_pos; chi_z_vel(13) <= chi13_z_vel; chi_z_acc(13) <= chi13_z_acc;

                        chi_x_pos(14) <= chi14_x_pos; chi_x_vel(14) <= chi14_x_vel; chi_x_acc(14) <= chi14_x_acc;
                        chi_y_pos(14) <= chi14_y_pos; chi_y_vel(14) <= chi14_y_vel; chi_y_acc(14) <= chi14_y_acc;
                        chi_z_pos(14) <= chi14_z_pos; chi_z_vel(14) <= chi14_z_vel; chi_z_acc(14) <= chi14_z_acc;

                        chi_x_pos(15) <= chi15_x_pos; chi_x_vel(15) <= chi15_x_vel; chi_x_acc(15) <= chi15_x_acc;
                        chi_y_pos(15) <= chi15_y_pos; chi_y_vel(15) <= chi15_y_vel; chi_y_acc(15) <= chi15_y_acc;
                        chi_z_pos(15) <= chi15_z_pos; chi_z_vel(15) <= chi15_z_vel; chi_z_acc(15) <= chi15_z_acc;

                        chi_x_pos(16) <= chi16_x_pos; chi_x_vel(16) <= chi16_x_vel; chi_x_acc(16) <= chi16_x_acc;
                        chi_y_pos(16) <= chi16_y_pos; chi_y_vel(16) <= chi16_y_vel; chi_y_acc(16) <= chi16_y_acc;
                        chi_z_pos(16) <= chi16_z_pos; chi_z_vel(16) <= chi16_z_vel; chi_z_acc(16) <= chi16_z_acc;

                        chi_x_pos(17) <= chi17_x_pos; chi_x_vel(17) <= chi17_x_vel; chi_x_acc(17) <= chi17_x_acc;
                        chi_y_pos(17) <= chi17_y_pos; chi_y_vel(17) <= chi17_y_vel; chi_y_acc(17) <= chi17_y_acc;
                        chi_z_pos(17) <= chi17_z_pos; chi_z_vel(17) <= chi17_z_vel; chi_z_acc(17) <= chi17_z_acc;

                        chi_x_pos(18) <= chi18_x_pos; chi_x_vel(18) <= chi18_x_vel; chi_x_acc(18) <= chi18_x_acc;
                        chi_y_pos(18) <= chi18_y_pos; chi_y_vel(18) <= chi18_y_vel; chi_y_acc(18) <= chi18_y_acc;
                        chi_z_pos(18) <= chi18_z_pos; chi_z_vel(18) <= chi18_z_vel; chi_z_acc(18) <= chi18_z_acc;

                        state <= COMPUTE_DELTAS;
                    end if;
                when COMPUTE_DELTAS =>

                    current_weight <= WEIGHTS(accumulate_idx);

                    delta_x_pos <= chi_x_pos(accumulate_idx) - x_pos_mean_reg;
                    delta_x_vel <= chi_x_vel(accumulate_idx) - x_vel_mean_reg;
                    delta_x_acc <= chi_x_acc(accumulate_idx) - x_acc_mean_reg;
                    delta_y_pos <= chi_y_pos(accumulate_idx) - y_pos_mean_reg;
                    delta_y_vel <= chi_y_vel(accumulate_idx) - y_vel_mean_reg;
                    delta_y_acc <= chi_y_acc(accumulate_idx) - y_acc_mean_reg;
                    delta_z_pos <= chi_z_pos(accumulate_idx) - z_pos_mean_reg;
                    delta_z_vel <= chi_z_vel(accumulate_idx) - z_vel_mean_reg;
                    delta_z_acc <= chi_z_acc(accumulate_idx) - z_acc_mean_reg;

                    delta_z_x <= chi_x_pos(accumulate_idx) - z_x_mean_reg;
                    delta_z_y <= chi_y_pos(accumulate_idx) - z_y_mean_reg;
                    delta_z_z <= chi_z_pos(accumulate_idx) - z_z_mean_reg;

                    state <= COMPUTE_OUTER;

                when COMPUTE_OUTER =>

                    outer_11 <= delta_x_pos * delta_z_x; outer_12 <= delta_x_pos * delta_z_y; outer_13 <= delta_x_pos * delta_z_z;

                    outer_21 <= delta_x_vel * delta_z_x; outer_22 <= delta_x_vel * delta_z_y; outer_23 <= delta_x_vel * delta_z_z;

                    outer_31 <= delta_x_acc * delta_z_x; outer_32 <= delta_x_acc * delta_z_y; outer_33 <= delta_x_acc * delta_z_z;

                    outer_41 <= delta_y_pos * delta_z_x; outer_42 <= delta_y_pos * delta_z_y; outer_43 <= delta_y_pos * delta_z_z;

                    outer_51 <= delta_y_vel * delta_z_x; outer_52 <= delta_y_vel * delta_z_y; outer_53 <= delta_y_vel * delta_z_z;

                    outer_61 <= delta_y_acc * delta_z_x; outer_62 <= delta_y_acc * delta_z_y; outer_63 <= delta_y_acc * delta_z_z;

                    outer_71 <= delta_z_pos * delta_z_x; outer_72 <= delta_z_pos * delta_z_y; outer_73 <= delta_z_pos * delta_z_z;

                    outer_81 <= delta_z_vel * delta_z_x; outer_82 <= delta_z_vel * delta_z_y; outer_83 <= delta_z_vel * delta_z_z;

                    outer_91 <= delta_z_acc * delta_z_x; outer_92 <= delta_z_acc * delta_z_y; outer_93 <= delta_z_acc * delta_z_z;

                    state <= WEIGHT;

                when WEIGHT =>

                    weighted_11 <= resize(shift_right(current_weight * outer_11, Q), 96);
                    weighted_12 <= resize(shift_right(current_weight * outer_12, Q), 96);
                    weighted_13 <= resize(shift_right(current_weight * outer_13, Q), 96);
                    weighted_21 <= resize(shift_right(current_weight * outer_21, Q), 96);
                    weighted_22 <= resize(shift_right(current_weight * outer_22, Q), 96);
                    weighted_23 <= resize(shift_right(current_weight * outer_23, Q), 96);
                    weighted_31 <= resize(shift_right(current_weight * outer_31, Q), 96);
                    weighted_32 <= resize(shift_right(current_weight * outer_32, Q), 96);
                    weighted_33 <= resize(shift_right(current_weight * outer_33, Q), 96);
                    weighted_41 <= resize(shift_right(current_weight * outer_41, Q), 96);
                    weighted_42 <= resize(shift_right(current_weight * outer_42, Q), 96);
                    weighted_43 <= resize(shift_right(current_weight * outer_43, Q), 96);
                    weighted_51 <= resize(shift_right(current_weight * outer_51, Q), 96);
                    weighted_52 <= resize(shift_right(current_weight * outer_52, Q), 96);
                    weighted_53 <= resize(shift_right(current_weight * outer_53, Q), 96);
                    weighted_61 <= resize(shift_right(current_weight * outer_61, Q), 96);
                    weighted_62 <= resize(shift_right(current_weight * outer_62, Q), 96);
                    weighted_63 <= resize(shift_right(current_weight * outer_63, Q), 96);
                    weighted_71 <= resize(shift_right(current_weight * outer_71, Q), 96);
                    weighted_72 <= resize(shift_right(current_weight * outer_72, Q), 96);
                    weighted_73 <= resize(shift_right(current_weight * outer_73, Q), 96);
                    weighted_81 <= resize(shift_right(current_weight * outer_81, Q), 96);
                    weighted_82 <= resize(shift_right(current_weight * outer_82, Q), 96);
                    weighted_83 <= resize(shift_right(current_weight * outer_83, Q), 96);
                    weighted_91 <= resize(shift_right(current_weight * outer_91, Q), 96);
                    weighted_92 <= resize(shift_right(current_weight * outer_92, Q), 96);
                    weighted_93 <= resize(shift_right(current_weight * outer_93, Q), 96);

                    state <= ADD;

                when ADD =>

                    acc_11 <= acc_11 + weighted_11; acc_12 <= acc_12 + weighted_12; acc_13 <= acc_13 + weighted_13;
                    acc_21 <= acc_21 + weighted_21; acc_22 <= acc_22 + weighted_22; acc_23 <= acc_23 + weighted_23;
                    acc_31 <= acc_31 + weighted_31; acc_32 <= acc_32 + weighted_32; acc_33 <= acc_33 + weighted_33;
                    acc_41 <= acc_41 + weighted_41; acc_42 <= acc_42 + weighted_42; acc_43 <= acc_43 + weighted_43;
                    acc_51 <= acc_51 + weighted_51; acc_52 <= acc_52 + weighted_52; acc_53 <= acc_53 + weighted_53;
                    acc_61 <= acc_61 + weighted_61; acc_62 <= acc_62 + weighted_62; acc_63 <= acc_63 + weighted_63;
                    acc_71 <= acc_71 + weighted_71; acc_72 <= acc_72 + weighted_72; acc_73 <= acc_73 + weighted_73;
                    acc_81 <= acc_81 + weighted_81; acc_82 <= acc_82 + weighted_82; acc_83 <= acc_83 + weighted_83;
                    acc_91 <= acc_91 + weighted_91; acc_92 <= acc_92 + weighted_92; acc_93 <= acc_93 + weighted_93;

                    if accumulate_idx = 18 then
                        state <= NORMALIZE;
                    else
                        accumulate_idx <= accumulate_idx + 1;
                        state <= COMPUTE_DELTAS;
                    end if;

                when NORMALIZE =>

                    pxz_11 <= resize(shift_right(acc_11, Q), 48); pxz_12 <= resize(shift_right(acc_12, Q), 48); pxz_13 <= resize(shift_right(acc_13, Q), 48);
                    pxz_21 <= resize(shift_right(acc_21, Q), 48); pxz_22 <= resize(shift_right(acc_22, Q), 48); pxz_23 <= resize(shift_right(acc_23, Q), 48);
                    pxz_31 <= resize(shift_right(acc_31, Q), 48); pxz_32 <= resize(shift_right(acc_32, Q), 48); pxz_33 <= resize(shift_right(acc_33, Q), 48);
                    pxz_41 <= resize(shift_right(acc_41, Q), 48); pxz_42 <= resize(shift_right(acc_42, Q), 48); pxz_43 <= resize(shift_right(acc_43, Q), 48);
                    pxz_51 <= resize(shift_right(acc_51, Q), 48); pxz_52 <= resize(shift_right(acc_52, Q), 48); pxz_53 <= resize(shift_right(acc_53, Q), 48);
                    pxz_61 <= resize(shift_right(acc_61, Q), 48); pxz_62 <= resize(shift_right(acc_62, Q), 48); pxz_63 <= resize(shift_right(acc_63, Q), 48);
                    pxz_71 <= resize(shift_right(acc_71, Q), 48); pxz_72 <= resize(shift_right(acc_72, Q), 48); pxz_73 <= resize(shift_right(acc_73, Q), 48);
                    pxz_81 <= resize(shift_right(acc_81, Q), 48); pxz_82 <= resize(shift_right(acc_82, Q), 48); pxz_83 <= resize(shift_right(acc_83, Q), 48);
                    pxz_91 <= resize(shift_right(acc_91, Q), 48); pxz_92 <= resize(shift_right(acc_92, Q), 48); pxz_93 <= resize(shift_right(acc_93, Q), 48);

                    state <= FINISHED;

                when FINISHED =>

                    if abs(to_integer(pxz_42)) > 1677721600 or
                       abs(to_integer(pxz_52)) > 1677721600 or
                       abs(to_integer(pxz_62)) > 1677721600 then
                        report "WARNING: Pxz Y-axis elements exploding (>100)" severity warning;
                    end if;

                    done <= '1';
                    if start = '0' then
                        state <= IDLE;
                    end if;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end Behavioral;
