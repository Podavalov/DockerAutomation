#!/usr/bin/env python3
import os
import sys
import subprocess
import shutil
from pathlib import Path

def main():
    # Add common Docker installation paths to PATH (macOS/Linux)
    for p in ["/usr/local/bin", "/opt/homebrew/bin"]:
        if os.path.isdir(p) and p not in os.environ["PATH"].split(os.pathsep):
            os.environ["PATH"] = p + os.pathsep + os.environ["PATH"]

    print("Start Build")

    # --- 1. Check Docker ---
    if not shutil.which("docker"):
        print("ERROR: Docker is not installed or not in PATH!")
        print("Please install Docker Desktop from https://www.docker.com/products/docker-desktop/")
        sys.exit(1)

    try:
        docker_version = subprocess.check_output(["docker", "--version"], text=True).strip()
        print(f"Docker version: {docker_version}")
    except subprocess.CalledProcessError as e:
        print(f"ERROR: Failed to get Docker version: {e}")
        sys.exit(1)

    # --- 2. Ask for project directory ---
    script_dir = Path(__file__).resolve().parent

    while True:
        print()
        print("Enter the path to the project directory.")
        print(f"Press Enter to use the default: {script_dir}")
        user_input = input("Project path: ").strip()

        if not user_input:
            dir_path = script_dir
        else:
            # Remove surrounding quotes and spaces
            cleaned = user_input.strip().strip('"').strip("'")
            dir_path = Path(cleaned)

        if not dir_path.is_dir():
            print(f"ERROR: '{dir_path}' is not a directory.")
            continue

        dir_path = dir_path.resolve()
        break

    print(f"Using project directory: {dir_path}")

    # --- 3. npm install in frontend ---
    frontend_dir = dir_path / "frontend"
    if not frontend_dir.is_dir():
        print(f"ERROR: '{frontend_dir}' not found!")
        sys.exit(1)

    print(f"Running 'npm install' in {frontend_dir} ...")
    os.chdir(frontend_dir)

    npm_cmd = shutil.which("npm")
    if not npm_cmd:
        print("ERROR: npm is not installed or not in PATH!")
        sys.exit(1)

    try:
        subprocess.check_call([npm_cmd, "install"])
    except subprocess.CalledProcessError as e:
        print(f"ERROR: npm install failed: {e}")
        sys.exit(1)

    # --- 4. Check compose file ---
    os.chdir(dir_path)
    print(f"Current directory: {os.getcwd()}")

    compose_files = ["docker-compose.yml", "compose.yaml"]
    if not any((dir_path / f).is_file() for f in compose_files):
        print("ERROR: No docker-compose.yml or compose.yaml found!")
        sys.exit(1)

    # --- 5. Start ---
    print("Starting Docker Compose...")

    try:
        subprocess.check_call(["docker", "compose", "version"],
                              stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("ERROR: Docker Compose is not available!")
        sys.exit(1)

    try:
        subprocess.check_call(["docker", "compose", "up", "--build"])
    except subprocess.CalledProcessError as e:
        print(f"ERROR: docker compose up failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()