@tool
class_name DialogGraphEditor
extends Control

## Editor visual de diálogos — v1.1
## Cambios respecto a v1.0:
##   - Toolbar reemplazada por OptionButton + botón "+" único.
##   - Soporte para los 5 nuevos tipos de nodo.
##   - La lógica de spawn, conexión y guardado es idéntica a v1.0.

const DialogNodeData      = preload("res://addons/dialog_system/resources/dialog_node_data.gd")
const DialogGraphResource = preload("res://addons/dialog_system/resources/dialog_graph_resource.gd")

# ── Escenas de los nodos del editor ──────────────────────────────────────────
const SCENES := {
	DialogNodeData.NodeType.DIALOG:    "res://addons/dialog_system/editor/graph_nodes/graph_node_dialog.tscn",
	DialogNodeData.NodeType.IMAGE:     "res://addons/dialog_system/editor/graph_nodes/graph_node_image.tscn",
	DialogNodeData.NodeType.RANDOM:    "res://addons/dialog_system/editor/graph_nodes/graph_node_random.tscn",
	DialogNodeData.NodeType.CONDITION: "res://addons/dialog_system/editor/graph_nodes/graph_node_condition.tscn",
	DialogNodeData.NodeType.START:     "res://addons/dialog_system/editor/graph_nodes/graph_node_start.tscn",
	DialogNodeData.NodeType.END:       "res://addons/dialog_system/editor/graph_nodes/graph_node_end.tscn",
	DialogNodeData.NodeType.ANIMATION: "res://addons/dialog_system/editor/graph_nodes/graph_node_animation.tscn",
}

## Etiquetas y emojis para el OptionButton del dropdown
const NODE_LABELS := {
	DialogNodeData.NodeType.DIALOG:    "💬  Diálogo",
	DialogNodeData.NodeType.IMAGE:     "🖼  Imagen",
	DialogNodeData.NodeType.RANDOM:    "🎲  Aleatorio",
	DialogNodeData.NodeType.CONDITION: "❓  Condición",
	DialogNodeData.NodeType.START:     "▶  Inicio",
	DialogNodeData.NodeType.END:       "⏹  Fin",
	DialogNodeData.NodeType.ANIMATION: "✨  Animación",
}

# ── Referencias a nodos de la escena ─────────────────────────────────────────
@onready var graph_edit: GraphEdit       = %GraphEdit
@onready var opt_node_type: OptionButton = %OptNodeType   ## ← nuevo dropdown
@onready var btn_add: Button             = %BtnAdd         ## ← único botón "+"
@onready var btn_save: Button            = %BtnSave
@onready var btn_load: Button            = %BtnLoad
@onready var btn_clear: Button           = %BtnClear
@onready var lbl_status: Label           = %LblStatus
@onready var save_dialog: FileDialog     = %SaveFileDialog
@onready var load_dialog: FileDialog     = %LoadFileDialog

var current_resource: DialogGraphResource = null
var graph_nodes: Dictionary = {}   ## { node_id: GraphNode }


func _ready() -> void:
	current_resource = DialogGraphResource.new()
	_populate_dropdown()

	# GraphEdit
	graph_edit.connection_request.connect(_on_connection_request)
	graph_edit.disconnection_request.connect(_on_disconnection_request)
	graph_edit.delete_nodes_request.connect(_on_delete_nodes_request)

	# Toolbar v1.1
	btn_add.pressed.connect(_on_add_pressed)
	btn_save.pressed.connect(func(): save_dialog.popup_centered(Vector2i(800, 500)))
	btn_load.pressed.connect(func(): load_dialog.popup_centered(Vector2i(800, 500)))
	btn_clear.pressed.connect(_clear_graph)

	save_dialog.file_selected.connect(_save_resource)
	load_dialog.file_selected.connect(_load_resource)

	_set_status("v1.1 lista. Selecciona un tipo y pulsa '+'.")


# ──── Dropdown ────────────────────────────────────────────────────────────────

func _populate_dropdown() -> void:
	opt_node_type.clear()
	for type in NODE_LABELS.keys():
		opt_node_type.add_item(NODE_LABELS[type], type)
	opt_node_type.selected = 0


func _on_add_pressed() -> void:
	var type_id: int = opt_node_type.get_item_id(opt_node_type.selected)
	var type := type_id as DialogNodeData.NodeType
	_add_node(type)


# ──── Creación de nodos ───────────────────────────────────────────────────────

func _add_node(type: DialogNodeData.NodeType) -> void:
	var data := DialogNodeData.new()
	data.setup(type)
	current_resource.add_node(data)
	_spawn_graph_node(data)
	_set_status("Nodo '%s' agregado." % NODE_LABELS.get(type, str(type)))


func _spawn_graph_node(data: DialogNodeData) -> Control:
	var scene_path: String = SCENES.get(data.node_type, "")
	if scene_path.is_empty():
		push_error("[DialogGraphEditor] Sin escena para tipo: %d" % data.node_type)
		return null

	var scene: PackedScene = load(scene_path)
	var gnode: GraphNode   = scene.instantiate()
	graph_edit.add_child(gnode)

	gnode.position_offset = data.graph_position if data.graph_position != Vector2.ZERO \
						  else _centered_position()
	gnode.name = data.id
	gnode.setup(data)
	gnode.data_changed.connect(func(): pass)  # los datos se actualizan in-place
	gnode.position_offset_changed.connect(func(): data.graph_position = gnode.position_offset)

	graph_nodes[data.id] = gnode
	return gnode


func _centered_position() -> Vector2:
	return graph_edit.size / 2.0 + Vector2(randf_range(-100, 100), randf_range(-60, 60))


# ──── Señales del GraphEdit ───────────────────────────────────────────────────

func _on_connection_request(from_node: StringName, from_port: int,
							to_node: StringName,   to_port: int) -> void:
	graph_edit.connect_node(from_node, from_port, to_node, to_port)
	current_resource.add_connection(from_node, from_port, to_node, to_port)


func _on_disconnection_request(from_node: StringName, from_port: int,
							   to_node: StringName,   to_port: int) -> void:
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)
	current_resource.remove_connection(from_node, from_port, to_node, to_port)


func _on_delete_nodes_request(nodes_to_delete: Array) -> void:
	for node_name in nodes_to_delete:
		var gnode = graph_nodes.get(node_name)
		if gnode:
			current_resource.remove_node(node_name)
			graph_nodes.erase(node_name)
			gnode.queue_free()
	_set_status("Nodo(s) eliminado(s).")


# ──── Guardar / Cargar ────────────────────────────────────────────────────────

func _save_resource(path: String) -> void:
	var err := ResourceSaver.save(current_resource, path)
	_set_status("Guardado en: %s" % path if err == OK else "ERROR al guardar: %d" % err)


func _load_resource(path: String) -> void:
	var res = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)
	if not res is DialogGraphResource:
		_set_status("ERROR: no es un DialogGraphResource.")
		return
	_clear_graph()
	current_resource = res
	for data in current_resource.nodes:
		_spawn_graph_node(data)
	for c in current_resource.connections:
		graph_edit.connect_node(c.from_node, c.from_port, c.to_node, c.to_port)
	_set_status("Cargado: %s" % path)


func _clear_graph() -> void:
	for gnode in graph_nodes.values():
		gnode.queue_free()
	graph_nodes.clear()
	graph_edit.clear_connections()
	current_resource = DialogGraphResource.new()
	_set_status("Grafo limpiado.")


# ──── Helpers ─────────────────────────────────────────────────────────────────

func _set_status(msg: String) -> void:
	if lbl_status:
		lbl_status.text = "● " + msg
