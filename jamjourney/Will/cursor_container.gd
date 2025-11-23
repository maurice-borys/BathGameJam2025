extends MarginContainer

class_name Cursor

var _build = false
@onready var texture_rect = $BuildingCursor

@onready var init_texture = texture_rect.texture

func _ready() -> void:
	texture_rect.hide()

func build_cursor():
	_build = true
	texture_rect.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func normal_cursor():
	_build = false
	texture_rect.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func set_build_outline(texture: Texture2D):
	if _build:
		texture_rect.texture = texture
	else:
		texture_rect.texture = init_texture
	queue_redraw()


func _process(delta):
	# Get mouse position
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Center the texture on mouse
	position = mouse_pos - (texture_rect.size / 2)
	
func _exit_tree():
	normal_cursor()
