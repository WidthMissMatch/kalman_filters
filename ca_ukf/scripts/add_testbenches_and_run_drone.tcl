# TCL script to add testbenches to project and run drone simulation

# Open the project
open_project /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.xpr

# Add the drone and vehicle testbenches to sim_1 fileset
puts "======================================"
puts "Adding testbench files to simulation fileset..."
puts "======================================"

add_files -fileset sim_1 -norecurse {
    /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sim_1/new/ukf_real_synthetic_drone_500cycles_tb.vhd
    /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sim_1/new/ukf_real_synthetic_vehicle_600cycles_tb.vhd
}

# Update compile order
update_compile_order -fileset sim_1

# Switch to manual mode
set_property source_mgmt_mode None [current_project]

# Set the 500-cycle drone testbench as top
set_property top ukf_real_synthetic_drone_500cycles_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

# Save project
save_project_as -force ca_ukf.xpr

puts "======================================"
puts "Testbench set to: [get_property top [get_filesets sim_1]]"
puts "Launching simulation..."
puts "======================================"

# Launch behavioral simulation
launch_simulation

# Run simulation for 10ms (enough for 500 cycles)
puts "Running simulation for 10ms (500 cycles × 600 clocks × 10ns = 3ms + margin)..."
run 10ms

# Close simulation and project
close_sim
close_project

puts "======================================"
puts "500-cycle drone testbench complete"
puts "Check output file: ca_ukf.sim/sim_1/behav/xsim/vhdl_output_synthetic_drone_500cycles.txt"
puts "======================================"
