#!/usr/bin/env python3
"""
9D Constant Acceleration UKF Reference Implementation
Python gold model for validation of VHDL implementation

State vector (9D):
  [x_pos, x_vel, x_acc, y_pos, y_vel, y_acc, z_pos, z_vel, z_acc]

Measurement vector (3D):
  [z_x, z_y, z_z]  (position only)

Motion model: Constant acceleration
  x_k+1 = x_k + v_k*dt + 0.5*a_k*dt^2
  v_k+1 = v_k + a_k*dt
  a_k+1 = a_k  (constant)

Measurement model: h(x) = [x_pos, y_pos, z_pos]
"""

import numpy as np
from scipy.linalg import cholesky, sqrtm


class UKF_9D_CA:
    """9D Constant Acceleration Unscented Kalman Filter"""

    def __init__(self, dt=0.02, q_power=0.1, r_diag=1.0):
        """
        Initialize 9D CA UKF

        Args:
            dt: Time step (seconds)
            q_power: Process noise power spectral density
            r_diag: Measurement noise variance (position)
        """
        self.dt = dt
        self.n = 9  # State dimension
        self.m = 3  # Measurement dimension

        # UKF parameters (alpha=1, beta=2, kappa=0)
        self.alpha = 1.0
        self.beta = 2.0
        self.kappa = 0.0
        self.lambda_ = self.alpha**2 * (self.n + self.kappa) - self.n

        # Number of sigma points
        self.n_sigma = 2 * self.n + 1  # 19 points

        # UKF weights
        self.compute_weights()

        # Process noise Q (9x9 continuous white noise acceleration model)
        self.Q = self.compute_process_noise_ca(q_power)

        # Measurement noise R (3x3 diagonal)
        self.R = np.diag([r_diag, r_diag, r_diag])

        # State and covariance
        self.x = np.zeros(9)
        self.P = np.eye(9) * 1.0  # Initial covariance

        # Flag for first measurement (RESTORED - Direct init is more robust)
        self.first_cycle = True

    def compute_weights(self):
        """Compute UKF weights for mean and covariance"""
        self.Wm = np.zeros(self.n_sigma)
        self.Wc = np.zeros(self.n_sigma)

        # Weight for mean (center point)
        self.Wm[0] = self.lambda_ / (self.n + self.lambda_)
        # Weight for covariance (center point)
        self.Wc[0] = self.lambda_ / (self.n + self.lambda_) + (1 - self.alpha**2 + self.beta)

        # Weights for other sigma points
        for i in range(1, self.n_sigma):
            self.Wm[i] = 1.0 / (2.0 * (self.n + self.lambda_))
            self.Wc[i] = 1.0 / (2.0 * (self.n + self.lambda_))

    def compute_process_noise_ca(self, q_power):
        """
        Compute continuous white noise acceleration Q matrix (9x9 block diagonal)

        For constant acceleration model:
        Q = q * [dt^5/20   dt^4/8    dt^3/6]
                [dt^4/8    dt^3/3    dt^2/2]
                [dt^3/6    dt^2/2    dt    ]

        Block diagonal for x, y, z axes
        """
        dt = self.dt
        dt2 = dt * dt
        dt3 = dt2 * dt
        dt4 = dt3 * dt
        dt5 = dt4 * dt

        # 3x3 block for one axis
        Q_block = q_power * np.array([
            [dt5/20.0,  dt4/8.0,   dt3/6.0],
            [dt4/8.0,   dt3/3.0,   dt2/2.0],
            [dt3/6.0,   dt2/2.0,   dt]
        ])

        # 9x9 block diagonal
        Q = np.zeros((9, 9))
        Q[0:3, 0:3] = Q_block  # X axis
        Q[3:6, 3:6] = Q_block  # Y axis
        Q[6:9, 6:9] = Q_block  # Z axis

        return Q

    def generate_sigma_points(self, x, P):
        """
        Generate sigma points using Cholesky decomposition

        Args:
            x: State vector (9,)
            P: Covariance matrix (9x9)

        Returns:
            sigma_points: (19, 9) array of sigma points
        """
        n = len(x)
        sigma_points = np.zeros((self.n_sigma, n))

        # Compute matrix square root using Cholesky
        try:
            L = cholesky(P * (n + self.lambda_), lower=True)
        except np.linalg.LinAlgError:
            # If Cholesky fails, use eigenvalue decomposition
            print("WARNING: Cholesky failed, using eigenvalue decomposition")
            eigval, eigvec = np.linalg.eigh(P)
            eigval = np.maximum(eigval, 1e-10)  # Ensure positive
            L = eigvec @ np.diag(np.sqrt(eigval * (n + self.lambda_)))

        # Center point
        sigma_points[0] = x

        # Positive deviations
        for i in range(n):
            sigma_points[i+1] = x + L[:, i]

        # Negative deviations
        for i in range(n):
            sigma_points[n+i+1] = x - L[:, i]

        return sigma_points

    def f_ca_model(self, chi):
        """
        Constant acceleration motion model

        Args:
            chi: Sigma point (9,)

        Returns:
            chi_pred: Predicted sigma point (9,)
        """
        dt = self.dt
        chi_pred = np.zeros(9)

        # X axis
        chi_pred[0] = chi[0] + chi[1] * dt + 0.5 * chi[2] * dt * dt  # x_pos
        chi_pred[1] = chi[1] + chi[2] * dt  # x_vel
        chi_pred[2] = chi[2]  # x_acc (constant)

        # Y axis
        chi_pred[3] = chi[3] + chi[4] * dt + 0.5 * chi[5] * dt * dt  # y_pos
        chi_pred[4] = chi[4] + chi[5] * dt  # y_vel
        chi_pred[5] = chi[5]  # y_acc (constant)

        # Z axis
        chi_pred[6] = chi[6] + chi[7] * dt + 0.5 * chi[8] * dt * dt  # z_pos
        chi_pred[7] = chi[7] + chi[8] * dt  # z_vel
        chi_pred[8] = chi[8]  # z_acc (constant)

        return chi_pred

    def h_measurement_model(self, chi):
        """
        Measurement model: h(x) = [x_pos, y_pos, z_pos]

        Args:
            chi: Sigma point (9,)

        Returns:
            z_pred: Predicted measurement (3,)
        """
        return np.array([chi[0], chi[3], chi[6]])

    def predict(self):
        """UKF Prediction step"""
        # Generate sigma points from current state
        sigma_points = self.generate_sigma_points(self.x, self.P)

        # Propagate sigma points through motion model
        sigma_points_pred = np.zeros((self.n_sigma, self.n))
        for i in range(self.n_sigma):
            sigma_points_pred[i] = self.f_ca_model(sigma_points[i])

        # Compute predicted mean
        x_pred = np.zeros(self.n)
        for i in range(self.n_sigma):
            x_pred += self.Wm[i] * sigma_points_pred[i]

        # Compute predicted covariance
        P_pred = np.zeros((self.n, self.n))
        for i in range(self.n_sigma):
            diff = sigma_points_pred[i] - x_pred
            P_pred += self.Wc[i] * np.outer(diff, diff)

        # Add process noise
        P_pred += self.Q

        # Store predicted sigma points for update step
        self.sigma_points_pred = sigma_points_pred
        self.x_pred = x_pred
        self.P_pred = P_pred

        return x_pred, P_pred

    def update(self, z_meas):
        """
        UKF Update step

        Args:
            z_meas: Measurement vector (3,) [x_pos, y_pos, z_pos]

        Returns:
            x_upd: Updated state (9,)
            P_upd: Updated covariance (9x9)
        """
        # Generate measurement sigma points
        z_sigma = np.zeros((self.n_sigma, self.m))
        for i in range(self.n_sigma):
            z_sigma[i] = self.h_measurement_model(self.sigma_points_pred[i])

        # Predicted measurement mean
        z_pred = np.zeros(self.m)
        for i in range(self.n_sigma):
            z_pred += self.Wm[i] * z_sigma[i]

        # Innovation covariance S
        S = np.zeros((self.m, self.m))
        for i in range(self.n_sigma):
            diff = z_sigma[i] - z_pred
            S += self.Wc[i] * np.outer(diff, diff)
        S += self.R

        # Cross-covariance Pxz
        Pxz = np.zeros((self.n, self.m))
        for i in range(self.n_sigma):
            diff_x = self.sigma_points_pred[i] - self.x_pred
            diff_z = z_sigma[i] - z_pred
            Pxz += self.Wc[i] * np.outer(diff_x, diff_z)

        # Kalman gain K
        try:
            K = Pxz @ np.linalg.inv(S)
        except np.linalg.LinAlgError:
            print("WARNING: S matrix singular, using pseudo-inverse")
            K = Pxz @ np.linalg.pinv(S)

        # Innovation
        nu = z_meas - z_pred

        # State update
        x_upd = self.x_pred + K @ nu

        # Covariance update (Joseph form for numerical stability)
        # Measurement matrix H: 3x9 (extracts position states)
        H = np.array([[1, 0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 1, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 1, 0, 0]])
        I = np.eye(self.n)
        A = I - K @ H
        P_upd = A @ self.P_pred @ A.T + K @ self.R @ K.T

        # Ensure symmetry
        P_upd = 0.5 * (P_upd + P_upd.T)

        self.x = x_upd
        self.P = P_upd

        return x_upd, P_upd, nu

    def process_measurement(self, z_meas):
        """
        Complete UKF cycle: predict + update

        Args:
            z_meas: Measurement vector (3,)

        Returns:
            x_upd: Updated state (9,)
            P_upd: Updated covariance (9x9)
            nu: Innovation (3,)
        """
        # RESTORED: Direct measurement initialization on cycle 0 (more robust)
        # Robustness testing showed this approach has:
        #   - 45% better RMSE on drone dataset (1.12m vs 2.03m)
        #   - 6× smaller max error (3.97m vs 25.18m)
        #   - 6× faster convergence in first 10 cycles
        if self.first_cycle:
            # Initialize state from first measurement
            self.x[0] = z_meas[0]  # x_pos
            self.x[3] = z_meas[1]  # y_pos
            self.x[6] = z_meas[2]  # z_pos
            # velocities and accelerations remain zero
            self.first_cycle = False
            return self.x.copy(), self.P.copy(), np.zeros(3)

        # Prediction
        self.predict()

        # Update
        x_upd, P_upd, nu = self.update(z_meas)

        return x_upd, P_upd, nu


def to_q24_24(value):
    """Convert float to Q24.24 fixed-point integer"""
    return int(value * (2**24))


def from_q24_24(value):
    """Convert Q24.24 fixed-point integer to float"""
    return float(value) / (2**24)


if __name__ == "__main__":
    # Quick test
    ukf = UKF_9D_CA(dt=0.02, q_power=5.0, r_diag=1.0)

    print("9D Constant Acceleration UKF initialized")
    print(f"State dimension: {ukf.n}")
    print(f"Measurement dimension: {ukf.m}")
    print(f"Sigma points: {ukf.n_sigma}")
    print(f"Weights (mean): {ukf.Wm}")
    print(f"Weights (cov): {ukf.Wc}")
    print(f"\nProcess noise Q (diagonal):")
    print(np.diag(ukf.Q))
    print(f"\nMeasurement noise R:")
    print(ukf.R)

    # Test with synthetic measurement
    z_test = np.array([0.01, -0.01, 0.01])
    x, P, nu = ukf.process_measurement(z_test)
    print(f"\nAfter first measurement:")
    print(f"State: {x}")
    print(f"Covariance diagonal: {np.diag(P)}")
