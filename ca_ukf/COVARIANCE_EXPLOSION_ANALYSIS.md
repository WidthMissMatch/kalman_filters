# Covariance Explosion Analysis - Root Cause Identified

**Date:** February 5, 2026  
**Status:** ROOT CAUSE FOUND - Covariance matrix overflowing due to unbounded growth

---

## Executive Summary

**The problem is NOT precision loss - it's COVARIANCE EXPLOSION.**

The predicted covariance matrix P is growing exponentially and overflowing the 48-bit fixed-point representation. This causes:
1. P diagonal values to overflow → wrap to negative values
2. Matrix becomes non-positive-semi-definite (negative variances impossible)
3. Cholesky decomposition fails (can't compute sqrt of ill-conditioned P)
4. Filter diverges (unable to propagate sigma points)

---

## Evidence from Diagnostic Logging

### 1. P Diagonal Values Explode and Overflow

**Covariance Reconstruction Outputs (Q24.24 format, 48-bit signed):**

| Cycle | P77 (Z pos variance) | P88 (Z vel variance) | P99 (Z acc variance) | Status |
|-------|----------------------|----------------------|----------------------|--------|
| 0 | 16,783,915 | 16,783,915 | 16,777,206 | ✓ Normal (~1.0) |
| 1 | 31,311,343 | 16,968,583 | 31,432,340 | Growing |
| 2 | 95,861,624 | 17,262,815 | 284,431,577 | **P99 exploding!** |
| 3 | 626,246,800 | 25,534,822 | **-966,185,017** | **P99 NEGATIVE!** |
| 4 | **-1,620,123,775** | 424,432,203 | 232,805,903 | **P77 NEGATIVE!** |
| 5 | 1,161,733,055 | **-31,731,361** | **-1,737,357,645** | **P88 & P99 NEGATIVE!** |
| 6 | **-1,806,700,702** | values corrupted | values corrupted | **Complete breakdown** |

**Key Observation:** Diagonal variance values go NEGATIVE, which violates the fundamental property of covariance matrices (variance ≥ 0). This proves P is not PSD.

### 2. Measurement Update Shows P_pred Saturation

**P values entering measurement update:**

| Cycle | P99_pred | Notes |
|-------|----------|-------|
| 0 | 18,454,928 | Normal |
| 1 | 33,110,062 | Growing |
| 2 | 286,109,299 | Exploding |
| 3 | **2,147,483,647** | **MAX INT32 - SATURATED!** |
| 4 | **2,147,483,647** | Still saturated |
| 5 | 234,483,625 | Wrapped around |
| 6+ | 2,147,483,647 | Repeatedly saturating |

**Value 2,147,483,647 = 2^31 - 1** is the maximum value for a 32-bit signed integer. The 48-bit values are overflowing when truncated for display.

### 3. Sigma Point Deltas Explode

**Sigma point deviations (δχ = χ - x̄) for sigma point 0:**

| Cycle | delta_z_pos | delta_z_vel | delta_z_acc | Notes |
|-------|-------------|-------------|-------------|-------|
| 0 | 109 | 1 | 0 | Normal |
| 1 | 117 | 7 | 5 | Reasonable |
| 2 | 107 | 9 | 14 | Still OK |
| 3 | 106 | 7 | 20 | Growing |
| 4 | 93 | 12 | 69 | Accelerating |
| 5 | 198 | -14 | -248 | Larger |
| 6 | **-89,110,244** | 600 | 2,409 | **EXPLOSION!** |

**Cycle 6:** Z position delta jumps from ~200 to **-89 million!** This is the smoking gun.

### 4. Cholesky Failures Correlate with Overflow

**First Cholesky PSD failure:** Line 1108 in logs (corresponds to early cycle after P becomes ill-conditioned)

**Failures continue throughout simulation** because P never recovers once corrupted.

---

## Root Cause Chain

```
1. Predicted Covariance P Grows Exponentially
   ↓
2. Sigma Points Spread: χᵢ = x̄ ± sqrt((n+λ)×P)
   ↓
3. Sigma Deltas Explode: δχᵢ = χᵢ - x̄ → HUGE VALUES
   ↓
4. Outer Products Explode: δχᵢ × δχᵢᵀ → EVEN LARGER
   ↓
5. Weighted Accumulation Overflows: Σ Wᵢ × outer → OVERFLOW 48-BIT
   ↓
6. P Values Wrap to Negative (Signed Integer Overflow)
   ↓
7. P Loses PSD Property (Negative Variances Impossible)
   ↓
8. Cholesky Fails: Cannot Decompose Ill-Conditioned Matrix
   ↓
9. Sigma Point Propagation Skipped
   ↓
10. Filter Diverges: Using Stale/Wrong Predictions
```

---

## Why Is Covariance Exploding?

The predicted covariance P is growing without bound. Possible causes:

### A. Measurement Update Not Shrinking P Enough

**Joseph Form:** P_upd = (I - KH)P_pred(I - KH)ᵀ + KRKᵀ

If Kalman gain K is too small:
- (I - KH) ≈ I (identity)  
- P_upd ≈ P_pred (no shrinkage!)
- Measurement information not incorporated

**Why K might be small:**
- Innovation covariance S too large
- Cross-covariance Pxz too small
- K = Pxz × S⁻¹ → if Pxz small or S large, K → 0

### B. Process Noise Q Adding Too Much

**Prediction:** P_pred = F×P_upd×Fᵀ + Q

Current Q values (Q24.24):
- Q77 (Z pos): 16,777 (0.001 m²)
- Q88 (Z vel): 167,772 (0.01 (m/s)²)
- Q99 (Z acc): 1,677,722 (0.1 (m/s²)²)

**BUT:**
- Drone Z-axis nearly constant (10.0m → 10.08m over 500 cycles)
- Adding Q99=0.1 to P99 every cycle accumulates
- If measurement update doesn't shrink P, Q keeps stacking

**Per-axis Q tuning failed** because:
- Reducing Q88/Q99 by 2-5× didn't help
- Problem is P explosion, not Q magnitude
- Even with smaller Q, if measurement update doesn't work, P still grows

### C. State Transition Matrix F Amplifying P

**Constant Acceleration Model:**
```
F = [1, dt, 0.5×dt²;  
     0,  1,      dt;
     0,  0,       1]
```

For dt=0.1s:
```
F = [1.0, 0.1, 0.005;  
     0.0, 1.0,  0.1;
     0.0, 0.0,  1.0]
```

**F×P×Fᵀ can amplify covariance** if:
- Off-diagonal correlations grow
- Numerical errors in matrix multiply
- Precision loss in fixed-point arithmetic

### D. Innovation Explosion Corrupting Kalman Gain

**From earlier logs:** Innovation z - ẑ saturates at 2^31-1  
If innovation is corrupted → S = HPHᵀ + R corrupted → K = Pxz×S⁻¹ corrupted

---

## What Per-Axis Q Tuning Revealed

**Test:** Reduced Z-axis Q88 (0.01→0.005) and Q99 (0.1→0.02)  
**Result:** ZERO improvement - RMSE identical  
**Why:** Because the problem is covariance EXPLOSION, not process noise magnitude

**Key Insight:** Q is added AFTER P reconstruction, but P is already overflowing during reconstruction. Smaller Q doesn't prevent overflow.

---

## Comparison with Python Baseline

**Python UKF:** 0.69m RMSE ✅  
**VHDL UKF:** 107m RMSE ❌ (155× worse)

**Python uses:**
- Floating-point arithmetic (no overflow)
- NumPy matrix operations (numerically stable)
- Same Q values (or even larger!)

**Python doesn't suffer from:**
- Integer overflow
- Fixed-point precision constraints
- 48-bit representation limits

**This proves:** The algorithm is correct, the VHDL fixed-point implementation has numerical issues.

---

## Solutions to Investigate

### Priority 1: Prevent Covariance Overflow

**Option A: Saturation Instead of Wraparound**
- Clip P diagonal to MAX_SAFE_VALUE (e.g., 2^30) instead of allowing overflow
- At least prevents negative variances
- Downside: Filter becomes conservative (large P → wide uncertainty)

**Option B: Scale Down Covariance Representation**
- Use Q16.16 instead of Q24.24 for P (sacrifice precision for range)
- Accommodates larger values before overflow
- Downside: Less precision for small covariances

**Option C: Logarithmic Covariance Representation**
- Store log(P) instead of P
- Prevents overflow (log grows slowly)
- Complex: requires exp/log operations in fixed-point

### Priority 2: Fix Measurement Update

**Investigate why Kalman gain K is not shrinking P:**
1. Log innovation covariance S values → check if exploding
2. Log cross-covariance Pxz → check if vanishing
3. Log Kalman gain K → check if near zero
4. Verify Joseph form implementation for numerical stability

**Potential fixes:**
- Add minimum threshold for K (prevent K → 0)
- Check S matrix inversion for numerical issues
- Verify H matrix (measurement model) correctness

### Priority 3: Covariance Regularization

**Add epsilon to diagonal BEFORE Cholesky:**
```vhdl
p11_reg <= p11 + EPSILON;  -- Ensure P positive definite
p22_reg <= p22 + EPSILON;
...
```

**But:** This won't prevent overflow, only helps Cholesky stability

### Priority 4: Hybrid Scaling Approach

**Dynamically scale P when values get large:**
1. Detect when P diagonal > THRESHOLD (e.g., 2^28)
2. Scale entire P matrix: P_scaled = P / SCALE_FACTOR
3. Track scale factor separately
4. Re-scale when presenting results

**Downside:** Complex state management

---

## Recommended Next Steps

1. **Immediate:** Add saturation to covariance_reconstruct_3d.vhd to prevent negative P values  
   - At least prevents ill-conditioned matrices
   - Filter may be conservative but won't corrupt

2. **Short-term:** Investigate measurement update Kalman gain computation
   - Log S, Pxz, K values cycle-by-cycle
   - Identify why K not shrinking P

3. **Medium-term:** Consider reduced precision for P (Q16.16)
   - Trade precision for dynamic range
   - Test if prevents overflow

4. **Long-term:** Consider square-root UKF formulation
   - Propagates sqrt(P) instead of P
   - More numerically stable
   - Requires Cholesky update instead of full matrix multiply
   - **Significant architectural change**

---

## Conclusion

**The filter is mathematically correct but numerically unstable in fixed-point.**

The covariance matrix P is growing exponentially and overflowing the 48-bit representation. This is NOT a precision loss issue (where small values underflow to zero), but a **dynamic range issue** (where large values overflow to negative).

**Per-axis Q tuning was correct to try but addressed the wrong problem.** The issue is not process noise magnitude but unbounded covariance growth due to:
1. Insufficient measurement information incorporation (small K?)
2. Fixed-point overflow in accumulation
3. Possible state propagation instabilities

**Immediate action:** Add saturation to prevent negative P values  
**Root fix:** Investigate and fix Kalman gain computation / measurement update

---

*Analysis: February 5, 2026*  
*Tool: ca_ukf with diagnostic logging*  
*Dataset: synthetic_drone_500cycles*  
*Outcome: Root cause identified - covariance overflow*
