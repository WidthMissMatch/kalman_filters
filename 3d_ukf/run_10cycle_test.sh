#!/bin/bash
# Run 10-cycle CV UKF testbench using xsim
set -e

PROJ_DIR="/home/arunupscee/Desktop/xtortion/3d_ukf"
SRC_DIR="$PROJ_DIR/3d_ukf.srcs/sources_1/new"
SIM_DIR="$PROJ_DIR/3d_ukf.srcs/sim_1/new"
WORK_DIR="$PROJ_DIR/xsim_work"

# Clean
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "=== Step 1: Compiling VHDL sources ==="

# Source files in dependency order
SOURCES=(
    "$SRC_DIR/sqrt_newton.vhd"
    "$SRC_DIR/inverse_newsy.vhd"
    "$SRC_DIR/cholsky_6.vhd"
    "$SRC_DIR/predicti_cv3d.vhd"
    "$SRC_DIR/sigma_3d.vhd"
    "$SRC_DIR/predicted_mean_3d.vhd"
    "$SRC_DIR/covariance_reconstruct_3d.vhd"
    "$SRC_DIR/process_noise_3d.vhd"
    "$SRC_DIR/prediction_phase_3d.vhd"
    "$SRC_DIR/measurement_mean_3d.vhd"
    "$SRC_DIR/innovation_3d.vhd"
    "$SRC_DIR/innovation_covariance_3d.vhd"
    "$SRC_DIR/matrix_inverse_3x3.vhd"
    "$SRC_DIR/cross_covariance_3d.vhd"
    "$SRC_DIR/kalman_gain_3d.vhd"
    "$SRC_DIR/state_update_3d.vhd"
    "$SRC_DIR/measurement_update_3d.vhd"
    "$SRC_DIR/ukf_supreme_3d.vhd"
    "$SIM_DIR/cv_ukf_50cycle_tb.vhd"
)

for f in "${SOURCES[@]}"; do
    echo "  Compiling: $(basename $f)"
    xvhdl -work work "$f" 2>&1
done

echo ""
echo "=== Step 2: Elaborating ==="
xelab -debug typical work.cv_ukf_50cycle_tb -s cv_ukf_sim 2>&1

echo ""
echo "=== Step 3: Running simulation (timeout 5 min) ==="
timeout 300 xsim cv_ukf_sim -runall -onerror quit 2>&1 | tee "$WORK_DIR/sim_output.log"

echo ""
echo "=== Simulation complete ==="
echo "Output file: $WORK_DIR/cv_ukf_50cycle_output.txt"
if [ -f "$WORK_DIR/cv_ukf_50cycle_output.txt" ]; then
    cat "$WORK_DIR/cv_ukf_50cycle_output.txt"
fi
