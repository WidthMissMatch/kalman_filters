library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity innovation_3d is
    port (
        clk   : in  std_logic;
        start : in  std_logic;

        z_x_meas : in signed(47 downto 0);
        z_y_meas : in signed(47 downto 0);
        z_z_meas : in signed(47 downto 0);

        z_x_mean : in signed(47 downto 0);
        z_y_mean : in signed(47 downto 0);
        z_z_mean : in signed(47 downto 0);

        nu_x : out signed(47 downto 0);
        nu_y : out signed(47 downto 0);
        nu_z : out signed(47 downto 0);

        done : out std_logic
    );
end innovation_3d;

architecture Behavioral of innovation_3d is

    type state_type is (IDLE, COMPUTE, SATURATE, FINISHED);
    signal state : state_type := IDLE;

    signal diff_x : signed(48 downto 0);
    signal diff_y : signed(48 downto 0);
    signal diff_z : signed(48 downto 0);

    constant MAX_VALUE : signed(47 downto 0) := signed'(X"3FFFFFFFFFFF");
    constant MIN_VALUE : signed(47 downto 0) := signed'(X"C00000000000");

begin

    process(clk)
    begin
        if rising_edge(clk) then
            case state is

                when IDLE =>
                    done <= '0';
                    if start = '1' then
                        state <= COMPUTE;
                    end if;

                when COMPUTE =>

                    diff_x <= resize(z_x_meas, 49) - resize(z_x_mean, 49);
                    diff_y <= resize(z_y_meas, 49) - resize(z_y_mean, 49);
                    diff_z <= resize(z_z_meas, 49) - resize(z_z_mean, 49);

                    state <= SATURATE;

                when SATURATE =>

                    if diff_x > MAX_VALUE then
                        nu_x <= MAX_VALUE;
                    elsif diff_x < MIN_VALUE then
                        nu_x <= MIN_VALUE;
                    else
                        nu_x <= resize(diff_x, 48);
                    end if;

                    if diff_y > MAX_VALUE then
                        nu_y <= MAX_VALUE;
                    elsif diff_y < MIN_VALUE then
                        nu_y <= MIN_VALUE;
                    else
                        nu_y <= resize(diff_y, 48);
                    end if;

                    if diff_z > MAX_VALUE then
                        nu_z <= MAX_VALUE;
                    elsif diff_z < MIN_VALUE then
                        nu_z <= MIN_VALUE;
                    else
                        nu_z <= resize(diff_z, 48);
                    end if;

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
