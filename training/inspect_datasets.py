from pathlib import Path
import yaml

for ds in sorted(Path("raw").iterdir()):
    if not (ds / "data.yaml").exists():
        print(f"{ds.name}: NO data.yaml (wrong folder level?)")
        continue
    y = yaml.safe_load((ds / "data.yaml").read_text(encoding="utf-8"))
    names = y["names"] if isinstance(y["names"], list) else list(y["names"].values())
    n = {s: len(list((ds / s / "images").glob("*")))
         for s in ("train", "valid", "test") if (ds / s / "images").exists()}
    print(f"\n{ds.name}\n  images: {n}\n  classes: {names}")