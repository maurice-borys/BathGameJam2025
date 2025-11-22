extends CharacterBody2D

class_name Grunt

signal goto_command_path_start(path: CommandPath)

@export var speed: float = 100.0
@onready var click_area: Area2D = $ClickArea

@onready var nav_agent: NavigationAgent2D = $NavAgent
@onready var nav_timer: Timer = $NavTimer
@onready var sprite: Sprite2D = $Sprite
@export var godottexture: Texture2D


#@onready var skelebones: Texture2D = preload("res://Will/skeleton left.png")

var pointer_node: Node2D

var target: Node2D
var follow: CommandPath

var vel = Vector2.ZERO
var is_selected = false

func _ready():
	add_to_group("enemies")
	target_player()
	nav_agent.max_speed = speed

func target_player():
	target = get_tree().get_first_node_in_group("player")
	nav_agent.target_position = target.global_position

func _physics_process(delta: float) -> void:
	#if Engine.get_frames_drawn() % 60 == 0:
		#debug_state()
		
	if not target:
		target_player()
		return
		
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	var next_path_position = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_position)
	
	nav_agent.velocity = direction * speed

#func debug_state():
	#print("=== GRUNT: ", name, " ===")
	#print("Target: ", target)
	#print("Target name: ", target.name if target else "None")
	#print("Target position: ", target.global_position if target else "None")
	#print("Follow: ", follow)
	#if follow:
		#print("Follow instance ID: ", follow.get_instance_id())
		#print("Follow going: ", follow.going)
		#print("Follow finished: ", follow.finished)
		#print("Follow command_follow: ", follow.command_follow)
		#print("Follow command_follow position: ", follow.command_follow.global_position)
	#print("Pointer node: ", pointer_node)
	#print("Nav target position: ", nav_agent.target_position)
	#print("=========================")

func set_selected(selected: bool):
	is_selected = selected
	queue_redraw()
	
func goto(end: Vector2):
	free_all()
	pointer_node = Node2D.new()
	pointer_node.global_position = end
	add_child(pointer_node)
	set_target(pointer_node)
	
func set_target(new_target: Node2D):
	if new_target:
		free_all()
		target = new_target
		nav_agent.target_position = new_target.global_position

func set_command_follow(new_follow: CommandPath):
	free_all()
	
	follow = new_follow
	target = follow.command_follow
	nav_agent.target_position = follow.command_follow.global_position

func _draw():
	if is_selected:
		draw_circle(Vector2.ZERO, 25, Color(0, 1, 0, 0.3))
		draw_arc(Vector2.ZERO, 25, 0, TAU, 32, Color(0, 1, 0), 2.0)


func free_pointer_node():
	if pointer_node:
		remove_child(pointer_node)
		pointer_node.queue_free()
		pointer_node = null

func free_follow():
	if follow:
		follow.get_parent().remove_child(follow)
		follow.queue_free()
		follow = null

func free_all():
	free_follow()
	free_pointer_node()
	target = null


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
	

func _on_nav_agent_target_reached() -> void:
	velocity = Vector2.ZERO
	if follow:
		if follow.finished:
			free_all()
			target = null
			
		elif not follow.going:
			follow.start()
		
	if pointer_node:
		free_all()
		target = null
	### turn off reacting to avoidance when attacking
	nav_agent.set_avoidance_mask_value(0b10, false)


func _on_nav_agent_path_changed() -> void:
	if nav_agent.is_target_reached():
		### turn off reacting to avoidance when attacking
		nav_agent.set_avoidance_mask_value(0b10, false)
	else:
		nav_agent.set_avoidance_mask_value(0b10, true)
