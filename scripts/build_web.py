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
EXPORT_PATH = "build/web/index.pck" # Export as PCK
TEMPLATE_ZIP = r"C:\Users\Ranamzes\AppData\Roaming\Godot\export_templates\4.6.stable\web_release.zip"

def ignore_patterns(path, names):
    # Ignore these directories/files during copy
    return {'.godot', '.git', '.history', 'temp_build_env', 'build', '.import'}

def setup_build_env():
    if os.path.exists(BUILD_DIR):
        print(f"Cleaning previous build env: {BUILD_DIR}")
        shutil.rmtree(BUILD_DIR)

    print(f"Copying project to {BUILD_DIR}...")
    shutil.copytree(SOURCE_DIR, BUILD_DIR, ignore=shutil.ignore_patterns('.godot', '.git', '.history', 'temp_build_env', 'build', '.import'))
    print("Copy complete.")

def patch_project_godot():
    project_file = os.path.join(BUILD_DIR, "project.godot")
    print(f"Patching {project_file}...")

    with open(project_file, "r") as f:
        lines = f.readlines()

    new_lines = []
    for line in lines:
        if "locale/translations_pot_files" in line and ".history" in line:
            print("  Removing invalid line")
            # Empty array to be safe
            new_lines.append('locale/translations_pot_files=PackedStringArray()\n')
        # We can keep plugins enabled for pack export, or disable them if they cause issues.
        # Let's keep them disabled to be safe as previously determined.
        elif "[editor_plugins]" in line:
             print("  Disabling editor plugins section")
             new_lines.append('; [editor_plugins]\n')
        elif "enabled=PackedStringArray" in line and "plugin.cfg" in line:
             print("  Commenting out plugin list")
             new_lines.append(';' + line)
        else:
            new_lines.append(line)

    with open(project_file, "w") as f:
        f.writelines(new_lines)

def patch_export_presets():
    presets_file = os.path.join(BUILD_DIR, "export_presets.cfg")
    print(f"Patching {presets_file}...")

    if not os.path.exists(presets_file):
        print("export_presets.cfg not found!")
        return
    # We don't need to patch head_include for export-pack

def run_export_pack():
    print("Running Godot export-pack...")
    # Ensure export directory exists in the temp env
    export_dir = os.path.dirname(os.path.join(BUILD_DIR, EXPORT_PATH))
    os.makedirs(export_dir, exist_ok=True)

    cmd = [
        GODOT_BIN,
        "--headless",
        "--path", BUILD_DIR, # Run in the build dir
        "--verbose",
        "--export-pack", # CHANGED to export-pack
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
            print("Export PCK SUCCESS!")
            return True
        except subprocess.CalledProcessError as e:
            print(f"Export FAILED with code {e.returncode}")
            return False

def extract_template_files():
    print(f"Extracting template files from {TEMPLATE_ZIP}...")
    dest_dir = os.path.dirname(os.path.join(BUILD_DIR, EXPORT_PATH))

    try:
        with zipfile.ZipFile(TEMPLATE_ZIP, 'r') as zip_ref:
            # Extract required files
            zip_ref.extract("godot.html", dest_dir)
            zip_ref.extract("godot.js", dest_dir)
            zip_ref.extract("godot.wasm", dest_dir)
            # Maybe service worker?
            if "godot.service.worker.js" in zip_ref.namelist():
                 zip_ref.extract("godot.service.worker.js", dest_dir)

        # Rename godot.html to index.html
        os.rename(os.path.join(dest_dir, "godot.html"), os.path.join(dest_dir, "index.html"))

        # We need to ensure index.html loads index.pck
        # The default godot.html usually looks for a .pck with the same base name as the .html?
        # Or it uses "index.pck" by default?
        # Let's hope it works with index.pck (which we exported to).
        # Actually we exported to index.pck so renaming godot.html to index.html makes them match!

        print("Template extraction complete.")
        return True
    except Exception as e:
        print(f"Error extracting template: {e}")
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
        if run_export_pack():
            if extract_template_files():
                copy_artifacts_back()
                # Cleanup
                print(f"Cleaning up build environment: {BUILD_DIR}")
                shutil.rmtree(BUILD_DIR)
                sys.exit(0)
            else:
                 sys.exit(1)
        else:
            sys.exit(1)
    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)
