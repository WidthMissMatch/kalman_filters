library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.rf_fixed_point_pkg.all;
use work.rf_tree_rom_pkg.all;

entity rf_classifier_top is
    generic (
        MAX_DEPTH_G      : integer := MAX_DEPTH_ROM;

        CONF_THRESHOLD_G : integer := 0
    );
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

        class_out  : out integer range 0 to N_CLASSES-1;
        confidence : out integer range 0 to MAX_TREES;
        valid      : out std_logic;
        uncertain  : out std_logic;
        done       : out std_logic
    );
end rf_classifier_top;

architecture Structural of rf_classifier_top is

    component rf_feature_extract is
        port (
            clk, reset, start : in  std_logic;
            px_in, py_in, pz_in : in q24_t;
            vx_in, vy_in, vz_in : in q24_t;
            ax_in, ay_in, az_in : in q24_t;
            features : out feature_vector_t;
            done     : out std_logic
        );
    end component;

    component rf_tree_engine is
        generic (
            TREE_ID   : integer := 0;
            MAX_DEPTH : integer := 12
        );
        port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            start     : in  std_logic;
            features  : in  feature_vector_t;
            class_out : out integer range 0 to N_CLASSES-1;
            done      : out std_logic
        );
    end component;

    component rf_majority_voter is
        generic (
            N_TREES_G : integer := N_TREES
        );
        port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            start      : in  std_logic;
            tree_preds : in  tree_pred_t;
            class_out  : out integer range 0 to N_CLASSES-1;
            confidence : out integer range 0 to MAX_TREES;
            done       : out std_logic
        );
    end component;

    signal features   : feature_vector_t;
    signal feat_start : std_logic := '0';
    signal feat_done  : std_logic;

    type tree_class_arr_t is array(0 to N_TREES_ROM-1) of integer range 0 to N_CLASSES-1;
    type tree_done_arr_t  is array(0 to N_TREES_ROM-1) of std_logic;

    signal tree_cls  : tree_class_arr_t;
    signal tree_done : tree_done_arr_t;
    signal trees_start : std_logic := '0';

    signal voter_preds : tree_pred_t := (others => 0);

    signal voter_start : std_logic := '0';
    signal voter_done  : std_logic;
    signal voter_class : integer range 0 to N_CLASSES-1;
    signal voter_conf  : integer range 0 to MAX_TREES;

    signal tree_done_latch : std_logic_vector(0 to N_TREES_ROM-1) := (others => '0');
    signal all_trees_done  : std_logic;

    type ctrl_t is (
        IDLE, FEATURE_EXTRACT, WAIT_FEAT,
        START_TREES, WAIT_TREES,
        VOTE, WAIT_VOTE, OUTPUT
    );
    signal ctrl_state : ctrl_t := IDLE;

    signal done_reg      : std_logic := '0';
    signal valid_reg     : std_logic := '0';
    signal uncertain_reg : std_logic := '0';
    signal class_reg     : integer range 0 to N_CLASSES-1 := 0;
    signal conf_reg      : integer range 0 to MAX_TREES := 0;

begin

    FEAT_EXTRACT : rf_feature_extract
        port map (
            clk    => clk, reset => reset, start => feat_start,
            px_in  => px_in, py_in => py_in, pz_in => pz_in,
            vx_in  => vx_in, vy_in => vy_in, vz_in => vz_in,
            ax_in  => ax_in, ay_in => ay_in, az_in => az_in,
            features => features,
            done     => feat_done
        );

    GEN_TREES : for i in 0 to N_TREES_ROM-1 generate
        TREE_I : rf_tree_engine
            generic map (TREE_ID => i, MAX_DEPTH => MAX_DEPTH_G)
            port map (
                clk       => clk,
                reset     => reset,
                start     => trees_start,
                features  => features,
                class_out => tree_cls(i),
                done      => tree_done(i)
            );
    end generate;

    process(tree_cls)
    begin
        voter_preds <= (others => 0);
        for i in 0 to N_TREES_ROM-1 loop
            voter_preds(i) <= tree_cls(i);
        end loop;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or trees_start = '1' then
                tree_done_latch <= (others => '0');
            else
                for i in 0 to N_TREES_ROM-1 loop
                    if tree_done(i) = '1' then
                        tree_done_latch(i) <= '1';
                    end if;
                end loop;
            end if;
        end if;
    end process;

    process(tree_done_latch)
        variable a : std_logic;
    begin
        a := '1';
        for i in 0 to N_TREES_ROM-1 loop
            a := a and tree_done_latch(i);
        end loop;
        all_trees_done <= a;
    end process;

    VOTER : rf_majority_voter
        generic map (N_TREES_G => N_TREES_ROM)
        port map (
            clk        => clk,
            reset      => reset,
            start      => voter_start,
            tree_preds => voter_preds,
            class_out  => voter_class,
            confidence => voter_conf,
            done       => voter_done
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                ctrl_state    <= IDLE;
                feat_start    <= '0';
                trees_start   <= '0';
                voter_start   <= '0';
                done_reg      <= '0';
                valid_reg     <= '0';
                uncertain_reg <= '0';
            else
                feat_start  <= '0';
                trees_start <= '0';
                voter_start <= '0';
                done_reg    <= '0';

                case ctrl_state is
                    when IDLE =>
                        valid_reg     <= '0';
                        uncertain_reg <= '0';
                        if start = '1' then
                            feat_start <= '1';
                            ctrl_state <= FEATURE_EXTRACT;
                        end if;

                    when FEATURE_EXTRACT =>
                        ctrl_state <= WAIT_FEAT;

                    when WAIT_FEAT =>
                        if feat_done = '1' then
                            ctrl_state <= START_TREES;
                        end if;

                    when START_TREES =>
                        trees_start <= '1';
                        ctrl_state  <= WAIT_TREES;

                    when WAIT_TREES =>
                        if all_trees_done = '1' then
                            ctrl_state <= VOTE;
                        end if;

                    when VOTE =>
                        voter_start <= '1';
                        ctrl_state  <= WAIT_VOTE;

                    when WAIT_VOTE =>
                        if voter_done = '1' then
                            class_reg  <= voter_class;
                            conf_reg   <= voter_conf;
                            ctrl_state <= OUTPUT;
                        end if;

                    when OUTPUT =>

                        if conf_reg >= CONF_THRESHOLD_G then
                            valid_reg     <= '1';
                            uncertain_reg <= '0';
                        else
                            valid_reg     <= '0';
                            uncertain_reg <= '1';
                        end if;
                        done_reg   <= '1';
                        ctrl_state <= IDLE;

                end case;
            end if;
        end if;
    end process;

    class_out  <= class_reg;
    confidence <= conf_reg;
    valid      <= valid_reg;
    uncertain  <= uncertain_reg;
    done       <= done_reg;

end Structural;
