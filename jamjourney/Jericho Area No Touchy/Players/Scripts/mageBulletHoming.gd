extends Area2D
class_name HomingSpell

@export var damage : float = 10
@export var speed : float = 30
@export var rotationSpeed : float = 0.25
@export var minDistance : float = 10

var target : Node2D
var direction : Vector2 = Vector2.RIGHT

func _ready() -> void:
	self.body_entered.connect(bodyEntered)

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
	
	direction = lerp(direction, global_position.direction_to(target.global_position), rotationSpeed * delta)
	position += direction * speed * delta

func bodyEntered(body : Node2D):
	var healthMoule : Health = Health.findHealthModule(target)
	if healthMoule != null:
		healthMoule.dealDamage(damage)
		queue_free()
