#!/usr/bin/env python3
"""
Analyze ONE-STEP-AHEAD prediction accuracy for drone and F1 trajectories

This script computes prediction error: How well does the UKF predict the NEXT state
given all measurements up to the current time?

Prediction error at cycle N = |state_estimate(N) - ground_truth(N+1)|
"""

import pandas as pd
import numpy as np

def q24_to_float(q24_val):
    """Convert Q24.24 integer to float"""
    return q24_val / (2**24)

def analyze_dataset(dataset_name, gt_file, vhdl_file, python_file):
    """Analyze prediction accuracy for one dataset"""
    
    print("=" * 100)
    print(f"{dataset_name.upper()} TRAJECTORY - ONE-STEP-AHEAD PREDICTION ANALYSIS")
    print("=" * 100)
    print()
    
    # Load data
    gt = pd.read_csv(gt_file)
    vhdl = pd.read_csv(vhdl_file)
    python_ukf = pd.read_csv(python_file)
    
    num_cycles = min(len(gt), len(vhdl), len(python_ukf)) - 1  # -1 because we need N+1
    
    print(f"Analyzing {num_cycles} prediction steps")
    print()
    
    # Arrays to store errors
    vhdl_pos_errors = []
    python_pos_errors = []
    vhdl_vel_errors = []
    python_vel_errors = []
    
    # Detailed output for first 10 cycles
    print("SAMPLE: First 10 One-Step-Ahead Predictions")
    print("-" * 100)
    print(f"{'Cycle':<6} | {'GT Pos(N+1)':<25} | {'VHDL Pred(N)':<25} | {'Py Pred(N)':<25} | {'VHDL Err':<10} | {'Py Err':<10}")
    print("-" * 100)
    
    for i in range(num_cycles):
        # Ground truth at cycle N+1 (what we're trying to predict)
        gt_next = gt.iloc[i+1]
        gt_x_next = gt_next['gt_x_pos']
        gt_y_next = gt_next['gt_y_pos']
        gt_z_next = gt_next['gt_z_pos']
        gt_vx_next = gt_next['gt_x_vel']
        gt_vy_next = gt_next['gt_y_vel']
        gt_vz_next = gt_next['gt_z_vel']
        
        # VHDL estimate at cycle N (our prediction for N+1)
        vhdl_curr = vhdl.iloc[i]
        vhdl_x = q24_to_float(vhdl_curr['x_pos'])
        vhdl_y = q24_to_float(vhdl_curr['y_pos'])
        vhdl_z = q24_to_float(vhdl_curr['z_pos'])
        vhdl_vx = q24_to_float(vhdl_curr['x_vel'])
        vhdl_vy = q24_to_float(vhdl_curr['y_vel'])
        vhdl_vz = q24_to_float(vhdl_curr['z_vel'])
        
        # Python estimate at cycle N
        py_curr = python_ukf.iloc[i]
        py_x = py_curr['x_pos']
        py_y = py_curr['y_pos']
        py_z = py_curr['z_pos']
        py_vx = py_curr['x_vel']
        py_vy = py_curr['y_vel']
        py_vz = py_curr['z_vel']
        
        # Position prediction errors
        vhdl_err_pos = np.sqrt((vhdl_x - gt_x_next)**2 + (vhdl_y - gt_y_next)**2 + (vhdl_z - gt_z_next)**2)
        py_err_pos = np.sqrt((py_x - gt_x_next)**2 + (py_y - gt_y_next)**2 + (py_z - gt_z_next)**2)
        
        # Velocity prediction errors
        vhdl_err_vel = np.sqrt((vhdl_vx - gt_vx_next)**2 + (vhdl_vy - gt_vy_next)**2 + (vhdl_vz - gt_vz_next)**2)
        py_err_vel = np.sqrt((py_vx - gt_vx_next)**2 + (py_vy - gt_vy_next)**2 + (py_vz - gt_vz_next)**2)
        
        vhdl_pos_errors.append(vhdl_err_pos)
        python_pos_errors.append(py_err_pos)
        vhdl_vel_errors.append(vhdl_err_vel)
        python_vel_errors.append(py_err_vel)
        
        # Print first 10
        if i < 10:
            gt_pos_str = f"({gt_x_next:.2f},{gt_y_next:.2f},{gt_z_next:.2f})"
            vhdl_pos_str = f"({vhdl_x:.2f},{vhdl_y:.2f},{vhdl_z:.2f})"
            py_pos_str = f"({py_x:.2f},{py_y:.2f},{py_z:.2f})"
            print(f"{i:<6} | {gt_pos_str:<25} | {vhdl_pos_str:<25} | {py_pos_str:<25} | {vhdl_err_pos:>9.3f}m | {py_err_pos:>9.3f}m")
    
    print("-" * 100)
    print()
    
    # Compute statistics
    vhdl_pos_rmse = np.sqrt(np.mean(np.array(vhdl_pos_errors)**2))
    python_pos_rmse = np.sqrt(np.mean(np.array(python_pos_errors)**2))
    vhdl_vel_rmse = np.sqrt(np.mean(np.array(vhdl_vel_errors)**2))
    python_vel_rmse = np.sqrt(np.mean(np.array(python_vel_errors)**2))
    
    vhdl_pos_max = np.max(vhdl_pos_errors)
    python_pos_max = np.max(python_pos_errors)
    
    print("PREDICTION ACCURACY METRICS:")
    print("-" * 100)
    print()
    
    print("POSITION PREDICTION (One-Step-Ahead):")
    print(f"  VHDL RMSE:   {vhdl_pos_rmse:.4f} m")
    print(f"  Python RMSE: {python_pos_rmse:.4f} m")
    print(f"  Difference:  {abs(vhdl_pos_rmse - python_pos_rmse):.4f} m ({abs(vhdl_pos_rmse - python_pos_rmse)/python_pos_rmse*100:.1f}%)")
    print()
    
    print("VELOCITY PREDICTION (One-Step-Ahead):")
    print(f"  VHDL RMSE:   {vhdl_vel_rmse:.4f} m/s")
    print(f"  Python RMSE: {python_vel_rmse:.4f} m/s")
    print(f"  Difference:  {abs(vhdl_vel_rmse - python_vel_rmse):.4f} m/s ({abs(vhdl_vel_rmse - python_vel_rmse)/python_vel_rmse*100:.1f}%)")
    print()
    
    print("MAXIMUM PREDICTION ERRORS:")
    print(f"  VHDL max pos error:   {vhdl_pos_max:.4f} m")
    print(f"  Python max pos error: {python_pos_max:.4f} m")
    print()
    
    # Verdict
    print("VERDICT:")
    if vhdl_pos_rmse < python_pos_rmse * 1.2:
        print(f"  ✅ VHDL prediction accuracy is within 20% of Python ({vhdl_pos_rmse/python_pos_rmse*100:.1f}%)")
    else:
        print(f"  ⚠️  VHDL prediction accuracy is more than 20% worse than Python ({vhdl_pos_rmse/python_pos_rmse*100:.1f}%)")
    print()
    
    return {
        'vhdl_pos_rmse': vhdl_pos_rmse,
        'python_pos_rmse': python_pos_rmse,
        'vhdl_vel_rmse': vhdl_vel_rmse,
        'python_vel_rmse': python_vel_rmse,
        'vhdl_pos_max': vhdl_pos_max,
        'python_pos_max': python_pos_max
    }

if __name__ == '__main__':
    print("\n" * 2)
    print("=" * 100)
    print("UKF ONE-STEP-AHEAD PREDICTION ANALYSIS")
    print("=" * 100)
    print()
    print("This analysis tests: Given measurements up to time N, how accurately")
    print("can the UKF predict the state at time N+1?")
    print()
    
    # Analyze drone
    drone_metrics = analyze_dataset(
        "DRONE",
        "../test_data/drone_trajectory_800cycles.csv",
        "../test_data/vhdl_drone_outputs.txt",
        "../test_data/python_drone_outputs.txt"
    )
    
    # Analyze F1
    f1_metrics = analyze_dataset(
        "F1 CAR",
        "../test_data/f1_trajectory_600cycles.csv",
        "../test_data/vhdl_f1_outputs.txt",
        "../test_data/python_f1_outputs.txt"
    )
    
    # Summary comparison
    print("=" * 100)
    print("FINAL COMPARISON: DRONE vs F1")
    print("=" * 100)
    print()
    
    print("VHDL Position Prediction RMSE:")
    print(f"  Drone: {drone_metrics['vhdl_pos_rmse']:.4f} m")
    print(f"  F1:    {f1_metrics['vhdl_pos_rmse']:.4f} m")
    print(f"  Ratio: {f1_metrics['vhdl_pos_rmse']/drone_metrics['vhdl_pos_rmse']:.2f}x (F1 is harder)")
    print()
    
    print("Python Position Prediction RMSE:")
    print(f"  Drone: {drone_metrics['python_pos_rmse']:.4f} m")
    print(f"  F1:    {f1_metrics['python_pos_rmse']:.4f} m")
    print(f"  Ratio: {f1_metrics['python_pos_rmse']/drone_metrics['python_pos_rmse']:.2f}x (F1 is harder)")
    print()
    
    print("VHDL vs Python Agreement:")
    print(f"  Drone: VHDL is {drone_metrics['vhdl_pos_rmse']/drone_metrics['python_pos_rmse']*100:.1f}% of Python performance")
    print(f"  F1:    VHDL is {f1_metrics['vhdl_pos_rmse']/f1_metrics['python_pos_rmse']*100:.1f}% of Python performance")
    print()
    
    # Save summary
    summary = pd.DataFrame([
        {
            'dataset': 'drone',
            **drone_metrics
        },
        {
            'dataset': 'f1',
            **f1_metrics
        }
    ])
    
    summary.to_csv('../results/prediction_accuracy_summary.csv', index=False)
    print("Summary saved to: results/prediction_accuracy_summary.csv")
    print()
