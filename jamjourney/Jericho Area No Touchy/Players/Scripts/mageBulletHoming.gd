extends Node2D
class_name HomingSpell

@export var damage : float = 10
@export var speed : float = 30
@export var rotationSpeed : float = 0.25
@export var minDistance : float = 10

var target : Node2D
var direction : Vector2 = Vector2.RIGHT

func _process(delta: float) -> void:
	direction = lerp(direction, global_position.direction_to(target.global_position), rotationSpeed * delta)
	position += direction * speed * delta
	
	if global_position.distance_to(target.global_position) < minDistance:
		var healthMoule : Health = Health.findHealthModule(target)
		healthMoule.dealDamage(damage)
		queue_free()
