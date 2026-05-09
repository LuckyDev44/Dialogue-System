# DialogSystem — Plugin para Godot 4.3

Sistema de diálogos basado en nodos con editor visual (GraphEdit).

---

## 📁 Estructura de archivos

```
addons/dialog_system/
├── plugin.cfg
├── plugin.gd                          ← Entrada del plugin al editor
├── resources/
│   ├── dialog_graph_resource.gd       ← Resource que se guarda como .tres
│   └── dialog_node_data.gd            ← Datos de un nodo individual
├── editor/
│   ├── dialog_graph_editor.gd         ← Controlador del editor visual
│   ├── dialog_graph_editor.tscn       ← (Debes crear esta escena, ver abajo)
│   └── graph_nodes/
│       ├── graph_node_dialog.gd       ← Nodo visual tipo DIALOG
│       ├── graph_node_dialog.tscn     ← (Debes crear esta escena, ver abajo)
│       ├── graph_node_image.gd        ← Nodo visual tipo IMAGE
│       └── graph_node_image.tscn      ← (Debes crear esta escena, ver abajo)
└── nodes/
    ├── dialog_node.gd                 ← Controlador runtime
    ├── dialog_textbox.gd              ← UI del textbox
    └── dialog_textbox.tscn            ← Escena del textbox
```

---

## ⚙️ Instalación

1. Copia la carpeta `addons/dialog_system/` a tu proyecto.
2. Ve a **Project → Project Settings → Plugins** y activa **DialogSystem**.
3. Verás el botón **"Dialog Editor"** en el panel inferior del editor.

---

## 🏗️ Escenas que debes crear manualmente

### `dialog_graph_editor.tscn`

Raíz: `Control` con script `dialog_graph_editor.gd`

```
Control
├── VBoxContainer
│   ├── HBoxContainer (toolbar)
│   │   ├── Button (unique: BtnAddDialog)   text="+ Diálogo"
│   │   ├── Button (unique: BtnAddImage)    text="+ Imagen"
│   │   ├── HSeparator
│   │   ├── Button (unique: BtnSave)        text="💾 Guardar"
│   │   ├── Button (unique: BtnLoad)        text="📂 Cargar"
│   │   └── Button (unique: BtnClear)       text="🗑 Limpiar"
│   └── GraphEdit (unique: GraphEdit)
│       └── [zoom_min=0.3, zoom_max=2.5, snapping_enabled=true]
├── Label (unique: LblStatus)
├── FileDialog (unique: SaveFileDialog)
│   └── [file_mode=SAVE_FILE, filters=["*.tres"]]
└── FileDialog (unique: LoadFileDialog)
    └── [file_mode=OPEN_FILE, filters=["*.tres"]]
```

### `graph_node_dialog.tscn`

Raíz: `GraphNode` con script `graph_node_dialog.gd`
- **Puerto de entrada** (slot 0, izquierda)
- **Puerto de salida** (slot 0, derecha)

```
GraphNode
└── VBoxContainer
    ├── LineEdit (unique: FieldCharName)       placeholder="Nombre personaje"
    ├── TextEdit (unique: FieldText)           placeholder="Texto del diálogo…"
    ├── OptionButton (unique: OptFlow)
    ├── SpinBox (unique: SpinDelay)            min=0.1 max=30.0 step=0.1
    ├── OptionButton (unique: OptIconPos)
    ├── HBoxContainer
    │   ├── Label                              text="Icono Izq:"
    │   └── LineEdit (unique: FieldIconLeft)
    ├── HBoxContainer (unique: ContainerIconRight)
    │   ├── Label                              text="Icono Der:"
    │   └── LineEdit (unique: FieldIconRight)
    ├── VBoxContainer (unique: AudioList)
    │   └── Button (unique: BtnAddAudio)       text="+ Audio Track"
```

> En el inspector de GraphNode activa los slots:
> - Slot 0: `enable_left_port = true`, `enable_right_port = true`

### `graph_node_image.tscn`

Raíz: `GraphNode` con script `graph_node_image.gd`
- **Puerto de entrada** (slot 0, izquierda)
- **Puerto de salida** (slot 0, derecha)

```
GraphNode
└── VBoxContainer
    ├── HBoxContainer
    │   ├── Label                              text="Ruta imagen:"
    │   └── LineEdit (unique: FieldImagePath)  placeholder="res://sprites/item.png"
    ├── Label (unique: LblPreviewTag)
    └── TextureRect (unique: PreviewRect)      custom_min_size=(120,120) stretch_mode=KEEP_ASPECT_CENTERED
```

---

## 🎮 Uso en tu juego

### 1. Crear un diálogo en el editor

1. Abre el **Dialog Editor** desde el panel inferior.
2. Haz clic en **+ Diálogo** para agregar nodos.
3. Conecta los nodos arrastrando desde el puerto derecho al izquierdo.
4. Guarda con **💾 Guardar** como `.tres`.

### 2. Usar DialogNode en escena

```gdscript
# En tu escena de juego:
@onready var dialog: DialogNode = $DialogNode

func _ready():
    dialog.dialog_resource = preload("res://dialogs/mi_dialogo.tres")
    dialog.textbox_scene = preload("res://addons/dialog_system/nodes/dialog_textbox.tscn")
    dialog.dialog_finished.connect(_on_dialog_done)

func hablar():
    dialog.start()

func _on_dialog_done():
    print("Diálogo terminado!")
```

### 3. Inyectar imágenes en texto

Desde el editor, conecta un nodo **Imagen** antes de un nodo **Diálogo** y referencia el tag en el texto:

```
Encontraste [img]res://sprites/llave.png[/img] ¡una llave dorada!
```

### 4. Avanzar diálogos por señal externa (modo AUTO)

```gdscript
# Cuando termina una animación, avanzar el diálogo:
func _on_animation_finished():
    $DialogNode.advance()
```

---

## 🔧 Personalizar la apariencia del textbox

Edita `dialog_textbox.tscn` y ajusta:
- `StyleBoxFlat` del `PanelContainer` para colores y bordes.
- Tamaños de fuente en `LabelCharName` y `RichText`.
- Posición del `AdvanceIndicator`.
- Agrega animaciones `show` y `hide` en el `AnimationPlayer` para transiciones.

---

## 📝 Señales disponibles en DialogNode

| Señal | Descripción |
|-------|-------------|
| `dialog_started` | Se emite al llamar `start()` |
| `dialog_node_shown(data)` | Se emite al mostrar cada nodo |
| `dialog_finished` | Se emite cuando no hay más nodos |
