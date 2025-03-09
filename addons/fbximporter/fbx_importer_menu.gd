@tool
extends ConfirmationDialog

@onready var preview_scene: Node3D = %PreviewScene
@onready var preview_viewport: SubViewport = %PreviewViewport

@onready var import_settings_inspector: InspectorContainer = $Control/HBoxContainer/TabContainer/ImportSettingsInspector

@onready var import_settings: ImportSettings

var material_retriever: MaterialRetriever

var current_fbx_path: String = ""

func _ready() -> void:
	hide()
	import_settings = import_settings_inspector.object as ImportSettings
	material_retriever = MaterialRetriever.new(import_settings)


func open(fbx_path: String) -> void:
	if not FileAccess.file_exists(fbx_path):
		push_error("FBX file don't exist")
		return
	current_fbx_path = fbx_path
	preview(fbx_path)
	
	popup_centered_ratio()

func preview(fbx_path: String) -> void:
	var scene: Node3D = material_retriever.retrieve_for(fbx_path)
	preview_scene.preview_scene(scene)


func _on_confirmed() -> void:
	if current_fbx_path.is_empty():
		return
	var scene_path = current_fbx_path.replace(current_fbx_path.get_extension(), "tscn")
	preview_scene.save(scene_path)
