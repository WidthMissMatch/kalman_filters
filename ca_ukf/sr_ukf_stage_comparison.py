#!/usr/bin/env python3
"""
Stage-by-stage comparison of SR-UKF Python vs VHDL.
Identifies exactly where precision loss or bugs occur.
"""
import numpy as np
import re, os, sys, csv, math

Q24 = 2**24
N = 9
N_SIGMA = 19
DT = 0.02  # Match VHDL predicti_ca3d
ALPHA = 1.0; BETA = 2.0; KAPPA = 0.0
LAMBDA = ALPHA**2 * (N + KAPPA) - N  # = 0
GAMMA = np.sqrt(N + LAMBDA)  # = 3.0

W_M = np.zeros(N_SIGMA)
W_C = np.zeros(N_SIGMA)
W_M[0] = LAMBDA / (N + LAMBDA)  # = 0
W_C[0] = LAMBDA / (N + LAMBDA) + (1 - ALPHA**2 + BETA)  # = 2.0
for i in range(1, N_SIGMA):
    W_M[i] = 1.0 / (2.0 * (N + LAMBDA))  # = 1/18
    W_C[i] = 1.0 / (2.0 * (N + LAMBDA))  # = 1/18

P_INIT = np.diag([5.0, 20.0, 0.01, 5.0, 20.0, 0.01, 5.0, 20.0, 0.01])
L_INIT = np.linalg.cholesky(P_INIT)
Q_DIAG = np.array([0.05, 0.0005, 0.00001, 0.05, 0.0005, 0.00001, 0.05, 0.0005, 0.00001])
Q = np.diag(Q_DIAG)
LQ = np.diag(np.sqrt(Q_DIAG))
R = np.diag([0.25, 0.25, 0.25])
H = np.zeros((3, N)); H[0,0] = 1.0; H[1,3] = 1.0; H[2,6] = 1.0

F = np.eye(N)
for axis in range(3):
    base = 3 * axis
    F[base, base+1] = DT
    F[base, base+2] = 0.5 * DT**2
    F[base+1, base+2] = DT


def cholupdate(L, u):
    L_new = L.copy(); u_new = u.copy(); n = len(u)
    for col in range(n):
        r = np.sqrt(L_new[col,col]**2 + u_new[col]**2)
        if r == 0: continue
        c = L_new[col,col] / r
        s = u_new[col] / r
        L_new[col,col] = r
        for row in range(col+1, n):
            temp_L = c * L_new[row,col] + s * u_new[row]
            temp_u = c * u_new[row] - s * L_new[row,col]
            L_new[row,col] = temp_L
            u_new[row] = temp_u
    return L_new

def choldowndate(L, w):
    L_new = L.copy(); w_new = w.copy(); n = len(w)
    for col in range(n):
        r_sq = L_new[col,col]**2 - w_new[col]**2
        if r_sq <= 0:
            r = np.sqrt(abs(r_sq)) if r_sq < 0 else 0
            if r == 0: continue
        else:
            r = np.sqrt(r_sq)
        c = r / L_new[col,col]
        s = w_new[col] / L_new[col,col]
        L_new[col,col] = r
        for row in range(col+1, n):
            temp_L = (L_new[row,col] - s * w_new[row]) / c if c != 0 else L_new[row,col]
            temp_w = c * w_new[row] - s * L_new[row,col]
            w_new[row] = temp_w
            L_new[row,col] = temp_L
    return L_new


def to_q24(val):
    """Convert float to Q24.24 integer"""
    return int(round(val * Q24))

def from_q24(val):
    """Convert Q24.24 integer to float"""
    return val / Q24


def load_measurements():
    tb_path = 'ca_ukf.srcs/sim_1/new/sr_ukf_real_synthetic_drone_500cycles_tb.vhd'
    with open(tb_path) as f:
        content = f.read()
    z_data = []
    for axis in ['x', 'y', 'z']:
        pattern = rf'constant meas_{axis}_data\s*:\s*meas_array_t\s*:=\s*\((.*?)\);'
        match = re.search(pattern, content, re.DOTALL)
        values = re.findall(r'to_signed\((-?\d+),\s*48\)', match.group(1))
        z_data.append([int(v)/Q24 for v in values])
    return np.array(z_data).T


def load_ground_truth():
    gt = {}
    with open('test_data/real_world/synthetic_drone_500cycles.csv') as f:
        reader = csv.DictReader(f)
        for row in reader:
            c = int(row['cycle'])
            gt[c] = (float(row['gt_x_pos']), float(row['gt_y_pos']), float(row['gt_z_pos']))
    return gt


def load_vhdl_output():
    estimates = {}
    with open('sr_vhdl_output_synthetic_drone_500cycles.txt') as f:
        for line in f:
            m = re.match(r'Cycle\s+(\d+):\s+x_pos=(-?\d+)\s+x_vel=(-?\d+)\s+x_acc=(-?\d+)\s+y_pos=(-?\d+)\s+y_vel=(-?\d+)\s+y_acc=(-?\d+)\s+z_pos=(-?\d+)\s+z_vel=(-?\d+)\s+z_acc=(-?\d+)', line)
            if m:
                c = int(m.group(1))
                estimates[c] = [int(m.group(i)) for i in range(2,11)]
    return estimates


def main():
    z_data = load_measurements()
    gt = load_ground_truth()
    vhdl = load_vhdl_output()

    print("="*100)
    print("SR-UKF STAGE-BY-STAGE AUDIT: Python (float64) vs VHDL (Q24.24)")
    print("Goal: Find if 1.17m RMSE (vs 0.90m standard UKF) is precision or a bug")
    print("="*100)

    x = np.zeros(N)
    L = L_INIT.copy()

    n_cycles = min(500, len(z_data))
    py_errors = []
    vhdl_errors = []

    # Stage-by-stage comparison for first few cycles
    for cycle in range(n_cycles):
        z_meas = z_data[cycle]
        verbose = (cycle < 3)  # Show first 3 cycles in detail

        # ===== PREDICTION PHASE =====
        # Step 1: Sigma points
        chi = np.zeros((N_SIGMA, N))
        chi[0] = x
        for i in range(N):
            chi[i+1] = x + GAMMA * L[:, i]
            chi[i+1+N] = x - GAMMA * L[:, i]

        # Step 2: Predict sigma points through CA model
        chi_pred = np.zeros((N_SIGMA, N))
        for i in range(N_SIGMA):
            chi_pred[i] = F @ chi[i]

        # Step 3: Predicted mean
        x_pred = np.zeros(N)
        for i in range(N_SIGMA):
            x_pred += W_M[i] * chi_pred[i]

        # Step 4: QR decomposition
        sqrt_wc = np.sqrt(W_C[1])  # sqrt(1/18)
        A = np.zeros((N, N_SIGMA-1))
        for j in range(N_SIGMA-1):
            A[:, j] = sqrt_wc * (chi_pred[j+1] - x_pred)

        Q_mat, R_mat = np.linalg.qr(A.T, mode='reduced')
        L_qr = R_mat.T
        for i in range(N):
            if L_qr[i,i] < 0:
                L_qr[i,:] *= -1

        # Step 5: W0 rank-1 update
        sqrt_wc0 = np.sqrt(abs(W_C[0]))  # sqrt(2.0)
        w0_vec = sqrt_wc0 * (chi_pred[0] - x_pred)
        L_w0 = cholupdate(L_qr, w0_vec)

        # Step 6: Process noise rank-1 updates
        L_pred = L_w0.copy()
        for col in range(N):
            L_pred = cholupdate(L_pred, LQ[:, col])

        # ===== MEASUREMENT UPDATE PHASE =====
        # Step 7: Measurement sigma points and mean
        z_sigma = np.zeros((N_SIGMA, 3))
        for i in range(N_SIGMA):
            z_sigma[i] = H @ chi_pred[i]
        z_mean = np.zeros(3)
        for i in range(N_SIGMA):
            z_mean += W_M[i] * z_sigma[i]

        # Step 8: Innovation
        nu = z_meas - z_mean

        # Step 9: Cross-covariance
        Pxz = np.zeros((N, 3))
        for i in range(N_SIGMA):
            dx = chi_pred[i] - x_pred
            dz = z_sigma[i] - z_mean
            Pxz += W_C[i] * np.outer(dx, dz)

        # Step 10: Innovation covariance
        S_yy = np.zeros((3, 3))
        for i in range(N_SIGMA):
            dz = z_sigma[i] - z_mean
            S_yy += W_C[i] * np.outer(dz, dz)
        S_yy += R

        # Step 11: Kalman gain
        K = Pxz @ np.linalg.inv(S_yy)

        # Step 12: State update
        x_upd = x_pred + K @ nu

        # Step 12b: L update via Potter downdates with sqrt(S)
        L_upd = L_pred.copy()
        for m_idx in range(3):
            sqrt_s = np.sqrt(S_yy[m_idx, m_idx])
            w = K[:, m_idx] * sqrt_s
            L_upd = choldowndate(L_upd, w)

        # Compute errors vs ground truth
        if cycle in gt:
            gx, gy, gz = gt[cycle]
            py_err = math.sqrt((x_upd[0]-gx)**2 + (x_upd[3]-gy)**2 + (x_upd[6]-gz)**2)
            py_errors.append(py_err)

            if cycle in vhdl:
                vx = vhdl[cycle][0]/Q24
                vy = vhdl[cycle][3]/Q24
                vz = vhdl[cycle][6]/Q24
                vhdl_err = math.sqrt((vx-gx)**2 + (vy-gy)**2 + (vz-gz)**2)
                vhdl_errors.append(vhdl_err)

        if verbose:
            print(f"\n{'='*80}")
            print(f"CYCLE {cycle}")
            print(f"{'='*80}")
            print(f"  z_meas: [{z_meas[0]:.6f}, {z_meas[1]:.6f}, {z_meas[2]:.6f}]")

            # L input
            print(f"\n  --- L_input (start of cycle) ---")
            print(f"  L diag: [{', '.join(f'{L[i,i]:.6f}' for i in range(N))}]")
            print(f"  L Q24:  [{', '.join(f'{to_q24(L[i,i])}' for i in range(N))}]")

            # Predicted mean
            print(f"\n  --- Predicted mean (after sigma+predict+mean) ---")
            print(f"  x_pred: [{', '.join(f'{x_pred[i]:.6f}' for i in range(N))}]")

            # QR result
            print(f"\n  --- After QR decomposition ---")
            print(f"  L_qr diag: [{', '.join(f'{L_qr[i,i]:.6f}' for i in range(N))}]")
            print(f"  L_qr Q24:  [{', '.join(f'{to_q24(L_qr[i,i])}' for i in range(N))}]")

            # W0 update
            print(f"\n  --- After W0 rank-1 update ---")
            print(f"  w0_vec: [{', '.join(f'{w0_vec[i]:.6f}' for i in range(N))}]")
            print(f"  L_w0 diag: [{', '.join(f'{L_w0[i,i]:.6f}' for i in range(N))}]")
            print(f"  L_w0 Q24:  [{', '.join(f'{to_q24(L_w0[i,i])}' for i in range(N))}]")

            # Process noise
            print(f"\n  --- After process noise rank-1 updates ---")
            print(f"  L_pred diag: [{', '.join(f'{L_pred[i,i]:.6f}' for i in range(N))}]")
            print(f"  L_pred Q24:  [{', '.join(f'{to_q24(L_pred[i,i])}' for i in range(N))}]")

            # Pxz and S
            print(f"\n  --- Cross-covariance and Innovation covariance ---")
            print(f"  Pxz[:,0]: [{', '.join(f'{Pxz[i,0]:.6f}' for i in range(N))}]")
            print(f"  S_yy diag: [{S_yy[0,0]:.6f}, {S_yy[1,1]:.6f}, {S_yy[2,2]:.6f}]")
            print(f"  S_yy Q24: [{to_q24(S_yy[0,0])}, {to_q24(S_yy[1,1])}, {to_q24(S_yy[2,2])}]")

            # Kalman gain
            print(f"\n  --- Kalman gain ---")
            print(f"  K[:,0]: [{', '.join(f'{K[i,0]:.6f}' for i in range(N))}]")
            print(f"  K[:,1]: [{', '.join(f'{K[i,1]:.6f}' for i in range(N))}]")

            # State update
            print(f"\n  --- State update ---")
            print(f"  nu: [{nu[0]:.6f}, {nu[1]:.6f}, {nu[2]:.6f}]")
            print(f"  Python x_upd: [{', '.join(f'{x_upd[i]:.6f}' for i in range(N))}]")
            if cycle in vhdl:
                print(f"  VHDL   x_upd: [{', '.join(f'{vhdl[cycle][i]/Q24:.6f}' for i in range(N))}]")
                diff = [abs(x_upd[i] - vhdl[cycle][i]/Q24) for i in range(N)]
                print(f"  Diff (abs):   [{', '.join(f'{d:.6f}' for d in diff)}]")

            # L update
            print(f"\n  --- L update (Potter downdates with sqrt(S)) ---")
            print(f"  sqrt(S): [{np.sqrt(S_yy[0,0]):.6f}, {np.sqrt(S_yy[1,1]):.6f}, {np.sqrt(S_yy[2,2]):.6f}]")
            print(f"  L_upd diag: [{', '.join(f'{L_upd[i,i]:.6f}' for i in range(N))}]")
            print(f"  L_upd Q24:  [{', '.join(f'{to_q24(L_upd[i,i])}' for i in range(N))}]")

            # Error comparison
            if cycle in gt:
                gx, gy, gz = gt[cycle]
                print(f"\n  --- Error vs ground truth ---")
                print(f"  Ground truth: ({gx:.4f}, {gy:.4f}, {gz:.4f})")
                print(f"  Python err: {py_err:.4f}m")
                if cycle in vhdl:
                    print(f"  VHDL   err: {vhdl_err:.4f}m")

        # Update state for next cycle
        x = x_upd
        L = L_upd

    # Summary
    print(f"\n{'='*100}")
    print("SUMMARY")
    print(f"{'='*100}")
    py_rmse = np.sqrt(np.mean(np.array(py_errors)**2))
    vhdl_rmse = np.sqrt(np.mean(np.array(vhdl_errors)**2))
    print(f"Python SR-UKF RMSE: {py_rmse:.4f}m")
    print(f"VHDL SR-UKF RMSE:   {vhdl_rmse:.4f}m")
    print(f"Gap: {vhdl_rmse - py_rmse:.4f}m ({(vhdl_rmse/py_rmse - 1)*100:.1f}% worse)")

    # Check for systematic differences
    print(f"\nPer-range RMSE comparison:")
    for start, end in [(0,10), (10,50), (50,100), (100,200), (200,500)]:
        py_slice = py_errors[start:min(end, len(py_errors))]
        vhdl_slice = vhdl_errors[start:min(end, len(vhdl_errors))]
        if py_slice and vhdl_slice:
            py_r = np.sqrt(np.mean(np.array(py_slice)**2))
            vhdl_r = np.sqrt(np.mean(np.array(vhdl_slice)**2))
            print(f"  Cycles {start:3d}-{end:3d}: Python={py_r:.4f}m  VHDL={vhdl_r:.4f}m  Gap={vhdl_r-py_r:.4f}m")

    # Check if VHDL is consistently worse (precision) or sometimes better (different behavior)
    better_count = sum(1 for i in range(len(vhdl_errors)) if vhdl_errors[i] < py_errors[i])
    total = len(vhdl_errors)
    print(f"\nVHDL better than Python in {better_count}/{total} cycles ({better_count/total*100:.1f}%)")

    # Check specific L diagonal comparison between Python and VHDL
    # This requires VHDL L output which we don't have yet
    print(f"\nFinal Python L diag: [{', '.join(f'{L[i,i]:.6f}' for i in range(N))}]")

    # Key diagnostic: check if the Potter downdate vectors match
    # The key question: does VHDL use S or R for the sqrt?
    print(f"\nKey check - sqrt(S) vs sqrt(R) at cycle 0:")
    S0 = S_yy[0,0]  # This was computed for the FIRST cycle above (we'd need to track it)
    print(f"  S[0,0] should be ~{5.058 + 0.25:.4f} (P_pred[0,0] + R)")
    print(f"  R[0,0] = 0.25")
    print(f"  sqrt(S) ≈ {np.sqrt(5.308):.4f}")
    print(f"  sqrt(R) = {np.sqrt(0.25):.4f}")
    print(f"  Ratio: {np.sqrt(5.308)/np.sqrt(0.25):.2f}x")


if __name__ == '__main__':
    main()
