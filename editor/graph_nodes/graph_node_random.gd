@tool
class_name GraphNodeRandom
extends GraphNode

## Nodo visual RANDOM dentro del GraphEdit.
## Permite múltiples puertos de salida; en runtime elige uno al azar.
## Cada clic en "+ Rama" agrega un puerto de salida adicional.

signal data_changed

@onready var lbl_info: Label      = %LblInfo
@onready var btn_add: Button      = %BtnAddBranch
@onready var lbl_count: Label     = %LblCount

var data: DialogNodeData = null

## Número de ramas (= puertos de salida) actuales
var _branch_count: int = 1


func setup(d: DialogNodeData) -> void:
	data = d
	title = "🎲 Aleatorio"

	# Guardar el conteo de ramas a partir de las conexiones existentes (si se carga)
	# Se actualiza desde el editor cuando se restaura el grafo
	_branch_count = max(1, d.get_meta("branch_count", 1))
	_rebuild_ports()
	_connect_signals()


func _connect_signals() -> void:
	btn_add.pressed.connect(_add_branch)


func _add_branch() -> void:
	_branch_count += 1
	data.set_meta("branch_count", _branch_count)
	_rebuild_ports()
	data_changed.emit()


## Reconstruye los slots del GraphNode según _branch_count.
## Puerto de entrada siempre en slot 0 (izquierda).
## Puertos de salida en slots 0..N-1 (derecha), uno por rama.
func _rebuild_ports() -> void:
	# Limpiar slots previos (Godot 4: clear_all_slots no existe; hay que hacerlo manual)
	for i in get_child_count():
		set_slot_enabled_left(i, false)
		set_slot_enabled_right(i, false)

	# Slot 0: entrada única
	set_slot_enabled_left(0, true)
	set_slot_color_left(0, Color.CYAN)

	# Slots 0..N-1: una salida por rama
	# El GraphNode necesita un Control hijo por cada slot que use
	# Aquí usamos los hijos existentes del VBoxContainer como filas
	_sync_branch_labels()

	lbl_count.text = "Ramas: %d" % _branch_count


## Sincroniza las etiquetas de rama en el VBoxContainer y sus slots.
func _sync_branch_labels() -> void:
	var vbox: VBoxContainer = %VBoxBranches
	# Eliminar etiquetas anteriores
	for child in vbox.get_children():
		child.queue_free()

	for i in _branch_count:
		var row := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = "Rama %d" % (i + 1)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)

		# Botón eliminar (solo si hay más de 1 rama)
		if _branch_count > 1:
			var btn_del := Button.new()
			btn_del.text = "✕"
			var idx := i
			btn_del.pressed.connect(func():
				_branch_count -= 1
				data.set_meta("branch_count", _branch_count)
				_rebuild_ports()
				data_changed.emit()
			)
			row.add_child(btn_del)

		vbox.add_child(row)
		# Habilitar slot de salida para esta fila
		# Los índices de slot corresponden a los hijos del GraphNode
		# VBoxBranches es hijo 1 (índice 0-based del GraphNode); sus filas son sub-hijos
		# En GD4, los slots se mapean a los hijos directos del GraphNode

	# Re-asignar slots a los hijos directos del GraphNode
	# Hijo 0 = LblInfo (entrada)
	# Hijo 1 = VBoxBranches (ramas de salida)
	# Godot asigna un slot por hijo directo; necesitamos un hijo por rama
	# Solución: usar el VBoxContainer como contenedor visual y manejar slots
	# sobre el propio GraphNode con índices 0..branch_count

	# Resetear todos los slots
	for s in get_child_count():
		set_slot_enabled_left(s, false)
		set_slot_enabled_right(s, false)

	# Slot 0 (LblInfo): entrada
	set_slot_enabled_left(0, true)
	set_slot_color_left(0, Color.CYAN)

	# Slots 1..N: salidas por rama (si el GraphNode tiene suficientes hijos)
	# Añadimos hijos Label ocultos para que Godot genere los slots necesarios
	_ensure_slot_children(_branch_count)

	for i in _branch_count:
		set_slot_enabled_right(i + 1, true)
		set_slot_color_right(i + 1, Color(1.0, 0.6, 0.1))


## Asegura que el GraphNode tenga suficientes hijos directos para los slots.
func _ensure_slot_children(count: int) -> void:
	# Los primeros 2 hijos son LblInfo y VBoxBranches (fijos)
	var fixed_children := 2
	var needed := fixed_children + count
	var current := get_child_count()
	# Agregar hijos-slot transparentes si faltan
	while get_child_count() < needed:
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0, 16)
		add_child(spacer)
	# Ocultar sobrantes
	for i in range(fixed_children, get_child_count()):
		get_child(i).visible = (i - fixed_children) < count
