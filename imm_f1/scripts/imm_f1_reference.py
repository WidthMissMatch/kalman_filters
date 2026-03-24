#!/usr/bin/env python3
"""
IMM (Interacting Multiple Model) Filter - Python Reference Implementation
Combines 3 UKF models: CA (Constant Acceleration), Singer, Bicycle
for F1 racing track prediction.

Outputs: per-cycle model probabilities, per-model RMSE, fused RMSE,
         hex testbench data for VHDL verification.
"""
import csv
import math
import sys
import os
import numpy as np
from copy import deepcopy

# ==============================================================================
# Fixed-point constants
# ==============================================================================
Q_SCALE = 2**24
DT = 0.02  # 50 Hz

# ==============================================================================
# UKF Parameters (shared)
# ==============================================================================
ALPHA = 1.0
BETA = 2.0
KAPPA = 0.0

def ukf_weights(n):
    """Compute UKF sigma point weights for dimension n."""
    lam = ALPHA**2 * (n + KAPPA) - n
    gamma = math.sqrt(n + lam)
    w_m0 = lam / (n + lam)
    w_c0 = lam / (n + lam) + (1 - ALPHA**2 + BETA)
    w_i = 1.0 / (2 * (n + lam))
    return gamma, w_m0, w_c0, w_i

# ==============================================================================
# CA UKF Model (9D)
# ==============================================================================
class CA_UKF:
    """Constant Acceleration UKF - 9D Cartesian state."""
    N = 9

    # Process noise
    Q_POS = 0.05
    Q_VEL = 0.00025
    Q_ACC = 0.00001

    # Measurement noise
    R = 0.25

    # Initial covariance diagonal
    P_INIT = np.diag([5.0, 20.0, 0.01, 5.0, 20.0, 0.01, 5.0, 20.0, 0.01])

    def __init__(self):
        self.x = np.zeros(9)
        self.P = self.P_INIT.copy()
        self.gamma, self.w_m0, self.w_c0, self.w_i = ukf_weights(9)
        self.innovation = np.zeros(3)
        self.S = np.eye(3)
        self.name = "CA"

    def init_state(self, x):
        self.x = x.copy()

    def get_position(self):
        return np.array([self.x[0], self.x[3], self.x[6]])

    def _process_model(self, x):
        """CA state transition: pos += vel*dt + 0.5*acc*dt^2, vel += acc*dt."""
        x_new = x.copy()
        for axis in range(3):
            p_idx = axis * 3
            v_idx = axis * 3 + 1
            a_idx = axis * 3 + 2
            x_new[p_idx] = x[p_idx] + x[v_idx]*DT + 0.5*x[a_idx]*DT**2
            x_new[v_idx] = x[v_idx] + x[a_idx]*DT
            x_new[a_idx] = x[a_idx]
        return x_new

    def _Q_matrix(self):
        """Block-diagonal process noise for CA model."""
        Q = np.zeros((9, 9))
        for axis in range(3):
            i = axis * 3
            Q[i, i] = self.Q_POS
            Q[i+1, i+1] = self.Q_VEL
            Q[i+2, i+2] = self.Q_ACC
        return Q

    def _H_matrix(self):
        """Measurement matrix: observe positions only."""
        H = np.zeros((3, 9))
        H[0, 0] = 1.0  # x_pos
        H[1, 3] = 1.0  # y_pos
        H[2, 6] = 1.0  # z_pos
        return H

    def predict(self):
        """UKF predict step."""
        n = self.N
        # Generate sigma points
        try:
            L = np.linalg.cholesky(self.P)
        except np.linalg.LinAlgError:
            self.P = (self.P + self.P.T) / 2 + np.eye(n) * 1e-6
            L = np.linalg.cholesky(self.P)

        sigmas = np.zeros((2*n+1, n))
        sigmas[0] = self.x
        for i in range(n):
            sigmas[i+1] = self.x + self.gamma * L[:, i]
            sigmas[n+i+1] = self.x - self.gamma * L[:, i]

        # Propagate through process model
        sigmas_pred = np.zeros_like(sigmas)
        for i in range(2*n+1):
            sigmas_pred[i] = self._process_model(sigmas[i])

        # Predicted mean
        x_pred = self.w_m0 * sigmas_pred[0]
        for i in range(1, 2*n+1):
            x_pred += self.w_i * sigmas_pred[i]

        # Predicted covariance
        diff = sigmas_pred[0] - x_pred
        P_pred = self.w_c0 * np.outer(diff, diff)
        for i in range(1, 2*n+1):
            diff = sigmas_pred[i] - x_pred
            P_pred += self.w_i * np.outer(diff, diff)
        P_pred += self._Q_matrix()

        self.x = x_pred
        self.P = P_pred
        self._sigmas_pred = sigmas_pred

    def update(self, z):
        """UKF measurement update."""
        n = self.N
        H = self._H_matrix()

        # Regenerate sigma points from predicted state
        try:
            L = np.linalg.cholesky(self.P)
        except np.linalg.LinAlgError:
            self.P = (self.P + self.P.T) / 2 + np.eye(n) * 1e-6
            L = np.linalg.cholesky(self.P)

        sigmas = np.zeros((2*n+1, n))
        sigmas[0] = self.x
        for i in range(n):
            sigmas[i+1] = self.x + self.gamma * L[:, i]
            sigmas[n+i+1] = self.x - self.gamma * L[:, i]

        # Measurement sigma points (linear H)
        z_sigmas = np.zeros((2*n+1, 3))
        for i in range(2*n+1):
            z_sigmas[i] = H @ sigmas[i]

        # Measurement mean
        z_pred = self.w_m0 * z_sigmas[0]
        for i in range(1, 2*n+1):
            z_pred += self.w_i * z_sigmas[i]

        # Innovation covariance S
        diff_z = z_sigmas[0] - z_pred
        S = self.w_c0 * np.outer(diff_z, diff_z)
        for i in range(1, 2*n+1):
            diff_z = z_sigmas[i] - z_pred
            S += self.w_i * np.outer(diff_z, diff_z)
        S += self.R * np.eye(3)

        # Cross-covariance Pxz
        diff_x = sigmas[0] - self.x
        diff_z = z_sigmas[0] - z_pred
        Pxz = self.w_c0 * np.outer(diff_x, diff_z)
        for i in range(1, 2*n+1):
            diff_x = sigmas[i] - self.x
            diff_z = z_sigmas[i] - z_pred
            Pxz += self.w_i * np.outer(diff_x, diff_z)

        # Kalman gain
        S_inv = np.linalg.inv(S)
        K = Pxz @ S_inv

        # Innovation
        self.innovation = z - z_pred
        self.S = S

        # State update
        self.x = self.x + K @ self.innovation
        self.P = self.P - K @ S @ K.T
        # Ensure symmetry
        self.P = (self.P + self.P.T) / 2


# ==============================================================================
# Singer UKF Model (9D)
# ==============================================================================
class Singer_UKF(CA_UKF):
    """Singer's correlated acceleration model - 9D Cartesian state."""

    TAU = 2.0
    SIGMA_A = 5.0
    Q_POS = 0.08
    Q_VEL = 0.00025
    Q_ACC = 0.00001
    R = 0.25
    P_INIT = np.diag([10.0, 100.0, 0.01, 10.0, 100.0, 0.01, 10.0, 100.0, 0.01])

    def __init__(self):
        super().__init__()
        self.P = self.P_INIT.copy()
        self.name = "Singer"

    def _process_model(self, x):
        """Singer state transition with correlated acceleration decay."""
        x_new = x.copy()
        tau = self.TAU
        exp_term = math.exp(-DT / tau)

        for axis in range(3):
            p_idx = axis * 3
            v_idx = axis * 3 + 1
            a_idx = axis * 3 + 2

            p = x[p_idx]
            v = x[v_idx]
            a = x[a_idx]

            # Singer's equations (a_mean = 0)
            x_new[a_idx] = a * exp_term
            x_new[v_idx] = v + a * tau * (1 - exp_term)
            x_new[p_idx] = p + v * DT + a * tau * (DT - tau * (1 - exp_term))

        return x_new


# ==============================================================================
# Bicycle UKF Model (7D)
# ==============================================================================
class Bicycle_UKF:
    """Kinematic Bicycle model - 7D polar state."""
    N = 7
    L = 3.6      # wheelbase
    LR = 1.6     # CG to rear axle

    Q_DIAG = np.array([0.5, 0.5, 10.0, 0.05, 0.001, 5.0, 0.5])
    R = 2.0
    P_INIT = np.diag([5.0, 5.0, 20.0, 0.1, 0.1, 1.0, 5.0])

    def __init__(self):
        self.x = np.zeros(7)
        self.P = self.P_INIT.copy()
        self.gamma, self.w_m0, self.w_c0, self.w_i = ukf_weights(7)
        self.innovation = np.zeros(3)
        self.S = np.eye(3)
        self.name = "Bicycle"

    def init_state(self, x):
        self.x = x.copy()

    def get_position(self):
        return np.array([self.x[0], self.x[1], self.x[6]])

    def _process_model(self, x):
        """Bicycle kinematic model."""
        px, py, v, theta, delta, a, z = x
        beta = (self.LR / self.L) * delta

        px_new = px + v * math.cos(theta + beta) * DT
        py_new = py + v * math.sin(theta + beta) * DT
        v_new = v + a * DT
        theta_new = theta + (v * delta / self.L) * DT
        delta_new = delta
        a_new = a
        z_new = z

        return np.array([px_new, py_new, v_new, theta_new, delta_new, a_new, z_new])

    def _H_matrix(self):
        """Measurement: observe px, py, z."""
        H = np.zeros((3, 7))
        H[0, 0] = 1.0  # px
        H[1, 1] = 1.0  # py
        H[2, 6] = 1.0  # z
        return H

    def predict(self):
        n = self.N
        try:
            L = np.linalg.cholesky(self.P)
        except np.linalg.LinAlgError:
            self.P = (self.P + self.P.T) / 2 + np.eye(n) * 1e-6
            L = np.linalg.cholesky(self.P)

        sigmas = np.zeros((2*n+1, n))
        sigmas[0] = self.x
        for i in range(n):
            sigmas[i+1] = self.x + self.gamma * L[:, i]
            sigmas[n+i+1] = self.x - self.gamma * L[:, i]

        sigmas_pred = np.zeros_like(sigmas)
        for i in range(2*n+1):
            sigmas_pred[i] = self._process_model(sigmas[i])

        x_pred = self.w_m0 * sigmas_pred[0]
        for i in range(1, 2*n+1):
            x_pred += self.w_i * sigmas_pred[i]

        diff = sigmas_pred[0] - x_pred
        P_pred = self.w_c0 * np.outer(diff, diff)
        for i in range(1, 2*n+1):
            diff = sigmas_pred[i] - x_pred
            P_pred += self.w_i * np.outer(diff, diff)
        P_pred += np.diag(self.Q_DIAG)

        self.x = x_pred
        self.P = P_pred

    def update(self, z):
        n = self.N
        H = self._H_matrix()

        try:
            L = np.linalg.cholesky(self.P)
        except np.linalg.LinAlgError:
            self.P = (self.P + self.P.T) / 2 + np.eye(n) * 1e-6
            L = np.linalg.cholesky(self.P)

        sigmas = np.zeros((2*n+1, n))
        sigmas[0] = self.x
        for i in range(n):
            sigmas[i+1] = self.x + self.gamma * L[:, i]
            sigmas[n+i+1] = self.x - self.gamma * L[:, i]

        z_sigmas = np.zeros((2*n+1, 3))
        for i in range(2*n+1):
            z_sigmas[i] = H @ sigmas[i]

        z_pred = self.w_m0 * z_sigmas[0]
        for i in range(1, 2*n+1):
            z_pred += self.w_i * z_sigmas[i]

        diff_z = z_sigmas[0] - z_pred
        S = self.w_c0 * np.outer(diff_z, diff_z)
        for i in range(1, 2*n+1):
            diff_z = z_sigmas[i] - z_pred
            S += self.w_i * np.outer(diff_z, diff_z)
        S += self.R * np.eye(3)

        diff_x = sigmas[0] - self.x
        diff_z = z_sigmas[0] - z_pred
        Pxz = self.w_c0 * np.outer(diff_x, diff_z)
        for i in range(1, 2*n+1):
            diff_x = sigmas[i] - self.x
            diff_z = z_sigmas[i] - z_pred
            Pxz += self.w_i * np.outer(diff_x, diff_z)

        S_inv = np.linalg.inv(S)
        K = Pxz @ S_inv

        self.innovation = z - z_pred
        self.S = S

        self.x = self.x + K @ self.innovation
        self.P = self.P - K @ S @ K.T
        self.P = (self.P + self.P.T) / 2


# ==============================================================================
# State Mapping Functions
# ==============================================================================
def state_9d_to_7d(x9):
    """Convert 9D Cartesian state to 7D Bicycle (polar) state."""
    x_pos, x_vel, x_acc = x9[0], x9[1], x9[2]
    y_pos, y_vel, y_acc = x9[3], x9[4], x9[5]
    z_pos = x9[6]

    px = x_pos
    py = y_pos
    z = z_pos
    v = math.sqrt(x_vel**2 + y_vel**2)
    theta = math.atan2(y_vel, x_vel)
    delta = 0.0  # reset steering

    if v > 1e-6:
        a = (x_vel * x_acc + y_vel * y_acc) / v
    else:
        a = math.sqrt(x_acc**2 + y_acc**2)

    return np.array([px, py, v, theta, delta, a, z])


def state_7d_to_9d(x7):
    """Convert 7D Bicycle (polar) state to 9D Cartesian state."""
    px, py, v, theta, delta, a, z = x7

    x_pos = px
    x_vel = v * math.cos(theta)
    x_acc = a * math.cos(theta)
    y_pos = py
    y_vel = v * math.sin(theta)
    y_acc = a * math.sin(theta)
    z_pos = z
    z_vel = 0.0
    z_acc = 0.0

    return np.array([x_pos, x_vel, x_acc, y_pos, y_vel, y_acc, z_pos, z_vel, z_acc])


def cov_9d_to_7d_diag(P9_diag):
    """Map 9D covariance diagonal to 7D (approximate)."""
    # px, py map directly; v = sqrt(vx^2+vy^2) ~ max(vx_var, vy_var)
    p7 = np.zeros(7)
    p7[0] = P9_diag[0]  # px
    p7[1] = P9_diag[3]  # py
    p7[2] = max(P9_diag[1], P9_diag[4])  # v ~ max(vx_var, vy_var)
    p7[3] = 0.1   # theta uncertainty (default)
    p7[4] = 0.1   # delta uncertainty (default)
    p7[5] = max(P9_diag[2], P9_diag[5])  # a
    p7[6] = P9_diag[6]  # z
    return np.diag(p7)


def cov_7d_to_9d_diag(P7_diag):
    """Map 7D covariance diagonal to 9D (approximate)."""
    p9 = np.zeros(9)
    p9[0] = P7_diag[0]  # x_pos
    p9[1] = P7_diag[2]  # x_vel ~ v
    p9[2] = P7_diag[5]  # x_acc ~ a
    p9[3] = P7_diag[1]  # y_pos
    p9[4] = P7_diag[2]  # y_vel ~ v
    p9[5] = P7_diag[5]  # y_acc ~ a
    p9[6] = P7_diag[6]  # z_pos
    p9[7] = 0.01         # z_vel (default)
    p9[8] = 0.001        # z_acc (default)
    return np.diag(p9)


# ==============================================================================
# IMM Filter
# ==============================================================================
class IMM_Filter:
    """Interacting Multiple Model filter with 3 UKF models."""

    # Markov transition matrix
    #          CA    Singer  Bicycle
    T = np.array([
        [0.97, 0.02, 0.01],   # From CA
        [0.02, 0.95, 0.03],   # From Singer
        [0.01, 0.02, 0.97],   # From Bicycle
    ])

    # Probability clamp bounds
    PROB_MIN = 0.01
    PROB_MAX = 0.98

    def __init__(self):
        self.models = [CA_UKF(), Singer_UKF(), Bicycle_UKF()]
        self.probs = np.array([0.5, 0.3, 0.2])
        self.n_models = 3

    def init_state(self, z_meas):
        """Initialize all models from first measurement."""
        x9_init = np.array([z_meas[0], 0, 0, z_meas[1], 0, 0, z_meas[2], 0, 0])
        x7_init = np.array([z_meas[0], z_meas[1], 0, 0, 0, 0, z_meas[2]])

        self.models[0].init_state(x9_init)  # CA
        self.models[1].init_state(x9_init)  # Singer
        self.models[2].init_state(x7_init)  # Bicycle

    def _compute_mixing_weights(self):
        """Compute mixing weights mu_ij = T_ij * prob_i / c_j."""
        mu = np.zeros((3, 3))
        c = np.zeros(3)

        for j in range(3):
            c[j] = sum(self.T[i, j] * self.probs[i] for i in range(3))
            if c[j] < 1e-10:
                c[j] = 1e-10

        for i in range(3):
            for j in range(3):
                mu[i, j] = self.T[i, j] * self.probs[i] / c[j]

        return mu, c

    def _mix_states(self, mu):
        """Mix states using mixing weights. Handles 9D/7D conversion."""
        # Get all states in both representations
        states_9d = []
        states_7d = []
        P_diags_9d = []
        P_diags_7d = []

        for m in self.models:
            if m.N == 9:
                x9 = m.x.copy()
                x7 = state_9d_to_7d(x9)
                p9 = np.diag(m.P).copy()
                p7 = np.diag(cov_9d_to_7d_diag(p9))
            else:
                x7 = m.x.copy()
                x9 = state_7d_to_9d(x7)
                p7 = np.diag(m.P).copy()
                p9 = np.diag(cov_7d_to_9d_diag(p7))
            states_9d.append(x9)
            states_7d.append(x7)
            P_diags_9d.append(p9)
            P_diags_7d.append(p7)

        # Mix for each target model
        mixed_states = []
        mixed_P_diags = []

        for j in range(3):
            target_n = self.models[j].N
            if target_n == 9:
                states = states_9d
                P_diags = P_diags_9d
            else:
                states = states_7d
                P_diags = P_diags_7d

            # Mixed state: x_mix_j = sum_i(mu_ij * x_i)
            x_mix = np.zeros(target_n)
            for i in range(3):
                x_mix += mu[i, j] * states[i]

            # Mixed covariance (diagonal approx):
            # P_mix_j = sum_i mu_ij * [P_i + (x_i - x_mix)(x_i - x_mix)^T]
            P_mix_diag = np.zeros(target_n)
            for i in range(3):
                diff = states[i] - x_mix
                P_mix_diag += mu[i, j] * (P_diags[i] + diff**2)

            mixed_states.append(x_mix)
            mixed_P_diags.append(P_mix_diag)

        return mixed_states, mixed_P_diags

    def _compute_likelihood(self, model):
        """Compute Gaussian log-likelihood from innovation and S matrix."""
        nu = model.innovation
        S = model.S

        try:
            S_inv = np.linalg.inv(S)
            sign, log_det = np.linalg.slogdet(S)
            if sign <= 0:
                log_det = 30.0  # large penalty
        except np.linalg.LinAlgError:
            return -1e10

        mahal = nu @ S_inv @ nu
        log_L = -0.5 * (mahal + log_det + 3 * math.log(2 * math.pi))
        return log_L

    def step(self, z_meas):
        """Run one IMM cycle: mix → predict → update → likelihood → prob_update → output."""

        # Stage 1: MIXING
        mu, c = self._compute_mixing_weights()
        mixed_states, mixed_P_diags = self._mix_states(mu)

        # Inject mixed states into models
        for j in range(3):
            self.models[j].x = mixed_states[j].copy()
            self.models[j].P = np.diag(mixed_P_diags[j])
            # Ensure positive diagonal
            for k in range(self.models[j].N):
                if self.models[j].P[k, k] < 1e-6:
                    self.models[j].P[k, k] = 1e-6

        # Stage 2: PREDICTION
        for m in self.models:
            m.predict()

        # Stage 3: UPDATE
        z = np.array(z_meas)
        for m in self.models:
            m.update(z)

        # Stage 4: LIKELIHOOD
        log_Ls = np.array([self._compute_likelihood(m) for m in self.models])

        # Max-subtract trick for numerical stability
        max_ll = np.max(log_Ls)
        Ls = np.exp(log_Ls - max_ll)

        # Stage 5: PROBABILITY UPDATE
        # prob_j_new = L_j * c_j / sum(L_k * c_k)
        weighted = Ls * c
        total = np.sum(weighted)
        if total < 1e-20:
            self.probs = np.array([1.0/3, 1.0/3, 1.0/3])
        else:
            self.probs = weighted / total

        # Clamp probabilities
        self.probs = np.clip(self.probs, self.PROB_MIN, self.PROB_MAX)
        # Renormalize
        self.probs /= np.sum(self.probs)

        # Stage 6: OUTPUT (weighted position fusion)
        positions = []
        for m in self.models:
            positions.append(m.get_position())

        pos_out = np.zeros(3)
        for j in range(3):
            pos_out += self.probs[j] * positions[j]

        return pos_out


# ==============================================================================
# Data Loading
# ==============================================================================
def load_ground_truth(csv_path):
    """Load ground truth from CSV."""
    gt = {}
    meas = {}
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            cycle = int(row['cycle'])
            gt[cycle] = np.array([
                float(row['gt_x_pos']),
                float(row['gt_y_pos']),
                float(row['gt_z_pos']),
            ])
            meas[cycle] = np.array([
                float(row['meas_x']),
                float(row['meas_y']),
                float(row['meas_z']),
            ])
    return gt, meas


def load_f1_data(csv_path):
    """Load F1 data (no separate gt velocity columns, compute from positions)."""
    gt = {}
    meas = {}
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            cycle = int(row['cycle'])
            gt[cycle] = np.array([
                float(row['gt_x_pos']),
                float(row['gt_y_pos']),
                float(row['gt_z_pos']),
            ])
            meas[cycle] = np.array([
                float(row['meas_x']),
                float(row['meas_y']),
                float(row['meas_z']),
            ])
    return gt, meas


def to_q24(val):
    """Convert float to Q24.24 signed integer."""
    return int(round(val * Q_SCALE))


def to_hex48(val_q24):
    """Convert Q24.24 integer to 12-char hex."""
    if val_q24 < 0:
        val_q24 += (1 << 48)
    return f"{val_q24 & 0xFFFFFFFFFFFF:012X}"


# ==============================================================================
# Main
# ==============================================================================
def run_imm(csv_path, label="Dataset", max_cycles=None):
    """Run IMM filter on dataset and report results."""

    # Load data
    gt, meas = load_ground_truth(csv_path)
    total_cycles = len(gt)
    if max_cycles:
        total_cycles = min(total_cycles, max_cycles)

    print(f"\n{'='*80}")
    print(f"IMM FILTER - {label}")
    print(f"Dataset: {csv_path}")
    print(f"Cycles: {total_cycles}")
    print(f"{'='*80}")

    # Initialize IMM
    imm = IMM_Filter()
    imm.init_state(meas[0])

    # Also run individual models for comparison
    ca_solo = CA_UKF()
    singer_solo = Singer_UKF()
    bike_solo = Bicycle_UKF()

    x9_init = np.array([meas[0][0], 0, 0, meas[0][1], 0, 0, meas[0][2], 0, 0])
    x7_init = np.array([meas[0][0], meas[0][1], 0, 0, 0, 0, meas[0][2]])
    ca_solo.init_state(x9_init)
    singer_solo.init_state(x9_init)
    bike_solo.init_state(x7_init)

    # Storage
    imm_positions = {}
    model_probs_log = {}
    ca_positions = {}
    singer_positions = {}
    bike_positions = {}

    # Cycle 0: use initial state
    imm_positions[0] = meas[0].copy()
    ca_positions[0] = meas[0].copy()
    singer_positions[0] = meas[0].copy()
    bike_positions[0] = meas[0].copy()
    model_probs_log[0] = imm.probs.copy()

    # Run filter
    for c in range(1, total_cycles):
        z = meas[c]

        # IMM step
        pos_imm = imm.step(z)
        imm_positions[c] = pos_imm
        model_probs_log[c] = imm.probs.copy()

        # Solo models
        ca_solo.predict()
        ca_solo.update(z)
        ca_positions[c] = ca_solo.get_position()

        singer_solo.predict()
        singer_solo.update(z)
        singer_positions[c] = singer_solo.get_position()

        bike_solo.predict()
        bike_solo.update(z)
        bike_positions[c] = bike_solo.get_position()

    # Print first 10 cycles
    print(f"\n--- First 10 Cycles ---")
    print(f"{'Cyc':>3} | {'IMM_x':>10} {'IMM_y':>10} {'IMM_z':>10} | "
          f"{'P(CA)':>6} {'P(Si)':>6} {'P(Bi)':>6} | {'err_3D':>8}")
    print("-" * 90)
    for c in range(min(10, total_cycles)):
        pos = imm_positions[c]
        probs = model_probs_log[c]
        err = np.linalg.norm(pos - gt[c])
        print(f"{c:3d} | {pos[0]:10.4f} {pos[1]:10.4f} {pos[2]:10.4f} | "
              f"{probs[0]:6.3f} {probs[1]:6.3f} {probs[2]:6.3f} | {err:8.4f}")

    # Print last 5 cycles
    if total_cycles > 15:
        print(f"\n--- Last 5 Cycles ---")
        for c in range(total_cycles - 5, total_cycles):
            pos = imm_positions[c]
            probs = model_probs_log[c]
            err = np.linalg.norm(pos - gt[c])
            print(f"{c:3d} | {pos[0]:10.4f} {pos[1]:10.4f} {pos[2]:10.4f} | "
                  f"{probs[0]:6.3f} {probs[1]:6.3f} {probs[2]:6.3f} | {err:8.4f}")

    # Compute RMSE
    def rmse_3d(positions, gt_dict, n):
        sum_sq = 0.0
        count = 0
        for c in range(n):
            if c in positions and c in gt_dict:
                sum_sq += np.sum((positions[c] - gt_dict[c])**2)
                count += 1
        return math.sqrt(sum_sq / count) if count > 0 else float('inf')

    checkpoints = [10, 100, 500, 750]
    print(f"\n{'='*80}")
    print(f"RMSE COMPARISON")
    print(f"{'='*80}")
    print(f"{'Cycles':>8} | {'IMM':>10} | {'CA solo':>10} | {'Singer solo':>12} | {'Bicycle solo':>13}")
    print("-" * 70)

    for cp in checkpoints:
        if cp > total_cycles:
            continue
        r_imm = rmse_3d(imm_positions, gt, cp)
        r_ca = rmse_3d(ca_positions, gt, cp)
        r_si = rmse_3d(singer_positions, gt, cp)
        r_bi = rmse_3d(bike_positions, gt, cp)
        print(f"{cp:>8} | {r_imm:10.4f} | {r_ca:10.4f} | {r_si:12.4f} | {r_bi:13.4f}")

    # Full RMSE
    r_imm = rmse_3d(imm_positions, gt, total_cycles)
    r_ca = rmse_3d(ca_positions, gt, total_cycles)
    r_si = rmse_3d(singer_positions, gt, total_cycles)
    r_bi = rmse_3d(bike_positions, gt, total_cycles)
    print(f"{'ALL':>8} | {r_imm:10.4f} | {r_ca:10.4f} | {r_si:12.4f} | {r_bi:13.4f}")

    # Model probability statistics
    probs_arr = np.array([model_probs_log[c] for c in range(total_cycles)])
    print(f"\n{'='*80}")
    print(f"MODEL PROBABILITY STATISTICS")
    print(f"{'='*80}")
    print(f"{'Model':>10} | {'Mean':>8} | {'Std':>8} | {'Min':>8} | {'Max':>8}")
    print("-" * 50)
    for j, name in enumerate(["CA", "Singer", "Bicycle"]):
        p = probs_arr[:, j]
        print(f"{name:>10} | {np.mean(p):8.4f} | {np.std(p):8.4f} | {np.min(p):8.4f} | {np.max(p):8.4f}")

    # Generate hex testbench data
    hex_path = csv_path.replace('.csv', '_imm_hex.txt')
    hex_path = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            os.path.basename(hex_path))
    with open(hex_path, 'w') as f:
        for c in range(total_cycles):
            z = meas[c]
            pos = imm_positions[c]
            probs = model_probs_log[c]
            f.write(f"Cycle {c}: "
                    f"meas_x=0x{to_hex48(to_q24(z[0]))} "
                    f"meas_y=0x{to_hex48(to_q24(z[1]))} "
                    f"meas_z=0x{to_hex48(to_q24(z[2]))} "
                    f"imm_x=0x{to_hex48(to_q24(pos[0]))} "
                    f"imm_y=0x{to_hex48(to_q24(pos[1]))} "
                    f"imm_z=0x{to_hex48(to_q24(pos[2]))} "
                    f"p_ca={probs[0]:.6f} "
                    f"p_singer={probs[1]:.6f} "
                    f"p_bicycle={probs[2]:.6f}\n")
    print(f"\nHex testbench data written to: {hex_path}")

    return r_imm


def main():
    base = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.join(base, '..', '..')

    datasets = [
        (os.path.join(project_root, 'ca_ukf/test_data/real_world/synthetic_drone_500cycles.csv'),
         "Synthetic Drone 500cy", 500),
        (os.path.join(project_root, 'ca_ukf/test_data/real_world/f1_monaco_2024_750cycles.csv'),
         "F1 Monaco 2024 750cy", 750),
        (os.path.join(project_root, 'ca_ukf/test_data/real_world/f1_silverstone_2024_750cycles.csv'),
         "F1 Silverstone 2024 750cy", 750),
    ]

    results = {}
    for path, label, max_cy in datasets:
        if os.path.exists(path):
            rmse = run_imm(path, label, max_cy)
            results[label] = rmse
        else:
            print(f"\nSkipping {label}: file not found at {path}")

    print(f"\n{'='*80}")
    print(f"FINAL SUMMARY")
    print(f"{'='*80}")
    for label, rmse in results.items():
        status = "SUB-METER!" if rmse < 1.0 else ("GOOD" if rmse < 5.0 else "NEEDS TUNING")
        print(f"  {label:40s}: {rmse:.4f} m RMSE [{status}]")


if __name__ == '__main__':
    main()
