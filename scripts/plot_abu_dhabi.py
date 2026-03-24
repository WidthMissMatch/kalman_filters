#!/usr/bin/env python3
"""Generate Abu Dhabi actual vs predicted trajectory plot."""
import os
import re
import csv
import struct
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

CSV_PATH  = os.path.join(BASE, 'imm_friend', 'test_data', 'abu_dhabi_verstappen_4173cycles.csv')
NAMO_PATH = os.path.join(BASE, 'imm_friend', 'results', 'namo.txt')
OUT_PATH  = os.path.join(BASE, 'results', 'abu_dhabi_actual_vs_predicted.png')

Q = 2**24  # Q24.24 scale

def hex48_to_float(h):
    """Convert 48-bit hex string to signed Q24.24 float."""
    v = int(h, 16)
    if v >= (1 << 47):  # sign bit
        v -= (1 << 48)
    return v / Q

# ── Load ground truth ──────────────────────────────────────────────────────
gt_x, gt_y, gt_z = [], [], []
with open(CSV_PATH) as f:
    reader = csv.DictReader(f)
    for row in reader:
        gt_x.append(float(row['gt_x_pos']))
        gt_y.append(float(row['gt_y_pos']))
        gt_z.append(float(row['gt_z_pos']))

# ── Load VHDL predictions (namo.txt) ──────────────────────────────────────
# Format: Cycle N: imm_x=0xHHHHHHHHHHHH imm_y=... imm_z=...
pred_x, pred_y, pred_z = [], [], []
pat = re.compile(r'imm_x=(0x[0-9A-Fa-f]+)\s+imm_y=(0x[0-9A-Fa-f]+)\s+imm_z=(0x[0-9A-Fa-f]+)')
with open(NAMO_PATH) as f:
    for line in f:
        m = pat.search(line)
        if m:
            pred_x.append(hex48_to_float(m.group(1)[2:].zfill(12)))
            pred_y.append(hex48_to_float(m.group(2)[2:].zfill(12)))
            pred_z.append(hex48_to_float(m.group(3)[2:].zfill(12)))

n = min(len(gt_x), len(pred_x))
gt_x, gt_y = gt_x[:n], gt_y[:n]
pred_x, pred_y = pred_x[:n], pred_y[:n]

# ── Plot ───────────────────────────────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(16, 7))
fig.patch.set_facecolor('#0d1117')
for ax in axes:
    ax.set_facecolor('#161b22')
    ax.tick_params(colors='#c9d1d9')
    ax.xaxis.label.set_color('#c9d1d9')
    ax.yaxis.label.set_color('#c9d1d9')
    ax.title.set_color('#f0f6fc')
    for spine in ax.spines.values():
        spine.set_edgecolor('#30363d')

# XY trajectory
ax = axes[0]
ax.plot(gt_x, gt_y, color='#58a6ff', linewidth=1.4, label='Ground Truth', alpha=0.9)
ax.plot(pred_x, pred_y, color='#f85149', linewidth=1.0, label='IMM Predicted', alpha=0.8, linestyle='--')
ax.set_xlabel('X Position (m)')
ax.set_ylabel('Y Position (m)')
ax.set_title('Abu Dhabi — XY Trajectory\nMax Verstappen (4173 cycles)', fontsize=12, fontweight='bold')
ax.legend(facecolor='#21262d', edgecolor='#30363d', labelcolor='#c9d1d9')
ax.grid(True, color='#21262d', linewidth=0.5)

# Position error over time
errors = np.sqrt((np.array(gt_x) - np.array(pred_x))**2 +
                 (np.array(gt_y) - np.array(pred_y))**2)
ax2 = axes[1]
ax2.plot(errors, color='#3fb950', linewidth=0.8, alpha=0.7)
ax2.axhline(np.median(errors), color='#f0f6fc', linewidth=1.5, linestyle='--',
            label=f'Median: {np.median(errors):.2f}m')
ax2.axhline(np.mean(errors), color='#e3b341', linewidth=1.5, linestyle=':',
            label=f'Mean: {np.mean(errors):.2f}m')
ax2.set_xlabel('Cycle')
ax2.set_ylabel('2D Position Error (m)')
ax2.set_title(f'Position Error Over Time\nRMSE: {np.sqrt(np.mean(errors**2)):.3f}m', fontsize=12, fontweight='bold')
ax2.legend(facecolor='#21262d', edgecolor='#30363d', labelcolor='#c9d1d9')
ax2.grid(True, color='#21262d', linewidth=0.5)
ax2.set_ylim(bottom=0)

plt.tight_layout(pad=2.0)
os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
plt.savefig(OUT_PATH, dpi=150, bbox_inches='tight', facecolor=fig.get_facecolor())
print(f"Saved: {OUT_PATH}")
print(f"Cycles: {n} | RMSE: {np.sqrt(np.mean(errors**2)):.3f}m | Median: {np.median(errors):.3f}m")
