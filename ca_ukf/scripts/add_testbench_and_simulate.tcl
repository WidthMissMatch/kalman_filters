# Vivado TCL Script - Add testbench and simulate
# Ensures testbench is added to project before simulating

# Open project
open_project /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.xpr

# Add testbench file if not already added
set tb_file "/home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sim_1/new/ukf_supreme_3d_smoke_tb.vhd"
if {[file exists $tb_file]} {
    puts "INFO: Adding testbench file: $tb_file"
    add_files -fileset sim_1 -norecurse $tb_file

    # Update compile order
    update_compile_order -fileset sim_1

    # Set as top
    set_property top ukf_supreme_3d_smoke_tb [get_filesets sim_1]

    puts "INFO: Testbench added successfully"
} else {
    puts "ERROR: Testbench file not found: $tb_file"
    exit 1
}

# Launch simulation
puts "INFO: Launching behavioral simulation..."
launch_simulation

# Run for 10ms (5 cycles)
puts "INFO: Running simulation..."
run 10ms

# Report status
puts "INFO: Simulation complete"

# Close simulation
close_sim

# Close project
close_project

puts "SUCCESS: Smoke test completed"
