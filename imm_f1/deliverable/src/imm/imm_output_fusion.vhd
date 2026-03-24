library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imm_output_fusion is
  port (
    clk   : in  std_logic;
    start : in  std_logic;

    prob_ca, prob_singer, prob_bicycle : in signed(47 downto 0);

    ca_px, ca_py, ca_pz       : in signed(47 downto 0);
    singer_px, singer_py, singer_pz : in signed(47 downto 0);
    bike_px, bike_py, bike_pz : in signed(47 downto 0);

    px_out, py_out, pz_out : out signed(47 downto 0);
    done : out std_logic
  );
end entity;

architecture Behavioral of imm_output_fusion is
  constant Q : integer := 24;
  type state_type is (IDLE, MULTIPLY, OUTPUT);
  signal state : state_type := IDLE;
begin

  process(clk)
    variable prod : signed(95 downto 0);
    variable sum_x, sum_y, sum_z : signed(47 downto 0);
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if start = '1' then
            state <= MULTIPLY;
          end if;

        when MULTIPLY =>

          prod := prob_ca * ca_px;
          sum_x := resize(shift_right(prod, Q), 48);
          prod := prob_singer * singer_px;
          sum_x := sum_x + resize(shift_right(prod, Q), 48);
          prod := prob_bicycle * bike_px;
          sum_x := sum_x + resize(shift_right(prod, Q), 48);

          prod := prob_ca * ca_py;
          sum_y := resize(shift_right(prod, Q), 48);
          prod := prob_singer * singer_py;
          sum_y := sum_y + resize(shift_right(prod, Q), 48);
          prod := prob_bicycle * bike_py;
          sum_y := sum_y + resize(shift_right(prod, Q), 48);

          prod := prob_ca * ca_pz;
          sum_z := resize(shift_right(prod, Q), 48);
          prod := prob_singer * singer_pz;
          sum_z := sum_z + resize(shift_right(prod, Q), 48);
          prod := prob_bicycle * bike_pz;
          sum_z := sum_z + resize(shift_right(prod, Q), 48);

          px_out <= sum_x;
          py_out <= sum_y;
          pz_out <= sum_z;
          state <= OUTPUT;

        when OUTPUT =>
          done <= '1';
          if start = '0' then
            state <= IDLE;
          end if;

      end case;
    end if;
  end process;

end Behavioral;
