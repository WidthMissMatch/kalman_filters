#!/usr/bin/env python3
"""
Diagnose Vehicle Dataset Divergence at Cycle 287

Extracts intermediate UKF values from Python implementation at the divergence
point to compare with VHDL debug outputs.

Focus: Covariance update components (APAT, KRK) to verify double-shift bug hypothesis.
"""

import numpy as np
import pandas as pd
from pathlib import Path
import sys

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))
from ukf_9d_ca_reference import UKF_9D_CA

def diagnose_cycle_287():
    """Run Python UKF and extract intermediate values at divergence point"""

    base_dir = Path(__file__).parent.parent

    # Load vehicle dataset
    dataset_file = base_dir / "test_data" / "real_world" / "synthetic_vehicle_600cycles.csv"
    df = pd.read_csv(dataset_file)

    print("=" * 80)
    print("VEHICLE DATASET CYCLE 287 DIVERGENCE ANALYSIS")
    print("=" * 80)
    print()
    print(f"Dataset: {dataset_file.name}")
    print(f"Total cycles: {len(df)}")
    print()

    # Initialize UKF with same parameters as VHDL
    ukf = UKF_9D_CA(dt=0.02, q_power=5.0, r_diag=1.0)

    # Track cycles to analyze
    target_cycles = [285, 287, 290]

    # Storage for intermediate values
    diagnostics = []

    print("Running Python UKF with intermediate value extraction...")
    print()

    for cycle in range(min(300, len(df))):  # Run to cycle 300 to see recovery
        # Get measurement
        row = df.iloc[cycle]
        z_meas = np.array([row['meas_x'], row['meas_y'], row['meas_z']])

        # Run UKF and extract internals
        if cycle in target_cycles:
            print(f"{'='*80}")
            print(f"CYCLE {cycle} - Extracting Intermediate Values")
            print(f"{'='*80}")

            # Store state before update
            x_before = ukf.x.copy()
            P_before = ukf.P.copy()

            # Run prediction
            x_pred, P_pred = ukf.predict()

            # Extract measurement sigma points
            z_sigma = np.zeros((ukf.n_sigma, ukf.m))
            for i in range(ukf.n_sigma):
                z_sigma[i] = ukf.h_measurement_model(ukf.sigma_points_pred[i])

            # Predicted measurement mean
            z_pred = np.zeros(ukf.m)
            for i in range(ukf.n_sigma):
                z_pred += ukf.Wm[i] * z_sigma[i]

            # Innovation covariance S
            S = np.zeros((ukf.m, ukf.m))
            for i in range(ukf.n_sigma):
                diff = z_sigma[i] - z_pred
                S += ukf.Wc[i] * np.outer(diff, diff)
            S += ukf.R

            # Cross-covariance Pxz
            Pxz = np.zeros((ukf.n, ukf.m))
            for i in range(ukf.n_sigma):
                diff_x = ukf.sigma_points_pred[i] - x_pred
                diff_z = z_sigma[i] - z_pred
                Pxz += ukf.Wc[i] * np.outer(diff_x, diff_z)

            # Kalman gain K
            K = Pxz @ np.linalg.inv(S)

            # Innovation
            nu = z_meas - z_pred

            # State update
            x_upd = x_pred + K @ nu

            # Covariance update (Joseph form)
            H = np.array([[1, 0, 0, 0, 0, 0, 0, 0, 0],
                          [0, 0, 0, 1, 0, 0, 0, 0, 0],
                          [0, 0, 0, 0, 0, 0, 1, 0, 0]])
            I = np.eye(ukf.n)
            A = I - K @ H

            # CRITICAL: Compute APAT and KRK separately
            APAT = A @ P_pred @ A.T
            KRK = K @ ukf.R @ K.T

            # Final covariance
            P_upd = APAT + KRK

            # Update UKF state
            ukf.x = x_upd
            ukf.P = P_upd

            # Store diagnostics
            diagnostic = {
                'cycle': cycle,
                'P_pred_11': P_pred[0, 0],
                'P_pred_44': P_pred[3, 3],
                'P_pred_77': P_pred[6, 6],
                'K_11': K[0, 0],
                'K_12': K[0, 1],
                'K_13': K[0, 2],
                'K_41': K[3, 0],
                'K_42': K[3, 1],
                'K_43': K[3, 2],
                'APAT_11': APAT[0, 0],
                'APAT_44': APAT[3, 3],
                'APAT_77': APAT[6, 6],
                'KRK_11': KRK[0, 0],
                'KRK_44': KRK[3, 3],
                'KRK_77': KRK[6, 6],
                'P_upd_11': P_upd[0, 0],
                'P_upd_44': P_upd[3, 3],
                'P_upd_77': P_upd[6, 6],
                'x_pos': x_upd[0],
                'y_pos': x_upd[3],
                'z_pos': x_upd[6]
            }

            diagnostics.append(diagnostic)

            # Print key values
            print(f"\n**Predicted Covariance (P_pred):**")
            print(f"  P11 (x_pos variance): {P_pred[0,0]:.8f}")
            print(f"  P44 (y_pos variance): {P_pred[3,3]:.8f}")
            print(f"  P77 (z_pos variance): {P_pred[6,6]:.8f}")

            print(f"\n**Kalman Gain (K):**")
            print(f"  K[0,0] (x_pos ← meas_x): {K[0,0]:.8f}")
            print(f"  K[0,1] (x_pos ← meas_y): {K[0,1]:.8f}")
            print(f"  K[0,2] (x_pos ← meas_z): {K[0,2]:.8f}")
            print(f"  K[3,0] (y_pos ← meas_x): {K[3,0]:.8f}")
            print(f"  K[3,1] (y_pos ← meas_y): {K[3,1]:.8f}")
            print(f"  K[3,2] (y_pos ← meas_z): {K[3,2]:.8f}")

            print(f"\n**APAT Matrix (A·P_pred·A^T):**")
            print(f"  APAT[0,0]: {APAT[0,0]:.8f}")
            print(f"  APAT[3,3]: {APAT[3,3]:.8f}")
            print(f"  APAT[6,6]: {APAT[6,6]:.8f}")

            print(f"\n**KRK Matrix (K·R·K^T):**")
            print(f"  KRK[0,0]: {KRK[0,0]:.8f}")
            print(f"  KRK[3,3]: {KRK[3,3]:.8f}")
            print(f"  KRK[6,6]: {KRK[6,6]:.8f}")

            print(f"\n**Updated Covariance (P_upd = APAT + KRK):**")
            print(f"  P_upd[0,0]: {P_upd[0,0]:.8f}")
            print(f"  P_upd[3,3]: {P_upd[3,3]:.8f}")
            print(f"  P_upd[6,6]: {P_upd[6,6]:.8f}")

            print(f"\n**Updated State:**")
            print(f"  x_pos: {x_upd[0]:.6f} m")
            print(f"  y_pos: {x_upd[3]:.6f} m")
            print(f"  z_pos: {x_upd[6]:.6f} m")

            print(f"\n**Ground Truth (Cycle {cycle+1}):**")
            if cycle + 1 < len(df):
                gt_next = df.iloc[cycle + 1]
                print(f"  gt_x_pos: {gt_next['gt_x_pos']:.6f} m")
                print(f"  gt_y_pos: {gt_next['gt_y_pos']:.6f} m")
                print(f"  gt_z_pos: {gt_next['gt_z_pos']:.6f} m")
            print()

        else:
            # Normal processing for other cycles
            x_upd, P_upd, nu = ukf.process_measurement(z_meas)

    # Save diagnostics to CSV
    output_dir = base_dir / "results" / "diagnostics"
    output_dir.mkdir(parents=True, exist_ok=True)

    diag_df = pd.DataFrame(diagnostics)
    output_file = output_dir / "python_cycle_287_diagnostics.csv"
    diag_df.to_csv(output_file, index=False, float_format='%.10f')

    print(f"\n{'='*80}")
    print(f"Diagnostics saved to: {output_file}")
    print(f"{'='*80}")
    print()

    # Generate comparison instructions
    print("NEXT STEPS FOR VHDL COMPARISON:")
    print("-" * 80)
    print("1. Add debug signals to state_update_3d.vhd:")
    print("   - debug_apat_11, debug_krk_11, debug_p11_upd")
    print()
    print("2. Run VHDL simulation with debug logging at cycles 285, 287, 290")
    print()
    print("3. Compare VHDL vs Python:")
    print(f"   Python APAT[0,0] at Cycle 287: {diagnostics[1]['APAT_11']:.10f}")
    print(f"   Python KRK[0,0] at Cycle 287:  {diagnostics[1]['KRK_11']:.10f}")
    print()
    print("4. Expected VHDL values (Q48.48 format):")
    print(f"   VHDL APAT_11 should be: {int(diagnostics[1]['APAT_11'] * (2**48))}")
    print(f"   VHDL KRK_11 should be:  {int(diagnostics[1]['KRK_11'] * (2**48))}")
    print()
    print("5. If VHDL KRK is ~16M× smaller, double-shift bug confirmed!")
    print(f"   (KRK would be: {int(diagnostics[1]['KRK_11'] * (2**24))} instead)")
    print()

    return diag_df

if __name__ == "__main__":
    diagnose_cycle_287()
