#!/bin/bash
# Cleanup ca_ukf project - keep only essential UKF CA files

set -e

echo "================================================"
echo "  UKF CA Project Cleanup"
echo "================================================"
echo ""

# Create backup before cleanup
BACKUP_DIR="ca_ukf_backup_$(date +%Y%m%d_%H%M%S)"
echo "Creating backup: $BACKUP_DIR"
cp -r ca_ukf "$BACKUP_DIR"
echo "✓ Backup created"
echo ""

# Remove old/unused VHDL source files
echo "Removing unused VHDL source files..."
cd ca_ukf/ca_ukf.srcs/sources_1/new

# Remove CV model (not needed for CA)
rm -f predicti_cv3d.vhd
echo "  ✓ Removed predicti_cv3d.vhd (CV model)"

# Remove 6x6 Cholesky (for CV, not CA)
rm -f cholsky_6.vhd
echo "  ✓ Removed cholsky_6.vhd (6x6 Cholesky)"

# Remove old/unused components
rm -f inverse_newsy.vhd
echo "  ✓ Removed inverse_newsy.vhd (unused reciprocal)"

rm -f sqrt_newton.vhd
echo "  ✓ Removed sqrt_newton.vhd (alternative sqrt)"

rm -f sqrt_digit_recurrence.vhd
echo "  ✓ Removed sqrt_digit_recurrence.vhd (alternative sqrt)"

rm -f divider_pipelined.vhd
echo "  ✓ Removed divider_pipelined.vhd (unused)"

# Remove backup/old versions
rm -f cholesky_column_parallel.vhd
echo "  ✓ Removed cholesky_column_parallel.vhd (old version)"

rm -f cholsky_9_col78.vhd
echo "  ✓ Removed cholsky_9_col78.vhd (old version)"

rm -f cholsky_9_phase2_backup.vhd
echo "  ✓ Removed cholsky_9_phase2_backup.vhd (backup)"

rm -f cholsky_9_phase2.vhd
echo "  ✓ Removed cholsky_9_phase2.vhd (old version)"

rm -f covariance_reconstruct_3d_phase2.vhd
echo "  ✓ Removed covariance_reconstruct_3d_phase2.vhd (old version)"

rm -f kalman_gain_3d_phase1.vhd
echo "  ✓ Removed kalman_gain_3d_phase1.vhd (old version)"

rm -f matrix_inverse_3x3_baseline.vhd
echo "  ✓ Removed matrix_inverse_3x3_baseline.vhd (old version)"

cd ../../../..

echo ""
echo "Cleaning simulation files..."
# Clean simulation directory but keep final outputs
if [ -d "ca_ukf/ca_ukf.sim" ]; then
    # Keep F1 outputs
    mkdir -p ca_ukf_temp_outputs
    cp -r ca_ukf/ca_ukf.sim/sim_1/behav/xsim/*.txt ca_ukf_temp_outputs/ 2>/dev/null || true

    # Remove simulation directory
    rm -rf ca_ukf/ca_ukf.sim
    echo "  ✓ Removed simulation cache"
fi

echo ""
echo "Cleaning build files..."
# Remove cache directories
rm -rf ca_ukf/ca_ukf.cache
echo "  ✓ Removed .cache directory"

# Remove generated files
rm -rf ca_ukf/ca_ukf.gen
echo "  ✓ Removed .gen directory"

# Remove IP user files
rm -rf ca_ukf/ca_ukf.ip_user_files
echo "  ✓ Removed .ip_user_files directory"

echo ""
echo "Cleaning logs and temporary files..."
# Remove log files in root
rm -f ca_ukf/vivado*.log
rm -f ca_ukf/vivado*.jou
rm -f ca_ukf/*.log
echo "  ✓ Removed Vivado logs"

# Remove TCL scripts (keep only necessary ones)
cd ca_ukf
rm -f run_f1_*_clean.tcl
rm -f run_all_f1_circuits.sh
echo "  ✓ Removed temporary TCL scripts"

cd ..

echo ""
echo "Organizing results..."
# Keep results directory organized
if [ -d "ca_ukf/results" ]; then
    echo "  ✓ Results directory preserved"
else
    echo "  ⚠  No results directory found"
fi

echo ""
echo "================================================"
echo "  Essential Files Remaining:"
echo "================================================"
echo ""
echo "VHDL Sources (23 files for UKF CA):"
echo "  ├── cholesky_multiplier_array.vhd (package)"
echo "  ├── ukf_supreme_3d.vhd (top level)"
echo "  ├── prediction_phase_3d.vhd"
echo "  ├── measurement_update_3d.vhd"
echo "  ├── predicti_ca3d.vhd (CA motion model)"
echo "  ├── cholsky_9.vhd (9×9 Cholesky)"
echo "  ├── sigma_3d.vhd"
echo "  ├── predicted_mean_3d.vhd"
echo "  ├── covariance_reconstruct_3d.vhd"
echo "  ├── process_noise_3d.vhd"
echo "  ├── measurement_mean_3d.vhd"
echo "  ├── innovation_3d.vhd"
echo "  ├── cross_covariance_3d.vhd"
echo "  ├── innovation_covariance_3d.vhd"
echo "  ├── kalman_gain_3d.vhd"
echo "  ├── state_update_3d.vhd"
echo "  ├── matrix_inverse_3x3.vhd"
echo "  ├── sqrt_cordic.vhd"
echo "  ├── cholesky_col2_parallel.vhd"
echo "  ├── cholesky_col3_parallel.vhd"
echo "  ├── cholesky_col4_parallel.vhd"
echo "  ├── cholesky_col5_parallel.vhd"
echo "  └── cholesky_col678_parallel.vhd"
echo ""

# Verify essential files exist
cd ca_ukf/ca_ukf.srcs/sources_1/new
ESSENTIAL_FILES=(
    "cholesky_multiplier_array.vhd"
    "ukf_supreme_3d.vhd"
    "prediction_phase_3d.vhd"
    "measurement_update_3d.vhd"
    "predicti_ca3d.vhd"
    "cholsky_9.vhd"
    "sigma_3d.vhd"
    "predicted_mean_3d.vhd"
    "covariance_reconstruct_3d.vhd"
    "process_noise_3d.vhd"
    "measurement_mean_3d.vhd"
    "innovation_3d.vhd"
    "cross_covariance_3d.vhd"
    "innovation_covariance_3d.vhd"
    "kalman_gain_3d.vhd"
    "state_update_3d.vhd"
    "matrix_inverse_3x3.vhd"
    "sqrt_cordic.vhd"
    "cholesky_col2_parallel.vhd"
    "cholesky_col3_parallel.vhd"
    "cholesky_col4_parallel.vhd"
    "cholesky_col5_parallel.vhd"
    "cholesky_col678_parallel.vhd"
)

MISSING_FILES=0
for file in "${ESSENTIAL_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "✗ ERROR: Missing essential file: $file"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

cd ../../../..

if [ $MISSING_FILES -eq 0 ]; then
    echo "✓ All 23 essential UKF CA files verified"
else
    echo "✗ WARNING: $MISSING_FILES essential files missing!"
fi

echo ""
echo "Remaining VHDL files:"
ls -1 ca_ukf/ca_ukf.srcs/sources_1/new/*.vhd | wc -l
echo ""

echo "================================================"
echo "  Cleanup Complete!"
echo "================================================"
echo ""
echo "Backup saved to: $BACKUP_DIR"
echo "Project cleaned: ca_ukf/"
echo ""
