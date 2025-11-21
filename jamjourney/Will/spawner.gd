extends Area2D

@export var spawn_entity: PackedScene

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	var enemy = spawn_entity.instantiate()
	get_parent().add_child(enemy)  # Add this!
	enemy.global_position = global_position  # Position it


func _process(delta: float) -> void:
	pass
