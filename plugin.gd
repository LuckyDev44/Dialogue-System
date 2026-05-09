@tool
extends EditorPlugin

const DIALOG_EDITOR_SCENE = preload("res://addons/dialog_system/editor/dialog_graph_editor.tscn")

var editor_instance: Control


func _enter_tree() -> void:
	editor_instance = DIALOG_EDITOR_SCENE.instantiate()

	add_control_to_bottom_panel(editor_instance, "Dialog Editor")

	print("[DialogSystem] Plugin cargado correctamente.")


func _exit_tree() -> void:
	if editor_instance:
		remove_control_from_bottom_panel(editor_instance)
		editor_instance.queue_free()


func get_plugin_name() -> String:
	return "DialogSystem"
