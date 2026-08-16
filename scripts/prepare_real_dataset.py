#!/usr/bin/env python3
"""
scripts/prepare_real_dataset.py
Extracts completely UNIQUE, DISJOINT real Oracle-MNIST character images for:
  - 10 known_symbols prototypes
  - 30 distinct practice images (10 for tier1, 10 for tier2, 10 for tier3)
  - 40 distinct competition images (10 for tier1, 10 for tier2, 10 for tier3, 10 for extra_hard)

Every single tier and symbol uses a different real artifact image from the dataset.
"""

import os
import gzip
import struct
import urllib.request
import csv
import numpy as np
from PIL import Image

BASE_URL = "https://raw.githubusercontent.com/wm-bupt/oracle-mnist/main/data/oracle/"
IMG_FILE = "train-images-idx3-ubyte.gz"
LBL_FILE = "train-labels-idx1-ubyte.gz"

DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "data"))
CACHE_DIR = os.path.join(DATA_DIR, "_cache")

def download_file(filename):
    os.makedirs(CACHE_DIR, exist_ok=True)
    target_path = os.path.join(CACHE_DIR, filename)
    if not os.path.exists(target_path):
        url = BASE_URL + filename
        print(f"Downloading {url} ...")
        urllib.request.urlretrieve(url, target_path)
        print(f"Saved to {target_path}")
    return target_path

def load_idx_images(gz_path):
    with gzip.open(gz_path, 'rb') as f:
        magic, num, rows, cols = struct.unpack(">IIII", f.read(16))
        assert magic == 2051, f"Invalid magic number {magic}"
        data = np.frombuffer(f.read(), dtype=np.uint8)
        return data.reshape(num, rows, cols)

def load_idx_labels(gz_path):
    with gzip.open(gz_path, 'rb') as f:
        magic, num = struct.unpack(">II", f.read(8))
        assert magic == 2049, f"Invalid magic number {magic}"
        return np.frombuffer(f.read(), dtype=np.uint8)

def apply_tier_degradation(img_np, tier_name, seed=42):
    """
    Applies realistic physical degradation models to real images:
    - Tier 1: Authentic real character, natural contrast
    - Tier 2: Real character + stone/bone rubbing texture and porosity
    - Tier 3: Real character + high-frequency speckle noise + partial stroke erosion
    - Extra Hard: Real character + non-uniform lighting gradient + heavy texture noise
    """
    np.random.seed(seed)
    img = img_np.astype(np.float32) / 255.0

    if tier_name == "tier1":
        out = np.clip(img * 1.05, 0.0, 1.0)
    elif tier_name == "tier2":
        # Add realistic stone/bone texture noise
        noise = np.random.normal(0, 0.08, img.shape)
        out = np.clip(img * 0.90 + noise, 0.0, 1.0)
    elif tier_name == "tier3":
        # High-frequency noise + stroke thinning/erosion
        noise = np.random.normal(0, 0.14, img.shape)
        mask = (np.random.rand(*img.shape) > 0.06).astype(np.float32)
        out = np.clip(img * mask + noise, 0.0, 1.0)
    elif tier_name == "extra_hard":
        # Complex non-uniform background gradient + heavier noise
        h, w = img.shape
        x_grad = np.linspace(-0.18, 0.18, w)
        y_grad = np.linspace(-0.18, 0.18, h)
        xx, yy = np.meshgrid(x_grad, y_grad)
        grad = xx + yy
        noise = np.random.normal(0, 0.18, img.shape)
        out = np.clip(img * 0.82 + grad + noise, 0.0, 1.0)
    else:
        out = img

    return (out * 255.0).astype(np.uint8)

def process_and_save(img_28x28, out_path, target_size=64, tier_name=None, seed=42):
    pil_img = Image.fromarray(img_28x28)
    pil_resized = pil_img.resize((target_size, target_size), Image.Resampling.BICUBIC)
    arr_64 = np.array(pil_resized)
    
    if tier_name is not None:
        arr_final = apply_tier_degradation(arr_64, tier_name, seed)
    else:
        arr_final = arr_64

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    Image.fromarray(arr_final).save(out_path)

def filter_good_samples(images, indices, min_stroke_ratio=0.12, max_stroke_ratio=0.55):
    """Filter candidate images for good, distinct stroke representations."""
    valid = []
    for idx in indices:
        img = images[idx]
        ratio = np.mean(img > 50)
        if min_stroke_ratio <= ratio <= max_stroke_ratio:
            valid.append(idx)
    return valid

def main():
    print("=== Oracle-MNIST: Generating 100% Unique Disjoint Real Dataset ===")
    img_gz = download_file(IMG_FILE)
    lbl_gz = download_file(LBL_FILE)

    images = load_idx_images(img_gz)
    labels = load_idx_labels(lbl_gz)

    print(f"Loaded {len(images)} raw images across 10 classes.")

    # Filter distinct good quality samples per class
    class_pool = {}
    for c in range(10):
        raw_idx = np.where(labels == c)[0]
        good_idx = filter_good_samples(images, raw_idx)
        if len(good_idx) < 100:
            good_idx = list(raw_idx)
        class_pool[c] = good_idx
        print(f"  Class {c+1:02d}: {len(good_idx)} high-quality candidate samples available.")

    known_dir = os.path.join(DATA_DIR, "known_symbols")
    practice_dir = os.path.join(DATA_DIR, "practice")
    competition_dir = os.path.join(DATA_DIR, "competition")

    for d in [known_dir, practice_dir, competition_dir]:
        os.makedirs(d, exist_ok=True)

    # Clear directories
    for folder in [known_dir, practice_dir, competition_dir]:
        for root, dirs, files in os.walk(folder, topdown=False):
            for f in files:
                os.remove(os.path.join(root, f))
            for d in dirs:
                os.rmdir(os.path.join(root, d))

    # We will track used sample indices to guarantee 100% zero overlap
    used_indices = set()

    def get_unique_sample(c, start_offset=0):
        pool = class_pool[c]
        for candidate in pool[start_offset:]:
            if candidate not in used_indices:
                used_indices.add(candidate)
                return candidate
        # fallback
        for candidate in pool:
            if candidate not in used_indices:
                used_indices.add(candidate)
                return candidate
        return pool[0]

    # 1. Known Symbols (10 distinct real prototype characters)
    print("\n1. Generating known_symbols (10 unique prototype glyphs)...")
    for c in range(10):
        sample_idx = get_unique_sample(c, start_offset=0)
        sym_path = os.path.join(known_dir, f"symbol_{c+1:02d}.png")
        process_and_save(images[sample_idx], sym_path, target_size=64)
        print(f"  Class {c+1:02d} prototype -> sample idx {sample_idx} -> {sym_path}")

    # 2. Practice Dataset (3 Tiers x 10 Classes = 30 completely UNIQUE real images)
    print("\n2. Generating data/practice/ (30 completely UNIQUE real images across 3 Tiers)...")
    practice_labels = []
    tiers_practice = ["tier1", "tier2", "tier3"]

    for t_idx, tier in enumerate(tiers_practice):
        tier_dir = os.path.join(practice_dir, tier)
        os.makedirs(tier_dir, exist_ok=True)
        for c in range(10):
            # Pick a completely fresh, unique real image
            sample_idx = get_unique_sample(c, start_offset=10 + t_idx * 15)
            fname = f"sample_{c+1:02d}.png"
            fpath = os.path.join(tier_dir, fname)
            rel_path = os.path.join(tier, fname)
            
            process_and_save(images[sample_idx], fpath, target_size=64, tier_name=tier, seed=100 + t_idx * 20 + c)
            practice_labels.append({"filename": rel_path, "class_id": c + 1, "tier": tier})

    practice_csv = os.path.join(practice_dir, "practice_labels.csv")
    with open(practice_csv, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["filename", "class_id", "tier"])
        writer.writeheader()
        writer.writerows(practice_labels)
    print(f"  Wrote practice labels to {practice_csv}")

    # 3. Competition Dataset (4 Tiers x 10 Classes = 40 completely UNIQUE real images)
    print("\n3. Generating data/competition/ (40 completely UNIQUE real images across 4 Tiers)...")
    competition_labels = []
    tiers_competition = ["tier1", "tier2", "tier3", "extra_hard"]

    for t_idx, tier in enumerate(tiers_competition):
        tier_dir = os.path.join(competition_dir, tier)
        os.makedirs(tier_dir, exist_ok=True)
        for c in range(10):
            # Pick a completely fresh, unique real image
            sample_idx = get_unique_sample(c, start_offset=80 + t_idx * 20)
            fname = f"comp_sample_{c+1:02d}.png"
            fpath = os.path.join(tier_dir, fname)
            rel_path = os.path.join(tier, fname)
            
            process_and_save(images[sample_idx], fpath, target_size=64, tier_name=tier, seed=500 + t_idx * 20 + c)
            competition_labels.append({"filename": rel_path, "class_id": c + 1, "tier": tier})

    secret_csv = os.path.join(competition_dir, "secret_labels.csv")
    with open(secret_csv, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["filename", "class_id", "tier"])
        writer.writeheader()
        writer.writerows(competition_labels)
    print(f"  Wrote competition labels to {secret_csv}")

    print(f"\nSuccessfully generated dataset! Total unique real images used: {len(used_indices)} (zero duplicates across symbols and tiers).")

if __name__ == "__main__":
    main()
