extends Area2D
class_name PiercingSpell

@onready var timer = $Timer

var direction

@export var speed = 30
@export var lifeSpan = 2
@export var damage = 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(entered)
	
	timer.wait_time = lifeSpan
	timer.start()
	timer.timeout.connect(limitDepleted)

func _process(delta: float) -> void:
	position += direction * speed * delta

func entered(body : Node2D) -> void:
	Health.findHealthModule(body).dealDamage(damage)

func limitDepleted() -> void:
	queue_free()
