# TCL script to add all missing Cholesky sub-components

# Open the project
open_project /home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.xpr

# List of all Cholesky component files
set cholesky_files [list \
    "/home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sources_1/new/sqrt_cordic.vhd" \
    "/home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sources_1/new/cholesky_col2_parallel.vhd" \
    "/home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sources_1/new/cholesky_col3_parallel.vhd" \
    "/home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sources_1/new/cholesky_col4_parallel.vhd" \
    "/home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sources_1/new/cholesky_col5_parallel.vhd" \
    "/home/arunupscee/Desktop/xtortion/ca_ukf/ca_ukf.srcs/sources_1/new/cholesky_col678_parallel.vhd" \
]

# Add each file if not already in sources_1
foreach file $cholesky_files {
    if {[llength [get_files -of_objects [get_filesets sources_1] $file]] == 0} {
        add_files -fileset sources_1 -norecurse $file
        puts "Added [file tail $file] to sources_1"
    } else {
        puts "[file tail $file] already in sources_1"
    }
}

# Update compile order
update_compile_order -fileset sources_1

# Set the smoke testbench as top
set_property top ukf_supreme_3d_smoke_tb [get_filesets sim_1]
update_compile_order -fileset sim_1

# Launch behavioral simulation
launch_simulation

# Run simulation for 10ms
run 10ms

# Close simulation and project
close_sim
close_project

puts "======================================"
puts "Simulation complete with all Cholesky components"
puts "======================================"
