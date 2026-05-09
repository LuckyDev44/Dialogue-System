@tool
class_name GraphNodeCondition
extends GraphNode

## Nodo visual CONDITION dentro del GraphEdit.
## Puerto de salida 0 → rama TRUE
## Puerto de salida 1 → rama FALSE

signal data_changed

@onready var field_variable: LineEdit    = %FieldVariable
@onready var opt_operator: OptionButton  = %OptOperator
@onready var field_value: LineEdit       = %FieldValue
@onready var lbl_preview: Label          = %LblPreview

var data: DialogNodeData = null


func setup(d: DialogNodeData) -> void:
	data = d
	title = "❓ Condición"
	_refresh_ui()
	_connect_signals()
	_setup_slots()


func _setup_slots() -> void:
	# Slot 0 (entrada única, izquierda)
	set_slot_enabled_left(0, true)
	set_slot_color_left(0, Color.CYAN)
	# Slot 0 (salida TRUE, derecha) — mismo slot, distinto lado
	set_slot_enabled_right(0, true)
	set_slot_color_right(0, Color(0.2, 0.9, 0.2))   # verde = TRUE
	# Slot 1 (salida FALSE, derecha)
	set_slot_enabled_right(1, true)
	set_slot_color_right(1, Color(0.9, 0.2, 0.2))   # rojo  = FALSE


func _refresh_ui() -> void:
	if not data:
		return
	field_variable.text = data.condition_variable
	field_value.text    = data.condition_value

	opt_operator.clear()
	var ops := ["== (igual)", "!= (distinto)", "> (mayor)", "< (menor)", ">= (mayor-igual)", "<= (menor-igual)"]
	for op in ops:
		opt_operator.add_item(op)
	opt_operator.selected = data.condition_operator
	_update_preview()


func _connect_signals() -> void:
	field_variable.text_changed.connect(func(v):
		data.condition_variable = v
		_update_preview()
		data_changed.emit()
	)
	opt_operator.item_selected.connect(func(idx):
		data.condition_operator = idx as DialogNodeData.ConditionOperator
		_update_preview()
		data_changed.emit()
	)
	field_value.text_changed.connect(func(v):
		data.condition_value = v
		_update_preview()
		data_changed.emit()
	)


func _update_preview() -> void:
	if not lbl_preview:
		return
	var op_symbols := ["==", "!=", ">", "<", ">=", "<="]
	var op_str: String = op_symbols[data.condition_operator] if data.condition_operator < op_symbols.size() else "?"
	var var_str := data.condition_variable if not data.condition_variable.is_empty() else "variable"
	var val_str := data.condition_value    if not data.condition_value.is_empty()    else "valor"
	lbl_preview.text = "if  %s  %s  %s" % [var_str, op_str, val_str]
