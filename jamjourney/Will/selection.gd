extends Node2D

const DOUBLE_CLICK_TIME = 0.3

var is_dragging = false
var drag_start = Vector2.ZERO
var drag_end = Vector2.ZERO
var selected_units = []

var last_empty_click_time = 0
var click_was_handled = false

func _ready():
	add_to_group("selection")

func _unhandled_input(event):
	if event is InputEventMouseButton:
		handle_click(event)
	elif event is InputEventMouseMotion and is_dragging:
		handle_drag(event)
	

func handle_drag(event):
	drag_end = get_global_mouse_position()
	queue_redraw()
	
func handle_click(event):
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_start = get_global_mouse_position()
			drag_end = drag_start
			click_was_handled = false
		else:
			var isDrag = drag_start.distance_to(drag_end) <= 5
			if isDrag:
				await get_tree().process_frame
				if not click_was_handled:
					handle_empty_click()
			else:
				select_units_in_box()	
			is_dragging = false
			queue_redraw()
	

func handle_empty_click():
	var current_time = Time.get_ticks_msec() / 1000.0
	if (current_time - last_empty_click_time) < DOUBLE_CLICK_TIME:
		clear_selection()
		last_empty_click_time = 0 
	else:
		last_empty_click_time = current_time

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
	click_was_handled = true
	if Input.is_key_pressed(KEY_SHIFT):
		toggle_selection(enemy)
	else:
		clear_selection()
		select_unit(enemy)


func toggle_selection(unit):
	if unit in selected_units:
		selected_units.erase(unit)
		unit.set_selected(false)
	else:
		selected_units.append(unit)
		unit.set_selected(true)
		

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
