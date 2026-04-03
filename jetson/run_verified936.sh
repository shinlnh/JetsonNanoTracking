#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$HOME/HELIOS/MyECOTracker}"

# shellcheck disable=SC1090
source "$SCRIPT_DIR/activate_verified936_env.sh"

MODE="${1:-smoke}"
MAIN_PARAM_NAME="${MAIN_PARAM_NAME:-verified_otb936_main}"

run_pytracking() {
  local experiment="$1"
  shift || true
  python3 "$PROJECT_ROOT/pytracking/pytracking/run_experiment.py" myexperiments "$experiment" "$@"
}

require_dir() {
  local path="$1"
  local name="$2"
  if [ ! -d "$path" ]; then
    echo "Missing $name dataset dir: $path" >&2
    exit 1
  fi
}

case "$MODE" in
  smoke)
    python3 - <<'PY'
import numpy as np
from pytracking.parameter.eco.verified_otb936_main import parameters
from pytracking.tracker.eco import get_tracker_class

params = parameters()
tracker = get_tracker_class()(params)
image = np.zeros((256, 256, 3), dtype=np.uint8)
info = {'init_bbox': [60, 70, 80, 90]}
tracker.initialize(image, info)
print('verified_otb936_main smoke init: OK')
PY
    ;;
  otb)
    require_dir "$MYECO_OTB_PATH" "OTB100"
    run_pytracking eco_verified_otb936_otb --debug 0 --threads 0
    ;;
  otb_easy3)
    require_dir "$MYECO_OTB_PATH" "OTB100"
    run_pytracking eco_verified_otb936_otb_easy3 --debug 0 --threads 0
    ;;
  lasot)
    require_dir "$MYECO_LASOT_PATH" "LaSOT"
    run_pytracking eco_verified_otb936_lasot --debug 0 --threads 0
    ;;
  lasot_first20)
    require_dir "$MYECO_LASOT_PATH" "LaSOT"
    run_pytracking eco_verified_otb936_lasot_first20 --debug 0 --threads 0
    ;;
  lasot_headtail40)
    require_dir "$MYECO_LASOT_PATH" "LaSOT"
    run_pytracking eco_verified_otb936_lasot_headtail40 --debug 0 --threads 0
    ;;
  *)
    echo "Unknown mode: $MODE" >&2
    echo "Usage: $0 {smoke|otb|otb_easy3|lasot|lasot_first20|lasot_headtail40}" >&2
    exit 1
    ;;
esac
