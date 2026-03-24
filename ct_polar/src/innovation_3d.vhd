library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity innovation_3d is
  port (
    clk   : in  std_logic;
    start : in  std_logic;

    z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);

    z_x_pred, z_y_pred, z_z_pred : in signed(47 downto 0);

    nu_x, nu_y, nu_z : buffer signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of innovation_3d is
  type state_type is (IDLE, COMPUTE, FINISHED);
  signal state : state_type := IDLE;
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
          nu_x <= z_x_meas - z_x_pred;
          nu_y <= z_y_meas - z_y_pred;
          nu_z <= z_z_meas - z_z_pred;
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
  end process;
end Behavioral;
