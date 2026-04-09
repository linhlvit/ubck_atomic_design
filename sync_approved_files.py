"""
sync_approved_files.py
Fetch approved file list from Cloudflare Worker API,
copy approved files to docs/approved/ in this repo.
Run by GitHub Actions after each review batch.
"""
import os, json, shutil, requests
from pathlib import Path

WORKER_BASE = os.environ["WORKER_BASE_URL"]           # https://datamodel-worker.linhlv-it.workers.dev
CLIENT_IDS  = [x.strip() for x in os.environ.get("CLIENT_IDS", "").split(",") if x.strip()]
LAYERS      = [x.strip() for x in os.environ.get("LAYERS",     "").split(",") if x.strip()]

print(f"CLIENT_IDS={CLIENT_IDS}")
print(f"LAYERS={LAYERS}")

OUT_DIR = Path("docs/approved")
shutil.rmtree(OUT_DIR, ignore_errors=True)   # rebuild sạch mỗi lần chạy
OUT_DIR.mkdir(parents=True, exist_ok=True)

manifest = []

for client_id in CLIENT_IDS:
    for layer in LAYERS:
        url = f"{WORKER_BASE}/{client_id}/{layer}/csv-reviews"
        print(f"  Fetching: .../{client_id}/{layer}/csv-reviews (client_id len={len(client_id)}, repr={repr(client_id)})")
        try:
            r = requests.get(url, timeout=15)
            r.raise_for_status()
            reviews = r.json()
        except Exception as e:
            print(f"[SKIP] {client_id}/{layer}: {e}")
            continue

        approved = {k: v for k, v in reviews.items() if v.get("status") == "approved"}
        print(f"[{client_id}/{layer}] {len(approved)}/{len(reviews)} files approved")

        for key, rv in approved.items():
            # key format: "{repo}/{filePath}"
            # e.g. "ubck_atomic_design/Silver/hld/DCST_relationship_diagram.md"
            parts = key.split("/", 1)
            if len(parts) < 2:
                print(f"  [SKIP] bad key format: {key}")
                continue
            file_path = Path(parts[1])   # strip repo prefix → actual path in repo
            if not file_path.exists():
                print(f"  [MISSING] {file_path}")
                continue
            dst = OUT_DIR / key
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(file_path, dst)
            manifest.append({
                "key": key,
                "approvedBy": rv.get("by"),
                "approvedAt": rv.get("at"),
                "comment":    rv.get("comment", ""),
            })
            print(f"  ✓ {key}")

manifest_path = OUT_DIR / "manifest.json"
with open(manifest_path, "w", encoding="utf-8") as f:
    json.dump(manifest, f, ensure_ascii=False, indent=2)

print(f"\nDone: {len(manifest)} approved files → {OUT_DIR}/")
