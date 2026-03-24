# TCL script to run drone simulation (simplified - assumes testbenches already added)

# Open the project
open_project /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.xpr

# Close any open simulation
catch {close_sim -quiet}

# Switch to manual mode
set_property source_mgmt_mode None [current_project]

# Set the 500-cycle drone testbench as top
set_property top ukf_real_synthetic_drone_500cycles_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

puts "======================================"
puts "Simulation top: [get_property top [get_filesets sim_1]]"
puts "Launching 500-cycle drone simulation..."
puts "======================================"

# Launch behavioral simulation
launch_simulation

# Run simulation for 10ms (500 cycles × 600 clocks × 10ns = 3ms + margin)
puts "Running simulation for 10ms..."
run 10ms

# Close simulation
close_sim

puts "======================================"
puts "Simulation complete at [clock format [clock seconds]]"
puts "Output file location: ca_ukf.sim/sim_1/behav/xsim/vhdl_output_synthetic_drone_500cycles.txt"
puts "======================================"

# Close project
close_project

exit
