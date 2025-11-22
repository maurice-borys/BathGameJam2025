extends Node2D

class_name PathManager

@onready var active_paths: Dictionary = {}


func _ready() -> void:
	pass # Replace with function body.


func register_path(command_path: CommandPath, selected_units: Array[Grunt]):
	var id = command_path.get_instance_id()
	active_paths[id] = command_path
	command_path.path_completed.connect(_on_path_completed)
	for unit in selected_units:
		unit.set_target(command_path.command_follow)
	command_path.start()

func _on_path_completed(command_path: CommandPath):
	var id = command_path.get_instance_id()
	active_paths.erase(id) 
	command_path.get_parent().queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
