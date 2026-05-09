@tool
class_name DialogGraphEditor
extends Control

## Editor visual de diálogos basado en GraphEdit.
## Permite crear, conectar y configurar nodos de diálogo.

const DialogNodeData = preload("res://addons/dialog_system/resources/dialog_node_data.gd")
const DialogGraphResource = preload("res://addons/dialog_system/resources/dialog_graph_resource.gd")
const GRAPH_NODE_DIALOG_SCENE = preload("res://addons/dialog_system/editor/graph_nodes/graph_node_dialog.tscn")
const GRAPH_NODE_IMAGE_SCENE  = preload("res://addons/dialog_system/editor/graph_nodes/graph_node_image.tscn")

@onready var graph_edit: GraphEdit       = %GraphEdit
@onready var btn_add_dialog: Button      = %BtnAddDialog
@onready var btn_add_image: Button       = %BtnAddImage
@onready var btn_save: Button            = %BtnSave
@onready var btn_load: Button            = %BtnLoad
@onready var btn_clear: Button           = %BtnClear
@onready var lbl_status: Label           = %LblStatus
@onready var save_dialog: FileDialog     = %SaveFileDialog
@onready var load_dialog: FileDialog     = %LoadFileDialog

## Recurso activo en el editor
var current_resource: DialogGraphResource = null

## Diccionario de graph_nodes instanciados { id -> GraphNode }
var graph_nodes: Dictionary = {}


func _ready() -> void:
	current_resource = DialogGraphResource.new()

	# Conectar señales del GraphEdit
	graph_edit.connection_request.connect(_on_connection_request)
	graph_edit.disconnection_request.connect(_on_disconnection_request)
	graph_edit.delete_nodes_request.connect(_on_delete_nodes_request)

	# Botones de toolbar
	btn_add_dialog.pressed.connect(func(): _add_node(DialogNodeData.NodeType.DIALOG))
	btn_add_image.pressed.connect(func():  _add_node(DialogNodeData.NodeType.IMAGE))
	btn_save.pressed.connect(_on_save_pressed)
	btn_load.pressed.connect(_on_load_pressed)
	btn_clear.pressed.connect(_clear_graph)

	save_dialog.file_selected.connect(_save_resource)
	load_dialog.file_selected.connect(_load_resource)

	_set_status("Listo. Agrega nodos para comenzar.")


# ──── Creación de nodos ──────────────────────────────────────────────────────

func _add_node(type: DialogNodeData.NodeType) -> void:
	var data := DialogNodeData.new()
	data.setup(type)
	current_resource.add_node(data)
	_spawn_graph_node(data)
	_set_status("Nodo '%s' agregado." % data.id)


func _spawn_graph_node(data: DialogNodeData) -> Control:
	var scene = GRAPH_NODE_DIALOG_SCENE if data.node_type == DialogNodeData.NodeType.DIALOG \
			  else GRAPH_NODE_IMAGE_SCENE
	var gnode: GraphNode = scene.instantiate()
	graph_edit.add_child(gnode)
	gnode.position_offset = data.graph_position if data.graph_position != Vector2.ZERO \
						  else _get_centered_position()
	gnode.name = data.id
	gnode.setup(data)
	gnode.data_changed.connect(func(): _on_node_data_changed(data))
	gnode.position_offset_changed.connect(func(): data.graph_position = gnode.position_offset)
	graph_nodes[data.id] = gnode
	return gnode


func _get_centered_position() -> Vector2:
	var center := graph_edit.size / 2.0
	return center + Vector2(randf_range(-80, 80), randf_range(-40, 40))


# ──── Señales del GraphEdit ──────────────────────────────────────────────────

func _on_connection_request(from_node: StringName, from_port: int,
							to_node: StringName, to_port: int) -> void:
	graph_edit.connect_node(from_node, from_port, to_node, to_port)
	current_resource.add_connection(from_node, from_port, to_node, to_port)


func _on_disconnection_request(from_node: StringName, from_port: int,
							   to_node: StringName, to_port: int) -> void:
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


func _on_node_data_changed(_data: DialogNodeData) -> void:
	pass  # Los datos se actualizan directamente en el objeto, no se necesita nada extra


# ──── Guardar / Cargar ───────────────────────────────────────────────────────

func _on_save_pressed() -> void:
	save_dialog.popup_centered(Vector2i(800, 500))


func _on_load_pressed() -> void:
	load_dialog.popup_centered(Vector2i(800, 500))


func _save_resource(path: String) -> void:
	var err := ResourceSaver.save(current_resource, path)
	if err == OK:
		_set_status("Guardado en: %s" % path)
	else:
		_set_status("ERROR al guardar: código %d" % err)


func _load_resource(path: String) -> void:
	var res = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)
	if not res is DialogGraphResource:
		_set_status("ERROR: El archivo no es un DialogGraphResource.")
		return
	_clear_graph()
	current_resource = res
	# Reconstruir nodos
	for data in current_resource.nodes:
		_spawn_graph_node(data)
	# Reconstruir conexiones
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


# ──── UI helpers ─────────────────────────────────────────────────────────────

func _set_status(msg: String) -> void:
	if lbl_status:
		lbl_status.text = "● " + msg
