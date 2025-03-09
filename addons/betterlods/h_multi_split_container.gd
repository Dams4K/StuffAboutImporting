extends HSplitContainer
class_name HMultiSplitContainer

var to_update: HSplitContainer
var number_of_childrens: int = 0

var dragged_hsplit_idx := -1
var dragged_hsplit: HSplitContainer
var start_offset := 0.0

var real_offsets: Array[float] = []

func _ready() -> void:
	if get_child_count() > 2:
		var childrens: Array[Node] = get_children()
		var child_count: int = get_child_count()
		
		var parent: Control = self
		for i in range(child_count-1):
			var child = childrens[i]
			if not (child is Control):
				continue
			
			var new_hsplit := HSplitContainer.new()
			new_hsplit.name = "created_hsplit_%s" % i
			new_hsplit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			new_hsplit.size_flags_stretch_ratio = child_count-i
			#new_hsplit.dragged.connect(_on_hsplit_dragged.bind(new_hsplit))
			new_hsplit.drag_started.connect(_on_drag_started.bind(new_hsplit))
			new_hsplit.drag_ended.connect(_on_drag_ended.bind(new_hsplit))
			parent.add_child(new_hsplit)
			real_offsets.append(new_hsplit.split_offset) # at pos i
			
			remove_child(child)
			new_hsplit.add_child(child)
			
			parent = new_hsplit
		remove_child(childrens[-1])
		parent.add_child(childrens[-1])

func _on_drag_started(hsplit: HSplitContainer):
	var childrens = hsplit.find_children("created_hsplit_*", "HSplitContainer", false, false)
	number_of_childrens = hsplit.find_children("created_hsplit_*", "HSplitContainer", true, false).size()
	if not childrens.is_empty():
		to_update = childrens[0]
	
	dragged_hsplit_idx = hsplit.name.split("_")[-1].to_int()
	dragged_hsplit = hsplit
	start_offset = hsplit.split_offset

func _on_drag_ended(hsplit: HSplitContainer):
	real_offsets[dragged_hsplit_idx] = hsplit.split_offset
	
	#for i in range(to_update.size()):
		#var child: HSplitContainer = to_update[i]
		#var child_idx = child.name.split("_")[-1].to_int()
	#
	#to_update = []
	#to_update2 = []
	var child: HSplitContainer = to_update
	var child_idx = child.name.split("_")[-1].to_int()
	real_offsets[child_idx] = child.split_offset
	
	
	dragged_hsplit_idx = -1
	dragged_hsplit = null
	start_offset = 0.0

func _process(delta: float) -> void:
	if dragged_hsplit == null or dragged_hsplit_idx < 0:
		return
	
	var delta_offset = start_offset - dragged_hsplit.split_offset
	#print(delta_offset)
	#for j in range(to_update.size()):
		#var child: HSplitContainer = to_update[j]
		#var child_idx = child.name.split("_")[-1].to_int()
		#var i = child_idx - dragged_hsplit_idx
		##printt(child.name, 2*i+1)
		##printt(to_update.size(), ( (float(to_update.size()-1))/2 ))
		#if child.name.ends_with("2"):
			#printt(child.name, child_idx)
			##printt(i, to_update.size(), float(i)/to_update.size())
			##printt(delta_offset/(2*i-float(i)/to_update.size()), delta_offset/(2*i-0.6666667))
		## 0
		## -0.5
			##child.split_offset = real_offsets[child_idx] + (delta_offset/(2*i-0.6666667) * (-1**(j)))
			##child.split_offset = real_offsets[child_idx] + delta_offset/(2*i-float(i)/to_update.size() * (-1**(j)))
			##child.split_offset = real_offsets[child_idx] + delta_offset/(2*i-4) * (-1**(j))
			#child.split_offset = delta_offset/1.33333
		#if child.name.ends_with("3"):
			##child.split_offset = -delta_offset/1
			#pass
	
	
	if to_update != null and number_of_childrens != 0:
		var child: HSplitContainer = to_update
		var child_idx = child.name.split("_")[-1].to_int()
		var divide_by = float(5-child_idx+1) / number_of_childrens
		child.split_offset = delta_offset/divide_by
