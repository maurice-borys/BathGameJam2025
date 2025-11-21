extends Node2D

@export var maxHealth : float

signal healthChanged(oldHealth, newHealth)
var health : float

func _ready() -> void:
	health = maxHealth

func dealDamage(damage : float) -> void:
	var newHealth = clamp(health - damage, 0, maxHealth)
	healthChanged.emit(health, newHealth)
	health = newHealth
	
func healHealth(amount : float) -> void:
	var newHealth = clamp(health + amount, 0, maxHealth)
	healthChanged.emit(health, newHealth)
	health = newHealth
	
func getHealth() -> float:
	return health
