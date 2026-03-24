#!/bin/bash
# Script to run isolated cross_covariance_3d testbench

SRC_DIR="../ca_ukf.srcs/sources_1/new"
TB_DIR="../ca_ukf.srcs/sim_1/new"
WORK_DIR="../sim_work"

cd "$(dirname "$0")"

mkdir -p ${WORK_DIR}
cd ${WORK_DIR}

echo "=== Compiling cross_covariance_3d module ==="
ghdl -a --std=08 ${SRC_DIR}/cross_covariance_3d.vhd

echo "=== Compiling isolated testbench ==="
ghdl -a --std=08 ${TB_DIR}/cross_covariance_3d_isolated_tb.vhd

echo "=== Elaborating ==="
ghdl -e --std=08 cross_covariance_3d_isolated_tb

echo "=== Running simulation ==="
ghdl -r --std=08 cross_covariance_3d_isolated_tb \
    --stop-time=10us \
    --assert-level=warning

echo "=== Simulation complete ==="
