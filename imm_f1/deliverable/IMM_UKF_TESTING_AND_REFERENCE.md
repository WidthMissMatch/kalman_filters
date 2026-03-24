# IMM-UKF F1 Filter: Complete Reference and Testing Guide

## Overview

The **Interacting Multiple Model (IMM)** filter combines three parallel Unscented Kalman Filters (UKF) with Bayesian model switching for robust 3D position tracking. All arithmetic is **Q24.24 fixed-point** (signed 48-bit: 24 integer bits, 24 fractional bits).

### Three Motion Models

| Model | States | Sigma Points | Description |
|-------|--------|--------------|-------------|
| **CA (Constant Acceleration)** | 9 [px,py,pz,vx,vy,vz,ax,ay,az] | 19 | Best for straight-line or gentle curves |
| **Singer** | 9 [px,py,pz,vx,vy,vz,ax,ay,az] | 19 | Best for manoeuvring targets (acceleration fading) |
| **Bicycle** | 7 [px,py,v,theta,delta,a,z] | 15 | Best for vehicle turns (wheelbase=3.6m) |

### IMM Pipeline (per measurement cycle)

```
Measurements (z_x, z_y, z_z)
        |
   [State Mixing]        -- Blend states using transition matrix
   [Covariance Mixing]   -- Blend covariances + spread-of-means
        |
   +---------+---------+
   |         |         |
  CA UKF   Singer    Bicycle   -- All 3 run in PARALLEL
   |         |         |
   +---------+---------+
        |
   [Likelihood]          -- Gaussian innovation likelihood per model
   [Probability Update]  -- Bayesian update with Markov transitions
   [Output Fusion]       -- Weighted sum of model outputs
        |
   Fused output (px_out, py_out, pz_out, probabilities)
```

**Clocks per cycle:** ~1500 at 100 MHz (15 us per measurement)

---

## Directory Structure

```
deliverable/
  src/
    shared/               -- Math utilities (3 files)
      sqrt_cordic.vhd          -- CORDIC-based square root
      sin_cos_cordic.vhd       -- CORDIC-based sin/cos
      matrix_inverse_3x3.vhd   -- 3x3 matrix inversion
    ca_ukf/               -- Constant Acceleration UKF (19 files)
      cholsky_9.vhd            -- 9x9 Cholesky decomposition
      cholesky_multiplier_array.vhd
      cholesky_col2..5_parallel.vhd  -- Parallel Cholesky columns
      cholesky_col678_parallel.vhd
      sigma_3d.vhd             -- 9D sigma point generation
      predicti_ca3d.vhd        -- CA state transition model
      prediction_phase_3d.vhd  -- Prediction phase orchestrator
      process_noise_3d.vhd     -- CA process noise Q matrix
      predicted_mean_3d.vhd    -- Weighted mean of predicted sigma pts
      covariance_reconstruct_3d.vhd  -- Predicted covariance P_pred
      measurement_mean_3d.vhd  -- Measurement sigma point mean
      innovation_3d.vhd        -- Innovation (z - z_hat)
      innovation_covariance_3d.vhd   -- S = H*P*H^T + R
      cross_covariance_3d.vhd  -- P_xz cross-covariance
      kalman_gain_3d.vhd       -- K = P_xz * S^{-1}
      state_update_3d.vhd      -- x_upd = x_pred + K*nu (144-bit precision)
    singer_ukf/           -- Singer UKF (4 files)
      singer_exp_cordic.vhd         -- Exponential via CORDIC (e^{-alpha*dt})
      singer_process_noise_singer_p_3d.vhd  -- Singer process noise
      predicti_singer3d.vhd         -- Singer state transition
      prediction_phase_p_3d.vhd     -- Singer prediction orchestrator
    bicycle_ukf/          -- Bicycle UKF (10 files)
      cholesky_7x7.vhd        -- 7x7 Cholesky decomposition
      sigma_7d.vhd             -- 7D sigma point generation
      predicti_bicycle.vhd     -- Bicycle kinematic model
      predicted_mean_7d.vhd    -- 7D predicted mean
      predicted_covariance_7d.vhd   -- 7D predicted covariance
      process_noise_bicycle.vhd     -- Bicycle process noise
      innovation_covariance_7d.vhd  -- 7D innovation covariance
      cross_covariance_7d.vhd -- 7D cross-covariance
      kalman_gain_7d.vhd       -- 7D Kalman gain
      state_update_7d.vhd      -- 7D state update
    imm/                  -- IMM framework (15 files)
      imm_f1_top.vhd          -- TOP-LEVEL: master FSM controller
      ca_ukf_supreme_imm.vhd  -- CA UKF wrapper (IMM-compatible)
      singer_ukf_supreme_imm.vhd   -- Singer UKF wrapper
      bicycle_ukf_supreme_imm.vhd  -- Bicycle UKF wrapper
      ca_measurement_update_imm.vhd -- CA measurement update
      singer_measurement_update_imm.vhd -- Singer measurement update
      state_mapper_9d_to_7d.vhd     -- 9D -> 7D state mapping
      state_mapper_7d_to_9d.vhd     -- 7D -> 9D state mapping
      imm_state_mixer.vhd     -- State mixing with mu weights
      imm_covariance_mixer.vhd -- Covariance mixing + spread-of-means
      imm_likelihood.vhd       -- Gaussian likelihood computation
      imm_prob_update.vhd      -- Bayesian probability update
      imm_output_fusion.vhd    -- Weighted output fusion
      exp_lut.vhd              -- Exponential lookup table
      log_lut.vhd              -- Logarithm lookup table
  testbench/
    imm_f1_10cycle_tb.vhd     -- 10-cycle hardcoded testbench (Monaco data)
  test_data/
    f1_monaco_2024_750cycles.csv       -- Monaco F1 ground truth + measurements
    f1_silverstone_2024_750cycles.csv  -- Silverstone F1 ground truth + measurements
    synthetic_drone_500cycles.csv      -- Synthetic drone trajectory
  results/
    yeah_raha.txt              -- Monaco 750-cycle VHDL output (hex)
    waha.txt                   -- Silverstone 750-cycle VHDL output (hex)
  scripts/
    run_vivado_sim.sh          -- Vivado xsim simulation runner
    analyze_vhdl_output.py     -- Parse hex output + compute RMSE
    compute_rmse.py            -- RMSE computation utility
```

**Total: 51 VHDL source files + 1 testbench**

---

## Individual Module Testing

### Shared Modules

| Module | Test Method | Key Checks |
|--------|-------------|------------|
| `sqrt_cordic.vhd` | Feed known squares (e.g., 4.0=0x04000000), verify output=2.0=0x02000000 | Precision within 1 LSB for values 0..1000 |
| `sin_cos_cordic.vhd` | Feed angles 0, pi/4, pi/2, pi; verify sin/cos outputs | Max error < 2^{-20} |
| `matrix_inverse_3x3.vhd` | Feed identity matrix, verify output=identity; feed known S, verify S^{-1}*S=I | Check for division-by-zero handling |

### CA UKF Modules (9-state, 19 sigma points)

| Module | Test Method | Key Checks |
|--------|-------------|------------|
| `cholsky_9.vhd` | Feed known positive-definite 9x9 P, verify L*L^T=P | Cholesky must use parallel col helpers; check diagonal>0 |
| `sigma_3d.vhd` | Feed mean + L matrix, verify 19 sigma points generated correctly | sigma[0]=mean, sigma[1..9]=mean+gamma*L_col, sigma[10..18]=mean-gamma*L_col |
| `predicti_ca3d.vhd` | Feed sigma points, verify x_{k+1} = F*x_k (constant accel model) | p += v*dt + 0.5*a*dt^2, v += a*dt, a = a |
| `prediction_phase_3d.vhd` | Integration: sigma gen -> propagation -> mean/cov reconstruction | Verify P_pred positive definite, mean tracks measurements |
| `innovation_3d.vhd` | Feed z_hat and z_meas, verify nu = z - z_hat | Widened to 49-bit to prevent overflow at >128m |
| `innovation_covariance_3d.vhd` | Verify S = sum(w_c * (Z_i - z_hat)*(Z_i - z_hat)^T) + R | R_DIAG = 0.25 (Q24.24: 0x00400000) |
| `state_update_3d.vhd` | Verify x_upd = x_pred + K*nu, P_upd = P_pred - K*S*K^T | Uses **144-bit precision** (Q72.72 intermediate) |

### Singer UKF Modules

| Module | Test Method | Key Checks |
|--------|-------------|------------|
| `singer_exp_cordic.vhd` | Feed alpha*dt, verify e^{-alpha*dt} | TAU=2.0, alpha=1/TAU=0.5 |
| `predicti_singer3d.vhd` | Singer transition: a(k+1) = e^{-alpha*dt} * a(k) | Acceleration exponentially decays |
| `singer_process_noise_singer_p_3d.vhd` | Verify Q matrix matches Singer model | Q_POS=0.08, Q_VEL=0.00025, Q_ACC=0.00001 |

### Bicycle UKF Modules (7-state, 15 sigma points)

| Module | Test Method | Key Checks |
|--------|-------------|------------|
| `cholesky_7x7.vhd` | Feed known 7x7 P, verify L*L^T=P | Smaller than 9x9 version |
| `predicti_bicycle.vhd` | Bicycle model: px += v*cos(theta)*dt, py += v*sin(theta)*dt | Wheelbase L=3.6m, lr=1.6m |
| `process_noise_bicycle.vhd` | Verify Q diagonal for 7 states | Conservative defaults |

### IMM Framework Modules

| Module | Test Method | Dedicated TB Available? |
|--------|-------------|------------------------|
| `imm_state_mixer.vhd` | Verify mu_ij = T_ij * prob_i / c_j, then x_mix = sum(mu_ij * x_i) | Yes: `tb_imm_state_mixer.vhd` |
| `imm_covariance_mixer.vhd` | Verify P_mix = sum(mu_ij * [P_i + (x_i - x_mix)*(x_i - x_mix)^T]) | Integrated test only |
| `imm_likelihood.vhd` | Feed innovation nu and S, verify L = exp(-0.5 * nu^T * S^{-1} * nu) / sqrt(det(S)) | Yes: `tb_imm_likelihood.vhd` |
| `imm_prob_update.vhd` | Verify prob_j_new = sum_i(T_ij * L_j * prob_i) / normalizer | Yes: `tb_imm_prob_update.vhd` |
| `imm_output_fusion.vhd` | Verify fused_x = sum(prob_j * x_j) | Yes: `tb_imm_output_fusion.vhd` |
| `state_mapper_9d_to_7d.vhd` | Map [px,py,pz,vx,vy,vz,ax,ay,az] -> [px,py,v,theta,delta,a,z] | Yes: `tb_state_mappers.vhd` |
| `exp_lut.vhd` / `log_lut.vhd` | Verify lookup accuracy for Q24.24 inputs | Yes: `tb_exp_log_lut.vhd` |

---

## IMM Top-Level Integration Testing

### Quick Smoke Test (10 cycles)

Use the included `imm_f1_10cycle_tb.vhd`:

```bash
# Compile order matters (dependencies must come first)
cd /path/to/deliverable

# Step 1: Compile sources
xvhdl --2008 src/shared/sqrt_cordic.vhd
xvhdl --2008 src/shared/sin_cos_cordic.vhd
xvhdl --2008 src/shared/matrix_inverse_3x3.vhd
# ... all ca_ukf, singer_ukf, bicycle_ukf, imm files ...
xvhdl --2008 testbench/imm_f1_10cycle_tb.vhd

# Step 2: Elaborate
xelab --debug typical -s imm_sim imm_f1_10cycle_tb

# Step 3: Run
echo "run all; quit" > run.tcl
xsim imm_sim -t run.tcl
```

**Or use the included script** (adapting paths):
```bash
bash scripts/run_vivado_sim.sh 10cycle
```

**Expected output** (`imm_10cycle_output.txt`):
```
Cycle 0: imm_x=0x0000007F28A8 imm_y=0xFFFFFF13A6FA imm_z=0x000000C742AA p_ca=0x000000800000 p_si=0x0000004CCCCD p_bi=0x000000333333
Cycle 1: imm_x=0x000006BF519C imm_y=0xFFFFFC920E69 imm_z=0xFFFFFF3E071C p_ca=0x000000028F5C p_si=0x000000028F5C p_bi=0x000000FAE148
...
Cycle 9: imm_x=0x00003CDC9CF5 imm_y=0xFFFFECA9C872 imm_z=0xFFFFFE91DD5E p_ca=0x000000028F5C p_si=0x000000FAE148 p_bi=0x000000028F5C
```

### Interpreting Output

**Position values** (Q24.24): Divide hex value by 2^24 (16777216) to get metres.
- `0x00003CDC9CF5` = 63.86 m (positive X)
- `0xFFFFECA9C872` = -19.34 m (negative Y, two's complement)

**Probabilities** (Q24.24): Sum should equal ~1.0 = 0x01000000.
- `p_ca=0x000000028F5C` = 0.01 (1% CA)
- `p_si=0x000000FAE148` = 0.98 (98% Singer)
- `p_bi=0x000000028F5C` = 0.01 (1% Bicycle)

### Markov Transition Matrix

```
T = | 0.97  0.02  0.01 |   (CA stays CA 97%, switches to Singer 2%, Bicycle 1%)
    | 0.02  0.95  0.03 |   (Singer stays Singer 95%)
    | 0.01  0.02  0.97 |   (Bicycle stays Bicycle 97%)
```

Initial probabilities: p_ca=0.5, p_singer=0.3, p_bicycle=0.2

---

## Full Dataset Testing

### Monaco F1 2024 (750 cycles)

```bash
bash scripts/run_vivado_sim.sh monaco
# Output: results/yeah_raha.txt
python3 scripts/analyze_vhdl_output.py results/yeah_raha.txt test_data/f1_monaco_2024_750cycles.csv
```

**Results:** RMSE = **1.91 m** over 750 cycles (15 seconds at dt=0.02s)

### Silverstone F1 2024 (750 cycles)

```bash
bash scripts/run_vivado_sim.sh silverstone
# Output: results/waha.txt
python3 scripts/analyze_vhdl_output.py results/waha.txt test_data/f1_silverstone_2024_750cycles.csv
```

**Results:** RMSE = **2.19 m** over 750 cycles

### Synthetic Drone (500 cycles)

```bash
bash scripts/run_vivado_sim.sh drone
# Output: results/imm_vhdl_drone.txt
```

### RMSE Summary Table

| Dataset | Cycles | VHDL RMSE | Python RMSE | Precision Gap |
|---------|--------|-----------|-------------|---------------|
| Monaco F1 2024 | 750 | **1.91 m** | 1.43 m | 34% |
| Silverstone F1 2024 | 750 | **2.19 m** | 1.50 m | 46% |
| Monaco (first 100) | 100 | **1.89 m** | 1.66 m | 14% |
| Silverstone (first 100) | 100 | **2.13 m** | 1.91 m | 11% |

The VHDL-Python gap increases over longer runs due to Q24.24 fixed-point truncation accumulating over 750 cycles. The 100-cycle gap (11-14%) is more representative of single-cycle precision.

---

## CSV Test Data Format

```
cycle,time,gt_x_pos,gt_y_pos,gt_z_pos,meas_x,meas_y,meas_z,meas_x_q24,meas_y_q24,meas_z_q24
0,0.000,0.496,-0.925,0.778,0.496,-0.925,0.778,8333481,-15423748,13058732
1,0.020,7.071,-3.590,-0.850,7.116,-3.603,-0.851,119443229,-60488091,-14269014
...
```

- Columns 2-4: Ground truth position (metres, float)
- Columns 5-7: Noisy measurements (metres, float)
- Columns 8-10: Measurements in Q24.24 integer (as fed to VHDL)

---

## Key Design Decisions

1. **144-bit intermediate precision** in `state_update_3d.vhd`: AP*AT and KR*KT computed in Q72.72, single shift at end. This reduced RMSE from 1.55m to 0.88m on drone data.

2. **Parallel filter execution**: All 3 UKFs start simultaneously in `INJECT_MIXED` state, saving ~2x latency vs sequential.

3. **Probability clamping**: Model probabilities clamped to [0.01, 0.98] to prevent any model from being permanently eliminated.

4. **Newton-Raphson reciprocal** in `imm_prob_update.vhd`: Used for normalizing probabilities (avoids hardware division).

5. **State mapping**: 9D-to-7D mapper converts [px,py,pz,vx,vy,vz,ax,ay,az] -> [px,py,speed,heading,steering,accel,z] using atan2 CORDIC for heading computation.

---

## Compilation Order

Sources must be compiled in dependency order. The `run_vivado_sim.sh` script handles this automatically. Manual order:

1. `shared/` (sqrt_cordic, sin_cos_cordic, matrix_inverse_3x3)
2. `ca_ukf/` (cholesky helpers -> cholsky_9 -> sigma_3d -> predicti/process_noise -> prediction_phase -> mean/cov/innovation -> kalman_gain -> state_update)
3. `singer_ukf/` (exp_cordic -> predicti_singer -> process_noise -> prediction_phase_p)
4. `bicycle_ukf/` (cholesky_7x7 -> sigma_7d -> predicti_bicycle -> predicted_mean/cov_7d -> process_noise -> innovation/cross_cov -> kalman_gain_7d -> state_update_7d)
5. `imm/` (mappers -> measurement_update wrappers -> ukf_supreme wrappers -> mixer/likelihood/prob_update/fusion -> imm_f1_top)
6. `testbench/` (imm_f1_10cycle_tb)

---

## Known Limitations

- Q24.24 integer range: +/-8388608 (~8388 km). F1 tracks stay well within range.
- Probability clamping at [1%, 98%] may slow model switching in borderline cases.
- Bicycle model assumes flat ground (z handled separately).
- No measurement dropout handling (assumes continuous measurements at dt=0.02s).
