#!/usr/bin/env python3
"""
SR-UKF Reference Implementation (CA Model) - Floating-Point Python
Matches VHDL sr_ukf_supreme_ca_3d pipeline exactly.

Pipeline per cycle:
  1. sigma_3d:           L_current -> chi(19)
  2. predicti_ca3d:      chi -> chi_pred(19) via F matrix
  3. predicted_mean_3d:  chi_pred -> x_mean(9)
  4. qr_decomp_9x19:    chi_pred[1:18] + x_mean -> L_qr (LQ factorization)
  5. chol_rank1_update:  L_qr + W0*(chi0_pred - x_mean) -> L_w0
  6. process_noise_rank1: L_w0 + Lq columns -> L_pred
  7. measurement_mean:   chi_pred -> z_mean
  8. innovation:         z_meas - z_mean -> nu
  9. cross_covariance:   chi_pred + means -> Pxz
  10. innov_covariance:  chi_pred + z_mean -> S_yy
  11. kalman_gain:       Pxz * S_yy^-1 -> K
  12. potter_update:     x + K*nu -> x_upd, L - choldowndate(K*sqrt(R)) -> L_upd

Parameters (matching VHDL):
  alpha=1.0, beta=2, kappa=0, n=9, dt=1.0
  P_INIT = diag(5.0, 20.0, 0.01, 5.0, 20.0, 0.01, 5.0, 20.0, 0.01)
  Q_POS=0.05, Q_VEL=0.0005, Q_ACC=0.00001
  R = diag(0.25, 0.25, 0.25)
"""

import numpy as np
import re
import sys
import os

# ============================================================================
# Parameters (matching VHDL exactly)
# ============================================================================
N = 9           # state dimension
N_SIGMA = 2*N+1  # 19 sigma points
DT = 0.02  # 20ms = 50Hz, matching VHDL predicti_ca3d

ALPHA = 1.0
BETA = 2.0
KAPPA = 0.0

LAMBDA = ALPHA**2 * (N + KAPPA) - N  # = 0
GAMMA = np.sqrt(N + LAMBDA)  # = 3.0

# UKF weights
W_M = np.zeros(N_SIGMA)
W_C = np.zeros(N_SIGMA)
W_M[0] = LAMBDA / (N + LAMBDA)  # = 0
W_C[0] = LAMBDA / (N + LAMBDA) + (1 - ALPHA**2 + BETA)  # = 2.0
for i in range(1, N_SIGMA):
    W_M[i] = 1.0 / (2.0 * (N + LAMBDA))  # = 1/18
    W_C[i] = 1.0 / (2.0 * (N + LAMBDA))  # = 1/18

# Initial covariance
P_INIT = np.diag([5.0, 20.0, 0.01, 5.0, 20.0, 0.01, 5.0, 20.0, 0.01])
L_INIT = np.linalg.cholesky(P_INIT)  # Lower triangular

# Process noise (diagonal)
Q_DIAG = np.array([0.05, 0.00025, 0.00001, 0.05, 0.00025, 0.00001, 0.05, 0.00025, 0.00001])
Q = np.diag(Q_DIAG)
LQ = np.diag(np.sqrt(Q_DIAG))  # Cholesky factor of Q

# Measurement noise
R = np.diag([0.25, 0.25, 0.25])

# CA state transition matrix (dt=1)
F = np.eye(N)
for axis in range(3):
    base = 3 * axis
    F[base, base+1] = DT
    F[base, base+2] = 0.5 * DT**2
    F[base+1, base+2] = DT

# Measurement matrix (position only)
H = np.zeros((3, N))
H[0, 0] = 1.0  # x_pos
H[1, 3] = 1.0  # y_pos
H[2, 6] = 1.0  # z_pos


# ============================================================================
# Cholesky rank-1 update/downdate (matching VHDL Givens rotation algorithm)
# ============================================================================
def cholupdate(L, u):
    """Rank-1 Cholesky update: L_new such that L_new @ L_new.T = L @ L.T + u @ u.T"""
    L_new = L.copy()
    u_new = u.copy()
    n = len(u)
    for col in range(n):
        r = np.sqrt(L_new[col, col]**2 + u_new[col]**2)
        if r == 0:
            continue
        c = L_new[col, col] / r
        s = u_new[col] / r
        L_new[col, col] = r
        for row in range(col + 1, n):
            temp_L = c * L_new[row, col] + s * u_new[row]
            temp_u = c * u_new[row] - s * L_new[row, col]
            L_new[row, col] = temp_L
            u_new[row] = temp_u
    return L_new


def choldowndate(L, w):
    """Rank-1 Cholesky downdate: L_new such that L_new @ L_new.T = L @ L.T - w @ w.T"""
    L_new = L.copy()
    w_new = w.copy()
    n = len(w)
    for col in range(n):
        r_sq = L_new[col, col]**2 - w_new[col]**2
        if r_sq <= 0:
            # Downdate would break positive definiteness
            r = np.sqrt(abs(r_sq)) if r_sq < 0 else 0
            if r == 0:
                continue
        else:
            r = np.sqrt(r_sq)
        c = r / L_new[col, col]
        s = w_new[col] / L_new[col, col]
        L_new[col, col] = r
        for row in range(col + 1, n):
            temp_L = (L_new[row, col] - s * w_new[row]) / c if c != 0 else L_new[row, col]
            temp_w = c * w_new[row] - s * L_new[row, col] if True else w_new[row]
            # Correct downdate Givens:
            # L_new[row,col] = (L[row,col] - s*w[row]) / c
            # w_new[row] = c*w[row] - s*L[row,col]
            w_new[row] = temp_w
            L_new[row, col] = temp_L
    return L_new


# ============================================================================
# SR-UKF prediction phase (matching VHDL pipeline exactly)
# ============================================================================
def sr_ukf_predict(x, L, verbose=False):
    """
    SR-UKF prediction phase.
    Returns: x_pred, L_pred, chi_pred (19x9)
    """
    # Step 1: Generate sigma points (sigma_3d)
    chi = np.zeros((N_SIGMA, N))
    chi[0] = x
    for i in range(N):
        chi[i + 1] = x + GAMMA * L[:, i]      # chi_{1..9}
        chi[i + 1 + N] = x - GAMMA * L[:, i]  # chi_{10..18}

    # Step 2: Propagate through process model (predicti_ca3d)
    chi_pred = np.zeros((N_SIGMA, N))
    for i in range(N_SIGMA):
        chi_pred[i] = F @ chi[i]

    # Step 3: Compute predicted mean (predicted_mean_3d)
    x_pred = np.zeros(N)
    for i in range(N_SIGMA):
        x_pred += W_M[i] * chi_pred[i]

    # Step 4: QR decomposition (qr_decomp_9x19)
    # Build weighted deviation matrix A (9x18) - chi1..chi18 only
    sqrt_wc = np.sqrt(W_C[1])  # = sqrt(1/18)
    A = np.zeros((N, N_SIGMA - 1))  # 9x18
    for j in range(N_SIGMA - 1):
        A[:, j] = sqrt_wc * (chi_pred[j + 1] - x_pred)

    # LQ factorization: A = L_qr * Q^T
    # Equivalent to QR of A^T: A^T = Q * R, L_qr = R^T
    Q_mat, R = np.linalg.qr(A.T, mode='reduced')  # A^T is 18x9
    L_qr = R.T  # 9x9 lower triangular

    # Ensure positive diagonal (VHDL does abs(alpha_diag))
    for i in range(N):
        if L_qr[i, i] < 0:
            L_qr[i, :] *= -1  # Flip row sign

    if verbose:
        print(f"  L_qr diag: [{', '.join(f'{L_qr[i,i]:.6f}' for i in range(N))}]")

    # Step 5: W0 rank-1 update (cholesky_rank1_update)
    # W_c[0] = 2.0 > 0, so this is an UPDATE
    sqrt_wc0 = np.sqrt(abs(W_C[0]))  # = sqrt(2.0) = 1.4142
    w0_vec = sqrt_wc0 * (chi_pred[0] - x_pred)
    L_w0 = cholupdate(L_qr, w0_vec)

    if verbose:
        print(f"  L_w0 diag: [{', '.join(f'{L_w0[i,i]:.6f}' for i in range(N))}]")

    # Step 6: Process noise rank-1 updates (process_noise_rank1_ca_3d)
    # 9 sequential rank-1 updates, one per column of Lq
    L_pred = L_w0.copy()
    for col in range(N):
        L_pred = cholupdate(L_pred, LQ[:, col])

    if verbose:
        print(f"  L_pred diag: [{', '.join(f'{L_pred[i,i]:.6f}' for i in range(N))}]")

    return x_pred, L_pred, chi_pred


# ============================================================================
# SR-UKF measurement update phase (matching VHDL pipeline exactly)
# ============================================================================
def sr_ukf_update(x_pred, L_pred, chi_pred, z_meas, verbose=False):
    """
    SR-UKF measurement update phase.
    Returns: x_upd, L_upd
    """
    n_z = 3  # measurement dimension

    # Step 7: Measurement mean (measurement_mean_3d)
    # Measurement model h(x) = [x_pos, y_pos, z_pos] = H @ x
    z_sigma = np.zeros((N_SIGMA, n_z))
    for i in range(N_SIGMA):
        z_sigma[i] = H @ chi_pred[i]

    z_mean = np.zeros(n_z)
    for i in range(N_SIGMA):
        z_mean += W_M[i] * z_sigma[i]

    # Step 8: Innovation (innovation_3d)
    nu = z_meas - z_mean

    # Step 9: Cross-covariance (cross_covariance_3d)
    Pxz = np.zeros((N, n_z))
    for i in range(N_SIGMA):
        dx = chi_pred[i] - x_pred
        dz = z_sigma[i] - z_mean
        Pxz += W_C[i] * np.outer(dx, dz)

    # Step 10: Innovation covariance (innovation_covariance_3d)
    S_yy = np.zeros((n_z, n_z))
    for i in range(N_SIGMA):
        dz = z_sigma[i] - z_mean
        S_yy += W_C[i] * np.outer(dz, dz)
    S_yy += R

    # Step 11: Kalman gain (kalman_gain_3d)
    K = Pxz @ np.linalg.inv(S_yy)

    if verbose:
        print(f"  K[:,0]: [{', '.join(f'{K[i,0]:.6f}' for i in range(N))}]")
        print(f"  nu: [{nu[0]:.6f}, {nu[1]:.6f}, {nu[2]:.6f}]")

    # Step 12: State update (state_update_potter_3d)
    x_upd = x_pred + K @ nu

    # Covariance update via 3 rank-1 Cholesky downdates
    # CORRECT: w_i = K_col_i * sqrt(S_ii)  (NOT sqrt(R_ii)!)
    # P_upd = P_pred - K*S*K^T, so downdate vectors = columns of K*chol(S)
    # For diagonal S: w_i = K[:,i] * sqrt(S_ii)
    #
    # BUG IN VHDL: uses sqrt(R_ii) instead of sqrt(S_ii)
    # This under-removes covariance, causing L to grow unbounded.
    L_upd = L_pred.copy()
    for m in range(n_z):
        sqrt_s = np.sqrt(S_yy[m, m])  # CORRECT: use S, not R
        w = K[:, m] * sqrt_s
        L_upd = choldowndate(L_upd, w)

    if verbose:
        print(f"  L_upd diag: [{', '.join(f'{L_upd[i,i]:.6f}' for i in range(N))}]")

    return x_upd, L_upd


# ============================================================================
# Load measurement data from VHDL testbench
# ============================================================================
def load_measurements_from_vhdl(tb_path):
    """Parse measurement data from VHDL testbench file."""
    with open(tb_path, 'r') as f:
        content = f.read()

    Q24 = 2**24
    measurements = {'x': [], 'y': [], 'z': []}

    for axis in ['x', 'y', 'z']:
        pattern = rf'constant meas_{axis}_data\s*:\s*meas_array_t\s*:=\s*\((.*?)\);'
        match = re.search(pattern, content, re.DOTALL)
        if not match:
            raise ValueError(f"Could not find meas_{axis}_data in {tb_path}")

        data_str = match.group(1)
        # Extract to_signed(VALUE, 48) entries
        values = re.findall(r'to_signed\((-?\d+),\s*48\)', data_str)
        measurements[axis] = [int(v) / Q24 for v in values]

    n_cycles = len(measurements['x'])
    z_data = np.zeros((n_cycles, 3))
    z_data[:, 0] = measurements['x']
    z_data[:, 1] = measurements['y']
    z_data[:, 2] = measurements['z']
    return z_data


# ============================================================================
# Main: Run SR-UKF and print per-cycle diagnostics
# ============================================================================
def main():
    # Load measurements
    tb_path = os.path.join(os.path.dirname(__file__),
                           'ca_ukf.srcs/sim_1/new/sr_ukf_real_synthetic_drone_500cycles_tb.vhd')
    if not os.path.exists(tb_path):
        print(f"ERROR: Testbench not found at {tb_path}")
        sys.exit(1)

    z_data = load_measurements_from_vhdl(tb_path)
    n_cycles = len(z_data)
    print(f"Loaded {n_cycles} measurement cycles from testbench")
    print(f"First measurement: x={z_data[0,0]:.4f}, y={z_data[0,1]:.4f}, z={z_data[0,2]:.4f}")

    # How many cycles to show detailed output
    n_verbose = int(sys.argv[1]) if len(sys.argv) > 1 else 10

    # Initialize state
    x = np.zeros(N)  # Initial state = 0
    L = L_INIT.copy()

    # Tracking for RMSE
    positions_est = []
    positions_true = []  # We don't have true positions, use measurements for comparison

    print(f"\n{'='*80}")
    print(f"SR-UKF Reference (CA Model) - Python Floating-Point")
    print(f"Parameters: alpha={ALPHA}, beta={BETA}, kappa={KAPPA}, n={N}")
    print(f"P_INIT diag: {np.diag(P_INIT)}")
    print(f"Q diag: {Q_DIAG}")
    print(f"R diag: {np.diag(R)}")
    print(f"L_INIT diag: {np.diag(L_INIT)}")
    print(f"{'='*80}\n")

    for cycle in range(n_cycles):
        z_meas = z_data[cycle]
        verbose = (cycle < n_verbose)

        if verbose:
            print(f"--- Cycle {cycle} ---")
            print(f"  z_meas: [{z_meas[0]:.4f}, {z_meas[1]:.4f}, {z_meas[2]:.4f}]")
            print(f"  x_pre:  [{', '.join(f'{x[i]:.4f}' for i in range(N))}]")
            print(f"  L diag: [{', '.join(f'{L[i,i]:.6f}' for i in range(N))}]")

        # Prediction
        x_pred, L_pred, chi_pred = sr_ukf_predict(x, L, verbose=verbose)

        if verbose:
            print(f"  x_pred: [{', '.join(f'{x_pred[i]:.4f}' for i in range(N))}]")

        # Measurement update
        x_upd, L_upd = sr_ukf_update(x_pred, L_pred, chi_pred, z_meas, verbose=verbose)

        if verbose:
            print(f"  x_upd:  [{', '.join(f'{x_upd[i]:.4f}' for i in range(N))}]")
            P_diag = np.array([L_upd[i, i]**2 for i in range(N)])
            print(f"  P_diag: [{', '.join(f'{P_diag[i]:.6f}' for i in range(N))}]")
            print()

        # Update state for next cycle
        x = x_upd
        L = L_upd

        # Track position error vs measurement
        positions_est.append([x[0], x[3], x[6]])

        # Print periodic summary
        if (cycle + 1) % 50 == 0 or cycle == n_cycles - 1:
            pos_err = np.sqrt((x[0] - z_meas[0])**2 + (x[3] - z_meas[1])**2 + (x[6] - z_meas[2])**2)
            L_diag_str = ', '.join(f'{L[i,i]:.4f}' for i in range(N))
            print(f"Cycle {cycle:3d}: pos=[{x[0]:.2f}, {x[3]:.2f}, {x[6]:.2f}] "
                  f"err={pos_err:.4f}m  L_diag=[{L_diag_str}]")

    # Final summary
    print(f"\n{'='*80}")
    print(f"Final state: [{', '.join(f'{x[i]:.6f}' for i in range(N))}]")
    print(f"Final L diag: [{', '.join(f'{L[i,i]:.6f}' for i in range(N))}]")
    print(f"Final P diag: [{', '.join(f'{L[i,i]**2:.6f}' for i in range(N))}]")

    # Check for divergence
    max_L = max(abs(L[i, i]) for i in range(N))
    if max_L > 1000:
        print(f"\nWARNING: L appears to be diverging! max(L_diag) = {max_L:.2f}")
    else:
        print(f"\nL is stable. max(L_diag) = {max_L:.6f}")


if __name__ == '__main__':
    main()
