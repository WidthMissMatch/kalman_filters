################################################################################
# CTR UKF Hex Capture Script for xsim
#
# Runs the compiled ctr_ukf_25cycle_tb testbench and captures DUT output
# signals in hex after each UKF cycle completes (done='1').
#
# Usage:
#   cd ctr_ukf/ctr_ukf/ctr_ukf.sim/sim_1/behav/xsim
#   xsim ctr_ukf_25cycle_tb_behav -tclbatch ../../../../../../run_hex_capture.tcl
#
# Or from Vivado Tcl console after elaboration:
#   source run_hex_capture.tcl
################################################################################

puts "============================================"
puts "CTR UKF Hex Capture - 25 Cycles"
puts "============================================"

# Signal paths in the DUT (ukf_supreme_3d under ctr_ukf_25cycle_tb)
set DUT "/ctr_ukf_25cycle_tb/uut"

# State estimate signals (9 states)
set state_signals {
    x_pos_current x_vel_current x_omega_current
    y_pos_current y_vel_current y_omega_current
    z_pos_current z_vel_current z_omega_current
}

# Covariance diagonal signals (9 uncertainties)
set cov_signals {
    x_pos_uncertainty x_vel_uncertainty x_omega_uncertainty
    y_pos_uncertainty y_vel_uncertainty y_omega_uncertainty
    z_pos_uncertainty z_vel_uncertainty z_omega_uncertainty
}

# Done signal
set done_sig "${DUT}/done"

# Output file
set outfile [open "hex_capture_output.txt" w]
puts $outfile "=== CTR UKF Hex Capture - 25 Cycles ==="
puts $outfile "Signal path: ${DUT}"
puts $outfile "Format: 48-bit signed hex (Q24.24)"
puts $outfile ""

# Number of cycles to capture
set NUM_CYCLES 25

# Clock period in simulation time
set CLK_PERIOD 10ns

# Wait for reset to complete (5 cycles reset + 2 gap = 7 cycles)
puts "Waiting for reset to complete..."
run 80ns

# Main capture loop
for {set cycle 0} {$cycle < $NUM_CYCLES} {incr cycle} {
    puts "--- Waiting for cycle $cycle done signal ---"

    # Wait for done='1' with timeout (100,000 clocks = 1ms sim time)
    set timeout 0
    set max_timeout 1000000
    while {$timeout < $max_timeout} {
        run $CLK_PERIOD
        set done_val [get_value $done_sig]
        if {$done_val == "1"} {
            break
        }
        incr timeout
    }

    if {$timeout >= $max_timeout} {
        puts "ERROR: Cycle $cycle timed out!"
        puts $outfile "CYCLE $cycle: TIMEOUT"
        continue
    }

    # Allow one extra clock for outputs to settle
    run $CLK_PERIOD

    # Read all state signals
    puts -nonewline "CYCLE $cycle:"
    puts -nonewline $outfile "CYCLE $cycle"

    # State estimates
    set line_states "  STATES:"
    foreach sig $state_signals {
        set path "${DUT}/${sig}"
        set hex_val [get_value -radix hex $path]
        append line_states " ${sig}=${hex_val}"
    }
    puts $line_states
    puts $outfile $line_states

    # Covariance diagonals
    set line_cov "  COV:   "
    foreach sig $cov_signals {
        set path "${DUT}/${sig}"
        set hex_val [get_value -radix hex $path]
        append line_cov " ${sig}=${hex_val}"
    }
    puts $line_cov
    puts $outfile $line_cov

    # Also print decimal for quick reference
    set line_dec "  DEC:   "
    foreach sig {x_pos_current y_pos_current z_pos_current} {
        set path "${DUT}/${sig}"
        set dec_val [get_value -radix dec $path]
        append line_dec " ${sig}=${dec_val}"
    }
    puts $line_dec
    puts $outfile $line_dec
    puts $outfile ""

    # Wait for done to go low before next cycle
    run [expr {5 * 10}]ns
}

puts ""
puts "============================================"
puts "Hex capture complete: $NUM_CYCLES cycles"
puts "Output saved to hex_capture_output.txt"
puts "============================================"

close $outfile

# End simulation
quit
