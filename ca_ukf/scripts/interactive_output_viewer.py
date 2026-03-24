#!/usr/bin/env python3
"""
Interactive VHDL Output Viewer
GUI tool for cycle-by-cycle inspection of VHDL UKF outputs

Features:
- Slider to navigate through cycles
- 3D trajectory plot with real-time update
- State comparison table (VHDL vs Python vs Ground Truth)
- Covariance uncertainty ellipsoids
- Highlight cycles with large errors
- Export snapshots of suspicious cycles

Usage:
  python interactive_output_viewer.py --dataset drone_euroc_mh01
"""

import numpy as np
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider, Button
from mpl_toolkits.mplot3d import Axes3D
import argparse

BASE_DIR = Path(__file__).parent.parent
MANUAL_DIR = BASE_DIR / "results" / "manual_inspection"
OUTPUT_DIR = BASE_DIR / "results" / "manual_inspection" / "snapshots"

class InteractiveViewer:
    """Interactive viewer for VHDL outputs"""
    
    def __init__(self, dataset_name):
        self.dataset_name = dataset_name
        
        # Load comparison data
        csv_file = MANUAL_DIR / f"vhdl_readable_{dataset_name}.csv"
        if not csv_file.exists():
            raise FileNotFoundError(
                f"Readable comparison not found: {csv_file}\n"
                f"Run generate_human_readable_outputs.py first"
            )
        
        self.data = pd.read_csv(csv_file)
        self.current_cycle = 0
        self.max_cycle = len(self.data) - 1
        
        print(f"Loaded {len(self.data)} cycles for {dataset_name}")
        
        # Setup figure
        self.setup_figure()
    
    def setup_figure(self):
        """Create interactive figure with subplots"""
        self.fig = plt.figure(figsize=(16, 10))
        
        # 3D trajectory plot
        self.ax_3d = self.fig.add_subplot(2, 2, 1, projection='3d')
        
        # Error time series
        self.ax_error = self.fig.add_subplot(2, 2, 2)
        
        # State comparison table (text)
        self.ax_table = self.fig.add_subplot(2, 2, 3)
        self.ax_table.axis('off')
        
        # Uncertainty bars
        self.ax_uncert = self.fig.add_subplot(2, 2, 4)
        
        # Slider for cycle navigation
        ax_slider = plt.axes([0.15, 0.02, 0.7, 0.03])
        self.slider = Slider(
            ax_slider, 'Cycle', 0, self.max_cycle,
            valinit=0, valstep=1, color='lightblue'
        )
        self.slider.on_changed(self.update)
        
        # Buttons
        ax_prev = plt.axes([0.15, 0.07, 0.1, 0.04])
        ax_next = plt.axes([0.26, 0.07, 0.1, 0.04])
        ax_export = plt.axes([0.75, 0.07, 0.1, 0.04])
        
        self.btn_prev = Button(ax_prev, 'Previous')
        self.btn_next = Button(ax_next, 'Next')
        self.btn_export = Button(ax_export, 'Export')
        
        self.btn_prev.on_clicked(self.prev_cycle)
        self.btn_next.on_clicked(self.next_cycle)
        self.btn_export.on_clicked(self.export_snapshot)
        
        # Initial plot
        self.update(0)
        
        plt.subplots_adjust(left=0.05, right=0.95, top=0.95, bottom=0.12, hspace=0.3, wspace=0.3)
    
    def plot_3d_trajectory(self, current_cycle):
        """Plot 3D trajectory with current position highlighted"""
        self.ax_3d.clear()
        
        # Plot full trajectories
        self.ax_3d.plot(
            self.data['gt_x_pos'], self.data['gt_y_pos'], self.data['gt_z_pos'],
            'k-', linewidth=1, alpha=0.3, label='Ground Truth'
        )
        
        self.ax_3d.plot(
            self.data['vhdl_x_pos'], self.data['vhdl_y_pos'], self.data['vhdl_z_pos'],
            'b-', linewidth=1, alpha=0.5, label='VHDL Estimate'
        )
        
        if 'py_x_pos' in self.data.columns:
            self.ax_3d.plot(
                self.data['py_x_pos'], self.data['py_y_pos'], self.data['py_z_pos'],
                'g-', linewidth=1, alpha=0.5, label='Python Ref'
            )
        
        # Highlight current position
        row = self.data.iloc[current_cycle]
        
        self.ax_3d.scatter(
            [row['gt_x_pos']], [row['gt_y_pos']], [row['gt_z_pos']],
            c='black', s=100, marker='o', label=f'GT (cycle {current_cycle})'
        )
        
        self.ax_3d.scatter(
            [row['vhdl_x_pos']], [row['vhdl_y_pos']], [row['vhdl_z_pos']],
            c='blue', s=100, marker='^', label=f'VHDL (cycle {current_cycle})'
        )
        
        # Error vector
        self.ax_3d.plot(
            [row['gt_x_pos'], row['vhdl_x_pos']],
            [row['gt_y_pos'], row['vhdl_y_pos']],
            [row['gt_z_pos'], row['vhdl_z_pos']],
            'r--', linewidth=2, label=f'Error: {row["err_pos_mag"]:.3f}m'
        )
        
        self.ax_3d.set_xlabel('X (m)')
        self.ax_3d.set_ylabel('Y (m)')
        self.ax_3d.set_zlabel('Z (m)')
        self.ax_3d.set_title(f'3D Trajectory - {self.dataset_name}')
        self.ax_3d.legend(loc='upper left', fontsize=8)
        self.ax_3d.grid(True, alpha=0.3)
    
    def plot_error_time_series(self, current_cycle):
        """Plot error time series with current cycle marked"""
        self.ax_error.clear()
        
        self.ax_error.plot(
            self.data['time'], self.data['err_pos_mag'],
            'b-', linewidth=1, alpha=0.7
        )
        
        # Mark current cycle
        row = self.data.iloc[current_cycle]
        self.ax_error.scatter(
            [row['time']], [row['err_pos_mag']],
            c='red', s=100, marker='o', zorder=5
        )
        
        # Threshold lines
        self.ax_error.axhline(y=0.5, color='green', linestyle='--', alpha=0.5, label='Excellent')
        self.ax_error.axhline(y=1.0, color='yellow', linestyle='--', alpha=0.5, label='Acceptable')
        
        self.ax_error.set_xlabel('Time (s)')
        self.ax_error.set_ylabel('Position Error (m)')
        self.ax_error.set_title(f'Error Time Series (Cycle {current_cycle}/{self.max_cycle})')
        self.ax_error.legend(fontsize=8)
        self.ax_error.grid(True, alpha=0.3)
    
    def plot_state_comparison_table(self, current_cycle):
        """Display state comparison as text table"""
        self.ax_table.clear()
        self.ax_table.axis('off')
        
        row = self.data.iloc[current_cycle]
        
        # Create comparison text
        table_text = f"CYCLE {current_cycle} - Time: {row['time']:.3f}s\n"
        table_text += "=" * 60 + "\n\n"
        
        table_text += "POSITION (m):\n"
        table_text += f"  X:  GT={row['gt_x_pos']:8.3f}  VHDL={row['vhdl_x_pos']:8.3f}  Err={row['err_x_pos']:7.3f}\n"
        table_text += f"  Y:  GT={row['gt_y_pos']:8.3f}  VHDL={row['vhdl_y_pos']:8.3f}  Err={row['err_y_pos']:7.3f}\n"
        table_text += f"  Z:  GT={row['gt_z_pos']:8.3f}  VHDL={row['vhdl_z_pos']:8.3f}  Err={row['err_z_pos']:7.3f}\n"
        table_text += f"  3D Magnitude Error: {row['err_pos_mag']:.4f} m\n\n"
        
        table_text += "VELOCITY (m/s):\n"
        table_text += f"  X:  GT={row['gt_x_vel']:8.3f}  VHDL={row.get('vhdl_x_vel', np.nan):8.3f}\n"
        table_text += f"  Y:  GT={row['gt_y_vel']:8.3f}  VHDL={row.get('vhdl_y_vel', np.nan):8.3f}\n"
        table_text += f"  Z:  GT={row['gt_z_vel']:8.3f}  VHDL={row.get('vhdl_z_vel', np.nan):8.3f}\n\n"
        
        if 'py_x_pos' in row and not np.isnan(row['py_x_pos']):
            table_text += "PYTHON REFERENCE:\n"
            table_text += f"  Pos X: {row['py_x_pos']:8.3f}  Diff: {row.get('diff_vhdl_py_x', 0):.4f}\n"
            table_text += f"  Pos Y: {row['py_y_pos']:8.3f}  Diff: {row.get('diff_vhdl_py_y', 0):.4f}\n"
            table_text += f"  Pos Z: {row['py_z_pos']:8.3f}  Diff: {row.get('diff_vhdl_py_z', 0):.4f}\n"
            table_text += f"  3D Diff: {row.get('diff_vhdl_py_mag', 0):.4f} m\n"
        
        # Color code based on error
        if row['err_pos_mag'] < 0.5:
            status = "✓ EXCELLENT"
            color = 'green'
        elif row['err_pos_mag'] < 1.0:
            status = "⚠ ACCEPTABLE"
            color = 'orange'
        else:
            status = "✗ INVESTIGATE"
            color = 'red'
        
        table_text += f"\nStatus: {status}"
        
        self.ax_table.text(
            0.05, 0.95, table_text,
            transform=self.ax_table.transAxes,
            fontsize=9, verticalalignment='top',
            fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor=color, alpha=0.2)
        )
    
    def plot_uncertainty_bars(self, current_cycle):
        """Plot uncertainty visualization"""
        self.ax_uncert.clear()
        
        # This is a placeholder - actual covariance would come from VHDL output
        # For now, show error distribution
        
        recent_window = max(0, current_cycle - 50)
        recent_data = self.data.iloc[recent_window:current_cycle+1]
        
        self.ax_uncert.hist(
            recent_data['err_pos_mag'], bins=20, alpha=0.7,
            edgecolor='black', color='blue'
        )
        
        # Mark current error
        row = self.data.iloc[current_cycle]
        self.ax_uncert.axvline(
            x=row['err_pos_mag'], color='red', linewidth=2,
            label=f'Current: {row["err_pos_mag"]:.3f}m'
        )
        
        self.ax_uncert.set_xlabel('Position Error (m)')
        self.ax_uncert.set_ylabel('Frequency')
        self.ax_uncert.set_title(f'Error Distribution (Last {len(recent_data)} cycles)')
        self.ax_uncert.legend()
        self.ax_uncert.grid(True, alpha=0.3)
    
    def update(self, val):
        """Update all plots for new cycle"""
        self.current_cycle = int(self.slider.val)
        
        self.plot_3d_trajectory(self.current_cycle)
        self.plot_error_time_series(self.current_cycle)
        self.plot_state_comparison_table(self.current_cycle)
        self.plot_uncertainty_bars(self.current_cycle)
        
        self.fig.canvas.draw_idle()
    
    def prev_cycle(self, event):
        """Go to previous cycle"""
        if self.current_cycle > 0:
            self.slider.set_val(self.current_cycle - 1)
    
    def next_cycle(self, event):
        """Go to next cycle"""
        if self.current_cycle < self.max_cycle:
            self.slider.set_val(self.current_cycle + 1)
    
    def export_snapshot(self, event):
        """Export current view as image"""
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
        
        filename = OUTPUT_DIR / f"snapshot_{self.dataset_name}_cycle{self.current_cycle:04d}.png"
        self.fig.savefig(filename, dpi=150, bbox_inches='tight')
        print(f"✓ Snapshot saved: {filename}")
    
    def show(self):
        """Display interactive viewer"""
        plt.show()

def main():
    parser = argparse.ArgumentParser(description='Interactive VHDL Output Viewer')
    parser.add_argument('--dataset', type=str, required=True,
                        help='Dataset name (e.g., drone_euroc_mh01)')
    args = parser.parse_args()
    
    print("="*80)
    print("INTERACTIVE VHDL OUTPUT VIEWER")
    print("="*80)
    print(f"Dataset: {args.dataset}")
    print("\nControls:")
    print("  - Use slider to navigate cycles")
    print("  - Click 'Previous' / 'Next' for fine control")
    print("  - Click 'Export' to save current view")
    print("  - Close window to exit")
    
    try:
        viewer = InteractiveViewer(args.dataset)
        viewer.show()
    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
