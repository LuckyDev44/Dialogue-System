@tool
class_name DialogNodeData
extends Resource

# ──── Enums ─────────────────────────────────────────────────────────────────

## Todos los tipos de nodo disponibles en el grafo
enum NodeType {
	DIALOG,     ## Nodo de texto/diálogo
	IMAGE,      ## Nodo de inyección de imagen
	# v1.1 ────────────────────
	RANDOM,     ## Selector aleatorio de ramas
	CONDITION,  ## Evaluador de condición lógica
	START,      ## Punto de entrada del flujo
	END,        ## Punto de cierre del flujo
	ANIMATION,  ## Configurador de animación de entrada del textbox
}

## Tipo de flujo del diálogo
enum FlowType {
	SKIPPABLE,  ## El jugador puede saltar la animación y avanzar manualmente
	AUTO,       ## Avanza solo por tiempo o señal externa (no skippable)
}

## Posición del icono del personaje
enum IconPosition {
	LEFT,   ## Icono solo a la izquierda
	RIGHT,  ## Icono solo a la derecha
	DUO,    ## Icono en ambos lados (modo duo)
}

## Operadores de comparación para el nodo CONDITION
enum ConditionOperator {
	EQUALS,         ## variable == valor
	NOT_EQUALS,     ## variable != valor
	GREATER,        ## variable > valor
	LESS,           ## variable < valor
	GREATER_EQUAL,  ## variable >= valor
	LESS_EQUAL,     ## variable <= valor
}

## Orden de reproducción de animaciones (nodo ANIMATION)
enum AnimationOrder {
	SEQUENTIAL,    ## Una tras otra
	SIMULTANEOUS,  ## Todas a la vez
}

## Tipos de tween para el textbox
enum TweenType {
	NONE,
	FADE,
	SLIDE_LEFT,
	SLIDE_RIGHT,
	SLIDE_UP,
	SLIDE_DOWN,
	SCALE,
	POP,
	BOUNCE,
}

enum TweenTransition {
	LINEAR,
	SINE,
	QUAD,
	CUBIC,
	QUART,
	QUINT,
	EXPO,
	BACK,
	BOUNCE,
	ELASTIC,
}

enum TweenEase {
	IN,
	OUT,
	IN_OUT,
	OUT_IN,
}

enum TweenMode {
	INTRO,
	OUTRO,
	BOTH,
}

# ──── Campos comunes ─────────────────────────────────────────────────────────

## Identificador único del nodo
@export var id: String = ""

## Tipo de nodo
@export var node_type: NodeType = NodeType.DIALOG

## Posición en el GraphEdit (para el editor)
@export var graph_position: Vector2 = Vector2.ZERO

# ──── Campos del nodo DIALOG ─────────────────────────────────────────────────

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

# ──── Campos del nodo IMAGE ──────────────────────────────────────────────────

## Ruta de la imagen a inyectar
@export var image_path: String = ""

## Tag BBCode generado automáticamente
var inject_tag: String:
	get:
		if image_path.is_empty():
			return ""
		return "[img]%s[/img]" % image_path

# ──── Campos del nodo CONDITION ──────────────────────────────────────────────

## Nombre de la variable a evaluar (ej: "player_health")
@export var condition_variable: String = ""

## Operador de comparación
@export var condition_operator: ConditionOperator = ConditionOperator.EQUALS

## Valor contra el que comparar (como string; se intenta parsear a número)
@export var condition_value: String = ""

# ──── Campos del nodo ANIMATION ──────────────────────────────────────────────

@export var tween_type: TweenType = TweenType.FADE

@export var tween_transition: TweenTransition = TweenTransition.SINE
@export var tween_ease: TweenEase = TweenEase.OUT
@export var tween_mode: TweenMode = TweenMode.INTRO

@export var tween_duration: float = 0.4
@export var tween_delay: float = 0.0

@export var tween_offset: Vector2 = Vector2(300, 120)

@export var tween_start_scale: Vector2 = Vector2(0.8, 0.8)

# ──── Campos del nodo START ──────────────────────────────────────────────────

## Etiqueta opcional para identificar este punto de entrada
@export var start_label: String = "Inicio"

# ──── Campos del nodo END ────────────────────────────────────────────────────

## Etiqueta opcional para identificar el cierre
@export var end_label: String = "Fin"

# ──── Setup ──────────────────────────────────────────────────────────────────

## Inicializa el nodo con un ID único basado en tipo y timestamp
func setup(type: NodeType) -> void:
	node_type = type
	id = "%s_%d" % [NodeType.keys()[type], Time.get_ticks_msec()]
