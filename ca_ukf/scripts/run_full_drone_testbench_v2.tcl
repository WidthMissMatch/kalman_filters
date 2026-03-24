# TCL script to run full 500-cycle drone testbench (version 2 - direct approach)

# Open the project
open_project /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.xpr

# Close any open simulation
catch {close_sim -quiet}

# Reset simulation fileset
reset_run sim_1

# Force manual mode and save
set_property source_mgmt_mode None [current_project]
save_project_as -force ca_ukf.xpr

# Now set the top for simulation
set_property top ukf_real_synthetic_drone_500cycles_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

# Save again
save_project_as -force ca_ukf.xpr

# Launch behavioral simulation
puts "======================================"
puts "Launching simulation with top: ukf_real_synthetic_drone_500cycles_tb"
puts "======================================"
launch_simulation

# Run simulation for enough time to complete 500 cycles
# 500 cycles × 600 clocks/cycle = 300,000 clocks = 3ms
# Add margin: run 10ms to be safe
puts "Running simulation for 10ms..."
run 10ms

# Close simulation and project
close_sim
close_project

puts "======================================"
puts "500-cycle drone testbench complete"
puts "Check output file: vhdl_output_synthetic_drone_500cycles.txt"
puts "======================================"
