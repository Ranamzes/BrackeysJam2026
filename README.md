# BrackeysJam2026

Godot 4.6 Game Jam Project.

## Development Setup

### Python & GDLinter

This project uses [uv](https://docs.astral.sh/uv/) for Python dependency management, specifically for the `gdlint` tool.

1.  Install `uv` (if not already installed).
2.  Run `uv sync` in the project root to install dependencies (`gdtoolkit`).
3.  In Godot, the GDLinter plugin will automatically detect and use `uv run gdlint`.

### Plugins

-   **G.U.I.D.E.** - Input management. (Included in `addons/`)
-   **Sound Manager** - Audio management. (Included in `addons/`)
-   **GDLinter** - Script linting.
-   **Script-IDE** - Enhanced script editor.

### Local Deployment (Fast & Autonomous)

We use a Python script that handles everything:
1.  **Auto-Discovery**: Finds Godot/Butler on your system.
2.  **Auto-Install**: Downloads Butler automatically if missing.
3.  **Deploy**: Exports and pushes to Itch.io.

**Run:**
```bash
uv run scripts/deploy.py
```

## Known Issues

-   **SplitContainer Errors**: You may see error messages related to `split_container.cpp` in the Godot console. These are a known engine regression and can be safely ignored.
