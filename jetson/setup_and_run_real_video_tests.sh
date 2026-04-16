#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
MODE="${1:-pure}"

export PROJECT_ROOT

bash "$SCRIPT_DIR/bootstrap_native_verified936.sh"
bash "$SCRIPT_DIR/run_real_video_tests.sh" "$MODE"
