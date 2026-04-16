#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
MODE="${1:-pure}"
TRACKER_NAME="${TRACKER_NAME:-eco}"
TRACKER_PARAM="${TRACKER_PARAM:-verified_otb936_run_update}"
RUN_ROOT="${RUN_ROOT:-$PROJECT_ROOT/jetson/video_runs/portable}"
CACHE_ROOT="${CACHE_ROOT:-$PROJECT_ROOT/jetson/video_cache}"
VIDEO_MODEL_PATH="${VIDEO_MODEL_PATH:-$PROJECT_ROOT/jetson/video_models/yolo_person_only.torchscript}"

export PROJECT_ROOT

python3 "$SCRIPT_DIR/download_runtime_assets.py" --profile "$MODE"

# shellcheck disable=SC1090
source "$SCRIPT_DIR/activate_verified936_env.sh"

mkdir -p "$RUN_ROOT" "$CACHE_ROOT"

run_pure_test() {
  local test_name="$1"
  local init_x="$2"
  local init_y="$3"
  local init_w="$4"
  local init_h="$5"
  local video_path="$PROJECT_ROOT/jetson/video_inputs/$test_name/${test_name#test}.mp4"
  local frames_dir="$CACHE_ROOT/$test_name/decoded_jpg"
  local output_dir="$RUN_ROOT/$test_name/pure_predecoded_dualacc"

  mkdir -p "$output_dir"

  python3 "$PROJECT_ROOT/jetson/run_myeco_predecoded_fps.py" \
    "$video_path" \
    --frames-dir "$frames_dir" \
    --output-dir "$output_dir" \
    --init-xywh "$init_x" "$init_y" "$init_w" "$init_h" \
    --tracker-name "$TRACKER_NAME" \
    --param "$TRACKER_PARAM" \
    --reuse-frames

  echo
  echo "[pure] $test_name summary"
  grep -E '^(video_path|frames_decoded|param|fps_including_init|fps_excluding_init)=' "$output_dir/metrics.txt" || true
  echo
}

run_yolo_test() {
  local test_name="$1"
  local video_path="$PROJECT_ROOT/jetson/video_inputs/$test_name/${test_name#test}.mp4"
  local output_dir="$RUN_ROOT/$test_name/dualacc_yolo_ts"

  mkdir -p "$output_dir"

  python3 "$PROJECT_ROOT/jetson/run_myeco_yolo_onnx_video.py" \
    "$video_path" \
    --model-path "$VIDEO_MODEL_PATH" \
    --tracker-name "$TRACKER_NAME" \
    --param "$TRACKER_PARAM" \
    --output-dir "$output_dir" \
    --input-size 640 \
    --detector-backend torchscript \
    --device cuda \
    --detector-conf 0.25 \
    --detect-interval 5 \
    --low-score-threshold 0.72

  echo
  echo "[yolo] $test_name summary"
  grep -E '^(video_path|param|frames_processed|overall_fps|detection_calls|soft_corrections|hard_reinits)=' "$output_dir/metrics.txt" || true
  echo
}

case "$MODE" in
  pure)
    run_pure_test test1 212.184288 257.928192 144.936000 457.832448
    run_pure_test test2 216.375840 276.175872 156.336192 485.984256
    run_pure_test test3 209.488032 237.759488 173.271744 503.552000
    ;;
  yolo)
    run_yolo_test test1
    run_yolo_test test2
    ;;
  all)
    run_pure_test test1 212.184288 257.928192 144.936000 457.832448
    run_pure_test test2 216.375840 276.175872 156.336192 485.984256
    run_pure_test test3 209.488032 237.759488 173.271744 503.552000
    run_yolo_test test1
    run_yolo_test test2
    ;;
  *)
    echo "Unknown mode: $MODE" >&2
    echo "Usage: $0 {pure|yolo|all}" >&2
    exit 1
    ;;
esac
