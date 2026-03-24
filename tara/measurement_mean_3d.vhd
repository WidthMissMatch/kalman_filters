library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity measurement_mean_3d is
    port (
        clk   : in  std_logic;
        start : in  std_logic;
        chi0_x_pos, chi0_y_pos, chi0_z_pos : in signed(47 downto 0);
        chi1_x_pos, chi1_y_pos, chi1_z_pos : in signed(47 downto 0);
        chi2_x_pos, chi2_y_pos, chi2_z_pos : in signed(47 downto 0);
        chi3_x_pos, chi3_y_pos, chi3_z_pos : in signed(47 downto 0);
        chi4_x_pos, chi4_y_pos, chi4_z_pos : in signed(47 downto 0);
        chi5_x_pos, chi5_y_pos, chi5_z_pos : in signed(47 downto 0);
        chi6_x_pos, chi6_y_pos, chi6_z_pos : in signed(47 downto 0);
        chi7_x_pos, chi7_y_pos, chi7_z_pos : in signed(47 downto 0);
        chi8_x_pos, chi8_y_pos, chi8_z_pos : in signed(47 downto 0);
        chi9_x_pos, chi9_y_pos, chi9_z_pos : in signed(47 downto 0);
        chi10_x_pos, chi10_y_pos, chi10_z_pos : in signed(47 downto 0);
        chi11_x_pos, chi11_y_pos, chi11_z_pos : in signed(47 downto 0);
        chi12_x_pos, chi12_y_pos, chi12_z_pos : in signed(47 downto 0);
        z_x_mean : out signed(47 downto 0);
        z_y_mean : out signed(47 downto 0);
        z_z_mean : out signed(47 downto 0);
        done : out std_logic
    );
end measurement_mean_3d;
architecture Behavioral of measurement_mean_3d is
    constant W0 : signed(47 downto 0) := to_signed(-16777216, 48);
    constant W1 : signed(47 downto 0) := to_signed(2796203, 48);
    constant Q : integer := 24;
    type state_type is (IDLE, MULTIPLY, ADD, NORMALIZE, FINISHED);
    signal state : state_type := IDLE;
    signal accumulate_count : integer range 0 to 12 := 0;
    type position_array is array (0 to 12) of signed(47 downto 0);
    signal chi_x_pos_array, chi_y_pos_array, chi_z_pos_array : position_array := (others => (others => '0'));
    type weight_array is array (0 to 12) of signed(47 downto 0);
    constant WEIGHTS : weight_array := (W0, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1, W1);
    signal acc_z_x : signed(43 downto 0) := (others => '0');
    signal acc_z_y : signed(43 downto 0) := (others => '0');
    signal acc_z_z : signed(43 downto 0) := (others => '0');
    signal weighted_x, weighted_y, weighted_z : signed(95 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when IDLE =>
                    done <= '0';
                    accumulate_count <= 0;
                    acc_z_x <= (others => '0');
                    acc_z_y <= (others => '0');
                    acc_z_z <= (others => '0');
                    if start = '1' then
                        chi_x_pos_array(0) <= chi0_x_pos;
                        chi_y_pos_array(0) <= chi0_y_pos;
                        chi_z_pos_array(0) <= chi0_z_pos;
                        chi_x_pos_array(1) <= chi1_x_pos;
                        chi_y_pos_array(1) <= chi1_y_pos;
                        chi_z_pos_array(1) <= chi1_z_pos;
                        chi_x_pos_array(2) <= chi2_x_pos;
                        chi_y_pos_array(2) <= chi2_y_pos;
                        chi_z_pos_array(2) <= chi2_z_pos;
                        chi_x_pos_array(3) <= chi3_x_pos;
                        chi_y_pos_array(3) <= chi3_y_pos;
                        chi_z_pos_array(3) <= chi3_z_pos;
                        chi_x_pos_array(4) <= chi4_x_pos;
                        chi_y_pos_array(4) <= chi4_y_pos;
                        chi_z_pos_array(4) <= chi4_z_pos;
                        chi_x_pos_array(5) <= chi5_x_pos;
                        chi_y_pos_array(5) <= chi5_y_pos;
                        chi_z_pos_array(5) <= chi5_z_pos;
                        chi_x_pos_array(6) <= chi6_x_pos;
                        chi_y_pos_array(6) <= chi6_y_pos;
                        chi_z_pos_array(6) <= chi6_z_pos;
                        chi_x_pos_array(7) <= chi7_x_pos;
                        chi_y_pos_array(7) <= chi7_y_pos;
                        chi_z_pos_array(7) <= chi7_z_pos;
                        chi_x_pos_array(8) <= chi8_x_pos;
                        chi_y_pos_array(8) <= chi8_y_pos;
                        chi_z_pos_array(8) <= chi8_z_pos;
                        chi_x_pos_array(9) <= chi9_x_pos;
                        chi_y_pos_array(9) <= chi9_y_pos;
                        chi_z_pos_array(9) <= chi9_z_pos;
                        chi_x_pos_array(10) <= chi10_x_pos;
                        chi_y_pos_array(10) <= chi10_y_pos;
                        chi_z_pos_array(10) <= chi10_z_pos;
                        chi_x_pos_array(11) <= chi11_x_pos;
                        chi_y_pos_array(11) <= chi11_y_pos;
                        chi_z_pos_array(11) <= chi11_z_pos;
                        chi_x_pos_array(12) <= chi12_x_pos;
                        chi_y_pos_array(12) <= chi12_y_pos;
                        chi_z_pos_array(12) <= chi12_z_pos;
                        state <= MULTIPLY;
                    end if;
                when MULTIPLY =>
                    weighted_x <= chi_x_pos_array(accumulate_count) * WEIGHTS(accumulate_count);
                    weighted_y <= chi_y_pos_array(accumulate_count) * WEIGHTS(accumulate_count);
                    weighted_z <= chi_z_pos_array(accumulate_count) * WEIGHTS(accumulate_count);
                    state <= ADD;
                when ADD =>
                    acc_z_x <= acc_z_x + resize(shift_right(weighted_x, Q), 44);
                    acc_z_y <= acc_z_y + resize(shift_right(weighted_y, Q), 44);
                    acc_z_z <= acc_z_z + resize(shift_right(weighted_z, Q), 44);
                    if accumulate_count = 12 then
                        state <= NORMALIZE;
                    else
                        accumulate_count <= accumulate_count + 1;
                        state <= MULTIPLY;
                    end if;
                when NORMALIZE =>
                    z_x_mean <= resize(acc_z_x, 48);
                    z_y_mean <= resize(acc_z_y, 48);
                    z_z_mean <= resize(acc_z_z, 48);
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
