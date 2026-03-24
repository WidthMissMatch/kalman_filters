# Per-Axis Q Tuning Analysis - ca_ukf

## Objective
Test whether reducing Z-axis process noise (Q88, Q99) improves filter stability on drone dataset where Z-axis has near-constant altitude (10.0m → 10.08m over 500 cycles).

## Configuration Changes Applied

### Option A: Conservative Reduction
**File:** `ca_ukf.srcs/sources_1/new/process_noise_3d.vhd`

| Parameter | Before | After | Reduction |
|-----------|--------|-------|-----------|
| Q77 (Z pos) | 16777 (0.001 m²) | 16777 (0.001 m²) | None |
| Q88 (Z vel) | 167772 (0.01 (m/s)²) | 83886 (0.005 (m/s)²) | 2× |
| Q99 (Z acc) | 1677722 (0.1 (m/s²)²) | 335544 (0.02 (m/s²)²) | 5× |

**Safety Verification:**
- Q88: 83886 / 64 (MIN_POSITIVE) = 1310× safety margin ✓
- Q99: 335544 / 64 (MIN_POSITIVE) = 5243× safety margin ✓
- Far above Cholesky decomposition numerical threshold

## Results

### Baseline (Before Tuning)
```
3D RMSE:     106.993 m
X-axis RMSE:  57.607 m
Y-axis RMSE:  20.241 m
Z-axis RMSE:  87.859 m
Divergence:   Cycle 7 (Z: 10.06m → 117.12m)
```

### Option A (After Conservative Q Tuning)
```
3D RMSE:     106.993 m (IDENTICAL)
X-axis RMSE:  57.607 m (IDENTICAL)
Y-axis RMSE:  20.241 m (IDENTICAL)
Z-axis RMSE:  87.859 m (IDENTICAL)
Divergence:   Cycle 7 (Z: 10.06m → 117.12m) (IDENTICAL)
```

**Improvement:** 0.0% - NO CHANGE WHATSOEVER

## Root Cause Analysis

### Why Q Tuning Had Zero Effect

**Critical Finding:** Simulation logs show repeated Cholesky decomposition failures:
```
Warning: ERROR: Cholesky PSD failure - P matrix ill-conditioned, skipping prediction update
```

These failures occur at lines 986, 1411, 1836, 2261... throughout the simulation.

**What This Means:**
1. The predicted covariance matrix P becomes ill-conditioned BEFORE Q noise is added
2. Cholesky decomposition fails because P is not positive semi-definite (PSD)
3. When Cholesky fails, the filter skips the sigma point propagation
4. Without sigma point updates, the filter cannot track the measurements
5. The filter diverges regardless of Q values

**Key Insight:** The problem is NOT process noise magnitude. The problem is that P itself becomes numerically unstable during:
- Covariance reconstruction (P = W × outer_product(sigma_deltas))
- Measurement update (P = (I - K×H)P)
- Or both

### Evidence from Simulation Output

**Cycle 6 (Last good cycle):**
- Z estimate: 18.68m (error: 8.64m)
- Still tracking, no massive divergence

**Cycle 7 (Divergence):**
- Z estimate: 117.12m (error: 107.07m)
- Massive jump indicates Cholesky failure → no sigma point update → filter uses wrong prediction

The Z-axis spike from 18.68m → 117.12m is NOT due to excessive process noise. It's due to the filter's inability to propagate uncertainty because the covariance matrix has become ill-conditioned.

## Conclusion

**Per-axis Q tuning approach: FAILED**

**Reason:** Not effective when the root cause is numerical instability in covariance propagation, not process noise magnitude.

**Recommendation:** Abandon Q-based approaches. The problem requires:

1. **Fixing covariance reconstruction:** Investigate `covariance_reconstruct_3d.vhd` for numerical precision loss
2. **Improving measurement update:** Check `state_update_3d.vhd` Joseph form covariance update
3. **Verifying sigma point deltas:** Ensure sigma_deltas don't underflow in fixed-point arithmetic
4. **Adding covariance conditioning:** Implement regularization (add small diagonal terms) to prevent ill-conditioning

## Next Steps

**DO NOT proceed with:**
- Singers_model Q tuning (same root cause expected)
- More aggressive Q reductions (Option B)
- R-matrix tuning (won't fix P ill-conditioning)

**DO investigate:**
- Why P matrix becomes ill-conditioned at cycle ~5-7
- Whether sigma point deltas are too small in fixed-point Q72.72 format
- Whether outer product computation in `covariance_reconstruct_3d.vhd` loses precision
- Whether measurement update's P propagation needs regularization

**Status:** Conservative Q tuning numerically safe but INEFFECTIVE. Root problem is deeper in covariance propagation pipeline.

---
*Generated: Feb 5, 2026*
*Test: ca_ukf on synthetic_drone_500cycles dataset*
*Outcome: No improvement, Cholesky PSD failures detected*
