extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NavigationServer2D.set_debug_enabled(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
