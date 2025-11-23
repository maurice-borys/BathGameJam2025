extends Area2D

class_name GruntSpawner

@export var spawn_entity: PackedScene
@export var set_mana_cost: float = 50.0
@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	var enemy = spawn_entity.instantiate()
	get_parent().add_child(enemy)  
	enemy.global_position = global_position 


func mana_cost():
	return set_mana_cost
