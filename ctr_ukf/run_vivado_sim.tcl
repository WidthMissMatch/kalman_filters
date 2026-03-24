# CTR UKF 25-Cycle Testbench - Vivado Batch Simulation Script
# Usage: vivado -mode batch -source run_vivado_sim.tcl

set proj_dir [file normalize [file dirname [info script]]]
set src_dir "$proj_dir/src"
set proj_name "ctr_ukf"
set part "xczu7ev-ffvc1156-2-e"

# Remove old project if exists
file delete -force "$proj_dir/$proj_name"

# Create project
create_project $proj_name "$proj_dir/$proj_name" -part $part -force

# Add all RTL sources
set src_files [list \
    "$src_dir/sqrt_cordic.vhd" \
    "$src_dir/cholesky_multiplier_array.vhd" \
    "$src_dir/cholesky_col2_parallel.vhd" \
    "$src_dir/cholesky_col3_parallel.vhd" \
    "$src_dir/cholesky_col4_parallel.vhd" \
    "$src_dir/cholesky_col5_parallel.vhd" \
    "$src_dir/cholesky_col678_parallel.vhd" \
    "$src_dir/cholsky_9.vhd" \
    "$src_dir/sigma_3d.vhd" \
    "$src_dir/predicti_ctr3d.vhd" \
    "$src_dir/predicted_mean_3d.vhd" \
    "$src_dir/covariance_reconstruct_3d.vhd" \
    "$src_dir/process_noise_3d.vhd" \
    "$src_dir/prediction_phase_3d.vhd" \
    "$src_dir/matrix_inverse_3x3.vhd" \
    "$src_dir/measurement_mean_3d.vhd" \
    "$src_dir/innovation_3d.vhd" \
    "$src_dir/innovation_covariance_3d.vhd" \
    "$src_dir/cross_covariance_3d.vhd" \
    "$src_dir/kalman_gain_3d.vhd" \
    "$src_dir/state_update_3d.vhd" \
    "$src_dir/measurement_update_3d.vhd" \
    "$src_dir/ukf_supreme_3d.vhd" \
]

foreach f $src_files {
    add_files -norecurse $f
}

# Set VHDL 2008 for all sources
set_property file_type {VHDL 2008} [get_files *.vhd]

# Add testbench as simulation source
add_files -fileset sim_1 -norecurse "$src_dir/ctr_ukf_25cycle_tb.vhd"
set_property file_type {VHDL 2008} [get_files -of_objects [get_filesets sim_1] *.vhd]

# Set testbench as top
set_property top ctr_ukf_25cycle_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Configure simulation settings
set_property -name {xsim.simulate.runtime} -value {200us} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Launch simulation
puts "=========================================="
puts "Launching CTR UKF 25-cycle simulation..."
puts "=========================================="

launch_simulation

# Run simulation
run 200us

puts "=========================================="
puts "Simulation complete. Check output file:"
puts "  vhdl_output_ctr_25cycles.txt"
puts "=========================================="

# Close
close_sim
close_project
