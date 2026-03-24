# TCL script to run full 500-cycle drone testbench

# Open the project
open_project /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.xpr

# Switch to manual compile order mode (required to set custom top)
set_property source_mgmt_mode None [current_project]

# Set the 500-cycle drone testbench as top
set_property top ukf_real_synthetic_drone_500cycles_tb [get_filesets sim_1]
update_compile_order -fileset sim_1

# Launch behavioral simulation
launch_simulation

# Run simulation for enough time to complete 500 cycles
# 500 cycles × 600 clocks/cycle = 300,000 clocks = 3ms
# Add margin: run 10ms to be safe
run 10ms

# Close simulation and project
close_sim
close_project

puts "======================================"
puts "500-cycle drone testbench complete"
puts "Check output file: vhdl_output_synthetic_drone_500cycles.txt"
puts "======================================"
