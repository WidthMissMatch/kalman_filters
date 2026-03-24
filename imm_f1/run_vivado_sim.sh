#!/bin/bash
# IMM F1 Filter - Vivado xsim Simulation Runner
# Usage: ./run_vivado_sim.sh [3cycle|drone|monaco|silverstone|monaco100|silverstone100]
set -e

DATASET=${1:-3cycle}
IMM_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$IMM_DIR/src"
WORK_DIR="/tmp/imm_f1_xsim"

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "========================================"
echo "IMM F1 Filter - Vivado xsim Simulation"
echo "Dataset: $DATASET"
echo "Working dir: $WORK_DIR"
echo "========================================"

# Build file list for xvhdl
FILES=(
  # Shared utilities
  "$SRC/shared/sqrt_cordic.vhd"
  "$SRC/shared/sin_cos_cordic.vhd"
  "$SRC/shared/matrix_inverse_3x3.vhd"
  # CA UKF 9D submodules (Cholesky parallel helpers must come before cholsky_9)
  "$SRC/ca_ukf/cholesky_multiplier_array.vhd"
  "$SRC/ca_ukf/cholesky_col2_parallel.vhd"
  "$SRC/ca_ukf/cholesky_col3_parallel.vhd"
  "$SRC/ca_ukf/cholesky_col4_parallel.vhd"
  "$SRC/ca_ukf/cholesky_col5_parallel.vhd"
  "$SRC/ca_ukf/cholesky_col678_parallel.vhd"
  "$SRC/ca_ukf/cholsky_9.vhd"
  "$SRC/ca_ukf/sigma_3d.vhd"
  "$SRC/ca_ukf/predicted_mean_3d.vhd"
  "$SRC/ca_ukf/covariance_reconstruct_3d.vhd"
  "$SRC/ca_ukf/measurement_mean_3d.vhd"
  "$SRC/ca_ukf/innovation_3d.vhd"
  "$SRC/ca_ukf/innovation_covariance_3d.vhd"
  "$SRC/ca_ukf/cross_covariance_3d.vhd"
  "$SRC/ca_ukf/kalman_gain_3d.vhd"
  "$SRC/ca_ukf/state_update_3d.vhd"
  # CA UKF prediction
  "$SRC/ca_ukf/predicti_ca3d.vhd"
  "$SRC/ca_ukf/process_noise_3d.vhd"
  "$SRC/ca_ukf/prediction_phase_3d.vhd"
  # CA IMM wrappers
  "$SRC/ca_measurement_update_imm.vhd"
  "$SRC/ca_ukf_supreme_imm.vhd"
  # Singer UKF
  "$SRC/singer_ukf/singer_exp_cordic.vhd"
  "$SRC/predicti_singer3d.vhd"
  "$SRC/singer_ukf/singer_process_noise_singer_p_3d.vhd"
  "$SRC/prediction_phase_p_3d.vhd"
  "$SRC/singer_measurement_update_imm.vhd"
  "$SRC/singer_ukf_supreme_imm.vhd"
  # Bicycle UKF 7D
  "$SRC/bicycle_ukf/cholesky_7x7.vhd"
  "$SRC/bicycle_ukf/sigma_7d.vhd"
  "$SRC/bicycle_ukf/predicti_bicycle.vhd"
  "$SRC/bicycle_ukf/predicted_mean_7d.vhd"
  "$SRC/bicycle_ukf/predicted_covariance_7d.vhd"
  "$SRC/bicycle_ukf/process_noise_bicycle.vhd"
  "$SRC/bicycle_ukf/innovation_covariance_7d.vhd"
  "$SRC/bicycle_ukf/cross_covariance_7d.vhd"
  "$SRC/bicycle_ukf/kalman_gain_7d.vhd"
  "$SRC/bicycle_ukf/state_update_7d.vhd"
  # IMM modules
  "$SRC/state_mapper_9d_to_7d.vhd"
  "$SRC/state_mapper_7d_to_9d.vhd"
  "$SRC/bicycle_ukf_supreme_imm.vhd"
  "$SRC/exp_lut.vhd"
  "$SRC/log_lut.vhd"
  "$SRC/imm_output_fusion.vhd"
  "$SRC/imm_prob_update.vhd"
  "$SRC/imm_likelihood.vhd"
  "$SRC/imm_state_mixer.vhd"
  "$SRC/imm_covariance_mixer.vhd"
  "$SRC/imm_f1_top.vhd"
)

# Select testbench
case $DATASET in
  3cycle)
    TB_FILE="$IMM_DIR/testbenches/imm_f1_3cycle_tb.vhd"
    TB_NAME="imm_f1_3cycle_tb"
    SIM_TIME="50ms"
    ;;
  drone)
    TB_FILE="$IMM_DIR/testbenches/imm_f1_drone_tb.vhd"
    TB_NAME="imm_f1_drone_tb"
    SIM_TIME="500ms"
    ;;
  monaco)
    TB_FILE="$IMM_DIR/testbenches/imm_f1_monaco_tb.vhd"
    TB_NAME="imm_f1_monaco_tb"
    SIM_TIME="800ms"
    ;;
  silverstone)
    TB_FILE="$IMM_DIR/testbenches/imm_f1_silverstone_tb.vhd"
    TB_NAME="imm_f1_silverstone_tb"
    SIM_TIME="800ms"
    ;;
  monaco100)
    TB_FILE="$IMM_DIR/testbenches/imm_f1_monaco_100_tb.vhd"
    TB_NAME="imm_f1_monaco_100_tb"
    SIM_TIME="150ms"
    ;;
  silverstone100)
    TB_FILE="$IMM_DIR/testbenches/imm_f1_silverstone_100_tb.vhd"
    TB_NAME="imm_f1_silverstone_100_tb"
    SIM_TIME="150ms"
    ;;
  debug5)
    TB_FILE="$IMM_DIR/testbenches/imm_f1_debug_5cy_tb.vhd"
    TB_NAME="imm_f1_debug_5cy_tb"
    SIM_TIME="50ms"
    ;;
  *)
    echo "Unknown dataset: $DATASET"
    exit 1
    ;;
esac

# Step 1: Compile all sources
echo ""
echo "--- Compiling with xvhdl ---"
for f in "${FILES[@]}"; do
  xvhdl --2008 "$f" 2>&1 | grep -i error || true
done
xvhdl --2008 "$TB_FILE" 2>&1 | grep -i error || true
echo "  Compilation complete"

# Step 2: Elaborate
echo ""
echo "--- Elaborating with xelab ---"
xelab --debug typical -s imm_sim "$TB_NAME" 2>&1 | tail -20

# Step 3: Create TCL run script
cat > "$WORK_DIR/run_sim.tcl" << 'EOF'
run all
quit
EOF

# Step 4: Run simulation
echo ""
echo "--- Running xsim ($SIM_TIME) ---"
xsim imm_sim -t "$WORK_DIR/run_sim.tcl" 2>&1 | tail -80

# Step 5: Copy output files to results directory
mkdir -p "$IMM_DIR/results"
for outf in "$WORK_DIR"/imm_vhdl_*.txt "$WORK_DIR"/imm_debug_*.txt "$WORK_DIR"/yeah_raha.txt "$WORK_DIR"/waha.txt; do
  if [ -f "$outf" ]; then
    cp "$outf" "$IMM_DIR/results/"
    echo "Output saved: $IMM_DIR/results/$(basename "$outf")"
  fi
done

echo ""
echo "=== VIVADO XSIM SIMULATION COMPLETE ==="
