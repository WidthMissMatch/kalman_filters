# Debug Testbench Usage Guide

Quick reference for using the minimal debug testbenches.

---

## Available Testbenches

### 1. **ukf_5cycle_debug_tb** - Baseline Test
- **Cycles:** 5 (cycles 0-4 from drone dataset)
- **Runtime:** ~1 second
- **Purpose:** Minimal reproducible test, catches overflow at cycle 4
- **Use when:** Quick validation, testing fixes, baseline comparison

### 2. **ukf_10cycle_stress_tb** - Extended Test
- **Cycles:** 10 (cycles 0-9 from drone dataset)
- **Runtime:** ~2 seconds
- **Purpose:** Extended test with threshold warnings, captures divergence progression
- **Use when:** Stress testing, confirming fixes persist over longer runs

---

## Quick Start

### Run 5-Cycle Test
```bash
cd /home/arunupscee/Desktop/xtortion/ca_ukf

# Compile (only needed once, or after code changes)
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work ca_ukf_lib \
  ca_ukf.srcs/sim_1/new/ukf_5cycle_debug_tb.vhd

# Elaborate (only needed once, or after recompile)
/home/arunupscee/vivado/2025.1/Vivado/bin/xelab -debug typical \
  ca_ukf_lib.ukf_5cycle_debug_tb -s ukf_5cycle_debug

# Run simulation
/home/arunupscee/vivado/2025.1/Vivado/bin/xsim ukf_5cycle_debug -R | tee 5cycle_debug.log
```

### Run 10-Cycle Test
```bash
# Compile
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work ca_ukf_lib \
  ca_ukf.srcs/sim_1/new/ukf_10cycle_stress_tb.vhd

# Elaborate
/home/arunupscee/vivado/2025.1/Vivado/bin/xelab -debug typical \
  ca_ukf_lib.ukf_10cycle_stress_tb -s ukf_10cycle_stress

# Run
/home/arunupscee/vivado/2025.1/Vivado/bin/xsim ukf_10cycle_stress -R | tee 10cycle_stress.log
```

---

## Output Format

Each cycle shows:

### 1. Inputs (Measurements)
```
INPUTS:
  meas_x = [847194280] (0x00003280008) {50.497 m}
  meas_y = [-2319690] (0xFFFFFFDC8F3FA) {-0.138 m}
  meas_z = [178638570] (0x0000000AA51DEA) {10.648 m}
```
- **[Decimal]**: Raw Q24.24 signed integer
- **(0xHex)**: 12-digit hex representation (shows bit pattern)
- **{Real}**: Converted to meters (Q24.24 → float)

### 2. Outputs (State Estimates)
```
X-axis:
  x_pos = [847194176] (0x00003280000) {50.497 m}
  x_vel = [7] (0x000000000007) {0.000 m/s}
  x_acc = [16] (0x000000000010) {0.000 m/s²}
```

### 3. Uncertainty (sqrt of P diagonal)
```
UNCERTAINTY (sqrt of P diagonal):
  sigma_x_pos = [3356381] (0x0000003336DD) {0.200 m}
  sigma_x_vel = [419] (0x0000000001A3)
  sigma_x_acc = [25] (0x000000000019)
```

---

## Analyzing Results

### Check for Overflow
```bash
# Search for negative uncertainties (overflow indicator)
grep "WARNING: Negative uncertainty" 5cycle_debug.log

# Check for Cholesky failures
grep "Cholesky PSD failure" 5cycle_debug.log
```

### Track P99 Growth
```bash
# Extract P99 values across cycles
grep "p99_state" 5cycle_debug.log

# Expected output:
#   Cycle 0: p99_state = 16777216 (1.0)
#   Cycle 1: p99_state = 18449025 (1.1)
#   Cycle 2: p99_state = 82704131 (4.9)
#   Cycle 3: p99_state = 1641418400 (97.8)
#   Cycle 4: p99_state = -1488003564 (OVERFLOW!)
```

### Extract Uncertainty Values
```bash
# Get all Z-axis uncertainty values
grep "sigma_z_pos" 5cycle_debug.log

# Get cycle-by-cycle progression
grep -E "CYCLE [0-9]|sigma_z_pos" 5cycle_debug.log
```

### Find Critical Warnings (10-cycle test only)
```bash
# Check for threshold warnings
grep "CRITICAL:" 10cycle_stress.log

# Expected if overflow occurs:
#   CRITICAL: z_pos_uncertainty approaching overflow threshold!
#   Value: 1234567890 (threshold: 1073741824)
```

---

## Interpreting Hex Values

### Normal Values
```
0x000001000000 = 16,777,216 (Q24.24) = 1.0 (real)
0x000000100000 = 1,048,576 (Q24.24) = 0.0625 (real)
```

### Overflow Indicators
```
0xFFFFFFxxxxxx = Negative value (MSB = 1)
0x7FFFFFxxxxxx = Max positive (~127 in Q24.24)
0xA74FE614 = -1,488,003,564 (OVERFLOW!)
```

### Quick Conversion
```
Decimal → Real (Q24.24): value / 16,777,216
Example: 847194280 / 16777216 = 50.497 m
```

---

## Comparing with Baseline

### Save Known Good Output
```bash
# After fixing the issue, save baseline
/home/arunupscee/vivado/2025.1/Vivado/bin/xsim ukf_5cycle_debug -R > baseline_5cycle.log
```

### Compare with New Run
```bash
# Run new test
/home/arunupscee/vivado/2025.1/Vivado/bin/xsim ukf_5cycle_debug -R > test_5cycle.log

# Extract key values for comparison
grep "sigma_z_pos\|p99_state" baseline_5cycle.log > baseline_summary.txt
grep "sigma_z_pos\|p99_state" test_5cycle.log > test_summary.txt

# Compare
diff baseline_summary.txt test_summary.txt
```

---

## Modifying Tests

### Change Number of Cycles
Edit the testbench file:
```vhdl
constant NUM_CYCLES : integer := 5;  -- Change to desired number
```

Add corresponding measurements to arrays (extract from CSV).

### Add More Measurements
Extract from `synthetic_drone_500cycles.csv`:
```bash
# Get cycles 10-14 (Q24.24 values)
head -16 test_data/real_world/synthetic_drone_500cycles.csv | tail -5 | \
  awk -F, '{print "to_signed(" $14 ", 48),  -- Cycle", NR+9, ":", $12, "m"}'
```

Paste into `meas_x_data`, `meas_y_data`, `meas_z_data` arrays.

### Change Timeout
```vhdl
constant MAX_WAIT_CYCLES : integer := 100000;  -- Increase if needed
```

---

## Common Issues

### Compilation Error: "character with value 0x83 is not a graphic literal character"
**Cause:** Unicode characters (like σ) not supported by VHDL
**Fix:** Replace with ASCII (e.g., "sigma_" instead of "σ_")

### Timeout at Specific Cycle
**Cause:** UKF stuck in infinite loop (e.g., matrix inversion failure)
**Check:**
```bash
grep "Timeout waiting for done" 5cycle_debug.log
```
**Debug:** Increase timeout or check for division by zero in module logs

### Values All Zero
**Cause:** UKF not initialized properly
**Check:**
```bash
grep "INIT_STATE\|first_cycle" 5cycle_debug.log
```
**Fix:** Verify reset timing in testbench

---

## Performance

| Test | Cycles | Runtime | Log Size | Lines |
|------|--------|---------|----------|-------|
| 5-cycle | 5 | ~1 sec | 121 KB | 1,630 |
| 10-cycle | 10 | ~2 sec | ~240 KB | ~3,200 |
| 500-cycle | 500 | ~11 sec | 5.8 MB | 99,000 |

**Speedup:** 5-cycle test is **100× faster** than 500-cycle test.

---

## Tips

1. **Always check for Cholesky failures first**
   ```bash
   grep "Cholesky PSD failure" *.log
   ```

2. **Track P99 to catch overflow early**
   ```bash
   grep "p99_state" *.log | awk '{print $NF}'
   ```

3. **Use hex to spot wraparound**
   - Negative values start with `0xF...`
   - Large positive near overflow: `0x7F...`

4. **Save logs after each fix**
   ```bash
   cp 5cycle_debug.log 5cycle_debug_fix1.log
   ```

5. **Automate regression tests**
   ```bash
   # Create test script
   #!/bin/bash
   xsim ukf_5cycle_debug -R > test.log 2>&1
   if grep -q "Cholesky PSD failure" test.log; then
       echo "FAIL: Overflow detected"
       exit 1
   fi
   echo "PASS: No overflow"
   exit 0
   ```

---

## Next Steps After Running Tests

1. **If overflow detected (P99 negative):**
   - Check cycle before overflow (e.g., cycle 3 if cycle 4 overflows)
   - Log intermediate values in `covariance_reconstruct_3d.vhd`
   - Check sigma point deltas in `sigma_3d.vhd`

2. **If no overflow (test passes):**
   - Run extended test (10-cycle or more)
   - Compare with baseline output
   - Test on other datasets (vehicle, aircraft)

3. **To investigate root cause:**
   - Add logging to `state_update_3d.vhd` (Kalman gain K)
   - Add logging to `innovation_covariance_3d.vhd` (innovation S)
   - Add logging to `cross_covariance_3d.vhd` (cross-covariance Pxz)

---

## Related Files

- **Test Data:** `/test_data/real_world/synthetic_drone_500cycles.csv`
- **Results:** `DEBUG_TESTBENCH_RESULTS.md`
- **UKF Top-Level:** `/ca_ukf.srcs/sources_1/new/ukf_supreme_3d.vhd`

---

## Contact / Issues

If tests produce unexpected results:
1. Check MEMORY.md for known issues
2. Review DEBUG_TESTBENCH_RESULTS.md for expected behavior
3. Compare with baseline 500-cycle test output
