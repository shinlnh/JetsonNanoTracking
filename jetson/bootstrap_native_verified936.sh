#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
VENV_DIR="${VENV_DIR:-$PROJECT_ROOT/.venv}"
TORCH_BOX_URL="${TORCH_BOX_URL:-https://nvidia.box.com/shared/static/fjtbno0vpo676a25cgvuqc1wty0fkkg6.whl}"
RECREATE_VENV="${RECREATE_VENV:-0}"

mkdir -p "$PROJECT_ROOT" "$HOME/opt/libomp_pkgs" "$HOME/opt/libomp_root" \
         "$HOME/opt/openmpi_pkgs" "$HOME/opt/openmpi_root" \
         "$HOME/opt/hwloc_pkgs" "$HOME/opt/hwloc_root" \
         "$HOME/opt/torch_wheels"

if [ "$RECREATE_VENV" = "1" ] && [ -d "$VENV_DIR" ]; then
  rm -rf "$VENV_DIR"
fi

if ! python3 -m virtualenv --version >/dev/null 2>&1; then
  python3 -m pip install --user "virtualenv==20.17.1"
fi

if [ ! -d "$VENV_DIR" ]; then
  python3 -m virtualenv --system-site-packages "$VENV_DIR"
fi

"$VENV_DIR/bin/pip" install --no-cache-dir "numpy==1.19.4" "pillow<9" pyyaml tqdm visdom

cd "$HOME/opt/libomp_pkgs"
apt-get download libomp5-8 libomp-8-dev >/dev/null
for deb in ./*.deb; do dpkg-deb -x "$deb" "$HOME/opt/libomp_root"; done

cd "$HOME/opt/openmpi_pkgs"
apt-get download libopenmpi2 >/dev/null
for deb in ./*.deb; do dpkg-deb -x "$deb" "$HOME/opt/openmpi_root"; done

cd "$HOME/opt/hwloc_pkgs"
apt-get download libhwloc5 libhwloc-plugins >/dev/null
for deb in ./*.deb; do dpkg-deb -x "$deb" "$HOME/opt/hwloc_root"; done

cd "$HOME/opt/torch_wheels"
wget --content-disposition -O torch-1.10.0-cp36-cp36m-linux_aarch64.whl "$TORCH_BOX_URL"

export LD_LIBRARY_PATH="$HOME/opt/libomp_root/usr/lib/llvm-8/lib:$HOME/opt/openmpi_root/usr/lib/aarch64-linux-gnu:$HOME/opt/openmpi_root/usr/lib/aarch64-linux-gnu/openmpi/lib:$HOME/opt/hwloc_root/usr/lib/aarch64-linux-gnu:${LD_LIBRARY_PATH:-}"
"$VENV_DIR/bin/pip" install --no-cache-dir ./torch-1.10.0-cp36-cp36m-linux_aarch64.whl

echo
echo "Bootstrap complete."
echo "Next:"
echo "  source \"$PROJECT_ROOT/jetson/activate_verified936_env.sh\""
echo "  bash \"$PROJECT_ROOT/jetson/setup_and_run_real_video_tests.sh\" pure"
