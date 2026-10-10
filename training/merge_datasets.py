import shutil
import time
from pathlib import Path
import yaml

RAW = Path("raw")
OUT = Path("merged")

FINAL = ["crosswalk", "ped_red", "ped_green", "pothole", "stairs",
         "curb", "manhole", "pole", "barrier"]

ALIASES = {
    "crosswalk": "crosswalk", "zebra crossing": "crosswalk",
    "pothole": "pothole", "potholes": "pothole",
    "stairs": "stairs", "staircase": "stairs", "stair": "stairs", "steps": "stairs",
    "curb": "curb", "kerb": "curb", "curb ramp": "curb",
    "manhole": "manhole", "pole": "pole", "barrier": "barrier",
}

# Only valid if ped_light1 shows PEDESTRIAN lights
PER_DATASET = {
    "ped_light1": {"red": "ped_red", "green": "ped_green"},
}

SPLITS = {"train": "train", "valid": "valid", "val": "valid", "test": "test"}


def load_names(ds):
    y = yaml.safe_load((ds / "data.yaml").read_text(encoding="utf-8"))
    n = y["names"]
    return n if isinstance(n, list) else [n[k] for k in sorted(n)]


def safe_copy(src, dst, tries=8):
    for _ in range(tries):
        try:
            shutil.copyfile(src, dst)
            return True
        except PermissionError:
            time.sleep(0.5)   # file locked by antivirus or indexer, wait and retry
    return False


for s in ("train", "valid", "test"):
    (OUT / s / "images").mkdir(parents=True, exist_ok=True)
    (OUT / s / "labels").mkdir(parents=True, exist_ok=True)

counts = {c: 0 for c in FINAL}
images = {"train": 0, "valid": 0, "test": 0}
unmapped = {}
skipped = 0

for ds in sorted(p for p in RAW.iterdir() if p.is_dir()):
    names = load_names(ds)
    print("working on", ds.name, "...", flush=True)
    mapping = {**ALIASES, **PER_DATASET.get(ds.name, {})}
    idmap = {}
    for i, n in enumerate(names):
        key = str(n).strip().lower()
        if key in mapping:
            idmap[i] = FINAL.index(mapping[key])
        else:
            unmapped.setdefault(ds.name, []).append(n)

    for sdir in ds.iterdir():
        if not sdir.is_dir() or sdir.name not in SPLITS:
            continue
        split = SPLITS[sdir.name]
        for img in (sdir / "images").glob("*"):
            if img.suffix.lower() not in {".jpg", ".jpeg", ".png"}:
                continue
            lbl = sdir / "labels" / (img.stem + ".txt")
            lines, found = [], []
            if lbl.exists():
                for line in lbl.read_text().splitlines():
                    p = line.split()
                    if len(p) < 5:
                        continue
                    cid = int(float(p[0]))
                    if cid in idmap:
                        new_id = idmap[cid]
                        p[0] = str(new_id)
                        lines.append(" ".join(p))
                        found.append(FINAL[new_id])
            if not lines:
                continue

            new = f"{ds.name}_{img.name}"
            if not safe_copy(img, OUT / split / "images" / new):
                skipped += 1
                print("SKIPPED (locked):", new, flush=True)
                continue
            (OUT / split / "labels" / (Path(new).stem + ".txt")).write_text(
                "\n".join(lines))
            for c in found:
                counts[c] += 1
            images[split] += 1
            total = sum(images.values())
            if total % 500 == 0:
                print("copied", total, "images", flush=True)

(OUT / "data.yaml").write_text(yaml.safe_dump({
    "path": "/content/merged",
    "train": "train/images", "val": "valid/images", "test": "test/images",
    "nc": len(FINAL), "names": FINAL,
}, allow_unicode=True), encoding="utf-8")

print("\nDONE. Images per split:", images)
print("Skipped (locked):", skipped)
print("Labels per class:")
for c, n in counts.items():
    print(f"  {c:12s} {n}")
print("\nClasses NOT used (ignored):")
for d, l in unmapped.items():
    print(f"  {d}: {l}")