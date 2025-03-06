@tool
extends Node
class_name UnrealImport

const STATIC_MESH: StringName = "sm_"

@export_tool_button("Import") var import_action = import_files

@export_category("In/Out")
@export_dir var entry_folder = ""
@export var extension = "fbx"
@export_dir var out_folder = ""

@export_category("Textures")
@export_dir var textures_folder = ""
@export var base_color_file := "BaseColor"
@export var metallic_roughness_file := "MetallicRoughness"
@export var normal_file := "Normal"

@export var texture_extensions: Array[String] = []

func correct_extension(path: String) -> bool:
	if extension == null:
		printerr("extension variable is null")
		return false
	var ext: String = path.get_extension()
	return ext.to_lower() == extension.to_lower()

func get_dir_content(path: String, recursive := true) -> Array[String]:
	var dir = DirAccess.open(path)
	var files: Array[String] = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var file_path = path.path_join(file_name)
			if dir.current_is_dir():
				files.append_array(get_dir_content(file_path))
			else:
				files.append(file_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	return files

func import_files() -> void:
	if entry_folder == "":
		printerr("Entry folder is empty")
		return
	
	var files = get_dir_content(entry_folder)
	var unreal_files = files.filter(correct_extension)
	
	for path in unreal_files:
		import(path)


func import(scene_path) -> void:
	var scene: PackedScene = load(scene_path)
	var scene_folder: String = scene_path.get_base_dir()
	
	var node: Node3D = scene.instantiate()
	for child: Node in node.get_children():
		if not (child is MeshInstance3D):
			continue
		if not child.name.begins_with(STATIC_MESH):
			continue
		var mesh_inst = child as MeshInstance3D
		var mesh: Mesh = mesh_inst.mesh
		var mesh_name = mesh_inst.name.replace(STATIC_MESH, "")
		
		var surface_count: int = mesh.get_surface_count()
		for surf_idx in range(surface_count):
			var mat: Material = mesh.surface_get_material(surf_idx)
			if not (mat is StandardMaterial3D):
				print("%s mat is not StandardMaterial3D: %s with %s" % [surf_idx, mat, mesh_name])
				continue
			var standar_mat = mat as StandardMaterial3D
			var mat_name: String = standar_mat.resource_name
			
			standar_mat.vertex_color_use_as_albedo = false
			
			var normal_path: String = get_file(textures_folder, mat_name, normal_file)
			if normal_path != "":
				standar_mat.normal_enabled = true
				standar_mat.normal_texture = load(normal_path)
			var met_rou_path: String = get_file(textures_folder, mat_name, metallic_roughness_file)
			if met_rou_path != "":
				standar_mat.metallic_texture = load(met_rou_path)
				standar_mat.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GRAYSCALE
				
				standar_mat.roughness_texture = load(met_rou_path)
				standar_mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
			var base_col_path: String = get_file(textures_folder, mat_name, base_color_file)
			if base_color_file != "":
				standar_mat.albedo_color = Color.WHITE
				standar_mat.albedo_texture = load(base_col_path)
			
			mesh.surface_set_material(surf_idx, standar_mat)
		
		var out_path = out_folder.path_join("%s.res" % mesh_name)
		if ResourceSaver.save(mesh, out_path) == OK:
			print("%s exported to %s" % [mesh_name, out_path])

func get_file(folder: String, mid: String, end: String) -> String:
	for ext in texture_extensions:
		var file_name = "%s_%s.%s" % [mid, end, ext]
		var path = folder.path_join(file_name)
		if FileAccess.file_exists(path):
			return path
	var path = "%s_%s.X" % [mid, end]
	printerr("No file %s" % path)
	return ""
