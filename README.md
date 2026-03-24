# UKF Tracking — VHDL Hardware Implementations

Fixed-point Unscented Kalman Filter variants implemented in VHDL, synthesized and verified on the **Xilinx Zynq UltraScale+ ZCU106** FPGA.
All designs share a common pipeline architecture and use **Q24.24 fixed-point arithmetic** (48-bit signed).

**Total VHDL Modules:** 178 across 6 filter designs + RF classifier (Singer: 41 · CA: 31 · Bicycle: 15 · CT Polar: 15 · CTRA: 15 · IMM: 56 · RF: 5)

---

## Table of Contents

1. [Common UKF Architecture](#1-common-ukf-architecture)
2. [Filter Variants — What Makes Each Different](#2-filter-variants)
   - [CA UKF](#21-ca-ukf--constant-acceleration)
   - [Singer's Model UKF](#22-singers-model-ukf)
   - [CTRA UKF](#23-ctra-ukf--constant-turn-rate--acceleration)
   - [Bicycle UKF](#24-bicycle-ukf--kinematic-vehicle-model)
   - [CT Polar UKF](#25-ct-polar-ukf--coordinated-turn-polar)
3. [IMM-UKF — Interacting Multiple Model](#3-imm-ukf--interacting-multiple-model)
4. [Results — Individual Filters](#4-results--individual-filters)
5. [Key Result — IMM on Max Verstappen Abu Dhabi 2024](#5-key-result--imm-on-max-verstappen-abu-dhabi-2024)
6. [Random Forest Object Classifier (VHDL)](#6-random-forest-object-classifier-vhdl)
6. [Datasets](#6-datasets)
7. [Testbenches](#7-testbenches)
8. [Fixed-Point Format](#8-fixed-point-format)
9. [Hardware](#9-hardware)

---

## 1. Common UKF Architecture

Every filter in this repo follows the same 4-stage pipeline. The **only difference between filters is the prediction model and state vector**. All share identical measurement update logic (linear H matrix observing position only).

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                   SHARED UKF PIPELINE (all variants)                        │
│                                                                             │
│                    ┌─────────────────────────────────────────┐              │
│  P(k-1), x(k-1)    │  STAGE 1: Sigma Point Generation        │              |
│  ───────────────▶  │                                         │              │
│                    │  χᵢ = x̂ ± √((n+λ)·P)  via Cholesky      │              │
│                    │  n sigma points = 2n+1                  │              │
│                    └──────────────────┬──────────────────────┘              │
│                                       │  19 pts (9D) or 15 pts (7D)         │
│                                       ▼                                     │
│                    ┌─────────────────────────────────────────┐              │
│                    │  STAGE 2: Prediction (model-specific)   │ ◀ differs    │
│                    │                                         │   per filter │
│                    │  χᵢ⁺ = f(χᵢ)  ← motion model here       │              │
│                    │  x̂⁻  = Σ Wᵢᵐ · χᵢ⁺  (predicted mean)    │              │
│                    │  P⁻   = Σ Wᵢᶜ · (χᵢ⁺-x̂⁻)(χᵢ⁺-x̂⁻)ᵀ + Q   │              │
│                    └──────────────────┬──────────────────────┘              │
│                                       │                                     │
│  z(k)  ─────────────────────────────▶ │                                     │
│  (GPS measurement)                    ▼                                     │
│                    ┌─────────────────────────────────────────┐              │
│                    │  STAGE 3: Measurement Update (shared)   │              │
│                    │                                         │              │
│                    │  ŷ  = H · x̂⁻          (predicted meas)  │              │
│                    │  v  = z - ŷ            (innovation)     │              │
│                    │  S  = H·P⁻·Hᵀ + R      (innov cov)      │              │
│                    │  K  = P⁻·Hᵀ·S⁻¹        (Kalman gain)    │              │
│                    └──────────────────┬──────────────────────┘              │
│                                       ▼                                     │
│                    ┌───────────────────────────────────────────┐            │
│                    │  STAGE 4: State & Covariance Update       │            │
│                    │                                           │            │
│                    │  x̂(k) = x̂⁻ + K · v                        │            │
│                    │  P(k)  = (I - K·H)·P⁻·(I - K·H)ᵀ + K·R·Kᵀ |            │
│                    │          (Joseph form, 144-bit precision) │            │
│                    └──────────────────┬────────────────────────┘            │
│                                       │                                     │
│                                       ▼                                     │
│                              x̂(k), P(k) output                              │
└─────────────────────────────────────────────────────────────────────────────┘

  Shared VHDL modules across all filters:
  ├── sigma_Nd.vhd              sigma point generation
  ├── cholesky_NxN.vhd          P matrix square root
  ├── predicted_mean_Nd.vhd     weighted mean of propagated sigma pts
  ├── innovation_3d.vhd         z - H·x̂
  ├── innovation_covariance.vhd  H·P·Hᵀ + R
  ├── kalman_gain_Nd.vhd        K = P·Hᵀ·S⁻¹
  ├── state_update_Nd.vhd       x, P update (Joseph form)
  ├── sqrt_cordic.vhd           CORDIC square root
  ├── sin_cos_cordic.vhd        CORDIC sin/cos (trig models only)
  └── matrix_inverse_3x3.vhd   3×3 inversion for Kalman gain
```

**Observation model (H matrix) is identical across all filters:**
```
H = [ 1  0  0  0  0  0  ... ]   ← measures x position
    [ 0  0  0  1  0  0  ... ]   ← measures y position
    [ 0  0  0  0  0  0  1 ... ] ← measures z position
```
GPS/position only — no velocity or acceleration measurements.

---

## 2. Filter Variants

### 2.1 CA UKF — Constant Acceleration

**States (9D):** `[px, py, pz, vx, vy, vz, ax, ay, az]`
**Sigma points:** 19 | **Modules:** 31 | **Clocks/update:** ~1200

**What makes it different:** Simplest motion model. Acceleration is treated as a **random walk** — it stays constant between steps with process noise. No model of how acceleration evolves.

```
Motion model  f(χ):
  px ← px + vx·dt + ½·ax·dt²
  vx ← vx + ax·dt
  ax ← ax                       ← constant (no decay, no steering)

Q matrix: diag[Q_pos, Q_vel, Q_acc] × 3 axes
  Q_POS=0.05,  Q_VEL=0.00025,  Q_ACC=0.00001
```

**Unique modules:** `predicti_ca3d.vhd`, `process_noise_3d.vhd`
**Best for:** Short-horizon smooth trajectories (drones, linear motion)

---

### 2.2 Singer's Model UKF

**States (9D):** `[px, py, pz, vx, vy, vz, ax, ay, az]`
**Sigma points:** 19 | **Modules:** 41 | **Clocks/update:** ~1300

**What makes it different:** Acceleration is modelled as an **Ornstein-Uhlenbeck process** — it exponentially decays toward zero with time constant τ. This captures maneuver correlation: if a target is accelerating, it tends to keep accelerating for ~τ seconds before changing.

```
Motion model  f(χ):
  px ← px + vx·dt + ax·(dt - τ(1-e^{-dt/τ}))  / τ
  vx ← vx + ax·τ·(1 - e^{-dt/τ})
  ax ← ax · e^{-dt/τ}              ← exponential decay (Singer decay)
                    ↑
               τ = 2.0 seconds (maneuver time constant)

Q matrix: Singer formulation — correlates pos/vel/acc noise
  Q_POS=0.08,  Q_VEL=0.00025,  Q_ACC=0.00001,  R=0.25
```

**Unique modules:** `predicti_singer3d.vhd`, `process_noise_singer_p_3d.vhd`, `singer_exp_cordic.vhd` (CORDIC e^{-dt/τ})
**Also available:** SR-UKF (Square-Root Potter variant) — `src/singers_model/sr_ukf/`
**Best for:** Maneuvering targets where acceleration is correlated over time

---

### 2.3 CTRA UKF — Constant Turn Rate & Acceleration

**States (7D):** `[px, py, v, θ, ω, a, z]`
**Sigma points:** 15 | **Modules:** 15 | **Clocks/update:** ~900

**What makes it different:** Models **turning motion explicitly** with a turn rate ω state. Velocity is a scalar magnitude; direction comes from heading θ. Includes CORDIC for sin/cos computation.

```
Motion model  f(χ):
  px ← px + (v/ω)·(sin(θ+ω·dt) - sin(θ))   ← arc motion
  py ← py + (v/ω)·(cos(θ)      - cos(θ+ω·dt))
  v  ← v + a·dt
  θ  ← θ + ω·dt
  ω  ← ω                                      ← constant turn rate
  a  ← a
  z  ← z

  Special case: ω≈0 → straight line (numerical stability)
```

**Unique modules:** `predicti_ctra.vhd`, `process_noise_ctra.vhd`
**Best for:** Vehicles executing smooth turns at known curvature

---

### 2.4 Bicycle UKF — Kinematic Vehicle Model

**States (7D):** `[px, py, v, θ, δ, a, z]`
**Sigma points:** 15 | **Modules:** 15 | **Clocks/update:** ~840

**What makes it different:** The only filter with an **explicit steering angle δ** state and wheelbase geometry. Uses a kinematic bicycle model that relates steering to path curvature through the wheelbase L and CG offset lr. Most physically accurate for cars.

```
Motion model  f(χ):
  β  = arctan( lr·tan(δ) / L )     ← slip angle (CG relative to axle)
  px ← px + v·cos(θ+β)·dt
  py ← py + v·sin(θ+β)·dt
  θ  ← θ  + (v/lr)·sin(β)·dt      ← yaw from kinematics
  v  ← v  + a·dt
  δ  ← δ                            ← steering angle persists
  a  ← a
  z  ← z

  Parameters: L=3.6m (wheelbase),  lr=1.6m (CG→rear axle),  dt=0.02s
```

**Unique modules:** `predicti_bicycle.vhd`, `process_noise_bicycle.vhd`, `sin_cos_cordic.vhd`
**Best for:** Ground vehicles — F1 cars, autonomous driving, robotics

---

### 2.5 CT Polar UKF — Coordinated Turn Polar

**States (9D):** `[px, py, v, θ, ω, a, z, vz, az]`
**Sigma points:** 19 | **Modules:** 15 | **Clocks/update:** ~1543

**What makes it different:** Extends CTRA to full 3D with **explicit vertical dynamics** (vz, az states) and uses **polar-form velocity** (magnitude v + heading θ) instead of Cartesian (vx, vy). Best at tracking objects with simultaneous horizontal maneuver and altitude change.

```
Motion model  f(χ):
  px ← px + v·cos(θ)·dt
  py ← py + v·sin(θ)·dt
  v  ← v  + a·dt
  θ  ← θ  + ω·dt
  ω  ← ω                           ← constant yaw rate
  a  ← a
  z  ← z  + vz·dt
  vz ← vz + az·dt
  az ← az
```

**Unique modules:** `predicti_ct_polar.vhd`, `process_noise_ct_polar.vhd`
**Best for:** UAVs and aircraft during banking turns with altitude change

---

## 3. IMM-UKF — Interacting Multiple Model

**Sub-models:** CT Polar (9D) + Singer (9D) + Bicycle (7D)
**Total modules:** 56 | **Clocks/update:** ~4500

The IMM does not pick one model — it **runs all three simultaneously** every cycle and weights their outputs by how well each model explains the current measurement. A Markov transition matrix governs how probability flows between models over time.

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         IMM-UKF PIPELINE                                     │
│                                                                              │
│  z(k)   ──────────────────────────────────────────────────────────────┐      │
│                                                                       │      │
│  μ(k-1) = [p_ct, p_si, p_bi]   (model probabilities from last step)   │      │
│                                                                       │      │
│  ┌──────────────────────────────────────────────────────────────┐     │      │
│  │  STEP 1: Model Mixing                                        │     │      │
│  │  x̂°ᵢ = Σⱼ μⱼ|ᵢ · x̂ⱼ     (mixed initial state per model)      │     │      │
│  │  P°ᵢ = Σⱼ μⱼ|ᵢ · (Pⱼ + (x̂ⱼ-x̂°ᵢ)(x̂ⱼ-x̂°ᵢ)ᵀ)                    │     │      │
│  │  μⱼ|ᵢ = pᵢⱼ·μⱼ / c̄ᵢ   (Markov mixing weights)                │     │      │
│  └──────────┬────────────────────┬────────────────────┬─────────┘     │      │
│             │                    │                    │               │      │
│             ▼                    ▼                    ▼               │      │
│   ┌─────────────────┐  ┌──────────────────┐  ┌──────────────────┐     │      │
│   │  CT Polar UKF   │  │  Singer UKF      │  │  Bicycle UKF     │     │      │
│   │    (9 states)   │  │  (9 states)      │  │  (7 states)      │     │      │
│   │  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐    │     │      │
│   │  │ Chol 9×9  │  │  │  │ Chol 9×9  │  │  │  │ Chol 7×7  │    │     │      │
│   │  │ Sigma 19  │  │  │  │ Sigma 19  │  │  │  │ Sigma 15  │    │     │      │
│   │  │ CT model  │  │  │  │Singer model│  │  │  │Bicycle mdl│   │     │      │
│   │  │ KF update │  │  │  │ KF update │  │  │  │ KF update │    │     │      │
│   │  └───────────┘  │  │  └───────────┘  │  │  └───────────┘    │     │      │
│   └────────┬────────┘  └────────┬─────────┘  └────────┬─────────┘     │      │
│            │  x̂₁,P₁,v₁,S₁      │  x̂₂,P₂,v₂,S₂      │  x̂₃,P₃,v₃,S₃│    |      │
│            └────────────────────┼────────────────────┘                │      │
│                                 ▼                       ◀─────────────┘      │
│  ┌──────────────────────────────────────────────────────────────┐            │
│  │  STEP 2: Likelihood Update                                   │            │
│  │  Λᵢ = N(v; 0, Sᵢ)  = exp(-½ vᵢᵀ Sᵢ⁻¹ vᵢ) / √|2πSᵢ|           │            │
│  │  μᵢ(k) = Λᵢ · c̄ᵢ / Σⱼ Λⱼ·c̄ⱼ    (normalised probability)      │            │
│  └──────────────────────────────┬───────────────────────────────┘            │
│                                 ▼                                            │
│  ┌──────────────────────────────────────────────────────────────┐            │
│  │  STEP 3: Output Fusion                                       │            │
│  │  x̂(k) = Σᵢ μᵢ · x̂ᵢ                (fused position)           │            │
│  │  P(k)  = Σᵢ μᵢ · (Pᵢ + (x̂ᵢ-x̂)(x̂ᵢ-x̂)ᵀ)  (fused covariance)    │            │
│  └──────────────────────────────────────────────────────────────┘            │
│                                                                              │
│  Output per cycle:  imm_x, imm_y, imm_z,  p_ct, p_si, p_bi                   │
│  State mappers:  7D ↔ 9D conversion for bicycle ↔ singer/CT mixing           │
└──────────────────────────────────────────────────────────────────────────────┘

  Key IMM modules:
  ├── imm_friend_top.vhd           top-level FSM orchestrator
  ├── imm_friend_state_mixer.vhd   Step 1: state mixing
  ├── imm_friend_covariance_mixer.vhd
  ├── imm_likelihood.vhd           Step 2: Gaussian likelihood
  ├── imm_prob_update.vhd          normalised probability update
  ├── imm_output_fusion.vhd        Step 3: weighted fusion
  ├── exp_lut.vhd / log_lut.vhd   LUTs for e^x / ln(x) in likelihood
  ├── state_mapper_7d_to_9d.vhd   bicycle → singer/CT padding
  ├── state_mapper_9d_to_7d.vhd   singer/CT → bicycle projection
  ├── singer_ukf_supreme_imm.vhd  Singer sub-filter (wrapped)
  ├── bicycle_ukf_supreme_imm.vhd Bicycle sub-filter (wrapped)
  └── ctra_ukf_supreme_imm.vhd    CT sub-filter (wrapped)
```

---

## 4. Results — Individual Filters

All filters tested on three datasets. Drone dataset uses known ground truth (fully reproducible). F1 datasets use real GPS telemetry.

### 4.1 Synthetic Drone Dataset (500 cycles, dt=20ms)

| Filter | States | RMSE (3D) | Cycles |
|--------|--------|-----------|--------|
| **CA UKF** | 9D | **0.895 m** | 500 |
| **Bicycle UKF** | 7D | **0.981 m** | 500 |
| Singer UKF | 9D | 0.995 m | 500 |
| CT Polar UKF | 9D | 1.324 m | 500 |

> CA UKF leads on the drone — the drone trajectory has near-constant acceleration segments where the CA model is optimal. Singer adds unnecessary τ-decay overhead.

### 4.2 F1 Monaco 2024 (750 cycles)

| Filter | RMSE (3D) | Notes |
|--------|-----------|-------|
| **Bicycle UKF** | **3.121 m** | Best — steering model fits car dynamics |
| CT Polar UKF | 18.829 m | Turns tracked but no steering constraint |
| Singer UKF | 2684 m | Diverges — CA-like model wrong for F1 |
| CA UKF | 14595 m | Diverges — constant accel violated at corners |

> **Bicycle UKF dramatically outperforms** Singer and CA on F1 data because its kinematic model reflects how a car actually steers through corners. Singer/CA have no concept of steering — they diverge once the car brakes and turns sharply.

### 4.3 F1 Silverstone 2024 (750 cycles)

| Filter | RMSE (3D) | Notes |
|--------|-----------|-------|
| **Bicycle UKF** | **3.940 m** | Best single model |
| CA UKF | 10887 m | Diverges |
| Singer UKF | 352772 m | Severe divergence |

### 4.4 Summary Heatmap

```
Dataset          │ CA UKF  │ Singer  │ Bicycle │ CT Polar│ IMM
─────────────────┼─────────┼─────────┼─────────┼─────────┼──────────
Drone 500cy      │  0.895m │  0.995m │  0.981m │  1.324m │   —
Monaco 750cy     │ 14595m  │  2684m  │  3.121m │ 18.83m  │   —
Silverstone 750cy│ 10887m  │ 352772m │  3.940m │    —    │   —
Abu Dhabi 4173cy │   —     │    —    │    —    │    —    │ 1.072m
```

### Drone Tracking — Singer UKF (500 cycles)

![Drone UKF Result](images/drone_ukf_result.png)

### Monaco 2024 — Singer UKF vs Ground Truth

![Monaco UKF Result](images/f1_monaco_ukf_result.png)

---

## 5. Key Result — IMM on Max Verstappen Abu Dhabi 2024

The IMM-UKF was run on **4,173 cycles** of real GPS telemetry from Max Verstappen's Abu Dhabi 2024 race lap.

![Verstappen Abu Dhabi IMM-UKF Result](images/verstappen_abu_dhabi_imm_ukf.png)

### Performance

| Metric | Value |
|--------|-------|
| **3D RMSE** | **1.072 m** |
| **2D RMSE (XY)** | **1.061 m** |
| **Z RMSE** | 0.156 m |
| X RMSE | 0.639 m |
| Y RMSE | 0.847 m |
| **Median error** | **0.120 m** |
| P90 error | 1.20 m |
| P99 error | 5.11 m |
| Cycles | 4,173 |

> Median of 0.12m means the filter is within 12cm of ground truth for more than half of the lap. The P99 spike of 5.11m occurs at sharp chicanes where all three sub-models are momentarily uncertain.

### VHDL Output Format (`datasets/abu_dhabi_verstappen/imm_vhdl_output.txt`)

```
Cycle 0: imm_x=0x00009728CC9C imm_y=0x0000DACF64EF imm_z=0xFFFFE7FFFDBE  p_ct=0x000000666666 p_si=0x0000004CCCCD p_bi=0x0000004CCCCD
Cycle 1: imm_x=0x0000971FFFD9 imm_y=0x0000DACDE27C imm_z=0xFFFFE7FFFF44  p_ct=0x00000010B5B4 p_si=0x000000E283C2 p_bi=0x0000000CC68A
...
```

All values are **Q24.24 hex** (48-bit signed). Convert to metres:

```python
def hex_to_m(h):
    v = int(h, 16)
    if v >= (1 << 47): v -= (1 << 48)   # sign extend
    return v / (2**24)                   # → metres
```

### Model Probability Evolution

The `p_ct`, `p_si`, `p_bi` columns show which model the IMM trusted at each cycle:
- **p_ct (CT Polar)** spikes during cornering — the filter detects a turning maneuver
- **p_si (Singer)** dominates on straights — smooth correlated acceleration
- **p_bi (Bicycle)** rises under heavy braking — steering angle dynamics

This adaptive weighting is why IMM achieves **1.072m** where individual filters diverge to thousands of metres on the same circuit.

---

---

## 6. Random Forest Object Classifier (VHDL)

A fully hardware-implemented **10-class trajectory object classifier** alongside the UKF filters. The classifier takes the UKF state vector outputs `(px, py, pz, vx, vy, vz, ax, ay, az)` and classifies the tracked object in real time using a **50-tree random forest** running entirely in Q24.24 fixed-point arithmetic — no floating-point units required.

```
UKF State Output                RF Classifier
(every update cycle)               (5-clock pipeline)
─────────────────       ┌──────────────────────────────────────────┐
px, py, pz              │  Feature Extraction (rf_feature_extract) │
vx, vy, vz  ──────────▶ │  9 features derived from velocity/accel  │
ax, ay, az              └──────────────┬───────────────────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────────────────┐
                        │  50 Decision Trees (rf_tree_rom)         │
                        │  Each tree: FSM, 1 node/clock            │
                        │  All 50 trees run in PARALLEL            │
                        │  Max depth: 15 (up to 1139 nodes/tree)   │
                        └──────────────┬───────────────────────────┘
                                       │  50 votes
                                       ▼
                        ┌──────────────────────────────────────────┐
                        │  Majority Voter + Confidence Gate        │
                        │  conf = winning_votes / 50               │
                        │  conf < threshold → uncertain output     │
                        └──────────────┬───────────────────────────┘
                                       │
                                       ▼
                        class_id [0..9] + confident/uncertain
```

### 6.1 Supported Classes

| ID | Class | Typical Speed | Altitude | Key Discriminator |
|----|-------|--------------|----------|-------------------|
| 0 | Drone | 5–25 m/s | 10–400 m | Medium accel, variable altitude |
| 1 | Missile | 200–600 m/s | 100–15000 m | Very high speed + guidance accel |
| 2 | Car | 5–55 m/s | 0 m | Ground-level, lateral accel |
| 3 | F1 Car | 30–90 m/s | 0 m | Ground-level, high lateral accel |
| 4 | Cat | 0.5–8 m/s | 0 m | High horiz_accel_ratio (erratic) |
| 5 | Bird | 5–20 m/s | 5–500 m | Low accel, variable altitude |
| 6 | Airplane | 200–260 m/s | 9000–12000 m | Extreme altitude + near-zero accel |
| 7 | Ball | 5–40 m/s | 0–80 m | az ≈ −9.81 (gravity dominated) |
| 8 | Artillery | 300–900 m/s | 0–15000 m | High speed, zero horiz_accel (ballistic) |
| 9 | Pedestrian | 0.5–8 m/s | 0 m | Very low speed + bipedal gait pattern |

### 6.2 Feature Engineering (9 Features, Q24.24)

Features are extracted from the UKF state in 5 clock cycles by `rf_feature_extract.vhd`:

| # | Name | Formula | Separates |
|---|------|---------|-----------|
| f0 | speed_sq | vx²+vy²+vz² | Slow (ped/cat) vs fast (missile/artillery) |
| f1 | altitude | pz | Ground-level vs airborne |
| f2 | horiz_speed_sq | vx²+vy² | Horizontal velocity magnitude |
| f3 | vert_speed_abs | \|vz\| | Climbing/diving targets |
| f4 | accel_mag_sq | ax²+ay²+az² | Passive vs maneuvering targets |
| f5 | horiz_accel_sq | ax²+ay² | Guided (missile) vs ballistic (artillery) |
| f6 | climb_rate_sign | sign(vz·az) | Accelerating up vs decelerating |
| f7 | altitude_abs | \|pz\| | Signed altitude symmetry |
| f8 | horiz_accel_ratio | horiz_accel_sq / (speed_sq + 1) | Cat (0–8) vs Car (0–1) vs Pedestrian (0–0.5) |

**f8 is the critical new feature:** normalising lateral acceleration by speed clearly separates Cat (erratic, low-speed lateral bursts), Car (smooth turns at speed), and Pedestrian (near-zero ratio) — three classes that are identical at altitude=0 without it.

Division in Q24.24: `(f5 << 24) / (f0 + 2^24)` using 96-bit intermediates, no DSP divider needed.

### 6.3 VHDL Architecture (5 modules)

```
random_forest/src/
├── rf_fixed_point_pkg.vhd    package: constants (N_TREES=50, N_CLASSES=10, N_FEATURES=9, Q=24)
├── rf_feature_extract.vhd    5-clock pipeline: 9D state → 9 Q24.24 features
├── rf_tree_rom.vhd           auto-generated: 50 trees × ≤1139 nodes (Q24.24 thresholds)
├── rf_tree_engine.vhd        FSM traversal: 1 node/clock, latch-based done signal
├── rf_majority_voter.vhd     reduce 50 votes → winning class + confidence count
└── rf_classifier_top.vhd     top-level FSM + confidence gate (CONF_THRESHOLD_G generic)
```

**Done-latch mechanism:** All 50 FSM trees run in parallel but finish at different clock cycles (depth varies per tree). Each tree's `done` pulse is latched in `tree_done_latch`; the vector is cleared at `trees_start`. `all_trees_done` fires only once all 50 latches are set — prevents the AND-of-pulses false-negative that occurs when done pulses don't align.

**Confidence gate:** `CONF_THRESHOLD_G` (default=35/50 = 70%) gates the `valid` output. When fewer than 35 trees agree, `uncertain` fires instead of `valid` — the classifier abstains rather than giving a wrong answer.

### 6.4 Training Pipeline

```bash
cd random_forest

# 1. Generate 60,000-sample training set (6000/class)
python scripts/generate_training_data.py

# 2. Grid search {10,20,50} trees × {10,12,15} depth → pick best
#    Export winning model to data/trees_export.json (Q24.24 thresholds)
python scripts/train_random_forest.py

# 3. Regenerate VHDL ROMs from JSON
python scripts/export_rf_to_vhdl.py

# 4. Generate 2000-vector testbench (200/class)
python scripts/generate_testbench.py

# 5. Compile + simulate
mkdir -p build
ghdl -a --std=08 --workdir=build src/rf_fixed_point_pkg.vhd src/rf_tree_rom.vhd \
    src/rf_tree_engine.vhd src/rf_majority_voter.vhd src/rf_feature_extract.vhd \
    src/rf_classifier_top.vhd testbenches/rf_classifier_tb.vhd
ghdl -e --std=08 --workdir=build rf_classifier_tb
ghdl -r --std=08 --workdir=build rf_classifier_tb --stop-time=5000us
```

Or use the convenience script:
```bash
./run_simulation.sh          # run with existing model
./run_simulation.sh retrain  # regenerate training data + retrain + simulate
```

### 6.5 Results — 2000-Vector GHDL Simulation

**Model:** 50 trees, max depth 15, trained on 60,000 samples (6,000/class)
**Test:** 2,000 vectors (200/class), confidence threshold = 35/50 trees (70%)
**Simulation time:** 400 µs of simulated time for all 2,000 predictions

| Metric | Value |
|--------|-------|
| **VHDL confident accuracy** | **1902 / 1963 = 96.9%** |
| Python sklearn baseline | 98.2% (1964/2000) |
| Abstained (uncertain, conf < 70%) | 37 / 2000 (1.85%) |
| Wrong while confident | 61 / 2000 |

**Per-class breakdown (VHDL vs Python reference):**

| Class | Correct | Total | Uncertain | Accuracy |
|-------|---------|-------|-----------|----------|
| Drone | 200 | 200 | 0 | **100%** |
| Missile | 197 | 200 | 1 | 99% |
| Car | 154 | 200 | 23 | 77% |
| F1 Car | 199 | 200 | 0 | 99.5% |
| Cat | 199 | 200 | 0 | 99.5% |
| Bird | 199 | 200 | 0 | 99.5% |
| Airplane | 199 | 200 | 0 | 99.5% |
| Ball | 199 | 200 | 0 | 99.5% |
| Artillery | 199 | 200 | 0 | 99.5% |
| Pedestrian | 157 | 200 | 13 | 78.5% |

**8 of 10 classes achieve ≥99% accuracy.** The Car/Pedestrian overlap (both ground-level, pz≈0, low speed) accounts for 89 of the 98 total imperfect results. Many of these are samples where Python sklearn also predicts incorrectly — the confusion is intrinsic to the feature space, not a fixed-point artefact.

Artillery and Ball are perfectly separated (99.5%) despite both being ballistic — the key discriminator is speed (Artillery 300–900 m/s vs Ball 5–40 m/s).

Missile vs Airplane are perfectly separated (99%/99.5%) despite similar speeds — `altitude` (f1) cleanly discriminates: Airplane at 9000–12000 m vs Missile at mixed altitudes.

Full per-sample log: `random_forest/results/rf_classifier_results.txt`

### 6.6 Fixed-Point Quantisation

All tree thresholds are stored in **Q24.24** (48-bit signed). The Python exporter converts sklearn `float64` thresholds:

```python
thresh_q2424 = int(thresh_float * 2**24)
# Clamped to signed 48-bit: max ±140,737,488,355,327
```

The feature extractor computes in Q24.24 throughout. Division for f8 uses 96-bit numerator to preserve precision:

```vhdl
v_num96 := shift_left(resize(f5_reg, 96), Q);   -- horiz_accel_sq << 24
v_den96 := resize(f0_reg + Q_SCALE, 96);         -- speed_sq + 2^24
v_res96 := v_num96 / v_den96;                    -- Q24.24 ratio
```

## 7. Datasets

```
datasets/
├── abu_dhabi_verstappen/
│   ├── abu_dhabi_verstappen_4173cycles.csv   ← GT + GPS measurements
│   └── imm_vhdl_output.txt                  ← ZCU106 FPGA output (hex)
├── f1_monaco_2024_750cycles.csv
└── synthetic_drone/
    └── synthetic_drone_500cycles.csv
```

**CSV columns (all datasets):**
```
cycle, time, gt_x_pos, gt_y_pos, gt_z_pos,
meas_x, meas_y, meas_z,
meas_x_q24, meas_y_q24, meas_z_q24
```

**Drone CSV also includes:** `gt_x_vel, gt_y_vel, gt_z_vel, gt_x_acc, gt_y_acc, gt_z_acc, noise_x, noise_y, noise_z`

---

## 8. Testbenches

Each testbench has measurement constants embedded — no file I/O, works in any simulator.

```
testbenches/
├── singers_model/
│   ├── ukf_real_synthetic_drone_500cycles_tb.vhd
│   ├── ukf_real_f1_monaco_2024_750cycles_tb.vhd
│   └── ukf_real_f1_silverstone_2024_750cycles_tb.vhd
├── bicycle_ukf/
│   ├── bicycle_ukf_synthetic_drone_500cycles_tb.vhd
│   ├── bicycle_ukf_f1_monaco_2024_750cycles_tb.vhd
│   └── bicycle_ukf_f1_silverstone_2024_750cycles_tb.vhd
├── ct_polar/
│   ├── ct_polar_ukf_synthetic_drone_500cycles_tb.vhd
│   ├── ct_polar_ukf_f1_monaco_2024_750cycles_tb.vhd
│   └── ct_polar_ukf_f1_silverstone_2024_750cycles_tb.vhd
├── ctra/
│   ├── ctra_ukf_synthetic_drone_500cycles_tb.vhd
│   ├── ctra_ukf_f1_monaco_2024_750cycles_tb.vhd
│   └── ctra_ukf_f1_silverstone_2024_750cycles_tb.vhd
└── imm/
    ├── imm_friend_abu_dhabi_4173_tb.vhd       ← Verstappen full lap
    ├── imm_friend_monaco_750_tb.vhd
    └── imm_friend_monaco_10_tb.vhd
```

**Run with GHDL (example: Bicycle UKF, Monaco):**
```bash
ghdl -a src/bicycle_ukf/*.vhd testbenches/bicycle_ukf/bicycle_ukf_f1_monaco_2024_750cycles_tb.vhd
ghdl -e bicycle_ukf_tb
ghdl -r bicycle_ukf_tb --stop-time=10ms > output.txt
```

**Run with Vivado xsim (example: IMM, Abu Dhabi):**
```bash
xvhdl src/imm/*.vhd src/imm/imm/*.vhd testbenches/imm/imm_friend_abu_dhabi_4173_tb.vhd
xelab imm_friend_tb -s imm_sim
xsim imm_sim -runall
```

---

## 9. Fixed-Point Format

All signals use **Q24.24** — 24 integer bits + 24 fractional bits in a 48-bit signed integer:

```
 Bit 47  │  Bits 46–24 (integer)  │  Bits 23–0 (fractional)
  sign   │      ±8,388,607        │      2⁻²⁴ ≈ 59.6 nm

Range:      ±8,388,607 m  (~±8400 km — covers any track)
Resolution: 59.6 nm
```

**Convert float ↔ Q24.24:**
```python
SCALE = 2**24          # = 16,777,216

# float (metres) → Q24.24 integer  (for testbench input constants)
q = int(float_metres * SCALE)

# Q24.24 hex (VHDL output) → float metres
def hex_to_m(h):
    v = int(h, 16)
    if v >= (1 << 47): v -= (1 << 48)
    return v / SCALE
```

**144-bit intermediate precision** is used inside `state_update_Nd.vhd` for the APAT and KRK^T products before the final covariance write — this prevents truncation cascade that would otherwise add ~0.5m to the RMSE.

---

## 10. Hardware

**Target:** Xilinx Zynq UltraScale+ ZCU106
**Simulator:** Vivado xsim / GHDL
**Clock:** 100 MHz (10 ns)

| Filter | States | Sigma pts | Modules | Clocks/update | Updates/sec @ 100MHz |
|--------|--------|-----------|---------|---------------|----------------------|
| CA UKF | 9D | 19 | 31 | ~1,200 | 83,333 |
| Singer UKF | 9D | 19 | 41 | ~1,300 | 76,923 |
| CTRA UKF | 7D | 15 | 15 | ~900 | 111,111 |
| Bicycle UKF | 7D | 15 | 15 | ~840 | 119,047 |
| CT Polar UKF | 9D | 19 | 15 | ~1,543 | 64,800 |
| IMM (3-model) | multi | — | 56 | ~4,500 | 22,222 |
| **Total** | | | **173** | | |

All variants run comfortably within a 50 Hz GPS update rate (20 ms = **2,000,000 cycles** available @ 100 MHz).

---

## References

- Wan & van der Merwe, "The Unscented Kalman Filter," *Kalman Filtering and Neural Networks*, 2001
- Singer, "Estimating Optimal Tracking Filter Performance for Manned Maneuvering Targets," *IEEE Trans. AES*, 1970
- Blom & Bar-Shalom, "The Interacting Multiple Model Algorithm," *IEEE Trans. AC*, 1988
- Rajamani, *Vehicle Dynamics and Control*, 2nd ed., Springer, 2011 (bicycle model)
