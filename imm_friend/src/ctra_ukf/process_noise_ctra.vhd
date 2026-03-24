library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity process_noise_ctra is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    start : in  std_logic;

    p11_in, p22_in, p33_in, p44_in, p55_in, p66_in, p77_in : in signed(47 downto 0);

    p11_out, p22_out, p33_out, p44_out, p55_out, p66_out, p77_out : out signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of process_noise_ctra is

  type state_type is (IDLE, ADD_NOISE, FINISHED);
  signal state : state_type := IDLE;

  constant Q_PX    : signed(47 downto 0) := to_signed(8388608, 48);
  constant Q_PY    : signed(47 downto 0) := to_signed(8388608, 48);
  constant Q_V     : signed(47 downto 0) := to_signed(167772160, 48);
  constant Q_THETA : signed(47 downto 0) := to_signed(838861, 48);
  constant Q_OMEGA : signed(47 downto 0) := to_signed(16777, 48);
  constant Q_A     : signed(47 downto 0) := to_signed(83886080, 48);
  constant Q_Z     : signed(47 downto 0) := to_signed(8388608, 48);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= IDLE;
        done <= '0';
      else
        case state is
          when IDLE =>
            done <= '0';
            if start = '1' then
              state <= ADD_NOISE;
            end if;

          when ADD_NOISE =>

            p11_out <= p11_in + Q_PX;
            p22_out <= p22_in + Q_PY;
            p33_out <= p33_in + Q_V;
            p44_out <= p44_in + Q_THETA;
            p55_out <= p55_in + Q_OMEGA;
            p66_out <= p66_in + Q_A;
            p77_out <= p77_in + Q_Z;
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
