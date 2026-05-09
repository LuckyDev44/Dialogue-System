class_name DialogNode
extends Node

## Controlador de diálogos en tiempo de ejecución.
## Lee un DialogGraphResource y maneja la presentación de texto,
## iconos, audio y flujo (skippable / auto).
##
## Uso:
##   1. Asigna dialog_resource en el inspector o por código.
##   2. Llama a start() para iniciar el diálogo.
##   3. Escucha la señal dialog_finished para saber cuando terminó.

signal dialog_started
signal dialog_node_shown(data: DialogNodeData)
signal dialog_finished

@export var dialog_resource: DialogGraphResource
@export var textbox_scene: PackedScene  ## Escena de la UI del textbox

## Si true, la tecla de acción es "ui_accept"; si false, solo avanza por señal
@export var use_input_action: bool = true

# Referencia a la instancia del textbox en escena
var _textbox: DialogTextbox = null

# Nodo actual
var _current_data: DialogNodeData = null

# Estado de animación
var _is_typing: bool = false
var _can_advance: bool = false

# Jugadores de audio simultáneos
var _audio_players: Array[AudioStreamPlayer] = []

# Timer para modo AUTO
var _auto_timer: SceneTreeTimer = null


func _ready() -> void:
	# Verificar que tenemos la escena del textbox
	if not textbox_scene:
		push_error("[DialogNode] No se asignó textbox_scene.")


# ──── API pública ────────────────────────────────────────────────────────────

## Inicia el diálogo desde el nodo inicial del recurso.
func start() -> void:
	if not dialog_resource:
		push_error("[DialogNode] No hay dialog_resource asignado.")
		return
	_spawn_textbox()
	dialog_started.emit()
	_show_node(dialog_resource.start_node_id)


## Inicia el diálogo desde un nodo específico por ID.
func start_from(node_id: String) -> void:
	if not dialog_resource:
		return
	_spawn_textbox()
	dialog_started.emit()
	_show_node(node_id)


## Avanza al siguiente nodo manualmente (útil para botones de UI o señales externas).
func advance() -> void:
	if not _current_data:
		return
	if _is_typing:
		_skip_typing()
	elif _can_advance:
		_go_to_next()


## Finaliza el diálogo limpiando la UI.
func finish() -> void:
	_cleanup_audio()
	if _textbox:
		_textbox.hide_textbox()
		await _textbox.hidde
		_textbox.queue_free()
		_textbox = null
	_current_data = null
	dialog_finished.emit()


# ──── Input ──────────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if not use_input_action or not _current_data:
		return
	if event.is_action_pressed("ui_accept"):
		advance()
		get_viewport().set_input_as_handled()


# ──── Flujo interno ──────────────────────────────────────────────────────────

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

	# Resolver imagen inyectada si el nodo previo era IMAGE y apuntaba a este DIALOG
	# (La inyección ya viene en el texto con el tag [img])

	if data.node_type == DialogNodeData.NodeType.IMAGE:
		# Nodo imagen: no muestra nada, simplemente avanza al siguiente
		_go_to_next()
		return

	# Configurar textbox
	_textbox.set_character(data.character_name)
	_textbox.set_icon(data.icon_left_path, data.icon_right_path, data.icon_position)

	dialog_node_shown.emit(data)

	# Reproducir audio
	_play_audio(data.audio_tracks)

	# Animar texto
	_is_typing = true
	_can_advance = false
	await _textbox.type_text(data.dialog_text)
	_is_typing = false
	_can_advance = true

	# Configurar flujo
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
		# No hay forma directa de cancelar en GD4, pero desconectamos la señal
		if _auto_timer.timeout.is_connected(_go_to_next):
			_auto_timer.timeout.disconnect(_go_to_next)
	_auto_timer = null


# ──── Audio ──────────────────────────────────────────────────────────────────

func _play_audio(tracks: Array[String]) -> void:
	for track_path in tracks:
		if track_path.is_empty() or not ResourceLoader.exists(track_path):
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


# ──── Textbox ────────────────────────────────────────────────────────────────

func _spawn_textbox() -> void:
	if _textbox:
		_textbox.queue_free()
	_textbox = textbox_scene.instantiate() as DialogTextbox
	# Añadir al CanvasLayer para que siempre esté encima
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)
	canvas.add_child(_textbox)
