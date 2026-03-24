#!/usr/bin/env python3
"""
Verify UKF Parameters Match Across Implementations
Compares Custom Python vs FilterPy
"""

import numpy as np
from pathlib import Path
import sys

# Add scripts directory to path
sys.path.insert(0, str(Path(__file__).parent))

from ukf_9d_ca_filterpy import UKF_9D_CA_FilterPy

def load_custom_python_ukf():
    """Load custom Python UKF for comparison"""
    try:
        from ukf_9d_ca_reference import UKF_9D_CA_Reference
        return UKF_9D_CA_Reference(dt=0.02, q_power=5.0, r_diag=1.0)
    except ImportError:
        print("Warning: Custom Python UKF not found")
        return None

def compare_q_matrices(custom_ukf, filterpy_ukf):
    """Compare Q matrices element-wise"""
    print("\n" + "="*80)
    print("Q MATRIX COMPARISON")
    print("="*80)
    
    if custom_ukf is None:
        print("Custom UKF not available for comparison")
        return False
    
    q_custom = custom_ukf.Q if hasattr(custom_ukf, 'Q') else None
    q_filterpy = filterpy_ukf.ukf.Q
    
    if q_custom is None:
        print("Custom Q matrix not accessible")
        return False
    
    diff = np.abs(q_custom - q_filterpy)
    max_diff = diff.max()
    
    print(f"Maximum difference: {max_diff:.2e}")
    
    if max_diff < 1e-10:
        print("✓ Q matrices IDENTICAL")
        return True
    else:
        print("✗ Q matrices DIFFER")
        print("\nCustom Q (first 3x3 block):")
        print(q_custom[:3, :3])
        print("\nFilterPy Q (first 3x3 block):")
        print(q_filterpy[:3, :3])
        return False

def compare_r_matrices(custom_ukf, filterpy_ukf):
    """Compare R matrices"""
    print("\n" + "="*80)
    print("R MATRIX COMPARISON")
    print("="*80)
    
    if custom_ukf is None:
        return False
    
    r_custom = custom_ukf.R if hasattr(custom_ukf, 'R') else None
    r_filterpy = filterpy_ukf.ukf.R
    
    if r_custom is None:
        print("Custom R matrix not accessible")
        return False
    
    diff = np.abs(r_custom - r_filterpy)
    max_diff = diff.max()
    
    print(f"Maximum difference: {max_diff:.2e}")
    
    if max_diff < 1e-10:
        print("✓ R matrices IDENTICAL")
        return True
    else:
        print("✗ R matrices DIFFER")
        return False

def compare_ukf_weights(filterpy_ukf):
    """Display UKF weights"""
    print("\n" + "="*80)
    print("UKF WEIGHTS")
    print("="*80)
    
    points = filterpy_ukf.ukf.points_fn
    
    print(f"Alpha: {points.alpha}")
    print(f"Beta: {points.beta}")
    print(f"Kappa: {points.kappa}")
    print(f"Lambda: {points.lambda_}")
    print(f"Number of sigma points: {points.num_sigmas()}")
    
    expected = {'alpha': 1.0, 'beta': 2.0, 'kappa': 0.0}
    
    match = (abs(points.alpha - expected['alpha']) < 1e-10 and
             abs(points.beta - expected['beta']) < 1e-10 and
             abs(points.kappa - expected['kappa']) < 1e-10)
    
    if match:
        print("✓ UKF parameters MATCH expected values")
        return True
    else:
        print("✗ UKF parameters DO NOT MATCH")
        return False

def main():
    print("="*80)
    print("UKF PARAMETER VERIFICATION")
    print("="*80)
    print("Comparing: Custom Python vs FilterPy")
    
    # Create FilterPy UKF
    filterpy_ukf = UKF_9D_CA_FilterPy(dt=0.02, q_power=5.0, r_diag=1.0)
    
    # Load custom UKF
    custom_ukf = load_custom_python_ukf()
    
    # Compare
    results = {
        'q_matrix': compare_q_matrices(custom_ukf, filterpy_ukf),
        'r_matrix': compare_r_matrices(custom_ukf, filterpy_ukf),
        'ukf_weights': compare_ukf_weights(filterpy_ukf)
    }
    
    # Summary
    print("\n" + "="*80)
    print("VERIFICATION SUMMARY")
    print("="*80)
    
    for test, passed in results.items():
        status = "✓ PASS" if passed else "✗ FAIL"
        print(f"{test:20s}: {status}")
    
    if all(results.values()):
        print("\n✓ ALL PARAMETERS VERIFIED")
        print("FilterPy UKF matches custom Python implementation")
        return 0
    else:
        print("\n✗ PARAMETER MISMATCH DETECTED")
        return 1

if __name__ == "__main__":
    exit(main())
