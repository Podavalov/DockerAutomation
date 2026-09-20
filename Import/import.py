#!/usr/bin/env python3
import os
import sys
import subprocess
from pathlib import Path

def main():
    # Add common Docker paths to PATH
    for p in ["/usr/local/bin", "/opt/homebrew/bin"]:
        if os.path.isdir(p) and p not in os.environ["PATH"].split(os.pathsep):
            os.environ["PATH"] = p + os.pathsep + os.environ["PATH"]

    script_dir = Path(__file__).resolve().parent
    os.chdir(script_dir)

    print(f"📂 Project dir: {script_dir}")

    # --- Find .tar files in script directory ---
    tar_files = sorted(script_dir.glob("*.tar"))
    if not tar_files:
        print(f"❌ No .tar files found in {script_dir}")
        sys.exit(1)

    if len(tar_files) > 1:
        print("⚠️  Multiple .tar files found, using the first one:")
        for f in tar_files:
            print(f"   - {f.name}")

    tar_file = tar_files[0]
    print(f"📦 Using archive: {tar_file.name}")

    print("📥 Loading images...")

    try:
        subprocess.check_call(["docker", "load", "-i", str(tar_file)])
    except subprocess.CalledProcessError as e:
        print(f"ERROR: docker load failed: {e}")
        sys.exit(1)

    print("✅ Images uploaded.")

    if not (script_dir / ".env").is_file():
        print("⚠️  .env not found; please create it.")
        sys.exit(1)

    if not (script_dir / "infra" / "nginx" / "nginx.conf").is_file():
        print("⚠️  nginx.conf not found.")
        sys.exit(1)

    print("🚀 Launching containers...")
    try:
        subprocess.check_call(["docker", "compose", "up", "-d"])
    except subprocess.CalledProcessError as e:
        print(f"ERROR: docker compose up failed: {e}")
        sys.exit(1)

    print("✅ Done. Status:")
    try:
        subprocess.check_call(["docker", "compose", "ps"])
    except subprocess.CalledProcessError as e:
        print(f"ERROR: docker compose ps failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()