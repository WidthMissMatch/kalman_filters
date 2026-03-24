#!/bin/bash
set -e

TRACK=${1:-monaco}  # monaco or silverstone

XVHDL=/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl
XELAB=/home/arunupscee/vivado/2025.1/Vivado/bin/xelab
XSIM=/home/arunupscee/vivado/2025.1/Vivado/bin/xsim

rm -rf xsim.dir *.jou *.log *.pb xelab.* xvhdl.* webtalk* *.wdb
rm -f sr_vhdl_output_f1_${TRACK}_2024.txt

echo "=== Compiling CA SR-UKF F1 ($TRACK) ==="

# Shared components
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

# SR-UKF components
$XVHDL --work work src/sr_ukf/qr_decomp_9x19.vhd
$XVHDL --work work src/sr_ukf/cholesky_rank1_update.vhd
$XVHDL --work work src/sr_ukf/cholesky_rank1_downdate.vhd
$XVHDL --work work src/sr_ukf/process_noise_rank1_ca_3d.vhd
$XVHDL --work work src/sr_ukf/state_update_potter_3d.vhd
$XVHDL --work work src/sr_ukf/sr_prediction_phase_ca_3d.vhd
$XVHDL --work work src/sr_ukf/sr_measurement_update_ca_3d.vhd
$XVHDL --work work src/sr_ukf/sr_ukf_supreme_ca_3d.vhd

# Testbench
$XVHDL --work work ca_ukf.srcs/sim_1/new/sr_ukf_f1_${TRACK}_2024_tb.vhd

echo "=== Elaborating ==="
$XELAB -debug typical work.sr_ukf_ca_f1_${TRACK}_2024_tb -s sr_f1_sim

echo "=== Running ==="
$XSIM sr_f1_sim --runall

echo "=========================================="
echo "CA SR-UKF F1 $TRACK simulation complete!"
if [ -f sr_vhdl_output_f1_${TRACK}_2024.txt ]; then
    lines=$(wc -l < sr_vhdl_output_f1_${TRACK}_2024.txt)
    echo "Output: $lines lines"
    head -5 sr_vhdl_output_f1_${TRACK}_2024.txt
    echo "..."
    tail -3 sr_vhdl_output_f1_${TRACK}_2024.txt
fi
echo "=========================================="
