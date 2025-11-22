extends CharacterBody2D

@export var speed: float = 100.0
@export var target: Node2D
@onready var click_area: Area2D = $ClickArea
@onready var nav_agent: NavigationAgent2D = $NavAgent
@onready var nav_timer: Timer = $NavTimer

var is_selected = false

func _ready():
	add_to_group("enemies")
	call_deferred("actor_setup")
	nav_timer.start()

func actor_setup():
	await get_tree().physics_frame
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]
	
	# Configure NavigationAgent
	nav_agent.path_desired_distance = 40.0
	nav_agent.target_desired_distance = 100.0
	nav_agent.max_speed = speed 

func _physics_process(delta: float) -> void:
	if not target:
		return
	
	# Calculate distance to target
	var distance_to_target = global_position.distance_to(target.global_position)
	
	# Get obstacle radius if it exists
	var obstacle_radius = 0.0
	for child in target.get_children():
		if child is NavigationObstacle2D:
			obstacle_radius = child.radius
			break
	
	# Stop if within range (including obstacle radius)
	var stop_distance = nav_agent.target_desired_distance + obstacle_radius
	if distance_to_target <= stop_distance:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Stop if navigation finished
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Calculate movement
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * speed
	nav_agent.set_velocity(new_velocity)

func set_selected(selected: bool):
	is_selected = selected
	queue_redraw()

func _draw():
	if is_selected:
		draw_circle(Vector2.ZERO, 25, Color(0, 1, 0, 0.3))
		draw_arc(Vector2.ZERO, 25, 0, TAU, 32, Color(0, 1, 0), 2.0)

func _on_nav_agent_velocity_computed(safe_velocity: Vector2) -> void:
	if not target:
		return
	
	# Check if we're moving toward or away from target
	var to_target = (target.global_position - global_position).normalized()
	var velocity_direction = safe_velocity.normalized()
	
	# Dot product: positive = moving toward, negative = moving away
	var dot_product = velocity_direction.dot(to_target)
	
	# Only apply velocity if moving toward target (or stopped)
	if dot_product > -0.1 or safe_velocity.length() < 1.0:
		velocity = safe_velocity
	else:
		# Moving away from target - stop instead
		velocity = Vector2.ZERO
	
	move_and_slide()

func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_tree().call_group("selection", "handle_enemy_click", self)

func _on_nav_timer_timeout() -> void:
	if target:
		nav_agent.target_position = target.global_position
