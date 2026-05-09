@tool
class_name GraphNodeAnimation
extends GraphNode

signal data_changed

@onready var opt_tween: OptionButton = %OptTween
@onready var spin_duration: SpinBox = %SpinDuration
@onready var spin_delay: SpinBox = %SpinDelay
@onready var field_offset_x: SpinBox = %OffsetX
@onready var field_offset_y: SpinBox = %OffsetY
@onready var field_scale_x: SpinBox = %ScaleX
@onready var field_scale_y: SpinBox = %ScaleY

@onready var opt_transition: OptionButton = %OptTransition
@onready var opt_ease: OptionButton = %OptEase
@onready var opt_mode: OptionButton = %OptMode

var data: DialogNodeData = null


func setup(d: DialogNodeData) -> void:
	data = d

	title = "✨ Tween"

	set_slot_enabled_left(0, true)
	set_slot_color_left(0, Color.CYAN)

	set_slot_enabled_right(0, true)
	set_slot_color_right(0, Color.CYAN)

	_build_ui()
	_load_data()
	_connect_signals()


func _build_ui() -> void:

	opt_tween.clear()
	opt_transition.clear()
	opt_ease.clear()
	opt_mode.clear()

	for t in DialogNodeData.TweenType.keys():
		opt_tween.add_item(t)

	for t in DialogNodeData.TweenTransition.keys():
		opt_transition.add_item(t)

	for e in DialogNodeData.TweenEase.keys():
		opt_ease.add_item(e)

	for m in DialogNodeData.TweenMode.keys():
		opt_mode.add_item(m)


func _load_data() -> void:
	opt_tween.selected = data.tween_type

	spin_duration.value = data.tween_duration
	spin_delay.value = data.tween_delay

	field_offset_x.value = data.tween_offset.x
	field_offset_y.value = data.tween_offset.y

	field_scale_x.value = data.tween_start_scale.x
	field_scale_y.value = data.tween_start_scale.y
	opt_transition.selected = data.tween_transition
	opt_ease.selected = data.tween_ease
	opt_mode.selected = data.tween_mode


func _connect_signals() -> void:
	opt_tween.item_selected.connect(func(idx):
		data.tween_type = idx
		data_changed.emit()
	)

	spin_duration.value_changed.connect(func(v):
		data.tween_duration = v
		data_changed.emit()
	)

	spin_delay.value_changed.connect(func(v):
		data.tween_delay = v
		data_changed.emit()
	)

	field_offset_x.value_changed.connect(func(v):
		data.tween_offset.x = v
		data_changed.emit()
	)

	field_offset_y.value_changed.connect(func(v):
		data.tween_offset.y = v
		data_changed.emit()
	)

	field_scale_x.value_changed.connect(func(v):
		data.tween_start_scale.x = v
		data_changed.emit()
	)

	field_scale_y.value_changed.connect(func(v):
		data.tween_start_scale.y = v
		data_changed.emit()
	)
	
	opt_transition.item_selected.connect(func(idx):
		data.tween_transition = idx
		data_changed.emit()
	)

	opt_ease.item_selected.connect(func(idx):
		data.tween_ease = idx
		data_changed.emit()
	)

	opt_mode.item_selected.connect(func(idx):
		data.tween_mode = idx
		data_changed.emit()
	)
	
