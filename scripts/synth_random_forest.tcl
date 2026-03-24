set_part xczu7ev-ffvc1156-2-e
set_property target_language VHDL [current_project]

read_vhdl -vhdl2008 "/home/arunupscee/Desktop/xtortion/collection/random_forest/src/rf_fixed_point_pkg.vhd"
read_vhdl -vhdl2008 "/home/arunupscee/Desktop/xtortion/collection/random_forest/src/rf_tree_rom.vhd"
read_vhdl -vhdl2008 "/home/arunupscee/Desktop/xtortion/collection/random_forest/src/rf_tree_engine.vhd"
read_vhdl -vhdl2008 "/home/arunupscee/Desktop/xtortion/collection/random_forest/src/rf_feature_extract.vhd"
read_vhdl -vhdl2008 "/home/arunupscee/Desktop/xtortion/collection/random_forest/src/rf_majority_voter.vhd"
read_vhdl -vhdl2008 "/home/arunupscee/Desktop/xtortion/collection/random_forest/src/rf_classifier_top.vhd"

synth_design -top rf_classifier_top -part xczu7ev-ffvc1156-2-e -mode out_of_context

set rpt_dir "/home/arunupscee/Desktop/xtortion/collection/reports/random_forest"
file mkdir $rpt_dir
report_utilization -file "$rpt_dir/utilization.rpt" -hierarchical
report_timing_summary -file "$rpt_dir/timing_summary.rpt" -max_paths 10
report_power -file "$rpt_dir/power.rpt"
puts "Random Forest synthesis complete. Reports in $rpt_dir"
