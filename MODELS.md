Runtime model assets for this project are stored on Hugging Face:

- Repo: `https://huggingface.co/shin0412/JetsonNanoTracking`

They are downloaded automatically by:

- `jetson/download_runtime_assets.py`
- `jetson/setup_and_run_real_video_tests.sh`

## Runtime Assets Used By The Real Video Tests

- Tracker engine:
  `runtime_test_models/tracker/resnet18_vggmconv1_otb_dual_large_fp16.engine`
  ->
  `pytracking/pretrained_network/resnet18_vggmconv1/resnet18_vggmconv1_otb_dual_large_fp16.engine`

- Detector:
  `runtime_test_models/detector/yolo_person_only.torchscript`
  ->
  `jetson/video_models/yolo_person_only.torchscript`

## Test Videos Stored In Git

The three small real-video test inputs are stored directly in GitHub:

- `jetson/video_inputs/test1/1.mp4`
- `jetson/video_inputs/test2/2.mp4`
- `jetson/video_inputs/test3/3.mp4`

Decoded frames are not stored in Git. They are produced locally on the target device during the test run.
