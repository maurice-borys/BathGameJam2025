extends CharacterBody2D

class_name Grunt

signal goto_command_path_start(path: CommandPath)

@export var speed: float = 100.0
@export var damadge: float = 1.0
@onready var click_area: Area2D = $ClickArea

@onready var nav_agent: NavigationAgent2D = $NavAgent
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var nav_timer: Timer = $NavTimer
@onready var sprite: Sprite2D = $Sprite
@export var godottexture: Texture2D

var holding = true
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
	### target player by default
	target = get_tree().get_first_node_in_group("player")
	if target:
		nav_agent.target_position = target.global_position

func _physics_process(delta: float) -> void:
	if not target:
		hold_position()
		return
		
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	var next_path_position = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_position)
	nav_agent.velocity = direction * speed

func set_selected(selected: bool):
	is_selected = selected
	queue_redraw()

func toggle_hold():
	if holding:
		holding = false
		target_player()
	else:
		holding = true
		hold_position()
	
func hold_position():
	free_all()
	holding = true
	velocity = Vector2.ZERO
	pointer_node = Node2D.new()
	get_parent().add_child(pointer_node)
	pointer_node.global_position = global_position
	set_target(pointer_node)

func goto(end: Vector2):
	free_all()
	pointer_node = Node2D.new()
	get_parent().add_child(pointer_node)
	pointer_node.global_position = end
	set_target(pointer_node)
	
func set_target(new_target: Node2D):
	if new_target:
		target = new_target
		nav_agent.target_position = new_target.global_position

func set_command_follow(new_follow: CommandPath):
	free_all()
	holding = false
	follow = new_follow
	target = follow.command_follow
	nav_agent.target_position = follow.command_follow.global_position

func _draw():
	if is_selected:
		draw_circle(Vector2.ZERO, 25, Color(0, 1, 0, 0.3))
		draw_arc(Vector2.ZERO, 25, 0, TAU, 32, Color(0, 1, 0), 2.0)

func free_pointer_node():
	if pointer_node:
		get_parent().remove_child(pointer_node)
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
	if holding:
		return

	if follow:
		if follow.finished:
			free_all()
			hold_position()
			
		elif not follow.going:
			follow.start()
		
	if pointer_node:
		free_all()
		hold_position()
	### turn off reacting to avoidance when attacking
	nav_agent.set_avoidance_mask_value(0b10, false)


func _on_nav_agent_path_changed() -> void:
	if nav_agent.is_target_reached():
		### turn off reacting to avoidance when attacking
		nav_agent.set_avoidance_mask_value(0b10, false)
	else:
		nav_agent.set_avoidance_mask_value(0b10, true)


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	attack_timer.start()
	

func _on_attack_timer_timeout() -> void:
	for body in attack_hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			var health = Health.findHealthModule(body)
			if health:
				health.dealDamage(damadge)
				
		
