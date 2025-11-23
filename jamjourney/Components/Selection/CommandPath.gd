extends Path2D

class_name CommandPath

signal path_completed(command_path)

@onready var command_follow: PathFollow2D = $CommandFollow
@onready var sprite: Sprite2D = $CommandFollow/Sprite2D
var going = false
var finished = false
@export var speed: float = 20.0

func deepcopy() -> CommandPath:
	var copy = load("res://Components/Selection/CommandPath.tscn").instantiate()
	copy.curve = curve.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	return copy


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if going:
		### checks to see if path follow at end
		if command_follow.progress_ratio >= 1.0:
			path_completed.emit(self)
			going = false
			finished = true
		command_follow.progress += speed * delta

func get_start_point() -> Vector2:
	return curve.get_point_position(0)

func remove_sprite():
	sprite.texture = null

func start():
	going = true
