#!/bin/bash
################################################################################
# GHDL Smoke Test Runner for 9D CA UKF
# Purpose: Compile all modules and run 5-cycle smoke test
################################################################################

set -e  # Exit on error

# Directories
PROJECT_DIR="/home/arunupscee/Desktop/xtortion/ca_ukf"
SRC_DIR="${PROJECT_DIR}/ca_ukf.srcs/sources_1/new"
TB_DIR="${PROJECT_DIR}/ca_ukf.srcs/sim_1/new"
WORK_DIR="${PROJECT_DIR}/sim_work"

# Create work directory
echo "========================================="
echo "  9D CA UKF - SMOKE TEST COMPILATION"
echo "========================================="
echo ""
echo "Creating work directory..."
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

# Compilation flags
GHDL_FLAGS="--std=08 --workdir=. --work=work"

echo ""
echo "Starting compilation..."
echo ""

# Layer 1: Utilities
echo "[1/18] Compiling sqrt_newton.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/sqrt_newton.vhd"

echo "[2/18] Compiling inverse_newsy.vhd (reciprocal_newton)..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/inverse_newsy.vhd"

echo "[3/18] Compiling matrix_inverse_3x3.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/matrix_inverse_3x3.vhd"

echo "[4/18] Compiling innovation_3d.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/innovation_3d.vhd"

# Layer 2: Core UKF Components (9D)
echo "[5/18] Compiling cholsky_9.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/cholsky_9.vhd"

echo "[6/18] Compiling predicti_ca3d.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/predicti_ca3d.vhd"

echo "[7/18] Compiling sigma_3d.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/sigma_3d.vhd"

echo "[8/18] Compiling predicted_mean_3d.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/predicted_mean_3d.vhd"

echo "[9/18] Compiling covariance_reconstruct_3d.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/covariance_reconstruct_3d.vhd"

echo "[10/18] Compiling process_noise_3d.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/process_noise_3d.vhd"

# Layer 3: Measurement Update Components (9D)
echo "[11/18] Compiling measurement_mean_3d.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/measurement_mean_3d.vhd"

echo "[12/18] Compiling cross_covariance_3d.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/cross_covariance_3d.vhd"

echo "[13/18] Compiling innovation_covariance_3d.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/innovation_covariance_3d.vhd"

echo "[14/18] Compiling kalman_gain_3d.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/kalman_gain_3d.vhd"

echo "[15/18] Compiling state_update_3d.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/state_update_3d.vhd"

# Layer 4: Coordinators (9D)
echo "[16/18] Compiling prediction_phase_3d.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/prediction_phase_3d.vhd"

echo "[17/18] Compiling measurement_update_3d.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/measurement_update_3d.vhd"

# Layer 5: Top-Level (9D)
echo "[18/18] Compiling ukf_supreme_3d.vhd..."
ghdl -a ${GHDL_FLAGS} "${SRC_DIR}/ukf_supreme_3d.vhd"

# Compile testbench
echo ""
echo "Compiling testbench..."
ghdl -a ${GHDL_FLAGS} "${TB_DIR}/ukf_supreme_3d_smoke_tb.vhd"

# Elaborate
echo ""
echo "Elaborating design..."
ghdl -e ${GHDL_FLAGS} ukf_supreme_3d_smoke_tb

# Run simulation
echo ""
echo "========================================="
echo "  RUNNING SMOKE TEST (5 cycles)"
echo "========================================="
echo ""
ghdl -r ${GHDL_FLAGS} ukf_supreme_3d_smoke_tb \
    --stop-time=5ms \
    --assert-level=error

# Check exit code
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "  SMOKE TEST COMPLETED"
    echo "========================================="
    echo ""
    exit 0
else
    echo ""
    echo "========================================="
    echo "  SMOKE TEST FAILED"
    echo "========================================="
    echo ""
    exit 1
fi
