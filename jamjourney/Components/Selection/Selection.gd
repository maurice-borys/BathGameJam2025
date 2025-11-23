extends Node2D

class_name Selector

const DOUBLE_CLICK_TIME = 0.3

@export var mana_manager: ManaGer
@export var nav_mesh : NavigationRegion2D
@export var cursor: Cursor
@onready var place_timer: Timer = $PlaceTimer
@onready var command_path: PackedScene = preload("res://Components/Selection/CommandPath.tscn")
@onready var spawner: PackedScene = preload("res://Scenes/Buildings/Spawner/Spawner.tscn")
@onready var wall: PackedScene = preload("res://Scenes/Buildings/Wall/wall.tscn")

@onready var keymap: Dictionary = {
	KEY_2 : spawner,
}

var is_selecting = false
var is_commanding = false
var build_mode = false
var wall_build = false
var can_place = true

var drag_start = Vector2.ZERO
var drag_end = Vector2.ZERO
var wall_start = Vector2.ZERO
var selected_units: Array[Variant] = []

var last_empty_click_time = 0

var line: Line2D
var new_path: CommandPath

var current_building_scene: PackedScene
var preview_building: Node
var new_wall: WallClass

func _ready():
	add_to_group("selection")
	print("Selector position: ", global_position)  # Debug this
	
	line = Line2D.new()
	line.width = 3
	line.default_color = Color.WHITE
	add_child(line)

func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and is_commanding and not build_mode:
		add_point(get_global_mouse_position())
		queue_redraw()

func _input(event):
	if build_mode:
		handle_building_mode(event)
	else:
		handle_normal(event)

func make_dummy_instance(scene: PackedScene) -> Node:
	var dummy = scene.instantiate()
	add_child(dummy)
	dummy.set_process(false)
	dummy.visible = false
	return dummy
			

func handle_building_mode(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		remove_wall()
		deselect_building()
		cursor.unselected_cursor()
	
	if not can_place:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if wall_build:
			if new_wall:
				place_wall(get_global_mouse_position())
			else:
				build_wall(get_global_mouse_position())
		else:
			handle_build()
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R: 
				remove_wall()
				deselect_building()
				cursor.normal_cursor()
				build_mode = false
			KEY_1 : 
				wall_build = true
				if not new_wall:
					build_wall(get_global_mouse_position())
			_:
				select_building(event.keycode)
				wall_build = false


func place_wall(point: Vector2):
	if not new_wall or not is_instance_valid(new_wall):
		return
	
	new_wall.endPoint = point
	
	# Wait one frame for physics to update
	await get_tree().process_frame
	
	if new_wall.will_collide():
		print("Cannot place wall - collision detected")
		new_wall.queue_free()
		new_wall = null
		can_place = false
		place_timer.start()
		return
	
	var wall_cost = new_wall.cost()
	if not mana_manager.can_afford(wall_cost):
		print("Cannot afford wall - costs ", wall_cost)
		new_wall.queue_free()
		new_wall = null
		can_place = false
		place_timer.start()
		return
	
	# Place the wall
	mana_manager.spend(wall_cost)
	new_wall.init()
	new_wall = null
	can_place = false
	place_timer.start()
		
 
func remove_wall():
	wall_build = false
	if new_wall and is_instance_valid(new_wall):
		new_wall.queue_free()
		new_wall = null
	queue_redraw()

func deselect_building():
	if preview_building and is_instance_valid(preview_building):
		preview_building.queue_free()
	preview_building = null
	current_building_scene = null

func build_wall(start: Vector2):
	cursor.wallbuild_cursor()
	new_wall = wall.instantiate()
	new_wall.position = start
	new_wall.rebakeMesh.connect(overcook)
	new_wall.deleteWall.connect(delete_wall)
	nav_mesh.add_child(new_wall)
	can_place = false
	place_timer.start()
	

func overcook():
	if nav_mesh.is_baking():
		return
		
	nav_mesh.bake_navigation_polygon()

func delete_wall(body: Node2D):
	if body and is_instance_valid(body):
		body.get_parent().remove_child(body)
		body.queue_free()
		
		# Rebake navigation mesh
		if nav_mesh and not nav_mesh.is_baking():
			nav_mesh.bake_navigation_polygon()
	
	
func copy_collider(node) -> Variant:
	for child in node.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			return child.duplicate()
	return null

func select_building(keycode):
	if keycode not in keymap:
		return
	
	if preview_building and is_instance_valid(preview_building):
		preview_building.queue_free()
		
	current_building_scene = keymap[keycode]
	preview_building = make_dummy_instance(current_building_scene)
	
	cursor.building_cursor(preview_building)
	queue_redraw()

func handle_build():
	var mouse_pos = get_global_mouse_position()
	if not preview_building:
		return
	
	var collision_shape = get_collision_shape(preview_building)
	if not collision_shape or not collision_shape.shape:
		return
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	query.transform = Transform2D(0, mouse_pos)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 0b1111
	
	var collisions = space_state.intersect_shape(query)
	
	if collisions.is_empty():
		if mana_manager.can_place(preview_building):
			var place_building = current_building_scene.instantiate()
			place_building.position = mouse_pos
			get_tree().current_scene.add_child(place_building)
			can_place = false
			place_timer.start()		
	
	if preview_building and is_instance_valid(preview_building):
		preview_building.queue_free()
		
	preview_building = make_dummy_instance(current_building_scene)
	queue_redraw()

func get_collision_shape(node: Node) -> CollisionShape2D:
	for child in node.get_children():
		if child is CollisionShape2D:
			return child
		# Search recursively in children
		var found = get_collision_shape(child)
		if found:
			return found
	return null
	
func handle_normal(event):
	if event is InputEventMouseButton:
		handle_click(event)
	elif event is InputEventMouseMotion and is_selecting:
		handle_drag(event)
	
	### mouse eats all input if considered together
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				handle_hold()
			KEY_R: 
				build_mode = true
				cursor.unselected_cursor()
				line.clear_points()  # ADD THIS
				is_commanding = false 


func handle_drag(_event):
	drag_end = get_global_mouse_position()
	queue_redraw()
	
func handle_hold():
	if selected_units.is_empty():
		return
		
	var common = 0 
	for unit in selected_units:
		if unit.nav_component.holding:
			common += 1
		else:
			common -= 1
	if common > 0:
		move_all()
	elif common < 0:
		hold_all()
	else:
		if selected_units[0].nav_component.holding:
			move_all()
		else:
			hold_all()
	deselect_all()

func hold_all():
	for unit in selected_units:
		unit.nav_component.hold_position()

func move_all():
	for unit in selected_units:
		unit.nav_component.target_player()

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
	query.collision_mask = 2 
	query.collide_with_areas = true
	var result = space_state.intersect_point(query)
	
	if result:
		for collision in result:
			var enemy = collision.collider
			if enemy.is_in_group("enemies"):
				handle_enemy_click(enemy)
				return true
	return false

func command(event):
	if build_mode:
		return

	var mouse_pos = get_global_mouse_position()
	if event.pressed:
		is_commanding = true
		drag_start = mouse_pos
		drag_end = drag_start
		start_path(drag_start)
	else:
		is_commanding = false
		line.clear_points()
		if new_path.curve.get_point_count() == 1:
			register_goto()
		else:
			register_path()
		queue_redraw()

func free_path():
	remove_child(new_path)
	new_path.queue_free()
	new_path = null
	drag_start = Vector2.ZERO
	drag_end = Vector2.ZERO
	
func register_path():
	for unit in selected_units:
		var unit_command_path = new_path.deepcopy()
		add_child(unit_command_path)
		unit.nav_component.set_command_follow(unit_command_path)
	deselect_all()
	free_path()

func register_goto():
	var point = new_path.get_start_point()
	for unit in selected_units:
		unit.nav_component.goto(point)
	deselect_all()
	free_path()

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
	if is_selecting and drag_start.distance_to(drag_end) > 5 and not build_mode:
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
		unit.nav_component.set_selected(true)

func deselect_unit(unit):
	if unit in selected_units:
		selected_units.erase(unit)
		unit.nav_component.set_selected(false)

func deselect_all():
	for unit in selected_units:
		unit.nav_component.set_selected(false)
	selected_units.clear()

func get_selected_units():
	return selected_units


func _on_wall_timer_timeout() -> void:
	can_place = true
	
