# CA_UKF - Constant Acceleration Unscented Kalman Filter

## Project Overview

VHDL implementation of a 9-state Unscented Kalman Filter (UKF) using a Constant Acceleration motion model for 3D position tracking.

**Status**: ✅ **FIXED AND WORKING** (Feb 4, 2026)
- Fixed critical covariance collapse bug
- Stable for 500+ cycles
- RMSE: 1.634m on drone dataset (2.4× Python baseline)

---

## Folder Structure

```
ca_ukf/
├── docs/                          # Documentation
│   ├── README.md                  # Module reference (this file)
│   ├── CA_UKF_MODULES_REFERENCE.md # Detailed module documentation
│   ├── FIX_SUMMARY.md             # Bug fix documentation
│   ├── BEFORE_AFTER_COMPARISON.md # Performance comparison
│   └── FINAL_VALIDATION_REPORT.md # Validation results
│
├── src/                           # VHDL source modules (20 files)
│   ├── ukf_supreme_3d.vhd         # Top-level coordinator
│   ├── prediction_phase_3d.vhd    # Prediction wrapper
│   ├── measurement_update_3d.vhd  # Update wrapper
│   ├── predicti_ca3d.vhd          # Constant acceleration model
│   ├── covariance_reconstruct_3d.vhd # Covariance recovery (FIXED!)
│   ├── process_noise_3d.vhd       # Q matrix addition
│   ├── kalman_gain_3d.vhd         # Gain calculation
│   ├── state_update_3d.vhd        # Joseph form update
│   ├── cholesky_9x9.vhd           # 9×9 Cholesky decomposition
│   └── ... (11 more supporting modules)
│
├── testbenches/                   # VHDL testbenches
│   ├── ukf_real_synthetic_drone_500cycles_tb.vhd
│   └── ... (additional testbenches)
│
├── datasets/                      # Test datasets (symlink)
│   └── test_data/ → ../test_data
│
├── scripts/                       # Build and analysis scripts
│   └── ... (compilation scripts, Python analysis)
│
└── ca_ukf.srcs/                   # Vivado project structure
    ├── sources_1/new/             # Original source location
    └── sim_1/new/                 # Original testbench location
```

---

## Quick Start

### Compile and Simulate

```bash
cd /home/arunupscee/Desktop/xtortion/ca_ukf

# Compile all modules
/home/arunupscee/vivado/2025.1/Vivado/bin/xvhdl --work ca_ukf_lib \
  ca_ukf.srcs/sources_1/new/*.vhd

# Elaborate testbench
/home/arunupscee/vivado/2025.1/Vivado/bin/xelab -debug typical \
  ca_ukf_lib.ukf_real_synthetic_drone_500cycles_tb -s ca_drone_500_sim

# Run simulation
/home/arunupscee/vivado/2025.1/Vivado/bin/xsim ca_drone_500_sim --runall
```

### Calculate RMSE

```bash
python3 ../singers_model/calculate_rmse_drone.py vhdl_output_synthetic_drone_500cycles.txt
```

---

## System Specifications

### State Vector (9 elements)
```
[x_pos, x_vel, x_acc, y_pos, y_vel, y_acc, z_pos, z_vel, z_acc]
```

### Motion Model (Constant Acceleration)
```
x' = x + v·dt + 0.5·a·dt²
v' = v + a·dt
a' = a  (constant)
```

### Parameters
- **Fixed-point format**: Q24.24 (48-bit signed)
- **Sigma points**: 19 (2n+1 for n=9)
- **Time step**: dt = 0.1 seconds
- **Gamma**: 3.0 (sigma point spread)

### Tuned for Drone Tracking
- **Initial P0**: diag([50, 200, 5, ...]) m²
- **Process noise Q**: q_power = 56.25
  - Q_velocity = 0.00015 (m/s)²
  - Q_acceleration = 1.125 (m/s²)²
- **Measurement noise R**: diag([0.25, 0.25, 0.25]) m²

---

## Critical Bug Fix (Feb 4, 2026)

### The Problem
Covariance matrix collapsed from 50 m² to near-zero (2.8e-6 m²), causing filter divergence at cycle 21.

### Root Cause
**File**: `covariance_reconstruct_3d.vhd`, lines 426-478
**Bug**: Double shift in accumulation (72-bit total instead of 48-bit)

```vhdl
-- BEFORE (BROKEN)
acc_p11 <= acc_p11 + resize(shift_right(weighted_11, 2*Q), 56);

-- AFTER (FIXED)
acc_p11 <= acc_p11 + resize(shift_right(weighted_11, Q), 56);
```

### Results
| Metric | Before Fix | After Fix |
|--------|-----------|-----------|
| Cycles completed | 21 | 500 ✅ |
| 3D RMSE | ∞ (diverged) | 1.634 m ✅ |
| Covariance | 0 m² (collapsed) | 0.54 m² (stable) ✅ |

See `docs/FIX_SUMMARY.md` for complete details.

---

## Performance

### Drone Dataset (500 cycles)
- **3D RMSE**: 1.634 m
- **X/Y/Z RMSE**: 0.874 / 0.938 / 1.013 m
- **Max Error**: 3.821 m (cycle 69)
- **vs Python**: 2.4× baseline (excellent for fixed-point)
- **Stability**: ✅ Stable for all 500 cycles

### Computational Metrics
- **Latency**: ~200-250 clock cycles per filter iteration
  - Prediction: ~120 cycles
  - Measurement update: ~90 cycles
- **FPGA Resources**: Moderate (parallel processing used)

---

## Module Overview

### Top Level
- **ukf_supreme_3d**: FSM coordinator, manages state/covariance persistence

### Prediction Phase (6 modules)
1. **cholesky_9x9**: P = L·L^T decomposition (~100 cycles)
2. **sigma_3d**: Generate 19 sigma points (~4 cycles)
3. **predicti_ca3d**: Apply CA motion model (~4 cycles)
4. **predicted_mean_3d**: Weighted mean of sigma points
5. **covariance_reconstruct_3d**: Recover P from sigma points (~30 cycles) **[FIXED!]**
6. **process_noise_3d**: Add Q matrix (~1 cycle)

### Measurement Update (6 modules)
1. **measurement_mean_3d**: Predicted measurement from sigma points
2. **innovation_3d**: Residual ν = z - ẑ
3. **cross_covariance_3d**: Compute Pxz matrix
4. **innovation_covariance_3d**: Compute S = H·P·H^T + R
5. **kalman_gain_3d**: K = Pxz·S^(-1) with 3×3 inversion
6. **state_update_3d**: Joseph form P+ = (I-K·H)·P·(I-K·H)^T + K·R·K^T

See `docs/CA_UKF_MODULES_REFERENCE.md` for detailed FSM diagrams and math.

---

## When to Use ca_ukf

### Advantages
✅ Simpler tuning (3 direct Q parameters)
✅ Lower computational complexity
✅ Good for steady-state tracking
✅ Intuitive constant acceleration model

### Best Applications
- Highway vehicles (steady cruise)
- Drones in straight-line flight
- Ballistic trajectories
- Any target with nearly constant acceleration

### Comparison with singers_model
See `/home/arunupscee/Desktop/xtortion/CA_UKF_vs_SINGERS_COMPARISON.md`

---

## Key Files

| File | Purpose |
|------|---------|
| `docs/CA_UKF_MODULES_REFERENCE.md` | Complete module documentation |
| `docs/FIX_SUMMARY.md` | Bug fix details and validation |
| `docs/BEFORE_AFTER_COMPARISON.md` | Performance before/after fix |
| `src/ukf_supreme_3d.vhd` | Top-level entry point |
| `src/covariance_reconstruct_3d.vhd` | Critical bug fix location |
| `testbenches/ukf_real_synthetic_drone_500cycles_tb.vhd` | Main testbench |

---

## References

- **Working directory**: `/home/arunupscee/Desktop/xtortion/ca_ukf/`
- **Vivado version**: 2025.1
- **Related project**: `../singers_model/` (Singer's motion model variant)
- **Comparison doc**: `../CA_UKF_vs_SINGERS_COMPARISON.md`

---

## Status History

- **Dec 27, 2025**: Initial implementation
- **Jan 5, 2026**: Validation on F1 datasets
- **Feb 4, 2026**: **BUG FIXED** - Covariance collapse resolved
- **Feb 4, 2026**: Tuned for drone tracking (Q, P0 parameters updated)
- **Feb 4, 2026**: ✅ **Production ready** - 500 cycles stable, RMSE 1.634m

---

Last updated: February 4, 2026
