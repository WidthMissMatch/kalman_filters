###############################################################################
# Vivado Simulation TCL Script
# Runs behavioral simulation of UKF with real-world dataset testbench
# Auto-generated test framework for UKF validation
###############################################################################

# Get parameters from command line (dataset name)
if { $argc > 0 } {
    set dataset_name [lindex $argv 0]
    puts "Dataset: $dataset_name"
} else {
    puts "ERROR: No dataset specified"
    puts "Usage: vivado -mode batch -source run_vivado_simulation.tcl -tclargs dataset=drone_euroc_mh01"
    exit 1
}

# Project file (must exist)
set project_file "ca_ukf.xpr"

if { ![file exists $project_file] } {
    puts "ERROR: Project file not found: $project_file"
    exit 1
}

# Open project
puts "Opening project: $project_file"
open_project $project_file

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Set top-level testbench (infer from dataset name)
set safe_name [string map {"." "_" "-" "_"} $dataset_name]
set tb_name "ukf_real_${safe_name}_tb"

puts "Setting simulation top: $tb_name"
set_property top $tb_name [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Launch behavioral simulation
puts "Launching behavioral simulation..."
launch_simulation

# Run simulation (auto-stop when testbench completes)
puts "Running simulation..."
run all

# Export waveform (optional - can be large)
# puts "Exporting waveform..."
# set waveform_file "vivado_simulation_${dataset_name}.vcd"
# write_vcd $waveform_file

# Close simulation
puts "Closing simulation..."
close_sim

# Close project
close_project

puts "=== SIMULATION COMPLETE ==="
puts "Dataset: $dataset_name"
puts "Check simulation logs for output file location"

exit 0
