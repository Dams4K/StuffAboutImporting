extends Node3D
class_name LODStacker3D

# Will give what a normal lineedit size is
@export var lod_size: String
# Everything will be stored in string
# but the ui need more space than what a line edit gives
@export_multiline var lod_range: String

@export var meshs: Array[Mesh] = []
