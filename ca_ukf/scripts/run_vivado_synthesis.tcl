###############################################################################
# Vivado Synthesis TCL Script
# Synthesizes UKF design and generates resource/timing reports
# For ZCU106 FPGA (Zynq UltraScale+)
###############################################################################

# Get target FPGA from command line
if { $argc > 0 } {
    set target_fpga [lindex $argv 0]
    puts "Target FPGA: $target_fpga"
} else {
    set target_fpga "zcu106"
    puts "Using default target: $target_fpga"
}

# Project file
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

# Set top-level design
set_property top ukf_supreme_3d [get_filesets sources_1]

# Reset synthesis run
puts "Resetting synthesis run..."
reset_run synth_1

# Launch synthesis (use 4 jobs for parallel processing)
puts "Launching synthesis..."
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Check if synthesis succeeded
set synth_status [get_property STATUS [get_runs synth_1]]
set synth_progress [get_property PROGRESS [get_runs synth_1]]

puts "Synthesis status: $synth_status"
puts "Synthesis progress: $synth_progress"

if { $synth_status != "synth_design Complete!" } {
    puts "ERROR: Synthesis failed"
    close_project
    exit 1
}

# Open synthesized design
puts "Opening synthesized design..."
open_run synth_1

# Create report directory
set report_dir "results/vivado_reports"
file mkdir $report_dir

# Generate utilization report
puts "Generating utilization report..."
set util_report "${report_dir}/utilization.rpt"
report_utilization -file $util_report -hierarchical

# Generate timing summary
puts "Generating timing report..."
set timing_report "${report_dir}/timing.rpt"
report_timing_summary -file $timing_report -max_paths 10 -delay_type min_max

# Generate power report
puts "Generating power report..."
set power_report "${report_dir}/power.rpt"
report_power -file $power_report

# Generate clock interaction report
puts "Generating clock interaction report..."
set clock_report "${report_dir}/clock_interaction.rpt"
report_clock_interaction -file $clock_report

# Extract key metrics and print summary
puts ""
puts "==================================================================="
puts "SYNTHESIS SUMMARY"
puts "==================================================================="

# Parse utilization (LUTs, DSPs, BRAM)
set lut_used [get_property SLICE_LUTS [get_cells *]]
set dsp_used [get_property DSP48 [get_cells *]]
set bram_used [get_property RAMB36 [get_cells *]]

puts "Resource Utilization:"
puts "  LUTs: $lut_used"
puts "  DSPs: $dsp_used"
puts "  BRAMs: $bram_used"

# Timing
set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1]]
puts ""
puts "Timing:"
puts "  WNS (Worst Negative Slack): $wns ns"

if { $wns >= 0 } {
    puts "  Status: TIMING MET"
} else {
    puts "  Status: TIMING FAILED"
}

puts ""
puts "Reports generated in: $report_dir"
puts "  - utilization.rpt"
puts "  - timing.rpt"
puts "  - power.rpt"
puts "  - clock_interaction.rpt"

# Close design and project
close_design
close_project

puts ""
puts "=== SYNTHESIS COMPLETE ==="

exit 0
