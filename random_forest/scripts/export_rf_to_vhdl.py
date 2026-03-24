#!/usr/bin/env python3
"""
Export trained Random Forest (trees_export.json) to VHDL:
  1. rf_tree_rom.vhd     — package with tree node constants
  2. rf_tree_engine.vhd  — parametric tree traversal (combinational for <=20 trees)

All thresholds are Q24.24 signed 48-bit hex literals.
"""

import json
import os
import sys
import textwrap

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EXPORT_JSON = os.path.join(BASE, "data", "trees_export.json")
SRC_DIR     = os.path.join(BASE, "src")


# ---------------------------------------------------------------------------
# Format helpers
# ---------------------------------------------------------------------------

def to_signed48_hex(val):
    """Return 48-bit 2's complement hex string for a signed Python int."""
    val = int(val)
    if val < 0:
        val = val + (1 << 48)
    val = val & 0xFFFFFFFFFFFF  # 48-bit mask
    return f'x"{val:012X}"'


def indent(text, spaces=4):
    return textwrap.indent(text, " " * spaces)


# ---------------------------------------------------------------------------
# Generate rf_tree_rom.vhd
# ---------------------------------------------------------------------------

def gen_tree_rom(data):
    n_trees   = data["n_trees"]
    n_classes = data["n_classes"]
    trees     = data["trees"]

    # Find max nodes across all trees
    max_nodes = max(t["n_nodes"] for t in trees)

    lines = []
    lines.append("--------------------------------------------------------------------------------")
    lines.append("-- rf_tree_rom.vhd — Auto-generated Random Forest tree constants")
    lines.append(f"-- Trees: {n_trees}, Max depth: {data['max_depth']}, Q: {data['q_bits']}")
    lines.append("-- DO NOT EDIT — regenerate with export_rf_to_vhdl.py")
    lines.append("--------------------------------------------------------------------------------")
    lines.append("")
    lines.append("library IEEE;")
    lines.append("use IEEE.STD_LOGIC_1164.ALL;")
    lines.append("use IEEE.NUMERIC_STD.ALL;")
    lines.append("")
    lines.append("package rf_tree_rom_pkg is")
    lines.append("")
    lines.append(f"    constant N_TREES_ROM     : integer := {n_trees};")
    lines.append("    constant MAX_DEPTH_ROM   : integer := " + str(data["max_depth"]) + ";")
    lines.append(f"    constant MAX_NODES_ROM   : integer := {max_nodes};")
    lines.append(f"    constant N_CLASSES_ROM   : integer := {n_classes};")
    lines.append(f"    constant N_FEATURES_ROM  : integer := {data['n_features']};")
    lines.append("")
    lines.append("    -- Node record fields (per tree, per node):")
    lines.append("    -- is_leaf      : boolean")
    lines.append(f"    -- feature_idx  : integer 0..{data['n_features']-1}")
    lines.append("    -- threshold    : signed(47 downto 0) Q24.24")
    lines.append("    -- left_child   : integer (node index)")
    lines.append("    -- right_child  : integer (node index)")
    lines.append(f"    -- leaf_class   : integer 0..{n_classes-1}")
    lines.append("")
    lines.append(f"    type node_is_leaf_t    is array(0 to N_TREES_ROM-1, 0 to MAX_NODES_ROM-1) of boolean;")
    lines.append(f"    type node_feature_t    is array(0 to N_TREES_ROM-1, 0 to MAX_NODES_ROM-1) of integer range 0 to N_FEATURES_ROM-1;")
    lines.append(f"    type node_threshold_t  is array(0 to N_TREES_ROM-1, 0 to MAX_NODES_ROM-1) of signed(47 downto 0);")
    lines.append(f"    type node_left_t       is array(0 to N_TREES_ROM-1, 0 to MAX_NODES_ROM-1) of integer range 0 to MAX_NODES_ROM-1;")
    lines.append(f"    type node_right_t      is array(0 to N_TREES_ROM-1, 0 to MAX_NODES_ROM-1) of integer range 0 to MAX_NODES_ROM-1;")
    lines.append(f"    type node_class_t      is array(0 to N_TREES_ROM-1, 0 to MAX_NODES_ROM-1) of integer range 0 to N_CLASSES_ROM-1;")
    lines.append(f"    type tree_n_nodes_t    is array(0 to N_TREES_ROM-1) of integer range 1 to MAX_NODES_ROM;")
    lines.append("")

    # Build 2D arrays
    is_leaf_rows    = []
    feature_rows    = []
    thresh_rows     = []
    left_rows       = []
    right_rows      = []
    class_rows      = []
    n_nodes_list    = []

    for t in trees:
        nodes   = t["nodes"]
        n_nodes = t["n_nodes"]
        n_nodes_list.append(n_nodes)

        is_leaf_row  = []
        feat_row     = []
        thresh_row   = []
        left_row     = []
        right_row    = []
        class_row    = []

        for i in range(max_nodes):
            if i < n_nodes:
                nd = nodes[i]
                if nd["is_leaf"]:
                    is_leaf_row.append("true")
                    feat_row.append("0")
                    thresh_row.append(to_signed48_hex(0))
                    left_row.append("0")
                    right_row.append("0")
                    class_row.append(str(nd["class"]))
                else:
                    is_leaf_row.append("false")
                    feat_row.append(str(nd["feature_idx"]))
                    thresh_row.append(to_signed48_hex(nd["threshold_q2424"]))
                    left_row.append(str(nd["left_child"]))
                    right_row.append(str(nd["right_child"]))
                    class_row.append("0")
            else:
                # Padding
                is_leaf_row.append("true")
                feat_row.append("0")
                thresh_row.append(to_signed48_hex(0))
                left_row.append("0")
                right_row.append("0")
                class_row.append("0")

        is_leaf_rows.append(is_leaf_row)
        feature_rows.append(feat_row)
        thresh_rows.append(thresh_row)
        left_rows.append(left_row)
        right_rows.append(right_row)
        class_rows.append(class_row)

    # Emit constants
    def emit_2d_bool(name, rows):
        out = [f"    constant {name} : node_is_leaf_t := ("]
        for ti, row in enumerate(rows):
            comma = "," if ti < len(rows) - 1 else ""
            # Split into chunks of 8 for readability
            chunks = [", ".join(row[i:i+8]) for i in range(0, len(row), 8)]
            inner = ",\n                                         ".join(chunks)
            out.append(f"        {ti} => ({inner}){comma}")
        out.append("    );")
        return "\n".join(out)

    def emit_2d_int(name, type_name, rows):
        out = [f"    constant {name} : {type_name} := ("]
        for ti, row in enumerate(rows):
            comma = "," if ti < len(rows) - 1 else ""
            chunks = [", ".join(row[i:i+8]) for i in range(0, len(row), 8)]
            inner = ",\n                                         ".join(chunks)
            out.append(f"        {ti} => ({inner}){comma}")
        out.append("    );")
        return "\n".join(out)

    def emit_2d_thresh(name, rows):
        out = [f"    constant {name} : node_threshold_t := ("]
        for ti, row in enumerate(rows):
            comma = "," if ti < len(rows) - 1 else ""
            chunks = [", ".join(row[i:i+4]) for i in range(0, len(row), 4)]
            inner = ",\n                                         ".join(chunks)
            out.append(f"        {ti} => ({inner}){comma}")
        out.append("    );")
        return "\n".join(out)

    lines.append(emit_2d_bool("NODE_IS_LEAF", is_leaf_rows))
    lines.append("")
    lines.append(emit_2d_int("NODE_FEATURE", "node_feature_t", feature_rows))
    lines.append("")
    lines.append(emit_2d_thresh("NODE_THRESHOLD", thresh_rows))
    lines.append("")
    lines.append(emit_2d_int("NODE_LEFT", "node_left_t", left_rows))
    lines.append("")
    lines.append(emit_2d_int("NODE_RIGHT", "node_right_t", right_rows))
    lines.append("")
    lines.append(emit_2d_int("NODE_CLASS", "node_class_t", class_rows))
    lines.append("")

    # n_nodes per tree
    n_nodes_str = ", ".join(str(n) for n in n_nodes_list)
    lines.append(f"    constant TREE_N_NODES : tree_n_nodes_t := ({n_nodes_str});")
    lines.append("")
    lines.append("end package rf_tree_rom_pkg;")
    lines.append("")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Generate rf_tree_engine.vhd
# ---------------------------------------------------------------------------

def gen_tree_engine(data):
    max_depth = data["max_depth"]
    n_trees   = data["n_trees"]
    n_classes = data["n_classes"]
    use_fsm   = n_trees > 20   # combinational ≤20, FSM >20

    lines = []
    lines.append("--------------------------------------------------------------------------------")
    lines.append("-- rf_tree_engine.vhd — Parametric tree traversal engine")
    lines.append(f"-- Mode: {'FSM (sequential)' if use_fsm else 'Combinational'}")
    lines.append("-- Generic TREE_ID selects which tree from rf_tree_rom_pkg constants")
    lines.append("-- DO NOT EDIT — regenerate with export_rf_to_vhdl.py")
    lines.append("--------------------------------------------------------------------------------")
    lines.append("")
    lines.append("library IEEE;")
    lines.append("use IEEE.STD_LOGIC_1164.ALL;")
    lines.append("use IEEE.NUMERIC_STD.ALL;")
    lines.append("use work.rf_fixed_point_pkg.all;")
    lines.append("use work.rf_tree_rom_pkg.all;")
    lines.append("")
    lines.append("entity rf_tree_engine is")
    lines.append("    generic (")
    lines.append("        TREE_ID   : integer := 0;")
    lines.append(f"        MAX_DEPTH : integer := {max_depth}")
    lines.append("    );")
    lines.append("    port (")
    lines.append("        clk      : in  std_logic;")
    lines.append("        reset    : in  std_logic;")
    lines.append("        start    : in  std_logic;")
    lines.append("        features : in  feature_vector_t;")
    lines.append("        class_out : out integer range 0 to N_CLASSES-1;")
    lines.append("        done     : out std_logic")
    lines.append("    );")
    lines.append("end rf_tree_engine;")
    lines.append("")
    lines.append("architecture Behavioral of rf_tree_engine is")
    lines.append("")

    if not use_fsm:
        # Combinational: pure combinational traversal via process
        lines.append("    -- Combinational tree traversal — zero latency after feature_extract")
        lines.append("    signal node_idx  : integer range 0 to MAX_NODES_ROM-1;")
        lines.append("    signal done_reg  : std_logic := '0';")
        lines.append("    signal class_reg : integer range 0 to N_CLASSES-1 := 0;")
        lines.append("")
        lines.append("begin")
        lines.append("")
        lines.append("    -- Combinational traversal")
        lines.append("    process(features)")
        lines.append("        variable idx : integer range 0 to MAX_NODES_ROM-1;")
        lines.append("        variable depth : integer range 0 to MAX_DEPTH;")
        lines.append("    begin")
        lines.append("        idx := 0;")
        lines.append("        depth := 0;")
        lines.append("        for step in 0 to MAX_DEPTH loop")
        lines.append("            if NODE_IS_LEAF(TREE_ID, idx) then")
        lines.append("                null; -- stay at leaf")
        lines.append("            else")
        lines.append("                if features(NODE_FEATURE(TREE_ID, idx)) <= NODE_THRESHOLD(TREE_ID, idx) then")
        lines.append("                    idx := NODE_LEFT(TREE_ID, idx);")
        lines.append("                else")
        lines.append("                    idx := NODE_RIGHT(TREE_ID, idx);")
        lines.append("                end if;")
        lines.append("            end if;")
        lines.append("        end loop;")
        lines.append("        class_reg <= NODE_CLASS(TREE_ID, idx);")
        lines.append("    end process;")
        lines.append("")
        lines.append("    -- Register done on start (1 cycle after start)")
        lines.append("    process(clk)")
        lines.append("    begin")
        lines.append("        if rising_edge(clk) then")
        lines.append("            if reset = '1' then")
        lines.append("                done_reg <= '0';")
        lines.append("            else")
        lines.append("                done_reg <= start;")
        lines.append("            end if;")
        lines.append("        end if;")
        lines.append("    end process;")
        lines.append("")
        lines.append("    class_out <= class_reg;")
        lines.append("    done      <= done_reg;")
        lines.append("")
    else:
        # FSM version for >20 trees: IDLE → TRAVERSE (1 compare/clk) → LEAF → DONE
        lines.append("    type state_t is (IDLE, TRAVERSE, LEAF, DONE_ST);")
        lines.append("    signal state     : state_t := IDLE;")
        lines.append("    signal node_idx  : integer range 0 to MAX_NODES_ROM-1 := 0;")
        lines.append("    signal class_reg : integer range 0 to N_CLASSES-1 := 0;")
        lines.append("    signal done_reg  : std_logic := '0';")
        lines.append("")
        lines.append("begin")
        lines.append("")
        lines.append("    process(clk)")
        lines.append("    begin")
        lines.append("        if rising_edge(clk) then")
        lines.append("            if reset = '1' then")
        lines.append("                state    <= IDLE;")
        lines.append("                node_idx <= 0;")
        lines.append("                done_reg <= '0';")
        lines.append("            else")
        lines.append("                done_reg <= '0';")
        lines.append("                case state is")
        lines.append("                    when IDLE =>");
        lines.append("                        if start = '1' then")
        lines.append("                            node_idx <= 0;")
        lines.append("                            state    <= TRAVERSE;")
        lines.append("                        end if;")
        lines.append("                    when TRAVERSE =>")
        lines.append("                        if NODE_IS_LEAF(TREE_ID, node_idx) then")
        lines.append("                            state <= LEAF;")
        lines.append("                        else")
        lines.append("                            if features(NODE_FEATURE(TREE_ID, node_idx)) <= NODE_THRESHOLD(TREE_ID, node_idx) then")
        lines.append("                                node_idx <= NODE_LEFT(TREE_ID, node_idx);")
        lines.append("                            else")
        lines.append("                                node_idx <= NODE_RIGHT(TREE_ID, node_idx);")
        lines.append("                            end if;")
        lines.append("                        end if;")
        lines.append("                    when LEAF =>")
        lines.append("                        class_reg <= NODE_CLASS(TREE_ID, node_idx);")
        lines.append("                        state     <= DONE_ST;")
        lines.append("                    when DONE_ST =>")
        lines.append("                        done_reg <= '1';")
        lines.append("                        state    <= IDLE;")
        lines.append("                end case;")
        lines.append("            end if;")
        lines.append("        end if;")
        lines.append("    end process;")
        lines.append("")
        lines.append("    class_out <= class_reg;")
        lines.append("    done      <= done_reg;")
        lines.append("")

    lines.append("end Behavioral;")
    lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    if not os.path.exists(EXPORT_JSON):
        print(f"ERROR: {EXPORT_JSON} not found. Run train_random_forest.py first.")
        sys.exit(1)

    with open(EXPORT_JSON) as f:
        data = json.load(f)

    print(f"Loaded: {data['n_trees']} trees, depth={data['max_depth']}, "
          f"features={data['n_features']}, classes={data['n_classes']}")

    os.makedirs(SRC_DIR, exist_ok=True)

    # Generate rf_tree_rom.vhd
    rom_path = os.path.join(SRC_DIR, "rf_tree_rom.vhd")
    rom_code = gen_tree_rom(data)
    with open(rom_path, "w") as f:
        f.write(rom_code)
    print(f"Generated: {rom_path} ({len(rom_code.splitlines())} lines)")

    # Generate rf_tree_engine.vhd
    engine_path = os.path.join(SRC_DIR, "rf_tree_engine.vhd")
    engine_code = gen_tree_engine(data)
    with open(engine_path, "w") as f:
        f.write(engine_code)
    print(f"Generated: {engine_path} ({len(engine_code.splitlines())} lines)")

    print(f"\nMode: {'FSM (sequential)' if data['n_trees'] > 20 else 'Combinational'}")
    print(f"Max nodes per tree: {max(t['n_nodes'] for t in data['trees'])}")


if __name__ == "__main__":
    main()
