@tool
class_name DialogGraphResource
extends Resource

## Recurso principal que almacena todos los datos del grafo de diálogos.
## Se serializa como un .tres y lo lee DialogNode en tiempo de ejecución.

# Lista de nodos del diálogo
@export var nodes: Array[DialogNodeData] = []

# Lista de conexiones entre nodos
# Cada conexión es un diccionario: { from_node, from_port, to_node, to_port }
@export var connections: Array[Dictionary] = []

# ID del nodo inicial
@export var start_node_id: String = ""


## Agrega un nodo al grafo
func add_node(data: DialogNodeData) -> void:
	nodes.append(data)
	if nodes.size() == 1:
		start_node_id = data.id


## Elimina un nodo por su ID
func remove_node(id: String) -> void:
	for i in nodes.size():
		if nodes[i].id == id:
			nodes.remove_at(i)
			break
	# Limpiar conexiones huerfanas
	connections = connections.filter(func(c): return c.from_node != id and c.to_node != id)


## Obtiene un nodo por ID
func get_node_by_id(id: String) -> DialogNodeData:
	for n in nodes:
		if n.id == id:
			return n
	return null


## Obtiene el ID del nodo siguiente desde un nodo dado
func get_next_node_id(from_id: String) -> String:
	for c in connections:
		if c.from_node == from_id and c.from_port == 0:
			return c.to_node
	return ""


## Agrega una conexion
func add_connection(from_node: String, from_port: int, to_node: String, to_port: int) -> void:
	# Evitar duplicados
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
