@tool
class_name GraphNodeImage
extends GraphNode

## Nodo de inyección de imagen dentro del GraphEdit.
## Genera el tag [img]ruta[/img] para insertar en el nodo de diálogo previo.

signal data_changed

@onready var field_path: LineEdit    = %FieldImagePath
@onready var lbl_preview_tag: Label  = %LblPreviewTag
@onready var preview_rect: TextureRect = %PreviewRect

var data: DialogNodeData = null


func setup(d: DialogNodeData) -> void:
	data = d
	title = "🖼 Imagen (Inyección)"
	_refresh_ui()
	_connect_signals()


func _refresh_ui() -> void:
	if not data:
		return
	field_path.text = data.image_path
	_update_tag_preview()
	_load_preview()


func _connect_signals() -> void:
	field_path.text_changed.connect(func(v):
		data.image_path = v
		_update_tag_preview()
		_load_preview()
		data_changed.emit()
	)


func _update_tag_preview() -> void:
	lbl_preview_tag.text = data.inject_tag if not data.image_path.is_empty() \
						 else "[img]…[/img]"


func _load_preview() -> void:
	if data.image_path.is_empty() or not ResourceLoader.exists(data.image_path):
		preview_rect.texture = null
		return
	preview_rect.texture = load(data.image_path)
