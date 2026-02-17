# Renamed to build_web.py
import shutil
import os
import subprocess
import sys
import zipfile

# Configuration
SOURCE_DIR = os.getcwd()
BUILD_DIR = os.path.join(SOURCE_DIR, "temp_build_env")
GODOT_BIN = r"C:\Program Files\Godot\Godot.exe"
EXPORT_PRESET = "Web"
EXPORT_PATH = "build/web/index.html"

def run_export_web():
    print("Running Godot export-release for Web...")
    # Ensure export directory exists in the temp env
    export_dir = os.path.dirname(os.path.join(BUILD_DIR, EXPORT_PATH))
    os.makedirs(export_dir, exist_ok=True)

    cmd = [
        GODOT_BIN,
        "--headless",
        "--path", BUILD_DIR,
        "--verbose",
        "--export-release",
        EXPORT_PRESET,
        EXPORT_PATH
    ]

    with open("build_safe_log.txt", "w") as log_file:
        try:
            result = subprocess.run(
                cmd,
                check=True,
                stdout=log_file,
                stderr=subprocess.STDOUT,
                text=True
            )
            print("Export SUCCESS!")
            return True
        except subprocess.CalledProcessError as e:
            print(f"Export FAILED with code {e.returncode}")
            return False

def copy_artifacts_back():
    # EXPORT_PATH is "build/web/index.pck"
    # We want to copy the whole 'build/web' directory
    src = os.path.dirname(os.path.join(BUILD_DIR, EXPORT_PATH))
    src_dir = src # build/web
    dest_dir = os.path.join(SOURCE_DIR, "build", "web")

    print(f"Copying artifacts from {src_dir} to {dest_dir}...")

    if os.path.exists(src_dir):
        # Allow overwriting
        if os.path.exists(dest_dir):
            shutil.rmtree(dest_dir)
        shutil.copytree(src_dir, dest_dir)
        print("Artifacts copied successfully.")
    else:
        print("No artifacts found to copy.")

if __name__ == "__main__":
    try:
        setup_build_env()
        patch_project_godot()
        patch_export_presets()
        if run_export_web():
            copy_artifacts_back()
            # Cleanup
            print(f"Cleaning up build environment: {BUILD_DIR}")
            shutil.rmtree(BUILD_DIR)

            # Cleanup log file on success
            if os.path.exists("build_safe_log.txt"):
                print("Cleaning up build_safe_log.txt...")
                os.remove("build_safe_log.txt")

            print("Build and export successful!")
            sys.exit(0)
        else:
            sys.exit(1)
    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)
