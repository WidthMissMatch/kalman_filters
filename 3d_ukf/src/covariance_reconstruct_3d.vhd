library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.TEXTIO.ALL;

entity covariance_reconstruct_3d is
    port (
        clk   : in  std_logic;
        start : in  std_logic;

        x_pos_mean, x_vel_mean, y_pos_mean, y_vel_mean, z_pos_mean, z_vel_mean : in signed(47 downto 0);

        chi0_x_pos_pred, chi0_x_vel_pred, chi0_y_pos_pred, chi0_y_vel_pred, chi0_z_pos_pred, chi0_z_vel_pred : in signed(47 downto 0);
        chi1_x_pos_pred, chi1_x_vel_pred, chi1_y_pos_pred, chi1_y_vel_pred, chi1_z_pos_pred, chi1_z_vel_pred : in signed(47 downto 0);
        chi2_x_pos_pred, chi2_x_vel_pred, chi2_y_pos_pred, chi2_y_vel_pred, chi2_z_pos_pred, chi2_z_vel_pred : in signed(47 downto 0);
        chi3_x_pos_pred, chi3_x_vel_pred, chi3_y_pos_pred, chi3_y_vel_pred, chi3_z_pos_pred, chi3_z_vel_pred : in signed(47 downto 0);
        chi4_x_pos_pred, chi4_x_vel_pred, chi4_y_pos_pred, chi4_y_vel_pred, chi4_z_pos_pred, chi4_z_vel_pred : in signed(47 downto 0);
        chi5_x_pos_pred, chi5_x_vel_pred, chi5_y_pos_pred, chi5_y_vel_pred, chi5_z_pos_pred, chi5_z_vel_pred : in signed(47 downto 0);
        chi6_x_pos_pred, chi6_x_vel_pred, chi6_y_pos_pred, chi6_y_vel_pred, chi6_z_pos_pred, chi6_z_vel_pred : in signed(47 downto 0);
        chi7_x_pos_pred, chi7_x_vel_pred, chi7_y_pos_pred, chi7_y_vel_pred, chi7_z_pos_pred, chi7_z_vel_pred : in signed(47 downto 0);
        chi8_x_pos_pred, chi8_x_vel_pred, chi8_y_pos_pred, chi8_y_vel_pred, chi8_z_pos_pred, chi8_z_vel_pred : in signed(47 downto 0);
        chi9_x_pos_pred, chi9_x_vel_pred, chi9_y_pos_pred, chi9_y_vel_pred, chi9_z_pos_pred, chi9_z_vel_pred : in signed(47 downto 0);
        chi10_x_pos_pred, chi10_x_vel_pred, chi10_y_pos_pred, chi10_y_vel_pred, chi10_z_pos_pred, chi10_z_vel_pred : in signed(47 downto 0);
        chi11_x_pos_pred, chi11_x_vel_pred, chi11_y_pos_pred, chi11_y_vel_pred, chi11_z_pos_pred, chi11_z_vel_pred : in signed(47 downto 0);
        chi12_x_pos_pred, chi12_x_vel_pred, chi12_y_pos_pred, chi12_y_vel_pred, chi12_z_pos_pred, chi12_z_vel_pred : in signed(47 downto 0);

        p11_out, p12_out, p13_out, p14_out, p15_out, p16_out : out signed(47 downto 0);
        p22_out, p23_out, p24_out, p25_out, p26_out           : out signed(47 downto 0);
        p33_out, p34_out, p35_out, p36_out                    : out signed(47 downto 0);
        p44_out, p45_out, p46_out                             : out signed(47 downto 0);
        p55_out, p56_out                                      : out signed(47 downto 0);
        p66_out                                               : out signed(47 downto 0);

        done : out std_logic
    );
end covariance_reconstruct_3d;

architecture Behavioral of covariance_reconstruct_3d is

    constant W0 : signed(47 downto 0) := to_signed(5592405, 48);
    constant W1 : signed(47 downto 0) := to_signed(932068, 48);
    constant Q : integer := 24;

    type state_type is (IDLE, LATCH_INPUTS, COMPUTE_DELTA, COMPUTE_OUTER, WEIGHT, ADD, NORMALIZE, FINISHED);
    signal state : state_type := IDLE;
    signal accumulate_idx : integer range 0 to 12 := 0;

    signal x_pos_mean_reg, x_vel_mean_reg, y_pos_mean_reg, y_vel_mean_reg, z_pos_mean_reg, z_vel_mean_reg : signed(47 downto 0) := (others => '0');

    type sigma_point_array is array (0 to 12) of signed(47 downto 0);
    signal chi_x_pos, chi_x_vel, chi_y_pos, chi_y_vel, chi_z_pos, chi_z_vel : sigma_point_array := (others => (others => '0'));

    type weight_array is array (0 to 12) of signed(47 downto 0);
    constant WEIGHTS : weight_array := (W0, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1);
    signal current_weight_reg : signed(47 downto 0) := (others => '0');

    signal delta_x_pos, delta_x_vel, delta_y_pos, delta_y_vel, delta_z_pos, delta_z_vel : signed(47 downto 0) := (others => '0');

    signal outer_11, outer_12, outer_13, outer_14, outer_15, outer_16 : signed(95 downto 0) := (others => '0');
    signal outer_22, outer_23, outer_24, outer_25, outer_26           : signed(95 downto 0) := (others => '0');
    signal outer_33, outer_34, outer_35, outer_36                     : signed(95 downto 0) := (others => '0');
    signal outer_44, outer_45, outer_46                               : signed(95 downto 0) := (others => '0');
    signal outer_55, outer_56                                         : signed(95 downto 0) := (others => '0');
    signal outer_66                                                   : signed(95 downto 0) := (others => '0');

    signal weighted_11, weighted_12, weighted_13, weighted_14, weighted_15, weighted_16 : signed(95 downto 0) := (others => '0');
    signal weighted_22, weighted_23, weighted_24, weighted_25, weighted_26              : signed(95 downto 0) := (others => '0');
    signal weighted_33, weighted_34, weighted_35, weighted_36                           : signed(95 downto 0) := (others => '0');
    signal weighted_44, weighted_45, weighted_46                                        : signed(95 downto 0) := (others => '0');
    signal weighted_55, weighted_56                                                     : signed(95 downto 0) := (others => '0');
    signal weighted_66                                                                  : signed(95 downto 0) := (others => '0');

    signal acc_p11, acc_p12, acc_p13, acc_p14, acc_p15, acc_p16 : signed(43 downto 0) := (others => '0');
    signal acc_p22, acc_p23, acc_p24, acc_p25, acc_p26          : signed(43 downto 0) := (others => '0');
    signal acc_p33, acc_p34, acc_p35, acc_p36                   : signed(43 downto 0) := (others => '0');
    signal acc_p44, acc_p45, acc_p46                            : signed(43 downto 0) := (others => '0');
    signal acc_p55, acc_p56                                     : signed(43 downto 0) := (others => '0');
    signal acc_p66                                              : signed(43 downto 0) := (others => '0');

begin

    process(clk)
    begin
        if rising_edge(clk) then
            case state is

                when IDLE =>
                    done <= '0';
                    accumulate_idx <= 0;

                    acc_p11 <= (others => '0'); acc_p12 <= (others => '0'); acc_p13 <= (others => '0'); acc_p14 <= (others => '0'); acc_p15 <= (others => '0'); acc_p16 <= (others => '0');
                    acc_p22 <= (others => '0'); acc_p23 <= (others => '0'); acc_p24 <= (others => '0'); acc_p25 <= (others => '0'); acc_p26 <= (others => '0');
                    acc_p33 <= (others => '0'); acc_p34 <= (others => '0'); acc_p35 <= (others => '0'); acc_p36 <= (others => '0');
                    acc_p44 <= (others => '0'); acc_p45 <= (others => '0'); acc_p46 <= (others => '0');
                    acc_p55 <= (others => '0'); acc_p56 <= (others => '0');
                    acc_p66 <= (others => '0');

                    if start = '1' then
                        state <= LATCH_INPUTS;
                    end if;

                when LATCH_INPUTS =>

                    x_pos_mean_reg <= x_pos_mean;
                    x_vel_mean_reg <= x_vel_mean;
                    y_pos_mean_reg <= y_pos_mean;
                    y_vel_mean_reg <= y_vel_mean;
                    z_pos_mean_reg <= z_pos_mean;
                    z_vel_mean_reg <= z_vel_mean;

                    chi_x_pos(0) <= chi0_x_pos_pred; chi_x_vel(0) <= chi0_x_vel_pred;
                    chi_y_pos(0) <= chi0_y_pos_pred; chi_y_vel(0) <= chi0_y_vel_pred;
                    chi_z_pos(0) <= chi0_z_pos_pred; chi_z_vel(0) <= chi0_z_vel_pred;

                    chi_x_pos(1) <= chi1_x_pos_pred; chi_x_vel(1) <= chi1_x_vel_pred;
                    chi_y_pos(1) <= chi1_y_pos_pred; chi_y_vel(1) <= chi1_y_vel_pred;
                    chi_z_pos(1) <= chi1_z_pos_pred; chi_z_vel(1) <= chi1_z_vel_pred;

                    chi_x_pos(2) <= chi2_x_pos_pred; chi_x_vel(2) <= chi2_x_vel_pred;
                    chi_y_pos(2) <= chi2_y_pos_pred; chi_y_vel(2) <= chi2_y_vel_pred;
                    chi_z_pos(2) <= chi2_z_pos_pred; chi_z_vel(2) <= chi2_z_vel_pred;

                    chi_x_pos(3) <= chi3_x_pos_pred; chi_x_vel(3) <= chi3_x_vel_pred;
                    chi_y_pos(3) <= chi3_y_pos_pred; chi_y_vel(3) <= chi3_y_vel_pred;
                    chi_z_pos(3) <= chi3_z_pos_pred; chi_z_vel(3) <= chi3_z_vel_pred;

                    chi_x_pos(4) <= chi4_x_pos_pred; chi_x_vel(4) <= chi4_x_vel_pred;
                    chi_y_pos(4) <= chi4_y_pos_pred; chi_y_vel(4) <= chi4_y_vel_pred;
                    chi_z_pos(4) <= chi4_z_pos_pred; chi_z_vel(4) <= chi4_z_vel_pred;

                    chi_x_pos(5) <= chi5_x_pos_pred; chi_x_vel(5) <= chi5_x_vel_pred;
                    chi_y_pos(5) <= chi5_y_pos_pred; chi_y_vel(5) <= chi5_y_vel_pred;
                    chi_z_pos(5) <= chi5_z_pos_pred; chi_z_vel(5) <= chi5_z_vel_pred;

                    chi_x_pos(6) <= chi6_x_pos_pred; chi_x_vel(6) <= chi6_x_vel_pred;
                    chi_y_pos(6) <= chi6_y_pos_pred; chi_y_vel(6) <= chi6_y_vel_pred;
                    chi_z_pos(6) <= chi6_z_pos_pred; chi_z_vel(6) <= chi6_z_vel_pred;

                    chi_x_pos(7) <= chi7_x_pos_pred; chi_x_vel(7) <= chi7_x_vel_pred;
                    chi_y_pos(7) <= chi7_y_pos_pred; chi_y_vel(7) <= chi7_y_vel_pred;
                    chi_z_pos(7) <= chi7_z_pos_pred; chi_z_vel(7) <= chi7_z_vel_pred;

                    chi_x_pos(8) <= chi8_x_pos_pred; chi_x_vel(8) <= chi8_x_vel_pred;
                    chi_y_pos(8) <= chi8_y_pos_pred; chi_y_vel(8) <= chi8_y_vel_pred;
                    chi_z_pos(8) <= chi8_z_pos_pred; chi_z_vel(8) <= chi8_z_vel_pred;

                    chi_x_pos(9) <= chi9_x_pos_pred; chi_x_vel(9) <= chi9_x_vel_pred;
                    chi_y_pos(9) <= chi9_y_pos_pred; chi_y_vel(9) <= chi9_y_vel_pred;
                    chi_z_pos(9) <= chi9_z_pos_pred; chi_z_vel(9) <= chi9_z_vel_pred;

                    chi_x_pos(10) <= chi10_x_pos_pred; chi_x_vel(10) <= chi10_x_vel_pred;
                    chi_y_pos(10) <= chi10_y_pos_pred; chi_y_vel(10) <= chi10_y_vel_pred;
                    chi_z_pos(10) <= chi10_z_pos_pred; chi_z_vel(10) <= chi10_z_vel_pred;

                    chi_x_pos(11) <= chi11_x_pos_pred; chi_x_vel(11) <= chi11_x_vel_pred;
                    chi_y_pos(11) <= chi11_y_pos_pred; chi_y_vel(11) <= chi11_y_vel_pred;
                    chi_z_pos(11) <= chi11_z_pos_pred; chi_z_vel(11) <= chi11_z_vel_pred;

                    chi_x_pos(12) <= chi12_x_pos_pred; chi_x_vel(12) <= chi12_x_vel_pred;
                    chi_y_pos(12) <= chi12_y_pos_pred; chi_y_vel(12) <= chi12_y_vel_pred;
                    chi_z_pos(12) <= chi12_z_pos_pred; chi_z_vel(12) <= chi12_z_vel_pred;

                    state <= COMPUTE_DELTA;

                when COMPUTE_DELTA =>

                    if accumulate_idx <= 2 then
                        report "COV_RECON: COMPUTE_DELTA idx=" & integer'image(accumulate_idx) & LF &
                               "  chi_x_pos(" & integer'image(accumulate_idx) & ")=" & integer'image(to_integer(chi_x_pos(accumulate_idx))) & LF &
                               "  x_pos_mean_reg=" & integer'image(to_integer(x_pos_mean_reg));
                    end if;

                    current_weight_reg <= WEIGHTS(accumulate_idx);

                    delta_x_pos <= chi_x_pos(accumulate_idx) - x_pos_mean_reg;
                    delta_x_vel <= chi_x_vel(accumulate_idx) - x_vel_mean_reg;
                    delta_y_pos <= chi_y_pos(accumulate_idx) - y_pos_mean_reg;
                    delta_y_vel <= chi_y_vel(accumulate_idx) - y_vel_mean_reg;
                    delta_z_pos <= chi_z_pos(accumulate_idx) - z_pos_mean_reg;
                    delta_z_vel <= chi_z_vel(accumulate_idx) - z_vel_mean_reg;

                    state <= COMPUTE_OUTER;

                when COMPUTE_OUTER =>

                    outer_11 <= delta_x_pos * delta_x_pos;
                    outer_12 <= delta_x_pos * delta_x_vel;
                    outer_13 <= delta_x_pos * delta_y_pos;
                    outer_14 <= delta_x_pos * delta_y_vel;
                    outer_15 <= delta_x_pos * delta_z_pos;
                    outer_16 <= delta_x_pos * delta_z_vel;

                    outer_22 <= delta_x_vel * delta_x_vel;
                    outer_23 <= delta_x_vel * delta_y_pos;
                    outer_24 <= delta_x_vel * delta_y_vel;
                    outer_25 <= delta_x_vel * delta_z_pos;
                    outer_26 <= delta_x_vel * delta_z_vel;

                    outer_33 <= delta_y_pos * delta_y_pos;
                    outer_34 <= delta_y_pos * delta_y_vel;
                    outer_35 <= delta_y_pos * delta_z_pos;
                    outer_36 <= delta_y_pos * delta_z_vel;

                    outer_44 <= delta_y_vel * delta_y_vel;
                    outer_45 <= delta_y_vel * delta_z_pos;
                    outer_46 <= delta_y_vel * delta_z_vel;

                    outer_55 <= delta_z_pos * delta_z_pos;
                    outer_56 <= delta_z_pos * delta_z_vel;

                    outer_66 <= delta_z_vel * delta_z_vel;

                    state <= WEIGHT;

                when WEIGHT =>

                    weighted_11 <= resize(outer_11 * current_weight_reg, 96);
                    weighted_12 <= resize(outer_12 * current_weight_reg, 96);
                    weighted_13 <= resize(outer_13 * current_weight_reg, 96);
                    weighted_14 <= resize(outer_14 * current_weight_reg, 96);
                    weighted_15 <= resize(outer_15 * current_weight_reg, 96);
                    weighted_16 <= resize(outer_16 * current_weight_reg, 96);

                    weighted_22 <= resize(outer_22 * current_weight_reg, 96);
                    weighted_23 <= resize(outer_23 * current_weight_reg, 96);
                    weighted_24 <= resize(outer_24 * current_weight_reg, 96);
                    weighted_25 <= resize(outer_25 * current_weight_reg, 96);
                    weighted_26 <= resize(outer_26 * current_weight_reg, 96);

                    weighted_33 <= resize(outer_33 * current_weight_reg, 96);
                    weighted_34 <= resize(outer_34 * current_weight_reg, 96);
                    weighted_35 <= resize(outer_35 * current_weight_reg, 96);
                    weighted_36 <= resize(outer_36 * current_weight_reg, 96);

                    weighted_44 <= resize(outer_44 * current_weight_reg, 96);
                    weighted_45 <= resize(outer_45 * current_weight_reg, 96);
                    weighted_46 <= resize(outer_46 * current_weight_reg, 96);

                    weighted_55 <= resize(outer_55 * current_weight_reg, 96);
                    weighted_56 <= resize(outer_56 * current_weight_reg, 96);

                    weighted_66 <= resize(outer_66 * current_weight_reg, 96);

                    state <= ADD;

                when ADD =>

                    acc_p11 <= acc_p11 + resize(shift_right(weighted_11, 2*Q), 44);
                    acc_p12 <= acc_p12 + resize(shift_right(weighted_12, 2*Q), 44);
                    acc_p13 <= acc_p13 + resize(shift_right(weighted_13, 2*Q), 44);
                    acc_p14 <= acc_p14 + resize(shift_right(weighted_14, 2*Q), 44);
                    acc_p15 <= acc_p15 + resize(shift_right(weighted_15, 2*Q), 44);
                    acc_p16 <= acc_p16 + resize(shift_right(weighted_16, 2*Q), 44);

                    acc_p22 <= acc_p22 + resize(shift_right(weighted_22, 2*Q), 44);
                    acc_p23 <= acc_p23 + resize(shift_right(weighted_23, 2*Q), 44);
                    acc_p24 <= acc_p24 + resize(shift_right(weighted_24, 2*Q), 44);
                    acc_p25 <= acc_p25 + resize(shift_right(weighted_25, 2*Q), 44);
                    acc_p26 <= acc_p26 + resize(shift_right(weighted_26, 2*Q), 44);

                    acc_p33 <= acc_p33 + resize(shift_right(weighted_33, 2*Q), 44);
                    acc_p34 <= acc_p34 + resize(shift_right(weighted_34, 2*Q), 44);
                    acc_p35 <= acc_p35 + resize(shift_right(weighted_35, 2*Q), 44);
                    acc_p36 <= acc_p36 + resize(shift_right(weighted_36, 2*Q), 44);

                    acc_p44 <= acc_p44 + resize(shift_right(weighted_44, 2*Q), 44);
                    acc_p45 <= acc_p45 + resize(shift_right(weighted_45, 2*Q), 44);
                    acc_p46 <= acc_p46 + resize(shift_right(weighted_46, 2*Q), 44);

                    acc_p55 <= acc_p55 + resize(shift_right(weighted_55, 2*Q), 44);
                    acc_p56 <= acc_p56 + resize(shift_right(weighted_56, 2*Q), 44);

                    acc_p66 <= acc_p66 + resize(shift_right(weighted_66, 2*Q), 44);

                    if accumulate_idx = 12 then
                        state <= NORMALIZE;
                    else
                        accumulate_idx <= accumulate_idx + 1;
                        state <= COMPUTE_DELTA;
                    end if;

                when NORMALIZE =>

                    report "COV_RECON: NORMALIZE" & LF &
                           "  acc_p11(43:0)=" & integer'image(to_integer(acc_p11(31 downto 0))) & LF &
                           "  acc_p22(43:0)=" & integer'image(to_integer(acc_p22(31 downto 0)));

                    p11_out <= resize(acc_p11, 48);
                    p12_out <= resize(acc_p12, 48);
                    p13_out <= resize(acc_p13, 48);
                    p14_out <= resize(acc_p14, 48);
                    p15_out <= resize(acc_p15, 48);
                    p16_out <= resize(acc_p16, 48);

                    p22_out <= resize(acc_p22, 48);
                    p23_out <= resize(acc_p23, 48);
                    p24_out <= resize(acc_p24, 48);
                    p25_out <= resize(acc_p25, 48);
                    p26_out <= resize(acc_p26, 48);

                    p33_out <= resize(acc_p33, 48);
                    p34_out <= resize(acc_p34, 48);
                    p35_out <= resize(acc_p35, 48);
                    p36_out <= resize(acc_p36, 48);

                    p44_out <= resize(acc_p44, 48);
                    p45_out <= resize(acc_p45, 48);
                    p46_out <= resize(acc_p46, 48);

                    p55_out <= resize(acc_p55, 48);
                    p56_out <= resize(acc_p56, 48);

                    p66_out <= resize(acc_p66, 48);

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
