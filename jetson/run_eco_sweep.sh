#!/usr/bin/env bash
set -euo pipefail
cd /home/helios/HELIOS/MyECOTracker
source jetson/activate_verified936_env.sh >/dev/null
mkdir -p jetson/sweeps
cat > jetson/otb_human_easy3.txt <<'SEQ'
Girl
Walking2
Woman
SEQ
configs=(
  verified_otb936_jetson_fast_trt_vgg
  verified_otb936_jetson_fast_trt_vgg_scale3
  verified_otb936_jetson_fast_trt_gray
  verified_otb936_jetson_fast_trt_rgb
  verified_otb936_jetson_fast_trt_dual
)
run_id=950
for cfg in "${configs[@]}"; do
  echo "=== $cfg (run_id=$run_id) ==="
  python pytracking/pytracking/util_scripts/run_otb_profile.py \
    --tracker-name eco \
    --parameter-name "$cfg" \
    --run-id "$run_id" \
    --display-name "$cfg" \
    --sequence-file jetson/otb_human_easy3.txt \
    --warmup-frames 1 \
    --summary-csv "jetson/sweeps/${cfg}.csv"
  run_id=$((run_id + 1))
done
python - <<'PY'
import csv, glob
rows = []
for path in sorted(glob.glob('jetson/sweeps/*.csv')):
    with open(path, newline='', encoding='utf-8') as fh:
        row = next(csv.DictReader(fh))
    rows.append(row)
rows.sort(key=lambda r: (float(r['AUC']) >= 60.0 and float(r['FPS_weighted_by_frames']) >= 20.0,
                         float(r['AUC']) + 0.2 * float(r['FPS_weighted_by_frames'])), reverse=True)
print('=== SWEEP SUMMARY ===')
for row in rows:
    print('{tracker}\tAUC={AUC}\tFPSw={FPS_weighted_by_frames}\tFPSavg={FPS_avg_seq}'.format(**row))
PY
