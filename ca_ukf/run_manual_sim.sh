#!/bin/bash
set -e

# Clean up
rm -rf xsim.dir *.jou *.log *.pb xelab.* xvhdl.* webtalk* *.wdb
rm -f vhdl_output_synthetic_drone_500cycles.txt

echo "=== Compiling VHDL sources ==="

# Compile in dependency order using .srcs files
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/sqrt_cordic.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/cholesky_multiplier_array.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/cholesky_col2_parallel.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/cholesky_col3_parallel.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/cholesky_col4_parallel.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/cholesky_col5_parallel.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/cholesky_col678_parallel.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/cholsky_9.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/matrix_inverse_3x3.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/predicti_ca3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/sigma_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/predicted_mean_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/covariance_reconstruct_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/process_noise_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/prediction_phase_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/measurement_mean_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/cross_covariance_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/innovation_covariance_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/innovation_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/kalman_gain_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/state_update_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/measurement_update_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sources_1/new/ukf_supreme_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work ca_ukf.srcs/sim_1/new/ukf_real_synthetic_drone_500cycles_tb.vhd

echo "=== Elaborating testbench ==="
/home/arunupscee/vivado/2025.1/Vivado/bin/xelab -debug typical work.ukf_real_synthetic_drone_500cycles_tb -s sim

echo "=== Running simulation ==="
/home/arunupscee/vivado/2025.1/Vivado/bin/xsim sim --runall

echo "=========================================="
echo "Simulation complete!"
echo "Checking output..."
if [ -f vhdl_output_synthetic_drone_500cycles.txt ]; then
    lines=$(wc -l < vhdl_output_synthetic_drone_500cycles.txt)
    echo "Output file has $lines lines"
    echo "First 5 cycles:"
    head -8 vhdl_output_synthetic_drone_500cycles.txt
    echo "..."
    echo "Last 3 cycles:"
    tail -4 vhdl_output_synthetic_drone_500cycles.txt
else
    echo "ERROR: Output file not generated!"
fi
echo "=========================================="
