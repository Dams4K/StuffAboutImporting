extends Object
class_name ImporterSettings

const SETTINGS_FILE = "res://unreal_importer.cfg"

const MODELS_SECTION = "Models"
const TEXTURES_SECTION = "Textures"

var config := ConfigFile.new()

@export_group("Models")
@export_dir var models_dir = "res://":
	set(v):
		models_dir = v
		save_config()
@export var models_extension: String = "fbx":
	set(v):
		models_extension = v
		save_config()
@export_dir var out_dir = "res://":
	set(v):
		out_dir = v
		save_config()

@export_group("Textures")
@export_dir var textures_dir = "res://":
	set(v):
		textures_dir = v
		save_config()
@export var albedo_regex = "*BaseColor*":
	set(v):
		albedo_regex = v
		save_config()
@export var mettalic_regex = "*MetallicRoughness*":
	set(v):
		mettalic_regex = v
		save_config()
@export var mettalic_channel := BaseMaterial3D.TextureChannel.TEXTURE_CHANNEL_GRAYSCALE:
	set(v):
		mettalic_channel = v
		save_config()
@export var roughness_regex = "*MetallicRoughness*":
	set(v):
		roughness_regex = v
		save_config()
@export var roughness_channel := BaseMaterial3D.TextureChannel.TEXTURE_CHANNEL_GREEN:
	set(v):
		roughness_channel = v
		save_config()
@export var normal_regex = "*Normal*":
	set(v):
		normal_regex = v
		save_config()
@export var textures_extension: Array[String] = [
	"png",
	"jpg",
	"jpeg"
]:
	set(v):
		textures_extension = v
		save_config()

var fully_loaded = false

func _init() -> void:
	load_config()
	fully_loaded = true

func load_config() -> void:
	var err = config.load(SETTINGS_FILE)
	if err == ERR_FILE_NOT_FOUND:
		save_config()
		err = config.load(SETTINGS_FILE)
	if err != OK:
		printerr("Config not loaded: %s" % err)
		return
	
	models_dir = config.get_value(MODELS_SECTION, "models_dir", models_dir)
	models_extension = config.get_value(MODELS_SECTION, "models_extension", models_extension)
	out_dir = config.get_value(MODELS_SECTION, "out_dir", out_dir)
	
	textures_dir = config.get_value(TEXTURES_SECTION, "textures_dir", textures_dir)
	albedo_regex = config.get_value(TEXTURES_SECTION, "albedo_regex", albedo_regex)
	mettalic_regex = config.get_value(TEXTURES_SECTION, "mettalic_regex", mettalic_regex)
	mettalic_channel = config.get_value(TEXTURES_SECTION, "mettalic_channel", mettalic_channel)
	roughness_regex = config.get_value(TEXTURES_SECTION, "roughness_regex", roughness_regex)
	roughness_channel = config.get_value(TEXTURES_SECTION, "roughness_channel", roughness_channel)
	normal_regex = config.get_value(TEXTURES_SECTION, "normal_regex", normal_regex)
	textures_extension = config.get_value(TEXTURES_SECTION, "textures_extension", textures_extension)
	
	notify_property_list_changed()

func save_config() -> void:
	if not fully_loaded:
		return
	
	config.set_value(MODELS_SECTION, "models_dir", models_dir)
	config.set_value(MODELS_SECTION, "models_extension", models_extension)
	config.set_value(MODELS_SECTION, "out_dir", out_dir)
	
	config.set_value(TEXTURES_SECTION, "textures_dir", textures_dir)
	config.set_value(TEXTURES_SECTION, "albedo_regex", albedo_regex)
	config.set_value(TEXTURES_SECTION, "mettalic_regex", mettalic_regex)
	config.set_value(TEXTURES_SECTION, "mettalic_channel", mettalic_channel)
	config.set_value(TEXTURES_SECTION, "roughness_regex", roughness_regex)
	config.set_value(TEXTURES_SECTION, "roughness_channel", roughness_channel)
	config.set_value(TEXTURES_SECTION, "normal_regex", normal_regex)
	config.set_value(TEXTURES_SECTION, "textures_extension", textures_extension)
	
	config.save(SETTINGS_FILE)

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

func textures_extensions_regex() -> String:
	return "(%s)" % "|".join(textures_extension)

func get_file_regex(name: String, middle: String) -> RegEx:
	# mi_ is for material instance
	var regex = RegEx.new()
	regex.compile("%s%s" % [name, middle])
	return regex

func get_albedo_regex(name: String) -> RegEx:
	return get_file_regex(name, albedo_regex)

func get_mettalic_regex(name: String) -> RegEx:
	return get_file_regex(name, mettalic_regex)

func get_roughness_regex(name: String) -> RegEx:
	return get_file_regex(name, roughness_regex)

func get_normal_regex(name: String) -> RegEx:
	return get_file_regex(name, normal_regex)


func correct_extension(path: String, extensions: Array) -> bool:
	if extensions.size() == 0:
		printerr("no extensions")
		return false
	var file_ext: String = path.get_extension()
	for ext in extensions:
		if file_ext.to_lower() == ext.to_lower():
			return true
	return false

func get_unreal_models():
	var files = get_dir_content(models_dir, true)
	var unreal_models = files.filter(correct_extension.bind([models_extension]))
	return unreal_models

func get_textures():
	var files = get_dir_content(textures_dir, true)
	return files.filter(correct_extension.bind(textures_extension))
