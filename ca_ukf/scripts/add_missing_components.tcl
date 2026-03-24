# TCL script to add missing Cholesky and Predictor components to Vivado project

# Open the project
open_project /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.xpr

# Add the missing source files to sources_1 fileset
add_files -fileset sources_1 -norecurse \
    /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sources_1/new/cholsky_9.vhd \
    /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sources_1/new/predicti_ca3d.vhd

# Update compile order to ensure these files are compiled before prediction_phase_3d
update_compile_order -fileset sources_1

# Set the smoke testbench as top
set_property top ukf_supreme_3d_smoke_tb [get_filesets sim_1]
update_compile_order -fileset sim_1

# Save project
save_project_as -force /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.xpr

# Launch behavioral simulation
launch_simulation

# Run simulation for 10ms (should be enough for 5 cycles at 20ms timestep each)
run 10ms

# Close simulation and project
close_sim
close_project

puts "======================================"
puts "Simulation complete with missing components added"
puts "Check simulate.log for results"
puts "======================================"
