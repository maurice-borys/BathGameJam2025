extends TextureRect
class_name Cursor
var _build = false
@onready var unselected_texture: Texture2D = preload("res://Sprites/unselected.png")
@onready var wallpick_texture: Texture2D = preload("res://Sprites/skeleton left.png")

func _ready() -> void:
	show()
	# Ensure cursor is always on top
	z_index = 100
	
func copy_texture(node):
	for child in node.get_children():
		if child is Sprite2D:
			return child.texture.duplicate()
			
func unselected_cursor():
	_build = true
	texture = unselected_texture
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func building_cursor(building: Node):
	var child_texture = copy_texture(building)
	if child_texture:
		texture = child_texture
		_build = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		show()
		queue_redraw()
		
func wallbuild_cursor():
	_build = true
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func normal_cursor():
	_build = false
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _process(delta):
	# Get mouse position directly
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Try setting position directly (not global_position)
	position = mouse_pos
	
	
func _exit_tree():
	normal_cursor()
