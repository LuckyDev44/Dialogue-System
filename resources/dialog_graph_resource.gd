@tool
class_name DialogGraphResource
extends Resource

## Recurso principal que almacena todos los datos del grafo de diálogos.
## Se serializa como un .tres y lo lee DialogNode en tiempo de ejecución.

# Lista de nodos del diálogo
@export var nodes: Array[DialogNodeData] = []

# Lista de conexiones entre nodos
# Cada conexión: { from_node: String, from_port: int, to_node: String, to_port: int }
@export var connections: Array[Dictionary] = []

# ID del nodo inicial (primer START encontrado, o primer nodo agregado)
@export var start_node_id: String = ""


## Agrega un nodo al grafo
func add_node(data: DialogNodeData) -> void:
	nodes.append(data)
	# El nodo START o el primero agregado se convierte en punto de entrada
	if data.node_type == DialogNodeData.NodeType.START or nodes.size() == 1:
		start_node_id = data.id


## Elimina un nodo por su ID
func remove_node(id: String) -> void:
	for i in nodes.size():
		if nodes[i].id == id:
			nodes.remove_at(i)
			break
	connections = connections.filter(func(c): return c.from_node != id and c.to_node != id)


## Obtiene un nodo por ID
func get_node_by_id(id: String) -> DialogNodeData:
	for n in nodes:
		if n.id == id:
			return n
	return null


## Obtiene el ID del siguiente nodo desde un puerto específico de salida.
## Puerto 0 = salida principal / rama TRUE / rama aleatoria 0
## Puerto 1 = rama FALSE (CONDITION)
## Puertos 0..N = ramas aleatorias (RANDOM)
func get_next_node_id(from_id: String, from_port: int = 0) -> String:
	for c in connections:
		if c.from_node == from_id and c.from_port == from_port:
			return c.to_node
	return ""


## Devuelve todos los IDs de nodos conectados a las salidas de un nodo RANDOM.
## El orden del array equivale al índice del puerto de salida.
func get_random_branches(from_id: String) -> Array[String]:
	var branches: Array[String] = []
	# Recopilar puertos de salida conectados
	var port_map: Dictionary = {}
	for c in connections:
		if c.from_node == from_id:
			port_map[c.from_port] = c.to_node
	# Ordenar por índice de puerto
	var sorted_ports := port_map.keys()
	sorted_ports.sort()
	for p in sorted_ports:
		branches.append(port_map[p])
	return branches


## Agrega una conexion (reemplaza si ya existe el mismo from_node+from_port)
func add_connection(from_node: String, from_port: int, to_node: String, to_port: int) -> void:
	# Para RANDOM permitimos múltiples salidas (un puerto distinto por rama)
	var owner_data := get_node_by_id(from_node)
	var is_random := owner_data != null and owner_data.node_type == DialogNodeData.NodeType.RANDOM
	if not is_random:
		# Para todos los demás nodos: un único destino por puerto
		for c in connections:
			if c.from_node == from_node and c.from_port == from_port:
				connections.erase(c)
				break
	connections.append({
		"from_node": from_node,
		"from_port": from_port,
		"to_node": to_node,
		"to_port": to_port
	})


## Elimina una conexion
func remove_connection(from_node: String, from_port: int, to_node: String, to_port: int) -> void:
	for c in connections:
		if c.from_node == from_node and c.from_port == from_port \
		and c.to_node == to_node and c.to_port == to_port:
			connections.erase(c)
			return
