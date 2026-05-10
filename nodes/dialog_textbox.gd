class_name DialogTextbox
extends Control

## UI del textbox en tiempo de ejecución.
## Maneja la animación de escritura (typewriter), iconos, texto enriquecido.
##
## Estructura esperada de la escena (.tscn):
##   DialogTextbox (Control)
##   └── PanelContainer (root visual)
##       └── HBoxContainer
##           ├── TextureRect (IconLeft)
##           ├── VBoxContainer
##           │   ├── Label (LabelCharName)
##           │   └── RichTextLabel (RichText)
##           └── TextureRect (IconRight)
##   └── AnimationPlayer
##   └── Label (AdvanceIndicator) ▼

signal hidden_tb

@onready var icon_left: TextureRect       = %IconLeft
@onready var icon_right: TextureRect      = %IconRight
@onready var label_char_name: Label       = %LabelCharName
@onready var rich_text: RichTextLabel     = %RichText
@onready var advance_indicator: Label     = %AdvanceIndicator
@onready var anim_player: AnimationPlayer = %AnimationPlayer

## Velocidad de caracteres por segundo en la animación typewriter
@export var chars_per_second: float = 40.0

var _full_text: String = ""
var _is_skipped: bool  = false


func _ready() -> void:
	rich_text.bbcode_enabled = true
	advance_indicator.hide()
	show_textbox()


# ──── API pública ────────────────────────────────────────────────────────────

func show_textbox() -> void:
	show()
	if anim_player.has_animation("show"):
		anim_player.play("show")


func hide_textbox() -> void:
	if anim_player.has_animation("hide"):
		anim_player.play("hide")
		await anim_player.animation_finished
	hide()
	hidden_tb.emit()


## Establece el nombre del personaje
func set_character(char_name: String) -> void:
	label_char_name.text = char_name
	label_char_name.visible = not char_name.is_empty()


## Configura los iconos según la posición indicada
func set_icon(left_path: String, right_path: String,
			  position: DialogNodeData.IconPosition) -> void:
	# Ocultar todo primero
	icon_left.hide()
	icon_right.hide()

	match position:
		DialogNodeData.IconPosition.LEFT:
			_set_texture(icon_left, left_path)
			icon_left.show()
		DialogNodeData.IconPosition.RIGHT:
			_set_texture(icon_right, right_path if not right_path.is_empty() else left_path)
			icon_right.show()
		DialogNodeData.IconPosition.DUO:
			_set_texture(icon_left,  left_path)
			_set_texture(icon_right, right_path)
			icon_left.show()
			icon_right.show()


func _set_texture(rect: TextureRect, path: String) -> void:
	if path.is_empty() or not ResourceLoader.exists(path):
		rect.texture = null
		return
	rect.texture = load(path)


## Anima la escritura del texto enriquecido. Awaitable.
func type_text(text: String) -> void:
	_full_text  = text
	_is_skipped = false
	rich_text.text = ""
	rich_text.visible_ratio = 0.0

	# Calcular número total de caracteres visibles (sin tags BBCode)
	var temp := RichTextLabel.new()
	temp.bbcode_enabled = true
	temp.text = text
	var total_chars := temp.get_total_character_count()
	temp.free()

	# Asignar el texto completo y animar visible_ratio
	rich_text.text = text

	var elapsed := 0.0
	var duration := total_chars / chars_per_second

	while elapsed < duration:
		if _is_skipped:
			break
		elapsed += get_process_delta_time()
		rich_text.visible_ratio = clamp(elapsed / duration, 0.0, 1.0)
		await get_tree().process_frame

	# Asegurar que todo esté visible al final
	rich_text.visible_ratio = 1.0


## Salta la animación de escritura mostrando todo el texto de golpe
func skip_typing() -> void:
	_is_skipped = true
	rich_text.visible_ratio = 1.0


## Muestra u oculta el indicador de "presiona para avanzar"
func show_advance_indicator(visible_val: bool) -> void:
	advance_indicator.visible = visible_val


## Aplica la configuración de animación definida por un nodo ANIMATION.
## Llama las animaciones del AnimationPlayer en el orden indicado.
func apply_animation_config(anim_names: Array[String], order: int) -> void:
	if anim_names.is_empty():
		return

	match order:
		DialogNodeData.AnimationOrder.SEQUENTIAL:
			# Reproduce una tras otra
			for anim_name in anim_names:
				if anim_player.has_animation(anim_name):
					anim_player.play(anim_name)
					await anim_player.animation_finished

		DialogNodeData.AnimationOrder.SIMULTANEOUS:
			# Lanza todas a la vez y espera a la más larga
			var longest: float = 0.0
			for anim_name in anim_names:
				if anim_player.has_animation(anim_name):
					var length := anim_player.get_animation(anim_name).length
					if length > longest:
						longest = length
					anim_player.play(anim_name)
			if longest > 0.0:
				await get_tree().create_timer(longest).timeout
				
func apply_tween_config(data: DialogNodeData) -> void:
	var tween := create_tween()

	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	if data.tween_delay > 0.0:
		tween.tween_interval(data.tween_delay)

	match data.tween_type:

		DialogNodeData.TweenType.NONE:
			return

		DialogNodeData.TweenType.FADE:
			modulate.a = 0.0

			tween.tween_property(
				self,
				"modulate:a",
				1.0,
				data.tween_duration
			)

		DialogNodeData.TweenType.SLIDE_LEFT:
			var target := position

			position.x -= data.tween_offset.x

			tween.tween_property(
				self,
				"position",
				target,
				data.tween_duration
			)

		DialogNodeData.TweenType.SLIDE_RIGHT:
			var target := position

			position.x += data.tween_offset.x

			tween.tween_property(
				self,
				"position",
				target,
				data.tween_duration
			)

		DialogNodeData.TweenType.SLIDE_UP:
			var target := position

			position.y += data.tween_offset.y

			tween.tween_property(
				self,
				"position",
				target,
				data.tween_duration
			)

		DialogNodeData.TweenType.SLIDE_DOWN:
			var target := position

			position.y -= data.tween_offset.y

			tween.tween_property(
				self,
				"position",
				target,
				data.tween_duration
			)

		DialogNodeData.TweenType.SCALE:
			var target := scale

			scale = data.tween_start_scale

			tween.tween_property(
				self,
				"scale",
				target,
				data.tween_duration
			)

		DialogNodeData.TweenType.POP:
			scale = Vector2(0.7, 0.7)

			tween.tween_property(
				self,
				"scale",
				Vector2(1.08, 1.08),
				data.tween_duration * 0.6
			)

			tween.tween_property(
				self,
				"scale",
				Vector2.ONE,
				data.tween_duration * 0.4
			)

		DialogNodeData.TweenType.BOUNCE:
			scale = Vector2(0.6, 0.6)

			tween.tween_property(
				self,
				"scale",
				Vector2.ONE,
				data.tween_duration
			).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
