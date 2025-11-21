extends CharacterBody2D

var target : Vector2 = Vector2 (40, 0)

@onready var agent : NavigationAgent2D = $NavigationAgent2D

@export var speed : float = 10
@export var range : float = 0.5

func _ready() -> void:
	agent.target_position = target

func _physics_process(delta: float) -> void:
	if position.distance_to(target) > range:
		move()

func move() -> void:
	var pathPos = agent.get_next_path_position()
	var newVelocity = Vector2 (global_position.direction_to(pathPos) * speed)
	velocity = newVelocity
	move_and_slide()
