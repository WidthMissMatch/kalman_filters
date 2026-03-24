# TCL script to run full 600-cycle vehicle testbench

# Open the project
open_project /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.xpr

# Switch to manual compile order mode (required to set custom top)
set_property source_mgmt_mode None [current_project]

# Set the 600-cycle vehicle testbench as top
set_property top ukf_real_synthetic_vehicle_600cycles_tb [get_filesets sim_1]
update_compile_order -fileset sim_1

# Launch behavioral simulation
launch_simulation

# Run simulation for enough time to complete 600 cycles
# 600 cycles × 600 clocks/cycle = 360,000 clocks = 3.6ms
# Add margin: run 12ms to be safe
run 12ms

# Close simulation and project
close_sim
close_project

puts "======================================"
puts "600-cycle vehicle testbench complete"
puts "Check output file: vhdl_output_synthetic_vehicle_600cycles.txt"
puts "======================================"
