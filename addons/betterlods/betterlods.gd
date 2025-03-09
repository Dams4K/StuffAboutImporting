@tool
extends EditorPlugin

var editor_inspector: EditorInspector

func _enter_tree() -> void:
	editor_inspector = EditorInterface.get_inspector()
	editor_inspector.edited_object_changed.connect(_on_node_selected)
	
	#add_custom_type("LODStacker3D", "Node3D", preload("res://addons/betterlods/lod_stacker_3d.gd"), null)


func _on_node_selected() -> void:
	var selected_node: Node = editor_inspector.get_edited_object()
	if selected_node is LODStacker3D:
		search_lod_range(editor_inspector)
		#print_children(editor_inspector)

func search_lod_range(node: Node):
	var size_y := 0.0
	var container: HBoxContainer
	
	var childs: Array[Node] = node.get_children()
	while not childs.is_empty():
		var child = childs.pop_front()
		if child.get("label") == "LOD Range":
			container = child.get_children()[0]
		elif child.get("label") == "LOD Size":
			size_y = child.size.y
			child.hide()
		childs.append_array(child.get_children())
	
	if container == null:
		push_error("Container not found")
		return
	add_lod_range(size_y, container)

func add_lod_range(size_y: float, container: Container):
	var text_edit: TextEdit
	for child in container.get_children():
		if child is TextEdit:
			text_edit = child
			child.hide()
		
	assert(text_edit != null, "text_edit should'nt be null")
	

func print_children(node):
	for child: Node in node.get_children():
		printt(child.get("label"), child.get("text"), child )
		print_children(child)

func _exit_tree() -> void:
	#remove_custom_type("LODStacker3D")
	pass
