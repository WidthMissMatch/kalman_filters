# TCL script to compile missing components and run simulation

# Open the project
open_project /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.xpr

# Add the missing source files to sources_1 fileset if not already added
set file1 "/home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sources_1/new/cholsky_9.vhd"
set file2 "/home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sources_1/new/predicti_ca3d.vhd"

# Check if files are already in fileset, if not add them
if {[llength [get_files -of_objects [get_filesets sources_1] $file1]] == 0} {
    add_files -fileset sources_1 -norecurse $file1
    puts "Added cholsky_9.vhd to sources_1"
} else {
    puts "cholsky_9.vhd already in sources_1"
}

if {[llength [get_files -of_objects [get_filesets sources_1] $file2]] == 0} {
    add_files -fileset sources_1 -norecurse $file2
    puts "Added predicti_ca3d.vhd to sources_1"
} else {
    puts "predicti_ca3d.vhd already in sources_1"
}

# Update compile order
update_compile_order -fileset sources_1

# Set the smoke testbench as top
set_property top ukf_supreme_3d_smoke_tb [get_filesets sim_1]
update_compile_order -fileset sim_1

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
