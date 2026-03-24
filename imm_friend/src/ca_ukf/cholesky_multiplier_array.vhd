library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package cholesky_mult_types is
    type signed_48_array is array (natural range <>) of signed(47 downto 0);
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cholesky_mult_types.all;

entity cholesky_multiplier_array is
    generic (
        NUM_MULTIPLIERS : integer := 4;
        Q : integer := 24
    );
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;

        start     : in  std_logic;
        num_valid : in  integer range 0 to NUM_MULTIPLIERS;

        a_array : in  signed_48_array(0 to NUM_MULTIPLIERS-1);
        b_array : in  signed_48_array(0 to NUM_MULTIPLIERS-1);

        sum_result : out signed(47 downto 0);
        done       : out std_logic
    );
end cholesky_multiplier_array;

architecture Behavioral of cholesky_multiplier_array is

    type product_array is array (0 to NUM_MULTIPLIERS-1) of signed(95 downto 0);

    type state_type is (IDLE, MULTIPLY, SHIFT, ACCUMULATE, DONE_STATE);
    signal state : state_type := IDLE;

    signal products : product_array := (others => (others => '0'));
    signal shifted_products : signed_48_array(0 to NUM_MULTIPLIERS-1) := (others => (others => '0'));
    signal accumulator : signed(51 downto 0) := (others => '0');
    signal result_reg : signed(47 downto 0) := (others => '0');

    signal num_valid_reg : integer range 0 to NUM_MULTIPLIERS := 0;
    signal done_reg : std_logic := '0';

begin

    sum_result <= result_reg;
    done <= done_reg;

    process(clk)
        variable temp_sum : signed(51 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then

                state <= IDLE;
                products <= (others => (others => '0'));
                shifted_products <= (others => (others => '0'));
                accumulator <= (others => '0');
                result_reg <= (others => '0');
                num_valid_reg <= 0;
                done_reg <= '0';

            else
                case state is
                    when IDLE =>
                        done_reg <= '0';
                        if start = '1' then
                            num_valid_reg <= num_valid;
                            state <= MULTIPLY;

                            report "MULT_ARRAY: START" & LF &
                                   "  num_valid = " & integer'image(num_valid) & LF &
                                   "  a_array(0) = " & integer'image(to_integer(a_array(0))) & LF &
                                   "  b_array(0) = " & integer'image(to_integer(b_array(0)));
                        end if;

                    when MULTIPLY =>

                        for i in 0 to NUM_MULTIPLIERS-1 loop
                            products(i) <= a_array(i) * b_array(i);
                        end loop;
                        state <= SHIFT;

                    when SHIFT =>

                        for i in 0 to NUM_MULTIPLIERS-1 loop
                            shifted_products(i) <= resize(shift_right(products(i), Q), 48);
                        end loop;
                        state <= ACCUMULATE;

                    when ACCUMULATE =>

                        temp_sum := (others => '0');
                        for i in 0 to NUM_MULTIPLIERS-1 loop
                            if i < num_valid_reg then
                                temp_sum := temp_sum + resize(shifted_products(i), 52);
                            end if;
                        end loop;

                        accumulator <= temp_sum;
                        result_reg <= resize(temp_sum, 48);

                        report "MULT_ARRAY: COMPUTE" & LF &
                               "  shifted_products(0) = " & integer'image(to_integer(shifted_products(0))) & LF &
                               "  accumulator = " & integer'image(to_integer(temp_sum(47 downto 0)));

                        state <= DONE_STATE;

                    when DONE_STATE =>
                        done_reg <= '1';
                        if start = '0' then
                            state <= IDLE;
                        end if;

                end case;
            end if;
        end if;
    end process;

end Behavioral;
