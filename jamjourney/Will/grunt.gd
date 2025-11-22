extends CharacterBody2D

class_name Grunt

@export var speed: float = 100.0
@onready var click_area: Area2D = $ClickArea

@onready var nav_agent: NavigationAgent2D = $NavAgent
@onready var nav_timer: Timer = $NavTimer
@onready var sprite: Sprite2D = $Sprite
@export var godottexture: Texture2D

@onready var skelebones: Texture2D = preload("res://Will/skeleton left.png")

var pointer_node: Node2D

var target: Node2D

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
	if not target:
		target_player()
		return
	
	if nav_agent.is_target_reached():
		if pointer_node:
			remove_child(pointer_node)
			pointer_node.queue_free()
			pointer_node = null
			return
			
		velocity = Vector2.ZERO
		### turn off reacting to avoidance when attacking
		nav_agent.set_avoidance_mask_value(0b10, false)
		sprite.texture = godottexture
		sprite.scale = Vector2(0.3,0.3)
		return
		
	nav_agent.set_avoidance_mask_value(0b10, true)
	sprite.texture = skelebones
		
	if nav_agent.is_navigation_finished():
		return
	
	var next_path_position = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_position)
	
	nav_agent.velocity = direction * speed

func set_selected(selected: bool):
	is_selected = selected
	queue_redraw()
	
func goto(end: Vector2):
	pointer_node = Node2D.new()
	pointer_node.global_position = end
	add_child(pointer_node)
	target = pointer_node
	
func set_target(new_target: Node2D):
	target = new_target
	nav_agent.target_position = new_target.global_position

func _draw():
	if is_selected:
		draw_circle(Vector2.ZERO, 25, Color(0, 1, 0, 0.3))
		draw_arc(Vector2.ZERO, 25, 0, TAU, 32, Color(0, 1, 0), 2.0)


func _on_nav_agent_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("CLICKED")
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_tree().call_group("selection", "handle_enemy_click", self)
