#!/usr/bin/env python3
"""
Large-dataset RF training: 30,000 samples per class = 180,000 total.
Evaluates deeper/wider forests and picks the best.
Writes trees_export_large.json for separate VHDL export.
"""

import json, os, sys, numpy as np, pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import StratifiedKFold, cross_val_score
from sklearn.metrics import classification_report, confusion_matrix

BASE       = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SINGERS    = "/home/arunupscee/Desktop/xtortion/singers_model/scripts"
DATA_DIR   = os.path.join(BASE, "data")
JSON_LARGE = os.path.join(DATA_DIR, "trees_export_large.json")
Q          = 24; SCALE = 2**Q
MAX48 = (1<<47)-1; MIN48 = -(1<<47)

FEAT_NAMES = ["speed_sq","altitude","horiz_speed_sq","vert_speed_abs",
              "accel_mag_sq","horiz_accel_sq","climb_rate_sign","altitude_abs",
              "horiz_accel_ratio"]
CLASS_NAMES = {0:"Drone",1:"Missile",2:"Car",3:"F1",4:"Cat",5:"Bird",
               6:"Airplane",7:"Ball",8:"Artillery",9:"Pedestrian"}

# ── Data generators (same physics as generate_training_data.py, new seeds) ──

def gen_drone(n=30000, seed=200):
    rng = np.random.default_rng(seed); dt = 0.02
    rows = []; behaviors = ["hover","lateral","ascend","descend","patrol","delivery","circle","zigzag"]
    for k in range(n):
        beh = behaviors[k % len(behaviors)]
        alt = rng.uniform(5.0, 100.0)
        px,py,pz = rng.uniform(-1000,1000), rng.uniform(-1000,1000), alt
        vx,vy,vz = 0.0,0.0,0.0
        for _ in range(3):           # simulate a few steps to get realistic velocity
            if beh in ("hover",):
                ax=rng.uniform(-0.5,0.5); ay=rng.uniform(-0.5,0.5); az=rng.uniform(-0.3,0.3)
            elif beh in ("lateral","circle"):
                spd=rng.uniform(2,15); hd=rng.uniform(0,6.28)
                ax=spd*np.cos(hd)*0.1; ay=spd*np.sin(hd)*0.1; az=rng.uniform(-0.2,0.2)
            elif beh=="zigzag":
                ax=rng.uniform(-3,3); ay=rng.uniform(-3,3); az=rng.uniform(-0.5,0.5)
            elif beh=="ascend":
                ax=rng.uniform(-1,1); ay=rng.uniform(-1,1); az=rng.uniform(0.5,3.0)
            elif beh=="descend":
                ax=rng.uniform(-1,1); ay=rng.uniform(-1,1); az=rng.uniform(-3.0,-0.3)
            elif beh=="patrol":
                ax=2.0 if k%20<10 else -2.0; ay=rng.uniform(-0.3,0.3); az=rng.uniform(-0.1,0.1)
            else:  # delivery
                spd=rng.uniform(3,10); hd=rng.uniform(0,6.28)
                ax=spd*np.cos(hd)*0.05; ay=spd*np.sin(hd)*0.05; az=rng.uniform(-1.5,0.1)
            vx=np.clip(vx+ax*dt,-15,15); vy=np.clip(vy+ay*dt,-15,15); vz=np.clip(vz+az*dt,-5,5)
            pz=max(0.5, pz+vz*dt)
        rows.append([px,py,pz,vx,vy,vz,ax,ay,az,0])
    return pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])

def gen_missile(n=30000, seed=201):
    rng = np.random.default_rng(seed); g = 9.81; rows = []
    for k in range(n):
        spd=rng.uniform(200,800); elev=rng.uniform(np.radians(20),np.radians(70))
        az_=rng.uniform(0,6.28)
        vx=spd*np.cos(elev)*np.cos(az_); vy=spd*np.cos(elev)*np.sin(az_); vz=spd*np.sin(elev)
        px,py,pz=rng.uniform(-5000,5000),rng.uniform(-5000,5000),rng.uniform(0,500)
        dt=0.05
        for _ in range(5):
            ax=rng.uniform(-2,2); ay=rng.uniform(-2,2); az=-g+rng.uniform(-0.5,0.5)
            vx+=ax*dt; vy+=ay*dt; vz+=az*dt
            pz=max(0, pz+vz*dt)
        rows.append([px,py,pz,vx,vy,vz,ax,ay,az,1])
    return pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])

def gen_car(n=30000, seed=202):
    rng = np.random.default_rng(seed); dt = 0.02; rows = []
    for k in range(n):
        spd=rng.uniform(2,30); hd=rng.uniform(0,6.28)
        vx=spd*np.cos(hd); vy=spd*np.sin(hd); vz=0.0
        px,py,pz=rng.uniform(-2000,2000),rng.uniform(-2000,2000),0.0
        ax=rng.uniform(-5,5); ay=rng.uniform(-5,5); az=0.0
        rows.append([px,py,pz,vx,vy,vz,ax,ay,az,2])
    return pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])

def gen_f1(n=30000, seed=203):
    rng = np.random.default_rng(seed); dt = 0.02; rows = []
    for k in range(n):
        spd=rng.uniform(30,90); hd=rng.uniform(0,6.28)
        event = k % 3
        if event == 0:   # straight
            ax=np.cos(hd)*rng.uniform(-5,8); ay=np.sin(hd)*rng.uniform(-5,8); az=0.0
        elif event == 1: # corner
            lat=rng.uniform(15,50); td=1 if k%2==0 else -1
            ax=-np.sin(hd)*lat*td; ay=np.cos(hd)*lat*td; az=0.0
        else:            # braking
            ax=np.cos(hd)*rng.uniform(-35,-5); ay=np.sin(hd)*rng.uniform(-35,-5); az=0.0
        vx=spd*np.cos(hd); vy=spd*np.sin(hd); vz=0.0
        px,py,pz=rng.uniform(-5000,5000),rng.uniform(-5000,5000),0.0
        rows.append([px,py,pz,vx,vy,vz,ax,ay,az,3])
    return pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])

def gen_cat(n=30000, seed=204):
    rng = np.random.default_rng(seed); dt = 0.02; rows = []
    for k in range(n):
        vx,vy = rng.uniform(-3,3), rng.uniform(-3,3)
        ax=rng.uniform(-8,8); ay=rng.uniform(-8,8); az=0.0
        px,py,pz = rng.uniform(-100,100), rng.uniform(-100,100), 0.0
        rows.append([px,py,pz,vx,vy,0.0,ax,ay,az,4])
    return pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])

def gen_bird(n=30000, seed=205):
    rng = np.random.default_rng(seed); dt = 0.02; rows = []
    for k in range(n):
        spd=rng.uniform(5,25); hd=rng.uniform(0,6.28)
        alt=rng.uniform(2,200); ff=rng.uniform(0.5,3); fa=rng.uniform(0.3,3)
        t = k*dt
        az=-fa*(2*np.pi*ff)**2*np.sin(2*np.pi*ff*t)
        az=np.clip(az,-20,20)
        vx=spd*np.cos(hd); vy=spd*np.sin(hd); vz=np.clip(az*dt,-5,5)
        ax=rng.uniform(-0.5,0.5); ay=rng.uniform(-0.5,0.5)
        pz=alt+vz*dt
        pz=max(0.5,pz)
        px,py=rng.uniform(-1000,1000),rng.uniform(-1000,1000)
        rows.append([px,py,pz,vx,vy,vz,ax,ay,az,5])
    return pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])

def gen_airplane(n=30000, seed=206):
    """Commercial airplane: v=200-260 m/s, alt=9000-12000m, near-zero accel.
    Differentiators: extreme altitude, high steady speed, horiz_accel≈0 (no guidance),
    banking during turns (small lateral accel ~0.05-0.3g), zero vertical accel in cruise.
    Angular change: slow gentle heading changes (0.01-0.05 rad/s), long straight segments."""
    rng = np.random.default_rng(seed); rows = []
    for k in range(n):
        # Cruise phase: constant altitude, constant speed, near-zero accel
        spd = rng.uniform(200.0, 260.0)
        hd  = rng.uniform(0, 6.28)
        alt = rng.uniform(9000.0, 12000.0)
        # Segment type: straight cruise (70%) vs gentle banking turn (30%)
        event = k % 10
        if event < 7:   # straight cruise — near-zero accel
            ax = rng.uniform(-0.15, 0.15)   # tiny atmospheric turbulence
            ay = rng.uniform(-0.15, 0.15)
            az = rng.uniform(-0.05, 0.05)   # very stable vertical
        else:            # coordinated banking turn
            bank_g = rng.uniform(0.05, 0.3)  # 0.05-0.3g lateral load
            hd_rate = rng.uniform(0.01, 0.05) * (1 if k % 2 == 0 else -1)
            ax = -np.sin(hd) * bank_g * 9.81 + np.cos(hd) * rng.uniform(-0.1, 0.1)
            ay =  np.cos(hd) * bank_g * 9.81 + np.sin(hd) * rng.uniform(-0.1, 0.1)
            az = rng.uniform(-0.1, 0.1)   # altitude hold during bank
            hd += hd_rate
        vx = spd * np.cos(hd)
        vy = spd * np.sin(hd)
        vz = rng.uniform(-1.0, 1.0)   # very small climb/descent rate
        pz = alt + rng.uniform(-50.0, 50.0)
        px = rng.uniform(-50000, 50000)
        py = rng.uniform(-50000, 50000)
        rows.append([px, py, pz, vx, vy, vz, ax, ay, az, 6])
    return pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])


def gen_ball(n=30000, seed=207):
    """Ball/Projectile: v=5-40 m/s, alt=0-80m, gravity-dominated accel.
    Differentiators: accel_mag_sq≈96 (gravity), horiz_accel_sq≈0 (no thrust),
    low speed, low altitude, climb_rate_sign changes sign (arc).
    Angular change: initial launch angle 20-80 deg, parabolic arc."""
    rng = np.random.default_rng(seed); g = 9.81; rows = []
    # Load real projectile data if available
    proj_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                             "..","ca_ukf","test_data","realistic","projectile.csv")
    real_rows = []
    if os.path.exists(proj_path):
        import pandas as _pd
        df_r = _pd.read_csv(proj_path)
        dt_r = float(df_r["time"].iloc[1] - df_r["time"].iloc[0]) if len(df_r) > 1 else 0.02
        for i in range(1, len(df_r) - 1):
            vx = (df_r["x"].iloc[i+1] - df_r["x"].iloc[i-1]) / (2*dt_r)
            vy = (df_r["y"].iloc[i+1] - df_r["y"].iloc[i-1]) / (2*dt_r)
            vz = (df_r["z"].iloc[i+1] - df_r["z"].iloc[i-1]) / (2*dt_r)
            ax = (df_r["x"].iloc[i+1] - 2*df_r["x"].iloc[i] + df_r["x"].iloc[i-1]) / (dt_r**2)
            ay = (df_r["y"].iloc[i+1] - 2*df_r["y"].iloc[i] + df_r["y"].iloc[i-1]) / (dt_r**2)
            az = (df_r["z"].iloc[i+1] - 2*df_r["z"].iloc[i] + df_r["z"].iloc[i-1]) / (dt_r**2)
            pz = max(0.0, df_r["z"].iloc[i])
            real_rows.append([df_r["x"].iloc[i], df_r["y"].iloc[i], pz, vx, vy, vz, ax, ay, az, 7])
    # Synthetic ballistic arcs
    for k in range(n):
        if real_rows and k % 5 == 0:
            rows.append(real_rows[k % len(real_rows)])
            continue
        spd    = rng.uniform(5.0, 40.0)
        elev   = rng.uniform(np.radians(20), np.radians(80))
        azimuth = rng.uniform(0, 6.28)
        # Sample from mid-arc to get both ascending and descending phases
        t_flight = 2 * spd * np.sin(elev) / g   # total flight time
        t_sample = rng.uniform(0, t_flight)
        vx0 = spd * np.cos(elev) * np.cos(azimuth)
        vy0 = spd * np.cos(elev) * np.sin(azimuth)
        vz0 = spd * np.sin(elev)
        vx = vx0
        vy = vy0
        vz = vz0 - g * t_sample
        px = vx0 * t_sample + rng.uniform(-50, 50)
        py = vy0 * t_sample + rng.uniform(-50, 50)
        pz = max(0.0, vz0 * t_sample - 0.5 * g * t_sample**2)
        ax = rng.uniform(-0.2, 0.2)   # tiny air drag horiz
        ay = rng.uniform(-0.2, 0.2)
        az = -g + rng.uniform(-0.3, 0.3)
        rows.append([px, py, pz, vx, vy, vz, ax, ay, az, 7])
    return pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])


def gen_artillery(n=30000, seed=208):
    """Artillery shell: v=300-900 m/s, pure ballistic (NO guidance).
    Differentiators vs Missile: horiz_accel_sq≈0 (no guidance corrections),
    vs Ball: speed_sq 90000-810000 (much higher), same gravity-dominated accel.
    Angular change: fixed launch angle (no maneuvering after launch)."""
    rng = np.random.default_rng(seed); g = 9.81; rows = []
    for k in range(n):
        spd    = rng.uniform(300.0, 900.0)
        elev   = rng.uniform(np.radians(30), np.radians(70))
        azimuth = rng.uniform(0, 6.28)
        vx0 = spd * np.cos(elev) * np.cos(azimuth)
        vy0 = spd * np.cos(elev) * np.sin(azimuth)
        vz0 = spd * np.sin(elev)
        t_flight = 2 * vz0 / g
        t_sample = rng.uniform(0, t_flight * 0.95)   # sample before impact
        vx = vx0   # no horizontal force — angular change = 0 after launch
        vy = vy0
        vz = vz0 - g * t_sample
        px = vx0 * t_sample + rng.uniform(-100, 100)
        py = vy0 * t_sample + rng.uniform(-100, 100)
        pz = max(0.0, vz0 * t_sample - 0.5 * g * t_sample**2)
        ax = rng.uniform(-0.5, 0.5)    # tiny air drag, near-zero vs guidance
        ay = rng.uniform(-0.5, 0.5)
        az = -g + rng.uniform(-0.2, 0.2)
        rows.append([px, py, pz, vx, vy, vz, ax, ay, az, 8])
    return pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])


def gen_pedestrian(n=30000, seed=209):
    """Human pedestrian: v=0.5-8 m/s, pz=0, periodic bipedal gait.
    Differentiators vs Cat: lower peak accel (<3 m/s²), sustained direction,
    periodic stride (gait_freq 1-2 Hz causes periodic lateral oscillation),
    vs Car: much lower speed, vs Drone: pz=0, low speed.
    Angular change: slow heading changes with gait-induced lateral sway."""
    rng = np.random.default_rng(seed); rows = []
    # Load real pedestrian data if available
    ped_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                            "..","ca_ukf","test_data","realistic","pedestrian_walk.csv")
    real_rows = []
    if os.path.exists(ped_path):
        import pandas as _pd
        df_r = _pd.read_csv(ped_path)
        dt_r = float(df_r["time"].iloc[1] - df_r["time"].iloc[0]) if len(df_r) > 1 else 0.02
        for i in range(1, len(df_r) - 1):
            vx = (df_r["x"].iloc[i+1] - df_r["x"].iloc[i-1]) / (2*dt_r)
            vy = (df_r["y"].iloc[i+1] - df_r["y"].iloc[i-1]) / (2*dt_r)
            vz = 0.0
            ax = (df_r["x"].iloc[i+1] - 2*df_r["x"].iloc[i] + df_r["x"].iloc[i-1]) / (dt_r**2)
            ay = (df_r["y"].iloc[i+1] - 2*df_r["y"].iloc[i] + df_r["y"].iloc[i-1]) / (dt_r**2)
            real_rows.append([df_r["x"].iloc[i], df_r["y"].iloc[i], 0.0, vx, vy, vz, ax, ay, 0.0, 9])
    dt = 0.02
    for k in range(n):
        if real_rows and k % 4 == 0:
            rows.append(real_rows[k % len(real_rows)])
            continue
        # Bipedal gait: forward walking with periodic lateral sway
        spd        = rng.uniform(0.5, 8.0)
        hd         = rng.uniform(0, 6.28)
        gait_freq  = rng.uniform(1.0, 2.5)   # stride rate: 1-2.5 Hz (human gait)
        gait_amp   = rng.uniform(0.03, 0.12) # lateral sway amplitude (m)
        t          = k * dt
        # Forward velocity with slight periodic speed modulation (stride bounce)
        spd_mod    = spd * (1.0 + 0.05 * np.sin(2 * np.pi * gait_freq * t))
        vx_fwd     = spd_mod * np.cos(hd)
        vy_fwd     = spd_mod * np.sin(hd)
        # Lateral sway (perpendicular to heading)
        sway_v     = gait_amp * 2 * np.pi * gait_freq * np.cos(2 * np.pi * gait_freq * t)
        vx         = vx_fwd - np.sin(hd) * sway_v
        vy         = vy_fwd + np.cos(hd) * sway_v
        vz         = 0.0
        # Acceleration: gentle forward + sway accel
        ax_fwd     = rng.uniform(-1.5, 1.5)
        ay_fwd     = rng.uniform(-1.5, 1.5)
        sway_a     = -gait_amp * (2 * np.pi * gait_freq)**2 * np.sin(2 * np.pi * gait_freq * t)
        ax         = ax_fwd - np.sin(hd) * sway_a
        ay         = ay_fwd + np.cos(hd) * sway_a
        ax         = np.clip(ax, -3.0, 3.0)  # human max walking accel
        ay         = np.clip(ay, -3.0, 3.0)
        px         = rng.uniform(-500, 500)
        py         = rng.uniform(-500, 500)
        rows.append([px, py, 0.0, vx, vy, vz, ax, ay, 0.0, 9])
    return pd.DataFrame(rows, columns=["px","py","pz","vx","vy","vz","ax","ay","az","label"])


def extract_features(df):
    vx,vy,vz = df.vx.values, df.vy.values, df.vz.values
    ax,ay,az = df.ax.values, df.ay.values, df.az.values
    pz = df.pz.values
    speed_sq       = vx**2+vy**2+vz**2
    horiz_accel_sq = ax**2+ay**2
    return pd.DataFrame({
        "speed_sq":          speed_sq,
        "altitude":          pz,
        "horiz_speed_sq":    vx**2+vy**2,
        "vert_speed_abs":    np.abs(vz),
        "accel_mag_sq":      ax**2+ay**2+az**2,
        "horiz_accel_sq":    horiz_accel_sq,
        "climb_rate_sign":   np.sign(vz)*vz**2,
        "altitude_abs":      np.abs(pz),
        "horiz_accel_ratio": horiz_accel_sq / (speed_sq + 1.0),
        "label":             df.label.values,
    })

def export_tree(tree, q=24):
    t = tree.tree_
    nodes = []
    for i in range(t.node_count):
        is_leaf = (t.children_left[i] == -1)
        if is_leaf:
            nodes.append({"id":i,"is_leaf":True,"class":int(np.argmax(t.value[i][0])),
                          "counts":[int(c) for c in t.value[i][0]]})
        else:
            tf = float(t.threshold[i])
            tq = int(tf*(2**q)); tq=max(-(1<<47),min((1<<47)-1,tq))
            nodes.append({"id":i,"is_leaf":False,"feature_idx":int(t.feature[i]),
                          "feature_name":FEAT_NAMES[int(t.feature[i])],
                          "threshold_float":tf,"threshold_q2424":tq,
                          "threshold_hex":f"{tq&0xFFFFFFFFFFFF:012X}",
                          "left_child":int(t.children_left[i]),
                          "right_child":int(t.children_right[i])})
    return nodes

def main():
    print("=== LARGE DATASET RF TRAINING ===")
    print("Generating 300,000 samples (30,000 per class x 10 classes)...")

    frames = [gen_drone(), gen_missile(), gen_car(), gen_f1(), gen_cat(), gen_bird(),
              gen_airplane(), gen_ball(), gen_artillery(), gen_pedestrian()]
    raw = pd.concat(frames, ignore_index=True)
    feat = extract_features(raw)
    X = feat[FEAT_NAMES].values; y = feat["label"].values
    print(f"Dataset: {len(X):,} samples, {X.shape[1]} features, {len(np.unique(y))} classes")

    # Grid search on larger config space
    configs = []
    skf = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
    print(f"\n{'Trees':>6} {'Depth':>6} {'CV Acc':>8} {'Std':>6}")
    print("-"*35)
    for n_trees in [10, 20, 50]:
        for max_depth in [10, 12, 15]:
            clf = RandomForestClassifier(n_estimators=n_trees, max_depth=max_depth,
                                         random_state=42, n_jobs=-1)
            scores = cross_val_score(clf, X, y, cv=skf, scoring="accuracy")
            configs.append({"n_trees":n_trees,"max_depth":max_depth,
                            "cv_acc":scores.mean(),"cv_std":scores.std()})
            print(f"  {n_trees:4d}   {max_depth:5d}   {scores.mean():.4f}   {scores.std():.4f}")

    # Pick best
    best = max(configs, key=lambda c: c["cv_acc"] - 0.00005*c["n_trees"])
    print(f"\nBest: {best['n_trees']} trees, depth={best['max_depth']}, acc={best['cv_acc']:.4f}")

    # Train final
    clf = RandomForestClassifier(n_estimators=best["n_trees"], max_depth=best["max_depth"],
                                  random_state=42, n_jobs=-1)
    clf.fit(X, y)
    preds = clf.predict(X)
    print("\n" + classification_report(y, preds,
          target_names=[CLASS_NAMES[i] for i in range(10)], zero_division=0))
    print("Confusion matrix:")
    print(confusion_matrix(y, preds))

    # Export
    trees_data = []
    for i, est in enumerate(clf.estimators_):
        nodes = export_tree(est)
        n_leaves = sum(1 for n in nodes if n["is_leaf"])
        trees_data.append({"tree_id":i,"n_nodes":len(nodes),"n_leaves":n_leaves,
                           "max_depth":est.get_depth(),"nodes":nodes})
        print(f"  Tree {i:2d}: {len(nodes):4d} nodes, {n_leaves:3d} leaves, depth={est.get_depth()}")

    export = {"n_trees":best["n_trees"],"max_depth":best["max_depth"],
              "n_features":8,"n_classes":10,"feature_names":FEAT_NAMES,
              "class_names":[CLASS_NAMES[i] for i in range(10)],"q_bits":Q,
              "cv_accuracy":best["cv_acc"],"training_samples":len(X),
              "all_configs":configs,"trees":trees_data}
    with open(JSON_LARGE,"w") as f: json.dump(export, f, indent=2)
    print(f"\nExported → {JSON_LARGE}")

    # Save large raw for testbench
    raw.to_csv(os.path.join(DATA_DIR,"raw_states_large.csv"), index=False)
    feat.to_csv(os.path.join(DATA_DIR,"training_data_large.csv"), index=False)
    print(f"Saved training CSVs → data/training_data_large.csv")

if __name__ == "__main__":
    main()
