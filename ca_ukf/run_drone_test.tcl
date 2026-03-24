# Open the project
open_project ca_ukf.xpr

# Set the drone testbench as top
set_property top ukf_real_synthetic_drone_500cycles_tb [get_filesets sim_1]
update_compile_order -fileset sim_1

# Launch simulation
launch_simulation

# Run for 10ms (500 cycles * ~600 clocks/cycle = 300k clocks = 3ms @ 100MHz, add margin)
run 10ms

# Close simulation
close_sim

# Close project
close_project

puts "=========================================="
puts "Simulation complete!"
puts "Check: vhdl_output_synthetic_drone_500cycles.txt"
puts "=========================================="
