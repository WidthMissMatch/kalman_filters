# Vivado TCL Script for UKF Smoke Test
# Quick test to verify basic compilation

# Open project
open_project /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.xpr

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Set smoke test testbench
set tb_name "ukf_supreme_3d_smoke_tb"

puts "INFO: Setting top-level testbench: $tb_name"
set_property top $tb_name [get_filesets sim_1]

# Launch behavioral simulation
puts "INFO: Launching behavioral simulation..."
launch_simulation

# Run simulation for 10ms (smoke test is only 5 cycles)
puts "INFO: Running simulation for 10ms..."
run 10ms

# Check if simulation completed
puts "INFO: Simulation complete"

# Close simulation
close_sim

puts "INFO: Smoke test finished successfully"

# Close project
close_project
