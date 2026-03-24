#!/usr/bin/env python3
"""
Train Random Forest classifier on 8-feature trajectory data.
Evaluates {5,10,20,50} trees × {8,10,12} max_depth configurations.
Picks best accuracy/complexity tradeoff and exports winning model.

Output: data/trees_export.json
"""

import json
import os
import sys
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import StratifiedKFold, cross_val_score
from sklearn.metrics import classification_report, confusion_matrix

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_CSV   = os.path.join(BASE, "data", "training_data.csv")
EXPORT_JSON = os.path.join(BASE, "data", "trees_export.json")

Q = 24      # Q24.24 fractional bits
SCALE = 2**Q

CLASS_NAMES = {0: "Drone", 1: "Missile", 2: "Car", 3: "F1", 4: "Cat", 5: "Bird",
               6: "Airplane", 7: "Ball", 8: "Artillery", 9: "Pedestrian"}
FEATURE_NAMES = [
    "speed_sq", "altitude", "horiz_speed_sq", "vert_speed_abs",
    "accel_mag_sq", "horiz_accel_sq", "climb_rate_sign", "altitude_abs",
    "horiz_accel_ratio",
]


# ---------------------------------------------------------------------------
# Load data
# ---------------------------------------------------------------------------
def load_data():
    if not os.path.exists(DATA_CSV):
        print(f"ERROR: {DATA_CSV} not found. Run generate_training_data.py first.")
        sys.exit(1)
    df = pd.read_csv(DATA_CSV)
    X = df[FEATURE_NAMES].values.astype(np.float64)
    y = df["label"].values.astype(int)
    print(f"Loaded {len(X)} samples, {X.shape[1]} features, {len(np.unique(y))} classes")
    for cls, name in CLASS_NAMES.items():
        count = np.sum(y == cls)
        print(f"  Class {cls} ({name:8s}): {count:5d} samples")
    return X, y


# ---------------------------------------------------------------------------
# Grid search
# ---------------------------------------------------------------------------
def grid_search(X, y):
    configs = []
    n_trees_options = [5, 10, 20, 50]
    max_depth_options = [8, 10, 12]

    skf = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)

    print("\n=== Grid Search ===")
    print(f"{'Trees':>6} {'Depth':>6} {'CV Acc':>8} {'Std':>6}")
    print("-" * 35)

    for n_trees in n_trees_options:
        for max_depth in max_depth_options:
            clf = RandomForestClassifier(
                n_estimators=n_trees,
                max_depth=max_depth,
                random_state=42,
                n_jobs=-1,
            )
            scores = cross_val_score(clf, X, y, cv=skf, scoring="accuracy")
            mean_acc = scores.mean()
            std_acc = scores.std()

            # Estimate LUT count (rough heuristic: 100 LUTs per tree leaf node)
            # Max nodes in a full binary tree of depth d: 2^(d+1) - 1
            max_nodes = n_trees * (2**(max_depth+1) - 1)
            lut_est = max_nodes * 5   # ~5 LUTs per comparator node

            configs.append({
                "n_trees": n_trees,
                "max_depth": max_depth,
                "cv_acc": mean_acc,
                "cv_std": std_acc,
                "lut_est": lut_est,
            })
            print(f"  {n_trees:4d}   {max_depth:5d}   {mean_acc:.4f}   {std_acc:.4f}")

    return configs


# ---------------------------------------------------------------------------
# Pick best config: maximize accuracy, penalize complexity
# ---------------------------------------------------------------------------
def pick_best(configs):
    # Score = accuracy - 0.0001 * log2(lut_est)  (small complexity penalty)
    for c in configs:
        c["score"] = c["cv_acc"] - 0.0001 * np.log2(max(c["lut_est"], 1))

    best = max(configs, key=lambda c: c["score"])
    print(f"\n=== Best Config ===")
    print(f"  Trees={best['n_trees']}, Depth={best['max_depth']}")
    print(f"  CV Accuracy: {best['cv_acc']:.4f} ± {best['cv_std']:.4f}")
    print(f"  LUT estimate: ~{best['lut_est']}")
    return best


# ---------------------------------------------------------------------------
# Train final model on all data
# ---------------------------------------------------------------------------
def train_final(X, y, n_trees, max_depth):
    clf = RandomForestClassifier(
        n_estimators=n_trees,
        max_depth=max_depth,
        random_state=42,
        n_jobs=-1,
    )
    clf.fit(X, y)
    preds = clf.predict(X)
    print(f"\n=== Final Model (Train set) ===")
    print(classification_report(y, preds, target_names=[CLASS_NAMES[i] for i in range(10)],
                                 zero_division=0))
    cm = confusion_matrix(y, preds)
    print("Confusion matrix (rows=true, cols=pred):")
    print(cm)
    return clf


# ---------------------------------------------------------------------------
# Export tree structure to JSON with Q24.24 thresholds
# ---------------------------------------------------------------------------
def export_tree(tree, feature_names, q=24):
    """Convert sklearn decision tree to dict with Q24.24 thresholds."""
    t = tree.tree_
    n_nodes = t.node_count
    children_left  = t.children_left
    children_right = t.children_right
    feature        = t.feature
    threshold      = t.threshold
    value          = t.value    # shape [n_nodes, n_outputs, n_classes]

    nodes = []
    for i in range(n_nodes):
        is_leaf = (children_left[i] == -1)
        if is_leaf:
            class_counts = value[i][0].tolist()
            leaf_class = int(np.argmax(class_counts))
            node = {
                "id": i,
                "is_leaf": True,
                "class": leaf_class,
                "counts": [int(c) for c in class_counts],
            }
        else:
            thresh_float = float(threshold[i])
            thresh_q2424 = int(thresh_float * (2**q))
            # Clamp to signed 48-bit range
            MAX48 = (1 << 47) - 1
            thresh_q2424 = max(-MAX48, min(MAX48, thresh_q2424))
            node = {
                "id": i,
                "is_leaf": False,
                "feature_idx": int(feature[i]),
                "feature_name": feature_names[int(feature[i])],
                "threshold_float": thresh_float,
                "threshold_q2424": thresh_q2424,
                "threshold_hex": f"{thresh_q2424 & 0xFFFFFFFFFFFF:012X}",
                "left_child": int(children_left[i]),
                "right_child": int(children_right[i]),
            }
        nodes.append(node)

    return nodes


def export_forest(clf, feature_names, q=24):
    trees_data = []
    for i, estimator in enumerate(clf.estimators_):
        nodes = export_tree(estimator, feature_names, q)
        n_leaves = sum(1 for n in nodes if n["is_leaf"])
        trees_data.append({
            "tree_id": i,
            "n_nodes": len(nodes),
            "n_leaves": n_leaves,
            "max_depth": estimator.get_depth(),
            "nodes": nodes,
        })
        print(f"  Tree {i:2d}: {len(nodes):4d} nodes, {n_leaves:3d} leaves, depth={estimator.get_depth()}")
    return trees_data


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    X, y = load_data()

    configs = grid_search(X, y)
    best = pick_best(configs)

    clf = train_final(X, y, best["n_trees"], best["max_depth"])

    print(f"\n=== Exporting Forest ===")
    trees_data = export_forest(clf, FEATURE_NAMES)

    export = {
        "n_trees": best["n_trees"],
        "max_depth": best["max_depth"],
        "n_features": len(FEATURE_NAMES),
        "n_classes": 10,
        "n_features": len(FEATURE_NAMES),
        "feature_names": FEATURE_NAMES,
        "class_names": [CLASS_NAMES[i] for i in range(10)],
        "q_bits": Q,
        "cv_accuracy": best["cv_acc"],
        "all_configs": configs,
        "trees": trees_data,
    }

    with open(EXPORT_JSON, "w") as f:
        json.dump(export, f, indent=2)
    print(f"Exported to {EXPORT_JSON}")

    # Summary table
    print(f"\n=== Configuration Summary ===")
    print(f"{'Config':<20} {'CV Acc':>8} {'LUT Est':>10} {'Latency':>12}")
    print("-" * 55)
    for c in configs:
        lat = "~10 clk" if c["n_trees"] <= 20 else "~14 clk"
        print(f"  {c['n_trees']:2d} trees, d={c['max_depth']:2d}   "
              f"{c['cv_acc']:.4f}   {c['lut_est']:>8d}   {lat}")

    print(f"\nWinner: {best['n_trees']} trees, depth={best['max_depth']}, "
          f"accuracy={best['cv_acc']:.4f}")


if __name__ == "__main__":
    main()
