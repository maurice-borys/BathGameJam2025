extends CharacterBody2D

@export var speed: float = 100.0
@onready var click_area: Area2D = $ClickArea

@onready var nav_agent: NavigationAgent2D = $NavAgent
@onready var nav_timer: Timer = $NavTimer
var target: Node2D

var is_selected = false

func _ready():
	add_to_group("enemies")
	target = get_tree().get_first_node_in_group("player")
	nav_agent.max_speed = speed
	nav_agent.target_position = target.global_position

func _physics_process(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	
	# Get the next path position
	var next_path_position = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_position)
	
	# Set desired velocity for avoidance system
	nav_agent.velocity = direction * speed

func set_selected(selected: bool):
	is_selected = selected
	queue_redraw()

func _draw():
	if is_selected:
		draw_circle(Vector2.ZERO, 25, Color(0, 1, 0, 0.3))
		draw_arc(Vector2.ZERO, 25, 0, TAU, 32, Color(0, 1, 0), 2.0)

func _on_nav_agent_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_tree().call_group("selection", "handle_enemy_click", self)

func _on_nav_timer_timeout() -> void:
	if target:
		nav_agent.target_position = target.global_position
	nav_timer.start()
