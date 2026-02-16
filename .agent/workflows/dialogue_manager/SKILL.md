---
description: Comprehensive guide for Godot Dialogue Manager (v2.x/3.x)
---

# Godot Dialogue Manager Skill

## 1. Core Concepts
- **Stateless**: The manager queries game state (Globals/Autoloads) but doesn't store it.
- **Resource-Based**: Dialogues are written in `.dialogue` text files imported as `DialogueResource`.
- **Headless**: Provides data (`DialogueLine`); you implement the UI ("Balloon") or use the default one.

## 2. Dialogue Syntax (Ref: `.dialogue` files)

### Basic Conversation
```swift
~ start
Character: text
Character: text with [b]BBCode[/b].
Character: text with [wait=1] pause.
- Option 1
    Character: You chose 1.
- Option 2 => jump_to_title
=> END
```

### Flow Control & Logic
| Feature         | Syntax                   | Example                                                            |
| :-------------- | :----------------------- | :----------------------------------------------------------------- |
| **Title**       | `~ title`                | `~ start`                                                          |
| **Jump**        | `=> title`               | `=> start`                                                         |
| **Return Jump** | `=>< title`              | `=>< sub_dialogue` (returns after `=> END`)                        |
| **End**         | `=> END`                 | Ends conversation.                                                 |
| **Variables**   | `{{Global.var}}`         | `Hello {{Player.name}}!`                                           |
| **Conditions**  | `if`/`elif`/`else`       | `[if Player.gold > 10]` or block syntax.                           |
| **Mutations**   | `do`/`set`               | `do Player.heal(5)` or `set Player.gold -= 5`                      |
| **Random**      | `%` or `%Weight`         | `% Hello` (Equal chace), `%2 Hi` (Double chance).                  |
| **Import**      | `import "path" as alias` | `import "res://common.dialogue" as common` then `=>< common/start` |

### Special Flow Blocks
- **Match**:
  ```swift
  match state
  - "happy": I am happy!
  - "sad": I am sad.
  ```
- **While**:
  ```swift
  while gold > 0
      do gold -= 1
      Char: Spending gold...
  ```

### Typing Effects & BBCode
Godot Dialogue Manager supports **all standard Godot RichTextLabel BBCode**.

#### Standard Formatting
| Tag           | Description                    | Example                         |
| :------------ | :----------------------------- | :------------------------------ |
| **Bold**      | `[b]...[/b]`                   | `[b]Bold[/b]`                   |
| **Italic**    | `[i]...[/i]`                   | `[i]Italic[/i]`                 |
| **Color**     | `[color=NAME/HEX]...[/color]`  | `[color=red]Red[/color]`        |
| **Font Size** | `[font_size=N]...[/font_size]` | `[font_size=24]Big[/font_size]` |
| **Center**    | `[center]...[/center]`         | `[center]Centered[/center]`     |

#### Animated Effects
| Tag         | Description                                              | Example                       |
| :---------- | :------------------------------------------------------- | :---------------------------- |
| **Wave**    | `[wave amp=50 freq=2]...[/wave]`                         | `[wave]Wavy text[/wave]`      |
| **Tornado** | `[tornado radius=5 freq=2]...[/tornado]`                 | `[tornado]Spinning[/tornado]` |
| **Shake**   | `[shake rate=5 level=10]...[/shake]`                     | `[shake]Shaking![/shake]`     |
| **Fade**    | `[fade start=4 length=14]...[/fade]`                     | `[fade]Fading out[/fade]`     |
| **Rainbow** | `[rainbow freq=0.2 sat=10 val=20]...[/rainbow]`          | `[rainbow]Colorful[/rainbow]` |
| **Ghost**   | `[ghost freq=5 span=10]...[/ghost]`                      | `[ghost]Spooky[/ghost]`       |
| **Pulse**   | `[pulse freq=1.0 color=#ffffff44 height=0.0]...[/pulse]` | `[pulse]Throbbing[/pulse]`    |
| **Matrix**  | `[matrix clean=2.0 dirty=1.0 span=50]...[/matrix]`       | `[matrix]Hacker[/matrix]`     |

#### Dialogue Manager Specifics
- `[wait=N]`: Pause `N` seconds.
- `[wait=auto]`: Pause based on text length.
- `[speed=N]`: Speed multiplier (e.g., `0.2` very slow).
- `[next=auto]`: Auto-advance line after typing.
- `[next=N]`: Auto-advance after `N` seconds.

### Creating Custom Effects
To create your own tag (e.g., `[my_effect]`):

1. **Create Script**: Extend `RichTextEffect`.
    ```gdscript
    # my_effect.gd
    @tool
    class_name RichTextMyEffect
    extends RichTextEffect

    # Define the tag name
    var bbcode = "my_effect"

    func _process_custom_fx(char_fx: CharFXTransform) -> bool:
        # Get parameters from the tag [my_effect speed=10]
        var speed = char_fx.env.get("speed", 5.0)

        # Modify character properties
        # elapsed_time, relative_index, absolute_index, offset, color, etc.
        var sine = sin(char_fx.elapsed_time * speed + char_fx.relative_index)
        char_fx.offset.y += sine * 5.0

        # Return true to keep processing
        return true
    ```
2. **Register**:
    - Create a `RichTextEffect` resource accessing your script (or just add the script if it's a tool).
    - Add it to your `RichTextLabel`'s **Custom Effects** array in the Inspector.
3. **Use**: `[my_effect speed=10]Hello World[/my_effect]`.

## 3. GDScript Integration

### API: `DialogueManager`
- `show_dialogue_balloon(resource, title)`: Quick debug UI.
- `get_next_dialogue_line(resource, key, extra_states)`: **Core function**. Returns `DialogueLine`.
- `create_resource_from_text(string)`: compile dialogue at runtime.
- **Signals**:
    - `dialogue_ended(resource)`: Useful to unlock player movement.
    - `dialogue_started(resource)`
    - `mutated(mutation)`

### `DialogueLine` Object
Properties returned by `get_next_dialogue_line`:
- `text`: String (The raw text).
- `character`: String (Speaker name).
- `responses`: Array[`DialogueResponse`] (`text`, `next_id`, `is_allowed`).
- `next_id`: String (ID for next line).
- `tags`: Array[String] (e.g. `[#happy]`).
- `time`: String (if `[wait]` used).
- `translation_key`: String.

### `DialogueLabel` (RichTextLabel)
Helper node to handle typing effects.
- **Setup**: `dialogue_label.dialogue_line = line`
- **Trigger**: `dialogue_label.type_out()`
- **Signals**: `started_typing`, `finished_typing`, `spoke(letter, speed, pitch)`, `paused_typing(duration)`.

## 4. Custom UI Implementation Pattern
**Best Practice**: Create a `CanvasLayer` scene for your UI.

```gdscript
extends CanvasLayer

func start(resource: DialogueResource, title: String, extra_game_states: Array = []):
    var line = await DialogueManager.get_next_dialogue_line(resource, title, extra_game_states)
    while line != null:
        # 1. Update UI (Portrait, Name, Text)
        dialogue_label.dialogue_line = line
        dialogue_label.type_out()

        # 2. Wait for Input or Completion
        await await_input_or_skip()

        # 3. Handle Responses or Continue
        if line.responses.size() > 0:
            var response = await wait_for_response(line.responses)
            line = await DialogueManager.get_next_dialogue_line(resource, response.next_id, extra_game_states)
        else:
            line = await DialogueManager.get_next_dialogue_line(resource, line.next_id, extra_game_states)

    queue_free() # or hide()
```

## 5. Player Interaction Tips
- **Block Movement**: Handle input in `_unhandled_input` so the dialogue UI (if it consumes input) can block it. Or use `DialogueManager.dialogue_started` / `ended` signals to toggle a `is_active` flag on the player.

## 6. Project Settings
- **State Shortcuts**: Add singletons to `Project Settings > Dialogue Manager > States` to use `gold` instead of `Player.gold`.
- **Missing State**: Toggle "Ignore Missing State Values" for looser error checking.
- **Balloon Path**: correct path to your custom balloon scene.

## 7. Localization
- **Format**: `Text [ID:KEY_NAME]`.
- **Translators Notes**: Add `## Comment` before line.
- **Workflow**:
    1. Add IDs.
    2. "Translations" tab > Export CSV.
    3. Translate.
    4. Re-import CSV.

## 8. Debugging
- **Visualizer**: Enable "Show Dialogue Visualizer" in Debug menu to see history/state variables.
- **Syntax Check**: The editor highlights syntax errors immediately.
*   **Dialogue Not Appearing/Loading**: Ensure your `.dialogue` file is recognized. Open the **Dialogue** bottom panel in Godot to verify syntax and ensure the file is imported correctly. This is a common "gotcha".
*   **Stuck on First Line**: Check your input handling. Use `gui_input` on a full-screen Control to reliably capture mouse clicks, as `_input` might be consumed by other UI.
*   **Dialogue Not Appearing/Loading**: Ensure your `.dialogue` file is recognized. Open the **Dialogue** bottom panel in Godot to verify syntax and ensure the file is imported correctly. This is a common "gotcha".
*   **Stuck on First Line**: Check your input handling. Use `gui_input` on a full-screen Control to reliably capture mouse clicks, as `_input` might be consumed by other UI.
