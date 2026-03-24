# CA_UKF MODULES REFERENCE

## Unscented Kalman Filter (UKF) for 3D Constant Acceleration Tracking

**System**: 9-state constant acceleration model with 3D position measurements
- State Vector (9 elements): [x_pos, x_vel, x_acc, y_pos, y_vel, y_acc, z_pos, z_vel, z_acc]
- Measurements (3 elements): [z_x, z_y, z_z] (position only)
- Sigma Points: 19 points (1 mean + 9 positive + 9 negative perturbations)
- Fixed-Point Format: Q24.24 (24 integer bits, 24 fractional bits)
- Time Step: dt = 100ms (0.1 seconds)

---

## Module Summary Table

| Module | Purpose | Latency | Critical Operation |
|--------|---------|---------|-------------------|
| ukf_supreme_3d | Top-level coordinator | 200-250 cycles | State management |
| prediction_phase_3d | Prediction wrapper | 120-150 cycles | Cholesky |
| measurement_update_3d | Update wrapper | 90-100 cycles | Matrix operations |
| sigma_3d | Sigma point generation | 4-5 cycles | Vector addition |
| predicti_ca3d | CA motion model | 4-5 cycles | Kinematics |
| covariance_reconstruct_3d | Covariance recovery | 25-35 cycles | Outer product |
| process_noise_3d | Q addition | 1-2 cycles | Diagonal add |
| kalman_gain_3d | Gain calculation | 25-30 cycles | 3×3 inversion |
| state_update_3d | State/cov update | 35-50 cycles | Joseph form |
| cholesky_9x9 | Cholesky decomp | 90-110 cycles | CORDIC sqrt |

---

## System Parameters

### Fixed-Point Format: Q24.24
- **Range**: ±8,388,608.0
- **Precision**: 2^(-24) ≈ 6.0e-8
- **1.0 in Q24.24**: 16,777,216

### UKF Parameters
- **State dimension**: n = 9
- **Sigma points**: 2n+1 = 19
- **Gamma (spread)**: γ = √9 = 3.0
- **Weights**: W0 = 2.0, Wi = 1/18 (i=1..18)

### Tuned for Drone Tracking (Feb 4, 2026)
- **Initial P0**: diag([50, 200, 5, 50, 200, 5, 50, 200, 5]) m²
- **Process noise Q**: q_power = 56.25, dt = 0.02
  - Q22, Q55, Q88 = 0.00015 (velocity)
  - Q33, Q66, Q99 = 1.125 (acceleration)
- **Measurement noise R**: diag([0.25, 0.25, 0.25]) m²

---

## Module Details

[Full module documentation continues in original format...]

---

## Fixed Bug (Feb 4, 2026)

### Covariance Reconstruction Double Shift
**File**: covariance_reconstruct_3d.vhd, lines 426-478
**Bug**: shift_right(weighted_XX, 2*Q) → Total 72-bit shift instead of 48-bit
**Fix**: shift_right(weighted_XX, Q) → Correct 48-bit shift
**Impact**: Fixed covariance collapse causing divergence at cycle 21

See FIX_SUMMARY.md for complete details.

---

Document generated from source analysis of ca_ukf/ca_ukf.srcs/sources_1/new/
