extends Node2D

class_name Selector

const DOUBLE_CLICK_TIME = 0.3

@onready var command_path: PackedScene = preload("res://Will/command_path.tscn")

var is_selecting = false
var is_commanding = false

var drag_start = Vector2.ZERO
var drag_end = Vector2.ZERO
var selected_units: Array[Grunt] = []

var last_empty_click_time = 0
var click_was_handled = false

var line: Line2D
var new_path: CommandPath


func _ready():
	add_to_group("selection")
	
	
	line = Line2D.new()
	line.width = 3
	line.default_color = Color.WHITE
	add_child(line)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		handle_click(event)
	elif event is InputEventMouseMotion and is_selecting:
		handle_drag(event)
	elif event is InputEventKey:
		if event.keycode == KEY_SPACE:
			handle_hold()
	
func handle_drag(event):
	drag_end = get_global_mouse_position()
	queue_redraw()
	
func handle_hold():
	if selected_units.is_empty():
		return
		
	var common = 0 
	for unit in selected_units:
		if unit.holding:
			common += 1
		else:
			common -= 1
	if common > 0:
		move_all()
	elif common < 0:
		hold_all()
	else:
		if selected_units[0].holding:
			move_all()
		else:
			hold_all()
	deselect_all()

func hold_all():
	for unit in selected_units:
		unit.hold_position()

func move_all():
	for unit in selected_units:
		unit.target_player()


func handle_click(event):
	if event.button_index == MOUSE_BUTTON_LEFT:
		select(event)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		command(event)

func select(event):
	var mouse_pos = get_global_mouse_position()
	if event.pressed:
		is_selecting = true
		drag_start = mouse_pos
		drag_end = drag_start
		click_was_handled = false
	else:
		var notDrag = drag_start.distance_to(drag_end) <= 15.0
		if notDrag:
			if not select_single(mouse_pos):
				handle_empty_click()
		else:
			select_units_in_box()	
		is_selecting = false
		queue_redraw()

func select_single(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 2  # Adjust based on your collision layers
	query.collide_with_areas = true
	var result = space_state.intersect_point(query)
	
	if result:
		for collision in result:
			var enemy = collision.collider
			if enemy.is_in_group("enemies"):
				handle_enemy_click(enemy)
				click_was_handled = true
				return true
	return false

func command(event):
	var mouse_pos = get_global_mouse_position()
	print(new_path, drag_start, drag_end)
	if event.pressed:
		is_commanding = true
		drag_start = mouse_pos
		drag_end = drag_start
		start_path(drag_start)
	else:
		is_commanding = false
		line.clear_points()
		if new_path.curve.get_point_count() == 1:
			register_goto(new_path.get_start_point(), selected_units)
		else:
			register_path(new_path, selected_units)
			queue_redraw()

func free_path():
	remove_child(new_path)
	new_path.queue_free()
	new_path = null
	drag_start = Vector2.ZERO
	drag_end = Vector2.ZERO
	
func register_path(command_path: CommandPath, selected_units: Array[Grunt]):
	for unit in selected_units:
		var unit_command_path = command_path.deepcopy()
		add_child(unit_command_path)
		unit.set_command_follow(unit_command_path)
	deselect_all()
	free_path()

func register_goto(point: Vector2, selected_units: Array[Grunt]):
	for unit in selected_units:
		unit.goto(point)
	deselect_all()
	free_path()

func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(2):
		add_point(get_global_mouse_position())
		queue_redraw()

func start_path(pos: Vector2):
	if new_path and is_instance_valid(new_path):
		new_path.curve.clear_points()
		free_path()

	make_path()
	line.clear_points()
	add_point(pos)

func make_path():
	new_path = command_path.instantiate()
	new_path.curve.clear_points()
	add_child(new_path)
	
func add_curve_point_safe(pos: Vector2):
	# Prevent duplicate points
	for i in new_path.curve.get_point_count():
		if new_path.curve.get_point_position(i).distance_to(pos) < 5.0:  # 5 pixel tolerance
			return
	
	new_path.curve.add_point(pos)

func add_point(pos: Vector2):
	if new_path:
		add_curve_point_safe(pos)
		line.add_point(pos)
	else:
		start_path(pos)

func handle_empty_click():
	var current_time = Time.get_ticks_msec() / 1000.0
	if (current_time - last_empty_click_time) < DOUBLE_CLICK_TIME:
		deselect_all()
		last_empty_click_time = 0 
	else:
		last_empty_click_time = current_time

func _draw():
	if is_selecting and drag_start.distance_to(drag_end) > 5:
		var rect = Rect2(drag_start, drag_end - drag_start)
		draw_rect(rect, Color(0, 1, 0, 0.2), true)
		draw_rect(rect, Color(0, 1, 0, 0.8), false, 2.0)

func select_units_in_box():
	if not Input.is_key_pressed(KEY_SHIFT):
		deselect_all()
	
	var box = Rect2(drag_start, drag_end - drag_start).abs()
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		if box.has_point(enemy.global_position):
			select_unit(enemy)

func handle_enemy_click(enemy):
	if Input.is_key_pressed(KEY_SHIFT):
		if enemy in selected_units:
			deselect_unit(enemy)
		else:
			select_unit(enemy)
	else:
		deselect_all()
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

func deselect_all():
	for unit in selected_units:
		unit.set_selected(false)
	selected_units.clear()

func get_selected_units():
	return selected_units
