#!/bin/bash
set -e

XVHDL=/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl
XELAB=/home/arunupscee/vivado/2025.1/Vivado/bin/xelab
XSIM=/home/arunupscee/vivado/2025.1/Vivado/bin/xsim

# Clean up
rm -rf xsim.dir *.jou *.log *.pb xelab.* xvhdl.* webtalk* *.wdb
rm -f sr_vhdl_output_synthetic_drone_500cycles.txt

echo "=== Compiling SR-UKF CA VHDL sources ==="

# Shared components (same as standard UKF)
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

# SR-UKF specific components
$XVHDL --work work src/qr_decomp_9x19.vhd
$XVHDL --work work src/cholesky_rank1_update.vhd
$XVHDL --work work src/cholesky_rank1_downdate.vhd
$XVHDL --work work src/process_noise_rank1_ca_3d.vhd
$XVHDL --work work src/state_update_potter_3d.vhd

# SR-UKF wrappers and top-level
$XVHDL --work work src/sr_prediction_phase_ca_3d.vhd
$XVHDL --work work src/sr_measurement_update_ca_3d.vhd
$XVHDL --work work src/sr_ukf_supreme_ca_3d.vhd

# Testbench
$XVHDL --work work ca_ukf.srcs/sim_1/new/sr_ukf_real_synthetic_drone_500cycles_tb.vhd

echo "=== Elaborating SR-UKF CA testbench ==="
$XELAB -debug typical work.sr_ukf_real_synthetic_drone_500cycles_tb -s sr_sim

echo "=== Running SR-UKF CA simulation ==="
$XSIM sr_sim --runall

echo "=========================================="
echo "SR-UKF CA simulation complete!"
if [ -f sr_vhdl_output_synthetic_drone_500cycles.txt ]; then
    lines=$(wc -l < sr_vhdl_output_synthetic_drone_500cycles.txt)
    echo "Output file has $lines lines"
    echo "First 3 cycles:"
    head -6 sr_vhdl_output_synthetic_drone_500cycles.txt
    echo "..."
    echo "Last 2 cycles:"
    tail -3 sr_vhdl_output_synthetic_drone_500cycles.txt
else
    echo "ERROR: Output file not generated!"
fi
echo "==========================================
