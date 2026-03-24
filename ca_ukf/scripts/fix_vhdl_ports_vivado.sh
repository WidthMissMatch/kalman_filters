#!/bin/bash
# Systematic fix for VHDL port mode issues
# Changes 'out' ports that are read internally to 'buffer' ports

echo "=========================================="
echo "Fixing VHDL Port Modes for Vivado"
echo "=========================================="

cd /home/arunupscee/Desktop/xtortion/ca_ukf

# Fix ukf_supreme_3d component declarations in ukf_supreme_3d.vhd
echo "Fixing ukf_supreme_3d.vhd component declarations..."
sed -i '140,160s/: out signed/: buffer signed/g' ca_ukf.srcs/sources_1/new/ukf_supreme_3d.vhd

# Also fix the prediction_phase_3d component declaration if needed
echo "Checking prediction_phase_3d.vhd..."
grep -n "_upd.*: out signed" ca_ukf.srcs/sources_1/new/prediction_phase_3d.vhd 2>/dev/null && \
  sed -i 's/_upd : out signed/_upd : buffer signed/g' ca_ukf.srcs/sources_1/new/prediction_phase_3d.vhd

# Fix covariance_reconstruct_3d if it has similar issues
echo "Checking covariance_reconstruct_3d.vhd..."
grep -n "_cov.*: out signed" ca_ukf.srcs/sources_1/new/covariance_reconstruct_3d.vhd 2>/dev/null && \
  sed -i 's/_cov : out signed/_cov : buffer signed/g; s/p[0-9][0-9]_upd : out signed/p\1_upd : buffer signed/g' ca_ukf.srcs/sources_1/new/covariance_reconstruct_3d.vhd

# Fix innovation_3d.vhd
echo "Checking innovation_3d.vhd..."
grep -n "innov.*: out signed" ca_ukf.srcs/sources_1/new/innovation_3d.vhd 2>/dev/null && \
  sed -i 's/innov_[xyz] : out signed/innov_\1 : buffer signed/g' ca_ukf.srcs/sources_1/new/innovation_3d.vhd

# Fix innovation_covariance_3d.vhd
echo "Checking innovation_covariance_3d.vhd..."
grep -n "s[0-9][0-9].*: out signed" ca_ukf.srcs/sources_1/new/innovation_covariance_3d.vhd 2>/dev/null && \
  sed -i 's/s[0-9][0-9] : out signed/s\1 : buffer signed/g' ca_ukf.srcs/sources_1/new/innovation_covariance_3d.vhd

# Fix measurement_mean_3d.vhd
echo "Checking measurement_mean_3d.vhd..."
grep -n "z_.*_mean.*: out signed" ca_ukf.srcs/sources_1/new/measurement_mean_3d.vhd 2>/dev/null && \
  sed -i 's/z_[xyz]_mean_pred : out signed/z_\1_mean_pred : buffer signed/g' ca_ukf.srcs/sources_1/new/measurement_mean_3d.vhd

echo ""
echo "=========================================="
echo "Port fixes complete!"
echo "=========================================="
echo "Modified files:"
echo "  - ukf_supreme_3d.vhd"
echo "  - prediction_phase_3d.vhd"
echo "  - covariance_reconstruct_3d.vhd"
echo "  - innovation_3d.vhd"
echo "  - innovation_covariance_3d.vhd"
echo "  - measurement_mean_3d.vhd"
echo ""
