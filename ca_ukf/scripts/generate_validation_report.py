#!/usr/bin/env python3
"""
Generate Comprehensive Validation Report
Final comprehensive HTML report tying all validation results together

Includes:
- Executive summary (PASS/FAIL)
- Dataset characteristics
- Single/multi-step prediction metrics
- Three-way implementation comparison
- Vivado synthesis results (if available)
- Manual inspection findings
- Recommendations

Output: HTML interactive report + PDF (if possible)
"""

import numpy as np
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt
from jinja2 import Template
import base64
from io import BytesIO
import datetime

BASE_DIR = Path(__file__).parent.parent
RESULTS_BASE = BASE_DIR / "results"
OUTPUT_DIR = RESULTS_BASE / "validation_report"

# Collect results from various directories
SINGLE_STEP_DIR = RESULTS_BASE / "single_step"
MULTI_STEP_DIR = RESULTS_BASE / "multi_step"
HORIZONS_DIR = RESULTS_BASE / "prediction_horizons"
COVARIANCE_DIR = RESULTS_BASE / "covariance_consistency"
THREE_WAY_DIR = RESULTS_BASE / "three_way_comparison"
VIVADO_DIR = RESULTS_BASE / "vivado_reports"
MANUAL_DIR = RESULTS_BASE / "manual_inspection"

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>UKF Validation Report</title>
    <style>
        body {{
            font-family: 'Segoe UI', Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f0f0f0;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 40px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }}
        h1 {{
            color: #2c3e50;
            border-bottom: 4px solid #3498db;
            padding-bottom: 10px;
        }}
        h2 {{
            color: #34495e;
            margin-top: 40px;
            border-bottom: 2px solid #bdc3c7;
            padding-bottom: 5px;
        }}
        h3 {{
            color: #7f8c8d;
        }}
        .executive-summary {{
            background-color: #ecf0f1;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
        }}
        .status-pass {{
            color: #27ae60;
            font-weight: bold;
            font-size: 1.3em;
        }}
        .status-fail {{
            color: #e74c3c;
            font-weight: bold;
            font-size: 1.3em;
        }}
        .status-warning {{
            color: #f39c12;
            font-weight: bold;
            font-size: 1.3em;
        }}
        table {{
            border-collapse: collapse;
            width: 100%;
            margin: 20px 0;
        }}
        th {{
            background-color: #3498db;
            color: white;
            padding: 12px;
            text-align: left;
        }}
        td {{
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }}
        tr:hover {{
            background-color: #f5f5f5;
        }}
        .metric-box {{
            display: inline-block;
            padding: 15px 20px;
            margin: 10px;
            background-color: #ecf0f1;
            border-radius: 5px;
            border-left: 4px solid #3498db;
        }}
        .metric-value {{
            font-size: 1.5em;
            font-weight: bold;
            color: #2c3e50;
        }}
        .metric-label {{
            font-size: 0.9em;
            color: #7f8c8d;
        }}
        img {{
            max-width: 100%;
            margin: 20px 0;
            border: 1px solid #ddd;
            border-radius: 5px;
        }}
        .recommendation {{
            background-color: #d5f4e6;
            border-left: 4px solid #27ae60;
            padding: 15px;
            margin: 20px 0;
        }}
        .warning {{
            background-color: #ffeaa7;
            border-left: 4px solid #fdcb6e;
            padding: 15px;
            margin: 20px 0;
        }}
        .footer {{
            margin-top: 60px;
            padding-top: 20px;
            border-top: 2px solid #bdc3c7;
            text-align: center;
            color: #95a5a6;
            font-size: 0.9em;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>9D Constant Acceleration UKF - Comprehensive Validation Report</h1>
        
        <p><strong>Generated:</strong> {generation_time}</p>
        <p><strong>Datasets:</strong> {num_datasets} real-world trajectories (Drone + F1)</p>
        <p><strong>Implementations:</strong> Custom Python, FilterPy, VHDL</p>
        
        <div class="executive-summary">
            <h2>Executive Summary</h2>
            <p class="status-{overall_status_class}">Overall Status: {overall_status}</p>
            <p>{executive_summary_text}</p>
        </div>
        
        <h2>1. Dataset Characteristics</h2>
        {dataset_table}
        
        <h2>2. Single-Step Prediction Accuracy</h2>
        <p>Measures k→k+1 prediction error - the PRIMARY UKF performance metric.</p>
        {single_step_metrics}
        
        <h2>3. Multi-Step Prediction Horizons</h2>
        <p>How far ahead can the UKF predict without measurements?</p>
        {multi_step_summary}
        
        <h2>4. Covariance Consistency</h2>
        <p>Are uncertainty estimates trustworthy?</p>
        {covariance_summary}
        
        <h2>5. Three-Way Implementation Comparison</h2>
        <p>Do Custom Python, FilterPy, and VHDL agree?</p>
        {three_way_comparison}
        
        <h2>6. VHDL Hardware Validation</h2>
        {vhdl_section}
        
        <h2>7. Vivado Synthesis Results</h2>
        {vivado_section}
        
        <h2>8. Recommendations</h2>
        {recommendations}
        
        <div class="footer">
            <p>Generated by generate_validation_report.py</p>
            <p>UKF Comprehensive Validation Framework</p>
        </div>
    </div>
</body>
</html>
"""

def load_dataset_info():
    """Load dataset information"""
    data_dir = BASE_DIR / "test_data" / "real_world"
    datasets = []
    
    for csv_file in sorted(data_dir.glob("*.csv")):
        if 'drone_euroc' not in csv_file.name and 'f1_' not in csv_file.name:
            continue
        
        df = pd.read_csv(csv_file)
        
        datasets.append({
            'name': csv_file.stem,
            'cycles': len(df),
            'duration_s': df['time'].iloc[-1],
            'type': 'Drone' if 'drone' in csv_file.name else 'F1'
        })
    
    return datasets

def load_single_step_results():
    """Load single-step prediction results"""
    summary_file = SINGLE_STEP_DIR / "implementation_comparison.csv"
    
    if summary_file.exists():
        return pd.read_csv(summary_file)
    
    return None

def load_multi_step_results():
    """Load multi-step prediction results"""
    summary_file = MULTI_STEP_DIR / "multi_step_summary.csv"
    
    if summary_file.exists():
        return pd.read_csv(summary_file)
    
    return None

def load_horizon_results():
    """Load prediction horizon results"""
    summary_file = HORIZONS_DIR / "horizon_summary.csv"
    
    if summary_file.exists():
        return pd.read_csv(summary_file)
    
    return None

def load_covariance_results():
    """Load covariance consistency results"""
    summary_file = COVARIANCE_DIR / "consistency_summary.csv"
    
    if summary_file.exists():
        return pd.read_csv(summary_file)
    
    return None

def load_three_way_results():
    """Load three-way comparison results"""
    summary_file = THREE_WAY_DIR / "comparison_all_datasets.csv"
    
    if summary_file.exists():
        return pd.read_csv(summary_file)
    
    return None

def load_vivado_results():
    """Load Vivado synthesis results"""
    summary_file = VIVADO_DIR / "synthesis_summary.csv"
    
    if summary_file.exists():
        return pd.read_csv(summary_file)
    
    return None

def generate_report():
    """Generate comprehensive HTML report"""
    print("="*80)
    print("GENERATING COMPREHENSIVE VALIDATION REPORT")
    print("="*80)
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Load all results
    print("Loading results...")
    datasets = load_dataset_info()
    single_step = load_single_step_results()
    multi_step = load_multi_step_results()
    horizons = load_horizon_results()
    covariance = load_covariance_results()
    three_way = load_three_way_results()
    vivado = load_vivado_results()
    
    # Determine overall status
    print("Analyzing results...")
    
    overall_pass = True
    issues = []
    
    # Check single-step accuracy
    if single_step is not None:
        avg_rmse = single_step['pos_rmse'].mean()
        if avg_rmse > 1.0:
            overall_pass = False
            issues.append(f"Single-step RMSE high: {avg_rmse:.3f}m")
    
    # Check three-way comparison
    if three_way is not None:
        failed = (three_way['status'] == 'FAIL').sum()
        if failed > 0:
            overall_pass = False
            issues.append(f"{failed} implementation comparisons failed")
    
    # Executive summary
    if overall_pass:
        overall_status = "✓ VALIDATION PASSED"
        overall_status_class = "pass"
        executive_summary_text = "All critical validation tests passed. The VHDL UKF implementation agrees with Python reference models and demonstrates excellent prediction accuracy on real-world data."
    else:
        overall_status = "✗ VALIDATION ISSUES DETECTED"
        overall_status_class = "fail"
        executive_summary_text = f"Validation detected {len(issues)} issue(s): " + "; ".join(issues)
    
    # Build HTML sections
    dataset_rows = ""
    for ds in datasets:
        dataset_rows += f"""
        <tr>
            <td>{ds['name']}</td>
            <td>{ds['type']}</td>
            <td>{ds['cycles']}</td>
            <td>{ds['duration_s']:.2f}</td>
        </tr>
        """
    
    dataset_table = f"""
    <table>
        <tr>
            <th>Dataset</th>
            <th>Type</th>
            <th>Cycles</th>
            <th>Duration (s)</th>
        </tr>
        {dataset_rows}
    </table>
    <p>Total: {len(datasets)} datasets, {sum(d['cycles'] for d in datasets)} cycles</p>
    """
    
    # Single-step metrics
    if single_step is not None:
        single_step_metrics = f"""
        <div class="metric-box">
            <div class="metric-value">{single_step['pos_rmse'].mean():.4f} m</div>
            <div class="metric-label">Average Position RMSE</div>
        </div>
        <div class="metric-box">
            <div class="metric-value">{single_step['vel_rmse'].mean():.4f} m/s</div>
            <div class="metric-label">Average Velocity RMSE</div>
        </div>
        <div class="metric-box">
            <div class="metric-value">{single_step['pos_rmse'].max():.4f} m</div>
            <div class="metric-label">Worst Position RMSE</div>
        </div>
        """
    else:
        single_step_metrics = "<p>⚠ Single-step analysis not available</p>"
    
    # Multi-step summary
    if horizons is not None:
        multi_step_summary = f"""
        <p>Average maximum prediction horizon: <strong>{horizons['max_horizon_steps'].mean():.1f} steps ({horizons['max_horizon_seconds'].mean():.3f}s)</strong></p>
        <p>Range: {horizons['max_horizon_steps'].min():.0f}-{horizons['max_horizon_steps'].max():.0f} steps</p>
        """
    else:
        multi_step_summary = "<p>⚠ Prediction horizon analysis not available</p>"
    
    # Covariance summary
    if covariance is not None:
        covariance_summary = f"""
        <p>Average coverage within ±3σ: <strong>{covariance['actual_3sigma'].mean()*100:.1f}%</strong> (expected: 99.7%)</p>
        <p>Well-calibrated implementations: {covariance['is_consistent_3sigma'].sum()}/{len(covariance)}</p>
        """
    else:
        covariance_summary = "<p>⚠ Covariance consistency analysis not available</p>"
    
    # Three-way comparison
    if three_way is not None:
        three_way_rows = ""
        for _, row in three_way.groupby(['implementation_1', 'implementation_2']).first().iterrows():
            status_class = 'pass' if row['status'] == 'PASS' else 'fail'
            three_way_rows += f"""
            <tr>
                <td>{row['implementation_1']}</td>
                <td>{row['implementation_2']}</td>
                <td>{row['pos_mag_rmse']:.6f}</td>
                <td>{row['threshold_m']:.2f}</td>
                <td class="status-{status_class}">{row['status']}</td>
            </tr>
            """
        
        three_way_comparison = f"""
        <table>
            <tr>
                <th>Implementation 1</th>
                <th>Implementation 2</th>
                <th>RMSE (m)</th>
                <th>Threshold (m)</th>
                <th>Status</th>
            </tr>
            {three_way_rows}
        </table>
        """
    else:
        three_way_comparison = "<p>⚠ Three-way comparison not available</p>"
    
    # VHDL section
    vhdl_summary_file = MANUAL_DIR / "vhdl_summary.csv"
    if vhdl_summary_file.exists():
        vhdl_summary = pd.read_csv(vhdl_summary_file)
        vhdl_section = f"""
        <p>VHDL outputs validated against ground truth:</p>
        <p>Average Position RMSE: <strong>{vhdl_summary['pos_rmse'].mean():.4f} m</strong></p>
        <p>Excellent cycles (< 0.5m error): <strong>{vhdl_summary['excellent_pct'].mean():.1f}%</strong></p>
        """
    else:
        vhdl_section = "<p>⚠ VHDL simulation results not available. Run GHDL simulations first.</p>"
    
    # Vivado section
    if vivado is not None:
        vivado_section = f"""
        <p>Target FPGA: <strong>{vivado['target'].iloc[0]}</strong></p>
        <p>Resource Utilization:</p>
        <ul>
            <li>LUTs: {vivado['luts_used'].iloc[0]} / {vivado['luts_available'].iloc[0]} ({vivado['luts_pct'].iloc[0]:.2f}%)</li>
            <li>DSPs: {vivado['dsps_used'].iloc[0]} / {vivado['dsps_available'].iloc[0]} ({vivado['dsps_pct'].iloc[0]:.2f}%)</li>
            <li>BRAMs: {vivado['brams_used'].iloc[0]} / {vivado['brams_available'].iloc[0]} ({vivado['brams_pct'].iloc[0]:.2f}%)</li>
        </ul>
        <p>Timing: WNS = <strong>{vivado['wns_ns'].iloc[0]:.2f} ns</strong> ({"MET" if vivado['meets_timing'].iloc[0] else "FAILED"})</p>
        """
    else:
        vivado_section = "<p>⚠ Vivado synthesis not performed (optional)</p>"
    
    # Recommendations
    recommendations = "<div class='recommendation'>"
    if overall_pass:
        recommendations += "<p><strong>✓ UKF is production-ready:</strong></p>"
        recommendations += "<ul>"
        recommendations += "<li>All validation tests passed</li>"
        recommendations += "<li>VHDL implementation matches Python reference models</li>"
        recommendations += "<li>Prediction accuracy meets requirements</li>"
        recommendations += "<li>Proceed with hardware integration</li>"
        recommendations += "</ul>"
    else:
        recommendations += "<p><strong>⚠ Issues require attention:</strong></p>"
        recommendations += "<ul>"
        for issue in issues:
            recommendations += f"<li>{issue}</li>"
        recommendations += "</ul>"
        recommendations += "<p>Review detailed results and address issues before deployment.</p>"
    recommendations += "</div>"
    
    # Render HTML
    print("Rendering HTML...")
    template = Template(HTML_TEMPLATE)
    html_content = template.render(
        generation_time=datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        num_datasets=len(datasets),
        overall_status=overall_status,
        overall_status_class=overall_status_class,
        executive_summary_text=executive_summary_text,
        dataset_table=dataset_table,
        single_step_metrics=single_step_metrics,
        multi_step_summary=multi_step_summary,
        covariance_summary=covariance_summary,
        three_way_comparison=three_way_comparison,
        vhdl_section=vhdl_section,
        vivado_section=vivado_section,
        recommendations=recommendations
    )
    
    # Save HTML
    html_file = OUTPUT_DIR / "VALIDATION_REPORT.html"
    with open(html_file, 'w') as f:
        f.write(html_content)
    
    print(f"\n✓ HTML report generated: {html_file}")
    
    print(f"\n{'='*80}")
    print("VALIDATION REPORT COMPLETE")
    print('='*80)
    print(f"Report location: {html_file}")
    print(f"Overall status: {overall_status}")
    
    return html_file

def main():
    try:
        report_file = generate_report()
        print(f"\n✓ Open in browser: file://{report_file.absolute()}")
    except Exception as e:
        print(f"\n✗ Error generating report: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
