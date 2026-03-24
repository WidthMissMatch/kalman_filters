# TCL script to run vehicle simulation (600 cycles)

# Open the project
open_project /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.xpr

# Close any open simulation
catch {close_sim -quiet}

# Switch to manual mode
set_property source_mgmt_mode None [current_project]

# Set the 600-cycle vehicle testbench as top
set_property top ukf_real_synthetic_vehicle_600cycles_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

puts "======================================"
puts "Simulation top: [get_property top [get_filesets sim_1]]"
puts "Launching 600-cycle vehicle simulation..."
puts "======================================"

# Launch behavioral simulation
launch_simulation

# Run simulation for 12ms (600 cycles × 600 clocks × 10ns = 3.6ms + margin)
puts "Running simulation for 12ms..."
run 12ms

# Close simulation
close_sim

puts "======================================"
puts "Simulation complete at [clock format [clock seconds]]"
puts "Output file location: ca_ukf.sim/sim_1/behav/xsim/vhdl_output_synthetic_vehicle_600cycles.txt"
puts "======================================"

# Close project
close_project

exit
