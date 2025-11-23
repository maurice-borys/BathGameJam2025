extends TextureRect

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_level = true
	pivot_offset = size / 2
	top_level = true
	process_priority = 999
	hide()

func _process(delta):
	if visible:
		var mouse_pos = get_viewport().get_mouse_position()
		global_position = mouse_pos - pivot_offset

func _input(event):
	# This catches ALL input events first
	if event is InputEventMouseMotion and visible:
		global_position = event.global_position - pivot_offset
