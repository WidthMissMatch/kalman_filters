# Vivado TCL Script for UKF Simulation
# Runs testbench and captures outputs

# Open project
open_project /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.xpr

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Set simulation testbench
# Default: drone synthetic testbench
set tb_name "ukf_real_synthetic_drone_500cycles_tb"

# Check if testbench exists in simulation fileset
set tb_file "/home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sim_1/new/${tb_name}.vhd"
if {[file exists $tb_file]} {
    puts "INFO: Setting top-level testbench: $tb_name"
    set_property top $tb_name [get_filesets sim_1]
} else {
    puts "ERROR: Testbench file not found: $tb_file"
    exit 1
}

# Launch behavioral simulation
puts "INFO: Launching behavioral simulation..."
launch_simulation

# Run simulation for sufficient time (500 cycles at 100MHz = 50us)
# Add margin: run for 500ms to ensure completion
puts "INFO: Running simulation for 500ms..."
run 500ms

# Check if simulation completed
puts "INFO: Simulation complete"

# Export waveform (optional)
# write_vcd /home/arunupscee/Desktop/xtortion/ca_ukf/results/vhdl_outputs/vivado/simulation.vcd

# Close simulation
close_sim

puts "INFO: Simulation finished successfully"
puts "INFO: Check output file in simulation directory: vhdl_output_synthetic_drone_500cycles.txt"

# Close project
close_project
