#!/usr/bin/env python3
"""
Test whether widening the QR working matrix from Q24.24 (48-bit) to Q48.48 (96-bit)
improves SR-UKF RMSE.

Implements Householder LQ decomposition matching the VHDL algorithm exactly
(qr_decomp_9x19.vhd), with two fixed-point variants:
  - Q24.24: 48-bit signed, products truncated via >> 24 at every step (current VHDL)
  - Q48.48: 96-bit signed internally, products truncated via >> 48 only at final extraction

Runs the full SR-UKF pipeline with each QR variant and compares RMSE against
ground truth from the synthetic drone dataset.

Usage:
    python3 test_qr_precision.py
"""

import numpy as np
import re
import os
import csv
import math

# ============================================================================
# Parameters (matching VHDL exactly)
# ============================================================================
N = 9
N_SIGMA = 2 * N + 1  # 19
DT = 0.02  # 20ms = 50Hz

ALPHA = 1.0
BETA = 2.0
KAPPA = 0.0
LAMBDA = ALPHA**2 * (N + KAPPA) - N  # = 0
GAMMA = math.sqrt(N + LAMBDA)  # = 3.0

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
L_INIT = np.linalg.cholesky(P_INIT)

# Process noise
Q_DIAG = np.array([0.05, 0.00025, 0.00001, 0.05, 0.00025, 0.00001, 0.05, 0.00025, 0.00001])
Q_MAT = np.diag(Q_DIAG)
LQ = np.diag(np.sqrt(Q_DIAG))

# Measurement noise
R = np.diag([0.25, 0.25, 0.25])

# CA state transition
F = np.eye(N)
for axis in range(3):
    base = 3 * axis
    F[base, base + 1] = DT
    F[base, base + 2] = 0.5 * DT**2
    F[base + 1, base + 2] = DT

# Measurement matrix
H = np.zeros((3, N))
H[0, 0] = 1.0
H[1, 3] = 1.0
H[2, 6] = 1.0


# ============================================================================
# Cholesky rank-1 update/downdate (float64, matching VHDL Givens rotation)
# ============================================================================
def cholupdate(L, u):
    """Rank-1 Cholesky update: L_new s.t. L_new @ L_new.T = L @ L.T + u @ u.T"""
    L_new = L.copy()
    u_new = u.copy()
    n = len(u)
    for col in range(n):
        r = math.sqrt(L_new[col, col]**2 + u_new[col]**2)
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
    """Rank-1 Cholesky downdate: L_new s.t. L_new @ L_new.T = L @ L.T - w @ w.T"""
    L_new = L.copy()
    w_new = w.copy()
    n = len(w)
    for col in range(n):
        r_sq = L_new[col, col]**2 - w_new[col]**2
        if r_sq <= 0:
            r = math.sqrt(abs(r_sq)) if r_sq < 0 else 0.0
            if r == 0:
                continue
        else:
            r = math.sqrt(r_sq)
        c = r / L_new[col, col]
        s = w_new[col] / L_new[col, col]
        L_new[col, col] = r
        for row in range(col + 1, n):
            temp_L = (L_new[row, col] - s * w_new[row]) / c if c != 0 else L_new[row, col]
            temp_w = c * w_new[row] - s * L_new[row, col]
            w_new[row] = temp_w
            L_new[row, col] = temp_L
    return L_new


# ============================================================================
# Householder LQ decomposition - Float64 version (algorithm match)
# ============================================================================
def householder_lq_float64(A_in):
    """
    Row-wise Householder LQ factorization matching VHDL qr_decomp_9x19 algorithm.
    Input: A (9x18) float64 matrix
    Output: L (9x9) lower triangular with positive diagonal
    """
    nrows, ncols = A_in.shape
    assert nrows == 9 and ncols == 18
    A = A_in.copy()
    alpha_diag = np.zeros(9)

    for k in range(9):
        # Compute row norm: ||A(k, k:17)||
        norm_sq = 0.0
        for j in range(k, 18):
            norm_sq += A[k, j] ** 2
        norm_val = math.sqrt(norm_sq)

        # alpha = -sign(A(k,k)) * norm (LAPACK convention)
        if A[k, k] >= 0:
            alpha = -norm_val
        else:
            alpha = norm_val
        alpha_diag[k] = alpha

        # Build Householder vector v
        v = np.zeros(18)
        v[k] = A[k, k] - alpha
        for j in range(k + 1, 18):
            v[j] = A[k, j]

        # beta = 2 / ||v||^2
        vnorm_sq = 0.0
        for j in range(k, 18):
            vnorm_sq += v[j] ** 2
        if vnorm_sq > 0:
            beta_val = 2.0 / vnorm_sq
        else:
            beta_val = 0.0

        # Apply reflection to rows k+1..8
        for i in range(k + 1, 9):
            dot = 0.0
            for j in range(k, 18):
                dot += A[i, j] * v[j]
            scale = beta_val * dot
            for j in range(k, 18):
                A[i, j] -= scale * v[j]

    # Extract L with positive diagonal
    L = np.zeros((9, 9))
    for i in range(9):
        for j in range(i):
            if alpha_diag[j] < 0:
                L[i, j] = -A[i, j]
            else:
                L[i, j] = A[i, j]
        # Diagonal from alpha_diag with abs
        L[i, i] = abs(alpha_diag[i])

    return L


# ============================================================================
# Householder LQ decomposition - Q24.24 fixed-point version (current VHDL)
# ============================================================================
def householder_lq_q24(A_float):
    """
    Row-wise Householder LQ matching VHDL exactly with Q24.24 truncation.
    All values stored as int64 with 24 fractional bits.
    Products: (a * b) >> 24 (arithmetic shift right, toward -inf).
    """
    Q = 24
    ONE = 1 << Q  # 1.0 in Q24.24

    nrows, ncols = A_float.shape
    assert nrows == 9 and ncols == 18

    # Convert float A to Q24.24 int64
    A = np.zeros((9, 18), dtype=np.int64)
    for i in range(9):
        for j in range(18):
            A[i, j] = int(round(A_float[i, j] * ONE))

    alpha_diag = np.zeros(9, dtype=np.int64)

    for k in range(9):
        # Compute row norm squared in Q24.24:
        # norm_sq = sum(A[k,j]*A[k,j] >> Q) for j >= k
        # This is a 96-bit accumulator in VHDL, but result gets resized to 48-bit
        norm_sq = 0  # Python int, unlimited precision for accumulation
        for j in range(k, 18):
            prod = int(A[k, j]) * int(A[k, j])
            norm_sq += prod >> Q  # shift_right(temp_prod, Q) in VHDL
        # Truncate norm_sq to 48-bit signed for sqrt input (VHDL: resize(norm_v, 48))
        norm_sq_48 = _to_signed48(norm_sq)

        # sqrt via integer square root (models CORDIC)
        # sqrt_in is Q24.24, sqrt_out is Q24.24: sqrt(x_q24) = isqrt(x_q24 << Q)
        # Because sqrt(X * 2^24) = sqrt(X) * 2^12, we need to scale
        # Actually: if norm_sq_48 represents ||row||^2 in Q24.24,
        # then the real value is norm_sq_48 / 2^24.
        # sqrt of that real value is sqrt(norm_sq_48 / 2^24) = sqrt(norm_sq_48) / 2^12
        # In Q24.24: result = sqrt(norm_sq_48) * 2^12
        if norm_sq_48 > 0:
            sqrt_val = _isqrt(norm_sq_48) << 12  # Q24.24 output
        elif norm_sq_48 == 0:
            sqrt_val = 0
        else:
            # Negative input (shouldn't happen for norm squared)
            sqrt_val = 0

        # alpha = -sign(A(k,k)) * sqrt_out
        if A[k, k] >= 0:
            alpha = -sqrt_val
        else:
            alpha = sqrt_val
        alpha_diag[k] = alpha

        # Build v vector in Q24.24
        v = np.zeros(18, dtype=np.int64)
        v_first = int(A[k, k]) - int(alpha)
        v[k] = v_first
        for j in range(k + 1, 18):
            v[j] = A[k, j]

        # beta = 2 / ||v||^2 in Q24.24
        # VHDL: vnorm_v accumulates v[j]*v[j]>>Q, then beta = (2<<48) / vnorm_v
        vnorm_v = 0
        vnorm_v += (int(v_first) * int(v_first)) >> Q
        for j in range(k + 1, 18):
            vnorm_v += (int(A[k, j]) * int(A[k, j])) >> Q

        if vnorm_v > 0:
            beta_numer = 2 << (2 * Q)  # 2 * 2^48
            beta = beta_numer // vnorm_v  # integer division (VHDL truncates)
            beta = _to_signed48(beta)
        else:
            beta = 0

        # Apply reflection to rows k+1..8
        for i in range(k + 1, 9):
            # dot = sum(A[i,j] * v[j] >> Q) for j >= k
            dot_v = 0
            for j in range(k, 18):
                prod = int(A[i, j]) * int(v[j])
                dot_v += prod >> Q
            dot_v_48 = _to_signed48(dot_v)

            # scale = (beta * dot_v_48) >> Q
            temp_prod = int(beta) * int(dot_v_48)
            scale_v = temp_prod >> Q
            scale_v_48 = _to_signed48(scale_v)

            # A[i,j] -= (scale_v_48 * v[j]) >> Q for j >= k
            for j in range(k, 18):
                prod = int(scale_v_48) * int(v[j])
                sub = prod >> Q
                A[i, j] = _to_signed48(int(A[i, j]) - _to_signed48(sub))

    # Extract L with positive diagonal, convert back to float
    L = np.zeros((9, 9))
    for i in range(9):
        for j in range(i):
            val = A[i, j]
            if alpha_diag[j] < 0:
                val = -val
            L[i, j] = float(val) / ONE
        L[i, i] = float(abs(alpha_diag[i])) / ONE

    return L


# ============================================================================
# Householder LQ decomposition - Q48.48 fixed-point version (proposed wider VHDL)
# ============================================================================
def householder_lq_q48(A_float):
    """
    Row-wise Householder LQ with Q48.48 internal precision.
    Input A is initially in Q24.24 (from BUILD_WEIGHTED_A which truncates to 48-bit).
    Internally, the working matrix is promoted to Q48.48 (96-bit signed).
    Products of two Q48.48 values: (a * b) >> 48.
    Final extraction converts back to Q24.24 by >> 24.
    """
    Q24 = 24
    Q48 = 48
    ONE_24 = 1 << Q24
    ONE_48 = 1 << Q48

    nrows, ncols = A_float.shape
    assert nrows == 9 and ncols == 18

    # Convert float A to Q24.24 first (this matches BUILD_WEIGHTED_A truncation)
    # then promote to Q48.48 by shifting left 24
    A = {}  # Use dict of Python ints for unlimited precision
    for i in range(9):
        for j in range(18):
            q24_val = int(round(A_float[i, j] * ONE_24))
            # Promote to Q48.48: shift left by 24
            A[(i, j)] = q24_val << 24

    alpha_diag = [0] * 9

    for k in range(9):
        # Compute row norm squared: accumulate A[k,j]*A[k,j] >> Q48
        norm_sq = 0
        for j in range(k, 18):
            prod = A[(k, j)] * A[(k, j)]
            norm_sq += prod >> Q48

        # sqrt: norm_sq is in Q48.48 representation
        # Real value = norm_sq / 2^48
        # sqrt(real) = sqrt(norm_sq / 2^48) = sqrt(norm_sq) / 2^24
        # In Q48.48: result = sqrt(norm_sq) * 2^24
        if norm_sq > 0:
            sqrt_val = _isqrt_big(norm_sq) << 24
        else:
            sqrt_val = 0

        # alpha = -sign(A(k,k)) * sqrt_out
        if A[(k, k)] >= 0:
            alpha = -sqrt_val
        else:
            alpha = sqrt_val
        alpha_diag[k] = alpha

        # Build v vector in Q48.48
        v = [0] * 18
        v_first = A[(k, k)] - alpha
        v[k] = v_first
        for j in range(k + 1, 18):
            v[j] = A[(k, j)]

        # beta = 2 / ||v||^2 in Q48.48
        # vnorm_v = sum(v[j]*v[j] >> Q48)
        vnorm_v = 0
        vnorm_v += (v_first * v_first) >> Q48
        for j in range(k + 1, 18):
            vnorm_v += (A[(k, j)] * A[(k, j)]) >> Q48

        if vnorm_v > 0:
            beta_numer = 2 << (2 * Q48)  # 2 * 2^96
            beta = beta_numer // vnorm_v
        else:
            beta = 0

        # Apply reflection to rows k+1..8
        for i in range(k + 1, 9):
            # dot = sum(A[i,j] * v[j] >> Q48)
            dot_v = 0
            for j in range(k, 18):
                prod = A[(i, j)] * v[j]
                dot_v += prod >> Q48

            # scale = (beta * dot_v) >> Q48
            temp_prod = beta * dot_v
            scale_v = temp_prod >> Q48

            # A[i,j] -= (scale_v * v[j]) >> Q48
            for j in range(k, 18):
                prod = scale_v * v[j]
                sub = prod >> Q48
                A[(i, j)] = A[(i, j)] - sub

    # Extract L, convert from Q48.48 back to float
    L = np.zeros((9, 9))
    for i in range(9):
        for j in range(i):
            val = A[(i, j)]
            if alpha_diag[j] < 0:
                val = -val
            L[i, j] = float(val) / ONE_48
        L[i, i] = float(abs(alpha_diag[i])) / ONE_48

    return L


# ============================================================================
# Fixed-point helper functions
# ============================================================================
def _to_signed48(val):
    """Truncate Python int to 48-bit signed range (models VHDL resize to signed(47 downto 0))."""
    val = int(val) & 0xFFFFFFFFFFFF  # mask to 48 bits
    if val >= (1 << 47):
        val -= (1 << 48)
    return val


def _isqrt(n):
    """Integer square root (floor). For Q24.24 CORDIC model."""
    if n <= 0:
        return 0
    x = n
    y = (x + 1) // 2
    while y < x:
        x = y
        y = (x + n // x) // 2
    return x


def _isqrt_big(n):
    """Integer square root for arbitrary-precision Python ints."""
    if n <= 0:
        return 0
    x = n
    y = (x + 1) // 2
    while y < x:
        x = y
        y = (x + n // x) // 2
    return x


# ============================================================================
# SR-UKF prediction phase (parametric QR function)
# ============================================================================
def sr_ukf_predict(x, L, qr_func):
    """
    SR-UKF prediction phase.
    qr_func: callable(A_9x18) -> L_9x9 lower triangular
    Returns: x_pred, L_pred, chi_pred (19x9)
    """
    # Step 1: Generate sigma points
    chi = np.zeros((N_SIGMA, N))
    chi[0] = x
    for i in range(N):
        chi[i + 1] = x + GAMMA * L[:, i]
        chi[i + 1 + N] = x - GAMMA * L[:, i]

    # Step 2: Propagate through CA process model
    chi_pred = np.zeros((N_SIGMA, N))
    for i in range(N_SIGMA):
        chi_pred[i] = F @ chi[i]

    # Step 3: Predicted mean
    x_pred = np.zeros(N)
    for i in range(N_SIGMA):
        x_pred += W_M[i] * chi_pred[i]

    # Step 4: QR decomposition
    sqrt_wc = math.sqrt(W_C[1])  # sqrt(1/18)
    A = np.zeros((N, N_SIGMA - 1))  # 9x18
    for j in range(N_SIGMA - 1):
        A[:, j] = sqrt_wc * (chi_pred[j + 1] - x_pred)

    L_qr = qr_func(A)

    # Step 5: W0 rank-1 update
    sqrt_wc0 = math.sqrt(abs(W_C[0]))  # sqrt(2.0)
    w0_vec = sqrt_wc0 * (chi_pred[0] - x_pred)
    L_w0 = cholupdate(L_qr, w0_vec)

    # Step 6: Process noise rank-1 updates
    L_pred = L_w0.copy()
    for col in range(N):
        L_pred = cholupdate(L_pred, LQ[:, col])

    return x_pred, L_pred, chi_pred


# ============================================================================
# SR-UKF measurement update phase (float64, same for all variants)
# ============================================================================
def sr_ukf_update(x_pred, L_pred, chi_pred, z_meas):
    """SR-UKF measurement update phase."""
    n_z = 3

    # Measurement sigma points
    z_sigma = np.zeros((N_SIGMA, n_z))
    for i in range(N_SIGMA):
        z_sigma[i] = H @ chi_pred[i]

    z_mean = np.zeros(n_z)
    for i in range(N_SIGMA):
        z_mean += W_M[i] * z_sigma[i]

    # Innovation
    nu = z_meas - z_mean

    # Cross-covariance
    Pxz = np.zeros((N, n_z))
    for i in range(N_SIGMA):
        dx = chi_pred[i] - x_pred
        dz = z_sigma[i] - z_mean
        Pxz += W_C[i] * np.outer(dx, dz)

    # Innovation covariance
    S_yy = np.zeros((n_z, n_z))
    for i in range(N_SIGMA):
        dz = z_sigma[i] - z_mean
        S_yy += W_C[i] * np.outer(dz, dz)
    S_yy += R

    # Kalman gain
    K = Pxz @ np.linalg.inv(S_yy)

    # State update
    x_upd = x_pred + K @ nu

    # Covariance update via rank-1 downdates
    L_upd = L_pred.copy()
    for m in range(n_z):
        sqrt_s = math.sqrt(S_yy[m, m])
        w = K[:, m] * sqrt_s
        L_upd = choldowndate(L_upd, w)

    return x_upd, L_upd


# ============================================================================
# QR function wrappers
# ============================================================================
def qr_numpy(A):
    """NumPy QR (baseline float64)."""
    Q_mat, R_mat = np.linalg.qr(A.T, mode='reduced')
    L = R_mat.T
    for i in range(9):
        if L[i, i] < 0:
            L[i, :] *= -1
    return L


def qr_householder_float(A):
    """Float64 Householder (algorithm match to VHDL)."""
    return householder_lq_float64(A)


def qr_householder_q24(A):
    """Q24.24 Householder (current VHDL behavior)."""
    return householder_lq_q24(A)


def qr_householder_q48(A):
    """Q48.48 Householder (proposed wider VHDL)."""
    return householder_lq_q48(A)


# ============================================================================
# Load data
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
        values = re.findall(r'to_signed\((-?\d+),\s*48\)', data_str)
        measurements[axis] = [int(v) / Q24 for v in values]

    n_cycles = len(measurements['x'])
    z_data = np.zeros((n_cycles, 3))
    z_data[:, 0] = measurements['x']
    z_data[:, 1] = measurements['y']
    z_data[:, 2] = measurements['z']
    return z_data


def load_ground_truth(csv_path):
    """Load ground truth positions from the dataset CSV."""
    gt = []
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            gt.append([
                float(row['gt_x_pos']),
                float(row['gt_y_pos']),
                float(row['gt_z_pos']),
            ])
    return np.array(gt)


# ============================================================================
# Run SR-UKF with a given QR function
# ============================================================================
def run_sr_ukf(z_data, qr_func, label=""):
    """Run full SR-UKF pipeline, return per-cycle position estimates."""
    n_cycles = len(z_data)
    x = np.zeros(N)
    L = L_INIT.copy()
    positions = np.zeros((n_cycles, 3))

    for cycle in range(n_cycles):
        z_meas = z_data[cycle]

        # Prediction
        x_pred, L_pred, chi_pred = sr_ukf_predict(x, L, qr_func)

        # Measurement update
        x_upd, L_upd = sr_ukf_update(x_pred, L_pred, chi_pred, z_meas)

        x = x_upd
        L = L_upd
        positions[cycle] = [x[0], x[3], x[6]]

        # Progress indicator for slow fixed-point versions
        if label and (cycle + 1) % 100 == 0:
            print(f"  [{label}] cycle {cycle + 1}/{n_cycles}...")

    return positions


# ============================================================================
# Compute RMSE
# ============================================================================
def compute_rmse(positions_est, positions_gt):
    """Compute 3D position RMSE (meters)."""
    n = min(len(positions_est), len(positions_gt))
    err = positions_est[:n] - positions_gt[:n]
    mse = np.mean(np.sum(err**2, axis=1))
    return math.sqrt(mse)


# ============================================================================
# Main
# ============================================================================
def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    tb_path = os.path.join(script_dir,
                           'ca_ukf.srcs/sim_1/new/sr_ukf_real_synthetic_drone_500cycles_tb.vhd')
    csv_path = os.path.join(script_dir, 'test_data/real_world/synthetic_drone_500cycles.csv')

    if not os.path.exists(tb_path):
        print(f"ERROR: Testbench not found at {tb_path}")
        return
    if not os.path.exists(csv_path):
        print(f"ERROR: Ground truth CSV not found at {csv_path}")
        return

    print("Loading measurement data from VHDL testbench...")
    z_data = load_measurements_from_vhdl(tb_path)
    n_cycles = len(z_data)
    print(f"  Loaded {n_cycles} measurement cycles")

    print("Loading ground truth from CSV...")
    gt = load_ground_truth(csv_path)
    print(f"  Loaded {len(gt)} ground truth entries")
    print(f"  First GT: x={gt[0,0]:.4f}, y={gt[0,1]:.4f}, z={gt[0,2]:.4f}")
    print(f"  First meas: x={z_data[0,0]:.4f}, y={z_data[0,1]:.4f}, z={z_data[0,2]:.4f}")

    print()
    print("=" * 76)
    print("SR-UKF QR Precision Comparison Test")
    print("=" * 76)
    print(f"Parameters: N={N}, alpha={ALPHA}, beta={BETA}, kappa={KAPPA}, dt={DT}")
    print(f"P_INIT diag: {list(np.diag(P_INIT))}")
    print(f"Q diag: {list(Q_DIAG)}")
    print(f"R diag: {list(np.diag(R))}")
    print(f"Cycles: {n_cycles}")
    print("=" * 76)

    results = {}

    # --- 1. Float64 NumPy QR (baseline) ---
    print("\n[1/4] Running with float64 NumPy QR (baseline)...")
    pos_numpy = run_sr_ukf(z_data, qr_numpy, label="numpy")
    rmse_numpy = compute_rmse(pos_numpy, gt)
    results['numpy_qr'] = rmse_numpy
    print(f"  RMSE = {rmse_numpy:.6f} m")

    # --- 2. Float64 Householder QR (algorithm match) ---
    print("\n[2/4] Running with float64 Householder QR (algorithm match)...")
    pos_hh_float = run_sr_ukf(z_data, qr_householder_float, label="hh_float")
    rmse_hh_float = compute_rmse(pos_hh_float, gt)
    results['householder_float64'] = rmse_hh_float
    print(f"  RMSE = {rmse_hh_float:.6f} m")

    # --- 3. Q24.24 Householder QR (current VHDL) ---
    print("\n[3/4] Running with Q24.24 Householder QR (current VHDL behavior)...")
    print("  (This is slow due to Python big-int arithmetic, please wait...)")
    pos_q24 = run_sr_ukf(z_data, qr_householder_q24, label="Q24.24")
    rmse_q24 = compute_rmse(pos_q24, gt)
    results['householder_q24'] = rmse_q24
    print(f"  RMSE = {rmse_q24:.6f} m")

    # --- 4. Q48.48 Householder QR (proposed wider VHDL) ---
    print("\n[4/4] Running with Q48.48 Householder QR (proposed wider VHDL)...")
    print("  (This is slow due to Python big-int arithmetic, please wait...)")
    pos_q48 = run_sr_ukf(z_data, qr_householder_q48, label="Q48.48")
    rmse_q48 = compute_rmse(pos_q48, gt)
    results['householder_q48'] = rmse_q48
    print(f"  RMSE = {rmse_q48:.6f} m")

    # --- Summary ---
    print("\n" + "=" * 76)
    print("RESULTS SUMMARY")
    print("=" * 76)
    print(f"{'Method':<40s} {'RMSE (m)':>12s} {'vs Baseline':>14s}")
    print("-" * 76)
    print(f"{'Float64 NumPy QR (baseline)':<40s} {rmse_numpy:>12.6f} {'---':>14s}")
    print(f"{'Float64 Householder QR (algo match)':<40s} {rmse_hh_float:>12.6f} {rmse_hh_float - rmse_numpy:>+14.6f}")
    print(f"{'Q24.24 Householder QR (current VHDL)':<40s} {rmse_q24:>12.6f} {rmse_q24 - rmse_numpy:>+14.6f}")
    print(f"{'Q48.48 Householder QR (proposed VHDL)':<40s} {rmse_q48:>12.6f} {rmse_q48 - rmse_numpy:>+14.6f}")
    print("-" * 76)

    improvement = rmse_q24 - rmse_q48
    pct = (improvement / rmse_q24) * 100 if rmse_q24 > 0 else 0
    print(f"\nQ48.48 vs Q24.24 improvement: {improvement:+.6f} m ({pct:+.3f}%)")

    if improvement > 0.001:
        print("CONCLUSION: Widening QR to Q48.48 DOES improve RMSE significantly.")
    elif improvement > 0:
        print("CONCLUSION: Widening QR to Q48.48 shows marginal improvement.")
    else:
        print("CONCLUSION: Widening QR to Q48.48 does NOT improve RMSE.")
        print("  The precision bottleneck is elsewhere in the pipeline.")

    # Per-axis breakdown
    print("\n" + "-" * 76)
    print("Per-axis RMSE breakdown:")
    print(f"{'Method':<40s} {'X RMSE':>10s} {'Y RMSE':>10s} {'Z RMSE':>10s}")
    print("-" * 76)
    for name, pos in [("NumPy QR", pos_numpy), ("Householder float64", pos_hh_float),
                       ("Q24.24 (current VHDL)", pos_q24), ("Q48.48 (proposed)", pos_q48)]:
        n = min(len(pos), len(gt))
        err = pos[:n] - gt[:n]
        rx = math.sqrt(np.mean(err[:, 0]**2))
        ry = math.sqrt(np.mean(err[:, 1]**2))
        rz = math.sqrt(np.mean(err[:, 2]**2))
        print(f"{name:<40s} {rx:>10.6f} {ry:>10.6f} {rz:>10.6f}")
    print("-" * 76)


if __name__ == '__main__':
    main()
