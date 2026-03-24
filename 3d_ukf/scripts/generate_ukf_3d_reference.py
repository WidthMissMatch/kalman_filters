#!/usr/bin/env python3
"""
3D UKF Python Reference Implementation
Generates test vectors for validating VHDL implementation

State: [x_pos, x_vel, y_pos, y_vel, z_pos, z_vel]
Measurement: [z_x, z_y, z_z] (position only)
Motion model: Constant velocity in 3D
"""

import numpy as np
import csv
import sys

# Fixed-point conversion
Q = 24  # Fractional bits for Q24.24 format
SCALE = 2**Q  # 16777216

def to_fixed(val):
    """Convert float to Q24.24 fixed-point integer"""
    return int(round(val * SCALE))

def from_fixed(val):
    """Convert Q24.24 fixed-point integer to float"""
    return val / SCALE

class UKF3D:
    """3D Unscented Kalman Filter - Python Reference"""

    def __init__(self):
        # State dimension
        self.n = 6  # [x_pos, x_vel, y_pos, y_vel, z_pos, z_vel]
        self.m = 3  # [z_x, z_y, z_z]

        # Number of sigma points
        self.num_sigma = 2 * self.n + 1  # 13

        # UKF parameters
        self.alpha = 1.0
        self.beta = 2.0
        self.kappa = 3.0 - self.n
        self.lambda_ = self.alpha**2 * (self.n + self.kappa) - self.n

        # UKF weights
        self.Wm = np.zeros(self.num_sigma)
        self.Wc = np.zeros(self.num_sigma)

        self.Wm[0] = self.lambda_ / (self.n + self.lambda_)
        self.Wc[0] = self.Wm[0] + (1 - self.alpha**2 + self.beta)

        for i in range(1, self.num_sigma):
            self.Wm[i] = 1.0 / (2.0 * (self.n + self.lambda_))
            self.Wc[i] = self.Wm[i]

        # State and covariance
        self.x = np.zeros(self.n)
        self.P = np.eye(self.n) * 1.0  # Initial covariance

        # Process noise Q (diagonal)
        # Scaled for dt=100ms (5× larger than original 20ms)
        # Q scales linearly with dt: Q_new = Q_old × (0.1/0.02) = Q_old × 5
        # Q_pos: 1.0 × 5 = 5.0 m², Q_vel: 0.05 × 5 = 0.25 (m/s)²
        self.Q = np.diag([5.0, 0.25, 5.0, 0.25, 5.0, 0.25])

        # Measurement noise R (diagonal)
        # R = 4194304/16777216 = 0.25 for each axis
        self.R = np.diag([0.25, 0.25, 0.25])

        # Time step
        self.dt = 0.1  # 100ms (changed from 20ms for large dataset testing)

        # First measurement flag
        self.initialized = False

    def predict(self):
        """Prediction step"""
        # Generate sigma points
        gamma = np.sqrt(self.n + self.lambda_)

        try:
            L = np.linalg.cholesky(self.P)
        except np.linalg.LinAlgError:
            print("Warning: Cholesky failed, using eigenvalue decomposition")
            eigval, eigvec = np.linalg.eigh(self.P)
            eigval = np.maximum(eigval, 1e-10)  # Ensure positive
            L = eigvec @ np.diag(np.sqrt(eigval))

        # Sigma points
        sigma_points = np.zeros((self.num_sigma, self.n))
        sigma_points[0] = self.x

        for i in range(self.n):
            sigma_points[i + 1] = self.x + gamma * L[:, i]
            sigma_points[i + 1 + self.n] = self.x - gamma * L[:, i]

        # Propagate sigma points through motion model
        sigma_points_pred = np.zeros_like(sigma_points)
        for i in range(self.num_sigma):
            sigma_points_pred[i] = self.motion_model(sigma_points[i])

        # Predicted mean
        self.x_pred = np.sum(self.Wm[:, np.newaxis] * sigma_points_pred, axis=0)

        # Predicted covariance
        self.P_pred = np.zeros((self.n, self.n))
        for i in range(self.num_sigma):
            dx = sigma_points_pred[i] - self.x_pred
            self.P_pred += self.Wc[i] * np.outer(dx, dx)

        self.P_pred += self.Q

        # Store predicted sigma points for measurement update
        self.sigma_points_pred = sigma_points_pred

    def motion_model(self, x):
        """Constant velocity motion model"""
        x_next = np.zeros(self.n)
        x_next[0] = x[0] + x[1] * self.dt  # x_pos
        x_next[1] = x[1]                    # x_vel (constant)
        x_next[2] = x[2] + x[3] * self.dt  # y_pos
        x_next[3] = x[3]                    # y_vel (constant)
        x_next[4] = x[4] + x[5] * self.dt  # z_pos
        x_next[5] = x[5]                    # z_vel (constant)
        return x_next

    def update(self, z):
        """Measurement update step"""
        if not self.initialized:
            # Initialize from first measurement
            self.x[0] = z[0]  # x_pos
            self.x[2] = z[1]  # y_pos
            self.x[4] = z[2]  # z_pos
            self.x[1] = 0.0   # x_vel
            self.x[3] = 0.0   # y_vel
            self.x[5] = 0.0   # z_vel
            self.initialized = True
            return

        # Predicted measurements (position only)
        Z_sigma = np.zeros((self.num_sigma, self.m))
        for i in range(self.num_sigma):
            Z_sigma[i] = self.measurement_model(self.sigma_points_pred[i])

        # Predicted measurement mean
        z_pred = np.sum(self.Wm[:, np.newaxis] * Z_sigma, axis=0)

        # Innovation covariance S
        S = np.zeros((self.m, self.m))
        for i in range(self.num_sigma):
            dz = Z_sigma[i] - z_pred
            S += self.Wc[i] * np.outer(dz, dz)
        S += self.R

        # Cross-covariance Pxz
        Pxz = np.zeros((self.n, self.m))
        for i in range(self.num_sigma):
            dx = self.sigma_points_pred[i] - self.x_pred
            dz = Z_sigma[i] - z_pred
            Pxz += self.Wc[i] * np.outer(dx, dz)

        # Kalman gain
        try:
            K = Pxz @ np.linalg.inv(S)
        except np.linalg.LinAlgError:
            print("Warning: Singular S matrix, using pseudo-inverse")
            K = Pxz @ np.linalg.pinv(S)

        # Innovation
        innovation = z - z_pred

        # State update
        self.x = self.x_pred + K @ innovation

        # Covariance update (Joseph form)
        I = np.eye(self.n)
        H = np.array([[1, 0, 0, 0, 0, 0],
                      [0, 0, 1, 0, 0, 0],
                      [0, 0, 0, 0, 1, 0]])  # Position-only measurement
        A = I - K @ H
        self.P = A @ self.P_pred @ A.T + K @ self.R @ K.T

        return innovation, z_pred

    def measurement_model(self, x):
        """Measurement model: observe position only"""
        return np.array([x[0], x[2], x[4]])  # [x_pos, y_pos, z_pos]


def generate_trajectory(scenario, num_steps):
    """Generate ground truth trajectory and noisy measurements"""
    dt = 0.1  # 100ms (changed from 20ms for large dataset testing)
    t = np.arange(num_steps) * dt

    # Measurement noise (std dev = 0.5m per axis)
    meas_noise_std = 0.5

    if scenario == "straight_line_xyz":
        # Linear motion in all three axes with different velocities
        x_true = 1.0 * t  # 1 m/s in x
        y_true = 0.5 * t  # 0.5 m/s in y
        z_true = 0.3 * t  # 0.3 m/s in z

        x_vel_true = np.ones_like(t) * 1.0
        y_vel_true = np.ones_like(t) * 0.5
        z_vel_true = np.ones_like(t) * 0.3

    elif scenario == "circular_xy_static_z":
        # Circular motion in XY plane, static Z at 1m
        radius = 2.0
        omega = 0.5  # rad/s

        x_true = radius * np.cos(omega * t)
        y_true = radius * np.sin(omega * t)
        z_true = np.ones_like(t) * 1.0

        x_vel_true = -radius * omega * np.sin(omega * t)
        y_vel_true = radius * omega * np.cos(omega * t)
        z_vel_true = np.zeros_like(t)

    elif scenario == "helical":
        # Helical motion (circular XY + linear Z)
        radius = 2.0
        omega = 0.5  # rad/s
        z_vel_const = 0.5  # m/s upward

        x_true = radius * np.cos(omega * t)
        y_true = radius * np.sin(omega * t)
        z_true = z_vel_const * t

        x_vel_true = -radius * omega * np.sin(omega * t)
        y_vel_true = radius * omega * np.cos(omega * t)
        z_vel_true = np.ones_like(t) * z_vel_const

    else:
        raise ValueError(f"Unknown scenario: {scenario}")

    # Add measurement noise
    z_x_meas = x_true + np.random.normal(0, meas_noise_std, num_steps)
    z_y_meas = y_true + np.random.normal(0, meas_noise_std, num_steps)
    z_z_meas = z_true + np.random.normal(0, meas_noise_std, num_steps)

    return {
        'x_true': x_true, 'x_vel_true': x_vel_true,
        'y_true': y_true, 'y_vel_true': y_vel_true,
        'z_true': z_true, 'z_vel_true': z_vel_true,
        'z_x_meas': z_x_meas, 'z_y_meas': z_y_meas, 'z_z_meas': z_z_meas
    }


def run_ukf_test(scenario, num_steps, output_csv):
    """Run UKF on test scenario and save results"""
    print(f"Generating {scenario} trajectory ({num_steps} steps)...")
    data = generate_trajectory(scenario, num_steps)

    ukf = UKF3D()

    results = []

    for i in range(num_steps):
        z_meas = np.array([data['z_x_meas'][i],
                          data['z_y_meas'][i],
                          data['z_z_meas'][i]])

        # Predict
        if ukf.initialized:
            ukf.predict()

        # Update
        if ukf.initialized:
            innovation, z_pred = ukf.update(z_meas)
        else:
            ukf.update(z_meas)
            innovation = np.zeros(3)
            z_pred = z_meas

        # Store results
        results.append({
            'cycle': i,
            'time': i * 0.1,  # 100ms time step
            'x_pos_true': data['x_true'][i],
            'x_vel_true': data['x_vel_true'][i],
            'y_pos_true': data['y_true'][i],
            'y_vel_true': data['y_vel_true'][i],
            'z_pos_true': data['z_true'][i],
            'z_vel_true': data['z_vel_true'][i],
            'z_x_meas': data['z_x_meas'][i],
            'z_y_meas': data['z_y_meas'][i],
            'z_z_meas': data['z_z_meas'][i],
            'x_pos_est': ukf.x[0],
            'x_vel_est': ukf.x[1],
            'y_pos_est': ukf.x[2],
            'y_vel_est': ukf.x[3],
            'z_pos_est': ukf.x[4],
            'z_vel_est': ukf.x[5],
            'p11': ukf.P[0, 0],
            'p22': ukf.P[1, 1],
            'p33': ukf.P[2, 2],
            'p44': ukf.P[3, 3],
            'p55': ukf.P[4, 4],
            'p66': ukf.P[5, 5],
            'innovation_x': innovation[0],
            'innovation_y': innovation[1],
            'innovation_z': innovation[2]
        })

    # Write CSV
    print(f"Writing results to {output_csv}...")
    with open(output_csv, 'w', newline='') as f:
        fieldnames = results[0].keys()
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)

    # Calculate RMSE
    x_pos_errors = [abs(r['x_pos_true'] - r['x_pos_est']) for r in results[1:]]
    y_pos_errors = [abs(r['y_pos_true'] - r['y_pos_est']) for r in results[1:]]
    z_pos_errors = [abs(r['z_pos_true'] - r['z_pos_est']) for r in results[1:]]

    x_pos_rmse = np.sqrt(np.mean(np.array(x_pos_errors)**2))
    y_pos_rmse = np.sqrt(np.mean(np.array(y_pos_errors)**2))
    z_pos_rmse = np.sqrt(np.mean(np.array(z_pos_errors)**2))

    print(f"\nResults:")
    print(f"  X position RMSE: {x_pos_rmse:.6f} m")
    print(f"  Y position RMSE: {y_pos_rmse:.6f} m")
    print(f"  Z position RMSE: {z_pos_rmse:.6f} m")
    print(f"  CSV written: {output_csv}")

    return results


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 generate_ukf_3d_reference.py <scenario> [num_steps]")
        print("Scenarios: straight_line_xyz, circular_xy_static_z, helical")
        print("Default num_steps: 100")
        sys.exit(1)

    scenario = sys.argv[1]
    num_steps = int(sys.argv[2]) if len(sys.argv) > 2 else 100

    output_csv = f"ukf_3d_reference_{scenario}_{num_steps}.csv"

    np.random.seed(42)  # Reproducible results
    run_ukf_test(scenario, num_steps, output_csv)
