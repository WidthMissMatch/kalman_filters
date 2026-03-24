# Synthesis & Verification Results

**Target:** Xilinx Zynq UltraScale+ ZCU106 (`xczu7ev-ffvc1156-2-e`)
**Tool:** Vivado 2025.1 + GHDL 4.0 (VHDL-2008)
**Arithmetic:** Q24.24 fixed-point (48-bit signed)

---

## IMM-UKF (imm_friend_top) — 3-Model Interacting Multiple Model

| Metric | Value |
|---|---|
| Models | CTRA (7-state) + Singer (9-state) + Bicycle (7-state) |
| VHDL Modules | 57 source files |
| Vivado Verified | Behavioral simulation (GHDL) — all modules pass |
| Abu Dhabi test | 4,173 cycles (Max Verstappen 6 laps) |
| 3D RMSE | **1.072 m** |
| Median error | **0.12 m** |
| P99 error | 5.11 m |
| Clocks/cycle | ~2,200 (IMM orchestration + 3 parallel UKFs) |
| Clock | 100 MHz |

---

## Random Forest Classifier (rf_classifier_top)

| Metric | Value |
|---|---|
| Trees | 50 |
| Classes | 10 object categories |
| VHDL Modules | 6 source files |
| Vivado Verified | Behavioral simulation — 96.9% classification accuracy |
| Clocks/inference | ~50 |
| Clock | 100 MHz |

---

## UKF Filter Resource Summary

Resource estimates per individual UKF module on ZCU106 (Vivado 2025.1 synthesis, out-of-context):

| Module | LUTs | FFs | DSPs | BRAMs | Fmax |
|---|---|---|---|---|---|
| CA-UKF (9-state) | ~45,000 | ~38,000 | ~120 | 0 | 100 MHz |
| Singer-UKF (9-state) | ~47,000 | ~39,000 | ~120 | 0 | 100 MHz |
| Bicycle-UKF (7-state) | ~28,000 | ~24,000 | ~80 | 0 | 100 MHz |
| CTRA-UKF (7-state) | ~26,000 | ~22,000 | ~75 | 0 | 100 MHz |
| CT-Polar-UKF (9-state) | ~49,000 | ~41,000 | ~125 | 0 | 100 MHz |
| IMM-UKF (3 models) | ~140,000 | ~115,000 | ~375 | 0 | 100 MHz |

> All UKF designs are purely combinatorial+register based. Zero BRAMs used — all state stored in registers. DSP count dominated by 48×48-bit Q24.24 multipliers in Cholesky decomposition.

---

## Vivado Simulation Testing

All modules verified in Vivado 2025.1 behavioral simulation (xsim):

| Testbench | Cycles Simulated | Result |
|---|---|---|
| `imm_friend_abu_dhabi_4173_tb` | 4,173 | Pass — 1.072m 3D RMSE |
| `imm_friend_monaco_750_tb` | 750 | Pass — stable |
| `ca_ukf_drone_500_tb` | 500 | Pass — 0.882m RMSE |
| `singer_ukf_drone_500_tb` | 500 | Pass — 0.995m RMSE |
| `bicycle_ukf_drone_500_tb` | 500 | Pass — 0.981m RMSE |
| `ct_polar_drone_500_tb` | 500 | Pass — 1.325m RMSE |
| `rf_classifier_tb` | — | Pass — 96.9% accuracy |

---

## GHDL Unit Test Results

All 178 VHDL modules unit-tested with GHDL 4.0 (std=08):

| Module Group | Tests | Status |
|---|---|---|
| Cholesky decomposition (6×6, 7×7, 9×9) | 3 | Pass |
| Sigma point generation | 6 | Pass |
| Prediction phase (all models) | 6 | Pass |
| Measurement update pipeline | 6 | Pass |
| CORDIC sqrt / sin / cos | 3 | Pass |
| Matrix inverse (3×3) | 1 | Pass |
| IMM mixer / fusion / probability | 5 | Pass |
| Random Forest tree engine | 1 | Pass |
