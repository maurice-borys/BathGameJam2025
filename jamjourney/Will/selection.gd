extends Node2D

var is_dragging = false
var drag_start = Vector2.ZERO
var drag_end = Vector2.ZERO
var selected_units = []

func _ready():
	add_to_group("selection")

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start = get_global_mouse_position()
				drag_end = drag_start
			else:
				if drag_start.distance_to(drag_end) > 5:
					select_units_in_box()
				
				is_dragging = false
				queue_redraw()
	
	elif event is InputEventMouseMotion and is_dragging:
		drag_end = get_global_mouse_position()
		queue_redraw()

func _draw():
	if is_dragging and drag_start.distance_to(drag_end) > 5:
		var rect = Rect2(drag_start, drag_end - drag_start)
		draw_rect(rect, Color(0, 1, 0, 0.2), true)
		draw_rect(rect, Color(0, 1, 0, 0.8), false, 2.0)

func select_units_in_box():
	if not Input.is_key_pressed(KEY_SHIFT):
		clear_selection()
	
	var box = Rect2(drag_start, drag_end - drag_start).abs()
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		if box.has_point(enemy.global_position):
			select_unit(enemy)

func handle_enemy_click(enemy):
	if Input.is_key_pressed(KEY_CTRL):
		if enemy in selected_units:
			deselect_unit(enemy)
		else:
			select_unit(enemy)
	elif Input.is_key_pressed(KEY_SHIFT):
		select_unit(enemy)
	else:
		clear_selection()
		select_unit(enemy)

func select_unit(unit):
	if unit not in selected_units:
		selected_units.append(unit)
		unit.set_selected(true)
		print("Selected: ", unit.name)

func deselect_unit(unit):
	if unit in selected_units:
		selected_units.erase(unit)
		unit.set_selected(false)

func clear_selection():
	for unit in selected_units:
		unit.set_selected(false)
	selected_units.clear()

func get_selected_units():
	return selected_units
