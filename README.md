# DialogSystem — Godot 4.3 Dialogue Plugin

A modular **node-based Dialogue System** for Godot 4.3 focused on dynamic conversations, branching dialogue and scalable narrative workflows.

Built with a fully visual **GraphEdit interface**, DialogSystem allows developers to create dialogue sequences, conditional routes, random events and animated textbox flows directly inside the Godot editor.

> Like many modern development workflows, this project occasionally uses AI-assisted tooling for productivity tasks such as debugging, documentation and boilerplate assistance.

---

# ✨ Features

## 🎨 Visual Dialogue Editor

* Node-based GraphEdit workflow
* Drag & connect dialogue logic visually
* Modular and expandable architecture

## 💬 Dialogue System

* Dialogue nodes
* Image injection nodes
* Typewriter effect
* BBCode support
* Multi-track audio playback

## 🔀 Dynamic Flow Control

* Random branching nodes
* Conditional dialogue routes
* Start / End sequence nodes
* Runtime context variable system

## ✨ Advanced Tween Animations

* Textbox intro/outro tween animations
* Multiple tween presets
* Transition & easing controls
* Offset and scale customization
* VN-style presentation workflow

## 💾 Serialization

* Serializable `.tres` dialogue graphs
* Save/load compatible architecture

---

# 📦 Installation

## Important

If you downloaded the repository as ZIP, rename the folder:

```text
Dialogue-System-main
```

to:

```text
dialog_system
```

before placing it inside:

```text
addons/
```

The plugin uses fixed internal paths based on:

```text
res://addons/dialog_system/
```

---

## Setup

1. Download or clone the repository
2. Move the folder into:

```text
addons/dialog_system/
```

3. Open your Godot 4.3 project
4. Navigate to:

```text
Project → Project Settings → Plugins
```

5. Enable **DialogSystem**

Once enabled, the editor panel will appear automatically.

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

| Node        | Description                 |
| ----------- | --------------------------- |
| `DIALOG`    | Standard dialogue node      |
| `IMAGE`     | Inject images into dialogue |
| `RANDOM`    | Random branch selector      |
| `CONDITION` | Variable-based branching    |
| `START`     | Dialogue entry point        |
| `END`       | Ends dialogue sequence      |
| `ANIMATION` | Controls textbox tweens     |

---

# 🔀 Conditional Dialogues

Condition nodes support:

```text
==  !=  >  <  >=  <=
```

Example:

```gdscript
dialog.context_variables = {
    "player_health": 100,
    "has_key": true,
    "reputation": 5
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
| `dialog_started`          | Triggered when dialogue begins     |
| `dialog_node_shown(data)` | Triggered when a node is displayed |
| `dialog_finished`         | Triggered when dialogue ends       |

---

# 📋 Version Control

# v1.1.1 — Advanced Tween System

> Fully customizable textbox tween animations with transition & easing support.

## Added

* Advanced tween animation system
* Tween transition selector
* Tween ease selector
* Tween mode selector
* Offset & scale controls
* Runtime tween playback

## Tween Types

* `FADE`
* `SLIDE_LEFT`
* `SLIDE_RIGHT`
* `SLIDE_UP`
* `SCALE`
* `POP`
* `BOUNCE`

## Supported Transitions

* `LINEAR`
* `SINE`
* `QUAD`
* `CUBIC`
* `QUART`
* `QUINT`
* `EXPO`
* `BACK`
* `BOUNCE`
* `ELASTIC`

## Supported Ease Modes

* `IN`
* `OUT`
* `IN_OUT`
* `OUT_IN`

## Improvements

* Better VN-style presentation
* Improved textbox feedback
* Modular tween architecture

---

# v1.1 — Dynamic & Modular Flow

> Random nodes, conditions and expanded editor workflow.

## Added

* Random branch node
* Condition node
* Start node
* End node
* Animation node
* Dropdown toolbar workflow
* Multi-output branch support

## Improvements

* Cleaner Graph Editor UX
* Better runtime parsing
* Scalable node spawning architecture

---

# v1.0 — Initial Functional Release

> Core dialogue framework and visual editor.

## Added

* Visual GraphEdit editor
* Dialogue nodes
* Image nodes
* Typewriter effect
* BBCode support
* Audio playback system
* `.tres` graph serialization
* Runtime dialogue controller

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
* GDScript
* GraphEdit / GraphNode
