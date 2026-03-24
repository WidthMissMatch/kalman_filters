#!/bin/bash
set -e
TRACK=${1:-monaco}

XVHDL=/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl
XELAB=/home/arunupscee/vivado/2025.1/Vivado/bin/xelab
XSIM=/home/arunupscee/vivado/2025.1/Vivado/bin/xsim

rm -rf xsim.dir *.jou *.log *.pb xelab.* xvhdl.* webtalk* *.wdb 2>/dev/null
rm -f sr_vhdl_f1_${TRACK}_50.txt

echo "=== Compiling CA SR-UKF F1 ${TRACK} (50 cycles) ==="
$XVHDL --work work src/sqrt_cordic.vhd
$XVHDL --work work src/matrix_inverse_3x3.vhd
$XVHDL --work work src/predicti_ca3d.vhd
$XVHDL --work work src/sigma_3d.vhd
$XVHDL --work work src/predicted_mean_3d.vhd
$XVHDL --work work src/measurement_mean_3d.vhd
$XVHDL --work work src/cross_covariance_3d.vhd
$XVHDL --work work src/innovation_covariance_3d.vhd
$XVHDL --work work src/innovation_3d.vhd
$XVHDL --work work src/kalman_gain_3d.vhd

$XVHDL --work work src/sr_ukf/qr_decomp_9x19.vhd
$XVHDL --work work src/sr_ukf/cholesky_rank1_update.vhd
$XVHDL --work work src/sr_ukf/cholesky_rank1_downdate.vhd
$XVHDL --work work src/sr_ukf/process_noise_rank1_ca_3d.vhd
$XVHDL --work work src/sr_ukf/state_update_potter_3d.vhd
$XVHDL --work work src/sr_ukf/sr_prediction_phase_ca_3d.vhd
$XVHDL --work work src/sr_ukf/sr_measurement_update_ca_3d.vhd
$XVHDL --work work src/sr_ukf/sr_ukf_supreme_ca_3d.vhd

$XVHDL --work work ca_ukf.srcs/sim_1/new/sr_ukf_f1_${TRACK}_50_tb.vhd

echo "=== Elaborating ==="
$XELAB -debug typical work.sr_ukf_ca_f1_${TRACK}_50_tb -s sr_f1_50

echo "=== Running (50 cycles) ==="
$XSIM sr_f1_50 --runall

echo "=========================================="
if [ -f sr_vhdl_f1_${TRACK}_50.txt ]; then
    echo "Output:"
    cat sr_vhdl_f1_${TRACK}_50.txt
fi
echo "=========================================="
