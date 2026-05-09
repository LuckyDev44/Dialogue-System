@tool
class_name GraphNodeDialog
extends GraphNode

## Nodo visual dentro del GraphEdit que representa un nodo de diálogo.
## Expone los campos editables y emite data_changed cuando algo cambia.

signal data_changed

@onready var field_char_name: LineEdit      = %FieldCharName
@onready var field_text: TextEdit           = %FieldText
@onready var opt_flow: OptionButton         = %OptFlow
@onready var spin_delay: SpinBox            = %SpinDelay
@onready var opt_icon_pos: OptionButton     = %OptIconPos
@onready var field_icon_left: LineEdit      = %FieldIconLeft
@onready var field_icon_right: LineEdit     = %FieldIconRight
@onready var container_icon_right: HBoxContainer = %ContainerIconRight
@onready var audio_list: VBoxContainer      = %AudioList
@onready var btn_add_audio: Button          = %BtnAddAudio

var data: DialogNodeData = null


func setup(d: DialogNodeData) -> void:
	data = d
	title = "💬 Diálogo"
	_refresh_ui()
	_connect_signals()


func _refresh_ui() -> void:
	if not data:
		return
	field_char_name.text = data.character_name
	field_text.text      = data.dialog_text

	# Flow type
	opt_flow.clear()
	opt_flow.add_item("Skippable (jugador avanza)", DialogNodeData.FlowType.SKIPPABLE)
	opt_flow.add_item("Auto (por tiempo/señal)",    DialogNodeData.FlowType.AUTO)
	opt_flow.selected = data.flow_type

	spin_delay.value   = data.auto_delay
	spin_delay.visible = data.flow_type == DialogNodeData.FlowType.AUTO

	# Icon position
	opt_icon_pos.clear()
	opt_icon_pos.add_item("Izquierda", DialogNodeData.IconPosition.LEFT)
	opt_icon_pos.add_item("Derecha",   DialogNodeData.IconPosition.RIGHT)
	opt_icon_pos.add_item("Duo",       DialogNodeData.IconPosition.DUO)
	opt_icon_pos.selected = data.icon_position

	field_icon_left.text  = data.icon_left_path
	field_icon_right.text = data.icon_right_path
	_update_icon_right_visibility()

	# Audio tracks
	_rebuild_audio_list()


func _connect_signals() -> void:
	field_char_name.text_changed.connect(func(v): data.character_name = v; data_changed.emit())
	field_text.text_changed.connect(func(): data.dialog_text = field_text.text; data_changed.emit())

	opt_flow.item_selected.connect(func(idx):
		data.flow_type = idx as DialogNodeData.FlowType
		spin_delay.visible = idx == DialogNodeData.FlowType.AUTO
		data_changed.emit()
	)
	spin_delay.value_changed.connect(func(v): data.auto_delay = v; data_changed.emit())

	opt_icon_pos.item_selected.connect(func(idx):
		data.icon_position = idx as DialogNodeData.IconPosition
		_update_icon_right_visibility()
		data_changed.emit()
	)
	field_icon_left.text_changed.connect(func(v): data.icon_left_path = v; data_changed.emit())
	field_icon_right.text_changed.connect(func(v): data.icon_right_path = v; data_changed.emit())

	btn_add_audio.pressed.connect(_add_audio_track)


func _update_icon_right_visibility() -> void:
	var pos := opt_icon_pos.selected as DialogNodeData.IconPosition
	container_icon_right.visible = (pos == DialogNodeData.IconPosition.RIGHT \
								or pos == DialogNodeData.IconPosition.DUO)


func _add_audio_track() -> void:
	data.audio_tracks.append("")
	_rebuild_audio_list()
	data_changed.emit()


func _rebuild_audio_list() -> void:
	# Limpiar hijos previos (excepto el botón de agregar)
	for child in audio_list.get_children():
		if child != btn_add_audio:
			child.queue_free()
	# Recrear por cada pista
	for i in data.audio_tracks.size():
		var row := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = "Track %d:" % (i + 1)
		var field := LineEdit.new()
		field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		field.text = data.audio_tracks[i]
		field.placeholder_text = "res://audio/voice.ogg"
		var idx := i  # capturar índice para la lambda
		field.text_changed.connect(func(v):
			data.audio_tracks[idx] = v
			data_changed.emit()
		)
		var btn_del := Button.new()
		btn_del.text = "✕"
		btn_del.pressed.connect(func():
			data.audio_tracks.remove_at(idx)
			_rebuild_audio_list()
			data_changed.emit()
		)
		row.add_child(lbl)
		row.add_child(field)
		row.add_child(btn_del)
		audio_list.add_child(row)
		audio_list.move_child(row, audio_list.get_child_count() - 2)
