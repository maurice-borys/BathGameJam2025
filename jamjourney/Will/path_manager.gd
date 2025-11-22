extends Node

class_name PathManager

@onready var active_paths: Dictionary = {}

func register_path(command_path: CommandPath, selected_units: Array[Grunt]):
	for unit in selected_units:
		var unit_command_path = command_path.deepcopy()
		add_child(unit_command_path)
		unit.set_command_follow(unit_command_path)
	#command_path.remove_sprite()
		

func more_path(command_path: CommandPath):
	print(command_path)
	command_path.start()

func register_goto(point: Vector2, selected_units: Array[Grunt]):
	for unit in selected_units:
		unit.goto(point)
	
func _on_path_completed(command_path: CommandPath):
	var id = command_path.get_instance_id()
	active_paths.erase(id) 
	command_path.get_parent().queue_free()
