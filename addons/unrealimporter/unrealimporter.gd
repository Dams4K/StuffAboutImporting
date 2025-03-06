@tool
extends EditorPlugin

const IMPORTER_DOCK = preload("res://addons/unrealimporter/importer.tscn")

var dock

func _enter_tree() -> void:
	dock = IMPORTER_DOCK.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, dock)


func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()
