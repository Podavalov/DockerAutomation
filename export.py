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

    print("Start Export")

    # --- 1. Ask for project directory ---
    while True:
        print()
        print("Enter the path to the project directory (where docker-compose.yml is).")
        user_input = input("Project path: ").strip()

        if not user_input:
            print("ERROR: project path cannot be empty.")
            continue

        # Clean surrounding quotes and spaces
        cleaned = user_input.strip().strip('"').strip("'")
        project_path = Path(cleaned)

        if not project_path.is_dir():
            print(f"ERROR: '{cleaned}' is not a directory.")
            continue

        project_dir = project_path.resolve()
        break

    os.chdir(project_dir)
    print(f"Using project directory: {project_dir}")

    # --- 2. Archive name = basename of the entered folder ---
    project_name = Path(cleaned).name
    archive_name = f"{project_name}.tar"

    # --- 2a. Determine output path ---
    # If "Import" folder exists next to the script — save there automatically.
    # Otherwise — ask the user for a path.
    import_dir = script_dir / "Import"

    if import_dir.is_dir():
        output_file = import_dir / archive_name
        print()
        print(f"📁 Found 'Import' folder next to the script — saving there automatically.")
        print(f"Output file: {output_file}")
    else:
        default_out = script_dir / archive_name
        print()
        print("Enter the output .tar file path.")
        print(f"Press Enter to use the default: {default_out}")
        out_input = input("Output file: ").strip()

        if not out_input:
            output_file = default_out
        else:
            cleaned_out = out_input.strip().strip('"').strip("'")
            output_file = Path(cleaned_out)
            if not output_file.is_absolute():
                output_file = script_dir / output_file

    out_dir = output_file.parent
    if not out_dir.is_dir():
        print(f"ERROR: Output directory '{out_dir}' does not exist.")
        sys.exit(1)

    print(f"Output file: {output_file}")

    # --- 3. Collect images from compose file ---
    print()
    print("Collecting images from docker-compose.yml...")

    try:
        result = subprocess.run(
            ["docker", "compose", "config", "--images"],
            capture_output=True, text=True, check=True
        )
        images_raw = result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"ERROR: Failed to get images from compose: {e}")
        sys.exit(1)

    if not images_raw:
        print("❌ No images found in compose file.")
        sys.exit(1)

    images = sorted(set(images_raw.splitlines()))

    print("📦 Saving images into a single archive:")
    for img in images:
        print(f"   {img}")

    # --- 3b. Check that all images exist locally ---
    missing = []
    for img in images:
        try:
            subprocess.run(
                ["docker", "image", "inspect", img],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True
            )
        except subprocess.CalledProcessError:
            missing.append(img)

    if missing:
        print("❌ These images are missing locally:")
        for img in missing:
            print(f"   - {img}")
        print("   Run 'docker compose build' and/or 'docker compose pull' first.")
        sys.exit(1)

    # --- 4. Save ---
    if output_file.exists():
        print(f"Removing existing file: {output_file}")
        output_file.unlink()

    cmd = ["docker", "save", "--platform", "linux/amd64", "-o", str(output_file)] + images
    try:
        subprocess.check_call(cmd)
    except subprocess.CalledProcessError as e:
        print(f"ERROR: docker save failed: {e}")
        sys.exit(1)

    print()
    print(f"✅ Archive saved: {output_file}")

if __name__ == "__main__":
    main()