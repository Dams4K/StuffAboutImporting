@tool
extends Object
class_name ImportSettings

enum TextureType {
	ALBEDO,
	METALLIC,
	ROUGHNESS,
	NORMAL,
	AO
}

var config := ConfigFile.new()

@export_group("Model")
@export var remove_to_name: PackedStringArray = []

@export_group("Meshs")
@export var mesh_ignore_begin_with: String = ""

@export_group("Textures")
@export var search_same_folder := true
@export_dir var textures_folder = "res://"
@export var formats: PackedStringArray = [
	"png",
	"jpg",
	"jpeg"
] :
	set(v):
		for i in range(v.size()):
			v[i] = v[i].to_lower()
		formats = v
@export_subgroup("Albedo")
@export var albedo_name := "BaseColor"
@export var is_albedo_critical := true

@export_subgroup("Metallic")
@export var metallic_name := "Metalness"
@export var metallic_channel := BaseMaterial3D.TextureChannel.TEXTURE_CHANNEL_GRAYSCALE
@export var is_metallic_critical := true

@export_subgroup("Roughness")
@export var roughness_name := "Roughness"
@export var roughness_channel := BaseMaterial3D.TextureChannel.TEXTURE_CHANNEL_GREEN
@export var is_roughness_critical := true

@export_subgroup("Normal")
@export var normal_name := "Normal"
@export var is_normal_critical := true

@export_subgroup("AO")
@export var ao_name := "AO"
@export var is_ao_critical := false

func save() -> void:
	pass

func format_fbx_name(fbx_name: String) -> String:
	for s in remove_to_name:
		fbx_name = fbx_name.replace(s, "")
	return fbx_name

func get_albedo_texture(fbx_path: String) -> Texture2D:
	return get_texture(fbx_path, albedo_name)

func get_texture(fbx_path: String, texture_name: String) -> Texture2D:
	var texture_path: String = get_texture_path(fbx_path, texture_name)
	if texture_path.is_empty():
		return null
	return load(texture_path)

func get_texture_path(fbx_path: String, texture_name: String) -> String:
	if search_same_folder:
		var fbx_name: String = fbx_path.get_file()
		var fbx_dir: String = fbx_path.get_base_dir()
		var images: PackedStringArray = get_dir_content(fbx_dir, false, is_file_image)
		
		var texture_path: String = search_with_fbx_name(fbx_name, images, texture_name)
		if texture_path != "":
			return texture_path
	
	return ""

func get_texture_with_fbx_name(fbx_path: String, images: PackedStringArray, texture_type: TextureType) -> Texture2D:
	var texture_name: String = _get_texture_name(texture_type)
	if texture_name.is_empty():
		push_error("texture_name is empty")
		return null
	var texture_path: String = search_with_fbx_name(fbx_path, images, texture_name)
	print(texture_path)
	if texture_path.is_empty():
		return null
	return load(texture_path)

func _get_texture_name(texture_type: TextureType) -> String:
	match texture_type:
		TextureType.ALBEDO:
			return albedo_name
	
	return ""

func search_with_fbx_name(fbx_name: String, images: PackedStringArray, texture_name: String) -> String:
	var highest: String = ""
	var highest_score: float = 0.0
	
	var fbx_ext: String = fbx_name.get_extension()
	var fbx_name_only: String = fbx_name.replace(".%s" % fbx_ext, "")
	
	var search_for: String = "%s_%s.%s" % [fbx_name_only, texture_name, fbx_ext]
	print(search_for)
	for image: String in images:
		var score = image.similarity(search_for)
		if score > highest_score:
			highest_score = score
			highest = image
	
	if highest_score > 0.95:
		return highest
	printt(highest_score, highest)
	return ""

func is_file_image(path: String) -> bool:
	return path.get_extension().to_lower() in formats

func get_dir_content(path: String, recursive := false, filter := func(path): true) -> PackedStringArray:
	var dir = DirAccess.open(path)
	var files: PackedStringArray = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var file_path = path.path_join(file_name)
			if dir.current_is_dir() and recursive:
				files.append_array(get_dir_content(file_path))
			elif filter.call(file_path):
				files.append(file_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	return files
