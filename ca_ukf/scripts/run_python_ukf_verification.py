#!/usr/bin/env python3
"""
Run Python UKF on the SAME dataset used for VHDL verification
Output predictions for direct comparison with VHDL
"""

import numpy as np
import pandas as pd
from scipy.linalg import cholesky

class UKF_9D_CA:
    """9D Constant Acceleration UKF (Python reference)"""

    def __init__(self, dt=0.02, q_power=0.01, r_diag=0.1):
        """
        Initialize 9D CA UKF

        State: [x_pos, x_vel, x_acc, y_pos, y_vel, y_acc, z_pos, z_vel, z_acc]
        Measurement: [z_x, z_y, z_z] (position only)
        """
        self.dt = dt
        self.n = 9  # State dimension
        self.m = 3  # Measurement dimension

        # Initial state (zeros)
        self.x = np.zeros(9)

        # Initial covariance (diagonal)
        self.P = np.diag([100.0, 10.0, 1.0,   # x pos, vel, acc
                          100.0, 10.0, 1.0,   # y pos, vel, acc
                          100.0, 10.0, 1.0])  # z pos, vel, acc

        # Process noise (continuous white noise acceleration)
        self.Q = self._compute_process_noise_ca(q_power)

        # Measurement noise
        self.R = np.diag([r_diag**2, r_diag**2, r_diag**2])

        # UKF parameters
        alpha = 1e-3
        beta = 2.0
        kappa = 0.0
        self.lambda_ = alpha**2 * (self.n + kappa) - self.n
        self.gamma = np.sqrt(self.n + self.lambda_)

        # UKF weights
        self.Wm = np.zeros(2*self.n + 1)
        self.Wc = np.zeros(2*self.n + 1)
        self.Wm[0] = self.lambda_ / (self.n + self.lambda_)
        self.Wc[0] = self.Wm[0] + (1 - alpha**2 + beta)
        for i in range(1, 2*self.n + 1):
            self.Wm[i] = 1.0 / (2.0 * (self.n + self.lambda_))
            self.Wc[i] = self.Wm[i]

    def _compute_process_noise_ca(self, q_power):
        """Continuous white noise acceleration Q matrix for CA model"""
        dt = self.dt
        dt2 = dt**2
        dt3 = dt**3
        dt4 = dt**4
        dt5 = dt**5

        # Block for one axis
        Q_block = np.array([
            [dt5/20.0, dt4/8.0,  dt3/6.0],
            [dt4/8.0,  dt3/3.0,  dt2/2.0],
            [dt3/6.0,  dt2/2.0,  dt]
        ]) * q_power

        # Block diagonal for x, y, z
        Q = np.zeros((9, 9))
        Q[0:3, 0:3] = Q_block
        Q[3:6, 3:6] = Q_block
        Q[6:9, 6:9] = Q_block

        return Q

    def f_ca_model(self, chi):
        """Constant acceleration motion model"""
        dt = self.dt

        # State transition for each sigma point
        chi_pred = np.zeros_like(chi)

        for i in range(chi.shape[1]):
            # Extract state
            x_pos, x_vel, x_acc = chi[0, i], chi[1, i], chi[2, i]
            y_pos, y_vel, y_acc = chi[3, i], chi[4, i], chi[5, i]
            z_pos, z_vel, z_acc = chi[6, i], chi[7, i], chi[8, i]

            # Constant acceleration model
            chi_pred[0, i] = x_pos + x_vel*dt + 0.5*x_acc*dt**2
            chi_pred[1, i] = x_vel + x_acc*dt
            chi_pred[2, i] = x_acc

            chi_pred[3, i] = y_pos + y_vel*dt + 0.5*y_acc*dt**2
            chi_pred[4, i] = y_vel + y_acc*dt
            chi_pred[5, i] = y_acc

            chi_pred[6, i] = z_pos + z_vel*dt + 0.5*z_acc*dt**2
            chi_pred[7, i] = z_vel + z_acc*dt
            chi_pred[8, i] = z_acc

        return chi_pred

    def h_measurement_model(self, chi):
        """Measurement model (position only)"""
        Z = np.zeros((self.m, chi.shape[1]))
        Z[0, :] = chi[0, :]  # x position
        Z[1, :] = chi[3, :]  # y position
        Z[2, :] = chi[6, :]  # z position
        return Z

    def generate_sigma_points(self, x, P):
        """Generate sigma points"""
        n = len(x)
        chi = np.zeros((n, 2*n + 1))

        try:
            L = cholesky(P, lower=True)
        except np.linalg.LinAlgError:
            print("WARNING: Cholesky failed, using eigenvalue decomposition")
            eigvals, eigvecs = np.linalg.eigh(P)
            eigvals = np.maximum(eigvals, 1e-10)
            L = eigvecs @ np.diag(np.sqrt(eigvals))

        chi[:, 0] = x
        for i in range(n):
            chi[:, i+1] = x + self.gamma * L[:, i]
            chi[:, n+i+1] = x - self.gamma * L[:, i]

        return chi

    def predict(self):
        """UKF prediction step"""
        # Generate sigma points
        chi = self.generate_sigma_points(self.x, self.P)

        # Propagate sigma points through motion model
        chi_pred = self.f_ca_model(chi)

        # Compute predicted mean
        x_pred = np.sum(self.Wm[:, np.newaxis] * chi_pred.T, axis=0)

        # Compute predicted covariance
        P_pred = np.zeros((self.n, self.n))
        for i in range(2*self.n + 1):
            diff = chi_pred[:, i] - x_pred
            P_pred += self.Wc[i] * np.outer(diff, diff)
        P_pred += self.Q

        return x_pred, P_pred, chi_pred

    def update(self, z_meas, x_pred, P_pred, chi_pred):
        """UKF measurement update step"""
        # Propagate sigma points through measurement model
        Z = self.h_measurement_model(chi_pred)

        # Predicted measurement
        z_pred = np.sum(self.Wm[:, np.newaxis] * Z.T, axis=0)

        # Innovation covariance
        S = np.zeros((self.m, self.m))
        for i in range(2*self.n + 1):
            diff = Z[:, i] - z_pred
            S += self.Wc[i] * np.outer(diff, diff)
        S += self.R

        # Cross-correlation
        Pxz = np.zeros((self.n, self.m))
        for i in range(2*self.n + 1):
            dx = chi_pred[:, i] - x_pred
            dz = Z[:, i] - z_pred
            Pxz += self.Wc[i] * np.outer(dx, dz)

        # Kalman gain
        try:
            K = Pxz @ np.linalg.inv(S)
        except np.linalg.LinAlgError:
            print("WARNING: S matrix singular, using pseudo-inverse")
            K = Pxz @ np.linalg.pinv(S)

        # State update
        innovation = z_meas - z_pred
        x_updated = x_pred + K @ innovation

        # Covariance update
        P_updated = P_pred - K @ S @ K.T

        return x_updated, P_updated, K

    def process_measurement(self, z_meas):
        """Complete UKF cycle"""
        # Prediction
        x_pred, P_pred, chi_pred = self.predict()

        # Update
        x_updated, P_updated, K = self.update(z_meas, x_pred, P_pred, chi_pred)

        # Store results
        self.x = x_updated
        self.P = P_updated

        return x_pred, x_updated, P_updated, K


def q24_to_float(q24_val):
    """Convert Q24.24 integer to float"""
    return q24_val / (2**24)


def run_python_ukf_verification(csv_file, num_cycles=10):
    """Run Python UKF on verification dataset"""

    # Read dataset
    df = pd.read_csv(csv_file)
    num_cycles = min(num_cycles, len(df))

    print("=" * 80)
    print("PYTHON UKF VERIFICATION RUN")
    print("=" * 80)
    print(f"Dataset: {csv_file}")
    print(f"Cycles: {num_cycles}")
    print()

    # Initialize UKF
    ukf = UKF_9D_CA(dt=0.02, q_power=0.01, r_diag=0.1)

    results = []

    for i in range(num_cycles):
        row = df.iloc[i]

        # Get measurements (convert from Q24.24)
        z_x = q24_to_float(row['meas_x_q24'])
        z_y = q24_to_float(row['meas_y_q24'])
        z_z = q24_to_float(row['meas_z_q24'])

        z_meas = np.array([z_x, z_y, z_z])

        print(f"====== CYCLE {i} ======")
        print(f"Measurements (float):")
        print(f"  z_x = {z_x:.6f} m")
        print(f"  z_y = {z_y:.6f} m")
        print(f"  z_z = {z_z:.6f} m")

        # Process measurement
        x_pred, x_updated, P_updated, K = ukf.process_measurement(z_meas)

        print(f"Python UKF Output:")
        print(f"  x_pos = {x_updated[0]:.6f} m")
        print(f"  y_pos = {x_updated[3]:.6f} m")
        print(f"  z_pos = {x_updated[6]:.6f} m")
        print(f"  x_vel = {x_updated[1]:.6f} m/s")
        print(f"  y_vel = {x_updated[4]:.6f} m/s")
        print(f"  z_vel = {x_updated[7]:.6f} m/s")
        print()

        results.append({
            'cycle': i,
            'x_pos': x_updated[0],
            'y_pos': x_updated[3],
            'z_pos': x_updated[6],
            'x_vel': x_updated[1],
            'y_vel': x_updated[4],
            'z_vel': x_updated[7],
            'x_acc': x_updated[2],
            'y_acc': x_updated[5],
            'z_acc': x_updated[8],
            'z_x_meas': z_x,
            'z_y_meas': z_y,
            'z_z_meas': z_z
        })

    # Save to CSV
    results_df = pd.DataFrame(results)
    output_file = '../test_data/python_outputs_verified.txt'
    results_df.to_csv(output_file, index=False)

    print("=" * 80)
    print(f"Python UKF outputs saved to: {output_file}")
    print("=" * 80)
    print()

    return results_df


if __name__ == '__main__':
    df = run_python_ukf_verification(
        '../test_data/constant_velocity_10cycles.csv',
        num_cycles=10
    )
