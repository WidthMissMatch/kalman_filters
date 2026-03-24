#!/bin/bash
# IMM F1 Filter - GHDL Simulation Runner (Standard UKF version)
# All sources are now local in src/ subdirectories.
# Usage: ./run_imm_sim.sh [drone|monaco|silverstone] [cycles]
set -e

DATASET=${1:-drone}
MAX_CYCLES=${2:-500}
IMM_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJ_ROOT="$(cd "$IMM_DIR/.." && pwd)"
WORK_DIR="/tmp/imm_f1_build"
SRC="$IMM_DIR/src"

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "========================================"
echo "IMM F1 Filter - GHDL Simulation"
echo "Dataset: $DATASET"
echo "All sources from: $SRC"
echo "Working dir: $WORK_DIR"
echo "========================================"

# =========================================================================
# Step 1: Shared utility modules
# =========================================================================
echo ""
echo "--- Compiling shared utility modules ---"
ghdl -a --std=08 "$SRC/shared/sqrt_cordic.vhd"
ghdl -a --std=08 "$SRC/shared/sin_cos_cordic.vhd"
ghdl -a --std=08 "$SRC/shared/matrix_inverse_3x3.vhd"
echo "  sqrt_cordic, sin_cos_cordic, matrix_inverse_3x3"

# =========================================================================
# Step 2: Shared 9D UKF submodules (used by CA and Singer standard UKF)
# =========================================================================
echo ""
echo "--- Compiling shared 9D submodules ---"
ghdl -a --std=08 "$SRC/ca_ukf/cholesky_multiplier_array.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/cholesky_col2_parallel.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/cholesky_col3_parallel.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/cholesky_col4_parallel.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/cholesky_col5_parallel.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/cholesky_col678_parallel.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/cholsky_9.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/sigma_3d.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/predicted_mean_3d.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/covariance_reconstruct_3d.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/measurement_mean_3d.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/innovation_3d.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/innovation_covariance_3d.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/cross_covariance_3d.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/kalman_gain_3d.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/state_update_3d.vhd"
echo "  cholesky_9x9, sigma_3d, predicted_mean_3d, covariance_reconstruct_3d"
echo "  measurement_mean_3d, innovation_3d, innovation_covariance_3d"
echo "  cross_covariance_3d, kalman_gain_3d, state_update_3d"

# =========================================================================
# Step 3: CA standard UKF (prediction + measurement update + IMM wrapper)
# =========================================================================
echo ""
echo "--- Compiling CA UKF ---"
ghdl -a --std=08 "$SRC/ca_ukf/predicti_ca3d.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/process_noise_3d.vhd"
ghdl -a --std=08 "$SRC/ca_ukf/prediction_phase_3d.vhd"
ghdl -a --std=08 "$SRC/ca_measurement_update_imm.vhd"
ghdl -a --std=08 "$SRC/ca_ukf_supreme_imm.vhd"
echo "  CA UKF (standard) with IMM wrapper complete"

# =========================================================================
# Step 4: Singer standard UKF (prediction + measurement update + IMM wrapper)
# =========================================================================
echo ""
echo "--- Compiling Singer UKF ---"
ghdl -a --std=08 "$SRC/singer_ukf/singer_exp_cordic.vhd"
ghdl -a --std=08 "$SRC/predicti_singer3d.vhd"
ghdl -a --std=08 "$SRC/singer_ukf/singer_process_noise_singer_p_3d.vhd"
ghdl -a --std=08 "$SRC/prediction_phase_p_3d.vhd"
ghdl -a --std=08 "$SRC/singer_measurement_update_imm.vhd"
ghdl -a --std=08 "$SRC/singer_ukf_supreme_imm.vhd"
echo "  Singer UKF (standard) with IMM wrapper complete"

# =========================================================================
# Step 5: Bicycle UKF modules (7D, standard UKF)
# =========================================================================
echo ""
echo "--- Compiling Bicycle UKF (7D) ---"
ghdl -a --std=08 "$SRC/bicycle_ukf/cholesky_7x7.vhd"
ghdl -a --std=08 "$SRC/bicycle_ukf/sigma_7d.vhd"
ghdl -a --std=08 "$SRC/bicycle_ukf/predicti_bicycle.vhd"
ghdl -a --std=08 "$SRC/bicycle_ukf/predicted_mean_7d.vhd"
ghdl -a --std=08 "$SRC/bicycle_ukf/predicted_covariance_7d.vhd"
ghdl -a --std=08 "$SRC/bicycle_ukf/process_noise_bicycle.vhd"
ghdl -a --std=08 "$SRC/bicycle_ukf/innovation_covariance_7d.vhd"
ghdl -a --std=08 "$SRC/bicycle_ukf/cross_covariance_7d.vhd"
ghdl -a --std=08 "$SRC/bicycle_ukf/kalman_gain_7d.vhd"
ghdl -a --std=08 "$SRC/bicycle_ukf/state_update_7d.vhd"
echo "  Bicycle UKF submodules complete"

# =========================================================================
# Step 6: IMM-specific modules
# =========================================================================
echo ""
echo "--- Compiling IMM modules ---"

# State mappers (9D <-> 7D)
ghdl -a --std=08 "$SRC/state_mapper_9d_to_7d.vhd"
ghdl -a --std=08 "$SRC/state_mapper_7d_to_9d.vhd"

# Bicycle IMM wrapper (uses standard UKF internally)
ghdl -a --std=08 "$SRC/bicycle_ukf_supreme_imm.vhd"

# IMM core modules
ghdl -a --std=08 "$SRC/exp_lut.vhd"
ghdl -a --std=08 "$SRC/log_lut.vhd"
ghdl -a --std=08 "$SRC/imm_output_fusion.vhd"
ghdl -a --std=08 "$SRC/imm_prob_update.vhd"
ghdl -a --std=08 "$SRC/imm_likelihood.vhd"
ghdl -a --std=08 "$SRC/imm_state_mixer.vhd"
ghdl -a --std=08 "$SRC/imm_covariance_mixer.vhd"

# IMM top-level
ghdl -a --std=08 "$SRC/imm_f1_top.vhd"

echo "  IMM modules compiled"

# =========================================================================
# Step 7: Compile testbench
# =========================================================================
echo ""
echo "--- Compiling testbench ---"
case $DATASET in
  drone)
    TB_NAME="imm_f1_drone_tb"
    CSV_PATH="$PROJ_ROOT/ca_ukf/test_data/real_world/synthetic_drone_500cycles.csv"
    ;;
  monaco)
    TB_NAME="imm_f1_monaco_tb"
    CSV_PATH="$PROJ_ROOT/ca_ukf/test_data/real_world/f1_monaco_2024_750cycles.csv"
    ;;
  silverstone)
    TB_NAME="imm_f1_silverstone_tb"
    CSV_PATH="$PROJ_ROOT/ca_ukf/test_data/real_world/f1_silverstone_2024_750cycles.csv"
    ;;
  *)
    echo "Unknown dataset: $DATASET"
    exit 1
    ;;
esac

ghdl -a --std=08 "$IMM_DIR/testbenches/${TB_NAME}.vhd"

# Step 8: Elaborate
echo "--- Elaborating ---"
ghdl -e --std=08 "$TB_NAME"

# Step 9: Run
echo "--- Running simulation ---"
echo "This may take several minutes..."
ghdl -r --std=08 "$TB_NAME" --stop-time=500ms --ieee-asserts=disable 2>&1 | tail -50

# Step 10: Compute RMSE
if [ -f "imm_vhdl_output.txt" ]; then
  echo ""
  echo "--- Computing RMSE ---"
  python3 "$IMM_DIR/scripts/compute_rmse.py" imm_vhdl_output.txt "$CSV_PATH"
else
  echo "WARNING: No output file generated"
fi

echo ""
echo "Done!"
