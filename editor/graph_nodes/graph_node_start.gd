## ─────────────────────────────────────────────────────────────────────────────
## graph_node_start.gd
## Nodo visual START — solo puerto de salida (0, derecha).
## ─────────────────────────────────────────────────────────────────────────────
@tool
class_name GraphNodeStart
extends GraphNode

signal data_changed

@onready var field_label: LineEdit = %FieldLabel

var data: DialogNodeData = null


func setup(d: DialogNodeData) -> void:
	data = d
	title = "▶ Inicio"
	field_label.text = data.start_label
	# Solo salida
	set_slot_enabled_left(0, false)
	set_slot_enabled_right(0, true)
	set_slot_color_right(0, Color(0.2, 1.0, 0.4))
	field_label.text_changed.connect(func(v):
		data.start_label = v
		data_changed.emit()
	)
