@tool
extends HFlowContainer

@export var default_extensions = [
	"png",
	"jpg",
	"jpeg"
]

@onready var add_stuff_container: HBoxContainer = $AddStuffContainer

@onready var add_line_edit: LineEdit = $AddStuffContainer/AddLineEdit
@onready var add_button: Button = $AddStuffContainer/AddButton


func _ready() -> void:
	add_line_edit.hide()
	add_button.custom_minimum_size = Vector2.ONE * add_button.size.y
	for ext in default_extensions:
		var btn := create_extension_button(ext)
		add_child(btn)
	move_child(add_stuff_container, -1)

func create_extension_button(extension: String) -> Button:
	var btn := Button.new()
	btn.name = extension
	btn.text = extension
	btn.button_mask = MOUSE_BUTTON_MASK_RIGHT
	btn.pressed.connect(_on_extension_button_pressed.bind(btn))
	return btn

func _on_extension_button_pressed(btn: Button) -> void:
	btn.queue_free()


func _on_add_button_pressed() -> void:
	if add_line_edit.visible:
		_on_add_line_edit_text_submitted(add_line_edit.text)
	
	add_line_edit.text = ""
	add_line_edit.show()
	add_line_edit.grab_focus()

func _on_add_line_edit_text_submitted(text: String) -> void:
	add_line_edit.hide()
	var ext = text.replace(" ", "")
	if ext == "":
		return
	
	var btn = create_extension_button(text)
	add_child(btn)
	move_child(add_stuff_container, -1)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and add_line_edit.visible:
			add_line_edit.hide()


func _on_add_line_edit_focus_exited() -> void:
	_on_add_line_edit_text_submitted(add_line_edit.text)	
