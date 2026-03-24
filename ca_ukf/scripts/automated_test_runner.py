#!/usr/bin/env python3
"""
Automated Test Runner
Master pipeline orchestrator - runs all validation steps automatically

This is the ONE-CLICK validation framework that executes:
  1. Dataset format validation
  2. FilterPy UKF runs
  3. Parameter verification
  4. Single-step prediction analysis
  5. Multi-step prediction analysis
  6. Prediction horizon estimation
  7. Covariance consistency analysis
  8. GHDL/Vivado simulations (if requested)
  9. Three-way implementation comparison
  10. Final validation report generation

Estimated runtime: 20-30 minutes (without Vivado)
                    1-2 hours (with Vivado synthesis)
"""

import subprocess
import sys
from pathlib import Path
import time
import argparse

BASE_DIR = Path(__file__).parent.parent
SCRIPTS_DIR = BASE_DIR / "scripts"

class TestRunner:
    """Orchestrates automated validation pipeline"""
    
    def __init__(self, include_vivado=False, quick_mode=False):
        self.include_vivado = include_vivado
        self.quick_mode = quick_mode
        self.results = {}
        self.start_time = time.time()
    
    def run_script(self, script_name, description, required=True):
        """Run a Python script and track results"""
        print(f"\n{'='*80}")
        print(f"STEP: {description}")
        print(f"Script: {script_name}")
        print('='*80)
        
        script_path = SCRIPTS_DIR / script_name
        
        if not script_path.exists():
            msg = f"Script not found: {script_path}"
            print(f"✗ {msg}")
            if required:
                self.results[description] = {'status': 'FAILED', 'error': msg}
                return False
            else:
                self.results[description] = {'status': 'SKIPPED', 'error': msg}
                return True
        
        step_start = time.time()
        
        try:
            result = subprocess.run(
                [sys.executable, str(script_path)],
                cwd=BASE_DIR,
                capture_output=True,
                text=True,
                timeout=1800  # 30 minute timeout per script
            )
            
            duration = time.time() - step_start
            
            # Print output
            if result.stdout:
                print(result.stdout)
            
            if result.stderr:
                print("STDERR:")
                print(result.stderr)
            
            if result.returncode == 0:
                print(f"\n✓ {description} completed in {duration:.1f}s")
                self.results[description] = {'status': 'PASSED', 'duration_s': duration}
                return True
            else:
                print(f"\n✗ {description} failed (exit code {result.returncode})")
                self.results[description] = {'status': 'FAILED', 'error': f'Exit code {result.returncode}', 'duration_s': duration}
                return False
        
        except subprocess.TimeoutExpired:
            duration = time.time() - step_start
            msg = f"Timeout after {duration:.1f}s"
            print(f"\n✗ {description} {msg}")
            self.results[description] = {'status': 'FAILED', 'error': msg, 'duration_s': duration}
            return False
        
        except Exception as e:
            duration = time.time() - step_start
            msg = str(e)
            print(f"\n✗ {description} error: {msg}")
            self.results[description] = {'status': 'FAILED', 'error': msg, 'duration_s': duration}
            return False
    
    def run_pipeline(self):
        """Execute full validation pipeline"""
        print("="*80)
        print("AUTOMATED UKF VALIDATION PIPELINE")
        print("="*80)
        print(f"Mode: {'Quick' if self.quick_mode else 'Full'}")
        print(f"Vivado: {'Included' if self.include_vivado else 'Skipped'}")
        print(f"Start time: {time.strftime('%Y-%m-%d %H:%M:%S')}")
        
        # Phase 1: Dataset validation
        self.run_script(
            "validate_dataset_format.py",
            "1. Validate dataset format",
            required=True
        )
        
        # Phase 2: FilterPy runs
        self.run_script(
            "run_filterpy_on_dataset.py",
            "2. Run FilterPy UKF on datasets",
            required=True
        )
        
        self.run_script(
            "verify_ukf_parameters.py",
            "3. Verify UKF parameter matching",
            required=True
        )
        
        # Phase 3: Prediction analysis
        self.run_script(
            "analyze_single_step_prediction.py",
            "4. Analyze single-step prediction",
            required=True
        )
        
        if not self.quick_mode:
            self.run_script(
                "analyze_multi_step_prediction.py",
                "5. Analyze multi-step prediction",
                required=False
            )
            
            self.run_script(
                "prediction_horizon_estimator.py",
                "6. Estimate prediction horizons",
                required=False
            )
            
            self.run_script(
                "analyze_covariance_consistency.py",
                "7. Analyze covariance consistency",
                required=False
            )
        
        # Phase 4: VHDL simulation (if requested)
        if self.include_vivado:
            print("\n⚠ Vivado simulations requested but require manual testbench generation")
            print("Run: python generate_vhdl_testbench_with_inspection.py --all")
            print("Then: python run_vivado_batch.py --mode simulation --dataset <name>")
        
        # Phase 5: Comparison and reporting
        self.run_script(
            "compare_three_implementations.py",
            "8. Three-way implementation comparison",
            required=False
        )
        
        self.run_script(
            "generate_validation_report.py",
            "9. Generate final validation report",
            required=True
        )
        
        # Summary
        total_duration = time.time() - self.start_time
        self.print_summary(total_duration)
    
    def print_summary(self, total_duration):
        """Print final summary"""
        print(f"\n{'='*80}")
        print("VALIDATION PIPELINE SUMMARY")
        print('='*80)
        print(f"Total duration: {total_duration/60:.1f} minutes")
        
        passed = sum(1 for r in self.results.values() if r['status'] == 'PASSED')
        failed = sum(1 for r in self.results.values() if r['status'] == 'FAILED')
        skipped = sum(1 for r in self.results.values() if r['status'] == 'SKIPPED')
        
        print(f"\nResults:")
        print(f"  ✓ Passed:  {passed}")
        print(f"  ✗ Failed:  {failed}")
        print(f"  ⊘ Skipped: {skipped}")
        print(f"  Total:     {len(self.results)}")
        
        print("\nStep Details:")
        for step, result in self.results.items():
            status_symbol = {'PASSED': '✓', 'FAILED': '✗', 'SKIPPED': '⊘'}[result['status']]
            duration_str = f"({result.get('duration_s', 0):.1f}s)" if 'duration_s' in result else ""
            error_str = f" - {result['error']}" if 'error' in result else ""
            print(f"  {status_symbol} {step} {duration_str}{error_str}")
        
        if failed == 0:
            print("\n✓ ALL CRITICAL TESTS PASSED")
            print("UKF validation complete - check final report")
        else:
            print(f"\n✗ {failed} TESTS FAILED")
            print("Review error messages above")
        
        print(f"\nFinal report: results/validation_report/")

def main():
    parser = argparse.ArgumentParser(description='Automated UKF Validation Pipeline')
    parser.add_argument('--vivado', action='store_true', 
                        help='Include Vivado simulation and synthesis steps')
    parser.add_argument('--quick', action='store_true',
                        help='Quick mode (skip optional analysis steps)')
    args = parser.parse_args()
    
    runner = TestRunner(
        include_vivado=args.vivado,
        quick_mode=args.quick
    )
    
    runner.run_pipeline()

if __name__ == "__main__":
    main()
