extends CharacterBody2D

var dir : float
var spawn_pos : Vector2
var spawn_rot : float
@export var speed = 800

func _ready() -> void:
	global_position = spawn_pos
	global_rotation = spawn_rot
	
func _physics_process(delta: float) -> void:
	velocity = Vector2(0,-speed).rotated(dir)
	move_and_slide()
