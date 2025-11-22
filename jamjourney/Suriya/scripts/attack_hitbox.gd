extends Area2D

var atk = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _init() -> void:
	collision_layer = 1
	collision_mask = 2

func attack() -> void:
	if Input.is_action_just_pressed("right_click"):
		pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
