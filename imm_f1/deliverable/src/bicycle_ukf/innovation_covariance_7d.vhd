library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity innovation_covariance_7d is
    port (
        clk   : in  std_logic;
        start : in  std_logic;

        z_x_mean, z_y_mean, z_z_mean : in signed(47 downto 0);

        chi0_z_x, chi0_z_y, chi0_z_z : in signed(47 downto 0);
        chi1_z_x, chi1_z_y, chi1_z_z : in signed(47 downto 0);
        chi2_z_x, chi2_z_y, chi2_z_z : in signed(47 downto 0);
        chi3_z_x, chi3_z_y, chi3_z_z : in signed(47 downto 0);
        chi4_z_x, chi4_z_y, chi4_z_z : in signed(47 downto 0);
        chi5_z_x, chi5_z_y, chi5_z_z : in signed(47 downto 0);
        chi6_z_x, chi6_z_y, chi6_z_z : in signed(47 downto 0);
        chi7_z_x, chi7_z_y, chi7_z_z : in signed(47 downto 0);
        chi8_z_x, chi8_z_y, chi8_z_z : in signed(47 downto 0);
        chi9_z_x, chi9_z_y, chi9_z_z : in signed(47 downto 0);
        chi10_z_x, chi10_z_y, chi10_z_z : in signed(47 downto 0);
        chi11_z_x, chi11_z_y, chi11_z_z : in signed(47 downto 0);
        chi12_z_x, chi12_z_y, chi12_z_z : in signed(47 downto 0);
        chi13_z_x, chi13_z_y, chi13_z_z : in signed(47 downto 0);
        chi14_z_x, chi14_z_y, chi14_z_z : in signed(47 downto 0);

        s11, s12, s22, s13, s23, s33 : buffer signed(47 downto 0);

        done : out std_logic
    );
end innovation_covariance_7d;

architecture Behavioral of innovation_covariance_7d is

    constant W0 : signed(47 downto 0) := to_signed(33554432, 48);
    constant W1 : signed(47 downto 0) := to_signed(1198373, 48);
    constant Q  : integer := 24;

    constant R11_Q24 : signed(47 downto 0) := to_signed(4194304, 48);
    constant R22_Q24 : signed(47 downto 0) := to_signed(4194304, 48);
    constant R33_Q24 : signed(47 downto 0) := to_signed(4194304, 48);

    type state_type is (IDLE, COMPUTE_DELTA, COMPUTE_OUTER, WEIGHT, ADD, ADD_R, SATURATE, FINISHED);
    signal state : state_type := IDLE;
    signal accumulate_idx : integer range 0 to 14 := 0;

    type meas_array is array (0 to 14) of signed(47 downto 0);
    signal chi_z_x, chi_z_y, chi_z_z : meas_array := (others => (others => '0'));

    type weight_array is array (0 to 14) of signed(47 downto 0);
    constant WEIGHTS : weight_array := (W0, W1, W1, W1, W1, W1, W1, W1,
                                        W1, W1, W1, W1, W1, W1, W1);

    signal z_x_mean_reg, z_y_mean_reg, z_z_mean_reg : signed(47 downto 0);

    signal current_weight : signed(47 downto 0);

    signal delta_z_x, delta_z_y, delta_z_z : signed(47 downto 0) := (others => '0');

    signal outer_11, outer_12, outer_22 : signed(95 downto 0) := (others => '0');
    signal outer_13, outer_23, outer_33 : signed(95 downto 0) := (others => '0');

    signal weighted_11, weighted_12, weighted_22 : signed(95 downto 0) := (others => '0');
    signal weighted_13, weighted_23, weighted_33 : signed(95 downto 0) := (others => '0');

    signal acc_s11, acc_s12, acc_s22 : signed(48 downto 0) := (others => '0');
    signal acc_s13, acc_s23, acc_s33 : signed(48 downto 0) := (others => '0');

    signal sum_s11, sum_s22, sum_s33 : signed(48 downto 0) := (others => '0');
    signal sum_s12, sum_s13, sum_s23 : signed(48 downto 0) := (others => '0');

    constant MAX_VALUE : signed(47 downto 0) := signed'(X"3FFFFFFFFFFF");
    constant MIN_VALUE : signed(47 downto 0) := signed'(X"C00000000000");

begin

    process(clk)
    begin
        if rising_edge(clk) then
            case state is

                when IDLE =>
                    done <= '0';
                    accumulate_idx <= 0;
                    acc_s11 <= (others => '0'); acc_s12 <= (others => '0'); acc_s22 <= (others => '0');
                    acc_s13 <= (others => '0'); acc_s23 <= (others => '0'); acc_s33 <= (others => '0');

                    if start = '1' then
                        z_x_mean_reg <= z_x_mean;
                        z_y_mean_reg <= z_y_mean;
                        z_z_mean_reg <= z_z_mean;

                        chi_z_x(0)  <= chi0_z_x;  chi_z_y(0)  <= chi0_z_y;  chi_z_z(0)  <= chi0_z_z;
                        chi_z_x(1)  <= chi1_z_x;  chi_z_y(1)  <= chi1_z_y;  chi_z_z(1)  <= chi1_z_z;
                        chi_z_x(2)  <= chi2_z_x;  chi_z_y(2)  <= chi2_z_y;  chi_z_z(2)  <= chi2_z_z;
                        chi_z_x(3)  <= chi3_z_x;  chi_z_y(3)  <= chi3_z_y;  chi_z_z(3)  <= chi3_z_z;
                        chi_z_x(4)  <= chi4_z_x;  chi_z_y(4)  <= chi4_z_y;  chi_z_z(4)  <= chi4_z_z;
                        chi_z_x(5)  <= chi5_z_x;  chi_z_y(5)  <= chi5_z_y;  chi_z_z(5)  <= chi5_z_z;
                        chi_z_x(6)  <= chi6_z_x;  chi_z_y(6)  <= chi6_z_y;  chi_z_z(6)  <= chi6_z_z;
                        chi_z_x(7)  <= chi7_z_x;  chi_z_y(7)  <= chi7_z_y;  chi_z_z(7)  <= chi7_z_z;
                        chi_z_x(8)  <= chi8_z_x;  chi_z_y(8)  <= chi8_z_y;  chi_z_z(8)  <= chi8_z_z;
                        chi_z_x(9)  <= chi9_z_x;  chi_z_y(9)  <= chi9_z_y;  chi_z_z(9)  <= chi9_z_z;
                        chi_z_x(10) <= chi10_z_x; chi_z_y(10) <= chi10_z_y; chi_z_z(10) <= chi10_z_z;
                        chi_z_x(11) <= chi11_z_x; chi_z_y(11) <= chi11_z_y; chi_z_z(11) <= chi11_z_z;
                        chi_z_x(12) <= chi12_z_x; chi_z_y(12) <= chi12_z_y; chi_z_z(12) <= chi12_z_z;
                        chi_z_x(13) <= chi13_z_x; chi_z_y(13) <= chi13_z_y; chi_z_z(13) <= chi13_z_z;
                        chi_z_x(14) <= chi14_z_x; chi_z_y(14) <= chi14_z_y; chi_z_z(14) <= chi14_z_z;

                        state <= COMPUTE_DELTA;
                    end if;

                when COMPUTE_DELTA =>
                    current_weight <= WEIGHTS(accumulate_idx);
                    delta_z_x <= chi_z_x(accumulate_idx) - z_x_mean_reg;
                    delta_z_y <= chi_z_y(accumulate_idx) - z_y_mean_reg;
                    delta_z_z <= chi_z_z(accumulate_idx) - z_z_mean_reg;
                    state <= COMPUTE_OUTER;

                when COMPUTE_OUTER =>
                    outer_11 <= delta_z_x * delta_z_x;
                    outer_12 <= delta_z_x * delta_z_y;
                    outer_22 <= delta_z_y * delta_z_y;
                    outer_13 <= delta_z_x * delta_z_z;
                    outer_23 <= delta_z_y * delta_z_z;
                    outer_33 <= delta_z_z * delta_z_z;
                    state <= WEIGHT;

                when WEIGHT =>
                    weighted_11 <= resize(outer_11 * current_weight, 96);
                    weighted_12 <= resize(outer_12 * current_weight, 96);
                    weighted_22 <= resize(outer_22 * current_weight, 96);
                    weighted_13 <= resize(outer_13 * current_weight, 96);
                    weighted_23 <= resize(outer_23 * current_weight, 96);
                    weighted_33 <= resize(outer_33 * current_weight, 96);
                    state <= ADD;

                when ADD =>
                    acc_s11 <= acc_s11 + resize(shift_right(weighted_11, 2*Q), 49);
                    acc_s12 <= acc_s12 + resize(shift_right(weighted_12, 2*Q), 49);
                    acc_s22 <= acc_s22 + resize(shift_right(weighted_22, 2*Q), 49);
                    acc_s13 <= acc_s13 + resize(shift_right(weighted_13, 2*Q), 49);
                    acc_s23 <= acc_s23 + resize(shift_right(weighted_23, 2*Q), 49);
                    acc_s33 <= acc_s33 + resize(shift_right(weighted_33, 2*Q), 49);

                    if accumulate_idx = 14 then
                        state <= ADD_R;
                    else
                        accumulate_idx <= accumulate_idx + 1;
                        state <= COMPUTE_DELTA;
                    end if;

                when ADD_R =>
                    sum_s11 <= acc_s11 + resize(R11_Q24, 49);
                    sum_s22 <= acc_s22 + resize(R22_Q24, 49);
                    sum_s33 <= acc_s33 + resize(R33_Q24, 49);
                    sum_s12 <= acc_s12;
                    sum_s13 <= acc_s13;
                    sum_s23 <= acc_s23;
                    state <= SATURATE;

                when SATURATE =>
                    if sum_s11 > MAX_VALUE then s11 <= MAX_VALUE;
                    elsif sum_s11 < 0 then s11 <= to_signed(0, 48);
                    else s11 <= resize(sum_s11, 48); end if;

                    if sum_s22 > MAX_VALUE then s22 <= MAX_VALUE;
                    elsif sum_s22 < 0 then s22 <= to_signed(0, 48);
                    else s22 <= resize(sum_s22, 48); end if;

                    if sum_s33 > MAX_VALUE then s33 <= MAX_VALUE;
                    elsif sum_s33 < 0 then s33 <= to_signed(0, 48);
                    else s33 <= resize(sum_s33, 48); end if;

                    if sum_s12 > MAX_VALUE then s12 <= MAX_VALUE;
                    elsif sum_s12 < MIN_VALUE then s12 <= MIN_VALUE;
                    else s12 <= resize(sum_s12, 48); end if;

                    if sum_s13 > MAX_VALUE then s13 <= MAX_VALUE;
                    elsif sum_s13 < MIN_VALUE then s13 <= MIN_VALUE;
                    else s13 <= resize(sum_s13, 48); end if;

                    if sum_s23 > MAX_VALUE then s23 <= MAX_VALUE;
                    elsif sum_s23 < MIN_VALUE then s23 <= MIN_VALUE;
                    else s23 <= resize(sum_s23, 48); end if;

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
