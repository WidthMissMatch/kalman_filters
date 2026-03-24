#!/usr/bin/env python3
"""
Generate training data for 10-class trajectory classifier.
Classes: 0=Drone, 1=Missile, 2=Car, 3=F1, 4=Cat/Animal, 5=Bird,
         6=Airplane, 7=Ball/Projectile, 8=Artillery, 9=Pedestrian

Reuses existing UKF output CSVs where available, generates synthetic data
for missing classes (missile, cat, bird).

Output: data/training_data.csv
Columns: px,py,pz,vx,vy,vz,ax,ay,az,label
"""

import numpy as np
import pandas as pd
import os

RANDOM_SEED = 42
rng = np.random.default_rng(RANDOM_SEED)

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # random_forest/
SINGERS = "/home/arunupscee/Desktop/xtortion/singers_model/scripts"
DATA_OUT = os.path.join(BASE, "data", "training_data.csv")

Q = 24          # Q24.24 fractional bits
MAX_VAL = (1 << 47) - 1   # signed 48-bit max


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def load_singer_csv(path):
    """Load a singer-model UKF output CSV. Returns DataFrame with 9 state cols."""
    df = pd.read_csv(path)
    rename = {
        "est_x_pos": "px", "est_x_vel": "vx", "est_x_acc": "ax",
        "est_y_pos": "py", "est_y_vel": "vy", "est_y_acc": "ay",
        "est_z_pos": "pz", "est_z_vel": "vz", "est_z_acc": "az",
    }
    df = df.rename(columns=rename)
    cols = ["px", "py", "pz", "vx", "vy", "vz", "ax", "ay", "az"]
    return df[cols].copy()


def clip_q2424(v):
    """Clip float to Q24.24 representable range (±2^23)."""
    limit = 2**23
    return np.clip(v, -limit, limit)


# ---------------------------------------------------------------------------
# Class 0: Drone — load from singer synthetic_drone_500cycles
# ---------------------------------------------------------------------------
def load_drone_data():
    path = os.path.join(SINGERS, "singer_python_synthetic_drone_500cycles.csv")
    if not os.path.exists(path):
        path = os.path.join(SINGERS, "singer_python_drone_dt02.csv")
    df = load_singer_csv(path)
    df["label"] = 0
    print(f"  [Drone]  {len(df)} samples from {os.path.basename(path)}")
    return df


# ---------------------------------------------------------------------------
# Class 3: F1 — load from singer monaco + silverstone
# ---------------------------------------------------------------------------
def load_f1_data():
    frames = []
    for fname in ["ca_python_monaco_750cycles_highspeed.csv",
                  "ca_python_silverstone_750cycles_highspeed.csv"]:
        path = os.path.join(SINGERS, fname)
        if os.path.exists(path):
            frames.append(load_singer_csv(path))
            print(f"  [F1]     loaded {fname}")
    if not frames:
        raise FileNotFoundError("No F1 CSV found in singers scripts/")
    df = pd.concat(frames, ignore_index=True)
    df["label"] = 3
    print(f"  [F1]     {len(df)} total samples")
    return df


# ---------------------------------------------------------------------------
# Class 2: Car — generate synthetic (ground-level, moderate speed)
# ---------------------------------------------------------------------------
def generate_car_data(n_trajectories=20, steps=300):
    """
    Car: ground level (pz~0), speed 5-30 m/s, gradual turns.
    dt = 0.02s (50 Hz). Constant velocity segments with slight acceleration.
    """
    rows = []
    for _ in range(n_trajectories):
        speed = rng.uniform(5.0, 30.0)
        heading = rng.uniform(0, 2 * np.pi)
        px, py, pz = rng.uniform(-500, 500), rng.uniform(-500, 500), 0.0
        vx = speed * np.cos(heading)
        vy = speed * np.sin(heading)
        vz = 0.0
        ax, ay, az = 0.0, 0.0, 0.0

        dt = 0.02
        for t in range(steps):
            # Occasional mild acceleration / turn
            if t % 30 == 0:
                ax = rng.uniform(-3.0, 3.0)
                ay = rng.uniform(-3.0, 3.0)
            # Drag
            ax -= 0.1 * vx
            ay -= 0.1 * vy
            vx += ax * dt
            vy += ay * dt
            # Ground constraint
            vz = 0.0
            az = 0.0
            pz = 0.0
            px += vx * dt
            py += vy * dt
            rows.append([px, py, pz, vx, vy, vz, ax, ay, az, 2])

    df = pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])
    print(f"  [Car]    {len(df)} samples generated")
    return df


# ---------------------------------------------------------------------------
# Class 1: Missile — ballistic arc, high speed, high altitude
# ---------------------------------------------------------------------------
def generate_missile_data(n_trajectories=15, steps=400):
    """
    Missile: ballistic trajectory.
    Launch at angle 30-60 deg, speed 200-800 m/s, apogee 1000-30000m.
    """
    rows = []
    g = 9.81
    for _ in range(n_trajectories):
        speed = rng.uniform(200.0, 800.0)
        elevation = rng.uniform(np.radians(25), np.radians(65))
        azimuth = rng.uniform(0, 2 * np.pi)

        vx = speed * np.cos(elevation) * np.cos(azimuth)
        vy = speed * np.cos(elevation) * np.sin(azimuth)
        vz = speed * np.sin(elevation)
        px, py, pz = 0.0, 0.0, 0.0
        dt = 0.05  # 20 Hz (coarser for long-range)

        for t in range(steps):
            ax = rng.uniform(-2.0, 2.0)   # small lateral perturbation
            ay = rng.uniform(-2.0, 2.0)
            az = -g + rng.uniform(-0.5, 0.5)   # gravity dominant

            vx += ax * dt
            vy += ay * dt
            vz += az * dt
            px += vx * dt
            py += vy * dt
            pz += vz * dt

            if pz < 0:
                pz = 0.0
                vz = abs(vz) * 0.1  # impact

            rows.append([px, py, pz, vx, vy, vz, ax, ay, az, 1])

    df = pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])
    print(f"  [Missile] {len(df)} samples generated")
    return df


# ---------------------------------------------------------------------------
# Class 4: Cat/Animal — slow, ground level, erratic
# ---------------------------------------------------------------------------
def generate_cat_data(n_trajectories=40, steps=200):
    """
    Cat: 0-5 m/s, z~0, frequent abrupt direction changes.
    """
    rows = []
    for _ in range(n_trajectories):
        px, py, pz = rng.uniform(-50, 50), rng.uniform(-50, 50), 0.0
        vx, vy, vz = 0.0, 0.0, 0.0
        ax, ay, az = 0.0, 0.0, 0.0
        dt = 0.02

        for t in range(steps):
            # Frequent random direction changes every 5-15 steps
            if t % rng.integers(5, 15) == 0:
                angle = rng.uniform(0, 2 * np.pi)
                speed = rng.uniform(0.0, 3.0)
                ax = speed * np.cos(angle) / dt - vx / dt
                ay = speed * np.sin(angle) / dt - vy / dt
                ax = np.clip(ax, -8.0, 8.0)
                ay = np.clip(ay, -8.0, 8.0)

            vx += ax * dt
            vy += ay * dt
            vz = 0.0
            az = 0.0
            pz = 0.0
            px += vx * dt
            py += vy * dt
            rows.append([px, py, pz, vx, vy, vz, ax, ay, az, 4])

    df = pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])
    print(f"  [Cat]    {len(df)} samples generated")
    return df


# ---------------------------------------------------------------------------
# Class 5: Bird — slow-moderate, low altitude, periodic vertical oscillation
# ---------------------------------------------------------------------------
def generate_bird_data(n_trajectories=30, steps=300):
    """
    Bird: 5-25 m/s, altitude 2-200m, periodic vertical flapping oscillation.
    """
    rows = []
    for _ in range(n_trajectories):
        speed = rng.uniform(5.0, 25.0)
        heading = rng.uniform(0, 2 * np.pi)
        alt_base = rng.uniform(2.0, 200.0)
        flap_freq = rng.uniform(0.5, 3.0)   # Hz
        flap_amp  = rng.uniform(0.3, 3.0)   # meters amplitude

        px = rng.uniform(-300, 300)
        py = rng.uniform(-300, 300)
        pz = alt_base
        vx = speed * np.cos(heading)
        vy = speed * np.sin(heading)
        vz = 0.0
        dt = 0.02

        for t in range(steps):
            time = t * dt
            # Gentle horizontal drift
            if t % 40 == 0:
                heading += rng.uniform(-0.5, 0.5)
                speed = rng.uniform(5.0, 25.0)
                vx = speed * np.cos(heading)
                vy = speed * np.sin(heading)

            ax = rng.uniform(-0.5, 0.5)
            ay = rng.uniform(-0.5, 0.5)
            # Vertical flapping: sinusoidal oscillation
            az = -flap_amp * (2 * np.pi * flap_freq)**2 * np.sin(2 * np.pi * flap_freq * time)
            az = np.clip(az, -20.0, 20.0)

            vz += az * dt
            pz += vz * dt
            if pz < 0.5:
                pz = 0.5
                vz = abs(vz) * 0.5
            vx += ax * dt
            vy += ay * dt
            px += vx * dt
            py += vy * dt

            rows.append([px, py, pz, vx, vy, vz, ax, ay, az, 5])

    df = pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])
    print(f"  [Bird]   {len(df)} samples generated")
    return df


# ---------------------------------------------------------------------------
# Feature extraction (mirrors VHDL rf_feature_extract)
# ---------------------------------------------------------------------------
def extract_features(df):
    """
    Compute 8 derived features from 9 state inputs.
    All values kept as float (Python training).
    """
    px = df["px"].values
    py = df["py"].values
    pz = df["pz"].values
    vx = df["vx"].values
    vy = df["vy"].values
    vz = df["vz"].values
    ax = df["ax"].values
    ay = df["ay"].values
    az = df["az"].values

    speed_sq       = vx**2 + vy**2 + vz**2
    horiz_accel_sq = ax**2 + ay**2
    feat = pd.DataFrame({
        "speed_sq":           speed_sq,                              # f0
        "altitude":           pz,                                    # f1
        "horiz_speed_sq":     vx**2 + vy**2,                        # f2
        "vert_speed_abs":     np.abs(vz),                            # f3
        "accel_mag_sq":       ax**2 + ay**2 + az**2,                # f4
        "horiz_accel_sq":     horiz_accel_sq,                        # f5
        "climb_rate_sign":    np.sign(vz) * vz**2,                   # f6
        "altitude_abs":       np.abs(pz),                            # f7
        "horiz_accel_ratio":  horiz_accel_sq / (speed_sq + 1.0),    # f8 — new
        "label":              df["label"].values,
    })
    return feat


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def generate_drone_augmented(n_trajectories=110, steps=50):
    """
    Synthetic drone trajectories covering the full operational envelope:
    - Hovering at 5-100m altitude
    - Lateral flight (0-15 m/s horizontal)
    - Ascending/descending (0-3 m/s vertical)
    - Inspection patterns (slow, precise)
    - Delivery approach (moderate speed + controlled descent)
    """
    rows = []
    rng_d = np.random.default_rng(77)
    dt = 0.02

    behaviors = ["hover", "lateral", "ascend", "descend", "patrol", "delivery"]
    for traj in range(n_trajectories):
        beh = behaviors[traj % len(behaviors)]
        alt = rng_d.uniform(5.0, 100.0)
        px = rng_d.uniform(-500, 500)
        py = rng_d.uniform(-500, 500)
        pz = alt
        vx, vy, vz = 0.0, 0.0, 0.0
        ax, ay, az = 0.0, 0.0, 0.0

        for t in range(steps):
            if beh == "hover":
                # Near-stationary with wind disturbance
                ax = rng_d.uniform(-0.5, 0.5)
                ay = rng_d.uniform(-0.5, 0.5)
                az = rng_d.uniform(-0.3, 0.3)
            elif beh == "lateral":
                speed_h = rng_d.uniform(2.0, 15.0)
                heading = rng_d.uniform(0, 2 * np.pi)
                ax = speed_h * np.cos(heading) * 0.1
                ay = speed_h * np.sin(heading) * 0.1
                az = rng_d.uniform(-0.2, 0.2)
            elif beh == "ascend":
                az = rng_d.uniform(0.5, 3.0)
                ax = rng_d.uniform(-1.0, 1.0)
                ay = rng_d.uniform(-1.0, 1.0)
            elif beh == "descend":
                az = rng_d.uniform(-3.0, -0.3)
                ax = rng_d.uniform(-1.0, 1.0)
                ay = rng_d.uniform(-1.0, 1.0)
            elif beh == "patrol":
                # Back-and-forth scanning
                if t % 20 < 10:
                    ax = 1.0
                else:
                    ax = -1.0
                ay = rng_d.uniform(-0.3, 0.3)
                az = rng_d.uniform(-0.1, 0.1)
            else:  # delivery
                speed_h = rng_d.uniform(3.0, 10.0)
                heading = rng_d.uniform(0, 2 * np.pi)
                ax = speed_h * np.cos(heading) * 0.05
                ay = speed_h * np.sin(heading) * 0.05
                az = rng_d.uniform(-1.5, 0.1)  # mostly descending

            vx += ax * dt
            vy += ay * dt
            vz += az * dt
            # Speed limits
            vx = np.clip(vx, -15.0, 15.0)
            vy = np.clip(vy, -15.0, 15.0)
            vz = np.clip(vz, -5.0, 5.0)
            px += vx * dt
            py += vy * dt
            pz += vz * dt
            pz = max(0.5, pz)
            rows.append([px, py, pz, vx, vy, vz, ax, ay, az, 0])

    df = pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])
    print(f"  [Drone+] {len(df)} augmented samples")
    return df


# ---------------------------------------------------------------------------
# Class 3: F1 augmentation — circuit racing dynamics
# ---------------------------------------------------------------------------
def generate_f1_augmented(n_trajectories=90, steps=50):
    """
    Synthetic F1 trajectories:
    - Ground level (pz~0)
    - High speed 30-90 m/s (108-324 km/h)
    - High lateral acceleration (cornering 20-50 m/s²)
    - Braking/acceleration events
    """
    rows = []
    rng_f = np.random.default_rng(88)
    dt = 0.02

    for traj in range(n_trajectories):
        speed = rng_f.uniform(30.0, 90.0)
        heading = rng_f.uniform(0, 2 * np.pi)
        vx = speed * np.cos(heading)
        vy = speed * np.sin(heading)
        vz = 0.0
        px = rng_f.uniform(-2000, 2000)
        py = rng_f.uniform(-2000, 2000)
        pz = 0.0
        ax, ay, az = 0.0, 0.0, 0.0

        for t in range(steps):
            event = t % 30
            if event < 10:
                # Straight: mild acceleration/braking
                ax = np.cos(heading) * rng_f.uniform(-5.0, 8.0)
                ay = np.sin(heading) * rng_f.uniform(-5.0, 8.0)
            elif event < 25:
                # Corner: high lateral acceleration
                lateral_g = rng_f.uniform(15.0, 50.0)
                turn_dir = 1.0 if traj % 2 == 0 else -1.0
                ax = -np.sin(heading) * lateral_g * turn_dir + np.cos(heading) * rng_f.uniform(-3.0, 3.0)
                ay =  np.cos(heading) * lateral_g * turn_dir + np.sin(heading) * rng_f.uniform(-3.0, 3.0)
                heading += turn_dir * 0.15   # gradual turn
            else:
                # Braking zone
                ax = np.cos(heading) * rng_f.uniform(-30.0, -5.0)
                ay = np.sin(heading) * rng_f.uniform(-30.0, -5.0)

            az = 0.0
            vx += ax * dt
            vy += ay * dt
            vz = 0.0
            pz = 0.0
            px += vx * dt
            py += vy * dt
            rows.append([px, py, pz, vx, vy, vz, ax, ay, az, 3])

    df = pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])
    print(f"  [F1+]   {len(df)} augmented samples")
    return df
# ---------------------------------------------------------------------------
# Class 6: Airplane — commercial cruise, extreme altitude, near-zero accel
# ---------------------------------------------------------------------------
def generate_airplane_data(n_trajectories=120, steps=50):
    """
    Commercial airplane cruise at 9000-12000m, 200-260 m/s.
    Physics: near-zero accel (cruise), gentle banking during turns.
    Angular change: slow heading drift (0.01-0.05 rad/s) during bank segments.
    Key separators vs Missile: horiz_accel_sq≈0 (no guidance), stable altitude.
    """
    rows = []
    rng_a = np.random.default_rng(300)

    for traj in range(n_trajectories):
        spd = rng_a.uniform(200.0, 260.0)
        hd  = rng_a.uniform(0, 2 * np.pi)
        alt = rng_a.uniform(9000.0, 12000.0)
        pz  = alt
        px  = rng_a.uniform(-50000, 50000)
        py  = rng_a.uniform(-50000, 50000)
        dt  = 0.02

        for t in range(steps):
            event = t % 10
            if event < 7:
                # Straight cruise — atmospheric turbulence only
                ax = rng_a.uniform(-0.15, 0.15)
                ay = rng_a.uniform(-0.15, 0.15)
                az = rng_a.uniform(-0.05, 0.05)
            else:
                # Gentle coordinated banking turn (max 0.3g lateral)
                bank_g = rng_a.uniform(0.05, 0.30)
                hd_rate = rng_a.uniform(0.01, 0.05) * (1 if traj % 2 == 0 else -1)
                ax = -np.sin(hd) * bank_g * 9.81 + rng_a.uniform(-0.1, 0.1)
                ay =  np.cos(hd) * bank_g * 9.81 + rng_a.uniform(-0.1, 0.1)
                az = rng_a.uniform(-0.1, 0.1)
                hd += hd_rate * dt

            vx = spd * np.cos(hd) + rng_a.uniform(-1.0, 1.0)
            vy = spd * np.sin(hd) + rng_a.uniform(-1.0, 1.0)
            vz = rng_a.uniform(-1.0, 1.0)   # nearly zero vertical velocity at cruise
            pz += vz * dt
            pz = np.clip(pz, 8000.0, 13000.0)
            px += vx * dt
            py += vy * dt
            rows.append([px, py, pz, vx, vy, vz, ax, ay, az, 6])

    df = pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])
    print(f"  [Airplane]   {len(df)} samples generated")
    return df


# ---------------------------------------------------------------------------
# Class 7: Ball/Projectile — short arc, gravity-dominated, low speed
# ---------------------------------------------------------------------------
def generate_ball_data(n_trajectories=24, steps=250):
    """
    Thrown/kicked ball: 5-40 m/s, altitude 0-80m, pure ballistic.
    Physics: az≈-9.81 (gravity), horiz_accel≈0 (no thrust), parabolic arc.
    Key separators vs Artillery: speed_sq much lower (25-1600 vs 90k-810k).
    vs Missile: horiz_accel_sq≈0, low speed.
    """
    rows = []
    rng_b = np.random.default_rng(301)

    # Load real projectile CSV if available
    proj_path = os.path.join(BASE, "..", "ca_ukf", "test_data", "realistic", "projectile.csv")
    proj_path = os.path.normpath(proj_path)
    if os.path.exists(proj_path):
        df_real = pd.read_csv(proj_path)
        dt_r = float(df_real["time"].iloc[1] - df_real["time"].iloc[0]) if len(df_real) > 1 else 0.02
        for i in range(1, len(df_real) - 1):
            vx = (df_real["x"].iloc[i+1] - df_real["x"].iloc[i-1]) / (2 * dt_r)
            vy = (df_real["y"].iloc[i+1] - df_real["y"].iloc[i-1]) / (2 * dt_r)
            vz = (df_real["z"].iloc[i+1] - df_real["z"].iloc[i-1]) / (2 * dt_r)
            ax = (df_real["x"].iloc[i+1] - 2*df_real["x"].iloc[i] + df_real["x"].iloc[i-1]) / (dt_r**2)
            ay = (df_real["y"].iloc[i+1] - 2*df_real["y"].iloc[i] + df_real["y"].iloc[i-1]) / (dt_r**2)
            az = (df_real["z"].iloc[i+1] - 2*df_real["z"].iloc[i] + df_real["z"].iloc[i-1]) / (dt_r**2)
            pz = max(0.0, df_real["z"].iloc[i])
            rows.append([df_real["x"].iloc[i], df_real["y"].iloc[i], pz,
                         vx, vy, vz, ax, ay, az, 7])
        print(f"  [Ball]   loaded {len(df_real)-2} real projectile samples from {proj_path}")

    # Synthetic ballistic arcs
    g = 9.81
    for traj in range(n_trajectories):
        spd     = rng_b.uniform(5.0, 40.0)
        elev    = rng_b.uniform(np.radians(20), np.radians(80))
        azimuth = rng_b.uniform(0, 2 * np.pi)
        dt = 0.02

        vx0 = spd * np.cos(elev) * np.cos(azimuth)
        vy0 = spd * np.cos(elev) * np.sin(azimuth)
        vz0 = spd * np.sin(elev)
        px = rng_b.uniform(-200, 200)
        py = rng_b.uniform(-200, 200)
        pz = rng_b.uniform(0.5, 5.0)   # thrown from near ground

        for t in range(steps):
            ax = rng_b.uniform(-0.2, 0.2)   # tiny air drag — near-zero horiz
            ay = rng_b.uniform(-0.2, 0.2)
            az = -g + rng_b.uniform(-0.3, 0.3)
            vx0 += ax * dt
            vy0 += ay * dt
            vz0 += az * dt
            px += vx0 * dt
            py += vy0 * dt
            pz += vz0 * dt
            if pz <= 0.0:
                pz = 0.0
                vz0 = 0.0   # ball lands
            rows.append([px, py, pz, vx0, vy0, vz0, ax, ay, az, 7])

    df = pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])
    print(f"  [Ball]   {len(df)} total samples")
    return df


# ---------------------------------------------------------------------------
# Class 8: Artillery — pure ballistic, very high speed, NO guidance
# ---------------------------------------------------------------------------
def generate_artillery_data(n_trajectories=15, steps=400):
    """
    Artillery shell: 300-900 m/s, pure ballistic trajectory.
    Physics: horiz_accel≈0 (no guidance angular corrections),
             speed_sq 90k-810k (much higher than Ball/Missile),
             az≈-9.81 (gravity only, no thrust).
    Angular change: ZERO after launch (fixed ballistic trajectory).
    Key separator vs Missile (class 1): horiz_accel_sq≈0 vs missile>0.
    Key separator vs Ball: speed_sq >> 90000 vs ball < 1600.
    """
    rows = []
    rng_art = np.random.default_rng(302)
    g = 9.81

    for traj in range(n_trajectories):
        spd     = rng_art.uniform(300.0, 900.0)
        elev    = rng_art.uniform(np.radians(30), np.radians(70))
        azimuth = rng_art.uniform(0, 2 * np.pi)
        dt = 0.05   # coarser time step for long-range

        vx = spd * np.cos(elev) * np.cos(azimuth)
        vy = spd * np.cos(elev) * np.sin(azimuth)
        vz = spd * np.sin(elev)
        px, py, pz = 0.0, 0.0, 0.0

        for t in range(steps):
            # Pure ballistic: NO horizontal guidance, only gravity
            ax = rng_art.uniform(-0.5, 0.5)   # tiny air resistance, near-zero
            ay = rng_art.uniform(-0.5, 0.5)
            az = -g + rng_art.uniform(-0.2, 0.2)
            vx += ax * dt
            vy += ay * dt
            vz += az * dt
            px += vx * dt
            py += vy * dt
            pz += vz * dt
            if pz < 0.0:
                pz = 0.0
                vz = 0.0
            rows.append([px, py, pz, vx, vy, vz, ax, ay, az, 8])

    df = pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])
    print(f"  [Artillery]  {len(df)} samples generated")
    return df


# ---------------------------------------------------------------------------
# Class 9: Pedestrian/Human — bipedal gait, low speed, ground level
# ---------------------------------------------------------------------------
def generate_pedestrian_data(n_trajectories=30, steps=200):
    """
    Human pedestrian: 0.5-8 m/s, pz=0, periodic bipedal gait.
    Physics: gait frequency 1-2.5 Hz induces periodic lateral sway;
             low peak accel (<3 m/s²) — distinguishes from Cat (up to 8 m/s²);
             sustained heading (no erratic direction changes like Cat).
    Angular change: slow heading turns (0.05-0.3 rad/s) with stride periodicity.
    Key separators vs Cat: lower horiz_accel_sq, more sustained direction.
    """
    rows = []
    rng_p = np.random.default_rng(303)

    # Load real pedestrian CSV if available
    ped_path = os.path.join(BASE, "..", "ca_ukf", "test_data", "realistic", "pedestrian_walk.csv")
    ped_path = os.path.normpath(ped_path)
    if os.path.exists(ped_path):
        df_real = pd.read_csv(ped_path)
        dt_r = float(df_real["time"].iloc[1] - df_real["time"].iloc[0]) if len(df_real) > 1 else 0.02
        for i in range(1, len(df_real) - 1):
            vx = (df_real["x"].iloc[i+1] - df_real["x"].iloc[i-1]) / (2 * dt_r)
            vy = (df_real["y"].iloc[i+1] - df_real["y"].iloc[i-1]) / (2 * dt_r)
            ax = (df_real["x"].iloc[i+1] - 2*df_real["x"].iloc[i] + df_real["x"].iloc[i-1]) / (dt_r**2)
            ay = (df_real["y"].iloc[i+1] - 2*df_real["y"].iloc[i] + df_real["y"].iloc[i-1]) / (dt_r**2)
            rows.append([df_real["x"].iloc[i], df_real["y"].iloc[i], 0.0,
                         vx, vy, 0.0, ax, ay, 0.0, 9])
        print(f"  [Pedestrian] loaded {len(df_real)-2} real samples from {ped_path}")

    dt = 0.02
    for traj in range(n_trajectories):
        spd       = rng_p.uniform(0.5, 8.0)
        hd        = rng_p.uniform(0, 2 * np.pi)
        gait_freq = rng_p.uniform(1.0, 2.5)     # Hz — human stride cadence
        gait_amp  = rng_p.uniform(0.03, 0.12)   # lateral sway amplitude (m)
        hd_rate   = rng_p.uniform(-0.3, 0.3)    # slow directional drift (rad/s)
        px = rng_p.uniform(-500, 500)
        py = rng_p.uniform(-500, 500)

        for t in range(steps):
            time_s = t * dt
            # Forward speed modulation by stride bounce (±5%)
            spd_mod = spd * (1.0 + 0.05 * np.sin(2 * np.pi * gait_freq * time_s))
            # Lateral sway (perpendicular to heading) from bipedal gait
            sway_v  = gait_amp * 2 * np.pi * gait_freq * np.cos(2 * np.pi * gait_freq * time_s)
            sway_a  = -gait_amp * (2 * np.pi * gait_freq)**2 * np.sin(2 * np.pi * gait_freq * time_s)
            # Build velocity: forward + sway
            vx = spd_mod * np.cos(hd) - np.sin(hd) * sway_v
            vy = spd_mod * np.sin(hd) + np.cos(hd) * sway_v
            vz = 0.0
            # Acceleration: gentle + gait-induced sway accel
            ax_base = rng_p.uniform(-1.5, 1.5)
            ay_base = rng_p.uniform(-1.5, 1.5)
            ax = np.clip(ax_base - np.sin(hd) * sway_a, -3.0, 3.0)
            ay = np.clip(ay_base + np.cos(hd) * sway_a, -3.0, 3.0)
            # Slow heading change
            hd += hd_rate * dt
            px += vx * dt
            py += vy * dt
            rows.append([px, py, 0.0, vx, vy, vz, ax, ay, 0.0, 9])

    df = pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])
    print(f"  [Pedestrian] {len(df)} total samples")
    return df


def main():
    print("=== Generating training data ===")
    frames = []

    # Load real + synthetic data
    try:
        frames.append(load_drone_data())
    except Exception as e:
        print(f"  [Drone]  WARNING: {e}, generating synthetic")
        frames.append(generate_synthetic_drone())

    try:
        frames.append(load_f1_data())
    except Exception as e:
        print(f"  [F1]     WARNING: {e}")

    frames.append(generate_drone_augmented())    # +5500 varied drone trajectories
    frames.append(generate_car_data())
    frames.append(generate_missile_data())
    frames.append(generate_cat_data(n_trajectories=30, steps=200))  # Cat: cap at ~6000
    frames.append(generate_bird_data(n_trajectories=20, steps=300)) # Bird: cap at ~6000
    frames.append(generate_f1_augmented())          # +4500 synthetic F1

    # New classes 6-9
    frames.append(generate_airplane_data())
    frames.append(generate_ball_data())
    frames.append(generate_artillery_data())
    frames.append(generate_pedestrian_data())

    # Combine raw states
    raw = pd.concat(frames, ignore_index=True)
    print(f"\nRaw data: {len(raw)} samples across {raw['label'].nunique()} classes")
    print(raw["label"].value_counts().sort_index().to_string())

    # Extract features
    feat_df = extract_features(raw)

    # Save
    os.makedirs(os.path.join(BASE, "data"), exist_ok=True)
    feat_df.to_csv(DATA_OUT, index=False)

    # Also save raw states for testbench generation
    raw.to_csv(os.path.join(BASE, "data", "raw_states.csv"), index=False)

    print(f"\nSaved features → {DATA_OUT}")
    print(f"Saved raw states → {BASE}/data/raw_states.csv")
    print(f"\nFeature ranges:")
    for col in feat_df.columns[:-1]:
        print(f"  {col:20s}: [{feat_df[col].min():.3g}, {feat_df[col].max():.3g}]")


def generate_synthetic_drone(n=500):
    """Fallback synthetic drone if CSV not found."""
    rows = []
    rng_d = np.random.default_rng(1)
    for _ in range(n):
        speed_h = rng_d.uniform(0, 15)
        alt = rng_d.uniform(5, 100)
        vx = rng_d.uniform(-speed_h, speed_h)
        vy = rng_d.uniform(-speed_h, speed_h)
        vz = rng_d.uniform(-3, 3)
        rows.append([rng_d.uniform(-200,200), rng_d.uniform(-200,200), alt,
                     vx, vy, vz,
                     rng_d.uniform(-2,2), rng_d.uniform(-2,2), rng_d.uniform(-1,1), 0])
    df = pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])
    print(f"  [Drone]  {len(df)} synthetic samples")
    return df


if __name__ == "__main__":
    main()


# ---------------------------------------------------------------------------
# Class 0: Drone augmentation — varied altitudes, behaviors, trajectories
# ---------------------------------------------------------------------------
