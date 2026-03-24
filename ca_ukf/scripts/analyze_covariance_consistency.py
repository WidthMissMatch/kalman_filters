#!/usr/bin/env python3
"""
Analyze Covariance Consistency
Validates UKF uncertainty estimates using statistical tests

Checks if the UKF's reported covariance (uncertainty) matches
actual estimation errors. A well-calibrated filter should have:
- Actual errors within predicted 3σ bounds ~99.7% of the time
- Normalized Innovation Squared (NIS) ~ chi-squared distribution

This is CRITICAL for safety-critical applications where we need
to trust the uncertainty estimates for decision making.
"""

import numpy as np
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt
from scipy import stats
import sys

sys.path.insert(0, str(Path(__file__).parent))

BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR / "test_data" / "real_world"
PYTHON_CUSTOM_DIR = BASE_DIR / "results" / "python_outputs" / "custom"
PYTHON_FILTERPY_DIR = BASE_DIR / "results" / "python_outputs" / "filterpy"
OUTPUT_DIR = BASE_DIR / "results" / "covariance_consistency"

def load_data(dataset_name, implementation='filterpy'):
    """Load ground truth and UKF estimates with covariances"""
    # Load ground truth
    gt_file = DATA_DIR / f"{dataset_name}.csv"
    ground_truth = pd.read_csv(gt_file)
    
    # Load estimates
    if implementation == 'custom':
        output_dir = PYTHON_CUSTOM_DIR
        prefix = 'custom'
    else:
        output_dir = PYTHON_FILTERPY_DIR
        prefix = 'filterpy'
    
    pattern = f"{prefix}_{dataset_name.replace('.csv', '')}*.csv"
    matches = list(output_dir.glob(pattern))
    
    if not matches:
        raise FileNotFoundError(f"No {implementation} outputs for {dataset_name}")
    
    estimates = pd.read_csv(matches[0])
    
    return ground_truth, estimates

def compute_normalized_errors(ground_truth, estimates):
    """
    Compute normalized errors (error / uncertainty)
    
    For Gaussian errors, normalized errors should follow N(0,1)
    i.e., ~68% within ±1σ, ~95% within ±2σ, ~99.7% within ±3σ
    """
    normalized_errors = []
    
    for k in range(len(ground_truth)):
        gt = ground_truth.iloc[k]
        est = estimates.iloc[k]
        
        # Position errors
        for axis in ['x', 'y', 'z']:
            error = est[f'est_{axis}_pos'] - gt[f'gt_{axis}_pos']
            sigma = np.sqrt(est[f'cov_{axis}_pos'])
            normalized_errors.append({
                'cycle': k,
                'state': f'{axis}_pos',
                'error': error,
                'sigma': sigma,
                'normalized_error': error / sigma if sigma > 0 else 0,
                'within_1sigma': abs(error) <= sigma,
                'within_2sigma': abs(error) <= 2 * sigma,
                'within_3sigma': abs(error) <= 3 * sigma
            })
        
        # Velocity errors
        for axis in ['x', 'y', 'z']:
            error = est[f'est_{axis}_vel'] - gt[f'gt_{axis}_vel']
            sigma = np.sqrt(est[f'cov_{axis}_vel'])
            normalized_errors.append({
                'cycle': k,
                'state': f'{axis}_vel',
                'error': error,
                'sigma': sigma,
                'normalized_error': error / sigma if sigma > 0 else 0,
                'within_1sigma': abs(error) <= sigma,
                'within_2sigma': abs(error) <= 2 * sigma,
                'within_3sigma': abs(error) <= 3 * sigma
            })
        
        # Acceleration errors
        for axis in ['x', 'y', 'z']:
            error = est[f'est_{axis}_acc'] - gt[f'gt_{axis}_acc']
            sigma = np.sqrt(est[f'cov_{axis}_acc'])
            normalized_errors.append({
                'cycle': k,
                'state': f'{axis}_acc',
                'error': error,
                'sigma': sigma,
                'normalized_error': error / sigma if sigma > 0 else 0,
                'within_1sigma': abs(error) <= sigma,
                'within_2sigma': abs(error) <= 2 * sigma,
                'within_3sigma': abs(error) <= 3 * sigma
            })
    
    return pd.DataFrame(normalized_errors)

def analyze_consistency(norm_errors_df):
    """Analyze covariance consistency statistics"""
    # Expected percentages
    expected_1sigma = 0.6827  # 68.27%
    expected_2sigma = 0.9545  # 95.45%
    expected_3sigma = 0.9973  # 99.73%
    
    # Actual percentages
    actual_1sigma = norm_errors_df['within_1sigma'].mean()
    actual_2sigma = norm_errors_df['within_2sigma'].mean()
    actual_3sigma = norm_errors_df['within_3sigma'].mean()
    
    # Chi-squared test for normalized errors
    # If well-calibrated, normalized_error² should follow chi-squared(1)
    chi2_values = norm_errors_df['normalized_error']**2
    chi2_mean = chi2_values.mean()
    chi2_expected = 1.0  # Expected mean for chi-squared(1)
    
    # Normality test on normalized errors
    _, shapiro_p = stats.shapiro(norm_errors_df['normalized_error'].values[:5000])  # Max 5000 samples
    
    results = {
        'actual_1sigma': actual_1sigma,
        'actual_2sigma': actual_2sigma,
        'actual_3sigma': actual_3sigma,
        'expected_1sigma': expected_1sigma,
        'expected_2sigma': expected_2sigma,
        'expected_3sigma': expected_3sigma,
        'chi2_mean': chi2_mean,
        'chi2_expected': chi2_expected,
        'shapiro_p_value': shapiro_p,
        'is_consistent_1sigma': abs(actual_1sigma - expected_1sigma) < 0.05,
        'is_consistent_2sigma': abs(actual_2sigma - expected_2sigma) < 0.03,
        'is_consistent_3sigma': abs(actual_3sigma - expected_3sigma) < 0.01
    }
    
    return results

def plot_consistency_analysis(norm_errors_df, dataset_name, implementation, stats):
    """Plot covariance consistency visualizations"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # 1. Normalized error histogram vs Gaussian
    axes[0, 0].hist(norm_errors_df['normalized_error'], bins=50, density=True, 
                    alpha=0.7, label='Actual', edgecolor='black')
    
    x = np.linspace(-4, 4, 100)
    axes[0, 0].plot(x, stats.norm.pdf(x, 0, 1), 'r-', linewidth=2, 
                   label='Expected N(0,1)')
    
    axes[0, 0].set_xlabel('Normalized Error (error / σ)')
    axes[0, 0].set_ylabel('Density')
    axes[0, 0].set_title(f'Normalized Error Distribution - {implementation} - {dataset_name}')
    axes[0, 0].legend()
    axes[0, 0].grid(True, alpha=0.3)
    
    # 2. Coverage percentages
    categories = ['1σ', '2σ', '3σ']
    expected = [stats['expected_1sigma'], stats['expected_2sigma'], stats['expected_3sigma']]
    actual = [stats['actual_1sigma'], stats['actual_2sigma'], stats['actual_3sigma']]
    
    x_pos = np.arange(len(categories))
    width = 0.35
    
    axes[0, 1].bar(x_pos - width/2, expected, width, label='Expected', alpha=0.7)
    axes[0, 1].bar(x_pos + width/2, actual, width, label='Actual', alpha=0.7)
    
    axes[0, 1].set_xlabel('Sigma Bounds')
    axes[0, 1].set_ylabel('Percentage Within Bounds')
    axes[0, 1].set_title('Coverage Consistency Check')
    axes[0, 1].set_xticks(x_pos)
    axes[0, 1].set_xticklabels(categories)
    axes[0, 1].legend()
    axes[0, 1].grid(True, alpha=0.3, axis='y')
    axes[0, 1].set_ylim([0, 1.05])
    
    # 3. Error vs uncertainty scatter
    sample = norm_errors_df[::10]  # Sample for clarity
    axes[1, 0].scatter(sample['sigma'], sample['error'].abs(), alpha=0.3, s=10)
    
    max_sigma = sample['sigma'].max()
    x_line = np.linspace(0, max_sigma, 100)
    axes[1, 0].plot(x_line, x_line, 'r--', linewidth=2, label='1σ bound')
    axes[1, 0].plot(x_line, 2*x_line, 'y--', linewidth=2, label='2σ bound')
    axes[1, 0].plot(x_line, 3*x_line, 'g--', linewidth=2, label='3σ bound')
    
    axes[1, 0].set_xlabel('Predicted Uncertainty (σ)')
    axes[1, 0].set_ylabel('Actual Error (|error|)')
    axes[1, 0].set_title('Error vs Uncertainty Calibration')
    axes[1, 0].legend()
    axes[1, 0].grid(True, alpha=0.3)
    
    # 4. Q-Q plot
    stats.probplot(norm_errors_df['normalized_error'], dist="norm", plot=axes[1, 1])
    axes[1, 1].set_title('Q-Q Plot (Normal Distribution)')
    axes[1, 1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    
    plot_file = OUTPUT_DIR / f"covariance_consistency_{implementation}_{dataset_name}.png"
    plt.savefig(plot_file, dpi=150)
    plt.close()
    
    return plot_file

def analyze_dataset(dataset_name, implementation='filterpy'):
    """Analyze covariance consistency for one dataset"""
    print(f"\n{'='*80}")
    print(f"Dataset: {dataset_name}")
    print(f"Implementation: {implementation}")
    print('='*80)
    
    # Load data
    ground_truth, estimates = load_data(dataset_name, implementation)
    print(f"Cycles: {len(ground_truth)}")
    
    # Compute normalized errors
    print("Computing normalized errors...")
    norm_errors_df = compute_normalized_errors(ground_truth, estimates)
    
    # Analyze consistency
    print("Analyzing consistency...")
    stats_dict = analyze_consistency(norm_errors_df)
    
    # Print results
    print(f"\nCoverage Statistics:")
    print(f"  Within ±1σ: {stats_dict['actual_1sigma']*100:.2f}% (expected: {stats_dict['expected_1sigma']*100:.2f}%)")
    print(f"  Within ±2σ: {stats_dict['actual_2sigma']*100:.2f}% (expected: {stats_dict['expected_2sigma']*100:.2f}%)")
    print(f"  Within ±3σ: {stats_dict['actual_3sigma']*100:.2f}% (expected: {stats_dict['expected_3sigma']*100:.2f}%)")
    
    print(f"\nChi-squared Statistics:")
    print(f"  Mean(error²/σ²): {stats_dict['chi2_mean']:.4f} (expected: {stats_dict['chi2_expected']:.4f})")
    
    print(f"\nNormality Test:")
    print(f"  Shapiro-Wilk p-value: {stats_dict['shapiro_p_value']:.6f}")
    
    # Overall assessment
    if stats_dict['is_consistent_3sigma']:
        print(f"\n✓ COVARIANCE WELL CALIBRATED")
        print(f"  Uncertainty estimates are trustworthy")
    else:
        print(f"\n✗ COVARIANCE MISCALIBRATED")
        if stats_dict['actual_3sigma'] < stats_dict['expected_3sigma']:
            print(f"  Filter is OVERCONFIDENT (underestimating uncertainty)")
        else:
            print(f"  Filter is UNDERCONFIDENT (overestimating uncertainty)")
    
    # Save normalized errors
    csv_file = OUTPUT_DIR / f"normalized_errors_{implementation}_{dataset_name}.csv"
    norm_errors_df.to_csv(csv_file, index=False, float_format='%.6f')
    print(f"\n✓ Normalized errors saved: {csv_file.name}")
    
    # Plot
    plot_file = plot_consistency_analysis(norm_errors_df, dataset_name, implementation, stats_dict)
    print(f"✓ Plot saved: {plot_file.name}")
    
    return stats_dict

def main():
    print("="*80)
    print("COVARIANCE CONSISTENCY ANALYSIS")
    print("="*80)
    print("Validates UKF uncertainty estimates using:")
    print("  - Coverage statistics (% within 1σ, 2σ, 3σ)")
    print("  - Chi-squared test (normalized error distribution)")
    print("  - Normality test (Shapiro-Wilk)")
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Find datasets
    datasets = sorted(DATA_DIR.glob("*.csv"))
    real_world = [d.stem for d in datasets if 'drone_euroc' in d.name or 'f1_' in d.name or 'synthetic' in d.name]
    
    if not real_world:
        print("\n✗ No datasets found")
        return
    
    print(f"\nFound {len(real_world)} datasets")
    
    all_stats = []
    
    for dataset_name in real_world:
        for impl in ['custom', 'filterpy']:
            try:
                stats_dict = analyze_dataset(dataset_name, impl)
                stats_dict['dataset'] = dataset_name
                stats_dict['implementation'] = impl
                all_stats.append(stats_dict)
            except FileNotFoundError as e:
                print(f"\n✗ {impl} outputs not found: {e}")
            except Exception as e:
                print(f"\n✗ Error: {e}")
                import traceback
                traceback.print_exc()
    
    # Summary across all datasets
    if all_stats:
        print(f"\n{'='*80}")
        print("SUMMARY ACROSS ALL DATASETS")
        print('='*80)
        
        summary_df = pd.DataFrame(all_stats)
        
        print("\nAverage Coverage:")
        print(f"  Within ±1σ: {summary_df['actual_1sigma'].mean()*100:.2f}% (expected: 68.27%)")
        print(f"  Within ±2σ: {summary_df['actual_2sigma'].mean()*100:.2f}% (expected: 95.45%)")
        print(f"  Within ±3σ: {summary_df['actual_3sigma'].mean()*100:.2f}% (expected: 99.73%)")
        
        consistent_count = summary_df['is_consistent_3sigma'].sum()
        total_count = len(summary_df)
        print(f"\nWell-calibrated: {consistent_count}/{total_count} ({consistent_count/total_count*100:.1f}%)")
        
        # Save summary
        csv_file = OUTPUT_DIR / "consistency_summary.csv"
        summary_df.to_csv(csv_file, index=False, float_format='%.6f')
        print(f"\n✓ Summary saved: {csv_file}")
    
    print(f"\n{'='*80}")
    print("COVARIANCE ANALYSIS COMPLETE")
    print('='*80)
    print(f"Results: {OUTPUT_DIR}")
    print("\nKey findings:")
    print("  - Well-calibrated filters have ~99.7% errors within 3σ")
    print("  - Underconfident filters overestimate uncertainty (safe but inefficient)")
    print("  - Overconfident filters underestimate uncertainty (DANGEROUS)")

if __name__ == "__main__":
    main()
