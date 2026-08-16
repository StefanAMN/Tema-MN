#!/usr/bin/env python3
"""
scripts/prepare_real_dataset.py
Downloads the official Oracle-MNIST benchmark dataset (real Shang Dynasty Oracle Bone Inscriptions),
normalizes images to 64x64, and partitions them into:
  - data/known_symbols/ (10 reference prototypes)
  - data/practice/ (30 real images on 3 Tiers: tier1, tier2, tier3) + practice_labels.csv
  - data/competition/ (40 distinct real images on 4 Tiers: tier1, tier2, tier3, extra_hard) + secret_labels.csv
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
    Applies realistic physical degradation models:
    - Tier 1: Clean real image with mild contrast normalization
    - Tier 2: Texture noise (porosity of stone/bone rubbings) + minor blur
    - Tier 3: High-frequency speckle noise + erosion / stroke thinning
    - Extra Hard: Non-uniform background illumination gradient + heavy noise
    """
    np.random.seed(seed)
    img = img_np.astype(np.float32) / 255.0

    if tier_name == "tier1":
        out = np.clip(img * 1.05, 0.0, 1.0)
    elif tier_name == "tier2":
        noise = np.random.normal(0, 0.08, img.shape)
        out = np.clip(img * 0.9 + noise, 0.0, 1.0)
    elif tier_name == "tier3":
        noise = np.random.normal(0, 0.15, img.shape)
        mask = (np.random.rand(*img.shape) > 0.08).astype(np.float32)
        out = np.clip(img * mask + noise, 0.0, 1.0)
    elif tier_name == "extra_hard":
        h, w = img.shape
        x_grad = np.linspace(-0.2, 0.2, w)
        y_grad = np.linspace(-0.2, 0.2, h)
        xx, yy = np.meshgrid(x_grad, y_grad)
        grad = xx + yy
        noise = np.random.normal(0, 0.20, img.shape)
        out = np.clip(img * 0.8 + grad + noise, 0.0, 1.0)
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

def main():
    print("=== Oracle-MNIST Real Dataset Preparation ===")
    img_gz = download_file(IMG_FILE)
    lbl_gz = download_file(LBL_FILE)

    images = load_idx_images(img_gz)
    labels = load_idx_labels(lbl_gz)

    print(f"Loaded {len(images)} raw images across classes: {np.unique(labels)}")

    class_indices = {c: np.where(labels == c)[0] for c in range(10)}

    known_dir = os.path.join(DATA_DIR, "known_symbols")
    practice_dir = os.path.join(DATA_DIR, "practice")
    competition_dir = os.path.join(DATA_DIR, "competition")

    for d in [known_dir, practice_dir, competition_dir]:
        os.makedirs(d, exist_ok=True)

    # 1. Clean existing known_symbols and create 10 prototype glyphs
    for f in os.listdir(known_dir):
        fp = os.path.join(known_dir, f)
        if os.path.isfile(fp):
            os.remove(fp)

    print("\n1. Generating known_symbols (10 prototype glyphs)...")
    for c in range(10):
        idx_list = class_indices[c]
        chosen_idx = idx_list[0]
        for candidate in idx_list[:50]:
            if np.mean(images[candidate] > 50) > 0.15:
                chosen_idx = candidate
                break
        
        sym_path = os.path.join(known_dir, f"symbol_{c+1:02d}.png")
        process_and_save(images[chosen_idx], sym_path, target_size=64)
        print(f"  Class {c+1:02d} -> {sym_path}")

    # 2. Populate Practice Dataset (30 real images on 3 Tiers)
    print("\n2. Generating data/practice/ (3 Tiers x 10 Classes)...")
    practice_labels = []
    tiers_practice = ["tier1", "tier2", "tier3"]

    for t_idx, tier in enumerate(tiers_practice):
        tier_dir = os.path.join(practice_dir, tier)
        os.makedirs(tier_dir, exist_ok=True)
        for c in range(10):
            sample_idx = class_indices[c][10 + t_idx * 5]
            fname = f"sample_{c+1:02d}.png"
            fpath = os.path.join(tier_dir, fname)
            rel_path = os.path.join(tier, fname)
            
            process_and_save(images[sample_idx], fpath, target_size=64, tier_name=tier, seed=100 + t_idx * 10 + c)
            practice_labels.append({"filename": rel_path, "class_id": c + 1, "tier": tier})

    practice_csv = os.path.join(practice_dir, "practice_labels.csv")
    with open(practice_csv, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["filename", "class_id", "tier"])
        writer.writeheader()
        writer.writerows(practice_labels)
    print(f"  Wrote practice labels to {practice_csv}")

    # 3. Populate Competition Dataset (40 distinct real images on 4 Tiers)
    print("\n3. Generating data/competition/ (4 Tiers x 10 Classes)...")
    competition_labels = []
    tiers_competition = ["tier1", "tier2", "tier3", "extra_hard"]

    for t_idx, tier in enumerate(tiers_competition):
        tier_dir = os.path.join(competition_dir, tier)
        os.makedirs(tier_dir, exist_ok=True)
        for c in range(10):
            sample_idx = class_indices[c][100 + t_idx * 7]
            fname = f"comp_sample_{c+1:02d}.png"
            fpath = os.path.join(tier_dir, fname)
            rel_path = os.path.join(tier, fname)
            
            process_and_save(images[sample_idx], fpath, target_size=64, tier_name=tier, seed=500 + t_idx * 10 + c)
            competition_labels.append({"filename": rel_path, "class_id": c + 1, "tier": tier})

    secret_csv = os.path.join(competition_dir, "secret_labels.csv")
    with open(secret_csv, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["filename", "class_id", "tier"])
        writer.writeheader()
        writer.writerows(competition_labels)
    print(f"  Wrote competition labels to {secret_csv}")

    print("\nDataset preparation completed successfully!")

if __name__ == "__main__":
    main()
