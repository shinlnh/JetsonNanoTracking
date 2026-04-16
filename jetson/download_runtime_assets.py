#!/usr/bin/env python3
from __future__ import print_function

import argparse
import hashlib
import os
import sys
import urllib.request
from pathlib import Path


ASSET_BASE_URL = "https://huggingface.co/shin0412/JetsonNanoTracking/resolve/main"

ASSETS = {
    "tracker_engine": {
        "repo_path": "runtime_test_models/tracker/resnet18_vggmconv1_otb_dual_large_fp16.engine",
        "local_rel_path": "pytracking/pretrained_network/resnet18_vggmconv1/resnet18_vggmconv1_otb_dual_large_fp16.engine",
        "sha256": "4526B031E323AD3B9C7A4B3B9F65BCA48D9A05A2AEF928314D5FC990E5B5CB86",
    },
    "yolo_person_torchscript": {
        "repo_path": "runtime_test_models/detector/yolo_person_only.torchscript",
        "local_rel_path": "jetson/video_models/yolo_person_only.torchscript",
        "sha256": "154E9ABC777BA6414A6659428AA7272D378C1BF075EEB12C962F3A20C4AA7C86",
    },
    "test1_video": {
        "repo_path": "runtime_test_videos/test1/1.mp4",
        "local_rel_path": "jetson/video_inputs/test1/1.mp4",
        "sha256": "4FAD52417A1D5FE591D6C8A716D7C5851B9525EA5E35E69CCD4748A20678F44D",
    },
    "test2_video": {
        "repo_path": "runtime_test_videos/test2/2.mp4",
        "local_rel_path": "jetson/video_inputs/test2/2.mp4",
        "sha256": "098E365C56DE97BB030B05592FBFA081A6FE1DC1F7D7740B7B802F447B512598",
    },
    "test3_video": {
        "repo_path": "runtime_test_videos/test3/3.mp4",
        "local_rel_path": "jetson/video_inputs/test3/3.mp4",
        "sha256": "5AA36A098362C0AAFDE8C912A17728A495AAE49604B91AE101EFF7D0C708235C",
    },
}

PROFILES = {
    "pure": ["tracker_engine", "test1_video", "test2_video", "test3_video"],
    "yolo": ["tracker_engine", "yolo_person_torchscript", "test1_video", "test2_video"],
    "all": ["tracker_engine", "yolo_person_torchscript", "test1_video", "test2_video", "test3_video"],
}


def parse_args():
    parser = argparse.ArgumentParser(description="Download runtime models and demo videos for JetsonNanoTracking.")
    parser.add_argument("--profile", choices=sorted(PROFILES.keys()), default="all", help="Named runtime asset bundle.")
    parser.add_argument("--project-root", type=Path, default=None, help="Override project root.")
    parser.add_argument("--force", action="store_true", help="Redownload even if a matching file already exists.")
    return parser.parse_args()


def resolve_project_root(cli_root):
    if cli_root is not None:
        return cli_root.expanduser().resolve()

    env_root = os.environ.get("PROJECT_ROOT")
    if env_root:
        return Path(env_root).expanduser().resolve()

    return Path(__file__).resolve().parents[1]


def sha256sum(path):
    digest = hashlib.sha256()
    with path.open("rb") as f:
        while True:
            chunk = f.read(1024 * 1024)
            if not chunk:
                break
            digest.update(chunk)
    return digest.hexdigest().upper()


def download_file(url, destination):
    tmp_path = destination.with_suffix(destination.suffix + ".part")
    if tmp_path.exists():
        tmp_path.unlink()

    with urllib.request.urlopen(url) as response:
        total = response.headers.get("Content-Length")
        total = int(total) if total is not None else None
        downloaded = 0
        with tmp_path.open("wb") as f:
            while True:
                chunk = response.read(1024 * 1024)
                if not chunk:
                    break
                f.write(chunk)
                downloaded += len(chunk)
                if total:
                    percent = 100.0 * downloaded / float(total)
                    print("[download] {:.1f}% {}".format(percent, destination.name))
                else:
                    print("[download] {} bytes {}".format(downloaded, destination.name))

    tmp_path.replace(destination)


def ensure_asset(project_root, base_url, asset_name, force=False):
    spec = ASSETS[asset_name]
    destination = project_root / spec["local_rel_path"]
    destination.parent.mkdir(parents=True, exist_ok=True)

    if destination.exists() and not force:
        current_hash = sha256sum(destination)
        if current_hash == spec["sha256"]:
            print("[skip] {} already present".format(spec["local_rel_path"]))
            return destination
        print("[replace] {} hash mismatch".format(spec["local_rel_path"]))

    url = "{}/{}".format(base_url.rstrip("/"), spec["repo_path"])
    print("[fetch] {} -> {}".format(url, destination))
    download_file(url, destination)

    final_hash = sha256sum(destination)
    if final_hash != spec["sha256"]:
        raise RuntimeError(
            "SHA256 mismatch for {}: expected {}, got {}".format(
                destination, spec["sha256"], final_hash
            )
        )

    print("[ok] {}".format(spec["local_rel_path"]))
    return destination


def main():
    args = parse_args()
    project_root = resolve_project_root(args.project_root)
    base_url = os.environ.get("MYECO_HF_ASSET_BASE_URL", ASSET_BASE_URL)

    if not (project_root / "pytracking").is_dir():
        raise RuntimeError("PROJECT_ROOT does not look like JetsonNanoTracking: {}".format(project_root))

    print("[assets] project_root={}".format(project_root))
    print("[assets] base_url={}".format(base_url))
    print("[assets] profile={}".format(args.profile))

    for asset_name in PROFILES[args.profile]:
        ensure_asset(project_root, base_url, asset_name, force=args.force)

    print("[assets] done")
    return 0


if __name__ == "__main__":
    sys.exit(main())
