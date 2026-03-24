#!/usr/bin/env python3
"""
Vivado Batch Runner
Python wrapper for Vivado TCL automation scripts

Runs Vivado simulations and synthesis from the Python validation pipeline.
Parses Vivado reports and integrates results with comparison framework.

Usage:
  python run_vivado_batch.py --mode simulation --dataset drone_euroc_mh01
  python run_vivado_batch.py --mode synthesis --target zcu106
"""

import subprocess
import argparse
from pathlib import Path
import re
import pandas as pd

BASE_DIR = Path(__file__).parent.parent
VIVADO_BIN = "/home/arunupscee/vivado/2025.1/Vivado/bin/vivado"
TCL_DIR = BASE_DIR / "scripts"
VIVADO_OUTPUT_DIR = BASE_DIR / "results" / "vhdl_outputs" / "vivado"
VIVADO_REPORTS_DIR = BASE_DIR / "results" / "vivado_reports"

def check_vivado_installed():
    """Check if Vivado is installed"""
    vivado_path = Path(VIVADO_BIN)
    if not vivado_path.exists():
        raise FileNotFoundError(
            f"Vivado not found at: {VIVADO_BIN}\n"
            f"Update VIVADO_BIN path in this script"
        )
    print(f"✓ Vivado found: {VIVADO_BIN}")

def run_vivado_tcl(tcl_script, args_dict=None):
    """Run Vivado with TCL script"""
    print(f"\nRunning Vivado TCL script: {tcl_script.name}")
    
    # Build command
    cmd = [VIVADO_BIN, "-mode", "batch", "-source", str(tcl_script)]
    
    # Add TCL arguments if provided
    if args_dict:
        for key, value in args_dict.items():
            cmd.extend(["-tclargs", f"{key}={value}"])
    
    print(f"Command: {' '.join(cmd)}")
    
    # Run
    try:
        result = subprocess.run(
            cmd,
            cwd=BASE_DIR,
            capture_output=True,
            text=True,
            timeout=3600  # 1 hour timeout
        )
        
        print("\n=== Vivado Output ===")
        print(result.stdout)
        
        if result.stderr:
            print("\n=== Vivado Errors/Warnings ===")
            print(result.stderr)
        
        if result.returncode != 0:
            print(f"\n✗ Vivado exited with code {result.returncode}")
            return False
        
        print("\n✓ Vivado completed successfully")
        return True
        
    except subprocess.TimeoutExpired:
        print("\n✗ Vivado timeout (> 1 hour)")
        return False
    except Exception as e:
        print(f"\n✗ Error running Vivado: {e}")
        return False

def parse_utilization_report(report_file):
    """Parse Vivado utilization report"""
    if not report_file.exists():
        print(f"✗ Report not found: {report_file}")
        return None
    
    print(f"\nParsing utilization report: {report_file.name}")
    
    utilization = {}
    
    with open(report_file, 'r') as f:
        content = f.read()
        
        # Extract LUTs
        lut_match = re.search(r'Slice LUTs\s+\|\s+(\d+)\s+\|\s+(\d+)\s+\|\s+([\d.]+)', content)
        if lut_match:
            utilization['luts_used'] = int(lut_match.group(1))
            utilization['luts_available'] = int(lut_match.group(2))
            utilization['luts_pct'] = float(lut_match.group(3))
        
        # Extract DSPs
        dsp_match = re.search(r'DSPs\s+\|\s+(\d+)\s+\|\s+(\d+)\s+\|\s+([\d.]+)', content)
        if dsp_match:
            utilization['dsps_used'] = int(dsp_match.group(1))
            utilization['dsps_available'] = int(dsp_match.group(2))
            utilization['dsps_pct'] = float(dsp_match.group(3))
        
        # Extract BRAMs
        bram_match = re.search(r'Block RAM Tile\s+\|\s+(\d+)\s+\|\s+(\d+)\s+\|\s+([\d.]+)', content)
        if bram_match:
            utilization['brams_used'] = int(bram_match.group(1))
            utilization['brams_available'] = int(bram_match.group(2))
            utilization['brams_pct'] = float(bram_match.group(3))
    
    if utilization:
        print("  Resource Utilization:")
        print(f"    LUTs:  {utilization.get('luts_used', 'N/A')} / {utilization.get('luts_available', 'N/A')} ({utilization.get('luts_pct', 0):.2f}%)")
        print(f"    DSPs:  {utilization.get('dsps_used', 'N/A')} / {utilization.get('dsps_available', 'N/A')} ({utilization.get('dsps_pct', 0):.2f}%)")
        print(f"    BRAMs: {utilization.get('brams_used', 'N/A')} / {utilization.get('brams_available', 'N/A')} ({utilization.get('brams_pct', 0):.2f}%)")
    
    return utilization

def parse_timing_report(report_file):
    """Parse Vivado timing report"""
    if not report_file.exists():
        print(f"✗ Report not found: {report_file}")
        return None
    
    print(f"\nParsing timing report: {report_file.name}")
    
    timing = {}
    
    with open(report_file, 'r') as f:
        content = f.read()
        
        # Extract WNS (Worst Negative Slack)
        wns_match = re.search(r'WNS\(ns\)\s+([-\d.]+)', content)
        if wns_match:
            timing['wns_ns'] = float(wns_match.group(1))
            timing['meets_timing'] = timing['wns_ns'] >= 0
        
        # Extract TNS (Total Negative Slack)
        tns_match = re.search(r'TNS\(ns\)\s+([-\d.]+)', content)
        if tns_match:
            timing['tns_ns'] = float(tns_match.group(1))
        
        # Extract max frequency
        freq_match = re.search(r'Max Frequency:\s+([\d.]+)\s+MHz', content)
        if freq_match:
            timing['max_freq_mhz'] = float(freq_match.group(1))
    
    if timing:
        print("  Timing Results:")
        print(f"    WNS: {timing.get('wns_ns', 'N/A')} ns")
        print(f"    TNS: {timing.get('tns_ns', 'N/A')} ns")
        print(f"    Max Frequency: {timing.get('max_freq_mhz', 'N/A')} MHz")
        
        if timing.get('meets_timing'):
            print("    ✓ Timing constraints MET")
        else:
            print("    ✗ Timing constraints FAILED")
    
    return timing

def run_simulation(dataset_name):
    """Run Vivado simulation for dataset"""
    print(f"\n{'='*80}")
    print(f"VIVADO SIMULATION: {dataset_name}")
    print('='*80)
    
    VIVADO_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    tcl_script = TCL_DIR / "run_vivado_simulation.tcl"
    
    if not tcl_script.exists():
        print(f"✗ TCL script not found: {tcl_script}")
        return False
    
    # Run simulation
    success = run_vivado_tcl(tcl_script, {'dataset': dataset_name})
    
    return success

def run_synthesis(target_fpga="zcu106"):
    """Run Vivado synthesis"""
    print(f"\n{'='*80}")
    print(f"VIVADO SYNTHESIS: {target_fpga}")
    print('='*80)
    
    VIVADO_REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    
    tcl_script = TCL_DIR / "run_vivado_synthesis.tcl"
    
    if not tcl_script.exists():
        print(f"✗ TCL script not found: {tcl_script}")
        return False
    
    # Run synthesis
    success = run_vivado_tcl(tcl_script, {'target': target_fpga})
    
    if success:
        # Parse reports
        utilization = parse_utilization_report(VIVADO_REPORTS_DIR / "utilization.rpt")
        timing = parse_timing_report(VIVADO_REPORTS_DIR / "timing.rpt")
        
        # Save summary
        summary = {
            'target': target_fpga,
            **utilization,
            **timing
        }
        
        summary_df = pd.DataFrame([summary])
        csv_file = VIVADO_REPORTS_DIR / "synthesis_summary.csv"
        summary_df.to_csv(csv_file, index=False)
        print(f"\n✓ Synthesis summary saved: {csv_file}")
    
    return success

def main():
    parser = argparse.ArgumentParser(description='Vivado Batch Runner')
    parser.add_argument('--mode', type=str, choices=['simulation', 'synthesis'], required=True,
                        help='Vivado operation mode')
    parser.add_argument('--dataset', type=str, help='Dataset name for simulation')
    parser.add_argument('--target', type=str, default='zcu106', help='FPGA target for synthesis')
    args = parser.parse_args()
    
    print("="*80)
    print("VIVADO BATCH RUNNER")
    print("="*80)
    
    # Check Vivado installation
    check_vivado_installed()
    
    # Run requested mode
    if args.mode == 'simulation':
        if not args.dataset:
            print("\n✗ --dataset required for simulation mode")
            return
        
        success = run_simulation(args.dataset)
    
    elif args.mode == 'synthesis':
        success = run_synthesis(args.target)
    
    # Exit code
    exit(0 if success else 1)

if __name__ == "__main__":
    main()
