@tool
class_name GraphNodeEnd
extends GraphNode

## Nodo visual END — solo puerto de entrada (0, izquierda).
## Marca el cierre de una rama narrativa.

signal data_changed

@onready var field_label: LineEdit = %FieldLabel

var data: DialogNodeData = null


func setup(d: DialogNodeData) -> void:
	data = d
	title = "⏹ Fin"
	field_label.text = data.end_label
	# Solo entrada
	set_slot_enabled_left(0, true)
	set_slot_color_left(0, Color(0.9, 0.3, 0.3))
	set_slot_enabled_right(0, false)
	field_label.text_changed.connect(func(v):
		data.end_label = v
		data_changed.emit()
	)
