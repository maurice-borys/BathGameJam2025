extends Area2D


var atk = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _init() -> void:
	collision_layer = 2
	collision_mask = 1
