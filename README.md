# DialogSystem — Godot 4.3 Dialogue Plugin

A modular node-based Dialogue System for Godot 4.3 focused on dynamic conversations, branching dialogue and scalable narrative workflows.

Built with a visual GraphEdit interface, this plugin allows you to create dialogue sequences, conditional routes, random events and animated textbox flows directly inside the editor.

---

# ✨ Features

* Visual node-based dialogue editor
* Dialogue and image nodes
* Random dialogue branching
* Conditional dialogue routes
* Start and End sequence nodes
* Dialogue animation nodes
* Typewriter effect
* BBCode support
* Multi-track audio support
* Serializable `.tres` dialogue graphs
* Modular and expandable architecture

---

# 📦 Installation

1. Download or clone the repository.
2. Copy the `dialog_system` folder into your project's `addons/` directory.
3. Open your Godot 4.3 project.
4. Go to:

```text
Project → Project Settings → Plugins
```

5. Enable **DialogSystem**.

Once enabled, the plugin will appear inside the editor automatically.

---

# 🚀 Basic Usage

```gdscript
@onready var dialog: DialogNode = $DialogNode

func _ready() -> void:
    dialog.dialog_resource = preload("res://dialogs/example_dialog.tres")
    dialog.textbox_scene = preload("res://addons/dialog_system/nodes/dialog_textbox.tscn")

func start_dialog() -> void:
    dialog.start()
```

---

# 🧩 Available Node Types

| Node      | Description                     |
| --------- | ------------------------------- |
| DIALOG    | Standard dialogue node          |
| IMAGE     | Inject images into dialogue     |
| RANDOM    | Randomly selects a branch       |
| CONDITION | Branches depending on variables |
| START     | Entry point node                |
| END       | Ends the dialogue sequence      |
| ANIMATION | Controls textbox animations     |

---

# 🔀 Conditional Dialogues

Condition nodes support operators such as:

* `==`
* `!=`
* `>`
* `<`
* `>=`
* `<=`

Example:

```gdscript
dialog.context_variables = {
    "player_health": 100,
    "has_key": true
}
```

---

# 🖼️ BBCode Image Injection

```text
You found [img]res://sprites/key.png[/img] a golden key!
```

---

# 📡 Signals

| Signal                    | Description                        |
| ------------------------- | ---------------------------------- |
| `dialog_started`          | Triggered when dialogue starts     |
| `dialog_node_shown(data)` | Triggered when a node is displayed |
| `dialog_finished`         | Triggered when dialogue ends       |

---

# 📋 Version Control

## v1.1 — Dynamic & Modular Flow

> Random nodes · Conditions · Animation nodes · Improved toolbar workflow

### Added

* Random branch node
* Condition node
* Start node
* End node
* Animation node
* Dropdown-based toolbar
* Multi-output support for random branches
* Conditional execution system
* Animation sequencing support

### Improved

* Cleaner Graph Editor workflow
* More scalable node spawning system
* Expanded node type architecture
* Runtime condition parsing

---

## v1.0 — Initial Functional Release

> Core dialogue workflow · Graph editor · Typewriter system

### Added

* Visual GraphEdit dialogue editor
* Dialogue nodes
* Image nodes
* Typewriter effect
* BBCode support
* Multi-track audio playback
* `.tres` graph serialization
* Runtime dialogue controller
* Dialogue signals system

---

# 🛣️ Roadmap

Planned future features:

* Choice nodes
* Event/action nodes
* Save/load integration
* Portrait animation support
* Camera event integration
* Timeline/cutscene support

---

# 🛠️ Built With

* Godot 4.3
* GraphEdit / GraphNode
* GDScript
