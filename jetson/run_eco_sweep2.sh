#!/usr/bin/env bash
set -euo pipefail
cd /home/helios/HELIOS/MyECOTracker
source jetson/activate_verified936_env.sh >/dev/null
mkdir -p jetson/sweeps2
configs=(
  verified_otb936_jetson_fast_trt_vgg_scale3
  verified_otb936_jetson_fast_trt_rgb_acc
  verified_otb936_jetson_fast_trt_rgb_scale3
  verified_otb936_jetson_fast_trt_dual_acc
)
run_id=960
for cfg in "${configs[@]}"; do
  echo "=== $cfg (run_id=$run_id) ==="
  python pytracking/pytracking/util_scripts/run_otb_profile.py \
    --tracker-name eco \
    --parameter-name "$cfg" \
    --run-id "$run_id" \
    --display-name "$cfg" \
    --sequence-file jetson/otb_human_easy3.txt \
    --warmup-frames 1 \
    --summary-csv "jetson/sweeps2/${cfg}.csv"
  run_id=$((run_id + 1))
done
