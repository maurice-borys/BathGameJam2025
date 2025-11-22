extends CharacterBody2D
@export var speed = 100
@onready var click_area: Area2D = $ClickArea
@onready var nav_agent: NavigationAgent2D = $NavAgent
@onready var nav_timer: Timer = $NavTimer
var is_selected = false
var target: Node2D

func _ready():
	add_to_group("enemies")
	target = get_tree().get_first_node_in_group("player")
	call_deferred("actor_setup")
	nav_timer.start()

func actor_setup():
	await get_tree().physics_frame
	
	### going inside the radius is spooky
	var obstacle_radius = 0.0
	if target and target.has_node("NavigationObstacle2D"):
		obstacle_radius = target.get_node("NavigationObstacle2D").radius
	
	# Configure NavigationAgent
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 10.0 + obstacle_radius
	nav_agent.max_speed = speed 
	
func _physics_process(delta: float) -> void:
	# Check if navigation is finished before calculating movement
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	print(direction)
	nav_agent.set_velocity(direction * speed * delta)

func set_selected(selected: bool):
	is_selected = selected
	queue_redraw()

func _draw():
	if is_selected:
		draw_circle(Vector2.ZERO, 25, Color(0, 1, 0, 0.3))
		draw_arc(Vector2.ZERO, 25, 0, TAU, 32, Color(0, 1, 0), 2.0)

func _on_nav_agent_velocity_computed(safe_velocity: Vector2) -> void:
	print("velocity", safe_velocity)
	velocity = safe_velocity
	move_and_slide()

func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_tree().call_group("selection", "handle_enemy_click", self)

func _on_nav_timer_timeout() -> void:
	print("recalculating")
	nav_agent.target_position = target.global_position
	nav_timer.start()
