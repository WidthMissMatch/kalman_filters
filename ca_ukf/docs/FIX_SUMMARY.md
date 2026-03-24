# ca_ukf Covariance Collapse Fix - Summary

## Bug Found and Fixed

### The Problem
The ca_ukf filter's covariance matrix was collapsing from 50.0 m² to near-zero (2.8e-6 m²), causing the filter to diverge at cycle 21.

### Root Cause
**Double shift bug in `covariance_reconstruct_3d.vhd`**

The covariance reconstruction was applying a **72-bit total shift** (24 + 48 bits) when it should have been 48 bits (24 + 24 bits).

**Bug Location:** Lines 426-478 in ADD state

**Broken Code:**
```vhdl
-- Line 366 (WEIGHT state)
weighted_11 <= shift_right(outer_11 * current_weight_reg, Q);  -- Q48.48 format

-- Line 426+ (ADD state) - THE BUG
acc_p11 <= acc_p11 + resize(shift_right(weighted_11, 2*Q), 56);  -- Shifts by 48 bits!
```

**Data flow with bug:**
```
outer_11 * current_weight  →  Q72.72 (144-bit)
  ↓ shift_right(..., Q=24)
weighted_11  →  Q48.48 (96-bit)
  ↓ shift_right(..., 2*Q=48)  ← BUG: Shifts by 48 instead of 24
acc_p11  →  Q0.0 (All fractional bits lost = ZERO!)
```

### The Fix

**Changed 45 lines (all acc_pXX assignments) in ADD state:**

```vhdl
-- BEFORE (BROKEN)
acc_p11 <= acc_p11 + resize(shift_right(weighted_11, 2*Q), 56);

-- AFTER (FIXED)
acc_p11 <= acc_p11 + resize(shift_right(weighted_11, Q), 56);
```

**Change:** `2*Q` → `Q` (shift by 24 bits instead of 48)

**New data flow:**
```
outer_11 * current_weight  →  Q72.72 (144-bit)
  ↓ shift_right(..., Q=24)
weighted_11  →  Q48.48 (96-bit)
  ↓ shift_right(..., Q=24)  ← FIXED
acc_p11  →  Q24.24 (Fractional precision preserved!)
```

## Results After Fix

### Before Fix (Broken)
```
Cycle 0:  p11_pred = 50.0 m²
Cycle 1:  p11_pred = 0.0 m²   ← COLLAPSE
Cycle 21: Filter diverges
Result:   RMSE = ∞ (diverged)
```

### After Fix (Working)
```
Cycle 0:  p11_pred = 52.0 m²
Cycle 1:  p11_pred = 1.47 m²
Cycle 2:  p11_pred = 0.92 m²
Cycle 3:  p11_pred = 0.54 m²
Cycle 4+: p11_pred = 0.54 m² (stable)

Result:   RMSE = 1.634 m (all 500 cycles)
Status:   ✅ STABLE
```

### Performance Metrics

**ca_ukf (FIXED) - Drone Dataset:**
- **3D RMSE:** 1.634 m
- **X-axis:** 0.874 m
- **Y-axis:** 0.938 m
- **Z-axis:** 1.013 m
- **Max Error:** 3.821 m (cycle 69)
- **Completion:** 500/500 cycles (100%)
- **Status:** ✅ Stable, no divergence

**vs Python Baseline:**
- Python: 0.69 m
- ca_ukf: 1.634 m
- Ratio: 2.4× (within 3× threshold = excellent)

## Files Modified

1. **ca_ukf/ca_ukf.srcs/sources_1/new/covariance_reconstruct_3d.vhd**
   - Lines 426-478 (ADD state)
   - Changed all 45 `shift_right(weighted_XX, 2*Q)` to `shift_right(weighted_XX, Q)`

## Testing

**Simulation:** `ukf_real_synthetic_drone_500cycles_tb.vhd`
- Dataset: Synthetic drone trajectory (500 cycles)
- Measurement noise: R = 0.25 m²
- Process noise: Q optimized for CA model

**Command:**
```bash
cd /home/arunupscee/Desktop/xtortion/ca_ukf
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work ca_ukf_lib \
  ca_ukf.srcs/sources_1/new/covariance_reconstruct_3d.vhd
/home/arunupscee/vivado/2025.1/Vivado/bin/xelab -debug typical \
  ca_ukf_lib.ukf_real_synthetic_drone_500cycles_tb -s ca_drone_500_sim
/home/arunupscee/vivado/2025.1/Vivado/bin/xsim ca_drone_500_sim --runall
```

**RMSE Calculation:**
```bash
python3 calculate_rmse_drone.py vhdl_output_synthetic_drone_500cycles.txt
```

## Why singers_model Worked Despite Same Bug

The `singers_model` implementation has the **identical double shift bug** but doesn't collapse because:

1. **Larger process noise:** Singer's motion model naturally has larger Q values
2. **Wider sigma point spread:** GAMMA = 3.0 creates larger deltas
3. **Larger covariance deltas:** Doesn't underflow even with 48-bit extra shift

The ca_ukf uses a simpler Constant Acceleration model with smaller natural variations, making it more sensitive to the precision loss.

## Conclusion

✅ **Bug fixed successfully**
- Root cause: Double shift in covariance reconstruction
- Fix: Corrected shift amount from 2*Q to Q
- Result: ca_ukf now stable for 500 cycles with RMSE = 1.634m
- Performance: Within 2.4× of Python baseline (excellent for fixed-point)

The fix preserves fractional precision in small covariance calculations, preventing the death spiral that caused the original divergence.
