# JetsonNanoTracking

Portable Jetson Nano tracking repo for the ECO-based `MyECOTracker` runtime used in this project.

This GitHub repo is prepared so another Jetson Nano can:

1. clone the repo
2. create the runtime environment
3. auto-download the required runtime model assets from Hugging Face
4. run the real-video person-tracking tests with one command

## Quick Start

On the target Jetson Nano:

```bash
git clone https://github.com/shinlnh/JetsonNanoTracking.git
cd JetsonNanoTracking
bash jetson/setup_and_run_real_video_tests.sh pure
```

If the machine uses PowerShell instead of a normal shell, there is also a wrapper:

```powershell
pwsh -File jetson/setup_and_run_real_video_tests.ps1 pure
```

The canonical Jetson entrypoint is still the `.sh` script. The `.ps1` file is only a wrapper around it.

## What The One-Command Flow Does

`jetson/setup_and_run_real_video_tests.sh` will:

1. create or reuse `.venv`
2. install the Jetson Nano runtime dependencies
3. download runtime tracker / detector assets from:
   `https://huggingface.co/shin0412/JetsonNanoTracking`
4. run the three real person-tracking test videos bundled in this repo

Default mode:

- `pure`
  - runs the three historical real-video tests with `verified_otb936_run_update`

Optional modes:

- `yolo`
  - runs the detector-assisted `dualacc_yolo_ts` flow
- `all`
  - runs both `pure` and `yolo`

## Real Video Test Inputs

These three source videos are intentionally kept in Git because they are small enough and are needed for portable repro:

- `jetson/video_inputs/test1/1.mp4`
- `jetson/video_inputs/test2/2.mp4`
- `jetson/video_inputs/test3/3.mp4`

Decoded JPG frames, tracking outputs, logs, reports, and runtime cache are intentionally ignored from Git.

## Runtime Models

GitHub stores code plus the small demo videos.

Runtime model assets are downloaded automatically from Hugging Face by:

- `jetson/download_runtime_assets.py`

Current public asset source:

- `https://huggingface.co/shin0412/JetsonNanoTracking`

See [MODELS.md](MODELS.md) and [pytracking/pretrained_network/README.md](pytracking/pretrained_network/README.md).

## Main Runtime Mapping

The real-video tests use:

- parameter alias: `verified_otb936_run_update`
- alias chain:
  `verified_otb936_run_update -> jetson_fast_trt_rgb_run_update -> jetson_fast_trt_dual_acc`
- TensorRT engine:
  `resnet18_vggmconv1_otb_dual_large_fp16.engine`

For detector-assisted video tests, the detector artifact is:

- `yolo_person_only.torchscript`

## Jetson Assumptions

The portable flow assumes:

- Ubuntu / JetPack already installed on the Jetson
- CUDA / TensorRT runtime available on the device
- Python 3 available as `python3`
- internet access on first setup so runtime assets can be downloaded

The scripts no longer require the checkout to live specifically at `~/HELIOS/MyECOTracker`. They resolve the project root from the script location unless `PROJECT_ROOT` is overridden.

## Other Jetson Commands

Existing benchmark helpers still work:

```bash
bash jetson/run_verified936.sh smoke
bash jetson/run_verified936.sh smoke_run_update
bash jetson/run_verified936.sh real_videos
bash jetson/run_verified936.sh real_videos_yolo
bash jetson/run_verified936.sh real_videos_all
```

## Important Files

- Portable setup wrapper: `jetson/setup_and_run_real_video_tests.sh`
- PowerShell wrapper: `jetson/setup_and_run_real_video_tests.ps1`
- Runtime asset downloader: `jetson/download_runtime_assets.py`
- Real-video runner: `jetson/run_real_video_tests.sh`
- Jetson bootstrap: `jetson/bootstrap_native_verified936.sh`
- Env activation: `jetson/activate_verified936_env.sh`
- Real-video parameter alias: `pytracking/pytracking/parameter/eco/verified_otb936_run_update.py`

## Notes

- The repo is prepared for portability, not for storing heavyweight runtime outputs.
- TensorRT `.engine` files are still hardware / TensorRT-version sensitive. The current setup downloads the exact runtime asset used on the source Nano, but rebuilding on the target may still be necessary if JetPack / TensorRT differs too much.
- The GitHub repo intentionally ignores tracking results, decoded frames, logs, reports, large pretrained networks, and TensorRT build artifacts.
