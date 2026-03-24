# UKF Comprehensive Architecture & Results Reference

> **Date:** February 24, 2026
> **Format:** Q24.24 fixed-point (48-bit signed: 24 integer + 24 fractional bits)
> **Measurement Model:** All UKFs use 3D position-only measurements: H = [px, py, z]

---

## 1. Summary Table

| # | Model | States | Dim | Sigma Pts | Clocks/Cycle | Drone 500cy | Monaco 750cy | Silverstone 750cy |
|---|-------|--------|-----|-----------|--------------|-------------|--------------|-------------------|
| 1 | CA Standard | pos/vel/acc per axis | 9D | 19 | **600** (GHDL verified) | **0.882m** | -- | -- |
| 2 | Singer Standard | pos/vel/acc per axis | 9D | 19 | **638** (GHDL verified) | **0.995m** | -- | -- |
| 3 | CA SR-UKF | pos/vel/acc per axis | 9D | 19 | ~2000 (est.) | **0.934m** | -- | -- |
| 4 | Singer SR-UKF | pos/vel/acc per axis | 9D | 19 | ~1543 (est.) | **0.878m** | -- | -- |
| 5 | Bicycle | px,py,v,theta,delta,a,z | 7D | 15 | **780** (GHDL verified) | 1.22m | 20.5m | 24.3m |
| 6 | CTRA | px,py,v,theta,omega,a,z | 7D | 15 | ~780 (same arch as Bicycle) | ~1.2m | -- | -- |
| 7 | CT Polar | px,py,v,theta,omega,a,z,vz,az | 9D | 19 | **1543** (GHDL verified) | 1.325m | 18.87m | diverged |
| 8 | IMM F1 (CA+Singer+Bicycle) | 3-model fusion | -- | -- | ~900-1000 (est., bottleneck=Bicycle 780 + IMM overhead) | -- | **1.91m** | **2.19m** |
| 9 | IMM Friend (CTRA+Singer+Bicycle) | 3-model fusion | -- | -- | ~900-1000 (est., bottleneck=Bicycle 780 + IMM overhead) | -- | **1.78m** | -- |

> **Clock count verification method:** GHDL 4.1.0 simulation (`--std=08 --ieee=synopsys`), 3 UKF cycles with fixed measurements (10.0, 20.0, 5.0 Q24.24), counting rising edges from start pulse to done='1'. Cycle 2-3 are steady-state. **4 of 9 models verified** (CA Standard, Singer Standard, Bicycle, CT Polar). Remaining 5 could not compile in GHDL due to: (1) component-vs-entity port mismatches that Vivado auto-resolves (SR-UKFs, CTRA), (2) `when/else` conditional expressions in sequential context (CTRA `state_update_7d`), (3) IMM designs inherit sub-model binding issues.

---

## 2. CA Standard UKF (9D)

### 2.1 State Vector
```
x = [px, vx, ax, py, vy, ay, pz, vz, az]^T    (9 states)
```
- 3 axes (X, Y, Z) x 3 states (position, velocity, acceleration)
- 19 sigma points (2*9 + 1), gamma = 3.0

### 2.2 Motion Model (Constant Acceleration)
```
p' = p + v*dt + 0.5*a*dt^2
v' = v + a*dt
a' = a                         (acceleration held constant)
```
Applied identically to each axis. dt = 0.02s (50 Hz).

### 2.3 UKF Parameters

| Parameter | Value | Q24.24 |
|-----------|-------|--------|
| dt | 0.02 s | 335544 |
| Q_POS | 0.05 | -- |
| Q_VEL | 0.00025 | -- |
| Q_ACC | 0.00001 | -- |
| R (meas noise) | 0.25 | -- |
| P_INIT(pos) | 5.0 | 0x000005000000 |
| P_INIT(vel) | 20.0 | 0x000014000000 |
| P_INIT(acc) | 0.01 | 0x000000028F5C |

### 2.4 FSM States
```
IDLE -> INIT_STATE -> WAIT_INIT -> RUN_PREDICTION -> WAIT_PREDICTION
     -> RUN_UPDATE -> WAIT_UPDATE -> FINISHED -> IDLE
```
8 states. Two-phase pipeline: prediction_phase_3d then measurement_update_3d.

### 2.5 Clock Cycles
**600 clocks per output** (GHDL verified: all 3 cycles = 600 exactly).
- Init cycle also takes 600 (no separate fast-init path — prediction+update runs on first cycle too).

### 2.6 Key Modules
- `ukf_supreme_3d.vhd` (top-level FSM)
- `prediction_phase_3d.vhd` (prediction coordinator)
- `predicti_ca3d.vhd` (CA motion model, 19 sigma points)
- `cholsky_9.vhd` (9x9 Cholesky decomposition)
- `sigma_3d.vhd` (sigma point generation)
- `predicted_mean_3d.vhd` / `covariance_reconstruct_3d.vhd`
- `measurement_update_3d.vhd` (update coordinator)
- `innovation_3d.vhd` / `innovation_covariance_3d.vhd`
- `cross_covariance_3d.vhd` / `kalman_gain_3d.vhd`
- `state_update_3d.vhd` (Joseph-form, 144-bit precision)
- `matrix_inverse_3x3.vhd` / `sqrt_cordic.vhd`

### 2.7 RMSE Results
| Dataset | RMSE |
|---------|------|
| Drone 500cy | **0.882m** (sub-meter!) |

Key achievement: 144-bit precision in state_update_3d.vhd dropped RMSE from 1.55m to 0.882m.

---

## 3. Singer Standard UKF (9D)

### 3.1 State Vector
```
x = [px, vx, ax, py, vy, ay, pz, vz, az]^T    (9 states)
```
Same structure as CA but with Singer's correlated acceleration model.

### 3.2 Motion Model (Singer's Exponentially-Correlated Acceleration)
```
a' = a_mean + (a - a_mean) * exp(-dt/tau)
v' = v + (a - a_mean) * tau * (1 - exp(-dt/tau)) + a_mean * dt
p' = p + v*dt + (a - a_mean) * [dt - tau*(1 - exp(-dt/tau))] + a_mean * 0.5 * dt^2
```
- TAU (tau) = 2.0s — acceleration correlation time
- exp(-dt/tau) computed via CORDIC
- Acceleration decays exponentially toward a_mean

### 3.3 UKF Parameters

| Parameter | Value | Q24.24 |
|-----------|-------|--------|
| dt | 0.02 s | 335544 |
| TAU | 2.0 s | 33554432 |
| Q_POS | 0.08 | -- |
| Q_VEL | 0.00025 | -- |
| Q_ACC | 0.00001 | -- |
| R (meas noise) | 0.25 | -- |
| P_INIT(pos) | 10.0 | 0x00000A000000 |
| P_INIT(vel) | 100.0 | 0x000064000000 |
| P_INIT(acc) | 0.01 | 0x000000028F5C |

### 3.4 FSM States
```
IDLE -> INIT_STATE -> WAIT_INIT -> RUN_PREDICTION -> WAIT_PREDICTION
     -> RUN_UPDATE -> WAIT_UPDATE -> FINISHED -> IDLE
```
8 states. Identical FSM structure to CA standard. Uses `prediction_phase_p_3d` (the "p" variant with Singer process noise).

### 3.5 Clock Cycles
**638 clocks** per output (GHDL verified). Slightly more than CA's 600 due to Singer's exponential decay computation in prediction.

### 3.6 Key Modules
Same as CA standard except:
- `predicti_singer3d.vhd` (Singer motion model with exp decay)
- `prediction_phase_p_3d.vhd` (Singer prediction coordinator)
- `process_noise_singer_p_3d.vhd` (Singer process noise — **the active one**)

**WARNING:** `process_noise_singer_3d.vhd` and `process_noise_singer_3d_simple.vhd` exist but are **NOT instantiated** by the top-level. Only `process_noise_singer_p_3d.vhd` is used.

### 3.7 RMSE Results
| Dataset | RMSE |
|---------|------|
| Drone 500cy | **0.995m** (sub-meter!) |

Achieved via: 144-bit precision + Q_POS=0.08 tuning + zeroed off-diagonal P + P saturation.

---

## 4. CA SR-UKF (9D, Potter Square-Root)

### 4.1 State Vector
Same as CA Standard: `[px, vx, ax, py, vy, ay, pz, vz, az]^T`

### 4.2 Motion Model
Same constant acceleration equations as Section 2.2.

### 4.3 Differences from Standard CA
- Propagates Cholesky factor **L** instead of covariance **P** (P = L*L^T)
- Initialization: L_diag = sqrt(P_INIT) instead of P_INIT directly
- Uses QR decomposition + rank-1 Cholesky updates/downdates
- Potter downdate in measurement update: `w_i = K[:,i] * sqrt(S_ii)` (Bug #5 fix)

### 4.4 L Factor Initialization

| State | sqrt(P_INIT) | Q24.24 |
|-------|-------------|--------|
| pos | sqrt(5.0) = 2.236 | 37480968 |
| vel | sqrt(20.0) = 4.472 | 74961936 |
| acc | sqrt(0.01) = 0.1 | 1677722 |

### 4.5 FSM States
```
IDLE -> INIT_STATE -> WAIT_INIT -> RUN_PREDICTION -> WAIT_PREDICTION
     -> RUN_UPDATE -> WAIT_UPDATE -> FINISHED -> IDLE
```
8 states. Same structure but uses SR prediction/update modules.

### 4.6 Clock Cycles
~2000-2500 clocks per output (SR operations require more sequential steps).

### 4.7 Key Modules
- `sr_ukf_supreme_ca_3d.vhd` (top-level FSM)
- `sr_prediction_phase_ca_3d.vhd` (SR prediction with QR decomposition)
- `sr_measurement_update_ca_3d.vhd` (SR update with Potter downdate)
- `qr_decomp_9x19.vhd` (QR decomposition)
- `cholesky_rank1_update.vhd` / `cholesky_rank1_downdate.vhd`
- Shared: `predicti_ca3d.vhd`, `sigma_3d.vhd`, `predicted_mean_3d.vhd`, etc.

### 4.8 RMSE Results
| Dataset | RMSE |
|---------|------|
| Drone 500cy | **0.934m** |

With optimized params + 96-bit inlined Givens rotations.

---

## 5. Singer SR-UKF (9D, Potter Square-Root)

### 5.1 State Vector
Same as Singer Standard: `[px, vx, ax, py, vy, ay, pz, vz, az]^T`

### 5.2 Motion Model
Same Singer equations as Section 3.2.

### 5.3 L Factor Initialization

| State | sqrt(P_INIT) | Q24.24 |
|-------|-------------|--------|
| pos | sqrt(10.0) = 3.162 | 53031907 |
| vel | sqrt(100.0) = 10.0 | 167772160 |
| acc | sqrt(0.01) = 0.1 | 1677722 |

### 5.4 Optimized Parameters
```
Q_POS = 0.021,  Q_VEL = 0.01,  Q_ACC = 0.01,  R = 0.13
LQ_POS = 2431249,  LQ_VEL = 1677721,  LQ_ACC = 1677721  (Q24.24)
```

### 5.5 FSM States
Same 8-state structure as CA SR-UKF.

### 5.6 Clock Cycles
~1543 clocks per output.

### 5.7 Key Modules
- `sr_ukf_supreme_3d.vhd` (top-level FSM)
- `sr_prediction_phase_singer_3d.vhd`
- `sr_measurement_update_singer_3d.vhd`
- `state_update_potter_3d.vhd` (Bug #5: uses sqrt(S_ii) not sqrt(R_ii))

### 5.8 RMSE Results
| Dataset | RMSE |
|---------|------|
| Drone 500cy | **0.878m** (best single-model!) |

Python reference: 0.873m (0.6% precision gap).

---

## 6. Bicycle UKF (7D)

### 6.1 State Vector
```
x = [px, py, v, theta, delta, a, z]^T    (7 states)
```
- px, py: 2D position (m)
- v: speed magnitude (m/s)
- theta: heading angle (rad)
- delta: front-wheel steering angle (rad)
- a: longitudinal acceleration (m/s^2)
- z: altitude (m)

### 6.2 Motion Model (Bicycle Kinematics)
```
beta = (lr/L) * delta                    [side-slip angle at CG]
px'    = px + v * cos(theta + beta) * dt
py'    = py + v * sin(theta + beta) * dt
v'     = v + a * dt
theta' = theta + (v * delta / L) * dt   [angle-wrapped to [-pi, pi]]
delta' = delta                           [constant steering]
a'     = a                               [constant acceleration]
z'     = z                               [constant altitude]
```

### 6.3 Geometry Parameters

| Parameter | Value | Q24.24 |
|-----------|-------|--------|
| L (wheelbase) | 3.6 m | -- |
| lr (CG to rear) | 1.6 m | -- |
| dt | 0.02 s | 335544 |
| lr/L | 0.4444 | 7456540 |
| 1/L | 0.2778 | 4660337 |

### 6.4 UKF Parameters

| Parameter | Value |
|-----------|-------|
| P_INIT(px,py) | 5.0 |
| P_INIT(v) | 20.0 |
| P_INIT(theta,delta) | 0.1 |
| P_INIT(a) | 1.0 |
| P_INIT(z) | 5.0 |
| Q(px,py) | 0.5 |
| Q(v) | 10.0 |
| Q(theta) | 0.05 |
| Q(delta) | 0.001 |
| Q(a) | 5.0 |
| Q(z) | 0.5 |
| R | 0.13 |

### 6.5 FSM States
```
IDLE -> INIT_STATE
START_CHOLESKY -> WAIT_CHOLESKY -> WAIT_SIGMA
START_PROPAGATE -> WAIT_PROPAGATE
START_MEAN_COV -> WAIT_MEAN -> WAIT_COV
START_PROC_NOISE -> WAIT_PROC_NOISE
START_MEAS_UPDATE -> WAIT_INNOV_COV
START_KALMAN -> WAIT_KALMAN
START_STATE_UPD -> WAIT_STATE_UPD
LATCH_OUTPUT -> CYCLE_DONE
```
20 states. Fine-grained pipeline with explicit module start/wait per stage.

### 6.6 Clock Cycles
**780 clocks per output** (GHDL verified: Cycle 2 = 780, Cycle 3 = 779).
- Init cycle: 2 clocks (fast init path sets state from measurement + P_INIT)
- Steady-state breakdown (approximate):
  - Cholesky(7x7): ~100 | Sigma: ~30 | Propagate(15pts x CORDIC): ~350
  - Mean: ~40 | Covariance: ~130 | Process noise: ~1
  - Measurement update (parallel): ~60 | Kalman gain: ~80 | State update: ~100

### 6.7 Key Modules (11 components)
- `bicycle_ukf_supreme.vhd` (top-level FSM)
- `predicti_bicycle.vhd` (bicycle kinematic propagation with CORDIC)
- `process_noise_bicycle.vhd`
- `cholesky_7x7.vhd` / `sigma_7d.vhd`
- `predicted_mean_7d.vhd` / `predicted_covariance_7d.vhd`
- `innovation_covariance_7d.vhd` / `innovation_3d.vhd` / `cross_covariance_7d.vhd`
- `kalman_gain_7d.vhd` / `state_update_7d.vhd`
- `sin_cos_cordic.vhd` / `sqrt_cordic.vhd` / `matrix_inverse_3x3.vhd`

### 6.8 RMSE Results
| Dataset | RMSE |
|---------|------|
| Drone 500cy | 1.22m |
| Monaco 750cy | 20.5m |
| Silverstone 750cy | 24.3m |

Drone gap (35% vs Python 0.90m) attributed to pcov precision. F1 results stable but untuned.

---

## 7. CTRA UKF (7D)

### 7.1 State Vector
```
x = [px, py, v, theta, omega, a, z]^T    (7 states)
```
- omega: turn rate (rad/s) — replaces delta (steering) from bicycle model

### 7.2 Motion Model (Constant Turn Rate and Acceleration)

**Velocity & heading (always):**
```
v'     = v + a * dt
theta' = theta + omega * dt
omega' = omega                  [constant turn rate]
a'     = a                      [constant acceleration]
z'     = z                      [constant altitude]
```

**Position — Turning case (|omega| > 0.01 rad/s):**
```
px' = px + [v'*sin(theta') - v*sin(theta)] / omega
         + a*[cos(theta) - cos(theta')] / omega^2

py' = py + [-v'*cos(theta') + v*cos(theta)] / omega
         + a*[sin(theta') - sin(theta)] / omega^2
```

**Position — Straight-line case (|omega| <= 0.01 rad/s):**
```
px' = px + v*cos(theta)*dt + 0.5*a*cos(theta)*dt^2
py' = py + v*sin(theta)*dt + 0.5*a*sin(theta)*dt^2
```

### 7.3 UKF Parameters

| Parameter | Value |
|-----------|-------|
| dt | 0.02 s |
| omega_threshold | 0.01 rad/s |
| P_INIT(px,py) | 5.0 |
| P_INIT(v) | 20.0 |
| P_INIT(theta,omega) | 0.1 |
| P_INIT(a) | 1.0 |
| P_INIT(z) | 5.0 |
| POS_MAX | +/-8192 m (saturation) |

### 7.4 FSM States
```
IDLE -> INIT_STATE
START_CHOLESKY -> WAIT_CHOLESKY -> WAIT_SIGMA
START_PROPAGATE -> WAIT_PROPAGATE
START_MEAN_COV -> WAIT_MEAN -> WAIT_COV
START_PROC_NOISE -> WAIT_PROC_NOISE
START_MEAS_UPDATE -> WAIT_INNOV_COV -> WAIT_INNOV -> WAIT_CROSS_COV
START_KALMAN -> WAIT_KALMAN
START_STATE_UPD -> WAIT_STATE_UPD
LATCH_OUTPUT -> CYCLE_DONE
```
21 states.

### 7.5 Clock Cycles
~780 clocks per output (est., same pipeline as Bicycle which is GHDL-verified at 780).
- Cholesky: ~150 | Sigma: ~50 | Propagate(15pts x CORDIC): ~200
- Mean/Cov: ~150 | Measurement update (parallel): ~250 | Kalman: ~100 | State update: ~200

### 7.6 Key Modules (11 components)
- `ctra_ukf_supreme.vhd` (top-level FSM)
- `predicti_ctra.vhd` (CTRA motion model with omega branching)
- `process_noise_ctra.vhd`
- `cholesky_7x7.vhd` / `sigma_7d.vhd`
- `predicted_mean_7d.vhd` / `predicted_covariance_7d.vhd`
- `innovation_covariance_7d.vhd` / `innovation_3d.vhd` / `cross_covariance_7d.vhd`
- `kalman_gain_7d.vhd` / `state_update_7d.vhd`
- `sin_cos_cordic.vhd` / `sqrt_cordic.vhd` / `matrix_inverse_3x3.vhd`

### 7.7 RMSE Results
| Dataset | RMSE |
|---------|------|
| Drone 500cy | ~1.2m |

---

## 8. CT Polar UKF (9D)

### 8.1 State Vector
```
x = [px, py, v, theta, omega, a, z, vz, az]^T    (9 states)
```
Extends CTRA with vertical dynamics: vz (vertical velocity) and az (vertical acceleration).

### 8.2 Motion Model

**Horizontal — same CTRA equations as Section 7.2** (turning/straight branching).

**Vertical — Constant Acceleration:**
```
z'  = z + vz*dt + 0.5*az*dt^2
vz' = vz + az*dt
az' = az                        [constant vertical acceleration]
```

omega_threshold = 1e-4 rad/s (tighter than CTRA's 0.01).

### 8.3 UKF Parameters

| Parameter | Value |
|-----------|-------|
| dt | 0.02 s |
| P_INIT(px,py) | 5.0 |
| P_INIT(v) | 20.0 |
| P_INIT(theta,omega) | 0.1 |
| P_INIT(a) | 1.0 |
| P_INIT(z) | 5.0 |
| P_INIT(vz) | 100.0 |
| P_INIT(az) | 0.01 |
| gamma | 3.0 |

### 8.4 FSM States
```
IDLE -> INIT_STATE
START_CHOLESKY -> WAIT_CHOLESKY -> WAIT_SIGMA
START_PROPAGATE -> WAIT_PROPAGATE
START_MEAN_COV -> WAIT_MEAN -> START_PCOV -> WAIT_PCOV
START_PROC_NOISE -> WAIT_PROC_NOISE
START_MEAS_UPDATE -> WAIT_INNOV_COV
START_KALMAN -> WAIT_KALMAN
START_STATE_UPD -> WAIT_STATE_UPD
LATCH_OUTPUT -> CYCLE_DONE
```
20 states. Mean and pcov are sequential (mean must finish before pcov starts).

### 8.5 Clock Cycles
**1543 clocks** per output (GHDL verified). First cycle: 1549 clocks (init overhead), steady-state: 1543.

### 8.6 Key Modules (10 components)
- `ct_polar_ukf_supreme.vhd` (top-level FSM)
- `predicti_ct_polar.vhd` (CTRA horizontal + CA vertical)
- `process_noise_ct_polar.vhd`
- `cholesky_9x9.vhd` / `sigma_9d.vhd`
- `predicted_mean_9d.vhd` / `predicted_covariance_9d.vhd`
- `innovation_covariance_9d.vhd` / `innovation_3d.vhd` / `cross_covariance_9d.vhd`
- `kalman_gain_9d.vhd` / `state_update_9d.vhd`
- `sin_cos_cordic.vhd` / `sqrt_cordic.vhd` / `matrix_inverse_3x3.vhd`

### 8.7 RMSE Results
| Dataset | RMSE |
|---------|------|
| Drone 500cy | 1.325m (Python 1.36m, 2.6% gap) |
| Monaco 750cy | 18.87m (untuned) |
| Silverstone 750cy | diverged (needs IMM/tuning) |

---

## 9. IMM F1 (CA + Singer + Bicycle)

### 9.1 Architecture
Interacting Multiple Model filter combining 3 UKFs:
- **Model 1:** CA UKF (9D) — straight-line motion
- **Model 2:** Singer UKF (9D) — maneuvering with acceleration decay
- **Model 3:** Bicycle UKF (7D) — cornering with steering dynamics

### 9.2 IMM Pipeline
```
Measurement → [State Mappers] → [State Mixer] → [Covariance Mixer]
           → [3 UKFs in parallel] → [Likelihood] → [Prob Update]
           → [Output Fusion] → Fused Position
```

### 9.3 State Mapping
- CA 9D -> 7D (for mixing with Bicycle): `state_mapper_9d_to_7d`
- Singer 9D -> 7D: `state_mapper_9d_to_7d`
- Bicycle 7D -> 9D: `state_mapper_7d_to_9d`

### 9.4 Initial Probabilities
```
P(CA)     = 0.5    (Q24.24: 8388608)
P(Singer) = 0.3    (Q24.24: 5033165)
P(Bike)   = 0.2    (Q24.24: 3355443)
```

### 9.5 Probability Update (Bayesian)
```
L_i = exp(-0.5 * nu_i^T * S_i^-1 * nu_i)     [Gaussian likelihood per model]
c_i = sum_j(M_ji * prob_j)                      [normalizing constant from mixer]
prob_i_new = (L_i * c_i) / sum_j(L_j * c_j)    [Bayes update]
```
First cycle: skip probability update, use initial priors.

### 9.6 Output Fusion
```
p_fused = prob_CA * p_CA + prob_Singer * p_Singer + prob_Bike * p_Bike
```

### 9.7 FSM States
```
IDLE -> INIT_FIRST
MAP_STATES -> WAIT_MAP
START_MIX -> WAIT_MIX -> START_COV_MIX -> WAIT_COV_MIX
INJECT_MIXED -> WAIT_FILTERS
START_LIKELIHOOD -> WAIT_LIKELIHOOD
START_PROB_UPDATE -> WAIT_PROB_UPDATE
START_FUSION -> WAIT_FUSION -> DONE_STATE
```
17 states.

### 9.8 Clock Cycles
~900-1000 clocks per output (est.). Parallel UKFs bottleneck = Bicycle at 780, plus ~120-220 clocks IMM overhead (state mixing, likelihood, probability update, output fusion).

### 9.9 Key Modules (11 components)
- `imm_f1_top.vhd` (top-level IMM controller)
- `ca_ukf_supreme_imm.vhd` / `singer_ukf_supreme_imm.vhd` / `bicycle_ukf_supreme_imm.vhd`
- `state_mapper_9d_to_7d.vhd` (x2) / `state_mapper_7d_to_9d.vhd`
- `imm_state_mixer.vhd` / `imm_covariance_mixer.vhd`
- `imm_likelihood.vhd` / `imm_prob_update.vhd` / `imm_output_fusion.vhd`

### 9.10 RMSE Results
| Dataset | RMSE |
|---------|------|
| Monaco 750cy | **1.91m** |
| Silverstone 750cy | **2.19m** |

---

## 10. IMM Friend (CTRA + Singer + Bicycle)

### 10.1 Architecture
Interacting Multiple Model filter combining 3 UKFs:
- **Model 1:** CTRA UKF (7D) — constant turn rate + acceleration
- **Model 2:** Singer UKF (9D) — maneuvering with acceleration decay
- **Model 3:** Bicycle UKF (7D) — cornering with steering dynamics

### 10.2 IMM Pipeline
Same as IMM F1 but with 4 state mappers (more complex cross-model mapping):
```
Measurement → [4 State Mappers] → [State Mixer] → [Covariance Mixer]
           → [3 UKFs in parallel] → [Likelihood] → [Prob Update]
           → [Output Fusion] → Fused Position
```

### 10.3 State Mapping (4 mappers)
- Singer 9D -> Bicycle 7D: `state_mapper_9d_to_7d`
- Singer 9D -> CTRA 7D: `state_mapper_9d_to_7d_ctra`
- Bicycle 7D -> 9D: `state_mapper_7d_to_9d`
- CTRA 7D -> 9D: `state_mapper_7d_to_9d` (CTRA variant)

### 10.4 Initial Probabilities
```
P(CTRA)   = 0.4    (Q24.24: 6710886)
P(Singer) = 0.3    (Q24.24: 5033165)
P(Bike)   = 0.3    (Q24.24: 5033165)
```

### 10.5 Sanity Clamp
Output positions clamped to +/-10m from measurement if fusion deviates beyond that threshold. Prevents spikes during model switching.
```
10m in Q24.24 = 167772160
```

### 10.6 FSM States
Same 17 states as IMM F1:
```
IDLE -> INIT_FIRST
MAP_STATES -> WAIT_MAP
START_MIX -> WAIT_MIX -> START_COV_MIX -> WAIT_COV_MIX
INJECT_MIXED -> WAIT_FILTERS
START_LIKELIHOOD -> WAIT_LIKELIHOOD
START_PROB_UPDATE -> WAIT_PROB_UPDATE
START_FUSION -> WAIT_FUSION -> DONE_STATE
```

### 10.7 Clock Cycles
~900-1000 clocks per output (est.). Parallel UKFs bottleneck = Bicycle at 780, plus ~120-220 clocks IMM overhead.

### 10.8 Key Modules (12 components)
- `imm_friend_top.vhd` (top-level IMM controller)
- `ctra_ukf_supreme_imm.vhd` / `singer_ukf_supreme_imm.vhd` / `bicycle_ukf_supreme_imm.vhd`
- `state_mapper_9d_to_7d.vhd` / `state_mapper_9d_to_7d_ctra.vhd`
- `state_mapper_7d_to_9d.vhd` (x2: Bicycle and CTRA variants)
- `imm_friend_state_mixer.vhd` / `imm_friend_covariance_mixer.vhd`
- `imm_likelihood.vhd` / `imm_prob_update.vhd` / `imm_output_fusion.vhd`

### 10.9 RMSE Results
| Dataset | RMSE |
|---------|------|
| Monaco 750cy | **1.783m** (best IMM!) |

---

## 11. RMSE Comparison

### 11.1 Drone Trajectory (500 cycles, synthetic)

| Rank | Model | RMSE | Notes |
|------|-------|------|-------|
| 1 | Singer SR-UKF | **0.878m** | Best overall single model |
| 2 | CA Standard | **0.882m** | 144-bit precision key |
| 3 | CA SR-UKF | 0.934m | Square-root overhead |
| 4 | Singer Standard | 0.995m | Sub-meter with tuning |
| 5 | CTRA | ~1.2m | Untuned |
| 6 | Bicycle | 1.22m | pcov precision gap |
| 7 | CT Polar | 1.325m | Matches Python (2.6% gap) |

### 11.2 F1 Racing — Monaco (750 cycles)

| Rank | Model | RMSE | Notes |
|------|-------|------|-------|
| 1 | IMM Friend | **1.783m** | CTRA+Singer+Bicycle |
| 2 | IMM F1 | 1.91m | CA+Singer+Bicycle |
| 3 | CT Polar | 18.87m | Untuned standalone |
| 4 | Bicycle | 20.5m | Untuned standalone |

### 11.3 F1 Racing — Silverstone (750 cycles)

| Rank | Model | RMSE | Notes |
|------|-------|------|-------|
| 1 | IMM F1 | **2.19m** | Only IMM tested |
| 2 | Bicycle | 24.3m | Untuned standalone |
| 3 | CT Polar | diverged | Needs IMM/tuning |

### 11.4 Model Selection Guidance

| Scenario | Recommended Model | Rationale |
|----------|------------------|-----------|
| Straight-line motion (drone, UAV) | Singer SR-UKF | Best RMSE (0.878m), handles acceleration decay |
| Straight-line, simpler | CA Standard | Near-best RMSE (0.882m), fewer clock cycles |
| Mixed maneuvers (F1 racing) | IMM Friend | Best F1 RMSE (1.783m), adapts to turns+straights |
| General F1 (backup) | IMM F1 | Proven on 2 tracks (1.91m, 2.19m) |
| Drone with vertical dynamics | CT Polar | 9D with decoupled vertical CA model |
| Single nonlinear model | CTRA or Bicycle | When IMM overhead too expensive |
| Maximum numerical stability | SR-UKF variants | Square-root form prevents P going non-positive |

---

## 12. Common Infrastructure

### 12.1 Q24.24 Fixed-Point Format
```
Format: signed(47 downto 0)
  Bits [47:24] = integer part (24 bits, range: -8388608 to +8388607)
  Bits [23:0]  = fractional part (24 bits, resolution: ~5.96e-8)
  Effective range: approximately +/-128 in real units (practical)
  Multiplication: Q24.24 x Q24.24 = Q48.48, then >> 24 to get Q24.24
```

### 12.2 CORDIC Modules

**sqrt_cordic.vhd** — Newton-Raphson square root
- Input: Q24.24 positive value
- Output: Q24.24 square root
- Latency: ~20 clocks
- Used in: Cholesky decomposition, SR-UKF updates

**sin_cos_cordic.vhd** — CORDIC sine/cosine
- Input: angle in Q24.24 radians
- Output: sin(angle), cos(angle) in Q24.24
- Latency: ~24 clocks (24 CORDIC iterations)
- Used in: Bicycle, CTRA, CT Polar prediction models

### 12.3 Cholesky Decomposition
- **cholesky_9x9 (cholsky_9.vhd):** 9x9 lower-triangular decomposition, 45 output elements
- **cholesky_7x7:** 7x7 lower-triangular decomposition, 28 output elements
- Both use sqrt_cordic for diagonal elements and sequential column processing
- Latency: ~100-150 clocks

### 12.4 Matrix Inverse 3x3
**matrix_inverse_3x3.vhd** — Computes S^-1 for 3x3 innovation covariance
- Uses analytical cofactor formula (Cramer's rule)
- Input: 6 unique elements (symmetric 3x3)
- Output: 6 unique elements of S^-1
- Used by all Kalman gain computations

### 12.5 Sigma Point Generation
- **sigma_9d.vhd:** Generates 19 sigma points from 9D state + 9x9 Cholesky factor L
- **sigma_7d.vhd:** Generates 15 sigma points from 7D state + 7x7 Cholesky factor L
- Formula: chi_0 = x_mean, chi_i = x_mean + gamma*L_col_i, chi_{i+n} = x_mean - gamma*L_col_i
- gamma = sqrt(n + lambda) = 3.0 for n=9 (lambda=0)

### 12.6 UKF Weights
For n-dimensional state with lambda=0:
```
W_mean_0 = lambda / (n + lambda) = 0
W_cov_0  = lambda / (n + lambda) + (1 - alpha^2 + beta) ≈ 2.0
W_i      = 1 / (2*(n + lambda))  for i = 1..2n
```
In practice, gamma=3.0 absorbs the scaling, so weights are:
- W_0 = 0 (mean), W_0_cov = special
- W_i = 1/(2*9) = 1/18 for 9D; W_i = 1/(2*7) = 1/14 for 7D

---

## 13. Bug Fix History (Critical)

| # | Bug | Impact | Fix |
|---|-----|--------|-----|
| 1 | Double shift in covariance reconstruction | Covariance too small | Fixed shift amounts |
| 2 | TAU mismatch (10.0 vs 2.0) in Singer | Wrong acceleration decay | Matched component to entity TAU=2.0 |
| 3 | AP matrix indexing in state_update_3d | Wrong cross-block P terms | Fixed Y/Z axis indices |
| 4 | 32-bit truncation cascade | Position wraps at +/-128m | Widened to 48-bit throughout |
| 5 | Potter downdate uses sqrt(R) not sqrt(S) | L grows unbounded, diverges ~94cy | Added S_ii ports, use sqrt(S_ii) |

### Key Precision Achievement
**144-bit intermediate precision** in state_update_3d.vhd:
- AP*A^T and K*R*K^T computed in Q72.72 (144-bit)
- Single shift by 2*Q=48 at the end
- Eliminated two levels of Q24.24 truncation
- Effect: CA RMSE 1.55m -> 0.882m (43% improvement from single change)

---

## 14. Directory Structure

```
collection/
├── ca_ukf/
│   ├── src/
│   │   ├── standard_ukf/     # CA standard UKF top + update modules
│   │   ├── sr_ukf/           # CA SR-UKF top + SR update modules
│   │   ├── predicti_ca3d.vhd # Shared CA prediction model
│   │   ├── sigma_3d.vhd      # Shared sigma point gen (9D)
│   │   ├── sqrt_cordic.vhd   # Shared sqrt
│   │   └── ...               # Shared modules
│   └── ca_ukf.srcs/sources_1/new/  # Vivado project copies
│
├── singers_model/
│   ├── src/
│   │   ├── standard_ukf/     # Singer standard UKF
│   │   ├── sr_ukf/           # Singer SR-UKF
│   │   ├── predicti_singer3d.vhd
│   │   └── ...
│   └── singers_model.srcs/sources_1/new/
│
├── bicycle_ukf/
│   ├── src/                   # All 15 bicycle UKF modules
│   ├── scripts/
│   └── testbenches/
│
├── ctra/
│   └── src/                   # CTRA UKF modules
│
├── ct_polar/
│   └── src/                   # CT Polar UKF modules (16 files)
│
├── imm_f1/
│   └── src/                   # IMM F1 (CA+Singer+Bicycle)
│
└── imm_friend/
    └── src/
        ├── imm/               # IMM controller + mixers + fusion
        ├── ctra_ukf/          # CTRA variant for IMM
        ├── singer_ukf/        # Singer variant for IMM
        └── bicycle_ukf/       # Bicycle variant for IMM
```
