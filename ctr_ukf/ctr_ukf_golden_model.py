#!/usr/bin/env python3
"""
CTR UKF Golden Model — Python reference implementation matching VHDL exactly.

9-state Constant Turn Rate UKF:
  State = [x_pos, x_vel, x_omega, y_pos, y_vel, y_omega, z_pos, z_vel, z_omega]
  Measurement = [z_x, z_y, z_z] (position-only)

Two modes:
  --mode float   : double-precision floating point (default)
  --mode fixed   : Q24.24 fixed-point emulation matching VHDL intermediate widths

Constants extracted from VHDL sources:
  predicti_ctr3d.vhd, ukf_supreme_3d.vhd, sigma_3d.vhd,
  process_noise_3d.vhd, innovation_covariance_3d.vhd, state_update_3d.vhd,
  covariance_reconstruct_3d.vhd, kalman_gain_3d.vhd, cholsky_9.vhd,
  sqrt_cordic.vhd, matrix_inverse_3x3.vhd

VHDL Intermediate Precision (critical for bit-accuracy):
  - predicti_ctr3d: 96-bit products, shift_right(Q) to 48-bit
  - covariance_reconstruct: 112-bit outer products, 64-bit accumulators, shift_right(2Q)
  - state_update (APAT/KRK): 144-bit products, shift_right(2Q) to 48-bit
  - state_update (K*nu): 144-bit sum, shift_right(Q) to 48-bit
  - kalman_gain: 96-bit products, shift_right(Q), clamp to [-1,+1]
  - cholesky: 96-bit products, shift_right(Q); division via shift_left(Q)/divisor
  - sqrt_cordic: Newton-Raphson 7 iterations, 96-bit intermediates
  - matrix_inverse: 144-bit determinant, 96-bit cofactors, direct division
"""
import argparse
import math
import sys
import numpy as np
from copy import deepcopy

# ─── Q24.24 fixed-point constants (from VHDL) ───────────────────────────────
Q = 24
SCALE = 1 << Q           # 16777216
MAX_48 = (1 << 47) - 1   # 140737488355327
MIN_48 = -(1 << 47)      # -140737488355328
N = 9                     # state dimension
NUM_SIGMA = 2 * N + 1    # 19 sigma points

# Time constants
DT_FP       = 335544     # 0.02s  in Q24.24
DT_SQ_FP    = 6711       # 0.0004 in Q24.24
HALF_FP     = 8388608    # 0.5    in Q24.24

# Gamma = sqrt(N) = 3.0
GAMMA_FP    = 50331648   # 3.0 in Q24.24

# UKF weights
W0_MEAN     = 0          # lambda/(n+lambda) = 0
WI_MEAN     = 932067     # 1/18 in Q24.24
W0_COV      = 33554432   # 2.0 in Q24.24
WI_COV      = 932067     # 1/18 in Q24.24

# Initial covariance P0 diagonal
P0_POS      = 83886080   # 5.0
P0_VEL      = 335544320  # 20.0
P0_OMEGA    = 16777216   # 1.0

# Process noise Q diagonal
Q_POS       = 838861     # 0.05
Q_VEL       = 16777      # 0.001
Q_OMEGA     = 16777      # 0.001

# Measurement noise R diagonal
R_DIAG      = 4194304    # 0.25

# Kalman gain saturation
UNITY_FP    = 16777216   # 1.0
NEG_UNITY_FP = -16777216 # -1.0

# Covariance saturation
SAFE_MAX_P  = (1 << 46) - 1  # 0x3FFFFFFFFFFF

# Cholesky minimum diagonal
CHOL_MIN    = 64

# ─── Measurement data (from testbench, Q24.24 signed) ───────────────────────
MEAS_X_HEX = [
    0x0000004CCCCD, 0x000000CCCBB5, 0x0000021990DD, 0x000002B315B6,
    0x00000432ED4D, 0x000004E5DDE2, 0x0000064BE0EA, 0x000006CB563F,
    0x000008176A8A, 0x000008B01743, 0x00000A2EEF7B, 0x00000AE0B979,
    0x00000C456EB9, 0x00000CC36F1E, 0x00000E0DE75B, 0x00000EA4D0F2,
    0x00001021BF00, 0x000010D177D8, 0x00001233F503, 0x000012AF9674,
    0x000013F788ED, 0x0000148BC600, 0x00001605E0DC, 0x000016B29FE6,
    0x00001811FCBC,
]
MEAS_Y_HEX = [
    0xFFFFFFCCCCCD, 0x0000001AE147, 0xFFFFFFB851E0, 0x0000003EB819,
    0xFFFFFFFAE095, 0x0000006CCB18, 0xFFFFFFFADDBE, 0x000000584B5D,
    0x00000005138A, 0x0000009ACF5E, 0x000000664B1A, 0x000000E7861E,
    0x00000084E620, 0x000000F19D93, 0x000000ADABA6, 0x00000152A910,
    0x0000012D61AD, 0x000001BDD479, 0x0000016A66C6, 0x000001E64AA5,
    0x000001B17EE0, 0x000002659BCC, 0x0000024F6CE0, 0x000002EEF0B7,
    0x000002AA8C3F,
]
MEAS_Z_HEX = [
    0x00000019999A, 0xFFFFFFF0A3D7, 0x00000047AE14, 0xFFFFFFEB851F,
    0x000000428F5C, 0x00000019999A, 0x00000070A3D7, 0x000000147AE1,
    0x0000006B851F, 0x000000428F5C, 0x00000099999A, 0x0000003D70A4,
    0x000000947AE1, 0x0000006B851F, 0x000000C28F5C, 0x000000666666,
    0x000000BD70A4, 0x000000947AE1, 0x000000EB851F, 0x0000008F5C29,
    0x000000E66666, 0x000000BD70A4, 0x000001147AE1, 0x000000B851EC,
    0x0000010F5C29,
]

def hex48_to_signed(val):
    if val >= (1 << 47):
        val -= (1 << 48)
    return val

def to_hex48(val):
    if val < 0:
        val += (1 << 48)
    return f"{val & 0xFFFFFFFFFFFF:012X}"

def q24_to_real(val):
    return val / SCALE

def real_to_q24(val):
    return int(round(val * SCALE))

MEAS_X = [hex48_to_signed(v) for v in MEAS_X_HEX]
MEAS_Y = [hex48_to_signed(v) for v in MEAS_Y_HEX]
MEAS_Z = [hex48_to_signed(v) for v in MEAS_Z_HEX]

# ─── Fixed-point arithmetic (matching VHDL bit widths) ──────────────────────

def trunc48(val):
    """Truncate to 48-bit signed range (VHDL resize(..., 48))."""
    val = val & 0xFFFFFFFFFFFF
    if val >= (1 << 47):
        val -= (1 << 48)
    return val

def trunc_n(val, n_bits):
    """Truncate to n-bit signed range (VHDL resize(..., n))."""
    mask = (1 << n_bits) - 1
    val = val & mask
    if val >= (1 << (n_bits - 1)):
        val -= (1 << n_bits)
    return val

def fp_mul(a, b):
    """Q24.24 multiply matching VHDL: resize(shift_right(a*b, Q), 48).
    a*b is 96-bit, shift_right by 24 gives 72-bit, resize to 48."""
    prod = a * b                # arbitrary precision (96-bit equivalent)
    shifted = prod >> Q         # arithmetic right shift by 24
    return trunc48(shifted)

def fp_clamp(val):
    """Clamp to 48-bit signed range."""
    return max(MIN_48, min(MAX_48, val))

def fp_clamp_p(val):
    """Clamp covariance to SAFE_MAX_P (VHDL saturate_covariance)."""
    return max(MIN_48, min(SAFE_MAX_P, val))

def saturate_gain(val):
    """VHDL kalman_gain saturate_gain: clamp to [-1.0, +1.0] in Q24.24."""
    return max(NEG_UNITY_FP, min(UNITY_FP, val))

# ─── Newton-Raphson sqrt (matching sqrt_cordic.vhd, 7 iterations) ───────────

def isqrt_fp(val):
    """Integer sqrt in Q24.24 matching VHDL sqrt_cordic.vhd.
    Newton-Raphson: x_{n+1} = (x_n + N/x_n) * 0.5
    7 iterations, 96-bit intermediates, shift_right(Q)."""
    if val <= 0:
        return 0

    # Initial guess: shift_right(val, 1) -- VHDL uses x_input/2
    x = val >> 1
    if x == 0:
        x = 1

    for _ in range(7):
        # Step 1: N/x_current via shift_left(N, Q) / x (96-bit division)
        if x == 0:
            x = 1
        quotient = (val << Q) // x   # 96-bit / 48-bit
        quot_48 = trunc48(quotient)   # extract lower 48 bits

        # Step 2: sum = x + quotient
        temp_sum = x + quot_48

        # Step 3: multiply by 0.5 and normalize
        prod = temp_sum * HALF_FP     # 96-bit product
        x = trunc48(prod >> Q)        # shift_right(Q), resize to 48

        if x <= 0:
            x = 1

    return x

# ─── Cholesky decomposition (matching cholsky_9.vhd) ────────────────────────

def cholesky_9x9_fp(P):
    """Fixed-point Cholesky matching VHDL cholsky_9.vhd.
    Uses 96-bit intermediates for products and division."""
    L = [[0]*9 for _ in range(9)]
    for j in range(9):
        # Diagonal: L[j][j] = sqrt(P[j][j] - sum(L[j][k]^2))
        s = P[j][j]
        for k in range(j):
            # L[j][k]^2: 96-bit product, shift_right(Q), resize to 48
            sq = fp_mul(L[j][k], L[j][k])
            s -= sq
        s = max(s, CHOL_MIN)
        L[j][j] = isqrt_fp(s)

        # Off-diagonal: L[i][j] = (P[i][j] - sum(L[i][k]*L[j][k])) / L[j][j]
        for i in range(j+1, 9):
            s = P[i][j]
            for k in range(j):
                s -= fp_mul(L[i][k], L[j][k])
            # Division: shift_left(s, Q) / L[j][j] (96-bit / 48-bit)
            if L[j][j] != 0:
                div_result = (s << Q) // L[j][j]
                L[i][j] = trunc48(div_result)
            else:
                L[i][j] = 0
    return L

# ─── CTR Motion Model (matching predicti_ctr3d.vhd) ─────────────────────────

def ctr_predict_sigma_fp(state):
    """CTR motion model matching VHDL predicti_ctr3d.vhd.
    All products use 96-bit intermediates, shift_right(Q), resize(48)."""
    px, vx, wx, py, vy, wy, pz, vz, wz = state

    # Cross products: 96-bit products, shift_right(Q), resize(48)
    # cx = wy*vz - wz*vy
    cx = fp_mul(wy, vz) - fp_mul(wz, vy)
    cy = fp_mul(wz, vx) - fp_mul(wx, vz)
    cz = fp_mul(wx, vy) - fp_mul(wy, vx)

    # omega_sq = wx^2 + wy^2 + wz^2 (each term via fp_mul)
    omega_sq = trunc48(fp_mul(wx, wx) + fp_mul(wy, wy) + fp_mul(wz, wz))

    # vel*dt: 96-bit product, shift_right(Q), resize(48)
    vx_dt = fp_mul(vx, DT_FP)
    vy_dt = fp_mul(vy, DT_FP)
    vz_dt = fp_mul(vz, DT_FP)

    # cross*dt
    cx_dt = fp_mul(cx, DT_FP)
    cy_dt = fp_mul(cy, DT_FP)
    cz_dt = fp_mul(cz, DT_FP)

    # omega_sq * vel: 96-bit, shift_right(Q)
    osq_vx = fp_mul(omega_sq, vx)
    osq_vy = fp_mul(omega_sq, vy)
    osq_vz = fp_mul(omega_sq, vz)

    # omega_sq * vel * dt^2: 96-bit, shift_right(Q)
    osq_vx_dtsq = fp_mul(osq_vx, DT_SQ_FP)
    osq_vy_dtsq = fp_mul(osq_vy, DT_SQ_FP)
    osq_vz_dtsq = fp_mul(osq_vz, DT_SQ_FP)

    # correction = 0.5 * omega_sq * vel * dt^2
    corr_vx = fp_mul(HALF_FP, osq_vx_dtsq)
    corr_vy = fp_mul(HALF_FP, osq_vy_dtsq)
    corr_vz = fp_mul(HALF_FP, osq_vz_dtsq)

    # v' = v + cross*dt - correction
    vx_new = trunc48(vx + cx_dt - corr_vx)
    vy_new = trunc48(vy + cy_dt - corr_vy)
    vz_new = trunc48(vz + cz_dt - corr_vz)

    # p' = p + v*dt
    px_new = trunc48(px + vx_dt)
    py_new = trunc48(py + vy_dt)
    pz_new = trunc48(pz + vz_dt)

    return [px_new, vx_new, wx, py_new, vy_new, wy, pz_new, vz_new, wz]

# ─── Covariance reconstruct (matching covariance_reconstruct_3d.vhd) ────────

def compute_weighted_outer_sum_fp(chi_pred, x_pred, W0, Wi):
    """Compute sum of weighted outer products matching VHDL covariance_reconstruct_3d.
    Two-stage shifting matching VHDL pipeline:
      Stage 1 (WEIGHT): outer(112-bit) * weight(48-bit), shift_right(Q), resize(96)
      Stage 2 (ADD): shift_right(Q), resize(56), accumulate in 64-bit
      Final (NORMALIZE): resize(acc, 48)"""
    n = len(x_pred)
    acc = [[0]*n for _ in range(n)]

    for j in range(NUM_SIGMA):
        w = W0 if j == 0 else Wi
        diff = [trunc48(chi_pred[j][i] - x_pred[i]) for i in range(n)]

        for r in range(n):
            for c in range(r, n):
                # Stage 1: outer product * weight, shift by Q
                outer = diff[r] * diff[c]      # 48*48 = 96-bit (112-bit in VHDL)
                weighted_full = outer * w       # ~144-bit
                weighted_96 = trunc_n(weighted_full >> Q, 96)  # shift Q, resize 96

                # Stage 2: shift by Q again, resize to 56, accumulate in 64
                shifted_56 = trunc_n(weighted_96 >> Q, 56)     # shift Q, resize 56
                acc[r][c] += shifted_56
                if c != r:
                    acc[c][r] += shifted_56

    # Final: resize accumulator to 48-bit
    P = [[0]*n for _ in range(n)]
    for r in range(n):
        for c in range(n):
            P[r][c] = trunc48(acc[r][c])

    return P

# ─── 3x3 Matrix Inverse (matching matrix_inverse_3x3.vhd, Cramer's rule) ───

def invert_3x3_fp(M):
    """Invert 3x3 matrix matching VHDL matrix_inverse_3x3.vhd.
    Uses 144-bit determinant, 96-bit cofactors, direct division."""
    a, b, c = M[0][0], M[0][1], M[0][2]
    d, e, f = M[1][0], M[1][1], M[1][2]
    g, h, i = M[2][0], M[2][1], M[2][2]

    # Cofactors via 96-bit products, shift_right(Q), resize(48)
    cof11 = fp_mul(e, i) - fp_mul(f, h)
    cof12 = -(fp_mul(d, i) - fp_mul(f, g))
    cof13 = fp_mul(d, h) - fp_mul(e, g)
    cof21 = -(fp_mul(b, i) - fp_mul(c, h))
    cof22 = fp_mul(a, i) - fp_mul(c, g)
    cof23 = -(fp_mul(a, h) - fp_mul(b, g))
    cof31 = fp_mul(b, f) - fp_mul(c, e)
    cof32 = -(fp_mul(a, f) - fp_mul(c, d))
    cof33 = fp_mul(a, e) - fp_mul(b, d)

    # Determinant: 144-bit via a*cof11 + b*cof12 + c*cof13
    # VHDL: det_term = s11 * minor (48-bit * 48-bit = 96-bit)
    # Then sum 3 terms and shift_right(Q)
    det_wide = a * cof11 + b * cof12 + c * cof13  # ~96-bit
    det_s = trunc48(det_wide >> Q)

    # Singularity check
    if abs(det_s) < 4096:
        det_s = 4096 if det_s >= 0 else -4096

    # Division: shift_left(cofactor, Q) / det (96-bit / 48-bit)
    inv = [[0]*3 for _ in range(3)]
    cofactors = [[cof11, cof21, cof31],
                 [cof12, cof22, cof32],
                 [cof13, cof23, cof33]]
    for r in range(3):
        for c_idx in range(3):
            if det_s != 0:
                inv[r][c_idx] = trunc48((cofactors[r][c_idx] << Q) // det_s)
            else:
                inv[r][c_idx] = 0
    return inv

# ─── Kalman Gain (matching kalman_gain_3d.vhd) ──────────────────────────────

def compute_kalman_gain_fp(Pxz, S_inv):
    """K = Pxz @ S_inv with 96-bit intermediates and gain saturation."""
    K = [[0]*3 for _ in range(9)]
    for r in range(9):
        for c in range(3):
            # VHDL: 96-bit product sum, shift_right(Q), saturate to [-1,+1]
            acc = 0
            for k in range(3):
                acc += Pxz[r][k] * S_inv[k][c]  # keep full precision
            shifted = trunc48(acc >> Q)
            K[r][c] = saturate_gain(shifted)
    return K

# ─── State Update (matching state_update_3d.vhd) ────────────────────────────

def state_update_fp(x_pred, K, innovation):
    """x = x_pred + K @ nu, with 144-bit intermediate for K*nu sum."""
    state_new = list(x_pred)
    for i in range(9):
        # VHDL: temp_sum = resize(k_i1*nu_x + k_i2*nu_y + k_i3*nu_z, 144)
        # Then shift_right(Q) and resize to 48
        temp_sum = (K[i][0] * innovation[0] +
                    K[i][1] * innovation[1] +
                    K[i][2] * innovation[2])
        correction = trunc48(temp_sum >> Q)
        state_new[i] = trunc48(x_pred[i] + correction)
    return state_new

def saturate_covariance(val_144):
    """Match VHDL saturate_covariance: shift_right(2Q), resize(48),
    then clamp diagonal: negative -> UNITY, >SAFE_MAX_P -> SAFE_MAX_P."""
    shifted = trunc48(val_144 >> (2 * Q))
    if shifted > SAFE_MAX_P:
        return SAFE_MAX_P
    elif shifted < 0:
        return UNITY_FP  # Reset negative diagonal to 1.0
    else:
        return shifted

def covariance_update_fp(P_pred, K):
    """Joseph form: P = (I-KH)*P_pred*(I-KH)^T + K*R*K^T
    Matches VHDL state_update_3d.vhd exactly:
    - A = I - K*H is block-diagonal (only same-axis K entries used)
    - AP: 96-bit products (no intermediate truncation)
    - APAT: 144-bit products, shift_right(2Q) at end
    - KR: 96-bit products
    - KRK^T: 144-bit products, shift_right(2Q) at end
    - Diagonal: saturate_covariance (negative -> 1.0)
    - Off-diagonal: resize(shift_right(val, 2Q), 48)"""

    # Build A = I - K*H (block-diagonal, matching VHDL CONSTRUCT_A)
    # H = [I3|0|0], so KH has nonzero columns at 0,3,6 only
    # VHDL only uses diagonal-block K entries for A construction
    A = [[0]*9 for _ in range(9)]
    for i in range(9):
        A[i][i] = UNITY_FP  # Identity diagonal

    # X-axis block (states 0,1,2): measurement 0
    A[0][0] = trunc48(UNITY_FP - K[0][0])
    A[1][0] = trunc48(-K[1][0])
    A[2][0] = trunc48(-K[2][0])

    # Y-axis block (states 3,4,5): measurement 1
    A[3][3] = trunc48(UNITY_FP - K[3][1])
    A[4][3] = trunc48(-K[4][1])
    A[5][3] = trunc48(-K[5][1])

    # Z-axis block (states 6,7,8): measurement 2
    A[6][6] = trunc48(UNITY_FP - K[6][2])
    A[7][6] = trunc48(-K[7][2])
    A[8][6] = trunc48(-K[8][2])

    # AP = A * P_pred (96-bit products, no shift yet)
    AP = [[0]*9 for _ in range(9)]
    for i in range(9):
        for j in range(9):
            acc = 0
            for k in range(9):
                if A[i][k] != 0:
                    acc += A[i][k] * P_pred[k][j]  # 48*48 = 96-bit
            AP[i][j] = acc  # keep at full precision (96-bit equivalent)

    # APAT = AP * A^T (144-bit: 96-bit * 48-bit, accumulated)
    # Only compute upper triangle + diagonal (symmetric)
    APAT = [[0]*9 for _ in range(9)]
    for r in range(9):
        for c in range(r, 9):
            acc = 0
            for k in range(9):
                if A[c][k] != 0:
                    acc += AP[r][k] * A[c][k]  # 96*48 = 144-bit
            APAT[r][c] = acc
            APAT[c][r] = acc

    # KR = K * R (96-bit: 48*48, R is diagonal)
    KR = [[0]*3 for _ in range(9)]
    for i in range(9):
        for j in range(3):
            KR[i][j] = K[i][j] * R_DIAG  # 96-bit, no shift

    # KRK^T = KR * K^T (144-bit: 96*48, accumulated)
    KRK = [[0]*9 for _ in range(9)]
    for r in range(9):
        for c in range(r, 9):
            acc = 0
            for k in range(3):
                acc += KR[r][k] * K[c][k]  # 96*48 = 144-bit
            KRK[r][c] = acc
            KRK[c][r] = acc

    # P_new = APAT + KRK, normalize to Q24.24
    P_new = [[0]*9 for _ in range(9)]
    for r in range(9):
        for c in range(r, 9):
            total = APAT[r][c] + KRK[r][c]
            if r == c:
                # Diagonal: saturate_covariance (shift 2Q, clamp)
                P_new[r][c] = saturate_covariance(total)
            else:
                # Off-diagonal: just shift and resize
                P_new[r][c] = trunc48(total >> (2 * Q))
                P_new[c][r] = P_new[r][c]

    return P_new

# ─── UKF Core (Fixed-Point Mode) ────────────────────────────────────────────

def run_ukf_fixed(num_cycles=25):
    """Run fixed-point CTR UKF matching VHDL intermediate precision."""
    results = []

    # Initial state: first measurement as position, zero vel/omega
    state = [MEAS_X[0], 0, 0, MEAS_Y[0], 0, 0, MEAS_Z[0], 0, 0]

    # Initial covariance P0 (9x9 diagonal)
    P = [[0]*9 for _ in range(9)]
    P[0][0] = P0_POS; P[1][1] = P0_VEL; P[2][2] = P0_OMEGA
    P[3][3] = P0_POS; P[4][4] = P0_VEL; P[5][5] = P0_OMEGA
    P[6][6] = P0_POS; P[7][7] = P0_VEL; P[8][8] = P0_OMEGA

    for cycle in range(num_cycles):
        z_meas = [MEAS_X[cycle], MEAS_Y[cycle], MEAS_Z[cycle]]

        # === PREDICTION PHASE ===
        # 1. Cholesky decomposition of P
        L = cholesky_9x9_fp(P)

        # 2. Generate sigma points (matching sigma_3d.vhd)
        # chi0 = mean, chi1-9 = mean + gamma*L_col, chi10-18 = mean - gamma*L_col
        sigma_pts = [list(state)]
        for j in range(9):
            col = [L[i][j] for i in range(9)]
            plus = list(state)
            minus = list(state)
            for i in range(9):
                # VHDL: resize(shift_right(GAMMA * L_reg, Q), 48)
                perturbation = fp_mul(GAMMA_FP, col[i])
                plus[i] = trunc48(state[i] + perturbation)
                minus[i] = trunc48(state[i] - perturbation)
            sigma_pts.append(plus)
        # Append negative perturbations (chi10-18)
        for j in range(9):
            col = [L[i][j] for i in range(9)]
            minus = list(state)
            for i in range(9):
                perturbation = fp_mul(GAMMA_FP, col[i])
                minus[i] = trunc48(state[i] - perturbation)
            sigma_pts.append(minus)

        # 3. Propagate sigma points through CTR motion model
        chi_pred = [ctr_predict_sigma_fp(sp) for sp in sigma_pts]

        # 4. Predicted mean (matching predicted_mean_3d.vhd)
        # W0_MEAN=0, Wi_MEAN=1/18; weighted sum of sigma points 1-18
        x_pred = [0] * 9
        for i in range(9):
            acc = 0
            for j in range(1, NUM_SIGMA):
                acc += WI_MEAN * chi_pred[j][i]  # keep wide
            x_pred[i] = trunc48(acc >> Q)

        # 5. Predicted covariance (matching covariance_reconstruct_3d.vhd)
        # Wide intermediates: 112-bit outer products, 64-bit accumulators, shift 2Q
        P_pred = compute_weighted_outer_sum_fp(chi_pred, x_pred, W0_COV, WI_COV)

        # Add process noise Q (matching process_noise_3d.vhd)
        P_pred[0][0] = fp_clamp_p(P_pred[0][0] + Q_POS)
        P_pred[1][1] = fp_clamp_p(P_pred[1][1] + Q_VEL)
        P_pred[2][2] = fp_clamp_p(P_pred[2][2] + Q_OMEGA)
        P_pred[3][3] = fp_clamp_p(P_pred[3][3] + Q_POS)
        P_pred[4][4] = fp_clamp_p(P_pred[4][4] + Q_VEL)
        P_pred[5][5] = fp_clamp_p(P_pred[5][5] + Q_OMEGA)
        P_pred[6][6] = fp_clamp_p(P_pred[6][6] + Q_POS)
        P_pred[7][7] = fp_clamp_p(P_pred[7][7] + Q_VEL)
        P_pred[8][8] = fp_clamp_p(P_pred[8][8] + Q_OMEGA)

        # === MEASUREMENT UPDATE PHASE ===
        # Measurement sigma points: H = [I3 | 0], z_i = [chi_x_pos, chi_y_pos, chi_z_pos]
        z_sigma = [[chi_pred[j][0], chi_pred[j][3], chi_pred[j][6]] for j in range(NUM_SIGMA)]

        # Predicted measurement mean (matching measurement_mean_3d.vhd)
        z_pred = [0] * 3
        for m in range(3):
            acc = 0
            for j in range(1, NUM_SIGMA):
                acc += WI_MEAN * z_sigma[j][m]
            z_pred[m] = trunc48(acc >> Q)

        # Innovation (matching innovation_3d.vhd)
        innovation = [trunc48(z_meas[m] - z_pred[m]) for m in range(3)]

        # Innovation covariance S (matching innovation_covariance_3d.vhd)
        # Same wide intermediate approach as covariance_reconstruct
        S = compute_weighted_outer_sum_3x3_fp(z_sigma, z_pred, W0_COV, WI_COV)
        S[0][0] = fp_clamp_p(S[0][0] + R_DIAG)
        S[1][1] = fp_clamp_p(S[1][1] + R_DIAG)
        S[2][2] = fp_clamp_p(S[2][2] + R_DIAG)

        # Cross-covariance Pxz (matching cross_covariance_3d.vhd)
        Pxz = compute_cross_covariance_fp(chi_pred, x_pred, z_sigma, z_pred,
                                           W0_COV, WI_COV)

        # Matrix inverse S^-1 (matching matrix_inverse_3x3.vhd)
        S_inv = invert_3x3_fp(S)

        # Kalman gain K = Pxz @ S^-1 (matching kalman_gain_3d.vhd)
        K = compute_kalman_gain_fp(Pxz, S_inv)

        # State update (matching state_update_3d.vhd, 144-bit K*nu)
        state_new = state_update_fp(x_pred, K, innovation)

        # Covariance update - Joseph form (matching state_update_3d.vhd)
        # P = (I-KH)*P_pred*(I-KH)^T + K*R*K^T with block-diagonal A
        P_new = covariance_update_fp(P_pred, K)

        state = state_new
        P = P_new

        results.append({
            'cycle': cycle,
            'est_x': state[0], 'vel_x': state[1], 'omega_x': state[2],
            'est_y': state[3], 'vel_y': state[4], 'omega_y': state[5],
            'est_z': state[6], 'vel_z': state[7], 'omega_z': state[8],
            'p_xpos': P[0][0], 'p_xvel': P[1][1], 'p_xomg': P[2][2],
            'p_ypos': P[3][3], 'p_yvel': P[4][4], 'p_yomg': P[5][5],
            'p_zpos': P[6][6], 'p_zvel': P[7][7], 'p_zomg': P[8][8],
        })

    return results

def compute_weighted_outer_sum_3x3_fp(z_sigma, z_pred, W0, Wi):
    """3x3 version for innovation covariance, matching VHDL two-stage shifting."""
    acc = [[0]*3 for _ in range(3)]
    for j in range(NUM_SIGMA):
        w = W0 if j == 0 else Wi
        diff = [trunc48(z_sigma[j][m] - z_pred[m]) for m in range(3)]
        for r in range(3):
            for c in range(r, 3):
                outer = diff[r] * diff[c]
                weighted_full = outer * w
                weighted_96 = trunc_n(weighted_full >> Q, 96)
                shifted_56 = trunc_n(weighted_96 >> Q, 56)
                acc[r][c] += shifted_56
                if c != r:
                    acc[c][r] += shifted_56
    S = [[0]*3 for _ in range(3)]
    for r in range(3):
        for c in range(3):
            S[r][c] = trunc48(acc[r][c])
    return S

def compute_cross_covariance_fp(chi_pred, x_pred, z_sigma, z_pred, W0, Wi):
    """Cross-covariance Pxz (9x3), matching VHDL two-stage shifting."""
    acc = [[0]*3 for _ in range(9)]
    for j in range(NUM_SIGMA):
        w = W0 if j == 0 else Wi
        dx = [trunc48(chi_pred[j][i] - x_pred[i]) for i in range(9)]
        dz = [trunc48(z_sigma[j][m] - z_pred[m]) for m in range(3)]
        for r in range(9):
            for c in range(3):
                outer = dx[r] * dz[c]
                weighted_full = outer * w
                weighted_96 = trunc_n(weighted_full >> Q, 96)
                shifted_56 = trunc_n(weighted_96 >> Q, 56)
                acc[r][c] += shifted_56
    Pxz = [[0]*3 for _ in range(9)]
    for r in range(9):
        for c in range(3):
            Pxz[r][c] = trunc48(acc[r][c])
    return Pxz

# ─── UKF Core (Float Mode) ──────────────────────────────────────────────────

def ctr_predict_sigma_float(state, dt=0.02):
    px, vx, wx, py, vy, wy, pz, vz, wz = state
    cx = wy*vz - wz*vy
    cy = wz*vx - wx*vz
    cz = wx*vy - wy*vx
    omega_sq = wx**2 + wy**2 + wz**2
    vx_new = vx + cx*dt - 0.5*omega_sq*vx*dt**2
    vy_new = vy + cy*dt - 0.5*omega_sq*vy*dt**2
    vz_new = vz + cz*dt - 0.5*omega_sq*vz*dt**2
    px_new = px + vx*dt
    py_new = py + vy*dt
    pz_new = pz + vz*dt
    return [px_new, vx_new, wx, py_new, vy_new, wy, pz_new, vz_new, wz]

def run_ukf_float(num_cycles=25):
    dt = 0.02
    gamma = 3.0
    wi_mean = 1.0 / 18.0
    w0_cov = 2.0
    wi_cov = 1.0 / 18.0

    results = []
    state = np.array([
        q24_to_real(MEAS_X[0]), 0.0, 0.0,
        q24_to_real(MEAS_Y[0]), 0.0, 0.0,
        q24_to_real(MEAS_Z[0]), 0.0, 0.0,
    ])
    P = np.diag([5.0, 20.0, 1.0, 5.0, 20.0, 1.0, 5.0, 20.0, 1.0])
    Q_noise = np.diag([0.05, 0.001, 0.001, 0.05, 0.001, 0.001, 0.05, 0.001, 0.001])
    R_noise = np.diag([0.25, 0.25, 0.25])
    H = np.zeros((3, 9)); H[0,0]=1.0; H[1,3]=1.0; H[2,6]=1.0

    for cycle in range(num_cycles):
        z_meas = np.array([q24_to_real(MEAS_X[cycle]), q24_to_real(MEAS_Y[cycle]),
                           q24_to_real(MEAS_Z[cycle])])
        try:
            L = np.linalg.cholesky(P)
        except np.linalg.LinAlgError:
            P = (P + P.T) / 2 + np.eye(9) * 1e-6
            L = np.linalg.cholesky(P)

        sigma_pts = [state.copy()]
        for j in range(9):
            sigma_pts.append(state + gamma * L[:, j])
        for j in range(9):
            sigma_pts.append(state - gamma * L[:, j])

        chi_pred = [np.array(ctr_predict_sigma_float(sp.tolist(), dt)) for sp in sigma_pts]

        x_pred = np.zeros(9)
        for j in range(1, NUM_SIGMA):
            x_pred += wi_mean * chi_pred[j]

        P_pred = np.zeros((9, 9))
        for j in range(NUM_SIGMA):
            w = w0_cov if j == 0 else wi_cov
            diff = chi_pred[j] - x_pred
            P_pred += w * np.outer(diff, diff)
        P_pred += Q_noise

        z_sigma = [H @ cp for cp in chi_pred]
        z_pred = np.zeros(3)
        for j in range(1, NUM_SIGMA):
            z_pred += wi_mean * z_sigma[j]

        innovation = z_meas - z_pred
        S = np.zeros((3, 3))
        for j in range(NUM_SIGMA):
            w = w0_cov if j == 0 else wi_cov
            dz = z_sigma[j] - z_pred
            S += w * np.outer(dz, dz)
        S += R_noise

        Pxz = np.zeros((9, 3))
        for j in range(NUM_SIGMA):
            w = w0_cov if j == 0 else wi_cov
            dx = chi_pred[j] - x_pred
            dz = z_sigma[j] - z_pred
            Pxz += w * np.outer(dx, dz)

        K = Pxz @ np.linalg.inv(S)
        K = np.clip(K, -1.0, 1.0)
        state = x_pred + K @ innovation
        P = P_pred - K @ S @ K.T
        P = (P + P.T) / 2
        eigvals = np.linalg.eigvalsh(P)
        if np.min(eigvals) < 0:
            P += np.eye(9) * (abs(np.min(eigvals)) + 1e-8)

        results.append({
            'cycle': cycle,
            'est_x': real_to_q24(state[0]), 'vel_x': real_to_q24(state[1]), 'omega_x': real_to_q24(state[2]),
            'est_y': real_to_q24(state[3]), 'vel_y': real_to_q24(state[4]), 'omega_y': real_to_q24(state[5]),
            'est_z': real_to_q24(state[6]), 'vel_z': real_to_q24(state[7]), 'omega_z': real_to_q24(state[8]),
            'p_xpos': real_to_q24(P[0,0]), 'p_xvel': real_to_q24(P[1,1]), 'p_xomg': real_to_q24(P[2,2]),
            'p_ypos': real_to_q24(P[3,3]), 'p_yvel': real_to_q24(P[4,4]), 'p_yomg': real_to_q24(P[5,5]),
            'p_zpos': real_to_q24(P[6,6]), 'p_zvel': real_to_q24(P[7,7]), 'p_zomg': real_to_q24(P[8,8]),
        })
    return results

# ─── Output ──────────────────────────────────────────────────────────────────

def print_results(results, mode):
    print(f"=== CTR UKF Golden Model ({mode} mode) - {len(results)} Cycles ===")
    print(f"Format: Q24.24 signed integers (scale={SCALE})")
    print()
    for r in results:
        c = r['cycle']
        print(f"CYCLE {c}")
        print(f"  EST_X={r['est_x']}  EST_Y={r['est_y']}  EST_Z={r['est_z']}")
        print(f"  VEL_X={r['vel_x']}  VEL_Y={r['vel_y']}  VEL_Z={r['vel_z']}")
        print(f"  OMEGA_X={r['omega_x']}  OMEGA_Y={r['omega_y']}  OMEGA_Z={r['omega_z']}")
        print(f"  P_xpos={r['p_xpos']}  P_xvel={r['p_xvel']}  P_xomg={r['p_xomg']}"
              f"  P_ypos={r['p_ypos']}  P_yvel={r['p_yvel']}  P_yomg={r['p_yomg']}"
              f"  P_zpos={r['p_zpos']}  P_zvel={r['p_zvel']}  P_zomg={r['p_zomg']}")
        print()
    print("=== GOLDEN MODEL COMPLETE ===")

def write_output(results, filename, mode):
    with open(filename, 'w') as f:
        f.write(f"=== CTR UKF Golden Model ({mode} mode) - {len(results)} Cycles ===\n")
        f.write(f"Format: Q24.24 signed integers (scale={SCALE})\n\n")
        for r in results:
            c = r['cycle']
            f.write(f"CYCLE {c}\n")
            f.write(f"  EST_X={r['est_x']}  EST_Y={r['est_y']}  EST_Z={r['est_z']}\n")
            f.write(f"  VEL_X={r['vel_x']}  VEL_Y={r['vel_y']}  VEL_Z={r['vel_z']}\n")
            f.write(f"  OMEGA_X={r['omega_x']}  OMEGA_Y={r['omega_y']}  OMEGA_Z={r['omega_z']}\n")
            f.write(f"  P_xpos={r['p_xpos']}  P_xvel={r['p_xvel']}  P_xomg={r['p_xomg']}"
                    f"  P_ypos={r['p_ypos']}  P_yvel={r['p_yvel']}  P_yomg={r['p_yomg']}"
                    f"  P_zpos={r['p_zpos']}  P_zvel={r['p_zvel']}  P_zomg={r['p_zomg']}\n")
            f.write("\n")
        f.write("=== GOLDEN MODEL COMPLETE ===\n")

def main():
    parser = argparse.ArgumentParser(description="CTR UKF Golden Model")
    parser.add_argument('--mode', choices=['float', 'fixed'], default='float',
                        help='Arithmetic mode (default: float)')
    parser.add_argument('--output', '-o', default=None,
                        help='Output file (default: golden_model_<mode>.txt)')
    parser.add_argument('--cycles', '-n', type=int, default=25)
    args = parser.parse_args()

    if args.output is None:
        args.output = f"golden_model_{args.mode}.txt"

    print(f"Running CTR UKF golden model in {args.mode} mode for {args.cycles} cycles...")

    if args.mode == 'fixed':
        results = run_ukf_fixed(args.cycles)
    else:
        results = run_ukf_float(args.cycles)

    print_results(results, args.mode)
    write_output(results, args.output, args.mode)
    print(f"\nOutput written to {args.output}")

    for r in results[:3]:
        print(f"  Cycle {r['cycle']}: x_pos={q24_to_real(r['est_x']):.4f}  "
              f"y_pos={q24_to_real(r['est_y']):.4f}  z_pos={q24_to_real(r['est_z']):.4f}")

if __name__ == '__main__':
    main()
