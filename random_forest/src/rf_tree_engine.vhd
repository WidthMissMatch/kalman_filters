library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.rf_fixed_point_pkg.all;
use work.rf_tree_rom_pkg.all;

entity rf_tree_engine is
    generic (
        TREE_ID   : integer := 0;
        MAX_DEPTH : integer := 15
    );
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        start    : in  std_logic;
        features : in  feature_vector_t;
        class_out : out integer range 0 to N_CLASSES-1;
        done     : out std_logic
    );
end rf_tree_engine;

architecture Behavioral of rf_tree_engine is

    type state_t is (IDLE, TRAVERSE, LEAF, DONE_ST);
    signal state     : state_t := IDLE;
    signal node_idx  : integer range 0 to MAX_NODES_ROM-1 := 0;
    signal class_reg : integer range 0 to N_CLASSES-1 := 0;
    signal done_reg  : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state    <= IDLE;
                node_idx <= 0;
                done_reg <= '0';
            else
                done_reg <= '0';
                case state is
                    when IDLE =>
                        if start = '1' then
                            node_idx <= 0;
                            state    <= TRAVERSE;
                        end if;
                    when TRAVERSE =>
                        if NODE_IS_LEAF(TREE_ID, node_idx) then
                            state <= LEAF;
                        else
                            if features(NODE_FEATURE(TREE_ID, node_idx)) <= NODE_THRESHOLD(TREE_ID, node_idx) then
                                node_idx <= NODE_LEFT(TREE_ID, node_idx);
                            else
                                node_idx <= NODE_RIGHT(TREE_ID, node_idx);
                            end if;
                        end if;
                    when LEAF =>
                        class_reg <= NODE_CLASS(TREE_ID, node_idx);
                        state     <= DONE_ST;
                    when DONE_ST =>
                        done_reg <= '1';
                        state    <= IDLE;
                end case;
            end if;
        end if;
    end process;

    class_out <= class_reg;
    done      <= done_reg;

end Behavioral;
