@tool
extends ConfirmationDialog

@onready var preview_scene: Node3D = %PreviewScene
@onready var preview_viewport: SubViewport = %PreviewViewport

@onready var import_settings_inspector: InspectorContainer = $Control/HBoxContainer/TabContainer/ImportSettingsInspector

@onready var import_settings: ImportSettings

var material_retriever: MaterialRetriever

func _ready() -> void:
	hide()
	import_settings = import_settings_inspector.object as ImportSettings
	material_retriever = MaterialRetriever.new(import_settings)


func open(fbx_path: String) -> void:
	if not FileAccess.file_exists(fbx_path):
		push_error("FBX file don't exist")
		return
	preview(fbx_path)
	
	popup_centered_ratio()

func preview(fbx_path: String) -> void:
	var scene: Node3D = material_retriever.retrieve_for(fbx_path)
	
	#var mesh_instances: Array = scene.find_children("*", "MeshInstance3D")
	#if mesh_instances.size() == 1:
		#if apply_by_fbx_name(fbx_path, mesh_instances[0].mesh):
			#print("OK")
			#pass
	
	preview_scene.preview_scene(scene)

func apply_by_fbx_name(fbx_path: String, mesh: Mesh) -> bool:
	var fbx_dir = fbx_path.get_base_dir()
	var images: PackedStringArray = import_settings.get_dir_content(fbx_dir, false, import_settings.is_file_image)
	var albedo_texture: Texture2D = import_settings.get_texture_with_fbx_name(fbx_path, images, import_settings.TextureType.ALBEDO)
	print(albedo_texture)
	if albedo_texture != null:
		var mat: StandardMaterial3D = mesh.surface_get_material(0)
		mat.albedo_texture = albedo_texture
		mesh.surface_set_material(0, mat)
		return true
	
	return false

#
#func _unhandled_input(event: InputEvent) -> void:
	#preview_viewport.push_input(event)


func _on_confirmed() -> void:
	pass # Replace with function body.
