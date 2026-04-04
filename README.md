# JetsonNanoTracking

Code-only Jetson Nano tracking repository for the ECO-based `MyECOTracker` setup used in this project. The focus of this repo is a practical TensorRT-accelerated ECO run on Jetson Nano, plus the scripts needed to bootstrap the device and reproduce the selected benchmark run.

This repository does not include large model weights, ONNX exports, TensorRT engines, datasets, logs, or tracking results. Those assets are intentionally stored outside GitHub.

## What This Repo Contains

- A trimmed `pytracking` codebase with ECO changes and TensorRT integration.
- Jetson Nano shell scripts for environment bootstrap and reproducible runs.
- Multiple Jetson-oriented ECO parameter variants under `pytracking/pytracking/parameter/eco/`.
- A canonical main run alias: `verified_otb936_main`.

## Main Run

The default benchmark profile is:

- Parameter alias: `verified_otb936_main`
- Backing profile: `jetson_fast_trt_rgb`
- Tracker family: `eco`
- Main engine: `pytracking/pretrained_network/resnet18_vggmconv1/resnet18_vggmconv1_otb_small_fp16.engine`

This alias is defined in [pytracking/pytracking/parameter/eco/verified_otb936_main.py](pytracking/pytracking/parameter/eco/verified_otb936_main.py).

## Benchmark Snapshot

Selected main run on the small tuning subset used during speed and accuracy search:

| Dataset / split | AUC | FPS avg seq |
| --- | ---: | ---: |
| `Girl + Walking2 + Woman` | `59.2330` | `27.5965` |

Full OTB100 run on Jetson Nano:

| Metric | Value |
| --- | ---: |
| `AUC_mean` | `49.5614` |
| `FPS_avg_seq` | `27.4311` |
| `FPS_weighted_by_frames` | `27.2438` |

## Model Assets

GitHub is code-only. Download weights and TensorRT engines from Hugging Face:

- Namespace: `https://huggingface.co/shin0412`
- TensorRT engine repo: `https://huggingface.co/shin0412/jetsonnano-eco-engines`

See [MODELS.md](MODELS.md) and [pytracking/pretrained_network/README.md](pytracking/pretrained_network/README.md).

At minimum, the main run expects this engine to exist locally:

```text
pytracking/pretrained_network/resnet18_vggmconv1/resnet18_vggmconv1_otb_small_fp16.engine
```

If you keep the repo code in a different location, make sure `MYECO_NETWORK_PATH` points to the matching `pretrained_network` directory.

## Repository Layout

```text
JetsonNanoTracking/
|- jetson/
|  |- bootstrap_native_verified936.sh
|  |- activate_verified936_env.sh
|  |- run_verified936.sh
|  |- run_eco_sweep.sh
|  `- run_eco_sweep2.sh
|- pytracking/
|  |- pretrained_network/
|  `- pytracking/
|     |- experiments/
|     |- features/
|     |- parameter/eco/
|     `- tracker/
|- requirements-jetson.txt
|- requirements-jetson-freeze.txt
`- MODELS.md
```

## Jetson Nano Setup

The Jetson scripts assume this checkout lives at:

```bash
~/HELIOS/MyECOTracker
```

If you want to keep a different path, export `PROJECT_ROOT` before calling the scripts.

### 1. Clone

```bash
git clone https://github.com/shinlnh/JetsonNanoTracking.git ~/HELIOS/MyECOTracker
cd ~/HELIOS/MyECOTracker
```

### 2. Put models in place

Create the pretrained network directory if needed, then place the required `.pth` and `.engine` assets under:

```bash
~/HELIOS/MyECOTracker/pytracking/pretrained_network/
```

For the selected main run, the important engine path is:

```bash
~/HELIOS/MyECOTracker/pytracking/pretrained_network/resnet18_vggmconv1/resnet18_vggmconv1_otb_small_fp16.engine
```

### 3. Bootstrap the Jetson environment

```bash
cd ~/HELIOS/MyECOTracker
bash jetson/bootstrap_native_verified936.sh
```

This script creates `.venv`, downloads the Jetson-compatible PyTorch wheel, and installs the minimal runtime dependencies used on the source Nano.

### 4. Activate the environment

```bash
source jetson/activate_verified936_env.sh
```

By default, the activation script expects:

- `MYECO_NETWORK_PATH=$PROJECT_ROOT/pytracking/pretrained_network`
- `MYECO_OTB_PATH=$HOME/HELIOS/otb/otb100`
- `MYECO_LASOT_PATH=$HOME/HELIOS/ls/lasot`

Override them before sourcing the script if your datasets live elsewhere.

## Running

### Smoke test

```bash
bash jetson/run_verified936.sh smoke
```

### Full OTB100 using the main run

```bash
bash jetson/run_verified936.sh otb
```

### Small OTB sanity run

```bash
bash jetson/run_verified936.sh otb_easy3
```

### LaSOT runs

```bash
bash jetson/run_verified936.sh lasot
bash jetson/run_verified936.sh lasot_first20
bash jetson/run_verified936.sh lasot_headtail40
```

## Important Files

- Main alias: [pytracking/pytracking/parameter/eco/verified_otb936_main.py](pytracking/pytracking/parameter/eco/verified_otb936_main.py)
- Main profile: [pytracking/pytracking/parameter/eco/jetson_fast_trt_rgb.py](pytracking/pytracking/parameter/eco/jetson_fast_trt_rgb.py)
- Experiment entrypoints: [pytracking/pytracking/experiments/myexperiments.py](pytracking/pytracking/experiments/myexperiments.py)
- Jetson runner: [jetson/run_verified936.sh](jetson/run_verified936.sh)
- Runtime dependency list: [requirements-jetson.txt](requirements-jetson.txt)
- Frozen reference environment: [requirements-jetson-freeze.txt](requirements-jetson-freeze.txt)

## Notes

- `requirements-jetson.txt` is the practical install target for the Nano.
- `requirements-jetson-freeze.txt` is only a reference snapshot from the original device.
- TensorRT `.engine` files are hardware and TensorRT-version sensitive. Rebuilding on the target device is safer than assuming portability.
- The repository ignores tracking results, result plots, large models, ONNX exports, and TensorRT engines on purpose.

## Upstream References

- PyTracking: `https://github.com/visionml/pytracking`
- ECO paper: `https://openaccess.thecvf.com/content_iccv_2017/html/Danelljan_ECO_Efficient_Convolution_ICCV_2017_paper.html`
