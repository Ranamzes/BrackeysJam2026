# Gemini Project Context: BrackeysJam2026

## 1. Project Overview

This is a game for BrackeysJam2026, built with Godot Engine 4.6.

The project follows a strict, modular, and data-driven architecture inspired by Entity-Component-System (ECS) principles. The goal is to produce scalable, maintainable, and performant code that is easy to debug and extend.

### Key Addons
*   **G.U.I.D.E.:** For input handling.
*   **Sound Manager:** For audio management, following ECS principles.

---

## 2. Core Architecture: Data-Driven ECS

The project's foundation is a component-based architecture where logic (Systems) is separated from data (Components and Resources).

### 🔥 Core Mandates
1.  **Plan First:** Before taking any action, I must first thoroughly understand the request and the relevant codebase. I will explore the files, gather context, and when I have enough information, I will create a detailed execution plan. I will present this plan for approval and will not proceed with the implementation until it is approved. This is a critical rule.
2.  **Component-Based Design:** Entities (like the player or enemies) are `Node`s composed of smaller, single-responsibility components. Prefer composition over inheritance.
3.  **Data-Driven with Resources:** All static and dynamic data that can vary between instances (e.g., enemy stats, weapon definitions, audio events) **MUST** be defined as `Resource` (`.tres`) files. This allows designers to configure the game without changing code.
4.  **Strict Typing is Mandatory:** Use specific, static types for **ALL** variables, function parameters, and return values. This is the most critical rule for preventing runtime errors.
    *   **YES:** `var health_component: HealthComponent`, `var enemies: Array[Enemy]`
    *   **NO:** `var component`, `var nodes: Array`
5.  **Feature-Based Project Structure:** The project **MUST** be organized by features/entities (e.g., `res://player/`, `res://enemies/`), not by file types (e.g., `res://scripts/`). This makes features modular and easy to migrate.
6.  **`class_name` is Mandatory:** Every custom GDScript file (components, resources, systems) **MUST** have a `class_name` to enforce project-wide type safety.
7.  **Godot 4 Syntax Only:** All code **MUST** adhere strictly to Godot 4 syntax and best practices. Godot 3 syntax (e.g., `onready var`, `export var`, `setget`, `yield`) is strictly forbidden. Use Godot 4 equivalents like `@onready`, `@export`, property setters/getters, and `await`. class_name is NOT allowed to be used for variable and parameter names, it is a reserved name.
8. Mandatory Godot API Verification (Smart Mode)

Before using or generating any **GDScript code**, the agent must **verify API availability** using the **official Godot documentation and structured introspection**, if not helped use *general search queries*.

---

#### 🧭 Godot 4.6.1 API Search Guidelines for LLM Agents

**Goal:**
Ensure that the LLM agent always uses **only existing methods** and **verified API data** from Godot 4.6.1, while being able to **quickly find valid code examples**.
Search the latest stable Godot documentation trough Google
---

##### 🧩 Priority Order of Sources (Descending)

###### **1️⃣ Official Godot 4.6 (stable) Documentation**
**URL:**
[https://docs.godotengine.org/en/stable/](https://docs.godotengine.org/en/stable/)

**How to Search:**
Use the site filter for precise queries:
```bash
site:docs.godotengine.org/en/stable/ <ClassName> <MethodName>
```
Or use direct class URLs:
```bash
https://docs.godotengine.org/en/stable/classes/class_<classname>.html
```
Example:
```bash
https://docs.godotengine.org/en/stable/classes/class_sprite2d.html
```

**Verification Steps:**
- Confirm the method exists under **Methods** or **Properties**.
- Use only the exact signature listed.
- If the method does not exist — **do not use it**.

---

##### **2️⃣ Godot Source Code on GitHub**
**URL:**
[https://github.com/godotengine/godot/tree/4.6.1](https://github.com/godotengine/godot/tree/4.6.1)

**Search Pattern:**
```bash
repo:godotengine/godot 4.6.1 "<method_name>" path:modules OR path:scene
```

**Purpose:**
Check the declaration or implementation in `.cpp` or `.h` files to confirm existence in version 4.6.1 (not in `master`).

---

##### **3️⃣ Built-in Godot Editor Documentation**
**Local Access:**
In the Godot Editor → **Help → Search Help (F1)**

**Steps:**
1. Press **F1**.
2. Type the class name (e.g., `AnimationPlayer`).
3. Confirm available methods and signals.

✅ This ensures perfect match with your installed version of Godot.

---

##### **4️⃣ Official Demo Projects**
**URL:**
[https://github.com/godotengine/godot-demo-projects](https://github.com/godotengine/godot-demo-projects)

**Search Pattern:**
```bash
site:github.com/godotengine/godot-demo-projects <classname> <method>
```

**Purpose:**
Find verified working examples using the same methods.
If a method appears here, it is confirmed to be valid and used in production.

---

##### **5️⃣ Community Sources (for Examples Only)**
Use these **only** for usage examples, not for verifying existence.

**Reliability Order:**
1. [https://godotengine.org/qa/](https://godotengine.org/qa/) — Godot Q&A
2. [https://www.reddit.com/r/godot/](https://www.reddit.com/r/godot/)
3. StackOverflow (tag `[godot4]`)
4. GitHub Issues (repository `godotengine/godot`)

**Search Example:**
```bash
"<method_name>" godot 4.6 site:godotengine.org OR site:github.com/godotengine OR site:stackoverflow.com
```

---

## 🧠 Verification Process (Strict Order)

1. **Check official documentation** (Step 1).
2. **If missing, check source code** (Step 2).
3. **If still missing, check via F1 in the editor** (Step 3).
4. **If found in demo projects, cross-check the signature** (Step 4).
5. **If only found in community posts — reject.**

---

## 🧰 Helper Commands (for automation)

```bash
# Search class in official docs
search_godot_class() {
  local class=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  echo "https://docs.godotengine.org/en/stable/classes/class_${class}.html"
}

# Search method within class
search_godot_method() {
  local class=$1
  local method=$2
  echo "https://docs.godotengine.org/en/stable/classes/class_${class}.html#class-${class}-${method}"
}

# Example:
# search_godot_class Sprite2D
# search_godot_method Sprite2D set_texture
```

---

## 🧠 LLM Logic Rules

- Never "guess" or fabricate methods.
- If a method is not found in version 4.6 docs, respond with:
  **"This method does not exist in Godot 4.6."**
- Always include the source link in responses.
- Verify compatibility if an example references 4.3 or 4.4.

---

## 💡 Example Query Flow

**User Query:**
> How to disable texture filtering on a Sprite2D?

**Agent Steps:**
1. Open [class_sprite2d.html](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html)
2. Find the property `texture_filter`
3. Generate verified code example:
   ```gdscript
   $Sprite2D.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
   ```
4. Provide documentation link as reference.

---

### ✅ Summary

**Use only:**
1. Official Docs
2. Source Code
3. Editor Help
4. Official Demos

**Never trust:**
- Forum posts
- YouTube examples
- Outdated blog content

This guarantees that all generated code is **100% valid for Godot 4.6.1** and backed by verifiable documentation.

---

## 3. Implementation Guide & Best Practices

### Naming Conventions (Official Godot Standards)
*   **Files & Resources (`.gd`, `.tres`):** `snake_case` (e.g., `player_controller.gd`, `enemy_stats.tres`)
*   **Scenes (`.tscn`):** `PascalCase` (e.g., `MainMenu.tscn`, `PlayerCharacter.tscn`)
*   **Class Names:** `PascalCase` (e.g., `class_name PlayerController`)
*   **Node Names:** `PascalCase` (e.g., `Player`, `HealthComponent`)
*   **Functions & Variables:** `snake_case` (e.g., `func load_level():`, `var move_speed`)
*   **Signals:** `snake_case` (e.g., `signal health_depleted`)
*   **Constants & Enum Members:** `CONSTANT_CASE` (e.g., `const MAX_SPEED = 200`)

### Performance & Safety
*   **StringName (`&"..."`):** Use `StringName` for all node lookups, signal names, method calls, and group names to improve performance. (e.g., `get_node(&"PlayerSprite")`)
*   **Safe Node Access:** **NEVER** assume a node exists. Always use `get_node_or_null()` or `has_node()` with guard clauses.
    ```gdscript
    var health_bar: ProgressBar = get_node_or_null(&"UI/HealthBar")
    if not health_bar:
        push_error("HealthBar node not found")
        return
    ```
*   **Deferred Calls:** Use `call_deferred()` for node operations that happen within physics callbacks or when changing scenes to avoid instability.

---

## 4. Architecture in Practice: ECS Audio Example

The following demonstrates how to apply these principles to a feature, using footstep sounds with FMOD as an example.

### Step 1: Define Data with Resources
Create `Resource`-based scripts to define the data for the audio system. This makes audio events configurable from the Godot editor.

*   `FMODEventResource.gd`: Describes a single FMOD event and its parameters.
*   `AudioSurfaceResource.gd`: Defines a surface type (e.g., "stone", "grass") and its corresponding FMOD parameter value.
*   `FootstepProfile.gd`: A profile that groups an FMOD event and a list of possible surfaces for a character's footsteps.

### Step 2: Create ECS Components
Create components as `Resource` or `Node` classes that hold the runtime state for an entity.

*   `FootstepComponent.gd`: Holds a reference to a `FootstepProfile` and tracks the time since the last step.
*   `SurfaceComponent.gd`: Tracks the surface the entity is currently on.
*   `VelocityComponent.gd`: Tracks the entity's current velocity.

### Step 3: Build Logic in a System
A "System" is a `Node` that contains game logic. It operates on entities that have a specific set of components.

*   `FootstepLogicSystem.gd`: This system queries for entities with `FootstepComponent`, `VelocityComponent`, and `SurfaceComponent`. It checks if an entity is moving and, if enough time has passed, emits a signal like `play_footstep` with the necessary data (event path, surface value, position). **This system knows nothing about FMOD; it only handles game logic.**

### Step 4: Create a Service for Playback
A "Service" or "Playback System" is a `Node` that handles low-level operations.

*   `AudioPlaybackSystem.gd`: This system listens for the `play_footstep` signal from the `FootstepLogicSystem`. When the signal is received, it uses the FMOD API to create and play the sound event with the correct parameters. **This system knows nothing about game logic; it only handles FMOD.**

### Summary
This architecture separates **what** sound to play (Data Resources), **when** to play it (Logic System), and **how** to play it (Playback System), creating a decoupled, scalable, and data-driven feature.

---

## 5. Building and Running

1.  **Open the project:** Use Godot 4.6+ to import the `project.godot` file.
2.  **Run the game:** The main scene is configured as `res://node_2d.tscn` in `project.godot`. However, this file does not exist. You should change this to `res://main.tscn` in the project settings (`Application -> Run -> Main Scene`) to run the game.

---

## 6. Workflow: Interface-First Design

This project follows an **"Interface-First"** philosophy. Before writing complex logic, we design the component's public interface directly in the Godot editor. This makes components more flexible, reusable, and understandable for game designers.

### Step-by-step process for creating a new component:

**Step 1: Define the Component's Role (What does it do?)**
*   Clearly state its single responsibility.
    *   *Example: "Manages health and damage," "Makes an entity follow a target."*

**Step 2: Design the Inspector Interface (How to configure it?)**
*   Use `\@export` for all parameters a game designer might want to tweak. **Always use strict types.**
    ```gdscript
    \@export var max_health: int = 100
    \@export var move_speed: float = 200.0
    ```
*   Group parameters using `\@export_group` for a cleaner inspector.
    ```gdscript
    \@export_group("Combat Stats")
    \@export var damage: int = 10
    \@export_group("Movement")
    \@export var move_speed: float = 200.0
    ```
*   For complex data, create a custom `Resource` and export it. This is the foundation of a data-driven approach.
    ```gdscript
    \# player_stats.gd
    class_name PlayerStats
    extends Resource
    \@export var max_health: int = 100

    \# health_component.gd
    \@export var stats: PlayerStats
    ```

**Step 3: Define the Public API (How to interact with it?)**
*   **Inputs (Methods):** Create public functions that will be called from other systems. They should be simple and clear.
    *   *Example: `func take_damage(attack: Attack)`*
*   **Outputs (Signals):** Define signals for events that other parts of the game should know about. This is the primary way components should communicate. **Always type your signal parameters.**
    *   *Example: `signal health_changed(new_health: int, max_health: int)`, `signal died()`*

**Step 4: Implement the Internal Logic (The Code)**
*   Only now should you write the GDScript code that implements the component's behavior.
*   The logic should read from the `\@export` variables and emit signals at the appropriate times.
*   Follow all other best practices: strict typing, safety checks (`get_node_or_null`), etc.

### Example: `HealthComponent`

1.  **Role:** Manages an entity's health, damage, and death.
2.  **Inspector Interface:**
    ```gdscript
    class_name HealthComponent
    extends Node

    \@export_group("Health Stats")
    \@export var max_health: int = 100
    ```
3.  **Public API:**
    *   Method: `func apply_damage(amount: int) -> void`
    *   Signals: `signal health_changed(new_health: int)`, `signal died`
4.  **Implementation:** Write the logic for `apply_damage` that reduces health and emits the `health_changed` and `died` signals.

---

## 7. Tooling and Plugin Guides

### Using G.U.I.D.E. for Input Management

G.U.I.D.E. is an advanced input management system that operates via `GUIDEMappingContext` resources. It allows for the decoupling of game logic from specific keys and buttons.

The basic workflow is as follows:

**1. Create a `GUIDEMappingContext`:**
*   In the FileSystem dock, right-click -> New Resource... and select `GUIDEMappingContext`. This file will store your control settings (e.g., `player_controls.tres`).

**2. Create `GuideAction`s:**
*   Inside the `GUIDEMappingContext` resource, you create abstract actions like `move_left`, `jump`, or `interact`.

**3. Bind Inputs to Actions:**
*   For each action, you specify which physical inputs trigger it (e.g., `jump` -> `Spacebar` on keyboard and `A` on a gamepad). G.U.I.D.E. provides various input types for this (`GuideInputKey`, `GuideInputJoyButton`, etc.).

**4. Use Actions in Code:**
*   Instead of `Input.is_action_pressed("ui_accept")`, you will use the `GUIDE` singleton. First, you need to activate your context:
    ```gdscript
    \@export var mapping_context: GUIDEMappingContext

    func _ready():
        if mapping_context:
            GUIDE.activate_mapping_context(mapping_context)
    ```
*   Then, in your code, you check the action's state like this:
    ```gdscript
    func _process(delta):
        if GUIDE.is_action_pressed("jump"):
            \# Jump logic here
            pass
    ```

**Key Advantage:** You can create different `GUIDEMappingContext`s (e.g., for menus, gameplay, driving), switch between them, and easily implement key remapping.

---

## 8. Development Resources

### Editor Icons

A complete list of available editor icons for use in plugins and tool scripts can be found at the following community-run viewer:
*   **Godot Editor Icons Viewer:** [https://godot-editor-icons.github.io](https://godot-editor-icons.github.io)

Here is your **Markdown guide (in English)** for writing and using RegEx in GDScript with the Godot Engine `RegEx` class.

---

## 9. egEx in GDScript - Best Practices Guide

*Based on Godot documentation and common pitfalls*

---

### 1. Overview

* In Godot you use the `RegEx` class to compile and search patterns. ([docs.godotengine.org][1])
* The search pattern must be **escaped for GDScript** before being compiled by `RegEx`. For example:

  ````gdscript
  var regex = RegEx.new()
  regex.compile("\\d+")  # means \d+ when interpreted by RegEx
  ``` :contentReference[oaicite:2]{index=2}
  ````
* After `compile()`, you can use `search()` to find the first match or `search_all()` to find all non-overlapping matches. ([docs.godotengine.org][1])
* Named capturing groups are supported (e.g., `(?<name>…)`). ([docs.godotengine.org][1])
* The implementation is based on PCRE2. ([docs.godotengine.org][1])

---

### 2. Instructions / Checklist for Agent Use

Use this whenever you craft or review a regex in GDScript:

1. **Understand the context** — what you are trying to match (annotations like `@on_event("…")`, method calls like `EventHub.emit("…")`, etc).
2. **Write the regex pattern** according to what needs matching (use character classes, quantifiers, anchors, groups, etc).
3. **Escape properly for GDScript string**:

   * Because the pattern is a string literal in GDScript, backslashes must be doubled (e.g., `\\d+` to represent `\d+`).
   * If you use double quotes for the string, interior double-quotes must be escaped: e.g., `\"`.
   * Optionally use raw strings (`r"…"`) if supported, to reduce escaping. ([docs.godotengine.org][1])
4. **Compile and check**:

   ```gdscript
   var regex = RegEx.new()
   var err = regex.compile(pattern)
   if err != OK:
       push_error("Invalid regex: %s" % err)
   ```

   Ensure `regex.is_valid()` returns true. ([docs.godotengine.org][1])
5. **Use search/search_all**:

   * `regex.search(subject)` => first match or `null`.
   * `regex.search_all(subject)` => array of `RegExMatch`. ([docs.godotengine.org][1])
6. **Extract groups**:

   ```gdscript
   for match in regex.search_all(subject):
       var group1 = match.get_string(1)
       \# or named: match.get_string("name")
   ```

   Group index 0 is the whole match. ([docs.godotengine.org][1])
7. **If doing replacements**, use `regex.sub(subject, replacement, all=true)` to replace all matches. ([Game Development Stack Exchange][2])
8. **Avoid JS/other-language regex habits**:

   * Do *not* include leading/trailing delimiters like `/ ... /g`. Those cause compile errors in Godot. ([Reddit][3])
   * Global (`g`) modifier is not used; use `search_all()` instead. ([Game Development Stack Exchange][2])
9. **Test patterns**: Use a regex tester (with PCRE support) to validate your pattern, then translate into GDScript string form.
10. **Document your regex**: Explain what it matches, what groups capture, and any special escaping. That helps future maintainers.

---

### 3. Example Templates for Your Project

Here are some ready-to‐use patterns (adjust if needed) for your use-cases:

| Use-case                                                     | GDScript pattern (string literal)            | Notes                  |
| ------------------------------------------------------------ | -------------------------------------------- | ---------------------- |
| `@on_event("event_id")`                                      | `r'@on_event\("([^"]+)"\)'`                  | captures event_id      |
| `@forward_signal("signal_name", "res://path/to/event.tres")` | `r'@forward_signal\("[^"]+",\s*"([^"]+)"\)'` | captures resource path |
| `EventHub.emit("event_id", ...)`                             | `r'EventHub\.emit\("([^"]+)"'`               | captures event_id      |
| `EventHub.subscribe("event_id", ...)`                        | `r'EventHub\.subscribe\("([^"]+)"'`          | captures event_id      |

**Usage example**:

```gdscript
var regex := RegEx.new()
regex.compile(r'@on_event\("([^"]+)"\)')
for line in lines:
    for match in regex.search_all(line):
        var captured = match.get_string(1)
        \# use captured
```

---

### 4. Common Pitfalls & Tips

* **Double escaping**: remember that the string literal eats one layer of `\`, so `\\d+` becomes `\d+`. ([docs.godotengine.org][1])
* **Delimiters**: Don’t include `/` at start/end like `/pattern/` — they’ll fail. ([Reddit][3])
* **Modifiers**: e.g., `g`, `m`, `i` in JS don’t apply directly — use embedded flags like `(?m)` for multiline if needed. ([Reddit][4])
* **Anchors and multiline**: Godot’s default `^`/`$` match start/end of string, not necessarily each line in a multi-line subject — if you need linewise matching, you might process each line individually or use `(?m)` flag. ([Reddit][4])
* **Replacement behavior**: `sub()` supports backreferences like `$1` or `$name`, but you still need to compile first. ([Game Development Stack Exchange][2])
* **Performance**: For large files or many lines, compiling one `RegEx` instance and re-using it is better than compiling repeatedly inside loops.
* **Debugging**: If `search_all()` returns fewer matches than expected, check escaping and pattern correctness. Reddit users report Godot’s behavior may differ slightly from other testers. ([Reddit][5])

---

### 5. Summary

* Always escape your pattern properly for GDScript.
* Compile and check validity before using.
* Use `search_all()` for multiple matches.
* Avoid JS-style delimiters/modifiers.
* Document the pattern’s purpose for maintainability.

---
