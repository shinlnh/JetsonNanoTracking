#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
VENV_DIR="${VENV_DIR:-$PROJECT_ROOT/.venv}"

default_lasot_path="$PROJECT_ROOT/lasot"
if [ ! -d "$default_lasot_path" ]; then
  default_lasot_path="$HOME/HELIOS/ls/lasot"
fi

default_otb_path="$PROJECT_ROOT/otb/otb100"
if [ ! -d "$default_otb_path" ]; then
  default_otb_path="$HOME/HELIOS/otb/otb100"
fi

if [ ! -d "$VENV_DIR" ]; then
  echo "Missing virtualenv: $VENV_DIR" >&2
  return 1 2>/dev/null || exit 1
fi

if [ ! -d "$PROJECT_ROOT/pytracking" ]; then
  echo "Missing project root: $PROJECT_ROOT/pytracking" >&2
  return 1 2>/dev/null || exit 1
fi

export LD_LIBRARY_PATH="$HOME/opt/libomp_root/usr/lib/llvm-8/lib:$HOME/opt/openmpi_root/usr/lib/aarch64-linux-gnu:$HOME/opt/openmpi_root/usr/lib/aarch64-linux-gnu/openmpi/lib:$HOME/opt/hwloc_root/usr/lib/aarch64-linux-gnu:${LD_LIBRARY_PATH:-}"
export PYTHONPATH="$PROJECT_ROOT/pytracking:${PYTHONPATH:-}"
export MYECO_NETWORK_PATH="${MYECO_NETWORK_PATH:-$PROJECT_ROOT/pytracking/pretrained_network}"
export MYECO_LASOT_PATH="${MYECO_LASOT_PATH:-$default_lasot_path}"
export MYECO_OTB_PATH="${MYECO_OTB_PATH:-$default_otb_path}"
export MYECO_HF_ASSET_BASE_URL="${MYECO_HF_ASSET_BASE_URL:-https://huggingface.co/shin0412/JetsonNanoTracking/resolve/main}"

# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

echo "[myeco] venv=$VENV_DIR"
echo "[myeco] project=$PROJECT_ROOT"
echo "[myeco] MYECO_NETWORK_PATH=$MYECO_NETWORK_PATH"
echo "[myeco] MYECO_LASOT_PATH=$MYECO_LASOT_PATH"
echo "[myeco] MYECO_OTB_PATH=$MYECO_OTB_PATH"
echo "[myeco] MYECO_HF_ASSET_BASE_URL=$MYECO_HF_ASSET_BASE_URL"
