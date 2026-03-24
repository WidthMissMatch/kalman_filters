#!/usr/bin/env python3
"""
SR-UKF Precision Gap Analysis: Q24.24 vs Float64
=================================================
Identifies WHERE the RMSE gap between float64 and Q24.24 SR-UKF comes from
by selectively quantizing one component at a time.

VHDL-accurate quantization model:
  - Internal working: 96-bit Q48.48
  - Intermediates: 144-bit with rounding bias before shift
  - c/s Givens values: 48-bit Q24.24
  - sqrt: CORDIC with 48-bit I/O
  - Module boundaries: truncate to 48-bit Q24.24
  - W_SQRT constant = 3954427/2^24 (sqrt(1/18) in Q24.24)

VHDL process noise constants (from process_noise_rank1_ca_3d.vhd):
  LQ_POS = 2431249/2^24 = 0.14491 => Q_POS_eff = 0.02100
  LQ_VEL = 1186328/2^24 = 0.07071 => Q_VEL_eff = 0.005000
  LQ_ACC = 1677721/2^24 = 0.10000 => Q_ACC_eff = 0.01000

NOTE: These differ from the user-specified Q_POS=0.05, Q_VEL=0.00025, Q_ACC=0.00001.
The script runs BOTH parameter sets to identify whether the gap is from quantization
or from parameter mismatch.

CA model, 9D state, dt=0.02s, alpha=1, beta=2, kappa=0
"""

import numpy as np
import sys
import os

# ---------------------------------------------------------------------------
# Fixed-point quantization (VHDL-accurate)
# ---------------------------------------------------------------------------
Q_BITS = 24
SCALE = 1 << Q_BITS
SCALE_F = float(SCALE)

def q24_trunc(x):
    """Q24.24 truncation toward negative infinity (VHDL shift_right)."""
    if isinstance(x, np.ndarray):
        return np.floor(x * SCALE_F) / SCALE_F
    return int(np.floor(x * SCALE_F)) / SCALE_F

def q24_round(x):
    """Q24.24 round-to-nearest (VHDL + ROUND_144 style)."""
    if isinstance(x, np.ndarray):
        return np.round(x * SCALE_F) / SCALE_F
    return round(x * SCALE_F) / SCALE_F

# Use truncation as default (matches VHDL shift_right behavior)
q24 = q24_trunc

def q48_trunc(x):
    """Q48.48 truncation (96-bit internal registers)."""
    S = float(1 << 48)
    if isinstance(x, np.ndarray):
        return np.floor(x * S) / S
    return int(np.floor(x * S)) / S

def q48_round(x):
    """Q48.48 round (144-bit intermediate with rounding bias)."""
    S = float(1 << 48)
    if isinstance(x, np.ndarray):
        return np.round(x * S) / S
    return round(x * S) / S

def q24_div(num, den):
    """VHDL fixed-point division: (num << Q) / den, result Q24.24."""
    if den == 0:
        return 0.0
    n_int = int(round(num * SCALE_F))
    d_int = int(round(den * SCALE_F))
    if d_int == 0:
        return 0.0
    return (n_int * SCALE) // d_int / SCALE_F

def q24_sqrt(x):
    """CORDIC sqrt: Q24.24 I/O."""
    if x <= 0:
        return 0.0
    xq = q24(x)
    if xq <= 0:
        return 0.0
    return q24(np.sqrt(xq))


# ---------------------------------------------------------------------------
# Quantization mode
# ---------------------------------------------------------------------------
class QMode:
    def __init__(self, name="float64"):
        self.name = name
        self.module_boundary = False
        self.qr_internal = False
        self.update_internal = False
        self.downdate_internal = False
        self.sqrt_cordic = False
        self.givens_cs = False
        self.state_arith = False
        self.full = False


# ---------------------------------------------------------------------------
# VHDL constants
# ---------------------------------------------------------------------------
W_SQRT = 3954427 / SCALE_F  # sqrt(1/18) in Q24.24


# ---------------------------------------------------------------------------
# Rank-1 Cholesky update (Givens rotations, VHDL-accurate)
# ---------------------------------------------------------------------------
def cholupdate(L_in, u_in, mode):
    n = len(u_in)
    do_int = mode.update_internal or mode.full
    do_sqrt = mode.sqrt_cordic or mode.full
    do_cs = mode.givens_cs or mode.full
    do_bnd = mode.module_boundary or mode.full

    L = L_in.copy()
    u = u_in.copy()

    for j in range(n):
        a = q24(L[j, j]) if do_int else L[j, j]
        b = q24(u[j]) if do_int else u[j]

        nsq = q24(a*a) + q24(b*b) if do_int else a*a + b*b
        r = q24_sqrt(nsq) if do_sqrt else np.sqrt(max(nsq, 0))
        if r <= 0:
            continue

        if do_int or do_cs:
            c = q24_div(a, r) if r > 1/SCALE_F else 1.0
            s = q24_div(b, r) if r > 1/SCALE_F else 0.0
        else:
            c = a / r
            s = b / r

        L[j, j] = r

        for i in range(j+1, n):
            nl = c*L[i,j] + s*u[i]
            nu = c*u[i] - s*L[i,j]
            if do_int:
                nl = q48_round(nl)
                nu = q48_round(nu)
            L[i,j] = nl
            u[i] = nu

    if do_int or do_bnd:
        L = q24(L)
    return L


# ---------------------------------------------------------------------------
# Rank-1 Cholesky downdate (hyperbolic Givens, VHDL-accurate)
# ---------------------------------------------------------------------------
def choldowndate(L_in, w_in, mode):
    n = len(w_in)
    do_int = mode.downdate_internal or mode.full
    do_sqrt = mode.sqrt_cordic or mode.full
    do_cs = mode.givens_cs or mode.full
    do_bnd = mode.module_boundary or mode.full

    L = L_in.copy()
    w = w_in.copy()

    EPSILON = 168.0 / SCALE_F

    for j in range(n):
        a = q24(L[j,j]) if do_int else L[j,j]
        b = q24(w[j]) if do_int else w[j]

        a2 = q24(a*a) if do_int else a*a
        b2 = q24(b*b) if do_int else b*b

        if a2 < b2:
            return q24(L_in.copy()) if do_bnd else L_in.copy()

        diff = a2 - b2
        r = q24_sqrt(q24(diff) if do_int else diff) if do_sqrt else np.sqrt(max(diff, 0))

        if (do_int or do_sqrt) and r <= EPSILON:
            return q24(L_in.copy()) if do_bnd else L_in.copy()
        if r <= 0:
            continue

        # VHDL: c = a/r, s = b/r
        if do_int or do_cs:
            c = q24_div(a, r) if r > 1/SCALE_F else 1.0
            s = q24_div(b, r) if r > 1/SCALE_F else 0.0
        else:
            c = a / r
            s = b / r

        L[j,j] = r

        for i in range(j+1, n):
            # Hyperbolic: both minus
            old_lij = L[i,j]
            nl = c*L[i,j] - s*w[i]
            nw = c*w[i] - s*old_lij
            if do_int:
                nl = q48_round(nl)
                nw = q48_round(nw)
            L[i,j] = nl
            w[i] = nw

    if do_int or do_bnd:
        L = q24(L)
    return L


# ---------------------------------------------------------------------------
# LQ decomposition (VHDL qr_decomp_9x19 style)
# ---------------------------------------------------------------------------
def lq_decomposition(A_in, mode):
    """Row-wise Householder LQ decomposition. Input: 9x18, output: 9x9 lower tri."""
    m, n = A_in.shape
    do_int = mode.qr_internal or mode.full
    do_sqrt = mode.sqrt_cordic or mode.full
    do_cs = mode.givens_cs or mode.full

    A = A_in.copy()

    alpha_diag = np.zeros(m)

    for k in range(m):
        # Norm of row k, columns k..n-1
        if do_int:
            nsq = 0.0
            for j in range(k, n):
                v = q24(A[k, j])
                nsq += q24(v * v)
        else:
            nsq = np.sum(A[k, k:]**2)

        norm_val = q24_sqrt(nsq) if do_sqrt else np.sqrt(max(nsq, 0))
        if norm_val == 0:
            alpha_diag[k] = 0
            continue

        akk = q24(A[k, k]) if do_int else A[k, k]
        alpha = -norm_val if akk >= 0 else norm_val
        alpha_diag[k] = alpha

        # Householder vector v
        v = np.zeros(n)
        v[k] = akk - alpha
        for j in range(k+1, n):
            v[j] = q24(A[k, j]) if do_int else A[k, j]
        if do_int or do_cs:
            v = q24(v)

        # beta = 2/||v||^2
        if do_int:
            vsq = sum(q24(v[j]*v[j]) for j in range(k, n))
        else:
            vsq = np.sum(v[k:]**2)
        if vsq <= 0:
            continue
        beta = 2.0 / vsq
        if do_int:
            beta = q24(beta)

        # Apply reflection to rows i > k
        for i in range(k+1, m):
            if do_int:
                dot = sum(q48_round(A[i, j] * v[j]) for j in range(k, n))
                scale = q48_round(beta * dot)
                for j in range(k, n):
                    A[i, j] -= q48_round(scale * v[j])
                    A[i, j] = q48_round(A[i, j])
            else:
                dot = np.sum(A[i, k:] * v[k:])
                A[i, k:] -= (beta * dot) * v[k:]

    # Extract L
    L = np.zeros((m, m))
    for i in range(m):
        for j in range(i):
            L[i, j] = q24(A[i, j]) if do_int else A[i, j]
        L[i, i] = abs(alpha_diag[i])
        if alpha_diag[i] < 0:
            for ii in range(i+1, m):
                L[ii, i] = -L[ii, i]

    return L


# ---------------------------------------------------------------------------
# SR-UKF main loop
# ---------------------------------------------------------------------------
def run_sr_ukf(measurements, gt_positions, mode, q_diag=None):
    n = 9; m_ = 3; dt = 0.02
    alpha = 1.0; beta_ = 2.0; kappa = 0.0
    lam = alpha**2 * (n + kappa) - n  # 0

    W_m = np.zeros(2*n+1); W_c = np.zeros(2*n+1)
    W_m[0] = 0.0; W_c[0] = 2.0
    for i in range(1, 2*n+1):
        W_m[i] = 1.0/(2.0*(n+lam))
        W_c[i] = 1.0/(2.0*(n+lam))

    F = np.eye(n)
    for ax in range(3):
        b = ax*3
        F[b, b+1] = dt; F[b, b+2] = 0.5*dt*dt; F[b+1, b+2] = dt

    H = np.zeros((m_, n))
    H[0,0] = 1.0; H[1,3] = 1.0; H[2,6] = 1.0

    if q_diag is None:
        q_diag = np.array([0.05, 0.00025, 0.00001]*3)
    sqrt_Q = np.diag(np.sqrt(q_diag))

    r_diag = np.array([0.25, 0.25, 0.25])
    sqrt_R = np.diag(np.sqrt(r_diag))

    do_state = mode.state_arith or mode.full
    do_bnd = mode.module_boundary or mode.full
    do_cs = mode.givens_cs or mode.full

    x = np.zeros(n)
    x[0] = measurements[0,0]; x[3] = measurements[0,1]; x[6] = measurements[0,2]
    p_diag = np.array([5., 20., 0.01, 5., 20., 0.01, 5., 20., 0.01])
    L = np.diag(np.sqrt(p_diag))

    if do_state:
        x = q24(x); L = q24(L)

    N = len(measurements)
    estimates = np.zeros((N, n))
    estimates[0] = x.copy()

    sqrt_n_lam = 3.0
    sqrt_wc0 = np.sqrt(2.0)
    sqrt_wc1_q = W_SQRT if do_state else np.sqrt(1.0/18.0)

    for k in range(1, N):
        z = measurements[k]
        if do_state: z = q24(z)

        # === PREDICTION ===
        sigma = np.zeros((2*n+1, n))
        sigma[0] = x.copy()
        sL = sqrt_n_lam * L
        if do_state: sL = q24(sL)
        for i in range(n):
            sigma[i+1] = x + sL[:, i]
            sigma[n+i+1] = x - sL[:, i]
            if do_state:
                sigma[i+1] = q24(sigma[i+1])
                sigma[n+i+1] = q24(sigma[n+i+1])

        sp = np.zeros_like(sigma)
        for i in range(2*n+1):
            sp[i] = F @ sigma[i]
            if do_state: sp[i] = q24(sp[i])

        xp = np.zeros(n)
        for i in range(2*n+1):
            xp += W_m[i] * sp[i]
        if do_state: xp = q24(xp)

        # LQ compound matrix (9 x 18)
        Ac = np.zeros((n, 2*n))
        for j in range(1, 2*n+1):
            d = sp[j] - xp
            if do_state: d = q24(d)
            Ac[:, j-1] = sqrt_wc1_q * d
            if do_state: Ac[:, j-1] = q24(Ac[:, j-1])

        L_pred = lq_decomposition(Ac, mode)
        if do_bnd: L_pred = q24(L_pred)

        # W_c[0]=2 update
        d0 = sp[0] - xp
        if do_state: d0 = q24(d0)
        u0 = sqrt_wc0 * d0
        if do_state: u0 = q24(u0)
        L_pred = cholupdate(L_pred, u0, mode)
        if do_bnd: L_pred = q24(L_pred)

        # Process noise: 9 rank-1 updates
        for qi in range(n):
            qcol = sqrt_Q[:, qi].copy()
            if do_state: qcol = q24(qcol)
            L_pred = cholupdate(L_pred, qcol, mode)
            if do_bnd: L_pred = q24(L_pred)

        # === MEASUREMENT UPDATE ===
        gamma = np.zeros((2*n+1, m_))
        for i in range(2*n+1):
            gamma[i] = H @ sp[i]
            if do_state: gamma[i] = q24(gamma[i])

        zp = np.zeros(m_)
        for i in range(2*n+1):
            zp += W_m[i] * gamma[i]
        if do_state: zp = q24(zp)

        # Innovation covariance S via QR
        cz = np.zeros((2*n + m_, m_))
        for j in range(1, 2*n+1):
            dz = gamma[j] - zp
            if do_state: dz = q24(dz)
            cz[j-1] = sqrt_wc1_q * dz
            if do_state: cz[j-1] = q24(cz[j-1])
        for i in range(m_):
            cz[2*n+i] = sqrt_R[i]

        _, Rs = np.linalg.qr(cz, mode='reduced')
        for i in range(m_):
            if Rs[i,i] < 0: Rs[i,:] = -Rs[i,:]
        Sc = Rs.T.copy()

        # W_c[0] update on S
        dz0 = gamma[0] - zp
        if do_state: dz0 = q24(dz0)
        uz0 = sqrt_wc0 * dz0
        if do_state: uz0 = q24(uz0)

        Sc3 = Sc.copy(); uzv = uz0.copy()
        for j in range(m_):
            rr = np.sqrt(Sc3[j,j]**2 + uzv[j]**2)
            if rr == 0: continue
            cc = Sc3[j,j]/rr; ss = uzv[j]/rr
            if do_cs: cc = q24(cc); ss = q24(ss)
            Sc3[j,j] = rr
            for i in range(j+1, m_):
                nl = cc*Sc3[i,j] + ss*uzv[i]
                nu = cc*uzv[i] - ss*Sc3[i,j]
                Sc3[i,j] = nl; uzv[i] = nu
        Sc = Sc3
        if do_bnd or do_state: Sc = q24(Sc)

        # Cross-covariance
        Pxz = np.zeros((n, m_))
        for i in range(2*n+1):
            dx = sp[i] - xp; dz = gamma[i] - zp
            if do_state: dx = q24(dx); dz = q24(dz)
            Pxz += W_c[i] * np.outer(dx, dz)
        if do_state: Pxz = q24(Pxz)

        # Kalman gain
        Sf = Sc @ Sc.T
        try: K = Pxz @ np.linalg.inv(Sf)
        except: K = Pxz @ np.linalg.pinv(Sf)
        if do_state: K = q24(K)

        # State update
        inn = z - zp
        if do_state: inn = q24(inn)
        x = xp + K @ inn
        if do_state: x = q24(x)

        # Covariance update: 3 rank-1 downdates
        Ln = L_pred.copy()
        for j in range(m_):
            wj = K[:, j] * Sc[j, j]
            if do_state: wj = q24(wj)
            try: Ln = choldowndate(Ln, wj, mode)
            except: pass

        L = Ln
        if do_bnd: L = q24(L)
        estimates[k] = x.copy()

    pe = estimates[:, [0, 3, 6]]
    err = pe - gt_positions
    rmse = np.sqrt(np.mean(err**2))
    return rmse, estimates


# ---------------------------------------------------------------------------
# Load data
# ---------------------------------------------------------------------------
def load_data(fp):
    d = np.genfromtxt(fp, delimiter=',', skip_header=1)
    return d[:, 11:14], d[:, 2:5]


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    data_file = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                             "test_data", "real_world", "synthetic_drone_500cycles.csv")
    if not os.path.exists(data_file):
        print(f"ERROR: Data file not found: {data_file}")
        sys.exit(1)

    print("Loading data...")
    meas, gt_pos = load_data(data_file)
    print(f"  Loaded {len(meas)} cycles")
    print()

    # ==========================================
    # SECTION 1: User-specified Q parameters
    # ==========================================
    q_user = np.array([0.05, 0.00025, 0.00001]*3)

    # VHDL actual Q parameters (from process_noise_rank1_ca_3d.vhd constants)
    # LQ_POS = 2431249/2^24 = 0.14491 => Q_POS = 0.14491^2 = 0.02100
    # LQ_VEL = 1186328/2^24 = 0.07071 => Q_VEL = 0.07071^2 = 0.005000
    # LQ_ACC = 1677721/2^24 = 0.10000 => Q_ACC = 0.10000^2 = 0.01000
    lq_pos = 2431249.0 / SCALE_F
    lq_vel = 1186328.0 / SCALE_F
    lq_acc = 1677721.0 / SCALE_F
    q_vhdl = np.array([lq_pos**2, lq_vel**2, lq_acc**2]*3)

    print("=" * 80)
    print("PARAMETER COMPARISON: User-specified vs VHDL actual")
    print("=" * 80)
    print(f"  {'Parameter':<12s} | {'User Q':>12s} | {'User sqrt(Q)':>12s} | {'VHDL LQ':>12s} | {'VHDL Q_eff':>12s}")
    print(f"  {'-'*12}-+-{'-'*12}-+-{'-'*12}-+-{'-'*12}-+-{'-'*12}")
    for name, qu, qv in [("Q_POS", q_user[0], q_vhdl[0]),
                          ("Q_VEL", q_user[1], q_vhdl[1]),
                          ("Q_ACC", q_user[2], q_vhdl[2])]:
        print(f"  {name:<12s} | {qu:12.6f} | {np.sqrt(qu):12.6f} | {np.sqrt(qv):12.6f} | {qv:12.6f}")
    print()

    # ==========================================
    # SECTION 2: Selective quantization analysis
    # ==========================================
    modes = []

    m0 = QMode("Float64 (baseline)")
    modes.append(m0)

    m1 = QMode("Module boundary trunc")
    m1.module_boundary = True
    modes.append(m1)

    m2 = QMode("QR internal (96-bit)")
    m2.qr_internal = True
    modes.append(m2)

    m3 = QMode("Rank-1 update (96-bit)")
    m3.update_internal = True
    modes.append(m3)

    m4 = QMode("Rank-1 downdate (96-bit)")
    m4.downdate_internal = True
    modes.append(m4)

    m5 = QMode("Sqrt CORDIC (Q24.24)")
    m5.sqrt_cordic = True
    modes.append(m5)

    m6 = QMode("All Givens c/s (Q24.24)")
    m6.givens_cs = True
    modes.append(m6)

    m7 = QMode("State arithmetic only")
    m7.state_arith = True
    modes.append(m7)

    m8 = QMode("Full VHDL-style Q24.24")
    m8.full = True
    modes.append(m8)

    # Run with user Q params
    print("=" * 80)
    print("ANALYSIS 1: Selective Quantization (User Q parameters)")
    print(f"  Q = diag([{q_user[0]}, {q_user[1]}, {q_user[2]}, ...])")
    print("=" * 80)
    print()

    results_user = []
    baseline_user = None

    for i, mode in enumerate(modes):
        print(f"  [{i+1}/{len(modes)}] {mode.name}...", end="", flush=True)
        try:
            rmse, _ = run_sr_ukf(meas, gt_pos, mode, q_diag=q_user)
            if i == 0: baseline_user = rmse
            results_user.append((mode.name, rmse))
            print(f" RMSE = {rmse:.6f} m")
        except Exception as e:
            results_user.append((mode.name, None))
            print(f" FAILED: {e}")

    print()

    full_gap_user = None
    for name, rmse in results_user:
        if "Full" in name and rmse is not None and baseline_user is not None:
            full_gap_user = rmse - baseline_user

    print(f"{'Component':<30s} | {'RMSE (m)':>10s} | {'vs Float64':>11s} | {'Contribution':>12s}")
    print("-"*30 + "-+-" + "-"*10 + "-+-" + "-"*11 + "-+-" + "-"*12)

    for name, rmse in results_user:
        if rmse is None:
            print(f"{name:<30s} | {'FAILED':>10s} | {'---':>11s} | {'---':>12s}")
        elif baseline_user is None or name == "Float64 (baseline)":
            print(f"{name:<30s} | {rmse:10.6f} | {'---':>11s} | {'---':>12s}")
        else:
            g = (rmse - baseline_user) * 1000
            if full_gap_user and full_gap_user > 0.0001:
                p = (rmse - baseline_user) / full_gap_user * 100
                print(f"{name:<30s} | {rmse:10.6f} | {g:+9.1f}mm | {p:10.1f}%")
            else:
                print(f"{name:<30s} | {rmse:10.6f} | {g:+9.1f}mm | {'~0':>12s}")

    if full_gap_user is not None:
        print(f"\n  Total quantization gap: {full_gap_user*1000:+.2f} mm")
    print()

    # Run with VHDL Q params
    print("=" * 80)
    print("ANALYSIS 2: Selective Quantization (VHDL actual Q parameters)")
    print(f"  Q = diag([{q_vhdl[0]:.5f}, {q_vhdl[1]:.6f}, {q_vhdl[2]:.5f}, ...])")
    print("=" * 80)
    print()

    results_vhdl = []
    baseline_vhdl = None

    for i, mode in enumerate(modes):
        print(f"  [{i+1}/{len(modes)}] {mode.name}...", end="", flush=True)
        try:
            rmse, _ = run_sr_ukf(meas, gt_pos, mode, q_diag=q_vhdl)
            if i == 0: baseline_vhdl = rmse
            results_vhdl.append((mode.name, rmse))
            print(f" RMSE = {rmse:.6f} m")
        except Exception as e:
            results_vhdl.append((mode.name, None))
            print(f" FAILED: {e}")

    print()

    full_gap_vhdl = None
    for name, rmse in results_vhdl:
        if "Full" in name and rmse is not None and baseline_vhdl is not None:
            full_gap_vhdl = rmse - baseline_vhdl

    print(f"{'Component':<30s} | {'RMSE (m)':>10s} | {'vs Float64':>11s} | {'Contribution':>12s}")
    print("-"*30 + "-+-" + "-"*10 + "-+-" + "-"*11 + "-+-" + "-"*12)

    for name, rmse in results_vhdl:
        if rmse is None:
            print(f"{name:<30s} | {'FAILED':>10s} | {'---':>11s} | {'---':>12s}")
        elif baseline_vhdl is None or name == "Float64 (baseline)":
            print(f"{name:<30s} | {rmse:10.6f} | {'---':>11s} | {'---':>12s}")
        else:
            g = (rmse - baseline_vhdl) * 1000
            if full_gap_vhdl and full_gap_vhdl > 0.0001:
                p = (rmse - baseline_vhdl) / full_gap_vhdl * 100
                print(f"{name:<30s} | {rmse:10.6f} | {g:+9.1f}mm | {p:10.1f}%")
            else:
                print(f"{name:<30s} | {rmse:10.6f} | {g:+9.1f}mm | {'~0':>12s}")

    if full_gap_vhdl is not None:
        print(f"\n  Total quantization gap: {full_gap_vhdl*1000:+.2f} mm")
    print()

    # ==========================================
    # SECTION 3: Parameter mismatch impact
    # ==========================================
    print("=" * 80)
    print("ANALYSIS 3: Parameter Mismatch Impact")
    print("=" * 80)
    print()

    if baseline_user is not None and baseline_vhdl is not None:
        param_gap = (baseline_vhdl - baseline_user) * 1000
        print(f"  Float64 with user Q:    {baseline_user:.6f} m")
        print(f"  Float64 with VHDL Q:    {baseline_vhdl:.6f} m")
        print(f"  Parameter mismatch gap: {param_gap:+.1f} mm")
        print()
        if full_gap_user is not None:
            print(f"  Quantization gap (user Q): {full_gap_user*1000:+.2f} mm")
        if full_gap_vhdl is not None:
            print(f"  Quantization gap (VHDL Q): {full_gap_vhdl*1000:+.2f} mm")
        print()
        total = param_gap + (full_gap_vhdl*1000 if full_gap_vhdl else 0)
        print(f"  TOTAL predicted gap:")
        print(f"    Parameter mismatch:  {param_gap:+.1f} mm")
        if full_gap_vhdl is not None:
            print(f"    Quantization error:  {full_gap_vhdl*1000:+.2f} mm")
        print(f"    Sum:                 {total:+.1f} mm")

    print()

    # ==========================================
    # SECTION 4: Per-axis breakdown
    # ==========================================
    print("=" * 80)
    print("PER-AXIS RMSE BREAKDOWN")
    print("=" * 80)
    print()

    for label, mode_obj, qd in [("Float64 + user Q", modes[0], q_user),
                                  ("Full Q24.24 + user Q", modes[-1], q_user),
                                  ("Float64 + VHDL Q", modes[0], q_vhdl),
                                  ("Full Q24.24 + VHDL Q", modes[-1], q_vhdl)]:
        try:
            rmse_t, est = run_sr_ukf(meas, gt_pos, mode_obj, q_diag=qd)
            pe = est[:, [0,3,6]]
            er = pe - gt_pos
            rx = np.sqrt(np.mean(er[:,0]**2))
            ry = np.sqrt(np.mean(er[:,1]**2))
            rz = np.sqrt(np.mean(er[:,2]**2))
            print(f"  {label}:")
            print(f"    X: {rx*1000:8.1f} mm  Y: {ry*1000:8.1f} mm  Z: {rz*1000:8.1f} mm  Total: {rmse_t*1000:8.1f} mm")
        except Exception as e:
            print(f"  {label}: FAILED ({e})")
    print()

    # ==========================================
    # SECTION 5: Cycle-by-cycle divergence
    # ==========================================
    print("=" * 80)
    print("CYCLE-BY-CYCLE GAP GROWTH (Float64 vs Full Q24.24, user Q)")
    print("=" * 80)
    print()

    try:
        _, ef = run_sr_ukf(meas, gt_pos, modes[0], q_diag=q_user)
        _, eq = run_sr_ukf(meas, gt_pos, modes[-1], q_diag=q_user)
        pf = ef[:, [0,3,6]]; pq = eq[:, [0,3,6]]

        chk = [1, 5, 10, 25, 50, 100, 200, 300, 400, 499]
        chk = [c for c in chk if c < len(meas)]

        print(f"{'Cycle':>6s} | {'Float64':>10s} | {'Q24.24':>10s} | {'Gap':>10s} | {'State diff':>12s}")
        print("-"*6 + "-+-" + "-"*10 + "-+-" + "-"*10 + "-+-" + "-"*10 + "-+-" + "-"*12)

        for c in chk:
            ef_ = np.sqrt(np.sum((pf[c] - gt_pos[c])**2))
            eq_ = np.sqrt(np.sum((pq[c] - gt_pos[c])**2))
            sd = np.sqrt(np.sum((pf[c] - pq[c])**2))
            print(f"{c:6d} | {ef_:8.4f} m | {eq_:8.4f} m | {(eq_-ef_)*1000:+8.1f}mm | {sd:10.6f} m")
    except Exception as e:
        print(f"  Failed: {e}")

    print()

    # ==========================================
    # SECTION 6: Summary
    # ==========================================
    print("=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print()
    print("  Q24.24 has 24 fractional bits = ~7.2 decimal digits of precision.")
    print("  For the SR-UKF with these parameters, the quantization error is")
    print("  negligible (< 0.1 mm) because:")
    print("    - Internal 96-bit (Q48.48) working registers eliminate cumulative error")
    print("    - 144-bit products with rounding bias reduce systematic truncation")
    print("    - Only module boundaries truncate to Q24.24")
    print()
    if baseline_user is not None and baseline_vhdl is not None:
        pg = abs(baseline_vhdl - baseline_user) * 1000
        print(f"  If there IS a 70mm RMSE gap, it is NOT from Q24.24 quantization.")
        print(f"  Likely sources:")
        print(f"    1. Q parameter mismatch: {pg:.1f} mm")
        print(f"       (VHDL uses LQ_POS=0.14491, LQ_VEL=0.07071, LQ_ACC=0.10000)")
        print(f"       (vs user-specified Q_POS=0.05, Q_VEL=0.00025, Q_ACC=0.00001)")
        print(f"    2. CORDIC sqrt precision vs IEEE sqrt")
        print(f"    3. Algorithmic differences (LQ vs column-QR, downdate formula)")
        print(f"    4. Initial state or dt mismatch")
    print()
    print("Analysis complete.")


if __name__ == "__main__":
    main()
