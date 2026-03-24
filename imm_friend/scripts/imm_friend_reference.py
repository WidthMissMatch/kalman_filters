#!/usr/bin/env python3
"""
IMM Friend Reference Implementation
====================================
Interacting Multiple Model filter with 3 UKF motion models:
  1. Singer (9D): [x_pos, x_vel, x_acc, y_pos, y_vel, y_acc, z_pos, z_vel, z_acc]
  2. CTRA   (7D): [px, py, v, theta, omega, a, z]
  3. Bicycle(7D): [px, py, v, theta, delta, a, z]

Matches VHDL implementation in imm_friend_top.vhd with Q24.24 fixed-point.
"""

import numpy as np
import csv
import struct
import os
import sys
from copy import deepcopy

# ============================================================================
# Configuration
# ============================================================================

DT = 0.02
TAU = 2.0       # Singer time constant
L_BIKE = 3.6    # Bicycle wheelbase
LR_BIKE = 1.6   # CG to rear axle

# Measurement noise (diagonal)
R_DIAG = np.array([0.25, 0.25, 0.25])

# --- Process noise (diagonal only, matching VHDL constants) ---

# Singer 9D: Q_POS=0.05, Q_VEL=0.00025, Q_ACC=0.00001
# (from process_noise_3d.vhd: Q11=838861/2^24=0.05, Q22=4194/2^24≈0.00025, Q33=168/2^24≈0.00001)
Q_SINGER = np.diag([
    0.05, 0.00025, 0.00001,   # x: pos, vel, acc
    0.05, 0.00025, 0.00001,   # y: pos, vel, acc
    0.05, 0.00025, 0.00001,   # z: pos, vel, acc
])

# CTRA 7D: from process_noise_ctra.vhd
Q_CTRA = np.diag([0.05, 0.05, 0.1, 0.01, 0.005, 0.1, 0.05])

# Bicycle 7D: from process_noise_bicycle.vhd
Q_BICYCLE = np.diag([0.5, 0.5, 10.0, 0.05, 0.001, 5.0, 0.5])

# --- Markov transition matrix (from imm_friend_state_mixer.vhd) ---
#        to:  CTRA   Singer  Bicycle
# from CTRA:  0.95    0.03    0.02
# from Si:    0.03    0.94    0.03
# from Bi:    0.02    0.03    0.95
T_MARKOV = np.array([
    [0.95, 0.03, 0.02],   # from CTRA
    [0.03, 0.94, 0.03],   # from Singer
    [0.02, 0.03, 0.95],   # from Bicycle
])

# Initial probabilities: CTRA=0.4, Singer=0.3, Bicycle=0.3
PROB_INIT = np.array([0.4, 0.3, 0.3])

# UKF parameters
ALPHA = 1e-3
BETA = 2.0
KAPPA_OFFSET = 0  # kappa = 3 - n typically, but we use alpha-based scaling

# Initial covariance diagonal
P_INIT_SINGER = np.diag([10.0, 1.0, 0.01,
                          10.0, 1.0, 0.01,
                          10.0, 1.0, 0.01])

P_INIT_CTRA = np.diag([10.0, 10.0, 100.0, 1.0, 0.1, 1.0, 10.0])

P_INIT_BICYCLE = np.diag([10.0, 10.0, 100.0, 1.0, 0.01, 1.0, 10.0])


# ============================================================================
# UKF Core
# ============================================================================

class UKF:
    """Standard Unscented Kalman Filter (no square-root)."""

    def __init__(self, n, fx, hx, Q, R, x0, P0, dt=DT):
        self.n = n
        self.fx = fx   # state transition: fx(x, dt) -> x_pred
        self.hx = hx   # measurement function: hx(x) -> z_pred
        self.Q = Q.copy()
        self.R = np.diag(R) if R.ndim == 1 else R.copy()
        self.x = x0.copy()
        self.P = P0.copy()
        self.dt = dt

        # Sigma point weights (Van der Merwe parameterization)
        self.alpha = 0.1   # moderate spread for VHDL compatibility
        self.beta = 2.0
        self.kappa = 3.0 - n
        self.lam = self.alpha**2 * (n + self.kappa) - n

        self.n_sigma = 2 * n + 1
        self._compute_weights()

    def _compute_weights(self):
        n = self.n
        lam = self.lam
        self.Wm = np.full(self.n_sigma, 0.5 / (n + lam))
        self.Wc = np.full(self.n_sigma, 0.5 / (n + lam))
        self.Wm[0] = lam / (n + lam)
        self.Wc[0] = lam / (n + lam) + (1 - self.alpha**2 + self.beta)
        self.gamma = np.sqrt(n + lam)

    def _sigma_points(self, x, P):
        n = self.n
        sigmas = np.zeros((self.n_sigma, n))
        sigmas[0] = x

        try:
            S = np.linalg.cholesky((n + self.lam) * P)
        except np.linalg.LinAlgError:
            # Force positive definite
            eigvals = np.linalg.eigvalsh(P)
            min_eig = min(eigvals)
            if min_eig < 0:
                P = P + (-min_eig + 1e-6) * np.eye(n)
            S = np.linalg.cholesky((n + self.lam) * P)

        for i in range(n):
            sigmas[i + 1] = x + S[i]
            sigmas[n + i + 1] = x - S[i]
        return sigmas

    def predict(self):
        """Predict step."""
        sigmas = self._sigma_points(self.x, self.P)

        # Propagate sigma points
        sigmas_f = np.zeros_like(sigmas)
        for i in range(self.n_sigma):
            sigmas_f[i] = self.fx(sigmas[i], self.dt)

        # Predicted mean
        x_pred = np.zeros(self.n)
        for i in range(self.n_sigma):
            x_pred += self.Wm[i] * sigmas_f[i]

        # Predicted covariance
        P_pred = self.Q.copy()
        for i in range(self.n_sigma):
            d = sigmas_f[i] - x_pred
            P_pred += self.Wc[i] * np.outer(d, d)

        self.x = x_pred
        self.P = P_pred
        self._sigmas_f = sigmas_f

    def update(self, z):
        """Update step. Returns innovation and innovation covariance."""
        sigmas_f = self._sigmas_f

        # Transform sigma points through measurement function
        m = len(z)
        sigmas_h = np.zeros((self.n_sigma, m))
        for i in range(self.n_sigma):
            sigmas_h[i] = self.hx(sigmas_f[i])

        # Measurement mean
        z_pred = np.zeros(m)
        for i in range(self.n_sigma):
            z_pred += self.Wm[i] * sigmas_h[i]

        # Innovation covariance S = Pzz + R
        S = self.R.copy()
        for i in range(self.n_sigma):
            dz = sigmas_h[i] - z_pred
            S += self.Wc[i] * np.outer(dz, dz)

        # Cross-covariance Pxz
        Pxz = np.zeros((self.n, m))
        for i in range(self.n_sigma):
            dx = sigmas_f[i] - self.x
            dz = sigmas_h[i] - z_pred
            Pxz += self.Wc[i] * np.outer(dx, dz)

        # Kalman gain
        K = Pxz @ np.linalg.inv(S)

        # Innovation
        nu = z - z_pred

        # State update
        self.x = self.x + K @ nu

        # Covariance update (standard form)
        self.P = self.P - K @ S @ K.T

        # Force symmetry
        self.P = 0.5 * (self.P + self.P.T)

        return nu, S


# ============================================================================
# Motion Models
# ============================================================================

def singer_fx(x, dt):
    """Singer (Constant Acceleration) 9D state transition.
    State: [x_pos, x_vel, x_acc, y_pos, y_vel, y_acc, z_pos, z_vel, z_acc]
    Singer model: acc decays with time constant tau.
    """
    tau = TAU
    alpha_s = 1.0 / tau
    e_at = np.exp(-alpha_s * dt)

    x_new = np.zeros(9)
    for axis in range(3):
        p_idx = axis * 3
        v_idx = axis * 3 + 1
        a_idx = axis * 3 + 2

        pos = x[p_idx]
        vel = x[v_idx]
        acc = x[a_idx]

        # Singer state transition
        x_new[p_idx] = pos + vel * dt + acc * (dt - tau * (1 - e_at)) / 1.0
        x_new[v_idx] = vel + acc * tau * (1 - e_at)
        x_new[a_idx] = acc * e_at

    return x_new


def ctra_fx(x, dt):
    """CTRA (Constant Turn-Rate and Acceleration) 7D state transition.
    State: [px, py, v, theta, omega, a, z]
    """
    px, py, v, theta, omega, a, z = x

    # Avoid division by zero for omega
    if abs(omega) < 1e-6:
        # Straight-line approximation
        px_new = px + (v * dt + 0.5 * a * dt**2) * np.cos(theta)
        py_new = py + (v * dt + 0.5 * a * dt**2) * np.sin(theta)
    else:
        v_new_temp = v + a * dt
        px_new = px + (v_new_temp * np.sin(theta + omega * dt) - v * np.sin(theta)) / omega \
                    + a * (np.cos(theta + omega * dt) - np.cos(theta)) / (omega**2)
        py_new = py + (-v_new_temp * np.cos(theta + omega * dt) + v * np.cos(theta)) / omega \
                    + a * (np.sin(theta + omega * dt) - np.sin(theta)) / (omega**2)

    v_new = v + a * dt
    theta_new = theta + omega * dt
    omega_new = omega      # constant turn rate
    a_new = a              # constant acceleration
    z_new = z              # z unchanged (no z dynamics in CTRA)

    return np.array([px_new, py_new, v_new, theta_new, omega_new, a_new, z_new])


def bicycle_fx(x, dt):
    """Bicycle model 7D state transition.
    State: [px, py, v, theta, delta, a, z]
    L = wheelbase, lr = CG to rear axle
    beta = atan(lr/L * tan(delta)) -- slip angle
    """
    px, py, v, theta, delta, a, z = x

    # Slip angle
    if abs(delta) < 1e-8:
        beta = 0.0
    else:
        beta = np.arctan(LR_BIKE / L_BIKE * np.tan(delta))

    # State transition
    px_new = px + v * np.cos(theta + beta) * dt
    py_new = py + v * np.sin(theta + beta) * dt
    v_new = v + a * dt
    theta_new = theta + (v / L_BIKE) * np.sin(beta) * dt
    delta_new = delta    # steering angle constant
    a_new = a            # acceleration constant
    z_new = z            # z unchanged

    return np.array([px_new, py_new, v_new, theta_new, delta_new, a_new, z_new])


# ============================================================================
# Measurement Models
# ============================================================================

def singer_hx(x):
    """Singer: measure [x_pos, y_pos, z_pos] = states [0, 3, 6]."""
    return np.array([x[0], x[3], x[6]])

def ctra_hx(x):
    """CTRA: measure [px, py, z] = states [0, 1, 6]."""
    return np.array([x[0], x[1], x[6]])

def bicycle_hx(x):
    """Bicycle: measure [px, py, z] = states [0, 1, 6]."""
    return np.array([x[0], x[1], x[6]])


# ============================================================================
# State Mappers (matching VHDL state_mapper modules)
# ============================================================================

def singer9d_to_ctra7d(x9):
    """Singer 9D -> CTRA 7D.
    x9 = [xp, xv, xa, yp, yv, ya, zp, zv, za]
    x7 = [px, py, v, theta, omega, a, z]
    """
    xp, xv, xa, yp, yv, ya, zp, zv, za = x9

    px = xp
    py = yp
    v = np.sqrt(xv**2 + yv**2)
    theta = np.arctan2(yv, xv)

    # omega = (xv * ya - yv * xa) / (xv^2 + yv^2)
    v_sq = xv**2 + yv**2
    if v_sq > 1e-10:
        omega = (xv * ya - yv * xa) / v_sq
    else:
        omega = 0.0

    # a = (xv*xa + yv*ya) / v  (tangential acceleration)
    if v > 1e-6:
        a = (xv * xa + yv * ya) / v
    else:
        a = np.sqrt(xa**2 + ya**2)

    z = zp

    return np.array([px, py, v, theta, omega, a, z])


def singer9d_to_bicycle7d(x9):
    """Singer 9D -> Bicycle 7D.
    Same as CTRA mapping but delta=0 (no direct omega->delta mapping).
    """
    xp, xv, xa, yp, yv, ya, zp, zv, za = x9

    px = xp
    py = yp
    v = np.sqrt(xv**2 + yv**2)
    theta = np.arctan2(yv, xv)
    delta = 0.0   # no direct mapping from Singer to steering angle

    if v > 1e-6:
        a = (xv * xa + yv * ya) / v
    else:
        a = np.sqrt(xa**2 + ya**2)

    z = zp

    return np.array([px, py, v, theta, delta, a, z])


def ctra7d_to_singer9d(x7):
    """CTRA 7D -> Singer 9D.
    x7 = [px, py, v, theta, omega, a, z]
    x9 = [xp, xv, xa, yp, yv, ya, zp, zv, za]
    """
    px, py, v, theta, omega, a, z = x7

    xp = px
    yp = py
    xv = v * np.cos(theta)
    yv = v * np.sin(theta)
    xa = a * np.cos(theta)
    ya = a * np.sin(theta)
    zp = z
    zv = 0.0
    za = 0.0

    return np.array([xp, xv, xa, yp, yv, ya, zp, zv, za])


def bicycle7d_to_singer9d(x7):
    """Bicycle 7D -> Singer 9D.
    x7 = [px, py, v, theta, delta, a, z]
    Same mapping as CTRA (delta/omega not needed for 9D).
    """
    px, py, v, theta, delta, a, z = x7

    xp = px
    yp = py
    xv = v * np.cos(theta)
    yv = v * np.sin(theta)
    xa = a * np.cos(theta)
    ya = a * np.sin(theta)
    zp = z
    zv = 0.0
    za = 0.0

    return np.array([xp, xv, xa, yp, yv, ya, zp, zv, za])


def ctra7d_to_bicycle7d(x7_ctra):
    """CTRA 7D -> Bicycle 7D.
    px, py, v, theta stay the same.
    omega -> delta = 0 (no direct mapping).
    """
    px, py, v, theta, omega, a, z = x7_ctra
    return np.array([px, py, v, theta, 0.0, a, z])


def bicycle7d_to_ctra7d(x7_bike):
    """Bicycle 7D -> CTRA 7D.
    px, py, v, theta stay the same.
    delta -> omega = 0 (no direct mapping).
    """
    px, py, v, theta, delta, a, z = x7_bike
    return np.array([px, py, v, theta, 0.0, a, z])


# ============================================================================
# Covariance Mappers (diagonal approximation)
# ============================================================================

def singer_P_to_ctra_P(P9):
    """Map Singer 9x9 covariance to CTRA 7x7 (diagonal approximation)."""
    P7 = np.zeros((7, 7))
    P7[0, 0] = P9[0, 0]   # px from x_pos
    P7[1, 1] = P9[3, 3]   # py from y_pos
    P7[2, 2] = P9[1, 1] + P9[4, 4]  # v from xv, yv
    P7[3, 3] = 1.0        # theta: default
    P7[4, 4] = 0.1        # omega: default
    P7[5, 5] = P9[2, 2] + P9[5, 5]  # a from xa, ya
    P7[6, 6] = P9[6, 6]   # z
    return P7


def singer_P_to_bicycle_P(P9):
    """Map Singer 9x9 covariance to Bicycle 7x7 (diagonal approximation)."""
    P7 = np.zeros((7, 7))
    P7[0, 0] = P9[0, 0]
    P7[1, 1] = P9[3, 3]
    P7[2, 2] = P9[1, 1] + P9[4, 4]
    P7[3, 3] = 1.0
    P7[4, 4] = 0.01       # delta: small
    P7[5, 5] = P9[2, 2] + P9[5, 5]
    P7[6, 6] = P9[6, 6]
    return P7


def ctra_P_to_singer_P(P7):
    """Map CTRA 7x7 covariance to Singer 9x9 (diagonal approximation)."""
    P9 = np.zeros((9, 9))
    P9[0, 0] = P7[0, 0]   # x_pos from px
    P9[1, 1] = P7[2, 2]   # x_vel from v
    P9[2, 2] = P7[5, 5]   # x_acc from a
    P9[3, 3] = P7[1, 1]   # y_pos from py
    P9[4, 4] = P7[2, 2]   # y_vel from v
    P9[5, 5] = P7[5, 5]   # y_acc from a
    P9[6, 6] = P7[6, 6]   # z_pos
    P9[7, 7] = 1.0        # z_vel: default
    P9[8, 8] = 1.0        # z_acc: default
    return P9


def bicycle_P_to_singer_P(P7):
    """Map Bicycle 7x7 covariance to Singer 9x9 (diagonal approximation)."""
    return ctra_P_to_singer_P(P7)  # same structure


# ============================================================================
# IMM Mixing Step
# ============================================================================

def compute_mixing_probs(probs, T):
    """Compute mixing probabilities mu_ij and normalizing constants c_j.

    probs: [p_ctra, p_singer, p_bicycle]
    T: 3x3 Markov transition matrix T[i,j] = P(model j | model i was active)

    Returns:
        mu: 3x3 array where mu[i,j] = probability that model i contributes to model j
        c: 3-vector of normalizing constants
    """
    n = len(probs)
    c = np.zeros(n)
    mu = np.zeros((n, n))

    # c_j = sum_i T[i,j] * prob[i]
    for j in range(n):
        for i in range(n):
            c[j] += T[i, j] * probs[i]

    # mu[i,j] = T[i,j] * prob[i] / c[j]
    for j in range(n):
        if c[j] > 1e-20:
            for i in range(n):
                mu[i, j] = T[i, j] * probs[i] / c[j]
        else:
            mu[:, j] = 1.0 / n  # uniform if degenerate

    return mu, c


def mix_states_and_covs(filters, mappers_to, mappers_from, P_mappers_to, P_mappers_from, mu):
    """
    Mix states and covariances for each target model.

    filters: list of 3 UKF objects [ctra, singer, bicycle]
    mappers_to[j][i]: function to map state from model i space to model j space
    mu[i,j]: mixing weight for source i into target j

    Returns: list of 3 (x_mixed, P_mixed) tuples in each model's native space
    """
    n_models = 3
    mixed = []

    for j in range(n_models):
        # Get all states mapped to model j's space
        states_j = []
        covs_j = []
        for i in range(n_models):
            x_mapped = mappers_to[j][i](filters[i].x)
            P_mapped = P_mappers_to[j][i](filters[i].P)
            states_j.append(x_mapped)
            covs_j.append(P_mapped)

        # Mixed state: x_mix_j = sum_i mu[i,j] * x_i_mapped
        n_j = len(states_j[0])
        x_mix = np.zeros(n_j)
        for i in range(n_models):
            x_mix += mu[i, j] * states_j[i]

        # Mixed covariance: P_mix_j = sum_i mu[i,j] * (P_i_mapped + (x_i - x_mix)(x_i - x_mix)^T)
        P_mix = np.zeros((n_j, n_j))
        for i in range(n_models):
            dx = states_j[i] - x_mix
            P_mix += mu[i, j] * (covs_j[i] + np.outer(dx, dx))

        # Force symmetry
        P_mix = 0.5 * (P_mix + P_mix.T)

        mixed.append((x_mix, P_mix))

    return mixed


# ============================================================================
# IMM Likelihood
# ============================================================================

def gaussian_likelihood(nu, S):
    """Compute Gaussian likelihood N(nu; 0, S).
    Returns scalar likelihood value.
    """
    m = len(nu)
    det_S = np.linalg.det(S)
    if det_S <= 0:
        det_S = 1e-30

    # log likelihood for numerical stability
    sign, logdet = np.linalg.slogdet(S)
    if sign <= 0:
        return 1e-30

    log_L = -0.5 * (m * np.log(2 * np.pi) + logdet + nu @ np.linalg.solve(S, nu))
    L = np.exp(log_L)

    return max(L, 1e-300)


def update_probabilities(probs, likelihoods, c):
    """Update model probabilities.
    prob_j_new = L_j * c_j / sum_k(L_k * c_k)
    """
    n = len(probs)
    probs_new = np.zeros(n)

    total = 0.0
    for j in range(n):
        probs_new[j] = likelihoods[j] * c[j]
        total += probs_new[j]

    if total > 1e-300:
        probs_new /= total
    else:
        probs_new = np.ones(n) / n

    # Clamp to prevent degeneration
    for j in range(n):
        probs_new[j] = max(probs_new[j], 0.001)
    probs_new /= probs_new.sum()

    return probs_new


def fuse_outputs(filters, probs, extractors):
    """Fuse position outputs from all models.
    pos_fused = sum_j prob_j * pos_j

    extractors[j]: function that extracts [px, py, pz] from model j's state
    """
    pos = np.zeros(3)
    for j in range(3):
        p_j = extractors[j](filters[j].x)
        pos += probs[j] * p_j
    return pos


# ============================================================================
# Position Extractors
# ============================================================================

def ctra_pos(x):
    return np.array([x[0], x[1], x[6]])

def singer_pos(x):
    return np.array([x[0], x[3], x[6]])

def bicycle_pos(x):
    return np.array([x[0], x[1], x[6]])


# ============================================================================
# Q24.24 Hex Conversion
# ============================================================================

def float_to_q24_24(val):
    """Convert float to Q24.24 signed 48-bit integer."""
    q = int(round(val * (2**24)))
    # Clamp to 48-bit signed range
    if q > 2**47 - 1:
        q = 2**47 - 1
    elif q < -(2**47):
        q = -(2**47)
    return q


def q24_to_hex(val_float):
    """Convert float to Q24.24 hex string (12 hex digits, 48-bit)."""
    q = float_to_q24_24(val_float)
    if q < 0:
        q += 2**48
    return f"{q:012X}"


# ============================================================================
# Data Loading
# ============================================================================

def load_dataset(csv_path):
    """Load Monaco CSV dataset.
    Returns: list of dicts with keys: gt_x, gt_y, gt_z, meas_x, meas_y, meas_z
    """
    data = []
    with open(csv_path) as f:
        reader = csv.reader(f)
        header = next(reader)
        for row in reader:
            data.append({
                'gt_x': float(row[2]),
                'gt_y': float(row[3]),
                'gt_z': float(row[4]),
                'meas_x': float(row[5]),
                'meas_y': float(row[6]),
                'meas_z': float(row[7]),
            })
    return data


# ============================================================================
# Main IMM Loop
# ============================================================================

def run_imm(csv_path, output_path):
    print(f"Loading dataset from: {csv_path}")
    data = load_dataset(csv_path)
    n_cycles = len(data)
    print(f"Loaded {n_cycles} cycles")

    # -----------------------------------------------------------------------
    # Initialize filters
    # -----------------------------------------------------------------------
    # Use first measurement as initial position
    m0 = np.array([data[0]['meas_x'], data[0]['meas_y'], data[0]['meas_z']])

    # Singer initial state: position = measurement, vel/acc = 0
    x0_singer = np.array([m0[0], 0, 0, m0[1], 0, 0, m0[2], 0, 0])

    # CTRA initial state: position = measurement, v from second measurement if available
    if n_cycles > 1:
        m1 = np.array([data[1]['meas_x'], data[1]['meas_y'], data[1]['meas_z']])
        dx = m1[0] - m0[0]
        dy = m1[1] - m0[1]
        v_init = np.sqrt(dx**2 + dy**2) / DT
        theta_init = np.arctan2(dy, dx)
    else:
        v_init = 0.0
        theta_init = 0.0

    x0_ctra = np.array([m0[0], m0[1], v_init, theta_init, 0.0, 0.0, m0[2]])
    x0_bicycle = np.array([m0[0], m0[1], v_init, theta_init, 0.0, 0.0, m0[2]])

    # Create UKFs
    R = R_DIAG.copy()
    ukf_ctra = UKF(7, ctra_fx, ctra_hx, Q_CTRA, R, x0_ctra, P_INIT_CTRA.copy(), DT)
    ukf_singer = UKF(9, singer_fx, singer_hx, Q_SINGER, R, x0_singer, P_INIT_SINGER.copy(), DT)
    ukf_bicycle = UKF(7, bicycle_fx, bicycle_hx, Q_BICYCLE, R, x0_bicycle, P_INIT_BICYCLE.copy(), DT)

    filters = [ukf_ctra, ukf_singer, ukf_bicycle]
    probs = PROB_INIT.copy()

    # -----------------------------------------------------------------------
    # State mappers: mappers_to[target_model][source_model](x_source) -> x_target_space
    # -----------------------------------------------------------------------
    # Model indices: 0=CTRA, 1=Singer, 2=Bicycle
    identity_7d = lambda x: x.copy()
    identity_9d = lambda x: x.copy()

    mappers_to = [
        # Target = CTRA (7D)
        [identity_7d, singer9d_to_ctra7d, bicycle7d_to_ctra7d],
        # Target = Singer (9D)
        [ctra7d_to_singer9d, identity_9d, bicycle7d_to_singer9d],
        # Target = Bicycle (7D)
        [ctra7d_to_bicycle7d, singer9d_to_bicycle7d, identity_7d],
    ]

    # Covariance mappers (diagonal approximation)
    identity_P7 = lambda P: P.copy()
    identity_P9 = lambda P: P.copy()

    P_mappers_to = [
        # Target = CTRA (7D)
        [identity_P7, singer_P_to_ctra_P, identity_P7],
        # Target = Singer (9D)
        [ctra_P_to_singer_P, identity_P9, bicycle_P_to_singer_P],
        # Target = Bicycle (7D)
        [identity_P7, singer_P_to_bicycle_P, identity_P7],
    ]

    # Position extractors for fusion
    extractors = [ctra_pos, singer_pos, bicycle_pos]

    # -----------------------------------------------------------------------
    # Storage for results
    # -----------------------------------------------------------------------
    results = []
    errors_3d = []

    # -----------------------------------------------------------------------
    # IMM Loop
    # -----------------------------------------------------------------------
    for k in range(n_cycles):
        z = np.array([data[k]['meas_x'], data[k]['meas_y'], data[k]['meas_z']])
        gt = np.array([data[k]['gt_x'], data[k]['gt_y'], data[k]['gt_z']])

        if k == 0:
            # First cycle: just update with measurement (no mixing/predict)
            for f in filters:
                f.predict()
                nu, S = f.update(z)

            # Compute fused output
            pos_fused = fuse_outputs(filters, probs, extractors)
        else:
            # ----- Step 1: Compute mixing probabilities -----
            mu, c = compute_mixing_probs(probs, T_MARKOV)

            # ----- Step 2: Mix states and covariances -----
            mixed = mix_states_and_covs(filters, mappers_to, None, P_mappers_to, None, mu)

            # ----- Step 3: Inject mixed states into filters -----
            filters[0].x = mixed[0][0].copy()
            filters[0].P = mixed[0][1].copy()
            filters[1].x = mixed[1][0].copy()
            filters[1].P = mixed[1][1].copy()
            filters[2].x = mixed[2][0].copy()
            filters[2].P = mixed[2][1].copy()

            # ----- Step 4: Predict -----
            for f in filters:
                f.predict()

            # ----- Step 5: Update -----
            nus = []
            Ss = []
            for f in filters:
                nu, S = f.update(z)
                nus.append(nu)
                Ss.append(S)

            # ----- Step 6: Compute likelihoods -----
            likelihoods = []
            for j in range(3):
                L = gaussian_likelihood(nus[j], Ss[j])
                likelihoods.append(L)

            # ----- Step 7: Update probabilities -----
            probs = update_probabilities(probs, likelihoods, c)

            # ----- Step 8: Fuse output -----
            pos_fused = fuse_outputs(filters, probs, extractors)

        # Compute error
        err = np.sqrt((pos_fused[0] - gt[0])**2 +
                       (pos_fused[1] - gt[1])**2 +
                       (pos_fused[2] - gt[2])**2)
        errors_3d.append(err)

        results.append({
            'cycle': k,
            'x': pos_fused[0],
            'y': pos_fused[1],
            'z': pos_fused[2],
            'p_ctra': probs[0],
            'p_singer': probs[1],
            'p_bicycle': probs[2],
            'err3d': err,
        })

        if k < 20 or k % 100 == 0:
            print(f"  Cycle {k:4d}: pos=({pos_fused[0]:10.3f}, {pos_fused[1]:10.3f}, {pos_fused[2]:10.3f}) "
                  f"gt=({gt[0]:10.3f}, {gt[1]:10.3f}, {gt[2]:10.3f}) "
                  f"err={err:8.4f} "
                  f"p=[{probs[0]:.3f},{probs[1]:.3f},{probs[2]:.3f}]")

    # -----------------------------------------------------------------------
    # RMSE Summary
    # -----------------------------------------------------------------------
    errors_3d = np.array(errors_3d)
    print("\n" + "=" * 70)
    print("IMM Friend Python Reference - RMSE Summary")
    print("=" * 70)

    for n in [10, 50, 100, 200, 500, 750, n_cycles]:
        if n <= n_cycles:
            rmse = np.sqrt(np.mean(errors_3d[:n]**2))
            mean_e = np.mean(errors_3d[:n])
            max_e = np.max(errors_3d[:n])
            print(f"  Cycles {n:>4d}: RMSE={rmse:10.4f}m  Mean={mean_e:10.4f}m  Max={max_e:10.4f}m")

    total_rmse = np.sqrt(np.mean(errors_3d**2))
    print(f"\n  TOTAL RMSE ({n_cycles} cycles): {total_rmse:.4f} m")

    # Model probability statistics
    print(f"\nModel Probability Statistics:")
    print(f"  {'Model':>10} | {'Mean':>8} | {'Min':>8} | {'Max':>8}")
    print(f"  " + "-" * 45)
    for name, key in [('CTRA', 'p_ctra'), ('Singer', 'p_singer'), ('Bicycle', 'p_bicycle')]:
        vals = [r[key] for r in results]
        print(f"  {name:>10} | {np.mean(vals):>8.4f} | {np.min(vals):>8.4f} | {np.max(vals):>8.4f}")

    # -----------------------------------------------------------------------
    # Save hex output (matching VHDL output format)
    # -----------------------------------------------------------------------
    out_dir = os.path.dirname(output_path)
    if out_dir and not os.path.exists(out_dir):
        os.makedirs(out_dir, exist_ok=True)

    with open(output_path, 'w') as f:
        for r in results:
            hx = q24_to_hex(r['x'])
            hy = q24_to_hex(r['y'])
            hz = q24_to_hex(r['z'])
            hp_ca = q24_to_hex(r['p_ctra'])
            hp_si = q24_to_hex(r['p_singer'])
            hp_bi = q24_to_hex(r['p_bicycle'])
            f.write(f"Cycle {r['cycle']:4d}: "
                    f"imm_x=0x{hx} imm_y=0x{hy} imm_z=0x{hz} "
                    f"p_ca=0x{hp_ca} p_si=0x{hp_si} p_bi=0x{hp_bi}\n")

    print(f"\nHex output saved to: {output_path}")
    print(f"Format: Q24.24 (48-bit signed, 12 hex digits)")

    return total_rmse


# ============================================================================
# Entry Point
# ============================================================================

if __name__ == '__main__':
    csv_path = "/home/arunupscee/Desktop/xtortion/collection/imm_f1/deliverable/test_data/f1_monaco_2024_750cycles.csv"
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_dir, "imm_friend_python_output.txt")

    # Allow overrides from command line
    if len(sys.argv) > 1:
        csv_path = sys.argv[1]
    if len(sys.argv) > 2:
        output_path = sys.argv[2]

    rmse = run_imm(csv_path, output_path)
    print(f"\nFinal RMSE: {rmse:.4f} m")
