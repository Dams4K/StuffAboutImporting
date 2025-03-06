@tool
extends VBoxContainer

const STATIC_MESH: StringName = "sm_"

var inspector := EditorInspector.new()
var settings := ImporterSettings.new()

func _ready() -> void:
	inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inspector.edit(settings)
	
	settings.notify_property_list_changed()
	
	add_child(inspector)
	move_child(inspector, 0)


func _on_import_button_pressed() -> void:
	import()


func import():
	var unreal_models = settings.get_unreal_models()
	for path: String in unreal_models:
		import_model(path)

func import_model(model_path: String):
	var model_name: String = model_path.get_file()
	var scene: PackedScene = load(model_path)
	var node: Node3D = scene.instantiate()
	var mesh_instances: Array[MeshInstance3D] = []
	
	var textures: Array[String] = settings.get_textures()
	
	for child: Node in node.get_children():
		if not (child is MeshInstance3D):
			continue
		if not child.name.begins_with(STATIC_MESH):
			continue
		var mesh_inst = child as MeshInstance3D
		var mesh: Mesh = mesh_inst.mesh
		var mesh_name: String = mesh_inst.name.replace(STATIC_MESH, "")
		
		
		for surf_idx in range(mesh.get_surface_count()):
			var mat: Material = mesh.surface_get_material(surf_idx)
			if not (mat is StandardMaterial3D):
				print("%s mat is not StandardMaterial3D: %s with %s" % [surf_idx, mat, mesh_name])
				continue
			var standar_mat = mat as StandardMaterial3D
			var mat_name: String = standar_mat.resource_name
			standar_mat.vertex_color_use_as_albedo = false
			
			var albedo_texture: Texture2D = load_texture(textures, mat_name, settings.get_albedo_regex)
			var mettalic_texture: Texture2D = load_texture(textures, mat_name, settings.get_mettalic_regex)
			var roughness_texture: Texture2D = load_texture(textures, mat_name, settings.get_roughness_regex)
			var normal_texture: Texture2D = load_texture(textures, mat_name, settings.get_normal_regex)
			
			standar_mat.albedo_color = Color.WHITE
			standar_mat.albedo_texture = albedo_texture
			
			standar_mat.metallic_texture = mettalic_texture
			standar_mat.metallic_texture_channel = settings.mettalic_channel
			
			standar_mat.roughness_texture = roughness_texture
			standar_mat.roughness_texture_channel = settings.roughness_channel
			
			standar_mat.normal_enabled = normal_texture != null
			standar_mat.normal_texture = normal_texture
			
			mesh.surface_set_material(surf_idx, standar_mat)
		
		mesh_instances.append(mesh_inst)
	
	save_model(mesh_instances, model_name)

func save_model(mesh_instances: Array[MeshInstance3D], model_name: String):
	model_name = model_name.replace("." + model_name.get_extension(), "")
	var model_file = "%s.tscn" % model_name
	
	var node = combine_as_node(mesh_instances)
	node.name = model_name
	
	var scene = PackedScene.new()
	scene.pack(node)
	var path = settings.out_dir.path_join(model_file)
	ResourceSaver.save(scene, path)
	print("Saved to: %s" % path)

func combine_as_node(mesh_instances: Array[MeshInstance3D]) -> Node3D:
	var node := Node3D.new()
	if mesh_instances.size() == 0:
		printerr("No meshs")
	else:
		for _mesh_instance: MeshInstance3D in mesh_instances:
			var mesh_instance := _mesh_instance.duplicate()
			node.add_child(mesh_instance)
			mesh_instance.owner = node
	
	return node

func load_texture(textures: Array[String], mat_name: String, get_regex: Callable) -> Texture2D:
	var path = search_file(textures, get_regex.call(mat_name))
	
	if path == "" or not FileAccess.file_exists(path):
		return null
	return load(path)

func search_file(files: Array[String], regex: RegEx):
	for path: String in files:
		if regex.search(path) != null:
			return path
	return ""
