#!/bin/bash
# IMM Friend Filter (Singer+CTRA+Bicycle) - Vivado xsim Simulation Runner
# Usage: ./run_vivado_sim.sh [monaco10|smoke]
set -e

DATASET=${1:-monaco10}
IMM_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$IMM_DIR/src"
WORK_DIR="/tmp/imm_friend_xsim"

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "========================================"
echo "IMM Friend Filter - Vivado xsim Simulation"
echo "Models: Singer(9D) + CTRA(7D) + Bicycle(7D)"
echo "Dataset: $DATASET"
echo "Working dir: $WORK_DIR"
echo "========================================"

# Build file list for xvhdl
FILES=(
  # Shared utilities
  "$SRC/shared/sqrt_cordic.vhd"
  "$SRC/shared/sin_cos_cordic.vhd"
  "$SRC/shared/matrix_inverse_3x3.vhd"
  # CA/Singer 9D submodules (Cholesky parallel helpers first)
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
  # Singer UKF prediction
  "$SRC/singer_ukf/singer_exp_cordic.vhd"
  "$SRC/singer_ukf/predicti_singer3d.vhd"
  "$SRC/singer_ukf/singer_process_noise_singer_p_3d.vhd"
  "$SRC/singer_ukf/prediction_phase_p_3d.vhd"
  # Singer IMM wrapper
  "$SRC/imm/singer_measurement_update_imm.vhd"
  "$SRC/imm/singer_ukf_supreme_imm.vhd"
  # Bicycle UKF 7D (shared by CTRA too)
  "$SRC/bicycle_ukf/cholesky_7x7.vhd"
  "$SRC/bicycle_ukf/sigma_7d.vhd"
  "$SRC/bicycle_ukf/predicted_mean_7d.vhd"
  "$SRC/bicycle_ukf/predicted_covariance_7d.vhd"
  "$SRC/bicycle_ukf/innovation_covariance_7d.vhd"
  "$SRC/bicycle_ukf/cross_covariance_7d.vhd"
  "$SRC/bicycle_ukf/kalman_gain_7d.vhd"
  "$SRC/bicycle_ukf/state_update_7d.vhd"
  # Bicycle-specific
  "$SRC/bicycle_ukf/predicti_bicycle.vhd"
  "$SRC/bicycle_ukf/process_noise_bicycle.vhd"
  "$SRC/imm/bicycle_ukf_supreme_imm.vhd"
  # CTRA-specific
  "$SRC/ctra_ukf/predicti_ctra.vhd"
  "$SRC/ctra_ukf/process_noise_ctra.vhd"
  "$SRC/imm/ctra_ukf_supreme_imm.vhd"
  # State mappers
  "$SRC/imm/state_mapper_9d_to_7d.vhd"
  "$SRC/imm/state_mapper_9d_to_7d_ctra.vhd"
  "$SRC/imm/state_mapper_7d_to_9d.vhd"
  # IMM infrastructure
  "$SRC/imm/exp_lut.vhd"
  "$SRC/imm/log_lut.vhd"
  "$SRC/imm/imm_output_fusion.vhd"
  "$SRC/imm/imm_prob_update.vhd"
  "$SRC/imm/imm_likelihood.vhd"
  # IMM Friend specific
  "$SRC/imm/imm_friend_state_mixer.vhd"
  "$SRC/imm/imm_friend_covariance_mixer.vhd"
  "$SRC/imm/imm_friend_top.vhd"
)

# Select testbench
case $DATASET in
  monaco10)
    TB_FILE="$IMM_DIR/testbenches/imm_friend_monaco_10_tb.vhd"
    TB_NAME="imm_friend_monaco_10_tb"
    SIM_TIME="50ms"
    ;;
  monaco750)
    TB_FILE="$IMM_DIR/testbenches/imm_friend_monaco_750_tb.vhd"
    TB_NAME="imm_friend_monaco_750_tb"
    SIM_TIME="500ms"
    ;;
  abudhabi)
    TB_FILE="$IMM_DIR/testbenches/imm_friend_abu_dhabi_4173_tb.vhd"
    TB_NAME="imm_friend_abu_dhabi_4173_tb"
    SIM_TIME="2500ms"
    ;;
  *)
    echo "Unknown dataset: $DATASET"
    echo "Available: monaco10, monaco750, abudhabi"
    exit 1
    ;;
esac

# Step 1: Compile all sources
echo ""
echo "--- Compiling with xvhdl (${#FILES[@]} files) ---"
ERRORS=0
for f in "${FILES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "  MISSING: $f"
    ERRORS=$((ERRORS + 1))
    continue
  fi
  OUTPUT=$(xvhdl --2008 "$f" 2>&1)
  if echo "$OUTPUT" | grep -qi "error"; then
    echo "  ERROR in $(basename "$f"):"
    echo "$OUTPUT" | grep -i error
    ERRORS=$((ERRORS + 1))
  fi
done
xvhdl --2008 "$TB_FILE" 2>&1 | grep -i error || true
echo "  Compilation complete ($ERRORS errors)"

if [ $ERRORS -gt 0 ]; then
  echo "Fix compilation errors before proceeding."
  exit 1
fi

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

# Step 5: Copy output files
mkdir -p "$IMM_DIR/results"
for outf in "$WORK_DIR"/imm_*.txt "$WORK_DIR"/*.txt; do
  if [ -f "$outf" ]; then
    cp "$outf" "$IMM_DIR/results/"
    echo "Output saved: $IMM_DIR/results/$(basename "$outf")"
  fi
done

echo ""
echo "=== IMM FRIEND VIVADO XSIM SIMULATION COMPLETE ==="
