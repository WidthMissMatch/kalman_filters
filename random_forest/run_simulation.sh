#!/usr/bin/env bash
# RF Classifier GHDL simulation script
# Usage: ./run_simulation.sh [retrain]
#   retrain  — regenerate training data, retrain, re-export VHDL before simulating

set -e
cd "$(dirname "$0")"

PYTHON=/tmp/rf_venv/bin/python
BUILD=build

if [[ "$1" == "retrain" ]]; then
    echo "=== Step 1: Generate training data ==="
    $PYTHON scripts/generate_training_data.py

    echo ""
    echo "=== Step 2: Train Random Forest ==="
    $PYTHON scripts/train_random_forest.py

    echo ""
    echo "=== Step 3: Export to VHDL ==="
    $PYTHON scripts/export_rf_to_vhdl.py

    echo ""
    echo "=== Step 4: Generate testbench ==="
    $PYTHON scripts/generate_testbench.py
fi

mkdir -p $BUILD

echo ""
echo "=== Compiling VHDL (GHDL) ==="
ghdl -a --std=08 --workdir=$BUILD \
    src/rf_fixed_point_pkg.vhd \
    src/rf_tree_rom.vhd \
    src/rf_feature_extract.vhd \
    src/rf_tree_engine.vhd \
    src/rf_majority_voter.vhd \
    src/rf_classifier_top.vhd \
    testbenches/rf_classifier_tb.vhd

echo "=== Elaborating ==="
ghdl -e --std=08 --workdir=$BUILD rf_classifier_tb

echo "=== Running simulation ==="
ghdl -r --std=08 --workdir=$BUILD rf_classifier_tb 2>&1 | grep -v "metavalue"

echo ""
echo "=== Results ==="
grep -A8 "VHDL CLASSIFICATION RESULTS" rf_classifier_results.txt
