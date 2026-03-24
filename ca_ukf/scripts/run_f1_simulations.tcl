# Run all F1 circuit simulations in Vivado
# Usage: vivado -mode batch -source scripts/run_f1_simulations.tcl

set circuits [list monaco singapore suzuka silverstone]

foreach circuit $circuits {
    puts "\n=========================================="
    puts "Running F1 $circuit simulation..."
    puts "==========================================\n"
    
    # Open project
    open_project ca_ukf.xpr
    
    # Set simulation top
    set_property top ukf_real_f1_${circuit}_2024_750cycles_tb [get_filesets sim_1]
    
    # Reset and launch simulation
    reset_simulation sim_1
    launch_simulation -mode behavioral
    
    # Run for sufficient time (750 cycles × 630 clk/cycle × 10ns/clk = 4.725ms)
    run 5ms
    
    # Close simulation
    close_sim -force
    close_project
    
    puts "\n✓ Completed F1 $circuit simulation"
}

puts "\n=========================================="
puts "All F1 simulations complete!"
puts "=========================================="
exit
