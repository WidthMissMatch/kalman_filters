#!/bin/bash

# Clean up previous simulation
rm -rf xsim.dir
rm -f *.jou *.log *.pb

# Create work library
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/cholesky_multiplier_array.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/cholesky_col2_parallel.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/cholesky_col3_parallel.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/cholesky_col4_parallel.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/cholesky_col5_parallel.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/cholesky_col678_parallel.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/cholsky_9.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/matrix_inverse_3x3.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/predicti_ca3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/sigma_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/predicted_mean_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/covariance_reconstruct_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/process_noise_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/prediction_phase_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/measurement_mean_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/cross_covariance_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/innovation_covariance_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/innovation_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/kalman_gain_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/measurement_update_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work src/ukf_supreme_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work work testbenches/ukf_real_synthetic_drone_500cycles_tb.vhd

# Elaborate
/home/arunupscee/vivado/2025.1/Vivado/bin/xelab -debug typical work.ukf_real_synthetic_drone_500cycles_tb -s sim

# Run simulation
/home/arunupscee/vivado/2025.1/Vivado/bin/xsim sim --runall

echo "======================================"
echo "500-cycle drone testbench complete"
echo "Check output file: vhdl_output_synthetic_drone_500cycles.txt"
echo "======================================"
