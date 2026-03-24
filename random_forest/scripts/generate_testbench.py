#!/usr/bin/env python3
"""
Auto-generate rf_classifier_tb.vhd from test partition of training data.
50 samples per class = 300 test vectors.
Values output as Q24.24 hex (hwrite pattern, not to_integer — avoids Bug #4).

Output: testbenches/rf_classifier_tb.vhd
"""

import json
import os
import sys
import numpy as np
import pandas as pd

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW_CSV     = os.path.join(BASE, "data", "raw_states.csv")
JSON_PATH   = os.path.join(BASE, "data", "trees_export.json")
TB_OUT      = os.path.join(BASE, "testbenches", "rf_classifier_tb.vhd")

Q     = 24
SCALE = 2**Q
N_PER_CLASS      = 200
CONF_THRESHOLD   = 35    # 70% of 50 trees — reject ambiguous samples

CLASS_NAMES = ["Drone", "Missile", "Car", "F1", "Cat", "Bird",
               "Airplane", "Ball", "Artillery", "Pedestrian"]


def float_to_q2424_hex(v):
    """Convert float to Q24.24 signed 48-bit hex literal."""
    scaled = int(round(v * SCALE))
    MAX48 = (1 << 47) - 1
    MIN48 = -(1 << 47)
    scaled = max(MIN48, min(MAX48, scaled))
    if scaled < 0:
        scaled = scaled + (1 << 48)
    return f'x"{scaled & 0xFFFFFFFFFFFF:012X}"'


def load_test_samples():
    """Load 50 samples per class from raw states."""
    if not os.path.exists(RAW_CSV):
        print(f"ERROR: {RAW_CSV} not found. Run generate_training_data.py first.")
        sys.exit(1)
    df = pd.read_csv(RAW_CSV)
    rng = np.random.default_rng(99)   # reproducible test split
    samples = []
    for cls in range(10):
        cls_df = df[df["label"] == cls]
        if len(cls_df) == 0:
            print(f"WARNING: class {cls} ({CLASS_NAMES[cls]}) has no data!")
            continue
        n = min(N_PER_CLASS, len(cls_df))
        idxs = rng.choice(len(cls_df), size=n, replace=False)
        rows = cls_df.iloc[idxs]
        for _, row in rows.iterrows():
            samples.append({
                "px": row["px"], "py": row["py"], "pz": row["pz"],
                "vx": row["vx"], "vy": row["vy"], "vz": row["vz"],
                "ax": row["ax"], "ay": row["ay"], "az": row["az"],
                "label": int(row["label"]),
            })
    print(f"Test samples: {len(samples)} ({N_PER_CLASS} per class)")
    return samples


def load_python_predictions(samples):
    """Run sklearn model on samples to get reference predictions."""
    if not os.path.exists(JSON_PATH):
        print("WARNING: trees_export.json not found, skipping Python predictions")
        return [s["label"] for s in samples]  # fallback: use true labels

    try:
        from sklearn.ensemble import RandomForestClassifier

        # Load JSON first so FEATURE_NAMES stays in sync with trained model
        with open(JSON_PATH) as f:
            data = json.load(f)

        FEATURE_NAMES = data.get("feature_names", [
            "speed_sq", "altitude", "horiz_speed_sq", "vert_speed_abs",
            "accel_mag_sq", "horiz_accel_sq", "climb_rate_sign", "altitude_abs",
            "horiz_accel_ratio",
        ])

        train_csv = os.path.join(BASE, "data", "training_data.csv")
        train_df = pd.read_csv(train_csv)
        X_train = train_df[FEATURE_NAMES].values
        y_train = train_df["label"].values

        clf = RandomForestClassifier(
            n_estimators=data["n_trees"],
            max_depth=data["max_depth"],
            random_state=42
        )
        clf.fit(X_train, y_train)

        # Extract features from test samples
        feat_rows = []
        for s in samples:
            vx, vy, vz = s["vx"], s["vy"], s["vz"]
            ax, ay, az = s["ax"], s["ay"], s["az"]
            pz = s["pz"]
            speed_sq       = vx**2 + vy**2 + vz**2
            horiz_accel_sq = ax**2 + ay**2
            feat_rows.append([
                speed_sq,
                pz,
                vx**2 + vy**2,
                abs(vz),
                ax**2 + ay**2 + az**2,
                horiz_accel_sq,
                np.sign(vz) * vz**2,
                abs(pz),
                horiz_accel_sq / (speed_sq + 1.0),
            ])
        X_test = np.array(feat_rows)
        preds = clf.predict(X_test).tolist()
        print(f"Python predictions computed: accuracy vs true label = "
              f"{sum(p==s['label'] for p,s in zip(preds,samples))/len(samples):.3f}")
        return preds

    except Exception as e:
        print(f"WARNING: Could not compute Python predictions ({e}), using true labels")
        return [s["label"] for s in samples]


def generate_tb(samples, py_preds):
    n_samples = len(samples)
    lines = []
    lines.append("--------------------------------------------------------------------------------")
    lines.append("-- rf_classifier_tb.vhd — Auto-generated testbench")
    lines.append(f"-- {n_samples} test vectors ({N_PER_CLASS} per class)")
    lines.append("-- All values Q24.24 (hwrite hex output — avoids to_integer overflow)")
    lines.append("-- Reference classes from sklearn RF predictions")
    lines.append("--------------------------------------------------------------------------------")
    lines.append("")
    lines.append("library ieee;")
    lines.append("use ieee.std_logic_1164.all;")
    lines.append("use ieee.numeric_std.all;")
    lines.append("use std.textio.all;")
    lines.append("use ieee.std_logic_textio.all;")
    lines.append("use work.rf_fixed_point_pkg.all;")
    lines.append("")
    lines.append("entity rf_classifier_tb is")
    lines.append("end entity rf_classifier_tb;")
    lines.append("")
    lines.append("architecture behavioral of rf_classifier_tb is")
    lines.append("")
    lines.append("    component rf_classifier_top is")
    lines.append("        generic (")
    lines.append("            MAX_DEPTH_G      : integer := 15;")
    lines.append(f"            CONF_THRESHOLD_G : integer := {CONF_THRESHOLD}")
    lines.append("        );")
    lines.append("        port (")
    lines.append("            clk        : in  std_logic;")
    lines.append("            reset      : in  std_logic;")
    lines.append("            start      : in  std_logic;")
    lines.append("            px_in      : in  signed(47 downto 0);")
    lines.append("            py_in      : in  signed(47 downto 0);")
    lines.append("            pz_in      : in  signed(47 downto 0);")
    lines.append("            vx_in      : in  signed(47 downto 0);")
    lines.append("            vy_in      : in  signed(47 downto 0);")
    lines.append("            vz_in      : in  signed(47 downto 0);")
    lines.append("            ax_in      : in  signed(47 downto 0);")
    lines.append("            ay_in      : in  signed(47 downto 0);")
    lines.append("            az_in      : in  signed(47 downto 0);")
    lines.append("            class_out  : out integer range 0 to N_CLASSES-1;")
    lines.append("            confidence : out integer range 0 to MAX_TREES;")
    lines.append("            valid      : out std_logic;")
    lines.append("            uncertain  : out std_logic;")
    lines.append("            done       : out std_logic")
    lines.append("        );")
    lines.append("    end component;")
    lines.append("")
    lines.append("    -- Clock and control")
    lines.append("    signal clk    : std_logic := '0';")
    lines.append("    signal reset  : std_logic := '1';")
    lines.append("    signal start  : std_logic := '0';")
    lines.append("    signal done      : std_logic;")
    lines.append("    signal valid     : std_logic;")
    lines.append("    signal uncertain : std_logic;")
    lines.append("")
    lines.append("    -- State inputs")
    lines.append("    signal px_s, py_s, pz_s : signed(47 downto 0) := (others => '0');")
    lines.append("    signal vx_s, vy_s, vz_s : signed(47 downto 0) := (others => '0');")
    lines.append("    signal ax_s, ay_s, az_s : signed(47 downto 0) := (others => '0');")
    lines.append("")
    lines.append("    -- Outputs")
    lines.append("    signal class_out_s  : integer range 0 to N_CLASSES-1;")
    lines.append("    signal confidence_s : integer range 0 to MAX_TREES;")
    lines.append(f"    constant CONF_THRESH : integer := {CONF_THRESHOLD};")
    lines.append("")
    lines.append("    constant CLK_PERIOD : time := 10 ns;")
    lines.append("")
    lines.append("    -- Test vector type")
    lines.append("    type state_vec_t is record")
    lines.append("        px, py, pz : signed(47 downto 0);")
    lines.append("        vx, vy, vz : signed(47 downto 0);")
    lines.append("        ax, ay, az : signed(47 downto 0);")
    lines.append("        expected_class : integer range 0 to N_CLASSES-1;")
    lines.append("        true_class     : integer range 0 to N_CLASSES-1;")
    lines.append("    end record;")
    lines.append(f"    type test_array_t is array(0 to {n_samples-1}) of state_vec_t;")
    lines.append("")

    # Emit test vectors
    lines.append("    -- Test vectors (Q24.24 hex)")
    class_name_map = ["Drone", "Missile", "Car", "F1", "Cat", "Bird",
                      "Airplane", "Ball", "Artillery", "Pedestrian"]
    lines.append(f"    constant TEST_VECTORS : test_array_t := (")
    for i, (s, pred) in enumerate(zip(samples, py_preds)):
        comma = "," if i < n_samples - 1 else ""
        lines.append(f"        -- Sample {i:3d}: class={s['label']} ({class_name_map[s['label']]}) pred={pred}")
        lines.append(f"        {i} => (")
        lines.append(f"            px => {float_to_q2424_hex(s['px'])},")
        lines.append(f"            py => {float_to_q2424_hex(s['py'])},")
        lines.append(f"            pz => {float_to_q2424_hex(s['pz'])},")
        lines.append(f"            vx => {float_to_q2424_hex(s['vx'])},")
        lines.append(f"            vy => {float_to_q2424_hex(s['vy'])},")
        lines.append(f"            vz => {float_to_q2424_hex(s['vz'])},")
        lines.append(f"            ax => {float_to_q2424_hex(s['ax'])},")
        lines.append(f"            ay => {float_to_q2424_hex(s['ay'])},")
        lines.append(f"            az => {float_to_q2424_hex(s['az'])},")
        lines.append(f"            expected_class => {pred},")
        lines.append(f"            true_class     => {s['label']}){comma}")
    lines.append("    );")
    lines.append("")
    lines.append("begin")
    lines.append("")
    lines.append("    -- Clock generation")
    lines.append("    clk <= not clk after CLK_PERIOD / 2;")
    lines.append("")
    lines.append("    -- DUT instantiation")
    lines.append("    DUT : rf_classifier_top")
    lines.append("        generic map (")
    lines.append("            MAX_DEPTH_G      => 15,")
    lines.append(f"            CONF_THRESHOLD_G => {CONF_THRESHOLD}")
    lines.append("        )")
    lines.append("        port map (")
    lines.append("            clk        => clk,")
    lines.append("            reset      => reset,")
    lines.append("            start      => start,")
    lines.append("            px_in      => px_s,")
    lines.append("            py_in      => py_s,")
    lines.append("            pz_in      => pz_s,")
    lines.append("            vx_in      => vx_s,")
    lines.append("            vy_in      => vy_s,")
    lines.append("            vz_in      => vz_s,")
    lines.append("            ax_in      => ax_s,")
    lines.append("            ay_in      => ay_s,")
    lines.append("            az_in      => az_s,")
    lines.append("            class_out  => class_out_s,")
    lines.append("            confidence => confidence_s,")
    lines.append("            valid      => valid,")
    lines.append("            uncertain  => uncertain,")
    lines.append("            done       => done")
    lines.append("        );")
    lines.append("")
    lines.append("    -- Stimulus + checker")
    lines.append("    process")
    lines.append("        variable correct         : integer := 0;")
    lines.append("        variable total           : integer := 0;")
    lines.append("        variable n_uncertain     : integer := 0;")
    lines.append("        variable n_wrong_certain : integer := 0;")
    lines.append("        variable per_class_ok    : integer_array_t := (others => 0);")
    lines.append("        variable per_class_tot   : integer_array_t := (others => 0);")
    lines.append("        variable per_class_unc   : integer_array_t := (others => 0);")
    lines.append("        variable l               : line;")
    lines.append("        file     results_file    : text;")
    lines.append("    begin")
    lines.append("        -- Open results file")
    lines.append("        file_open(results_file, \"rf_classifier_results.txt\", write_mode);")
    lines.append("")
    lines.append("        -- Reset")
    lines.append("        reset <= '1';")
    lines.append("        wait for CLK_PERIOD * 5;")
    lines.append("        reset <= '0';")
    lines.append("        wait for CLK_PERIOD * 2;")
    lines.append("")
    lines.append(f"        for i in 0 to {n_samples-1} loop")
    lines.append("            -- Apply inputs")
    lines.append("            px_s <= TEST_VECTORS(i).px;")
    lines.append("            py_s <= TEST_VECTORS(i).py;")
    lines.append("            pz_s <= TEST_VECTORS(i).pz;")
    lines.append("            vx_s <= TEST_VECTORS(i).vx;")
    lines.append("            vy_s <= TEST_VECTORS(i).vy;")
    lines.append("            vz_s <= TEST_VECTORS(i).vz;")
    lines.append("            ax_s <= TEST_VECTORS(i).ax;")
    lines.append("            ay_s <= TEST_VECTORS(i).ay;")
    lines.append("            az_s <= TEST_VECTORS(i).az;")
    lines.append("            start <= '1';")
    lines.append("            wait for CLK_PERIOD;")
    lines.append("            start <= '0';")
    lines.append("")
    lines.append("            -- Wait for done")
    lines.append("            wait until done = '1';")
    lines.append("            wait for CLK_PERIOD;")
    lines.append("")
    lines.append("            -- Check result")
    lines.append("            per_class_tot(TEST_VECTORS(i).true_class) :=")
    lines.append("                per_class_tot(TEST_VECTORS(i).true_class) + 1;")
    lines.append("            total := total + 1;")
    lines.append("            if uncertain = '1' then")
    lines.append("                n_uncertain := n_uncertain + 1;")
    lines.append("                per_class_unc(TEST_VECTORS(i).true_class) :=")
    lines.append("                    per_class_unc(TEST_VECTORS(i).true_class) + 1;")
    lines.append("            elsif class_out_s = TEST_VECTORS(i).expected_class then")
    lines.append("                correct := correct + 1;")
    lines.append("                per_class_ok(TEST_VECTORS(i).true_class) :=")
    lines.append("                    per_class_ok(TEST_VECTORS(i).true_class) + 1;")
    lines.append("            else")
    lines.append("                n_wrong_certain := n_wrong_certain + 1;")
    lines.append("            end if;")
    lines.append("")
    lines.append("            -- Write per-sample result")
    lines.append("            write(l, string'(\"SAMPLE \"));")
    lines.append("            write(l, i);")
    lines.append("            write(l, string'(\" true=\"));")
    lines.append("            write(l, TEST_VECTORS(i).true_class);")
    lines.append("            write(l, string'(\" pred=\"));")
    lines.append("            write(l, class_out_s);")
    lines.append("            write(l, string'(\" ref=\"));")
    lines.append("            write(l, TEST_VECTORS(i).expected_class);")
    lines.append("            write(l, string'(\" conf=\"));")
    lines.append("            write(l, confidence_s);")
    lines.append("            if uncertain = '1' then")
    lines.append("                write(l, string'(\" UNCERTAIN\"));")
    lines.append("            end if;")
    lines.append("            writeline(results_file, l);")
    lines.append("")
    lines.append("            wait for CLK_PERIOD * 2;")
    lines.append("        end loop;")
    lines.append("")
    lines.append("        -- Summary")
    lines.append("        write(l, string'(\"=== VHDL CLASSIFICATION RESULTS ===\"));")
    lines.append("        writeline(results_file, l);")
    lines.append(f"        write(l, string'(\"Confidence threshold: {CONF_THRESHOLD} / 50 trees (70%)\"));")
    lines.append("        writeline(results_file, l);")
    lines.append("        write(l, string'(\"Total samples: \"));")
    lines.append("        write(l, total);")
    lines.append("        writeline(results_file, l);")
    lines.append("        write(l, string'(\"Uncertain (abstained): \"));")
    lines.append("        write(l, n_uncertain);")
    lines.append("        writeline(results_file, l);")
    lines.append("        write(l, string'(\"Confident correct vs Python RF: \"));")
    lines.append("        write(l, correct);")
    lines.append("        write(l, string'(\" / \"));")
    lines.append("        write(l, total - n_uncertain);")
    lines.append("        writeline(results_file, l);")
    lines.append("        write(l, string'(\"Wrong while confident: \"));")
    lines.append("        write(l, n_wrong_certain);")
    lines.append("        writeline(results_file, l);")
    for cls in range(10):
        lines.append(f"        write(l, string'(\"  Class {cls} ({CLASS_NAMES[cls]:10s}): ok=\"));")
        lines.append(f"        write(l, per_class_ok({cls}));")
        lines.append(f"        write(l, string'(\" tot=\"));")
        lines.append(f"        write(l, per_class_tot({cls}));")
        lines.append(f"        write(l, string'(\" unc=\"));")
        lines.append(f"        write(l, per_class_unc({cls}));")
        lines.append(f"        writeline(results_file, l);")
    lines.append("        file_close(results_file);")
    lines.append("        report \"Testbench complete. See rf_classifier_results.txt\";")
    lines.append("        wait;")
    lines.append("    end process;")
    lines.append("")
    lines.append("end behavioral;")
    lines.append("")

    return "\n".join(lines)


def main():
    samples = load_test_samples()
    py_preds = load_python_predictions(samples)

    os.makedirs(os.path.join(BASE, "testbenches"), exist_ok=True)
    tb_code = generate_tb(samples, py_preds)

    with open(TB_OUT, "w") as f:
        f.write(tb_code)
    print(f"Generated: {TB_OUT} ({len(tb_code.splitlines())} lines)")

    # Print class distribution of test set
    from collections import Counter
    dist = Counter(s["label"] for s in samples)
    print("\nTest set distribution:")
    for cls in sorted(dist):
        name = CLASS_NAMES[cls] if cls < len(CLASS_NAMES) else f"Class{cls}"
        print(f"  Class {cls} ({name}): {dist[cls]}")


if __name__ == "__main__":
    main()
