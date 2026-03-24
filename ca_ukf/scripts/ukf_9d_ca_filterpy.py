#!/usr/bin/env python3
"""
9D Constant Acceleration UKF using FilterPy Library
Third gold model for validation (Custom Python, FilterPy, VHDL)

CRITICAL: Parameters must exactly match ukf_9d_ca_reference.py
"""

import numpy as np
from filterpy.kalman import UnscentedKalmanFilter, MerweScaledSigmaPoints

class UKF_9D_CA_FilterPy:
    """9D Constant Acceleration UKF using FilterPy library"""
    
    def __init__(self, dt=0.02, q_power=5.0, r_diag=1.0):
        """
        Initialize FilterPy UKF with matching parameters
        
        Args:
            dt: Time step (seconds)
            q_power: Process noise power
            r_diag: Measurement noise variance (m²)
        """
        self.dt = dt
        self.q_power = q_power
        self.r_diag = r_diag
        
        # State dimension
        self.n = 9  # [x_pos, x_vel, x_acc, y_pos, y_vel, y_acc, z_pos, z_vel, z_acc]
        
        # Measurement dimension
        self.m = 3  # [z_x, z_y, z_z] - position only
        
        # UKF parameters (MUST match custom Python)
        self.alpha = 1.0
        self.beta = 2.0
        self.kappa = 0.0
        
        # Initialize sigma points
        points = MerweScaledSigmaPoints(
            n=self.n,
            alpha=self.alpha,
            beta=self.beta,
            kappa=self.kappa
        )
        
        # Create UKF
        self.ukf = UnscentedKalmanFilter(
            dim_x=self.n,
            dim_z=self.m,
            dt=self.dt,
            fx=self.fx,
            hx=self.hx,
            points=points
        )
        
        # Initialize state
        self.ukf.x = np.zeros(self.n)
        
        # Initialize covariance (diagonal, 1.0 for all states)
        self.ukf.P = np.eye(self.n)
        
        # Set process noise Q
        self.ukf.Q = self._compute_process_noise_q()
        
        # Set measurement noise R
        self.ukf.R = np.diag([self.r_diag, self.r_diag, self.r_diag])
    
    def _compute_process_noise_q(self):
        """
        Compute process noise Q matrix
        Continuous white noise acceleration model
        MUST match custom Python implementation
        """
        dt = self.dt
        q = self.q_power
        
        # Single axis block
        q_block = q * np.array([
            [dt**5 / 20.0, dt**4 / 8.0,  dt**3 / 6.0],
            [dt**4 / 8.0,  dt**3 / 3.0,  dt**2 / 2.0],
            [dt**3 / 6.0,  dt**2 / 2.0,  dt        ]
        ])
        
        # Build 9×9 block diagonal
        Q = np.zeros((9, 9))
        Q[0:3, 0:3] = q_block  # X axis
        Q[3:6, 3:6] = q_block  # Y axis
        Q[6:9, 6:9] = q_block  # Z axis
        
        return Q
    
    def fx(self, x, dt):
        """
        State transition function (constant acceleration model)
        
        x[k+1] = F * x[k]
        where F is the state transition matrix
        """
        F = np.array([
            # X axis
            [1, dt, 0.5*dt**2,  0,  0,         0,  0,  0,         0],
            [0,  1,        dt,  0,  0,         0,  0,  0,         0],
            [0,  0,         1,  0,  0,         0,  0,  0,         0],
            # Y axis
            [0,  0,         0,  1, dt, 0.5*dt**2,  0,  0,         0],
            [0,  0,         0,  0,  1,        dt,  0,  0,         0],
            [0,  0,         0,  0,  0,         1,  0,  0,         0],
            # Z axis
            [0,  0,         0,  0,  0,         0,  1, dt, 0.5*dt**2],
            [0,  0,         0,  0,  0,         0,  0,  1,        dt],
            [0,  0,         0,  0,  0,         0,  0,  0,         1]
        ])
        
        return F @ x
    
    def hx(self, x):
        """
        Measurement function (observe position only)
        
        z = H * x
        where H extracts position from state
        """
        return np.array([x[0], x[3], x[6]])  # [x_pos, y_pos, z_pos]
    
    def predict(self):
        """Run prediction step"""
        self.ukf.predict()
    
    def update(self, z):
        """Run update step with measurement"""
        self.ukf.update(z)
    
    def process_measurement(self, z):
        """Complete filter cycle: predict + update"""
        self.predict()
        self.update(z)
    
    def get_state(self):
        """Get current state estimate"""
        return self.ukf.x.copy()
    
    def get_covariance(self):
        """Get current covariance matrix"""
        return self.ukf.P.copy()
    
    def get_covariance_diagonal(self):
        """Get diagonal elements of covariance (uncertainties)"""
        return np.diag(self.ukf.P)
    
    def reset(self):
        """Reset filter to initial state"""
        self.ukf.x = np.zeros(self.n)
        self.ukf.P = np.eye(self.n)

def main():
    """Test FilterPy UKF with simple trajectory"""
    print("="*80)
    print("FilterPy 9D CA UKF - Test Run")
    print("="*80)
    
    # Create filter
    ukf = UKF_9D_CA_FilterPy(dt=0.02, q_power=5.0, r_diag=1.0)
    
    # Generate simple test trajectory (constant acceleration)
    dt = 0.02
    cycles = 50
    
    # True state: constant acceleration
    ax, ay, az = 1.0, 0.5, 0.3
    
    print(f"\nTest trajectory: {cycles} cycles")
    print(f"True acceleration: ax={ax}, ay={ay}, az={az} m/s²")
    
    for k in range(cycles):
        t = k * dt
        
        # Ground truth (constant acceleration)
        x_pos = 0.5 * ax * t**2
        y_pos = 0.5 * ay * t**2
        z_pos = 0.5 * az * t**2
        
        # Noisy measurement
        z = np.array([x_pos, y_pos, z_pos]) + np.random.normal(0, 1.0, 3)
        
        # Process measurement
        ukf.process_measurement(z)
        
        if k % 10 == 0:
            state = ukf.get_state()
            print(f"\nCycle {k:3d}:")
            print(f"  Position: [{state[0]:6.2f}, {state[3]:6.2f}, {state[6]:6.2f}]")
            print(f"  Velocity: [{state[1]:6.2f}, {state[4]:6.2f}, {state[7]:6.2f}]")
            print(f"  Accel:    [{state[2]:6.2f}, {state[5]:6.2f}, {state[8]:6.2f}]")
    
    print("\n" + "="*80)
    print("Test complete - FilterPy UKF operational")
    print("="*80)

if __name__ == "__main__":
    main()
