library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.rf_fixed_point_pkg.all;

entity rf_majority_voter is
    generic (
        N_TREES_G : integer := N_TREES
    );
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        start : in  std_logic;

        tree_preds : in  tree_pred_t;

        class_out  : out integer range 0 to N_CLASSES-1;
        confidence : out integer range 0 to MAX_TREES;
        done       : out std_logic
    );
end rf_majority_voter;

architecture Behavioral of rf_majority_voter is

    type state_t is (IDLE, COUNT, ARGMAX, DONE_ST);
    signal state : state_t := IDLE;

    signal counts     : class_count_t := (others => 0);
    signal preds_r    : tree_pred_t;
    signal class_reg  : integer range 0 to N_CLASSES-1 := 0;
    signal conf_reg   : integer range 0 to MAX_TREES := 0;
    signal done_reg   : std_logic := '0';

begin

    process(clk)
        variable cnt      : class_count_t;
        variable max_cnt  : integer range 0 to MAX_TREES;
        variable winner   : integer range 0 to N_CLASSES-1;
        variable cls      : integer range 0 to N_CLASSES-1;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state    <= IDLE;
                done_reg <= '0';
                class_reg <= 0;
                conf_reg  <= 0;
            else
                done_reg <= '0';

                case state is

                    when IDLE =>
                        if start = '1' then

                            preds_r <= tree_preds;
                            state   <= COUNT;
                        end if;

                    when COUNT =>

                        for c in 0 to N_CLASSES-1 loop
                            cnt(c) := 0;
                        end loop;

                        for i in 0 to N_TREES_G-1 loop
                            cls := preds_r(i);
                            cnt(cls) := cnt(cls) + 1;
                        end loop;

                        for c in 0 to N_CLASSES-1 loop
                            counts(c) <= cnt(c);
                        end loop;
                        state <= ARGMAX;

                    when ARGMAX =>
                        max_cnt := 0;
                        winner  := 0;
                        for c in 0 to N_CLASSES-1 loop
                            if counts(c) > max_cnt then
                                max_cnt := counts(c);
                                winner  := c;
                            end if;
                        end loop;
                        class_reg <= winner;
                        conf_reg  <= max_cnt;
                        state     <= DONE_ST;

                    when DONE_ST =>
                        done_reg <= '1';
                        state    <= IDLE;

                end case;
            end if;
        end if;
    end process;

    class_out  <= class_reg;
    confidence <= conf_reg;
    done       <= done_reg;

end Behavioral;
