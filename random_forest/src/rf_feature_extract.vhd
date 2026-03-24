library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.rf_fixed_point_pkg.all;

entity rf_feature_extract is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        start : in  std_logic;

        px_in : in  q24_t;
        py_in : in  q24_t;
        pz_in : in  q24_t;
        vx_in : in  q24_t;
        vy_in : in  q24_t;
        vz_in : in  q24_t;
        ax_in : in  q24_t;
        ay_in : in  q24_t;
        az_in : in  q24_t;

        features : out feature_vector_t;
        done     : out std_logic
    );
end rf_feature_extract;

architecture Behavioral of rf_feature_extract is

    type state_t is (IDLE, COMPUTE_SQ, SUM, ABS_SIGN, DIVIDE, DONE_ST);
    signal state : state_t := IDLE;

    signal px_r, py_r, pz_r : q24_t := (others => '0');
    signal vx_r, vy_r, vz_r : q24_t := (others => '0');
    signal ax_r, ay_r, az_r : q24_t := (others => '0');

    signal vx2, vy2, vz2 : q24_t := (others => '0');
    signal ax2, ay2, az2 : q24_t := (others => '0');

    signal f0_reg, f2_reg, f4_reg, f5_reg : q24_t := (others => '0');
    signal f3_reg, f6_reg, f7_reg, f8_reg : q24_t := (others => '0');

    signal done_reg : std_logic := '0';

begin

    process(clk)

        variable p_vx2   : signed(95 downto 0);
        variable p_vy2   : signed(95 downto 0);
        variable p_vz2   : signed(95 downto 0);
        variable p_ax2   : signed(95 downto 0);
        variable p_ay2   : signed(95 downto 0);
        variable p_az2   : signed(95 downto 0);

        variable v_num96 : signed(95 downto 0);
        variable v_den48 : signed(47 downto 0);
        variable v_den96 : signed(95 downto 0);
        variable v_res96 : signed(95 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state    <= IDLE;
                done_reg <= '0';
                features <= (others => (others => '0'));
            else
                done_reg <= '0';

                case state is

                    when IDLE =>
                        if start = '1' then
                            px_r  <= px_in;
                            py_r  <= py_in;
                            pz_r  <= pz_in;
                            vx_r  <= vx_in;
                            vy_r  <= vy_in;
                            vz_r  <= vz_in;
                            ax_r  <= ax_in;
                            ay_r  <= ay_in;
                            az_r  <= az_in;
                            state <= COMPUTE_SQ;
                        end if;

                    when COMPUTE_SQ =>

                        p_vx2 := vx_r * vx_r;  vx2 <= p_vx2(71 downto 24);
                        p_vy2 := vy_r * vy_r;  vy2 <= p_vy2(71 downto 24);
                        p_vz2 := vz_r * vz_r;  vz2 <= p_vz2(71 downto 24);
                        p_ax2 := ax_r * ax_r;  ax2 <= p_ax2(71 downto 24);
                        p_ay2 := ay_r * ay_r;  ay2 <= p_ay2(71 downto 24);
                        p_az2 := az_r * az_r;  az2 <= p_az2(71 downto 24);

                        state <= SUM;

                    when SUM =>

                        f0_reg <= vx2 + vy2 + vz2;

                        f2_reg <= vx2 + vy2;

                        f4_reg <= ax2 + ay2 + az2;

                        f5_reg <= ax2 + ay2;
                        state  <= ABS_SIGN;

                    when ABS_SIGN =>

                        if vz_r(47) = '1' then
                            f3_reg <= -vz_r;
                        else
                            f3_reg <= vz_r;
                        end if;

                        if vz_r(47) = '0' then
                            f6_reg <= vz2;
                        else
                            f6_reg <= -vz2;
                        end if;

                        if pz_r(47) = '1' then
                            f7_reg <= -pz_r;
                        else
                            f7_reg <= pz_r;
                        end if;
                        state <= DIVIDE;

                    when DIVIDE =>

                        v_den48 := f0_reg + to_signed(Q_SCALE, 48);
                        if v_den48 <= 0 then

                            f8_reg <= f5_reg;
                        else
                            v_num96 := shift_left(resize(f5_reg, 96), Q);
                            v_den96 := resize(v_den48, 96);
                            v_res96 := v_num96 / v_den96;

                            if v_res96(95 downto 47) = (95 downto 47 => v_res96(47)) then
                                f8_reg <= resize(v_res96, 48);
                            elsif v_res96(95) = '0' then
                                f8_reg <= (47 => '0', others => '1');
                            else
                                f8_reg <= (47 => '1', others => '0');
                            end if;
                        end if;
                        state <= DONE_ST;

                    when DONE_ST =>
                        features(0) <= f0_reg;
                        features(1) <= pz_r;
                        features(2) <= f2_reg;
                        features(3) <= f3_reg;
                        features(4) <= f4_reg;
                        features(5) <= f5_reg;
                        features(6) <= f6_reg;
                        features(7) <= f7_reg;
                        features(8) <= f8_reg;
                        done_reg    <= '1';
                        state       <= IDLE;

                end case;
            end if;
        end if;
    end process;

    done <= done_reg;

end Behavioral;
