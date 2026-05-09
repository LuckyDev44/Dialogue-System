@tool
class_name DialogNodeData
extends Resource

## Tipos de nodo disponibles en el grafo
enum NodeType {
	DIALOG,  ## Nodo de texto/diálogo
	IMAGE,   ## Nodo de inyección de imagen
}

## Tipo de flujo del diálogo
enum FlowType {
	SKIPPABLE,    ## El jugador puede saltar la animación y avanzar manualmente
	AUTO,         ## Avanza solo por tiempo o señal externa (no skippable)
}

## Posición del icono del personaje
enum IconPosition {
	LEFT,   ## Icono solo a la izquierda
	RIGHT,  ## Icono solo a la derecha
	DUO,    ## Icono en ambos lados (modo duo)
}

# Identificador único del nodo
@export var id: String = ""

# Tipo de nodo
@export var node_type: NodeType = NodeType.DIALOG

# Posición en el GraphEdit (para el editor)
@export var graph_position: Vector2 = Vector2.ZERO

# ──── Campos del nodo DIALOG ────────────────────────────────────────────────

## Nombre del personaje que habla
@export var character_name: String = ""

## Texto del diálogo (soporta BBCode enriquecido con tags [img])
@export var dialog_text: String = ""

## Tipo de flujo
@export var flow_type: FlowType = FlowType.SKIPPABLE

## Delay en segundos (solo para FlowType.AUTO)
@export var auto_delay: float = 3.0

## Posicion del icono del personaje
@export var icon_position: IconPosition = IconPosition.LEFT

## Ruta del icono izquierdo (o único)
@export var icon_left_path: String = ""

## Ruta del icono derecho (solo en modo DUO o RIGHT)
@export var icon_right_path: String = ""

## Lista de pistas de audio simultáneas (rutas a AudioStream)
@export var audio_tracks: Array[String] = []

# ──── Campos del nodo IMAGE ─────────────────────────────────────────────────

## Ruta de la imagen a inyectar
@export var image_path: String = ""

## Tag que se inserta en el texto del nodo anterior: [img]ruta[/img]
var inject_tag: String:
	get:
		if image_path.is_empty():
			return ""
		return "[img]%s[/img]" % image_path


## Inicializa el nodo con un ID único
func setup(type: NodeType) -> void:
	node_type = type
	id = "%s_%d" % [NodeType.keys()[type], Time.get_ticks_msec()]
