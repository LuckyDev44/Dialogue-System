class_name DialogNode
extends Node

signal dialog_started
signal dialog_node_shown(data: DialogNodeData)
signal dialog_finished

@export var dialog_resource: DialogGraphResource
@export var textbox_scene: PackedScene
@export var use_input_action: bool = true

var _textbox: DialogTextbox = null
var _current_data: DialogNodeData = null

var _is_typing: bool = false
var _can_advance: bool = false

var _audio_players: Array[AudioStreamPlayer] = []
var _auto_timer: SceneTreeTimer = null

var context_variables: Dictionary = {}

# NUEVO
var _current_tween_data: DialogNodeData = null


func _ready() -> void:
	if not textbox_scene:
		push_error("[DialogNode] No se asignó textbox_scene.")


# ─────────────────────────────────────────────────────────────
# API
# ─────────────────────────────────────────────────────────────

func start() -> void:
	if dialog_resource == null:
		push_error("[DialogNode] No hay dialog_resource asignado.")
		return

	var start_id := ""

	# Buscar START
	for node in dialog_resource.nodes:
		if node.node_type == DialogNodeData.NodeType.START:
			start_id = node.id
			break

	# Fallback al primer nodo
	if start_id.is_empty() and dialog_resource.nodes.size() > 0:
		start_id = dialog_resource.nodes[0].id

	if start_id.is_empty():
		push_error("[DialogNode] El grafo no tiene nodos.")
		return

	_spawn_textbox()

	dialog_started.emit()

	_show_node(start_id)


func start_from(node_id: String) -> void:
	if not dialog_resource:
		return

	_spawn_textbox()

	dialog_started.emit()

	_show_node(node_id)


func advance() -> void:
	if not _current_data:
		return

	if _is_typing:
		_skip_typing()
	elif _can_advance:
		_go_to_next()


func finish() -> void:
	_cleanup_audio()

	if _textbox:
		_textbox.hide_textbox()
		await _textbox.hidde
		_textbox.queue_free()
		_textbox = null

	_current_data = null

	dialog_finished.emit()


# ─────────────────────────────────────────────────────────────
# INPUT
# ─────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if not use_input_action or not _current_data:
		return

	if event.is_action_pressed("ui_accept"):
		advance()
		get_viewport().set_input_as_handled()


# ─────────────────────────────────────────────────────────────
# FLUJO
# ─────────────────────────────────────────────────────────────

func _show_node(node_id: String) -> void:
	if node_id.is_empty():
		finish()
		return

	var data := dialog_resource.get_node_by_id(node_id)

	if not data:
		push_error("[DialogNode] Nodo no encontrado: %s" % node_id)
		finish()
		return

	_current_data = data

	_cancel_auto_timer()
	_cleanup_audio()

	match data.node_type:

		DialogNodeData.NodeType.START:
			_go_to_next()
			return

		DialogNodeData.NodeType.END:
			finish()
			return

		DialogNodeData.NodeType.IMAGE:
			_go_to_next()
			return

		DialogNodeData.NodeType.ANIMATION:
			_current_tween_data = data
			_go_to_next()
			return

		DialogNodeData.NodeType.RANDOM:
			var branches := dialog_resource.get_random_branches(data.id)

			if branches.is_empty():
				finish()
				return

			var random_next := branches.pick_random()

			_show_node(random_next)
			return

		DialogNodeData.NodeType.CONDITION:
			var result := _evaluate_condition(data)

			var next_id := dialog_resource.get_next_node_id(
				data.id,
				0 if result else 1
			)

			_show_node(next_id)
			return

	# ─────────────────────────────────────────
	# DIALOG
	# ─────────────────────────────────────────

	_textbox.set_character(data.character_name)

	_textbox.set_icon(
		data.icon_left_path,
		data.icon_right_path,
		data.icon_position
	)

	# APLICAR TWEEN
	if _current_tween_data:
		_textbox.apply_tween_config(_current_tween_data)

	dialog_node_shown.emit(data)

	_play_audio(data.audio_tracks)

	_is_typing = true
	_can_advance = false

	await _textbox.type_text(data.dialog_text)

	# Limpiar tween luego del uso
	_current_tween_data = null

	_is_typing = false
	_can_advance = true

	match data.flow_type:

		DialogNodeData.FlowType.SKIPPABLE:
			_textbox.show_advance_indicator(true)

		DialogNodeData.FlowType.AUTO:
			_textbox.show_advance_indicator(false)

			_auto_timer = get_tree().create_timer(data.auto_delay)

			_auto_timer.timeout.connect(_go_to_next)


func _go_to_next() -> void:
	_cancel_auto_timer()

	_can_advance = false

	var next_id := dialog_resource.get_next_node_id(_current_data.id)

	_show_node(next_id)


func _skip_typing() -> void:
	_textbox.skip_typing()


func _cancel_auto_timer() -> void:
	if _auto_timer and not _auto_timer.is_queued_for_deletion():
		if _auto_timer.timeout.is_connected(_go_to_next):
			_auto_timer.timeout.disconnect(_go_to_next)

	_auto_timer = null


# ─────────────────────────────────────────────────────────────
# AUDIO
# ─────────────────────────────────────────────────────────────

func _play_audio(tracks: Array[String]) -> void:
	for track_path in tracks:

		if track_path.is_empty():
			continue

		if not ResourceLoader.exists(track_path):
			continue

		var player := AudioStreamPlayer.new()

		add_child(player)

		player.bus = "sounds"

		player.stream = load(track_path)

		player.play()

		_audio_players.append(player)


func _cleanup_audio() -> void:
	for p in _audio_players:
		if is_instance_valid(p):
			p.stop()
			p.queue_free()

	_audio_players.clear()


# ─────────────────────────────────────────────────────────────
# TEXTBOX
# ─────────────────────────────────────────────────────────────

func _spawn_textbox() -> void:
	if _textbox:
		_textbox.queue_free()

	_textbox = textbox_scene.instantiate() as DialogTextbox

	var canvas := CanvasLayer.new()

	canvas.layer = 100

	add_child(canvas)

	canvas.add_child(_textbox)


# ─────────────────────────────────────────────────────────────
# CONDITION
# ─────────────────────────────────────────────────────────────

func _parse_value(value: String):
	if value.is_valid_int():
		return value.to_int()

	if value.is_valid_float():
		return value.to_float()

	if value.to_lower() == "true":
		return true

	if value.to_lower() == "false":
		return false

	return value


func _evaluate_condition(data: DialogNodeData) -> bool:
	var variable_value = context_variables.get(data.condition_variable)

	var compare_value = _parse_value(data.condition_value)

	match data.condition_operator:

		DialogNodeData.ConditionOperator.EQUALS:
			return variable_value == compare_value

		DialogNodeData.ConditionOperator.NOT_EQUALS:
			return variable_value != compare_value

		DialogNodeData.ConditionOperator.GREATER:
			return variable_value > compare_value

		DialogNodeData.ConditionOperator.LESS:
			return variable_value < compare_value

		DialogNodeData.ConditionOperator.GREATER_EQUAL:
			return variable_value >= compare_value

		DialogNodeData.ConditionOperator.LESS_EQUAL:
			return variable_value <= compare_value

	return false
