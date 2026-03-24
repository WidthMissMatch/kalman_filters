#!/bin/bash
# GHDL Compilation and Simulation Script for UKF
# Compiles all VHDL sources and runs testbench

set -e  # Exit on error

echo "================================"
echo "GHDL UKF Compilation & Simulation"
echo "================================"

# Directories
SRC_DIR="/home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sources_1/new"
TB_DIR="/home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sim_1/new"
WORK_DIR="/home/arunupscee/Desktop/xtortion/ca_ukf/ghdl_work"

# Create work directory
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo ""
echo "Step 1: Analyzing all source files..."
echo "======================================="

# Compile packages first (contains type definitions)
echo "Analyzing packages..."
ghdl -a --std=08 --workdir="$WORK_DIR" "$SRC_DIR/cholesky_multiplier_array.vhd"

# Compile all other source files
for vhd_file in "$SRC_DIR"/*.vhd; do
    if [ -f "$vhd_file" ]; then
        filename=$(basename "$vhd_file")
        # Skip already compiled packages
        if [ "$filename" != "cholesky_multiplier_array.vhd" ]; then
            echo "Analyzing: $filename"
            ghdl -a --std=08 --workdir="$WORK_DIR" "$vhd_file" || {
                echo "WARNING: Failed to analyze $filename (may be normal for backups)"
                # Continue compilation - some files may be backups
            }
        fi
    fi
done

echo ""
echo "Step 2: Analyzing testbench..."
echo "==============================="

# Choose which testbench to run (default: drone)
TB_NAME="${1:-ukf_real_synthetic_drone_500cycles_tb}"
TB_FILE="$TB_DIR/${TB_NAME}.vhd"

if [ ! -f "$TB_FILE" ]; then
    echo "ERROR: Testbench not found: $TB_FILE"
    exit 1
fi

echo "Analyzing: $TB_NAME"
ghdl -a --std=08 --workdir="$WORK_DIR" "$TB_FILE"

echo ""
echo "Step 3: Elaborating testbench..."
echo "=================================="
ghdl -e --std=08 --workdir="$WORK_DIR" "$TB_NAME"

echo ""
echo "Step 4: Running simulation..."
echo "=============================="
echo "Testbench: $TB_NAME"
echo "Output file: vhdl_output_*.txt"
echo ""

# Run simulation with timeout
timeout 300 ghdl -r --std=08 --workdir="$WORK_DIR" "$TB_NAME" --stop-time=500ms || {
    if [ $? -eq 124 ]; then
        echo "WARNING: Simulation timeout after 300 seconds"
    else
        echo "ERROR: Simulation failed"
        exit 1
    fi
}

echo ""
echo "================================"
echo "Simulation Complete!"
echo "================================"

# Check for output file
if [ -f "vhdl_output_*.txt" ]; then
    echo "Output file generated:"
    ls -lh vhdl_output_*.txt
    echo ""
    echo "First 20 lines of output:"
    head -20 vhdl_output_*.txt
else
    echo "WARNING: No output file found (vhdl_output_*.txt)"
fi
