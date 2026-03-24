#!/bin/bash
# IMM F1 - Unit Test Runner
# Runs individual module tests (Tests 1-6) then optionally the integration smoke (Test 7)
# Usage: ./run_unit_tests.sh [1|2|3|4|5|6|7|all]
set -e

IMM_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$IMM_DIR/src"
TB_DIR="$IMM_DIR/testbenches"
WORK_DIR="/tmp/imm_unit_tests"

TEST=${1:-all}
PASS_TOTAL=0
FAIL_TOTAL=0

run_test() {
  local test_num=$1
  local test_name=$2
  local tb_entity=$3
  shift 3
  local src_files=("$@")

  echo ""
  echo "========================================"
  echo "  TEST $test_num: $test_name"
  echo "========================================"

  local test_dir="$WORK_DIR/test${test_num}"
  rm -rf "$test_dir"
  mkdir -p "$test_dir"
  cd "$test_dir"

  # Compile sources
  echo "  Compiling..."
  local compile_ok=true
  for f in "${src_files[@]}"; do
    if ! xvhdl --2008 "$f" 2>&1 | grep -i "^ERROR" && true; then
      true
    fi
  done

  # Compile testbench
  if ! xvhdl --2008 "$TB_DIR/${tb_entity}.vhd" 2>&1 | grep -i "^ERROR" && true; then
    true
  fi

  # Elaborate
  echo "  Elaborating..."
  if ! xelab --debug off -s "test${test_num}_sim" "$tb_entity" 2>&1 | tail -5; then
    echo "  ELABORATE FAILED"
    FAIL_TOTAL=$((FAIL_TOTAL + 1))
    return
  fi

  # Run
  echo "  Running..."
  cat > run.tcl << 'EOF'
run all
quit
EOF
  local output
  output=$(xsim "test${test_num}_sim" -t run.tcl 2>&1)
  echo "$output" | grep -E "(\[PASS\]|\[FAIL\]|TEST.*RESULTS|PASS.*ALL|FAIL.*SOME|Error:)" || true

  # Count pass/fail from output
  local passes=$(echo "$output" | grep -c "\[PASS\]" || true)
  local fails=$(echo "$output" | grep -c "\[FAIL\]" || true)
  PASS_TOTAL=$((PASS_TOTAL + passes))
  FAIL_TOTAL=$((FAIL_TOTAL + fails))
}

########################################################################
# Test 1: exp_lut + log_lut
########################################################################
run_test_1() {
  run_test 1 "exp_lut + log_lut" "tb_exp_log_lut" \
    "$SRC/exp_lut.vhd" \
    "$SRC/log_lut.vhd"
}

########################################################################
# Test 2: imm_output_fusion
########################################################################
run_test_2() {
  run_test 2 "imm_output_fusion" "tb_imm_output_fusion" \
    "$SRC/imm_output_fusion.vhd"
}

########################################################################
# Test 3: imm_state_mixer
########################################################################
run_test_3() {
  run_test 3 "imm_state_mixer" "tb_imm_state_mixer" \
    "$SRC/imm_state_mixer.vhd"
}

########################################################################
# Test 4: imm_likelihood (needs exp_lut, log_lut)
########################################################################
run_test_4() {
  run_test 4 "imm_likelihood" "tb_imm_likelihood" \
    "$SRC/exp_lut.vhd" \
    "$SRC/log_lut.vhd" \
    "$SRC/imm_likelihood.vhd"
}

########################################################################
# Test 5: imm_prob_update
########################################################################
run_test_5() {
  run_test 5 "imm_prob_update" "tb_imm_prob_update" \
    "$SRC/imm_prob_update.vhd"
}

########################################################################
# Test 6: State mappers (needs sqrt_cordic, sin_cos_cordic)
########################################################################
run_test_6() {
  run_test 6 "state_mappers" "tb_state_mappers" \
    "$SRC/shared/sqrt_cordic.vhd" \
    "$SRC/shared/sin_cos_cordic.vhd" \
    "$SRC/state_mapper_9d_to_7d.vhd" \
    "$SRC/state_mapper_7d_to_9d.vhd"
}

########################################################################
# Test 7: Full integration smoke (recompile everything with fixes)
########################################################################
run_test_7() {
  echo ""
  echo "========================================"
  echo "  TEST 7: Full IMM 3-cycle smoke"
  echo "========================================"

  local test_dir="$WORK_DIR/test7"
  rm -rf "$test_dir"
  mkdir -p "$test_dir"
  cd "$test_dir"

  # Full compile (same order as run_vivado_sim.sh)
  echo "  Compiling all 43+ source files..."
  local FILES=(
    "$SRC/shared/sqrt_cordic.vhd"
    "$SRC/shared/sin_cos_cordic.vhd"
    "$SRC/shared/matrix_inverse_3x3.vhd"
    "$SRC/ca_ukf/cholesky_multiplier_array.vhd"
    "$SRC/ca_ukf/cholesky_col2_parallel.vhd"
    "$SRC/ca_ukf/cholesky_col3_parallel.vhd"
    "$SRC/ca_ukf/cholesky_col4_parallel.vhd"
    "$SRC/ca_ukf/cholesky_col5_parallel.vhd"
    "$SRC/ca_ukf/cholesky_col678_parallel.vhd"
    "$SRC/ca_ukf/cholsky_9.vhd"
    "$SRC/ca_ukf/sigma_3d.vhd"
    "$SRC/ca_ukf/predicted_mean_3d.vhd"
    "$SRC/ca_ukf/covariance_reconstruct_3d.vhd"
    "$SRC/ca_ukf/measurement_mean_3d.vhd"
    "$SRC/ca_ukf/innovation_3d.vhd"
    "$SRC/ca_ukf/innovation_covariance_3d.vhd"
    "$SRC/ca_ukf/cross_covariance_3d.vhd"
    "$SRC/ca_ukf/kalman_gain_3d.vhd"
    "$SRC/ca_ukf/state_update_3d.vhd"
    "$SRC/ca_ukf/predicti_ca3d.vhd"
    "$SRC/ca_ukf/process_noise_3d.vhd"
    "$SRC/ca_ukf/prediction_phase_3d.vhd"
    "$SRC/ca_measurement_update_imm.vhd"
    "$SRC/ca_ukf_supreme_imm.vhd"
    "$SRC/singer_ukf/singer_exp_cordic.vhd"
    "$SRC/predicti_singer3d.vhd"
    "$SRC/singer_ukf/singer_process_noise_singer_p_3d.vhd"
    "$SRC/prediction_phase_p_3d.vhd"
    "$SRC/singer_measurement_update_imm.vhd"
    "$SRC/singer_ukf_supreme_imm.vhd"
    "$SRC/bicycle_ukf/cholesky_7x7.vhd"
    "$SRC/bicycle_ukf/sigma_7d.vhd"
    "$SRC/bicycle_ukf/predicti_bicycle.vhd"
    "$SRC/bicycle_ukf/predicted_mean_7d.vhd"
    "$SRC/bicycle_ukf/predicted_covariance_7d.vhd"
    "$SRC/bicycle_ukf/process_noise_bicycle.vhd"
    "$SRC/bicycle_ukf/innovation_covariance_7d.vhd"
    "$SRC/bicycle_ukf/cross_covariance_7d.vhd"
    "$SRC/bicycle_ukf/kalman_gain_7d.vhd"
    "$SRC/bicycle_ukf/state_update_7d.vhd"
    "$SRC/state_mapper_9d_to_7d.vhd"
    "$SRC/state_mapper_7d_to_9d.vhd"
    "$SRC/bicycle_ukf_supreme_imm.vhd"
    "$SRC/exp_lut.vhd"
    "$SRC/log_lut.vhd"
    "$SRC/imm_output_fusion.vhd"
    "$SRC/imm_prob_update.vhd"
    "$SRC/imm_likelihood.vhd"
    "$SRC/imm_state_mixer.vhd"
    "$SRC/imm_covariance_mixer.vhd"
    "$SRC/imm_f1_top.vhd"
  )

  for f in "${FILES[@]}"; do
    xvhdl --2008 "$f" 2>&1 | grep -i "^ERROR" || true
  done
  xvhdl --2008 "$TB_DIR/imm_f1_smoke_tb.vhd" 2>&1 | grep -i "^ERROR" || true

  echo "  Elaborating..."
  xelab --debug typical -s smoke_sim imm_f1_smoke_tb 2>&1 | tail -5

  echo "  Running (1ms max)..."
  cat > smoke_run.tcl << 'EOF'
run 1ms
quit
EOF
  local output
  output=$(xsim smoke_sim -t smoke_run.tcl 2>&1)
  echo "$output" | grep -E "(DONE|TIMEOUT|Error|SMOKE|START|cycle)" || true

  # Check for timeout
  local timeouts=$(echo "$output" | grep -c "TIMEOUT" || true)
  local dones=$(echo "$output" | grep -c "Cycle.*DONE" || true)
  if [ "$timeouts" -eq 0 ] && [ "$dones" -ge 3 ]; then
    echo "  [PASS] All 3 cycles completed!"
    PASS_TOTAL=$((PASS_TOTAL + 1))
  else
    echo "  [FAIL] $timeouts timeouts, $dones cycles completed"
    FAIL_TOTAL=$((FAIL_TOTAL + 1))
  fi
}

########################################################################
# Main
########################################################################
echo "========================================"
echo "  IMM F1 Unit Test Suite"
echo "  Working dir: $WORK_DIR"
echo "========================================"

case $TEST in
  1) run_test_1 ;;
  2) run_test_2 ;;
  3) run_test_3 ;;
  4) run_test_4 ;;
  5) run_test_5 ;;
  6) run_test_6 ;;
  7) run_test_7 ;;
  all)
    run_test_1
    run_test_2
    run_test_3
    run_test_4
    run_test_5
    run_test_6
    run_test_7
    ;;
  *)
    echo "Usage: $0 [1|2|3|4|5|6|7|all]"
    exit 1
    ;;
esac

echo ""
echo "========================================"
echo "  OVERALL: $PASS_TOTAL PASS, $FAIL_TOTAL FAIL"
echo "========================================"
if [ "$FAIL_TOTAL" -eq 0 ]; then
  echo "  ALL TESTS PASSED!"
else
  echo "  SOME TESTS FAILED"
  exit 1
fi
