import subprocess
import sys
import os
import shutil
from pathlib import Path
import platform
import zipfile
import urllib.request
import stat

# --- CONFIGURATION ---
ITCH_USER = "ranamzes"
ITCH_GAME = "testdev" # Your itch.io game slug
EXPORT_PRESET = "Web"
EXPORT_DIR = ".export/web"
EXPORT_FILE = "index.html"
BUTLER_VERSION = "LATEST" # or specific version like "15.21.0"
# ---------------------

def get_platform_info():
    system = platform.system().lower()
    if system == "windows":
        return "windows", "amd64", "butler.exe"
    elif system == "darwin":
        return "mac", "amd64", "butler" # M1/M2 usually work with amd64 via Rosetta, or use "arm64" if preferred
    else:
        return "linux", "amd64", "butler"

def download_butler(target_path):
    os_name, arch, binary_name = get_platform_info()
    url = f"https://broth.itch.ovh/butler/{os_name}-{arch}/{BUTLER_VERSION}/archive/default"
    dest_dir = Path("scripts/tools/butler")
    zip_path = dest_dir / "butler.zip"
    exe_path = dest_dir / binary_name

    print(f"--- Butler not found. Bootstrapping to {dest_dir}... ---")

    dest_dir.mkdir(parents=True, exist_ok=True)

    print(f"Downloading from {url}...")
    try:
        urllib.request.urlretrieve(url, zip_path)
    except Exception as e:
        print(f"ERROR: Failed to download Butler: {e}")
        return None

    print("Extracting...")
    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(dest_dir)
    except Exception as e:
        print(f"ERROR: Failed to extract Butler: {e}")
        return None

    if not exe_path.exists():
        print(f"ERROR: Extracted but {binary_name} not found in {dest_dir}")
        return None

    # Make executable on Linux/Mac
    if os_name != "windows":
        st = exe_path.stat()
        exe_path.chmod(st.st_mode | stat.S_IEXEC)

    print("--- Butler bootstrapped successfully! ---")
    return str(exe_path.absolute())

def find_tool(tool_name, common_paths):
    # 1. Check if it's already in PATH
    path = shutil.which(tool_name)
    if path:
        return path

    # 2. Check common installation paths
    for path_str in common_paths:
        expanded_path = os.path.expandvars(path_str)
        if os.path.exists(expanded_path):
            return expanded_path

    return None

def run_command(command, description):
    print(f"--- {description} ---")
    try:
        result = subprocess.run(command, check=True, text=True)
        return result.returncode == 0
    except subprocess.CalledProcessError as e:
        print(f"ERROR: {description} failed with return code {e.returncode}")
        return False
    except FileNotFoundError:
        print(f"ERROR: Command not found: {command[0]}")
        return False

def main():
    # Common paths for tools
    godot_paths = [
        r"C:\Program Files\Godot\Godot.exe",
        r"C:\Program Files (x86)\Godot\Godot.exe",
        r"D:\Godot\Godot.exe",
        r"/Applications/Godot.app/Contents/MacOS/Godot", # Mac
        r"/usr/bin/godot", # Linux
    ]

    # Local bootstrap path is checked first in find_tool if we add it to the list,
    # but we want to download if *none* are found.
    # So we used a separate check for download.
    butler_paths = [
        r"scripts/tools/butler/butler.exe", # Check local bootstrap first
        r"scripts/tools/butler/butler",
        r"%APPDATA%\itch\bin\butler.exe",
        r"C:\deps\butler\butler.exe",
        r"C:\Program Files (x86)\itch\bin\butler.exe",
        r"%USERPROFILE%\Downloads\butler.exe",
        r"%USERPROFILE%\Downloads\butler\butler.exe",
        r"%USERPROFILE%\Documents\butler.exe",
        r"D:\butler\butler.exe",
        r"~/.config/itch/bin/butler", # Linux/Mac
    ]

    godot_path = find_tool("godot", godot_paths)
    butler_path = find_tool("butler", butler_paths)

    if not godot_path:
        print("ERROR: Godot Engine not found!")
        print("Please ensure Godot is in your PATH or installed in standard locations.")
        print("Download Godot: https://godotengine.org/download")
        sys.exit(1)

    if not butler_path:
        butler_path = download_butler("scripts/tools/butler")
        if not butler_path:
            print("ERROR: Could not download/install Butler automatically.")
            print("Please download it manually: https://itch.io/docs/butler/installing.html")
            sys.exit(1)

    print(f"Using Godot: {godot_path}")
    print(f"Using Butler: {butler_path}")

    # Ensure Export Directory exists
    Path(EXPORT_DIR).mkdir(parents=True, exist_ok=True)

    # 1. Godot Export
    godot_cmd = [
        godot_path,
        "--headless",
        "--export-release",
        EXPORT_PRESET,
        str(Path(EXPORT_DIR) / EXPORT_FILE)
    ]

    if not run_command(godot_cmd, f"Godot Export ({EXPORT_PRESET})"):
        sys.exit(1)

    # 2. Butler Push
    butler_cmd = [
        butler_path,
        "push",
        EXPORT_DIR,
        f"{ITCH_USER}/{ITCH_GAME}:html5"
    ]

    if not run_command(butler_cmd, "Butler Push to Itch.io"):
        sys.exit(1)

    print("--- Deployment Complete! ---")

if __name__ == "__main__":
    main()
