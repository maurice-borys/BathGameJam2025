extends Path2D

class_name CommandPath

signal path_completed(command_path)

@onready var command_follow: PathFollow2D = $CommandFollow
var going = false
@export var speed: float = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curve = curve.duplicate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	### checks to see if path follow at end
	if command_follow.progress_ratio == 1.0:
		path_completed.emit(self)
	if going:
		command_follow.progress += speed * delta
	pass


func start():
	going = true
